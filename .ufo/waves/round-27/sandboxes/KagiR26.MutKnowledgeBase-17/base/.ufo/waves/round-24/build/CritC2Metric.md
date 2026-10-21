# CritC2Metric — round 24 C2 review

## Verdict

[INFERENCE] If implemented as written, C2 is a real but bounded freshness/provenance improvement, not merely bookkeeping: a dated, method-declared 2026-10-21 observation for each legacy source would make the evidence trail more auditable than an unexplained 2026-10-19 in-row digest. The planned captures are not present in the reviewed tree yet. Even when landed, they do **not** by themselves refresh source claims, validate quotes/locations, or show domain facts remain true. The 16→0 headline is capture-record coverage, not independently verified freshness.

## Strongest normalizer counterexample

The new code is close to the round-23 digest generator, but not behaviorally identical. Round-23's recorded generator required the opening script/style tag's `>` before matching its body (`(?is)<(script|style)\b[^>]*>.*?</\1\s*>`; `.ufo/waves/round-23/falsify/CritNormalizer.md:74-80`). `rendered-text-v1.py:56` instead uses `(?is)<(script|style)\b.*?</\1\s*>`, without `[^>]*>`.

In the isolated BASE clone with the reviewed working-tree normalizer copied in, the exact commands below returned exit 0. The selftest passed all 16 cases, but this input yielded different outputs under the current function versus the recorded generator:

```text
input:  L<script broken</script>secret</script>R
current: L secret R   sha256=5c3458ce91c9bee12f3e4b70c24bfe55a3f0139b3da67a3b6fa54ef7d4ba4f98
R23:     L R          sha256=be605116c4830a4fb713a371b82b04de03d4210c8fc8e8b6bf6fbecbf105f95
```

The input is malformed markup: the current regex treats the first `</script>` as a closing tag even though no opening-tag `>` preceded it, then leaves `secret`; the R23 pattern consumes through the second close. This is a **fixable edge-case incompatibility**, not evidence that any of the ten recorded page bodies currently hashes differently. The prior audit's listed real-capture comparisons do not specifically compare these two opener regexes (`CritNormalizer.md:160-164`); the current selftest still does not establish ten-row conformance.

Commands/evidence:

- `python3 corpus/rendered-text-v1.py --selftest` → exit 0, `RENDERED_TEXT_V1_SELFTEST: PASS (cases=16)`; also reproduced in the scratch clone.
- Scratch setup: `git clone -q --no-hardlinks /home/vgpnk/Projects/shokunin/kagi-shokunin /fast/scratch/kagi-r24/seats/CritC2Metric-2 && git -C /fast/scratch/kagi-r24/seats/CritC2Metric-2 checkout -q 4f94b52a3cdfaa289d779bd8a2afcd0b1fcd9105 && cp /home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/rendered-text-v1.py /fast/scratch/kagi-r24/seats/CritC2Metric-2/corpus/rendered-text-v1.py` → exit 0.
- Scratch comparison: `python3 -c 'import hashlib,html,re,runpy; n=runpy.run_path("corpus/rendered-text-v1.py")["normalize_bytes"]; x=b"L<script broken</script>secret</script>R"; new=n(x).decode(); old=x.decode(); old=re.sub(r"(?is)<(script|style)\b[^>]*>.*?</\1\s*>"," ",old); old=re.sub(r"<[^>]+>"," ",old); old=html.unescape(old); old=re.sub(r"\s+"," ",old).strip(); print("new=%r sha256=%s"%(new,hashlib.sha256(new.encode()).hexdigest())); print("old=%r sha256=%s"%(old,hashlib.sha256(old.encode()).hexdigest()))'` → exit 0, values above.

The selftest's synthetic `CASES` cover the listed choices, including the comment boundary, but do not run the ten historical capture bodies or compare their recorded digests (`corpus/rendered-text-v1.py:115-160`). `source-fetches.tsv` stores digests/metadata, not those bodies, and calls digests point attestations (`corpus/source-fetches.tsv:33-37`). Thus the plan's requirement to reproduce all ten is not satisfied by `--selftest` alone. Round-23 evidence did reproduce the digests under a particular generator (`CritNormalizer.md:70-80, 98-128`), but a repeat against the *same original bytes* is not a deterministic committed regression test when those bytes are absent.

**Smallest safe correction:** make `SCRIPT_STYLE_RE` use the R23 generator's exact `[^>]*>` opener and add the malformed-opener counterexample as a selftest case; align the docstring accordingly (`rendered-text-v1.py:10-22, 56-66, 115-131`). Report the ten-digest reproduction only if actually run against those same bytes (or explicitly say historical bodies are unavailable); do not imply the 16 synthetic cases prove it.

## Is 16→0 falsifiable and non-self-certifying?

- **Falsifiable as a coverage/count claim:** an omitted, duplicate, mis-keyed, or URL-mismatched capture/classification row can be detected from `SOURCES.md` and the TSVs. The plan freezes S001–S016 and specifies an in-row/capture split (`plans/round-24.md:37-50`).
- **Not independent evidence that the proposed captures are true.** The current census checks fields' shape, URL/status/row identity and digest syntax; it does not hash a response body or verify the claimed final URL, status, date, quote, or normalized digest (`corpus/sources-census.sh:245-274`). Its row-identity SHA binds only `id<TAB>status<TAB>url` (`:251-252`). The capture-file header calls digests point attestations and says legacy pins are only required to be present (`source-fetches.tsv:33-37`). The proposed capture table is lane-authored metadata with no body field, so `inrow_only=0` can be made true by adding well-shaped rows. Treating CLEAN or the count as capture validation would be self-certifying.
- The new `inrow-pins.tsv` labels must not become a second authority: have the census derive/check each class from the original in-row digest and that ID's capture (`raw_sha256`, `normalized_sha256`), require exactly one row for each frozen S001–S016, and reject non-population IDs. Define `non-reproducing` narrowly as “matches neither digest in this new capture,” not proof the historical pin was false or stale. Round 23 explicitly records the old representation as undocumented (`source-fetches.tsv:35-37`); a new-date mismatch only says the old pin matches neither digest for this new capture.
- There is also a baseline arithmetic/classification defect in the frozen text: `plans/round-24.md:49-50` calls six pins `non-reproducing` while including S008 and immediately saying S008 reproduces raw. Round-23 states S008 matches raw; S012–S016 are the five named non-matches under the cited comparisons (`corpus/lessons/round-23.md:115-121`). Split `raw_match` from `neither_current_digest`; do not carry “6 non-reproducing” forward.

**Strongest honest metric:** show separate fields: `declared_capture_coverage=16/16` (structural, lane-authored); computed legacy classes (`raw_match`, `normalized_match`, `neither_current_digest`, and `unclassified`); and `independently_reproduced_capture=N/16` only when a non-author re-fetches with the exact profile and normalizer. Until that independent count exists, mark it “not measured.” This preserves a real auditability gain without upgrading capture presence into truth. A non-author sample reopen is also required by the source contract (`CORPUS.md:112-115`).

## Sourcing scope

Official Python docs are appropriate authoritative sources **for the scoped implementation facts** (`re` `\s`, `html.unescape`)—the source contract makes tier A scope-specific and requires each row be opened in-round, with URL/date/located quote in the lesson Gate and a non-author sample reopen (`CORPUS.md:93-100, 112-115`). Those rows would source the normalizer method, not validate 1Password/Vault/OpenBao/SOPS claims or count as new domain knowledge. At the reviewed snapshot `corpus/SOURCES.md` ends at S026 (`:30-32`) and contains no Python normalizer rows, so this frozen sourced criterion is still prospective/unverified until those rows and lesson citations land. The rejected ASCII-whitespace alternative is useful only if its row explicitly records why that alternative does not match the chosen Python semantics.

## Impacted axes and disposition

- **Freshness (primary):** if all 16 captures land, they improve dated capture/provenance coverage, not demonstrated freshness of source meaning. Do not score `16→0` as independently verified source freshness.
- **Calibration:** the wrong `6` baseline and unverified class labels can overstate how many legacy pins actually fail to reproduce; normalizer selftest is implementation-self-consistency, not historical-input conformance.
- **Operability:** the digest CLI helps re-check a supplied body, but no archived body means the ten historical digest claim is not replayable from repository data.

Smallest safe plan edits: (1) clarify the coverage metric and add the independent-replay field/bound; (2) make classes derived and correct the S008/6 wording; (3) restore the precise R23 regex plus a regression case; (4) do not credit the all-ten claim until the comparison is exercised against the same inputs or its limitation is stated. No tools were installed.