# ConnSourcesCensus — kagi round 28 sibling-overlap + W04/E04 scan

Scope: read-only scan of `/home/vgpnk/Projects/shokunin/scripts/sources-census.sh` (fleet W04
rule) against kagi's registry and every sibling `corpus/SOURCES.md`; all runs used sandbox copies
under `.ufo/waves/round-28/sandboxes/ConnSourcesCensus/`, no lane file written.

Revisions read: fleet root `/home/vgpnk/Projects/shokunin` `c2e2913dcfabe58fbb0b678594b7a4ff69604487`;
kagi BASE `3553d499577084a6c98d7078906017840bbf7b28`, worktree `b9a42c0e947648ad9f3cf0245784fcb08dc1a442`
(diff BASE..HEAD over `corpus/SOURCES.md`, `corpus/release-clock.py`, `corpus/release-clocks.tsv` is
empty — bytes cited are BASE bytes); kengaku `56fd949a6478342531e61f4feecb4a685d831640`; kake `e28312b14b076584fedd696fae2a684e460bd11e`.

## Findings

F1. **W04/E04 are intra-registry; cross-lane URL reuse emits neither.** `row_pass` is invoked
    once per lane file (`scripts/sources-census.sh:717`); `url_seen`/`url_scopes`
    (`:643-655`) are gawk locals of that invocation. Cross-lane duplication is only the
    `shared` mode's advisory `url<TAB>shared<TAB>lane,…` rows (`:779-797`), which never set
    `findings` and never change exit (`:799-803`). A kagi row on a sibling's URL cannot
    produce W04 or E04.
F2. **The 11 START warnings are in-lane successor rows, not sibling overlap**
    (`.ufo/waves/round-28/census-start.txt:2-12`), each a second+ scope for a URL already in
    kagi: S019:25→S007:13, S020:26→S006:12, S021:27→S016:22, S022:28→S012:18,
    S023:29→S013:19, S025:31→S014:20, S026:32→S016:22, S032:38→S007:13, S039:46→S036:42,
    S040:47→S027:33, S041:48→S028:34 (all `corpus/SOURCES.md`). This successor-row pattern,
    not in-place editing, is the lane's 11-row prior art.
F3. **True cross-lane overlap at BASE is exactly two URLs** (`shared --root <fleet>` over the
    live fleet, exit 0; 28 shared URLs fleet-wide, kagi in two):
    - `docs.python.org/3/library/re.html` — kagi S027:33 + S040:47 ↔ kengaku `S046:68`.
    - `html.spec.whatwg.org/multipage/syntax.html` — kagi S031:37 ↔ kake `S030:38`.
    No sibling registry contains any 1Password, getsops, openbao, developer.hashicorp or
    curl.se URL at all (host scan, exit 1 = no match); kagi's domain sources are fleet-unique.
    S042 (`semver.org/spec/v2.0.0.html`, :49) and S043 (`packaging.python.org/…/version-specifiers`,
    :50) are held by **no** other lane, so a kagi row on either stays unshared even after landing.
F4. **New row on an S042/S043 URL** (fixtures at `sandbox …/exp/*`, all against the BASE
    registry shape; exit codes observed):
    | candidate row | result | exit |
    |---|---|---|
    | fresh URL (`stdtypes.html`, control) | `ok` | 0 |
    | S042 URL, **new** scope | `W04 S044 … across scopes` | 0 |
    | S042 URL, **S042's** scope | `E04 … within scope` | 1 |
    | same scope + teaches `supersedes S042` | `ok` | 0 |
    | same scope + teaches `supersedes S999` (no S999 exists) | `ok` | 0 |
    | same scope, status `rejected` | `ok` | 0 |
    | new scope, status `rejected` | `W04` (warnings fire on rejected rows too) | 0 |
    | S043 URL, S043's scope | `E04` | 1 |
    | S042 URL + `/#item-11` fragment, new scope | `W04` (fragment stripped) | 0 |
    So: **new scope = warning, same scope = hard duplicate error**; the only exception is the
    textual `supersedes S[0-9]{3}` token in `teaches` (`:646-649`). A `rejected` row is exempt
    from E04 but never from W04.
F5. **The E04 escape is unvalidated and brittle.** `teaches !~ /supersedes S[0-9]{3}/` is
    case-sensitive and needs ≥3 digits: `Supersedes S042` and `supersedes S42` both still E04
    (proven, exit 1), while `supersedes S999` — a nonexistent id — passes (exit 0). The escape
    also does not flip the superseded row's status; both rows stay live for the same URL.
F6. **The dedupe key is the URL string, so it is evadable by path case and mirrors.**
    `url_of` (`:600-608`) lowercases only the host, strips fragment and one trailing slash.
    `https://semver.org/Spec/v2.0.0.html` on the same scope produced `ok`, exit 0 (bypass);
    a mirror host would likewise be invisible to both `validate` and `shared`. Fragments do
    not bypass in-lane (tested), yet differing fragments on one page **do** merge in `shared`
    across lanes (`exp/fleet2`, exit 0) — a stdtypes registration would add a fleet-shared URL with souji `S061:81`.
F7. **Cost of the round's mandatory new registry row** (BASE sandbox copy + one S044 row):
    kagi's own gate has **no URL dedupe** at all — only id duplication
    (`corpus/sources-census.sh:187-189`) — but every row needs capture provenance
    (`SC_FETCH … missing-provenance`, `:328`; 16-field `source-fetches.tsv` row including a
    row-identity sha256 over `id\tstatus\tURL`) and a mined row needs its used-by file to
    exist and cite the id (`:229-231`). Observed on the copy with a realistic S044:
    `SC_USEDBY_MISSING path=corpus/lessons/round-28.md` + `SC_FETCH id=S044 missing-provenance`,
    exit 1; fleet `validate` on the same copy stayed at **11 W04** and added only
    `E11 S044 missing used-by …`, exit 1. Adding any row also breaks the pinned verdict line
    `corpus/claim-ledger.tsv:52` (R21-02, `rows=43 A=41 … mined=39 … captures=43`), which the
    lane migrates per round (`.ufo/waves/round-27/expectation-migrations.json`, R21-02 old→new;
    round-27 moved 41→43). No doc pins the SOURCES row count (`self-counts.tsv` has no
    `rows:corpus/SOURCES.md` entry), so SKILL/PROVINCE/README need no count edit.

## Contradiction (stated, not smoothed)

`plans/round-28.md:21-22` cites the leading-zero rule as “SemVer S042 §2”, but S042's registered
anchor is §11.2 and its `teaches` says “only the numeric core ordering is used”
(`corpus/SOURCES.md:49`). No gate detects anchor-scope overclaim: W04/E04 compare URL+scope only,
and kagi's SC_ENTRY_CITE checks id/status/used-by/tier, not anchor coverage. Under the round's own
C2 logic (declared value bound to its pinned source), §2 is currently unbound. Editing S042's
scope in place would be invisible to every gate (the R21-02 verdict carries counts, not scope
text) but contradicts the lane's 11 successor-row precedents.

## Proposed move (one, bounded)

Register the mandatory Python-int-limit row as a **new** row on a fleet-fresh URL
(`docs.python.org/3/library/sys.html#sys.set_int_max_str_digits` or `…/functions.html#int`;
`stdtypes.html#…` is also fresh in-lane but adds a new fleet-shared URL with souji S061:81 —
advisory only, exit 0), and bind §2 with a **successor** row on `semver.org/spec/v2.0.0.html`
under a §2-specific scope with a located quote — the pattern S019/S020/S022/S023/S025/S026/
S032/S039-S041 already establish — rather than extending S042's historical scope or writing
`supersedes S042`. Cost: +1 W04 (11→12, exit 0), one capture per new row, and an R21-02 rebind
(`rows=45 A=43 B=0 C=2 queued=1 mined=41 rejected=3 entries_sourced=4 legacy=21 captures=45 …`
if both are mined) recorded in a round-28 expectation-migration file, following round 27.
If L1 deliberately keeps one row, the lesson must declare §2 a same-page **unregistered**
anchor (an explicit limit), not present it as S042 coverage.

Risks: the END census W04 count rises (a reviewer may read 11→12 as regression; it is not a
failure); the claim-ledger rebind is the concrete break point (`verify` exits 1 until migrated);
a `queued` row still needs a capture (SC_FETCH covers every status) but postpones E11/SC_MINED_UNUSED
until the lesson lands — row and lesson land together either way.

## Commands run (exit codes)

- `git rev-parse`/`git log`/`git status` on fleet, kagi, kengaku, kake (0).
- `scripts/sources-census.sh validate --today 2026-10-21 --file <BASE copy>/corpus/SOURCES.md` → 11 W04 + `ok`, **0** (same 11 W04 lines as census-start.txt:2-12; only the lane label differs, `file` under `--file`).
- `scripts/sources-census.sh shared --root <fleet> --out …` → **0**; 28 shared URLs, kagi in 2.
- Nine fixture validates (`exp/*`) → exits as in F4; `exp/case-supersedes` (`Supersedes S042`, `supersedes S42`) → two E04, **1**.
- `shared`/`validate` on `exp/fleet` and `exp/fleet2` (cross-lane same URL; different fragments) → **0**, **0**, **0**, **0**.
- `bash corpus/sources-census.sh verify --root <BASE sandbox>` → `SOURCES_CENSUS: CLEAN (rows=43 … captures=43 …)`, **0**; on the +S044 copy → `FAILED (findings=2 rows=44)`, **1**.
- `scripts/sources-census.sh validate --file <+S044 copy>` → 11 W04 + `E11 S044`, **1**.
- Row-URL mapping (awk re-implementation of `url_of`) → F2 mapping; host scan over siblings → no match, **1**.

## Not checked

No network fetch of any candidate document (stdtypes/functions/sys/semver §2 text unverified
here; the build wave owns capture). No run of any kagi lane gate in the lane checkout (sandbox
copies only), no `release-clock.py` execution, no claim-ledger verify after a rebind, no edit of
any production or sibling file, no check of other lanes' W04 counts, no non-gawk awk. No tools
installed or upgraded.
