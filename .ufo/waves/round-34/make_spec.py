import json, pathlib

LANE = "/home/vgpnk/Projects/shokunin/kagi-shokunin"
WAVE = ".ufo/waves/round-34/build"
SCR = "/fast/scratch/hyaku/kagi-r34"
STAGED = "/home/vgpnk/Projects/shokuknow/merge/kagi"

context = f"""# Goal
kagi round-34 BUILD wave (one v1 wave, 13 seats). Lane repo {LANE} (secrets & vault ops shokunin: 1Password `op`, the-janitor handler — ABSENT on this host, SOPS/age, Vault/OpenBao, NIST key-management; the lane's axes are freshness + calibration).
Frozen BASE `f9dc06fd8f6b43c175193c76dc6350468f551634`. Frozen claims contract {LANE}/plans/round-34.md — READ IT FIRST; it fixes every predicate, counter, kill rule and target and it is already committed (`git -C {LANE} log -- plans/round-34.md`). Do not change a predicate or counter; if you think one is wrong, say so in your report and still measure it as written.
Claims: **C1 calibration** — `corpus/self-description-sweep.sh` gains three checks the round-33 defects escaped (SD7 gate-registry coverage, SD8 lesson-row range claims, SD9 admitted-entry provenance); BASE SD789=3+1+1=5, target 0. **C2 operability** — the pre-freeze gate's two unbacked round-33 claims become executed ones: a `relative-work` selftest case (11→12 cases) and an M7 (`--base`-ignoring) mutant receipt that names `base-isolation` as the failing case. **C3 coverage** — Alibaba Cloud RAM AccessKey custody enters as one knowledge entry plus five registry rows (lane ids S083–S087), every cited source re-opened this round.
The seven routed defects this round closes are `R33-1..R33-7` in {LANE}/corpus/lessons/round-33-verifier-spotcheck.md §6.

# Contract (binding on every seat)
- Path rule: every path you read or write is ABSOLUTE under {LANE} or your own scratch dir. Every `Report:` trailer the validator appends is relative to {LANE} — write it at {LANE}/<that path>.
- **Write scope: you are read-only on lane-tracked files.** You write ONLY under {LANE}/{WAVE}/ (your named report file plus the deliverables your item names) and your scratch dir {SCR}/<your-seat-name>/ (create it, export `TMPDIR={SCR}/<your-seat-name>/tmp` explicitly, `trap 'rm -rf -- "{SCR}/<your-seat-name>"' EXIT` in shell or `finally: shutil.rmtree` in Python; copy receipts into {LANE}/{WAVE}/ before exit). Never write under /tmp (reaped; >50 MB never). The L1 installs every deliverable into the lane tree — you never do.
- Write only the exact paths your item names: another seat owns each of the others (parallel writers are why). Never touch {LANE}/considerthese/, {STAGED} (read-only), any sibling `*-shokunin` repo, the fleet root's `.ufo/`, `.scratch/`, `templates/`, `scripts/`, `.ufo/state/`.
- Git: read-only only (`git -C {LANE} show/log/diff/ls-files/rev-parse`, `git archive`). NEVER git add/commit/stash/checkout/switch/reset/pull/push and NEVER any mutating jj command. Fixture repos only as `D=$(mktemp -d) && git -C "$D" init -q`, every later call `-C "$D"`, and verify `git -C "$D" rev-parse --show-toplevel` equals `$D` before the first commit.
- Vault contact: NONE. `op --version` is allowed; never `op signin/account/item/read/inject/run` against real config, never read `~/.config/the-janitor` or any `op.env`, never print a secret, token, session id or 1Password reference.
- Network: only the five Aliyun documentation URLs named in your item (plain `curl -fsSL --compressed`, no credentials, no POST) — and only for the three assimilation seats. Every other seat: no network.
- Leaf: no sub-swarm. Only `ExecSD` may spawn ONE read-only `labrat` probe (`task` with `agent: "labrat"`), for one falsifiable hypothesis about the new checks, and must record its output.
- Verify once, not mid-flight: run only the counting/measurement commands your item names. No lint/format/build/full-suite runs — the L1 runs the full gates after installing.
- Tooling authorization (operator 2026-10-19): you may install or upgrade tools that help this task — read `/home/vgpnk/.omp/agent/RULES.md` first (official channels only; record tool/version/channel/reason in your report). **pacman guard (orchestrator ruling 2026-10-20): ALL pacman transactions are PAUSED host-wide** — install via `uv tool` / `npx` / an official binary into `~/.local/bin`, or report the blocker; never `-Sy`, `-Syu`, `-U`, `-R`, downgrade or restart a host service.

# Measured state at BASE (do not re-derive; these are the L1's executed receipts)
- `plans/round-34.controls.tsv` ran CLEAN at BASE: sd7=3, sd8=1, sd9=1, sd789=5, prefreeze_cases=11, sweep_selftest_cases=7, registry_rows=82, aliyun_entry=0, m7_receipt=0, doc_entries=34. Receipt: {LANE}/.ufo/waves/round-34/controls/prefreeze-base.txt.
- The three SD7 hits at BASE are `corpus/prefreeze-control.sh`, `corpus/self-description-sweep.sh`, `corpus/feed-token-agree.py` (each mentions `--selftest`, none is named in `SKILL.md`).
- The one SD8 hit at BASE is `corpus/README.md:95` (`M33-1..M33-3` while `corpus/lessons/round-33.md` carries M33-4).
- The one SD9 hit at BASE is `corpus/knowledge/prefreeze-controls.md` (`Reverify: R33-01`, none of `source:`/`verified-at:`/`recheck:`).
- `bash corpus/sources-census.sh` at BASE: `SOURCES_CENSUS: CLEAN (rows=82 A=79 B=1 C=2 queued=1 mined=78 rejected=3 entries_sourced=12 legacy=22 captures=82 inrow=16 inrow_only=0 inrow_nonreproducing=12)` exit 0.
- SD6 is a **named exclusion**: three UNRESOLVED lines the citations gate prints against integrator-owned spot-check files. The sweep still exits 1 while they persist; C1's target is SD7–SD9 only. Do not try to fix them.

# Assimilation facts (C3)
- Staged package `{STAGED}/` (READ-ONLY): `MERGE-REPORT.md`, `SOURCES.append.md`, `knowledge/corpus/knowledge/aliyun-accesskey-credential-custody-r38.md`.
- The adopted entry is `aliyun-accesskey-credential-custody-r38.md`: staged ids S140, S141, S142, S143, S145 (campaign ids). Lane ids continue at **S083** and are re-pointed BY DOCUMENT (the URL is the evidence, the id follows it): S140→S083, S141→S084, S142→S085, S143→S086, S145→S087.
- Staged rows are campaign schema, not fleet schema: on append, `recheck` becomes a valid ISO date/`NNd`/symbolic cadence, no cell may contain a literal or escaped `|`, `status` is `mined`, `used-by` lists exactly the admitted entry.
"""

items = []
def item(name, role, prompt):
    items.append({"name": name, "role": role, "prompt": prompt})

# ---------------------------------------------------------------- executors ---
item("ExecSD", "executor", f"""# Target
Implement round-34 C1: extend `corpus/self-description-sweep.sh` with three checks (SD7, SD8, SD9) and one planted-mismatch selftest case each, exactly as frozen in `{LANE}/plans/round-34.md` §C1. Work from the BASE bytes (`git -C {LANE} show f9dc06fd8f6b43c175193c76dc6350468f551634:corpus/self-description-sweep.sh`) in scratch; deliver the final bytes to `{LANE}/{WAVE}/self-description-sweep.sh`. Do NOT edit the lane tree.
# Change
`{LANE}/{WAVE}/self-description-sweep.sh` (deliverable; the L1 installs it), `{LANE}/{WAVE}/ExecSD.md`, and receipts `{LANE}/{WAVE}/receipts/selftest-new.txt`, `{LANE}/{WAVE}/receipts/base-new.txt`, `{LANE}/{WAVE}/receipts/tip-new.txt`.
# Work
Keep SD1–SD6 byte-identical in behaviour and keep the `--root`/`--selftest` interface. Add:
1. **SD7** — for every top-level `corpus/*.sh` and `corpus/*.py` under the root whose bytes mention `--selftest` (whole file, `grep -q -- '--selftest'`), the basename must appear at least once in `SKILL.md` (`grep -qF`). One hit per unnamed script: `MISMATCH SD7 <relpath> mentions --selftest but SKILL.md never names <basename>`.
2. **SD8** — scan `SKILL.md`, `PROVINCE.md`, `SCORECARD.md`, `corpus/README.md` line by line for range tokens `M<r>-<n>..M<r>-<m>` (accept both the `M33-1..M33-3` and the abbreviated `M33-1..3` form; a range whose ends name different rounds is ignored). For each token: `corpus/lessons/round-<r>.md` must exist, must carry a row matching `^| M<r>-<m> `, and must carry no row `^| M<r>-<k> ` with `k > m`. One hit per violation: `MISMATCH SD8 <file>:<lineno> range '<token>' …` naming which of the three conditions failed.
3. **SD9** — for every `corpus/knowledge/*.md` whose first `^Reverify: ` line names an `R<r>-<n>` with `r >= 30`, the file must carry `^source:`, `^verified-at:` and `^recheck:`; one hit per violating entry naming the missing keys.
4. Extend the verdict line to `SELF_DESCRIPTION: MISMATCH n=N (SD1=a SD2=b SD3=c SD4=d SD5=e SD6=f SD7=g SD8=h SD9=i)` and keep `SELF_DESCRIPTION: CLEAN n=0` exactly as it is when the sum is zero. Update the header contract comment so the documented predicate, per-check definition and verdict shape match the code (the round-33 defect class is a doc that lies about its bytes).
5. `--selftest` gains three planted fixtures: `corpus/fixture-gate.sh` containing `--selftest` with SKILL.md not naming it (SD7); a fixture lesson `corpus/lessons/round-30.md` with rows M30-1/M30-2 plus `corpus/README.md` carrying `M30-1..M30-1` (SD8); `corpus/knowledge/fixture-entry.md` with `Reverify: R30-01` and no trio (SD9). The clean fixture tree must still exit 0 with `SELF_DESCRIPTION: CLEAN n=0`. Update the selftest's expected-verdict regex to the new shape. Final line `SELFTEST: PASS (<k> cases)` — expect 10.
# Acceptance
`bash <deliverable> --selftest` prints `SELFTEST: PASS (10 cases)` exit 0 (receipt). `bash <deliverable> --root <BASE extraction>` prints `SELF_DESCRIPTION: MISMATCH … SD7=3 SD8=1 SD9=1` and `bash <deliverable> --root {LANE}` (the current, unfixed tree) prints the same 3/1/1 — a receipt for each. Every new check must be shown able to fail: mutate your own copy (delete the SD7 loop, widen SD8 to any id, drop the trio test) and show `--selftest` FAILs naming the case. Yield the delivered path, the case count, the three readings and every mutation you ran.""")

item("ExecGate", "executor", f"""# Target
Round-34 C2, part 1: add a `relative-work` selftest case to `corpus/prefreeze-control.sh` so the round-33 F1 defect (a relative `--work` root turning every row into a false `SETUP noresult`) is witnessed by the shipped gate. Work from the BASE bytes (`git -C {LANE} show f9dc06fd8f6b43c175193c76dc6350468f551634:corpus/prefreeze-control.sh`) in scratch; deliver to `{LANE}/{WAVE}/prefreeze-control.sh`. Do NOT edit the lane tree.
# Change
`{LANE}/{WAVE}/prefreeze-control.sh` (deliverable; the L1 installs it), `{LANE}/{WAVE}/ExecGate.md`, receipts `{LANE}/{WAVE}/receipts/gate-selftest.txt`, `{LANE}/{WAVE}/receipts/gate-relative-work.txt`, `{LANE}/{WAVE}/receipts/gate-unfixed-relative-work.txt`.
# Work
1. Add ONE case after `base-isolation`, named `relative-work`: create `$tmp/rel`, write a controls file with one row (`wc -l < corpus/a.txt` expect 3 at the fixture's first commit), then run the gate from that directory with a RELATIVE `--work ./w` (`( cd "$tmp/rel" && bash "$SELF" run --base "$rev" --controls "$ctl" --work ./w )`). It must print `PREFREEZE: CLEAN (controls=1 mismatch=0)` exit 0 and `CASE relative-work ok`. Use the existing `try`/`ck` helpers or extend them; keep every existing case unchanged.
2. Show the case can fail: build an unfixed copy (delete the `WORK_ROOT=$(cd -- "$WORK_ROOT" && pwd -P)` line, or replace it with `WORK_ROOT=$WORK_ROOT`) and run `--selftest` on it — it must print `CASE relative-work FAIL …`. Save that output as the `gate-unfixed-relative-work.txt` receipt and name the exact line you removed.
3. Run `bash <deliverable> --selftest` — expect `PREFREEZE_SELFTEST: PASS (12 cases)` exit 0 — and `bash <deliverable> run --base f9dc06fd8f6b43c175193c76dc6350468f551634 --controls {LANE}/plans/round-34.controls.tsv --work /fast/scratch/hyaku/kagi-r34/ExecGate/w2` — expect `PREFREEZE: CLEAN (controls=10 mismatch=0)` exit 0.
# Acceptance
The three receipts exist with the exact verdict lines above; `ExecGate.md` names the delivered file's `sha256sum`, the case count, the removed line, and both runs. Yield the sha256, the case count and every failure you saw.""")

item("ExecMut", "executor", f"""# Target
Round-34 C2, part 2: rebuild the round-33 **M7** mutant — a `corpus/prefreeze-control.sh` that ignores `--base` and measures the live worktree — and show it FAILS the shipped selftest at the `base-isolation` case. Round 33 asserted this and committed no receipt (routed defect R33-2).
# Change
`{LANE}/{WAVE}/mut/m7-run.sh` (a reusable harness: takes a script path as $1, builds the mutant in scratch, runs its `--selftest`, prints the receipt), `{LANE}/{WAVE}/mut/m7-shipped-11.txt`, `{LANE}/{WAVE}/mut/M7.md`. Nothing else.
# Work
1. `A=/fast/scratch/hyaku/kagi-r34/ExecMut; mkdir -p "$A"; git -C {LANE} show f9dc06fd8f6b43c175193c76dc6350468f551634:corpus/prefreeze-control.sh > "$A/orig.sh"`.
2. Build the mutant exactly as the round-33 MutGate describes: the extraction result is discarded and `BASE_DIR` points at the live lane worktree (`BASE_DIR=$REPO`), so every declared command measures the current tree instead of the named revision. Change nothing else; record the diff.
3. `bash "$A/mutant.sh" --selftest > {LANE}/{WAVE}/mut/m7-shipped-11.txt 2>&1; echo "exit=$?" >> …`. The receipt must contain a `CASE base-isolation FAIL` line and MUST NOT contain `PREFREEZE_SELFTEST: PASS`.
4. Write `m7-run.sh` so the L1 can repeat it on the 12-case bytes after installing ExecGate's deliverable: `bash m7-run.sh <script> <outfile>` — copies the script, applies the same mutation, runs `--selftest`, writes the receipt and prints `M7_RECEIPT: <out> FAIL=<0|1>` where FAIL counts `CASE base-isolation FAIL`.
5. Sanity control: the same harness on the UNMUTATED shipped copy must produce `PREFREEZE_SELFTEST: PASS (11 cases)`.
# Acceptance
`m7-shipped-11.txt` exists, contains `CASE base-isolation FAIL`, contains no `PASS (`, and its `exit=` line is 1; the unmutated control receipt shows `PASS (11 cases)`; `M7.md` names the mutation diff, the two receipts and the harness contract. Yield the exact FAIL line you captured.""")

# ------------------------------------------------------------------ scouts ---
item("ScoutSources", "scout", f"""# Target
Re-open the five Alibaba Cloud documentation sources the adopted entry cites and produce the fetch evidence the registry capture rows need. Read-only on the lane; network is allowed ONLY for these five URLs.
# Change
`{LANE}/{WAVE}/accesskey-captures.tsv`, `{LANE}/{WAVE}/ScoutSources.md`, raw bodies under `{LANE}/{WAVE}/src-open/` (bodies are small; keep them only if each is under 200 KB).
# Work
URLs (staged ids in parentheses): https://help.aliyun.com/zh/ram/user-guide/rotate-accesskey-pairs-of-ram-users (S140); https://help.aliyun.com/zh/ram/delete-idle-accesskey-pairs-of-ram-users (S141); https://help.aliyun.com/zh/kms/key-management-service/user-guide/manage-and-use-ram-secrets (S142); https://help.aliyun.com/zh/ram/support/faq-about-accesskey-pairs (S143); https://www.alibabacloud.com/help/ja/ram/user-guide/rotate-accesskey-pairs-of-ram-users (S145).
1. For each: `curl -fsSL --compressed -o <body> -w '%{{http_code}} %{{url_effective}}' --max-time 90 <url>`; record final URL, HTTP status, fetch date (UTC, 2026-11-04), bytes, `sha256sum`.
2. Locate a <=25-word quote (Chinese/Japanese counts characters-as-words approximately — keep quotes short) that carries each staged row's claim. Record the anchor (section heading or code identifier) and the located quote verbatim.
3. Check each staged row's `teaches` cell (`{STAGED}/SOURCES.append.md`, ids S140–S145) against what the page actually says today; mark `agree` or `differs` with one line of reason. A page that now contradicts the staged row is a finding, never a pass.
4. Emit `accesskey-captures.tsv`, TAB-separated, one line per staged id: staged_id, lane_id (S083..S087 by document: S140→S083, S141→S084, S142→S085, S143→S086, S145→S087), url, final_url, http_status, fetched, bytes, sha256, quote, location, verdict, note.
# Acceptance
Five data lines; every sha256 64 lowercase hex; every quote non-empty; `ScoutSources.md` names per id the URL, anchor, quote, staged claim and agree/differs. Yield any URL you could not open and why.""")

item("ScoutLane", "scout", f"""# Target
Read-only data-walk giving the L1 exact insertion points, formats and the full list of doc case-count claims. No edits.
# Change
`{LANE}/{WAVE}/ScoutLane.md` only.
# Work
1. `SKILL.md`: the gate-registry table header row and the last two data rows with line numbers, and the file's line count; the exact 8-column order (`name | kind | entry command | verdict map | selftest | pinned values | write scope | owner`).
2. `corpus/README.md`: lines 92, 95 and 97 verbatim with line numbers; the coverage-map row shape (column count) and the last row.
3. `PROVINCE.md`: the bullet that names `corpus/prefreeze-control.sh` with its line number, and the exact phrase it uses for the selftest case count.
4. Every doc claim of the form `<number> case`/`<number> cases` in `SKILL.md`, `PROVINCE.md`, `corpus/README.md`, `SCORECARD.md` that sits on a line naming a `corpus/*.sh` or `corpus/*.py` script: list file:line, the number (digits or English word), the script, and the script's real `--selftest` case count if it prints one within 120 s (run each at most once, from {LANE}, and record the printed line). This inventory is the L1's hand-fix list.
5. `corpus/claim-ledger.tsv` header + the R32-01/R33-01/R33-02 rows; `corpus/stamps.tsv` header + its row count; how `bash corpus/claim-ledger.sh stamp` is invoked (usage block); `corpus/self-counts.tsv` header + two rows and whether it has any binding for a `--selftest` case count.
6. `corpus/source-fetches.tsv` header and its last row; `corpus/sources-census.sh`'s `SC_FETCH` field order as the CODE reads it (quote the code lines, not the comment).
7. `corpus/knowledge/prefreeze-controls.md`: its first 12 lines (front matter shape) and the line naming the selftest.
8. `corpus/lessons/round-33.md`: the `## Mistakes` table header and the M33-1..M33-4 rows with line numbers.
# Acceptance
`ScoutLane.md` holds each item as `file:line` + verbatim quote (<=20 words) + the command you ran, and section 4 is a complete table. Yield the case-count inventory and any place where a file's comment contradicts its code.""")

# ----------------------------------------------------------------- scribes ---
item("ScribeEntry", "scribe", f"""# Target
Draft the adopted knowledge entry `corpus/knowledge/aliyun-accesskey-credential-custody.md` for the lane, re-grounded this round. Staged original: `{STAGED}/knowledge/corpus/knowledge/aliyun-accesskey-credential-custody-r38.md` (read it, then treat it as a draft, not as evidence).
# Change
`{LANE}/{WAVE}/knowledge/aliyun-accesskey-credential-custody.md` (deliverable; the L1 installs it) and `{LANE}/{WAVE}/ScribeEntry.md`. Network is allowed ONLY for the five Aliyun URLs the entry cites.
# Work
1. Read the staged entry and `{LANE}/corpus/knowledge/feed-token-boundaries.md` plus `{LANE}/corpus/knowledge/nist-key-management-guidance-status.md` for the lane's entry shape: front matter `source:` (one line per row, lane ids S083–S087 — re-point by document: S140→S083, S141→S084, S142→S085, S143→S086, S145→S087), `verified-at: 2026-11-04`, `recheck:` (a bounded cadence with a runnable command), `ground:` (one line), then the body, then a `Reverify: R34-01` row where the lane's shape puts it.
2. Re-open EVERY cited URL yourself (`curl -fsSL --compressed`), locate every quote you keep, and keep quotes verbatim. A quote you cannot re-locate is dropped from the entry, not softened.
3. Keep the staged entry's structure where it is right (lifecycle: issue → rotate → expire → delete; the KMS-managed variant; the preference for STS tokens; the one-node-three-languages point) and correct anything the pages no longer say. The entry must be useful standalone: a reader must be able to act on the rotation/disable/delete windows without opening the pages.
4. No secret, token, ID value or credential is copied — documentation only. English prose; keep Chinese/Japanese source quotes as quotes.
# Acceptance
The deliverable carries the four front-matter lines, cites only S083–S087, every quote is located in a 2026-11-04 fetch (state the fetch you used per quote in `ScribeEntry.md`), and `grep -c '^source:'` is 5. Yield the entry's word count and any staged claim you had to correct or drop.""")

item("ScribeRows", "scribe", f"""# Target
Draft the registry append block and the capture rows for round-34 C3: five rows S083–S087 for `corpus/SOURCES.md` and five capture rows for `corpus/source-fetches.tsv`, normalized to the lane's schemas from the staged campaign rows.
# Change
`{LANE}/{WAVE}/sources-append.md`, `{LANE}/{WAVE}/fetches-append.tsv`, `{LANE}/{WAVE}/id-map.txt`, `{LANE}/{WAVE}/ScribeRows.md`. Network is allowed ONLY for the five Aliyun URLs.
# Work
1. Read the staged rows for S140, S141, S142, S143, S145 in `{STAGED}/SOURCES.append.md` and the lane's `corpus/SOURCES.md` header + last row (S082) so the column count matches exactly (11 columns).
2. Re-point ids by document: S140→S083, S141→S084, S142→S085, S143→S086, S145→S087. Normalize every row to the lane schema: `recheck` becomes a valid ISO date, `NNd`, or a symbolic cadence (never campaign prose like `2026-10-23 — re-verify …`); no cell may contain a literal or escaped `|` (rewrite the anchor in your own words if it does); `status` is `mined`; `opened` is 2026-11-04; `used-by` is exactly `corpus/knowledge/aliyun-accesskey-credential-custody.md`.
3. Fetch each URL once to record its capture row: the exact header of `corpus/source-fetches.tsv` decides the columns (read it; do not assume). Fill it from your own fetch: date, bytes, sha256, representation label the lane uses for HTML (`decoded-http-body-v1` or the header's equivalent), normalized digest if the header has that column — never invent a normalization the declared normalizer cannot perform.
4. Build the append block in `sources-append.md` as exactly five table rows (no header, no prose) so the L1 can append it mechanically; `fetches-append.tsv` as exactly five data lines.
# Acceptance
`sources-append.md` has 5 lines each with 12 `|` characters (11 columns); `fetches-append.tsv` has 5 TAB-separated lines matching the header's field count; `id-map.txt` names staged→lane for all five; every row's URL is the one you fetched. Yield the row count, the field count you matched, and any staged cell you had to rewrite.""")

item("ScribeRegistry", "scribe", f"""# Target
Draft the three `SKILL.md` gate-registry rows round 34 owes (routed defect R33-1 and its two siblings): `corpus/prefreeze-control.sh`, `corpus/self-description-sweep.sh`, `corpus/feed-token-agree.py`.
# Change
`{LANE}/{WAVE}/skill-registry-rows.md` only.
# Work
1. Read `{LANE}/SKILL.md`'s registry sections (grep for `## Gate registry`) and copy the exact 8-column shape and the prose style of the last three rows.
2. For each of the three scripts, read the header/usage block and the argument parser (not the prose of another doc) and state, from the code: kind, entry command(s), verdict map with exit codes, selftest command and its case count (run `--selftest` once per script and record the printed line), pinned values/data file, write scope, owner.
   - `corpus/prefreeze-control.sh`: `run --base <rev> --controls <tsv> [--work <dir>] [--timeout <s>]` and `--selftest`; verdicts `PREFREEZE: CLEAN` 0 / `MISMATCH` 1 / `SETUP` 2; case count from the run.
   - `corpus/self-description-sweep.sh`: `[--root DIR] [--selftest]`; verdicts `SELF_DESCRIPTION: CLEAN n=0` 0 / `MISMATCH n=N (SD…)` 1 / `SETUP` 2; note that it reads committed bytes only and that SD6 counts integrator-owned lines (the named exclusion).
   - `corpus/feed-token-agree.py`: `--selftest` and its default mode; verdicts from the code; case count from the run.
3. Write the three rows verbatim, each on one line, plus a short paragraph the L1 can paste under the table.
# Acceptance
Three complete rows in the existing 8-column shape, every cell derived from code you quote in the deliverable (path:line), and the selftest lines you actually observed. Yield the three case counts.""")

# ---------------------------------------------------------------- connector ---
item("ConnOverlap", "connector", f"""# Target
Read-only sibling-overlap scan for round-34 ground: (a) Alibaba Cloud / AccessKey / RAM / cloud-IAM credential-custody claims, and (b) any sibling lane that already runs a self-description or doc-vs-bytes sweep (the SD7–SD9 class).
# Change
`{LANE}/{WAVE}/ConnOverlap.md`, `{LANE}/{WAVE}/ConnOverlap-receipts.txt`.
# Work
For every `/home/vgpnk/Projects/shokunin/*-shokunin` except `kagi-shokunin` (about 20 lanes):
1. `grep -rn` for `AccessKey`, `Aliyun`, `阿里云`, `Alibaba`, `RAM user`, `cloud IAM`, `access key` in `PROVINCE.md`, `SKILL.md`, `corpus/SOURCES.md`, `corpus/knowledge/` — count per lane and quote the owning sentence when a lane claims the ground.
2. `grep -rn` for `self-description`, `doc-vs-bytes`, `claim-ledger`, `registry coverage` in `PROVINCE.md`/`SKILL.md` — is any sibling running the same instrument class? Name it and quote it.
3. `grep -rn` in every sibling `corpus/knowledge/*.md` for `11770`, `17901`, `Key Management` — the lane must not absorb a neighbour's key-management claim.
4. Write the counts and the quotes; state per lane `no-claim` / `claims` / `contested`, and give the L1 a one-line ownership verdict for the AccessKey ground and for the self-description-instrument class.
# Acceptance
Every lane appears once; every `claims`/`contested` row carries `file:line` + a <=20-word quote; no writes outside your two files. Yield the verdicts.""")

# ----------------------------------------------------------------- attacks ---
item("ReviewC1", "reviewer", f"""# Target
Attack round-34 C1 — the three new checks in `corpus/self-description-sweep.sh` (SD7, SD8, SD9) and the claim `SD789_SUM=0` at the landing revision.
# Change
`{LANE}/{WAVE}/review/ReviewC1.md` only.
# Work
The deliverable is `{LANE}/{WAVE}/self-description-sweep.sh` written by ExecSD during this wave. If it is absent when you start, check for it every 30 s up to 10 times (`sleep 30`) before falling back to attacking the plan's predicate on the BASE script — and say which happened.
1. Read `{LANE}/plans/round-34.md` §C1 and the delivered script.
2. Cheat paths — try each and report what happens: can SD789_SUM=0 be reached without fixing anything (e.g. by deleting the checks, by adding junk script names to SKILL.md, by pointing `--root` at a tree with no `corpus/`)? Can a doc satisfy SD7 by naming the script anywhere (a changelog line, a code fence) rather than in the registry? Can SD8 be satisfied by editing the lesson instead of the doc? Can SD9 be satisfied by adding an empty `source:`?
3. False positives — build fixtures: a script named only in a `SKILL.md` code fence; a legit `M33-1..M33-4` range; a legacy entry (no `Reverify:`) with no trio; an entry with `Reverify: R29-01`. None of these should fire; report any that do.
4. False negatives — the round-33 instances must fire: the unfixed tree (BASE) must print SD7=3 SD8=1 SD9=1. Confirm.
5. Reachability: run the plan's exact counting command on the delivered script with `--root` at a BASE extraction (`git archive f9dc06fd… | tar -x -C <scratch>`) and at the current lane tree.
# Acceptance
`ReviewC1.md` lists each attack with the command you ran and the observed line, then a verdict `C1 sound` or `C1 defect: …` with the defect named. Yield the verdict and any defect you found.""")

item("ReviewC2", "reviewer", f"""# Target
Attack round-34 C2 — the `relative-work` selftest case and the M7 mutant receipt in `corpus/prefreeze-control.sh`.
# Change
`{LANE}/{WAVE}/review/ReviewC2.md` only.
# Work
The deliverables are `{LANE}/{WAVE}/prefreeze-control.sh` (ExecGate) and `{LANE}/{WAVE}/mut/` (ExecMut). If absent, check every 30 s up to 10 times before falling back to the BASE script and say which happened.
1. Read `{LANE}/plans/round-34.md` §C2.
2. Does the new `relative-work` case actually exercise a relative `--work`? Reproduce its failure by reverting `WORK_ROOT=$(cd -- "$WORK_ROOT" && pwd -P)` in a copy and show the case fails; then show it passes on the delivered bytes.
3. Is the M7 mutant the escape round 33 described (measures the live worktree; ignores `--base`)? Apply the same mutation yourself to the delivered bytes and run `--selftest`; it must fail at `base-isolation` and nowhere else.
4. Can the claim be met without the work? Try: a case that passes with a relative `--work` because the fixture is a single-commit repo (so live == base); a receipt generated against the wrong script sha; a `CASE base-isolation FAIL` string written by hand.
5. Check the case count really moved 11→12 and that no existing case was weakened or dropped (`grep -c '^  ck '` on both versions, plus a diff of case names).
# Acceptance
`ReviewC2.md` lists each attack with command + observed line, then `C2 sound` or `C2 defect: …`. Yield the verdict and the case-name diff.""")

item("CriticClaims", "critic", f"""# Target
Falsify the three claims as DECLARED in `{LANE}/plans/round-34.md` — not as the wave would like them to read.
# Change
`{LANE}/{WAVE}/CriticClaims.md` only.
# Work
1. For each claim (C1, C2, C3): quote its predicate, counter, target and kill rule verbatim from the plan, then answer — is the target reachable by the declared work, is it reachable by a do-nothing control, and could any post-data reading silently re-scope it?
2. Hunt the specific failure modes the round is at risk of: a counter that measures the new script against a tree where the defect never existed; a "moved" number that a stub reproduces; an entry that lands without the rows it cites; a case count that moves because a case was renamed rather than added; a target whose BASE was measured by a different code path than the tip.
3. Name any wording in the plan that a closure could read two ways, and the reading you would hold the lane to.
4. If a claim is unsound as declared, say which and why, and what the honest verdict would be. Do not propose a new target.
# Acceptance
`CriticClaims.md` carries, per claim, the verbatim predicate + your falsification attempts + `sound` / `unsound: <reason>`. Yield the three verdicts.""")

item("MutSweep", "mutation-tester", f"""# Target
Mutation-test the three new checks: does each one actually catch the class it claims, and does the selftest witness the loss?
# Change
`{LANE}/{WAVE}/mut/MutSweep.md` only, plus fixtures under your scratch dir.
# Work
The deliverable is `{LANE}/{WAVE}/self-description-sweep.sh` (ExecSD). If absent, check every 30 s up to 10 times, then use the BASE script and say so.
1. For each mutant, build it in scratch and run `--selftest` plus a `--root` run on a planted fixture:
   M1 delete the SD7 loop; M2 make SD7 match any `corpus/` path (no SKILL.md check); M3 make SD8 accept any token (skip the row-set test); M4 drop only the `k > m` half of SD8; M5 make SD9 require the trio on every entry (no round gate); M6 make SD9 test `source:` only.
2. For each: expected = `--selftest` FAILs naming the right case, or the `--root` fixture run changes its count. Report actual.
3. Any mutant that keeps `SELFTEST: PASS` is a survivor: name it and say which assertion is missing.
4. Also check the reverse direction: the unmutated delivered script must pass all 10 cases.
# Acceptance
`MutSweep.md` carries a table mutant → expected → observed → survivor?, each with the command and last line. Yield the survivor list (empty is a result).""")

spec = {
    "wave": "kagi-r34-build",
    "context": context,
    "reportDir": WAVE,
    "axes": ["calibration", "operability", "coverage"],
    "milestone": "Round 34: C1 self-description sweep SD7-SD9 (BASE 3/1/1 -> 0), C2 prefreeze relative-work case (11->12) + M7 mutant receipt, C3 AccessKey custody entry + 5 rows",
    "items": items,
}
out = pathlib.Path(f"{LANE}/.ufo/waves/round-34/build-spec.json")
out.write_text(json.dumps(spec, ensure_ascii=False, indent=2) + "\n")
print(f"wrote {out} items={len(items)} roles={sorted({i['role'] for i in items})}")
