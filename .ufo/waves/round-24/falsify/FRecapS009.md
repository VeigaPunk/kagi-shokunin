# FRecapS009 — C2 S009 falsification (Age on SOPS docs page)

Seat: KagiR24-2.FRecapS009-9 · 2026-10-21 · Frozen lane rev `c5ef9e92201b6c36396301f12b23740565bf86a0` (BASE `4f94b52a3cdfaa289d779bd8a2afcd0b1fcd9105`).
Scope: S009 only. Sandbox `/fast/scratch/kagi-r24-recovery/FRecapS009-9` (clone --no-hardlinks, checkout frozen rev, exit 0). No installs. Production untouched.

## Verdict: SUSTAINED — no falsifier found for S009 (pass)

The 2026-10-21 capture row is **historically reproducible today, byte-for-byte**; classification
`reproduces-raw` is correct under the declared recompute rule; metadata (status, row identity,
URL, last-modified/commit locator) is consistent; no undocumented representation is called current.

## Observed facts (commands, exit, stdout)

1. Fresh capture, env -i PATH=/usr/bin:/bin, empty HOME:
   `curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)' … -o out/S009.body`
   → exit 0, `URL_EFFECTIVE=https://getsops.io/docs/usage/identities/age/ HTTP=200`, `wc -c` = **29301**.
2. Frozen-rev normalizer on fresh body (`python3 corpus/rendered-text-v1.py digest ../out/S009.body`, exit 0):
   `raw_sha256=a840727ea1a8faa05e547f59766f608cbff81b28a66d1507a614d18d25b50b76 bytes=29301
   normalized_sha256=189d5ba9145e71f4a41dae10a42b9176fa660c58f3df5cb2774a145d11728d95 normalized_bytes=3570`.
   Independent `sha256sum` agrees (RAW_SHA=a840727e…). **Matches corpus/source-fetches.tsv:62** (raw, bytes,
   normalized) exactly — zero drift.
3. `--selftest` at frozen rev: exit 0, `RENDERED_TEXT_V1_SELFTEST: PASS (cases=20)`.
4. Quote: locate normalized form `'It is also possible to use updatekeys , when adding or removing age
   recipients.'` → exit 0, count=1 (TSV:13 cell form). Locate registry backticked form
   `'…use `updatekeys`, when…'` → exit 1, count=0 — expected representation artifact, not missing text:
   v1 rules (rendered-text-v1.py:3-58) replace tags with a space and never strip backticks, so
   `<code>updatekeys</code>,` renders as ``updatekeys , when``. Headed §Encrypting using age (body:18 TOC,
   content body:19-21). Matches build/RecapS009.md's count=0/count=1 reading.
5. Metadata consistency: body:43 `Last modified May 15, 2026: … commit 9b7b84e297bdabc9c78e571c1e6db43dcd69454a`
   = SOURCES.md:15 locator ("last modified 2026-05-15, docs commit 9b7b84e…"). Row identity recomputed:
   `printf 'S009\tmined\thttps://getsops.io/docs/usage/identities/age/\n' | sha256sum` →
   `ef1987e023083e520e38037aa5c4be4d23b509096301c91f011f78100648a9de` = TSV:62 col 3. TSV row NF=16
   (header: 16 columns, no tabs in cells). status `mined` = SOURCES.md:15 status. inrow-pins.tsv:15
   capture_fetched 2026-10-21 = TSV:62 fetched.
6. Classification interpretation: inrow-pins.tsv header (lines 2-6) declares verdicts RECOMPUTED from
   capture digests; `reproduces-raw` ⇔ capture sha256 = pin. I recomputed both sides independently:
   pin a840727e… (SOURCES.md:15 `Fetch sha256:`) = fresh raw a840727e… ⇒ reproduces-raw is the correct
   verdict; normalized 189d5ba9… ≠ pin, correctly not classified reproduces-normalized.
7. Uniqueness/representation audit: exactly one `^S009<TAB>` row in source-fetches.tsv (line 62).
   Representation `decoded-http-body-v1` documented (TSV:17-19); col 12 `-` = documented revision
   placeholder for non-moving-ref URLs (TSV:26); normalized digest declared under `rendered-text-v1`.
   Build receipt RecapS009.md labels raw and normalized digests explicitly and calls nothing else current.
   SOURCES.md:15's in-row pin stays representation-undocumented by design (D5 premise) and is classified,
   not re-labeled current.

## Historical reproducibility vs metadata consistency

- The round-24 capture (2026-10-21) reproduces today byte-for-byte under the declared request profile —
  this is genuine capture reproducibility, not merely metadata agreement.
- The round-23 in-row pin (mined 2026-10-19) is *consistent* as a raw-body observation (pin == current
  raw), but the 2026-10-19 fetch itself is not re-runnable; that limit is exactly what inrow-pins.tsv's
  header records ("historical point observation… not evidence that the page changed").

## Cross-checks outside my row (informational, no S009 impact)

- inrow-pins.tsv full file: 12 non-reproducing (S001-S007, S012-S016), 4 reproduces-raw (S008-S011),
  0 reproduces-normalized. Plan C2 text says "named non-reproducing in-row pins: 6 (S008, S012-S016…)"
  — that is the round-23 *previously named* set; the claim's requirement "every non-reproducing pin named
  by inrow-pins.tsv" holds at 12. S009 was never in the named non-reproducing set and classifies
  reproduces-raw, as the plan's parenthetical predicts. Severity: none for S009; planner may wish to
  reconcile the 6-named vs 12-classified delta in C2 counting prose.

## Bounds and falsifier status

Observed bounds: single URL `https://getsops.io/docs/usage/identities/age/`, single fetch 2026-10-21
(today), single frozen revision; census not run in full (per-seat bound); S009 not exercised under any
gate. Falsifier: any fresh fetch whose decoded body or normalized digest diverges from TSV:62 under the
declared profile — none observed; result would be drift-classified per header semantics, not capture
falsehood.
