Author: R72Scribe (scribe)

# Round 72 — scribe seat report

Scope: draft the round's prose for the L1 to integrate. Drafts live at
`.ufo/waves/round-72/w1/R72Scribe/drafts.md`; this report is the summary and the routing list.
This seat wrote **only** under `.ufo/waves/round-72/w1/R72Scribe/` — no lane file, no fleet file,
no sibling lane. Read-only git throughout; no mutating git/jj command was run anywhere.

## Behavior

The L1 landed an integration commit (`61792976d8ffa11f37894c01d2ba7ec6e6b2a1ab`) **while this seat
was still running**, so most of the prose this seat was asked to draft was drafted and landed by
the L1 first. The seat therefore (1) verified every named sentence against BASE and against the
landed tree rather than proposing text blind, (2) drafted the replacement text anyway and marked
which of it is already landed, and (3) hunted the prose that the integration left **inconsistent**,
which is where the seat's remaining value sits. Three defects were found; none is counted by C1 or
C2, and all three are prose.

## Gates (re-measured by this seat, from the lane root)

| gate | command | result |
|---|---|---|
| C1 at landed HEAD | `bash plans/round-72-c1.sh HEAD` | `C1_CLOCK_REARM: value=10 rows_passing=10 gate=1 fresh=1 census=1 live=1` rc 0 (12.2 s) |
| C1 at BASE | `bash plans/round-72-c1.sh b2f3dd661abda0ebd09b3f8ffc3f64904606d4d9` | `C1_CLOCK_REARM: value=0 rows_passing=0 gate=0 fresh=0 census=1 live=1` rc 0 (9.0 s) |
| C2 at landed HEAD | `bash plans/round-72-c2.sh HEAD` | `C2_SELF_COUNTS: value=0 pins=1 shape=1 claims=63 policy=2 ok=61 stale_ids=none` rc 0 (19.2 s) |

BASE 0 → 10 on C1 and 0 on C2 at HEAD reproduce the declared targets. The BASE C1 failure reasons
(`not-armed,not-newer,unsourced,live=2.2.1,no-ledger`) confirm the counter is not vacuously
satisfied at HEAD: every one of the ten conjuncts was false at BASE for a *named* reason.

Own receipts: `.ufo/waves/round-72/w1/R72Scribe/receipts.txt`. The scratch dir
`/fast/scratch/hyaku/kagi-r72/R72Scribe` was removed at yield; no scratch or `/tmp` path is cited as
evidence anywhere in this report or in the drafts.

## Touched surfaces

- `.ufo/waves/round-72/w1/R72Scribe/drafts.md` — the three deliverables (a) replacement text, (b)
  capability-row verdict, (c) lesson §Gate draft.
- `.ufo/waves/round-72/w1/R72Scribe/receipts.txt` — this seat's own command outputs.
- `.ufo/waves/round-72/w1/R72Scribe.md` — this report.

Nothing else in the lane was created, edited or deleted. `git status --porcelain` at the lane shows
only `.ufo/waves/round-72/w1/R72Scribe/` plus the L1's own pre-existing `final/` artifacts.

## Deliverable (a) — replacement text for the sentences that become false

Drafted in full in `drafts.md` §A, each with the BASE text, the replacement, and the reason. Six
surfaces were affected; the candidate moves the default receipt from the round-54 receipt to the
round-72 receipt, moves `fired` 14 → 4, and re-anchors ten derived clocks.

| surface | landed? |
|---|---|
| `corpus/release-clock.py` `--receipt` help text (line 2157) | **landed** at `6179297`, matches this seat's draft including the "against their own revision's table" clause |
| `SKILL.md:48` decision-table cell (the round-54 receipt → round-72 receipt; fired list; retained receipts; `retains fired old anchors` exception) | **landed**, matches |
| `SKILL.md:48` cell 3 failure list (the new "appending a feed row without searching the registry for its URL" refusal) | **landed**, matches |
| `SKILL.md:796` coverage-map row "source release clocks" | **landed**, matches |
| `PROVINCE.md:75` gate line | **landed**, matches |
| `corpus/README.md:147` Frontier bullet | **landed** as an appended round-72 clause, matches |
| `corpus/SOURCES.md` "## Paths" bullet "Observable release clocks" | **NOT landed** — residual, see finding R72-S1 |

Every history clause is preserved in the drafts: the S072 op CLI clock and its
`FEED_TITLE_PREFIXES` rule, the round-53 S103/S104 SOPS/age bindings, the five retained receipts,
the round-46 retirement of the S040/S041 successor clocks, the S098 `Revision 25` binding, the
`--observe` mismatch semantics, the round-28 `NON-CANONICAL`/`DERIVATION` rules and the 121-case
selftest count.

## Deliverable (b) — capability row for "release-clock re-arm of derived clocks"

**Verdict: NOT a new capability; do not enter a row.** Stated with reasons in `drafts.md` §B:
`AXES.md` §Capabilities admits a row only through a round that demonstrates the capability running;
the repertoire already carries **`release-clock observation`** (first-working round 25), and the
re-arm duty itself is older than this round (QM24 at round 26, exercised on S027/S028 through
S040/S041). Round 72 is the same instrument on a new population (derived clocks, whose anchor is
bound to the feed row's anchor cell under QM28) — the lane's own round-26 record put the identical
event on the **freshness** axis and added no capability row. The round-72 SCORECARD freshness cell
plus the lesson already carry the procedure. An optional *append*-form sentence is drafted in §B for
the L1 if it wants the procedure visible in the table, explicitly in the QM97 correction form and
not as a new row; this seat recommends against entering it.

## Deliverable (c) — lesson §Gate block for S174 and S175

Drafted in full in `drafts.md` §C with both quotes located by this seat in
`.ufo/waves/round-72/capture/S174.body` and `S175.body`:

| id | quote | raw-literal-v1 | rendered-text-v1 |
|---|---|---|---|
| S174 | `<title>v2.2.1</title>` | count 1, byte offset 726 | count 0 (markup is stripped) |
| S175 | `<title>v2.7.2</title>` | count 1, byte offset 729 | count 0 (markup is stripped) |

The offsets match the byte offsets the round-37 rows S089/S090 already record for the same two
feeds, so the round-72 captures put the same first stable entry at the same place — independent
evidence that the identity is the same entry, re-read. This seat additionally located one
release-note sentence **inside the first (v2.2.1 / v2.7.2) entry** of each capture that the lane's
default normalizer finds (rendered-text-v1 count 1), so the Gate row can carry a quote that both
normizers locate:

- S174 (18 words, needle byte 1147, first entry span 503–4207): `core/policy: Fixed a cache-key
  collision vulnerability that could cause policy-name aliases to resolve to the immutable root
  policy.`
- S175 (15 words, needle byte 5797, first entry span 505–30010): `auth/oidc: Fix login in direct
  callback mode by including the namespace in the redirect URI.`

Both entries carry tag `/releases/tag/v2.2.1` / `v2.7.2` and `<updated>` 2026-10-23T17:34:44Z /
2026-10-26T20:24:37Z. The landed lesson already carries the two decisions, the rejection row, the
two identity quotes and the reason clauses; the two corrections below are optional prose
improvements, not counted by C1 or C2.

## Findings — three residual prose defects in the landed tree

All three are prose. None changes a counter number, a gate verdict, or a census row; no instrument
reads any of the surfaces involved.

**R72-S1 — `corpus/release-clocks.tsv` notes name the wrong superseded predecessor.** At the
candidate the ten notes read `through S174 (supersedes S034, opened 2026-11-09)` / `through S175
(supersedes S035, …)`. The integration changed the *registry* rows instead (`corpus/SOURCES.md`
S174 → `supersedes S089`, S175 → `supersedes S090`, M72-1: S089/S090 already held those identities
since round 37) and did not touch the clock table — `git diff a947a42c 6179297 -- corpus/release-clocks.tsv`
is empty. The landed tree therefore disagrees with itself: 4 clock rows still say "S174 supersedes
S034" and 6 say "S175 supersedes S035", while the registry says S174 supersedes S089 (whose own
`teaches` cell says "supersedes S034 as the current release anchor") and S175 supersedes S090. The
note parenthetical names the wrong row. The round's own `dup-supersede.sh` cannot see this: it
defaults to `corpus/SOURCES.md` and splits registry rows on `|`, so pointed at the TSV it prints
`DUP_SUPERSEDE: 0` — the duplicate claim is invisible to the check written to catch it. Draft
correction (keeping every history clause) is in `drafts.md` §A.7; the prior anchors 2.2.0 / 2.7.1
remain visible in `corpus/clock-rearm.tsv`'s `prior_anchor` column, so nothing is lost.

**R72-S2 — `corpus/SOURCES.md` "## Paths" bullet still names the superseded study path.** Line 178
reads `S033 → S034 → S035 → S036 → S037, with S038 rejected`. After the re-open the two middle
legs are superseded (S034 → S089 → S174, S035 → S090 → S175), so the path names rows that no longer
carry the current Vault/OpenBao release anchors while the registry's `teaches` cells say otherwise.
Draft replacement in `drafts.md` §A.6. No instrument parses the Paths block
(`grep -rn 'supersedes' corpus/*.sh corpus/*.py` → 0 hits).

**R72-S3 — the lesson §Gate access time for the two feeds is an interpolated minute.** The landed
row says the feeds were `accessed 2026-11-09T04:00Z`. The committed evidence for the two **feed**
rows is the **date** only: `corpus/source-fetches.tsv` col 8 = `2026-11-09` for S174 and S175, and
the only committed per-request timestamps are
`.ufo/waves/round-72/controls/tools/page-times.tsv` (04:00:43Z–04:00:45Z) which hold the ten
**page** fetches, not the feeds'. The nearest committed time-bearing evidence for the feeds is the
round-72 receipt's own observations of those feed URLs — 2026-11-09T04:01:39Z (Vault) and
2026-11-09T04:01:40Z (OpenBao) — whose recorded sha256 equals the committed capture bytes exactly
(this seat verified both: `receipt_sha == capture_sha: True` for S013↔S174.body and S014↔S175.body).
Draft clause in `drafts.md` §C.1a.

## Out of scope / not this seat's business

- `.ufo/waves/round-72/w1-results.json` does not exist yet; the fleet gate
  `scripts/hyaku/prefile-falsification.py` reads it to derive the attack-seat set. The L1 owns it.
- The falsification ledger `.ufo/waves/round-72/claim-falsification.tsv` has 11 rows covering the
  8 attack-role seats (R72Reviewer, R72ReviewerSrc, R72Critic, R72MutTester, R72MutLater,
  R72Sentinel, R72Revenger, R72Connector) plus R72ExecReplica, R72ExecHarm and R72Scout. This
  seat's role is `scribe`, which is **not** in the gate's `ATTACK_ROLES`
  (`reviewer, security-reviewer, critic, mutation-tester, sentinel, connector, revenger, labrat`),
  so no ledger row is required for R72Scribe and this seat did not touch the ledger (it is not in
  this seat's write scope).
- `SKILL.md:800` ("The default `python3 corpus/release-clock.py` replays the **pinned round-26
  rearmed receipt**") is present-tense prose inside the dated `## Round-26 release-drift response`
  section and was **already false at BASE** (BASE default was the round-54 receipt; `git show
  b2f3dd66:SKILL.md` reads identically). It is a pre-existing staleness the candidate neither
  creates nor cures. The lane's own round-36 precedent was to update the current-state rows and
  leave the dated section alone, and the integration followed it. A one-line dated correction naming
  the current default could be appended, but that is a lane-policy call for the L1, not a
  candidate-introduced defect, and this seat did not draft one.
- Tooling: no package was installed or upgraded by this seat; nothing to record under the
  operator's tooling directive. Every command used tools already present on the host
  (`bash`, `git` read-only, `python3`, `grep`, `awk`, `sed`).
- Refusal boundary honoured: no vault, no `op`, no credential file, no `~/.ssh`, no
  `~/.vault-token`; only public GitHub release feeds and public documentation were read. No
  token-shaped string appears in this report or in the drafts.

## Known limits of this seat's work

- The three findings are prose consistency defects. No gate reads the clock table's note column, the
  Paths bullets, or the lesson's access-time clause, so none of them can change a measured number —
  which is exactly why they survive the round's instruments and why they are reported here rather
  than left implicit.
- The §Gate body's two rendered-text-v1 quotes are located but not yet in any committed file; if the
  L1 adopts them it should re-run `python3 corpus/rendered-text-v1.py locate` on the committed
  capture after the edit (this seat's count=1 was measured on the landed capture bytes, sha256
  `3ead3d0f…2e6ffc` / `a54d1a53…f2e0e`).
- This seat did not re-run the round's 20 prefreeze controls; it re-ran the two frozen counters at
  BASE and HEAD, which is what the drafts' claims rest on. The controls' verdicts are the L1's
  receipt (`controls/receipts/summary.txt`, 20/20 MATCH), which this seat read but did not reproduce.

## Artifacts

- Report: `.ufo/waves/round-72/w1/R72Scribe.md`
- Drafts: `.ufo/waves/round-72/w1/R72Scribe/drafts.md`
- Receipts: `.ufo/waves/round-72/w1/R72Scribe/receipts.txt`

FINDING R72-S1 neutral the ten re-armed clock-table notes still name S034/S035 as the superseded predecessor while the landed registry names S089/S090; prose only, no counter reads the note column
FINDING R72-S2 neutral the corpus/SOURCES.md Paths bullet still reads S033 -> S034 -> S035 -> S036 -> S037 after the re-open superseded the S034 and S035 legs
FINDING R72-S3 neutral the lesson Gate access time 2026-11-09T04:00Z for the two feeds has no committed time-bearing receipt, only the fetch date; the receipt's own feed observations are 04:01:39Z and 04:01:40Z
SEAT-STATUS: complete three deliverables drafted in .ufo/waves/round-72/w1/R72Scribe/drafts.md; C1 10 at HEAD and 0 at BASE and C2 0 re-measured; three residual prose defects routed; capability row recommended against
