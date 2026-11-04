# Round 34 — plan and frozen claims

Lane `kagi-shokunin` (secrets & vault ops). Round 34, attempt 1.
Frozen BASE `f9dc06fd8f6b43c175193c76dc6350468f551634` (lane `master` tip = the
round-33 verifier spot-check commit). Frozen 2026-11-04, committed ALONE with
`plans/round-34.controls.tsv` and the START receipts under
`.ufo/waves/round-34/controls/` (QM29).

## Inputs (measured at freeze, not estimated)

- Round 33 closed with **C2 not admitted** and **seven routed defects (R33-1..R33-7)**
  for this lane to close (`corpus/lessons/round-33-verifier-spotcheck.md` §6). Five of
  them (R33-1, R33-2, R33-3, R33-4, R33-5) are self-description defects: the lane's
  documents said something its bytes did not do.
- `git status --porcelain` at BASE: empty. No inherited uncommitted round work.
- Registry census at BASE: `SOURCES_CENSUS: CLEAN (rows=82 A=79 B=1 C=2 queued=1
  mined=78 rejected=3 entries_sourced=12 legacy=22 captures=82 inrow=16 inrow_only=0
  inrow_nonreproducing=12)` exit 0
  (`.ufo/waves/round-34/controls/census-start.txt`); fleet census exit 0
  (`fleet-census-start.txt`).
- Every axis stands at 9 (saturation line 9, stagnation window N=3). A capability
  entered in round 33, so the stagnation-nudge waiver is **not** claimed; the round
  works three axes that are tied at the lowest score.
- The SD6 residual is named and **excluded** from C1's target at freeze: three
  `UNRESOLVED` lines the citations gate prints against integrator-owned files
  (`corpus/lessons/round-30-verifier-spotcheck.md:41`,
  `corpus/lessons/round-32-verifier-spotcheck.md:54`,
  `corpus/lessons/round-33-verifier-spotcheck.md:90`). This lane cannot edit those
  files; a target that counted them would be unreachable by construction (M33-2).

## C1 — calibration — the self-description sweep covers the classes round 33 missed

Round 33's own spot-check found five defects the lane's instrument did not see: a
shipped gate absent from the gate registry (R33-1), a doc claiming a test count the
script contradicts (R33-5), a doc claiming a lesson-row range the lesson contradicts
(R33-5), and a knowledge entry admitted without the provenance trio the corpus
contract requires (R33-4). C1 extends `corpus/self-description-sweep.sh` with three
checks over those classes.

**Predicate (frozen, one sentence):** `SD789_SUM=0` at the landing revision, where
`SD789_SUM` is the sum of the SD7+SD8+SD9 components of the sweep's verdict line.

- **SD7 — gate-registry coverage.** For each top-level `corpus/*.sh` and
  `corpus/*.py` whose bytes mention `--selftest`, its basename must appear at least
  once in `SKILL.md`. Count = scripts not named.
- **SD8 — lesson-row range claims.** For each `M<r>-<n>..M<r>-<m>` token in
  `SKILL.md`, `PROVINCE.md`, `SCORECARD.md` or `corpus/README.md`, the lesson
  `corpus/lessons/round-<r>.md` must exist, must carry a row `| M<r>-<m> `, and must
  carry no row `| M<r>-<k> ` with `k > m`. Count = violations.
- **SD9 — admitted-entry provenance.** A `corpus/knowledge/*.md` entry whose
  `Reverify:` line names an `R<r>-<n>` with `r >= 30` must carry `^source:`,
  `^verified-at:` and `^recheck:`. Count = entries violating.

**Counting command** (the claim's counter; last line carries the integer):

    bash corpus/self-description-sweep.sh | awk -F'[ =()]' \
      '{for(i=1;i<NF;i++) if($i ~ /^SD[789]$/) s+=$(i+1)} END{print s+0}'

**BASE → target:** 5 → 0 (BASE components: SD7=3 SD8=1 SD9=1; measured at freeze by
`.ufo/waves/round-34/controls/sd789-base.sh` through the pre-freeze gate).

**Second reading:** `bash corpus/self-description-sweep.sh --selftest` — 7 → 10 cases
(one planted-mismatch fixture per new check).

**Kill rule:** `SD789_SUM > 0` at the landing revision → C1 not admitted, reported
honestly; the number is never re-scoped after data.

**Named exclusions.** SD1–SD6 keep their round-32 contract unchanged. The SD6
residual (above) is outside the target: the sweep still exits 1 while those three
lines persist, and the round reports that exit as it measures it.

## C2 — operability — the pre-freeze gate's two unbacked claims become executed ones

Round 33 asserted two closures it never executed: "the rebuilt mutant now fails
`--selftest`" (R33-2) and "a relative `--work` … re-tested" (R33-3). This round
executes both against the shipped bytes and adds the missing selftest case.

**Predicate (frozen):** `PREFREEZE_SELFTEST: PASS (12 cases)` with the shipped bytes,
and a committed M7 receipt whose output names `base-isolation` as the failing case.

**Counting commands:**

    bash corpus/prefreeze-control.sh --selftest | tail -1
    grep -c 'CASE base-isolation FAIL' .ufo/waves/round-34/mut/m7-shipped.txt

**BASE → target:** `PASS (11 cases)` → `PASS (12 cases)`; `0` → `1` receipt line.

**Kill rule:** either reading unmet at the landing revision → C2 not admitted.

## C3 — coverage — access-key custody enters as one entry and five registry rows

One theme from `/home/vgpnk/Projects/shokuknow/merge/kagi/` (§10 assimilation):
**Alibaba Cloud RAM AccessKey custody** — issue, rotate, disable, expire, delete, and
the KMS-managed variant. New ground: the lane holds 1Password, SOPS/age,
Vault/OpenBao and NIST key-management status, but no cloud-IAM access-key lifecycle.
The staged entry is re-grounded in-round (every cited source re-opened, my access date
and located quote in the lesson's `## Gate`); the staged ids S140–S143/S145 are
re-pointed **by document** to the lane's next registry ids S083–S087.

**Predicate (frozen):** the entry exists, the registry carries five more rows, and the
census is CLEAN at the new counts.

**Counting commands:**

    ls corpus/knowledge/aliyun-accesskey-credential-custody.md | wc -l
    grep -cE '^\|[[:space:]]*S[0-9]{3,}[[:space:]]*\|' corpus/SOURCES.md
    bash corpus/sources-census.sh

**BASE → target:** entry 0 → 1; rows 82 → 87; census `entries_sourced=12 legacy=22
captures=82` → `entries_sourced=13 legacy=21 captures=87`, exit 0.

**Kill rule:** any reading unmet → C3 not admitted; rows adopted are never
bulk-appended (only rows the admitted entry cites).

**Sourced claim:** C3's evidence is the five rows opened this round (S083–S087), and
the entry's `source:` line names them.

## Round shape

One v1 wave `kagi-r34-build` under
`/home/vgpnk/Projects/shokunin/scripts/hyaku/ufo-wave-policy.json` (band 8–16, L2 floor
8), 14 seats; attack seats ≥25 %. The L1 holds the canonical planner seat (the
validator's `SWARM_ROLES` has no `planner`; R32-1). Seats are leaves; no seat commits,
pushes, or touches a sibling lane; every seat writes only the paths its item names.

## Do-nothing control

Scored with the frozen counters at BASE: SD789_SUM=5, prefreeze cases=11, M7 receipt
absent, entry absent, rows=82. A round that skipped the work reaches none of the three
targets, so none is satisfiable by inaction.

## Frontier step

- `corpus/SOURCES.md` curated: five rows added (S083–S087), all opened this round with
  URL, access date and a located ≤25-word quote in `corpus/lessons/round-34.md` `## Gate`.
- Census before → after recorded with the lane counter and the fleet census.
- One mistake mined into `corpus/lessons/round-34.md` `## Mistakes` (the round-33
  defect already gives the candidate: a doc count asserted without the byte behind it).
- `considerthese/` mined at most one still-unimplemented proposal, or the reason none
  fits recorded.

## Bounds

- No operator decision is needed; no L0 question is filed.
- pacman stays paused host-wide; no install is planned. Any install would go through
  `uv tool`/`npx`/an official binary with the guard recorded.
- The new checks read committed bytes only: no network, no host surface, no vault.
- Scratch lives under `$HYAKU_SCRATCH/kagi-r34/<seat>/`; nothing citable lives in
  `/tmp`.
