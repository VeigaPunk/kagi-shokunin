# XReleaseClock — Round 25 build report

Revision: `4587c61a348e4528717404a68912c373f3ef4d03` (frozen BASE).

## Files and behavior

- Sandbox implementation: `corpus/release-clock.py`; sandbox `corpus/release-clocks.tsv` is the requested header-only 9-column template. `corpus/SOURCES.md` was not changed.
- Offline mode counts `on-release` registry rows, enforces exactly one binding, checks orphan/non-release IDs, feed-source existence/kind/exact URL, anchored version, ISO dates and feed verdict/version consistency. Missing TSV means all `on-release` rows are `UNBOUND`.
- `--observe` stores a separate 0600, exclusive/no-overwrite JSON receipt; it never updates TSV. It uses public HTTPS only, rejects query/userinfo and sensitive paths, follows bounded same-origin redirects (1Password paths stay on the original public path), disables ambient proxies, and pins validated globally routed DNS addresses through TLS while retaining the URL hostname for SNI.
- Feed parsing accepts bounded Atom/RSS XML (first entry); DTD/entities, oversized bodies/structures and unparseable versions fail closed. Rendered quotes import `corpus/rendered-text-v1.py` and check every extracted row quote.
- Pointers: `corpus/release-clock.py:55,95,125,143,219,248,276,325,411,431,436,477,518,566,600,650,1042`; template `corpus/release-clocks.tsv:1`.

## Evidence and checks

- Selftest command: `mkdir -p /fast/scratch/kagi-r25/XReleaseClock-2/tmp && env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/XReleaseClock-2/home TMPDIR=/fast/scratch/kagi-r25/XReleaseClock-2/tmp python3 corpus/release-clock.py --selftest; status=$?; printf 'EXIT=%d\n' "$status"; exit "$status"` — exit 0. Stdout: `RELEASE_CLOCK_SELFTEST: PASS (33 cases)`; `EXIT=0`. Cases include URL/query/path redaction, DNS/private-address rejection, proxy-free fake HTTPS request, redirect restrictions, XML guards, fired/not-fired behavior, rendered quote location, and receipt mode/no-overwrite/symlink refusal.
- BASE offline command: `env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/XReleaseClock-2/home TMPDIR=/fast/scratch/kagi-r25/XReleaseClock-2/tmp python3 corpus/release-clock.py --root /fast/scratch/kagi-r25/XReleaseClock-2/lane; status=$?; printf 'EXIT=%d\n' "$status"; exit "$status"` — exit 1, expected for the header-only BASE measurement. Stdout excerpt: `RELEASE_CLOCK: FAILED (on_release=28 bound=0 unbound=28 observed=0 fired=0)`, `UNBOUND S005` … `UNBOUND S032`, `EXIT=1` (the intervening UNBOUND IDs S006–S031 were also printed).
- Single-feed `--observe` trial command: `env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/XReleaseClock-2/home TMPDIR=/fast/scratch/kagi-r25/XReleaseClock-2/tmp python3 corpus/release-clock.py --root /fast/scratch/kagi-r25/XReleaseClock-2/trial-root --observe /fast/scratch/kagi-r25/XReleaseClock-2/trial-root/receipt-final5.json; status=$?; printf 'EXIT=%d\n' "$status"; exit "$status"` — exit 0. Synthetic root used one `S001` binding to `S002` (`kind=feed`) at `https://github.com/getsops/sops/releases.atom`; synthetic anchor `0.0.0` is a test control, not a corpus claim. Stdout: `RELEASE_CLOCK: CLEAN (on_release=1 bound=1 unbound=0 observed=1 fired=0)`; `RELEASE_CLOCK_OBSERVE: wrote 1 observations (failed=0 fired=1) to /fast/scratch/kagi-r25/XReleaseClock-2/trial-root/receipt-final5.json`; `EXIT=0`.
- Retained receipt: HTTP 200, parsed version `3.13.3`, verdict `fired`, UTC timestamp `2026-10-21T11:08:52Z`, body SHA-256 `47a224ad71435b7f5cae863bc96c01468bfed482636045fc307430983b072ff6`. Re-read synthetic TSV after observation remained byte-for-byte at its initial `0.0.0 / not-fired` row; only the separate receipt reported the new live observation.
- Patch: `.ufo/waves/round-25/patches/XReleaseClock.patch`. `git apply --check /home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-25/patches/XReleaseClock.patch` on a clean BASE clone — exit 0, no stdout.
- LSP symbol/refactor tooling: UNAVAILABLE in the mounted tool inventory; no existing callsites were refactored.
- Other builds, linters and formatters: UNRUN (wave instruction; parent owns integration gates). Tool installs/updates: none.

## Risks and blockers

- This seat intentionally leaves the production TSV header-only; BASE SOURCES contains S001–S032 and no S033+ release-feed rows. L1/scouts must supply the actual reviewed bindings and feed source rows.
- Feed-source ownership is evidenced by the registry row, `kind=feed`, and exact URL binding; official-source trust still depends on review of that row. The parser expects Atom/RSS XML and a version in the first entry, not JSON feeds.
- Receipt path-secret detection is conservative pattern-based redaction, not proof that every arbitrary URL path is non-sensitive; query strings, fragments and userinfo are omitted, and recognized token/session/opaque paths are not fetched or persisted.
- No blocker for the scoped implementation or patch; integration still requires L1 to populate the rows and admitted source evidence.