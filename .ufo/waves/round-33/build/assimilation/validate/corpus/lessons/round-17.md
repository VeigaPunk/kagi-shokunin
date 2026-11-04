# Round 17 — coverage: shared-directory breadth becomes a verdict

Axis-move: **coverage 8 → 9**. At the round-16 close depth and coverage were
tied at 8; the other four axes stood at 9. Coverage had the concrete,
vault-free gap: the census named paths under four shared directories but no
command re-derived how narrow those declarations were.

## 1. Pre-state, measured at `HEAD` `8a6ec16`

| Claim | Measurement |
|---|---|
| breadth was prose | `grep -cE '^# breadth[[:space:]]+.HOME/' corpus/adjacency.tsv` ⇒ 0 |
| shared leaf totals | opencode 20/4, local-bin 105/2, agents 4/1, Chrome profile 53/1 (`children/declared`) |
| total | 182 direct children, 8 declared child buckets, 174 undeclared |
| aggregate ancestors | `.config` 94/2, `.local/state` 15/2, `.local/share` 48/1, `the-musketeer` 2/1 — measured, deliberately not pinned |
| existing gate | partition only: 35 census rows = 27 owned + 8 shared; 43 selftests, 9 falsifiers |

A declared child is a direct child that is itself a census row or lexically
contains at least one census row. The scout and reviewer independently
reproduced the four leaf ratios and the four aggregate ratios. `ls -1` was
rejected as the primitive: it under-counted dotfiles (`opencode` 19 vs 20 and
Chrome 52 vs 53).

## 2. What landed

- Four exact `# breadth` rows in `corpus/adjacency.tsv`.
- Derived completeness: a leaf `# no-enumerate` dir MUST carry one pin;
  aggregate ancestors with descendant no-enumerate/scan dirs MUST NOT.
- `scope-gate.sh --breadth`: four count-only lines, a sorted required-member set,
  and `BREADTH_AUDIT`.
- R12/R13 verdicts for schema/membership/root/count failures.
- 18 new selftest cases (43 → 61) and 9 new shipped-data mutations (9 → 18).
- `corpus/knowledge/adjacency-breadth.md`, this lesson, ledger rows
  `R17-01..03`, scorecard/log updates.

Evidence on the shipped tree:

```
bash corpus/scope-gate.sh --breadth
  ADJACENCY_BREADTH: dir=$HOME/.config/opencode children=20 declared=4 undeclared=16
  ADJACENCY_BREADTH: dir=$HOME/.local/bin children=105 declared=2 undeclared=103
  ADJACENCY_BREADTH: dir=$HOME/.agents children=4 declared=1 undeclared=3
  ADJACENCY_BREADTH: dir=$HOME/.local/share/the-musketeer/chrome-profile children=53 declared=1 undeclared=52
  ADJACENCY_BREADTH_SET: dirs=$HOME/.agents,$HOME/.config/opencode,$HOME/.local/bin,$HOME/.local/share/the-musketeer/chrome-profile
  BREADTH_AUDIT: CLEAN (required=4 pins=4 checked=4 ok=4 children=182 declared=8 undeclared=174 missing=0 invalid=0 drift=0 exceeds=0 unverified=0)

bash corpus/scope-gate.sh --selftest
  SCOPE_SELFTEST: PASS (61 cases)

bash corpus/scope-gate.sh --falsify
  SCOPE_FALSIFY: PASS (caught=18/18 failed=0)
```

## 3. Decisions forced by counterexamples

1. **Completeness is derived, not opt-in.** The executor draft enabled
   `BREADTH-MISSING` only after at least one breadth row existed. The critic
   deleted all rows and got CLEAN. The landed rule derives four required leaves
   from `# no-enumerate` + `# scan`, so deleting every pin fails four times.
2. **Only leaves are pinned.** Pinning all eight no-enumerate dirs would make
   `.config`/`.local/share` churn unrelated to this domain a routine failure.
   Four aggregate ancestors are deterministically exempt; a pin on one is
   `BREADTH-SCOPE`.
3. **Counts, never names.** The sentinel showed that a name manifest reveals the
   operator's installed tool/application inventory and that a filename with a
   newline can forge a line-oriented verdict. The gate writes NUL-delimited names
   only to a mode-600 temporary file, prints no child name, never follows child
   links, and removes the file before returning.
4. **Enumeration failure is not zero.** `find | wc -l` can mask `find`'s status.
   The gate captures `find -P` output first, checks its exit, then counts it;
   missing/non-dir/symlink/unresolvable roots are distinct fail-closed tokens.
5. **Directive arity is exact.** Existing two-field directives silently ignored
   third fields. R1 now refuses extra fields, closing the sentinel's unchecked
   `lane:.../../../...` smuggling shape before breadth data could inherit it.
6. **`$HOME` cannot be no-enumerate.** It previously satisfied R10 merely by
   being an ancestor of every census row. Whole-home widening is now
   `ENUM-CLASH` and is both selftested and falsified.
7. **Count drift is hard.** The critic argued that a new foreign binary under
   `.local/bin` should be informational. The landed decision keeps it exit 1:
   verification is manual, re-pinning is reviewed, and an unseen coverage change
   is exactly the event the axis move exists to surface. The cost is named as a
   bound, not hidden.
8. **No name-membership claim.** A same-cardinality delete/add swap remains
   invisible. This is accepted because name pinning regresses privacy; the gate
   claims breadth, not identity.

## 4. Defects found while landing

- The first permanent selftest run failed 7/43 cases because the old fixture
  declared no breadth rows; the fixture now carries three pins and every old
  scenario runs through R12/R13.
- After that repair, one case still failed: deleting an opencode asset used to
  be exit-neutral here (`surface-census.sh` owned `GONE`), but now legitimately
  also changes the pinned breadth. The test was updated to require both the
  named absent-asset line and exit-1 breadth drift; the old behavior was not
  re-pinned.
- An L1 scratch classifier timed out after launching a `grep` process per child
  per census row. The landed gate does one NUL enumeration and an in-process
  lexical loop; live verify is ~2.3 s on 182 entries.
- The connector falsified the round-16 citation to fleet ledger `D-96`: D-96 is
  about six sibling `SKILL.md` files outside discovery roots, not
  `$HOME/.config/opencode` ownership. The false attribution is removed; the
  ownership ruling remains honestly unassigned.

## 5. L2 wave

Nine L2s ran this round; eight ran in the required single batched call
(scout, critic, sentinel, mutation-tester, connector, executor, reviewer,
scribe), with the planner dispatched immediately before that wave.

| lane | evidence | disposition |
|---|---|---|
| planner | exact four-field grammar; derived leaf membership; fail-closed root/count classes | grammar + membership landed; its hard-drift reading chosen |
| scout | reproduced all eight directory ratios; found dotfile and symlink quirks | leaf four pinned; aggregate four recorded only |
| reviewer | independently reproduced 20/4, 105/2, 4/1, 53/1 and 35/27/8 | numbers accepted |
| critic | deletion passes opt-in draft; count swaps invisible; foreign churn debate | deletion closed; swap/privacy bound retained; hard drift chosen |
| sentinel | name-manifest privacy leak; newline verdict forgery; pipeline error masking; root symlink trap | count-only/NUL/checked-find/root refusal landed |
| mutation-tester | 18 proposed breadth mutants | 18 selftest cases + 9 shipped mutations selected |
| executor | scratch implementation and 28-case fixture | core shape reused; opt-in completeness and neutral missing-root rejected |
| connector | no sibling duplicates host-dir breadth; D-96 citation is false | overlap reported; D-96 corrected |
| scribe | report/knowledge/scorecard skeletons; explicit count-vs-handler-reach ambiguity | structure reused; wording narrowed to census-linked |

## 6. Bounds and score

Coverage rises to 9, not 10. The gate measures only one directory level and
only cardinality; equal-count membership swaps pass, aggregate ancestors are
un-pinned, census linkage is not handler reachability, host verification is
manual, and ownership truth remains a governance claim. These are specific
bounds, not a generic confidence discount.

## 7. Effective fallback relay

The operator asked for the effective global fallback chain. Read-only config
showed `modelRoles.m_swe = devin/swe-2:max` but
`retry.fallbackChains.m_swe = null`; the intended
`m_swe → openai-codex/gpt-daybreak-blue-latest:max` hop was not visible. No
genuine `m_swe` capacity failure occurred, so no advancement observation exists.
No config or frozen mission contract was changed.
