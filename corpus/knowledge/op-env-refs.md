# Vault-ref env file discipline (`op.env`, `refs`, `run`)

Source: `~/.local/bin/the-janitor` `cmd_refs` (L228–235) and `cmd_run`
(L237–249); `stat` on `~/.config/the-janitor/op.env` taken 2026-09-28.
The file's *contents* were not read — this entry describes the mechanism, not
the keys.

## The pattern

`op.env` is the single env file consumed by `op run`. Convention enforced by
`cmd_refs`'s awk filter (L234): each line is `KEY=<value>`; the value is
expected to be an `op://vault/item/field` reference, which `op run` resolves
at exec time inside the child process. Secret bytes never live in the file —
only pointers into the vault.

- File observed: `-rw-------` (0600), 1078 bytes, mtime 2026-08-27.
- Path override: `THE_JANITOR_ENV` (default `~/.config/the-janitor/op.env`, L7).

## Two verbs, different audiences

| Verb | Reads | Prints | Auth used |
|---|---|---|---|
| `refs` | `op.env` text | `KEY=op://…` verbatim **or** `KEY=<redacted-non-op-value>` | none (no `op` call) |
| `run [--] <cmd>` | `op.env` via `op run --env-file` | whatever `<cmd>` prints | **caller's** `op` authorization, not the handler's |

`refs` redaction direction matters: it hides *raw values*, but `op://` paths
are shown verbatim — vault/item/field names leak into stdout. Treat `refs`
output as internal metadata: fine to act on, wrong to paste into reports,
commits, or handoffs (this corpus lists no ref paths for that reason).

`run` failure modes: missing env file → `the-janitor: missing <path>` exit 2;
missing `op` → `required command not found: op` exit 2; no command →
`the-janitor run: missing command` exit 2. A locked/absent caller-side `op`
authorization fails inside `op`, not in the wrapper — expect `op`'s own error.

## Discipline checklist implied by the code

1. New keys go in `op.env` as `KEY=op://…` — a raw value would be flagged by
   `refs` as `<redacted-non-op-value>` and sits at 0600 in a file other tools
   may read.
2. `run` is for one-shot caller-side use; anything persistent goes through
   `the-janitor request` (stdin), which carries handler authorization.
3. Never diff/copy `op.env` into artifacts; the *shape* (`KEY=op://` lines,
   0600) is the only durable fact worth recording.

## Falsification

- `the-janitor refs` output format matches the awk line at L234.
- `stat -c '%a' ~/.config/the-janitor/op.env` → `600`.
- `the-janitor run` with no args → `missing command`, exit 2.
