# Round 49 — frozen plan (kagi, attempt 1)

BASE (claim tip at declaration): `89afe91878f10805921d3caa67d28d21b33226da` (branch `master`; the
round-48 verifier spot-check landed at this tip and admitted round 48).
Counters: `plans/round-49-c1.sh`, `plans/round-49-c2.sh` (frozen; the predicate sentences below are
the same sentences as the counters' header comments). Pre-freeze controls: `plans/round-49-controls.sh`
(each expected value written in the script before it ran; fixtures `.ufo/waves/round-49/controls/fixtures/`;
receipt `.ufo/waves/round-49/controls/controls-prefreeze.txt`). BASE receipts: `.ufo/waves/round-49/controls/`
(`c1-base.txt`, `c2-base.txt`, `census-start.txt`, `instrument-sha256.txt`, `tool-install.txt`).
Predeclaration commit: recorded in the report. No earlier attempt of this round exists.

## Axes and the stagnation nudge

All six axes sit at 9 = the saturation line (`SCORECARD.md` §Saturation: line 9, window N = 3).
A capability entered in round 48, so the nudge does not fire this round. Every axis is tied lowest
at 9, so each claim works a lowest-scoring non-retired axis. C1 is a capability acquisition (axis
verdict: operability); C2 works the owned calibration axis. No axis is retired or split.

Causal separability: C1 lands `corpus/openbao-token-trial.sh` (new) and a `## Measured (round 49 …)`
section appended to `corpus/knowledge/vault-openbao-token-lease-lifecycle.md`. C2 lands a `Reverify:`
declaration and a revision stamp for `corpus/knowledge/iso-11770-3-edition-status.md` and the
stated counts in `SKILL.md:46`, `PROVINCE.md:73` and `corpus/README.md:65,67`. C1's counter reads
neither the stamps file nor any self-count; C2's counter executes `corpus/self-counts.py`, which reads
no trial script and no `## Measured` section. Controls K1-P (C1 change only, C2 absent) = 5 and K2-P
(C2 change only, C1 absent) = 0.

## C1 — operability: capability acquisition — the lane executes the OpenBao token and lease mechanics its entry documents, 0 → 5

Problem (measured at BASE): `corpus/knowledge/vault-openbao-token-lease-lifecycle.md:9` says
"Scope: vendor documentation only; nothing was deployed or probed", and `:74-78` ("How kagi uses
this") says kagi runs neither product. The entry's OpenBao token rows (§OpenBao tokens, S016,
Version 2.7.x) are read from a page and never executed; one reading (`:58`) is `[INFERENCE]`. The
lane held no OpenBao binary and no way to check whether a 2.7.x release still behaves as S016 says.

Tool (installed this round; pacman paused host-wide): OpenBao v2.7.2 official GitHub release
tarball `openbao_2.7.2_linux_amd64.tar.gz` (sha256 `582b1f3c…cbc96`, equal to its line in the
release's `checksums.txt` and to the GitHub asset digest; `checksums.txt` sha256 `d839d376…fb77e`
equal to its asset digest) → `~/.local/bin/bao` sha256
`9c5f36287c673f386e1533e9c044169a248e4ee50dd54810fa766e95bd41b788`. The `.gpgsig` and
`.sigstore.json` assets were **not** verified (receipt `controls/tool-install.txt`).

Frozen predicate:
`C1_OPENBAO_TRIAL: value = number of tests T in {T1..T5} that DISCRIMINATE, when PINS = 1 and SETUP_OK = 1 and NOSECRET = 1, else 0; target 5.`
DISCRIMINATE(T) = the measured tree's `corpus/openbao-token-trial.sh`, under `env -i` with PATH =
counter bin dir:/usr/bin:/bin, prints exactly one `TRIAL T HOLDS …` line with the real binary **and**
exactly one `TRIAL T BROKEN …` line under T's designated falsifier shim (SH1 token-lookup-always-
succeeds, SH2 create-drops-explicit-max-ttl, SH3 create-drops-batch-type, SH4 userpass-login-returns-
a-child-token, SH5 create-drops-ttl; `plans/round-49-c1.sh`) **and** the entry carries a
`## Measured (round 49` section with a `- T<n> ` line naming `OpenBao 2.7.2`. SETUP_OK: with no bao on
PATH the trial exits 2 and prints no HOLDS line. NOSECRET: no run's output carries a token-shaped
string, the dev root token shape `r49-<24 hex>` or a `password=<32 hex>`. Fail closed: a real run
with no final `OPENBAO_TRIAL: ` line is SETUP.

Tests (OpenBao, a throwaway in-memory `bao server -dev` on 127.0.0.1; each sourced from S016):
- T1 a non-root token with TTL 2 s is alive, then refused after its TTL lapses (§Token Time-To-Live:
  "Every non-root token has a time-to-live").
- T2 an explicit max TTL is a hard cap: a renewal asking 3600 s is granted ≤ 5 s, and the token is
  refused after the cap (§Token Time-To-Live).
- T3 a batch token is neither renewable nor manually revocable (§Token type comparison).
- T4 a login through a non-token auth method (userpass) yields an orphan token; revoking the
  caller's token revokes its child but not the login token (§Token hierarchies and orphan tokens).
- T5 when a token's TTL lapses, the lease it created (a PKI certificate issued with
  `generate_lease=true`) is revoked with it (§Token Time-To-Live: "it, and its associated leases,
  are revoked").

Controls (expected values in `plans/round-49-controls.sh` before the first run):
K1-0 do-nothing 0; K1-P reference trial + entry section 5; K1-F1 constant-HOLDS 0; K1-F2 reference
forcing the real bao onto PATH (shims bypassed) 0; K1-F3 reference without the entry section 0;
K1-F4 reference with T1's after-lapse check removed 4; K1-F5 entry naming `OpenBao 2.7.1` 0; K1-F6
unpinned bao SETUP; K1-F7 trial printing a token 0; K1-F8 silent producer SETUP.

Kill rules (any fires ⇒ C1 is not admitted): the entry loses any line present at BASE (`git diff BASE
<candidate> -- <entry> | grep -cE '^-[^-]'` > 0); any committed file at the candidate matches the
dev-root-token shape `r49-[0-9a-f]{24}`; the frozen instruments (`plans/round-49-c1.sh`,
`plans/round-49-c2.sh`, `plans/round-49-controls.sh`, the fixtures) differ between the
predeclaration and the candidate.

Named ceilings (recorded, not closed): a trial that detects the counter's shims (reads its PATH or
the shim bytes) passes; a trial that calls the HTTP API directly (curl) bypasses every shim and reads
0 — the trial must drive the `bao` CLI. The trial runs one host and one release.

## C2 — calibration: the lane's stated self-counts agree with the observed repo state, 6 → 0

Problem (measured at BASE, `controls/c2-base.txt`): `python3 corpus/self-counts.py` reads
`SELF_COUNTS: POLICY (claims=63 stale=3 unlocated=0 ambiguous=0 policy=2 setup=3)`. Three STALE:
`SKILL.md:46`, `PROVINCE.md:73` and `corpus/README.md:65` state 122 revision stamps, the table holds
123. Three SETUP: the README's knowledge-entry declaration counts cannot be read because their source,
ledger `R14-01` (`bash corpus/claim-ledger.sh docs`), exits 1 — `DOC_AUDIT: BROKEN (entries=36
row_linked=32 by_hand=3 undeclared=1 … unpinned=1 …)`: the round-45 entry
`corpus/knowledge/iso-11770-3-edition-status.md` carries no `Reverify:` line and no stamp row. The
lane's self-description has disagreed with its own gate since round 45.

Frozen predicate:
`C2_SELF_COUNTS: value = number of the six frozen BASE keys {SC-SKILL-STAMPS, PV-STAMPS, RD-STAMPS, RD-DOCS-ROWLINKED, RD-DOCS-BYHAND, RD-DOCS-ENTRIES} whose line in the measured revision's python3 corpus/self-counts.py output does not start OK (a missing line counts), when GUARD = 1, else SETUP; target 0 (BASE 6).`
GUARD (each failure is SETUP, never a zero): G1 `corpus/self-counts.py` and `corpus/claim-ledger.sh`
byte-identical to BASE; G2 the six keys' rows of `corpus/self-counts.tsv` byte-identical to BASE; G3
every BASE `corpus/knowledge/*.md` still present; G4 every BASE stamps path still a stamps row; G5 the
POLICY lines are exactly PV-FEEDTOKEN-SHAPES and PV-FEEDTOKEN-SELFTEST (the operator-routed
R29-01/R29-02 boundary is kept); G6 at least 63 verdict lines. Executed in a clean `git clone
--shared` checkout of the measured revision.

Controls: K2-0 do-nothing 6; K2-P reference (iso entry `Reverify: R21-02` + stamp row, README docs
33/3/36, the three stamp counts set to the live count) 0; K2-F1 iso entry deleted SETUP; K2-F2 a BASE
stamps row deleted SETUP; K2-F3 `self-counts.py` changed SETUP; K2-F4 stamp counts only 3; K2-F5 docs
only 3; K2-F6 SKILL stamp count written 999 → 1; K2-F7 a frozen key row removed from
`self-counts.tsv` SETUP.

Kill rules: R25-02, R29-01 or R29-02 changes state or expectation; any ledger row loses its row; the
round's ledger `verify` reads a STALE stamp the candidate created and did not restamp.

Named ceiling: the stamp count is revision-bound — every round that adds a stamp row re-opens three
STALE keys until the stated counts move with it.

## Non-claim work (no counter; recorded in the lesson)

Round-48 closure defects D1 (seat completion form), D2 (quote word counts: erratum + counting rule),
D3 (enumerate protected instrument sets by path — done in this plan's G1/G2 and kill rules); round-48
routed E48-1 (append to `plans/round-47.md`); S098 `rejected` + `on-release`; SD10 into
`corpus/self-description-sweep.sh`. Each lands only if a seat delivers it checked; none is a claim.
