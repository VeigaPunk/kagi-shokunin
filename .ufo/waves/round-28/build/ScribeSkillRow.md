# ScribeSkillRow — round-28 release-clock wording (SKILL.md:48 row, PROVINCE.md:54 bullet)

Scope: draft wording only. No production file touched; lane checkout read-only. All line cites are at BASE `3553d499577084a6c98d7078906017840bbf7b28` (extracted to `.ufo/waves/round-28/sandboxes/ScribeSkillRow/base`). Lane HEAD `bdf90f58` differs from BASE only by `plans/round-28.md` and `.ufo/waves/round-28/census-start.txt` (`git diff --stat` exit 0), so corpus cites are identical in both.

## Findings

1. **Self-count regexes preserved.** `corpus/self-counts.tsv:22` (SC-CLOCK-SELFTEST) and `:38` (PV-CLOCK-SELFTEST) match exactly one line each at BASE (`SKILL.md:48`, `PROVINCE.md:54`), captured `79`. Both drafts below keep the locator shape; re-run on the drafted documents: same single match, same capture. Simulated `91` in the count slot is captured as `91`. Every other SC/PV locator in the tsv gives identical match sets base vs draft. Matcher semantics: `corpus/self-counts.py:326-338` require exactly one matching line (else AMBIGUOUS) and capture group 1 as the claim.
   - Constraints the drafts obey: the decision row keeps 5 pipes (4 cells); PROVINCE line keeps exactly one `` `--selftest` proves N cases `` phrase; the new prose adds no second `--selftest` occurrence.
   - The count token must still be the live output of `python3 corpus/release-clock.py --selftest` (ledger `R25-03`, `corpus/claim-ledger.tsv:82`, expects `79 cases`). Adding selftest cases forces SKILL, PROVINCE and the R25-03 pin to move together.

2. **C1 gap confirmed at BASE (no canonical-token check).**
   - `corpus/release-clock.py:366` `NUMERIC_VERSION_RE = [0-9]+` and `:378` fullmatch accept leading zeros; `:380` calls `int()` with no bound.
   - `:582` compares tokens as strings (`norm_version(observed) != norm_version(anchored)`), so `3.15.01` vs anchor `3.15.1` counts as a fired release.
   - Counterexample CX1 (table lie, receipt forged to match): S040 `observed_version=3.15.01 verdict=fired` plus receipt `S040.parsed_version=3.15.01, verdict=fired`, run with `--receipt FILE --receipt-sha <sha>`: `RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=4 derived=15)`, exit 0. Control (same receipt path, unmodified table): `fired=3`, exit 0.
   - Counterexample CX2 (oversize): S040 `observed_version="3.15." + 4301×"1"`: exit 1 with Traceback, `ValueError: Exceeds the limit (4300 digits) for integer string conversion`, through `release-clock.py:567` → `:386` → `:380`. Interpreter here is Python 3.14.8, `sys.get_int_max_str_digits()`=4300.

3. **C2 gap confirmed at BASE (derived anchors not bound to the feed row).**
   - `corpus/release-clock.py:565-566`: `is_derived = note.startswith("derived:")`; `anchor_ok = is_derived or version_is_named(...)`. A `derived:` row skips every comparison with its `feed_source_id` registry row. `parse_sources` (`:88`) reads the registry anchor (`cells[5]`) but the derived path never consults it.
   - Derived rows: 15, at `corpus/release-clocks.tsv` lines 5–8 (S008–S011), 10 (S013), 11–13 (S014–S016), 18 (S021), 19–21 (S022–S024), 22–23 (S025–S026), 26 (S029).
   - Counterexample CX3 (plan's forgery, with receipt forged to match): G1 SOPS S008–S011 → 3.13.0; G2 Vault S013,S022–S024 → 2.1.0; G3 OpenBao S014–S016,S021,S025,S026 → 2.7.0; G4 curl S029 → 8.22.0; all `not-fired`, receipt `parsed_version` lowered to match. All four: `RELEASE_CLOCK: CLEAN (... observed=30 fired=3 derived=15)`, exit 0. Feed floors (`:390-410`) move with the group, so `:568` does not fire (equal to floor).

4. **Frozen-measure defects (reported, NOT redefined).**
   - D1 (C2 before-state). The frozen fixture set is "release-clocks.tsv edits only", but the pinned receipt binds the table: `receipt_matches` `:433-444` (verdict, observed_at, parsed_version), enforced at `:606-615`. Default command on the table-only G1–G4 at BASE: exit 1 with `RECEIPT-MISMATCH` on every group row, never CLEAN. So BASE `ACCEPTED` is 0/4, not the "k/4" implied by `plans/round-28.md:65-68`. The premise at `plans/round-28.md:48-50` holds only with an explicit forged receipt (`:467-471` accept `--receipt`/`--receipt-sha`), which the frozen set excludes.
   - D2 (C1 before-state). Frozen F1 under the default command at BASE: exit 1, `RECEIPT-MISMATCH S040`, no Traceback. The frozen predicate (`plans/round-28.md:38-41`) counts that as TYPED for the fixture's row, so BASE credits F1 to the receipt pin, not to a canonical-token check. The plan's "MISHANDLED k/4" cannot be reproduced by the frozen set alone.
   - D3. F3/F4 (`--observe` over a local feed copy) were not run. `--observe` fetches live; I did not fetch.
   - D4. "bounded" (`plans/round-28.md:22`) has no number. Interpreter default is 4300 here; relying on it makes the bound depend on the interpreter. L1 should pick an explicit constant and state it in the prose.
   - D5. `tools/` under `.ufo/waves/round-28/` is empty: `c1-measure.py` and `c2-measure.py` do not exist yet, so the frozen commands were not executable by me.

5. **Citation grounding gaps the wording depends on.**
   - "SemVer S042 §2" (`plans/round-28.md:22`): registry row `corpus/SOURCES.md:49` (S042) quotes §11.2 only. §2 (no leading zeros) needs a registry quote opened this round.
   - "Python integer-string conversion limit" (`plans/round-28.md:24-25`): no such row at BASE (grep of `corpus/SOURCES.md` for `int_max_str_digits` / `integer string conversion` / `4300`: no match). The C1 "sourced" clause is unmet until a row is opened.

6. **Typo fixed in draft.** `SKILL.md:48` "demoting on-release successors to90d" → "to 90d".

7. **Stamps.** `corpus/stamps.tsv:5` (SKILL.md) and `:2` (PROVINCE.md) pin sha256 and byte size. Any edit changes both; restamping is an L1 integration step. Not performed here.

8. **Other exit-code mentions not reviewed.** `SKILL.md:787` (table row "source release clocks") and `:791` (replay paragraph) name the code set; the drafts do not change them. If L1 adds codes, those need a check. Not checked in full.

## Draft wording

### SKILL.md:48 — three edits in the row, cells 1–2 untouched except none

Cell 3 (mistakes): replace
`a derived anchor without \`derived:\`; silently re-pinning fired clocks; demoting on-release successors to90d;`
with
`a derived anchor without \`derived:\`; a \`derived:\` anchor not equal to the version its feed registry row locates (\`DERIVATION-MISMATCH\`); a leading-zero or over-bound version token used as anchor, observation or feed entry (\`NONCANONICAL\`); silently re-pinning fired clocks; demoting on-release successors to 90d;`

Cell 4 (exit): replace `\`RECEIPT-MISMATCH\`/\`REGRESSED\` + \`FAILED\`;` with `\`RECEIPT-MISMATCH\`/\`REGRESSED\`/\`NONCANONICAL\`/\`DERIVATION-MISMATCH\` + \`FAILED\`;`

Cell 4 (append before the trailing pipe, after "...remains separate"):
`. Round 28: \`NONCANONICAL\` = a version token used as an anchor, table observation or feed entry with a leading zero in a multi-digit component (SemVer §2; registry row pending) or beyond the declared digit bound; \`DERIVATION-MISMATCH\` = a \`derived:\` row whose anchored version differs from the version its \`feed_source_id\` row (S033–S037) locates in corpus/SOURCES.md; both exit 1, neither is a release event or a traceback`

Full drafted row: `.ufo/waves/round-28/sandboxes/ScribeSkillRow/drafts/SKILL-row48.draft.md`

### PROVINCE.md:54 — insert after "...unorderable anchors are declared limits."

` Since round 28 a version token used as an anchor, table observation or feed entry must be canonical (no leading zero in a multi-digit component; within the declared digit bound) or it is \`NONCANONICAL\` (exit 1), never a release event or a traceback; a \`derived:\` row's anchored version must equal the version its \`feed_source_id\` row's located anchor names in corpus/SOURCES.md or it is \`DERIVATION-MISMATCH\` (exit 1).`

Full drafted line: `.ufo/waves/round-28/sandboxes/ScribeSkillRow/drafts/PROVINCE-line54.draft.md`

### Placeholders L1 must resolve before shipping
1. Digit-bound constant and its number (C1 "bounded"; D4).
2. Registry row IDs for SemVer §2 and the CPython int-limit documentation (Finding 5).
3. Selftest count N from the END run; SKILL row, PROVINCE line and ledger R25-03 pin move together (Finding 1).
4. Finding names `NONCANONICAL` and `DERIVATION-MISMATCH` are PROPOSED here. The frozen plan names no codes (only "typed finding, exit 1" and "typed derivation findings"). Implementation must emit exactly these strings or the wording must change.

## Commands run (exit codes)
- `git -C <lane> cat-file -t 3553d499…` → `commit`, exit 0.
- `git archive 3553d499… | tar -x -C …/base` → exit 0.
- `python3 -I -B corpus/release-clock.py --selftest` (BASE copy) → `RELEASE_CLOCK_SELFTEST: PASS (79 cases)`, exit 0.
- `python3 -I -B corpus/release-clock.py` (BASE copy) → `RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=3 derived=15)`, exit 0.
- Table-only fixtures, default command: F1 → `RECEIPT-MISMATCH S040`, exit 1; F2 → Traceback, exit 1; G1–G4 → `RECEIPT-MISMATCH` on group rows, exit 1.
- Forged-receipt runs (`--receipt`/`--receipt-sha`): control → CLEAN fired=3, exit 0; CX1 → CLEAN fired=4, exit 0; CX3 G1–G4 → CLEAN, exit 0.
- Python regex emulation of self-counts locators on BASE vs drafted SKILL/PROVINCE: one match each, capture 79; all other SC/PV locators unchanged; 91-simulation captures 91. Not the gate itself (lane gate forbidden for seats).
- `git -C <lane> diff --stat 3553d499… bdf90f58…` → exit 0: `plans/round-28.md`, `.ufo/waves/round-28/census-start.txt` only.
- `python3 --version` → 3.14.8; `sys.get_int_max_str_digits()` → 4300.
- Fixtures and receipts: `.ufo/waves/round-28/sandboxes/ScribeSkillRow/fx/`.

## Tooling
None installed or updated. Used existing `python3` 3.14.8 and `git`.

## Not checked
- `claim-ledger.sh verify|cells|docs` and `self-counts.py` gates (lane gates; seats must not run them in the lane). Regex emulation only.
- Live feed behaviour (no network). F3/F4 unrun.
- Whether C1/C2 implementation will emit the proposed finding codes (no implementation exists at BASE).
- `SKILL.md:245`, `:787`, `:791`, `PROVINCE.md` other bullets, and `corpus/README.md` for stale mentions of the exit-code list.
- Round-28 `SOURCES.md` curation (new S-rows) and the lesson file; not in my scope.
- Whether a `derived:` row's located anchor is unambiguous when the registry row contains more than one version-like token (e.g., S036-style titles). Only S033–S037 at BASE were inspected by eye.
