# R72Scribe — round-72 prose drafts for L1 integration

Seat: scribe (drafting only; the L1 decides). No lane file was edited by this seat; every draft below
is a proposal with its own verification. Base `b2f3dd661abda0ebd09b3f8ffc3f64904606d4d9`, candidate
`a947a42c52dc5b64cc9be1eef98207712fca7c42`. **The L1 landed an integration commit
(`61792976d8ffa11f37894c01d2ba7ec6e6b2a1ab`) while this seat was running**, so sections A and C
below compare the landed text with this seat's independently drafted text and mark the residual
defects that landed text still carries.

Verification receipts: `.ufo/waves/round-72/w1/R72Scribe/receipts.txt` (this seat's own commands and
outputs). Every command in this file was run from `/home/vgpnk/Projects/shokunin/kagi-shokunin` or from
the extracted tree in scratch `/fast/scratch/hyaku/kagi-r72/R72Scribe` (removed at yield).

---

## A. Sentences that become false after the candidate — replacement text

The candidate moves the default receipt from the round-54 receipt to the round-72 receipt
(`.ufo/waves/round-72/final/observe-r72.json`, 32 observations dated 2026-11-09), re-anchors ten
derived Vault/OpenBao clocks, and moves `fired` 14 → 4. Every sentence that names the old default,
the old fired count, or the old anchor set is false after it. The lane's own record-supersession
doctrine (`corpus/README.md:150`, "a correction **supersedes** and never **rewrites**") is why the
replacements below keep the old text as history inside the new sentence instead of deleting it.

### A.1 `corpus/release-clock.py` — `--receipt` help text (the `--help` line a reader sees)

**False at BASE (line 2157):**
`retained observation receipt (default is the round-54 observe-r54 receipt; the round-53, round-46,
round-36 and round-26 receipts stay citable with --receipt/--receipt-sha)`

**Replacement (this seat's draft):**
```
retained observation receipt (default is the round-72 observe-r72 receipt; the round-54, round-53,
round-46, round-36 and round-26 receipts stay citable with --receipt/--receipt-sha against their
own revision's table)
```

Why the tail clause: this seat replayed **each** retained receipt against **its own** revision's table
and every one is CLEAN — round-54 `observe-r54.json` → CLEAN (fired=14) at `16623924`; round-53
`observe-r53.json` → CLEAN (fired=13) at `36d0a86`; round-46 `observe-r46.json` → CLEAN (fired=13) at
`0bd8888`; round-36 `observe-live.json` → CLEAN (fired=15) at `4a32d2c`; round-26 `observe-2.json` →
CLEAN (fired=3) at `d30c989`. A reader who replays a retained receipt against the *current* table
instead gets `RELEASE-MISMATCH` on all 32 rows (this seat measured exactly that), so the clause names
the table the receipt belongs to.

**Landed at `6179297`:** identical in substance — the landed help text reads "default is the round-72
observe-r72 receipt; the round-54, round-53, round-46, round-36 and round-26 receipts stay citable
with --receipt/--receipt-sha against their own revision's table". **No action needed.**

### A.2 `SKILL.md:48` — decision-table row "Judge whether a source's `on-release` recheck fired"

**False at BASE (cell 2):** the row said the gate "replays the **pinned round-54 receipt**
`.ufo/waves/round-54/final/observe-r54.json` (32 clocks observed live 2026-11-07 …)", listed the
retained receipts as "the round-53, round-46, round-36 and round-26 receipts", and said
"`corpus/release-clocks.tsv` retains fired old anchors" without qualification.

**Replacement (this seat's draft):**
```
`python3 corpus/release-clock.py` replays the **pinned round-72 receipt**
`.ufo/waves/round-72/final/observe-r72.json` (32 clocks observed live 2026-11-09; round 72
re-armed the ten derived Vault/OpenBao clocks S013–S016, S021–S026 at 2.2.1 / 2.7.2 through the
feed rows S174/S175 re-opened that day, after the round-47 teaching re-verification
(`corpus/fired-reverify.tsv`) and a round-72 page re-fetch (`corpus/clock-rearm.tsv`), so `fired=4`:
S012, S027, S028, S072). History: the round-54 receipt `observe-r54.json` (32 clocks observed live
2026-11-07, including the S072 op CLI clock round 54 bound to the S112 1Password Releases feed under
the declared title prefix `1Password CLI` (`FEED_TITLE_PREFIXES`; an undeclared feed keeps the
one-word title rule) and the clock bindings round 53 added for the round-48 S103/S104 SOPS and age
release pins) and the round-53, round-46, round-36 and round-26 receipts are retained, citable with
`--receipt/--receipt-sha` against their own revision's table; none is live vendor truth;
`corpus/release-clocks.tsv` retains fired old anchors except where a logged re-arm moved them (round
72, journal `.ufo/waves/round-72/expectation-migrations.json`); the S040/S041 successor clocks were
retired in round 46 (their registry rows left `on-release` in round 39 and are superseded by
S095/S096), and the REJECTED S098 is bound to its `Revision 25` quote. `--observe OUT.json` fetches
clocks to a NEW receipt and compares against the selected profile, so later drift can return
`RECEIPT-MISMATCH` / exit 1 without capture failure — that mismatch, not a verdict change, is how a
newer release first shows (a re-armed row reads `fired` only once the table records the observation).
Since round 28 a non-canonical version token (leading zero, component over 18 digits) is
`NON-CANONICAL` and a `derived:` anchor not equal to the one version its feed row's anchor cell names
is `DERIVATION` (both exit 1); `--selftest` 121 cases
```

**Every history clause of the BASE cell is kept**: the S072 op CLI clock and its `FEED_TITLE_PREFIXES`
prefix rule, the round-53 S103/S104 SOPS/age bindings, the four retained receipts, the round-46
retirement of the S040/S041 successor clocks, the S098 `Revision 25` binding, the `--observe`
mismatch semantics, the round-28 `NON-CANONICAL`/`DERIVATION` rules and the 121-case selftest count.

**Landed at `6179297`:** the landed cell carries all of the above except that it does **not** carry
the "a re-armed row reads `fired` only once the table records the observation" clause — the landed text
reads "so later drift can return `RECEIPT-MISMATCH` / exit 1 without capture failure — that mismatch,
not a verdict change, is how a newer release first shows (a re-armed row reads `fired` only once the
table records the observation)". **It does carry it.** No action needed.

**Cell 3 (the failure-mode list).** BASE cell 3 listed what the gate must refuse. The candidate adds
one refusal that only exists from this round on — appending a same-URL feed row without searching the
registry for that URL first (M72-1). Draft addition to cell 3:
```
… ; trusting a `derived:` anchor its feed row does not name; appending a feed row without searching
the registry for its URL (round 72: S174/S175 re-opened identities S089/S090 already held)
```
**Landed at `6179297`:** present verbatim. No action needed.

### A.3 `SKILL.md:796` — coverage-map row "source release clocks"

**False at BASE:** "default is the byte-pinned **round-54 receipt** `observe-r54.json` (round-53,
round-46, round-36 and round-26 retained as history)" and "ledger R36-03 pins the default verdict line
(migrated round 46)".

**Replacement (this seat's draft):**
```
| source release clocks | `python3 corpus/release-clock.py` / `--selftest`; default is the byte-pinned
**round-72 receipt** `observe-r72.json` (2026-11-09; round-54, round-53, round-46, round-36 and
round-26 retained as history), not live release state; ledger R36-03 pins the default verdict line
(migrated round 46; round 72 `fired=14` → `fired=4` after the logged re-arm of ten derived clocks,
journal `.ufo/waves/round-72/expectation-migrations.json`). `--receipt FILE --receipt-sha SHA256`
selects a receipt against the selected root's table; `--observe NEW.json` never overwrites a receipt
or rewrites TSV. Later drift may return exit1. Default/table/R25-04 migration and the separate
original historical replay are named in the round26 lesson | R25-03/R25-04; S033–S041; S174/S175;
`corpus/lessons/round-26.md`; `corpus/lessons/round-72.md` |
```

**Landed at `6179297`:** the landed row matches this draft, including the `S174/S175` and
`corpus/lessons/round-72.md` additions to the evidence column. No action needed.

### A.4 `PROVINCE.md:75` — the `corpus/release-clock.py` + `corpus/release-clocks.tsv` gate line

**False at BASE:** "default is the pinned round-54 receipt `observe-r54.json` (round-53, round-46,
round-36 and round-26 retained as history; …)".

**Replacement (this seat's draft):** the same clause change as A.2/A.3, plus the round-72 re-arm named
as a gate fact:
```
- `corpus/release-clock.py` + `corpus/release-clocks.tsv` — every `on-release` row bound to a feed or
rendered-quote clock; default is the pinned round-72 receipt `observe-r72.json` (2026-11-09; round-54,
round-53, round-46, round-36 and round-26 retained as history; round 53 binds the S103/S104 SOPS and
age current-release pins to the S033/S111 feeds; round 54 binds the S072 op CLI identity to the S112
1Password Releases feed under a declared title prefix; round 72 re-arms the ten derived Vault/OpenBao
clocks at 2.2.1/2.7.2 on the re-opened feed rows S174/S175, with `corpus/clock-rearm.tsv` recording
the page re-fetch behind each re-arm), NOT live vendor truth. `--observe` writes a NEW receipt without
rewriting the table and can fail on later receipt/profile drift. …
```
The rest of the BASE line (S040/S041 retired, old3.15.0 anchors stay fired, the round-27 `REGRESSED`
rule, the round-28 `NON-CANONICAL`/`DERIVATION` rule, the round-29 `STABLE_TOKEN_RE` boundary, the
non-POSIX `0o600` SKIP limit, the explicit default/table/R25-04 migration and the historical frozen
snapshot, exit 0/1/2) is carried unchanged.

**Landed at `6179297`:** matches this draft. No action needed.

### A.5 `corpus/README.md:147` — the Frontier bullet "Observable release clocks"

BASE text is a dated round-25 statement ("entered in round25 (S033–S037; S038 empty-feed reject);
on-demand observation of declared identities, not continuous vendor-truth monitoring"). It does not
become *false* after the candidate — it becomes **incomplete**: the frontier gains a re-arm step.
Because the lane's Frontier bullets carry their own round-clauses, the right shape is an appended
sentence, not a rewrite of the round-25 clause.

**Appended clause (this seat's draft):**
```
Round 72 adds the re-arm step of the clock lifecycle: ten derived Vault/OpenBao clocks fired since
round 36 and re-verified in round 47 are re-anchored at the observed release through re-opened feed
rows (S174/S175, superseding S089/S090), each re-arm bound to a re-fetched page with its quote
located (`corpus/clock-rearm.tsv`); `fired` 14 → 4.
```
Verification of every clause in it: the ten rows first read `fired` at round 36 (`00bbe66` shows S013
anchor 2.2.0 / observed 2.2.1 / verdict fired; BASE `b2f3dd66` still reads fired); round 47's semantic
re-verification is `corpus/fired-reverify.tsv` (11 rows, 10 of them the F ids, verdict
`teaching-holds`); the re-open relation is S174→S089 / S175→S090 as landed in `corpus/SOURCES.md`;
the re-check ledger is `corpus/clock-rearm.tsv` (ten rows, each with capture path, sha256, bytes and
quote_count); `fired` 14 → 4 is this seat's own measurement of the gate at BASE and at HEAD.

**Landed at `6179297`:** the landed clause is present and matches this draft. No action needed.

### A.6 `corpus/SOURCES.md` — the "## Paths" bullet "Observable release clocks"

BASE: `S033 → S034 → S035 → S036 → S037, with S038 rejected`. After the candidate the two middle
legs of that study path are superseded (S034 → S089 → S174, S035 → S090 → S175), so the path as
written names rows that no longer carry the clock bindings.

**Replacement (this seat's draft), keeping the round-25 clause as history:**
```
- **Observable release clocks** — S033 → S034 → S035 → S036 → S037, with S038 rejected: distinguish
server/product stable releases from module tags, prereleases and empty living-standard feeds. Round 72
re-anchors the Vault and OpenBao legs: S034 → S089 → S174 (Vault v2.2.1) and S035 → S090 → S175
(OpenBao v2.7.2), the older rows kept as the superseded-anchor record.
```
**Status at `6179297`: NOT landed.** The landed `corpus/SOURCES.md` "## Paths" bullet still reads
`S033 → S034 → S035 → S036 → S037, with S038 rejected` (this seat read the landed file at HEAD). The
registry's own `teaches` cells now say S174 supersedes S089 and S175 supersedes S090, so the path
bullet and the registry disagree about which rows hold the current Vault/OpenBao release anchors. This
is a one-line prose defect the L1 may close in the same wave; it is a documentation-consistency issue,
not a counter or gate issue (no gate reads the "## Paths" bullets — `grep -rn "supersedes" corpus/*.sh
corpus/*.py` returns 0 hits, and no instrument parses the Paths block).

### A.7 `corpus/release-clocks.tsv` — the ten re-armed rows' notes (RESIDUAL DEFECT, landed)

This is the one prose inconsistency the landed tree still carries, and it is the substantive finding
of this seat.

At the **candidate** `a947a42c`, the ten notes ended:
```
round 72: re-armed at 2.2.1 through S174 (supersedes S034, opened 2026-11-09) after the round-47
teaching re-verification (corpus/fired-reverify.tsv) and the round-72 re-check
(corpus/clock-rearm.tsv); the round-72 receipt observe-r72.json (2026-11-09) observes 2.2.1, equal
to the new anchor, so the clock is armed (not-fired)
```
At **integration** `6179297` the L1 changed the *registry* rows (`corpus/SOURCES.md`) from
`supersedes S034` / `supersedes S035` to `supersedes S089` / `supersedes S090` (M72-1: S089/S090
already held those identities since round 37, so naming S034 would make two rows claim the same
predecessor). The integration did **not** touch `corpus/release-clocks.tsv` (this seat checked
`git diff a947a42c 6179297 -- corpus/release-clocks.tsv` → empty), so the ten clock notes still say
**"through S174 (supersedes S034, opened 2026-11-09)"** and **"through S175 (supersedes S035, …)"**.

Landed tree, verified at HEAD — the two files now disagree about the immediate predecessor:
- `corpus/SOURCES.md` S174 `teaches`: `supersedes S089 — re-opened 2026-11-09: … the identity S089
  (round 37, itself superseding S034) already recorded but never bound to a clock; …`
- `corpus/release-clocks.tsv` S013/S022/S023/S024 notes: `through S174 (supersedes S034, opened
  2026-11-09)`
- `corpus/release-clocks.tsv` S014/S015/S016/S021/S025/S026 notes: `through S175 (supersedes S035,
  opened 2026-11-09)`

So the clock table still names S034/S035 as the row that S174/S175 superseded, while the registry
says S089/S090. Under QM103 (added this round) and the M72-1 correction the L1 itself applied, the
correct immediate predecessor is S089/S090. Note also that the round's own `dup-supersede.sh` check
cannot see this: it greps `^ {0,3}\| *S[0-9]{3} ` rows and splits on `|`, so it reads only the
registry and reports `DUP_SUPERSEDE: 1` (the carried S007 pair) — pointed at `corpus/release-clocks.tsv`
it prints `DUP_SUPERSEDE: 0` because the TSV has no `|`-delimited registry rows at all. The duplicate
claim is therefore invisible to the check that was written to catch it.

**Draft correction (this seat's proposal), for the ten rows only — the notes' history clauses stay:**
```
round 72: re-armed at 2.2.1 through S174 (S174 supersedes S089, which itself superseded S034;
opened 2026-11-09) after the round-47 teaching re-verification (corpus/fired-reverify.tsv) and the
round-72 re-check (corpus/clock-rearm.tsv); the round-72 receipt observe-r72.json (2026-11-09) observes
2.2.1, equal to the new anchor, so the clock is armed (not-fired)
```
and symmetrically for the six OpenBao rows (`through S175 (S175 supersedes S090, which itself
superseded S035; opened 2026-11-09)`). The prior anchors stay visible in `corpus/clock-rearm.tsv`'s
`prior_anchor` column (2.2.0 / 2.7.1), so nothing about the old anchors is lost.

---

## B. SCORECARD capability row for "release-clock re-arm of derived clocks" — **not a new capability**

Verdict: **do not enter a capability row.** Reasons, in the lane's own terms:

1. `AXES.md` §Capabilities: "Rows enter only through a round that demonstrates the capability
   running; a capability without a passing demonstration in the round report is pre-claiming and does
   not enter the table." This round demonstrates the *procedure*, but the capability table already
   carries **`release-clock observation`** (first-working round 25) — "observe every on-release
   registry clock against its declared official release feed or capture quote and retain a dated
   receipt" — and the re-arm duty itself is older than this round: QM24 (round 26) already required
   "a successor to an on-release teaching retains release-driven rechecking and is bound at its named
   current release", and round 26 already re-armed S027/S028 at named 3.15.1 anchors through S040/S041.
2. The round-72 move is the *same* instrument applied to a new population (derived clocks, whose
   anchor is bound to the feed row's anchor cell under QM28), not a new instrument. The lane's own
   round-26 record puts the same event on the **freshness** axis, not in the capability table
   (`SCORECARD.md` round-26 post-move: "freshness | 9 → 9 | C1: S039/S040/S041 … named3.15.1
   successors rearmed on-release"; "depth | 9 → 9 | R21-01 unchanged; no new mechanism or normalizer
   behavior claim"). Round 72 should read the same way.
3. What round 72 *does* add that a reader may not find elsewhere is the **procedure**: re-arm a
   derived clock by opening a successor feed row that names the currently observed release, keeping
   the old row's anchor cell untouched (the anchor-pin gate forbids editing S034/S035's anchor cells),
   with a per-clock re-check ledger (`corpus/clock-rearm.tsv`) binding each re-arm to a re-fetched page
   whose declared quote locates. That belongs in the round-72 SCORECARD freshness cell (the L1 already
   wrote it) and in the lesson — not in the repertoire table.

**Optional addendum if the L1 wants the procedure visible in the repertoire table** — then it must be an
*append* to the existing `release-clock observation` row's evidence, in the QM97 correction form the
round-71 closure routed, not a new row and not a rewrite of the round-25 row:
```
| release-clock observation | observe every on-release registry clock against its declared official
release feed or capture quote and retain a dated receipt; since round 72 a fired derived clock is
re-armed by opening a successor feed row that names the currently observed release — the old row's
anchor cell is never edited (anchor-pins gate), each re-arm is recorded per clock in
`corpus/clock-rearm.tsv` against a re-fetched page whose declared quote locates | `python3 corpus/
release-clock.py --observe <receipt>`; R25-03/R25-04; `.ufo/waves/round-25/observe-1.json`;
round-72 `plans/round-72-c1.sh` ⇒ value=10, `corpus/clock-rearm.tsv` | 25 (round-72 adds the
re-arm step) |
```
This seat's recommendation is to **not** enter it: the round-72 post-move freshness cell plus the
lesson already carry the procedure, and the table's rows are first-working-round keyed (the row would
have to say "25 (round-72 adds the re-arm step)", which is exactly the kind of amended row the round-71
closure had to route as an errata).

---

## C. Lesson §Gate block for S174 and S175 (draft; quotes located by this seat)

The landed lesson at `6179297` already carries a §Gate table for S174/S175. This section gives the
draft and two corrections this seat can source.

Draft row shape follows `corpus/lessons/round-71.md` §Gate and the lane's contract (CORPUS.md rule 1:
"the URL, the access date, and a ≤25-word quote with its location grounding `teaches`").

### C.1 quotes located by this seat

Both feed rows' declared quotes are the raw title tag. This seat located each **twice**, by both
normalizers the lane uses for feed rows (`source-fetches.tsv` col 14 declares `raw-literal-v1`):

| id | quote | raw-literal count | byte offset | rendered-text-v1 count |
|---|---|---|---|---|
| S174 | `<title>v2.2.1</title>` | 1 | 726 | 0 (markup is stripped) |
| S175 | `<title>v2.7.2</title>` | 1 | 729 | 0 (markup is stripped) |

The offsets are a useful independent check: the round-37 rows S089/S090 already record "first stable
entry at byte offset 726" / "729" for the same two feeds, so the round-72 captures put the same
first stable entry at the same offsets — the identities are the same entries, re-read.

**Correction C.1a — the access time.** The landed §Gate row says the feeds were "accessed
2026-11-09T04:00Z". The committed evidence for the two **feed** rows is the date only:
`corpus/source-fetches.tsv` records `fetched 2026-11-09` for S174/S175, and no committed artifact
carries a per-feed fetch *timestamp* — `.ufo/waves/round-72/controls/tools/page-times.tsv` holds the
ten **page** times (04:00:43Z–04:00:45Z), not the feeds'. The nearest committed time evidence for the
feeds is the round-72 receipt's own observations of those feed URLs: 2026-11-09T04:01:39Z (Vault) and
2026-11-09T04:01:40Z (OpenBao), whose recorded sha256 equals the committed capture bytes exactly
(this seat verified both). Draft the access clause as:
```
accessed 2026-11-09 (fetch row `corpus/source-fetches.tsv`); the round-72 receipt re-read the same
bytes at 2026-11-09T04:01:39Z / 04:01:40Z with identical sha256 (`.ufo/waves/round-72/final/
observe-r72.json`)
```
This keeps the date the corpus contract asks for and replaces the interpolated "T04:00Z" minute with a
committed timestamp.

**Correction C.1b — a quote that also locates under rendered-text-v1.** The landed §Gate quotes are
raw-literal only; a reader who re-runs the lane's default normalizer on a feed body gets count=0
(R72ReviewerSrc SR-2 recorded the same). Both captures contain a release-note sentence **inside the
first (v2.2.1 / v2.7.2) entry** that locates count=1 under rendered-text-v1 and is ≤25 words, so the
Gate row can quote the identity *and* carry a body sentence that the lane's own normalizer finds:

- S174 (17–18 words, inside the v2.2.1 entry):
  `core/policy: Fixed a cache-key collision vulnerability that could cause policy-name aliases to
  resolve to the immutable root policy.`
- S175 (15 words, inside the v2.7.2 entry):
  `auth/oidc: Fix login in direct callback mode by including the namespace in the redirect URI.`

Both were located by this seat with `python3 corpus/rendered-text-v1.py locate` → `count=1`, and both
are inside the **first** `<entry>` of their capture (this seat checked the entry boundaries: the
first entry spans bytes 503–4207 in S174.body and 505–30010 in S175.body, and each sentence lies
inside that span), so the sentence is content of the release the row names.

### C.2 drafted §Gate block

```
| id | decision | source | located quote (≤25 words) | reason |
|---|---|---|---|---|
| S174 | admit, tier A, `mined` | https://github.com/hashicorp/vault/releases.atom — 297455 B, sha256
`3ead3d0f…2e6ffc`, accessed 2026-11-09 (fetch row `corpus/source-fetches.tsv`; the round-72 receipt
re-read the same bytes at 2026-11-09T04:01:39Z with identical sha256,
`.ufo/waves/round-72/final/observe-r72.json`) | “<title>v2.2.1</title>” (raw-literal, count 1, byte
offset 726 — first stable entry, tag link /releases/tag/v2.2.1, entry updated 2026-10-23T17:34:44Z);
“core/policy: Fixed a cache-key collision vulnerability that could cause policy-name aliases to resolve
to the immutable root policy.” (18 words, rendered-text-v1 count 1, inside the first entry) | newest
stable Vault server tag; sdk/ and -rc entries excluded by the gate's parser. Same identity S089
recorded on 2026-11-05 (M72-1): admitted as the re-open that carries the derived-clock binding,
`supersedes S089` |
| S175 | admit, tier A, `mined` | https://github.com/openbao/openbao/releases.atom — 543805 B, sha256
`a54d1a53…f2e0e`, accessed 2026-11-09 (fetch row `corpus/source-fetches.tsv`; the round-72 receipt
re-read the same bytes at 2026-11-09T04:01:40Z with identical sha256,
`.ufo/waves/round-72/final/observe-r72.json`) | “<title>v2.7.2</title>” (raw-literal, count 1, byte
offset 729 — first stable entry, tag link /releases/tag/v2.7.2, entry updated 2026-10-26T20:24:37Z);
“auth/oidc: Fix login in direct callback mode by including the namespace in the redirect URI.” (15
words, rendered-text-v1 count 1, inside the first entry) | newest stable OpenBao server tag; api/ and
sdk/ module releases excluded. Same identity S090 recorded on 2026-11-05 (M72-1): admitted as the
re-open, `supersedes S090` |
| a third Vault/OpenBao identity row naming v2.2.1 / v2.7.2 as NEW release identities | reject (no
row) | the same two feeds | — | S089/S090 already hold both identities since round 37; a row
claiming a new identity would be false. Flip: a newer stable tag on either feed |
```

**Landed at `6179297`:** the table, the decisions, the rejections, the two identity quotes and the
reason clauses are all present; the two corrections above (the access-time clause and the
rendered-text-locatable body sentences) are **not** in the landed text. Both are optional prose
improvements; neither changes a counter number or a gate verdict.

---

## D. Drafts this seat did not need to write because the L1 landed them first

The L1's integration commit `6179297` landed, before this seat finished, every replacement in A.1–A.5
and the §Gate block in C.2, plus: `corpus/claim-ledger.tsv` R36-02 `^3$`→`^13$` and R36-03
`fired=14`→`fired=4`, `.ufo/waves/round-72/expectation-migrations.json`, `corpus/QUALITY.md` QM103,
`corpus/SOURCES.md` S174/S175 `supersedes S089`/`S090`, the round-72 SCORECARD pre/post-move rows,
the LOG entry, and 185 stamp rows. This seat's independent re-measurement at the landed HEAD:
`C1_CLOCK_REARM: value=10 rows_passing=10 gate=1 fresh=1 census=1 live=1` (rc 0),
`C2_SELF_COUNTS: value=0 pins=1 shape=1 claims=63 policy=2 ok=61 stale_ids=none` (rc 0),
gate `RELEASE_CLOCK: CLEAN (on_release=32 bound=32 unbound=0 observed=32 fired=4 derived=17)`
(BASE: `fired=14`), `SOURCES_CENSUS: CLEAN (rows=166 …)` (BASE: rows=164),
`ANCHOR_PINS: CLEAN (pins=4)`.

## E. Residual items for the L1 (both prose, neither counted by C1 or C2)

1. **`corpus/release-clocks.tsv` notes name S034/S035 as the superseded predecessor** while
   `corpus/SOURCES.md` names S089/S090 — see A.7. Draft correction supplied. No instrument reads the
   note column or the Paths bullets, so nothing else will flag it.
2. **`corpus/SOURCES.md` "## Paths" bullet still reads `S033 → S034 → S035 → S036 → S037`** — see A.6.
3. **Lesson §Gate access-time clause** interpolates "T04:00Z" for the two feeds — see C.1a.
