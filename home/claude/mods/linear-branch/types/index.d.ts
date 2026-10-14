export type StateType = 'triage' | 'backlog' | 'unstarted' | 'started' | 'completed' | 'canceled' | (string & {})

export type Pr = {
  number: number | null
  /** open, draft, merged, closed */
  state: string
  url: string
  review: string | null
  checks: string | null
}

export type Ticket = {
  identifier: string
  title: string
  url: string
  stateName: string
  stateType: StateType
  stateColor: string
  assignee: string | null
  labels: string[]
  milestone: string | null
  prs: Pr[]
}

export type Progress = {
  name: string
  /** 0..1 */
  progress: number
  status: string | null
  targetDate: string | null
  /** e.g. `12/30 issues` where the % is counted here, not Linear's own */
  detail: string | null
}

export type Panel =
  | { kind: 'idle' }
  | { kind: 'none'; branch: string; reason: string }
  | { kind: 'error'; branch: string; message: string }
  | {
      kind: 'ticket'
      branch: string
      isPinned: boolean
      fetchedAt: number
      ticket: Ticket
      project: Progress | null
      milestone: Progress | null
    }
  | {
      kind: 'map'
      branch: string
      isPinned: boolean
      fetchedAt: number
      ticket: Ticket
      project: Progress | null
      milestone: Progress | null
      impl: Ticket[]
      done: number
      total: number
    }

declare module 'claude-code' {
  interface PluginState {
    'linear-branch': { panel: Panel; isLoading: boolean }
  }
}
