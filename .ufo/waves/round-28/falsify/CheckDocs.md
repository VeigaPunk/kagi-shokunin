# CheckDocs — SKILL/PROVINCE/README/QUALITY QM27–29 vs the actual token/derived rules

Target: kagi-shokunin @ `62a33b1bd15217ed729df2ca40c8a30aba3076c0` (pinned candidate). Scope: doc↔code agreement for QM27 (canonical tokens), QM28 (derived anchors), QM29 (conformance) and the SKILL/PROVINCE/README prose stating the same rules. Counts only; no production edits. Verdict: **FAIL (narrow)** — 1 HIGH, 2 MEDIUM, 1 LOW mismatch; narrow PASS block below. All findings are against the pinned candidate, not the later repair `5e847472`/`899c50b`.

## F1 — HIGH: QM27's "never ordered, compared" is false, and the comparison collapses leading zeros

`corpus/QUALITY.md:134` (QM27): "A non-canonical anchor, observation or newest feed entry is a typed `NON-CANONICAL` finding …; **it is never ordered, compared**, fired, written as a verdict, or turned into a traceback." The candidate contradicts this twice:
- `corpus/release-clock.py:409-415` — `version_order` docstring: "exact for any digit count, so a non-canonical token **is compared by its value** (leading zeros change nothing)"; the key is `(len(part.lstrip("0")), part.lstrip("0"))`.
- `corpus/release-clock.py:795-796` — `newest_stable` compares non-canonical tokens: `any(version_order(token) >= version_order(newest) for token in tokens if non_canonical_version(token))`.

Counterexample (measured, candidate module imported read-only): `version_order('3.15.01') == version_order('3.15.1')` → **True**. The very collapse S046 is cited to forbid is the mechanism that decides the feed's fail-vs-ignore branch.

## F2 — HIGH: QM27/QM28's typed findings have no ledger row — the behavior is unpinned by any lane gate

`corpus/claim-ledger.tsv` has **zero** rows mentioning `NON-CANONICAL` or `DERIVATION` (`grep -n "canonical\|digit\|NON-CANONICAL\|DERIVATION" corpus/claim-ledger.tsv` → only R21-03 "2-digit ids" and R25-03). R25-03 pins only the case **count** (`^RELEASE_CLOCK_SELFTEST: PASS \(106 cases\)$`), R25-04 only the CLEAN summary line. So replacing `NON-CANONICAL` with `RECEIPT-MISMATCH`, or `DERIVATION` with `INCONSISTENT`, leaves every lane gate green — measured `python3 -I -B corpus/self-counts.py` → `SELF_COUNTS: CLEAN (claims=60 stale=0)`, exit 0. QM29 (`corpus/QUALITY.md:136`) demands "A check of this must fail on a round that broke it"; QM27/QM28 have no equivalent. Their only executors are wave-local tools (committed in 62a33b1: `.ufo/waves/round-28/tools/c1-measure.py`, `c2-measure.py`) — not gate rows.

## F3 — MEDIUM: SKILL.md's exit-1 category list omits the two round-28 categories the code emits

`SKILL.md:48` exit cell: "1 `UNBOUND`/`ORPHAN`/`BADFEED`/`INCONSISTENT`/`RECEIPT-MISMATCH`/`REGRESSED` + `FAILED`" — no `NON-CANONICAL`, no `DERIVATION`, though the same row's prose cell introduces them. Code emits them at `corpus/release-clock.py:625` (`DERIVATION`), `:631` and `:680` (`NON-CANONICAL`). Measured `evaluate()` on synthetic rows → errors `[('NON-CANONICAL','S001')]` and `[('DERIVATION','S001'),('INCONSISTENT','S001'),('NOT OBSERVED','S001')]`. (`NOT OBSERVED`, `corpus/release-clock.py:677`, is also unlisted — present at BASE too, pre-existing, not a round-28 regression.) PROVINCE.md:54 has no enumeration → unaffected.

## F4 — MEDIUM: the length bound's stated ground no longer matches the code, and its number is unpinned

`corpus/README.md:233` cites "S044 CPython int-string limit" for the canonical-token rule; S044's registry scope (`corpus/SOURCES.md:51`) says: "…why a release clock must bound version components lexically before any int(); **not a canonicality or feed rule**". QM27 leans on the same source ("a declared lexical length bound decided before any int()"). But the candidate **removed int() from ordering entirely** — `corpus/release-clock.py:409-415` compares by string length/digits only, and `grep -n "int(" corpus/release-clock.py` shows no int() on any version text (only `%d` print formats). The traceback hazard S044 describes is already impossible, so the bound is now purely a canonicality rule with no cited authority. The number is a lane-local choice (comment `corpus/release-clock.py:385-387`: 18 digits keep a component inside a signed 64-bit integer) with no registry row and no self-counts binding, yet `SKILL.md:48` and `corpus/README.md:234` state "18"/"over-18-digit" as current-tense numbers about this lane's own artifact. `corpus/self-counts.tsv` (60 rows) binds no row for it (search for `18`/`digit` returns only R18-01 and a round-18 history note).

## F5 — LOW (limit, undocumented): a feed anchor cell naming a module tag breaks a correct derived anchor

`corpus/release-clock.py:349-364` requires the feed anchor cell's stable-token **set** to equal exactly `{anchored}`. Measured: `derived_anchor_bound('v2.2.0 and sdk/v0.26.0','2.2.0')` → **False** → `DERIVATION`. QM28 names "a cell naming two versions binds none" but not the module-tag shape (the same string S034's `teaches` column carries).

## Narrow PASS (measured against the candidate)

- Selftest count agrees: `SKILL.md:48` "`--selftest` 106 cases"; `python3 -I -B corpus/release-clock.py --selftest` → `RELEASE_CLOCK_SELFTEST: PASS (106 cases)`, exit 0; `python3 -I -B corpus/self-counts.py` → `OK SC-CLOCK-SELFTEST SKILL.md:48 claimed=106 live=106`, exit 0; R25-03's `\(106 cases\)` matches. (114 belongs to later repair `5e847472`.)
- Default gate: `python3 -I -B corpus/release-clock.py` → `RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=3 derived=15)`, exit 0 — byte-equal to R25-04; `derived=15` equals the 15 `derived:` rows in `corpus/release-clocks.tsv` (all 30 rows listed).
- QM29 holds: `python3 -I -B .ufo/waves/round-28/tools/round-conformance.py <lane> 28` → `C1 OK touched=2`, `C2 OK same-commit`, `C3 OK lines=2`, `VERDICT PASS`, exit 0; same command on round 27 → `C1 FAIL-SCOPE touched=1874 outside=1873`, `C2 FAIL-MISSING census=never-committed`, `VERDICT FAIL`, exit 1.
- Plan frozen part unchanged: `git diff bdf90f5…62a33b1 -- plans/round-28.md` adds only lines after the `## Plan corrections` heading; both corrections (`b9a42c0`, `2dfb534`) precede the work commit.
- Canonicality core agrees with the prose: `3.15.01` non-canonical, `3.15.1` canonical, component `0` canonical vs `00` non-canonical, 18-digit canonical vs 19-digit non-canonical, leading-zero never fires (S040 fixture → `NON-CANONICAL`, row invalid).
- QM28 binding works as documented: unbound derived anchor → `('DERIVATION','S001')`; re-pointing the row to a feed naming a different version → `DERIVATION`; same-version feed → no `DERIVATION`.

## Not checked / scope limits

Frozen counting commands (`c1-measure.py`, `c2-measure.py` over BASE vs candidate) were not re-run — outside my doc-agreement scope; `corpus/claim-ledger.sh verify` (lane-wide) not run. Host-private ledger rows were read as pins only (R12-03/R21-04); no host/op/vault/CDP contact, no network fetches, no `corpus/SOURCES.md` edit. S044–S049 capture bodies and S045/S046 quote accuracy were not re-verified against the live pages. The lane checkout is not clean (untracked `.ufo/waves/round-28/**` + modified SKILL/PROVINCE/QUALITY/README carrying the later repair content, matching `5e847472` for those docs); I edited no production file. Tooling: none installed this round.
