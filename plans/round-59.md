# Round 59 — frozen plan (kagi-shokunin)

Lane: kagi (secrets & vault ops). Round 59, attempt 1. Claim BASE
`5fa6e658f36bd9e440cb567fbbd2bfac88f868b6` (round-58 verifier spot-check tip).

Axes at BASE: depth 9, coverage 9, operability 9, freshness 9, calibration 9,
adjacency 9. Saturation line 9, stagnation window N=3; a capability entered round 57
(audit devices) and round 58 (ACL policies), so no stagnation waiver is claimed. Both
claims are declared here before any candidate work; this file is committed alone as the
predeclaration, then the instruments, then the pre-freeze control battery, then the
candidate.

Motivating evidence for the round:
- `corpus/lessons/round-58-verifier-spotcheck.md` §7 (non-author closure of round 58)
  routes five defects D1–D5 the lane must fix; none is resolved at BASE and no lane gate
  reads any of them. The round-58 lesson states `Registry 119 → 120 at the candidate`
  (`corpus/lessons/round-58.md:94`) where the claim BASE holds 117 rows; no committed
  line states the `corpus/source-fetches.tsv` delta that the spot-check measured as 6
  rows; the control set is documented three ways and two documented controls
  (`C1-F10`, `C2-F4`) never shipped (`.ufo/waves/round-58/controls/controls-prefreeze.txt`
  holds 20 controls: 9 C1, 7 C2, 2 K1, 2 K2); the round-58 report's "fixed" citation-gate
  finding has no post-fix reading; the round-58 report carries no stale-lane line.
- `corpus/knowledge/` holds no executed OpenBao **transit (encryption-as-a-service)**
  mechanic: the lane's trials cover token/lease (r49), response wrapping (r51), KV v2
  versions (r52), audit devices (r57) and ACL policies (r58). `grep -rl 'transit'
  corpus/knowledge/` matches only entries that mention the Vault transitive trust
  boundaries or NIST key-management prose, never a transit engine mechanic.

## C1 — calibration: the five round-58 routed record defects are resolved and re-checkable

Target axis: calibration (mismatch count between the lane's own statements and the
observed repository state).

**Frozen predicate (this sentence is the plan's, the counter's code and the receipt's label):**

```
C1_ROUTED: value = the number of UNRESOLVED items over POP = 5 fixed routed-defect
items (I1..I5 below), when GUARD = 1, else FAIL; target 0 (BASE 5).
An item is UNRESOLVED iff its named condition does not hold on the measured tree.
GUARD = 1 iff the checker evaluates all five items (prints population=5 with
i1..i5 each 0|1, none skipped) and, on a copy of the measured tree whose only delta
is the digit after the arrow on the LAST `Registry N → M at the candidate` line of
corpus/lessons/round-58.md changed from M to M+1, prints exactly value+1, and a
printer stub that always prints value=0 fails that same challenge.
```

Every number an item compares is derived by the checker from a named revision of the
lane repository; no constant in the checker carries a fact the measured tree asserts.

| id | routed defect | required condition on the measured tree |
|---|---|---|
| I1 | spot-check D1 | the LAST line of `corpus/lessons/round-58.md` matching the form `Registry <N> → <M> at the candidate` states N and M equal to the data-row counts of `corpus/SOURCES.md` at the round-58 claim BASE `1b13f5dad921f8901f56d30c428f89614dd74d8a` (117) and at the round-58 landing `be8705f8` (120), both derived with `git show <rev>:corpus/SOURCES.md \| grep -cE '^\|[[:space:]]*S[0-9]{3,}[[:space:]]*\|'`. Earlier occurrences are history and are not rewritten (append-only). |
| I2 | D2 | the LAST line of that lesson naming `corpus/source-fetches.tsv` carries, as the first unsigned integer after the file name, the added-row count of `git diff 1b13f5da be8705f8 -- corpus/source-fetches.tsv \| grep -c '^+S'` (6). |
| I3 | D3 | (a) the LAST line of that lesson naming `controls-prefreeze.txt` states all three counts derived from `.ufo/waves/round-58/controls/controls-prefreeze.txt` — total `CONTROL ` lines (20), `CONTROL C1-F` lines (9), `CONTROL C2-F` lines (7); (b) `plans/round-58-controls-supplement.sh` exists and names both `C1-F10` and `C2-F4`, and `.ufo/waves/round-59/final/supplement-receipt.txt` ends with the line `SUPPLEMENT: match=2 mismatch=0`. |
| I4 | D4 | `.ufo/waves/round-59/final/citation-gate-r59.txt` exists and its last line matches `CITATION_GATE: … unresolved=<U> …`; the LAST line of the round-58 lesson naming that path states `unresolved=<U>` with the same U. |
| I5 | D5 | the round-58 lesson carries a line matching `stale-lane:` (case-insensitive) that states the mission duration in whole minutes derived from the two driver-digest timestamps in `corpus/lessons/round-58-verifier-spotcheck.md` (11:54:48 → 13:36:19 = 101 min) and the word `progressing`. |

Commands:
```
python3 -I -B plans/round-59-c1-check.py --root <tree> [--no-challenge] [--json]
bash plans/round-59-c1.sh [revision]          # BASE when omitted; --tree DIR also accepted
```
Output line: `C1_ROUTED: value=V population=5 i1=.. i5=.. guard=G`.
Exit 0 iff guard=1 and V==0; 1 otherwise; 2 SETUP.

**Kill rules (each must be able to fire):**
- K1: if any item's "fix" is a wording change the item's own condition does not read
  (checked by the five forgery controls C1-F1..C1-F5 in `plans/round-59-controls.sh`,
  each of which breaks one item's substance while keeping satisfied-looking text), the
  counter must read value>0 on that forged tree; a forged tree reading 0 voids the claim.
- K2: if the checker prints value=0 on a tree byte-identical to BASE in every input file
  of an item, that item is vacuous and the claim is void; the BASE census must print
  `value=5 population=5`.
- K3: a fabricated receipt (a `SUPPLEMENT:` or `CITATION_GATE:` line with no run behind
  it) is the declared ceiling of I3(b)/I4 and is checked by the receipts themselves and a
  non-author re-run, not by this counter.

**Population census at BASE (must be measured, not assumed):** the checker run on the
BASE tree must print `value=5 population=5` and its guard leg `value=FAIL … guard=0`
(the challenge cannot fire on a tree where I1 is already unresolved — the round-58 A4
reading).

**Named ceilings:** the five items are a closed set (the routed list is fixed by the
spot-check); an item's condition is a structural read, not a semantic proof that the
fixed text is true; "last occurrence wins" is the correction convention, so a later line
that restates a fact supersedes an earlier one without rewriting it; the checker trusts
the receipt files it reads.

## C2 — operability: an executed OpenBao transit-engine trial

Target axis: operability (a new executed capability, `SCORECARD.md` §Capabilities).

**Frozen predicate:**

```
C2_TRANSIT_TRIAL: value = 5 when the trial's real run is HOLDS 5/5 in two independent
runs, each of the five falsifier shims flips exactly its designated test (baseline
vector HHHHH; SH1 -> BHHHH, SH2 -> HBHHH, SH3 -> HHBHH, SH4 -> HHHBH, SH5 -> HHHHB),
a PATH with no bao reads SETUP rc2 with no HOLDS, and a second, independent throwaway
dev server refuses to decrypt the first server's T1 ciphertext; else 0.
Target 5 (BASE 0: the trial does not exist at BASE).
POP: T1 round trip and tamper refusal; T2 rotate advances the key version while the
older ciphertext still decrypts; T3 rewrap migrates ciphertext to the newest version
without a decrypt round trip; T4 min_decryption_version refuses older ciphertext;
T5 convergent encryption gives equal ciphertext for equal plaintext+context and
different ciphertext otherwise.
```

The five tests, each grounded in the sources opened this round (S121
`https://openbao.org/docs/secrets/transit/`, S122
`https://openbao.org/docs/api/secret/transit/`, OpenBao docs 2.7.x):

| test | mechanic | observable |
|---|---|---|
| T1 | `transit/encrypt/<key>` returns `vault:v1:<base64>`; `transit/decrypt` returns the plaintext | a round trip returns the exact plaintext, the ciphertext carries a `vault:v1:` prefix and does not contain the plaintext, and a ciphertext with one base64 character changed is refused with a decrypt error |
| T2 | `transit/keys/<key>/rotate` creates a new key version; older ciphertext stays decryptable | after one rotation a fresh encryption carries `vault:v2:` while the pre-rotation `vault:v1:` ciphertext still decrypts |
| T3 | `transit/rewrap` re-encrypts a ciphertext under the newest key version without the client supplying the plaintext | after rewrap the ciphertext carries `vault:v2:` and decrypts; raising `min_decryption_version` to 2 afterwards still decrypts the rewrapped value while the original `vault:v1:` ciphertext is refused (so the rewrap did not need a decrypt) |
| T4 | `min_decryption_version` is the retirement control | raising it to 2 refuses version-1 ciphertext with a named error; lowering it back to 1 makes the same ciphertext decrypt again |
| T5 | `convergent_encryption: true` with a `context` makes ciphertext deterministic for equal plaintext+context | identical plaintext + identical context gives byte-identical ciphertext; a different context gives different ciphertext; a non-convergent key gives different ciphertext for identical plaintext |

Commands:
```
bash plans/round-59-c2.sh [revision]          # BASE when omitted; --tree DIR also accepted
bash corpus/openbao-transit-trial.sh [--work DIR]
```
Output line: `C2_TRANSIT_TRIAL: value=V tests=5 pass=P shims=K vectors=ok/5 guard=G`.
Exit 0 iff value=5; 1 otherwise; 2 SETUP.

**Kill rules:**
- K1: a PATH with no `bao` must read SETUP rc 2 with no `HOLDS` line; a counter that
  scores it voids the claim.
- K2: the trial must resolve `bao` through PATH; a trial with an absolute-path binary and
  shape-keyed output is the declared ceiling, checked by the receipts and a non-author
  probe, not by the counter.
- K3: no token, plaintext marker or key material may appear on any argv or in any printed
  line; a secret-shaped string (`hvs.`/`hvb.` token, the trial's plaintext marker) in any
  receipt voids the claim.
- K4: the clean-room leg must run a second `bao server -dev` with its own storage; a
  counter that reads the cross-server refusal from the same server voids the claim.

**Named ceilings:** a trial that shape-keys the shim vectors reads 5 without measuring
(the round-51/57/58 ceiling class); one binary (OpenBao 2.7.2), dev-server in-memory
storage, one host; `transit` signing, HMAC, key import/export, RSA/AES key types and
key-version re-encryption of stored data are not measured.

## Instruments created by this round

- `corpus/openbao-transit-trial.sh` — the trial (T1–T5, shims SH1–SH5).
- `plans/round-59-c1-check.py`, `plans/round-59-c1.sh`, `plans/round-59-c2.sh`,
  `plans/round-59-controls.sh` — instruments.
- `plans/round-58-controls-supplement.sh` — the two controls the round-58 set
  documented and did not ship (`C1-F10` printer-stub challenge, `C2-F4` single-run leg).

## Pre-freeze controls (`plans/round-59-controls.sh`)

Two no-work controls (both counters on the BASE tree: C1 value=5, C2 value=0), two
positive reference readings (a tree carrying the five fixes reads 0; a tree carrying the
trial reads 5), and the forgery / fail-closed set:

- C1-F1..C1-F5 — each breaks one item's substance while keeping satisfied-looking text;
  the checker must read exactly 1.
- C1-F6 — the checker on a tree with the round-58 lesson removed reads pop<5/FAIL.
- C1-F7 — a printer stub (always value=0) fails the challenge leg.
- C1-F8 — a `Registry` line appended *before* the correction does not move the reading
  (last-occurrence rule bites only the tail).
- C2-F1 — a trial with the T5 shim removed reads <5; C2-F2 — a no-bao PATH reads SETUP;
  C2-F3 — a trial whose clean-room leg is removed reads <5; C2-F4 — a trial whose real run
  is single-run reads <5; C2-F5 — a trial that prints HOLDS lines without a summary reads
  0; C2-F6 — a counter that accepts a shim flipping two tests reads <5.
- C2-F7 — a bao binary whose sha256 is not the pinned OpenBao 2.7.2 is SETUP.
- C2-F8 — ambient `BAO_*`/`VAULT_*` variables exported by the caller do not change the
  readings.

The battery must read `CONTROLS: match=<N> mismatch=0` before any candidate is measured,
and the receipt pins the instrument hashes.

## Shape and write scope

One v1 wave, 13 seats, under `scripts/hyaku/ufo-wave-policy.json` (band 8–16):
3 executors, 2 scouts, 2 scribes, 1 reviewer, 1 critic, 1 mutation-tester, 1 sentinel,
1 connector, 1 labrat (attack share 4/13 = 31 %). The L1 holds the canonical planner
seat. Seats return findings and files; only the L1 commits, through
`scripts/hyaku/jj-lane.sh`.

## Lane status

lane-status: open at BASE; the round-59 mission is `progressing` for as long as it has
committed lane activity inside two driver ticks and `silent` otherwise — the round-59
report states which, with the launch and landing timestamps it reads from
`.ufo/watchdog.log`. (Round-58 closure D5: a 101-minute mission whose report named only
its launch time.)
