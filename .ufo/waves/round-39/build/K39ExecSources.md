# K39ExecSources — round 39 build wave (freshness + calibration reproduction, S094 reopen, sources census)

Seat: K39ExecSources (executor). Candidate `6742fdef0e261dd06a38a0fb0b66b1bc027d1bee` (= lane HEAD, worktree clean apart from untracked `.ufo/waves/round-39/` runtime files). BASE `06144518d3b3745e7fdf82d4207b4a3b5532a7a7`; predeclaration `1909e3876341cc90246516886def37a7c9ea92f9`; frozen plan `7c11e769cd7c2450cf46faabcd3b43fca993f388`. All git calls read-only (`archive`, `cat-file`, `log`, `show`, `diff`, `status`, `rev-parse`); no commits, no fixture mutation. Candidate extracted once via `git archive` into scratch; scratch deleted after receipt preservation.

## C1 freshness — anchor-pin gate, 0 → 3: REPRODUCED

- `bash <candidate>/plans/round-39-c1.sh` → `3` (target 3; receipt `c1-counter.out`).
- `bash <candidate>/corpus/anchor-pins.sh --root <candidate>` → `ANCHOR_PINS: CLEAN (pins=3)`, exit 0 (receipt `c1-gate.out`).
- Pins (`anchor-pins.tsv`, receipt copy): S034 `5e10a867bd3954bd1d771d4f1efc96197edd8dceee66f43933095db96d443811`, S035 `0ddd47c09377c066d75f6912e643246e742853c9746d73953e7482551683d33a`, S039 `772e58b25951bca52d8e5ac195906a8b7411be224bb8f02634cf71167fef4230` — match the plan's committed digests.
- Frozen predicate sentence verified verbatim in `corpus/anchor-pins.sh` header (receipt `predicates.txt`).

## C2 calibration — declared-axis gate, 0 → 3: REPRODUCED

- `bash <candidate>/plans/round-39-c2.sh` → `3` (target 3; receipt `c2-counter.out`).
- `bash corpus/claims-declared.sh --root .` at candidate → `CLAIMS_DECLARED: CLEAN (claims=2)`, exit 0 (receipt `c2-gate.out`).
- Frozen predicate sentence verified verbatim in `corpus/claims-declared.sh` header (receipt `predicates.txt`).

## Frozen controls (predeclaration 1909e38): REPRODUCED CLEAN 4/4

`corpus/prefreeze-control.sh run --base 1909e38… --controls plans/round-39.controls.tsv` (PREFREEZE_REPO=lane, scratch work dir) → `c1_nowork 0`, `c1_positive_three 3`, `c2_nowork 0`, `c2_positive_three 3`, `PREFREEZE: CLEAN (controls=4 mismatch=0)`, exit 0 — exactly the plan's frozen rows (receipt `prefreeze-controls.out`). Instrument drift predeclaration→candidate: empty diffstat over `plans/round-39-c1.sh`, `plans/round-39-c2.sh`, `plans/round-39.controls.tsv`, `corpus/anchor-pins.sh`, `corpus/anchor-pins.tsv`, `corpus/claims-declared.sh`, `corpus/claims-declared.tsv` (receipt `instrument-drift.diffstat`) — instruments frozen as declared.

## S094 reopen (non-author verification): PASSES, no domain drift

- Row: S094, own-work, tier A, mined, anchor cell (col 6) `SOURCES.md Rules item 2, line 116, revision f47ad6ba8d306f8125597401cb2ce45c1297a593`, used-by `corpus/lessons/round-39.md`.
- Reopen: `curl -fsSL https://raw.githubusercontent.com/VeigaPunk/shokunin/f47ad6ba8d306f8125597401cb2ce45c1297a593/CORPUS.md` → HTTP 200, 11296 bytes, sha256 `88556402940e7a0f1dbbed3abef9e00c87a90db6f80eaed03269e371f50050b8` (receipts `s094-curl-meta.txt`, `s094-bytes.txt`, `s094-sha256.txt`, full capture `s094-capture-f47ad6ba.md`).
- Byte comparison: identical sha256 from `git -C /home/vgpnk/Projects/shokunin show f47ad6ba…:CORPUS.md` (fleet repo, origin `https://github.com/VeigaPunk/shokunin.git`, commit present locally) — captured bytes == local pinned blob.
- Located quote: line 116 of the capture reads `2. **Append-only.** Only \`status\`, \`recheck\` and \`used-by\` change in place, and each change` — the row's located quote ("Only `status`, `recheck` and `used-by` change in place", 9 words) sits exactly at the claimed line 116, rule item 2 (receipt `s094-lines110-120.txt`). The rule the C1 claim rests on is reproduced unchanged at the pinned revision today.

## Sources census

- Fleet: `scripts/sources-census.sh validate --root /home/vgpnk/Projects/shokunin kagi` → exit 0, final line `kagi ok /home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/SOURCES.md`, 19×W04 duplicate-URL warnings (warning class; does not fail validate) (receipt `census-fleet-validate.out`).
- Lane (candidate extraction): `SOURCES_CENSUS: CLEAN (rows=94 A=90 B=2 C=2 queued=1 mined=90 rejected=3 entries_sourced=14 legacy=21 captures=94 inrow=16 inrow_only=0 inrow_nonreproducing=12)` exit 0 (receipt `census-lane-candidate.out`). Matches the plan's census-after expectation: rows 93→94 with S094 added; `entries_sourced` unchanged at 14; A 89→90, mined 89→90, captures 93→94 (S094 fetch capture present and passing SC_FETCH); inrow=16 and inrow_nonreproducing=12 unchanged from BASE.

## Defects / surviving observations

- No new defect found in this slice; no falsification of C1 or C2. Every frozen reading (counters 3/3, gates CLEAN, controls 4/4) reproduced at the candidate.
- W04 duplicate-URL warnings (19) persist at fleet validate — expected class per plan START census, warnings only.
- `inrow_nonreproducing=12` persists — historical attested state carried unchanged from BASE, not a round-39 regression.
- Lane worktree has untracked `.ufo/waves/round-39/` wave-runtime files (dispatch/build-run/spec/ready); outside census and gate inputs, no effect on any reading.

## Receipts

`.ufo/waves/round-39/build/K39ExecSources/`: `c1-counter.out`, `c2-counter.out`, `c1-gate.out`, `c2-gate.out`, `prefreeze-controls.out`, `instrument-drift.diffstat`, `predicates.txt`, `anchor-pins.tsv`, `census-fleet-validate.out`, `census-lane-candidate.out`, `s094-curl-meta.txt`, `s094-bytes.txt`, `s094-sha256.txt`, `s094-lines110-120.txt`, `s094-capture-f47ad6ba.md`.

No tool installs this seat. Scratch `/fast/scratch/hyaku/kagi-r39/K39ExecSources/` deleted after receipt preservation.
