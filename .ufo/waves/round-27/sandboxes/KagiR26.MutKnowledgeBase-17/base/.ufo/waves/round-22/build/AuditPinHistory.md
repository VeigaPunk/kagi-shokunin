# AuditPinHistory — C2 pin reconciliation

Axes: **freshness** (assigned C2 only; no C1 adjudication performed).

## Delivered implementation

Added `corpus/revision-audit.py` **only in** the private clone `/tmp/kagi-r22-AuditPinHistory`, created from frozen base `c2cab35bc92e57e39e5489bac3386db078345b3f`. Before these additions, the implementation was synchronized from the exact integrated H1 source `8ada17a50a25a75e6fc4a8cf880c87a85c67c8a3` (`ac19e186ce6f8e70ad6443058f0569222519d501a55106c813fa5f71ed1f8977`); its `GIT_NO_LAZY_FETCH`, `GIT_NO_REPLACE_OBJECTS`, and root-prefix handling were preserved.
The read-only CLI is `python3 corpus/revision-audit.py --history <full-hex-commit-id>`; `--root <repo-root>` is available for isolated fixtures. It rejects refs, abbreviated IDs, revision expressions and option-looking history inputs before any Git lookup. The history value must resolve to a commit object; after commit-type validation, its canonical Git object ID must exactly equal the lowercased full input, preventing a 40-character prefix from passing in a SHA-256 repository. Historical `corpus/stamps.tsv` is read using fixed-argument, read-only `git cat-file`; the commit supplies membership only. Current stamps and pinned bytes are read from the worktree. SHA-256, newline count (`wc -l` semantics) and byte count are computed from the same safely opened file descriptor; traversal is descriptor-relative, no-follow, and rejects cross-device entries. Any path component exactly `.git` or `.jj` is rejected before opening; `.gitignore` remains permitted. Regular target files must have link count one, so hardlinks fail closed before contents are read. No command or URL is evaluated, no external target is contacted, and no automatic restamp or other write occurs.
Output is sorted and path-stable: `STALE <path>`, `MISSING <path>`, `DROPPED <path>`, informational `ADDED <path>`, and setup findings for malformed/duplicate/unsafe inputs, followed by stale/missing/dropped/added/invalid counts. Exit 0 is clean, 1 is revision drift, 2 is cannot-evaluate/setup error. `--selftest` is an isolated temporary-Git fixture arm with **17 cases**, each asserting the expected exit plus finding ID (or no findings for the clean control): the prior 15 cases (clean, dropped, modified-worktree stale, missing, malformed/duplicate current and historical rows, traversal, parent symlink, FIFO, option history, Git/JJ admin paths, hardlink, and `.gitignore` control), plus SHA-256 full-64 acceptance and truncated-40 rejection. The `.gitignore` control restores `keep.txt` and retains the two baseline stamp rows before adding `.gitignore`, so it expects only `ADDED .gitignore`. **No checks or selftest were run**, as instructed.


## Historic finding: nine mismatches were not nine deleted members

Read revisions: `aea7a4301034aa9160ada69457a6427f77064169` (the logged round-21 baseline), `c41af82dfb11ac74b5cb40284415ed366554262b`, `e1544c194fddf1bb073b3946847b4526f326ad73`, and frozen base `c2cab35bc92e57e39e5489bac3386db078345b3f`. These are read-only Git-object measurements; file bodies/commands were not executed.

`LOG.md:982-984` records nine `sha256sum --check` mismatches at `aea7a43`, with five untouched rows intentionally left unpinned. Recomputing those nine rows against the committed tree at that revision reproduces exactly these paths and measurements (`stamp sha/lines/bytes → aea7a43 blob sha/lines/bytes`):

| Path | Stamped at aea7a43 | Committed blob at aea7a43 |
|---|---|---|
| `corpus/knowledge/config-layering.md` | `848b8e502ea2046aacd3f8ae1717d6a4882b07c9317d13d012eb5bae6c88fe83 / 109 / 6621` | `9d4ac8c24981a64b02a2a67cdd54fd5102c62d516224965392fb422aada18cf0 / 136 / 8088` |
| `corpus/knowledge/handler-on-disk-state.md` | `811572dcf630efc89e9222ed6c9e545a9b755f05be2908a6e0487a0fa8862be2 / 247 / 17609` | `df6a5e5d05f4fa06cdcf2114c3a212e48c6b697d56cca1ced63342133e649c38 / 277 / 19329` |
| `corpus/knowledge/handler-trust-boundary.md` | `263c7b0e734c299ae795ac8a5168f1dae562c875959820257c1c6294072dd5e5 / 285 / 17669` | `fa17fff38dfbed86d66acb17dcb2c931b9c31280ce4d2ce41f05269b12561eba / 316 / 19410` |
| `corpus/knowledge/janitor-env-contract.md` | `88dca63ac7e6137f6a737439f18e99b9f602f57a065c63c478c364b46d873c1f / 90 / 5111` | `dac43ef973938efaba5f990fd185d6137b0d66b1703ef714c44d2b3eedd492a4 / 113 / 6372` |
| `corpus/lessons/round-18.md` | `614335f2a8cbd9507021d4f32a928faca7e4c4d8947f866564b676706cbe9f17 / 73 / 4216` | `b00b7dd8d5b2b469d6633752e4575cc830df4e9bd4e7947b2754ff4b31477b49 / 80 / 4557` |
| `corpus/op-ref-probe.sh` | `509f084ad33229db5b7421e1da948c02f9d191a6098f7a449341cf9adc95da1c / 660 / 28660` | `0f1945e8d8a8fc56aaee256180cd7badde466bc8ac91503aa1e1853e79044f4c / 788 / 34362` |
| `corpus/README.md` | `6ddda47d8babffe68bbef905eb37396d20c45a5c39fe217d1e5b91a981ddb292 / 86 / 18689` | `d669dfbfffa6c769ec50d96a7a87473773fdc88c3357f09d41a6d09936267146 / 92 / 19193` |
| `LOG.md` | `e6db90d2a37c4b347e5b9a4e2373d1fc3a8a2747a9746be361358c04eb817e9b / 762 / 56847` | `904e71e98e6eacb442749adcf93147629cba9204fb775b3b51b87861cbbeac83 / 963 / 68885` |
| `SCORECARD.md` | `f3e61bfe2e7878cb8a3ffe22bde79dd7b8479f416d4c8fa628468981fb58c113 / 446 / 66069` | `fa452bc318ad1efd0395691a8ec99d5174366f25efccadcf78e296ec0aab988a / 621 / 77831` |

The exact member-set comparison is different from the nine-byte-mismatch count: `aea7a43` declared 56 distinct stamp paths; frozen base declares 63; **dropped=0, added=7**. The seven added paths are `corpus/QUALITY.md`, `corpus/SOURCES.md`, `corpus/knowledge/onepassword-machine-credentials.md`, `corpus/knowledge/sops-age-key-rotation.md`, `corpus/knowledge/vault-openbao-token-lease-lifecycle.md`, `corpus/lessons/round-21.md`, and `corpus/sources-census.sh`. All 56 historical member IDs remain declared. Thus “nine previously dropped stamps” is not supported as a membership deletion by the available Git history: it is the nine stale stamp rows recorded in `LOG.md`.

At frozen base `c2cab35bc92e57e39e5489bac3386db078345b3f`, the **five originally stale paths** named in `corpus/lessons/round-21.md:85` remain stale: the five knowledge/round-18 rows above. There is a sixth stale row, `LOG.md`: its pin is `60a8fd366c8340800be603eb4b7bca5ad615de1c415eaccf815194babf341d60 / 1043 / 74864`, while the current frozen-base file is `51e76cf1f69f4007c79c27d6f6f84d19371c6add0da60d81dfa5021920fd389a / 1050 / 75404`. The `e1544c1..c2cab35` diff adds seven log lines for a documentation-only wiki-link directive; this later edit explains the extra stale row but does not make its pin current. Of the other four paths from the historical nine, `op-ref-probe.sh`, `README.md`, and `SCORECARD.md` match their frozen-base pins; `LOG.md` is stale again after the later append.

### Restore recommendation

Do **not** restore old hashes as current pins or add duplicate rows: the historical member set was not deleted. Preserve all 56 old members and all seven later additions. Treat the five inherited rows as named debt, review each current worktree file, then update only its existing stamp row to the reviewed file’s SHA-256/`wc -l`-equivalent newline count/byte length. Separately review and refresh the `LOG.md` row for the documented seven-line change. Do not touch the three already-current rows (`op-ref-probe.sh`, `README.md`, `SCORECARD.md`). This follows `corpus/knowledge/claim-ledger.md:49-55`: re-pinning is a reviewed change, not a silent repair.

## Claim-ledger expectation migrations

Exact row values were extracted from `git show <revision>:corpus/claim-ledger.tsv` at the revisions above. These are historical expectation moves; keep their rationale and old values visible rather than normalizing history:

| Row | Earlier expectation | Later/current expectation | Revision and evidence |
|---|---|---|---|
| `R12-02` | `OP_REF_SELFTEST: PASS (29 cases)` | `OP_REF_SELFTEST: PASS (36 cases)` | `aea7a43` → `c41af82`; row note says the unclaimed `--dotenv-bytes` arm added seven comparator cases. Current `claim-ledger.tsv:27`; round-21 `corpus/lessons/round-21.md:15`. |
| `R12-03` | `56` stamp rows | `63` stamp rows | `aea7a43` → `c41af82`; seven round-21 artifacts entered the declared set. Current `claim-ledger.tsv:28`. |
| `R13-01` | `20` scorecard headings | `23` headings | `aea7a43` → `c41af82`; two round-21 pre/post headings plus the round-20 attempt heading are included. Current `claim-ledger.tsv:29`. |
| `R14-01` | `entries=21 row_linked=18` | `entries=24 row_linked=21` | `aea7a43` → `c41af82`; three sourced entries were added. Current `claim-ledger.tsv:32`. |
| `R21-03` | `SOURCES_CENSUS_SELFTEST: PASS (40 cases)` | `SOURCES_CENSUS_SELFTEST: PASS (47 cases)` | `c41af82` → `e1544c1`; post-landing review added seven fail-open mutation cases. The diff changes only this expected case count; current `claim-ledger.tsv:53` and `corpus/lessons/round-21.md:99-104`. |

`R21-04` (`39` claim rows) is a newly added expectation at `c41af82`, not a migration from an earlier row. At `e1544c1` and frozen base, `R21-03` remains 47 cases. No claim-ledger row was edited by this assignment.

## Limits, risk, and handoff

- The implementation is written only in the requested private clone; no production implementation file, live Git/JJ state, index, or configuration was changed. The advisory report is the only production-tree write.
- A stale pin establishes worktree byte/line/size disagreement, not whether the content edit was intended. The five inherited paths remain for an owner’s content review; the tool does not bless them.
- Checks were not run. Parent should run `python3 corpus/revision-audit.py --selftest` (17 cases), then invoke `python3 corpus/revision-audit.py --history c2cab35bc92e57e39e5489bac3386db078345b3f` after integration. The selftest covers canonical SHA-256 ID validation, Git/JJ admin-path rejection, hardlink rejection, `.gitignore` acceptance, parent-symlink rejection, and FIFO rejection; add remaining fixture attacks for final symlink/dangling link, malformed rows after valid prefixes, invalid full-hash object types, and an `--history=--output=...` sentinel. Assert stable findings/exit codes and no external bytes or fixture Git/worktree mutation.
- No tools were installed or updated.

Report: `.ufo/waves/round-22/build/AuditPinHistory.md`
