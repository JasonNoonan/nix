---
name: slidev-deck
description: >-
  Create a shareable slide presentation from a stated objective using Slidev.
  Use whenever the user wants to build a slide deck, slideshow, or presentation —
  e.g. "make a presentation explaining this feature for my PM", "recap the PRs
  from the last two weeks as slides", "turn this into a deck", "present these
  changes". Works in any repo: gathers material (git history, PRs, diffs, README,
  code) when the objective implies it, writes a Slidev deck to ~/presentations/,
  and launches a live dev server.
---

# Slidev Deck Builder

Turn a plain-language objective into a polished, shareable Slidev presentation.

The user gives an **objective** ("create a presentation describing this feature
for my project manager", "recap the functionality changes of the PRs over the
last 2 weeks"). Produce a focused, well-structured deck and serve it live.

## Workflow

Follow these steps in order.

### 1. Understand the objective

Extract from the request:
- **Topic / scope** — what the deck is about (a feature, a time range of work, an
  architecture, a proposal, a retro…).
- **Audience** — who it's for. This drives depth and vocabulary:
  - *PM / non-technical / leadership* → outcomes, user impact, why it matters,
    minimal code. Lead with the "so what".
  - *Engineers / technical review* → design decisions, trade-offs, code snippets,
    diagrams.
  - *Mixed / demo* → narrative arc, screenshots, a few technical highlights.
- **Length** — infer a sensible slide count (see Sizing). Ask only if genuinely
  ambiguous; otherwise pick a good default and state it.

If the objective is too vague to act on (no discernible topic), ask **one**
concise clarifying question. Otherwise proceed — don't over-interrogate.

### 2. Gather source material (git-aware by default)

Pull real content so the deck is accurate and specific, not generic. Choose the
sources the objective implies:

- **"recap PRs / changes over the last N days/weeks"** — this is the flagship
  case. Gather with:
  ```sh
  # Merged PRs in a window (requires gh, authenticated)
  gh pr list --state merged --limit 100 \
    --json number,title,author,mergedAt,url,body,labels \
    --search "merged:>=$(date -v-14d +%Y-%m-%d)"     # macOS date; last 14 days

  # Fallback / supplement via git log
  git log --since="2 weeks ago" --no-merges --pretty=format:'%h %s (%an, %ad)' --date=short
  git log --since="2 weeks ago" --merges --pretty=format:'%h %s'
  ```
  Group changes into themes (features, fixes, refactors, infra) rather than
  listing every commit. Link PRs by number/URL.
- **"explain / describe this feature"** — read the relevant code, README, and
  recent commits touching it. Use `git log --oneline -- <path>`, read key files,
  and summarize behavior + why it exists. Prefer showing a small, real code
  snippet over pseudo-code.
- **"proposal / plan / architecture"** — read existing code and docs to ground
  the proposal in the current state; contrast current vs. proposed.
- **General** — check `README*`, `docs/`, `package.json`/manifest for project
  name, purpose, and stack.

Also run `git remote -v` / `basename $(git rev-parse --show-toplevel)` to get the
project name for the title slide.

If not in a git repo or the user supplied all context inline, skip gathering and
use what was given.

**Never fabricate.** If a detail (a metric, a date, a name) isn't in the sources,
omit it or mark it as a placeholder for the user to fill — don't invent numbers.

### 3. Choose a slug and scaffold the project

Derive a short kebab-case `<slug>` from the topic (e.g. `pr-recap-jul-2026`,
`billing-feature-overview`). Create a self-contained project:

```sh
DECK=~/presentations/<slug>
mkdir -p "$DECK"
cp ~/.claude/skills/slidev-deck/assets/package.json "$DECK/package.json"
```

Then write the deck to `"$DECK/slides.md"` (see step 4). Update the `name` field
in the copied `package.json` to `<slug>` if you like (optional).

The Slidev CLI itself is installed globally via nix on these hosts, so the
per-deck `package.json` only pins the **theme** — `npm install` fetches just a
handful of small packages (a few seconds), not the whole Slidev toolchain. The
global `slidev` command runs against the deck's local theme in `./node_modules`.

### 4. Write slides.md

Author `slides.md` using Slidev markdown. See `assets/slides-template.md` for a
complete starting template and `reference/slidev-syntax.md` for the full syntax
cheatsheet. Key rules:

- Start with the **headmatter** (YAML frontmatter on the first slide) setting
  `theme: seriph`, `title:`, `transition: slide-left`, and an optional cover.
- Separate slides with `---` on its own line (blank line before and after).
- **One idea per slide.** Prefer 3–6 bullet points max; break dense content
  across slides. Use `v-clicks` to reveal points progressively when it aids a
  live talk.
- Open with a **title/cover slide**, then an **agenda/overview**, the body, and a
  **closing / next-steps** slide.
- Match depth to audience (step 1). For PMs, lead each section with impact.
- Use real content from step 2. Attribute PRs (`#123`) and link where useful.
- Use layouts (`layout: two-cols`, `layout: center`, `layout: section`,
  `layout: statement`, `layout: quote`) to vary rhythm — avoid 15 identical
  bullet slides.
- Add speaker notes with an HTML comment block at the end of a slide (`<!-- notes -->`)
  when they'd help the presenter.
- Keep code snippets short and highlight lines (```` ```ts {2,4} ````) rather
  than pasting whole files.

### 5. Launch the live dev server

```sh
cd ~/presentations/<slug>
npm install        # first run only; fetches just the theme (fast)
npm run dev -- --open
```

`slidev` is provided globally by nix, so `npm install` only pulls the theme.
`npm run dev` starts Slidev on http://localhost:3030 with hot reload. Tell the
user the URL and that edits to `slides.md` reload live. Run it in the background
(or tell the user to run it) so the session isn't blocked — do **not** block the
turn waiting on the server. Prefer launching with `run_in_background`.

Report to the user:
- Where the deck lives (`~/presentations/<slug>/slides.md`)
- The local URL (http://localhost:3030)
- Presenter mode is at `/presenter`; overview at `/overview`

### 6. Sharing (offer, don't assume)

The dev server is the default deliverable. Mention these follow-ons the user can
ask for:
- **Share a live link** (temporary public tunnel):
  `npm run dev -- --tunnel`
- **Static site** (self-contained, hostable/zippable):
  `npm run build` → outputs to `dist/`
- **PDF** (for email/attachment). Two routes:
  - *Browser exporter (no setup, preferred):* with the dev server running, open
    http://localhost:3030/export and use the browser's print-to-PDF. Uses your
    own browser — nothing to install.
  - *CLI export:* `npm run export`. The nix `slidev-cli` bundles the playwright
    package but **not** the browser binary, so the first run needs a one-time
    `npx playwright install chromium` to download it into the playwright cache.

## Sizing guide

| Objective                     | Suggested slides |
|-------------------------------|------------------|
| Quick feature explainer (PM)  | 6–10             |
| PR / changes recap            | 8–14             |
| Technical deep-dive           | 12–20            |
| Proposal / plan               | 8–15             |

Fewer, clearer slides beat a wall of text. When in doubt, cut.

## Notes

- The `slidev` CLI is installed globally via nix (`slidev-cli` in
  `home/{cyan,leo}/default.nix`). It bundles no themes, so a deck always needs
  its theme in local `node_modules` — that's the one thing the per-deck
  `package.json` provides. Don't add `@slidev/cli` back as a dep; the global one
  is used.
- The `seriph` theme (clean, serif headings) is the default here. Other themes
  (`@slidev/theme-default`, `@slidev/theme-apple-basic`, community themes) can be
  swapped via the `theme:` headmatter + the matching dep in `package.json`.
- **Non-nix machine (no global slidev)?** Fall back to running the deck via npx:
  `npx -y @slidev/cli@latest slides.md --open` from the deck folder — this
  installs the theme on demand alongside the CLI.
