---
name: dev-env-sync
description: Sync this machine's live dotfiles and configs into the ~/src/dev-env repo, commit, and push. Use when the user asks to update, back up, or push dev-env, or to start tracking a new config file there.
---

# dev-env sync

`~/src/dev-env` is a **copy-based** config repo, not a symlink/stow farm. Live
configs drift from it silently, so the repo is only as good as the last sync.

`sync-dev-env/manifest.tsv` is the single source of truth for what gets copied.
Everything else on the machine is untracked by design.

```
sync-dev-env/manifest.tsv     REPO_PATH <TAB> SOURCE_PATH [<TAB> ex:GLOB,GLOB]
sync-dev-env/candidates.txt   advisory list of config locations worth checking
sync-dev-env/sync.sh          status | pull | scan | check   [--only PATTERN]
```

## Rule: never add to the manifest on your own

Detection is automatic, adoption is not. `scan` reports what exists on this
machine but isn't tracked — that is a *suggestion list*. Only add a line to
`manifest.tsv` when the user says yes to that specific path. A config repo the
user doesn't fully trust is worse than one that's a bit behind.

## Workflow

Run from `~/src/dev-env`.

1. **Get current.** `git status --short` and `git pull --rebase`. If the tree
   already has uncommitted changes, show them and ask before piling a sync on top.

2. **Show drift.** `sync-dev-env/sync.sh status`. This is content-based (rsync `-c` /
   `cmp`), so anything listed is a real difference, not a timestamp. Read it out
   for the user — which entries changed, roughly what.

3. **Scan for new things.** `sync-dev-env/sync.sh scan`. Present the hits as a short
   list with a one-line guess at what each is, and ask which (if any) to start
   tracking. Default answer is none. For each yes:
   - pick a repo path that matches the existing convention — a package dir named
     after the tool, containing the home-relative path (`fish/.config/fish/`,
     `zshrc/.zshrc`). Editor configs under `~/Library/Application Support` don't
     mirror; follow `vscode/vscode-settings/settings.json` instead.
   - append the line to `manifest.tsv` under the right section header.
   - if the source is a directory holding state as well as config, add an
     `ex:` field rather than tracking the noise.

4. **Copy.** `sync-dev-env/sync.sh pull`. Directories mirror with `--delete`, so files
   removed on the machine disappear from the repo too — that's intended.

5. **Check for secrets.** `sync-dev-env/sync.sh check`. Non-zero exit means stop,
   show the hits, and let the user decide. Do not commit past it.

6. **Review.** `git add -A && git diff --cached --stat`, then look at the actual
   diff of anything security-adjacent (`gh` config, `.gitconfig*`,
   `.claude/settings*.json`). Call out anything surprising before committing.

7. **Commit and push.** Match the repo's commit style: short, imperative,
   lowercase-ish, one line, no body unless it earns one — "Add mkcd",
   "Update keybindings.json", "Set global git config `recurse=true`". For a
   multi-package sync, name what actually changed rather than writing
   "Sync configs": e.g. "Add claude skills and hooks; update fish config".
   Then `git push`.

## Things that must never be tracked

`check` enforces these, but know them anyway:

- `~/.config/gh*/hosts.yml` — OAuth tokens. Only `config.yml` is synced.
- `~/.ssh/id_*`, `~/.netrc`, `*.pem`, `.env`, anything under `~/.aws/credentials`.
- `~/.claude/` state: `history.jsonl`, `sessions/`, `projects/`, `shell-snapshots/`,
  `telemetry/`, `cache/`, `file-history/`. The manifest allowlists only
  `CLAUDE.md`, `settings.json`, `hooks/` and `skills/`, and `skills/` excludes `.trash` and `synced`
  (managed via claude.ai). `commands/` is not tracked.
- `~/.claude/settings.local.json` — machine-local permission grants, deliberately
  untracked. If the user asks for it back, say what it holds first.

## Notes

- Symlinks pointing outside a synced tree are dereferenced into real files
  (`--copy-unsafe-links`), so a skill symlinked from elsewhere lands as content.
- `--only PATTERN` limits any subcommand to matching manifest entries, e.g.
  `sync-dev-env/sync.sh pull --only claude`.
- Restoring repo → machine is deliberately not implemented. Adding it means
  overwriting live configs, which needs its own design.
- A global `~/.claude/AGENTS.md` is already listed in `candidates.txt`; it'll
  show up in `scan` the moment it exists.
