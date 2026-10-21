# kagi-shokunin — round 6 aggregator audit

**Provenance:** auditor = aggregator L1 round-6, non-author review (lane `kagi` authored none of the
audited changes); date 2026-09-28, clock `date -u` → `Mon 28 Sep 2026 09:24:16 PM UTC`; audited
repo `kagi-shokunin` at HEAD `e64e81b` (`round-9: freshness axis-move — drift gate with committed
baselines, transcript-gate correction`), working tree clean. Axis ownership per `MISSION.md:18`:
freshness + calibration. All evidence is a command re-run at audit time; no secret value, token,
cookie, op-ref path, or private-file digest appears in this entry (sweep: §Re-executed citations
row 14). **Anchor revision:** `PROTOCOL.md`/`ROADMAP.md` were working-tree-modified by a concurrent
protocol-lane edit when read (`sha256` `9e700d691307…` / `d9a6ad856cf7…`); line numbers are soft, the
quoted clause text is the durable pointer.

## Verdict

**Not conformant.** Failed rule: **CORPUS.md rule 4 — counts carry their command** — falsified by the
committed lesson `corpus/lessons/round-9.md:175` ("The delivered 445-line revision is green") against
`wc -l corpus/drift-pins.sh` → `451` and `git show e64e81b:corpus/drift-pins.sh | wc -l` → `451`
(no 445-line blob exists: `git log --all --oneline -- corpus/drift-pins.sh` → `e64e81b`, `5f55ba8`
only), and self-contradicted inside the same commit by `LOG.md:147` ("451 lines").

Rules 1, 2, 3, 5, 6, 7, 8, 9, 10 **pass** on the re-executed sample: 14/14 knowledge entries open
with a source line, lessons cite their round, 31/31 `corpus/README.md` rows resolve to files on disk
and vice-versa (bidirectional, zero orphans), the credential sweep is clean, and the append-only rule
holds (`git show --stat e64e81b -- corpus/lessons/round-8.md` → empty; only `round-9.md` added).

Consequential defect outside the corpus rules, from the same root cause (self-assessment counts
written without a counting command): the committed `SCORECARD.md` depth cell carries four falsified
numbers — see defect 2.

## Re-executed citations

| # | Claim (file:line) | Command | Observed | Pass |
|---|---|---|---|---|
| 1 | baseline = 15 rows (`corpus/README.md`, `PROVINCE.md`, `SCORECARD.md`) | `wc -l corpus/drift-baseline.tsv` | `15` | ✅ |
| 2 | symbol pins = 19 (`corpus/README.md`, `drift-gate.md`) | `grep -cv '^#\|^$' corpus/drift-symbols.tsv` | `19` | ✅ |
| 3 | "6 private 0600 files carry `-`" (`corpus/README.md`) | awk field-4 census + `NOHASH` array | `6` / `6` | ✅ |
| 4 | gate = 451 lines, sha `c138d34c…0feb` (`LOG.md:147`, `drift-gate.md:3`) | `wc -l`; `sha256sum` | `451`; `c138d34c7f0d…0feb` | ✅ |
| 5 | scan = 282 lines, sha `2d60981b…3a23` (`LOG.md:196`) | `wc -l`; `sha256sum` | `282`; `2d60981b19…3a23` | ✅ |
| 6 | scan baseline `HITS=2 (cells=888 patterns=32+5 warns=2)` (`corpus/README.md`, r9 report) | `bash corpus/transcript-scan.sh` | `TRANSCRIPT_SCAN: HITS=2 (cells=888 patterns=32+5 warns=2 schema-absent=0)`, exit 1, 5/5 tripwires `rows=0` | ✅ |
| 7 | drift gate LIVE (`SCORECARD.md` post-move) | `bash corpus/drift-pins.sh`; `--selftest` | `DRIFT_PINS: CLEAN (files=15 symbols=19)` exit 0; `DRIFT_SELFTEST: PASS (13 cases)` exit 0 | ✅ |
| 8 | gate detects drift (`SCORECARD.md`, `LOG.md`) | scratch baseline copy with one sha → `deadbeef…`, run `--baseline /tmp/…` | `DRIFT …/opencode.json sha deadbeef0000->a318e719a04b`; `DRIFT_PINS: DRIFT (files_ok=14 files_bad=1 symbols_ok=19 symbols_bad=0)`, exit 1 | ✅ |
| 9 | usage error exits 2 (`drift-gate.md`) | `bash corpus/drift-pins.sh --baseline` | `drift-pins: --baseline needs a path`, exit 2 | ✅ |
| 10 | "pins verifiable for only 2 of 13 files" (`PROTOCOL.md:453-454`, `SCORECARD.md`) | each of v1's 13 paths tested for an abbreviated digest in the `ea77bf0` tree (`git grep -F -c`) | `the-janitor` (4 files), `client.py` (1 file) → `2/13`; v1 script stored nothing (`git show ea77bf0:corpus/drift-pins.sh \| grep -c baseline` → `0`) | ✅ |
| 11 | `_serve` unsets 20 cloud-key vars (r9 correction 18→20) | `sed -n '186,226p' ~/.local/bin/the-janitor \| grep 'unset ' \| … \| grep -cE '^[A-Z_]+$'` | `20` | ✅ |
| 12 | r9 line-ref corrections (`janitor-lifecycle.md` L121–135, `op-cli-surface.md` L183, `handler-trust-boundary.md` `client.py` L22–38, `cdp-bridge-1password.md` L22–26) | `sed -n` on the host files at those lines | `cmd_request() {`; `rm -f "$SESSION_FILE"`; `def request(…) -> object:`; knob table row | ✅ |
| 13 | "11 tables" scanned / 5 tripwires (`transcript-hygiene.md:26`) | `grep -c '^SCAN_COLS\[' corpus/transcript-scan.sh`; tripwire string | `11`; 5 tables | ✅ |
| 14 | credential sweep clean (`corpus/README.md`, `LOG.md`) | `grep -rnE <scheme \| sk-{16,} \| PRIVATE KEY \| ghp_ \| eyJ> corpus` | 44 matching lines in 20 files, **all prose/schematic scheme mentions**; token classes (`sk-`, key header, `ghp_`, `eyJ`, `gsk_`, `xai-`) → `0` each; strict ref-shape sweep → 1 line (`transcript-scan.sh:242`, synthetic scratch seed) | ✅ |
| 15 | pin data is hygienic (`LOG.md`, sentinel policy) | `grep -c <scheme> corpus/drift-baseline.tsv corpus/drift-symbols.tsv`; the 10 live op.env key names tested `grep -qF` against both TSVs | `0`/`0`; `keys scanned: 10 / appearing literally: 0` | ✅ |
| 16 | index = disk (`corpus/README.md`) | normalize rows to paths, `comm -13`/`comm -23` against `ls knowledge lessons` + the 4 gate artifacts | both empty → 31 rows ↔ 31 files | ✅ |
| 17 | "The delivered **445**-line revision is green" (`corpus/lessons/round-9.md:175`; `LOG.md:215`) | `wc -l corpus/drift-pins.sh`; `git show e64e81b:corpus/drift-pins.sh \| wc -l` | `451`; `451` | ❌ **rule 4** |
| 18 | `SCORECARD.md:16` depth counts (16-row table / 13-row failure / 15-item checklist / 25 anti-patterns / `Source basis:` prefix on every knowledge entry) | section-aware awk/grep on `git show ea77bf0:SKILL.md` and on HEAD `SKILL.md`; `grep -l '^Source basis:' corpus/knowledge/*.md \| wc -l` | `15`/`16`; `13`/`13`; `13`/`14`; `21`/`24`; `6/14` | ❌ (defect 2) |

## Defects

1. **major — falsified count "445-line revision" (rule 4 / calibration).**
   Standing claim: "The delivered 445-line revision is green (verified repeatedly: `CLEAN 15/19`,
   13-case selftest)" and "the committed 445-line revision is green".
   Where: `kagi-shokunin/corpus/lessons/round-9.md:174-175`; `kagi-shokunin/LOG.md:215`.
   Falsified by: `wc -l corpus/drift-pins.sh` → `451`; `git show e64e81b:corpus/drift-pins.sh | wc -l`
   → `451`; `git log --all --oneline -- corpus/drift-pins.sh` → `e64e81b`, `5f55ba8` (30 lines) —
   no 445-line blob ever existed; the same file's `LOG.md:147` says `451 lines`.
   Required correction form: **appended entry** — a `corpus/lessons/round-10.md` correction plus a new
   `LOG.md` entry recording `451`. Never rewrite `round-9.md` (append-only, both directions).
   Owning lane: kagi.

2. **major — four falsified counts in the committed SCORECARD depth cell.**
   Standing claim (`SCORECARD.md:16`, pre-move table measured at `ea77bf0`): "a **16-row** decision
   table, a **13-row** failure table … a **15-item** hygiene checklist, **25** anti-pattern bullets …
   each `corpus/knowledge/*` entry opens with a `Source basis:` line".
   Where: `kagi-shokunin/SCORECARD.md:16`.
   Falsified by (awk per section; `git show ea77bf0:SKILL.md` vs `SKILL.md`):
   decision table `15` at `ea77bf0` / `16` at HEAD; failure table `13`/`13` ✅; checklist `13`/`14`
   (`grep -c '^[[:space:]]*- \[ \]'`); anti-pattern bullets `21`/`24`;
   `grep -l '^Source basis:' corpus/knowledge/*.md | wc -l` → `6` of `14` (the other 8 open with
   `Source:`/`Sources:`; `grep -l '^Source' …` → `14/14`, so the *substance* holds and the literal
   prefix generalization fails).
   Required correction form: correct the cell in place **with the counting commands inline**
   (`SCORECARD.md` is lane-owned, not append-only) + a `LOG.md` entry. Owning lane: kagi.

3. **major — stale integrator debt recorded against kagi in `ROADMAP.md`.**
   Standing claim: "Three `SHONEN.md` files still must regenerate to the round-8 embedded template:
   kagi (4 bare `[x]`s)".
   Where: `ROADMAP.md:46-47` (main repo, integrator-owned).
   Falsified by: canonical-seed diff of `SHONEN.md` (seed = `PROTOCOL.md:469-476`, `<name>`
   substituted, `[x]`→`[ ]`, evidence lines removed) → `exit=0` (byte-identical modulo `<name>`, the
   box character, and one indented evidence line per box); `grep -c '\[x\]' SHONEN.md` → `4`
   (`[~]` 0, `[ ]` 0); shipped in `e64e81b`.
   Required correction form: integrator edits `ROADMAP.md` (only integrator roles write main-repo
   files). Owning lane: protocol/integrator.

4. **major — the `[x]` marks do not satisfy the promotion gate as written.**
   Standing claim: `SHONEN.md` boxes are "marked from the round-9 reviewer lane's verdicts, not from
   self-assertion", with "a named non-author verifier per box".
   Where: `kagi-shokunin/SHONEN.md:5,7,9,11` (+ evidence lines `:6,8,10,12`).
   Falsified by: `grep -rn KagiR9Reviewer` over the whole shokunin tree → **only** `SHONEN.md:6`
   (the id resolves to no report, transcript, or agent record); boxes 2 and 4 name no verifier id at
   all (box 2 cites `LOG.md` round-3 — author work; box 4 cites "round-9 connector/reviewer" lane
   names). Per `PROTOCOL.md:43-47` any `[x]` carrying no named non-author verifier counts as `[~]`;
   per `ROADMAP.md:39-41` no kagi report carries a conforming `SHONEN` heading
   (`grep -cE '^#{1,6} *SHONEN' .ufo/reports/round-9/kagi.md` → `0`; fleet-wide
   `grep -rLE '^#{1,6} *SHONEN' .ufo/reports/round-*/*.md | wc -l` → `51` of `61`), so the round-9
   assessment is author-asserted.
   Required correction form: appended `LOG.md`/lesson entry re-marking boxes 2 and 4 as `[~]`, or
   supplying a resolvable verifier id + evidence pointer for each `[x]`. Owning lane: kagi.

5. **major — round-5 routed defects never landed (uncorrected after routing ×4 rounds).**
   Standing claims (aggregator-owned mirror lesson, `corpus/lessons/round-5-aggregator-mirror-bare-path-and-unclosed-prereq.md`):
   (a) every `handoff-status.json` mention in `SKILL.md` must carry its absolute path; (b) the
   `op.env` prerequisite row must state the fail-closed stop.
   Where: `kagi-shokunin/SKILL.md:136,:164,:195,:272` and `:28`.
   Falsified by: `grep -c 'local/state/tac/handoff-status.json' SKILL.md` → `0` (all four mentions
   bare 4 rounds after routing); `SKILL.md:28` unchanged ("needs `~/.config/the-janitor/op.env`
   present") with no stop clause anywhere in the file for it (`grep -n missing SKILL.md` → only
   drift-gate and command-error lines). Mirrored, not absorbed: the lesson is never edited.
   Required correction form: lane edits `SKILL.md` (path on each mention; one clause: absent file ⇒
   the tool's own `missing $ENV_FILE` refusal, exit 2). Owning lane: kagi.

6. **minor — SCORECARD measurement discipline.** Post-move rows name their commit by subject
   ("commit `round-9`") rather than hash, and most post-move cells carry no counting command, though
   `PROTOCOL.md:466` requires each score to carry "the counting command that produced it and the
   commit it was measured against". Where: `SCORECARD.md` §"Round 9 — post-move". Owning lane: kagi.

7. **minor/contested — CDP-9222 listener + musketeer chrome-profile lease ownership, unruled.**
   Claims: `kagi r3` `.ufo/reports/round-3/kagi.md:72-73` ("unchanged, still reported-not-absorbed");
   `kagi r7` `.ufo/reports/round-7/kagi.md:76` ("the documented `webzites` lease is cooperative
   serialization, **not** an ACL — the same loopback-is-not-a-boundary question applies to that
   listener; ownership ruling still open"); re-flagged `kagi r9`
   `.ufo/reports/round-9/kagi.md:151` + `PROVINCE.md` §Network surfaces + `corpus/README.md` overlap
   table; counter-claim `kake r9` `.ufo/reports/round-9/kake.md:56` ("Shared burner-chrome lease
   (CDP 9222) ownership between kake and kagi lanes is unresolved … needs orchestrator decision");
   standing row `ROADMAP.md:129-130`. Contested scope is **two-part**: (1) ownership of the machine-wide
   lease on the chrome profile + its CDP 9222 listener (kake burner-chrome/`webzites-keeper` surface
   vs kagi's 1Password↔CDP bridge), and (2) the security ruling on whether that loopback listener is
   a boundary at all. Per `PROTOCOL.md:486-490` silence is not a ruling and scope must not default to
   the first writer. Required correction form: integrator ruling; connector carries it as an **open**
   ledger row re-flagged this round. Owning lane: kake + kagi (integrator adjudicates).

8. **major — commit identity violates the lane-identity invariant.**
   Standing claim: `PROTOCOL.md:535-548` — round commits carry the lane identity
   (`<lane>-shokunin` / `<lane>@shokunin.local`), with `kagi` named as a repo that "already does";
   operator-identity lane commits are "a conformance defect", and an unconfigured repo's lane sets
   the config once and notes it in `LOG.md`.
   Where: `kagi-shokunin` git config + commit authors (rows in `git log`), and `PROTOCOL.md:537-538`.
   Falsified by: `git config --local user.name` / `--local user.email` → both exit 1 (unset);
   `git log --format='%an <%ae>' | sort | uniq -c` → `10 Joao Pedro Veiga <jpveigao10@gmail.com>`,
   `2 shokunin <shokunin@local>`; `0` commits under `kagi-shokunin <kagi@shokunin.local>` (HEAD
   `e64e81b` and rounds 3–9 all operator-personal; `ea77bf0` = `shokunin@local`); no `LOG.md`
   identity note (`grep -n 'user.name\|user.email\|identity' LOG.md` → 0).
   Required correction form: lane sets `git config --local user.name/email` once and notes it in
   `LOG.md`; integrator corrects the protocol-side assertion for kagi. Owning lane: kagi (+integrator).

9. **minor — audit-invariant drift (non-material).** The round-5 aggregator audit's falsification
   sweep (strict ref-shape pattern, placeholder excluded) returned 0 lines in round 5; it now returns
   **1** line, `kagi-shokunin/corpus/transcript-scan.sh:242` — a synthetic two-segment marker inside
   the transcript gate's scratch-CDB `--selftest` seed (no vault identifiers, no material; the other
   seed at `:202` is the documented placeholder form). Required correction form: annotate the round-5
   lesson's falsification clause with the new expected result (append-only, aggregator-owned).
   Owning lane: aggregator.

10. **minor — hash-policy enumeration vs the mode census.** Policy statements (`SCORECARD.md`
    post-move freshness cell, `drift-gate.md` §"Hash policy", `LOG.md`) say "6 private **0600** files"
    are pinned by mode+lines only; the baseline holds **7** rows with mode `600`, the 7th being the
    musketeer `NativeMessagingHosts` manifest, which carries a sha256. No secret material is
    involved (host-declaration JSON), but the sentence and the `NOHASH` list are not coextensive with
    mode-0600, so a reader can mis-infer that no 0600 file is hashed. Required correction form:
    restate the policy as a named-path list (not a mode class) + a sentinel ruling on that path.
    Owning lane: kagi (+sentinel).

## Fleet-2 axis-framework state (this repo)

- `SCORECARD.md`: **exists** (7.7 KB) and **committed** (`git ls-files SCORECARD.md` → `1`); the
  three contract fields are present — **axes** (six rows: score, evidence pointer, last-change
  round), **planned** (coverage 6, one axis-move with a falsifiable target), **retired** ("None" with
  justification); declared owned axes "freshness + calibration" **match** `MISSION.md:18`; both
  before and after are recorded for round 9 (`freshness 2→7`, `operability 5→7`, `coverage 5→6`,
  `calibration 4→6`, `depth 7→7`, `adjacency 8→8`). Gaps: defect 2 (four falsified counts in the
  depth cell) and defect 6 (commit identified by subject, missing counting commands on post-move
  rows).
- The round-9 axis-move itself is **real and independently reproduced here**: `drift-pins.sh` went
  from a fingerprint printer that stored nothing (`git show ea77bf0:corpus/drift-pins.sh | grep -c
  baseline` → `0`; 13 paths, 2 of 13 verifiable by any recorded digest) to a committed gate with
  15 baseline rows + 19 symbol pins, `CLEAN (files=15 symbols=19)` exit 0, a 13-case selftest, and
  proven drift detection on a falsified baseline (`DRIFT … sha deadbeef0000->a318e719a04b`, exit 1).
  The four artifacts the round-6 brief found uncommitted are all in `e64e81b`; the tree is clean.
- `SHONEN.md`: byte-identical to the canonical seed modulo `<name>`/box/one evidence line each, but
  its verifier ids do not survive the promotion gate (defect 4) and no kagi report carries a
  `SHONEN` heading (fleet-wide: 51 of 61 report files lack one).

## Routed-defect rows for the ledger

```
kagi-shokunin | corpus/lessons/round-9.md:175 + LOG.md:215 say "delivered 445-line revision"; committed blob is 451 lines, no 445-line blob in history | r6 | open | wc -l corpus/drift-pins.sh; git show e64e81b:corpus/drift-pins.sh | wc -l
kagi-shokunin | SCORECARD.md:16 depth cell: 16-row table / 15-item checklist / 25 anti-patterns / "Source basis:"-in-every-knowledge-entry — all falsified (15|16, 13|14, 21|24, 6/14) | r6 | open | git show ea77bf0:SKILL.md | awk '/^## Vault-ops decision table/,/^## /' | grep -c '^\|[-]'; grep -c '^[[:space:]]*- \[ \]' SKILL.md; grep -l '^Source basis:' corpus/knowledge/*.md | wc -l
kagi-shokunin | ROADMAP.md:46-47 "kagi (4 bare [x]s) … must regenerate" — SHONEN.md regenerated in e64e81b (seed diff exit 0, 4 boxed [x], 0 bare) | r6 | open (integrator-owned file) | diff <(seed, [x]->[ ] , evidence lines dropped) kagi-shokunin/SHONEN.md
kagi-shokunin | SHONEN.md [x] marks: verifier id KagiR9Reviewer resolves nowhere; boxes 2 and 4 name no verifier → count as [~]; no report carries a SHONEN heading | r6 | open | grep -rn KagiR9Reviewer <main repo tree>; grep -cE '^#{1,6} *SHONEN' .ufo/reports/round-9/kagi.md
kagi-shokunin | round-5 routed: handoff-status.json still cited bare in SKILL.md (4 mentions, 0 absolute paths) | r5 | open (4 rounds) | grep -c 'local/state/tac/handoff-status.json' kagi-shokunin/SKILL.md
kagi-shokunin | round-5 routed: SKILL.md:28 op.env prerequisite row still has no fail-closed stop clause | r5 | open (4 rounds) | grep -n 'missing' kagi-shokunin/SKILL.md
kagi-shokunin | commit identity: 10/12 commits operator-personal, 2/12 shokunin@local, 0/12 kagi-shokunin@shokunin.local; git config --local unset; no LOG.md identity note | r6 | open | git -C kagi-shokunin config --local user.name; git -C kagi-shokunin log --format='%an <%ae>' | sort | uniq -c
kagi-shokunin | SCORECARD post-move rows identify the commit by subject and omit counting commands (PROTOCOL.md:466) | r6 | open | grep -n 'commit `round-9`' kagi-shokunin/SCORECARD.md
kagi-shokunin | CDP-9222 listener + musketeer chrome-profile lease ownership unruled (kagi r3/r7/r9 vs kake r9) | r3 (raised) / r7 (re-flagged) / r9 (re-flagged) | open | ROADMAP.md:129-130; .ufo/reports/round-3/kagi.md:72; .ufo/reports/round-7/kagi.md:76; .ufo/reports/round-9/kake.md:56
kagi-shokunin | hash-policy says "6 private 0600 files" mode+lines-only; baseline has 7 mode-600 rows (musketeer manifest is hashed) | r6 | open | awk -F'\t' '$2=="600"' corpus/drift-baseline.tsv | wc -l; awk '/^NOHASH=\(/,/^\)/' corpus/drift-pins.sh | grep -c '\$HOME'
kagi-shokunin | round-5 audit's ref-shape falsification sweep now returns 1 line instead of 0 (non-material scratch seed, transcript-scan.sh:242) | r6 | open (aggregator append-only annotation) | grep -rnE '<ref-shape>' kagi-shokunin/corpus/ kagi-shokunin/SKILL.md | grep -v 'vault/item/field'
```