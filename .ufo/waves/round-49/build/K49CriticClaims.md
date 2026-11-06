# K49CriticClaims — round-49 claims, pre-candidate attack

Reviewed: `plans/round-49.md` (frozen), `plans/round-49-c1.sh`, `plans/round-49-c2.sh`,
`plans/round-49-controls.sh`, the BASE receipts, `corpus/knowledge/vault-openbao-token-lease-lifecycle.md`,
`corpus/knowledge/iso-11770-3-edition-status.md`, `corpus/claim-ledger.tsv` (R12-03/R14-01),
`corpus/self-counts.tsv` (the six keys), `SCORECARD.md`, `AXES.md`, and
`scripts/hyaku/lane-addendum.md` §9.
Lane HEAD at review: `082bfb3f6baa2407df2a23c0489043495b4dce4d` (predeclaration); BASE
`89afe91878f10805921d3caa67d28d21b33226da`. No candidate commit existed at review time, so every
finding below is against the declared claim, counter, control and landing list — not against a
seat's work product. (The build wave's working-tree edits appeared while this review ran — modified
`SKILL.md`, `PROVINCE.md`, `corpus/README.md`, `corpus/claim-ledger.tsv`, the iso entry,
`corpus/stamps.tsv`, `plans/round-47.md` and untracked `corpus/openbao-token-trial.sh`. Those are
seats' work, not mine; I made no lane writes. The main agent should contrast the candidate diff with
these findings, especially §5/§8's restamp and R14-01/R12-03 migrations.)

No tool installs. The dev-server probes used the already-installed pinned `bao`
(sha256 `9c5f36287c673f386e1533e9c044169a248e4ee50dd54810fa766e95bd41b788`, `OpenBao v2.7.2`).
No token value was printed or copied. The token-shape probes started throwaway `bao server -dev`
processes on random 127.0.0.1 ports; each scratch log (which carries the dev root token) was
deleted. **The shell EXIT traps missed five of those servers**: peer `K49ExecTrial` flagged the PIDs
via `/proc/<pid>/fd/2` pointing at this scratch. All five PIDs were absent on re-check, a full
`pgrep -f 'bao server'` shows 0 live `bao server` processes with no fd under this scratch, and the
scratch tree is gone. No critic-owned `bao` process remains; if one had, it would have been killed
by explicit PID only. Receipts: `.ufo/waves/round-49/build/K49CriticClaims-receipts/`.

## Rulings (unsoftened)

| Claim | Ruling | Exact sentence | Reason and pointer |
|---|---|---|---|
| C1 as measured | **falsified** | `C1_OPENBAO_TRIAL: value = number of tests T in {T1..T5} that DISCRIMINATE, when PINS = 1 and SETUP_OK = 1 and NOSECRET = 1, else 0; target 5.` (plan:42-53) plus `a trial that detects the counter's shims (reads its PATH or the shim bytes) passes` (plan:78-79) | A trial that never starts or contacts OpenBao, and only reads the counter's PATH, scores **value=5** on the frozen counter (receipt `cheap-c1.receipt`). `DISCRIMINATE` is therefore satisfiable without executing the mechanics. The reference trial is real, so the *capability* is not disproven; the *claim as measured* is falsified — the counter assigns the target to a non-execution. §9 (lane-addendum: `Name the axis by the surface…` block) says a cheapest control that meets the target means the counter or target is wrong and must be fixed before data. The plan names the ceiling instead of closing it. |
| C1 after-state | **weakened** | `the lane executes the OpenBao token and lease mechanics its entry documents, 0 → 5` (plan:27) | "its entry documents" is broader than T1–T5. The entry documents JWT login (S014), Kubernetes invisibility (S015), Vault leases (S013) and OpenBao token rows; the trial tests five S016 token/lease rows on one `bao server -dev`. The entry's `:58` `[INFERENCE]` (Kubernetes-side revocation) is not tested by T4 (userpass). The entry still says `:9` "nothing was deployed or probed" and `:76` "kagi runs neither product"; the kill rule (plan:72-74) forbids removing those lines and the plan does not require the append-only supersession note that round 48's accepted entry carries (`corpus/knowledge/sops-age-key-rotation.md:132`). |
| C1 axis | **holds** | `C1 is a capability acquisition (axis verdict: operability)` (plan:16-17) | The surface changed is the new runnable `corpus/openbao-token-trial.sh`; operability is "runnable artifacts: … scripts that run" (`AXES.md`). The plan names the capability and the script, not the number 5. Freshness is the alternative reading (the entry's S016 rows re-verified against a live release); the plan does not say why operability wins, but the counter measures the script, so the chosen axis fits the counter. |
| C2 | **weakened** | `C2 lands a Reverify: declaration and a revision stamp for corpus/knowledge/iso-11770-3-edition-status.md and the stated counts in SKILL.md:46, PROVINCE.md:73 and corpus/README.md:65,67.` (plan:19-23); `the lane's self-description has disagreed with its own gate since round 45` (plan:84-92) | The six-key target is reachable (reference `value=0`), but only 3 of the 6 are a real gate repair (the docs-audit red); the other 3 are revision-bound stamp numbers. The reference passes while `claim-ledger.tsv` R14-01 (the source the plan cites) still expects `entries=35 row_linked=32` and R12-03 still expects `^122$` against a live 124 (receipt `ledger-reds.txt`); `claim-ledger.sh verify` would stay red. The plan's kill rules protect R25-02/R29-01/R29-02 but not R14-01/R12-03. |
| Causal separability | **holds** | `C1's counter reads neither the stamps file nor any self-count; C2's counter executes corpus/self-counts.py, which reads no trial script and no ## Measured section.` (plan:19-25) | The controls receipt is `k1-p=5` on BASE+trial+entry with no C2 change and `k2-p=0` on BASE+iso/stamp/README/counts with no C1 change (`controls-prefreeze.txt`). The counters are disjoint. The *landings* share `corpus/stamps.tsv` and the three stated counts (see §11), which the sentence above does not cover. |

## 1. C1 cheap control — the counterexample

The plan itself names the hole (plan:78: "a trial that detects the counter's shims (reads its PATH
or the shim bytes) passes"). I built exactly that control and scored it with the frozen counter:

```
fixture: /fast/scratch/hyaku/kagi-r49/K49CriticClaims/cheap-c1
  corpus/openbao-token-trial.sh  (never starts/contacts OpenBao; reads PATH)
  corpus/knowledge/vault-openbao-token-lease-lifecycle.md  (BASE + reference Measured section)
command: HYAKU_SCRATCH=/fast/scratch/hyaku bash plans/round-49-c1.sh --tree <fixture>
last line: C1_OPENBAO_TRIAL: value=5 discriminating=5 pins=1 setup_ok=1 nosecret=1 \
           real_rc=0 none_rc=2 T1:real=HOLDS,shim=BROKEN,entry=1,ok=1 \
           T2:real=HOLDS,shim=BROKEN,entry=1,ok=1 ... T5:real=HOLDS,shim=BROKEN,entry=1,ok=1
```

The trial is 7 lines (`K49CriticClaims-receipts/cheap-trial.sh`): it checks `command -v bao`, then
`case "$PATH" in */bin/sh[1-5]:*) st=BROKEN;; *) st=HOLDS;; esac`, prints five `TRIAL T<n> $st`
lines and the final `OPENBAO_TRIAL:` line. The counter's real run has PATH `$W/bin/real` (no match,
HOLDS); each shim run has PATH `$W/bin/sh1..sh5` (match, BROKEN); the no-bao run exits 2 with no
HOLDS. It passes every C1 kill rule: it loses no BASE entry line, contains no `r49-` token, and the
instruments are untouched.

Impacted axes: **operability** (the axis the claim moves) and **calibration** (a capability row could
enter on a non-execution). The round-48 C1 row's named ceiling (`K48CriticCeiling: value 5`;
`SCORECARD.md` round-48 operability row) records the same defect; a precedent does not make
`value=5` evidence of execution.

C1 delivery gap: the plan's §C1 landing list (plan:19-20) does not name the `SCORECARD.md`
`capabilities:` row or its evidence pointer (`AXES.md` §Capabilities: "Rows enter only through a round
that demonstrates the capability running"). Round 48's candidate added its row. The round-49 row must
say "dev server, five S016 token/lease tests" and point at `corpus/openbao-token-trial.sh` plus the
measured section, not at the counter alone (the counter is the cheap-control victim).

Smallest safe correction (instruments frozen; route, do not edit now):

1. Make the shim PATH components non-identifying (e.g. `$W/x1`, not `$W/bin/sh1`), so a PATH reader
   gets no signal; and
2. Bind each `TRIAL T<n> HOLDS` line and the entry's `- T<n>` line to a server-derived value the
   cheap trial cannot know without running the server (T2 `granted=5`, T4 `orphan=true`, T5
   `lease-before=1 lease-after=0`), with the counter cross-checking the entry against the real run's
   output; and
3. Add the PATH-reader as a pre-freeze control with expected **0**.

If the instruments cannot be changed before data, the honest claim is "the trial discriminates
against five named shims", not "the lane executes the mechanics" — and the closure should not enter
a capability row on the counter alone (see §5).

## 2. C1 — real trial or toy? The dev-mode ceiling

`bao server -dev` is a real OpenBao 2.7.2 binary, and T1–T5 drive real token-store and expiration
paths; this is not a mock or a docs-only trial. It is still a **dev-mode** server: in-memory storage,
auto-unsealed, a root token, one host, no TLS, no audit device, no HA/replication, no seal/unseal.
The plan's §Tests (plan:54-65) says "throwaway in-memory `bao server -dev`"; the plan's named
ceilings (plan:78-81) name "one host and one release" but **not** dev mode. The counter's
`entry_line` requires only `OpenBao 2.7.2` (counter:104-110), not "dev server"; the reference entry
section says "dev server", so a candidate that drops the qualifier still passes.

What the trial fails to establish, which the entry or a later round might overclaim:

- persistence of tokens/leases across restart or seal/unseal; revocation on seal; HA/replication;
  audit-device logging of revocations; TLS; namespaces/multi-tenant;
- periodic tokens, token roles/accessors, response wrapping, identity tokens; batch-token behaviour
  beyond "not renewable, not manually revocable";
- the entry's `:58` `[INFERENCE]` about Kubernetes-side revocation (S015/S016) — T4 uses userpass,
  not Kubernetes;
- Vault token mechanics and Vault/OpenBao parity (already excluded by the entry's `Does not
  establish`).

The claim's sentence "the mechanics **its entry documents**" (plan:27) is the overclaim: the entry
documents four clocks, JWT login and Kubernetes invisibility, not only the five S016 token/lease
rows. Smallest safe correction: narrow the sentence to "five S016 token/lease rows"; append a
`Does not establish` bullet naming dev-mode/single-host/one-release/five-test scope and the untested
`[INFERENCE]`; make the Measured heading and the capability row say "dev server". The kill rule
permits append-only.

## 3. C1 — the entry's own false sentences, and the missing supersession note

At BASE the entry says `:9` "Scope: vendor documentation only; nothing was deployed or probed" and
`:74-76` "How kagi uses this … kagi runs neither product". The plan's §C1 Problem cites exactly
these as the defect (plan:29-34). After a real trial the first is false and the second is false for
the trial's scope. The kill rule (plan:72-74) forbids any `-` line in the entry diff, so the
candidate cannot correct them; it must append. The plan's landing list (plan:19-20) and the
reference fixture (`controls/fixtures/entry-measured.ref.md`) append only the Measured section — no
supersession note. Round 48's accepted entry does append one
(`corpus/knowledge/sops-age-key-rotation.md:132` "Supersession note (append-only entry): the
`Scope:` sentence above …"). A round-49 candidate can pass `value=5` while the entry still says
nothing was probed, directly beside a "Measured" section.

Impacted axes: **calibration** (the entry's self-description vs observed state) and **depth** (a
false sentence a reader must reconcile). Smallest safe correction: require the round-48-style
append-only supersession note naming the Scope sentence, §How kagi uses this, and the `[INFERENCE]`;
no BASE line is removed, and the counter stays frozen.

## 4. C1 — the Measured section is not bound to the run

The frozen predicate (plan:48-50; counter:104-110) requires only a `## Measured (round 49` section
with a `- T<n> ` line containing `OpenBao 2.7.2`. The reference fixture's lines are generic
("T1 token TTL lapse stops the token (OpenBao 2.7.2)"), which can be written without running the
trial. The trial's real output carries `granted=5`, `orphan=true`, `lease-before=1 lease-after=0`;
the entry need not. The "Measured" label is a provenance claim not tied to the trial output.

Impacted axes: **operability** (the evidence is the script, but the entry's measured claim is not
measured) and **calibration** (a reader cannot tell the section was produced by the run). Smallest
safe correction: the entry's `- T<n>` lines must carry the observed values and the run date, and the
closure compares them with the counter's `real.out`; a future counter should check the values. The
candidate can harden the entry now without touching the frozen counter.

## 5. C1 — hidden ledger regression: the vault entry's stamp row

`corpus/stamps.tsv:55` pins the vault entry
(`4932f37f…b17298`, 176 lines, 12404 bytes). C1 appends a Measured section, so that row becomes
STALE unless restamped. The plan's C1 landing list (plan:19-20) does not name the restamp; C1's kill
rules (plan:72-77) do not check it; C1's counter reads the entry section but not `stamps.tsv`. The
C2 kill rule (plan:108-110) names "a STALE stamp the candidate **created** and did not restamp" —
the vault row is **modified**, not created, so the wording does not clearly cover it. Round 48's
landing did restamp the sops entry (its `stamps.tsv:49` row matches the live sha
`ba6fb252…33363`, 159 lines, 16221 bytes). A passing C1 can therefore leave
`claim-ledger.sh verify` red on the vault entry.

Impacted axes: **calibration** and **freshness** (the lane's gate red after a passing claim).
Smallest safe correction: add "restamp `corpus/knowledge/vault-openbao-token-lease-lifecycle.md`
(reviewed `stamp` commit)" to C1's landing, and have the closure run `claim-ledger.sh verify` and
treat a stale vault row as a C1 defect. The `stamp` mode's shrink guard means the restamp must
present the full reviewed path set (the README's `stamp PATH…` contract).

## 6. C1 — tool provenance note (not a counter finding)

The binary is sha-pinned (`9c5f3628…b788`) and the plan records that the release `checksums.txt`
and the GitHub asset digest agree. The plan also records, correctly, that `checksums.txt.gpgsig` and
`checksums.txt.sigstore.json` were **not** verified (`controls/tool-install.txt`). The provenance is
a checksum chain, not a release signature; for a secrets-domain capability that is a named
ceiling, not an admission blocker. If a verifier is available, the Sigstore bundle or GPG signature
would close it; otherwise the receipt stands as recorded. The NOSECRET ERE is adequate for the
product's token shapes: a service token (`s.`+24) and a batch token (`b.`+162) both match, as does
the `r49-<24 hex>` root shape (`tokenprobe.receipt`). The dev root token appears once in the
server's scratch log, which the trial deletes; the counter's NOSECRET scans stdout/stderr only, so
the cleanup is load-bearing.

## 7. C2 — real half vs bookkeeping

BASE (`controls/c2-base.txt`): `value=6`, `SC-SKILL-STAMPS=STALE PV-STAMPS=STALE RD-STAMPS=STALE`
(docs say 122, `stamps.tsv` has 123) and `RD-DOCS-*=SETUP` (the docs audit exits 1).

- **Real half (3 keys):** the docs audit has been red since round 45; the round-45 iso entry
  carries no `Reverify:` line and no stamp row (`DOC_AUDIT: BROKEN (entries=36 row_linked=32
  by_hand=3 undeclared=1 … unpinned=1)` at BASE). Adding `Reverify: R21-02` and a stamp row is a
  genuine gate repair, and the README's declaration counts (32/3/35) follow the audit (33/3/36).
- **Bookkeeping half (3 keys):** the three stamp numbers are a hand edit to the live R12-03 output.
  The docs repair itself adds a stamp row, so the live count becomes **124**, not the 123 the plan's
  §Problem names; the candidate must write 124 (the plan's K2-P control says "set to the live
  count", so the control is right even though the §Problem number is the BASE reading).
- The plan's §Problem conflates dates: the docs red is since round 45; the stamp red is since round
  48 (123 vs 122). The plan's own ceiling (plan:111-113) says every new stamp row re-opens the three
  keys.

Fixing the stamp count by hand teaches only "update the three lines after a stamp row". It is not a
calibration mechanism, and the plan proposes no durable binding. What would make it durable: a `stamp`/post-stamp check that runs `self-counts.py` and refuses/warns
when the three stamp keys are STALE (script-side; `claim-ledger.sh` is frozen by G1, so next round),
or a wrapper in the landing ritual. A new ledger row that runs `self-counts.py` and asserts `stale=0`
is data-only (`claim-ledger.tsv` is not frozen by G1/G2), but it raises the ledger's claim count, so
any doc number bound to that count must move too; prefer the stamp post-check. The round's G1 freezes
`claim-ledger.sh` and `self-counts.py`, so the script-side binding cannot land this round; declare it
as next-round work rather than leaving the ceiling unnamed.

## 8. C2 — the six-key target is reachable while the ledger gate stays red

I built the reference C2 fixture (a `git clone --shared` of the lane at BASE 89afe91, toplevel
asserted, plus iso `Reverify: R21-02` + stamp row + README docs 33/3/36 + three counts = live 124)
and ran the frozen counter:

```
C2_SELF_COUNTS: value=0 keys=6 lines=63 self_counts_rc=2 \
  SC-SKILL-STAMPS=OK PV-STAMPS=OK RD-STAMPS=OK \
  RD-DOCS-ROWLINKED=OK RD-DOCS-BYHAND=OK RD-DOCS-ENTRIES=OK
SELF_COUNTS: POLICY (claims=63 stale=0 unlocated=0 ambiguous=0 policy=2 setup=0)
```

Post-fix `bash corpus/claim-ledger.sh docs` last line:

```
DOC_AUDIT: CLEAN (entries=36 row_linked=33 by_hand=3 undeclared=0 missing_ids=0 unpinned=0 duplicate_reasons=0)
```

But the ledger rows still disagree:

- `corpus/claim-ledger.tsv:32` (R14-01) expects
  `^DOC_AUDIT: CLEAN \(entries=35 row_linked=32 by_hand=3 undeclared=0 missing_ids=0 unpinned=0`
  — it does not match `entries=36 row_linked=33`, so `verify` fails the very row the plan cites as
  the docs source.
- `corpus/claim-ledger.tsv:28` (R12-03) expects `^122$`; the live count is 124
  (123 even at BASE), so `verify` fails it too. The plan's §C2 Problem does not name this red.

The C2 GUARDs G1/G2 freeze `self-counts.py`, `claim-ledger.sh` and the six `self-counts.tsv` rows —
not `claim-ledger.tsv`; the migration is allowed but undeclared. The assignment milestone names
"R14-01 migration"; the frozen plan does not. The C2 kill rules protect R25-02/R29-01/R29-02 but not
R14-01/R12-03. The counter cannot see the difference (`self-counts.py` reads R14-01's command exit
code and extract, not its expected line; it reads R12-03's output, not its expectation).

Impacted axis: **calibration** — the six keys are OK while the lane's calibration gate is red.
Smallest safe correction: C2's landing must migrate R14-01's expect to `entries=36 row_linked=33`
(and the rest of the CLEAN line) and R12-03's to `^124$` (or the final live count), then run the
round's `claim-ledger.sh verify`; add the durable binding above as next-round work.

## 9. C2 — would the closure call it thin?

Yes, on the declared evidence: 3/6 keys are a real docs-gate repair, 3/6 are a revision-bound count
edit; the docs half is compliance (an entry declaration/stamp), the stamp half is bookkeeping; the
plan names the revision-bound ceiling but proposes no binding; and the six-key target can be green
while `claim-ledger.sh verify` is red on R14-01/R12-03. The claim's axis (calibration) fits the
surface (the lane's stated counts), but the move is a maintenance realignment, not a new calibration
mechanism. The closure should either (a) accept C2 as a thin but honest debt payment with the
R14-01/R12-03 migration, or (b) reject it as bookkeeping and require the durable binding. Given the
assignment's milestone includes "R14-01 migration", (a) is the minimum.

## 10. Causal separability — counters hold; landings share state

The plan's K1-P/K2-P statement matches the controls: `k1-p=5` (BASE + trial + entry, no C2 change)
and `k2-p=0` (BASE + iso/stamp/README/counts, no C1 change). The counters read disjoint surfaces
(C1: trial + entry section; C2: `self-counts.py` in a clean clone). Verified.

The landings share two pieces of state the counters do not adjudicate:

1. `corpus/stamps.tsv`: C1 must restamp the vault entry (§5); C2 adds the iso row and must set the
   three stated counts to the final live count. The iso row raises the count to 124; the vault
   restamp changes content, not the row count, so 124 is stable **if** C1 adds no new stamp row.
   Round-48 precedent does not stamp the trial script, but the plan should say so.
2. The three stated counts: they must be computed after all stamp edits. If C1 or the round's other
   seats add a stamp row, 124 becomes 125 and the three keys re-stale. One integration owner should
   run the stamp/count edits last.

The plan's sentence (plan:19-25) is true of the counters, not of the landings; the C1 §Change should
name the vault restamp and the C2 §Change should name the R14-01/R12-03 migrations.

## 11. Receipt index and commands

- `K49CriticClaims-receipts/cheap-c1.receipt` — the frozen C1 counter on the PATH-reading fixture:
  `C1_OPENBAO_TRIAL: value=5 …` (the counter's value path; the script's `exit 0`).
- `K49CriticClaims-receipts/cheap-trial.sh` — the 7-line control (never contacts OpenBao).
- `K49CriticClaims-receipts/c2fix.receipt` — the frozen C2 counter on the reference fixture:
  `C2_SELF_COUNTS: value=0 …` and `SELF_COUNTS: POLICY (claims=63 stale=0 … policy=2 setup=0)`.
- `K49CriticClaims-receipts/ledger-reds.txt` — the post-fix DOC_AUDIT line, R14-01/R12-03
  expectations, live count 124, and the C2 counter's output.
- `K49CriticClaims-receipts/tokenprobe.receipt` — service `len=26 regex=True`, batch `len=164
  regex=True`, `create_rc service=0 batch=0`, root shape True, server-log root-token lines 1.
- Read-only checks: `git rev-parse HEAD` → `082bfb3…`; `git rev-parse 89afe91` → BASE; `bash
  corpus/claim-ledger.sh docs` at BASE → `DOC_AUDIT: BROKEN (entries=36 row_linked=32 by_hand=3
  undeclared=1 … unpinned=1)`; `grep` of `corpus/claim-ledger.tsv:28,32`; `grep` of
  `corpus/self-counts.tsv` keys; `SCORECARD.md` axes/capabilities; `AXES.md`;
  `scripts/hyaku/lane-addendum.md` §9.
- Not run: the lane's full `claim-ledger.sh verify` or `self-counts.py` (the assignment excludes
  them); the full verify is the closure's check, and §8 gives the rows it will fail.

No tool was installed. Scratch (`/fast/scratch/hyaku/kagi-r49/K49CriticClaims/`) was used for the
fixtures; the C2 fixture is a local clone with one fixture commit, toplevel asserted; no lane writes
and no git mutation in the lane or fleet.
