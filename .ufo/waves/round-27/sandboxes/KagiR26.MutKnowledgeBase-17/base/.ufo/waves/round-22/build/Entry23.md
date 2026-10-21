# Entry23 — freshness/calibration audit: `corpus/knowledge/transcript-hygiene.md`

Axes: **calibration (C1)**, **freshness (C2)**. Read-only scout; no gates executed, no host
state read, no installs. Base: `c2cab35bc92e57e39e5489bac3386db078345b3f` (HEAD). The three
audited paths are byte-identical between HEAD blobs and the working tree
(`git show HEAD:<p> | sha256sum` = `sha256sum <p>` for the entry, the script and `stamps.tsv`);
sibling in-flight edits elsewhere in the tree were not read as evidence.

**Verdict in one line:** the stamp row is byte-exact and the script it describes is unchanged
since round 9 — but the entry carries four substantive claim defects that the byte pin cannot
see (stale pattern token, wrong 270→888 causal attribution, an unqualified round-8 WARN number,
and a dead `?`/`#` URI limitation). An appended erratum is warranted; a re-stamp alone would be
laundering.

## 1. Byte pin (freshness of the file) — PASS, no mismatch

`corpus/stamps.tsv:31`:

```
corpus/knowledge/transcript-hygiene.md	cd76590aef62b55e9e72f317d16c391ad57e379bf2d7f18076ec024b7bf49d44	149	8877
```

Actual: `sha256 = cd76590a…f49d44`, `149` lines, `8877` bytes. Exact match (all four fields).

Pin history (committed, `git log -p -- corpus/stamps.tsv`):

| Commit | Event | Row |
|---|---|---|
| `301b9ec` (round 11) | row introduced | `900c3738…1339` / 147 / 8851 |
| `2486643` (round 14) | updated by +2 lines (+26 B): the `Reverify:` line | `cd76590a…49d44` / 149 / 8877 |
| `4b8c018, 587fda0, 8a6ec16, bc1af88, fecee87, c41af82, e1544c1` | unchanged in every later revision | same |

- The row is present exactly once in every `stamps.tsv` revision from `301b9ec` to HEAD.
- **Not among the "nine dropped stamps."** The round-21 correction `e1544c1` removed exactly
  nine `-corpus/…` row lines and added exactly nine `+corpus/…` row lines, same nine paths,
  new hashes (`claim-ledger.tsv`, `onepassword-machine-credentials.md`,
  `sops-age-key-rotation.md`, `vault-openbao-token-lease-lifecycle.md`, `round-21.md`,
  `QUALITY.md`, `README.md`, `sources-census.sh`, `SOURCES.md`). Transcript-hygiene appears once
  in that diff as an **unchanged context line**. `comm` over every consecutive `stamps.tsv`
  revision shows **zero paths ever removed without same-commit re-add**; no duplicate rows at
  HEAD. So for this row the "nine dropped" reading is a row-update signature, not deletion —
  nothing to restore here, and no laundering occurred for this path.

## 2. Referent pin (freshness of the described artifact) — PASS

`corpus/stamps.tsv:58` = `corpus/transcript-scan.sh 2d60981b198cef41b9263a1427b41f92d98b65eb26ff71c28057bea0ad823a23 282 14709`;
actual bytes match. The same hash is byte-identical at `e64e81b` (round 9), at `301b9ec`
(ledger introduction) and at HEAD — **the script has not changed since the round-9
re-verification**. Committed corroboration, `corpus/lessons/round-9.md` §Verification evidence:
"script sha256 `2d60981b…3a23`, 282 lines" and the measured line `TRANSCRIPT_SCAN: HITS=2
(cells=888 patterns=32+5 warns=2 schema-absent=0)`, exit 1, 5 tripwires empty.

Static recount from the shipped file reproduces the entry's numbers exactly:

- `SCAN_COLS` columns: part(1) message(1) event(1) session(7) session_input(1)
  session_message(1) session_context_epoch(2) todo(1) project(4) workspace(3) permission(2)
  = **24 columns**, 11 tables.
- `PATTERNS_HIT` = **32**, `PATTERNS_WARN` = **5** → 24 × 37 = **888 cells**. ✓
- Round 8 (`git show 148ae5c:corpus/transcript-scan.sh`): 9 columns × (25+5) = **270**. ✓

## 3. Substantive defects the byte pin cannot see

All are falsifiable from committed files; none require the host DB.

**(a) Wrong 270→888 causal attribution — line 34-35.**
> "(this last group is what makes the shipped revision 888 cells rather than round-8's 270)"
Single-factor claim; arithmetic refutes it. Round 8: 9 cols × 30 patterns = 270. Shipped:
24 cols × 37 patterns = 888. The delta is **+15 columns and +7 patterns**: `session` widened
1→7 (+6), `project`/`workspace`/`permission` added (+9), patterns 30→37. The new group alone
would give 18 × 30 = 540. Contributing but not "what makes" 888.

**(b) Stale HIT token and an incomplete enumeration — lines 49-53.**
The prose list names JWT `eyJhbGci`/`eyJhbG`; the shipped array contains only `eyJhbG`
(`grep -c "'eyJhbGci'" corpus/transcript-scan.sh` → 0; it existed in round 8 only, `148ae5c`).
The enumeration also omits eight shipped patterns: `xoxc-`, `xapp-`, `sk-or-v1-`, `gsk_`,
`xai-`, `csk-`, `glpat-`, `npm_`. Count: 25 listed tokens, 24 correct, 1 stale, 8 missing of 32.
Read as a set, it contradicts the entry's own "32+5" baseline (line 70).

**(c) Unqualified round-8 WARN number — line 57.**
> "Baseline 2026-09-28 has 4 WARN cells spanning 5 distinct sessions"
The shipped revision reports `warns=2` (line 70, and lessons/round-9.md). `4 WARN` is the
round-8 270-cell revision (line 64 + lessons §12, which quotes "0 HIT, 4 WARN, 270 cells ×
25+5 patterns"). This is exactly the failure mode the entry's own §Bounds prohibits: "Any
baseline number must name the *shipped revision* it describes" (line 125). Mechanism for 4→2 is
[INFERENCE], not measured: four of the five WARN patterns contain `_` (`access_token`,
`refresh_token`, `api_key`, `secret_key`) and round 8's queries were unescaped, so wildcard
underscores could account for the difference. Do not state the mechanism as fact.

**(d) Dead `?`/`#` URI limitation — lines 109-110.**
> "`--db` paths containing `?`/`#` break the URI form (caught by the open probe → exit 2)"
Describes round 8's `file:$DB?immutable=1` read design. The shipped gate takes a literal path
(`DB="$2"`), copies db + `-wal`/`-shm` to `mktemp`, and opens the copy; `sql()` is
`sqlite3 "$SCAN_DB" "$1"`. `grep -n 'file:' corpus/transcript-scan.sh` → only the header
comment at line 27. No URI is formed and no open probe can reject `?`/`#`; the entry itself
documents the snapshot design at lines 85-91, so the two passages contradict each other.

**(e) Exit-2 bullet omits the schema-absent fail-closed path — lines 103-104.**
Script tail: `[[ $hits -eq 0 && $absent -eq 0 ]] || exit $(( hits > 0 ? 1 : 2 ))`. A zero-HIT run
with any scanned table missing exits **2** (coverage unknown), not a usage/db error. The script
header calls this "usage/db/schema"; the entry's bullet names only usage/db causes.

**(f) Baseline omits the script hash its own rule requires — lines 70-71 vs 125-127.**
Line 70 says "shipped revision" but names no `sha256`; line 125 demands "pattern count, cell
count and the script's hash — or it is not a baseline." The hash is available and committed
(`2d60981b…a23`/282/14709), so this is an omission, not an unknown. Note: the entry's
`Reverify: R11-06, R11-07` (line 12) resolves; `corpus/claim-ledger.sh docs` enforces exactly
one resolvable declaration + a stamps row, and **does not** check baseline referents. That is
the enforcement gap: the pin is on the doc, not on what the baseline claims.

## 4. Absent-source limits (what was not verified)

- The primary source is a live host SQLite DB (`~/.local/state/the-janitor/xdg-data/opencode/opencode.db`,
  0600, WAL). This lane forbids live host reads and host gates, so `HITS=2`, `warns=2`,
  "all 5 tripwires empty" and the row census (7/39/55/238) remain **2026-09-28 measurements
  carried forward**, re-correlated against committed evidence but not re-derived from the DB.
- `--selftest`/`--classify` were not executed (gate execution out of lane); their described
  behavior was checked statically against the script only.
- The 4→2 WARN delta mechanism is inference (see 3c). The exact round-8 WARN cells are not
  reconstructible from the frozen tree.
- The "nine dropped stamps" framing is not reconstructible as deletion from committed history;
  the only nine-row event is the in-place re-pin at `e1544c1` (Section 1). Whether some
  out-of-git working-tree set was meant is another lane's evidence.

## 5. Proposed appended correction (proposal only — not applied)

Append a new section; do not rewrite the existing baseline paragraphs, the HIT enumeration or
the historical round-8/round-9 numbers. No legacy header migration (out of scope, per lane).

```md
## Errata (round 22, 2026-10-20) — baseline revision and pattern list

- Measured revision: `corpus/transcript-scan.sh` sha256
  `2d60981b198cef41b9263a1427b41f92d98b65eb26ff71c28057bea0ad823a23`, 282 lines, 14709 bytes,
  unchanged since round 9 (`e64e81b`) and pinned in `corpus/stamps.tsv`. The round-9 baseline
  `HITS=2 (cells=888 patterns=32+5 warns=2 schema-absent=0)` was measured against these bytes.
- The 270→888 delta is not the new column group alone: round 8 (`148ae5c`) scanned 9 columns ×
  30 patterns = 270; the shipped gate scans 24 columns × 37 patterns = 888. The delta is
  +15 columns (`session` 1→7, +6; `project`/`workspace`/`permission`, +9) and +7 patterns
  (25+5 → 32+5); `eyJhbGci` was dropped as prefix-subsumed by `eyJhbG`, coverage unchanged.
- The HIT enumeration above is illustrative, not exhaustive: the shipped array has 32 entries.
  `eyJhbGci` is not one; `xoxc-`, `xapp-`, `sk-or-v1-`, `gsk_`, `xai-`, `csk-`, `glpat-`, `npm_`
  are absent from the prose list.
- The "4 WARN cells" figure is the round-8 (270-cell, 25+5) revision; the shipped revision
  reports `warns=2`. The 4→2 change is consistent with round 9's LIKE-underscore escaping
  (four of five WARN patterns contain `_`), but that attribution is inference, not re-measured.
- The `--db` `?`/`#` limitation belonged to the round-8 `?immutable=1` read design. The shipped
  gate takes a literal path and scans a `mktemp` copy; no `file:` URI is formed.
- Exit 2 also covers a zero-HIT run with any scanned table ABSENT (fail-closed coverage), in
  addition to the listed usage/db causes.
```

**Provenance per bullet:** (1) `stamps.tsv:58` + `lessons/round-9.md` §Verification evidence +
`git show e64e81b:corpus/transcript-scan.sh | sha256sum`; (2) `git show 148ae5c:corpus/transcript-scan.sh`
counts; (3) literal array at HEAD; (4) entry line 57/64 + lessons §12; (5) script `sql()`/`--db`
handling; (6) script tail exit expression. Bullets 1-3, 5-6 are [OBSERVED]; bullet 4's mechanism
is [INFERENCE].

## 6. Exact recheck scope (parent, post-integration, read-only)

```sh
sha256sum corpus/transcript-scan.sh; wc -l -c corpus/transcript-scan.sh   # 2d60981b…a23 | 282 14709
awk '/^PATTERNS_HIT=\(/,/^\)/' corpus/transcript-scan.sh | grep -o "'[^']*'" | wc -l      # 32
grep '^PATTERNS_WARN=' corpus/transcript-scan.sh | grep -o "'[^']*'" | wc -l               # 5
sed -n '/declare -A SCAN_COLS/,/TRIPWIRE_TABLES/p' corpus/transcript-scan.sh \
  | grep -o 'SCAN_COLS\[[a-z_]*\]="[^"]*"' | sed 's/.*="//;s/"//' | wc -w                   # 24
git show 148ae5c:corpus/transcript-scan.sh   # 9 cols / 25+5 → 270 (historic, commit-addressable)
grep -c "'eyJhbGci'" corpus/transcript-scan.sh                                             # 0
grep -n 'file:' corpus/transcript-scan.sh                                                  # comment only
bash corpus/claim-ledger.sh docs          # docs audit: one Reverify, ids resolve, entry pinned
```

After the append lands, recompute the entry's `sha256/lines/bytes` and update **only** row 31 in
the same reviewed commit (old `cd76590a…/149/8877` → new), recording the old→new values in the
integration report. `stamps.tsv` regeneration is a reviewed `stamp` commit — **no auto-re-pin**;
a stale row is a question, not an invitation to rewrite silently.

## 7. Ledger expectation migration (C2, pin debt) — propose only

`corpus/claim-ledger.tsv:20` (`R11-06`) matches `^TRANSCRIPT_SCAN: HITS=2 \(cells=[1-9][0-9]*`
with exit 1. The `cells` clause accepts **any** nonzero count, so a shrink of the column or
pattern set (e.g. 9 columns × 37 = 333, or 24 × 5 = 120 with HIT patterns deleted while prose
still fires) would pass the pin. The printed line already carries the exact facts, and has since
round 9 (`patterns=%d+%d … schema-absent=%d`). Proposed tightening, preserving history in the note:

```
R11-06	bash corpus/transcript-scan.sh	^TRANSCRIPT_SCAN: HITS=2 \(cells=888 patterns=32\+5 warns=2 schema-absent=0\) db=	1	300	known baseline measured against script 2d60981b…a23 (282 lines, 14709 B) on 2026-09-28; cells wildcard before round 22 accepted any nonzero count (round-22 Entry23) [substrate]
```

Direction is tighten-only; the existing `[substrate]` tag and the comment "a change in that line
is a host-state event to re-baseline" both remain true. Do not re-baseline `HITS=2` from an
unreproduced host observation.

## Confidence

- Stamp exactness, pin history, script identity, cell/pattern arithmetic, `eyJhbGci` absence,
  URI-path absence: **high** (direct byte/read/git evidence).
- 4→2 WARN mechanism: **low** (mechanism inferred, numbers are committed quotes).
- Host-measured counts (`HITS=2`, `warns=2`, tripwires, census): **unverified today** (absent
  source, carried from 2026-09-28).
