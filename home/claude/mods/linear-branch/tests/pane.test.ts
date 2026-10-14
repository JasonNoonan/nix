import { expect, mock, test } from 'claude-code/testing'
import type { On } from 'claude-code'

import { CHILDREN, PROJECT, RELATED, mapIssue } from './fixtures'

const PANE = {
  component: 'Pane',
  requestId: 'linear-branch',
  viewport: { columns: 120, rows: 30 },
  props: { title: 'PORT-450', isFocused: false, bodyColumns: 110, placement: 'dock', scroll: { offset: 0, bodyRows: 28 }, view: {} },
} as const

const run = (args: string) =>
  ({ command: 'linear', args, origin: { kind: 'composer' }, presentation: { isFullscreen: true, columns: 120 } }) as const

const json = (v: unknown) => ({ value: { content: [{ type: 'text', text: JSON.stringify(v) }], isError: false } })

/** A repo on `branch` with an in-memory git config, and a Linear MCP that knows the map. */
function engine(on: On, branch: string) {
  mock.clock(on)
  const gitConfig = new Map<string, string>()
  const calls: string[] = []
  const ran = (exitCode: number, stdout: string) => ({
    value: { exitCode, stdout, stderr: '', isStdoutTruncated: false, isStderrTruncated: false },
  })
  on('session.cwd', () => ({ value: '/repo/worktrees/' + branch }))
  on('process.run', ($, e) => {
    const [cmd, ...a] = e.argv
    if (cmd === 'git' && a[0] === 'rev-parse' && a[1] === '--abbrev-ref') return ran(0, branch + '\n')
    if (cmd === 'git' && a[0] === 'rev-parse') return ran(0, '/repo/worktrees/' + branch + '\n')
    if (cmd === 'git' && a[0] === 'config' && a[1] === '--get') {
      const v = gitConfig.get(a[2] ?? '')
      return v ? ran(0, v + '\n') : ran(1, '')
    }
    if (cmd === 'git' && a[0] === 'config' && a[1] === '--unset') return gitConfig.delete(a[2] ?? '') ? ran(0, '') : ran(5, '')
    if (cmd === 'git' && a[0] === 'config') {
      gitConfig.set(a[1] ?? '', a[2] ?? '')
      return ran(0, '')
    }
    if (cmd === 'gh' && a[0] === 'api')
      return ran(0, JSON.stringify({ data: { p0: { pullRequest: { number: 2203, state: 'MERGED', isDraft: false, url: 'https://github.com/o/r/pull/2203' } } } }))
    return ran(1, '')
  })
  on('mcp.call', ($, e) => {
    calls.push(`${e.tool} ${JSON.stringify(e.args.id ?? e.args.parentId ?? e.args.project ?? e.args.query)}`)
    if (e.tool === 'get_issue') {
      if (e.args.id === 'PORT-450') return json(mapIssue())
      const found = RELATED.find(r => r.id === e.args.id)
      if (found) return json(found)
      return { value: { content: [{ type: 'text', text: 'Could not find referenced Issue.' }], isError: true } }
    }
    if (e.tool === 'list_issues')
      return json({ issues: e.args.parentId ? CHILDREN : [{ statusType: 'completed' }, { statusType: 'started' }], hasNextPage: false })
    if (e.tool === 'get_project') return json(PROJECT)
    return { value: { content: [], isError: true } }
  })
  on('ui.open', () => ({ value: { isPlaced: true as const } }))
  on('ui.status', () => ({ value: undefined }))
  return { calls, gitConfig }
}

test('a wayfinder map branch draws the implementation table from the Linear MCP', async ($, on) => {
  const { calls } = engine(on, 'port-450')
  expect(await $.command.run(run(''))).toEqual(expect.objectContaining({ text: 'PORT-450: Backlog' }))
  expect(calls).toContain('get_issue "PORT-450"')
  expect(calls).not.toContain('get_issue "PORT-254"')

  for (const surface of ['terminal', 'desktop'] as const) {
    const ui = await $.ui.mount({ plugin: 'linear-branch', surface, ...PANE })
    expect(await ui.find({ text: /1\/3 implementation tickets done/ })).toBeDefined()
    expect(await ui.find({ text: /PORT-470/ })).toBeDefined()
    expect(await ui.find({ text: /#2203 merged/ })).toBeDefined()
    expect(await ui.find({ text: /1\/2 issues/ })).toBeDefined()
    expect(await ui.find({ text: /PORT-254/ })).toBeUndefined()
    expect(await ui.find({ text: /PORT-451/ })).toBeUndefined()
    await ui.unmount()
  }
})

test('a branch with no ticket id asks for a pin, and /linear PORT-450 pins it in git config', async ($, on) => {
  const { calls, gitConfig } = engine(on, 'way-downcase-emails')
  const first = await $.command.run(run(''))
  expect(first).toEqual(expect.objectContaining({ text: expect.stringContaining('Pin one with /linear PORT-123') }))
  expect(calls).toEqual([])

  const pinned = await $.command.run(run('port-450'))
  expect(pinned).toEqual(expect.objectContaining({ text: 'Pinned PORT-450 to way-downcase-emails. PORT-450: Backlog' }))
  expect(gitConfig.get('branch.way-downcase-emails.linear-issue')).toBe('PORT-450')

  const ui = await $.ui.mount({ plugin: 'linear-branch', surface: 'terminal', ...PANE })
  expect(await ui.find({ text: /\(pinned\)/ })).toBeDefined()
  await ui.unmount()

  expect(await $.command.run(run('unpin'))).toEqual(expect.objectContaining({ text: expect.stringContaining('Unpinned way-downcase-emails.') }))
  expect(gitConfig.has('branch.way-downcase-emails.linear-issue')).toBe(false)
})
