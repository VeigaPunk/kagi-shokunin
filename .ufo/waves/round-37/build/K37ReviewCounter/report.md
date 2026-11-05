# K37ReviewCounter — adversarial review of the frozen counter `plans/round-37-c2.sh`

Seat: K37ReviewCounter, kagi round-37 build wave, 2026-11-05.
Scope: the counter as an instrument. The counter, receipt, and controls were not edited; every attack ran on a
separate `git archive 9efcea7` extraction under `/fast/scratch/hyaku/kagi-r37/K37ReviewCounter/<state>/`
(BASE 911ab51 extractions used for some probes, receipt+counter copied in where the BASE tree predates them).

## Baseline

```
$(cd base && bash plans/round-37-c2.sh)      → "0", rc=0      (candidate tree at 9efcea7)
$(cd base && sha256sum .ufo/…/observe-r37.json) → cb96cfb2…c9203 (matches the pin)
$(cd a5d && …)                               → "3", rc=0      (BASE 911ab51 + frozen counter + receipt)
```

Counter invocation is cwd-independent (`root` derived from `$0`): running it from the fleet root still returned
`0, rc=0` for the same extraction — no fixture leakage between trees observed.

## Attack table

| # | Attack | Tree | Result | Expected under predicate | Verdict |
|---|---|---|---|---|---|
| A1 | Rewrite S034's anchor in place, `v2.2.0`→`v2.2.1` | candidate 9efcea7 | `0, rc=0` | 0 | Counter reads 0 — append-only not enforced by the counter |
| A1b | Same, BASE tree (S034 only) | 911ab51 | `2, rc=0` | 2 | vault surface "held" by rewritten S034 |
| A1c | Rewrite all three stale anchors in place at BASE | 911ab51 | `0, rc=0` | 0 | Full 3→0 achievable by in-place rewrite, zero new rows, zero supersession |
| A2 | Stale-tree row with trailing query string (`https://…/releases.atom?tab=secrets`) + current anchor | 911ab51 | `3, rc=0` | 3 (must not count) | Query string NOT stripped: URL substring match does not count the variant ✓ strict |
| A2b | Different scheme (`http://github.com/hashicorp/vault/releases.atom`) + current anchor | 911ab51 | `3, rc=0` | 3 | Scheme variant does not count ✓ strict |
| A2h | Row whose source cell embeds the URL inside a longer string (`…releases.atom.atom-mirror`) + current anchor | 911ab51 | `2, rc=0` | 2 (this DOES count per falsifiable substring semantics) | Substring URL match counts — latent looseness, not exploited by the frozen claim, see ceiling C-3 |
| A3 | Receipt carries one extra duplicate observation for vault with `parsed_version=2.2.0` (different value) | repinned logic-only copy | `exit 2`, stderr `C2 SETUP: surface … carries 2 receipt versions` | exit 2 | Fail-closed ✓ (sha-gated first: on the frozen counter the tampered receipt exits 2 at the sha check) |
| A4 | Receipt with all vault observations deleted | repinned logic-only copy | `exit 2`, stderr `… carries 0 receipt versions` | exit 2 | Fail-closed ✓ (frozen counter exits 2 at the sha gate) |
| A4b | Receipt with surface present but every vault record `parsed_version=""` | repinned logic-only copy | `exit 2`, stderr `… carries 0 receipt versions` | exit 2 | Fail-closed ✓ |
| A5 | Anchor contains the version only as substring of a longer version | BASE tree, see probes | see C-1 naming | must not count | `v2.2.10` and `3.15.21` MISS ✓ (trailing `(?![0-9])` works); `12.2.1`, `.v2.2.1`, `1v2.2.1`, `hashicorp-vault2.2.1`, `v2.2.1.`, `3.15.2-rc1`, `python 3.15.2`, `Python  3.15.2` all MATCH — see C-1, C-2 |
| A6 | Rows wrapped in an HTML comment | candidate, holding rows commented | `0, rc=0` | 0 (unchanged) | Commented-out rows STILL count (comment-insensitive) — ceiling C-4, not a claim failure |
| A6b | Same inside a code fence | candidate, fenced | `0, rc=0` | — | Identical: fence-insensitive |
| A6c | Stale rows S034/35/39 commented, candidate tree | 9efcea7 | `0, rc=0` | 0 | Comment-insensitivity confirmed both directions; held rows still hold inside comments (a6a) |
| A6d/e | Stale rows S034/35/39 commented or fenced at BASE | 911ab51 | `3, rc=0` each | 3 | Symmetric: stale rows count wherever they sit. Consistent with "any matching row holds the surface"; the counter has no comment/fence awareness at all |
| A7 | Receipt sha correct but `format` string wrong (`release-clock-observations-v2`) | candidate, counter sha re-pinned to match | `exit 2`, stderr `C2 SETUP: bad receipt format` | exit 2 | Fail-closed ✓ — the format check is real, not bypassed by the sha equation |

All runs executed with `bash plans/round-37-c2.sh` in the named extraction, stderr captured separately; exit
codes shown exactly. Every state was driven twice (re-runs included above).

## Ceilings named (counter reads N without the full claimed state, or marginally too strictly)

**C-1 — regex lookahead is loose on prefixes.** `(?<![0-9.])` only checks the character BEFORE the optional
`v`/`Python ` prefix-less match. Loose at the left edge (probe-verified at BASE, all `MATCH`): `1v2.2.1` and
`hashicorp-vault2.2.1` both hold the vault surface, `.v2.2.1` holds it (the `.v` is treated as bare `2.2.1`
since the optional `v` was consumed), `v2.2.1.` (trailing dot) holds it. On the python surface, bare `3.15.2`,
`python 3.15.2` (lowercase, "python" without a capital P also matches because the `Python ` token is optional),
and `3.15.2-rc1` (a prerelease suffix on the stable number) all count as anchors. This means the counter can
over-warm (read 0 with a weaker anchor than the receipt version). Not falsified-beyond the claim's wording
("boundary-delimited bare version"), but the "boundary-delimited" wording is broader in effect than the
character-class lookbehind suggests. Residual risk only because a buggy or fabricated word-with-digit prefix
counts; reviewer seats + located quotes are named for that class (plan's declared ceiling).

**C-2 — trailing version-digit boundary is tight.** `v2.2.10` does NOT hold 2.2.1, and `3.15.21` does NOT
hold 3.15.2 (both MISS, probe-verified). The A5 direction named in the assignment is handled correctly.

**C-3 — URL matching is plain `in`.** A source cell containing the URL as a substring of a longer string
(`…releases.atom.atom-mirror…`) satisfies the source-cell test (BASE 3→2, probe-verified). A committed row with
a stray or annotated URL therefore counts. This is a looseness ceiling, not a non-freshness hole — it needs a
registry row edited in place (out of band) or a future round citing a URL-bearing longer string.

**C-4 — no comment/fence awareness.** Rows inside HTML comments or code fences parse and count exactly like
ordinary rows (both directions verified at BASE and candidate). This is a ceiling the round's claim need not
fall through because commented-out stale rows cannot make a do-nothing tree pass — the stale-row side stays
3 — but a nascent row deliberately hidden in a comment would count today. The census/peripheral plumbing treats these
as sources rows; the counter treats them likewise. Not exploited by the current candidate; recorded here as
the same-class counter gap A6 asked about.

## Named gate that would catch append-only violations (A1)

Not this counter: it deliberately reads the current tree, and an in-place rewrite leaves row count and URLs
identical, so neither the counter nor `corpus/sources-census.sh` distinguishes (probe: in-place S034 anchor
rewrite at BASE, `bash corpus/sources-census.sh` → `SOURCES_CENSUS: CLEAN (rows=88 … captures=88 …)`, rc 0).
The gates that name this are outside the counter: (a) the plan's kill rule "a historical receipt, row, or
lesson is rewritten or deleted instead of superseded → C2 fails" is enforced by review seats reading `git diff`
history, not mechanically; (b) the fleet census `scripts/sources-census.sh validate …` still EXITs 0 after the
in-place rewrite in the a1census probe above, i.e. the census checks the same shape and would not catch it
either. In short: **the append-only rule is unenforced by any automated instrument in scope; it is enforced
only by reviewer seats reading the diff/statement of what was added.** The claim as frozen (3→0 via appended
S089/S090/S091) is unaffected because the candidate actually appends; the counter being rewrite-indifferent is
a ceiling, not a falsifier of C2.

## Fail-open review

- Missing receipt → exit 2, no integer (rc=2 verified, base tree with receipt moved away).
- Sha-mismatched receipt → exit 2 (A3/A4 frozen runs, exact stderr `C2 SETUP: receipt missing or sha mismatch`).
- Wrong `format` string with sha re-pinned → exit 2 (A7), so the format check is not shadowed by the sha pin.
- Surface present with zero records or with an empty `parsed_version` → exit 2 (A4, A4b, logic-only runs) and
  duplicate differing `parsed_version` for the same URL → also exit (A3). Fail-closed per R34-2 as claimed.
- `set -u` is on but not `set -e`: no scenario found in the attack battery where the script runs to completion
  and emits a wrong count through a swallowed error.

## Bottom line

The counter is tight along every axis the frozen claim exercises: correct 3→0 direction on appended current
version rows, strict URL matching for query/scheme variants, tight trailing-digit boundary, fail-closed setup
path (missing/mismatched sha, wrong format, zero-version surface, duplicate observation), strict substring
matching on the anchor EXCEPT the loose char-class cases C-1 lists. The append-only rule is unenforced here and
by the census; that would allow a rewriter to reach 0 without a single appended row, which is a ceiling the
plan's kill rules already name for reviewer seats, but no automated gate currently enforces. The frozen claim
is NOT affected: it is made on the actual committed candidate (S089–S091 appended, `git show 9efcea7` diff is
required to establish it) and C-1/C-3/C-4 are probe-level observations above the threshold at which any current
control would flip the counter to the wrong side of 3→0.

COUNTER REVIEW: DONE attacks=15 wrong=0
