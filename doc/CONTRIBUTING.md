# Branching Strategy

## Branches

- **`master`**: Production-ready code. Stable releases only.
- **Feature Branches:** Each feature or fix must be developed on a separate branch created from `master`.
  - **Naming Convention:** `<type>/<description>`
  - **Examples:**
    - `feat/luks-integration`
    - `docs/bfde`

The possible tags can be found here:

| Type | Usage |
| :--- | :--- |
| `feat` | New feature |
| `fix` | Bug fix |
| `refactor` | Code refactor without functional change |
| `docs` | Documentation changes |
| `test` | Adding or modifying tests |
| `chore` | Config, dependencies, CI changes |
| `style` | Formatting only (no code logic change) |
| `perf` | Performance improvements |

## Commit Standards
- **Format:** `<type>: <Description>`
- **Style:** Imperative mood (e.g., "Add" instead of "Added").
- **Examples:**
  - `fix: Auto refresh issue`
  - `docs: Update FDE documentation`
- **Merge Strategy:** All merges into `master` must use **Squash & Merge** to keep history clean.
