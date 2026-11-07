# R51ReviewerTrial — review of the C1 reference trial and counter against S108

Reviewer: seat R51ReviewerTrial, kagi round 51. Reviewed on BASE 214d8bf530a0c87c00686493f21af15396284793
(the candidate is not landed); artifacts: reference trial
`.ufo/waves/round-51/controls/fixtures/ref/corpus/openbao-wrap-trial.sh` (201 lines), counter
`plans/round-51-c1.sh` (155 lines), plan `plans/round-51.md` §C1, S108 capture
`.ufo/waves/round-51/capture/S108.body` — sha256 verified equal to the §C1 declaration
(`a555301e8f61a407130515449309b05c4e2c7a936f8f1bdf1921e2f9cc32ed55`, 37186 B). Page text quoted below was
extracted with the lane's own `corpus/rendered-text-v1.py` (normalize + `locate`; every quote cited has
`count=1` in the capture). Pre-freeze receipt read for cross-check:
`.ufo/waves/round-51/controls/controls-prefreeze.txt` (20/20 MATCH, `CONTROLS: pass=20 fail=0`).

Scratch: `/fast/scratch/hyaku/kagi-r51/R51ReviewerTrial/` (removed at exit; receipts copied to
`.ufo/waves/round-51/build/R51ReviewerTrial-receipts/`). Refusal boundary respected: one throwaway
`bao server -dev` per trial run, random `r51-` root token in scratch only, no real vault/account/key
touched, no `op://` strings, web reads none (page text from the committed capture).

## Page sentences (S108, all located count=1 in the committed capture)

- §Overview (single use): "It provides malfeasance detection by ensuring that only a single party can ever
  unwrap the token and see what's inside."
- §Overview (lifetime): "It limits the lifetime of secret exposure because the response-wrapping token has a
  lifetime that is separate from the wrapped secret (and often can be much shorter), so if a client fails to
  come up and unwrap the token, the token can expire very quickly."
- §Response-Wrapping token operations (Lookup): "Lookup ( sys/wrapping/lookup ) : This allows fetching the
  response-wrapping token's creation time, creation path, and TTL. This path is unauthenticated and
  available to response-wrapping tokens themselves."
- §Response-Wrapping token operations (Rewrap): "Rewrap ( sys/wrapping/rewrap ) : Allows migrating the
  wrapped data to a new response-wrapping token."
- §Response-Wrapping token validation: "Perform a lookup on the response-wrapping token. This immediately
  tells you if the token has already been unwrapped or is expired (or otherwise revoked)."
- §validation (workflow order): "After prefix validation, unwrap the token." — the page's documented
  validate-then-unwrap workflow presumes lookup does not consume the token; the page never states
  non-consumption as a standalone sentence.
- §validation (creation path): "With the token information in hand, validate that the creation path matches
  expectations. … If the path is not what you expect, it is possible that the data contained inside was read
  and then put into a new response-wrapping token. (This is especially likely if the path starts with
  cubbyhole or sys/wrapping/wrap .) Particular care should be taken with kv secrets engine: exact matches on
  the path are best there."

## Live execution (my own runs, not the receipt's)

1. Reference trial under `env -i` (PATH=/home/vgpnk/.local/bin:/usr/bin:/bin, HOME/TMPDIR/--work in
   scratch):
   `rc=0`, stdout exactly:
   ```
   TRIAL T1 HOLDS first-unwrap-returns-value=1 second-unwrap-refused=1
   TRIAL T2 HOLDS wrap-ttl=2s unwrap-after-4s-refused=1 secret-still-readable=1
   TRIAL T3 HOLDS lookup-path=secret/data/t3 unwrap-after-lookup=1 lookup-after-unwrap-refused=1
   TRIAL T4 HOLDS new-token-differs=1 old-token-refused=1 new-token-returns-value=1
   TRIAL T5 HOLDS original-path=secret/data/t5 rewrapped-path=sys/wrapping/wrap
   OPENBAO_WRAP_TRIAL: HOLDS holds=5 broken=0 error=0 bao=v2.7.2
   ```
   stderr empty. Wall 8.95 s.
2. Counter in `--tree` mode on a fixture tree built exactly as `ref_tree()` of
   `plans/round-51-controls.sh` (BASE archive + reference trial + S108 row inserted after the last `| S`
   row + entry section appended), run as `HYAKU_SCRATCH=/fast/scratch/hyaku bash plans/round-51-c1.sh
   --tree <tree>`: `rc=0`,
   ```
   C1_OPENBAO_WRAP: value=5 discriminating=5 pins=1 setup_ok=1 nosecret=1 src=1(S108) real_rc=0 none_rc=2
   T1:real=HOLDS,shim=BROKEN,entry=1,ok=1 T2:real=HOLDS,shim=BROKEN,entry=1,ok=1 T3:real=HOLDS,shim=BROKEN,
   entry=1,ok=1 T4:real=HOLDS,shim=BROKEN,entry=1,ok=1 T5:real=HOLDS,shim=BROKEN,entry=1,ok=1
   ```
   (one line; wrapped here). Seven runs (real, none, SH1–SH5) executed in shuffled order, each with fresh
   random-hex bin dir, dispatcher `bao` + `.mode`/`.real` sidecars, fresh HOME/TMPDIR/--work, `env -i`,
   `timeout 600`. Matches receipt K1-P exactly.

## Per-test verdicts

### T1 — single use — verdict: WEAK (one conjunct conflates refusal with failure; counter still fails closed)

- Page sentence: "only a single party can ever unwrap the token and see what's inside." (count=1)
- HOLDS measures: first `bao unwrap` (no client token) returns the stored nonce AND second unwrap of the
  same wrapping token is refused. That is the page sentence, operationalized. SH1 (unwrap replays its first
  answer) makes the second unwrap return the cached value → `u2=1` → BROKEN; verified
  `T1:real=HOLDS,shim=BROKEN`. SH1 models exactly the named failure (a client breaking single use) and is
  T1-specific in practice (no replay without a prior success, so T2–T4 stay HOLDS under SH1).
- Wrong-reason path: the second-unwrap "refused" verdict is taken from any nonzero rc. `unwrapv` parses with
  an unguarded `json.load`; an exit-0 garbage/HTML/empty stdout raises JSONDecodeError → rc 1 → counted as
  refusal. stderr is discarded (`2>/dev/null`), so the refusal reason is never checked. The entry-section
  fixture even documents the message "`wrapping token is not valid or does not exist`" — the trial never
  asserts it. Counter impact: none in the admitted direction — with a broken unwrap CLI the FIRST unwrap
  also fails → `u1=0` → BROKEN → no credit; a first-succeeds/second-fails-for-unrelated-reason CLI is
  exactly the SH1 class. Fail-closed.
- Fix (if acted on: frozen fixture — needs a new predeclaration, see Defects): classify parse failure with
  a distinct exit code (e.g. 3) and report ERROR; or capture stderr and require the documented message for
  refusal verdicts.

### T2 — wrap TTL separate from the secret — verdict: WEAK (narrow; companion check closes most of the window)

- Page sentence: "…the response-wrapping token has a lifetime that is separate from the wrapped secret (and
  often can be much shorter), so if a client fails to come up and unwrap the token, the token can expire
  very quickly." (count=1)
- HOLDS measures: `-wrap-ttl=2s` token cannot be unwrapped after a 4 s sleep AND `bao kv get -field=v` still
  returns the nonce. Both halves of the page claim are measured (token expires; secret unaffected). SH2
  (forced `-wrap-ttl=600s`) keeps the token alive past the sleep → unwrap succeeds → `u=1` → BROKEN;
  verified `T2:real=HOLDS,shim=BROKEN`. SH2 models exactly "requested wrap TTL not honored"; the
  `-field=v` readback carries no `-wrap-ttl` and passes through the shim untouched, so only the TTL half is
  falsified — correct surgical scope.
- Wrong-reason path (the assignment's example): unwrap-after-expiry refused *because of a different error*.
  Server-level failures are caught by the companion `s=1` (the kv readback would fail too → BROKEN). What
  survives is unwrap-subcommand-level failure with the server alive: an unwrap regression, or exit-0
  garbage stdout → parse crash → "refused" → T2 HOLDS with a broken unwrap path. Counter impact: under SH2
  the same broken unwrap also fails → shim run HOLDS ≠ BROKEN → `ok=0` → value 0. Fail-closed. Timing: a
  host stall cannot produce false HOLDS (the token cannot outlive its TTL server-side); it can only turn
  infra errors into BROKEN (also fail-closed). Plan's named ceiling covers this direction.
- Fix: as T1 (distinct exit code for parse failure, or assert the expiry-flavored refusal).

### T3 — unauthenticated lookup, creation path, does not consume — verdict: WEAK (one of three conjuncts); wrong-reason "creation_path from cache" is unreachable in the real run

- Page sentences: "Lookup ( sys/wrapping/lookup ) : This allows fetching the response-wrapping token's
  creation time, creation path, and TTL. This path is unauthenticated and available to response-wrapping
  tokens themselves." (count=1) and "This immediately tells you if the token has already been unwrapped or
  is expired (or otherwise revoked)." (count=1).
- HOLDS measures three conjuncts: (a) `creation_path` == `secret/data/t3` from a lookup run with NO client
  token (`env -u BAO_TOKEN`; fresh HOME, `-dev-no-store-token`, so no token file fallback) — the page's
  "creation path" + "unauthenticated" + KV "exact matches on the path are best there" (the KV v2 request
  path is `secret/data/t3`); (b) unwrap AFTER the lookup returns the nonce — "does not consume", the
  page-presumed workflow ("After prefix validation, unwrap the token."); (c) lookup after the unwrap is
  refused — "This immediately tells you if the token has already been unwrapped". (a) and (b) are direct
  positive measurements and sound. Live: `lookup-path=secret/data/t3 unwrap-after-lookup=1`.
- Creation_path-from-cache wrong-reason: unreachable in the real run — every lookup is a fresh `bao write`
  to a fresh in-memory dev server; the CLI keeps no state (fresh per-run HOME, unauthenticated path, no
  cache layer exists client-side). A caching/lying client is a different target than the real `bao`, and
  that is exactly what SH5 falsifies (lookup replays its first answer → post-unwrap lookup claims live →
  `l2=1` → BROKEN; verified `T3:shim=BROKEN`). SH3 (lookup also unwraps) kills the "does not consume"
  conjunct (`u=0` → BROKEN; verified) and models precisely the named failure.
- Wrong-reason path that remains: conjunct (c) is rc-based, same conflation as T1/T2 (parse crash or lookup
  CLI failure reads "refused"). Counter impact fail-closed: under a broken lookup, SH5's replay also can't
  produce a live-looking answer that the real lookup didn't produce — but note SH5 would then replay
  nothing (first lookup failed → nothing cached) → shim run (c) also refused → shim HOLDS ≠ BROKEN → ok=0.
- Fix: as T1.

### T4 — rewrap migrates data, old token spent — verdict: WEAK (one conjunct); shim models the named failure exactly

- Page sentence: "Rewrap ( sys/wrapping/rewrap ) : Allows migrating the wrapped data to a new
  response-wrapping token." (count=1)
- HOLDS measures: new token differs from old, new token unwraps to the same nonce, old token is refused.
  "Migrating … to a new token" directly supports (differ + same value); "old token spent" is the
  single-use principle ("only a single party can ever unwrap") applied to the migrated data — a faithful,
  if slightly stronger-than-quoted, reading. SH4 (rewrap echoes the old token) makes `w2 == w1` → `d=0`
  AND leaves the old token live → `o=1` → BROKEN on two conjuncts; verified
  `T4:real=HOLDS,shim=BROKEN`. SH4 models exactly "rewrap does not migrate".
- Wrong-reason path: the old-token-refused conjunct is rc-based (same conflation class); `d` and `v` are
  positive checks — with a broken unwrap `v=0` → BROKEN (fail-closed at the counter: SH4 run would show
  `v` failing identically... specifically SH4's `unwrapv w2`=unwrap(w1): under a broken unwrap the real
  run reads BROKEN, not HOLDS, so no credit either way).
- Fix: as T1.

### T5 — creation path exposes a read-and-rewrap — verdict: SOUND

- Page sentences: "validate that the creation path matches expectations. … it is possible that the data
  contained inside was read and then put into a new response-wrapping token. (This is especially likely if
  the path starts with cubbyhole or sys/wrapping/wrap .)" (count=1).
- HOLDS measures three positive conjuncts: original creation_path == `secret/data/t5`, unwrapped value ==
  nonce, re-wrapped-through-`sys/wrapping/wrap` token's creation_path == `sys/wrapping/wrap` (exact match,
  per the KV "exact matches" guidance). No refusal-by-rc anywhere: any parse failure or CLI failure makes a
  conjunct fail → BROKEN, never a false HOLDS. SH5 (lookup replays its first answer) makes `p2` replay the
  run's first lookup answer (`secret/data/t3` from T3's lookup in the same run) → `p2 ≠ sys/wrapping/wrap`
  → BROKEN; verified `T5:real=HOLDS,shim=BROKEN`. (The replay crosses tests because SH5's state file lives
  in the run's bin dir for the whole trial — harmless for the counter, but the BROKEN is then witnessed via
  the replay mechanism rather than a fresh rewrap lookup; still a faithful kill of a caching client.)
- Live: `original-path=secret/data/t5 rewrapped-path=sys/wrapping/wrap`. This is the strongest test in the
  trial.

## Defect list (ranked)

1. MEDIUM-LOW — rc-conflation of "refused" with "any failure" in `unwrapv`/`lookup`
   (trial lines 96–116): unguarded `json.load` + discarded stderr (`2>/dev/null`) mean T1's
   second-unwrap, T2's expiry, T3's post-unwrap refusal and T4's old-token refusal cannot be distinguished
   from a CLI/parse failure. Demonstrated in vivo: with a fake `bao` on PATH that exits 0 printing
   `not-json-at-all`, the trial's exact `lookup` function yields `l2=0` — the trial would print
   `lookup-after-unwrap-refused=1` and credit a HOLDS conjunct (receipt
   `R51ReviewerTrial-receipts/lookup-repro.txt`); `wtok` by contrast is guarded and fails toward ERROR
   (`parse-repro.txt`). Admission integrity is intact — every conflation path I traced fails CLOSED at the
   counter (broken unwrap/lookup breaks the positive conjunct or the shim's BROKEN, → `ok=0` → value 0) —
   so this is a semantics/attribution defect, not an admit-integrity one. Proposed fix (frozen fixture —
   acting on it requires a new predeclaration since the kill rules forbid any non-comment change to
   `corpus/openbao-wrap-trial.sh` between predeclaration and candidate): give the parsers a distinct exit
   code on parse failure and report ERROR when seen; optionally capture stderr and require the documented
   refusal message.
2. LOW — the entry-section fixture (`ref/entry-section.md`, lands in
   `corpus/knowledge/vault-openbao-token-lease-lifecycle.md`) documents the error string
   "`wrapping token is not valid or does not exist`" for T1, but the trial never asserts any error string
   (stderr discarded). Measurement entry over-claims relative to the trial. Fix options within the freeze:
   none to the artifacts (both frozen); recommend the round report record this as a named gap, or a
   follow-up predeclaration makes the trial assert the string.
3. COSMETIC — counter header comment says "byte-identical across the six runs"; seven runs execute (six
   bear a dispatcher; none-mode has no `bao`). Plan §C1 says "the seven runs (real, none, SH1–SH5)". No
   behavioral impact (`for m in real none sh1..sh5 | shuf` covers all seven). Fix: comment wording only.
4. INFO (already-declared ceilings, verified consistent): shims are client-side, so tests discriminate
   against a lying CLI, not a misbehaving server (plan names this); a trial reading the sibling `.mode`
   file can still tell runs apart (K1-F5 expect=5 got=5 MATCH — the named ceiling); one OpenBao version
   (2.7.2, pin verified live by the counter's `pins=1` against sha256 `9c5f3628…`) and KV v2 only; T2's
   2 s/4 s window cannot produce false HOLDS (token cannot outlive its TTL server-side).

## Hygiene checks (all exercised, none assumed)

- No token/nonce printed: NOSECRET ERE (`(s|b|r|hvs)\.[A-Za-z0-9]{20,}` / `r51-[0-9a-f]{24}`) over my
  direct-run stdout+stderr and the counter's stdout+stderr: CLEAN. The counter's own `nosecret=1` covers
  all seven run outputs. The dev server's startup lines (which contain the root token) go to
  `$D/server.log`, removed by `cleanup` (`rm -rf -- "$D"`), never printed by the trial. Detail strings
  embed only booleans and literal paths, never values. Note for siblings: `pgrep -af 'bao server'` on this
  host prints other seats' `-dev-root-token-id=…` arguments; I used it only for process attribution and
  copied none of it into the lane tree.
- Server killed: my direct run — `pgrep -c -f 'bao server'` 0 before, 0 after. The counter run self-removed
  its scratch (`trap 'rm -rf -- "$W"' EXIT`) and no live `bao server` process on the host has its cwd in my
  scratch (five running servers attributed by `/proc/<pid>/cwd` to sibling seats' scratch dirs:
  `R51MutCounters/mut/C1-M{1,2,3,4}/work` and one 2-second-old transient in the lane root — sibling load,
  not leaks). Trial mechanics verified in code: `kill` → 5 s poll → `kill -9` → `wait`, plus
  `setpriv --pdeathsig KILL` so a SIGKILLed shell still takes the server down; traps on
  EXIT/INT/TERM/HUP all route through cleanup.
- set -u: trial runs `set -u`; every variable is initialized before use (`WORK=""`, `SRV=""`, `H/B/E=0`,
  `w=""`/`p=""/v=""/w2=""` fallbacks on every capture); `report` always receives 3 args; `mktemp` failure
  exits before the trap is armed (nothing to clean). No unbound-variable path found. Counter also
  `set -u`; associative arrays initialized before use; `verdict()` counts with an anchored ERE
  `^TRIAL T<n> (HOLDS|BROKEN|ERROR)( |$)` so a second line for the same T reads DUP and disqualifies the
  test (defensive, correct).
- python3 JSON parse failure: `wtok` guarded → wrap failures read ERROR (exit 2, fail-closed);
  `unwrapv`/`lookup` unguarded → parse crash ≡ refusal (Defect 1, demonstrated). python3 absence is caught
  up front (`command -v python3` → SETUP, exit 2).
- Path-blindness exercised live: my counter run used seven random-hex bin dirs, byte-identical dispatcher,
  fresh HOME/TMPDIR/--work each, shuffled order — `value=5` reproduces without any run-name dependence
  (F2/F3/F4 controls all read 0 in the receipt).
- SRC verified against the real table shape: fixture row has 13 `|`-fields; `$3` = source cell (contains
  the URL), `$9` = `mined` — the counter's awk indices are correct; `head -n 20 | grep -w S108` hits trial
  line 5. Live `src=1(S108)`. Entry check: heading matches `^## Measured \(round 51`, each `- T<n> ` line
  carries `OpenBao 2.7.2`; live `entry=1` ×5.

## Residual risk / verification gaps

- The counter's DISCRIMINATE is client-side by construction; a hostile *server* (or a `bao` that special-
  cases the dev server) is out of scope — plan declares this ceiling; I did not test a hostile server.
- I ran the reference fixture and one full counter `--tree` pass; I did not re-run all ten K1 controls
  myself (the pre-freeze receipt covers them; K1-P reproduced identically in my run).
- The shuf order of runs is not printed by the counter; I confirmed randomness only by code reading
  (`shuf` over the seven modes) — cosmetic.
- T2's 4 s sleep is wall-clock; on an extremely stalled host an infra error would read BROKEN (fail-closed,
  named ceiling). Not observed here (8.95 s total trial wall).
- Defect 1's fix touches frozen fixtures: any change to `corpus/openbao-wrap-trial.sh` beyond comment
  lines between predeclaration 4ad8ab7 and the candidate fires a kill rule. Recommendation: record as a
  named gap this round; fix only via a new predeclaration.
