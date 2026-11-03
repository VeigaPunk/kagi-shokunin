# ScribeKnowledge — round-32 build, C2 §11.1 draft + QM33 draft

Seat: `ScribeKnowledge` (scribe, leaf). Lane root `/home/vgpnk/Projects/shokunin/kagi-shokunin`,
BASE `32c35fe5ed44f2017d6a662c7fd13f7e63a7ce9b`, frozen contract `plans/round-32.md` (read first).
No lane-tracked file was edited. No vault contact. No op subcommand except `op --version`.

## Artifacts written (absolute paths)

1. `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-32/build/knowledge/op-ref-11.1.md`
   — 21 lines (target < 40), the text of `### 11.1 Re-measure on op 2.41.1 (round 32)` for insertion
   at the END of the §11 range of `corpus/knowledge/op-ref-consumption.md`, i.e. immediately before
   `## Erratum (round 22 — comparator history)` (currently line 377; §11 range is lines 310–376).
2. `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-32/build/quality/QM33.md`
   — 16 lines, the text of `## Criterion from the round-32 M32-1 mistake (landed round 32)` with
   row `QM33`, for appending to `corpus/QUALITY.md` (currently ends at line 160).
3. this report.

Scratch `/fast/scratch/hyaku/kagi-r32/ScribeKnowledge/` created, used for a splice simulation only,
and removed (`ls` → exit 2, absent). One stray `/home/vgpnk/Projects/shokunin/sim.md` created by a
`cp` before I re-set cwd was deleted immediately (verified absent); no other out-of-scope path written.

## Behaviour delivered

### op-ref-11.1.md (draft) states, in this order
- Installed version `2.41.1` with its provenance: `op --version` first field, exit 0, 2026-11-03,
  receipt `.ufo/waves/round-32/build/probe/op-version.txt` (content `2.41.1` / `version_exit=0`).
- That the existing §11 text stays as written for its own scope (`2.40.0`–`2.41.0`) — no 2.41.0 prose
  changed by the draft.
- Command + expected last line: `bash corpus/op-ref-probe.sh --dotenv-bytes` → six
  `DOTENV_BYTES_CASE id=<id> status=PASS` then `OP_DOTENV_BYTES: CLEAN (checks=6 failed=0)`, exit 0;
  measured 2026-11-03 exit 0, six PASS (receipt `probe/base-probe.txt`).
- The counter command verbatim from `plans/round-32.md` C2 (three lines: `V=…`, the `awk`/`grep -c`
  over the §11 range, the probe + `echo "exit=$?"`), with BASE `0` and after-splice `1`, predicate
  `BYTE_PIN: CURRENT`.
- The six classes unchanged, with ids and asserted child bytes: `escaped-lf` 616c7068610a62657461,
  `trailing-lf` 616c7068610a0a, `newline-only` 0a, `single-literal` 616c7068615c6e62657461,
  `double-multiline` and `single-multiline` 616c7068610a62657461. No byte change claimed on 2.41.1.
- Cite: `corpus/SOURCES.md` **S072**, `https://app-updates.agilebits.com/product_history/CLI2`,
  accessed 2026-11-03, located quote `2.41.1 (build #2410101 ) – released 2026-10-21`, capture
  `.ufo/waves/round-32/build/src-open/S072-body.html`. Taken from `build/ScoutOp.md` §2–§3
  (HTTP 200, effective URL identical, 516927 bytes, fsha `d1fc423b…8209`) — the scout's values, not
  mine, and cited as release identity only, not as byte evidence.
- Bound: representation fidelity for these six classes on that exact version only; no ref-resolved
  value, no item read, no vault/account fact, no handler behaviour (handler absent); the §11 `$(...)`
  trailing-LF loss is a shell fact and not re-measured; later releases unmeasured until `on-release`.
- Falsifier: any `DOTENV_BYTES_CASE … status=FAIL` or `DRIFT`/`SETUP` verdict from the probe on a
  newer op release; `recheck: on-release of op`.

### QM33.md (draft) states
- Title `## Criterion from the round-32 M32-1 mistake (landed round 32)`, house table shape
  `| id | criterion | weak signal | lesson |`.
- Criterion text verbatim from the seat spec: *A frontier-to-core move removes the frontier entry in
  the same round; corpus/self-description-sweep.sh SD1 and SD2 must read 0 at the landing revision.*
- Weak signal: round-31 `PROVINCE.md:90` (SD1 = 2) and `corpus/README.md:117,118` (SD2 = 2).
- Lesson cell: `corpus/lessons/round-32.md` §Mistakes M32-1.
- A short paragraph binding QM33 to plan R1/R6 and to the frozen SD1–SD6 set.
- Red witness as observed at BASE by direct file read: `PROVINCE.md:90` names
  `OIDC workload-federation trust policy` and `secret-scanning detection vs verification` under
  `Frontier` while `PROVINCE.md:88,89` hold both under `Core`; `corpus/README.md:117,118` read
  `moved to core` inside `## Frontier`. Receipt path named:
  `.ufo/waves/round-32/build/sweep/base-run.txt`.

## Commands run (all read-only; exit code after each)

| command (cwd = lane root unless stated) | result | exit |
|---|---|---|
| `op --version` | `2.41.1` | 0 |
| `grep -c "QM33" corpus/QUALITY.md` | `0` (free) | 1 |
| `grep -rIl "QM33" --include=*.md/tsv/sh/json . \| grep -v ./.ufo/ \| wc -l` | `0` files | 0 |
| `grep -oE "QM[0-9]+" corpus/QUALITY.md \| sed s/QM// \| sort -n \| uniq \| tail -1` | `32` (so 33 is next) | 0 |
| `grep -c '^\| S072 ' corpus/SOURCES.md` | `0` (row not landed yet) | 1 |
| `git status --porcelain corpus PROVINCE.md README.md` | empty (I changed nothing) | 0 |
| `wc -l .ufo/waves/round-32/build/knowledge/op-ref-11.1.md` | 21 | 0 |
| `wc -l .ufo/waves/round-32/build/quality/QM33.md` | 16 | 0 |
| scratch splice sim: copy `corpus/knowledge/op-ref-consumption.md` → scratch, insert draft before `## Erratum (round 22 …)`, then the plan's counter with `V=2.41.1` | lane file `0`; spliced copy `1` | grep-c 1 / 0 |
| sim: `awk '/^## 11\./…' spliced \| grep -c '^### 11\.1 Re-measure on op 2\.41\.1 (round 32)'` | `1`, at line 377, before `## Erratum` at 399 | 0 |
| sim: §11 range line count base vs spliced | 66 → 88 (+21 draft + 1 blank) | 0 |
| content greps on the draft: six ids, expected last line, `S072.*CLI2.*2026-11-03` | 6/6, 1, 1 | 0 |

No tool was installed or upgraded; no pacman transaction attempted.

## Gates / measurements I relied on (produced by other seats, read only)

- `build/probe/op-version.txt`: `2.41.1`, `version_exit=0`.
- `build/probe/base-counter.txt`: `0`, `V=2.41.1`, `grep_exit=1`, range `310-376`, versions in range
  `op \`2.40.0\`` ×1 and `op \`2.41.0\`` ×1.
- `build/probe/base-probe.txt`: six `DOTENV_BYTES_CASE … status=PASS`, last line
  `OP_DOTENV_BYTES: CLEAN (checks=6 failed=0)`, `exit=0` → the probe half of C2 is CLEAN on the
  installed 2.41.1; the moving part of C2 is the version token in §11 (BASE 0).
- `build/probe/selftest.txt`: `OP_REF_SELFTEST: PASS (36 cases)`, `exit=0`.
- `build/probe/op-subcommands.txt`: only `run` is invoked; no account/vault/item/signin/inject/read
  site in the probe.
- `build/sweep/selftest.txt`: `CASE clean ok` + `CASE SD1..SD6 ok`, `SELFTEST: PASS (7 cases)`,
  `exit=0` → the plan's planted-mismatch fix-pinning is satisfied by the counter.
- `build/ScoutOp.md`: S072 URL/status/bytes/sha/quote/date (values quoted above); the 2.41.1 entry
  itself mentions no `op run`, `--env-file` or dotenv text (`grep` exit 1 on article lines 812–1061);
  2.41.0 has `op run --environment` GA.

## Findings (reported, not fixed — predicates and counters untouched)

1. **`build/sweep/base-run.txt` is 0 bytes** (written 19:42, still empty at 19:46). ExecSweep's
   seat spec names that file as the BASE receipt with per-check counts. My QM33 red witness therefore
   rests on the BASE file lines I read myself (`PROVINCE.md:88,89,90`; `corpus/README.md:117,118`) and
   only *names* the receipt path; the L1 must have the sweep's BASE counts written there before C1 is
   scored, otherwise the "do-nothing control" is asserted, not receipted.
2. **Residual self-description after the frontier fix (same M32-1 class).** `fix/fix-frontier-readme.patch`
   drops both themes from `PROVINCE.md:90`, but line 88 still says "The frontier bullet below keeps its
   history." Once the patch lands, that sentence is false for secret scanning. SD1/SD2 do not count it
   (they read 0 after the patch); it is a leftover a reader sees. The patch does not touch it.
3. **S072 is not yet in `corpus/SOURCES.md`** (`grep -c '^\| S072 '` → 0). My §11.1 draft cites S072
   ahead of the row; the row (`build/S072-row.md`) and its capture row
   (`build/S072-capture-row.tsv`) must land in the same round, else the subsection cites a row that
   does not exist and the census stays at 71.
4. **C2's sourced row says nothing about env-file bytes** — the 2.41.1 entry is a Go/base-image
   security release with no `op run`/`--env-file`/dotenv text; the nearest release text is 2.41.0's
   `op run --environment` GA. The byte claim rests on the probe, and S072 carries release identity
   only, which is how the draft words it. Not a defect, but a reviewer should not read S072 as
   mechanism support.
5. **Version string vs the frozen plan's expected text.** Plan C2 says `op --version` → `2.41.1`;
   observed `2.41.1` (`op --version` prints exactly that, no trailing fields). The draft's counter
   copy is unmodified from the plan, so `V=$(op --version | awk '{print $1}')` yields the same token.
6. `§11` currently has no `###` subsection; the splice adds the only one, and the plan's awk range
   keeps it inside §11 (`^## ` stops only at the Erratum). Verified on the spliced copy.

## Out of scope / not run (not passed by me)

- No edit to `corpus/knowledge/op-ref-consumption.md`, `corpus/QUALITY.md`, `PROVINCE.md`,
  `corpus/README.md`, `corpus/SOURCES.md`, `corpus/lessons/*` or any sibling repo — drafts only.
- No sweep run against the lane or a BASE clone (ExecSweep's verify step); no probe run (ExecProbe's);
  no ledger, census, lint, build or suite run. Nothing is claimed as measured beyond the table above.
- `corpus/lessons/round-32.md` does not exist yet (ScribeLesson's); QM33 cites the path the lesson will
  occupy, which is the house convention (every criterion cites the lesson that produced it).
- The `$(...)` trailing-LF shell fact in §11 was not re-run; the draft says so.
- The-janitor handler absence: untouched and expected; no handler claim is made anywhere in the drafts.
