// Pure logic: which ticket a branch names, and how the Linear MCP's answers
// become a Panel. No `$` here, so the tests can drive it directly.

import type { Panel, Pr, Progress, Ticket } from '../types'

const ID = /(?:^|[/_.])([a-z][a-z0-9]{1,9})-(\d+)(?=$|[-_/.])/gi
const EXACT_ID = /^[A-Za-z][A-Za-z0-9]{1,9}-\d+$/

export const isIdentifier = (s: string) => EXACT_ID.test(s)

/** Ticket identifiers a branch or folder name spells, in order, uppercased. */
export function identifiersIn(...names: (string | null | undefined)[]): string[] {
  const found: string[] = []
  for (const name of names) {
    if (!name) continue
    for (const m of name.matchAll(ID)) {
      const id = `${(m[1] ?? '').toUpperCase()}-${m[2]}`
      if (!found.includes(id)) found.push(id)
    }
  }
  return found
}

/** The git config key that pins a ticket to a branch. */
export const pinKey = (branch: string) => `branch.${branch}.linear-issue`

export const ISSUE_FIELDS = [
  'title', 'url', 'status', 'statusType', 'assignee', 'labels',
  'project', 'projectMilestone', 'attachments', 'relations', 'description',
]
export const ROW_FIELDS = ['title', 'url', 'status', 'statusType', 'assignee', 'labels', 'projectMilestone', 'attachments']

/* What the Linear MCP answers (the parts read here). */
export type McpIssue = {
  id: string
  title: string
  url: string
  status: string
  statusType: string
  assignee?: string | null
  labels?: string[] | null
  project?: string | null
  projectMilestone?: { id: string; name: string } | null
  attachments?: { url: string; title?: string | null }[] | null
  relations?: {
    relatedTo?: { id: string }[]
    blocks?: { id: string }[]
    blockedBy?: { id: string }[]
  } | null
  description?: string | null
}
export type McpProject = {
  id: string
  name: string
  status?: { name: string } | null
  targetDate?: string | null
  milestones?: { id: string; name: string; targetDate?: string | null; progress?: string | number }[]
}

const STATE_COLOR: Record<string, string> = {
  started: 'warning',
  completed: 'success',
  canceled: 'inactive',
  backlog: 'subtle',
  unstarted: 'text',
  triage: 'subtle',
}

const PR_URL = /^https:\/\/github\.com\/([^/]+)\/([^/]+)\/pull\/(\d+)/

/** PR links among a ticket's attachments, as `owner/repo#n` keys. */
export function prKeys(issue: McpIssue): string[] {
  return (issue.attachments ?? []).flatMap(a => {
    const m = a.url.match(PR_URL)
    return m ? [`${m[1]}/${m[2]}#${m[3]}`] : []
  })
}

function linkedPr(key: string): Pr {
  const [repo, n] = key.split('#')
  return { number: Number(n), state: 'linked', url: `https://github.com/${repo}/pull/${n}`, review: null, checks: null }
}

export function toTicket(issue: McpIssue, prs: ReadonlyMap<string, Pr>): Ticket {
  return {
    identifier: issue.id,
    title: issue.title,
    url: issue.url,
    stateName: issue.status,
    stateType: issue.statusType,
    stateColor: STATE_COLOR[issue.statusType] ?? 'text',
    assignee: issue.assignee || null,
    labels: issue.labels ?? [],
    milestone: issue.projectMilestone?.name ?? null,
    prs: prKeys(issue).map(k => prs.get(k) ?? linkedPr(k)),
  }
}

export const isMap = (t: Ticket) => t.labels.some(l => l.toLowerCase() === 'wayfinder:map')
const isWayfinder = (t: Ticket) =>
  t.labels.some(l => l.toLowerCase().startsWith('wayfinder:')) || /wayfinder/i.test(t.milestone ?? '')

/** Identifiers named in the map body's "## Out of scope" section. */
export function outOfScope(description: string | null | undefined): Set<string> {
  const out = new Set<string>()
  if (!description) return out
  const m = description.match(/^#{1,6}\s*Out of scope\s*$([\s\S]*?)(?=^#{1,6}\s|$(?![\s\S]))/im)
  for (const id of (m?.[1] ?? '').matchAll(/\b([A-Z][A-Z0-9]{1,9}-\d+)\b/g)) if (id[1]) out.add(id[1])
  return out
}

/** A map's related, blocking and blocked issues worth fetching (out-of-scope ones left out). */
export function relatedIds(map: McpIssue): string[] {
  const excluded = outOfScope(map.description)
  const r = map.relations ?? {}
  const ids = [...(r.relatedTo ?? []), ...(r.blocks ?? []), ...(r.blockedBy ?? [])].map(x => x.id)
  return [...new Set(ids)].filter(id => id !== map.id && !excluded.has(id))
}

/**
 * A wayfinder map's implementation tickets: its related issues and children
 * that are not wayfinder tickets (map or decision), not in the wayfinder
 * milestone, and not ruled out of scope in the map body.
 */
export function implementationTickets(map: McpIssue, candidates: readonly McpIssue[], prs: ReadonlyMap<string, Pr>): Ticket[] {
  const excluded = outOfScope(map.description)
  const seen = new Map<string, Ticket>()
  for (const c of candidates) {
    const t = toTicket(c, prs)
    if (t.identifier === map.id || isWayfinder(t) || excluded.has(t.identifier)) continue
    seen.set(t.identifier, t)
  }
  return [...seen.values()].sort(byStateThenId)
}

const ORDER = ['started', 'unstarted', 'backlog', 'triage', 'completed', 'canceled']
const rank = (t: Ticket) => {
  const i = ORDER.indexOf(t.stateType)
  return i === -1 ? ORDER.length : i
}
function byStateThenId(a: Ticket, b: Ticket) {
  return rank(a) - rank(b) || a.identifier.localeCompare(b.identifier, undefined, { numeric: true })
}

/** Done over the items that still count (canceled ones drop out). */
export function completion(items: readonly { stateType: string }[]): { done: number; total: number } {
  const counted = items.filter(t => t.stateType !== 'canceled')
  return { done: counted.filter(t => t.stateType === 'completed').length, total: counted.length }
}

const fraction = (v: string | number | undefined) => {
  const n = typeof v === 'number' ? v : Number(String(v ?? '').replace('%', ''))
  return Number.isFinite(n) ? n / 100 : 0
}

export type PanelInput = {
  issue: McpIssue
  branch: string
  isPinned: boolean
  fetchedAt: number
  prs: ReadonlyMap<string, Pr>
  livePr: Pr | null
  project: McpProject | null
  projectIssues: readonly { statusType: string }[]
  candidates: readonly McpIssue[]
}

export function toPanel(input: PanelInput): Panel {
  const { issue, branch, isPinned, fetchedAt, prs, livePr, project: proj } = input
  const ticket = toTicket(issue, prs)
  if (livePr) ticket.prs = [livePr, ...ticket.prs.filter(p => p.number !== livePr.number)]
  const counts = completion(input.projectIssues.map(i => ({ stateType: i.statusType })))
  const project: Progress | null = proj
    ? {
        name: proj.name,
        progress: counts.total ? counts.done / counts.total : 0,
        status: proj.status?.name ?? null,
        targetDate: proj.targetDate ?? null,
        detail: `${counts.done}/${counts.total} issues`,
      }
    : null
  const ms = proj?.milestones?.find(m => m.id === issue.projectMilestone?.id)
  const milestone: Progress | null = ms
    ? { name: ms.name, progress: fraction(ms.progress), status: null, targetDate: ms.targetDate ?? null, detail: null }
    : null
  const base = { branch, isPinned, fetchedAt, ticket, project, milestone }
  if (!isMap(ticket)) return { kind: 'ticket', ...base }
  const impl = implementationTickets(issue, input.candidates, prs)
  return { kind: 'map', ...base, impl, ...completion(impl) }
}

/** `gh pr view --json number,state,isDraft,reviewDecision,url,statusCheckRollup` → Pr. */
export function prFromGh(json: string): Pr | null {
  let v: {
    number?: number
    state?: string
    isDraft?: boolean
    reviewDecision?: string
    url?: string
    statusCheckRollup?: { conclusion?: string; state?: string; status?: string }[]
  }
  try {
    v = JSON.parse(json)
  } catch {
    return null
  }
  if (!v.url) return null
  const state = v.isDraft && v.state === 'OPEN' ? 'draft' : (v.state ?? 'linked').toLowerCase()
  const checks = v.statusCheckRollup ?? []
  let pass = 0
  let fail = 0
  let pending = 0
  for (const c of checks) {
    const r = (c.conclusion || c.state || c.status || '').toUpperCase()
    if (['SUCCESS', 'NEUTRAL', 'SKIPPED'].includes(r)) pass++
    else if (['FAILURE', 'ERROR', 'TIMED_OUT', 'CANCELLED', 'ACTION_REQUIRED', 'STARTUP_FAILURE'].includes(r)) fail++
    else pending++
  }
  const parts = [pass && `${pass}✓`, fail && `${fail}✗`, pending && `${pending}…`].filter(Boolean)
  return {
    number: v.number ?? null,
    state,
    url: v.url,
    review: v.reviewDecision ? v.reviewDecision.toLowerCase().replace(/_/g, ' ') : null,
    checks: parts.length ? parts.join(' ') : null,
  }
}

/** One `gh api graphql` query for the state of every `owner/repo#n` PR. */
export function prStatesQuery(keys: readonly string[]): string {
  const parts = keys.map((k, i) => {
    const [repo, n] = k.split('#')
    const [owner, name] = (repo ?? '').split('/')
    return `p${i}: repository(owner: ${JSON.stringify(owner)}, name: ${JSON.stringify(name)}) { pullRequest(number: ${Number(n)}) { number state isDraft url } }`
  })
  return `query { ${parts.join(' ')} }`
}

export function parsePrStates(keys: readonly string[], json: string): Map<string, Pr> {
  const out = new Map<string, Pr>()
  let data: Record<string, { pullRequest?: { number: number; state: string; isDraft: boolean; url: string } | null } | null>
  try {
    data = JSON.parse(json).data ?? {}
  } catch {
    return out
  }
  keys.forEach((k, i) => {
    const pr = data[`p${i}`]?.pullRequest
    if (!pr) return
    const state = pr.isDraft && pr.state === 'OPEN' ? 'draft' : pr.state.toLowerCase()
    out.set(k, { number: pr.number, state, url: pr.url, review: null, checks: null })
  })
  return out
}

export function bar(fraction: number, width: number): string {
  const n = Math.max(0, Math.min(width, Math.round(fraction * width)))
  return '█'.repeat(n) + '░'.repeat(width - n)
}

export const pct = (fraction: number) => `${Math.round(fraction * 100)}%`

export function ago(ms: number): string {
  const s = Math.max(0, Math.round(ms / 1000))
  if (s < 60) return 'just now'
  if (s < 3600) return `${Math.floor(s / 60)}m ago`
  return `${Math.floor(s / 3600)}h ago`
}
