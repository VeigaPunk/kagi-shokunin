# SentinelBound — round 36 report

**Verdict: CLEAR on the four assigned security checks. BLOCK on one landing
condition: `SCORECARD.md:1409`.**

The four checks (credential material, unauthenticated public reads, refusal
boundary, execution surface) are clean — evidence in `review.md`. The block is a
provenance/readiness defect, which my role treats as a correctness defect: the
pushed SCORECARD cites an **untracked** seat build artifact, and that citation is
the only thing standing between the frozen C1 kill rule (`SD6 must stay 5`) and a
failing claim — while the counter the claim is measured by still prints `0`.

## What the numbers actually are (measured, with rc)

Lane HEAD `09f27e2e16c26484b2675aa2a2b1e2ca4d3d1d8d` throughout. The tree moved
while I reviewed (the L1 was landing), so every reading is bound to a snapshot.

| snapshot | pushed set | C1 | SD5 | SD6 | stale | C2 | C3 |
|---|---|---|---|---|---|---|---|
| T1 00:16–00:22Z | + F1/F2, SOURCES dates, ledger R36-01..03, c3.sh | **3** rc0 | 0 | **6** | 3 | 0 rc0 | CLEAN rc0 |
| T2 00:26Z | SOURCES reverted; SKILL/PROVINCE/README fixed | **0** rc0 | — | — | — | 0 rc0 | CLEAN rc0 |
| T3 00:29Z | + `ConnOverlap.md` created 00:25Z | **0** rc0 | 0 | **5** | 0 | 0 rc0 | CLEAN rc0 |

T3 is the state at handoff. Raw outputs: `receipts/sd4.out`, `receipts/sc4.out`,
`receipts/snapshot4.txt`; T1: `receipts/sd3.out`, `receipts/sc3.out`,
`receipts/c1split.txt`, `receipts/snapshot2.txt`.

```
T3: SELF_DESCRIPTION: MISMATCH n=5 (SD1=0 SD2=0 SD3=0 SD4=0 SD5=0 SD6=5 SD7=0 SD8=0 SD9=0)
T3: SELF_COUNTS: POLICY (claims=63 stale=0 unlocated=0 ambiguous=0 policy=2 setup=0)  rc=2
T3: bash plans/round-36-c1.sh -> 0   rc=0
T3: bash plans/round-36-c2.sh -> 0   rc=0
T3: bash plans/round-36-c3.sh -> RELEASE_CLOCK: CLEAN (on_release=30 bound=30
    unbound=0 observed=30 fired=15 derived=15)   rc=0
    python3 corpus/release-clock.py --selftest -> PASS (116 cases)   rc=0
```

## Why BLOCK — `SCORECARD.md:1409`

```
| adjacency | 9 → 9 | The connector sweep over the sibling lanes is the sole-ground
  check for the four cited feeds; ownership partition unchanged. |
  Row `R17-02`; `.ufo/waves/round-36/build/ConnScope/ConnOverlap.md` |
```

SD6 is defined as the `UNRESOLVED` lines of `bash corpus/claim-ledger.sh
citations` (sweep L22, L398-412). Measured A/B, with `SCORECARD.md` bytes
identical in both runs (`a53c0aa0…`):

- **T1** — `.ufo/waves/round-36/build/ConnScope/ConnOverlap.md` did not exist yet
  (created 00:25Z) → `MISMATCH SD6 SCORECARD.md:1409 … (ufo)` → **SD6 = 6**.
- **T3** — the file exists → the citation resolves → **SD6 = 5**.

`plans/round-36.md` §C1 kill rule: *"SD6 differs from 5 at the landing revision,
or any non-owned verifier file is edited → C1 fails, admission withheld."*

The file is **untracked** (`git status` lists `.ufo/waves/round-36/build/` as
`??`). So at the landing revision the outcome is:

- if `.ufo/waves/round-36/build/ConnScope/ConnOverlap.md` is **committed in the
  same landing** → SD6 = 5, kill rule satisfied, C1 = 0 admissible;
- if it is **not** committed → SD6 = 6 at the landing revision, the frozen kill
  rule fires, and **C1 fails while `bash plans/round-36-c1.sh` still prints 0** —
  the counter the claim is stated in cannot see its own kill rule.

Either the citation at `SCORECARD.md:1409` must name a path that is committed
with it, or the landing must include that file. That is the one line that must
change (or be paired with its artifact).

Two block items from my T1 pass are **resolved at T3** and no longer stand:
`SCORECARD.md:1404`'s "C1 4 → 0" is now true (measured 0), and
`corpus/claim-ledger.tsv:98` `R36-01`'s `^0$` expectation now matches. The
`stale=3` component (SKILL.md:46, PROVINCE.md:73, corpus/README.md:64 claiming
79 ledger rows against 82) was fixed between T1 and T3 (`stale=0`).

## The four assigned checks — CLEAR

| check | result |
|---|---|
| 1. credential material / private paths / user names / tokens | **0 hits** across the pushed set for `op://`, `ghp_`, `/home/`, `@`, `vgpnk`. The 6 `sk-` lines in `SCORECARD.md` are the substring in `handler-on-disk-state` (historical, none added this round); the 1 `@` is `"$@"` in a historical snippet (L112). Every ≥32-char token is a sha256 content digest of a public body, the receipt pin, a public URL path, or a selftest callable — no credential shape. |
| 2. unauthenticated public reads | 30/30 records `http_status 200`, all `https`, 7 public hosts, no userinfo, no query, no auth-ish field, bodies not stored. Request path sets only `User-Agent` (L751); `ProxyHandler({})` (L294) blocks credentialed env proxies; userinfo/query/secret-shaped paths refused; redirects same-origin; `--selftest` PASS 116 rc0 asserts `Authorization is None` and no proxy handler. |
| 3. refusal boundary | Quotes from `PROVINCE.md:6`, `PROVINCE.md:83`, `corpus/QUALITY.md:24` (QA5) in `review.md`. Zero ref paths, zero vault/item/field names, zero `op` invocations; the four cited SOURCES rows carry public URLs, tags, titles and located public quotes only. |
| 4. execution surface of F1-F4 (+T1 additions) | F4 = three string literals; default receipt path root-relative; `--receipt` still requires `--receipt-sha` (64 lowercase hex). Ledger rows `R36-01..03` are relative `bash plans/…` commands; `plans/round-36-c3.sh` is 6 lines (`exec python3 corpus/release-clock.py`, `bash -n` rc0). No absolute path, no unquoted expansion, no `op` surface. Fail-closed proved: missing default receipt → rc1 `NOT OBSERVED`; tampered receipt → rc1 `RECEIPT-MISMATCH`; real tree → rc0 CLEAN. |

## Snapshot at handoff (T3, 2026-11-05T00:29Z)

```
a53c0aa0df9ed85a193c4d3300943ebe4268e5e463222483a881ae792b2a3983  SCORECARD.md
757788698c53ca604aab92816f927a074a4125a0c10de4efcf5811da3aa54c62  corpus/claim-ledger.tsv
5356c3aa812b5109ddcf70b7caa105667eb0dd1655bff313bce4620c3e4b1284  corpus/release-clocks.tsv
b18444f8f821c314719c91acf83bba3ad76731c7f787995b2783b1db8d2fa960  corpus/release-clock.py
adc20b1eb861dcad30cfada0b1912240e5bde8a88ddf3ec1344302bee266f759  plans/round-36-c3.sh
d574e503a26457d863ee4e8ca45b2e8f4acf567071036f1d1e13ae265f89c478  SKILL.md
aeb578c971fe55f36c221ae28f2de1415a50701e01c2311f18ab76a37042503b  PROVINCE.md
d351f8b040d1c27788216a3ad88b53c18f1de5bfd1bf52fc79aae9bd4fdde887  corpus/README.md
3f611eec30d4a48f4f389bb1a630551d77110d92fb97eee954eeb6f7c8558727  .ufo/waves/round-36/controls/observe-live.json
```

The receipt digest recomputed here equals the frozen claim, the F4
`DEFAULT_RECEIPT_SHA256` and `plans/round-36.md`. `corpus/SOURCES.md` is at
`b974504e…` = HEAD (the T1 date edits were reverted before T2, so the four cited
rows ship unchanged at T3).

## Routed, pre-existing (not this round's push; no edit rights here)

- **68 tracked `.ufo/**` files carry `set-cookie:`**, e.g.
  `.ufo/waves/round-26/build/ClockS011-evidence/feed.headers:15` (`_gh_sess=…`,
  `logged_in=no`), `:16` (`_octo=…`), and
  `.ufo/waves/round-26/build/ClockS005.headers.txt:10` (`unleash-session-id=…`).
  Anonymous and short-lived, no account scope — low severity, but the "session
  id" class QA5 forbids. Round 36 itself captures no headers.
- **`corpus/SOURCES.md:117`** carries
  `/home/vgpnk/Projects/shokunin/.tower/worktrees/kaika/…` — host-private path
  plus the user name in a tracked artifact. Pre-existing, untouched.
- **`plans/round-36-c2.sh` trusts the receipt by path, not digest** (`-s` and
  `format` only); the sha256 pin lives only in `release-clock.py`'s default path
  and the plan prose.
- **F3 scope:** all 30 TSV rows changed — 15 moved `observed_version` (exactly the
  C2 population; the 3 keeping `fired` are S012/S027/S028 as the plan says) and
  15 only moved `observed_at` + note. The second group is receipt-grounded and
  true, but C2 does not measure it. `anchored_version`, `clock`,
  `feed_source_id`, `feed_url` changed on no row.

## Dead ends / limits

- The lane tree moved under the review (four snapshots). A reading taken at T1
  (C1 = 3, SD6 = 6) is **not** the T3 reading; both are recorded with hashes
  rather than one overwriting the other.
- The SD6 A/B is empirical, not a fixture: `SCORECARD.md` bytes were identical
  (`a53c0aa0…`) in both runs, and only the cited file's existence changed. I did
  not build an isolated `claim-ledger.sh citations` fixture (the gate is
  documented as slow on this host, >300 s).
- `self-description-sweep.sh` and `self-counts.py` return
  `SETUP missing PROVINCE.md under root` from a scratch cwd — they resolve root
  from cwd, so all readings were taken with cwd = lane root (read-only).
- Receipt body digests cannot be re-verified offline; only presence and shape
  were checked. No network was used by this seat.
- No tool was installed or upgraded; no pacman transaction attempted.

## Files

- `.ufo/waves/round-36/build/SentinelBound/review.md` — full evidence, raw grep output, refusal quotes
- `.ufo/waves/round-36/build/SentinelBound/report.md` — this file
- `.ufo/waves/round-36/build/SentinelBound.md` — report-path copy
- `.ufo/waves/round-36/build/SentinelBound/receipts/` — snapshot hashes, sweep/self-counts
  outputs, c1/c2/c3 outputs, selftest output, fail-closed fixture outputs
- scratch `/fast/scratch/hyaku/kagi-r36/SentinelBound/` removed after copying
