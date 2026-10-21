# Round-24 build — ScribeMistakes: `## Mistakes` candidates

Seat: KagiR24.ScribeMistakes-2 (leaf, no dispatch). Lane base 4f94b52. Measured 2026-10-21.
Target lesson `corpus/lessons/round-24.md` does not exist yet; these rows are candidates for its `## Mistakes` table.
Axes: C2 freshness (M24-1), C1 operability (M24-2), C1/D7 operability+process (M24-3).
Scratch only: `/fast/scratch/kagi-r24/seats/ScribeMistakes-2` (`head/` = clone at 4f94b52; `wt/` = head + copy of the working-tree `claim-ledger.sh`). `HOME=emptyhome`. No lane file edited; no real-tree `verify`/`cells`; no vault/account/host command.
Tools: none installed or updated (used existing curl, python3, git, bash, sha256sum).

## M24-1 — S008 filed as a non-reproducing in-row pin (count error) [C2 freshness/calibration]
- **class:** a reproducing legacy pin misclassified in summaries; the non-reproducing set is also under-counted.
- **evidence pointer:**
  - Fetched S008 (`curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)' …/getsops/sops/main/README.rst`, exit 0): 1909 B, `sha256sum` `63cb0a462ce23574…3440` = pin at `corpus/SOURCES.md:14`.
  - `python3 corpus/rendered-text-v1.py digest` → `raw_sha256=63cb0a46…3440 bytes=1909 normalized_sha256=4dd7e969…0d79 normalized_bytes=1448`. Normalizer `--selftest` → `PASS (cases=16)`, exit 0.
  - Committed lesson already says S008 reproduces: `corpus/lessons/round-23.md:115-116` (same text in e1884c6…5dd1411).
  - Misreadings: `corpus/lessons/round-23-verifier-spotcheck.md:146-147` ("the lesson names only S008 and S012–S016"); `:196` (D5 lists "S001–S004, S009–S011 are silent" as non-reproducing — S009–S011 reproduce raw, exit 0 today); `plans/round-24.md:48-50` ("non-reproducing in-row pins: 6 (S008, S012–S016; S008 actually reproduces raw)"); `.ufo/waves/round-23/parent-build/SourceS002.md:74` (cites `lessons/round-23.md:109-113` as listing S008 as unreproducible; no such text in any lesson revision).
  - Measured set today (13 pins fetched S001–S008, S012–S016 with the contract profile, all exit 0; S009–S011 fetched separately): raw match = S008, S009, S010, S011 (4). Non-reproducing = S001–S007, S012–S016 (12). Agrees with `.ufo/waves/round-23/falsify/RevPinDomain.md:297` (4/16 exact, 12/16 differ) and `CritLegacyBound.md:34-36`.
  - The lesson names 5 of the 12 (S012–S016); S001–S007 are silent. The plan's "6" is wrong in both directions.
  - S008 registry quote is not located under rendered-text-v1 (`locate` count=0); raw body is `` `getsops.io <https://getsops.io/>`_ `` (reST), consistent with the lesson's "reST-rendered" wording.
- **captured-by:** no gate. The falsify critic and RevPinDomain measured correctly; the spot-check and the frozen plan carried the misreading into committed text.
- **fix:** (a) round-24 lesson states a named correction: S008 reproduces raw; non-reproducing = 12 (S001–S007, S012–S016); S015 stays named historical debt. (b) The plan's frozen count gets a named correction line (D8 precedent), not a silent edit. (c) C2 `corpus/inrow-pins.tsv` classifies all 16 pins, and the census recomputes each class from its capture digest.
- **fail-first:** NOT SHOWN. `inrow-pins.tsv` and any classification check are absent at HEAD and in the working tree (`git status`). The wording fix cannot fail a test. Fail-first exists only after build: in a scratch copy set S008's class to non-reproducing; census must FAIL.

## M24-2 — guard comment promises `g\it` is refused; guard refuses only `\\` [C1 operability]
- **class:** policy-guard comment/code divergence (a refusal the comment claims is not implemented).
- **evidence pointer:**
  - HEAD `corpus/claim-ledger.sh:184`: `[[ $c == *'\\'* ]]` (two backslashes).
  - HEAD comments promise refusal: `:93-95` ("no backslash"), `:183` and `:186` (`g\it` "executed a stand-in" / "cannot walk past").
  - Scratch run at 4f94b52, rows file `rows.tsv`: `HOME=emptyhome bash corpus/claim-ledger.sh verify --claims <rows>`.
    - c2 `wc -l corpus/claim-ledger\.tsv` → not refused, OK.
    - c3 `wc -l corpus/g\it` (expect `No such file`) → not refused; ran, OK. Unquoted `g\it` is the word `git`.
    - c4 `wc -l corpus/g\\it` → `POLICY c4 reason=backslash`; `CLAIM_LEDGER: POLICY (claims=4 policy=1 …)` exit 2.
  - HEAD selftest has no single-backslash case (`grep -c claims-bs` = 0).
- **exploitability:** [INFERENCE] none under the current allowlist. First-token check runs on the raw word (`:173`, `ALLOWED_RE` at `:160`), so `g\it` cannot reach command position; it is argv only.
- **captured-by:** none at HEAD.
- **fix (working tree, uncommitted):** `corpus/claim-ledger.sh:260` `[[ $c == *\\* ]]`; selftest case `:1323` (`test -e corpus/a\b`).
- **fail-first:** SHOWN for the guard. Same c2/c3 rows that run at HEAD return `POLICY … reason=backslash` with the working-tree script (`wt/` run: `POLICY c2`, `POLICY c3`, `POLICY c4`; exit 2).
- **collateral (blocks landing as-is):** committed row R18-02 (`corpus/claim-ledger.tsv:49`, `grep -cE '\[substrate\]' …`) has one backslash. Working-tree script refuses it: `POLICY R18-02 reason=backslash` (scratch run, exit 2); HEAD runs it. The plan says R18-02 "is rewritten as a fixed-string count", but `git status` shows `corpus/claim-ledger.tsv` unmodified. The fixed-string form `grep -cF "[substrate]" …` passed policy in the same run. Land the guard only together with the R18-02 rewrite, and run a policy-only pass over every committed row before any guard change.

## M24-3 — wave evidence exported to git 49 min after the fleet report [C1/D7 process]
- **class:** evidence-ordering defect: report calls artifacts uncommitted; they were committed later.
- **evidence pointer:**
  - Reflog: HEAD `8a4ecbb` at 01:34:39 → `46fac5a` at 02:24:03 ("export from jj").
  - Fleet report `/home/vgpnk/Projects/shokunin/.ufo/reports/round-23/kagi.md`, mtime 01:34:58.097; lines 115-116: "other parent-built reports remain parent-owned and uncommitted by this lane".
  - `git ls-tree -r --name-only 8a4ecbb -- .ufo/waves/round-23/parent-build` → 1 path; at `46fac5a` → 67. Falsify: 2 → 65. `46fac5a` adds 66 parent-build and 63 falsify paths (`git log --diff-filter=A`).
  - Spot-check `corpus/lessons/round-23-verifier-spotcheck.md:29-32` and D7 at `:201-202` match. Its "driver `complete` at 02:22:20" was not checked here.
  - Nuance: `46fac5a`'s author date is 01:34:39, 19 s before the report. The git-visible landing is the 02:24:03 export. The "uncommitted" sentence was true of git master at 01:34:58; the defect is the 49-minute lag and an unsynced sentence.
  - Label collision: `corpus/lessons/round-23.md:111` D7 is source provenance; the wave-commit item is the spot-check D7 and `plans/round-24.md` D7. The round-24 lesson must use distinct labels.
- **captured-by:** the round-23 verifier spot-check (`:29-32`, `:201`). No gate.
- **fix:** a gate that every `.ufo/waves/<round>/**` path cited by a fleet report is tracked at the report's commit. Live now: `.ufo/waves/round-24/` is untracked (`git status` `??`) and holds the build reports (`build/`: ScribeRegistry.md, ScribeCorrections.md and others). The same defect recurs unless it is committed before the round-24 fleet report.
- **fail-first:** PARTIAL. The tracked-count test shown above FAILs at `8a4ecbb` (1 of 67) and PASSes at `46fac5a` (67) on the input state. No committed gate exists to fail first.

## Checked and not candidates
- Normalizer reproduces S008 raw (`63cb0a46…`) and S009–S011 raw (all exit 0). Selftest 16 cases PASS.
- Same URL as S020 correction row (`1password.com/blog/1password-credential-broker-public-preview`, S006 here): 190,261 B, normalized `20b4fd86dada…`, matching the lesson's S020 normalized `20b4fd86…`.

## Lane state observed (not caused by this seat)
- Working tree changed during the run: `corpus/claim-ledger.sh` and `corpus/sources-census.sh` modified; `corpus/row-identity.sh` and `corpus/rendered-text-v1.py` untracked; `corpus/__pycache__/` appeared. This seat ran no python or bash inside the lane.
- Exit codes: curl S008/S001–S016 all 0; `digest` 0; normalizer `--selftest` 0; HEAD scratch verify with c2–c4 exit 2 (POLICY c4); WT scratch verify exit 2 (POLICY c2/c3/c4); R18-02 HEAD scratch run `failed=0` (exit 1 only from unresolved IDs in a partial claims file, not policy); R18-02 WT scratch run exit 2 (POLICY R18-02).
