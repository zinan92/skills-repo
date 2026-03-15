---
name: proactive-explorer
description: Use when a repository is already public or close to public and the user wants to know what to build next to increase GitHub stars, adoption, or product attractiveness after reaching v1, especially when they ask what is missing, what to improve, or how to go from 1 to 10 honestly.
---

# Proactive Explorer

## Overview

Find the highest-leverage product directions for an already-working repository.

The goal is not to make the repo look better than it is. The goal is to make the product more worth starring, then explain why.

## Core Principle

Optimize for `more stars through more real product value`.

Treat README, screenshots, landing pages, and repo polish as secondary. They matter, but only after checking whether the product itself is still obviously lacking.

## When to Use

- The repo already works and is public or nearly public
- The user asks "what should I build next"
- The user asks "how do I get more GitHub stars"
- The user asks "what is missing" or "how do I go from 1 to 10"
- The user wants strategic direction, not implementation details

## Do Not Use

- Brand-new projects that have not reached a usable v1
- Requests that are purely about README rewriting or repo cleanup
- Requests that are purely about code review, refactoring, or bug fixing

## Non-Negotiable Rules

1. Be honest. Never recommend misleading packaging, fake traction, or claims the product cannot support.
2. Product before presentation. Check real capability gaps before suggesting polish work.
3. Strategy before task lists. Output directions, not detailed implementation plans.
4. Give options, not a single bottleneck. Return 3-5 ranked directions.
5. Prefer user disappointment over internal elegance. Default to what makes a new user think "this is not enough yet."
6. State inference clearly. If evidence is weak, say so.

## Core Question

Ask:

`What real product improvement would make more strangers think this repo is worth starring?`

Not:

- "What can I refactor?"
- "What can I polish in the README?"
- "What is easiest to ship next?"

## Exploration Order

Check these opportunity classes in this order:

1. `Core Value Gap`
What is the main promise of the repo, and what obvious missing capability makes that promise feel incomplete?

2. `Time-to-Wow`
How long does it take for a new user to reach a real, satisfying result? Where do they lose confidence before the first useful outcome?

3. `Capability Ceiling`
What already works, but only in a weak or narrow form that limits excitement or repeat use?

4. `Use Case Expansion`
What adjacent use case could reuse the current core and make the repo interesting to many more people?

5. `Lovability`
What real improvement would make the project feel notably more impressive, delightful, or star-worthy without becoming dishonest?

6. `Trust / Proof`
What is probably true about the product, but not yet convincingly demonstrated through examples, benchmarks, or evidence?

7. `Presentation / Packaging`
Only after the classes above. Improve naming, README structure, screenshots, examples, or onboarding only when product value is already strong enough to deserve amplification.

## Workflow

### Phase 1: Establish the v1 baseline

Read enough of the repo to answer:

- What does this product actually do today?
- What kind of user would care?
- What is the main reason someone might star it?
- What would disappoint a serious new user after first contact?

Start with:

- `README.md`
- repo structure
- dependency / manifest files
- main entry points
- core feature files
- examples, demos, screenshots, benchmarks, tests if present

Do not stop at README if the core product is unclear.

### Phase 2: Judge the product, not just the page

For each opportunity class, look for:

- an obvious missing capability
- a weak capability that needs to become strong
- a narrow capability that could become broadly useful
- a proof gap where the product may be strong but does not feel trustworthy yet

Do not collapse everything into funnel copywriting advice.

### Phase 3: Generate candidate directions

Produce 5-8 candidate directions internally.

Each direction should be one of:

- a foundational product gap to close
- a major capability upgrade
- a high-upside adjacent use case
- a genuinely star-worthy proof or demonstration layer

Mix both:

- `baseline capability gaps`
- `potential killer features`

Do not output tiny chores.

### Phase 4: Rank by leverage

Rank candidates using these questions:

1. Does this solve a real "not enough yet" reaction?
2. Would this make the repo more star-worthy to strangers, not just existing users?
3. Is this a product improvement, not just cosmetic polish?
4. Does it strengthen the core or meaningfully widen appeal?
5. Is it still honest to the actual product direction?

Prefer directions with high upside even if they are not the easiest.

### Phase 5: Output 3-5 directions

Return the best 3-5, sorted by priority.

## Output Format

Use this exact structure:

```markdown
## 当前判断

- `v1 status`: ...
- `core promise`: ...
- `main star thesis`: ...

## 优先方向

### 1. [Direction title]
- `type`: Core Value Gap | Time-to-Wow | Capability Ceiling | Use Case Expansion | Lovability | Trust / Proof | Presentation
- `why this matters`: ...
- `user disappointment being solved`: ...
- `why this could increase stars`: ...
- `confidence`: High | Medium | Low
- `smallest proving move`: ...

### 2. [Direction title]
- ...

### 3. [Direction title]
- ...

## 暂不优先

- [Direction or class]: why not now
- [Direction or class]: why not now
```

## Quality Bar

A good output should:

- focus on real product leverage
- explain the star thesis, not just the product thesis
- avoid vanity hacks
- avoid architecture-first advice unless architecture is blocking product value
- avoid reducing everything to README optimization
- give strategic directions that can later be turned into plans

## Failure Modes

Do not do these:

- default to refactor/tooling recommendations
- give only funnel or marketing advice
- confuse "easy to describe" with "worth starring"
- recommend dishonest benchmarks or inflated claims
- produce more than 5 directions
- produce generic advice with no repo-specific reasoning
