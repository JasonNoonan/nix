import { atom, read, update } from 'claude-code'
import type { EngineInterface, PluginOptions, Register } from 'claude-code'

import type { Panel, Pr, Progress, Ticket } from '../types'
import {
  ISSUE_FIELDS, ROW_FIELDS, ago, bar, identifiersIn, isIdentifier, parsePrStates, pct, pinKey, prFromGh, prKeys,
  prStatesQuery, relatedIds, toPanel,
} from './linear'
import type { McpIssue, McpProject } from './linear'

const PANE = 'linear-branch'
const panel = atom({ plugin: 'linear-branch', key: 'panel' } as const, { kind: 'idle' } as Panel)
const isLoading = atom({ plugin: 'linear-branch', key: 'isLoading' } as const, false)

type Git = { cwd: string; branch: string; folder: string; pinned: string | null }

async function readGit($: EngineInterface): Promise<Git | null> {
  const cwd = await $.session.cwd()
  const head = await $.process.run(['git', 'rev-parse', '--abbrev-ref', 'HEAD'], { cwd, timeoutMs: 5000 })
  if (head.exitCode !== 0) return null
  const branch = head.stdout.trim()
  const top = await $.process.run(['git', 'rev-parse', '--show-toplevel'], { cwd, timeoutMs: 5000 })
  const folder = top.exitCode === 0 ? (top.stdout.trim().split('/').pop() ?? '') : ''
  const pin = await $.process.run(['git', 'config', '--get', pinKey(branch)], { cwd, timeoutMs: 5000 })
  const pinned = pin.exitCode === 0 && isIdentifier(pin.stdout.trim()) ? pin.stdout.trim().toUpperCase() : null
  return { cwd, branch, folder, pinned }
}

/** What decides the ticket: a change in either refetches. */
const gitKey = (git: Git | null) => (git ? `${git.branch}|${git.pinned ?? ''}` : null)

async function livePr($: EngineInterface, cwd: string): Promise<Pr | null> {
  try {
    const r = await $.process.run(
      ['gh', 'pr', 'view', '--json', 'number,state,isDraft,reviewDecision,url,statusCheckRollup'],
      { cwd, timeoutMs: 15000 },
    )
    return r.exitCode === 0 ? prFromGh(r.stdout) : null
  } catch {
    return null
  }
}

async function prStates($: EngineInterface, cwd: string, keys: string[]): Promise<Map<string, Pr>> {
  if (keys.length === 0) return new Map()
  try {
    const r = await $.process.run(['gh', 'api', 'graphql', '-f', `query=${prStatesQuery(keys)}`], { cwd, timeoutMs: 20000 })
    return parsePrStates(keys, r.stdout)
  } catch {
    return new Map()
  }
}

class NotFound extends Error {}

/** One Linear MCP call, its JSON answer parsed; NotFound for an unknown reference. */
async function linear<T>($: EngineInterface, tool: string, args: Record<string, unknown>): Promise<T> {
  const server = typeof config.linearMcpServer === 'string' && config.linearMcpServer ? config.linearMcpServer : 'linear'
  const res = await $.mcp.call(server, tool, args)
  const text = res.content.map(b => b.text ?? '').join('')
  if (res.isError) {
    if (/could not find|not found/i.test(text)) throw new NotFound(text)
    throw new Error(`Linear MCP ${tool}: ${text.slice(0, 200)}`)
  }
  return (res.structuredContent as T | undefined) ?? (JSON.parse(text) as T)
}

async function getIssue($: EngineInterface, id: string, fields: string[]): Promise<McpIssue | null> {
  try {
    return await linear<McpIssue>($, 'get_issue', { id, fields })
  } catch (err) {
    if (err instanceof NotFound) return null
    throw err
  }
}

async function listAll($: EngineInterface, args: Record<string, unknown>): Promise<McpIssue[]> {
  const out: McpIssue[] = []
  let cursor: string | undefined
  for (let page = 0; page < 10; page++) {
    const r = await linear<{ issues: McpIssue[]; hasNextPage?: boolean; cursor?: string }>($, 'list_issues', {
      ...args,
      limit: 250,
      ...(cursor ? { cursor } : {}),
    })
    out.push(...r.issues)
    if (!r.hasNextPage || !r.cursor) break
    cursor = r.cursor
  }
  return out
}

let inflight: Promise<Panel> | null = null
let lastKey: string | null = null
let config: PluginOptions = {}

const NO_TICKET = (branch: string) => ({
  kind: 'none' as const,
  branch,
  reason: `No Linear ticket for ${branch}. Pin one with /linear PORT-123 (or git config ${pinKey(branch)} PORT-123).`,
})

async function fetchPanel($: EngineInterface, git: Git | null): Promise<Panel> {
  if (!git || git.branch === 'HEAD') return { kind: 'none', branch: git?.branch ?? '', reason: 'Not on a git branch.' }
  const { cwd, branch, folder, pinned } = git
  const ids = pinned ? [pinned] : identifiersIn(branch, folder)
  if (ids.length === 0) return NO_TICKET(branch)
  try {
    let issue: McpIssue | null = null
    for (const id of ids) {
      issue = await getIssue($, id, ISSUE_FIELDS)
      if (issue) break
    }
    if (!issue) return pinned ? { kind: 'error', branch, message: `Pinned ticket ${pinned} was not found in Linear.` } : NO_TICKET(branch)
    const found = issue
    const isMapTicket = (found.labels ?? []).some(l => l.toLowerCase() === 'wayfinder:map')

    const [project, candidates, live] = await Promise.all([
      found.project ? linear<McpProject>($, 'get_project', { query: found.project, includeMilestones: true }) : null,
      isMapTicket
        ? Promise.all([
            listAll($, { parentId: found.id, fields: ROW_FIELDS }),
            Promise.all(relatedIds(found).map(id => getIssue($, id, ROW_FIELDS))),
          ]).then(([children, related]) => [...children, ...related.filter((r): r is McpIssue => r !== null)])
        : [],
      livePr($, cwd),
    ])
    const projectIssues = project ? await listAll($, { project: project.id, fields: ['statusType'] }) : []
    const keys = [...new Set([found, ...candidates].flatMap(prKeys))]
    return toPanel({
      issue: found,
      branch,
      isPinned: pinned !== null,
      fetchedAt: await $.clock.now(),
      prs: await prStates($, cwd, keys),
      livePr: live,
      project,
      projectIssues,
      candidates,
    })
  } catch (err) {
    return { kind: 'error', branch, message: err instanceof Error ? err.message : String(err) }
  }
}

async function refresh($: EngineInterface, opts: { open?: boolean } = {}): Promise<Panel> {
  if (inflight) return inflight
  inflight = (async () => {
    await update($, isLoading, () => true)
    try {
      const git = await readGit($)
      const next = await fetchPanel($, git)
      await update($, panel, () => next)
      const key = gitKey(git)
      const isNewTicket = key !== lastKey
      lastKey = key
      if (next.kind === 'ticket' || next.kind === 'map') {
        $.ui.status(`${next.ticket.identifier} · ${next.ticket.stateName}`)
        if (opts.open || isNewTicket) void $.ui.open({ id: PANE, title: next.ticket.identifier })
      } else {
        $.ui.status(undefined)
        if (opts.open) void $.ui.open({ id: PANE, title: 'Linear' })
      }
      return next
    } finally {
      await update($, isLoading, () => false)
      inflight = null
    }
  })()
  return inflight
}

async function setPin($: EngineInterface, id: string | null): Promise<string> {
  const git = await readGit($)
  if (!git || git.branch === 'HEAD') return 'Not on a git branch.'
  const argv = id
    ? ['git', 'config', pinKey(git.branch), id.toUpperCase()]
    : ['git', 'config', '--unset', pinKey(git.branch)]
  const r = await $.process.run(argv, { cwd: git.cwd, timeoutMs: 5000 })
  if (r.exitCode !== 0 && id) return `Could not pin: ${r.stderr.trim()}`
  return id ? `Pinned ${id.toUpperCase()} to ${git.branch}.` : `Unpinned ${git.branch}.`
}

export const register: Register = (on, options) => {
  config = options

  on('session.start', async ($, e, next) => {
    await $.command.register({
      name: 'linear',
      description: 'Show the Linear ticket for this branch; PORT-123 pins one, unpin clears it, close hides the pane',
      argumentHint: '[PORT-123|unpin|refresh|close]',
    })
    void refresh($)
    const minutes = typeof options.refreshMinutes === 'number' && options.refreshMinutes > 0 ? options.refreshMinutes : 5
    $.clock.every(minutes * 60_000, () => void refresh($))
    return next(e)
  })

  // A checkout or a new pin (a skill running `git config`) shows after the turn.
  on('turn.complete', async ($, e, next) => {
    const result = await next(e)
    if (e.agentId === undefined) {
      const git = await readGit($).catch(() => null)
      if (gitKey(git) !== lastKey) void refresh($)
    }
    return result
  })

  on('command.run', { command: 'linear' }, async ($, e) => {
    const arg = e.args.trim()
    if (arg === 'close') {
      await $.ui.close({ id: PANE })
      return { text: 'Linear pane closed.' }
    }
    let note = ''
    if (arg === 'unpin') note = (await setPin($, null)) + ' '
    else if (isIdentifier(arg)) note = (await setPin($, arg)) + ' '
    else if (arg && arg !== 'refresh') return { text: `Unknown argument "${arg}". Use a ticket id, unpin, refresh or close.` }
    const p = await refresh($, { open: true })
    if (p.kind === 'ticket' || p.kind === 'map') return { text: `${note}${p.ticket.identifier}: ${p.ticket.stateName}` }
    if (p.kind === 'error') return { text: `${note}Linear: ${p.message}` }
    if (p.kind === 'none') return { text: `${note}${p.reason}` }
    return { text: `${note}Linear pane refreshed.` }
  })

  on('ui.render', { component: 'Pane', requestId: PANE }, async ($, e) => {
    const { Box, Text, Link } = $.ui.resolve(e)
    const p = await read($, panel)
    const loading = await read($, isLoading)
    const width = Math.max(30, e.props.bodyColumns)
    const now = await $.clock.now()

    if (p.kind === 'idle') return <Text dimColor>Loading Linear…</Text>
    if (p.kind === 'none') return <Text dimColor>{p.reason}</Text>
    if (p.kind === 'error')
      return (
        <Box flexDirection="column">
          <Text color="error">{p.message}</Text>
          <Text dimColor>branch {p.branch}</Text>
        </Box>
      )

    const LABEL = 11
    const row = (label: string, body: JSX.Element | string, key: string) => (
      <Box key={key} flexDirection="row">
        <Box width={LABEL} flexShrink={0}>
          <Text dimColor>{label}</Text>
        </Box>
        <Box flexGrow={1}>{typeof body === 'string' ? <Text wrap="truncate-end">{body}</Text> : body}</Box>
      </Box>
    )
    const progressRow = (label: string, prog: Progress, key: string) => {
      const barWidth = Math.max(5, Math.min(20, width - LABEL - prog.name.length - 8))
      return row(
        label,
        <Text wrap="truncate-end">
          {prog.name} <Text color="success">{bar(prog.progress, barWidth)}</Text> {pct(prog.progress)}
          <Text dimColor>
            {prog.detail ? ` (${prog.detail})` : ''}
            {prog.status ? ` · ${prog.status}` : ''}
            {prog.targetDate ? ` · due ${prog.targetDate}` : ''}
          </Text>
        </Text>,
        key,
      )
    }
    const prText = (pr: Pr) =>
      [pr.number ? `#${pr.number}` : 'PR', pr.state, pr.review, pr.checks && `checks ${pr.checks}`].filter(Boolean).join(' · ')
    const prColor = (pr: Pr) =>
      pr.state === 'merged' ? 'merged' : pr.state === 'closed' ? 'error' : pr.state === 'draft' ? 'inactive' : 'success'
    const state = (t: Ticket) => <Text color={t.stateColor}>● {t.stateName}</Text>
    const t = p.ticket

    const header = (
      <Box key="h" flexDirection="column" marginBottom={1}>
        <Text wrap="truncate-end">
          <Link href={t.url} key="id">
            {t.identifier}
          </Link>{' '}
          <Text bold>{t.title}</Text>
        </Text>
      </Box>
    )
    const footer = (
      <Text key="f" dimColor wrap="truncate-end">
        {loading ? 'refreshing…' : `updated ${ago(now - p.fetchedAt)}`} · {p.branch}
        {p.isPinned ? ' (pinned)' : ''} · /linear refresh
      </Text>
    )
    const context = [
      p.project && progressRow('Project', p.project, 'proj'),
      p.milestone && progressRow('Milestone', p.milestone, 'ms'),
    ].filter(Boolean) as JSX.Element[]

    if (p.kind === 'ticket') {
      return (
        <Box flexDirection="column">
          {header}
          {row('State', state(t), 'state')}
          {row('Assignee', t.assignee ?? 'Unassigned', 'who')}
          {t.prs.length === 0
            ? row('PR', <Text dimColor>none linked</Text>, 'pr')
            : t.prs.map((pr, i) =>
                row(
                  i === 0 ? 'PR' : '',
                  <Link href={pr.url} key={`pr${i}`}>
                    <Text color={prColor(pr)}>{prText(pr)}</Text>
                  </Link>,
                  `pr${i}`,
                ),
              )}
          {context}
          <Box marginTop={1}>{footer}</Box>
        </Box>
      )
    }

    // Wayfinder map: implementation tickets table.
    const fraction = p.total ? p.done / p.total : 0
    const idW = Math.max(4, ...p.impl.map(i => i.identifier.length)) + 2
    const stateW = Math.min(18, Math.max(7, ...p.impl.map(i => i.stateName.length + 2)) + 1)
    const whoW = 16
    const prW = 14
    const showTitle = width - idW - stateW - whoW - prW > 12
    const cell = (w: number | undefined, body: JSX.Element | string, key: string) => (
      <Box key={key} width={w} flexShrink={0} flexGrow={w === undefined ? 1 : 0}>
        {typeof body === 'string' ? <Text wrap="truncate-end">{body}</Text> : body}
      </Box>
    )
    const firstPr = (i: Ticket) => {
      const pr = i.prs[0]
      if (!pr) return <Text dimColor>—</Text>
      return (
        <Text color={prColor(pr)} wrap="truncate-end">
          {pr.number ? `#${pr.number} ` : ''}
          {pr.state}
          {i.prs.length > 1 ? ` +${i.prs.length - 1}` : ''}
        </Text>
      )
    }

    return (
      <Box flexDirection="column">
        {header}
        {row('Map', state(t), 'state')}
        {context}
        {row(
          'Built',
          <Text>
            <Text color="success">{bar(fraction, Math.max(5, Math.min(24, width - LABEL - 22)))}</Text> {pct(fraction)}{' '}
            <Text dimColor>
              ({p.done}/{p.total} implementation tickets done)
            </Text>
          </Text>,
          'built',
        )}
        <Box key="th" flexDirection="row" marginTop={1}>
          {cell(idW, <Text dimColor>Ticket</Text>, 'a')}
          {cell(stateW, <Text dimColor>State</Text>, 'b')}
          {cell(whoW, <Text dimColor>Assignee</Text>, 'c')}
          {cell(prW, <Text dimColor>PR</Text>, 'd')}
          {showTitle && cell(undefined, <Text dimColor>Title</Text>, 'e')}
        </Box>
        {p.impl.length === 0 && <Text dimColor>No implementation tickets linked to this map yet.</Text>}
        {p.impl.map(i => (
          <Box key={`r-${i.identifier}`} flexDirection="row">
            {cell(
              idW,
              <Link href={i.url} key={`l-${i.identifier}`}>
                {i.identifier}
              </Link>,
              'a',
            )}
            {cell(
              stateW,
              <Text color={i.stateColor} wrap="truncate-end" strikethrough={i.stateType === 'canceled'}>
                ● {i.stateName}
              </Text>,
              'b',
            )}
            {cell(whoW, i.assignee ? <Text wrap="truncate-end">{i.assignee}</Text> : <Text dimColor>—</Text>, 'c')}
            {cell(prW, firstPr(i), 'd')}
            {showTitle && cell(undefined, <Text dimColor={i.stateType === 'completed'} wrap="truncate-end">{i.title}</Text>, 'e')}
          </Box>
        ))}
        <Box marginTop={1}>{footer}</Box>
      </Box>
    )
  })
}
