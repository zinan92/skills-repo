---
name: remotion-best-practices
description: Use when Donald is planning or refining Remotion-based video logic, composition structure, captions, or render decisions.
platform: both
scope: agent:donald
---

# Remotion Best Practices

Use this skill when a workflow step involves Remotion design decisions rather than pure script execution.

## Use This For

- planning Remotion compositions before rendering
- mapping transcript logic into scenes, timing, and transitions
- deciding caption handling and subtitle timing
- choosing when to use FFmpeg before or after Remotion
- checking whether a step is a Remotion planning task or just a render command

## Do Not Use This For

- simple shell execution with no Remotion decision-making
- generic React advice unrelated to video composition
- pipeline orchestration questions that belong to SOP design

## Working Rules

1. Separate planning from rendering.
   - Planning is a skill-guided step.
   - Rendering is usually a deterministic script step.

2. Keep compositions explicit.
   - Define scene purpose, duration, inputs, and transitions before coding.

3. Treat captions as a first-class design layer.
   - Check timing, line length, readability, and overlap with other visuals.

4. Use FFmpeg for media preprocessing.
   - Trim, crop, detect silence, or normalize assets before Remotion when possible.

5. Prefer reusable composition patterns.
   - Reuse scene types and layout logic instead of inventing a new structure per video.

## Review Checklist

- What is the composition list?
- What props or metadata does each composition need?
- Which inputs are required from transcript, audio, or assets?
- Which steps belong in Remotion, and which belong in FFmpeg or other scripts?
- Is the output format already clear before coding starts?

## References

- Official upstream source: `https://github.com/remotion-dev/skills/blob/main/skills/remotion/SKILL.md`
- Use the upstream repo for deeper domain guidance if this local canonical version is not enough.
