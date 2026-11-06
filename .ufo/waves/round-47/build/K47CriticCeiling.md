# K47CriticCeiling — C2 named ceiling: do OLD committed bodies score 11?

Seat: K47CriticCeiling (critic). Lane `/home/vgpnk/Projects/shokunin/kagi-shokunin`, branch master, BASE
`252ef1cac9f41d84639c0d1f211d0e0911196112`, predeclaration `b020d978bac91284a431710148ebb7a7950eaab8`.
Counter under test: `plans/round-47-c2.sh` (sha256 `feac1da07ee56c5b3277d8b62a92c5398775c2d0a72b6ae9a42b42f458caf308`),
plan `plans/round-47.md` (sha256 `90b4c960f84ae34fc5c57570f297f24707fc7e76a1b0a73d983aba742147b555`). Nothing in
the lane was modified; all fixtures live in `$HYAKU_SCRATCH/kagi-r47/K47CriticCeiling` and every fixture
tree was extracted read-only from the lane with `git -C <lane> archive`.

## Hypothesis (H)

A fixture tree built from `b020d978` whose `corpus/fired-reverify.tsv` points at copies of bodies the
lane already committed **before this round**, with a hand-typed `fetched_at 2026-11-06T00:00:01Z`,
scores `value=11` on the frozen C2 counter — i.e. the named ceiling `K2-C` is reachable with **zero
fetches**, not only with fresh live-equivalent bodies.

## Method

1. `git -C <lane> archive b020d978… | tar -x -C $S/tree` (BASE content, no lane write).
2. Harvested old bodies: 185 candidate `.html/.htm/.body` files committed at BASE under `.ufo/waves/`
   (excluding `round-47`), scored with the measured tree's own normalizer:
   `python3 corpus/rendered-text-v1.py locate <body> <col13 quote>` for all seven distinct quotes
   (`scan-bodies.txt`). Every one of the eleven F ids has at least one committed body that locates its
   quote.
3. Copied eleven such bodies to `<tree>/.ufo/waves/round-47/capture/S0NN.body`, wrote
   `corpus/fired-reverify.tsv` with `url` from `corpus/SOURCES.md`, `observed_release` from
   `corpus/release-clocks.tsv` col 6, `fetched_at 2026-11-06T00:00:01Z`, measured sha256/bytes,
   `quote_count` from the normalizer run, `verdict teaching-holds` (`oldbody-ledger.tsv`).
4. Scored: `C2_TREE=<tree> C2_ASOF=$(date -u +%s) HYAKU_SCRATCH=/fast/scratch/hyaku bash
   plans/round-47-c2.sh` → exit 0.

## Verdict: H HOLDS

Frozen counter, old-body fixture (`c2-frozen-oldbody.txt`, exit 0), verbatim:

```
C2_FIRED_REVERIFIED: value=11 reverified=11 gate=1 (ok=S012 S013 S014 S015 S016 S021 S022 S023 S024 S025 S026; bad=; gate-line=RELEASE_CLOCK: CLEAN (on_release=29 bound=29 unbound=0 observed=29 fired=13 derived=15))
```

Eleven rows, no network access, no body fetched on 2026-11-06; every capture is a 2026-10-21
(`d30c989`) blob already committed at BASE.

## Ids with old committed bodies (all 11 have one; table in `oldbody-vs-live.tsv`)

| id | committed body used | commit | sha256 (old) | bytes | locate K | raw == live today | normalized == live today |
|---|---|---|---|---|---|---|---|
| S012 | `.ufo/waves/round-26/sandboxes/ClockS012/v121.body` | d30c989 2026-10-21 | bc67ab47…c9cf924 | 379583 | 1 | no | **no (v1.21.x banner)** |
| S013 | `.ufo/waves/round-26/build/ClockS013-evidence/lease.html` | d30c989 | 492ffb3c…efafde | 261632 | 1 | no | yes |
| S014 | `.ufo/waves/round-26/build/ClockS014-evidence/page.html` | d30c989 | 449ef132…1785d9 | 63046 | 1 | no | yes |
| S015 | `.ufo/waves/round-26/build/ClockS015-evidence/page.html` | d30c989 | 4e3fdb7d…edbf2f | 55824 | 1 | no | yes |
| S016 | `.ufo/waves/round-26/build/ClockS016-evidence/tokens.html` | d30c989 | 52295218…85f82c | 47384 | 1 | no | yes |
| S021 | `.ufo/waves/round-26/build/ClockS016-evidence/tokens.ua.html` | d30c989 | 52295218…85f82c (same blob as S016) | 47384 | 1 | no | yes |
| S022 | `.ufo/waves/round-26/sandboxes/ClockS022/jwt.html` | d30c989 | 4b4a151d…b2638e | 386435 | 1 | no | no (param-list drift only) |
| S023 | `.ufo/waves/round-26/build/ClockS023-artifacts/lease.html` | d30c989 | 492ffb3c…efafde (same blob as S013) | 261632 | 1 | no | yes |
| S024 | `.ufo/waves/round-26/build/ClockS024-artifacts/kv-v2.body` | d30c989 | 5ebc8281…071cda | 586146 | 3 | no | yes |
| S025 | `.ufo/waves/round-26/build/ClockS025-artifacts/jwt.html` | d30c989 | 449ef132…1785d9 (same blob as S014) | 63046 | 1 | no | yes |
| S026 | `.ufo/waves/round-26/build/ClockS026.tokens.html` | d30c989 | 52295218…85f82c (same blob as S016) | 47384 | 1 | no | yes |

Seven distinct blobs serve eleven rows. Live comparison: my own re-fetch of the six distinct registry
URLs at 2026-11-06T19:35:52–53Z (`live-fetch-receipt.tsv`, HTTP 200, UA
`kagi-shokunin-round47-critic/1.0`) produced **different raw bytes for all six**, and my S012 digest
(`0ccb802d…9912fa`) is byte-identical to L1's `$HYAKU_SCRATCH/kagi-r47/L1/S012.body`, so the live layer
itself is consistent and the counter's `d30c989` bytes are objectively not what the servers return
today.

**Sharpest case, S012 (and its shared URL with S022): the accepted capture is the anchored page, not
the served one.** Normalized text of `v121.body` contains
`You are viewing documentation for version v1.21.x . View latest version .` and the header
`Vault v1.21.x`; the 2026-11-06 page carries `AuthN methods JWT/OIDC v2.x (latest)` and adds the
`unsupported_critical_cert_extensions` parameter (`x12-normalized-diff` opcodes: banner deleted,
`v1.21.x → v2.x (latest)`, one parameter replaced, one bullet added; 2730 → 2820 words). The row's
own note claims the JWT-role teaching was "re-verified on the served v2.x page" — the capture that
scored it is the pre-fire v1.21.x page. Condition (e) only asks that the quote locate somewhere in the
bytes; nothing binds the bytes to the observed release.

## Two further widenings measured (beyond the declared K2-C wording)

1. **The capture need not be a body at all.** Plan text says "byte-correct bodies"; the counter hashes
   and normalizes any bytes. A committed 8333-byte prose report
   (`.ufo/waves/round-25/build/ClockS012.md`) used as S012's capture scores
   `value=11` (`c2-frozen-mdcapture.txt`) — 45× smaller than the page.
2. **Nothing binds capture bytes to the row's URL or release.** (a)/(b) compare registry *strings*;
   (d)/(e) compare a digest the row itself supplies and quote presence. The same blob served S016,
   S021 and S026 without objection.

## Amendment candidates (measured, both refused the fixture and kept K2-P at 11)

Amendment A — condition (g): the capture digest must not equal the digest of any file committed at
BASE, unless the round's live-leg receipt records the same `(url, sha256)` with `fetched_at ≥ floor`
(the byte-unchanged escape). Implemented in `proposal-c2-amendment-A.sh` (scratch copy: `REPO` pinned to
the lane; +1.5 s for the BASE digest set, 6732 files).

| fixture | counter | value | line |
|---|---|---|---|
| old bodies, hand-typed time | frozen | 11 | `c2-frozen-oldbody.txt` |
| old bodies, hand-typed time | A | **0** | `bad=S012:stale-bytes … S026:stale-bytes` (`c2-amended-oldbody.txt`) |
| K2-P reference (L1 captures + `capture-times.tsv`, 19:29:56Z) | frozen | 11 | `c2-frozen-k2pref.txt` |
| K2-P reference | A | 11 | `c2-amended-k2pref.txt` |
| old bodies **+ one appended space each** | A | **11** | `c2-amended-1bytemutation.txt` — A is defeated by a 1-byte mutation |
| committed `.md` as S012 capture | A | 10 | `bad=S012:stale-bytes` (`c2-amended-mdcapture.txt`) |
| old bodies + receipt dated 2026-11-05T23:59:59Z | A | 0 | hatch honours the floor (`c2-amended-escape-prefloor.txt`) |

Amendment B — condition (g) with no fallback: the digest must be the one the non-author live leg
recorded for that url on/after the floor (`proposal-c2-amendment-B.sh`).

| fixture | value | line |
|---|---|---|
| old bodies, no receipt | **0** | `bad=…:unwitnessed` (`c2-amendedB-oldbody.txt`) |
| K2-P reference + receipt built from L1 captures/times | 11 | `c2-amendedB-k2pref.txt` |
| old bodies + receipt naming their own digests | **11** | `c2-amendedB-forged-receipt.txt` — residual |

K2-P stays 11 under both amendments because legitimate live digests are today's digests: none of the six
live digests occurs anywhere in BASE (`0/6732`, `base-file-digests.txt`), and L1's captures *are* the
live digests. The cheaper variant "digest ≠ BASE `source-fetches.tsv` col-3 sha" would **not** work:
declared-vs-reused digests overlap is `0/11`.

## Impacted axes and kill rules

- **Freshness (C2).** H turns the named ceiling `K2-C` from "hand-typed times over byte-correct bodies"
  into "no fetch needed at all": any pre-round committed quote-bearing file scores. `K2-C` is
  therefore an *understatement* of the ceiling — a gate-relevant fact if `K2-C` is quoted as the full
  residual risk.
- **Calibration (C1).** Untouched by this probe; the eleven F ids overlap no C1 input beyond
  `SOURCES.md` reads, and the fixture changed neither `SOURCES.md` nor `source-fetches.tsv`.
- **Kill rules.** Unaffected: `value=11`, exit 0, `release-clocks.tsv` columns 1–8 unchanged in every
  fixture (`RELEASE_CLOCK: CLEAN`, 29 bound, fired=13 in all runs).

## Smallest safe correction

Within "committed bytes + declared times" the ceiling **cannot** be closed — that is the counter's own
docstring, and B's forged-receipt row proves the residual. The smallest change that makes the attack
cost a real fetch is B, stated as:

> (g) capture sha256 **equals** the digest the lane's live-leg receipt records for the same url with
> `fetched_at ≥ 2026-11-06T00:00:00Z`, the receipt naming a witness seat other than the L1; and the
> capture digest is absent from every file committed at BASE unless that receipt is present.

A is the weaker, cheaper special case (it only forces a 1-byte mutation); it is worth having only as
defence in depth if B is judged too strong for a frozen predicate, because it does not survive the
1-byte probe. Also worth one line regardless of A/B: (h) reject a capture whose normalized text carries
a served-version banner for the row's **anchored** version (`You are viewing documentation for version
v1.21.x` here) — that is what would have caught the S012 v1.21.x body without any fetch, at zero cost,
and it is verifiable from the bytes alone.

## Receipts (this directory)

```
c2-frozen-oldbody.txt            c2-amended-oldbody.txt        c2-frozen-k2pref.txt
c2-amended-k2pref.txt            c2-frozen-live.txt            c2-amended-live.txt
c2-amended-1bytemutation.txt     c2-amended-escape-prefloor.txt c2-amended-escape-confirmed.txt
c2-amendedB-oldbody.txt          c2-amendedB-k2pref.txt        c2-amendedB-forged-receipt.txt
c2-frozen-mdcapture.txt          c2-amended-mdcapture.txt      c2-frozen-live.txt
oldbody-ledger.tsv               oldbody-vs-live.tsv           live-fetch-receipt.tsv
scan-bodies.txt                  base-file-digests.txt         base-digest-check.txt
proposal-c2-amendment-A.sh
proposal-c2-amendment-B.sh       commands.txt
```

Scratch (removed on exit; trees rebuilt by `commands.txt`): `$HYAKU_SCRATCH/kagi-r47/K47CriticCeiling/`.
