# SentHygiene — round-30 hygiene + boundary scan (sentinel, leaf)

Seat: SentHygiene (sentinel). Lane: `kagi-shokunin`. Frozen BASE `f67232cd3ae682ea1fb14d447667016f2b6ed336`
(plan commit `b7482b4acc42413fbb3d49ab6e4f811fb18e9f0c`).

Target scanned: **every byte this round intends to land** — `plans/round-30.md` (read-only) plus the
whole wave tree `.ufo/waves/round-30/` (`final/`, `build/`, `*-report.md`, `build-spec.json`,
`build-dispatch.json`, `census-start.txt`).

**Corpus: 157 files / 158 scanned paths** (final snapshot `2026-11-03T18:41:53Z`; the wave was still
landing files while I scanned — I re-listed and re-scanned to a fixed point and the numbers below are
from the last full pass over all 158 paths, including the late `final/host/`, `final/attack-eol/`,
`build/XEol.md`, `build/ScoutHost.md` drops).

Scan was static/pattern-based over the file bytes (no lane file was opened for writing, no lane git
or jj mutation, no scratch outside `/fast/scratch/hyaku/kagi-r30/SentHygiene/`). Counts are counts;
per the seat contract no match is printed beyond its shape class.

## Verdict summary

| class | verdict | count |
|---|---|---|
| 1 — secret material | **PASS** | 0 credential-shaped hits; 1 env-assignment false positive (a scratch path); 18 `op://` mentions, all the prohibition text; **0** `op://` ref paths |
| 2 — refusal boundary (2026-10-21) | **PASS** | 19 phrase hits, every one either the plan's own binding sentence or an explicit non-violation attestation; **0** draft asserts feed-token derivation / token totality / release-clock tokenizer work |
| 3 — scope | **PASS** | **0** edit proposals against round-29-verifier-spotcheck.md, MANIFEST.json, fleet `templates/`, fleet `scripts/`, sibling repos, or shokuknow; 0 lane/sibling/fleet file writes by any seat |
| 4 — pacman guard | **PASS** | **0** pacman instructions; the only 2 occurrences of a pacman command are the guard sentence itself |

**Plus one high-severity finding outside the four classes (H7) — found live in the lane and now
resolved:** the `.gitattributes` the L1 had written was missing the `.ufo/** -text -eol` exclusion,
so the **next `git add -A` would have rewritten five round-29 evidence receipts** — the plan's own
C2 kill-rule trigger. I reported it with a reproduction; the L1 applied the one-line fix before
staging, and I re-verified independently against the fixed file (4 changed paths, 0 receipts
rewritten, under both `git add -A` and `--renormalize`). Details in H7.

---

## Class 1 — secret material: **PASS (0 hits)**

Shape classes scanned over all 158 paths, with counts:

| shape class | hits |
|---|---|
| PEM/PuTTY private-key block (`-----BEGIN … PRIVATE KEY-----`) | 0 |
| `op://` ref path (`op://<item>/…`) | **0** |
| AWS access-key id (`AKIA…`) | 0 |
| GitHub PAT (`ghp_`/`gho_`/`ghu_`/`ghs_`/`ghr_`) | 0 |
| Slack token (`xox[abposr]-…`) | 0 |
| JWT (3 dot-separated base64url segments) | 0 |
| GCP API key (`AIza…`) | 0 |
| OpenAI-style (`sk-…`) | 0 |
| `Authorization: Bearer …` | 0 |
| `Set-Cookie:` / `Cookie:` header value | 0 |
| `key/secret/password/token/credential = <16+ char value>` | 0 |
| env assignment (`NAME=<16+ char value>`) | **1 (false positive)** |
| example credential copied from a fetched page (`aws_secret_access_key`, `client_secret=`, `private_key=`) | 0 |
| `op://` appearing in ANY form (incl. prose) | 18 — all are the literal prohibition text |

Notes on the two non-zero rows, so the verdict is not read as "a scan that found something":

- **The 1 env-assignment hit is not a secret.** `final/attack-eol/matrix.out:50` reads
  `TOPLEVEL=/fast/scratch/hyaku/kagi-r30/MAttackEol/mx/git4/kagi-shokunin` — a shell variable holding a
  scratch path. Shape class: path assignment.
- **The 18 `op://` occurrences are all the guard text, never a value.** Every one is inside a sentence
  of the form "no `op://` values / paths / refs" — in `build-spec.json` (3), `build-dispatch.json` (3),
  and the six seat reports that attest it (`XAssimCol`, `XEol`, `XSrcOpen`, `ConnOverlap`, `RAttackC3`,
  and their `-report.md` twins). **Zero** occurrences have an item path after `op://` (the
  `op://<item>/…` shape is 0). No secret was read, printed, or derived from `op`; the only `op`
  invocation anywhere in the corpus is `op --version` → `2.41.1`, recorded in
  `final/host/substrate-absence.txt`. Confirmed independently: no `op run|read|item|list|signin|
  account|vault|whoami` invocation exists in any wave byte.
- **The high-entropy strings are all accounted for.** 100 hex-runs of ≥40 chars were classified:
  27 are git commit ids (`git log --all` membership verified), and 73 are 64-hex digests of the
  *lane's own* artifacts — `row-identity.sh` membership digests (`94df9364…`, `92016a58…`,
  `917ef251…`, `b0d0f6f5…`), `source-fetches` capture digests, and content digests of the fetched
  upstream READMEs/docs. None is a credential; the identity digests are reproducible from the lane
  (`bash corpus/row-identity.sh stamps` prints `sha256=94df9364…`, matching the drafted new pin).
  The remaining long opaque strings are gate verdict tokens (`reason=host-row-not-authorized`,
  `last=FEED_TOKEN_AGREE_SELFTEST`, `sha256=…`) and paths.

**Verdict class 1: PASS.** No secret material, no `op://` ref path, no credential value, no
private-key block anywhere in the bytes this round intends to land. Counts only were taken; nothing
beyond shape class is reproduced here.

---

## Class 2 — refusal boundary (2026-10-21): **PASS (0 violations)**

Patterns applied to feed-token/release-clock claims, and their hit counts with file pointers:

| pattern | hits | where | verdict |
|---|---|---|---|
| "totality of tokens" / "token totality" | 11 | `plans/round-30.md:31`; `build-spec.json` ×3; `build-dispatch.json` ×3; `build/RAttackC3.md:195-196`; `RAttackC3-report.md` | **all are the prohibition itself or an attestation of non-violation** |
| "feed-token derivation" | 5 | same set | same |
| "release-clock tokenizer(s)" | 3 | `plans/round-30.md:32`; `build/RAttackC3.md:196`; `RAttackC3-report.md` | same |
| "all feed tokens" / "derive(d) feed token" | 0 | — | clean |

Every hit is one of two things: (a) the plan's own binding sentence — *"the 2026-10-21 refusal boundary
is binding: no claim touches feed-token derivation, token totality, or the release-clock tokenizers"* —
or (b) `RAttackC3.md:193-196`, which is an explicit **PASS attestation** ("No entry claims token
totality, scanner completeness, or feed-token surface… the 2026-10-21 boundary… is untouched"). No
draft *asserts* a feed-token derivation, token-totality, or release-clock-tokenizer claim.

What the round's bytes actually touch in that neighbourhood, and why it is not boundary work:

- The C1 migration re-hosts two **existing** ledger rows R29-01/R29-02 (`corpus/feed-token-agree.py`).
  The command token changes; the instrument, the corpus, the extractors and the grammar are untouched.
  No seat edited `corpus/feed-token-agree.py` or `corpus/release-clock.py` — I grepped every draft for
  edit/modify/rewrite/patch proposals against those two paths: **0 hits**.
- `final/c1/_feed-token-no-flags.txt` and `final/c1/_bytecode-attribution.txt` are observations about
  `__pycache__` side effects of the re-hosted command. They contain no token, no extractor output, no
  shape list beyond the gate's own count lines.
- `final/c1/XD2Cells-cell-diff.txt` mentions release-clock only inside an unchanged `## Round ` heading
  cell (context line, not a `+`/`-` edit).
- The three C3 entries (`final/c3/assimilation/entries-repointed/*.md`) are about **third-party**
  secret-scanning tool semantics (Gitleaks/TruffleHog/Betterleaks detection vs verification). They
  claim no scanner-completeness or coverage metric — each carries a "What this entry does not
  establish" section that explicitly declines precision/recall/coverage.

**Verdict class 2: PASS.** No round-30 byte touches feed-token derivation, token totality, or the
release-clock tokenizers. The nearest approach (re-hosting the two feed-token-agree ledger rows) is a
command-token migration of already-committed rows, which the plan itself enumerates in C1.

---

## Class 3 — scope: **PASS (0 out-of-lane edit proposals), with one boundary to note**

Forbidden-target edit proposals (verb within 60 chars before the target), scanned across all 158 paths:

| forbidden target | edit proposals | evidence |
|---|---|---|
| `corpus/lessons/round-29-verifier-spotcheck.md` (integrator-authored) | **0** | the only 6 occurrences are `MISSING-ID` audit lines in `final/c1/_draft-verify.txt:600-602` and `final/c1/_gate-subset-original-rows.txt:610-612` — gate *output*, not a proposal |
| `MANIFEST.json` (fleet root) | **0** | absent from every draft; present only inside the seat prompt itself |
| fleet `templates/` | **0** | absent from every draft |
| fleet `scripts/` | **0** | `final/probe-gitattr.md:99-101` and `build/LProbeGitattr.md:44` **read** `scripts/sources-census.sh:581` to locate the `trim()` root cause; neither proposes editing it. No seat edited the fleet script (mtime `2026-10-19`, unchanged) |
| sibling repos (`/home/vgpnk/Projects/shokunin/*-shokunin`) | **0** | `build/ConnOverlap.md` is a read-only sweep of the 20 siblings; I verified no sibling repo has any non-`.ufo` file modified in the last 90 minutes (**0 files in all 21 lanes**) |
| `/home/vgpnk/Projects/shokuknow` (read-only source) | **0** | `final/c3/assimilation/id-lists.txt:4` cites the staged path as a *source*; the staged tree's mtimes are still `2026-10-24 23:33` — untouched |

Also confirmed in scope:

- **No seat committed or pushed anything.** `git commit` / `git push` appear in **0** wave bytes; the
  lane's `git status --porcelain` shows only untracked `.ufo/waves/round-30/**` artifacts — no tracked
  lane file is modified (`git status` in the lane lists `??` entries only).
- **No lane production file was edited.** `corpus/SOURCES.md`, `corpus/claim-ledger.tsv`, `SKILL.md`,
  `PROVINCE.md` all still carry the `14:51` mtime of the plan commit. Every draft is either a
  proposed diff (as text) or a scratch-mirror measurement.
- **Fleet root**: only `.scratch/run15-state.json` and `.ufo/l0-questions.md` are dirty — the latter
  is a *tsukuroi round-64* line appended by the fleet orchestrator, not by any kagi seat (its content
  concerns tsukuroi's S200-S346 id collision; kagi's wave files do not mention it).
- **New lane files proposed** are exactly the plan's own targets: `corpus/knowledge/<3 entries>.md`,
  the 8 `SOURCES.md` rows, `corpus/lessons/round-30.md`, `.gitattributes`, `corpus/eol-gate.sh`, plus
  the ledger pin migrations.

**Boundary to note (not a violation).** The fleet census parser defect is **outside** the lane and
cannot be fixed from here: `scripts/sources-census.sh:581`'s `trim()` strips `[ \t]` but not `\r`, so
`## Registry\r` never matches and every registry row is E12. Two seats located this (`LProbeGitattr`,
`XEol`) and both correctly declined to touch the fleet script — the lane repairs its own bytes
instead. **This defect is unowned after the round**: it will re-fire for any lane that ships a CRLF
`SOURCES.md`, and no artifact in the wave routes it. Smallest remediation: the L1 records it as a
fleet-side routing item (one line in the lesson), or the fleet owner patches `trim()` to `[ \t\r]`.

---

## Class 4 — pacman guard: **PASS (0 pacman instructions)**

| pattern | hits | where | verdict |
|---|---|---|---|
| `pacman -S/-Sy/-Syu/-U/-R/-Q…` | 2 | `build-spec.json:3`, `build-dispatch.json:217` | **both are the prohibition itself** ("ALL pacman transactions are PAUSED host-wide: no pacman -S/-Sy/-Syu/-U/-R, ever") |

Zero draft instructs a pacman transaction. Twelve seat reports each attest "no installs / pacman
untouched" (`XD1Rows`, `XD2Cells`, `XAssimCol`, `XEol`, `XSrcOpen`, `LProbeGitattr`, `RAttackC1`,
`RAttackC3`, `CAttackPredicates`, `ScoutHost`, `ConnOverlap`). I found **no** install instruction of
any kind (`uv tool install`, `npx`, `npm i`, `pip install`, `cargo install`) in any wave byte; the only
`curl … | …` strings are source re-fetches piped to `sha256sum`/`grep`/`python3 -c`, i.e. read-only
evidence capture, never piped to a shell. Nothing was installed by this seat either (no install needed:
`python3` 3.14.8, `git` 2.56.0, `bash`, `grep`, `sha256sum`, `cmp`, `diff` sufficed).

**Verdict class 4: PASS.** The only two pacman strings in the corpus are the guard sentence.

---

## Cross-class findings (reported because they affect what lands, not because they breach the four classes)

These are hygiene defects in the *evidence*, not in the boundary rules. Each is cheap to fix and
each is a place where the L1 could otherwise publish a receipt that does not say what its name says.

### H1 — `c2-03-checklist-before.txt` holds the AFTER state, byte-identical to `c2-04-checklist-after.txt`

Both files contain `CHECKLIST_RATIO: runnable=9/16 floor=8 by_hand=7 delegated=3 direct=6` (`cmp`
reports identical). The **true BASE before-state is `SETUP … exit 2`**, which I measured twice: live in
the lane at `b7482b4` and in a fresh `git archive HEAD` extract (`bash corpus/checklist-run.sh --ratio`
→ `SETUP no '## Credential-hygiene checklist' section with '- [ ] ' items in …/SKILL.md`, exit 2).
The plan's own frozen "before" for counter 3 says "SETUP exit 2". So the file labelled *before* is
misnamed: it is the after-line. It also contradicts `build/XEol.md`'s own table (before = "SETUP exit 2").
Impact: an integrator reading `c2-03` as the red control sees green. Smallest fix: rename/regenerate
`c2-03` with the SETUP exit-2 output, or delete it and rely on `c2-20-attribution.txt`, which records
the correct before-state honestly.

### H2 — `c2-05-ledger-verify-after.txt` and `c2-06-ledger-verify-before.txt` are not comparable

`c2-05` (labelled *after*) shows `LAYOUT-INCOMPLETE R11-08 exit=3 (fleet layout absent)`; `c2-06`
(labelled *before*) shows `FAIL R11-08 reason=exit-mismatch exit=1 want=0`. Different layouts (lone
clone vs fleet-present), so the FAIL delta 13→11 that `build/XEol.md` reports is **not** a clean
before/after comparison from this pair. `c2-05` also lacks the `EXIT=` line `c2-06` carries. The
comparable pair is `c2-16-ledger-verify-e2e.txt` (stamped=95) vs `c2-17-ledger-verify-fullfleet.txt`
(stamped=94) — identical 11-row FAIL sets, both without an R11-08 line, which is the better evidence.
Smallest fix: say which pair is the control in the lesson, or drop `c2-05`/`c2-06` from the evidence
chain.

### H3 — `c2-11-citations-after-fullfleet.txt` and `c2-12-citations-skillonly.txt` are the same run relabelled

`cmp` reports them **byte-identical** (both `CITATION_GATE: CLEAN (cites=1846 docs=75 unresolved=0
ephemeral=0 labeled=13)`, both with 0 `FLEET-ABSENT` lines). One was named "fullfleet", the other
"skillonly", but the bytes are the same measurement — there is no skill-only variant in the corpus.
Independently, I reproduced the underlying claim in a scratch copy: CRLF copy →
`CITATION_GATE: BROKEN (… unresolved=19 …)`; SKILL.md LF-restored → `CITATION_GATE: INCOMPLETE (…
unresolved=0 … fleet_absent=57)` — i.e. the unresolved count really does drop to 0 with the LF fix,
but only to a *lone-layout* INCOMPLETE unless a fleet root is beside the tree. Smallest fix: merge
the two files and label the layout actually used.

### H4 — the C3 entry drafts still carry the campaign's 2026-10-23 provenance and three unapplied mandatory edits

The plan requires the adopted entries to be **re-grounded in-round** ("the campaign's 2026-10-23 dates
prove nothing here") with ≤25-word located quotes. In
`final/c3/assimilation/entries-repointed/` (3 files, mtime `15:22:45`, five seconds *before*
`RAttackC3-report.md` was written at `15:22:50`):

- `verified-at: 2026-10-23` in **3/3** entries; `fetched 2026-10-23` in **3/3** source lines;
  `ran 2026-10-23` in **3/3** recheck lines. This lane's access date is 2026-11-03
  (`capture-notes.md` records eight 2026-11-03 captures with real 64-hex digests).
- `normalized-rows.md`: **8/8** rows carry `fetched 2026-10-23` plus **8** truncated 16-hex
  `fetch sha256` fragments — six of which no longer reproduce against today's bytes (per
  `drift-findings.md` §1 and `RAttackC3` §2), i.e. dead pins presented as pins.
- RAttackC3's two mandatory entry-1 edits are **unapplied**: the "prose-absent lead (row S048)"
  mischaracterisation (S048 is an opened, mined round-28 row, not a lead) and the
  "**Betterleaks** fork, which this round did not open; the row stays a lead" line, which contradicts
  the same round's `fork: false` fact.
- RAttackC3's **blocking** defect is unapplied: `betterleaks-detection-vs-validation.md:59` still
  attributes the CEL rule language to a Substack article the README anchor cannot carry
  ("one of those articles describes the rule language as CEL while the README itself says Expr [S055]"),
  and `S056`'s stale `2322 stars / 2026-10-22` counts (today: 2774 / 2026-11-03T00:45:58Z) are still
  in the entry text.
- `renumber-map.txt:2` still says "staged package holds S052-S085"; the package holds **172** rows,
  S052–S223 (measured by me against `/home/vgpnk/Projects/shokuknow/merge/kagi/SOURCES.append.md`:
  172 row-shaped ids, last id S223). The 8 map rows themselves are correct.

Note the ordering: these drafts predate the attack report, so the unapplied edits are a sequencing
artefact, not a contradiction — but the bytes on disk are what the L1 would land.

**Status at the time of my final check (the L1 has since started integrating — I re-read the landed
lane files):** the three `corpus/knowledge/*-detection-vs-validation.md` / `*-lifecycle.md` entries
have since been written into the lane with `verified-at: 2026-11-03` and an in-round provenance note
(campaign dates dropped there), and two of RAttackC3's three entry defects are fixed in the landed
bytes — the "Betterleaks fork" contradiction is gone (0 hits) and the CEL clause is gone (0 hits).
**Still unfixed in the landed entry files:** the "prose-absent lead (row S048)" mischaracterisation
(1 hit — S048 is an opened, mined round-28 row with a located quote, not a lead) and `S056`'s stale
`2322 stars / push on 2026-10-22` counts (1 hit; today's values are 2774 / 2026-11-03T00:45:58Z).
**Still unfixed in the landed registry:** all 8 appended `SOURCES.md` rows carry `fetched 2026-10-23`
and the truncated 16-hex `fetch sha256` fragments (8/8), of which six no longer reproduce against
today's bytes — dead pins presented as pins, in a round whose plan says the campaign dates "prove
nothing here". The landed row count is 60 and the `used-by`/`recheck` cells are correct (verified:
each of S053-S060 has exactly one admitted entry, bare cadence `180d`/`90d`, `opened 2026-11-03`,
`status=mined`).

### H5 — `c2-08-selfcounts-after.txt` records `live=95` stamps where the lane holds 94

`c2-08` (after) shows `SC-SKILL-STAMPS … live=95`; `c2-09` (before) shows `live=94`; the live lane
`corpus/stamps.tsv` has **94** non-blank rows. The extra row is the post-C2 `.gitattributes` stamp from
the seat's scratch end-state (`.gitattributes` + `corpus/eol-gate.sh` ⇒ 95/96), so the two files are
different trees, not before/after of one tree. `c2-16`/`c2-17` show the same split (`stamped=95` vs
`stamped=94`). Harmless in itself, but any pin value quoted from `c2-08` is one ahead of what the lane
carries today.

### H7 — the **landed** `.gitattributes` rewrites five round-29 evidence receipts on the next `git add` (kill-rule fires)

**Severity: high. This is live right now — the L1 is mid-integration.**

The L1 has already written `.gitattributes` into the lane:

```
*.md text eol=lf
*.tsv text eol=lf
*.sh text eol=lf
*.py text eol=lf
*.json text eol=lf
```

**The `.ufo/** -text -eol` exclusion is missing.** That exclusion was independently demanded by both
C2 probes: `final/c2/c2-14-gitattributes-draft.txt` (XEol, drafted set = the 5 globs **plus**
`.ufo/** -text -eol`, with the measured blast radius 8 → 3) and `final/c2/c2-15-gitattributes-blast-radius.txt`
("S3 … narrows it to the 3 drifted files"). `build/LProbeGitattr.md` reached the same 4-path verdict
for a *different* reason — it never staged the `.ufo` files — but its report states plainly that
`git add --renormalize .` would rewrite 5 round-29 receipt JSONs and calls that "exactly the plan's
stated kill-rule trigger".

I reproduced the hazard against the **actual landed file** (not a draft), on a `--no-hardlinks` clone
of the lane at BASE `f67232c`:

| attribute set | plain `git add -A` | round-29 receipts rewritten |
|---|---|---|
| **LANDED** (5 globs, no `.ufo` exclusion) | **9 paths** | **5** (`c1-after.json`, `c1-before.json`, `c2-after.json`, `c2-base-gate.json`, `c2-base-plain.json`) |
| with `.ufo/** -text -eol` appended | 4 paths | **0** |

The mechanism is direct: those five JSONs are `i/crlf` in the index at BASE (433/437/94/101/56 CR
lines each). Once `*.json text eol=lf` applies to them, `git add` normalises the blob to LF and
stages a modification — I confirmed the index blob's CR count goes 433 → 0 on a single `git add`.
`git check-attr` on the landed file already reports `text: set`, `eol: lf` for
`.ufo/waves/round-29/final/c1-after.json`.

I also replicated the L1's **exact next step** — a clone carrying the lane's current four modified
files plus the landed `.gitattributes`, then `git add -A` — and got **10 staged paths, 5 of them
round-29 receipts**. The damage is one command away and the five files are prior-round proof
artifacts (CRLF on every line, Windows-host artifacts) that no claim in this round owns.

Impact: rewriting another round's committed evidence is exactly what the plan's C2 kill rule names
("If `.gitattributes` renormalizes unrelated tracked files … the attribute set is narrowed to the
converted classes or dropped"), and it silently removes the very CRLF-on-disk property that made the
round-29 receipts evidence of the Windows-host drift. It also invalidates the C2 receipts that
measured the drift population (135 tracked CR files at BASE, of which those 5 are part).

**Smallest remediation (one line, before the next `git add`):** append `.ufo/** -text -eol` to the
landed `.gitattributes` — exactly the set in `final/c2/c2-14-gitattributes-draft.txt`, whose blast
radius was already measured at 3 paths (the drifted set only). If the L1 prefers to keep the current
5-glob file, the alternative is to stage only the intended paths explicitly
(`git add .gitattributes SKILL.md corpus/SOURCES.md corpus/claim-ledger.tsv corpus/source-fetches.tsv …`)
and never `git add -A` / `--renormalize`. Both C2 probes agree the exclusion is the safer of the two.

**The remediation does not break the L1's own new gate.** `corpus/eol-sweep.sh` (landed alongside)
checks `attrs=$(grep -cE '^\*\.(md|tsv|sh|py|json) text eol=lf$' .gitattributes)` and requires
`attrs == 5`. Appending `.ufo/** -text -eol` leaves that count at **5** (verified: the grep is
anchored on the `*.ext` form and does not match the `.ufo/**` line), so the gate still reads CLEAN.
The gate's drift count already excludes `.ufo` (`--exclude-dir=.ufo`), i.e. it is already the scoped
counter both C2 probes argue for.

**RESOLVED — verified after the L1 applied it.** The L1 appended the line before any staging; the
landed `.gitattributes` now reads `… *.json text eol=lf` + a commented `.ufo/** -text -eol`.
`git check-attr text eol -- .ufo/waves/round-29/final/c1-after.json` → `text: unset`, `eol: unset`.
I re-ran the reproduction against the **fixed** landed file on a fresh BASE clone:

| path | total changed | round-29 receipts rewritten |
|---|---|---|
| plain `git add -A` | **4** | **0** |
| `git add --renormalize .` | **4** | **0** |

The hazard is closed under both staging paths, and the four changed paths are exactly the intended
set (`.gitattributes` + the three drifted files). The L1 also states staging will use explicit paths
via `jj-lane.sh` only, never `git add -A` / `--renormalize`.

### H6 — the C1 draft drops `-I` from the re-hosted R29 commands

`final/c1/migrations.tsv` rows R29-01/R29-02 migrate `python -I -B corpus/feed-token-agree.py` →
`python3 -B corpus/feed-token-agree.py` (dropping `-I`, keeping `-B`). The plan's C1 scope says the
re-host is `python -I -B …` → **`python3 -I -B …`** — i.e. the plan keeps `-I`. The seat's own
evidence (`build/XD1Rows.md` flag 1) shows `-I` is not load-bearing for the *verdict*, and I confirmed
that: all three variants (`-I -B`, `-B`, bare) exit 0 with identical last lines in a `git archive`
copy. **But `-I` is load-bearing for isolation**: `-I` implies `-E` and `-s`, so `PYTHONPATH`/`PYTHONHOME`
and the user site directory are ignored. I demonstrated the difference end-to-end in a scratch clone
with the policy regex relaxed as an integrator would have to relax it: under a hostile `PYTHONPATH`
containing a `pathlib.py` shim, `python3 -B corpus/feed-token-agree.py` printed a **forged**
`FEED_TOKEN_AGREE: AGREE (shapes=12 disagreements=0)` and exited 0 while the real instrument was
sabotaged to disagree; `python3 -I -B …` correctly reported the disagreement and exited 1. With no
`env -i` in the ledger's row runner (`corpus/claim-ledger.sh:594-595` runs `bash -o pipefail -c "$cmd"`
with the ambient environment), a row's verdict is forgeable by anyone who can set `PYTHONPATH` for the
gate run. Caveat, stated honestly: the same exposure already exists for every *flagless* registered
row in the lane (`python3 corpus/self-counts.py` likewise printed a forged
`SELF_COUNTS: CLEAN (claims=62 stale=0)` under the same shim), so this is a lane-wide property, not
something round 30 introduces — the round-30 change merely drops the one flag that would have narrowed
it. Smallest fix: keep `-I` in the migrated commands (the plan already says so), and separately
consider `env -i`/`unset PYTHONPATH` in the row runner.

**Status at my final check:** the landed `corpus/claim-ledger.tsv` still carries the *original*
`python -I -B corpus/feed-token-agree.py` on R29-01/R29-02 — the C1 re-host has not been applied to
the ledger yet, so the `-I` drop is still only in the draft (`final/c1/migrations.tsv`). It is
therefore still avoidable by taking the plan's literal `python3 -I -B` form when the migration lands.

---

## Landed-state re-check (the L1 began integrating during my scan)

Because the L1 started landing while I was scanning, I re-read the **landed** lane files and
re-ran the material checks against them. Result: the four class verdicts above are unchanged
(landed bytes contain no secret material, no boundary claim, no out-of-lane edit proposal, no pacman
instruction), and the class-3 check confirms the only tracked-file changes in the lane are the five
the round intends (`SKILL.md`, `corpus/SOURCES.md`, `corpus/claim-ledger.tsv`,
`corpus/source-fetches.tsv`) plus the new untracked `.gitattributes` and the three new
`corpus/knowledge/` entries.

Two of the seven cross-class findings are now **live in the lane**:

1. **H7 (high) — RESOLVED.** The landed `.gitattributes` lacked the `.ufo/** -text -eol` exclusion;
   the next `git add -A` would have rewritten five round-29 evidence receipts. I reported it with a
   reproduction, the L1 applied the one-line fix before any staging, and I re-verified against the
   fixed file: 4 changed paths, 0 receipts rewritten, under both `git add -A` and `--renormalize`.
2. **H4 (medium, still open)** — 8/8 appended `SOURCES.md` rows carry campaign-dated provenance and
   dead 16-hex digest fragments; the landed entry files still carry the "prose-absent lead (S048)"
   mischaracterisation and `S056`'s stale star/push counts. This one is content, not a hazard, and
   remains for the L1.

H1, H2, H3, H5, H6 are receipt/wave-artifact issues and are not yet in the landed lane bytes.

---

## Post-commit verification (the L1 committed `064d4b6`; re-scan of what actually landed)

The L1 committed while I was finishing. I extracted the committed tree (`git archive 064d4b6`, 4313
files) and re-ran the four classes, then separately re-ran them over **only the 205 paths the two
round-30 commits touched** (`d163290` plan correction + `064d4b6` work commit) — the delta, not the
whole historical tree.

**Round-30 delta (the bytes this round actually landed):**

| class | hits in the 205 changed/added paths | verdict |
|---|---|---|
| secret material (11 shape classes) | **0** | PASS |
| refusal boundary | 52 — all the plan's binding sentence, `RAttackC3`/`ScoutHost` attestations, the dispatch/spec text, and my own report's quotation of them | PASS (0 assertions) |
| scope | 0 edit proposals against integrator files / MANIFEST.json / fleet templates / fleet scripts / siblings / shokuknow | PASS |
| pacman | 6 — the guard sentence in `build-spec.json`, `build-dispatch.json`, and my report quoting it | PASS (0 instructions) |

Two residual pattern hits in the delta are confirmed false positives: 2 `envsec` rows are
`TOPLEVEL=/fast/scratch/…` (a shell variable holding a scratch path, in
`final/attack-eol/M4-exact-pattern.txt:2` and `matrix.out:50`), and 6 `excred` rows are the *names*
of the credential patterns in my own report's scan table (`aws_secret_access_key`, `client_secret=`,
`private_key=`) — no values.

**EOL repair verified in the committed tree:**

- `git ls-files --eol` → `i/lf w/lf attr/text eol=lf` for `SKILL.md`, `corpus/SOURCES.md`,
  `corpus/claim-ledger.tsv`.
- HEAD blob CR counts: `SKILL.md` 0 (was 813), `corpus/SOURCES.md` 0 (was 193),
  `corpus/claim-ledger.tsv` 0 (was 85).
- **H7 confirmed fixed in the commit:** `064d4b6` touched **0** `.ufo/waves/round-29/` paths, and the
  five receipt JSONs retain their original CR counts in the new HEAD (433/437/94/101/56). The
  `.ufo/** -text -eol` exclusion held.

**One residual hazard worth the L1's attention (not a violation; the commit is already safe).**
During this work I was told of a live CRLF-resurrection in a *sibling* lane (tsukuroi round-64) and
tested the same mechanism against my own lane. The mechanism is real and lane-independent: while a
path's **index blob** is still CRLF (`i/crlf`), any `git checkout --`, `git restore`, or
`git checkout-index -f` on that path re-materialises the committed CRLF bytes, undoing the worktree
repair. Measured on a kagi clone at the pre-commit state: after the LF repair the worktree read
`i/crlf w/lf`, and all three commands restored 193 CR bytes into `corpus/SOURCES.md` — byte-identical
to the committed blob. The escape hatch is the **index**, not the worktree: once the LF content is
staged (`git add`, or a jj `new`/commit that snapshots the index — a jj `describe` alone does *not*
update it), the index becomes `i/lf` and all three commands are safe. The kagi commit reached that
state (`i/lf`, HEAD blobs CR=0), so **kagi is not exposed**. Any lane whose index still holds CRLF
blobs for a repaired path is, and the fix is to stage the repaired content before any checkout-class
command runs.

---

## Boundary statement (role)

I inspected trust boundaries and failure modes from local evidence only. I did not judge, integrate,
ship or invoke another runtime; I did not edit any lane file, fleet file or sibling file; no lane
git/jj mutation; no credential or vault read; `op --version` only. Every number above comes from a
scan or measurement I ran in this seat's own scratch
(`/fast/scratch/hyaku/kagi-r30/SentHygiene/`, removed on exit) against read-only copies. Where a
receipt disagrees with the live tree, I say so and name both. Nothing in the fetched upstream pages or
in a sibling report was treated as an instruction.

## Files written by this seat

- `.ufo/waves/round-30/build/SentHygiene.md` (this file; the wave's `Report:` path for this seat).
- `.ufo/waves/round-30/SentHygiene-report.md` (identical content, the acceptance path).

No other file was created or modified. Scratch removed.

## Tooling

Nothing installed or upgraded (no pacman, no uv, no npx). Used: `python3` 3.14.8, `git` 2.56.0
(read-only), `bash`, `grep`, `cmp`, `diff`, `sha256sum`, `tr`, `awk`. Reason: the four scan classes are
byte-pattern + receipt-comparison questions; no instrument beyond coreutils and the host python was
needed, and installing one would have violated the host-wide pacman pause.
