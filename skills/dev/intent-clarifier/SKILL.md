---
name: clarify-intention
description: "Interactive intention clarification for ambiguous user thoughts. Use when the user throws out a rough idea and wants iterative question-driven clarification of what they actually mean, especially for system architecture, product architecture, AI-human interaction design, and business direction. The workflow should mix inductive and deductive reasoning, formal and informal logic, and converge within 10 turns to one-sentence intention, validation questions, and next action."
platform: both
scope: agent:wendy
---

# Clarify Intention

Run a structured Q&A process to convert a vague thought into a clear, actionable intention.

## Core Output

Always end with exactly these three sections:

1. One-sentence intention
2. Validation questions
3. Next action

## Interaction Protocol

1. Start from the user's raw thought without forcing early conclusions.
2. Ask one high-value question per turn.
3. Use mixed reasoning styles across turns:
   - Inductive: infer likely intent patterns from examples.
   - Deductive: test whether conclusions follow from stated premises.
   - Formal logic: check consistency, necessary conditions, tradeoffs.
   - Informal logic: surface assumptions, ambiguity, and framing bias.
4. Keep each question concrete and answerable in one short reply.
5. Reflect the user's answer in one sentence before asking the next question.

## Turn Budget and Convergence

- Target 4 to 8 turns.
- Hard cap at 10 turns.
- At turn 8 or later, shift to convergence mode:
  - Stop opening new branches.
  - Prioritize unresolved critical uncertainty only.
- At turn 10, force synthesis and propose closure. Use this prompt at turn 10 if still ambiguous:

  > We reached the 10-turn limit. I will now synthesize your current best intention, list key uncertainties to validate, and propose one concrete next step.

## Question Ladder

Use this order unless context strongly suggests a different order.

1. Scope: What is this idea trying to change?
2. Outcome: What observable result would mean success?
3. User/Actor: Who benefits or interacts with this system?
4. Constraint: What must remain true (time, resources, architecture limits)?
5. Assumption: What are you currently assuming without proof?
6. Alternative: What is a plausible opposite approach?
7. Evidence: What signal would confirm or falsify this direction?
8. Decision: What is the smallest irreversible choice here?

## Quality Bar for the Final Synthesis

Before finalizing, verify:

- Intention is specific, not just a topic label.
- Validation questions are testable, not philosophical restatements.
- Next action can be executed within a clear short window (for example, one working session).

## Final Output Template

Use this exact template:

**One-sentence intention**
<single sentence, concrete and decision-oriented>

**Validation questions**
1) <question that tests feasibility or architecture fit>
2) <question that tests user/value alignment>
3) <question that tests execution risk>

**Next action**
<one concrete step to run immediately>

## Style Constraints

- Be precise, direct, and non-therapeutic.
- Do not lecture on logic frameworks; apply them through questions.
- Avoid broad multi-question turns.
- Prefer operational language: goal, constraint, evidence, decision, tradeoff.
- If the user's thought is already clear enough, skip the ladder and output the final template directly.
