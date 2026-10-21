# CritSupersession — round-23 falsification: supersession handling

Seat: critic (leaf). Target: S019/S020/S022/S023/S025/S026 carry their
supersession only as prose (`supersedes S0NN —` in `teaches`). Questions:
(1) can a stale (superseded) row's evidence stay active, and (2) do the census
used-by/cite checks ever see a missing supersession edge? Axes: calibration,
freshness, operability.

Footprint: read-only on the lane. The only lane write is this file. Mutations
ran on copies in a `mktemp -d` scratch root (`/tmp/critsup.tWpPnS`), removed
after this report (§8). No production edit, claim-ledger verify, host-bound
row, vault/account/handler command, network fetch, install, or git/jj
mutation. Read-only `git diff` only.

## 0. Bytes measured (the tree changed while the wave ran)

`corpus/sources-census.sh` changed at least six times between ~03:55Z and
04:20Z: five times in the table, and once more before the re-check below.

| observed (UTC) | census sha256 | state |
|---|---|---|
| first read, ~03:55 (not hashed; read tag `#3974`) | vA | `SUPERSEDED` declared (`:230`), filled from `^supersedes S…` rows (`:243-247`), **never read** |
| 03:59:35, 04:00:05 | `80966e20…` (vB) | declaration dropped (`:229`), writer kept (`:242`) → **live gate crashes** (F1) |
| 04:07:06 | `24d834cc…` (vC) | parser deleted; same-URL agreement block present |
| ~04:10 | `6d4190a7…` | seen once, not analysed |
| 04:10:43 | `6f202fce…` (vD) | same-URL block deleted; its own selftest `FAIL (59 cases, 1 failed)` (`fetch-disagree` wanted 2 findings, got 1) |
| 04:11:18–04:14:24 | `511deb27…` (vF, final) | CLEAN; selftest PASS (59) |

Final snapshot (vF, 04:14:24Z): `SOURCES.md` `c6ea91ab…`, `source-fetches.tsv`
`6e26e140…`, `lessons/round-23.md` `93df7d34…`, E3
`knowledge/vault-openbao-token-lease-lifecycle.md` `4932f37f…`, E1
`knowledge/onepassword-machine-credentials.md` `8380b359…`. Also: fleet
`scripts/sources-census.sh` `3fb72615…` and `.ufo/waves/kaika/SOURCES-CONTRACT-v1.md`
`6c674a22…`. Unless a finding says otherwise, every result below is on vF
bytes. The supersession results (F2–F7) were also identical on vC, on vD, and
on a scratch copy of vB with only `SUPERSEDED=()` added to the `:229`
declaration.

Post-snapshot re-check: at 04:20:24Z the census was `2d1bbbe3…`, a sixth
version. On it, `grep -c supersed corpus/sources-census.sh` → 0, verify →
`CLEAN (rows=26 …)` exit 0, and `--selftest` → `PASS (59 cases)` exit 0. On
fresh scratch copies of that tree, C04 → CLEAN exit 0, C09 → CLEAN exit 0, and
C13 → `FINDING SC_USEDBY_NOCITE id=S014 …`, FAILED, exit 1. Those copies
(`/tmp/critsup2.*`) were removed: cleanup exit 0, 0 left.

The lesson changed during the wave as well. At `993e114a…` (04:07Z),
`## Falsification bounds` said "The 64-seat falsification wave **confirmed** the
three claims". At 04:08:35Z, `ls .ufo/waves/round-23/falsify | wc -l` gave 35
entries, including `swarm-registry.json`: 34 of 64 reports, and not this one.
By `49632920…` (04:11Z) the sentence read "reported on". Any verdict must name
final hashes.

## 1. Commands and exits (live lane)

| command (cwd = lane root unless noted) | census sha | result | exit |
|---|---|---|---|
| `bash corpus/sources-census.sh` (run twice) | `80966e20` | stderr `corpus/sources-census.sh: line 242: S007: unbound variable`; **no stdout, no verdict line** | 1 |
| `bash corpus/sources-census.sh --selftest` | `80966e20` | `SOURCES_CENSUS_SELFTEST: PASS (59 cases)` | 0 |
| `bash corpus/sources-census.sh` / `--selftest` | `24d834cc` | `CLEAN (rows=26 …)` / `PASS (59 cases)` | 0 / 0 |
| `bash corpus/sources-census.sh` | `511deb27` | `SOURCES_CENSUS: CLEAN (rows=26 A=24 B=0 C=2 queued=1 mined=24 rejected=1 entries_sourced=4 legacy=21)` | 0 |
| `bash corpus/sources-census.sh --selftest` | `511deb27` | `SOURCES_CENSUS_SELFTEST: PASS (59 cases)` | 0 |
| `bash scripts/sources-census.sh validate --root /home/vgpnk/Projects/shokunin kagi` (cwd fleet root; read-only validator; 04:00Z and 04:14:59Z, identical) | fleet `3fb72615` | seven `W04` lines (S019, S020, S021, S022, S023, **S025, S026**) + `kagi ok …/corpus/SOURCES.md` | 0 |
| `git diff --numstat d218603 -- corpus/SOURCES.md <E1> <E3> corpus/README.md` | — | `9 0 corpus/SOURCES.md`; E1, E3 and README unchanged since base; 0 removed registry lines | 0 |

## 2. Findings

### F1 — operability, defect (fixed in the final bytes; a coverage gap remains): the supersession parse crashed the live gate, and the selftest could not see it

- vB `:229` `declare -A FURL=() FINROW=() FSEEN=() FDIG=() FNRM=()` has no
  `SUPERSEDED`, but `:242` still runs `SUPERSEDED[$fid]=1`. Under
  `set -uo pipefail` (`:107`), an undeclared array is indexed, so bash
  evaluates the subscript `S007` as an arithmetic variable name, and `set -u`
  aborts. S019 is the first `supersedes` row in file order, so `S007` is the id
  that fails.
- Exit 1 with no verdict line breaks the header contract `# VERDICT (last line,
  always):` (`:93`), and the exit code collides with FAILED.
- **The selftest is blind to it, reproduced.** The census's own
  `base_fixture()` and case table hold **0** `supersedes` tokens (C18,
  `awk '/^base_fixture\(\) \{/{f=1} f' | grep -c supersedes` → 0 on vF).
  - A1: vB on that fixture as built → `CLEAN (rows=4 …)`, exit 0.
  - A2: the same fixture plus **one** row
    `| S005 | Spec one, corrected — https://example.invalid/one | … | supersedes S001 — corrected reading. | mined | … | corpus/knowledge/e1.md |`,
    an e1.md cite and a provenance row → vB `line 242: S001: unbound variable`,
    exit 1.
  - A3: vC on the A2 fixture → `CLEAN (rows=5 …)`, exit 0.
- R21-03 (`corpus/claim-ledger.tsv:53`) pins only the selftest line, so it would
  have stayed green on vB. R21-02 (`:52`) expects CLEAN and would have failed.
  [INFERENCE: I ran neither ledger row.]
- In vF the parser is gone (`grep -c supersedes corpus/sources-census.sh` → 0).
  Remaining risk: any supersession logic added later will land untested until
  the fixture has a `supersedes` clean control.
- Independently observed by `RevS016.md` (its §on the crash, lines ~221-238).

### F2 — calibration/freshness, design boundary: the census never sees supersession

Each case is a vF copy with one or more changed bytes: changed-line counts were
6, 6, 1, 1, 1, 1. My helper's identity rewrite was byte-identical, and each
output was compared byte for byte with the baseline.

| case | mutation | census result |
|---|---|---|
| C03 | strip `supersedes Sxxx — ` from all six rows | CLEAN, **byte-identical to baseline** |
| C04 | retarget all six to nonexistent `S999` | identical |
| C05 | S025 `supersedes S025` (self) | identical |
| C06 | S026 (OpenBao tokens) `supersedes S001` (1Password CLI) | identical |
| C07 | S025 `supersedes S008` (a rejected row) | identical |
| C08 | cycle: prefix S014's teaches with `supersedes S025 — ` | identical |

The verdict does not change with the supersession graph at all. The census
header's stated bounds (vF `:67-69` legacy in-row pins; `:82-85` legacy entries)
say nothing about supersession. The lesson records it only as M23-2 routed debt
(`round-23.md:147`).

### F3 — freshness leak (live, no mutation): the active Vault/OpenBao entry cites only superseded or historical-pin rows

- E3 `:3` `source:` cites exactly S012, S013, S014, S015, S016. `:5` `recheck:`
  names S012/S013/S015/S016, and `:10` says "OpenBao claims cite S014–S016".
  `grep -c 'S025\|S026'` on E3 → **0**. E3 is unchanged since base (numstat
  above).
- **C19**: E3 ids ∩ `source-fetches.tsv` ids (S017–S026) = **∅** (overlap=0).
  Each E3 row is covered only by its in-row pin. The lesson itself says the
  S012/S013/S014/S016 pins match no tested representation (`round-23.md:111-114`)
  and that S015's matched none of 520 (`:115-117`).
- **C1**: delete only S016's in-row `Fetch sha256: \`c083fdca…\`` while S026's
  capture of the same URL stays → `FINDING SC_FETCH id=S016 missing-provenance`,
  `FAILED (findings=1 rows=26)`, exit 1. SC_FETCH coverage for a row that an
  active entry cites depends on the pin that S026 was added to supersede.
- S025/S026 are used only by `corpus/lessons/round-23.md` (`SOURCES.md:31-32`),
  and S022/S023 only by `corpus/lessons/round-22-source-errata.md` (`:28-29`).
  Lessons are outside SC_ENTRY_CITE, because the entry loop is
  `for f in "$kdir"/*.md` (vF `:290`). **C17**: running the round-23 lesson
  through the entry check gives 13 findings: `id=S008 status=rejected`, plus
  `used-by-omits-entry` for S014, S016 and S017–S026. `FAILED (findings=13 rows=26)`.
- E1 `:2` cites S006/S007, whose status/eligibility reading is superseded
  (`SOURCES.md:81`). E1 `:4` reads "on-release for S006–S007". Its corrected
  reading cites S017–S020 only in body brackets (`:41-63`). None of those ids is
  on E1's `source:` line, and none of those rows lists E1 in used-by.
- **Claims this contradicts:**
  - `LOG.md:1213-1215`: "only the declared captures in source-fetches.tsv are
    active provenance". False for E3, which resolves to zero declared captures.
  - `round-23.md:43`: "S025/S026 are the corrected active locators", and `:117-118`.
    True in the registry, not in E3, the only knowledge entry that uses those pages.
  - M23-2 (`round-23.md:147`) names the consumers of S012 and S018. It does not
    name E3 for this round's own S014→S025 / S016→S026 edges, or
    `corpus/README.md:78` ("SOURCES.md S012–S016").
- E3 `:7` says R21-02 "re-verifies the citation chain". Its CLEAN certifies
  S012–S016 as valid support and gives no supersession signal.

### F4 — leak path (mutation): a new active entry can adopt a superseded row

- **C09**: append `; S014 (https://openbao.org/docs/auth/jwt/, §JWT verification)`
  to `feature-bound-credential-review.md`'s `source:` line, and add that path to
  S014's used-by → **CLEAN, identical to baseline**.
- **C10** (control, used-by not extended) →
  `FINDING SC_ENTRY_CITE entry=corpus/knowledge/feature-bound-credential-review.md id=S014 used-by-omits-entry`.

The pairwise check works. Supersession is simply not one of its inputs.

### F5 — structural: the census plus the lane's immutability rule lock stale edges in place, and punish half-propagation

| case | edit | result |
|---|---|---|
| baseline | nothing | CLEAN |
| C11 | add S025 to E3's `source:` only | FAILED `SC_ENTRY_CITE entry=corpus/knowledge/vault-openbao-token-lease-lifecycle.md id=S025 used-by-omits-entry` |
| C12 | C11, plus E3 in S025's used-by | CLEAN |
| C13 | drop S014 from E3's `source:`; S014 row byte-identical | FAILED `SC_USEDBY_NOCITE id=S014 path=corpus/knowledge/vault-openbao-token-lease-lifecycle.md` |
| C14 | C13, plus S014 used-by `—` | FAILED `SC_MINED_UNUSED id=S014` |
| C15 | C13, plus S014 used-by `corpus/lessons/round-23.md` (its `source:` already cites S014) | CLEAN |

- Only two states have zero findings: no propagation, or full propagation.
- The lane's own rule that existing used-by fields never change rules out C15:
  `SOURCES.md:67` "No existing status/recheck/used-by field changed", and
  `:60-61` for round 23. That makes E3→S014/S016 (and E1→S006/S007) permanent
  active citations.
- Contract v1 is looser. Rule 2 (`SOURCES-CONTRACT-v1.md:49-51`) allows in-place
  `status`/`recheck`/`used-by` changes, logged old→new. The status enum has no
  `superseded` value (`:36-37`), so a superseded row can only stay `mined` with
  at least one consumer.

### F6 — reader routes still point at superseded rows, and nothing checks them

- `SOURCES.md:36` Path `S001 → S004 → S002 → S003 → S006 → S007`; `:38`
  `S012 → S013 → S014 → S015 → S016`.
- No Path names S024/S025/S026: `grep -n 'S02[456]' corpus/SOURCES.md` finds
  only the rows (`:30-32`) and the lead note (`:58`).
- **C16**: a Path `S999 → S014` (nonexistent, then superseded) → CLEAN,
  identical. Only the heading is checked (SC_SECTIONS).
- `corpus/README.md:76,78` index E1/E3 by "S001–S007" and "S012–S016".

### F7 — fleet gate (fleet-owned): the E04 waiver is an unvalidated substring

`scripts/sources-census.sh:646-648` waives E04 (same normalized URL and same
scope, both non-rejected) whenever `teaches !~ /supersedes S[0-9]{3}/` is false.
Test setup: on a vF copy, S025's scope set to S014's
(`OpenBao JWT/OIDC authentication and role claim validation`), then
`bash scripts/sources-census.sh validate <copy>`.

| case | S025 teaches | result |
|---|---|---|
| F02 | keeps `supersedes S014 —` | `ok`, exit 0; S025 also drops out of W04 |
| F03 | `supersedes S999 —` (nonexistent) | `ok`, exit 0 |
| F04 | `supersedes S025 —` (self) | `ok`, exit 0 |
| F06 | opening token removed; ` (cf. supersedes S999 elsewhere)` appended at the end | `ok`, exit 0 (the contract says the teaches *opens* with it) |
| F05 control | no token | `E04 S025 duplicate url openbao.org/docs/auth/jwt within scope …`, exit 1 |

`grep -r supersed scripts/fixtures` finds nothing, so the waiver has no fixture
case. With any `supersedes S###` string, a same-URL, same-scope duplicate gets
no signal from either gate.

### F8 — D1 count (corroborates RevW04's seat): seven W04 lines; the two unquoted ones are this round's supersession rows

- The fleet validate prints 7 W04 lines.
- `round-23.md:66` says "The census prints five W04 duplicate-URL warnings", and
  `:178-179` says "census at round end must exit 0 with the same W04 warnings and
  `rows=26`". Both are false at rows=26.
- The two lines not quoted verbatim are
  `W04 S025 duplicate url openbao.org/docs/auth/jwt across scopes` and
  `W04 S026 duplicate url openbao.org/docs/concepts/tokens across scopes`.
- `closure-dispositions.json` D1 is `fixed` ("quotes the five W04 … verbatim"),
  but this round's S025/S026 grew the obligation to seven lines.

### F9 — transient (vC only): the same-URL agreement rule rejected a content-change supersession

- On vC (`24d834cc`), a hypothetical `S027 … supersedes S026 —` at the same URL
  with a changed normalized digest →
  `FINDING SC_FETCH id=S027 same-url-normalized-disagreement url=https://openbao.org/docs/concepts/tokens/`,
  FAILED. With S026's digest → CLEAN rows=27.
- So the rule blocked recording exactly the change supersession exists for.
- vD/vF removed the rule (vF header `:64-66` "no cross-capture equality is
  enforced"). On vF, both variants → CLEAN rows=27.
- Not a live defect. Recorded because the wave saw both designs within four
  minutes, and any future agreement rule needs to know about supersession.

## 3. Confirmed (no defect)

- All six correction rows open with `supersedes S0NN —`, as contract rule 2
  requires (`SOURCES.md:25,26,28,29,31,32`). Against base the registry is
  append-only: 9 lines added, 0 removed.
- The pairwise used-by/cite checks behave as written. C10, C11, C13 and C14 each
  fail with the expected single finding, and C17 lists all 13.
- `corpus/feature-claims.json` does not bind S007's superseded reading. S007's
  bindings (`:54-60`) cover product/feature/path/eligibility.requirements, not
  release_status, which comes from S020. [Read only; `feature-claims.py` not run.]

## 4. Impacted axes

- **calibration**:
  - `LOG.md:1213-1215` and `round-23.md:43,117-118` overclaim what the
    superseding rows do for active knowledge.
  - `round-23.md:66,178-179` undercount W04 lines.
  - M23-2's consumer list is incomplete.
  - The census header has no supersession bound.
- **freshness**:
  - E3's provenance (the D7 subject) consists only of historical in-row pins,
    all found irreproducible.
  - The corrected locators cannot be reached from E3 or from any Path or README
    route.
  - The census cannot see supersession edges, missing ones included (F2, F5).
- **operability**:
  - The vB crash went past a green 59-case selftest. The bytes are fixed, but
    the fixture still has no `supersedes` row.
  - The gate and the lesson changed while the falsify wave was running.

## 5. Fixable defect vs. tradeoff

- **Fixable now, text only:**
  - correct `LOG.md:1213-1215`;
  - narrow `round-23.md:43/117-118`;
  - fix `round-23.md:66/178-179`: seven W04 lines, quote S025/S026;
  - complete the M23-2 consumer list;
  - add a census header STATED BOUND and a note on R21-02.
- **Fixable now, data, contract-legal, optional:** the C12 propagation. Put
  S025/S026 on E3's `source:` line and E3 in their used-by. S025/S026 are new
  this round, so setting their used-by before landing changes no existing
  field. Doing the same for S022/S023 is a rule-2 used-by change and needs an
  old→new line.
- **Tradeoff for the judge:** the lane's immutability rule, stricter than the
  contract, plus SC_USEDBY_NOCITE keep superseded rows as permanent active
  citations of E1/E3 (C13/C14). This is admissible only if the claim states it.
- **Not this lane's:** the fleet E04 waiver (F7). Route it to the fleet owner.
- **Reject condition:** if C2 is read as "the lane's active provenance is
  declared" (as `LOG.md:1215` says), that reading must be rejected; E3 is the
  counterexample. The narrower C2 survives: SC_FETCH shape/identity coverage of
  S017–S026 plus 16 bounded historical pins.

## 6. Smallest safe correction

1. **Bound (required).** State it in the census header, the R21-02 note and the
   lesson's `## Falsification bounds`:
   > Supersession is prose-only: `supersedes` is not parsed, and a CLEAN verdict
   > does not mean an active entry cites a superseding row or avoids a
   > superseded one. E3 cites S012–S016 only, each covered by a historical
   > in-row pin. S022–S026 are consumed only by lessons. Paths are not checked.

   In `LOG.md:1213-1215`, replace "only the declared captures … are active
   provenance" with "declared captures are the provenance of S017–S026; E1/E3
   still resolve to historical pins".
2. **D1.** Quote the S025/S026 W04 lines and say seven warnings at rows=26.
3. **Optional data** (shown CLEAN in C12): cite S025/S026 on E3's `source:` line
   and add E3 to their used-by.
4. **Next-round code (census):**
   - parse `^supersedes (S[0-9]{3,}) —`;
   - require the target to exist, differ from self, be an earlier row, and
     share the URL unless a different URL is declared;
   - count `superseded_cited=N` (entries citing a superseded id without its
     successor) in the verdict, or emit it as a finding;
   - selftest: one clean control with a `supersedes` row (this kills the vB
     class), plus unknown-target, self, cycle and stale-cite mutants.
5. **Next-round code (fleet):** anchor the E04 waiver to
   `^supersedes S[0-9]{3,} —` with a resolved earlier same-URL target, and add a
   fixture case.

## 7. Reproduction

1. Copy `corpus/{SOURCES.md,source-fetches.tsv,sources-census.sh,knowledge,lessons}`
   to a scratch root `R`. Run `bash R/corpus/sources-census.sh verify --root R`.
2. Registry edits change cells on the `| Sxxx |` line (split on `|`, 11 columns):
   - C03: delete the leading `supersedes Sxxx — ` from the teaches of S019,
     S020, S022, S023, S025 and S026.
   - C04: replace each `supersedes Sxxx` with `supersedes S999`.
   - C05: S025 → `supersedes S025`.
   - C06: S026 → `supersedes S001`.
   - C07: S025 → `supersedes S008`.
   - C08: prefix S014's teaches with `supersedes S025 — `.
   - C1: delete ``Fetch sha256: `c083fdca…`.`` from S016's teaches.
3. Entry edits change the column-1 `source:` line:
   - C09: append `; S014 (https://openbao.org/docs/auth/jwt/, §JWT verification)`
     to `feature-bound-credential-review.md`, and
     `, corpus/knowledge/feature-bound-credential-review.md` to S014's used-by.
   - C11: append `; S025 (https://openbao.org/docs/auth/jwt/, H1, rendered text)` to E3.
   - C12: C11, plus `, corpus/knowledge/vault-openbao-token-lease-lifecycle.md`
     in S025's used-by.
   - C13: delete `; S014 (https://openbao.org/docs/auth/jwt/, §JWT verification, §Bound claims, §Claims as metadata, OpenBao docs Version 2.7.x)` from E3.
   - C14: C13, plus S014 used-by `—`.
   - C15: C13, plus S014 used-by `corpus/lessons/round-23.md`.
4. Other edits:
   - C16: insert `- **bogus route** — S999 → S014: …` under `## Paths`.
   - C17: copy `lessons/round-23.md` to `knowledge/zz-round-23-lesson-as-entry.md`.
5. Fleet: on a copy `D`, set S025's scope cell to S014's, edit the teaches as in
   F02–F06, and run `bash scripts/sources-census.sh validate D`.
6. Selftest gap: extract `base_fixture()` from the census, build it, then add
   the A2 row, cite and provenance row described in F1.

## 8. Footprint and unrun checks

- Lane writes: this file only.
- Scratch: `/tmp/critsup.tWpPnS` held snapshots vB/vC/vD/vF, the scratch
  helper `mut.py` and two drivers. After the report was written,
  `rm -rf -- /tmp/critsup.tWpPnS` exited 0, then `test -e /tmp/critsup.tWpPnS`
  exited 1, and `ls -d /tmp/critsup.*` matched 0 entries.
- Installs: none. Network: none.
- Not run by this seat:
  - `corpus/closure-dispositions.py`;
  - any `corpus/claim-ledger.sh` row, including R21-02/R21-03;
  - `corpus/feature-claims.py`;
  - any page re-fetch;
  - the parent's 43 claim-row audits.
