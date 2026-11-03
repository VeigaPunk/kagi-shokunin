# ReviewOp — attack on C2 (BYTE_PIN: CURRENT), round-32 BUILD

Seat: ReviewOp (reviewer, leaf). Frozen contract: `plans/round-32.md` (commit 507dd9f), BASE `32c35fe5ed44f2017d6a662c7fd13f7e63a7ce9b`. Lane HEAD at review time: `76241c0`. Diff of every counter input (`corpus/knowledge/op-ref-consumption.md`, `corpus/op-ref-probe.sh`, `corpus/SOURCES.md`, `corpus/PROVINCE.md`, `corpus/README.md`) between BASE and HEAD: empty. No lane file was edited by this seat.

## Verdicts

| # | Item | Verdict |
|---|---|---|
| 1 | Independent §11 counter in BASE scratch + probe | **holds** (counter `0` as frozen; probe CLEAN). Cross-checked against `probe/base-counter.txt`: agrees. |
| 2 | S072 capture re-located by me; access date; quote ≤25 words | **holds for identity** (version + date located); **defect** for the quote as drafted (29 words); **not-delivered**: `ScoutOp.md` absent (no scout quote to compare), S072 row absent from `corpus/SOURCES.md`. |
| 3 | Overreach in §11.1 draft (`knowledge/op-ref-11.1.md`) | **defect (minor overreach)**: version binding of the probe receipt and access/URL claim not supported by the capture. Byte claims themselves stay within the six classes. |
| 4 | Vault contact (`probe/op-subcommands.txt` + my own grep) | **holds**: no account/item/read/inject/signin/run-with-ref path. Only `op run` is invoked; `op://` tokens appear only in fixtures the guard refuses before exec. My own runs: no vault contact. |
| 5 | Red witnesses | **defect**: both witnesses reach DRIFT (non-CLEAN, named reason `exit-or-bytes`), but the version-stub witness does NOT witness the version pin (the probe never reads the version). Silent-stub witness **holds**. |

**C2 overall, attack result:** the measured facts hold (probe CLEAN on `op 2.41.1`, independent run), so the kill rule (non-CLEAN probe on 2.41.1) is **not triggered**. The claim as worded — "byte-evidence pinned to the installed op version" — is **not enforced by the probe**: the version binding is carried only by a string match in §11 and by sequencing of two separate receipts. See findings F1–F3.

## Item 1 — independent counter (BASE scratch)

Method: `git archive 32c35fe5ed44f2017d6a662c7fd13f7e63a7ce9b | tar -x -C /fast/scratch/hyaku/kagi-r32/ReviewOp/base` (read-only on lane), then the plan's exact commands from that tree.

- `V=$(op --version | awk '{print $1}')` → `V=2.41.1` (exit 0; `op` at `/usr/bin/op`).
- `awk '/^## 11\./{f=1;next} /^## /{f=0} f' corpus/knowledge/op-ref-consumption.md | grep -c "op \`$V\`"` → **`0`** (grep exit 1 on zero matches, as the plan's own text implies). §11 range runs from `## 11. Byte fidelity…` (BASE line 310) to `## Erratum (round 22` (BASE line 377); the range names only `op 2.40.0` and `op 2.41.0`.
- `bash corpus/op-ref-probe.sh --dotenv-bytes; echo "exit=$?"` → six `DOTENV_BYTES_CASE … status=PASS` lines, `OP_DOTENV_BYTES: CLEAN (checks=6 failed=0)`, **`exit=0`**. Identical to `probe/base-probe.txt`.
- `probe/base-counter.txt` (delivered by another seat) reports `0`, `V=2.41.1`, the same section bounds, and the same two versions. **Agrees** with my independent run.

Counter value (independent): **0** at BASE (expected by the plan). Target ≥1 needs §11.1 (see F2 for what that 1 actually is).

## Item 2 — S072 re-check (saved body, located by my grep)

Saved body: `build/src-open/S072-body.html` (516,927 bytes; the 1Password CLI Release Notes page). `ScoutOp.md` is **not present** in `build/` (listing at review time; the scout's summary therefore cannot be compared — **not-delivered**).

Located by my grep of the saved body:

- L815–818 (h3 of `article id="v2410101"`): `2.41.1` / `(build #2410101 )` / `– released 2026-10-21`. Version and release date **located and confirmed**.
- L1030 — the candidate sentence, verbatim: "This release updates Go and the CLI base image to pull in the latest security fixes, and `op read` help text includes an example of reading a file attachment." **29 words — exceeds the ≤25 limit.** The ≤25 span inside it: "This release updates Go and the CLI base image to pull in the latest security fixes" (**16 words**, L1030, single match).
- Latest stable on the page is 2.41.1 (stable list: 2.41.1 → 2.41.0 → 2.40.0; betas 2.43.0-beta.02 and 2.44.0-beta.01 are listed `class='beta'`). Supports "installed = latest stable" as of capture.
- The 2.41.1 entry span (L812–1068) contains **0** occurrences of `env` or `op run` (case-insensitive): the release notes say nothing about the env-file/byte path for 2.41.1. The byte claim therefore rests on the probe, not on S072.
- Access date: the body carries **no access timestamp and no URL**. The capture contains a `2.44.0-beta.01 … released 2026-11-03` entry (L219), which is consistent with a fetch on or after 2026-11-03. This is inference, not a recorded access date. The URL in §11.1 (`https://app-updates.agilebits.com/product_history/CLI2`) cannot be confirmed from the saved body.

S072 row: `grep -cE '^\|[[:space:]]*S072[[:space:]]*\|' corpus/SOURCES.md` → **0** in the lane. §11.1 cites S072 before the row exists — a dangling citation (**not-delivered** row).

## Item 3 — overreach in §11.1 (`build/knowledge/op-ref-11.1.md`, 19 lines)

Byte-scope sentences that stay inside the six classes (no overreach):
- L15: "This round asserts no byte change on 2.41.1: six PASS is the whole claim."
- L19: "Does not establish. Representation fidelity for these six classes on op `2.41.1` only: no ref-resolved value, no item read, no vault or account fact, and no handler behaviour — `the-janitor` is absent…"

Overreach sentences:

- **O1 (L3, L5)** — "Installed CLI at measurement: `op --version` → `2.41.1` … " and "Measured 2026-11-03 on 2.41.1: exit 0, six PASS, that last line (receipt `…/probe/base-probe.txt`)." The `base-probe.txt` receipt carries no version: the probe never calls `op --version` (its only `VERSION` token is an internal label `VERSION=v4`, probe line 64). The "on 2.41.1" binding is therefore an inference from PATH state and file timing, not something the receipt records. The version fact itself is supported by `probe/op-version.txt` (`2.41.1`, `version_exit=0`). **Overreach: the receipt is presented as measuring 2.41.1; it does not record that.**
- **O2 (L3)** — "exit 0, 2026-11-03" for the `op --version` call: the only dated evidence is the file mtime (19:35), not a stamped receipt. Minor.
- **O3 (L17)** — "accessed 2026-11-03", and the URL `https://app-updates.agilebits.com/product_history/CLI2`: neither appears in the saved body (see Item 2). The quote `2.41.1 (build #2410101 ) – released 2026-10-21` is a reformatted rendering of L815–818 (the source splits `2.41.1`, `(build…)` and `– released…` across lines); usable, but not a verbatim single-line quote.

Predicate observation (not text overreach, but it decides the counter): L13 says the subsection "makes it print `1`". I simulated it in a scratch copy (draft inserted before `## Erratum (round 22`; counter re-run): it prints `1`, and the single match is **L19's scope disclaimer** "on op `2.41.1` only", not a measurement sentence. The frozen predicate counts any occurrence of ``op `V` `` in §11 and cannot distinguish a disclaimer from a measurement. See F2.

Note for the lane: §11.1 must be inserted **inside** §11 (before the next `## ` heading) for the counter's range to see it. Appended at end-of-file, the counter stays 0 — I verified this too.

## Item 4 — vault contact

- `probe/op-subcommands.txt` (delivered): the exact op_exec/op_run call-site inventory; "distinct op subcommands actually invoked": `run` ×10; account/vault/item/signin/inject/read: **none**. I reproduce this from source: the probe's op invocations are `run` only (probe lines 270, 282, 284, 286, 295, 324, 331, 333 (`run --no-masking`), 337, 340, 342, 344, 346, 542). `grep` for `account|item|read|inject|signin|whoami|vault|document` in the probe finds only shell `read` builtins and comments/fixture strings.
- `op://` tokens in the probe: only in fixture generators (`Kagi12NoVault/I/F` placeholders, lines 198–203, 674, 703–705). The guard `guard_op_file` (probe lines 228–245) refuses any op-side env file containing `op://` **before exec** (grep-based, returns 2 with POLICY); `op_exec` (lines 248–265) applies it to every `--env-file=`. The probe's default (non-byte) mode does execute `op run` on fixture dirs; I did **not** run that mode.
- My own op contact in this seat: `op --version` (×2, exit 0) and one `--dotenv-bytes` run in the BASE scratch copy, which the probe executes under `env -i` with `HOME`/`XDG_*` set to a temp dir and a plain env file containing no `op://` token. No account, item, read or inject call; no config under `~/.config/the-janitor` or `op.env` read. No secret value printed (the byte hex values are the probe's fixed contract strings).

Vault-contact result: **none** from this seat; the probe's byte path contains no account/item/read/inject path and no ref-resolution.

## Item 5 — red witnesses (`build/probe/red-witness-*.txt`)

- `red-witness-version-stub.txt`: stub prints `2.41.9` for `--version` and exits 1 otherwise. Output: six `DOTENV_BYTES_CASE … status=FAIL reason=exit-or-bytes`, `OP_DOTENV_BYTES: DRIFT (checks=6 failed=6)`, exit 1. **Non-CLEAN, but the reason is not the version.** The probe never calls `--version`; the stub's `run` simply exits 1. **F1: this witness does not witness the version pin.** It shows that a failing `op run` is caught, which is already covered.
- `red-witness-silent-stub.txt`: stub exits 0 and prints nothing. Output: six FAIL `reason=exit-or-bytes`, `DRIFT (checks=6 failed=6)`, exit 1. Non-CLEAN with a named reason. **Holds** (the reason label is generic, `exit-or-bytes`, but it is the code's own label for the empty-bytes case).

## Findings (concrete; no lane file edited)

- **F1 (defect, witness):** the version-stub red witness does not exercise the version pin. A probe run against a *different* op version with identical `run` behaviour is CLEAN. Nothing in the probe ties its CLEAN to the version it ran on. Fix candidates for the L1 (not applied by me): have the probe record `op --version` in the same invocation and fail when it differs from the version named in §11.1, or stop claiming a version pin for the probe receipt.
- **F2 (defect, predicate — frozen, reported not edited):** `grep -c "op \`$V\`"` in §11 is satisfied by any mention of the version, including the §11.1 scope disclaimer (L19). The first counter half therefore measures naming, not measurement. The plan's "Do not change any predicate" rule means this is reported, not fixed.
- **F3 (defect, §11.1 text):** O1 (probe receipt presented as measured on 2.41.1 without a version field) and O3 (access date and URL not in the capture); plus the S072 row is not yet in `corpus/SOURCES.md` while §11.1 cites it.
- **F4 (quote):** the drafted S072 quote is 29 words; the ≤25 requirement needs the 16-word span at L1030 or a shorter one. The row's Gate block must record the URL and access date from the fetch record, which I could not locate.

## Residual risk and verification gaps

- No `ScoutOp.md`: the scout's own quote and access record were not compared (not-delivered).
- The URL and access date of S072 are not verifiable from the saved body alone.
- The probe's default (non-byte) mode, which runs `op run` on fixture dirs, was not run by me.
- `probe/selftest.txt` (delivered by another seat: `OP_REF_SELFTEST: PASS (36 cases)`, exit 0) is not my item; not re-run.
- `the-janitor` absent on this host: no handler behaviour is claimed or tested (expected).

## Commands run (seat ReviewOp)

| command | exit |
|---|---|
| `git -C …/kagi-shokunin rev-parse HEAD`, `cat-file -t 32c35fe…`, `cat-file -t 507dd9f`, `log --oneline -5` | 0 |
| `git -C …/kagi-shokunin archive 32c35fe… \| tar -x -C …/ReviewOp/base` | 0 |
| `op --version` (×2) | 0 (`2.41.1`) |
| plan counter, BASE scratch (`awk … \| grep -c "op \`2.41.1\`"`) | grep 0 (pipeline 1, no match) |
| `bash corpus/op-ref-probe.sh --dotenv-bytes` (BASE scratch, `TMPDIR` set) | 0 (CLEAN checks=6 failed=0) |
| `git -C …/kagi-shokunin diff --stat 32c35fe… HEAD -- <counter inputs>` | 0 (empty) |
| `grep -n` / `awk` / `python3` on `src-open/S072-body.html` (read-only extraction to scratch) | 0 |
| `grep -cE '^\|…S072…\|' corpus/SOURCES.md` | 0 (count 0) |
| counter re-run on a scratch copy with the draft inserted into §11 | 0 (count 1, from L19) |
| `git -C …/kagi-shokunin status --short` | 0 |

No tools were installed or upgraded by this seat. No pacman, no vault commands, no lane writes.

## Receipts (absolute paths)

- `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-32/build/review/ReviewOp.md` (this report)
- `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-32/build/review/ReviewOp-receipts.txt` (counter + probe run)
- `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-32/build/review/ReviewOp-receipts-2.txt` (probe version grep, S072 locations, word counts, sim count)
