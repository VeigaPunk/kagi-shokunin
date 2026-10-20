# Entry10 — `handler-on-disk-state.md` freshness/calibration audit

Seat: read-only scout. Base: `c2cab35bc92e57e39e5489bac3386db078345b3f`.
Scope: `corpus/knowledge/handler-on-disk-state.md` and its row 18 in
`corpus/stamps.tsv` only.
Method: committed blobs and worktree bytes, read-only git object comparison, and
one metadata-only existence probe of the six substrate paths. No host gate was
run (`claim-ledger.sh`, `surface-census.sh`, `drift-pins.sh`, `state-shape`
were not executed). No file content outside the repo was read. No installs.

## Verdict

1. **The stale-byte mismatch is real and fully attributed.** Row 18 pins
   `811572dc…` / 247 / 17609 = the round-14 blob (`2486643`). The file at the
   base is `df6a5e5d…` / 277 / 19329 = the round-16 blob (`f4a8dd9`). The whole
   delta is the appended `## Historical-source erratum` block: `+30` logical
   lines, `+1720` bytes, and **no pre-existing byte changed** (proof in §Evidence).
   This is pin drift, not a rewritten observation.
2. **Substantive freshness is unchanged, and cannot be improved.** The six
   substrate paths are still `ENOENT` (probe `2026-10-20T21:40:47Z`), so no
   source-derived claim can be re-measured. The round-16 erratum already gives
   the correct bound ("historical … not current handler guarantees"). Nothing in
   this entry is a *current* overclaim except the drifted `SCORECARD.md` line
   pointers in that erratum (item 3).
3. **One appended correction is needed, for a different defect.** The erratum
   cites `SCORECARD.md:454-466` and `:496-506`. Those ranges were exact at
   `f4a8dd9`; `c41af82` (round 21) inserted four lines above them, so at the base
   the debt text is `458-470` and the count block is `500-510`. The section
   text is byte-identical, only shifted. Fix by appending a dated note with
   stable anchors, not by editing lines 250-278.
4. **A per-file re-pin is not expressible.** `stamp` replaces the whole row set
   and refuses a shrink without `--prune` (`claim-ledger.sh:236-257`). Re-pinning
   this row therefore refreshes all 63 rows, including five other stale rows
   this seat did not audit (their status is outside this lane). At the base, six
   rows mismatch (`before.json` records the same six independently). The lawful
   options are a reviewed whole-set re-pin with a journaled
   tuple per changed row, or leaving all six stale with the lag named. My
   recommendation: **journal this round; do not `stamp`.**

## Evidence — the row against the bytes

| Item | Read | Value |
|---|---|---|
| Stamp row 18 | `corpus/stamps.tsv:18` | `811572dcf630efc89e9222ed6c9e545a9b755f05be2908a6e0487a0fa8862be2` 247 17609 |
| Worktree file | `sha256sum`, `wc -l`, `wc -c` | `df6a5e5d05f4fa06cdcf2114c3a212e48c6b697d56cca1ced63342133e649c38`; 277; 19329 |
| Logical lines | `awk 'END{print NR}'` | 278 (last line unterminated — `wc -l` is 277 by design) |
| Blob identity | `git rev-parse c2cab35:<path>` | `ff64db66008451bbf5cfde884ebac6b0d6be8ae0` |
| Old blob | `git show 2486643:<path>` | `811572dc…`; 247 newlines; 17609 B |
| Prefix proof | `head -c 17609 <file> \| sha256sum` | `811572dcf630efc89e9222ed6c9e545a9b755f05be2908a6e0487a0fa8862be2` — byte-identical |
| Append delta | `git diff --numstat 2486643 f4a8dd9 -- <path>` | `31 1` (31 insertions, 1 deletion; net `+30` lines, `+1720` B) |
| Sole deletion | `git diff 2486643 f4a8dd9` | the closing ```` ``` ```` line re-emitted with a trailing newline; no text lost |
| Row stability | 9 commits ever touching `corpus/stamps.tsv` | row present in all 9; value unchanged from `2486643` through `c2cab35`; earlier value at `4b8c018` was `8e941945…` 245 17583 |
| Membership | consecutive stamp revisions, `LC_ALL=C comm` | 28 → 63 rows over 8 transitions; **0 path drops**, additions only (5, 11, 4, 4, 2, 2, 7, 0) |
| Wave baseline | `.ufo/waves/round-22/before.json` | `stale_count: 6`, same six paths — recorded independently of this loop |

Stale set at the base (bytes vs rows, computed read-only on git blobs):

| Path | Pinned (sha/lines/bytes) | At base |
|---|---|---|
| `corpus/knowledge/config-layering.md` | `848b8e50…` 109 6621 | `9d4ac8c2…` 136 8088 |
| **`corpus/knowledge/handler-on-disk-state.md`** | **`811572dc…` 247 17609** | **`df6a5e5d…` 277 19329** |
| `corpus/knowledge/handler-trust-boundary.md` | `263c7b0e…` 285 17669 | `fa17fff3…` 316 19410 |
| `corpus/knowledge/janitor-env-contract.md` | `88dca63a…` 90 5111 | `dac43ef9…` 113 6372 |
| `corpus/lessons/round-18.md` | `614335f2…` 73 4216 | `b00b7dd8…` 80 4557 |
| `LOG.md` | `60a8fd36…` 1043 74864 | `51e76cf1…` 1050 75404 |

Historic counts of the same comparison: `aea7a43` = 9 (matches the round-21
record, `LOG.md:983`), `c41af82` = 5, `e1544c1` = 5, `c2cab35` = 6. `LOG.md`
became the sixth at `c2cab35`, which added 7 lines to it ("preserve local round
log") without a stamp. The live worktree currently shows 10 because four
tracked files are dirty from concurrent writer seats — see §Limits.

## Substantive freshness, and what absence bounds

- The entry's dates are the newest evidence available: `verified 2026-09-28`
  (line 13) and the erratum dated `2026-10-15` (line 250). No later read of this
  source is recorded in the corpus; the round-19 re-census records the absence.
- Probe, metadata only (`test -e` / `stat -c '%F %a %s'`, no content read):
  `~/.local/bin/the-janitor`, `~/.config/the-janitor/client.py`,
  `~/.config/the-janitor/config.json`, `~/.config/the-janitor`,
  `~/.local/state/the-janitor`, `~/.cache/the-janitor` → all `ENOENT`;
  `command -v the-janitor` → empty. `2026-10-20T21:40:47Z`.
- That is a *fresh absence datum*, not re-verification. It rules out restoration
  as of today; it says nothing about the 2026-09-28 bytes.
- The abbreviated hashes in lines 3-6 remain consistent with the committed
  baseline: `corpus/drift-baseline.tsv:1-2` records `2408b0c9…57edd` / 333 lines
  / mode 755 and `8179b241…` / 117 / 755. Consistency with a baseline is not
  proof of the absent file; do not expand those prefixes into this entry.
- `Reverify: R11-01, R11-04` (line 16) resolves — both are ledger rows — but
  both are `[substrate]`-tagged (`corpus/claim-ledger.tsv:15,18`) and
  `substrate_present()` is `[[ -x "$HOME/.local/bin/the-janitor" ]]`
  (`claim-ledger.sh:138-144`). They therefore `DEFER reason=substrate-absent`
  (`:397-399`), never run. The declaration is a dependency, not an executed
  check, and `DOC_AUDIT` cannot see the difference: it counts `row_linked=2`.
- There is no by-hand class for "substrate absent" — `BYHAND_CLASSES` is exactly
  `control-plane-scratch|opencode-internal|interactive-only|vault-refusal`
  (`claim-ledger.sh:831`). So an absent-substrate entry must carry its bound in
  prose (the erratum), which is what this one does. Any future ledger
  expectation change should say so explicitly rather than imply `Reverify:` was
  satisfied.

Cannot be claimed from this seat: current handler/client hashes or line numbers,
DB census, lock timings, mode discipline, or anything about deletion of the
substrate elsewhere.

## Appended correction — exact content, not a header

Append after the current final line (278), preserving the no-trailing-newline
convention. Required assertions, in this order:

1. Heading `## Round-22 audit erratum (2026-10-20)` — dated, append-only.
2. Stamp provenance: row 18 pinned the round-14 blob (`811572dc…`, 247, 17609);
   the current bytes (`df6a5e5d…`, 277, 19329) differ only by the round-16
   erratum append at `f4a8dd9`; `head -c 17609` still hashes to `811572dc…`.
   One sentence, no restatement of the source findings.
3. Pointer correction: the erratum's `SCORECARD.md:454-466` / `:496-506` were
   exact at `f4a8dd9`; `c41af82` shifted them `+4`; at `c2cab35` the debt block
   is `SCORECARD.md` §Round-19 correction (`:458-470`) and the SOURCE_FRESHNESS
   block is §Current baseline — round-16 re-dispatch (`:500-510`). Prefer the
   heading names + revision row `f4a8dd9…`, since the line numbers have already
   moved once.
4. Absence re-probe: metadata-only, six paths `ENOENT`, `2026-10-20T21:40:47Z`,
   no content read, no gate run. Historical status unchanged; the deferred rows
   remain deferred.
5. Explicit non-claims: no source bytes, no `op.env`, no DB text, no behavior
   exercised; no current hash, posture, or domain-task claim; no depth claim.

Do **not** add a `Source-status:` header block at the top of the file — the
erratum form is the corpus convention for this entry, and editing lines 1-278
would break the byte-prefix proof above. Do not draft claim ids or criterion
rows; those belong to the ledger/QUALITY lanes.

## Exact recheck scope (conditional; not authorized now)

Only after operator-authorized substrate restoration, and only with the
separate authorization the erratum already requires. Every expected value below
is the *2026-09-28 observation to be re-measured*, never an assumption.

| Group | Claim to re-measure | Command (read-only unless noted) | Expected from the entry |
|---|---|---|---|
| G0 presence | substrate restored | `for p in ~/.local/bin/the-janitor ~/.config/the-janitor/client.py ~/.config/the-janitor/config.json; do stat -c '%n %F %a %s' $p; done` | three regular files today absent |
| G1 identity | source basis lines 3-6 | `sha256sum` the two sources; `wc -l`; compare **full** hashes to `corpus/drift-baseline.tsv:1-2` | `2408b0c9…57edd`/333; `8179b241…`/117 |
| G2 code lines | L186-226, L77-120, L145-171, L130/139/175, L303-330; client L22-38/49-65/67-96/98-100/103-113 | `grep -n` the named functions/verbs in both sources | ranges as printed; "re-grep before citing" already stated |
| G3 layout | three XDG roots, modes, sizes | `stat -c '%A %a %s' $STATE_DIR{,/xdg-data,/xdg-cache,/xdg-state}`; `find … -type d -empty` | 0700 roots; DB 9,240,576 B; log 33,687 B; models.json 4,709,964 B; `repos/`, `bin/`, `locks/` empty |
| G4 census | 7/39/55/238; part and event type histograms; 7 `janitor_auth`; 2 `JANITOR_ACTION_REQUIRED`; 0 `op://`; time bounds | copy DB to `/tmp` first **or** `file:…?immutable=1`; then the §Repro queries | counts and `event.type`-column histograms as printed |
| G5 log | 84 levels all ERROR; 8 `run=`; 61 `message="stream error"` of which 60 carry the API string; 10 process lines (2 `Aborted`); `grep -c 'Cannot connect to API'` = 70; 10 plugin lines; window 2026-08-29→2026-09-21 | `grep -o`/`grep -c` on `opencode.log` | as printed; never rotate/truncate while measuring |
| G6 behavior | lock wedge, 64 s `ensure_started`, foreign-server branch, 401 path | scratch `THE_JANITOR_STATE_DIR` + isolated `TMUX_TMPDIR` (never the real pane/lock); 2 s timeouts | `stop`/`start` exit 124 while held; `status` exit 0; ~64 s, not 60 |
| G7 shape pins | floors still hold | read `corpus/state-shape.tsv` rows: `session:2 message:13 part:18 event:79`, `tables_min 12`, log `size_min 16384`, mode 600 | floors are one-third of observed, not the counts |

Gates that must **not** be used as re-verification: `surface-census.sh` and
`drift-pins.sh` live modes read host state (and `drift-pins` reads the dotenv
path when present); they are `R11-01`/`R11-04` and remain `DEFER`red. Never run
them to "clear" this entry.

## Provenance requirement

Every re-measured claim must carry, in the appended record: full sha256 (compared
against `corpus/drift-baseline.tsv`, not printed into the entry), command text,
UTC timestamp, and the commit/blob read. Abbreviated-prefix equality alone is
explicitly not proof (the entry's own erratum says so). `mtime` is never a bound
— the DB mtime moves on any open, including a read-only one. DB reads go through
a copy or `immutable=1`, never the live path. No secret/session content is read;
counts and type strings only.

## Append-only preservation requirement

- Bytes `1..19329` must remain unchanged: `head -c 19329 <new>` hashes to
  `df6a5e5d…` (the same test that proves `2486643 → f4a8dd9` today).
- `git diff --numstat <base> <new>` must show insertions only, plus at most the
  one unavoidable `\ No newline at end of file` replacement when the current
  final line gains a newline. No deletion of any line 1-278.
- Keep one unterminated final line, so `wc -l` continues to equal logical lines
  minus one; state both numbers in the journal so no one "corrects" 277 to 278.
- One commit. The message names the old→new tuple and the audit seat
  (`Entry10`) for this row, and any other row whose value changes.

## Ledger expectation migration (what this row proves)

1. **A pin is set-level, not file-level.** `stamp` regenerates the entire row
   set; the no-shrink guard refuses dropped membership without `--prune`
   (`claim-ledger.sh:236-257`). A "re-pin just this reviewed file" operation
   does not exist. `--prune` for that purpose is silent deletion — the round-12
   class the guard was built for.
2. **Practice already diverged from the replace contract.** The committed row
   set cannot be a single full-set `stamp` over the then-current tree:
   my file's bytes were identical at `aea7a43` and `c41af82`
   (`df6a5e5d…` at both, hashed from blobs), yet round 21's rewrite kept the
   stale `811572dc…` row while adding 7 rows. A full-set run would have
   refreshed it. The write mechanism is not recorded in `LOG.md`; the
   observation is the inconsistency, the mechanism is `[INFERENCE]`.
3. **Consequence for round 22.** `verify` fails while `V_STALE > 0`
   (`claim-ledger.sh:951-952`); at the base six rows mismatch. Either:
   - (a) journal the six old→new tuples, leave the paths stale, and accept
     `stale=6` in the verify line; or
   - (b) re-pin the whole set after every writer settles, with an audit
     reference for **each** changed row and the previous tuple journaled.
   Do not run `stamp` with a subset (refused or destructive) and do not use it
   to "clear the detector" on unreviewed rows. For this file specifically, the
   journal must quote two transitions if this round appends:
   `811572dc…/247/17609 → df6a5e5d…/277/19329` (round-16, unrecorded) and
   `df6a5e5d…/277/19329 → <post-append>` (round-22).

## Limits and unresolved

- **Worktree is dirty and moving.** At first read the tree held four modified
  tracked files (`corpus/QUALITY.md`, `corpus/SOURCES.md`,
  `corpus/knowledge/onepassword-machine-credentials.md`,
  `corpus/knowledge/vault-openbao-token-lease-lifecycle.md`) plus three
  untracked round-22 files. By `2026-10-20T21:45:06Z` concurrent integration
  had produced 25 dirty/untracked entries. The target file was **not** touched
  at either observation: it still hashes to `df6a5e5d…`, 277/19329. All byte
  values here are for committed blob `c2cab35`; the worktree comparison yielded
  10 stale rows at first read, but the base's six are the only stable figure.
  Any re-pin must run after the integration settles and re-derive every
  non-target row.
- **"Nine dropped stamps" is not a membership fact in committed history.**
  Across 8 transitions the row set only grows (28→63) with zero path drops.
  `ConnectMistakes.md:24-26` accounts the nine as nine replaced *values*; I did
  not re-derive that count (outside this seat). My row is not one of them.
  Dropped-row accounting remains `ReviewStamps`/`AuditPinHistory`.
- `c41af82`'s four-line insertion is the sole cause of the pointer shift
  (`## Round-19 correction` at line 454 through `aea7a43`, at 458 from
  `c41af82`); the section bytes are identical (`cmp` over the shifted ranges).
- I did not run `verify`/`docs`/`cells` or any host gate, so the FAIL/exit-code
  expectation for `verify` is derived from the code path, not observed.
- No length or depth claim is made for this entry, and no new source was opened.

## Exact read revision

`c2cab35bc92e57e39e5489bac3386db078345b3f`

| Blob | SHA-1 |
|---|---|
| `corpus/knowledge/handler-on-disk-state.md` | `ff64db66008451bbf5cfde884ebac6b0d6be8ae0` |
| `corpus/stamps.tsv` | `aef5db6501082655ee4c3cb8155189c0961e4277` |
| `SCORECARD.md` | `cee48cdc7b3d968f4fa47ccac06143f355c9023a` |
| `corpus/claim-ledger.sh` | `1e69c589740d6a431d7a633045ec03a6a9afd427` |
| `corpus/claim-ledger.tsv` | `a8d3099a7e21cd0bafefacfa88fff0c1644bca35` |
| `corpus/drift-baseline.tsv` | `0a4dd3c8bb453f802e6f25b75cef021070a6621c` |
| `corpus/state-shape.tsv` | `b811cca9fb93c4a9e1758792a169578bfaa4011c` |

Installs/updates: none. Host gates run: none.
