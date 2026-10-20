# Entry11 — `handler-trust-boundary.md` freshness/calibration audit (read-only)

Base: `c2cab35bc92e57e39e5489bac3386db078345b3f` (HEAD; both audited paths clean in
`git status --porcelain`).
Read revision: working tree = HEAD blob
`fa17fff38dfbed86d66acb17dcb2c931b9c31280ce4d2ce41f05269b12561eba`.
Date of this read: 2026-10-20. No gate, no build, no host probe executed;
all statements below are file/git metadata plus `sha256sum/wc/cmp`.

Axes named: **C1 calibration** — classify the entry correctly (historical, not
current; no E1/E3 transfer), and admit only the bounded row-level control.
**C2 freshness** — separate stale bytes from substantive staleness and reconcile
one pin with exact provenance, no silent deletion, no laundering.

## 1. Observed state

| Object | sha256 | `wc -l` | bytes |
|---|---|---|---|
| `corpus/knowledge/handler-trust-boundary.md` (HEAD) | `fa17fff38dfbed86d66acb17dcb2c931b9c31280ce4d2ce41f05269b12561eba` | 316 | 19410 |
| `corpus/stamps.tsv:19` (row) | `263c7b0e734c299ae795ac8a5168f1dae562c875959820257c1c6294072dd5e5` | 285 | 17669 |

Display lines are 317 vs the row's 285; the file has no trailing newline
(last byte `0x2e`), and `wc -l` is the contract's measure
(`corpus/knowledge/claim-ledger.md:39-43`). Existing citations of the erratum as
`:288-317` use display lines and are correct.

Mismatch is real and mechanical: **+1741 bytes, +31 `wc -l` lines**
(`git diff --numstat` = `32 1`).

## 2. Stale bytes are fully attributed (not an unexplained edit)

- `2486643` (round-14, 2026-09-28) added the row and, at that commit, the blob was
  exactly `263c7b0e… / 285 / 17669` — the stamp was **accurate when authored**.
- `f4a8dd9` (round-16 re-dispatch, 2026-10-15) appended the
  `## Historical-source erratum` block. `git show --name-only --format= f4a8dd9`
  contains **no** `corpus/stamps.tsv`; the stale row is a missing re-pin.
- The row was never deleted or rewritten: zero `^-corpus/knowledge/handler-trust`
  lines across the nine revisions of `corpus/stamps.tsv`, and it is **not** among
  the nine values replaced in `e1544c1`.
- Append-only preservation holds byte-for-byte:
  `cmp -n 17669 <(git show 2486643:path) <(git show f4a8dd9:path)` → **exit 0**.
  The diff is a single tail hunk (`@@ -283,4 +283,35 @@`); the sole `-` line is
  the unchanged final text `  callers.` re-emitted after adding a trailing
  newline. `15ea78c:path` is the same pre-append blob
  (`263c7b0e/285/17669`), so round-16's `SOURCE_PRESERVATION: preserved=4/4`
  (`LOG.md:790-799`) used identical bytes.

Verdict: **stale-byte mismatch ≠ unclaimed edit.** Round-16 claimed and logged
this append; only the pin was not refreshed.

## 3. Substantive freshness

The existing erratum is substantively fresh and internally accurate:

- `Source-status: historical — ` at line 290 matches the gate regex
  (`/^Source-status: historical — /m`).
- Its line references check out against the preserved original: source basis
  3-11, verification marker 9-10, by-hand declaration 17, tail limit 284-286,
  and "through line 286" (original display 286).
- It makes no current hash, posture, or successful-task claim, and it explicitly
  requires restoration plus separate authorization before re-verification.

No new fact in this read contradicts it. **No appended correction is needed.**
The later host delta (below) is a dated observation, not a correction of the
2026-10-15 text; appending it would be new unadjudicated metadata and would force
another re-pin.

Do not move the freshness score for this entry: it remains historical, and
re-pinning is not re-verification.

## 4. Absent-source limits (observed 2026-10-20, metadata only)

`ENOENT` for all cited sources:

- `~/.local/bin/the-janitor`
- `~/.config/the-janitor/client.py`
- `~/.config/the-janitor/config.json`
- `~/.config/opencode/agents/janitor.md`
- `~/.config/opencode/tools/janitor_auth.ts`
- `~/.config/opencode/plugin/fnm-nudge.js`
- `~/.opencode/bin/opencode`

Consequences: none of `2408b0c9…`, `8179b241…`, `333`/`117` line counts,
opencode `1.18.31`, the auth matrix, or routes A/B/C can be re-verified. The
erratum recorded the opencode binary as **present** on 2026-10-15; it is now
absent. That dates but does not falsify the erratum, and it further narrows the
recheck to repo bytes plus absence metadata. Do not expand the abbreviated
hashes (named debt, `SCORECARD.md:454-466`).

## 5. C1 adjudication of claims about this entry

| Claim | Decision | Grounds |
|---|---|---|
| "A stale row proves an unreviewed edit" | **reject** | Delta is exactly `f4a8dd9`, logged at `LOG.md:790-799`, prefix-preserving |
| "`DOC_AUDIT: CLEAN` proves the pinned revision" | **reject** | `docs` checks stamp *membership* only; `verify` compares all four columns (`claim-ledger.sh:344-346`); the lane does not run `verify` (`lessons/round-21.md:84`) |
| "Round-21's 'no round claimed the edit' applies here" | **reject for this path** | Round-16 claimed it; the blanket rationale is falsified by `f4a8dd9`/LOG. It may still hold for the other four named rows, which this audit did not examine |
| "This entry is current / its socket posture is established" | **reject** | Historical only; all sources absent; no byte read |
| E1 (Broker eligibility / EPM Business) or E3 (lease-vs-KV-deletion) findings attach here | **reject** | This entry is neither `onepassword-machine-credentials.md` (E1) nor `vault-openbao-token-lease-lifecycle.md` (E3); no feature decision is made or transferred |
| One-row re-pin with provenance + absence-only recheck | **admit (bounded)** | Repairs the only demonstrable defect without asserting any vendor fact |

This keeps C1 and C2 causally separate: the row repair adjudicates no source, and
the source/status decision does not depend on restamping.

## 6. Proposed correction (exact)

One line only — `corpus/stamps.tsv:19`, replace all four columns:

```
old: corpus/knowledge/handler-trust-boundary.md	263c7b0e734c299ae795ac8a5168f1dae562c875959820257c1c6294072dd5e5	285	17669
new: corpus/knowledge/handler-trust-boundary.md	fa17fff38dfbed86d66acb17dcb2c931b9c31280ce4d2ce41f05269b12561eba	316	19410
```

- No edit to the entry; no appended correction.
- No row added or deleted; non-comment row count stays 63, so `docs`/`cells`
  membership pointers keep resolving.
- **Do not** run `claim-ledger.sh stamp` over the full set: it would re-pin five
  other stale rows and four dirty in-flight files, which is laundering.
- Record `316` (wc), not `317` (display) — `verify_stamps` compares bytes, lines
  and sha (`claim-ledger.sh:344-346`), so an off-by-one recreates STALE.

## 7. Exact proposed recheck scope

Run after integration, repo-local only:

```bash
cd /home/vgpnk/Projects/shokunin/kagi-shokunin
git status --porcelain -- corpus/knowledge/handler-trust-boundary.md corpus/stamps.tsv  # empty
sha256sum corpus/knowledge/handler-trust-boundary.md                                    # fa17fff3…
wc -l < corpus/knowledge/handler-trust-boundary.md; wc -c < …                           # 316 / 19410
git diff --numstat 2486643 f4a8dd9 -- corpus/knowledge/handler-trust-boundary.md        # 32	1
cmp -n 17669 <(git show 2486643:corpus/knowledge/handler-trust-boundary.md) \
             <(git show f4a8dd9:corpus/knowledge/handler-trust-boundary.md)             # exit 0
git show --name-only --format= f4a8dd9 | grep -c '^corpus/stamps.tsv$'                  # 0
```

Out of scope: reading any absent source's bytes, scratch `serve` replicas, vault
or account operations, `drift-pins.sh`, and full-table re-stamping.

Parent-run, post-integration: `bash corpus/claim-ledger.sh verify` must show no
`STALE` for this path; five stale rows are expected to remain at HEAD
(`config-layering`, `handler-on-disk-state`, `janitor-env-contract`,
`lessons/round-18`, `LOG.md`).

## 8. Provenance requirement

The repairing commit/report must carry, verbatim: the old row, the new row,
`2486643` → `f4a8dd9` as the delta chain, `32 1` numstat, `cmp` exit 0, the
observed date 2026-10-20, and the statements "entry bytes untouched" and
"no source bytes re-read; no posture claim." That makes the re-pin auditable
against the append it blesses.

## 9. Append-only preservation requirement

1. Lines 1-316 (19410 bytes) must remain byte-identical; after any further
   action, `cmp -n 19410 <HEAD>:… <new>:…` must exit 0.
2. Never rewrite lines 3-11 or 17; the erratum at 288-317 is the correction and
   must not be renumbered or reworded.
3. Any future text goes at EOF under a new dated heading only.
4. The stamp row stays present and keyed to this path; deletion or path rename
   breaks `docs`/`cells` resolution and counts as a dropped pin.
5. Historic statements stay historic: a re-pin records the artifact revision, it
   does not re-verify the janitor, opencode, or any security claim.

## 10. Bounded C2 cross-check (context, not this seat's ownership)

- Against **committed HEAD** the stale set is **six**: the four round-16 entries,
  `lessons/round-18.md`, and `LOG.md`. `LOG.md`'s sixth is explained by the base
  commit `c2cab35` (+7 lines; 1043→1050, 74864→75404). The documented "five"
  predates that landing — this is the "distinguish later changes" case, not a
  new unexplained drift.
- The working tree additionally has four uncommitted edits (`QUALITY.md`,
  `SOURCES.md`, `onepassword-machine-credentials.md`,
  `vault-openbao-token-lease-lifecycle.md`); these are in-flight round-22 work
  and must not be counted or restamped. Any detector must compare `git show
  HEAD:<path>`, not the dirty tree.
- The nine dropped stamp values are the `-9` lines of `e1544c1` (same nine paths
  re-added `+9`); this path is not among them.

## 11. Limits of this report

Read-only, single artifact plus its row; no host gate, no source byte, no
freshness-score change, no depth or legacy-header claim, no adjudication of E1 or
E3. The other five stale rows and the nine-value migration journal are outside
this seat and are reported only as cross-check context.
