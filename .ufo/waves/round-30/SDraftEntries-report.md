# SDraftEntries — C3 entry drafts, round-30 BUILD (lane kagi-shokunin)

Seat: SDraftEntries (drafter). Scope: C3 knowledge-entry drafts only. The lane
production corpus was READ-ONLY for this seat; the L1 (KagiR30) integrated
C3 in commit `064d4b6` before this seat finished, so the drafts below are
reported as **counterexamples against the landed entries**, not as pending work.

## 1. Draft paths (this seat's artifacts)

| draft | path |
|---|---|
| secret-scanning-detection-vs-validation.md | `.ufo/waves/round-30/final/c3/entries/secret-scanning-detection-vs-validation.md` |
| betterleaks-detection-vs-validation.md | `.ufo/waves/round-30/final/c3/entries/betterleaks-detection-vs-validation.md` |
| trufflehog-verification-lifecycle.md | `.ufo/waves/round-30/final/c3/entries/trufflehog-verification-lifecycle.md` |

Receipts written alongside them:

- `.ufo/waves/round-30/final/c3/entries/SDraftEntries-fetch-receipts.txt` — this
  seat's own fetch captures (8 rows: URL, HTTP, bytes, sha256, revision, quote
  needle, needle count) plus the assertions it checked.
- `.ufo/waves/round-30/final/c3/entries/SDraftEntries-lane-gate.txt` — the
  lane gate run over a scratch mirror carrying these three drafts.
- `.ufo/waves/round-30/final/c3/entries/SDraftEntries-fleet-gate.txt` — the
  fleet `sources-census.sh validate --file` run over the same mirror, plus the
  two frozen C3 counters.

Scratch tree `/fast/scratch/hyaku/kagi-r30/SDraftEntries/` was deleted after
the receipts above were copied into the wave dir (lane tree never touched).

## 2. Gate results on these drafts (scratch mirror, lane tree untouched)

Mirror = `git archive HEAD | tar -x` of the lane + LF-restored
`corpus/SOURCES.md` + the 8 re-pointed rows S053–S060 + the 8 capture rows +
these three drafts as `corpus/knowledge/*.md`.

```
$ bash corpus/sources-census.sh verify --root $M
SOURCES_CENSUS: CLEAN (rows=60 A=57 B=1 C=2 queued=1 mined=56 rejected=3 entries_sourced=8 legacy=21 captures=60 inrow=16 inrow_only=0 inrow_nonreproducing=12)
exit=0

$ /home/vgpnk/Projects/shokunin/scripts/sources-census.sh validate --file $M/corpus/SOURCES.md --root /home/vgpnk/Projects/shokunin
file  ok  $M/corpus/SOURCES.md          # W04 ×14 only, exit 0

$ grep -cE '^ {0,3}\|[[:space:]]*S(05[3-9]|060)[[:space:]]*\|' corpus/SOURCES.md
8
```

`claim-ledger.sh citations` over the same mirror: `CITATION_GATE: BROKEN
(cites=1852 docs=78 unresolved=19 …)` — **unresolved=19, identical to the
BASE receipt recorded in `plans/round-30.md`**; the three drafts added zero
unresolved citations and zero ephemeral tokens.

Shape note (this is the only structural difference from the landed entries):
these drafts use **one `source:` line per cited row**, the first at column 1 and
the rest as two-space-indented continuations. The lane's own
`corpus/sources-census.sh` `src_field()` helper reads "the first `source:` line
plus any directly following lines that start with whitespace (wrapped
continuation)", and it enforces **at most one column-1 `source:` line**
(`SC_ENTRY_HEADER: multiple source: lines`). The staged campaign package used
several column-1 `source:` lines and the sibling seat XAssimCol measured that
shape failing the lane gate with exactly three `SC_ENTRY_HEADER` findings
(`census-lane-gate-mirror-as-copied.txt`). Both shapes gate-CLEAN: the landed
entries put every row on **one** column-1 `source:` line joined by `;`. Mine
keeps one row per line as the seat spec asked, and it still passes.

## 3. Per-entry scope note — why each belongs in the PROVINCE frontier→core move

PROVINCE.md §"Core / Frontier / Adjacent (round 21)" lists **"Secret scanning:
detection versus verification"** under Frontier (explored, not held), with
`corpus/SOURCES.md` §Leads (unopened) naming "Gitleaks and Betterleaks project
direction and secret-scanning behavior" and "TruffleHog discovery-versus-
verification behavior" as leads only, not evidence. `corpus/README.md` §Frontier
carries the same area as explored-not-held. The registry lead is **S048**
("Secret scanning, GitHub concepts" — GitHub's own detection-vs-opt-in-validity
distinction), which the round-28 lead disposition opened as the *GitHub* side
only, leaving the scanner-tool side still a lead.

Each entry below therefore moves one named **frontier lead → admitted core**
within the lane's own domain (secrets & vault ops — credential-hygiene
evidence), and none of them restates another lane's ground:

- **secret-scanning-detection-vs-validation.md** — the class distinction
  itself: a detection is a pattern match, a validation is a live check. It
  closes the frontier item "does the scanner's finding establish that the
  credential works" for Gitleaks (S053) and TruffleHog (S054), which the lane
  previously held only as a lead. It explicitly does **not** extend to GitHub's
  own product (S048, already a registry row) and does not compare the two tools'
  rule quality.
- **betterleaks-detection-vs-validation.md** — the second scanner-tool lead
  (S055 README + S056 repository record), and the only one that corrects a
  *false* premise: the record is `fork: false`, i.e. an independent project
  whose rules cannot be read through Gitleaks's documentation, and whose
  findings are **stage-tagged** (default-off detection; validation/analysis as
  explicit opt-in stages). Lane fit: credential-hygiene evidence about a tool
  the lane's own janitor flow would use, not another lane's mechanism.
- **trufflehog-verification-lifecycle.md** — the product-documentation half of
  the same theme (S057–S060): what a *verdict* means once it leaves the
  scanner — a cached result with a three-hour bound, a read-only verification
  step, a rotation-detection path narrower than detection, and notification as
  a separate decision. This is the "what does a secret-scanning result
  entitle an operator to conclude" layer, which the lane's Frontier lead names
  but the registry did not yet hold.

None of the three carries a feed-token, token-totality, or release-clock
tokenizer claim, so the 2026-10-21 refusal boundary is respected.

## 4. Findings — defects in the landed entries (commit `064d4b6`), measured 2026-11-03

These are the counterexamples this seat's drafts carry and the landed entries
do not. Each is verified against a fetch performed in-round with the lane's
declared profile (`curl -fsSL --compressed`); receipts in
`SDraftEntries-fetch-receipts.txt`, and the per-source re-open receipts live in
`.ufo/waves/round-30/final/c3/src-open/`.

### F1 (material) — landed `secret-scanning-detection-vs-validation.md` mis-states what the TruffleHog README defines

Landed, §"What this entry does not establish" (lines 71–74):

> It does not claim that TruffleHog's `unverified` and `unknown` are distinct
> *policy* categories in the tool's own documentation; the README exposes the
> flags but **does not define the distinction**, so the table above is this
> lane's reading of the flag vocabulary, not a quotation of the vendor's
> definitions.

**Refuted by the source the entry itself cites.** The README has a section
`## What is credential verification?` (line 422) which defines all three
statuses in prose:

- `verified` — "Credential confirmed as valid and active by API testing"
- `unverified` — "Credential detected but not confirmed valid (may be invalid, expired, or verification disabled)"
- `unknown` — "Verification attempted but failed due to errors, such as a network or API failure"

That section is present **at the campaign's own pinned commit**
`d6ea4a52e3f4705989210e60e9f0da0deafe84bf` as well (I fetched that pin: 38515
bytes, sha256 `068fbb5c93eb993d…`, which reproduces the staged digest exactly),
so this is not drift introduced after the campaign — the staged entry's bound
was already wrong when written. Two consequences:

1. The landed table's meaning column (`the tool logged in and the credential
   worked` / `the credential did not validate` / `validation could not be
   attempted or failed`) is presented as the lane's reading, when the vendor's
   own wording is available and differs in one material respect: the README
   says `unknown` is verification **attempted** and failed, not that validation
   "could not be attempted"; and it says `unverified` may mean verification was
   **disabled** — a distinct case the landed table does not name.
2. The `--results` flag's **fourth** output value `filtered_unverified`
   ("unverified but would have been filtered out") and the documented default
   `verified,unverified,unknown` are absent from the landed entry.

My draft replaces the table with the vendor's own definitions, anchors them to
§"What is credential verification?", and withdraws the false bound in an
"Adoption notes (round 30)" section so the correction is auditable.

### F2 (material) — landed `betterleaks-detection-vs-validation.md` carries a stale number as a present-tense fact

Landed, line 15: "the GitHub repository search returns `betterleaks/betterleaks`
with `"fork": false`, **2322 stars and a push on 2026-10-22** [S056]".

`2322` / `2026-10-22` were the **campaign's 2026-10-23** point observations.
Re-opened in-round on 2026-11-03: `stargazers_count` **2774**,
`pushed_at` **2026-11-03T00:45:58Z**, `fork` still `false` (three
byte-identical fetches within the day). The numbers were stale on arrival and
are stale now; only `fork: false` is durable. The landed entry states them in
the present tense with no date marker, which reads as current fact.

My draft keeps the durable claim (`fork: false` ⇒ independent project, rules
cannot be read through Gitleaks's documentation), and marks the two counts
explicitly as *the campaign's 2026-10-23 capture* beside *this lane's
2026-11-03 re-open*, so neither is taught as a property.

### F3 (material) — landed `betterleaks` carries a bound the source contradicts

Landed, line 72–73: "It does not extend to Betterleaks' optional revocation
stage, which the features table lists but **the README does not describe in
operational detail**."

The re-opened README (lines 153–156) describes it operationally:

> Rules may also define an optional `revoke` Expr for explicit credential
> revocation.
> Use `betterleaks config show ids --revocation` to find configured support …
> `betterleaks revoke --rule <id>` to execute it. **Scans never run revocation.**

So the bound is false as written. The honest bound is different and is what my
draft carries: revocation exists, is operator-initiated, and is **outside any
scan** — a rule hit never means a credential was revoked.

### F4 (material) — the staged CEL clause was correctly dropped, but the landed entry over-claims the opposite

The staged betterleaks entry claimed: "one of those articles describes the rule
language as CEL while the README itself says Expr [S068]". The landed entry
correctly omits the CEL claim (the sibling seat XSrcOpen's receipt for S068
records that `CEL` occurs exactly once in the README, inside a linked Substack
post *title* — "Express YourCELf" — so S068 never carried it). The landed text
now says only "The README links three Substack posts and one vendor article.
Where a community write-up and the project's README disagree, the README wins
[S055]." That is defensible.

My draft goes one step further and records the *evidence* for the correction —
that `CEL` occurs exactly once and only in a post title, so the README's rule
language is unambiguously Expr — so a later reader does not re-open the same
dead question. This is a documentation-strength difference, not a defect in the
landed entry.

### F5 (material, lane-level) — the landed entries cite a **campaign-package row id** for the "unwritten" row and the row itself is still stale

The landed secret-scanning entry (line 69) says the GitHub side is "an
opened-but-unwritten row (S048)". In the lane, S048 is the GitHub concepts row
and its `used-by` is `corpus/lessons/round-28.md` — the landed entry does not
name S048 in its `source:` line, so the ledger/census citation chain does not
treat it as a source of this entry. That is a defensible editorial choice.

Separately, the **registry row** S056 still carries the campaign's stale
numbers in its `anchor` cell (`stargazers_count` 2322,
`pushed_at` 2026-10-22T21:28:27Z, response sha256 `0c8bdbd04508489c…`), while
the row's `recheck` is 90d. The sibling seat XAssimCol flagged the same thing
in `drift-findings.md` §3 ("Either drop the counts from the anchor or date
them"). The anchor cell is a registry artifact, not this seat's file, but it is
the same stale-number class F2 reports and it is the more consequential copy
because the registry is what a future reader cites.

### F6 (minor, structural) — the landed entries keep the campaign package's `round-1`/`round-2` numbering, which does not resolve inside the lane

The landed betterleaks entry refers to "the round-1 ledger", "the round-1
corpus", "the round-1 entry", "the round-1 Gitleaks fork-network page", and
"(see the round-2 rejection ledger)"; the landed trufflehog entry refers to
"the round-1 entry" and "the round-1 rule"; all three carry a `ground:` line
naming "Round-1 CANNOT-ANSWER item 1/2". Those are the **staged campaign
package's** round numbers. Inside this lane, `corpus/lessons/round-1.md` is the
aggregator's deferral/seed round and there is no `corpus/lessons/round-2.md` at
all — so the landed cross-references point at lesson files that either do not
exist or are about something else.

My drafts replace every one of them with the lane-resolvable pointer — the
sibling entry path `corpus/knowledge/secret-scanning-detection-vs-validation.md`
— and say in the body that the numbered rounds are the staged package's, not
the lane's.

### F7 (minor) — the landed entries carry no falsifier

Seven of the lane's existing sourced entries have a `## Falsifier` section
(`claim-ledger.md`, `feature-bound-credential-review.md`,
`feed-token-boundaries.md`, `onepassword-machine-credentials.md`,
`sops-age-key-rotation.md`, `substrate-deferral.md`,
`vault-openbao-token-lease-lifecycle.md`), and QUALITY.md **QA4** requires
"each entry names a falsifier (the observation that would make it wrong) and a
`recheck:` trigger". The landed three carry `recheck:` but **no falsifier**.
My drafts each close with a `## Falsifier` section naming the specific
observation that would falsify the entry.

### F8 (minor) — the landed `recheck:` cells carry the campaign's run date

All three landed `recheck:` cells end "-> 1 (**ran 2026-10-23**)", while their
own `verified-at:` says 2026-11-03 and adds "campaign dates 2026-10-23 are not
evidence here". The recheck command was therefore last run at the campaign's
date, yet the entry asserts it as its own recheck evidence — the two lines
contradict each other. This is also a live trap: the trufflehog page's
"Updated 06 Jul 2026" stamp renders as `Updated<!-- --> <!-- -->06 Jul 2026`, so
a needle aimed at the stamp text fails against the raw bytes (recorded in the
sibling's S070/S072/S073 receipts).

My drafts date every recheck command "(ran 2026-11-03)" with the count this
seat actually measured, and use the lane's declared profile
(`curl -fsSL --compressed`).

### F9 (note, no defect) — Gitleaks' maintenance status is still unrecorded in the registry row

The re-opened Gitleaks README opens with a maintainer banner: "Gitleaks is
feature complete. I'm not merging new features into Gitleaks. Future releases
will be security patches only. I'm shifting my focus to Betterleaks." The
landed S053 row's `scope`/`teaches` do not carry this, and neither do the
landed entries; the sibling seat flagged the same omission
(`drift-findings.md` §2). The landed entries' *claims* are unaffected (the
detect-only semantics are unchanged, and the README bytes are identical at the
staged pin `b58d3f1` and at today's HEAD `5f6ec56c` — so the pinned digest
still reproduces exactly).

My draft records the status as a dated note (observed 2026-11-03, same bytes as
the campaign capture) so the entry does not describe a closed-to-features
project as a live reference without saying so.

## 5. Content this seat refused to carry, and why

1. **The staged "does not define the distinction" bound** (F1) — refuted by the
   cited source at the cited pin. Carrying it would have taught a lane
   reader that the vendor is silent where the vendor is explicit.
2. **The staged CEL clause** — `CEL` occurs exactly once in the S055 README,
   inside a linked post title; the clause is not carried by that source and the
   linked article was not opened this round. Dropped, with the reason recorded
   in the draft's Adoption notes (not silently).
3. **The staged claim that the README does not describe revocation
   operationally** (F3) — contradicted by README lines 153–156. Withdrawn, and
   replaced with the accurate bound (revocation exists; scans never run it).
4. **The staged `2322` / `2026-10-22` API numbers as present-tense facts**
   (F2) — volatile endpoint, already stale on arrival. Kept only as dated
   campaign-era observations beside this round's re-open.
5. **The staged "round-1"/"round-2" ledger pointers** (F6) — they resolve to
   lesson files in this lane that either do not exist or are about a different
   subject. Re-pointed to the sibling lane entry.
6. **Any secret material** — the S060 page's example config carries a
   placeholder scanner-token field; it is vendor filler and is not copied into
   any artifact (QA5). Only the field *name* `sendUnverified` is cited.
7. **No `op://` path, no vault/account/handler/CDP interaction, no
   `op` sign-in or provisioning.** `op` was never invoked at all this round
   (not even `--version`); nothing in the three drafts touches a vault.

## 6. Tooling

No installs were needed or made this round: the work used only `curl`,
`python3` (3.14.8, stdlib), `bash`, `awk`/`sed`/`grep`, `git archive`, and
`git ls-remote` — all already present on the host. The generic "install useful
tools" directive was therefore not triggered. No pacman transaction was
attempted (host-wide pacman transactions are paused; this seat ran none).

## 7. Scope boundary

The lane production corpus was read-only for this seat: this seat wrote only
its own files under `.ufo/waves/round-30/` (this report, the three drafts, the
three receipt files) and its own scratch tree under
`/fast/scratch/hyaku/kagi-r30/SDraftEntries/`, which was deleted after the
receipts were copied into the wave dir. No git/jj mutation was performed in
the lane; the only git commands run were read-only (`git archive HEAD`,
`git ls-remote`, `git status`).
