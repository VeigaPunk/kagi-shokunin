# K46ReviewerLive findings — round 46 C2 live re-observation

Non-author leg: archived 44808ced56359c98f35995178fb24a6482899263 to scratch, applied the counter's own `c2_rebind` (drop S040/S041 clock rows, bind S098 rendered-quote row, receipt + repoint), ran `python3 -B corpus/release-clock.py --root $S/tree --observe $S/obs.json` myself (rc=0; `RELEASE_CLOCK: CLEAN (on_release=29 bound=29 unbound=0 observed=29 fired=13 derived=15)`; `wrote 29 observations (failed=0 fired=13 regressed=0)`), then independently curled all 14 distinct URLs and hand-parsed every feed.

Result: **AGREE on all 29 ids, zero findings.**

- Three-way per-id compare (my obs.json vs controls/c2-positive-observe.json vs my manual parse): parsed_version and verdict identical for every row; located flags identical for all 11 quote ids.
- sha256 of response bodies identical across all three fetches for every URL — byte-identical content; no release or page edit occurred between 18:45Z (pos receipt), 18:53Z (my observe), ~18:55Z (my curl).
- Hand-parsed newest stable: sops 3.13.3 (2026-07-23), vault 2.2.1 (2026-10-23; rc/module tags excluded), openbao 2.7.2 (2026-10-26), python 3.15.2 (2026-10-25), curl 8.23.0 (2026-10-14, next 2026-12-09). All predate the observation windows.
- S017/S018 quote pages 308-redirect (trailing-slash normalization); gate followed same-origin, my `-L` refetch landed on the same bytes (sha256 match).
- S012's `v1.21.x` anchor is non-canonical for naive numeric compare; parsed_version agrees three ways and `fired` is consistent (2.2.1 past the 1.21.x line).

Receipts: obs.json copied to `.ufo/waves/round-46/build/K46ReviewerLive/obs.json`; full table in `.ufo/waves/round-46/build/K46ReviewerLive/report.md`. No tools installed; no secrets touched; web reads were public GETs only.
