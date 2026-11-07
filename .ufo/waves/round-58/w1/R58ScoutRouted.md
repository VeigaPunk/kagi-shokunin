# R58ScoutRouted — reconnaissance of the eight C1 items (I1..I8)

Seat: scout (routed recon). Lane: `kagi-shokunin`, branch `master`.
BASE measured: `1b13f5dad921f8901f56d30c428f89614dd74d8a` (round-57 verifier spot-check tip).
Frozen predeclaration read: `plans/round-58.md` (as committed at `0085a5f`; the working tree carries
uncommitted §Amendments A1/A2/A3 from the L1 — read, not judged, here).
Frozen defect list read: `corpus/lessons/round-57-verifier-spotcheck.md` §7 (D1–D12).

## Method (why the readings are BASE readings)

Every measurement below was taken against an **immutable BASE tree**, never the mutable working tree:

```
S=${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r58/R58ScoutRouted
mkdir -p $S/base
cd /home/vgpnk/Projects/shokunin/kagi-shokunin
git archive 1b13f5dad921f8901f56d30c428f89614dd74d8a | tar -x -C $S/base
```

This seat is read-only on the lane. It never ran `git add/commit/stash/push` or a mutating `jj`
command; it never wrote into the lane tree, a sibling lane, or the fleet root. Its only lane
writes are this report and the wave report. Scratch is under
`${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r58/R58ScoutRouted/` and was deleted before yield.

A working-tree comparison is also reported where a sibling's candidate changes the *state at
BASE* reading; the BASE column is the frozen-defect fact, the candidate column is a later
observation.

## Authority map (what each item is measured against)

| item | authority (the file that decides it) |
|---|---|
| I1 (D1) | `LOG.md` round-57 section run + `SCORECARD.md` `## Round 57 — post-move` |
| I2 (D3) | `.ufo/waves/round-57/controls/controls-prefreeze-epochC*.txt` (`INSTRUMENT` pins + last `CONTROLS:` line) |
| I3 (D4) | `corpus/lessons/round-57.md` `## Gate` + `source:` line; `corpus/SOURCES.md` S117 row; `.ufo/waves/round-57/capture/S117.body` |
| I4 (D5) | `corpus/SOURCES.md` data rows (measured) vs the two named count locations; `.ufo/waves/round-57/final/gates.txt` `rows=` |
| I5 (D6) | `SKILL.md` gate-registry tables |
| I6 (D7+D8) | `corpus/current-claims.py` (AST + `--selftest`); `plans/round-57-c1-check.py` docstring vs code |
| I7 (D12) | `corpus/lessons/round-57.md` `## Gate` S115 row; live heading in `.ufo/waves/round-57/capture/S115.body` |
| I8 (D11) | `bash corpus/scope-gate.sh` `stale_basis=` token; `corpus/adjacency.tsv` basis column |

---

## The eight items, one row each

| # | state at BASE `1b13f5d` | authority | exact unresolved fact | minimal edit | command that shows it |
|---|---|---|---|---|---|
| **I1** (D1) | **UNRESOLVED.** `LOG.md:1935` names only *Freeze epoch B* `03cbf656` and receipt `controls-prefreeze-epochB.txt`; no epoch-C token and no epochC receipt path anywhere in the LOG round-57 run. `SCORECARD.md:1863` and `:1884` likewise name epoch B only; `SCORECARD.md:1887` cites `controls-prefreeze-epochB.txt`. `grep -c 'epoch[ -]*C'` over the r57 surface returns 0. Epoch C really exists: commit `8d8e05887b8a88452bf0448458fb3b8916bc56f5`, receipt `.ufo/waves/round-57/controls/controls-prefreeze-epochC.txt` (`CONTROLS: match=13 mismatch=0`). | `LOG.md` round-57 section run + `SCORECARD.md` `## Round 57 — post-move` | The durable files never learned that epoch C happened; the round-57 record names A/B only. | Append (not rewrite) to the LOG round-57 entry: epoch C `8d8e0588` + its receipt path + match count; and one epoch-C mention inside the SCORECARD r57 post-move section. Both files are append-only in the lane's practice. | `grep -nE 'epoch[ \t]*-?[ \t]*C\b' $S/base/LOG.md $S/base/SCORECARD.md` → no match; `grep -c 'controls-prefreeze-epochC' $S/base/LOG.md` → 0 |
| **I2** (D3) | **UNRESOLVED (pin mismatch).** `sha256sum plans/round-57.md` at BASE = `76e836ee111d60b7cf60007da4b45a102f1d94393f1d83c9de1a32d7cd33b173`. The receipt's pin = `INSTRUMENT b130bb83b3dd4bdb52b84aeb4c6d3459477188b66406adab429392049698c6dc plans/round-57.md` — **different bytes**. The receipt's `CONTROLS: match=13 mismatch=0` is fine. The other four pins match exactly. Root cause: `b130bb83…` is the **epoch-B** blob of the plan (`git cat-file -p 03cbf656:plans/round-57.md`), while `76e836ee…` is the **epoch-C** blob (`git cat-file -p 8d8e0588:plans/round-57.md`) — the plan was amended (A1/A2/A3 text) *after* the battery ran, and the receipt was never regenerated. | the receipt file itself; the script that wrote it is `plans/round-57-controls.sh` lines 41–43, which pins the five instruments `plans/round-57.md`, `plans/round-57-c1.sh`, `plans/round-57-c2.sh`, `plans/round-57-controls.sh`, `plans/round-57-c1-check.py` via `sha256sum` over `$REPO/$f` (the live work tree, not the commit) | The receipt pins a plan blob the tree does not contain, so it certifies the wrong tree. | Re-run the frozen battery so the receipt is generated over the shipped bytes: `HYAKU_SCRATCH=$S bash plans/round-57-controls.sh` — **verified**: the regenerated receipt differs from the committed one in exactly one line (the plan pin `b130bb83…` → `76e836ee…`) and still reads `CONTROLS: match=13 mismatch=0`. Writing it as a *new* file `controls-prefreeze-epochC-final.txt` also satisfies the `epochC*` glob without rewriting the committed receipt. | `sha256sum $S/base/plans/round-57.md` vs `grep 'plans/round-57.md' $S/base/.ufo/waves/round-57/controls/controls-prefreeze-epochC.txt` |
| **I3** (D4) | **UNRESOLVED (2 of 3 sub-conditions).** (a) No S117 row in the lesson's `## Gate` section: the section has `Admit S115`, `Admit S116`, `Admit the knowledge entry`, two `Reject:` bullets, `Assimilation: none` — no S117. (b) The lesson's `source:` line reads `source: S115 (…); S116 (…), both opened 2026-11-07.` — no S117. (c) **Already satisfied**: S117's `used-by` cell is `corpus/knowledge/openbao-audit-device-custody.md, corpus/lessons/round-57.md` — it already names the lesson. `.ufo/waves/round-57/capture/S117.body` exists (35071 B) and carries the quote: the 16-word sentence "This endpoint hashes the given input data with the specified audit device's hash function and salt." occurs in it (across a line break — collapsed-whitespace match, raw single-line match is 0). | the lesson `## Gate` + `source:`; S117 registry row; the capture body | The lesson never admits the row it is already credited with. | One `**Admit S117**` bullet in the lesson's `## Gate` (URL, access date, ≤25-word quote, capture path) **and** append S117 to the lesson's `source:` line. The quote must be located with whitespace collapsed — the capture wraps the sentence after `device's`. | `grep -c 'S117' $S/base/corpus/lessons/round-57.md` → 0; `sed -n '3p' $S/base/corpus/lessons/round-57.md` shows no S117; `sed -n '125p' $S/base/corpus/SOURCES.md \| tr '\|' '\n' \| tail -2` shows the used-by cell |
| **I4** (D5) | **UNRESOLVED at BASE.** Every registry-count statement in the round-57 surface says 116 while the measured registry has **117** data rows. Statements found: `SCORECARD.md:1897` (r57 post-move coverage row) `Registry 114 → 116 (S115, S116; tier A, mined)`; `corpus/lessons/round-57.md:86` `Registry 114 → 116 (S115, S116; …)`; `corpus/lessons/round-57.md:91` census line `start … 114 rows; end … 116 rows`. The measured count is **117** (`grep -cE '^\|[[:space:]]*S[0-9]{3,}[[:space:]]*\|' corpus/SOURCES.md` → 117; the shared census agrees: `scripts/sources-census.sh census --root …` → `kagi rows 117`). Separately, `.ufo/waves/round-57/final/gates.txt:20` carries `rows=116` — it was captured before S117 landed (both in commit `94d72de9`), so a line attributing a count to `gates.txt` must say **116**, not 117. | the measured `corpus/SOURCES.md` rows; `gates.txt`'s own `rows=` value | The round-57 surface states 116 where the tree has 117; and the round's own end-census pointer cites `gates.txt`, which carries 116. | In the two named locations, state the **landing** count 117 (S117 landed in `94d72de9`) *and* a **tip** count equal to the tree's live measured count, and where `gates.txt` is cited, state its own carried `rows=116` with the predication that it predates S117. (The L1's uncommitted plan §Amendments A3 encodes exactly this two-class reading.) | `grep -cE '^\|[[:space:]]*S[0-9]{3,}[[:space:]]*\|' $S/base/corpus/SOURCES.md` → 117; `grep -n 'rows=' $S/base/.ufo/waves/round-57/final/gates.txt` → `rows=116`; `grep -n 'Registry 114' $S/base/SCORECARD.md $S/base/corpus/lessons/round-57.md` |
| **I5** (D6) | **UNRESOLVED.** `SKILL.md` has four gate-registry sections (`## Gate registry — round-22 changed contracts` L695, `## Gate registry — round-23/24 contracts (routed D2)` L747, `### Round-25 gate registry additions` L783, `## Gate registry — round-34 routed closures` L817). **None names `corpus/current-claims.py`** (`grep -c 'current-claims' SKILL.md` → 0). The lane's own gate would notice: `corpus/self-description-sweep.sh` SD7 flags every `corpus/*.sh|py` mentioning `--selftest` whose basename is absent from `SKILL.md` — evaluated directly at BASE, the **only** SD7 miss is `corpus/current-claims.py`. | `SKILL.md` gate-registry table rows | A shipped gate with a verdict map and a `--selftest` has no registry row, so no reader can find its entry command, verdict map, or selftest spelling. | Append a row to the round-34 registry table (8 columns: `name \| kind \| entry command \| verdict map \| selftest \| pinned values \| write scope \| owner`), naming `python3 -I -B corpus/current-claims.py`, the verdict map `0 clean / 1 mismatch / 2 SETUP`, and `python3 -I -B corpus/current-claims.py --selftest`. One row clears the SD7 miss too. | `grep -c 'current-claims' $S/base/SKILL.md` → 0; the SD7 loop reproduced at BASE → `SD7 MISSING: corpus/current-claims.py mentions --selftest but SKILL.md never names current-claims.py` |
| **I6** (D7+D8) | **UNRESOLVED at BASE, on all three sub-conditions.** (D7) `corpus/current-claims.py` hard-codes round 56: `--round` does not exist (`argparse` offers only `--root/--verbose/--selftest`), and the audited-surface literals are `".ufo/waves/round-56/controls"`, `os.path.join("plans","round-56.md")`, `"corpus/lessons/round-56.md"`, `section(sc, r"^## Round 56 [—-] post-move")`, `section(lg, r"^## Round 56 \(")` — 12 `round-56` occurrences, 6 `Round 56` occurrences. (D8) **The docstring/code contradiction is in `plans/round-57-c1-check.py`, not in `current-claims.py`.** The r57 checker's docstring says the EPOCHS authority is "the number of `.ufo/waves/round-56/controls/controls-prefreeze-epoch*.txt` files" (that glob holds **5** files: B,C,D,E,F), but its `epoch_declared()` reads `plans/round-56.md` and counts distinct `epoch-[A-F]` tokens (**6**: A,B,C,D,E,F). The r57 checker's own `via=` label says `receipt-file-count` while the code computes a plan-token count — the label lies too. `corpus/current-claims.py`'s own docstring is **consistent** with its code (both say the plan's `epoch-[A-F]` tokens). The D8 defect is therefore the *frozen r57 checker's* docstring, and the fix belongs to the next instrument revision (the r58 checker), not to a retroactive edit of frozen r57 bytes. `--selftest` at BASE exits 0 (`CURRENT_CLAIMS_SELFTEST: PASS (13 cases)`, rc 0). | `corpus/current-claims.py` AST + its `--selftest`; `plans/round-57-c1-check.py` docstring vs `epoch_declared()` | The gate re-audits round 56 forever — the exact reason D5's stale count escaped it — and the frozen r57 checker's docstring names an authority its code never reads. | Add `--round N` to `current-claims.py` and derive **every** audited-surface path from N (SCORECARD section, LOG section, lesson path, plan path, receipt dir) with a dynamic `round-` string; state the EPOCHS authority in the docstring as the *plan's* `epoch-[A-F]` tokens; keep `--selftest` exiting 0. For D8 proper, the r58 instrument's docstring must say the plan-token authority (not the receipt-file count). | `grep -c 'round-56' $S/base/corpus/current-claims.py` → 12; `grep -n 'add_argument' $S/base/corpus/current-claims.py` → no `--round`; `grep -n 'epoch-\|receipt-file-count' $S/base/plans/round-57-c1-check.py`; `ls $S/base/.ufo/waves/round-56/controls/controls-prefreeze-epoch*.txt \| wc -l` → 5 vs `grep -oE 'epoch-[A-F]\b' $S/base/plans/round-56.md \| sort -u \| wc -l` → 6 |
| **I7** (D12) | **UNRESOLVED.** The lesson's S115 Gate row cites the anchor as `(§Enabling and disabling audit devices)`. The live heading in `.ufo/waves/round-57/capture/S115.body` is **`Enabling/Disabling audit devices`** (line 47: `<h2 … id=enablingdisabling-audit-devices>Enabling/Disabling audit devices`). The drift is in the lesson (and, separately, in the S115 registry row's anchor cell and in the knowledge entry's `source:`/`recheck:` lines — the routed defect names the lesson). The quote itself is real and locatable at that heading. | the capture body; the lesson's `## Gate` S115 bullet | The lesson names an anchor the live page does not have, so a reader following it lands nowhere. | Change the lesson's S115 Gate row anchor text from `§Enabling and disabling audit devices` to `§Enabling/Disabling audit devices`. (One string, in one bullet.) | `grep -n 'Enabling and disabling audit devices' $S/base/corpus/lessons/round-57.md`; `grep -o 'Enabling/Disabling audit devices' $S/base/.ufo/waves/round-57/capture/S115.body \| head -1` |
| **I8** (D11) | **UNRESOLVED at BASE.** `bash corpus/scope-gate.sh` prints `SCOPE STALE-BASIS $HOME/.config/opencode basis=SCORECARD.md:54 lines=54-54 token=opencode` and `ADJACENCY_SCOPE: DEFECT (… stale_basis=1 …)`. `corpus/adjacency.tsv:81` is the offending row: `$HOME/.config/opencode  integrator  unresolved  declared  SCORECARD.md:54  opencode  <note>`. `SCORECARD.md:54` is the round-9 **depth** row and no longer carries the token `opencode` — the token moved when the file grew. The live line that carries it is `SCORECARD.md:70` (the round-10 adjacency row naming `~/.config/opencode/opencode.json`'s ownership boundary). | `corpus/adjacency.tsv` basis column + the cited `SCORECARD.md` line | A cited basis line drifted away from the token it is supposed to carry, so the ownership claim for `$HOME/.config/opencode` rests on a line that no longer mentions it. | Re-point `corpus/adjacency.tsv:81`'s basis from `SCORECARD.md:54` to a `SCORECARD.md` line that carries the `opencode` token. **Two candidates, both verified to clear the gate** (see below). | `bash $S/base/corpus/scope-gate.sh` → `stale_basis=1`; `grep -n 'SCORECARD.md:54' $S/base/corpus/adjacency.tsv` |

---

## I8 — the two candidate lines for the re-pointed basis (both measured)

Both candidates are read from the **BASE** `SCORECARD.md` and both carry the token `opencode`
on the cited line, which is what `scope-gate.sh`'s `token_hits()` requires (it greps the cited
line range for the token as an ERE).

**Candidate A — `SCORECARD.md:70` (recommended).** The round-10 adjacency row; it is the row
that actually carries the ownership claim the adjacency.tsv note describes.

```
| adjacency | 8 → 8 | The census declares only handler-reaching paths and *reports* the rest: the
global `~/.config/opencode/opencode.json` ownership boundary (connector: needs an integrator
ruling), `~/.agents/AGENTS.md` + its undeclared `.bak` sibling (kotoba/fleet), the musketeer
profile (kake — kept presence-only, `mode = -`). | `corpus/README.md` §Known gaps (round-10
adjacency bullet); `PROVINCE.md` (the round-10 connector output was session-scoped scratch, not
retained; round 11 replaced the dead citation). |
```

**Candidate B — `SCORECARD.md:65`.** The round-10 coverage row; it also names the `opencode`
layer and its 20 children.

```
| coverage | 6 → **8** | The surface claim became a gate: 35 declared rows (20 asset / 15 runtime)
over the handler's config/state, the opencode layer that reaches it, evidence/custody and
network-adjacent paths; … Ceilings named in that entry's §Bounds: … `~/.config/opencode`
(20 children) / `~/.local/bin` …
```

**Verification (scratch copies of the BASE `adjacency.tsv`, real fleet lane-root):**

```
sed 's|SCORECARD.md:54|SCORECARD.md:70|' corpus/adjacency.tsv > adj.p70.tsv
ADJ_LANE_ROOT=/home/vgpnk/Projects/shokunin bash corpus/scope-gate.sh --data …/adj.p70.tsv
  → ADJACENCY_SCOPE: DEFECT (… stale_basis=0 basis_escape=0 …)     # candidate A
sed 's|SCORECARD.md:54|SCORECARD.md:65|' corpus/adjacency.tsv > adj.p65.tsv
  → ADJACENCY_SCOPE: DEFECT (… stale_basis=0 basis_escape=0 …)     # candidate B
```

Both clear `stale_basis` 1 → 0. The range form `SCORECARD.md:70-70` also works (the gate parses
`file:a-b`). **Recommendation: candidate A (`SCORECARD.md:70`)** — it is the adjacency row that
states the ownership boundary the adjacency.tsv note is about, whereas B is the coverage row
that merely mentions the layer. Either satisfies the frozen predicate; A is the truer citation.

---

## Candidate-state observation (later in the wave; not a BASE reading)

While this recon ran, sibling seats landed candidate fixes. Measured **after** those edits, the
r58 checker read on the live lane tree:

```
C1_ROUTED: value=0 population=8 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 i8=1 guard=1
```

Two things in that candidate are worth the L1's attention because they touch the *instruments*,
which the plan freezes:

1. **`plans/round-58-c1-check.py`'s I6 leg was weakened mid-wave.** The version this seat first
   read flagged *any* string constant matching `round-56` together with a path/heading shape
   (`/`, `.md`, `.tsv`, `##`) — including the `--selftest` fixture bodies and the module
   docstring. The current version exempts the docstring node, everything inside `run_selftest`,
   the arguments of `.replace`/`.write`/`.remove` calls, and any constant longer than 200 chars
   ("round-58 M58-4"). That is a defensible reading of "no literal round-56 path **in the surface
   list**" (fixtures are test data, not the audited surface) — but it is a *weakening of the
   instrument*, and under the stricter reading the candidate `corpus/current-claims.py` still
   carries 8 offending constants (lines 2, 258, 266, 287, 288, 382, 412, 413). The stricter
   reading is satisfiable: interpolating a module-level `FR = 56` into f-string fixtures removes
   all 8, and the gate's own `--selftest` still passes (**19 cases**, rc 0). Verified in scratch.
2. **The plan's §Amendments A1–A3 are uncommitted** (`plans/round-58.md` is modified, not
   committed). A1 restates I2 (five-pin equality, `match=N mismatch=0` with N ≥ 13), A2 restates
   I3 (whitespace-collapsed quote location), A3 restates I4 (landing count 117 vs tip count =
   measured). The checker's implementation follows A1–A3. The amendments are substantive to the
   frozen predicate and are what the plan's own "## Amendments" section exists for, so they must
   be committed with the instruments, before the pre-freeze battery.

`plans/round-58-controls.sh` **does not exist yet** at the time of this report, and
`.ufo/waves/round-58/controls/` holds only `census-start.txt`, `current-claims-base.txt`,
`scope-gate-base.txt` — no pre-freeze receipt. The plan requires the battery to read
`CONTROLS: match=<N> mismatch=0` and to pin the instrument hashes **before** any candidate is
measured. (For reference, the r57 battery is re-runnable and was run by this seat against BASE
for I2: `bash plans/round-57-controls.sh` → `CONTROLS: match=13 mismatch=0`.)

## Commands that show every reading (single script)

```bash
S=${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r58/R58ScoutRouted
cd /home/vgpnk/Projects/shokunin/kagi-shokunin
git archive 1b13f5dad921f8901f56d30c428f89614dd74d8a | tar -x -C $S/base

# I1  epoch-C absent from the durable files
grep -nE 'epoch[ \t]*-?[ \t]*C\b' $S/base/LOG.md $S/base/SCORECARD.md            # (no match)
grep -c 'controls-prefreeze-epochC' $S/base/LOG.md                                # 0

# I2  plan pin vs receipt pin
sha256sum $S/base/plans/round-57.md
grep 'plans/round-57.md' $S/base/.ufo/waves/round-57/controls/controls-prefreeze-epochC.txt
grep '^CONTROLS:' $S/base/.ufo/waves/round-57/controls/controls-prefreeze-epochC.txt
git cat-file -p 03cbf656:plans/round-57.md | sha256sum    # = the receipt's b130bb83… pin
git cat-file -p 8d8e0588:plans/round-57.md | sha256sum    # = the tree's  76e836ee… bytes

# I3  S117 Gate row / source: line / used-by / capture body
grep -c 'S117' $S/base/corpus/lessons/round-57.md                              # 0
sed -n '3p'  $S/base/corpus/lessons/round-57.md                                  # source: line
sed -n '125p' $S/base/corpus/SOURCES.md | tr '|' '\n' | tail -2                 # used-by cell
ls -l $S/base/.ufo/waves/round-57/capture/S117.body                             # 35071 B

# I4  measured count vs stated counts vs gates.txt
grep -cE '^\|[[:space:]]*S[0-9]{3,}[[:space:]]*\|' $S/base/corpus/SOURCES.md      # 117
grep -n 'Registry 114' $S/base/SCORECARD.md $S/base/corpus/lessons/round-57.md
grep -n 'rows=' $S/base/.ufo/waves/round-57/final/gates.txt                      # rows=116

# I5  no registry row; SD7 flags exactly this one script
grep -c 'current-claims' $S/base/SKILL.md                                       # 0
grep -n '^## Gate registry\|^### Round-25 gate registry' $S/base/SKILL.md

# I6  hard-coded round 56; D8 docstring vs code; selftest exit
grep -c 'round-56' $S/base/corpus/current-claims.py                              # 12
grep -n 'add_argument' $S/base/corpus/current-claims.py                         # no --round
grep -n 'epoch-\|receipt-file-count' $S/base/plans/round-57-c1-check.py
ls $S/base/.ufo/waves/round-56/controls/controls-prefreeze-epoch*.txt | wc -l    # 5  (docstring)
grep -oE 'epoch-[A-F]\b' $S/base/plans/round-56.md | sort -u | wc -l             # 6  (code)
(cd $S/base && python3 -I -B corpus/current-claims.py --selftest)               # PASS (13 cases) rc 0

# I7  lesson anchor vs live heading
grep -n 'Enabling and disabling audit devices' $S/base/corpus/lessons/round-57.md
grep -o 'Enabling/Disabling audit devices' $S/base/.ufo/waves/round-57/capture/S115.body | head -1

# I8  stale basis and the two candidate re-points
(cd $S/base && ADJ_LANE_ROOT=/home/vgpnk/Projects/shokunin bash corpus/scope-gate.sh)
grep -n 'SCORECARD.md:54' $S/base/corpus/adjacency.tsv
```

## Tooling

No tool was installed or upgraded by this seat. No `pacman`, `uv tool`, `cargo` or `npm`
transaction was run; the task needed only `git`, `grep`, `sed`, `bash` and `python3` (all
pre-existing). Nothing was downgraded and no host service was restarted.

## Secret discipline

No secret value, token, cookie, session id, or vault/item/field name appears in this report.
No fetch was performed by this seat, so no `Set-Cookie`/`Cookie` value could be written.

## Remaining unknowns (not resolvable from the repo)

1. Whether the L1 accepts the checker's mid-wave I6 weakening (the `M58-4` exemption of
   selftest fixtures / the docstring / `.replace`/`.write`/`.remove` arguments / >200-char
   constants) or wants the stricter reading. Under the stricter reading the candidate gate still
   has 8 offending constants, all removable by interpolating a module-level `FR = 56` (proved in
   scratch; the gate's own selftest stays green at 19 cases).
2. Whether `plans/round-58-controls.sh` and the pre-freeze receipt will exist before the
   candidate is measured, and which instrument bytes the receipt will pin (the plan requires the
   receipt to pin the shipped bytes; the r57 D3 defect is exactly a receipt that did not).
3. Whether the operator wants the I2 fix as a regenerated `controls-prefreeze-epochC.txt` or as
   an additional `controls-prefreeze-epochC-final.txt`. Both satisfy the `epochC*` glob; the
   second leaves the committed r57 receipt byte-untouched (the lane's append-only practice), the
   first replaces a receipt that is itself historically accurate for epoch C.
