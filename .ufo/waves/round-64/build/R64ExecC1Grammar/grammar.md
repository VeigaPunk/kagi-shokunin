# Round 64 — C1 grammar hardening seat (R64ExecC1Grammar)

Lane: kagi-shokunin. Claim BASE `09cbee831d57be7c4edfbe77bf238f46bf729047`.
Frozen plan read: `plans/round-64.md` (commit `dff0929c`, §C1 + Amendment A1),
`corpus/lessons/round-63-verifier-spotcheck.md` §2/§6, `corpus/lessons/round-63.md`,
plus the L1 mechanism reference `.ufo/waves/round-64/base/c1-fix-reference.md` and the
class census `.ufo/waves/round-64/base/census-a1.md`.

**Sealed set: `plans/round-64-heldout.tsv` was NOT read by this seat.** No command in
this receipt opens it, and no fixture string below is quoted from it; every synthetic
instance is built from the shape classes named in plan §C1 Amendment A1 and in
`census-a1.md` (which name classes, not fixture strings). The selftest fixtures are the
pre-existing round-61/62/63 texts plus this seat's synthetic shape-class instances.

## Instrument

File owned: `plans/round-61-c1-check.py` (the only lane file this seat wrote; the rest of
this directory is receipt material).

- BASE bytes: 2031 lines, `C1_CHECK_SELFTEST: PASS (cases=102)`.
- Candidate (frozen): `sha256 07bdc614f502d53287a3e5f3f0a7414e4831b0ab0b0863775c1c5d600079333c`,
  **2154 lines**.
- `python3 -I -B plans/round-61-c1-check.py --selftest` ⇒
  `C1_CHECK_SELFTEST: PASS (cases=111)`, rc 0. BASE 102 + 9 new shape-class cases; no
  existing case was removed or edited.
- Output line shape (`C1_ROUTED: value=V population=7 i1=.. i7=.. guard=G`) and the modes
  (`--root`, `--repo`, `--fleet`, `--no-challenge`, `--selftest`, `--json`, `--verbose`,
  `--work`) are unchanged. Only item internals and new selftest cases changed.

## Mechanisms implemented (each named by the class it closes)

| # | class (plan §C1 Amendment A1) | code |
|---|---|---|
| 1 | benign pair followed by a sentence-level denial | `_pair_asserted`: every `_pair_re` occurrence must have no denial predicate (`DENY_SINGLE`/`DENY_PHRASES`) between its end and the next `.`/`;`; a missing pair fails closed |
| 2 | duplicate pair appended elsewhere (unbound) | `_every_pair_own_subject`: EVERY occurrence of each derived fraction/percentage pair must be bound to a subject within `SUBJECT_WINDOW` (8) tokens; no subject / no pair fails closed |
| 3 | negated subject (`a different seat than the sentinel`) | `_subject_blocked`: a subject preceded within 5 tokens by `different`/`other`/`no`/`not` does not bind |
| 4 | appositive / parenthetical between subject and pair | `_mask_asides`: well-formed parentheticals `( … )` and em-dash asides `— … —` (≤60 chars, no `.` inside, non-greedy) are blanked position-preserving before the binding test and the token count, in addition to double-quoted spans |
| 5 | quoted claim then denied (`NO_NEW`) | `item4` asserts the `NO_NEW_RECORD_DEFECT_RE` match through `_asserted` (a denial predicate after it in the same sentence leaves the item unresolved) |
| 6 | duplicated mechanism claim | `item5` requires **exactly one** `REWRITTEN_IN_PLACE_RE` occurrence, and that occurrence asserted |
| 7 | benign idiom `not less than` | `IDIOMS` gains `("not", "less", "than")` |

`item7` composes 1–4 through `_both_pairs_ok`. `_denied_after`, `_negated_before`, the
token windows and every existing list are unchanged from round 63 except where the table
names them.

## Verification (all without the sealed file)

Slim tree `/fast/scratch/hyaku/kagi-r64/R64ExecC1Grammar/slim` = the checker's seven
inputs copied from the lane (`LOG.md`, `SKILL.md`, `plans/round-60.md`,
`plans/round-60-c2.sh`, `plans/round-61-c1-check.py`, `corpus/lessons/round-60.md`,
`.ufo/waves/round-60/w1-results.json`); fleet root `/home/vgpnk/Projects/shokunin`; lane
`--repo /home/vgpnk/Projects/shokunin/kagi-shokunin`.

Driver: `probe.sh` in this directory (fixture copy + one single-anchor edit, anchor count
asserted == 1). Raw output attached as `probe-final2.log`; the lines are:

```
## checker
07bdc614f502d53287a3e5f3f0a7414e4831b0ab0b0863775c1c5d600079333c  /home/vgpnk/Projects/shokunin/kagi-shokunin/plans/round-61-c1-check.py
2154 /home/vgpnk/Projects/shokunin/kagi-shokunin/plans/round-61-c1-check.py
## selftest
C1_CHECK_SELFTEST: PASS (cases=111)
rc=0
## base (unmodified slim copy)
C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0
## forgery classes (expect value=1)
denial-after-pair | C1_ROUTED: value=1 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=0 guard=0
duplicate-pair-unbound | C1_ROUTED: value=1 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=0 guard=0
negated-subject | C1_ROUTED: value=1 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=0 guard=0
quoted-claim-denied | C1_ROUTED: value=1 population=7 i1=1 i2=1 i3=1 i4=0 i5=1 i6=1 i7=1 guard=0
duplicated-mechanism | C1_ROUTED: value=1 population=7 i1=1 i2=1 i3=1 i4=1 i5=0 i6=1 i7=1 guard=0
## benign classes (expect value=0)
parenthetical | C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0
emdash-aside | C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0
idiom-not-less-than | C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0
blocker-window-bounded | C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0
```

Command shape for every probe line:
`python3 -I -B plans/round-61-c1-check.py --root <probe tree> --repo <lane> --fleet <fleet root> --no-challenge`
(run from the lane; the probe trees are copies under this seat's scratch).

### Reading

- (a) The unmodified slim copy reads `value=0` — the seven round-61 corrections still
  resolve; no item was made unresolvable by the hardening.
- (b) Each of the five forgery shape classes reads `value>=1`, with the expected item bit
  at 0: i7 for the three pair classes, i4 for the quoted-denial class, i5 for the
  duplicated-mechanism class.
- (c) Each of the three benign shape classes reads `value=0`.
- The extra `blocker-window-bounded` line is the over-blocking control: a benign subject
  preceded six tokens earlier by `other` still binds (a widened 8-token blocker window
  would read `value=1`; see the mutant table).

## Selftest cases added (9, each names its class, none quotes a sealed fixture)

`shape-i7-pair-denial`, `shape-i7-duplicate-pair-unbound`, `shape-i7-subject-negated`,
`shape-i7-parenthetical-benign`, `shape-i7-emdash-aside-benign`,
`shape-i7-blocker-window-bounded`, `shape-i4-quoted-denial`,
`shape-i5-duplicated-mechanism`, `shape-idiom-not-less-than`.

The two masking cases are **masking-only**: the parenthetical instance has 14 tokens and
the em-dash instance 9 tokens between subject and pair, so each reads resolved only
because the aside is masked (unmasked the 8-token window is exceeded). The
blocker-window case puts `other` outside the 5-token blocker window but inside a widened
one. The round-63 residual fixtures keep their pre-existing cases (`fx-f1`..`fx-f10`,
`fx-p1`..`fx-p6`, `b3`..`b7`, `p3`..`p5`); all of them pass inside the 111.

### Mutant check on the frozen bytes (this seat, scratch copies, selftest as detector)

| mutant (source edit) | reading |
|---|---|
| paren mask dropped (`for rx in (EMDASH_ASIDE_RE,)`) | `C1_CHECK_SELFTEST: FAIL (cases=111 failed=1 names=shape-i7-parenthetical-benign-benign)` |
| em-dash mask dropped (`for rx in (PAREN_SPAN_RE,)`) | `C1_CHECK_SELFTEST: FAIL (cases=111 failed=1 names=shape-i7-emdash-aside-benign-benign)` |
| mask call site dropped (`asserted = _mask_asides(asserted)` removed) | `C1_CHECK_SELFTEST: FAIL (cases=111 failed=2 names=shape-i7-parenthetical-benign-benign,shape-i7-emdash-aside-benign-benign)` |
| blocker window widened `[-5:]` → `[-8:]` | `C1_CHECK_SELFTEST: FAIL (cases=111 failed=1 names=shape-i7-blocker-window-bounded-benign)` |

The peer mutation seat (R64MutC1) independently reported the same four survivors on the
previous bytes (`bdb1bfc0`, cases=110) and this seat adopted its three fixture
suggestions before freezing `07bdc614`; the mutant readings above are on the frozen bytes.

## Discrepancies reported, not amended

1. **Subject-blocker window: 3 vs 5 tokens.** The assignment text says "preceded (within
   3 tokens)"; the class's own instance (`counting a different seat than the sentinel`)
   has `seat than the` between `different` and `sentinel`, so a 3-token window does not
   block it and the forgery reads accepted. The L1 mechanism reference
   (`c1-fix-reference.md` §3, "within five tokens") matches the measured B4 reading.
   Implemented at 5 tokens so the class is closed; the discrepancy is flagged for the L1
   rather than resolved by amending a frozen predicate.
2. **Named ceilings (unchanged from the plan).** The lists and windows stay closed floors:
   a fresh lookup table carrying one entry per fixture still passes every item; a benign
   subject genuinely negated but still asserting the count (`not only the sentinel`) reads
   unresolved; an em-dash aside longer than 60 characters or containing a `.` is not
   masked (`EMDASH_ASIDE_RE` bounded so a lone dash in the correction line cannot pair
   with a later aside; measured: the unbounded non-greedy form masked the text between
   the two dashes and broke the binding). No predicate, target, POP, kill rule, fixture or
   item condition was changed.

## Round-63 residual tables on the frozen bytes (plan §C1 guard leg c)

```
cd /home/vgpnk/Projects/shokunin/kagi-shokunin
HYAKU_SCRATCH=/fast/scratch/hyaku/kagi-r64/R64ExecC1Grammar \
  bash plans/round-63-c1.sh --tree /fast/scratch/hyaku/kagi-r64/R64ExecC1Grammar/slim
```

Measured tree = the slim copy whose `plans/round-61-c1-check.py` is byte-identical to
the frozen candidate (`07bdc614…`, verified by `sha256sum` on both before the run).
Full output attached as `residual-final.log`; verdict:

```
c1-residual: measured=--tree /fast/scratch/hyaku/kagi-r64/R64ExecC1Grammar/slim (copied 7 files)
c1-residual: selftest rc=0 pass=1 cases=111 (guard needs >= 91)
c1-residual: forgery accepted=0/10 benign rejected=0/6
c1-residual: unmodified value=0
c1-residual: prior leg=1 (B3..B7 must each read value>=1)
c1-residual: paraphrase leg=1 (P3..P5 must each read value=0)
c1-residual: stub e1_rc=2 e1_ok=1 e2_rc=2 e2_ok=1 e3_rc=2 e3_ok=1 (…)
c1-residual: checker challenge=1 (emptied negator set; run …)
C1_RESIDUAL: accepted=0 rejected=0 population=10/6 guard=1 (real=1 selftest=1 prior=1 para=1 stub=1 chal=1)
```

rc=0. The committed round-63 tables still close on the hardened checker: all ten
forgeries rejected, all six benign rewrites accepted, the round-62 bypass/paraphrase
legs unchanged, the printer stub and the emptied-negator challenge both refused. The
counter's own selftest reads the hardened checker's `cases=111` (its floor 91 is
re-derived from the counter's line, not asserted here).

## Scratch and tooling

- Scratch root: `/fast/scratch/hyaku/kagi-r64/R64ExecC1Grammar/` (slim tree, probe trees,
  mutant copies, counter scratch) — deleted before yield.
- No tool installed, upgraded or reconfigured; no pacman transaction; no host file written
  outside the lane paths this seat owns and its scratch.
