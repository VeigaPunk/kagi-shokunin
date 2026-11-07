# R60ScribeEntry — seat report (kagi round 60, attempt 1, w1)

Seat role: scribe (axes coverage, depth). Lane `/home/vgpnk/Projects/shokunin/kagi-shokunin`,
claim BASE `a677c78ece8e3d3b4a43dda55254f2a7b33cc1d2`. Read before work: `plans/round-60.md`
(including §A3/§A4, which landed while this seat ran) and
`corpus/lessons/round-59-verifier-spotcheck.md`. No git or jj command was run by this seat; no
registry row, no corpus path and no lane file outside this seat's build directory was written.

## Behaviour (what was produced)

`corpus/knowledge/openbao-approle-secret-id-custody.md` is drafted at
`.ufo/waves/round-60/build/R60ScribeEntry/openbao-approle-secret-id-custody.md` for the L1 to land
once the trial's receipts exist. Shape:

- title line; `source:` naming S123 (https://openbao.org/docs/auth/approle/) and S124
  (https://openbao.org/docs/api/auth/approle/) with the section anchors used and `Version 2.7.x`
  / `opened 2026-11-07`; `verified-at:` the fetch/read/locate statement; `recheck: on-release`
  naming the trial and the pages to re-open; `Reverify: R21-02` (the live sources-census row the
  peer OpenBao entries use) with the standard parenthetical;
- §Documented mechanics: the T1–T5 table (each row a located page sentence plus the frozen §C2
  assertion) and five sub-sections — the selector/secret split, reuse bounds as per-credential
  ceilings, the accessor as custody handle, CIDR binding as three layers, and user lockout as the
  confounder;
- §Mechanics (measured): one row per T1–T5 quoted from `receipt-ref-real.txt`, the byte-identity of
  the two real runs, the five shim rows with their vectors, an explicit statement of what a shim
  does and does not prove, the no-`bao` fail-closed leg and the 45-case selftest with its mutant;
- §Custody: which half is the secret, what bounds its reuse, how a non-secret accessor revokes it,
  plus the two documented custody hazards (`metadata` in plaintext audit logs, irreversible
  `local_secret_ids`) and the response-wrapping delivery path;
- §Docs-vs-binary: eleven rows (D1 the login parameter table vs its own prose; D2 what "expire"
  means; D3 the accessor lookup's use-count semantics; D4 refusal texts; D5 accessor state after
  destroy; D6 the CIDR refusal text and its `%!w(<nil>)` defect; D7 the at-least-one-constraint
  rule; D8 whether an accessor can authenticate; D9 the unbounded defaults; D10 the page's
  `curl` examples and content type; D11 when the CIDR binding is evaluated), plus a G1–G10 page-gap
  table whose absence checks are this seat's own locate counts;
- §Bounds: one binary, one host, one dev server per run, one mount, the deliberate
  `bind_secret_id=false` leg, proxy/CIDR interactions unmeasured, the T3 `1s`-TTL retry and its
  recorded flake, the one-direction CIDR rebind, Push mode / `local_secret_ids` / token-side
  parameters / response wrapping unmeasured, one page label;
- §Falsifiers: concrete break observations for each measured row, the accessor-semantics claim and
  the bounds;
- final line `SEAT-STATUS: complete` (seat marker; strip when landing).

Companions: `notes.md` (receipt → §Mechanics row map, capture provenance, findings for the L1,
what was and was not run, tooling, scratch) and `quote-locations.md` (73 located quote rows plus
the absence-check table).

## Gates

No gate was run by this seat, by design: the C1 counter, the C2 counter, the controls battery and
the trial belong to the executors and the L1. What this seat did verify mechanically:

- every `TRIAL`/summary/selftest line quoted in the draft exists verbatim in the named receipt
  (programmatic cross-check, both real receipts and all five shims);
- the two real receipts are byte-identical (`506a44a2…`, 256 B each) and read `HHHHH`;
- the five shim vectors are exactly `BHHHH` / `HBHHH` / `HHBHH` / `HHHBH` / `HHHHB`, each shim
  flipping only its designated test;
- every double-quoted page span locates at a non-zero count on the lane capture (largest 20 words);
- this seat's two independent fetches are byte-identical to the lane captures for S123 and S124;
- no secret-shaped string in any artifact of this seat.

## Touched surfaces

| path | kind |
|---|---|
| `.ufo/waves/round-60/build/R60ScribeEntry/openbao-approle-secret-id-custody.md` | new (draft for the L1 to land) |
| `.ufo/waves/round-60/build/R60ScribeEntry/notes.md` | new |
| `.ufo/waves/round-60/build/R60ScribeEntry/quote-locations.md` | new |
| `.ufo/waves/round-60/w1/R60ScribeEntry.md` | new (this report) |
| `/fast/scratch/hyaku/kagi-r60/R60ScribeEntry/` | scratch, deleted before yield |

Read-only inputs used: `plans/round-60.md`, `corpus/lessons/round-59-verifier-spotcheck.md`,
`corpus/knowledge/openbao-transit-engine.md`, `corpus/rendered-text-v1.py`,
`corpus/openbao-approle-trial.sh`, `plans/round-60-c2.sh`, the ten receipts under
`.ufo/waves/round-60/build/R60ExecTrial/`, `.ufo/waves/round-60/final/l1-probe.txt`,
`.ufo/waves/round-60/build/R60SentinelTrial/probe-groundtruth.txt`,
`.ufo/waves/round-60/build/R60ScribeRows/registry-rows.md`, `corpus/SOURCES.md`.

## Out of scope (not done here)

- Landing the entry at `corpus/knowledge/` — the L1's call, after the receipts exist.
- The `SOURCES.md` rows for S123/S124 — `R60ScribeRows` owns them; this seat only verified that its
  `source:` ids and capture digests agree with the rows being prepared.
- Running the trial, the counters or the controls battery — executor/L1 work.
- Any git/jj mutation, any commit, any push.

## Findings for the L1

1. **§C2 T4's "remaining use count" is stronger than the receipt.** The lookup runs before any
   login, so configured and remaining are both 3; `meta=1` establishes presence and a positive
   value only. The draft claims presence and marks the *remaining* reading `documented, not
   measured` (D3). Closing it needs one lookup after one login — a future round, not a plan edit.
2. **`plans/round-60.md` §A3 item 2 cites a receipt that does not carry the fact.** It asserts a
   form-encoded body "parses as empty" and cites `.ufo/waves/round-60/final/l1-probe.txt`, which has
   no form-encoded leg. Round-59 D5/D6 class. The draft does not use it as measured (D10).
3. **The T3 flake's superseded receipt was overwritten in place.** One battery run read
   `T3 BROKEN imm=1 expref=1 fresh=0`; the executor added bounded retries and overwrote the receipt.
   The flake is now recorded only in `R60ExecTrial/notes.md`, so it is not independently
   re-checkable from the receipts. The draft states the retry and the flake in §Mechanics and
   §Bounds.
4. **T5's shipped form is stronger than the plan's prose** — it reuses the same `role_id`+`secret_id`
   body after the rebind, which supports the login-time-evaluation statement (D11).
5. **The shims are verdict-mapping falsifiers.** `KAGI_APPROLE_SHIM` forces the trial's own flag to
   0; it proves the verdict is computed from that flag and that one flip moves exactly one test. It
   cannot distinguish a held binary from a mis-read. The draft says so; corroboration rests on the
   two identical real runs, the L1 probe and the sentinel's probe.

## Artifact paths and digests

| path | bytes | sha256 |
|---|---|---|
| `.ufo/waves/round-60/build/R60ScribeEntry/openbao-approle-secret-id-custody.md` | 47228 | `c984e32010bc87b3409e8020e60cc43249cef3da2198a3c035223cbd1cd17a46` |
| `.ufo/waves/round-60/build/R60ScribeEntry/quote-locations.md` | 11918 | `60d914bfa5015277b94736dc3a18e7f84ddf006a1c6507e74f865d7ae42d16fa` |
| `.ufo/waves/round-60/build/R60ScribeEntry/notes.md` | 9214 | `9f5242c124d398acefd727655bcebd67f11440d19bd9c7a04d755f67c93f8bde` |

Tooling: nothing installed or upgraded (zero pacman transactions, zero uv/npm/cargo installs); only
`python3`, `curl`, `sha256sum`, `grep`, `wc`, `sed`, `fold` and the lane's normalizer were used.

SEAT-STATUS: complete
