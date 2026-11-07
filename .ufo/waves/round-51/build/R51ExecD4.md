# R51ExecD4 — Round-50 closure D4: the non-row finding behind `verify_rc=1`

## Finding (one paragraph)

The `verify_rc=1` in `.ufo/waves/round-50/final/c2-final.txt` is **not** a frozen-row
failure, stamp drift, or policy refusal: on the counter's own subset mechanism
(`corpus/claim-ledger.sh verify --root <clone> --claims <10-row sub.tsv> --stamps
<clone>/corpus/stamps.tsv`, cloned at `d4994e3d15c03e62132a784d708bd56e00fa9d0d`
and at BASE `214d8bf530a0c87c00686493f21af15396284793`, exit code 1 in both) the
final line is `CLAIM_LEDGER: FAIL (claims=10 failed=0 deferred=0 stamped=124
stale=0 missing=0 unresolved_ids=1112 labeled_ids=121 host_skipped=0)` with **zero**
`FAIL`/POLICY/LAYOUT-INCOMPLETE lines for any of the ten frozen ids (so `C2_LEDGER_DRIFT:
value=0`), **zero** `STALE` and **zero** `MISSING` stamp lines — the sole nonzero
contributor is `IDX_MISSING=1112`: the `idref_audit` sub-check scans the **full**
default doc set (`AGENTS.md`, `LOG.md`, `PROVINCE.md`, `SCORECARD.md`, `SHONEN.md`,
`SKILL.md`, `corpus/README.md`, `corpus/knowledge/*.md`, `corpus/lessons/*.md`,
`claim-ledger.sh:766-767` via `default_docs()` at `:759-769`) for `R<digits>-<digits>`
tokens against only the **subset** ledger (the ten rows), so every historical id
cited anywhere in those docs — e.g. the echoed tail — is reported as `MISSING-ID
LOG.md:285 R11-03`, `MISSING-ID corpus/lessons/round-9-aggregator-corpus-verdict.md:11
R11-08`, etc. — and `corpus/claim-ledger.sh:1221-1224` (`if [[ $C_FAILED -gt 0 ||
$V_STALE -gt 0 || $V_MISSING -gt 0 || $IDX_MISSING -gt 0 ]]; then printf 'CLAIM_LEDGER:
FAIL …'; exit 1; fi`) turns any `IDX_MISSING > 0` into exit 1. (At BASE the same run
gives `unresolved_ids=1133`, rc 1, so the artifact is structural to the counter's
subset mechanism, not a round-50 regression; the counter correctly ignores it and
reports `value=0` precisely because its per-id check at `plans/round-50-c2.sh:122-127`
only greps `^(FAIL|POLICY|LAYOUT-INCOMPLETE) <id>` and `MISSING-ID` lines never match.)

## Reproduction (clone of BASE path, scratch `HYAKU_SCRATCH=/fast/scratch/hyaku`)

```bash
S=/fast/scratch/hyaku/kagi-r51/R51ExecD4; D=$(mktemp -d "$S/fx.XXXXXX")
LANE=/home/vgpnk/Projects/shokunin/kagi-shokunin
git clone -q --shared --no-checkout "$LANE" "$D"
[ "$(git -C "$D" rev-parse --show-toplevel)" = "$D" ]
git -C "$D" checkout -q --detach d4994e3d15c03e62132a784d708bd56e00fa9d0d
IDS="R13-01 R21-02 R22-03 R24-05 R24-06 R24-15 R31-02 R33-02 R34-03 R38-01"
: > "$D/sub.tsv"; L="$D/corpus/claim-ledger.tsv"
for id in $IDS; do grep -P "^\Q$id\E\t" "$L" >> "$D/sub.tsv"; done
(cd "$D" && timeout 900 bash corpus/claim-ledger.sh verify --root "$D" \
  --claims "$D/sub.tsv" --stamps "$D/corpus/stamps.tsv") > "$D/out.txt" 2>&1
echo "VERIFY_RC=$?"; tail -3 "$D/out.txt"; grep -c '^MISSING-ID' "$D/out.txt"
```

## Retained evidence (exact commands, exit codes, last lines)

Recorded on a scratch clone under `/fast/scratch/hyaku/kagi-r51/R51ExecD4/`
(trap-cleaned work trees; `verify-out.txt` / `verify-out-base.txt` copied out
before cleanup; `/tmp/run3-result.log`, `/tmp/runbase.log` hold the transcripts):

| run | command (working dir = clone) | exit | final line (verbatim tail) |
|---|---|---|---|
| round-50 measured rev `d4994e3d15c03e62132a784d708bd56e00fa9d0d` | `(cd clone && timeout 900 bash corpus/claim-ledger.sh verify --root clone --claims sub.tsv --stamps corpus/stamps.tsv)` | `VERIFY_RC=1` | `CLAIM_LEDGER: FAIL (claims=10 failed=0 deferred=0 stamped=124 stale=0 missing=0 unresolved_ids=1112 labeled_ids=121 host_skipped=0)` |
| BASE `214d8bf530a0c87c00686493f21af15396284793` | same | `BASE_VERIFY_RC=1` | `CLAIM_LEDGER: FAIL (claims=10 failed=0 deferred=0 stamped=124 stale=0 missing=0 unresolved_ids=1133 labeled_ids=121 host_skipped=0)` |

Output counts (measured rev): `MISSING-ID` lines = 1112; `^FAIL ` = 0;
`^STALE` = 0; `^MISSING ` (stamp) = 0; no `POLICY`/`LAYOUT-INCOMPLETE` line for
any frozen id. Head `MISSING-ID`s: `LOG.md:285 R11-03`, `LOG.md:285 R11-10`,
`LOG.md:285 R11-11`, `LOG.md:322 R12-01`, `LOG.md:384 R11-09`, … (all historical
ids absent from the 10-row subset, as expected). Tail `MISSING-ID`s:
`corpus/lessons/round-9-aggregator-corpus-verdict.md:11 R11-08` (precedes the
final `CLAIM_LEDGER:` line).

## Code path

- `corpus/claim-ledger.sh:759-769` (`default_docs`): full default doc set used
  when `--docs` is not passed (the round-50 counter passes no `--docs`).
- `corpus/claim-ledger.sh:894-920` (`idref_audit`, esp. `:903-919`): scans every
  `R[0-9]+-[0-9]+` token in that doc set; unresolved (not in `LID` from the
  **subset** `--claims` file via `load_ids` at `:856-867`) and unlabelled →
  `printf 'MISSING-ID %s:%s %s\n'` (`:915`), `IDX_MISSING++` (`:916`).
- `corpus/claim-ledger.sh:1213-1225` (verify verdict): `verify_stamps` →
  `verify_claims` → `idref_audit`, then `if [[ $C_FAILED -gt 0 || $V_STALE -gt 0
  || $V_MISSING -gt 0 || $IDX_MISSING -gt 0 ]]` (`:1221`) prints `CLAIM_LEDGER:
  FAIL … unresolved_ids=$IDX_MISSING …` and **`exit 1`** (`:1222-1224`).
- Counter-side: `plans/round-50-c2.sh:116-128` runs that verify, records
  `verify_rc=$rc`, computes `value` only from `FAIL|POLICY|LAYOUT-INCOMPLETE <id>`
  lines (`:122-127`) — hence `value=0 … verify_rc=1` co-occurrence in
  `c2-final.txt:2-3` is the expected fingerprint of this class.

## Risks / blockers / note

- No blocker; no lane file was edited (read-only; clone created in scratch,
  `rev-parse --show-toplevel` asserted before checkout).
- Risk acknowledged: any subset-verify run without `--docs` (or a fixture doc set)
  will always exit 1 while the default docs cite any id outside the subset — a
  counter-design footgun, not a ledger defect. Fixing it would be a counter
  invocation change (out of this seat's scope to make).
- No OpenBao server, token, or 1Password/vault access was used; no tooling install
  was needed (system `bash`/`grep`/`git` only); `pacman` never run;
  `~/.local/bin/bao` untouched.
- Full `claim-ledger.sh verify` on the real tree was never run (per instructions).

SEAT-STATUS: complete
