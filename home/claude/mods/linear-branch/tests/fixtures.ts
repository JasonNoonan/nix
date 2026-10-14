import type { McpIssue, McpProject } from '../hooks/linear'

const STATUS: Record<string, string> = { completed: 'Done', started: 'In Progress', canceled: 'Canceled', backlog: 'Backlog', unstarted: 'Todo' }

export function issue(
  id: string,
  statusType: string,
  extra: { labels?: string[]; milestone?: string; pr?: number; assignee?: string } = {},
): McpIssue {
  return {
    id,
    title: `${id} title`,
    url: `https://linear.app/x/issue/${id}`,
    status: STATUS[statusType] ?? statusType,
    statusType,
    assignee: extra.assignee ?? null,
    labels: extra.labels ?? [],
    projectMilestone: extra.milestone ? { id: `ms-${extra.milestone}`, name: extra.milestone } : null,
    attachments: extra.pr ? [{ url: `https://github.com/o/r/pull/${extra.pr}`, title: 'pr' }] : [],
  }
}

export const RELATED: McpIssue[] = [
  issue('PORT-248', 'completed', { pr: 2203, assignee: 'Flo' }),
  issue('PORT-470', 'started', { assignee: 'Jason' }),
  issue('PORT-471', 'canceled'),
  issue('PORT-254', 'backlog'),
  issue('PORT-329', 'backlog', { labels: ['wayfinder:map'] }),
  issue('PORT-472', 'unstarted'),
]

export const CHILDREN: McpIssue[] = [
  issue('PORT-451', 'completed', { labels: ['wayfinder:task'], milestone: 'wayfinder' }),
  issue('PORT-452', 'completed', { labels: ['wayfinder:research'], milestone: 'wayfinder' }),
]

export function mapIssue(): McpIssue {
  return {
    ...issue('PORT-450', 'backlog', { labels: ['wayfinder:map'], milestone: 'wayfinder' }),
    project: 'Nue Integration',
    description: '## Destination\n\nstuff PORT-1\n\n## Out of scope\n\n* thing [PORT-254](https://linear.app/x/issue/PORT-254)\n',
    relations: { relatedTo: RELATED.map(r => ({ id: r.id })), blocks: [], blockedBy: [] },
  }
}

export const PROJECT: McpProject = {
  id: 'P-PORT-805',
  name: 'Nue Integration',
  status: { name: 'Planning' },
  targetDate: null,
  milestones: [
    { id: 'ms-wayfinder', name: 'wayfinder', progress: '86%' },
    { id: 'ms-Portal SoT', name: 'Portal SoT', progress: '53%' },
  ],
}
