---
name: eli5
description: Explain a topic, file, doc, or question in the simplest possible terms and publish the explanation as a picture-first HTML Artifact — diagrams and short labels carrying the meaning, almost no paragraphs. Invoked as `/eli5 <topic or question>`, but also trigger on plain-language asks like "explain like I'm five", "explain like I know nothing about this", "ELI5 this", "dumb this down for me", "explain this simply", or "make this easy to understand" — even when the user doesn't type the slash command. Works on anything: a file or doc in the current project, a concept, a technology, how something works, or a plan/status the user just discussed.
---

# ELI5

Turn `<topic or question>` into an explanation a total newcomer can follow at a
glance, delivered as a published Artifact that leans on diagrams instead of
prose. The reader has zero background — never assume they know the domain's
jargon, acronyms, or "obviously."

## 1. Understand the topic before designing anything

Get it right before making it simple — a beautiful diagram of a wrong idea is
worse than no diagram.

- If the topic names a file, doc, or something in the current project, read
  it (and anything it clearly depends on) before writing a word of
  explanation. Don't explain from a guess when the source is one Read call
  away.
- If the topic was just discussed earlier in the conversation, use that
  context directly — don't re-derive it from scratch.
- If it's a general concept with no project tie-in, draw on what you already
  know. Only stop to ask the user something if the topic is genuinely
  ambiguous (e.g. it could mean two unrelated things) — otherwise make the
  reasonable call and proceed.

## 2. Find the one metaphor

This is the single highest-leverage step. A generic explanation reaches for
generic shapes (boxes and arrows, a bulleted list of "key points"). A good
ELI5 finds **one concrete metaphor drawn from the subject's own world** and
draws the whole page through it.

Look at the vocabulary already in play. If the subject talks about
"gateways" and "resources," a shipping-container/dock metaphor falls out
almost for free. If it's about layers of a cell, an onion or a city with
districts might fit. If it's a network protocol, a postal system. The
metaphor should make the mechanism *visible* — not just decorate the page,
but let a diagram replace a paragraph.

Pick one metaphor and commit to it across every section. Switching metaphors
between sections is more confusing than having none.

## 3. Load `artifact-design` before writing HTML

The Artifact tool requires this, and it also sets the token system (color,
type, layout) this skill's visual style builds on. Don't skip it or start
writing markup first.

Given this skill's brief — "big pictures, few words" — treat the page as
picture-first: light on flourish, heavy on diagrams that do the explaining.
Most ELI5 topics call for the same register as a well-made explainer poster:
polished and legible rather than a maximalist landing-page hero. A genuinely
playful topic (how rainbows form, why cats purr) can earn a lighter, more
colorful, more editorial treatment — match the register to the subject, not
to a fixed template.

## 4. Structure as a small set of visual sections, not paragraphs

Pick 3–5 sections from the patterns below — whichever actually fit this
topic's shape. Don't force a pattern that doesn't apply (a static concept has
no "roadmap"; a historical event has no "current state").

| The topic is shaped like... | Use this pattern |
|---|---|
| A change, a fix, an old way vs. a new way | Before/after diagram, side by side |
| A sequence of steps or stages | A step flow or timeline, left to right |
| A system made of parts that connect | A labeled diagram of the parts and how they connect |
| A status, a project, "where things stand" | A single "you are here" panel with the key facts |
| A set of options, categories, or examples | A small grid of short cards |
| A set of rules, tradeoffs, or gotchas | A short grid of one-line rule cards |

Every section gets: a short heading (2–5 words), one diagram or visual
element doing the actual explaining, and at most one caption sentence under
it. If a caption is growing into two sentences, the diagram isn't carrying
its weight yet — simplify the diagram, don't lengthen the caption.

Reference point for the shape and density this produces: an earlier `/eli5`
run on this project's refactor plan opened with a before/after diagram
(tangled per-doorway wiring vs. one standard container), then a six-phase
roadmap with a "you are here" marker, a current-status panel naming the
exact next task, a four-step process flow, and a four-card rules grid — each
section a diagram plus one line of caption, nothing longer.

## 5. Keep the word count honest

- No paragraphs. If you're tempted to write one, it's telling you a diagram
  is missing.
- Headings are short noun phrases, not sentences.
- Captions are one sentence, plain language, no jargon the reader wasn't
  just taught by the diagram above it.
- Prefer a label + icon/shape over a sentence wherever the diagram can carry
  it instead.

## 6. Publish

Publish via the Artifact tool:
- A specific, non-generic `title` (the subject's name, not "Explainer" or
  "ELI5").
- A one-sentence `description` for the gallery card.
- A `favicon` emoji that fits the metaphor chosen in step 2, not a generic
  book/lightbulb unless nothing else fits.

## 7. Reply short

The artifact is the explanation — don't repeat it in the chat. Reply with
the link and two or three sentences at most: what metaphor you used and the
2–3 sections you built. Do not re-explain the topic in prose after already
explaining it visually.
