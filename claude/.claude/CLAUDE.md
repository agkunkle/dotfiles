# Global Claude Code Instructions

This file contains your personal preferences and instructions for Claude Code across all projects.

IMPORTANT: to support cross-use of different AI tools, you are always to consider AGENTS.md instructions files and you should prioritize updating these over CLAUDE.md.  Use AGENTS.md as the more generally accepted convention! You can use your global ~/.claude/CLAUDE.md file but do NOT create CLAUDE.md files for projects - always read/create/update AGENTS.md

---

## Communication Style

**Tone & Detail Level:**
- Preferred response style: balanced
- Use of emojis: sparingly
- Explanation depth: provide context
- Progress updates: regular

**Interaction Preferences:**
- Ask before proceeding: for risky actions only
- Proactivity level: suggest improvements / auto-fix issues

**Writing Style:**

For explanations and normal conversational responses, write approximately
80% of the way toward ASD-STE100 Simplified Technical English.

Prefer:
- simple, direct vocabulary
- one term for one concept; do not vary terminology for style
- short sentences
- active voice
- one main idea per sentence
- explicit subjects and objects
- minimal filler, hedging, and rhetorical transitions

Do not omit important technical detail merely to satisfy the style.
Technical terminology, code identifiers, and domain-specific language are allowed.

Exception: for creative work done together (stories, fiction, other creative writing),
do NOT apply the ASD-STE100 guidance. Use whatever voice, vocabulary, and rhythm
fit the piece.

**Diagrams:**

Use diagrams when they materially reduce the effort required to understand structure,
sequence, state, dependency, ownership, or data flow.

- Design each diagram around the question it must answer.
- Choose the correct semantic diagram type. Do not default to a flowchart.
- Keep nodes and labels concise. Use consistent terminology.
- Label meaningful edges. Show important boundaries.
- Omit information that does not improve the reader's mental model.
  Every node and edge should encode useful information.
- Prefer a clear overview plus focused detail diagrams over one crowded diagram.
- Draw diagrams as ASCII art in the TUI. Do not use Mermaid.
- Check that the diagram is logically consistent and that the alignment is correct.
- Optimize for the time a technically competent reader needs to form the correct
  mental model. Do not optimize for completeness or visual complexity.

---

## Code Conventions

**Naming Styles:**
- Variables: snake_case
- Functions: snake_case
- Classes: PascalCase
- Constants: UPPER_SNAKE_CASE
- Files: snake_case

**Code Organization:**
- Line length limit: 100
- Indentation: 2 spaces
- Quotes:  context-dependent

**Comments & Documentation:**
- Inline comments: when needed
- Function documentation: when complex
- JSDoc/docstrings: exports only
- TODO comments: use liberally

**Testing Approach:**
- Test framework preference: pytest / gtest
- Write tests: always
- Test style: balanced
- Coverage expectations: reasonable

---

## Tool Preferences

**Git Workflow:**
- Commit message style: conventional commits
- Branch naming: name-description
- Auto-push: after commits
- Pre-commit hooks: always run

**File Operations:**
- Backup before major changes: never
- Create new files vs edit existing: prefer editing
- File organization: nested by feature

**Package Management:**
- Preferred package manager: pip
- Update dependencies: minor versions OK
- Install new packages: proceed if needed 

---

## Technologies

**Primary Languages:**
- Python, C, C++, Bash, Javascript

**Common Frameworks:**
- Frontend: [React / Vue / Angular / Svelte / other: ____]
- Backend: [Express / FastAPI / Django / Rails / other: ____]
- Testing: [Jest / pytest / RSpec / other: ____]
- Build tools: [Vite / Webpack / esbuild / other: ____]

**Development Environment:**
- Operating system: Windows / Ubuntu
- Shell: bash
- Editor: VS Code (vim plugin)

**Architecture Preferences:**
- API style: REST
- Database: PostgreSQL 

---

## Permissions & Authorization

**Automated Actions:**
- Run tests automatically: yes
- Install dependencies: yes
- Format code: yes
- Commit changes: proceed when requested
- Push to remote: proceed for non-main branches

**Destructive Operations:**
- Delete files: always ask
- Force push: always ask
- Drop database tables: always ask
- Modify CI/CD: always ask

**External Communications:**
- Create/comment on PRs: ask first
- Post to Slack/messaging: never
- Send emails: never

---

## File viewer (VS Code)
Use the VS Code CLI to show the user a file in the editor while we chat. Do this for
Markdown, images, long code, CSV and JSON. The command opens the file in the window that
owns this terminal.
`code -r -g FILE[:LINE]`
- `-r` reuses the current window. A second file opens as a new editor tab.
- `FILE:LINE` jumps to a line. Use it when you point at code.
- Open files reload on change, so edit the file and the user sees the update.
- Images render natively. JSON and CSV open as text.
- Markdown renders only if the user sets
  `"workbench.editorAssociations": {"*.md": "vscode.markdown.preview.editor"}`.
- VS Code does not render HTML. It opens as source.
- Do not open files the user did not ask to see, unless a rendered view helps.

---

## Project-Specific Overrides

If a project has its own AGENTS.md file, these preferences should be:
- Merge with project preferences, ask about conflicts

---

## Additional Notes

[Add any other preferences, quirks, or context about your workflow that would help Claude Code assist you better]

---

**Last Updated:** 2026/02/14
