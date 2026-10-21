# Round 23 falsification — SentSecrets (secrets / paths / injected text / trust boundaries)

Seat: security review of the round-23 artifacts (`corpus/closure-dispositions.py|.json`,
`corpus/source-fetches.tsv`, `corpus/fixtures/cells-hermetic/`, `corpus/lessons/round-23.md`,
round-23 claim-ledger additions, and the SHA-256/deny-list/pointer boundaries they use).
Read-only on the lane: the only file written is this report. No git/jj mutation, no installs, no
host gates, no vault/account/handler commands, no credential-config reads. I did not run the
parent's 43-row claim-ledger verify; R21-02's status is inferred from that row's pinned command
plus my direct run of the command.

## Tree moved during the review (must read before the findings)

The lane was edited by other seats while I measured. **T1** is the tree as delivered to me
(target-file mtimes 00:46–00:56); **T2** is the tree at 01:02:21–01:03:36, after in-flight repairs,
re-measured at 01:03:38. Findings below carry their phase; F1/F3/F4 were real at T1 and are already
repaired at T2. A T2-only reviewer would not see them, so the T1 record is the falsification value.

## Commands and exits (cwd = `/home/vgpnk/Projects/shokunin/kagi-shokunin`)

| # | command | T1 exit | T2 exit | observed |
|---|---|---|---|---|
| 1 | `bash corpus/sources-census.sh` | **1** | 0 | T1: stdout empty, stderr `corpus/sources-census.sh: line 242: S007: unbound variable`; T2: `SOURCES_CENSUS: CLEAN (rows=26 A=24 B=0 C=2 queued=1 mined=24 rejected=1 entries_sourced=4 legacy=21)` |
| 2 | `bash corpus/sources-census.sh --selftest` | 0 | 0 | `SOURCES_CENSUS_SELFTEST: PASS (59 cases)` |
| 3 | `python3 corpus/closure-dispositions.py --root . --selftest` | 0 | 0 | `CLOSURE_DISPOSITIONS_SELFTEST: PASS (13 cases)` |
| 4 | `python3 corpus/closure-dispositions.py --root .` | 0 | 0 | `CLOSURE_DISPOSITIONS: CLEAN (obligations=15 fixed=7 reported=2 operator_owned=1 no_action=5 rejected=0 pointers=15)` |
| 5 | `bash corpus/claim-ledger.sh cells --root corpus/fixtures/cells-hermetic --claims …/claims.tsv --stamps …/stamps.tsv --scorecard …/SCORECARD.md --docs …/SCORECARD.md` | 0 | 0 | exact `CELL_AUDIT: CLEAN (cells=6 row_pointed=6 stamp_pointed=1 uncited=0 missing_ids=0 rows_run=2 row_deferred=0 row_failures=0 stale_pointers=0 self_skipped=0 orphans=0)` |
| 6 | `bash -n corpus/sources-census.sh` | 0 | — | syntax valid |
| 7 | `shellcheck -S warning -f gcc corpus/{sources-census,surface-census,claim-ledger}.sh` (T1) | 0 | — | `corpus/sources-census.sh:242:47: warning: SUPERSEDED appears unused … [SC2034]` |
| 8 | symlink pointer probe (mktemp root, import `resolve_pointer`) | 0 | 0 | T1: out-of-root symlink pointer → `[]` (clean); T2: → `POINTER-ESCAPE`; `../…` and `/etc/hostname` rejected in both |
| 9 | `policy_check` sourced verbatim from `claim-ledger.sh:160-193` | 0 | 0 | ALLOW `bash corpus/s.sh`; ALLOW `bash …/fx-ok.sh`; REFUSE `curl …` (first-token), `grep -q op …` (denied-verb), `python3 corpus/evil.py` (python-script) |
| 10 | `awk`/`grep` scans (Confirmations) | — | — | no secrets, no absolute paths, no bidi/C0 bytes, all TSV rows NF=16 |

F1 diagnostics: `grep -n SUPERSEDED corpus/sources-census.sh` (T1) → one hit, line 242;
`grep -n 'declare -A'` (T1) → lines 203, 229 only; `bash -uc 'declare -a A=(); A[S007]=1'` →
`S007: unbound variable`, exit 127; `bash -uc 'declare -A B=(); B[S007]=1; echo ok'` → `ok`, exit 0.
Six SOURCES.md rows carry a `supersedes S…` tier (lines 25,26,28,29,31,32), so the T1 branch fired
on the first emitted key.

## Findings

### F1 — HIGH (T1; repaired in-flight) — census fatal before SC_FETCH, before the credential scan, before the verdict

**Defect (T1).** `corpus/sources-census.sh:242` assigned `SUPERSEDED[$fid]=1` with `SUPERSEDED`
never declared; the only associative declares were `:203` (`ST UB TI`) and `:229`
(`FURL FINROW FSEEN FDIG FNRM`). An undeclared array is indexed, so the key `S007` was arithmetic
evaluated; `set -u` (`:107`) made the unset name fatal. SC2034 at `:242:47` independently reported
the variable unused (written once, never read).

**Trigger.** Deterministic: the six `supersedes S…` tiers fed `:242-246`; the first key killed the
shell. No adversary required.

**Impact (T1).** The fatal preceded the SC_FETCH block (`:247-305`), `cred_scan "$src"
"corpus/SOURCES.md"` (`:307`), the per-entry `cred_scan` in the knowledge loop (`:333`) and the
verdict (`:337-343`). At T1, therefore: C2's counting command (`corpus/lessons/round-23.md:61-63`
then, `:169-174` now) was false; claim row R21-02 (`corpus/claim-ledger.tsv:52`, pinned
`^SOURCES_CENSUS: CLEAN \(rows=26 …\)$`) could not pass; and the lane's credential needle scan
(1Password refs, PEM armour, PAT, AWS key id, Slack token, age key, Vault/OpenBao token) never ran
on the real corpus. The 59-case selftest could not catch it: no fixture SOURCES row carried a
`supersedes` tier, so the branch was never exercised with a non-empty key.

**Status T2.** Repaired outside my lane (mtime 01:02:21): the `SUPERSEDED` block is gone; the
command exits 0 with the CLEAN row above, so SC_FETCH and `cred_scan` (`:302` now) execute again.
Removing the block is safe — the array was never read. Residual: none observed; if supersedes
parsing is reintroduced, add a selftest case with a `supersedes S…` tier.

### F2 — MEDIUM (live at T2) — claim-row deny list is a string filter; `bash <script>` bypasses it

`corpus/claim-ledger.sh` (mtime 00:53, unchanged in both phases): `policy_check` at `:158-192`
inspects only the command string — first-token allowlist `:160`, metachar ban `:163`, deny words
`:167` — and rows run with the inherited environment (`:426-427`, no `env -i`/`HOME` override).
`bash` is allowed and the executed file's contents are never scanned. Command 9 on the real
function: `bash corpus/s.sh` is ALLOW.

Round-23 relevance: the C3 fixture legitimizes that shape — `corpus/fixtures/cells-hermetic/claims.tsv:1`
runs `bash corpus/fx-ok.sh`, executed by R23-01 (`corpus/claim-ledger.tsv:59`). Today `fx-ok.sh` is
38 bytes (`printf 'FX: OK\n'`) and its SHA-256 matches fixture `stamps.tsv:1` (`29f98fba…`), so
there is no live exploit. The boundary is still weaker than it reads: any later fixture/script, or
a script changed together with its stamp, reaches the network, `op`, the vault or `$HOME` while
`policy_check` passes. "Hermetic/host-free" is a property of the fixture bytes, not an enforced
sandbox, and the lesson states no such bound.

Smallest remediation: refuse `bash <path>` unless the path is under the claim root and its SHA-256
is pinned in the active stamps file, and/or run rows under `env -i PATH=… HOME=<tmpdir>`; otherwise
state explicitly that `policy_check` is a lexical guard, not a sandbox.

### F3 — LOW (T1; repaired in-flight) — closure pointer containment was lexical only

At T1, `resolve_pointer` (`corpus/closure-dispositions.py:104-124` then) rejected absolute/`..`
paths but used `is_file()`/`read_text()`, which follow symlinks; command 8 proved a symlink inside
`--root` to an outside file returned `[]` (clean), so a `fixed` disposition could be satisfied by
an out-of-tree file the gate silently read. No symlinks exist in `corpus/` (`find corpus -type l` →
none), so it was latent, not live. At T2 (mtime 01:02:21) the function resolves and contains
(`:112-118`: `target.resolve()`, root-parent check, `OSError` → `POINTER-MISSING`); the probe now
returns `POINTER-ESCAPE`. Residual: none observed (`root` is a directory, so the `resolved !=
root.resolve()` clause is unreachable).

### F4 — LOW, calibration (T1; corrected in-flight) — provenance URL count

At T1 `corpus/lessons/round-23.md:165` said "10 declared provenance rows (S017-S026) over seven
distinct URLs". Measured: `awk -F'\t' '!/^#/ && NF==16 {print $4}' corpus/source-fetches.tsv |
sort -u | wc -l` → **9**. At T2 the text (`:169`) says "nine distinct URLs"; the artifact is
unchanged (mtime 00:55) and still yields 9. The adjacent registry claim (26 rows, 19 distinct
URLs, `18 → 19`) reproduces.

### F5 — LOW, self-certifying pointer (introduced at T2, 01:03:02) — D9's `fixed` proof is a token planted for the checker

`corpus/closure-dispositions.json` now points D9 (`fixed`) at
`corpus/fixtures/cells-hermetic/SCORECARD.md`, and that file's first line is
`<!-- D9: hermetic cells fixture; rows are declared in claims.tsv -->` — the token exists to
satisfy `resolve_pointer`'s id test (`corpus/closure-dispositions.py:123-126`). This is inside the
gate's stated bound ("a `fixed` pointer proves a reviewed record exists … not that its content is
correct"), and the pointer is semantically apt (D9 is the fixture row); flagging it only because
the proof is now the fixture commenting on itself. `corpus/claim-ledger.tsv` still contains the
earlier D9 token (R23-01 note), so the re-point was elective. No action required; do not cite D9's
pointer as independent evidence that the fixture is exercised — R23-01 and the exact CLEAN line
are the evidence.

## Seat classes (file:line and class only)

- **Credential material — none found.** Scans over `source-fetches.tsv`, `closure-dispositions.*`,
  `round-23.md`, the fixture tree, and the modified `SOURCES.md` / `op-ref-consumption.md` /
  `surface-census.sh` / `claim-ledger.sh` for `ops_…`, `-----BEGIN` armour, `eyJ…`, `AKIA…`,
  `ghp_…`, `glpat-…`, `xox[baprs]-`, `Bearer …`, `sk-…`, and ≥120/200-char base64-ish runs → zero
  matches. The census's fragment-assembled needle ERE does not self-match its source
  (`grep -cE` → 0). Fetch URLs carry no userinfo/query. No `.env`/PEM/`id_*`/`.netrc` in the
  fixture or the `/tmp` clone.
- **Absolute private paths — none absolute.** Home/tmp-anchored names only:
  `corpus/lessons/round-23.md:80` `~/.config/mise/config.toml` (D2 install disclosure),
  `:118` `/tmp/kagi-shokunin` (D8 residue), and `corpus/fixtures/cells-hermetic/corpus/adjacency.tsv:2-9`
  `$HOME/...` directory names as fixture data. Class: host-layout disclosure, non-secret; no
  contents. The `/tmp/kagi-shokunin` clone is a stale 2026-10-20 checkout (no round-23 files),
  755/644, remote `https://github.com/VeigaPunk/kagi-shokunin.git` with no embedded credentials
  (`.git/config` credential-word count 0).
- **Instruction-like text copied from fetched pages — none agent-directed.** The only imperative is
  S017's H1 quote "Use 1Password Credential Broker to access secrets in GitHub Actions at runtime
  (public preview)" (`corpus/source-fetches.tsv:37`, `corpus/SOURCES.md:23`) — a vendor CTA with no
  second-person/agent address. No `ignore`/`you`/`assistant`/`system prompt`/executable text in any
  quote; no HTML or `<script>` in TSV/SOURCES rows; zero C0/ESC and zero bidi/zero-width characters
  in the current files (`grep -P` classes → no match); quotes are ≤22 whitespace words and are
  emitted only via `printf '%s'` (`sources-census.sh:138`).

## Confirmations (attacked, held at T2)

- C1: verify CLEAN 15/15 pointers exit 0; 13-case selftest exit 0; selftest writes confined to
  `tempfile.TemporaryDirectory` (`closure-dispositions.py:264`), verify performs no writes.
- C3: exact pinned CLEAN line at exit 0 with `rows_run=2 self_skipped=0`; fixture stamps match bytes
  (`sha256sum` `29f98fba…`/38 B/2 lines, `c17f7e17…`/307 B/9 lines); the fixture's 8
  `# no-enumerate` matches equal the pinned `^8$`.
- D7 shape: all 10 provenance rows have 16 tab-separated fields, unique ids, status `mined`,
  https-only URLs; S021/S026 share a URL and agree on raw and normalized digests (consistent with
  the volatile rule); quote word counts ≤25 (max 22).
- D1/D2 census behaviours: at T2 the census reaches the verdict and prints no `SC_CREDENTIAL`
  finding; R21-02's pinned line is reproducible.
- Hygiene (non-security): `corpus/__pycache__/closure-dispositions.cpython-314.pyc` (644) is
  untracked residue and would enter a `git add -A` commit; it contains no secret.

## Bounds

I did not re-fetch the ten URLs, so declared digests/byte counts are unverified against live pages;
I did not run `claim-ledger.sh verify` (parent's 43-row audit, out of bounds), so F1's effect on
R21-02 is stated from its pinned command plus my direct census run, not a row execution. No
production file was edited; F1/F2/F3 fixes are proposed, not applied. T1 measurements used the
tree as delivered (target mtimes 00:46–00:56); T2 re-measurement is timestamped 01:03:38.
