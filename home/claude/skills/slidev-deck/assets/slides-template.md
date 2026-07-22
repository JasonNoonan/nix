---
# Headmatter — global config for the whole deck (first slide only).
theme: seriph
title: Deck Title
info: |
  One-line description of this deck.
class: text-center
transition: slide-left
mdc: true
# Optional cover background:
# background: https://source.unsplash.com/collection/94734566/1920x1080
---

# Deck Title

Subtitle — audience &amp; purpose, e.g. "Feature overview for Product"

<div class="pt-8 opacity-70 text-sm">
  Author · Date · Project
</div>

---
layout: default
---

# Agenda

<v-clicks>

- Context — where we are today
- What changed
- Why it matters
- What's next

</v-clicks>

---
layout: section
---

# Context

---

# The problem

<v-clicks>

- Point one grounded in real detail
- Point two
- Point three

</v-clicks>

<!--
Speaker notes: expand on the pain point here. Keep the slide itself sparse.
-->

---
layout: two-cols
layoutClass: gap-8
---

# Before

- Current behavior
- Limitation

::right::

# After

- New behavior
- Benefit

---

# How it works

```ts {2,5}
export function example(input: Input): Result {
  const parsed = parse(input)          // highlighted
  const validated = validate(parsed)
  return transform(validated)
}
```

Keep snippets short; highlight the lines that matter.

---
layout: statement
---

# The one thing to remember

A single, memorable takeaway.

---

# Recap of changes

<v-clicks>

- **Feature X** — short impact statement · #123
- **Fix Y** — what it resolves · #124
- **Refactor Z** — why it helps · #125

</v-clicks>

---
layout: center
class: text-center
---

# Next steps

- Action 1
- Action 2

<div class="pt-8 opacity-70">Questions?</div>
