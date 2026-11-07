# Round 58 — the round-57 routed record defects become an audited item set (C1, calibration); an executed OpenBao ACL-policy semantics trial measures the five authorization rules (C2, operability, capability)

source: S118 (https://openbao.org/docs/concepts/policies/), S119 (https://openbao.org/docs/commands/policy/), S120 (https://openbao.org/docs/api/system/policies/), all opened 2026-11-07; `corpus/lessons/round-57-verifier-spotcheck.md` (the non-author closure that routed D1–D12).

Frozen plan: `plans/round-58.md` (predeclaration `0085a5f76c9dc7e977f6606324e873d25b4fc44d`; §Amendments A1–A5, each landed before the recorded candidate reading). Claim BASE `1b13f5dad921f8901f56d30c428f89614dd74d8a`.
Instruments: `plans/round-58-c1-check.py`, `plans/round-58-c1.sh`, `plans/round-58-c2.sh`, `plans/round-58-controls.sh`; pre-freeze receipt `.ufo/waves/round-58/controls/controls-prefreeze.txt` (`CONTROLS: match=20 mismatch=0`; the earlier run that read `match=17 mismatch=5` is kept superseded as `controls-prefreeze-run2-superseded.txt`, M58-5).

## Claims

- **C1 calibration — the round-57 routed record defects, resolved and re-checkable.** Eight items
  (D1, D3, D4, D5, D6, D7+D8, D12, and the live stale basis D11) are each a structural read over
  committed bytes: the epoch-C record in `LOG.md` and `SCORECARD.md`; the epoch-C controls receipt
  re-run over the shipped instrument bytes; the S117 Gate row with a located quote, the row's
  `used-by` and the lesson's `source:` agreeing; the landing-117 / tip-120 registry-count split; the
  gate-registry row for `corpus/current-claims.py`; the round-parameterized gate with a behavioural
  `--round` probe; the live heading; `stale_basis=0`. Predicate
  `C1_ROUTED: value = unresolved items over POP = 8 when GUARD = 1, else FAIL; target 0`; BASE
  `value=FAIL` (diagnostic `value=8 population=8`); candidate `value=0 population=8 guard=1`.
- **C2 operability — OpenBao ACL-policy semantics trial (capability acquisition).** Five documented
  authorization rules executed on throwaway OpenBao 2.7.2 dev servers: T1 deny-by-default and
  exact-path reach; T2 `*` only as the last character (the sibling `bars` refused); T3 `deny`
  outranking a broader allow; T4 `+` bounded to one segment; T5 same-pattern union vs the
  highest-priority match (through client-side introspection, which the PATH-wrapper leg lies about).
  Predicate `C2_POLICY_TRIAL: value = 5 when the real run holds 5/5 twice, five shims flip exactly
  their tests, a no-bao PATH reads SETUP rc2 with no HOLDS, and a lie on the introspection flips T5
  only; else 0`; BASE `0`; candidate `5`.

## Gate

- **Admit S118** — https://openbao.org/docs/concepts/policies/, opened 2026-11-07 (HTTP 200, decoded
  body 122498 B, sha256 `a55ff1a4caf12c3a62bcaab61ff95fef1d382cba01da5dbd4521dbfbca6e1468`,
  `.ufo/waves/round-58/capture/S118.body`). Located quotes (each `count=1` under
  `corpus/rendered-text-v1.py locate`): “Policies are deny by default” (§Policies),
  “so an empty policy grants no permission in the system”, “This always takes precedence regardless of
  any other defined capabilities” (§Policy syntax), “The glob character referred to in this
  documentation is the asterisk”, “a + can be used to denote any number of characters bounded within a
  single path segment”, “we take the union of the capabilities” and “only the highest-priority match”.
  Tier A for OpenBao 2.7.x policy syntax; the trial measures T1–T5.
- **Admit S119** — https://openbao.org/docs/commands/policy/, opened 2026-11-07 (HTTP 200, 32520 B,
  sha256 `0472f29373a98f6dd1260aa6ca4d1bd80de9d4642a75c8df94bd22e47e0263e7`,
  `.ufo/waves/round-58/capture/S119.body`). Located quote: “The policy command groups subcommands for
  interacting with policies.” (§policy). It is the documented write path the trial uses.
- **Admit S120** — https://openbao.org/docs/api/system/policies/, opened 2026-11-07 (HTTP 200, 47012 B,
  sha256 `9b13c6d9456583a11f51c0aa36fc5896ff66587d980054f1c17120174288542c`,
  `.ufo/waves/round-58/capture/S120.body`). Located quotes: “A deleted policy set on a token acts as an
  empty policy” (§Delete ACL policy) and “Once a policy is updated, it takes effect immediately to all
  associated users”. The first is the API-side form of T1's consequence; the second is documented, not
  measured, and the entry says so.
- **Admit the knowledge entry** `corpus/knowledge/openbao-acl-policy-semantics.md`: documented
  mechanics table with located quotes, the KV v2 path mapping labelled as the lane's mapping, a
  `## Measured (round 58 …)` section carrying the trial's receipt lines, a bounds block and falsifiers.
- **Reject: the legacy API stub** https://openbao.org/api-docs/system/policies/ — 343 B meta-refresh
  stub (`http-equiv="refresh"` to `/docs/api/system/policies/`), no mechanism text; a row would teach
  nothing and its anchor could not be located. Flip: a served page at that path carrying parameters.
- **Reject: the `token` CLI page as a registry row** https://openbao.org/docs/commands/token/ — real
  page (200, 32638 B) but token CLI/lease ground is registered by S016/S021; the row would duplicate
  held scope. Flip: a token-CLI mechanic no held row carries.
- **Reject: the scribe's *unmeasured* readings** (mid-path `*`, `+` matching an empty segment, default
  policy contents, `list`/`scan`/`sudo`/templated policies): the trial exercises none of them, so they
  stay open questions in the entry rather than claims.
- **Spot-check result:** not self-attested. The non-author closure of this round re-opens a sample of
  these admits and rejects; this lesson records the gate, not its outside judgment.

## Mistakes

| id | class | evidence pointer | captured-by | fix |
|---|---|---|---|---|
| M58-1 | `stale-premise` — round 57 landed S115–S117 as `on-release` with no bound clock, and the ledger row R36-03 read `RELEASE_CLOCK: FAILED … unbound=3` at this round's BASE | `plans/round-36-c3.sh` at `1b13f5da`; `.ufo/waves/round-58/controls/scope-gate-base.txt` and `.ufo/waves/round-58/final/release-clock-candidate.txt` | QM63 existed and was not run on that landing | the three rows move `on-release` → `180d` (logged old→new in §Sources); the gate reads `CLEAN (on_release=32 bound=32 unbound=0 …)`; QM73 restates the duty with this red witness |
| M58-2 | `number-drift` — the round-57 lesson and SCORECARD stated the registry delta as 114 → 116 after S117 had landed (`94d72de9`), and the report cited `gates.txt` as `rows=117` while it reads `rows=116` | spot-check D5; `plans/round-58-c1-check.py` item4 | `corpus/current-claims.py` audited only round 56, so no lane gate read the round-57 surface | item4 with the landing/tip split (A3) and item6 (`--round`); the statements now read landing 117 / tip 120 and name the capture date of `gates.txt` |
| M58-3 | `landing` — the C1 checker's challenge made its "broken copy" next to the measured tree (the fleet root) and one leg wrote `Registry 114 → 120` into the live `SCORECARD.md` | observed in `git diff` at 12:20; the counter's own A3 check then read `i4=0` | none | scratch is `TMPDIR`-confined, `run_challenge` refuses a copy that resolves at/inside the measured root, the wrapper asserts the same, and the battery's C1-F1..C1-F10 re-run the legs; QM74 |
| M58-4 | `vacuous` — item6's "no round-56 literal" scan flagged the module docstring and the `--selftest` fixture bodies as hard-coded surfaces, so its first readings were about test data, not the gate | `plans/round-58-c1-check.py` item6 comments; `--selftest` 18 cases | none | the exclusion set is written down (docstring, fixture bodies, `.replace/.write/.remove` plumbing, ≤200-char bound) and QM75 makes an unwritten exclusion a defect |
| M58-5 | `overclaim` — the first control set carried expectations its instruments could not produce (`C1-F4` "1", `C1-F10` "0", `C2-F2` "0"), so five controls mismatched on the first battery | `.ufo/waves/round-58/controls/controls-prefreeze.txt` run 1 (17 MATCH / 5 MISMATCH, superseded) | the reviewer's control review | the expectations are corrected before the recorded reading (A5): F4 reads FAIL by structure, the wrapper prints FAIL when its guard fails, and C2-F2/F4 became the load-bearing pair for the counter's conjunction |
| M58-6 | `survivor` — four false-green shapes survived the first instrument: a decoy `| coverage` row, a symlinked tree, a dead `--round` that audits a fixed round, and a one-word quote | reviewer receipts `receipt-c1-decoy-row.txt`, `receipt-c1-symlink-tree.txt`; mutation survivors S1–S3 | none | each is closed in the landed bytes (unique coverage row, symlink refusal, behavioural `--round` probe, ≥6-word quote, S117-date match, existing receipt, gate-registry section + command cell), re-checked on the survivor copies |

## Routed dispositions (round-57 spot-check D1–D12)

| id | verdict | pointer |
|---|---|---|
| D1 epoch C missing from the durable record | fixed | C1 item I1; `LOG.md` §Round 57 correction; `SCORECARD.md` round-57 post-move header |
| D2 report listed epoch C above the landing commit | corrected in this round's report | the true order `03cbf656` → `d857f344` → `8d8e0588`; the filed report is not rewritten |
| D3 epoch-C receipt pinned a plan it did not ship with | fixed | `controls-prefreeze-epochC-final.txt`, `CONTROLS: match=15 mismatch=0`, five `INSTRUMENT` pins equal to the tip |
| D4 S117 had no Gate record and the lesson did not cite it | fixed | C1 item I3; the lesson's `source:` line and the S117 Gate row |
| D5 registry count stale at the tip | fixed | C1 item I4 (landing 117 / tip 120, `gates.txt` dated) |
| D6 the gate had no registry row | fixed | C1 item I5; `SKILL.md` §Gate registry — round-58 additions |
| D7 the gate was round-56-specific | fixed | C1 item I6 `--round`, behavioural probe |
| D8 the frozen checker's docstring contradicted its code | erratum, bytes frozen | `plans/round-57-c1-check.py` keeps its bytes; the authority sentence that matters now lives in `corpus/current-claims.py`, and this row records the mismatch rather than editing a frozen instrument |
| D9 wave shape (no planner L2, two executors) | met this round | 13 seats, 4 executors, 4 attack seats, 1 connector; the L1 holds the planner seat |
| D10 the lane committed the fleet prompt | why-not, integrator-owned | `.ufo/prompts/` is integrator-of-record scope; the lane did not touch it this round |
| D11 two red gates at the tip | one closed, one registered | `stale_basis=1` → 0 (C1 item I8); `CHECKLIST_RUN: BROKEN failed=7` is the absent the-janitor substrate (PROVINCE.md round-18 erratum), unchanged and carried |
| D12 anchor label drift | fixed | C1 item I7 |

## Sources

- Registry 119 → 120 at the candidate (S118, S119, S120; all tier A, `mined`, `180d`). The S115–S117
  `recheck` cells move `on-release` → `180d` (M58-1): version-scoped docs pages, no currency claim.
- Census: `/home/vgpnk/Projects/shokunin/scripts/sources-census.sh validate --root /home/vgpnk/Projects/shokunin kagi`
  — start `kagi ok` rc 0, 117 rows (`.ufo/waves/round-58/controls/census-start.txt`); end `kagi ok`
  rc 0, 120 rows, 19 standing W04 duplicate-URL warnings (unchanged in kind).
- Rows touched old→new: S115/S116/S117 `on-release` → `180d`; S118/S119 locator cells re-pointed from
  the scribe's build dir to `.ufo/waves/round-58/capture/` (byte-identical), S118 `teaches` quotes
  replaced by forms that locate; S120 added.
- Frontier: ACL policy authorization entered the coverage map as an executed capability.

## Adjacency

The connector sweep found no sibling lane holding OpenBao/Vault ACL-policy ground; `PROVINCE.md`'s
deliberate refusal (vault-side structure) is unchanged. The `~/.config/opencode` ownership question
stays reported to the integrator, never ruled here.
