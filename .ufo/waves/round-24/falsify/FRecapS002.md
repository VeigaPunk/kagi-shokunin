# FRecapS002 — S002 freshness recapture falsification

- Frozen lane revision: `c5ef9e92201b6c36396301f12b23740565bf86a0`; round-24 BASE: `4f94b52a3cdfaa289d779bd8a2afcd0b1fcd9105`.
- Bounds: S002 only. Read the S002 registry/fetch/pin rows, normalizer rules, and `build/RecapS002.md`; reopened the registered page in alternate-Markdown and raw-HTML views. No shell command, test, or independent digest computation was run; no production source was changed and no tool was installed.

## Findings

**Observed — citation and representation.** `corpus/SOURCES.md:8` records the 2026-10-19 historical pin `68017d4cf1655abb55baec982c2ed89b5a73731bba0275ca2426a25dfcd9d2a6` and quotes the Connect-server diagram caption. Reopening `https://www.1password.dev/connect` shows the exact sentence in the diagram's Markdown image alt; the raw HTML view also has it as the image `alt` attribute: “The Connect server is part of your environment, and communicates to Your Apps using access tokens and a REST API.” Thus the live page includes the access-token detail in this raw attribute, not just the REST API paraphrase.

`corpus/source-fetches.tsv:55` labels the 2026-10-21 S002 capture `decoded-http-body-volatile-v1`, with `raw-literal-v1`, no normalized digest, and location “Connect-server diagram image alt attribute (raw HTML only; absent from rendered text).” The committed receipt records raw SHA-256 `9b5dc190d03d118e2e956a83e157477a6d88cf568aeb9179c0c29f717ac4a975`, 1,186,855 bytes; `build/RecapS002.md:17` records normalized SHA-256 `b82b2b2cae2805bb4aaa0a4ceeee42709f07f014ff328bd5186fa036dc8779f2`. These are the prior 2026-10-21 capture's digests, not digests computed from this reread.

`corpus/rendered-text-v1.py:61-71` removes tags with `TAG_RE` before normalization; deleting the `<img ... alt="…">` tag removes the alt text too. Therefore the recorded `locate` result `count=0` (`build/RecapS002.md:25`, exit 1) is consistent with a raw-only quote and does not show that the page lacks the quoted access-token statement.

**Classification / metadata consistency.** `corpus/inrow-pins.tsv:8` correctly marks the historical pin `non-reproducing` against the 2026-10-21 raw and normalized digests; its schema (`inrow-pins.tsv:1-6`) explicitly defines that as a historical point observation with undocumented representation, not proof the page changed. Registry ID/status/URL, 2026-10-21 fetch date, and historical pin agree across the three rows. The capture row declares its current representation; the older `SOURCES.md` pin remains an undocumented historical representation. I did not independently recompute either committed digest.

## Falsifier and disposition

- **Counterexample (medium severity):** `build/RecapS002.md:33` concludes the access-token part is unsupported and the quote absent. The current raw HTML image alt contains the full quote, contradicting that conclusion. The failed normalized-text search is a representation mismatch, not evidence against the raw-literal citation.
- **C2 S002 subclaim:** current capture metadata and the `non-reproducing` classification are internally consistent; the recap's source-support interpretation fails. Do not use the historical-pin mismatch as evidence the 2026-10-19 capture was false or as proof of semantic drift.
- **Falsifier:** remove/alter the current page's diagram `alt` so it no longer contains the quoted statement, or produce the original 2026-10-19 body showing the historical pin has a different, declared representation. Neither was observed here. Historical capture reproducibility remains unresolved because no 2026-10-19 body/representation is available in the inspected evidence.

## Execution record

- Current-page reread: `read https://www.1password.dev/connect` and `read https://www.1password.dev/connect:raw`; exact quote observed in both representations. No HTTP status or fresh body digest was obtained from these reader views.
- No command was executed in this review. Existing `build/RecapS002.md:12-17,25` records the curl capture (exit 0; stdout final URL `https://www.1password.dev/connect 200`), digest command (exit 0; digests above), and normalized locator (exit 1; `RENDERED_TEXT_V1_LOCATE: count=0`); these are cited receipts, not reruns.