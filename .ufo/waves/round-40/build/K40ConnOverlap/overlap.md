# K40ConnOverlap — sibling-overlap scan receipt (round 40)

Seat: K40ConnOverlap (connector, leaf). Date: 2026-11-05. Read-only over the fleet; writes confined
to this seat dir and the Report path. No clones, no fixtures, no git/jj calls, no installs.

## Lanes walked (20; kagi-shokunin itself skipped)

Enumerated with `printf '%s\n' /home/vgpnk/Projects/shokunin/*-shokunin` (exit 0; 21 dirs, kagi skipped):
audio, chousa, game-dev-2d, game-dev-3d, kaidoku, kake, kama, kasegi, kengaku, kotoba, kotodama,
kumitate, lore, mado, mori, revenger, souji, tabi, tameshi, tsukuroi.

Presence check (bash loop, exit 0) — PROVINCE.md / SKILL.md / corpus/SOURCES.md:
- audio: PROVINCE, SOURCES (no SKILL.md)
- game-dev-2d: PROVINCE, SOURCES (no SKILL.md)
- all other 18 lanes: all three files present.

## Greps run (read tool `grep`, case-insensitive, per-lane three-file batches; three waves)

Wave A — (a) python.org documentation-currency claims:
`docs\.python\.org|Python 3\.[0-9]+\.[0-9]+ documentation|served[- ]version`
Wave B — (b) anchor-cell pinning of release/registry rows:
`anchor[ -]pins?|ANCHOR_PINS|sha-?pinned|lineSha256|pin-recheck|ANCHORLINE|anchor_line|anchor cell|anchor header|anchor-pins\.tsv`
Wave C — (c) gate-registry + committed-gate-selftest conformance:
`gate[ -]registr|SELFTEST[: ][A-Za-z]*pass|self-?test.*(pass|cases)|--selftest`
Confirmation greps (single file, deeper cap): `gate[ -]registr` on tsukuroi/SKILL.md, kaidoku/SKILL.md;
`gate[ -]registr|registry` on kengaku/SKILL.md; `gate[ -]registr|self-?test` on game-dev-3d/SKILL.md.

One fleet-wide probe `SELFTEST|selftest` over `*-shokunin` with a `!kagi-shokunin/**` exclusion
returned "No matches found" while per-lane greps on the same words matched — the mixed dir+exclusion
path spec is broken in the grep tool; the per-lane greps above are the authoritative scan. ([tool note])

## Per-lane verdict

Legend: (a)/(b)/(c) hit type in PROVINCE.md, SKILL.md, corpus/SOURCES.md. "overlap" = same surface as
kagi round-40's claim (SOURCES python-docs currency rows; sha-pinned anchor/quote cells of registry
rows; SKILL gate-registry table + committed gate selftests). "adjacent" = different surface, same idea.

| lane | (a) docs-currency | (b) anchor pinning | (c) gate-registry+selftest | verdict summary |
|---|---|---|---|---|
| audio | none | none | none | clean |
| chousa | overlap: SOURCES S038 (3.15.0 served 2026-10-21), S044 (3.15.1), S052–S056/S059/S060/S063 (3.15.1), S074 (3.15.1 dup-rejected); round-40 provenance re-opened hashlib S059 2026-10-24 | adjacent: sha256 of fetched bytes in locator cells (S057 `SHA-256 c8fff6f2…`); no anchor-pin gate | overlap: SKILL `## Gates` table; research-gate --selftest 275 cases; claims-audit --selftest 10 cases; lane-preflight G08 gate-selftest leg; routed S193 = gate-registry row missing owner cell | overlap on (a)+(c) |
| game-dev-2d | none | none | none | clean |
| game-dev-3d | none | adjacent: sha256 manifest pins (`sha256sum -c .manifest.d/*.sha256`), "cite mutable files by heading + sha256 stamp" citation rule | none: committed `run_gate.sh` CHECK 1–4 but no registry table or selftest in the scanned files | adjacent-only |
| kaidoku | overlap: SOURCES S050 (3.15.0), S143/S144 fetched+sha, S266/S267/S287/S292/S293 ("Python 3.15.2 documentation"), S274→S276 and S299→S300 correction/supersede pairs; SKILL:709 cites re.html | overlap: locator cells carry snapshot sha256 (S143/S145/S147); round-60/63 gates sha-pin instrument bytes (`--expect-sha256`); no anchor-cell pins file | overlap: SKILL `## Local round-evidence gate registry` (:886); `tools/round-86/gate-registry.py` re-derives one gate's registry row with G1–G5 legs incl. "the row's own self-test command run … exit compared" | overlap on all three |
| kake | overlap: S026/S027 (3.15), S100/S111/S115/S116 (3.15.1 retained sha), S133 (3.15.1), S437/S441/S442 (3.15.2) | adjacent: freshness-sidecar `lineSha256` pins (kake-paths-sidecar-v1) over lane-cited lines | overlap: `### Owned freshness gate registry`, receipt-replay registry, round-23/24 registries; Self-test columns with committed selftests | overlap on (a)+(c), (b) adjacent |
| kama | overlap: S044/S051/S061/S064/S065/S075–S077 (3.14), S087/S088 series-URL currency rows ("page title now3.14.9 rather than opening-time3.14.8"), S517 (3.15.2, last updated 2026-10-27), S538–S541 | adjacent(+): registry/pin-recheck-rows.tsv anchor headers recomputed by tools/round86-pin-origin.py vs live upstream bytes; corpus/anchors/ committed extracts (S566–S570) — same idea, kama's registry files not SOURCES | overlap: SKILL registry tables with per-row --selftest and pinned tallies (PRE_REPORT_SELFTEST pass=35 fail=0; PIN_RECHECK_SELFTEST pass=14 fail=0) | overlap on (a)+(c), (b) adjacent-strong |
| kasegi | none in scanned files | overlap: SOURCES rows "anchor pinned to the round-N capture … sha256 …, lines …" (S042/S044/S046–S052/S055/S056/S058/S059/S073/S074/S085–S091…); manifest.json digest pins | overlap: "Gates & probes registry addition" tables; anchorcheck.py --selftest (limbs=9, cases=12), source-recheck.py --selftest, capture-binding-check.py --selftest cases=33, r-defect-closure.sh --selftest; routed D3 "gates unregistered at the registry home" closed by registration rows | overlap on (b)+(c) |
| kengaku | overlap: S046/S052 "rechecked 2026-10-26 on Python 3.15.2 docs (R40SourcesRecheck)" (explicit served-version refresh rows), S065/S071/S075/S076 (3.15.1), S249/S250 (3.15.2 captures) | overlap(+): `anchor-line-check` gate (plans/anchor_line_check.py, --selftest, six fixture lanes) with `ANCHORLINE rows=210 cited=64 captured=57`; S221→S222, S265→S266 word-count/anchor corrections append-only | overlap(+): SKILL `## Gate/probe registry (PROTOCOL §Gate standard)` (:592); round74-c1 registry gate with `SELFTEST-UNBACKED` defect class; round73-c2/round75-c2 registry-audit gates | overlap on all three (strongest single-lane synthesis) |
| kotoba | overlap-light: S007 json docs (queued), S253 tempfile fetched+sha | adjacent-light: sha256-pinned normalization (own-work S010), no anchor pins | overlap: SKILL `## Gate registry` (:443) + `verifiers/check_gate_registry.py --rev` comparing rows with files; verify_skill_checklist --self-test 1845 assertions | overlap on (c), (a) light |
| kotodama | none | adjacent: sha-pinned replay profiles (SKILL:232) | overlap: gate registry table (:670–686) with --selftest column; check-gate-battery.py (7 selftests + baseline pins) | overlap on (c) |
| kumitate | none | none | overlap: SKILL `## Gate registry` (:587), 29 rows, per-row --selftest, gate-mutants 43-mutant battery | overlap on (c) |
| lore | overlap-light: S003 graphlib "Python 3.15.0 documentation, page last updated Oct 19, 2026" | none | overlap(+): SKILL `## Gate registry` (:48); boundary_doc_check --self-test landed while "the missing self-tests for discriminate_check and support_check remain conformance debt" — registry rows encode the exact kagi-C3 pairing and name debt where selftest absent | overlap on (c) (+) |
| mado | overlap: S440–S444 CPython 3.14.8 doc-source rows, triple-fetch byte-identical sha pins, supersedes chains | adjacent-light: self-audit sha256 stamps of receipts | overlap: SKILL `## Gate registry` (:779) with selftest columns | overlap on (a)+(c) |
| mori | overlap: S063/S065 (3.15.0), S176/S177/S226/S229/S231 (3.15.1/3.15.2; S231 located-quote correction supersedes S229), S347/S348, S577 (sphinx html_last_updated_fmt — the docs footer-stamp currency row), S589/S607–S609 | overlap: S349 sha256 anchor correction of S235's transposed anchor via superseding row ("that row is not rewritten"); S234 "anchor cell is immutable, so the fix rides this row" | overlap(+): SKILL registry table + self-test column; tools/mori-gate-registry.py ("Audit committed instruments against SKILL's gate-registry standard") and tools/mori-pin-check.py ("Remeasure the self-test tally pins bound in SKILL's gate registry") | overlap on all three (registry-conformance-as-gate) |
| revenger | overlap: S011 (3.15.0), S040 zipfile 3.15.0 → S044 3.15.1 → S053 3.15.2 (served-version refresh chain on one URL — kagi's S040→S095 pattern), S165/S484 (3.15.2) | overlap(+): receipt_sweep.py --selftest checks "the ANCHOR cell (column 7 of 11) of every `| S### |` row"; WC_MAP quotes byte-exact substrings of anchor cells (MAP_CHECK_ALL_OK=True) | overlap(+): `## Gate registry (registry home; PROTOCOL.md §Gate standard)` with field-value rows, self-test rows with red/green evidence pairs (gate_probe2, receipt_probe2, probe_negctl2) | overlap on all three (strong) |
| souji | overlap: S040/S050/S061 (3.15.0), S104–S108 (3.15.1), S226 vs S229 tempfile (S229 rejected because served 3.15.2 ≠ lane interpreter 3.14.8 — currency policy row), S248/S249/S252/S253/S255 (3.15.2 fetched, snapshot sha) | none | overlap: `## Gate registry` (:196); rows with selftest commands (souji-landing-gate --selftest 65/0 etc.) | overlap on (a)+(c) |
| tabi | none | adjacent: sha-pinned capture methodology scripts (SKILL:371–378) | overlap: `### Freshness gate registry` (:1555), `### Sources gate registry` (:1610), metadata/measurement-binding registries; self-invocation columns (--self-test) | overlap on (c), (b) adjacent |
| tameshi | overlap(+): S049 (3.15.0), S055 doctest 3.15.0 → S100 /3.15/ pinned snapshot supersedes S055 because "the /3/ alias drifts (footer rebuilds move the digest)"; S153/S154 "docs.python.org's footer clock moves within a day (the round-33/40 lesson)"; S307–S311 | overlap(+): S300 anchor-drift sweep (HTMLParser over snapshots, compares anchor cell §heading vs snapshot heading set); S299 anchor heading correction with red arm (s299-anchor-as-written) | overlap: SKILL surveys fleet-gate selftest grammars and runs mutation batteries over kagi/kumitate/tsukuroi gates (kagi surface-census 8/10 killed) | overlap on all three |
| tsukuroi | overlap: S259/S260 python-on-windows 3.13 (S260 locator correction), S335 subprocess rolling 3.x fetched 2026-11-05 "title Python 3.15.2 documentation" | adjacent: S333→S334 anchor re-index corrections to raw lines (append-only supersedes) | overlap: SKILL `### Gate registry` (:1705) and `### Round-14 correction-conformance gate registry` (:1774) with Self-test columns; census gate selftest (TSUKUROI_CENSUS_SELFTEST PASS 74/63 cases) | overlap on (a)+(c) |

Totals: (a) hits in 16/20 lanes (none: audio, game-dev-2d, game-dev-3d, kasegi, kotodama, kumitate — 6,
so 14 lanes with (a) hits; kotoba/lore light). (b) hits: overlap 7 (kaidoku, kasegi, kengaku, mori,
revenger, tameshi, + kama adjacent-strong/kake adjacent); adjacent 6. (c) hits: overlap 17/20 (none:
audio, game-dev-2d, game-dev-3d).

## Consequence for round 40 (one-line)

No sibling surface collides with kagi's C1 (claim-ledger rebind is lane-internal). C2's python-docs
refresh row pattern is already fleet-wide practice (every overlap lane above) — no novelty conflict,
and siblings already solved the /3/ URL drift problem kagi's captures will hit next. C3's
"registry row + passing committed selftest" conformance program exists in at least six siblings
(kengaku, kaidoku, mori, kotoba, revenger, lore) — kagi's two-row landing is conformant by fleet
convention, not novel.
