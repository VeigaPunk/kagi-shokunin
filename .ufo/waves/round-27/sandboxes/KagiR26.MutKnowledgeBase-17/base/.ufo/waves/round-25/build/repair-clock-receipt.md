# Receipt-bound C3 repair

Candidate: `82745e2c60e726b49499b8f309529935dc4eff2b`; BASE: `4587c61a348e4528717404a68912c373f3ef4d03`.

## Scoped change

- Only implementation file changed in the candidate sandbox: `corpus/release-clock.py`. No TSV, SOURCES, stamps, or other production files changed; stamps remain at the candidate's existing 88 rows.
- Offline `evaluate` now requires a matching retained observation for every uniquely bound clock. Missing records produce `NOT OBSERVED <id>` and fail; duplicate, malformed, orphan, or field-mismatched records produce `RECEIPT-MISMATCH <id>` and fail. It compares id, clock, URL, UTC observation date, verdict, HTTP success/hash, normalized feed version, or rendered quote `located` boolean.
- Default receipt: `.ufo/waves/round-25/observe-1.json`, byte-pinned to the actual candidate file SHA-256 `b74c8ee30aaeaf7a867fbbad39ea42e94f199da69ebd01d0e391d2e8b349f92` (measured with `sha256sum`). Explicit `--receipt FILE` requires `--receipt-sha SHA256`.
- `--observe OUT.json` recaptures before evaluating the new receipt, atomically replaces an existing regular receipt, rejects symlinks, and never rewrites TSV. `quote-missing` now contributes to the live `fired` summary. `argparse` has `allow_abbrev=False`.
- Scope limit: the retained receipt is structurally compared and, for the default, byte-matched to the committed local digest. This is not provider attestation or broader observation-history trust. Explicit override trust depends on the caller-supplied digest.
- Code pointers: `corpus/release-clock.py:28,366-455,761-823,847,1555-1595`.

## Evidence

- Selftest: `env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/XReleaseClock-2-82745e2c/home TMPDIR=/fast/scratch/kagi-r25/XReleaseClock-2-82745e2c/tmp PYTHONDONTWRITEBYTECODE=1 python3 -B corpus/release-clock.py --selftest; status=$?; printf 'EXIT=%d\n' "$status"; exit "$status"` — exit 0. Stdout: `RELEASE_CLOCK_SELFTEST: PASS (67 cases)`; `EXIT=0`. Paired controls/mutations cover receipt id/clock/URL/date/verdict/version, normalized `v` equivalence, missing/duplicate/extra receipts, receipt digest mismatch, TSV mutation against a retained receipt, quote location/missing, live quote-missing fired count, recapture over a stale receipt, and unchanged TSV.
- Candidate offline command: `env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/XReleaseClock-2-82745e2c/home PYTHONDONTWRITEBYTECODE=1 python3 -B corpus/release-clock.py --root /fast/scratch/kagi-r25/XReleaseClock-2-82745e2c/lane; status=$?; printf 'EXIT=%d\n' "$status"; exit "$status"` — exit 0. Stdout: `RELEASE_CLOCK: CLEAN (on_release=28 bound=28 unbound=0 observed=28 fired=1 derived=15)`; `EXIT=0`.
- Missing-binding BASE command: `env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/XReleaseClock-2-82745e2c/home PYTHONDONTWRITEBYTECODE=1 python3 -B /fast/scratch/kagi-r25/XReleaseClock-2-82745e2c/lane/corpus/release-clock.py --root /fast/scratch/kagi-r25/XReleaseClock-2/patch-check/lane; status=$?; printf 'EXIT=%d\n' "$status"; exit "$status"` — exit 1; stdout has `UNBOUND S005` through `UNBOUND S032` and `RELEASE_CLOCK: FAILED (on_release=28 bound=0 unbound=28 observed=0 fired=0 derived=0)`. The no-binding baseline remains `UNBOUND28`.
- `git apply --check /home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-25/patches/clock-receipt-repair.patch` on a clean candidate clone — exit 0, no stdout.
- No public network was used. Builds, linters and formatters: UNRUN. Tool installs/updates: none.

Patch: `.ufo/waves/round-25/patches/clock-receipt-repair.patch`. Report: `.ufo/waves/round-25/build/repair-clock-receipt.md`.
