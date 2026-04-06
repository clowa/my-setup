---
name: git-commit-message
description: Create a git commit message using semantic commit message style
allowed-tools: Bash(git log *), Bash(git status *), Bash(git diff *)
---

## Context

- Current git status: !`git status`
- Current git diff: !`git diff HEAD`
- Recent commits: !`git log --oneline -n 5`

## Semantic Message Style

Format: <type>(<scope>): <subject>
<scope> is optional

- `feat`: Used when a new feature is added to the application, not a new feature for build scripts
- `fix`: Used when a bug is fixed in the application, not a bug in a build script
- `docs`: Used if only documentation-related changes are made.
- `style`: Changes that do not affect the code's functionality, only related to formatting, missing semi colons, etc; no actual code changes
- `refactor`: Used to restructure the code without changing its functionality.
- `test`: Used for any changes made to tests, eg. adding or updating tests
- `chore`: Non-functional changes to the code or dependencies. For example, package updates or changes in build configurations, updating grunt tasks etc
- `perf`: Used for changes made solely to improve performance without altering functionality.
- `ci`: Used for changes related to continuous integration configuration.
- `build`: Used for changes related to the build system, such as build settings or dependency management.
- `revert`: Reverts the effects of a previous commit by mentioning it by reference like short commit id, PR id, etc.

**Scope (Optional):**
Specifies which module, file, or component the change was made on. It is written in parentheses along with the type. 
Examples: feat(auth), fix(ui), docs(readme), style(header), chore(deps), refactor(api), test(login), perf(image-loader), ci(travis), build(webpack), revert(api)

**Subject:**
Briefly and concisely describes what the commit does. It should be written in a maximum of 50 characters.

Examples:

- feat(auth): add login functionality
- fix(ui): resolve button alignment issue
- docs(readme): update installation instructions
- style(header): fix indentation
- chore(deps): update axios to v0.21.1
- refactor(api): optimize fetch method
- test(login): add unit tests for login function
- perf(image-loader): optimize image loading for faster page speed
- ci(travis): add deployment step to pipeline
- build(webpack): update webpack configuration for faster builds
- revert(api): revert API changes that caused issues with data fetching
