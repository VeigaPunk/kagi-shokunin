# Entry07 — `control-plane-hardening.md` freshness / calibration audit

Scope: read-only audit of `corpus/knowledge/control-plane-hardening.md`
(182 lines) and its row in `corpus/stamps.tsv` (line 15), at frozen base
`c2cab35bc92e57e39e5489bac3386db078345b3f`. No corpus/host gate was executed;
no production file was written.

Axes: **freshness** (pin age, source availability, expectation migration) and
**calibration** (byte-stale vs substantively stale; admit only bounded
controls). No depth move; no legacy-header count; no new prose outside the
proposed append.

## Verdict

1. **There is no stale-byte mismatch.** The stamp row is exact on all three
   columns, today and at the commit that introduced it.
2. **The entry is substantively stale**: it is a current-voice recipe whose
   source objects have been absent from this host since 2026-10-14, and it is
   one of the entries citing the handler/`client.py` source basis without a
   historical-source qualifier; the four entries in the round-16 erratum set
   all received one. It is not the corpus's only unqualified 2026-09-28
   source entry (`credential-isolation.md` is another), and SCORECARD's
   four-entry freshness scope is explicit; see §2c.
3. **An appended correction is needed**, matching the convention already
   adopted at `f4a8dd9` for four sibling entries — but it must be
   **append-only** and **re-pinned in the same change**. The sibling remedy
   was applied without re-pinning and created four of the six stale pins
   measured below; that failure must not be repeated.
4. This row is **not** one of any nine "dropped" stamp rows in committed
   history; see §5, which bounds that premise.

## 1. Observed: pin identity (exact)

`corpus/stamps.tsv:15`:

```
corpus/knowledge/control-plane-hardening.md  dad0b983369f558bfd130f68d598561ba0a07974cff1c50cae583b7d7e2feaa7  182  10575
```

Recomputed on the working tree at 2026-10-20:

- `sha256sum` = `dad0b983369f558bfd130f68d598561ba0a07974cff1c50cae583b7d7e2feaa7`
- `wc -l` = 182, `wc -c` = 10575
- UTF-8, LF only (182 `$` line ends, no CR), file ends with `` ```\n ``.
- Working-tree bytes are identical to `HEAD` (`git show HEAD:<path>`), so the
  audit is against the frozen base, not local churn.

`stamp_cmp` (`corpus/claim-ledger.sh:334-350`) returns 0 only when sha, lines
and bytes all match; by code read plus the computed triple this row is `OK`,
not `STALE`. I did **not** run `claim-ledger.sh`.

At `2486643` ("round-14: freshness axis-move") the file blob hashes to the
same `dad0b983…` at 182/10575, and the same row appears in that commit's
`stamps.tsv`. The pin was generated from the shipped bytes, not repaired
afterward. `git log` shows only two commits touching the file: `51c9d30`
(round-7) and `2486643` (round-14). No later commit changed it.

## 2. Observed: the entry is substantively stale

Source status, checked 2026-10-20 on this host:

| cited source | status |
|---|---|
| `~/.local/bin/the-janitor` | absent (`ls`: ENOENT; `find ~/.local ~/.config ~/.local/state -iname '*janitor*'`: no hits) |
| `~/.config/the-janitor/client.py` | absent (ENOENT; parent dir also absent) |
| `~/.local/state/the-janitor/` | absent (ENOENT) |

This is not new information to the corpus: `PROVINCE.md` carries a
"Round-18 erratum (2026-10-14)" stating the substrate was measured absent,
and `corpus/knowledge/substrate-deferral.md:3-9` records the same census.
The gap is that **this entry does not carry the qualifier** four sibling
entries received:

- `config-layering.md:111`, `handler-on-disk-state.md:250`,
  `handler-trust-boundary.md:288`, `janitor-env-contract.md:92` each carry
  `## Historical-source erratum — round-16 re-dispatch (2026-10-15)` with a
  `Source-status: historical` line, qualified original line ranges, current
  path-presence metadata, and an explicit "no current … is claimed" bound.
- `control-plane-hardening.md` has no such section. Its line 3 still reads
  `Source basis: host inspection verified 2026-09-28`, in current voice, with
  line-number citations (`server_healthy` L72–75 … `_serve` L186–226;
  `client.py` `request` L22–38 … `health` L98–100) and `OpenCode 1.18.31`.

Severity is amplified by operator-facing pointers to this file as the rollout
recipe: `SKILL.md:86` and `SKILL.md:459` both say
"Rollout recipe: `corpus/knowledge/control-plane-hardening.md`", and
`corpus/README.md:52` lists it as the "operator recipe". None of those
pointers is labeled historical.

The `Reverify:` declaration at line 11 is the counted by-hand class
`control-plane-scratch`. It cannot be discharged on this host: the class's
measurement is scratch `serve` replicas, which require the absent substrate.
The declaration is still structurally valid (`docs` mode: one `^Reverify: `
line, allowed class, reason ≥ 24 chars, path pinned), so this is honest
*deferral*, not an undeclared entry.

### 2a. Calibration defect inside the `Reverify` line

Line 11 ends: "though the retention block is re-measured by R11-01".
Measured scope of `R11-01` (`corpus/claim-ledger.tsv:15`) is
`bash corpus/surface-census.sh`; its DB assertions in
`corpus/state-shape.tsv:27-35` are `magic`, `mode 600`, `size_min 1`,
`tables_min 12`, `tables_required`, and `rows_min` floors
(`session:2`, `message:13`, `part:18`, `event:79`). It does **not** re-measure
the entry's `9,240,576`-byte size or its `7/39/55` row counts, and it does not
re-measure the plaintext-retention conclusion. `R11-01`'s note also carries
the `[substrate]` tag, so on this host it is `DEFER`, not a pass.

Therefore the parenthetical is a **pointer overclaim** — exactly the
"declaration is a POINTER, not relevance" defect class named at
`corpus/claim-ledger.sh:59-63`. An erratum must bound it; it must not be
laundered by leaving a green-looking pointer.

### 2b. Version drift (host-level only)

`~/.local/bin/opencode` is a 1,460-byte bash launcher that resolves
`opencode-ai` through `npx --yes --prefer-online --package …`; it reports
`1.19.3` today. That is a **host launcher observation**, not the handler's
version: the handler is absent, and `--prefer-online` makes the figure
registry-dependent. The entry's `1.18.31` cannot be confirmed or refuted from
this host. [INFERENCE] the launcher is newer than the handler-era install;
this is not evidence about handler behavior.

### 2c. Scope of the round-16 freshness move (calibration bound)

`SCORECARD.md:490` defines the debt as "four unqualified historical source
entries", and `SCORECARD.md:505` hardcodes exactly those four filenames in its
counting command; the round-16 outcome (`SCORECARD.md:525-538`) then scores
freshness 8 → 9. That move is honestly bounded: `SCORECARD.md:532-538`
refuses a corpus-wide currentness claim ("an author judgment about the
corrected four-entry debt, not … corpus-wide currentness") and does not claim
the four are exhaustive.

Calibration consequence: freshness 8 → 9 is **true over the declared
four-file scope and silent outside it**. Entries that cite the same absent
handler/client sources remain unqualified — this one, and
`credential-isolation.md:3-5` ("All read 2026-09-28", no erratum). So a
round-22 statement that "source freshness is 9 / every historical source entry
is qualified" would be an overclaim. The correct statement is: "the four-entry
debt named at `SCORECARD.md:490` is qualified; entries outside that list were
not measured." Extending the remedy is a scope decision for the parent, not a
defect in the round-16 record as written.

## 3. Calibration decisions (admit / reject)

| # | Candidate claim | Decision | Binding evidence |
|---|---|---|---|
| D1 | "The stamp row is stale (byte drift)." | **Reject** | Triple matches exactly at worktree and at `2486643`; `stamp_cmp` would return 0. |
| D2 | "The entry is fresh / still current." | **Reject** | Cited sources ENOENT; no source-status qualifier; by-hand class unexecutable; host launcher moved to 1.19.3. |
| D3 | "Delete or rewrite the entry / drop the row." | **Reject** | Corpus convention is append-only (`f4a8dd9` errata; `SCORECARD.md` round-19 correction: "mark those lines historical in an append-only erratum"). |
| D4 | "Append a historical-source erratum to this entry." | **Admit, bounded** | Four sibling entries already use this exact form; `SKILL.md` routes operators here; original bytes can be preserved. |
| D5 | "R11-01 re-measures the retention block." | **Reject as written** | `state-shape.tsv` pins shape floors, not size/row counts; row is `[substrate]`-deferred. |
| D6 | "This row is among nine dropped stamps." | **Reject for this row** | Committed history is monotone: 28→33→44→48→52→54→56→63 rows across 9 commits, zero path removals (§5). |

Only D4 changes a file; D1/D2/D3/D5/D6 change no bytes and are recorded as
adjudications, not as authored rows. This is the round's intended shape:
correct decisions, not row counts.

## 4. Proposed correction — append-only, exact scope

If the parent declines the append, the minimum honest alternative is to record
the source-status debt in the round record and stop treating the entry as a
current recipe. Leaving it unqualified while claiming a round-22 freshness
reconciliation would be the laundering path.

### 4.1 Placement and preservation

- Append **after line 182**; lines 1–182 stay byte-identical. Do **not** edit
  line 1, the source-basis block (3–9), or the declaration (11).
- Preservation proof after the append, mirroring the round-16
  `SOURCE_PRESERVATION` check:
  `cmp <(git show c2cab35:corpus/knowledge/control-plane-hardening.md) <(head -c 10575 corpus/knowledge/control-plane-hardening.md)`
  must exit 0.
- Proposed heading, following the sibling convention exactly:
  `## Historical-source erratum — round-22 recheck (2026-10-20)`.
- Required statements (short, factual):
  - `Source-status: historical — … remain observations from 2026-09-28, not current handler guarantees.`
  - Qualifies original lines **3–11, 13–31, 33–76, 78–105, 107–120, 122–131,
    133–182** (source basis + declaration; finding; rollout/password; retention;
    config isolation; residual risk; reproduction).
  - `Path-presence metadata on this host on 2026-10-20 found
    ~/.local/bin/the-janitor, ~/.config/the-janitor/client.py and
    ~/.local/state/the-janitor absent at their cited paths; no source bytes,
    database rows or credentials were read.`
  - Host launcher reports `1.19.3`, with the `npx --prefer-online` caveat and
    an explicit "not the handler's version" bound.
  - `R11-01` re-measures DB shape floors only and is `[substrate]`-deferred;
    exact size and `7/39/55` counts are not re-derived by any committed row.
  - `Re-verification requires restored authorized reads of the handler and
    client; the by-hand scratch class cannot run while the substrate is
    absent.`
  - `No current hash, line count, authentication posture, database size or
    row count, or handler behavior is claimed.`
- **Parser hazard:** `claim-ledger.sh:860-878` dies if any line starts with
  `Reverify` other than the single `^Reverify: ` declaration. The appended
  section must not start any line with that token (mid-sentence prose is fine).
- Do not add a hash, a new line count, or a "re-verified" verb; this audit did
  not read source bytes.

### 4.2 Same-change re-pin (mandatory)

Appending changes bytes; the row must move in the same change, or the round
reproduces `f4a8dd9`'s defect.

- Old triple (record it in the integration note, not in the entry):
  `dad0b983…`, 182, 10575.
- After the append, recompute:
  `sha256sum corpus/knowledge/control-plane-hardening.md`;
  `wc -l`; `wc -c`. Replace only line 15's last three fields.
- Proof of non-laundering: `git diff -U0 corpus/stamps.tsv` must show
  **exactly one** changed row and no other row touched.
- **Do not** run `bash corpus/claim-ledger.sh stamp` with only this path, and
  do not run it with all paths until the other stale rows are adjudicated:
  `stamp` replaces the whole row set (shrink refusal at
  `claim-ledger.sh:244-258`), and it recomputes every named file — a blind
  whole-set run would silently re-baseline the six stale rows below. If the
  round wants the gate's `stamp`, do it only after D2-style adjudication of
  each stale row, then require the diff to change exactly the intended set.

### 4.3 Exact recheck scope when the substrate returns

1. Re-read `~/.local/bin/the-janitor`; recompute sha256/lines/bytes; check the
   cited ranges: `server_healthy` 72–75, `ensure_started` 92–118,
   `cmd_request` 121–135, `cmd_stop` 173–184, `_serve` 186–226, usage 28–43,
   `op run --env-file` at 7 and 228–249.
2. Re-read `~/.config/the-janitor/client.py`: `request` 22–38, `run_prompt`
   67–95, `health` 98–100, timeout at 74; confirm the shared
   `urllib.request.Request` helper still omits `Authorization`.
3. Confirm `_serve` does not export `OPENCODE_SERVER_PASSWORD` and binds
   loopback only; record the handler's own `opencode --version`.
4. Re-run the scratch auth matrix on a throwaway port: `GET /global/health`
   and `POST /session`; anonymous vs Basic vs Bearer; record status codes only,
   never bodies.
5. Metadata-only DB read: size, mode, table list, `session` columns, and row
   counts; never select row contents.
6. If any item differs, append a further erratum; never rewrite 1–182.

## 5. Pin-debt reconciliation (exact historic evidence)

Computed by hashing `git show HEAD:<path>` against each stamp row (no gate
run). At base `c2cab35` there are **six** stale rows, with the exact commit
that staled each:

| path | pinned triple | stale since | cause |
|---|---|---|---|
| `corpus/knowledge/config-layering.md` | `848b8e50…` 109 6621 | `f4a8dd9` 2026-10-15 | round-16 erratum appended, row not moved |
| `corpus/knowledge/handler-on-disk-state.md` | `811572dc…` 247 17609 | `f4a8dd9` | same |
| `corpus/knowledge/handler-trust-boundary.md` | `263c7b0e…` 285 17669 | `f4a8dd9` | same |
| `corpus/knowledge/janitor-env-contract.md` | `88dca63a…` 90 5111 | `f4a8dd9` | same |
| `corpus/lessons/round-18.md` | `614335f2…` 73 4216 | `bad9088` 2026-10-14 | round-19 audit correction, row not moved |
| `LOG.md` | `60a8fd36…` 1043 74864 | `c2cab35` 2026-10-19 | base integration commit, row not moved |
| `corpus/knowledge/control-plane-hardening.md` | `dad0b983…` 182 10575 | **none** | — |

`f4a8dd9` touched only `LOG.md`, `SCORECARD.md` and the four knowledge files;
`corpus/stamps.tsv` is absent from that commit's file list. That is the exact
migration defect: the substantive-freshness remedy changed four stamped files
and left their pins describing the pre-erratum bytes. A count of "five stale
stamps" is reconcilable as the four errata entries plus `round-18.md`, i.e.
excluding the meta `LOG.md`; six is the full measured set. I report the
measured six, not the expected five.

Committed history contains **zero dropped stamp rows**: 9 commits touch
`corpus/stamps.tsv`, and the row set is monotone 28→33→44→48→52→54→56→63
with no removal at any commit. `corpus/claim-ledger.tsv` is likewise monotone
11→17→18→23→29→32→35→39. So any "nine previously dropped stamps" accounting
must cite evidence outside this checkout's committed history (working tree,
another lane, or a miscount); it is **not** substantiated here, and this row
is not part of it. Do not manufacture nine deletions to satisfy the premise.

Downstream scope: the round-16 baseline/outcome tables that cite the four
stale entries sit under `## Current baseline …` and `## Outcome …`, not under
`## Round <N> — pre-move|post-move`, and `cells` audits only the latter
(`claim-ledger.sh:704-735`). The four stale pins therefore surface in
`verify`, not as `STALE-POINTER` in `cells`. `SCORECARD.md`'s own pin is exact
(`29f9f023…`, 691, 87010).

## 6. Provenance

- Frozen base / HEAD: `c2cab35bc92e57e39e5489bac3386db078345b3f`.
- Audit target = `HEAD` blob (worktree identical); `stamps.tsv` also identical
  to `HEAD`.
- The working tree changed during this audit from concurrent round-22 seats.
  At the first check four files were modified (`corpus/QUALITY.md`,
  `corpus/SOURCES.md`, `corpus/knowledge/onepassword-machine-credentials.md`,
  `corpus/knowledge/vault-openbao-token-lease-lifecycle.md`); at the final
  check `git status` lists thirteen modified files under `corpus/` (including
  `corpus/claim-ledger.sh` and ten knowledge entries) and the transient
  working-tree `STALE` count is 19. These are in-flight edits, not base pin
  debt; §5's table is computed from `HEAD` and is unaffected. Not touched.
- Pin-introduction commit for this entry: `2486643` (2026-09-28). Sibling
  erratum commit: `f4a8dd9` (2026-10-15, `round-16: qualify historical janitor
  source claims`). Round-19 correction commit: `bad9088` (2026-10-14).
- Host probes (2026-10-20): `ls`/`find` ENOENT for the three cited paths;
  `opencode --version` → `1.19.3` through the launcher; no source bytes, DB
  rows, credentials, ports or services were read or started.
- No corpus gate was run (`claim-ledger`, `surface-census`, `docs`,
  `drift-pins` all untouched).

## 7. Remaining unknowns

- Whether the parent accepts the append (D4) or records the debt outside the
  entry; the entry is readable as historical either way, but only the append
  removes the current-voice framing.
- The post-append triple cannot be predeclared; it must be computed at edit
  time.
- Whether `1.19.3` is a cached or freshly fetched `opencode-ai`; the launcher's
  `--prefer-online` makes this non-deterministic.
- Whether `R11-01`'s `rows_min` floors were chosen to cover retention volume;
  the file records "observed 7/39/55" in notes, not as assertions.
- The origin of the "nine dropped stamps" figure; not reproducible in
  committed history at this base.

## 8. Tool installs (operator directive)

- `mise` installed `node@26.12.0` (global `~/.config/mise/config.toml`) as an
  automatic side effect of `~/.local/bin/opencode`'s
  `mise use -g node@latest` during the `opencode --version` probe. Channel:
  mise toolchain, not pacman; no package transaction. Reason: opencode
  launcher dependency. `opencode-ai` was resolved by npx and is not recorded
  as a system install.

## Checks for the parent after integration

Run these at the integrated revision, not the transient tree: `corpus/claim-ledger.sh`
itself was modified by a concurrent seat during this audit.

- `bash corpus/claim-ledger.sh verify` — expect `STALE` for exactly the six
  rows in §5 (plus this row until re-pinned), no `MISSING`/`NOT-A-FILE`.
- `bash corpus/claim-ledger.sh docs` — expect
  `DOC_AUDIT: CLEAN (entries=24 row_linked=21 by_hand=3 …)`; the append must
  not alter those counts.
- `git diff -U0 corpus/stamps.tsv` — exactly one changed row for this path.
- `bash corpus/claim-ledger.sh --selftest` — must remain `PASS` (do not pin a
  case count here; sibling work may change it).

Report: `.ufo/waves/round-22/build/Entry07.md`
