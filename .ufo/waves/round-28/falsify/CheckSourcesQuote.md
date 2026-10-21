# CheckSourcesQuote — round-28 falsify (SOURCES quote counts / normalization attribution / used-by S ids)

Seat `KagiR28.CheckSourcesQuote`. Target `kagi-shokunin` @ `62a33b1bd15217ed729df2ca40c8a30aba3076c0`.
Scope: quote word counts, normalization attribution, and that every new used-by path cites
the correct S id for the six new rows S044–S049. No production file edited; no host-private
ledger row executed. Everything anchored to `62a33b1` via `git archive 62a33b1` into a
sandbox, never the moving lane checkout (which advanced to `5e847472` mid-run).

## VERDICT: PASS (narrow — sources/quote/used-by surface only)

**1. Quote word counts — PASS.** The only word-count rule in the tree is
`corpus/sources-census.sh:277-278`: `words=$(printf '%s' "$fquote" | wc -w)` on the
`source-fetches.tsv` quote column, `SC_FETCH id=<id> quote` when `words > 25`. The in-row
`SOURCES.md` quote cell carries the same text, so I checked both columns independently.
Fetch-TSV quote words (identical in-row quote), limit 25: `S044=11 S045=23 S046=17
S047=21 S048=19 S049=19` — max S045=23. A whole-registry sweep of the in-row
`Quote: "…"` cell found **no** row over 25 words. For every one of S042–S049 the registry
quote and the fetch-TSV quote are byte-equal, so no registry quote drifts from its capture.

**2. Normalization attribution — PASS.** All six rows declare
`normalization=rendered-text-v1` with a `normalized_sha256` (`corpus/source-fetches.tsv:87-92`).
I recomputed both digests from the wave's own capture bodies
(`.ufo/waves/round-28/captures/S04*.body`) with the committed normalizer
`corpus/rendered-text-v1.py` (`digest` and `locate`). Result — all six, exit 0 each:
`S044` raw yes `7dcb450d…` / norm yes `c6c84fed…` / locate count=1 ·
`S045` raw yes `f9d4b8b1…` / norm yes `5e0f0d9a…` / count=1 ·
`S046` raw yes `15ae2918…` / norm yes `f3fbf619…` / count=1 ·
`S047` raw yes `bb94459d…` / norm yes `c345f249…` / count=1 ·
`S048` raw yes `d3a6953d…` / norm yes `039e5c9c…` / count=1 ·
`S049` raw yes `783c37dc…` / norm yes `d900f1ea…` / count=1.
Each quote locates **exactly once** under `rendered-text-v1` — the "located once" claim at
`corpus/lessons/round-28.md:31-36` holds. Independent live re-fetch (6 public doc URLs,
declared profile `curl -fsSL --compressed`, UA `kagi-shokunin-round23/1.0`; no
auth/vault/CDP): all six HTTP 200; the same six quotes each locate `count=1`. The two
`docs.python.org` pages carry a rotating build stamp ("Last updated on Oct 21, 2026
(HH:MM UTC)"), so their raw digests moved after the capture; patching only that stamp back
to its capture-time value reproduces the recorded raw **and** normalized digests
byte-exactly (both rows) — the recorded digests are faithful to the captured bodies, not a
stale artifact. Every anchor id the new rows assert exists in the fetched page:
`#integer-string-conversion-length-limitation`, `#semantic-versioning-specification-semver`,
`#int`, `#understanding-the-oidc-token`, `#about-validity-checks`, `#pub-announcement`,
`#pub-comments-due`.

**3. New used-by paths cite the correct S id — PASS.** The only new registry rows at the
candidate are S044–S049; each has `used-by = corpus/lessons/round-28.md`, and that lesson's
`source:` line (`corpus/lessons/round-28.md:1`) is `source: S044, S045, S046, S047, S048,
S049` — exactly those six, no others. Re-implementing the census rule `SC_USEDBY_NOCITE`
(the id must appear on the used-by file's `source:` line) against each row's own used-by
path: **6/6 cited**. `S042`/`S043` are *discussed* in that lesson but correctly absent from
its `source:` line, and their used-by still points at `corpus/lessons/round-27.md` — no
cross-round id is silently re-homed. Registry-table diff BASE→candidate: **0 existing rows
changed** in any column (status/opened/recheck/used-by untouched), 6 rows added — matching
the lesson's "Existing registry cells (status/recheck/used-by), old → new: none"
(`corpus/lessons/round-28.md:47`).

### Commands run (exit 0 unless noted)
```
git archive 62a33b1 | tar -x -C <sandbox>/cand                              exit 0
git show 62a33b1:corpus/SOURCES.md  (row-by-row BASE vs CAND diff)          exit 0
bash corpus/sources-census.sh verify --root <sandbox>/cand
  → SOURCES_CENSUS: CLEAN (rows=49 A=47 B=0 C=2 queued=1 mined=45 rejected=3
    entries_sourced=4 legacy=21 captures=49 inrow=16 inrow_only=0 inrow_nonreproducing=12)
bash /home/vgpnk/Projects/shokunin/scripts/sources-census.sh validate
  --file <sandbox>/cand/corpus/SOURCES.md   → 12×W04 + ok                    exit 0
python3 corpus/rendered-text-v1.py digest|locate   (×6, ×6)                  exit 0
curl -fsSL --compressed  (×6 public doc URLs + legacy-path probes)           exit 0
```
The 12 W04s are the 11 pre-existing START-census duplicates plus exactly one new: `S045
duplicate url semver.org/spec/v2.0.0.html` — S045 shares S042's URL with a different
scope, stated deliberately at `corpus/lessons/round-28.md:32` and in the plan correction
retiring the erroneous "SemVer S042 §2" citation. The gate still reports `ok`, exit 0;
W04 is a warning, not a finding.

### What I did NOT check
- Did not execute any `corpus/claim-ledger.tsv` row (host-private surfaces); the ledger was
  read as pins only. `R21-02` pins `rows=49 …` and the candidate census verdict matches that
  pin string exactly — string compare only, not a row run.
- Did not evaluate C1/C2 fixtures, `c1-measure.py`/`c2-measure.py`, the release-clock
  selftest, or repair revision `5e847472` (outside my slice).
- Did not audit the lesson's *wording* claims about S047/S048/S049 mechanics beyond the
  quotes' own presence and the anchor ids, nor diff the two census scripts' rule sets (I ran both).
- Did not check the lane working tree's later state (it advanced past the pinned candidate
  during my run: S050/S051 appeared at `5e847472`).

### Residual risk (low, not a finding)
- The two `docs.python.org` raw digests reproduce only with the upstream build stamp also
  patched; a recheck at a later build drifts. Their `representation=decoded-http-body-volatile-v1`
  declares that volatility, and the census does not require these non-historical rows to
  reproduce — consistent. `S045`/`S042` share one URL across two scopes; a future merge of
  their scopes would make one row's quote/anchor cell ambiguous.
