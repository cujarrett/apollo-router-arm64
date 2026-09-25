# apollo-router-arm64

Builds `ghcr.io/cujarrett/apollo-router-arm64`, Apollo's router from its tagged source with `JEMALLOC_SYS_WITH_LG_PAGE=16`, because the official image aborts on a 16K-page kernel. The Apollo operator in [homelab](https://github.com/cujarrett/homelab) points at it through `deployment.podTemplate.image`.

One file matters: `Dockerfile`. The version is `ARG ROUTER_VERSION`, tracked by Renovate against Apollo's releases. The runtime stage must stay a drop-in for upstream's image: `/dist/router`, `/dist/config`, `/dist/schema`, user `router`.

## Rules

- **Never run `git add`, `git commit`, `git push`, or any git command that writes to or modifies the index, repository history, or remotes.** Output the commands for the user to run. Staging is part of their review.
- **Whenever a task requires a commit, always give a suggested commit message.** Give `git add` and the commit as two separate steps, listing every file explicitly. Never output a `git push` command.
- **Never add a `Co-Authored-By` trailer or a "Generated with Claude Code" line** to commit messages or PR descriptions, including in suggested commit messages. Commits are authored by the user alone.
- Never use an em dash. Code comments are two or three lines, one fact per line.

### Pre-commit safety check

Before telling the user to commit, always run `/security-review`. It reviews the pending changes on the current branch for security issues. Once it confirms the changes are safe, offer the user a suggested commit message - do not run `git commit` yourself.

## Philosophy: Grug-Brained Development

> "Complexity very, very bad." - [grugbrain.dev](https://grugbrain.dev/)

- **Say no.** The best weapon against complexity is the word "no". No new feature, no new abstraction, until it earns its place.
- **Cheapest rung that works.** Before writing code go down the ladder and stop at the first rung that solves it - skip the feature, reuse code already here, standard library, native platform feature, a dependency already installed, one line, then build the minimum.
- **Chesterton's Fence.** Understand why code exists before removing it. If you don't see the use, go away and think.
- **Boring, obvious code wins.** Intermediate variables with good names beat clever one-liners. Easier to debug.
