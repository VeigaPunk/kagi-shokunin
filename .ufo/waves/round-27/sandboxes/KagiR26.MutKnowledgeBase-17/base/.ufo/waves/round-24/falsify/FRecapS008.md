# FRecapS008 — C2 S008

## Bounds
- Frozen lane HEAD observed: `c5ef9e92201b6c36396301f12b23740565bf86a0`; BASE: `4f94b52a3cdfaa289d779bd8a2afcd0b1fcd9105`.
- Fresh public fetch and digest used only a `--no-hardlinks` clone checked out at the frozen revision, under `/fast/scratch/kagi-r24-recovery/KagiR24-2.FRecapS008-9`; production files were read-only. No tools installed. Only this report was written.

## Fresh observations
- `corpus/SOURCES.md:14`: S008 is rejected for the claimed recipient/key-group/data-key rotation mechanics; historical pin is `63cb0a462ce23574365c0b692aa09ea2f632f4b4df2b5f4186d8c004b57e3440`; row says `main` opened 2026-10-19, no commit/version displayed.
- Command (exit 0): `env -i HOME=/fast/scratch/kagi-r24-recovery/KagiR24-2.FRecapS008-9/home PATH=/usr/bin:/bin curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)' -o /fast/scratch/kagi-r24-recovery/KagiR24-2.FRecapS008-9/s008-main.rst -w '%{url_effective} %{http_code}\n' https://raw.githubusercontent.com/getsops/sops/main/README.rst`
- Stdout: `https://raw.githubusercontent.com/getsops/sops/main/README.rst 200`.
- Command (exit 0): `env -i HOME=/fast/scratch/kagi-r24-recovery/KagiR24-2.FRecapS008-9/home PATH=/usr/bin:/bin python3 /fast/scratch/kagi-r24-recovery/KagiR24-2.FRecapS008-9/corpus/rendered-text-v1.py digest /fast/scratch/kagi-r24-recovery/KagiR24-2.FRecapS008-9/s008-main.rst`
- Stdout: `raw_sha256=63cb0a462ce23574365c0b692aa09ea2f632f4b4df2b5f4186d8c004b57e3440 bytes=1909 normalized_sha256=4dd7e969ed6f99d77145f72fa6b87d7d7601c76490e56221f3bb90fa1dbb0d79 normalized_bytes=1448`.
- This independently matches `corpus/source-fetches.tsv:61` (2026-10-21, `decoded-http-body-v1`, 1,909 bytes, HTTP 200, recorded revision `453e7e6ab01b1340dca9f9025fd8430229320f97`) and matches the old pin as **raw**, not normalized. `corpus/inrow-pins.tsv:14` correctly says `reproduces-raw`; this is a classification against the new capture, not a declaration of the historical pin's representation.
- Current GitHub API `main` metadata (saved in the scratch clone; curl exit 0) reports SHA `453e7e6ab01b1340dca9f9025fd8430229320f97`, committer date `2026-10-20T04:33:58Z`; it agrees with the capture row's revision. The current decoded body also matches the recorded capture digest/size.

## Quote and classification
- Fresh body lines 15–18 show `Documentation` and: `You can find the SOPS documentation on \`getsops.io <https://getsops.io/>\`_ under \`"Docs" <https://getsops.io/docs/>\`_.` Lines 4–5 list formats and backends (including age); the relevant text points readers to the docs rather than describing recipient, key-group, or data-key rotation mechanics. S008's `rejected` scope verdict remains supported by this README.
- The registry's plain quote (“…on getsops.io”) is rendered/reST-stripped, not a literal hit in the source. Normalizer command `.../rendered-text-v1.py locate ... 'You can find the SOPS documentation on getsops.io'` returned `RENDERED_TEXT_V1_LOCATE: count=0` (exit 1). In contrast, the capture row's `raw-literal-v1` quote retains the reST markup and is present in the raw body. No undocumented representation is called current: current capture is explicitly decoded HTTP body; normalized digest is explicitly `rendered-text-v1`.

## Findings / severity
- **S008 row-level C2: pass, high confidence.** Current raw capture equals both the legacy pin and the 2026-10-21 declared raw capture; normalized digest differs. This establishes a current raw-digest match, not independent recovery of the 2026-10-19 body or proof of what representation produced its undocumented pin. Round-23 lesson `corpus/lessons/round-23.md:111–121` explicitly retains that historical limitation.
- **Frozen aggregate wording: fail, medium severity.** `plans/round-24.md:47–50` says there are six non-reproducing pins and lists `S008, S012–S016`, while the same line notes S008 reproduces raw and the classification row confirms it. S008 cannot count as non-reproducing; this contradicts the frozen named set/count, without falsifying the live capture or proving the historical pin false.
- `build/RecapS008.md:48–57` records the same current `main` revision/body comparison. Its 2026-10-20 UTC commit date does not bind the registry's date-only 2026-10-19 observation to that revision; absent an original immutable ref/body and timezone, historical version attribution remains unknown. This is not evidence that the old digest was false.
- Falsifier for the pass: a fresh fetch under the same declared profile whose raw digest differs from the pin/capture (or a corrected historical immutable body proving the original pin differs); neither was observed here.
