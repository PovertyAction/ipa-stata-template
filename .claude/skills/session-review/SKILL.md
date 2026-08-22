---
name: session-review
description: Review session for AGENTS.md additions and skill opportunities
---

# Session Review for Knowledge Capture

Review this session to identify high-value learnings worth persisting. Focus on two outputs:

## 1. Project Instructions Updates

Scan the session and commits on this branch for insights that would help future Claude sessions in this project. Only add items that are **genuinely high-value** - things that:
- Took significant effort to discover
- Would save time in future sessions
- Are non-obvious from the codebase alone
- Are project-specific patterns or gotchas

Examples of what to add:
- Build/test commands that aren't documented
- Critical file locations or module relationships
- Workflow requirements or constraints
- Common errors and their solutions
- Naming conventions or patterns

If you find something worth adding, edit the project's instructions file directly (`AGENTS.md` or `CLAUDE.md`, whichever the project uses). Keep entries concise and actionable.

## 2. Skill Opportunities

Consider whether any task from this session should become a reusable skill. A skill is worth creating if:
- The task required multiple steps that could be templated
- The user is likely to need this workflow again
- The task required specific domain knowledge

If you identify a skill opportunity, either:
- Create it in `~/.claude/skills/<skill-name>/SKILL.md` (for cross-project skills)
- Create it in `.claude/skills/<skill-name>/SKILL.md` (for project-specific skills)

## Output

Summarize what you found:
1. What (if anything) was added to project instructions
2. What (if anything) was created as a skill
3. Any observations that don't fit neatly into either category but are worth noting

If nothing meets the bar for documentation, say so - don't force additions.
