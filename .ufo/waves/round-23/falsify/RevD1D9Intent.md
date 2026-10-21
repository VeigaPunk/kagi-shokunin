# RevD1D9Intent — do the round-23 dispositions answer the round-22 routed defects?

Read-only falsification seat, round 23. Leaf; no subagents. I attacked the
**intent** of routed defects D1–D9, not their wording: each disposition was
reconstructed from
`corpus/lessons/round-22-verifier-spotcheck.md:163-183` and then checked against
the artifact the disposition itself names.

**Snapshot (dispatch).** Lane HEAD `def9bc2e12534ae2c2492bae1034eb8122c2c179` at
2026-10-21T01:13:42-03:00. Fleet report
`/home/vgpnk/Projects/shokunin/.ufo/reports/round-23/kagi.md`, sha256
`b2c25306…`, mtime 2026-10-21 01:12:09. Artifact hashes at the dispatch snapshot:

```
49632920…  corpus/lessons/round-23.md
00fbf48d…  corpus/closure-dispositions.json
6e26e140…  corpus/source-fetches.tsv
511deb27…  corpus/sources-census.sh
72764bf3…  .ufo/waves/round-23/final-verification.json
23583252…  corpus/fixtures/cells-hermetic/SCORECARD.md
59869459…  corpus/claim-ledger.tsv
65a5b3de…  corpus/lessons/round-22-verifier-spotcheck.md (pinned by the JSON)
```

**Snapshot (final observed, after remediation).** Lane HEAD
`c349fc7f7a4039e5b311ebd1ca07a5a8fecb1c50` at 2026-10-21T01:30:06-03:00. Fleet
report sha256 `bfa4e2d1…`, mtime 01:28:30. Lesson `80b226a0…`, closure JSON
`67ac1a42…`, verdict `9ae5f75f…` (`measured_commit` `57776b2…`);
`corpus/source-fetches.tsv` unchanged at `6e26e140…`. While this audit ran the
integrator landed `58bd8d7` (D3 relabelled `reported`, W04 seven, selftest
bounds), `57776b2` (W04 base/end wording, D4 tuple names), `5dd1411`
(refreshed verdict), `31f24e0`, `8934464`, `d736adf`, `3f9fe72` (D3 scoped to
lane-authored contexts), `3764bc5` (id-marker fix), `17858cf`, and `c349fc7`
(snapshot HEAD). The dispatch table below is the pre-remediation record;
§Final snapshot lists what remains at `c349fc7`.

The tree moved during this audit (see §Flux). Every finding below was
re-measured at the dispatch snapshot, and each D-section carries a **Final
snapshot** line with the post-remediation residual. I wrote only this file; no
lane edits, no git mutation, no network, no host/private/vault gate. I did not
open `~/.config/mise/config.toml` or any live private config.

## Verdict at dispatch (pre-remediation)

Five of nine routed-defect dispositions meet their intent in the artifact they
name (D2, D5, D6, D8, D9); D2 and D8 additionally carry a note that misdescribes
the fleet report. Four do not: D1, D3, D4, D7.

| defect | intent (spot-check line) | disposition (JSON line) | verdict | why |
|---|---|---|---|---|
| D1 | 165: quote the five W04 warnings verbatim, not only `kagi ok` | fixed (49) | **FAILS at round end** | The round-23 report says "same five … no new warning"; the round-end census prints **seven** W04 lines (S025, S026 added by this round). |
| D2 | 167: name the global mise config write; revert operator-owned | reported (56) | **PASS in lesson; note's report claim false** | The lesson (`corpus/lessons/round-23.md:78-82`) names the write, but the fleet report's install record does **not** (`grep "mise\|config.toml"` exit 1), while the note says the *report* does. |
| D3 | 170: every wave context names forbidden paths; new guard rejects `revision` + positional ids under a selftest case id | fixed (63) | **partial / self-contradictory** | Parent-build wave context names neither `.ufo/state` nor `MANIFEST.json` (0 occurrences each). The guard *does* reject `revision` and `R1-01` (exit 2), but no selftest literal is id-shaped; the lesson says that half is "not claimed as fixed" while the disposition is `fixed`. |
| D4 | 173: per-tuple drift-causing commit in an appended journal, replacing one boilerplate string | fixed (70) | **different defect** | No appended journal exists. The round-22 journal still carries 38 stamps with one identical disposition string; round-23 adds only a grouped sentence. No per-tuple rows. |
| D5 | 175: state 130 spawn IDs / 129 names | fixed (77) | **PASS** | Fleet report line 98 states it; registries independently yield 130 records / 129 unique names / 130 unique spawn IDs. |
| D6 | 177: measured commit in the verdict file itself | fixed (84) | **PASS** | `.ufo/waves/round-23/final-verification.json:2-3` carries `measured_commit: e1884c6…`; report line 87 declares it; the commit is an ancestor of HEAD. |
| D7 | 180: per-row quote/fetch-digest fields + fix stale "S017–S020 added" prose | fixed (91) | **partial** | Provenance does bind (10 rows, 9 URLs, 10/10 identities, census CLEAN), but `corpus/lessons/round-22.md:23` still says "S017–S020 added" against its own line 89 "S017–S021". No round-23 artifact corrects it; the pointer cannot. |
| D8 | 182: scratch residue operator-owned | operator-owned (98) | **PASS in lesson; note's report claim false** | `/tmp/kagi-shokunin` exists; lesson names it. The fleet report contains no `/tmp`/`scratch` string, so "named in the report" is false. |
| D9 | 183: hermetic, host-free cells run over committed fixtures | fixed (105) | **PASS** | Exact `CELL_AUDIT: CLEAN …` line, exit 0; fixture is five files; `R23-01` is in the verdict; R13-03 remains in the skipped list. |

No disposition is wholesale cross-wired to another defect. The failure mode is
narrower and more useful: D4 and D7 answer a **neighboring** requirement inside
the same defect, and D1/D2/D8 name content that is in the lesson but not in the
artifact the disposition's prose names.

## Final snapshot after remediation (HEAD c349fc7, 01:30:06)

The integrator landed the commits listed in the snapshot header while this
audit ran. Current state:

* All six host-free gates re-run at `c349fc7` (2026-10-21T01:32:16-03:00),
  after earlier runs at `5dd1411` and `17858cf`:
  `CLOSURE_DISPOSITIONS: CLEAN (obligations=15 fixed=6 reported=3
  operator_owned=1 no_action=5 rejected=0 pointers=15)` exit 0; selftest
  `PASS (14 cases)` exit 0; `SOURCES_CENSUS: CLEAN (rows=26 A=24 B=0 C=2
  queued=1 mined=24 rejected=1 entries_sourced=4 legacy=21)` exit 0; selftest
  `PASS (59 cases)` exit 0; R23-01 exact `CELL_AUDIT: CLEAN …` exit 0;
  `REVISION_AUDIT: CLEAN (stale=0 missing=0 dropped=0 added=16 invalid=0)`
  exit 0.
* The verdict's `measured_commit` is `57776b2…`, and `5dd1411` changes only
  `.ufo/waves/round-23/final-verification.json`, so the measured commit is the
  parent of the verdict commit. The verdict adds `measured_note` (`:321`)
  saying the verdict file lands in a later metadata commit. Eight commits now
  follow the measured commit (`5dd1411`, `31f24e0`, `8934464`, `d736adf`,
  `3f9fe72`, `3764bc5`, `17858cf`, `c349fc7`), so the verdict is a point
  attestation, not a statement about the snapshot tip.

What remains after the remediation:

| defect | current residual (fleet report `bfa4e2d1`, lesson `80b226a0`) | status |
|---|---|---|
| D1 | The evidence bullet quotes all **seven** W04 lines (report 83-91). Sources says "plus the five W04 lines above" for the round start (147, correct) and "same seven W04 lines" at the end (149). | **PASS (remediated)** |
| D2 | The fleet report's install record still has no `mise`/`config.toml` (`grep` exit 1). Only the lesson names the write, but the note says the report does. | **note/artifact mismatch** |
| D3 | Disposition is `reported`. Since `3f9fe72`, the lesson scopes the claim to lane-authored contexts and says the parent-held build context lacked the list. That scoping is disclosed. **New (F7):** the report says a real-tree `cells` run happened. That run executes untagged host-private row R18-01, yet the next line says "no host-private gate was executed". | **D3 incident class recurs; report self-contradicts** |
| D4 | The lesson names the four files (`57776b2`). There is still no appended journal with per-tuple rows, and the round-22 journal still has 38 identical dispositions. | **per-tuple prose added; journal absent** |
| D5 | Unchanged. | **PASS** |
| D6 | The verdict carries `57776b2…`. The report's evidence bullet still says "the verdict file's own `measured_commit: e1884c6e…`" (99), while its landed-changes table says `measured_commit=57776b28` (124). | **verdict PASS; report contradicts verdict** |
| D7 | Unchanged: `round-22.md:23` still says "S017–S020 added"; 10 rows over 9 URLs; census CLEAN; quote checked for shape only. | **stale prose + claim count** |
| D8 | The fleet report still has no `/tmp`/`scratch`. The lesson names the residue, but the note says the report does. | **note/artifact mismatch** |
| D9 | R23-01 passes and prints the exact line. The real-tree `cells` run that F7 describes bypasses D9's hermetic purpose; R23-01 itself is SKIP-SELF inside it. | **PASS (fixture); see F7** |

The dispatch table above is the pre-remediation record. This residual table
is the list to act on before closure.

## Findings

### F1 — D1: the round-23 fleet report repeats the omission it was routed for

Intent (`round-22-verifier-spotcheck.md:165-166`): the fleet report must quote
the census warnings, not only the `kagi ok` line. The round-23 report does quote
five lines, but adds an absolute claim:

```
.ufo/reports/round-23/kagi.md:77-78
- Census at round start: exit 0, `rows=23`, five W04 warnings; at round end exit 0,
  `rows=26`, the same five W04 lines plus no new warning:
```

and again at `:126-129` ("same five W04 lines"). The round-end census under the
report's own command prints **seven**:

```
$ bash scripts/sources-census.sh validate --root /home/vgpnk/Projects/shokunin kagi
kagi	W04	S019 duplicate url www.1password.dev/brokered-access across scopes
kagi	W04	S020 duplicate url 1password.com/blog/1password-credential-broker-public-preview across scopes
kagi	W04	S021 duplicate url openbao.org/docs/concepts/tokens across scopes
kagi	W04	S022 duplicate url developer.hashicorp.com/vault/docs/auth/jwt across scopes
kagi	W04	S023 duplicate url developer.hashicorp.com/vault/docs/concepts/lease across scopes
kagi	W04	S025 duplicate url openbao.org/docs/auth/jwt across scopes
kagi	W04	S026 duplicate url openbao.org/docs/concepts/tokens across scopes
kagi	ok	/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/SOURCES.md
exit 0, W04 count 7
```

S025 and S026 are this round's new correction rows
(`corpus/SOURCES.md:31-32`); their warnings did not exist at round start. The
report asserts "no new warning" while its own `rows=26` census produces two.
The five D1-named lines are present, so the letter of the round-22 defect is
satisfied for S019–S023; the **intent** — a report that surfaces the warnings —
fails for the warnings the round itself created.

**Final snapshot (report `bfa4e2d1`):** the evidence bullet (`:83-91`) now
states five W04 lines at the base and quotes all seven round-end lines verbatim
(the base five are S019–S023). The
Sources section says "plus the five W04 lines above" for the round start
(`:147`) and "same seven W04 lines" after (`:149`). D1's disposition note
(JSON `67ac1a42`:52) says both. The fleet census re-run gives exactly those
seven lines plus `ok`. **D1 is remediated**; the intermediate report
`ff83cf21` still said "same five" at `:132/134`, and `bfa4e2d1` fixed it.

### F2 — D2: named in the lesson, absent from the install record

Intent (`:167-169`): the install record must name the global
`~/.config/mise/config.toml` write; revert is operator-owned. The round-23
report's install record (`:96-97`) says only:

```
- Tool installs: none. No pacman transaction. No account/vault/handler action; the only
  network use was `curl` against public documentation.
```

`grep -n "mise\|config.toml" .ufo/reports/round-23/kagi.md` → no output, exit 1.
The naming exists at `corpus/lessons/round-23.md:78-82`, but that is not the
artifact the disposition note names ("report install record names the global
… write"). D2 is therefore answered in a different file than the one it claims;
the underlying host effect remains operator-owned and I did not re-open the live
config (no private-config reads).

### F3 — D3: the wave-context half is false; the guard half is mislabelled

(a) The lesson says "Every wave context this round names the forbidden paths
(host-private files, vault refs/tokens, live config contents, sibling lanes,
`.ufo/state`, MANIFEST.json)" (`round-23.md:84-86`). Token counts in the actual
specs:

```
parent-build-spec.json (2438 chars): host-private 0, .ufo/state 0, MANIFEST.json 0,
                                      live config 0, sibling 1, vault 2, private config 1
falsify-spec.json      (1807 chars): host-private 0, .ufo/state 1, MANIFEST.json 1,
                                      live config 0, sibling 1, vault 1, private config 1
```

The parent-build wave context (`.ufo/waves/round-23/parent-build-spec.json`,
mtime 00:41:43) names neither `.ufo/state` nor `MANIFEST.json`; it also lacks
"host-private files" and "live config" as such. "Every wave context" is false.

(b) The guard. The intent asks for the exact tokens `revision` and positional
ids to be rejected under a selftest case id. Behaviour is correct today:

```
$ bash corpus/claim-ledger.sh verify R1-01 --root /nonexistent-root --claims /tmp/x --stamps /tmp/y
claim-ledger: unexpected positional argument for verify          exit 2
$ bash corpus/claim-ledger.sh revision --root /nonexistent-root --claims /tmp/x --stamps /tmp/y
claim-ledger: unexpected positional argument for verify          exit 2
```

`claim-ledger.sh:212` collects positionals; `:224` rejects them for `verify`.
The selftest cases are `mode-unknown-revision` (`:1292`, passes the literal
`revision`) and `verify-extra-positional` (`:1293`, passes `extra`). No case
passes an id-shaped literal — `ClaimR11X09.md:161-163` says so explicitly
("a grep finds 0"; "The guard (`:222-225`) rejects any positional today. The
behaviour is correct; the test for the …"). So the missing piece is a selftest
literal, not guard behaviour. The lesson's "does not yet cover an id-shaped
positional (`R1-01`)" is true only as test coverage; read as behaviour it is
false. More importantly, the disposition is `fixed` (`closure-dispositions.json:63`)
while the lesson routes that half as "routed debt … not claimed as fixed"
(`round-23.md:89-91`). A `fixed` disposition cannot carry an explicitly
unfixed half without the gate noticing; the gate only checks the id token.

**Final snapshot (`c349fc7`):** the disposition is now `reported` (JSON
`67ac1a42`:65), so the fixed-versus-debt contradiction is gone. Since
`3f9fe72` the lesson scopes the claim to "Every wave context authored by this
lane" and states that the parent-held build context "did not carry that list"
(`round-23.md:87-90`). The scoping holds for the lane-authored falsify context.
It names sibling lanes, `MANIFEST.json`, `.ufo/state`, vault commands,
credential contents, live private config, and data-not-instructions, though
not with the lesson's exact wording. The parent-build context still lacks the
list; that gap is now disclosed, not hidden. The guard's behaviour is unchanged
(exit 2 for `revision` and `R1-01`). The open D3 problem is **F7**: the round's
own real-tree `cells` run executed host-private R18-01.

### F4 — D4: no appended journal, no per-tuple rows

Intent (`:173-174`): every stale-pin `disposition` was one boilerplate string;
cite the drift-causing commit **per tuple** in an **appended journal**. Facts:

* `.ufo/waves/round-22/pin-migrations-integration.json` `stamp_changes` has 38
  entries and exactly one distinct disposition string
  ("Reviewed current round-22 artifact; historical source facts remain
  historical. …"). Round 23 appended nothing to it; no `pin-migrations*` file
  exists under `.ufo/waves/round-23/`.
* `.ufo/waves/round-23/expectation-migrations.json` is a row-expectation
  migration record, not a stale-pin journal: 0 occurrences of `f4a8dd9`,
  `bad9088`, `584dd67`, `c2cab35`, `stale`, or `drift`.
* The lesson gives one grouped sentence (`round-23.md:92-96`): four knowledge
  pins at `f4a8dd9`, the round-18 lesson at `bad9088`, `LOG.md` at
  `584dd67`/`c2cab35`. The commit mapping is factually right:
  `git show --stat f4a8dd9` touches the four knowledge files;
  `git show --stat bad9088` touches `corpus/lessons/round-18.md`;
  `git show --stat 584dd67` and `c2cab35` touch `LOG.md`.

So the commits are correct, but the artifact D4 demanded (an appended journal
with one row per stale tuple) is absent. The disposition note "lesson cites the
drift-causing commit per stale tuple" overstates: the lesson groups four files
under one commit and does not name the four files; a reader must consult the
round-22 spot-check. This is the clearest case of a disposition answering a
narrower, different requirement.

**Final snapshot:** `57776b2` names the four files in the lesson
(`round-23.md:92-97`), so the per-tuple naming half is now met. The appended
journal is still absent: `.ufo/waves/round-23/` has no `pin-migrations*` file
and the round-22 journal remains 38 identical dispositions. The disposition
stays `fixed`; if the journal is the required artifact, this is still partial.

### F5 — D7: provenance binds, the second half and one count do not

Intent (`:180-181`): S017–S023 lack the per-row quote/fetch-digest fields
S001–S016 carry **and** the round-22 §Gate prose "S017–S020 added" is stale
against its own table (S017–S021).

Evidence for the first half (good): `corpus/source-fetches.tsv` has 10 rows
(S017–S026) over **9 distinct URLs**; every row's URL/status/row-identity
sha256 matches `corpus/SOURCES.md` (10/10); `bash corpus/sources-census.sh`
exits 0 with `SOURCES_CENSUS: CLEAN (rows=26 A=24 B=0 C=2 queued=1 mined=24
rejected=1 entries_sourced=4 legacy=21)`, and `--selftest` passes 59 cases.

Evidence for the second half (bad): `corpus/lessons/round-22.md:23` still says
"S017–S020 added A/mined", while the same file at `:89` says "Total author-opened
source rows added this round: S017–S021". `grep -c 'S017–S020' corpus/lessons/round-23.md`
= 0; no round-23 artifact corrects the stale line. The disposition pointer is
`corpus/source-fetches.tsv`, which cannot correct a lesson sentence. D7's
intent is half-answered by a side-band artifact; the prose half is untouched.

Two further bounds:

* **Count claim.** The dispatched claim says "10 declared captures S017–S026
  over 7 URLs". The artifact has 9 distinct URLs (S021 and S026 share
  `openbao.org/docs/concepts/tokens/`). The current lesson was corrected to
  "nine distinct URLs" (`round-23.md:180`); the dispatch claim is stale.
* **Quote content.** The TSV header declares the quote "shape-checked only:
  <=25 ASCII words, not verified against the page bytes or the location"
  (`source-fetches.tsv:25`), and the lesson says the same at
  `round-23.md:112` and `:196`. The Gate table header still says "located
  quote" (`round-23.md:25`), a residual wording inconsistency. D7's "quote
  field" is therefore bound as a shape declaration, not as content/location
  evidence; that is a stated bound, not a hidden one.

Pre-integration transient (labeled): before the lane committed, the working-tree
`corpus/sources-census.sh` exited 1 on the real registry:

```
corpus/sources-census.sh: line 242: S007: unbound variable   exit 1
bash -x trace: + [[ -n S007 ]] ; + SUPERSEDED[$fid]=1 ; unbound variable
```

The cause was a `SUPERSEDED[$fid]=1` assignment with no `declare -A SUPERSEDED`
(the only occurrence of `SUPERSEDED` in the file); a `supersedes S…` teaches
cell in `SOURCES.md` triggered it. The 59-case selftest passed both before and
after because its fixtures contain no `supersedes` row (`grep -c supersedes
corpus/sources-census.sh` = 0). The loop was removed before the round-23 commit:
`git show e1884c6:corpus/sources-census.sh | grep -c SUPERSEDED` = 0, and the
HEAD run exits 0. The transient is a **selftest-adequacy** observation, not a
current artifact defect; the lesson's late bound (`:210-211`) already states the
selftest does not certify the in-row branch, and this was a real-tree-only path.

### F6 — Confirmations

**D5.** Registries `.ufo/waves/round-22/{build,falsify}/swarm-registry.json`:
130 member records, 129 unique member keys (the reused `CriticNoTrade` appears
twice with `KagiR22.CriticNoTrade` and `KagiR22.CriticNoTrade-2`), 130 unique
`agentId` values. The fleet report line 98 states exactly "130 spawn IDs under
129 names (fresh `-2` identity)". Intent met.

**D6.** `.ufo/waves/round-23/final-verification.json:2-3`:
`"measured_commit": "e1884c6ecb7ccd717965b0d748bc193137118dbf"`. The commit
exists (`git cat-file -t` → commit; `git merge-base --is-ancestor e1884c6 HEAD`
→ exit 0), and fleet report line 87 declares it. The original defect (`.h1` label
8ada17a5 vs measured 4be5da3, bound only by a sidecar) is fixed in form: the
verdict itself carries the measured commit. Bound: HEAD is five commits later
(`ea5b734`, `b55e0e7`, `7af07b4`, `284d40e`, `638d44c`, `def9bc2e`); the verdict
is a point attestation at `e1884c6e`, not a statement about the shipped tip.
`R22-03` reproduces at HEAD: `python3 corpus/revision-audit.py --history
c2cab35…` → `REVISION_AUDIT: CLEAN (stale=0 missing=0 dropped=0 added=16
invalid=0)`, exit 0.

**Final snapshot:** the verdict was refreshed to
`"measured_commit": "57776b2859638d3af26d5443e7fc4b54131b6eab"` (verdict sha
`9ae5f75f…`, committed at `5dd1411`, which changes only the verdict file). The
measured commit is the parent of the verdict commit — the intended two-evidence
pattern. `R23-01` and `R23-02` rows are present and clean. **Residual:** the
fleet report (`bfa4e2d1`) still says "Recorded measured commit is the verdict
file's own `measured_commit: e1884c6e…`" (`:99`). Its landed-changes table
says `measured_commit=57776b28` (`:124`), and the verdict file says
`57776b2…`. The round-22 defect (a verdict label disagreeing with what was
measured) has moved from the verdict file into the report's prose. Fix: change
`:99` to `57776b28`.

**D8.** `/tmp/kagi-shokunin` exists (`ls -ld` exit 0); the lesson names it and
leaves cleanup operator-owned. The disposition's "named in the report" is false
(fleet report has no `/tmp`/`scratch`; `grep` exit 1), but the substantive
disposition (operator-owned, no lane deletion) is correct.

**Final snapshot:** the fleet report at `ff83cf21` still has no `/tmp`/`scratch`
string (`grep` exit 1); the note remains false, the disposition remains correct.

**D9.** Exact command from `corpus/claim-ledger.tsv:59`:

```
$ bash corpus/claim-ledger.sh cells --root corpus/fixtures/cells-hermetic \
    --claims corpus/fixtures/cells-hermetic/claims.tsv \
    --stamps corpus/fixtures/cells-hermetic/stamps.tsv \
    --scorecard corpus/fixtures/cells-hermetic/SCORECARD.md \
    --docs corpus/fixtures/cells-hermetic/SCORECARD.md
CELL_AUDIT: CLEAN (cells=6 row_pointed=6 stamp_pointed=1 uncited=0 missing_ids=0
rows_run=2 row_deferred=0 row_failures=0 stale_pointers=0 self_skipped=0 orphans=0)
exit 0
```

The fixture is five files; `SCORECARD.md:1` carries the `D9` token that the
disposition pointer resolves; `R23-01` appears in
`.ufo/waves/round-23/final-verification.json`. R13-03 stays in the verdict's
`skipped` list (`final-verification.json:12`), with the round-22 safe-row plan
recording it as host/substrate-dependent. The skip is harness-level, not a
marker in `claim-ledger.tsv`; the disposition's "explicit host skip" is accurate
as a harness fact.

### F7 — D3 intent recurs: a real-tree `cells` run executes host-private R18-01, and the report says it did not

D3's intent (`round-22-verifier-spotcheck.md:170-172`) is to stop unauthorized
legacy runs. In round 22 two such runs left no receipts, so the privacy exposure
was unbounded; the second run's positional selection included **R18-01**
(`:144-145`). The fleet report at sha `bfa4e2d1…`:

```
.ufo/reports/round-23/kagi.md:92-100
- QM12 safe-row substitute (...): 45 rows considered, 32 pass, 12 skipped by id
  (R11-01/02/03/04/06, R12-01, R13-03, R15-01, R16-01/03, R17-01, R18-01 — host-bound/substrate), ...
  A direct real-tree `cells` run (the audit R13-03 skips) then printed
  `CELL_AUDIT: CLEAN (cells=156 row_pointed=104 stamp_pointed=87 uncited=0
  missing_ids=0 rows_run=37 row_deferred=10 row_failures=0 stale_pointers=0
  self_skipped=6 orphans=0)`; R23-01 is one of the six self-skips.
  ...
  No full legacy `verify`/`cells` was run; no host-private gate was executed.
```

Code shows what a real-tree `cells` run executes:

* `cells` collects every row id cited in a `## Round <N> — pre|post-move`
  section (`claim-ledger.sh:690,736-737,757-761`).
* `cells_evidence` re-runs each cited row unless its command contains
  `claim-ledger.sh` (`:810-821`).
* `verify_claims` defers a row only if its note contains `[substrate]` and the
  substrate is absent (`:416-418`); otherwise the row executes (`:426-427`).
* `SCORECARD.md:322` cites `R18-01` under `## Round 18 — post-move` (`:318`).
* `R18-01` is `bash corpus/drift-pins.sh` with **no** substrate tag, by design
  ("it must run on every host so it carries no substrate tag",
  `claim-ledger.tsv:48`).
* `drift-pins.sh` targets host-private paths, including
  `$HOME/.config/the-janitor/op.env`, `config.json`, `opencode.json`,
  `~/.local/state/tac/*`, and a 1Password native-messaging manifest
  (`drift-pins.sh:46-62,71-76`).
* The round-22 safe-row plan (`.ufo/waves/round-22/safe-row-plan.json`,
  `skipped_rows`) says of R18-01: "Explicit untagged drift-pins command reads
  host-private surfaces; not authorized." Round 23's own verdict lists R18-01
  under `skipped`.

A static replication of `cells` row selection (Python over `SCORECARD.md` and
`corpus/claim-ledger.tsv`, read-only, executing nothing) reproduces the
printed counts exactly and names the rows:

```
cells 156  cited ids 43
self_skipped 6 ['R11-09', 'R11-08', 'R13-03', 'R14-01', 'R18-03', 'R23-01']
rows_run(selected) 37  deferred(substrate) 10
executed 27
R18-01 executed: True
executed ∩ safe-row skip list: ['R18-01']
```

The printed line therefore comes from the real ledger (`row_deferred=10` matches
the ten tagged non-self rows, and `missing_ids=0` means R18-01 was not removed),
and that run executed R18-01. `row_failures=0` is consistent with R18-01
returning its pinned `DRIFT … files_bad=15` exit 1. [INFERENCE] The paths were
probed and found absent, so file contents were probably not read; I did not
observe the run. I did not re-run it, because it is the host-bound R13-03
command.

Consequences for the dispositions:

1. **D3** (`reported`) addresses wave-context naming and the positional guard.
   It does not address an integrator-level run of the same host-private row
   that the round-22 incident named. This round repeated the incident class:
   the only receipt is one summary line, there is no per-row output, and
   `grep -rc 'rows_run=37' .ufo/waves/round-23/` finds no file other than this
   report.
2. **The report contradicts itself.** "No full legacy `verify`/`cells` was run;
   no host-private gate was executed" (`:100`) follows the real-tree `cells`
   result it quotes (`:95-98`).
3. **D9's intent** was a host-free path, so that R13-03's host-bound audit
   would not need to run. Running the real-tree audit anyway bypasses that
   purpose. R23-01's evidence is the safe-row result
   (`final-verification.json`, R23-01 exit 0), not this run: R23-01 is
   SKIP-SELF inside it.

Smallest correction: withdraw or quarantine the real-tree `cells` result, as
round 22 did for AttackActiveReview. Then name R18-01's execution and the
host-private paths it probes in the report and lesson, and add R13-03/R18-01
to the forbidden-run list that wave and integrator contexts carry.

## Gate measurements (context, not the target)

**C1.** `python3 corpus/closure-dispositions.py` → `CLOSURE_DISPOSITIONS: CLEAN
(obligations=15 fixed=7 reported=2 operator_owned=1 no_action=5 rejected=0
pointers=15)`, exit 0; `--selftest` → `PASS (14 cases)`, exit 0. The source
digest matches (`sha256sum corpus/lessons/round-22-verifier-spotcheck.md` =
`65a5b3de…`, the JSON's `source_sha256`). The dispatched claim says "selftest
13"; the current artifact and both the lesson (`round-23.md:60`) and fleet
report (`:20`) say 14. The gate's own bound is explicit: it "does not judge
whether a disposition's prose is honest, rerun the fix" (`closure-dispositions.py:42-44`),
and `fixed` only proves the id token appears at the pointer (`:104-124`). That
is why D1/D3/D4/D7 pass the gate while failing their intent. At the final
snapshot the counts are `fixed=6 reported=3` because D3 moved to `reported`; the
15 obligations and 15 pointers still hold, exit 0.

**C2.** `bash corpus/sources-census.sh` → `SOURCES_CENSUS: CLEAN (rows=26 A=24
B=0 C=2 queued=1 mined=24 rejected=1 entries_sourced=4 legacy=21)`, exit 0;
`--selftest` → `SOURCES_CENSUS_SELFTEST: PASS (59 cases)`, exit 0; 10 provenance
rows over 9 distinct URLs; 10/10 row identities match. Fleet census: exit 0,
7 W04 + ok (the D1 conflict above).

**C3.** R23-01 exact line, exit 0 (above). I did not run fixture mutations; that
is the sibling seats' target, so I make no claim about the mutation-kill result.

## Flux observed during the audit

The tree was uncommitted when the falsify wave opened and was committed while I
measured. The pre-integration `sources-census.sh` crash above was repaired by
the integration edit at 01:02:21. The lane then committed `e1884c6` (the
dispatch measured commit), `ea5b734`, `b55e0e7`, `7af07b4`, `284d40e`,
`638d44c`, `def9bc2e` (dispatch HEAD), `58bd8d7`, `57776b2` (the final measured
commit), `5dd1411` (refreshed verdict), `31f24e0`, `8934464`, `d736adf`,
`3f9fe72`, `3764bc5`, `17858cf` and `c349fc7` (final snapshot HEAD). The fleet
report was rewritten at 01:12:09 (`b2c25306…`), 01:19:04 (`f314a3a3…`),
01:21:41 (`ff83cf21…`), 01:23:49 (`06e003c3…`), 01:27:08 (`aa40dc1f…`) and
01:28:30 (`bfa4e2d1…`). The verdict was regenerated at 01:21:26
(`measured_commit: 57776b2…`, `9ae5f75f…`). The dispatch table is the
pre-remediation record and §Final snapshot is the current state. Neither
treats a pre-commit state as final.

## Command ledger (exact exits)

| # | command | exit |
|---|---|---|
| 1 | `python3 corpus/closure-dispositions.py` | 0 (dispatch: fixed=7; final: `fixed=6 reported=3`, 15/15 pointers) |
| 2 | `python3 corpus/closure-dispositions.py --selftest` | 0 (PASS 14 cases) |
| 3 | `bash corpus/sources-census.sh --selftest` | 0 (PASS 59 cases) |
| 4 | `bash corpus/sources-census.sh` | 0 (CLEAN rows=26) |
| 5 | `bash corpus/claim-ledger.sh cells --root corpus/fixtures/cells-hermetic …` | 0 (exact CLEAN line) |
| 6 | `bash corpus/claim-ledger.sh verify R1-01 --root /nonexistent-root …` | 2 (guard) |
| 7 | `bash corpus/claim-ledger.sh revision --root /nonexistent-root …` | 2 (guard) |
| 8 | `bash corpus/claim-ledger.sh --selftest` | 0 (PASS 121) |
| 9 | `bash scripts/sources-census.sh validate --root /home/vgpnk/Projects/shokunin kagi` | 0 (7 W04 + ok) |
| 10 | `python3 corpus/revision-audit.py --history c2cab35…` | 0 (CLEAN added=16) |
| 11 | `sha256sum corpus/lessons/round-22-verifier-spotcheck.md` | 0 (`65a5b3de…`) |
| 12 | `git show --stat f4a8dd9 / bad9088 / 584dd67 / c2cab35` | 0 (mapping confirms D4 groups) |
| 13 | Python count: registries | 130 records / 129 unique names / 130 unique agentIds; duplicate `CriticNoTrade` |
| 14 | Python check: TSV identities | 10/10 ok; 9 distinct URLs |
| 15 | Python token counts: wave spec contexts | build: `.ufo/state` 0, `MANIFEST.json` 0; falsify: 1/1 |
| 16 | `grep -n "mise\|config.toml" .ufo/reports/round-23/kagi.md` | 1 (no match, dispatch and final) |
| 17 | `grep -n "/tmp\|scratch" .ufo/reports/round-23/kagi.md` | 1 (no match) |
| 18 | `grep -c 'S017–S020' corpus/lessons/round-23.md corpus/lessons/round-22.md` | 0 / 1 |
| 19 | `ls -ld /tmp/kagi-shokunin` | 0 (exists) |
| 20 | `git merge-base --is-ancestor e1884c6 def9bc2e`; `git merge-base --is-ancestor 57776b2 c349fc7`; `git log -1 --format=%P 5dd1411` | 0; 0; parent = `57776b2…` (verdict commit sits directly on the measured commit) |
| 21 | pre-integration `bash corpus/sources-census.sh` (working tree, before 01:02:21) | 1 (`line 242: S007: unbound variable`) |
| 22 | final re-runs at `c349fc7` (01:32:16): closure, closure `--selftest`, census, census `--selftest`, R23-01 cells, revision audit | 0 / 0 / 0 / 0 / 0 / 0 (outputs in §Final snapshot) |
| 23 | Python static replication of `cells` row selection over `SCORECARD.md` and `corpus/claim-ledger.tsv`, read-only, executing nothing | cells 156, cited 43, self_skipped 6, selected 37, deferred 10, executed 27; R18-01 executed (F7) |
| 24 | `grep -rc 'rows_run=37' .ufo/waves/round-23/` | only this report matches; no receipt for the real-tree run |
| 25 | `grep -n "real-tree\|host-private gate\|measured_commit" .ufo/reports/round-23/kagi.md` | `:95-98` real-tree `cells` result; `:99` `e1884c6e`; `:100` "no host-private gate"; `:124` `57776b28` |

## Bounds

* No network re-fetch: this seat checks intent/artifact alignment, not the page
  bytes; the provenance digits are sibling seats' target.
* No host gates, no vault/op/handler/account command, and no private config
  reads. `/tmp/kagi-shokunin` was observed, not modified. I did **not** run
  the real-tree `bash corpus/claim-ledger.sh cells` (R13-03); F7 is derived
  from code plus the printed counts.
* I did not re-run the 43 claim-ledger row audits. I used the existing verdict
  and the host-free gates above.
* Fixture mutation kills were not run (sibling seats); no claim is made for them.
* Intent reconstruction is a reading of the spot-check prose; where the prose is
  ambiguous I measured both readings (D3 "cover": behavior vs selftest literal;
  D7 "fields": in-row vs side-band).
