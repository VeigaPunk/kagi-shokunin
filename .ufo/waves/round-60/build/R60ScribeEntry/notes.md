# R60ScribeEntry — notes for the AppRole `secret_id` custody entry draft

Seat: R60ScribeEntry (scribe, coverage + depth). Round 60, attempt 1. Lane
`/home/vgpnk/Projects/shokunin/kagi-shokunin`, claim BASE
`a677c78ece8e3d3b4a43dda55254f2a7b33cc1d2`. Read before work: `plans/round-60.md` (including the
§A3/§A4 amendments that landed while this seat ran) and
`corpus/lessons/round-59-verifier-spotcheck.md`. This seat wrote no git or jj command, no registry
row, and no lane file outside its own build directory.

## Artifacts written

| path | bytes | sha256 |
|---|---|---|
| `.ufo/waves/round-60/build/R60ScribeEntry/openbao-approle-secret-id-custody.md` | 47228 | `c984e32010bc87b3409e8020e60cc43249cef3da2198a3c035223cbd1cd17a46` |
| `.ufo/waves/round-60/build/R60ScribeEntry/quote-locations.md` | 11918 | `60d914bfa5015277b94736dc3a18e7f84ddf006a1c6507e74f865d7ae42d16fa` |
| `.ufo/waves/round-60/build/R60ScribeEntry/notes.md` | 9019 | `ffca557b782a52644bf93f157e9f0dce40feb5177714ace1606cf8b69469a9f3` (before this row's own edit) |

The draft is delivered at the build path, not at `corpus/knowledge/`; the L1 lands it after the
trial's receipts exist. Its last line, `SEAT-STATUS: complete`, is this seat's acceptance marker
and is not part of the entry prose — strip it when landing (the peer corpus entries carry no seat
marker). The same marker ends the seat report at `.ufo/waves/round-60/w1/R60ScribeEntry.md`.

## §Mechanics row → receipt line

All from `.ufo/waves/round-60/build/R60ExecTrial/`. The two real receipts are byte-identical
(sha256 `506a44a2a2cc89878c26a98d71f43b49c3cabacfc94a61aa896565c868c49c8d`, 256 B each), so a row
citing `receipt-ref-real.txt` is also backed by `receipt-ref-real2.txt`.

| draft row | receipt file | receipt line quoted in the draft | verified |
|---|---|---|---|
| T1 | `receipt-ref-real.txt` | `TRIAL T1 HOLDS aref=1 upd=1 ctok=1` | present in both real receipts |
| T2 | `receipt-ref-real.txt` | `TRIAL T2 HOLDS first=1 ref2=1 fresh=1` | present in both |
| T3 | `receipt-ref-real.txt` | `TRIAL T3 HOLDS imm=1 expref=1 fresh=1` | present in both |
| T4 | `receipt-ref-real.txt` | `TRIAL T4 HOLDS meta=1 cust=1 revoked=1` | present in both |
| T5 | `receipt-ref-real.txt` | `TRIAL T5 HOLDS deny=1 upd=1 allow=1` | present in both |
| run summary | `receipt-ref-real.txt`, `receipt-ref-real2.txt` | `OPENBAO_APPROLE_TRIAL: HOLDS holds=5 broken=0 error=0 bao=v2.7.2` (then `rc=0`) | both |
| shim SH1 | `receipt-shim-SH1.txt` | `TRIAL T1 BROKEN aref=1 upd=1 ctok=0 aerr=missing-secret-id berr=` | vector `BHHHH`, rc 1 |
| shim SH2 | `receipt-shim-SH2.txt` | `TRIAL T2 BROKEN first=1 ref2=0 fresh=1 err2=invalid-role-or-secret-id` | vector `HBHHH`, rc 1 |
| shim SH3 | `receipt-shim-SH3.txt` | `TRIAL T3 BROKEN imm=1 expref=0 fresh=1 err=invalid-role-or-secret-id` | vector `HHBHH`, rc 1 |
| shim SH4 | `receipt-shim-SH4.txt` | `TRIAL T4 BROKEN meta=1 cust=1 revoked=0 err=invalid-role-or-secret-id` | vector `HHHBH`, rc 1 |
| shim SH5 | `receipt-shim-SH5.txt` | `TRIAL T5 BROKEN deny=1 upd=1 allow=0 err=source-address-127-0-0-1-unauthorized-by-cidr-re` | vector `HHHHB`, rc 1 |
| fail-closed | `receipt-none.txt` | `OPENBAO_APPROLE_TRIAL: SETUP no bao on PATH` (rc 2, no `TRIAL` line) | yes |
| selftest | `receipt-selftest.txt` | `APPROLE_SELFTEST: PASS (cases=45)` (rc 0) | yes |
| selftest mutant | `receipt-selftest-mutant.txt` | `FINDING F-SHIM-MATRIX` / `APPROLE_SELFTEST: FAIL (cases=45 failed=1)` (rc 1) | yes |

Mechanical re-check this seat ran over the shipped receipts (no trial execution): each real
receipt has exactly one `TRIAL T<n>` line for n=1..5; the vector is `HHHHH`; each shim receipt has
exactly one `TRIAL T<n>` line and it is the designated test's, the other four read `HOLDS`; the
five vectors are `BHHHH`/`HBHHH`/`HHBHH`/`HHHBH`/`HHHHB`; the two real files are byte-identical.

## Capture provenance

Lane captures: `.ufo/waves/round-60/capture/S123.body` (78543 B, raw sha256
`d16f639a0b0fff901707f56ad1b916f70665e7e0675197a6a40d6473e50c0187`) and `S124.body` (145203 B,
raw sha256 `e663c1d0f956edea896db404bba7e92c7f248f74e98857a717ab063a7aae7207`). This seat fetched
both URLs independently (same desktop browser User-Agent) into its scratch and got byte-identical
bodies, so every quote sits on the lane's canonical capture. Normalized (rendered-text-v1) digests:
S123 `4230771520d9749e67efe7dd42d57e30ebfbfd105206f142227d6023003b687a` (12089 B), S124
`966641e895fb723695d66fd870f39731b43bb47b08dec2ed2601da1443f65935` (21214 B). No `set-cookie:` or
`cookie:` header line was present in either response; the server-issued request-id headers were not
reproduced in any artifact.

Quote discipline: every double-quoted page span in the draft is at most 25 words (largest 22) and
has a `count=` in the prose or a row in `quote-locations.md`. Three quoted spans are deliberately
not page text and are labelled as such in the draft (the two candidate readings in D3, rendered in
italics, and the one `plans/round-60.md` §A3 quote in D10).

## Findings for the L1 (no frozen text was amended; these are reported, not acted on)

1. **The frozen §C2 T4 wording is stronger than the receipt.** The POP says the accessor lookup
   returns metadata "including the remaining use count and TTL". The trial's `meta` flag asserts
   that `secret_id_num_uses` and `secret_id_ttl` are present and non-empty, and `custody_ok`
   additionally requires a positive use count — but the lookup runs **before any login**, so
   "configured 3" and "remaining 3" are the same number and the receipt cannot discriminate. The
   draft therefore claims presence only and marks the *remaining* reading `documented, not
   measured` (§Docs-vs-binary D3). A future round can close it with one lookup after one login.
2. **`plans/round-60.md` §A3 item 2 cites a receipt that does not contain the fact.** Item 2 states
   that a form-encoded body "parses as empty: role creation returns 204 with defaults and every
   login reads 400 invalid role or secret ID", citing `.ufo/waves/round-60/final/l1-probe.txt`. That
   file has no form-encoded leg (it shows the mount, T1–T5 and the §A4 re-measurement only). This is
   the round-59 D5/D6 class (a pointer to a receipt that does not carry the claim). The draft does
   not use the assertion as measured; §Docs-vs-binary D10 records the gap.
3. **The T3 flake is recorded only in prose, and its superseded receipt was overwritten.** One
   battery run read `T3 BROKEN imm=1 expref=1 fresh=0` (a fresh `secret_id` expired between
   generation and login under CPU jitter at `secret_id_ttl=1s`). The executor added bounded retries
   (up to three attempts, each with a newly generated secret) and overwrote the superseded receipt
   in place. The lane's convention is "last occurrence wins" for corrections, but an overwritten
   receipt is not append-only, so the flake is not independently re-checkable from the receipts —
   only from `R60ExecTrial/notes.md` §"Deviations" item 2. The draft states the retry and the flake
   in §Mechanics and §Bounds rather than hiding them.
4. **T5's literal reading is stronger than the plan's prose.** The frozen T5 text says "with
   `127.0.0.1/32` bound the same login succeeds"; the shipped trial reuses the **same**
   `role_id`+`secret_id` body after the rebind (no fresh secret), so the receipt supports the
   stronger statement that the role binding is evaluated at login time. The draft records that as
   D11 rather than as a page claim.
5. **The shims are verdict-mapping falsifiers, not binary-behaviour falsifiers.** `KAGI_APPROLE_SHIM`
   makes the trial force its own flag to 0; it proves each test's verdict is computed from its own
   flag and that one flip moves exactly one test. It cannot distinguish a held binary from a
   mis-read. The draft says so explicitly; the real-run corroboration is the two byte-identical
   runs, the L1 probe and the sentinel's independent probe.

## What this seat ran, and what it did not

Ran: two independent `curl` fetches of S123/S124; `corpus/rendered-text-v1.py locate` over every
quoted span (73 located rows, plus absence counts for 18 strings on both captures); `sha256sum` on
the captures, the receipts and the artifacts; a byte-identity comparison of the two real receipts
and of this seat's fetches against the lane captures; a programmatic cross-check that every
`TRIAL`/summary/selftest line quoted in the draft exists verbatim in the named receipt; a
secret-shape scan over this seat's artifacts.

Did **not** run: `corpus/openbao-approle-trial.sh`, `plans/round-60-c2.sh`, `plans/round-60-c1.sh`,
any controls battery, any `bao` server, or any git/jj command. The measured rows are read from the
executor's receipts, not re-executed.

## Tooling

No tool installed or upgraded: zero pacman transactions (host guard respected), zero uv/npm/cargo
installs. Used only pre-present binaries: `python3`, `curl`, `sha256sum`, `grep`, `wc`, `sed`,
`fold` and the lane's own normalizer.

## Scratch

Scratch: `/fast/scratch/hyaku/kagi-r60/R60ScribeEntry/` (fetch bodies, normalized text, wrapped
views, working draft and fragments). Not citable evidence; deleted before this seat yields.
