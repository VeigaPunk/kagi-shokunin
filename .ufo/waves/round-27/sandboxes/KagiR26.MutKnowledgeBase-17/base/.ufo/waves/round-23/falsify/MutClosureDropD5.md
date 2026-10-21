# MutClosureDropD5 — closure-dispositions mutation probe (round 23)

Falsification seat for C1 only. Lane was read-only: every mutation ran on a byte copy at
`/tmp/kagi-r23-mut-closure-d5`; the only lane write is this report. No installs, no network,
no host-bound gates, no git/jj operations.

## Attacked artifact (snapshot)

| file | pristine sha256 |
|---|---|
| `corpus/closure-dispositions.py` | `6cc822785d2b93c6061b9cc738398bef533391cbe7d4cf36aa2567bb358bddd4` |
| `corpus/closure-dispositions.json` | `f20f00d1be8d50984953eb21c377a333912e9c1ca346e4637850586f04cc0d59` |
| `corpus/lessons/round-22-verifier-spotcheck.md` (pinned source) | `65a5b3dee667146c47c158d344dad7c2a9307d6997a0a9800d92b7dbb55869f7` |
| `corpus/lessons/round-23.md` (D5 fix pointer target) | `d55209887c13825cdf4b0a423aed080830d0ffaaefbb980ce01d49cb9642c773` |

Scratch setup (cwd `/home/vgpnk/Projects/shokunin/kagi-shokunin`):

```
rm -rf /tmp/kagi-r23-mut-closure-d5 && mkdir -p /tmp/kagi-r23-mut-closure-d5/corpus/lessons \
  /tmp/kagi-r23-mut-closure-d5/corpus/knowledge
cp corpus/closure-dispositions.py corpus/closure-dispositions.json corpus/SOURCES.md \
  corpus/source-fetches.tsv corpus/claim-ledger.tsv /tmp/kagi-r23-mut-closure-d5/corpus/
cp corpus/lessons/round-22-verifier-spotcheck.md corpus/lessons/round-23.md \
  /tmp/kagi-r23-mut-closure-d5/corpus/lessons/
cp corpus/knowledge/feature-bound-credential-review.md \
  corpus/knowledge/vault-openbao-token-lease-lifecycle.md \
  /tmp/kagi-r23-mut-closure-d5/corpus/knowledge/
```

The pinned source and every pointer target were copied so the baseline is a real run, not a
reduced fixture. Copy hashes equal the lane hashes above.

## Baseline (pristine bytes, scratch)

```
cd /tmp/kagi-r23-mut-closure-d5
python3 corpus/closure-dispositions.py            -> exit 0
  CLOSURE_DISPOSITIONS: CLEAN (obligations=15 fixed=7 reported=2 operator_owned=1 no_action=5 rejected=0 pointers=15)
python3 corpus/closure-dispositions.py --selftest -> exit 0
  CLOSURE_DISPOSITIONS_SELFTEST: PASS (13 cases)
```

The lane itself, same bytes at snapshot time:

```
cd /home/vgpnk/Projects/shokunin/kagi-shokunin
python3 corpus/closure-dispositions.py            -> exit 0
  CLOSURE_DISPOSITIONS: CLEAN (obligations=15 fixed=7 reported=2 operator_owned=1 no_action=5 rejected=0 pointers=15)
```

Baseline PASS. The 15 obligations are D1–D9 (`round-22-verifier-spotcheck.md:165-184`), SPOT-01–05
(table rows `:103-107`), and ADJ (`:157`). All 13 selftest cases printed `ok`
(case table `closure-dispositions.py:290-302`, PASS at `:353`).

## Mutant 1 — D5 disposition dropped (assigned)

Removed the JSON object `{"id": "D5", ...}` (pristine `closure-dispositions.json:76-82`) from the
scratch copy; remaining rows = 14. Mutated sha256:
`a038750906188de923cd40eb3e1eb9179c582b667c1e55bf157497d4a714eb91`.

```
cd /tmp/kagi-r23-mut-closure-d5
python3 corpus/closure-dispositions.py            -> exit 1
  DISPOSITION MISSING D5
  CLOSURE_DISPOSITIONS: FAILED (obligations=15 dispositions=14 missing=1 unknown=0 unresolved=0)
```

Verdict: **KILLED**. Detector matches the expected `exit 1 MISSING D5`; missing is computed at
`closure-dispositions.py:194` and printed at `:197`.

## Mutant 2 — D5 obligation class swapped (assigned)

Restored the pristine JSON (hash re-verified), then changed D5's `class` from `routed-defect` to
`spot-decision` (pristine `closure-dispositions.json:78`). Mutated sha256:
`1e81b1b2d165b11bc495c2c98892b773b975de96967d44dd42a9d028f79ca570`.

```
cd /tmp/kagi-r23-mut-closure-d5
python3 corpus/closure-dispositions.py            -> exit 2
  CLOSURE_DISPOSITIONS: SETUP (class mismatch for D5: 'spot-decision' != 'routed-defect')
```

Verdict: **KILLED**. Matches expected exit 2; check at `closure-dispositions.py:172-173`.

## Bound probe — coordinated source + pin edit (not an assigned mutant)

In scratch only: deleted the D5 bullet from the pinned closure
(`round-22-verifier-spotcheck.md:175-176`), recomputed its digest
`359f8ad374be6532501f99fcfa5d96cd26253c7d1e492a44dd3a868669989fe9`, rewrote
`source_sha256` (`closure-dispositions.json:4`) and dropped the D5 row (mutated JSON sha256
`3c26d6d6584469a0dfd50eaf3fa24be9bf7327d58310e1d11bebacdf619b2dd8`).

```
cd /tmp/kagi-r23-mut-closure-d5
python3 corpus/closure-dispositions.py            -> exit 0
  CLOSURE_DISPOSITIONS: CLEAN (obligations=14 fixed=6 reported=2 operator_owned=1 no_action=5 rejected=0 pointers=14)
```

Verdict: **SURVIVED by design** — a coverage/bound finding, not a contract change. The only
anti-tamper anchor (`source_sha256`, checked at `closure-dispositions.py:148-149`) is stored inside
the same lane-writable JSON as the rows. The gate proves the row set is internally consistent with
the pinned bytes; it cannot prove an obligation was never removed. Removing an obligation is
invisible to the gate when source, pin and row change together. Detection of that case rests on
review of the commit/diff, so C1 must state the pin's trust root is the review, not the gate.

## Additional bounds C1 must state

1. `fixed` pointer resolution is presence-only: file exists, anchor substring appears on some
   `#` line, and the id token appears anywhere in the file (`closure-dispositions.py:113-120`).
   It does not prove the pointed text is the fix or that the note is true (docstring bounds,
   `closure-dispositions.py:41-44`). For D5 the pointer resolves because `D5` appears at
   `round-23.md:97` under the anchor heading `## Routed defect dispositions` at `:64`; the cited
   lines `:97-99` do state "130 spawn IDs under 129 names" and the `CriticNoTrade` `-2` reuse, but
   that agreement is my read, not a gate assertion.
2. Obligations are keyed by id, so repeated `- D<N>` bullets collapse to one obligation
   (`closure-dispositions.py:78,90`), and only spot rows whose decision cell is exactly `admit` or
   `reject` become obligations (`:95-97`). A sixth spot row with any other decision cell would be
   silently outside the count. The actual document has exactly 5 admit/reject rows and 9 routed
   bullets, so the current `obligations=15` is correct; the claim should still scope itself to the
   parser's admission rule.

## Restoration evidence

Scratch was restored from lane bytes after each mutant, and the post-restore gate re-run:

```
cp <lane>/corpus/closure-dispositions.json corpus/closure-dispositions.json
cp <lane>/corpus/lessons/round-22-verifier-spotcheck.md corpus/lessons/round-22-verifier-spotcheck.md
sha256sum corpus/closure-dispositions.json -> f20f00d1be8d50984953eb21c377a333912e9c1ca346e4637850586f04cc0d59
sha256sum corpus/lessons/round-22-verifier-spotcheck.md -> 65a5b3dee667146c47c158d344dad7c2a9307d6997a0a9800d92b7dbb55869f7
python3 corpus/closure-dispositions.py -> exit 0
  CLOSURE_DISPOSITIONS: CLEAN (obligations=15 fixed=7 reported=2 operator_owned=1 no_action=5 rejected=0 pointers=15)
```

Lane hashes after all probes still equal the pristine table above (re-checked with `sha256sum`);
no lane file other than this report was written.

## Result against C1

Confirmation, no detector defect under the assigned mutants: pristine `obligations=15` each with
one typed disposition (`fixed=7 reported=2 operator_owned=1 no_action=5 rejected=0`, `pointers=15`),
selftest `PASS (13 cases)`, D5 drop dies `exit 1 MISSING D5`, D5 class swap dies `exit 2`. C1 must
carry the two bounds above, chiefly that the digest pin is self-referential (demonstrated
`exit 0 obligations=14` after a coordinated source+pin+row edit).
