# AttackEntry23 — fresh attack of integrated C2: `corpus/knowledge/transcript-hygiene.md`

Axes: **calibration (C1)**, **freshness (C2)**. Leaf attack seat; no delegation, no gates run, no
host reads, no installs (tooling directive: none performed, none needed). Static comparison of
frozen-before bytes, integrated bytes, stamp record, ledger row and build evidence. All paths
below relative to `/home/vgpnk/Projects/shokunin/kagi-shokunin`.

## Read revisions (exact)

- Master tip / integration landing: `8ada17a50a25a75e6fc4a8cf880c87a85c67c8a3` ("round-22: feature-bound review capability and audited revision repairs"), read from `git rev-parse master`, not from HEAD.
- Frozen base (historical BEFORE): `c2cab35bc92e57e39e5489bac3386db078345b3f` (blob verified in object store).
- Freeze authority: `.ufo/waves/round-22/integration-manifest.json` (inputs hashes named below).

## Hash evidence

| record | manifest freeze | observed | verdict |
|---|---|---|---|
| `corpus/knowledge/transcript-hygiene.md` | `4e041fd895b9c1d64c447d14cf66acb0beb74aad2a57bcdf2c4cc60228af7f12` 9905 B / 166 ln | `sha256sum` = same; `wc -c` 9905; blob at `8ada17a` = same | current == frozen == landing; zero in-wave drift |
| same file at base `c2cab35` | (BEFORE, not freeze) | `cd76590aef62b55e9e72f317d16c391ad57e379bf2d7f18076ec024b7bf49d44` 8877 B / 149 ln | base blob recovered |
| `corpus/stamps.tsv` | `88bbe15bf708283e7ee2dc0b6eda15671bb0d4352d3a935a634001853a314a29` | same | unmodified during wave |
| `corpus/claim-ledger.tsv` | `87fed349b7086893ea0a554f99bf857077db921d19dac82c0f68525777c3989a` | same | unmodified during wave |
| `corpus/transcript-scan.sh` | `2d60981b198cef41b9263a1427b41f92d98b65eb26ff71c28057bea0ad823a23` 282 / 14709 | same; matches its `stamps.tsv` row | referent pin exact, unchanged since round 9 |

## Finding 1 — unchanged prefix PROVEN; change is a pure append (freshness, PASS)

`head -c 8877` of the current file hashes to `cd76590a…49d44` — byte-identical to the base
blob. `diff base-blob current` is exactly `149a150,166`: one blank line plus the 17-line
`## Erratum (round 22 — baseline and implementation boundaries)` section. No deletion, no
modification of any historic line; the round-8/round-9 baseline paragraphs, the "verified
2026-09-28" stamps and the old WARN figures stand untouched as history. **No laundering.**

Only one commit (`8ada17a`) touched this file between base and master (same commit moved
`stamps.tsv` and `claim-ledger.tsv`) — one landing, no mid-flight rewrites.

## Finding 2 — stamp record migrated exactly, in the same reviewed commit (C2, PASS)

- Base pin: `corpus/knowledge/transcript-hygiene.md  cd76590a…49d44  149  8877` (was exact at base).
- Current pin (frozen `stamps.tsv`): `corpus/knowledge/transcript-hygiene.md  4e041fd8…af7f12  166  9905` — matches observed bytes on all four fields. Present exactly once; no duplicate.
- Not among the nine dropped/replaced rows: `round21-migrations.json` has `removed_members: []` and its nine changed records do not include this path; `historical-correction-pins.json` (c41af82→e1544c1, 13 records) does not either. The "nine dropped" framing is a row-update signature, never a member loss — zero removed members at both recorded spans.
- Not stale at before: `before.json` stale set (six: config-layering, handler-on-disk-state, handler-trust-boundary, janitor-env-contract, round-18.md, LOG.md) excludes this path — consistent, no unexplained mismatch either side of the landing.
- Ledger row `R11-06` (`claim-ledger.tsv` line 20) is byte-unchanged from its round-11 wording; no expectation migration occurred for this entry, so nothing needed documenting there. The header comment (lines 7-10: exit-1 firing baseline is a host-state event) still holds.

## Finding 3 — the appended erratum marks every false reading the build dossier found

Independent re-derivation from the frozen script (`2d60981b…`, read statically, never executed):
`PATTERNS_HIT` = 32, `PATTERNS_WARN` = 5, `SCAN_COLS` = 24 columns across 11 tables → 24×37 = 888
cells; `grep -c "'eyJhbGci'"` = 0 (only `'eyJhbG'`, line 93); `grep -n 'file:'` hits only the
header comment (line 27) — no URI is ever formed; tail is
`[[ $hits -eq 0 && $absent -eq 0 ]] || exit $(( hits > 0 ? 1 : 2 ))` under the comment "schema
drift is fail-closed".

| build/Entry23.md defect | erratum sentence that marks it | marked |
|---|---|---|
| (a) 270→888 attributed to the new column group alone | "Baseline changes included both column and pattern changes, not columns alone." | ✓ |
| (b) stale `eyJhbGci` token + prose list read as complete inventory | "The prose pattern list is illustrative, not the shipped array inventory; its old longer JWT prefix is not a current independent pattern." | ✓ |
| (c) unqualified round-8 "4 WARN" vs shipped warns=2 | "The early WARN figure is not a current summary; no cause for its difference is established." | ✓ (correctly refuses Entry23's own [INFERENCE] escaping mechanism as fact) |
| (d) dead `?`/`#` URI limitation | "The stated question-mark/hash database-path limitation belongs to the old URI design: the shipped scanner copies a literal path into its scratch snapshot." | ✓ |
| (e) exit-2 omits schema-absent fail-closed | "Exit 2 also includes missing schema coverage with no HIT, not just usage/database-open errors." | ✓ |
| (f) baseline lacks the script hash its own §Bounds rule demands | "Exact shipped-script hash and code-derived correction evidence: `kagi-shokunin/.ufo/waves/round-22/build/Entry23.md`; no live scan was run." | ✓ by named pointer; the hash itself is durably pinned in-tree (`stamps.tsv` row `corpus/transcript-scan.sh 2d60981b… 282 14709`, verified above) |

## Finding 4 — pointer freshness vs unavailable source facts, correctly separated

The erratum's "Source-status: historical — all live database row counts, findings and WARN
figures above are original observations, not a new database read" plus "no live scan was run"
carry `HITS=2`, `warns=2`, tripwire emptiness and the 7/39/55/238 census as 2026-09-28 historic
observations, not as freshly reverified facts; nothing was restamped into currentness. The
boundary sentence "The inherited example commands are historical recipes, not permission to open
this host's private transcript database" neutralizes the entry's live-scan Repro section against
this wave's host-read prohibition. Pointer-type facts (doc pin, script pin) were verified
byte-exact; host-type facts were left honestly unavailable. This is the C2 contract working.

## Admissibility verdict

**ADMIT** — for this entry the integrated round-22 tree is correct: unchanged 8877-byte historic
prefix, append-only 17-line erratum covering all six defect classes without rewriting history,
exact same-commit stamp migration `cd76590a/149/8877 → 4e041fd8/166/9905`, no membership loss,
and honest historic-vs-current separation of source facts.

## Residual risk (non-blocking)

1. **LOW** — `R11-06`'s `cells=[1-9][0-9]*` wildcard still accepts any nonzero cell count; build Entry23 §7's tighten-only proposal was not applied. Legitimate non-change (no migration to document), but the loosened pin persists.
2. **LOW** — the erratum's evidence pointer targets `.ufo/waves/round-22/build/Entry23.md`, which is outside the manifest's frozen input set; the durable referent is the in-tree `stamps.tsv` script row (verified), so no fact depends on the advisory file surviving.
3. **INFO** — the baseline paragraph still names no inline script hash; covered by the stamps row plus erratum pointer, not a false reading.

## Limits

No gate, selftest or revision-audit executed (parent reruns revision-audit once, globally). Host
DB facts (`HITS=2`, `warns=2`, tripwires, census) remain unverified-today by design; all verdicts
rest on committed/frozen bytes, git object history and the wave evidence files named above.
`corpus/claim-ledger.sh docs` (R14-01) not run; row read statically. Mount-optional: parent may
recompute `sha256sum corpus/knowledge/transcript-hygiene.md` expecting `4e041fd8…af7f12`.
