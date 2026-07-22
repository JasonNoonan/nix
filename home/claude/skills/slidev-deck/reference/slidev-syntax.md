# Slidev syntax cheatsheet

Reference for authoring `slides.md`. Slidev is Markdown + Vue + UnoCSS.

## ⚠️ Gotcha: raw `<` and `>` break the build

Because each slide is compiled as a Vue template, **any bare `<word>` is treated
as an HTML/Vue tag**. Unclosed ones fail the build with
`Element is missing end tag`. This bites hardest on placeholder text like
`<Deck Title>` or content such as `Vec<T>`, `a < b`, `List<String>`, or
`<not-a-real-tag>`.

- **Never** use `<...>` for fill-in placeholders — use plain text or `[brackets]`.
- Escape literal angle brackets in prose: `&lt;` and `&gt;` (or `&amp;` for `&`).
- Inside fenced code blocks, `<`/`>` are safe (not parsed) — put code there.
- For a literal generic in prose, use inline code: `` `Vec<T>` `` renders fine.

## Slide separators & frontmatter

- Slides are separated by `---` on its own line, with a blank line before and after.
- The **first** frontmatter block is the **headmatter** (deck-wide config).
- Each subsequent slide can start with its own frontmatter block for per-slide config.

```md
---
theme: seriph
title: My Deck
transition: slide-left
mdc: true
---

# First slide

---
layout: center
---

# Second slide
```

### Useful headmatter keys
- `theme:` — `seriph`, `default`, `apple-basic`, or any installed theme.
- `title:` — deck title (used in exports / browser tab).
- `transition:` — `slide-left`, `fade`, `slide-up`, `view-transition`, etc.
- `class:` — UnoCSS classes applied to slides (e.g. `text-center`).
- `background:` — cover image URL.
- `fonts:` — `{ sans: 'Inter', serif: 'Roboto Slab', mono: 'Fira Code' }`.
- `mdc: true` — enable MDC syntax (inline component/class attributes).
- `download: true` / `exportFilename:` — export options.

## Layouts (per-slide `layout:`)

| Layout        | Use                                                    |
|---------------|--------------------------------------------------------|
| `default`     | Standard content slide                                 |
| `cover`       | Title/opening slide                                     |
| `center`      | Vertically & horizontally centered content             |
| `section`     | Big section divider heading                             |
| `statement`   | One large centered statement                            |
| `quote`       | A pull quote                                            |
| `two-cols`    | Two columns — use `::right::` to split                  |
| `image-right` / `image-left` | Content + image (`image:` prop)         |
| `iframe-right`| Embed a live iframe beside content (`url:` prop)        |
| `fact`        | A big number/fact                                      |
| `end`         | Closing slide                                          |

Two-column example:
```md
---
layout: two-cols
layoutClass: gap-8
---

# Left

Left content

::right::

# Right

Right content
```

Image layout example:
```md
---
layout: image-right
image: /screenshot.png   # place asset in the deck folder or use a URL
---

# Feature in action

- Point about the screenshot
```

## Progressive reveal (click animations)

- `<v-click>` … `</v-click>` — reveal one block on click.
- `<v-clicks>` … `</v-clicks>` — reveal each child (list items) one click at a time.
- `<v-click at="3">` — reveal at a specific click index.
- `v-after` — appear together with the previous click.
- `.v-click-hidden` / motion via `v-motion`.

```md
<v-clicks>

- First
- Second
- Third

</v-clicks>
```

## Code blocks

Fenced blocks are syntax-highlighted (Shiki). Highlight/animate lines:

````md
```ts {2,4-5}
line 1
line 2   // highlighted
line 3
line 4   // highlighted
line 5   // highlighted
```
````

- Step through highlights across clicks: ```` ```ts {1|2|3-4} ````
- Line numbers: ```` ```ts {*}{lines:true} ````
- Mono editor / Monaco (editable): ```` ```ts {monaco} ````
- Diff runner: ```` ```ts {monaco-diff} ````

## Styling

- Inline UnoCSS/Tailwind-like classes work in HTML: `<div class="pt-8 text-center opacity-70">`.
- Per-slide `<style>` blocks are scoped to that slide:
  ```md
  <style>
  h1 { color: #2563eb; }
  </style>
  ```
- MDC inline (with `mdc: true`): `Some text{.text-blue-500}` or `[label]{.px-2}`.

## Speaker notes

Add an HTML comment as the **last** thing in a slide:
```md
# My slide

Content

<!--
These are speaker notes, visible in presenter mode (/presenter).
-->
```

## Diagrams

- **Mermaid**: ```` ```mermaid ```` fenced blocks render natively.
  ```md
  ```mermaid
  graph LR
    A[Client] --> B[API] --> C[(DB)]
  ```
  ```
- **PlantUML**: ```` ```plantuml ```` also supported.
- LaTeX math: `$inline$` and `$$block$$`.

## Components (built-in)

- `<Toc />` — auto table of contents.
- `<Transform :scale="0.8">…</Transform>` — scale content.
- `<Tweet id="..." />`, `<Youtube id="..." />` — embeds.
- `<SlideCurrentNo />`, `<SlidesTotal />` — slide numbers.
- `<Arrow x1 y1 x2 y2 />`, `<AutoFitText>` — annotations/fit text.

## Navigation & modes (dev server)

- `/` — the deck (arrow keys / space to advance).
- `/presenter` — presenter view with notes, next-slide preview, timer.
- `/overview` — grid of all slides.
- `f` fullscreen, `o` overview, `d` dark mode toggle, `g` go-to slide.

## CLI reference

```sh
slidev              # dev server (default slides.md) on :3030
slidev --open       # + open browser
slidev --tunnel     # public Cloudflare quick tunnel (share live)
slidev build        # static SPA -> dist/
slidev export       # PDF (needs playwright-chromium)
slidev export --format png   # per-slide PNGs
slidev format       # tidy the markdown
```

Via the scaffolded `package.json`: `npm run dev`, `npm run build`, `npm run export`.
