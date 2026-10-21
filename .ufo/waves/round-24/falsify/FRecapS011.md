# FRecapS011 — C2 S011

## Scope and bounds

- Frozen lane revision: `c5ef9e92201b6c36396301f12b23740565bf86a0` (verified in the isolated clone); round-24 BASE: `4f94b52a3cdfaa289d779bd8a2afcd0b1fcd9105`.
- Examined only C2/S011: `corpus/SOURCES.md:17`, `corpus/source-fetches.tsv:64`, `corpus/inrow-pins.tsv:17`, and `.ufo/waves/round-24/build/RecapS011.md`. Operability/C1 and calibration/C3 were not tested.
- The registered page is `https://getsops.io/docs/usage/key-management/`. The `read` URL helper selected an `application/feed` alternate (`index.xml`); it was not used as page/digest evidence.

## Fresh refetch and representation

- Clone: `git clone --no-hardlinks … /fast/scratch/kagi-r24-recovery/FRecapS011-9`, detached at the frozen revision. The only fetched body is in that unique sandbox.
- Reopen command: `curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)' -o S011.reopened.body -w '%{url_effective} %{http_code}' 'https://getsops.io/docs/usage/key-management/'` (run from the sandbox context; exit 0). Observed final URL was the registered URL; HTTP 200.
- Compared only documented representations: `decoded-http-body-v1` (curl-decompressed body) and `rendered-text-v1` (declared normalizer). Fresh digest output: raw SHA-256 `d0ab8b201f1a6d5f5751e1f261f904822492c530bdcdc5a4db9a8e178c2e180c`, 33,153 bytes; normalized SHA-256 `4a71dbc959fc4a0dd596c973d90001e894b28558db0774d6d0f8653c1af4c536`, 5,451 bytes.
- Those two digests and byte count exactly match S011's fetch row. The row's `row_identity_sha256` also matches `sha256('S011<TAB>mined<TAB>https://getsops.io/docs/usage/key-management/<LF>')`: `98e1368fce1e6cb682d9b68f26555d48f085d7280efc3d18d57b5cca8101104f`. The row records the same URL/final URL, HTTP 200, `curl-fsSL-compressed-v1`, `decoded-http-body-v1`, and `rendered-text-v1`.

## Quote and classification

- `rendered-text-v1 locate` on the registry's backtick-formatted quote `Use \`updatekeys\` if you want to add a key without rotating the data key.` returned `count=0`, exit 1. This is expected: `locate` normalizes HTML tags in the body but only collapses whitespace in the supplied query, so the query's literal backticks are not removed.
- The fetch-row quote without Markdown code delimiters, `Use updatekeys if you want to add a key without rotating the data key.`, returned `count=1`, exit 0. The rotate-command sentence and the cited compromise-sequencing sentence each returned `count=1`, exit 0. The page footer `Last modified May 15, 2026: Add page descriptions. (9b7b84e)` returned `count=1`, consistent with the source row's date and commit prefix.
- The in-row pin and `SOURCES.md` Fetch sha256 both equal the current/captured decoded-body digest, and differ from the normalized digest. `reproduces-raw` is therefore the correct classification relative to the two declared representations; it is not `normalized` or `non-reproducing`.

## Finding

- **Freshness result:** no S011 counterexample observed; severity none on this slice. The test falsifier would be a mismatch between the declared pin/capture digests or missing quoted support under the declared normalizer; neither occurred.
- This is byte reproducibility against the refetched declared representation plus consistency of the recorded row fields. It does not independently authenticate the original legacy fetch process/transport. No undocumented representation is treated as current. A later page change, if observed in a future capture, would not by itself show this historical pin false.
- No tools installed or updated; no production files edited. This bounded attack is not a C2-wide or overall round-24 pass.