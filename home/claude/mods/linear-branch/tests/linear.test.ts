import { expect, test } from 'claude-code/testing'

import {
  completion, identifiersIn, implementationTickets, outOfScope, parsePrStates, prFromGh, prStatesQuery, relatedIds, toPanel,
} from '../hooks/linear'
import { CHILDREN, PROJECT, RELATED, issue, mapIssue } from './fixtures'

test('reads ticket ids from branch and worktree names', () => {
  expect(identifiersIn('port-450')).toEqual(['PORT-450'])
  expect(identifiersIn('port-469-prod-nue-api')).toEqual(['PORT-469'])
  expect(identifiersIn('jason/PORT-12-fix', 'port-12')).toEqual(['PORT-12'])
  expect(identifiersIn('feature-implement-unthread-enablement-2')).toEqual([])
  expect(identifiersIn('way-downcase-emails', 'portal.pdq.com')).toEqual([])
})

test('collects ids from the map body Out of scope section only', () => {
  expect([...outOfScope(mapIssue().description)]).toEqual(['PORT-254'])
  expect(relatedIds(mapIssue())).not.toContain('PORT-254')
})

test('map implementation tickets skip wayfinder, other maps and out-of-scope', () => {
  const prs = parsePrStates(
    ['o/r#2203'],
    JSON.stringify({ data: { p0: { pullRequest: { number: 2203, state: 'MERGED', isDraft: false, url: 'https://github.com/o/r/pull/2203' } } } }),
  )
  const impl = implementationTickets(mapIssue(), [...CHILDREN, ...RELATED], prs)
  expect(impl.map(t => t.identifier)).toEqual(['PORT-470', 'PORT-472', 'PORT-248', 'PORT-471'])
  expect(completion(impl)).toEqual({ done: 1, total: 3 })
  expect(impl.find(t => t.identifier === 'PORT-248')?.prs[0]?.state).toBe('merged')
})

test('a plain ticket gets milestone % from Linear and project % counted from its issues', () => {
  const p = toPanel({
    issue: { ...issue('PORT-470', 'started', { assignee: 'Jason', milestone: 'Portal SoT' }), project: 'Nue Integration' },
    branch: 'port-470',
    isPinned: false,
    fetchedAt: 0,
    prs: new Map(),
    livePr: null,
    project: PROJECT,
    projectIssues: [{ statusType: 'completed' }, { statusType: 'started' }, { statusType: 'canceled' }, { statusType: 'completed' }],
    candidates: [],
  })
  expect(p.kind).toBe('ticket')
  if (p.kind !== 'ticket') return
  expect(p.ticket.assignee).toBe('Jason')
  expect(p.milestone?.progress).toBe(0.53)
  expect(p.project?.detail).toBe('2/3 issues')
})

test('PR states come back from one batched gh graphql query', () => {
  expect(prStatesQuery(['o/r#1', 'o/s#2'])).toBe(
    'query { p0: repository(owner: "o", name: "r") { pullRequest(number: 1) { number state isDraft url } } p1: repository(owner: "o", name: "s") { pullRequest(number: 2) { number state isDraft url } } }',
  )
  const pr = prFromGh(
    JSON.stringify({
      number: 7,
      state: 'OPEN',
      isDraft: false,
      reviewDecision: 'REVIEW_REQUIRED',
      url: 'https://github.com/o/r/pull/7',
      statusCheckRollup: [{ conclusion: 'SUCCESS' }, { conclusion: 'FAILURE' }, { status: 'IN_PROGRESS' }],
    }),
  )
  expect(pr).toEqual({ number: 7, state: 'open', url: 'https://github.com/o/r/pull/7', review: 'review required', checks: '1✓ 1✗ 1…' })
  expect(prFromGh('no pull requests found')).toBe(null)
})
