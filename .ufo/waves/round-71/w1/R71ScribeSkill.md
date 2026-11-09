Author: R71ScribeSkill (scribe)

# Round 71 — scribe seat: lane-surface update proposals (C1 depth)

Scope: drafts for integration only. No lane file was edited; nothing was committed, staged, or
pushed. Drafts are in `.ufo/waves/round-71/w1/R71ScribeSkill/`. The counter was not run (it is not
this seat's assignment); every counter number in the drafts is the placeholder `<FINAL COUNTER LINE>`.

## Files (drafts)

| draft | what it is | integration target |
|---|---|---|
| `skill-rows.md` | four new decision-table rows (T6 NotAfter, T7 per-issuer CRL, T8 token-less OCSP, T9 proof-of-possession revocation), in the table's four-column shape, each citing the round-71 entry | `SKILL.md` after line 55 |
| `province-line.md` | one Core bullet for round 71 with a counter placeholder | `PROVINCE.md` after line 97 |
| `readme-row.md` | one coverage-map row in the exact shape of the round-70 row, and the two README counts that change (stamps line 65; knowledge entries line 67) | `corpus/README.md` after line 95 |
| `scorecard-draft.md` | §A capability-table row (enters only at value=4); §B round-71 post-move in the round-70 shape with one `[C1]` depth row; §C the round-71 pre-move reproduced from the working tree; §D an appended errata for the round-70 PKI entry | `SCORECARD.md` |
| `corrections-sweep.md` | every place that is stale, false, or missing if the round lands (32 items, S/P/N/O labelled) | integration checklist |
| `counts-readonly.txt` | the read-only counts the drafts rely on (commands and output) | receipt for every number below |
| `round70-harm-rechecks.txt`, `c1-candidate.txt`, `l1-probe-observations.txt` | copies of receipts cited here | — |

## Findings the integration must act on

- **Stamps are incomplete.** At candidate `39e76bc` the stamp file has 178 data rows (177 at the freeze
  `1199295`), and the only round-71 stamp is the new knowledge entry. `corpus/openbao-pki-issuer-trial.sh`,
  `plans/round-71-c1.sh`, `plans/round-71-controls.sh` and `plans/round-71.md` have no stamp rows
  (`counts-readonly.txt`: `stamps_mentioning_round71_or_trial: 0`). The round-70 pattern pinned the
  trial and the counter. Decide the stamp step before the README count is written.
- **Claims manifest row missing.** `corpus/claims-declared.tsv` ends at `70 C1 coverage`. The round needs
  `71 C1 depth` (the plan's heading `## C1 — depth:` matches the gate's required shape).
- **Capability row and a stale paragraph.** The `## Capabilities` table (SCORECARD line 696) has a
  round-70 PKI row (`| 70 |`). The paragraph after it still says the latest first-working round is 62.
  That was already false at round 70. The round-71 row is drafted and enters only at `value=4`.
- **Knowledge-entry summary line is abbreviated.** The entry quotes `OPENBAO_PKI_ISSUER_TRIAL: HOLDS
  holds=4 broken=0 error=0`; the script prints `bao=<ver> openssl=<ver>` as well (trial line 64).
- **Recheck clock mismatch (class already routed at round 70).** S170 and S173 read `180d` in the registry
  recheck column (`awk -F'|'` on column 11). The new entry says `recheck: on-release`. The release-clock
  table has no S170/S173 row, so that clock is text only. Proposed entry wording: `on-release (content
  clock; registry recheck 180d)`. The registry cells stay as they are (append-only).
- **Round-70 entry's `Does not establish` list is partly superseded.** It lists `leaf_not_after_behavior`,
  OCSP, multi-issuer chain building and revocation with a private key. Round 71 measures three of these
  and per-issuer CRL routing. Proposed: a dated appended note (scorecard-draft.md §D), no rewrite.
- **Pre-existing stale self-counts (carried, not caused by round 71).** `SKILL.md` line 46 says
  `164 stamps + 101 claims`; `PROVINCE.md` line 73 says the same. The self-counts gate reads
  `POLICY … stale=4` with ids `SC-SKILL-STAMPS`, `SC-SKILL-CLAIMS`, `PV-STAMPS`, `PV-CLAIMS` (round-70
  spot-check `final/harm-rechecks.txt`, same four ids as BASE). Live values at the candidate are 178
  stamps and 102 claims (claim count unchanged; 120 non-blank ledger lines before and after). Fixing
  them is an integration decision; this seat only names them.
- **Count changes on README.** Line 65: 177 → 178 stamps, subject to the stamp decision above. Line 67:
  `47 row-linked / 3 by-hand / 50 pinned` → `48 / 3 / 51` (51 knowledge files at the candidate; the
  gate's own `claim-ledger.sh docs` number is authoritative).
- **Registry.** 163 → 164 rows (`grep -cE '^ {0,3}\| *S[0-9]{3}' corpus/SOURCES.md`). S173 is mined and
  its capture sha256 begins `42ef7582` (matches the round-70 scout capture).
- **Working tree is already ahead of the commits.** `SCORECARD.md` carries an uncommitted 27-line
  insertion: the round-70 freshness errata and a `## Round 71 — pre-move` section. The scorecard draft
  reproduces that text (§C) so integration can diff it. The post-move section does not exist yet.
- **Gate-registry gap (carried).** Round 70 added no registry row for its trial or counter; round 71 drafts
  none. This is an integration decision, not a stale line.

## Placeholders left open (by design)

`<FINAL COUNTER LINE>` and `<rc>` (PROVINCE, README, SKILL row text, SCORECARD §A and §B);
`<integration rev>`; `<SOURCES_CENSUS line at integration>`; `<R71Connector seat report, pending>`.
The L1 receipt `.ufo/waves/round-71/final/c1-candidate.txt` reads
`C1_PKI_ISSUER_TRIAL: value=4 … T6–T9 real=HOLDS,shim=BROKEN,spec=1,entry=1,art=1,ok=1`, rc 0. It is
cited as the L1 receipt only; the drafts do not take it as the final reading.

## What I did not do, and why

- No counter, trial, `bao` server, or gate was run. The assignment is drafting; the final reading and gate
  runs belong to integration. No `bao server -dev` was started, so there was nothing to kill.
- No file in the lane or the fleet repo was edited. The only writes are the drafts, the copied receipts,
  and `counts-readonly.txt` in my own seat directory. Scratch `/fast/scratch/hyaku/kagi-r71/R71ScribeSkill`
  was created for the run and removed before yield.
- Read-only git was used only for `git show 1199295…:corpus/stamps.tsv`, `git rev-parse`, `git log` and
  `git status --porcelain`; no mutating git or jj command ran.
- No tool was installed or updated (no install record needed). pacman was not used.
- Claims checked against the entry and the trial header only (the trial body was not re-executed). The
  "default `err` refuses the same request" wording in skill-rows row 1 is the entry's documented
  statement, not a counted verdict; the notes say so.

SEAT-STATUS: complete drafts delivered (4 proposed SKILL rows, 1 PROVINCE line, 1 README row plus 2 count changes, SCORECARD round-71 capability row/post-move/errata, 32-item corrections sweep); final counter reading and gate runs are integration's and remain placeholders
