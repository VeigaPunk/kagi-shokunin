# K45Sentinel — round-45 refusal-boundary and gaming review

Seat: sentinel (leaf member, no subagents dispatched). Read-only everywhere except this
report and `.ufo/waves/round-45/build/K45Sentinel-receipts/`.
Lane: `/home/vgpnk/Projects/shokunin/kagi-shokunin` (branch `master`).
Scratch: `/fast/scratch/hyaku/kagi-r45/K45Sentinel/` (all fixture trees under `mktemp -d`
inside it, each removed by `trap 'rm -rf -- "$S"' EXIT`; receipts copied out first).
Measured revision used for the C1/C2 counter readings: candidate `072bb0b` (the round-45
candidate landed during this seat's run; BASE `0d0192f`, predeclaration `307fb50`).
No tool was installed or upgraded by this seat (no pacman transaction; nothing to record).

## Axes named

calibration · coverage · freshness. Every finding below is a trust-boundary or
gaming observation about the round-45 instruments and staged inputs — not a claim that
the round is green.

---

## (a) Staged inputs — secret-shape scan

Targets (read-only, never edited):

- `/home/vgpnk/Projects/shokuknow/merge/kagi/knowledge/corpus/knowledge/iso-11770-3-2015-supersession-chain-r39.md`
- `/home/vgpnk/Projects/shokuknow/merge/kagi/knowledge/corpus/knowledge/iso-11770-3-catalogue-record-and-lifecycle-r41.md`
- `/home/vgpnk/Projects/shokuknow/merge/kagi/SOURCES.append.md` (staged registry rows)

**S-01 — INFO — no secret-shaped material in either staged entry.**
Pattern set and per-file counts (commands and outputs in §Receipts):

| pattern | r39 | r41 |
|---|---|---|
| `op://` | 0 | 0 |
| `sk-[A-Za-z0-9_-]{8,}` | 0 | 0 |
| `AKIA[0-9A-Z]{16}` | 0 | 0 |
| `-----BEGIN [A-Z ]*PRIVATE KEY-----` | 0 | 0 |
| `eyJ…` (JWT) | 0 | 0 |
| `gh[pousr]_[A-Za-z0-9]{20,}` | 0 | 0 |
| `xox[baprs]-…` | 0 | 0 |
| `cookie:` / `set-cookie` / `session[-_]?id` | 0 | 0 |
| e-mail / card / CN id / CN mobile / SSN | 0 | 0 |
| `bearer …` / `authorization:` | 0 | 0 |
| `password|secret|api_key|token…[:=]…` | 0 | 0 |
| `AKIA`/`GOOGLE_KEY`/`AGE-SECRET`/`hv…` | 0 | 0 |
| DB-URL credentials, npm/pypi/hf/anthropic/openai prefixes | 0 | 0 |
| `op://` + path | 0 | 0 |

The only hits in the two entries are benign: `LONG_HEX`/`LONG_B64` = 0 in both;
`PHONE` = 2 in r41 (digits inside the archive.org URL timestamp and a page-number
span — classified as URL/date context, not a number). No vault or account instruction
is present in either entry: `op`, `1password`, `the-janitor`, `vault` = 0 hits.

**S-02 — LOW — staged registry rows disclose local host paths.**
`/home/vgpnk/Projects/shokuknow/merge/kagi/SOURCES.append.md:150,156,170,171` — four
rows carry an absolute `/home/vgpnk/…` path in the source cell (own-work rows).
Pattern: `ABSOLUTE_HOST_PATH`. Not a secret and not a credential; it is path disclosure
inside a package that will be read by other lanes. Ceiling: the lane registry already
carries one such path today (`corpus/SOURCES.md:131`, pre-existing, not from this
round), and the staged rows are own-work rows the plan renumbers anyway.
Smallest remediation: carry a repo-relative path or the lane id instead of the host path.

**S-03 — INFO — the three `1password` hits in the staged rows are public vendor titles.**
`SOURCES.append.md:47,48,50` — `1Password Credential Broker` documentation pages
(`www.1password.dev/…`). Pattern: `VENDOR_NAME`. No token, no scheme, no path.

---

## (b) Round-45 wave artifacts and counters — secret-shape and privileged-call scan

Targets: every file under `.ufo/waves/round-45/build/` (114 files at scan time) and
`plans/round-45*.sh`.

**S-04 — LOW — `op://` appears as a bare scheme in four wave artifacts; no reference path.**
`.ufo/waves/round-45/build/K45Revenger.md:6`,
`.ufo/waves/round-45/build/K45ScoutSources.md:374`,
`.ufo/waves/round-45/build/K45ScoutSources/report.md:374`,
`.ufo/waves/round-45/build/K45ScribeEntry.md:43`.
Pattern: `OP_URI_SCHEME_ONLY`. Each occurrence is the scheme inside backticks in a
refusal sentence; the next character is a backtick in all four, so the lane census's own
credential ERE (`op://[A-Za-z0-9_-]`) does **not** match them. No vault path, no item,
no field, no secret value was written anywhere in the wave. (This report and the
receipt scripts under `K45Sentinel-receipts/` also contain the bare scheme as pattern
literals — 5 further occurrences, same shape, no path.)
Ceiling: the refusal boundary forbids writing an `op://` *reference path*; a bare scheme
token in a refusal sentence is not one. Residual risk: a future reader or a
loosened scanner could mistake it for a path.
Smallest remediation: write the scheme name without the `://` (e.g. "the 1Password
secret-reference scheme") — the four sentences lose nothing.

**S-05 — INFO — captured vendor pages carry session/password *identifiers*, not values.**
16 lines in the four raw captures match `session[-_]?id` case-insensitively
(`K45ExecISO/captures/S159.raw:648,4200,4228,4233` and the same line families in
`S171.raw` (648,4228,4256,4261), `S172.raw` (648,4193,4221,4226), `S173.raw`
(648,4214,4242,4247)): a `mage-cache-sessid` JS constant and a `sessionIdentifier`
query parameter in a payments script URL. 6 lines match a
`password|secret|api_key|token…[:=]…` shape (`S159.raw:1865`, `S171.raw:1865`,
`S172.raw:1865`, `S173.raw:1865` — a `customer-password` form-field read — plus two prose
mentions in `K45ScoutSources.md:346` and `report.md:346`). Patterns:
`SESSION_ID_IDENTIFIER`, `PASSWORD_KV_FORM_FIELD`. These are public page chrome; no
cookie, no token value, no credential. One published organisational contact address
appears in the captured ISO page (`K45ExecISO/captures/S170-live.raw:1175,1177`,
`K45ScoutSources/independent-iso60237.raw:1175,1177`,
`K45ExecISO/captures/S170.txt:1`): pattern `EMAIL_PUBLIC_CONTACT` — an organisational
e-mail on a public standards-body page, now inside a committed artifact. Ceiling:
`corpus/README.md:12` bars secret values, tokens, cookies and vault ref paths, not
published page content; but it is personal data of the mild organisational kind and it
was carried into the repo without a note. Smallest remediation: one line in the lesson
saying the capture body embeds a public contact address.

**S-06 — INFO — no privileged, mutating or vault call anywhere in the wave.**
Counts below exclude this seat's own report and receipt scripts (which contain the
pattern strings themselves). `pacman` 6 hits, all prose refusals
(`K45ExecISO.md:63`, `K45Revenger.md:6,16`, `K45Revenger/routed-state.md:5`,
`K45ScribeEntry.md:44`, `K45ScribeEntry/receipts.txt:121`); `sysctl` 1 (prose refusal,
`K45ScribeEntry.md:44`); `sudo` 0; `systemctl` 2 — both the revenger's read-only
inventory queries (`K45Revenger/routed-state.md:24,122`: `systemctl list-timers
--no-pager` / `crontab -l`, exit 0 and 127). No `pacman`, `sudo`, `op`, `1password`,
`the-janitor` or `vault` invocation; no `git add/commit/push/checkout/reset/stash` in
the lane; no mutating `jj`; no HTTP verb other than GET (`-X POST|PUT|DELETE|PATCH`,
`--data`, `-d` = 0 hits). The lane tree was never written by this seat; all fixture
work lived in scratch.

---

## (c) Adversarial: can the frozen instruments be satisfied without the underlying property?

### C1 — the REAL leg and the frozen counter

**S-07 — HIGH — the cheapest C1 forgery is a scope floor raised above the real landed rounds.**
Measured on a sandbox clone of the candidate `072bb0b`, with the candidate gate
(`build/K45ExecBijection/claims-declared.sh`) edited only in the scope bound
(`corpus/claims-declared.sh:202`, `-lt 39`):

| gate scope floor | frozen counter reads | planted omission at real round 39 / 44 / 45 |
|---|---|---|
| 39 (honest) | value=2 detected=2 positive=1 real=CLEAN | DETECTED (rc=1) at all three |
| 46 | value=2 detected=2 positive=1 real=CLEAN | **MISSED (rc=0)** at all three |
| 90 | value=2 detected=2 positive=1 real=CLEAN | **MISSED (rc=0)** at all three |

The frozen counter's fixtures A/B/C live at synthetic rounds 90/91, so any floor above 45
leaves them firing while every real landed round (39–44) stops being checked. The
mutation battery's scope mutant is the mirror of this one (`MINR=39→1`, killed by the
real tree); `MINR=39→46` is not in the battery and survives it: the battery reads
`value=2` for it. Named ceiling already recorded: `plans/round-45.md` A1-4 (fixtures
carry no shared marker; the REAL leg and the committed `--selftest` must both pass).
That ceiling does **not** cover a raised floor, and both of those remaining legs pass
for the raised-floor mutant (the gate's own `--selftest` reads
`CLAIMS_DECLARED_SELFTEST: PASS (8 cases)` for floors 39, 46, 90, 91 and 100 — the
selftest exercises only the manifest→plan direction).
Check that would refuse it: one planted-omission fixture at a **real** landed round
(39–45) that must read MISMATCH, plus an assertion that the scoped-round/pair counts
are non-zero and equal to the expected (an independent reference prints
`scoped-rounds=7 pairs=17 rows=17` on the candidate tree; a scope-narrowed gate prints
`scoped-rounds=0`).

**S-08 — HIGH — the crudest C1 forgery replaces the whole new direction with a
round-90-only stub.** Replacing the entire plan→manifest block of the candidate gate
with an unconditional `MISMATCH` for round 90 (no manifest/plan reasoning at all)
still reads `detected=2 positive=1 real=CLEAN` on the frozen counter, while missing a
planted omission at real round 44 (rc=0; the honest gate reads rc=1). Same refusing
check as S-07: a real-round fixture, and the requirement that the new direction's
verdict be derived from the manifest, not from the round number.

**S-09 — HIGH — C1's REAL leg can be satisfied by editing the registry, not the gate.**
On the candidate tree in a sandbox clone: deleting round 44's three manifest rows **and**
renaming round 44's `## Round 44 — post-move` header makes the gate exit 0
(`CLAIMS_DECLARED: CLEAN (claims=14)`) while `plans/round-44.md` still carries its
three `## C<k> — <axis>:` headings on disk (measured: 3 headings remain). Deleting the
manifest rows alone is caught (`MISMATCH 44 C3 no-manifest-row`); the header rename is
the second half of the forgery, because the direction's scope key is the SCORECARD
post-move header. Cheapest forgery: one manifest edit plus one SCORECARD header rename
per round. Check that would refuse it: an independent reference that enumerates
plan headings for rounds ≥39 **independently of the manifest and of the post-move
header** (the reference prints `scoped-rounds=6 pairs=14 rows=14` after the shrink,
against `7/17/17` before — the count moves, so a count assertion catches it), or a
stamp/ledger pin on `corpus/claims-declared.tsv` (currently unpinned: 0 stamp rows, 0
ledger rows, at BASE and at the candidate).

### C2 — the LOCATED leg

**S-10 — HIGH — LOCATED can be satisfied by a capture the seat wrote itself, with no
fetch at all.** In a sandbox clone of the candidate I removed the three committed
capture bodies and substituted three files whose *entire content* is the quote text,
then added matching `corpus/source-fetches.tsv` rows (self-consistent identity digest,
sha256 and byte count of my own file), `corpus/quote-bodies.tsv` rows and registry
rows. The **frozen** counter (`plans/round-45-c2.sh`, byte-identical except the
`LANE=` line) then read:
`C2_LOCATED: value=3 added=3 entries=1 census=0 located=3 (quote-locate rc=0, rows-added=3, not-located-added=0)`.
Nothing in `corpus/quote-locate.py` or in the census leg can distinguish a pasted body
from a fetched one: the locator checks body-sha256 ↔ provenance row, quote-at-offset,
and quote-in-registry-row — all three are self-consistent for a body the seat wrote.
Check that would refuse it: an **independent second capture of the same URL whose
sha256 must equal the committed body's sha256**. That check exists in the wave for one
of the three rows and I reproduced it: the scout seat's `independent-iso60237.raw` is
byte-identical to the committed `S101.raw` (`cmp` → identical) and my own refetch of
that URL with the declared request profile reproduced sha256
`2e4c1524ec05865536f819db68c56494d97fc67cb490df4f5d4b1ca85b7b0c80` exactly. For the two
IEC rows whole-body digest equality is **not** available (see S-12): the IEC page embeds
a per-response build hash, so two fetches of the same URL differ by 16–18 bytes at two
8/9-char lowercase-hex runs. There the refusal must be quote-located-at-offset in a body
plus a *second* fetch reproducing the quoted span, not digest equality.
Ceiling already recorded: `plans/round-45.md` §C2 declared ceilings ("C2 checks
committed capture bodies only; it does not re-fetch a live page. The live re-open is the
sourced-claim duty"). This finding names the cost of that ceiling.

**S-11 — MEDIUM — the located set is decoupled from the entry's own citations.**
The counter's `entries` leg counts a knowledge file whose first `source:` line cites an
ADDED id; its `located` leg counts `corpus/quote-bodies.tsv` rows whose id is in ADDED.
The two sets are computed independently. Replayed on a scratch tree: an entry citing
S900 (an ADDED id with **no** quote-bodies row), while three unrelated ADDED ids
S901/S902/S903 carry the located quotes → `value=3 added=4 entries=1 located=3`, with
the entry-cited ∩ located-quote intersection empty. So C2's value does not certify that
the located quotes are the entry's quotes. Check that would refuse it: require the
located ids to be a subset of the ids the admitted entry cites.

**S-12 — MEDIUM — the located quotes are not the entry's sentences, and the entry's
sentences are not byte-present in the committed bodies.**
`corpus/quote-bodies.tsv:7,8,9` locate short page-title strings
(`ISO/IEC 11770-3:2015/AMD1:2017` at offset 187, `Withdrawal of International Standard`
at 45752, `ISO/IEC 11770-3:2021` at 187) — verified byte-exact at those offsets in the
committed `.raw` bodies with `dd`. The entry
(`corpus/knowledge/iso-11770-3-edition-status.md`) instead asserts
`A more recent version of this publication exists: ISO/IEC 11770-3:2021/AMD1:2025`,
`New version available: ISO/IEC 11770-3:2021`, `Status : Withdrawn` and the
key-lifecycle exclusion sentence. Measured occurrences of those sentences in the
committed `.raw` bodies: **0** byte-for-byte; **1** each after whitespace/tag
normalisation. So `located=3` certifies three titles, not the entry's factual claims.
Related freshness fact: the two IEC bodies are **not** byte-stable — committed
`S100.raw` sha256 `9ef61b3f…` vs an independent same-profile refetch `8055b2b9…`
(16 differing bytes) vs the executor's `S159.raw` `8bd6e969…` (18 differing bytes), the
deltas confined to two lowercase-hex runs inside the page's JS; `S101.raw` is stable
across all three fetches. The provenance rows therefore declare
`representation=decoded-http-body-v1` for S100/S102 although the corpus's own
vocabulary reserves `decoded-http-body-volatile-v1` for exactly this
("deployment/response-coupled … a per-response token"). The census accepts either
class, so no gate refuses it. Smallest remediation: declare the volatile class for
S100/S102 and say in the lesson that their digests are point attestations, not pins.
Correction to a peer finding: the landed `quote-bodies.tsv` offsets (187 / 45752 / 187)
do resolve byte-exactly in the committed `.raw` bodies — the ".txt-render offset"
defect belongs to the staged package's rows, not to the landed ones.

### M45-1 red witness and the stamp/ledger surface

**S-13 — LOW — the M45-1 witness is satisfiable by a coordinated edit.**
`corpus/stamps.tsv` has no self-pin (0 rows for itself at BASE and at the candidate)
and the ledger pins only the row count (`R12-03`, `^122$`). In a scratch tree I altered
the stamped lane-root `LOG.md` **and** updated its stamp cell in the same tree:
`STAMP_DRIFT: rows=123 drift=0`, rc=0 — the witness reports clean. The seat's own
witness does what the plan asks (base drift=0; a stamped file altered → drift=1, rc=1;
I reproduced all three arms independently, including `corpus/QUALITY.md` → drift=1).
Pre-existing ledger drift, present at BASE `0d0192f` and not caused by round 45:
`R12-03` expects 122 stamp rows while the tree has carried 123 since round 42, and
`R34-03` expects a clean census with rows=98 while the tree reads rows=99 at BASE and
rows=102 at the candidate. Check that would refuse the coordinated edit: pin
`corpus/stamps.tsv` itself (hash) and pin the manifest row count, so a stamp edit and
its object edit cannot land together unnoticed.

**S-14 — MEDIUM — the landed ids now collide with staged-reserved ids for other
documents.** The plan renumbers by document to "the next free lane ids (S100 onward)";
the staged package also uses S100–S223 for different documents (S100/S101 = GitHub API
tree for betterleaks, S102 = a SAMR query). Measured after the landing: the §6 collision
pair (lane registry ids ∩ staged ids) grew from 48 to **51**, the three new members
being exactly the landed `S100, S101, S102`; the lane's own ids and the staged ids
denote different documents at the same number. Check that would refuse it: take the
next free id **above the staged package's reserved range** (or renumber the staged
package's reserved ids out of the lane's way) rather than from S100.

### Routed round-44 items — cross-checked where they touch this seat's surface

- Item 4 (unopened candidates → `## Leads (unopened)` bullets, no rows): verified at
  the candidate — `corpus/SOURCES.md:144` opens `## Leads (unopened)`, the moved
  inventory sits at `corpus/SOURCES.md:152` as a bullet, and **0** row-shaped lines
  exist between lines 144 and 193. Consistent with the routed requirement.
- Item 1 / M45-1 (stamp migration undercount → erratum + red witness): the red witness
  exists and fires (S-13 above); the coordinated-edit defeat and the stale ledger pins
  are named there. The erratum itself was not audited here (scribe seat's file).
- Collision/quarantine: independently re-measured at the candidate — the §6 pair
  (lane registry ids ∩ staged package ids) reads **51**, up from 48 at BASE, the three
  new members being the landed `S100/S101/S102` (S-14). The quarantine slice
  (S053, S071, S081, S090, S091, S093, S108, S113) intersects the admitted entry's
  cited ids in **0** members.

---

## What was measured, and what was not

Measured (commands, exit codes and last output lines are in
`.ufo/waves/round-45/build/K45Sentinel-receipts/`):

- `bash plans/round-45-c1.sh 072bb0b` → rc 0, last line
  `C1_BIJECTION: value=2 detected=2 positive=1 real=CLEAN (rc A=1 B=1 C=1 tree=072bb0b; real-last='CLAIMS_DECLARED: CLEAN (claims=17)' …)`.
- `HYAKU_SCRATCH=/fast/scratch/hyaku bash plans/round-45-c2.sh 072bb0b` → rc 0, last line
  `C2_LOCATED: value=3 added=3 entries=1 census=0 located=3 (quote-locate rc=0, rows-added=3, not-located-added=0, tree=072bb0b)`.
- `python3 corpus/quote-locate.py` on the candidate → rc 0, `QUOTE_LOCATE: CLEAN located=8 rows=8`.
- `/home/vgpnk/Projects/shokunin/scripts/sources-census.sh validate --file corpus/SOURCES.md` → rc 0, last line `file ok …/corpus/SOURCES.md` (W04 warnings only).
- `bash corpus/sources-census.sh` (lane census) on the candidate → rc 1,
  `SOURCES_CENSUS: FAILED (findings=3 rows=102)`; the same three findings exist at BASE
  (`findings=3 rows=99`), so the candidate adds none.
- Independent refetches of the three public URLs with the declared request profile
  (`curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)'`):
  S101 reproduced the committed digest exactly; S100/S102 differ by 16/16 bytes in two
  hex runs.

Not run, and why:

- The lane's full `corpus/claim-ledger.sh verify` — host-heavy, and the assignment
  forbids the lane's full claim-ledger verify and self-counts. Only the two named
  counters and the census/quote-locate gates above were run.
- `corpus/sources-census.sh --selftest`, `corpus/claim-ledger.sh --selftest`,
  `corpus/release-clock.py` (live feed fetch) — out of this seat's named instruments.
- Any fetch that is not GET to a public standards page; no form post, no remote write.
- The sibling wave's final report set was not audited for findings outside the
  round-45 build directory and the two frozen counters.

## Receipts

`.ufo/waves/round-45/build/K45Sentinel-receipts/` holds 45 files: the scanners
(`scan.sh`, `summary.sh`, `wide.sh`, `ci.sh`, `classify.sh`, `redact.sh`), their outputs
(`scan-hits.txt`, `summary-final.txt`, `wide-final.txt`, `ci-final.txt`,
`classified.txt`), the adversarial drivers and their outputs
(`c1-scope-forgery.sh`, `c1-fixture-aware-forgery.sh`, `c1-crudest-forgery.sh`,
`c1-threshold-46.sh`, `c1-candidate-scope-forgery.sh`, `c1-candidate-scope-shrink.sh`,
`c1-manifest-mutation.sh`, `c1-manifest-scorecard-gaming.sh`,
`c1-manifest-postmove-deletion.sh`, `c1-scope-shrink.sh`, `c2-selfauthored-forgery.sh`,
`c2-forgery-counter.sh`, `c2-decoupled-coverage.sh`, `c2-strict-decoupling.sh`,
`c2-lane-census.sh`, `m451-witness.sh`, `m451-selfdefeat.sh`,
`entry-quotes-in-committed-bodies.sh`, `entry-quotes-normalized.sh`) with their
recorded outputs. Every secret-shaped scan prints pattern names and `path:line` only —
never a matched value; where a context view was needed, the matched substring was
replaced by `[REDACTED]` before printing.

No secret value, token, cookie, vault field or `op://` reference path was printed,
copied or written by this seat; no account, 1Password, `op` or the-janitor was
contacted; no host sysctl, service, user, package or kernel setting was touched; no
pacman transaction was run; no tool was installed or upgraded.

SEAT-STATUS: complete
