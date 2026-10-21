# SrcPythonVersions — `https://devguide.python.org/versions/` (round-27 C2 source curation)

**Decision: ADMIT tier A for a narrow CPython branch/phase scope. REJECT the page as grounding for the `REGRESSED` rule itself.** The page is the primary source for the process facts behind *why a python.org feed can legitimately carry an older-series release dated after the newest version* (concurrent bugfix/security branches; a per-version latest release, Q4), and for what CPython calls a "stable release". The date-order consequence is an inference (Section 3.7), not a page sentence. It contains **no** version-precedence, feed-completeness, monotonicity, yank or rollback statement. Numeric core ordering remains S042/S043. The page also supports one wording correction: an older-series maintenance release **is** a release event; what it is not is a *newer-stable clock event*.

Frozen BASE `0a47dd189356ea66ec83c3891eed54526e95b89b`. Working tree was dirty with L1's C2 draft when read (2026-10-21T15:16–15:22Z); working-tree line numbers are labelled and may move. No registry, `source-fetches.tsv`, knowledge or production write. No build, selftest, linter or formatter was run.

## 1. Fetch record

| field | value |
|---|---|
| URL | `https://devguide.python.org/versions/` |
| final URL | same (no redirect) |
| access (UTC) | `2026-10-21T15:17:31Z` |
| HTTP status | `200` |
| profile | `curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)'` |
| content-type / encoding | `text/html; charset=utf-8` / `gzip` |
| `Last-Modified` | `Tue, 20 Oct 2026 18:09:28 GMT` |
| `ETag` | `"814ea99f9d62b69f72dd8e8d8e68482c"` |
| compressed download | 15,393 bytes |
| decoded body | 125,309 bytes; sha256 `a862729c9dc1b8c23c75dd3f4b4b57f5603bcf45b8b325494fe789483339380e` |
| rendered-text-v1 | sha256 `5495a03730d528be83d22d2614d7715e754a2ff0961fe3106506e86fccb90b71`, 5,639 bytes |
| page-displayed date | footer `Last updated on May 27, 2026` — earlier than the served table's `3.15` first release (`2026-10-09`), so it is not the content revision; it also differs from the HTTP `Last-Modified` |
| revision | none displayed; "Edit this page" targets `https://github.com/python/devguide/edit/main/versions.rst`, i.e. unpinned `main` |

Reproduction: a first, identity-encoded fetch at `2026-10-21T15:16:19Z` also returned `200` and the **same decoded sha256** `a862729c…`; only the compressed byte count and the weak/strong `ETag` form differed. So the body digest is representation-independent across those two fetches; the page can still change without any displayed revision.

Artifacts (this seat only): `.ufo/waves/round-27/build/SrcPythonVersions.profile.body`, `.profile.headers`, `.normalized.txt`, `.fetch.json`.

**Anchor consequence:** anchor by HTTP `Last-Modified` + fetch date + sha256, never by the footer date. `[INFERENCE]` The footer is consistent with a generated table whose `versions.rst` source file last changed in May while the table data is rebuilt on each release; the page itself does not say this.

## 2. Located quotes (rendered-text-v1)

Command (per quote): `python3 corpus/rendered-text-v1.py locate <body> "<quote>"`; normalizer declaration at `corpus/rendered-text-v1.py:110` (BASE). All counts below are 1; the machine record is in `SrcPythonVersions.fetch.json`.

| # | quote | tokens | section / anchor | carries |
|---|---|---|---|---|
| Q1 | “Once a version has been fully released, bug fixes and security fixes are accepted. New binaries are built and released roughly every two months.” | 24 | `#status-key` → `bugfix` | the bugfix phase ships binaries on a roughly two-month cadence, per released version |
| Q2 | “This phase is also called maintenance mode or stable release.” | 10 | `#status-key` → `bugfix` | CPython's own use of “stable release” = the bugfix phase |
| Q3 | “only security fixes are accepted and no more binaries are released. New source-only versions can be released as needed.” | 19 | `#status-key` → `security` | security-only branches still publish source releases |
| Q4 | “The latest release for each Python version can be found on the download page .” | 15 | `#status-of-python-versions` (intro) | per-version latest, **not** one global newest-stable. The detached ` .` is the rendered-text-v1 tag→space artefact; the spaced form is the one that locates |
| Q5 | “Release managers can adjust specific dates as needed.” | 8 | `#status-key` (intro) | schedules are not release identities |
| Q6 | “Dates shown in italic are scheduled and can be adjusted.” | 10 | `#supported-versions` | same, for the table |
| Q7 | “The main branch is currently the future Python 3.16, and is the only branch that accepts new features.” | 18 | `#status-of-python-versions` (intro) | 3.16 is future, not released |

Q1 is the proposed row's primary quote (24 ≤ 25 tokens). Q2 is the second, 10 tokens.

## 3. What the page supports

`[OBSERVED]` on the served page unless marked otherwise; section anchors are real IDs in the body (`#status-key`, `#supported-versions`, `#full-chart`).

1. **Concurrent branches in different phases.** `#supported-versions`: `3.15` and `3.14` are `bugfix`, `3.13`/`3.12`/`3.11` are `security`, `main` is `feature` (future 3.16). Three security branches and two bugfix branches are live at once.
2. **Per-version latest, not a global latest.** Q4 says each Python version's latest release is on the download page; the same table gives each branch its own first-release/EOL/release-manager row. The page itself does not publish those latest versions.
3. **“Stable” is the bugfix phase.** Q2; this is the page's only use of the word `stable` (sweep below: 1 hit).
4. **Security branches still release.** Q3: source-only releases “as needed”; the phrase `source-only` occurs once.
5. **Schedules are adjustable, not identities.** Q5/Q6.
6. **The table is current at access.** Two-point cross-check against the round-26 Python feed capture: table `3.15` first release `2026-10-09` matches `Python 3.15.0` pubDate `Fri, 09 Oct 2026 13:54:59 +0000`; table `3.10` end-of-life `2026-10-01` matches `Python 3.10.22` pubDate `Thu, 01 Oct 2026 01:19:11 +0000`. `[INFERENCE]` This supports currency of those rows; it is not a row-by-row verification.
7. **`[INFERENCE]` An older-series release can be the newest-dated item.** With two bugfix branches shipping binaries every ~2 months and security branches releasing “as needed” (1–4), a feed ordered by publication time can legitimately show `3.14.9` above `3.15.1`. The page does not state that date-order consequence; the feed capture does (below).

## 4. What the page does NOT support

Absence sweep over the rendered-text-v1 body (needle → lower-cased substring count; command and full result in `SrcPythonVersions.fetch.json`):

| needle | count | needle | count |
|---|---:|---|---:|
| `preceden` | 0 | `monoton` | 0 |
| `numeric` | 0 | `rollback` | 0 |
| `greater` | 0 | `yank` | 0 |
| `newer` | 0 | `withdraw` | 0 |
| `feed` | 0 | `stable` | 1 |
| `alpha` | 0 | `release candidate` | 0 |

Therefore, for the rule “an observed newest-stable release numerically below the anchored X.Y.Z is a regression finding, not a release event”:

- **Not supported: numeric precedence.** Zero statements about numeric comparison, ordering, or “greater”; `newer` is 0, and the lone `older` hit is the chart caption “See below for a chart with older versions”, not a precedence statement. That is S042 §11.2 and S043; this page cannot be cited for it.
- **Not supported: feed semantics.** Zero mentions of a feed, its completeness, monotonicity, rollback, or a newest-stable aggregate.
- **Not supported: the word “newest stable” as a global.** The page publishes a latest release *per version* (Q4); a global max is the lane's parser construct, not a CPython statement. Attributing “newest stable = 3.15.1” to this page would be a category error.
- **Not supported: a definition of backport.** The sole `backport` hit is the closing see-also, “more information about branches and backporting”; the page does not say an older-series release can be newer-dated. That step is the Section 3.7 inference plus the S039 capture, not a page sentence.
- **Not supported: yank/withdrawal.** Zero mentions. The page cannot ground any rule for a yanked or removed release.
- **Not supported: PEP 440 suffix parsing.** The page defines a `prerelease` *phase* (after the first beta, before the full release) and says “beta”, but never mentions `alpha`, `rc`/“release candidate”, or suffix precedence. The parser's `STABLE_TITLE_RE` (`corpus/release-clock.py:649`, BASE) is the mechanism; S043 is the spelling authority.
- **Not supported: an installed-runtime claim.** The page is a status table, not a probe of the host interpreter (same QA3 limit round 26 recorded for the Python docs).
- **Not usable as a revision pin.** No displayed commit/version; the footer date is earlier than the served content (Section 1).

## 5. Fit to the C2 rule, case by case

Rule under construction (working tree, re-read 2026-10-21T15:27Z, uncommitted; line numbers may move again): `corpus/release-clock.py:383-388` (`is_regression`: both strict X.Y.Z, `seen < floor`), `:390-410` (`feed_floors`: highest numeric anchor per feed URL), `:567-578` (evaluate adds `REGRESSED` against the row anchor or the feed floor), `:793-795` (`--observe` types `regressed` against the anchor or the previous observation). At BASE the mechanism does not exist: `git show HEAD:corpus/release-clock.py | grep -c REGRESSED` → `0`; `… | grep -c is_regression` → `0`. BASE instead types any non-equal observation `fired`: `corpus/release-clock.py:726-734`, accepted at `:524`. So the "before" defect is real and the row's job is to describe the premise, not to replace S042/S043.

### 5.1 Older-series / backport (the live Python case)

Real capture, not a hypothetical: `.ufo/waves/round-26/captures/S039.body` (sha256 `11c86a34…`, matching `corpus/source-fetches.tsv:82`) is ordered:

| item | pubDate (UTC) |
|---|---|
| Python 3.14.9 | Wed, 21 Oct 2026 13:08:09 |
| Python 3.15.1 | Wed, 21 Oct 2026 09:59:50 |
| Python 3.16.0a1 | Tue, 13 Oct 2026 19:02:12 |
| Python 3.11.17 | Thu, 01 Oct 2026 01:19:41 |
| Python 3.10.22 | Thu, 01 Oct 2026 01:19:11 |
| Python 3.12.15 | Wed, 30 Sep 2026 22:23:24 |

The newest-dated item (`3.14.9`) is **numerically below** the anchor `3.15.1`; `3.11.17` is a security-branch release below it; `3.10.22` is the EOL release. Round 26's M26-2 (`corpus/lessons/round-26.md:91`) already records the consequence: the max stable is `3.15.1`, and a first-entry reading must fail.

**What this supports:** “observed newest-stable” must be the max over stable entries, not the first entry. A correct, uncropped feed can have a below-anchor item at the top of the date order. The page explains why (Section 3).

**What it refutes — wording only:** a `3.14.9` release published after `3.15.1` is a **release event**. The working-tree comment at `corpus/release-clock.py:571-572` says such an observation is “a stale, cropped or withdrawn stream to re-verify, never a release event”. The “re-verify” framing is honest; “never a release event” overstates: `3.14.9` *is* a release; the clock must simply not fire. The rule's correct claim is “never a **newer-stable clock** event” / “never an un-fire”. `corpus/lessons/round-27.md:27` already states the honest version (“a typed stop for re-verification, not a claim that the vendor rolled back”); the code comment should say the same. `PROVINCE.md:54` (“never fired/CLEAN”) is already accurate.

**Cropped-feed cause:** if a consumer reads only the first item, `3.14.9 < 3.15.1` → `REGRESSED`. That is a true feed-completeness finding and exactly the stop the rule wants. The page supports “cropped” as a plausible cause (per-version latest + concurrent branches); it does **not** support “stale”, “withdrawn” or “rolled back” as diagnoses. Those remain inference, and the finding must not assert them.

### 5.2 Prerelease

`3.16.0a1` is numerically **above** `3.15.1` in its core (`3.16.0`) but is not a full release. If the parser admitted it, the clock would falsely **fire**, not regress. The page supports the phase distinction (prerelease is before the full release; 3.16 is `feature` with first release `2027-10-06`), but it does not define suffix spelling or feed inclusion. Mechanically, `STABLE_TITLE_RE` at BASE `corpus/release-clock.py:649` rejects the suffix; the working-tree downgrade fixture includes `v1.2.3-rc1` above `v1.2.2` and expects `regressed` (`corpus/release-clock.py:1435`, `:1440-1443`). The same capture also carries `Python 3.15.0rc3` and the non-CPython `Python install manager 26.4`; the page is silent on both, and the regex excludes them by shape (suffix / two components). Those exclusions are parser facts at `:649`, not claims this page supports. `is_regression` itself is **silent** on prereleases: `numeric_version("3.16.0a1")` returns `None`, so a prerelease observation cannot be typed `REGRESSED`. Enforcement comes from the parser + receipt equality, not from the regression predicate. The page cannot strengthen that; do not cite it for suffix handling.

### 5.3 Yank / withdrawal

The page is silent (0 hits). A yank that removes the newest release from a feed makes the observed max fall below the anchor — indistinguishable, from this source, from cropping. S042's own rejection row (`corpus/lessons/round-27.md:27`) already says an ordering spec does not prove feed completeness or that a vendor never yanks. Keep `REGRESSED` as a stop; do not claim “vendor rolled back”. PEP 592 (PyPI yank semantics) was **not opened** this round and is not evidence here; the flip is a vendor/PEP statement scoped to the actual feed.

### 5.4 Anchor ahead of any release (scheduled/future version)

The page shows `3.16` is `feature`, first release `2027-10-06`, and says dates are adjustable (Q5/Q6). An anchor `3.16.0` against a current `3.15.1` observation would type `REGRESSED` — correct as “not a fire”, wrong as “stale feed”: the anchor names an unreleased version. The same class already exists at BASE: `corpus/SOURCES.md:35` names “curl 8.23.1 man page”, while `corpus/release-clocks.tsv:26` anchors the released `8.23.0` with a `derived:` note explaining that `8.23.1` is curl's development label. The rule therefore depends on the operational convention **anchors name observed releases**, which nothing in `is_regression` enforces. Recommendation: state that convention in the lesson, or rename the finding's prose to “anchor ahead **or** feed behind”; do not let the comment assert a cause.

### 5.5 Branch-label anchors (X.Y)

The page's own notation is `3.15`, `3.14`, `3.13` (branch, not version). `numeric_version` only accepts strict `X.Y.Z` (`corpus/release-clock.py:369-380`, working tree), so a row whose `anchored_version` is copied as `3.15` is **non-numeric**: `is_regression(anchored, …)` is False, and without more the row's `fired` verdict would be accepted by the inequality branch (`:581-583`) on an observed `3.14.9`. The current working tree mostly closes this: `feed_floors` (`:390-410`) takes the highest numeric anchor per feed URL, and evaluate also tests `is_regression(floors.get(feed_url, ""), observed)` (`:567-578`). On the python.org feed the floor is `3.15.1` (S040/S041), so an observed `3.14.9` is `REGRESSED` even when the row's own anchor is `3.15`; the selftest `feed floor lifts non-numeric anchor` (`:1080-1086`) pins that. The remaining declared limit is a non-numeric anchor on a feed with **no** numeric anchor (or a row with a unique `feed_url`): there the inequality rule survives. Mitigation: when anchoring from this table, still expand the branch label to a specific `X.Y.Z` release from the feed, as S040/S041 did with `3.15.1` (`corpus/release-clocks.tsv:30-31`); the floor is a safety net, not a branch-release identity. **Cross-branch floor trap (concrete):** on the python.org feed the floor is `3.15.1`, so a future row anchored on the `3.11` security branch and hand-binding a branch-scoped observation of a real `3.11.20` (or using a branch-scoped feed) would be typed `REGRESSED` by `is_regression(3.15.1, 3.11.20)` even though a 3.11 release occurred. The floor is sound only while every row's `observed_version` is the feed's **global** max-stable (what `parse_latest_version` produces); a branch-scoped row needs a branch-scoped observation, which this feed does not provide. The page's per-branch table is the evidence that multiple active branches coexist, and the S039 capture already carries `3.11.17`, `3.12.15`, `3.14.9` and `3.15.1`. No current lane row has that shape (the Python rows anchor `3.15.x`), but the trap is concrete and should be a named limit or a test, not left to the reader.

## 6. Proposed `corpus/SOURCES.md` row (id TBD)

`id` is TBD; in the working tree S042/S043 already occupy the next two identifiers, so the next free is **S044**, shown below. Replace the id cell if L1 assigns differently — the census's row regex accepts only `S` + digits, so a literal `(TBD)` suffix would be skipped or malformed. If the id is S044, `row_identity_sha256` is `1897eb0aba2fc3e3744cfe905cd17a90922b84a712e14dc9aff7f7cb3c2955a6` (sha256 of `S044<TAB>mined<TAB>https://devguide.python.org/versions/<LF>`, formula re-verified against the pinned S042/S039 rows); recompute for any other id. Proposed cells:

```
| S044 | Status of Python versions — https://devguide.python.org/versions/ | docs | A | CPython 3.11–3.16 branch status and release-phase definitions for the python.org feed rows, and this row is tier A for that scope only; excludes version precedence, feed completeness/monotonicity, yank/withdrawal/rollback, branch-scoped release identity and installed-runtime claims | §Status key → bugfix and §Supported/§Unsupported versions tables; served page displays no version or commit (edit link targets devguide `main/versions.rst`), HTTP Last-Modified 2026-10-20T18:09:28Z while the footer says “Last updated on May 27, 2026”; fetched 2026-10-21 | Several branches are live at once — 3.15 and 3.14 bugfix, 3.13–3.11 security, 3.16 feature — and the page points each version at its own latest release on the download page, so an older-series item can be newest-dated while the page publishes no global newest-stable. The bugfix phase is “also called maintenance mode or stable release”. Quotes: “Once a version has been fully released, bug fixes and security fixes are accepted. New binaries are built and released roughly every two months.” (§Status key, bugfix; 24 tokens; located once); “This phase is also called maintenance mode or stable release.” (same section; 10 tokens; located once). NOT: numeric precedence (0 hits for `preceden`/`numeric`), feed order or completeness (0 for `feed`), yank/rollback (0 each), PEP 440 suffix spelling, or an installed-runtime claim. | mined | 2026-10-21 | 90d | corpus/lessons/round-27.md |
```

Mechanical notes for integration:

- **Recheck `90d`, not `on-release`.** A new source with `recheck: on-release` enters `evaluate`'s `on_release` set; it would need exactly one `corpus/release-clocks.tsv` row or fail `UNBOUND`, and the pinned round-26 receipt would lack it (`NOT OBSERVED`). That would break the “live default receipt still CLEAN30” acceptance unless L1 adds a clock row and a new receipt. `90d` keeps the default population unchanged.
- **`corpus/source-fetches.tsv` values** (16-column contract documented at `corpus/source-fetches.tsv:6-35`; S042 is the row template at `:85`, in column order id/status/identity/url/final/http_status/profile/fetched/representation/sha256/bytes/revision/quote/normalization/normalized-sha/location): status `mined`; url and final `https://devguide.python.org/versions/`; HTTP `200`; profile `curl-fsSL-compressed-v1`; fetched `2026-10-21`; representation `decoded-http-body-volatile-v1`; body sha256 `a862729c9dc1b8c23c75dd3f4b4b57f5603bcf45b8b325494fe789483339380e`; bytes `125309`; revision `-` (no commit displayed; the registered URL has no `/main/` path segment, so `SC_FETCH`'s moving-ref revision rule does not fire even though the page's edit link targets `main`); quote Q1; normalization `rendered-text-v1`; normalized sha256 `5495a03730d528be83d22d2614d7715e754a2ff0961fe3106506e86fccb90b71`; location `#status-key (bugfix)`.
- **Census mechanics:** `corpus/sources-census.sh` `SC_ENUM` requires the tier cell to be exactly `A`/`B`/`C` — the scoping lives in the scope/teaches cells, not the tier cell; `SC_FETCH` needs the source-fetches row above; `SC_USEDBY_NOCITE` needs `corpus/lessons/round-27.md`'s column-1 `source:` line to list the assigned id (it currently says `S042, S043`); `SC_USEDBY_MISSING` needs the used-by path to be exactly `corpus/lessons/round-27.md`; `SC_INFLATION` is satisfied because devguide is official Python documentation, not a `community` row.
- **Search-log line if admitted:** the round-27 question must name the feed-order premise, not only numeric precedence. Proposed: “Question — numeric precedence plus the release-process premise that concurrent CPython branches can date an older-series release after a newer one. Identified 3 URLs, screened 3, included 3 (S042–S044), excluded 0; rejected inference: the devguide page does not order versions or prove feed completeness.” The existing working-tree log says 2 identified/2 included; adding S044 changes those counts, so L1 must edit the log in the same commit. Counts here are proposed, not measured by this seat.
- **Tier reading:** A only for the branch/phase scope. If anyone cites this page for ordering or feed behavior, the tier is C (lead) and it cannot stand alone.

**If L1 declines the row:** rejection with flip — “REJECT as grounding for `REGRESSED`; flip: a CPython release-process statement that the downloads feed is complete and monotonic across branches, or that a release numbered below an already-published release cannot be published later. This page states the opposite structure (concurrent branches releasing independently), so such a statement would have to supersede it.” The round's ordering authority stays S042/S043 either way.

## 7. Rejected inferences

| inference | verdict | flip |
|---|---|---|
| This page grounds the numeric `REGRESSED` rule | REJECT (QA1 scope / QA3): 0 `preceden`/`numeric`/`greater`/`newer` hits; the one `older` is the chart caption | A precedence spec (already S042 §11.2 / S043); no CPython-specific ordering claim needed |
| This page proves a below-anchor observation is “not a release event” | REJECT as written: `3.14.9` and `3.11.17` are real releases below `3.15.1` | A source statement that the observed version was never released; the page shows the opposite, so the wording must narrow to “not a newer-stable clock event” |
| This page proves a feed is complete, monotonic, or never yanked | REJECT: 0 `feed`, `monoton`, `yank`, `rollback`, `withdraw` hits | A vendor feed-completeness/yank statement scoped to that feed; PEP 592 for PyPI yank semantics if a Python row ever needs it |
| This page gives a revision to pin | REJECT: no commit; footer date is earlier than the served table | HTTP `Last-Modified` + fetch date + body sha256 as a point observation |

## 8. What I did NOT check (unrun ≠ pass)

- Did **not** fetch `python.org/downloads` or its RSS this round. The only URL opened is `https://devguide.python.org/versions/`. The S039 feed facts above are a re-read of the round-26 capture (`.ufo/waves/round-26/captures/S039.body`, sha256 matches `corpus/source-fetches.tsv:82`), not a live request from this seat.
- Did **not** read PEP 602, the devguide "Development cycle" page, `versions.rst`, PEP 440, or PEP 592; the page points at the first two and this seat did not open them.
- Did **not** run `corpus/release-clock.py` in any mode: no `--selftest`, no `--observe`, no downgrade fixture, no gate. The `REGRESSED` behaviour described is read from source, not executed.
- Did **not** test the X.Y branch-label failure mode against the evaluator; it is read from `numeric_version`/`is_regression` only.
- Did **not** verify whether python.org removes yanked releases from its RSS, or how the feed's generator orders entries across branches.
- Did **not** verify the page's generated-table provenance or its Git history; no commit is displayed, and I did not open the GitHub `main/versions.rst` link.
- Did **not** check Vault/OpenBao/SOPS/curl branch models; this page is CPython-only and the rule is applied to those feeds by numeric core only.
- Did **not** write `corpus/SOURCES.md`, `corpus/source-fetches.tsv`, `corpus/release-clocks.tsv`, `corpus/lessons/round-27.md`, or any production file. Id assignment, row identity hash and the CLEAN30 decision are L1's.

## 9. Base pins used

| claim | pin at BASE `0a47dd1` |
|---|---|
| feed parser takes the max stable X.Y.Z, not the first entry | `corpus/release-clock.py:649-699` (regex `:649`, `parse_latest_version` `:654`, `return max` `:699`) |
| BASE types any non-equal observation `fired` | `corpus/release-clock.py:726-734`; accepted at `:524` |
| BASE has no regression predicate | `git show HEAD:corpus/release-clock.py \| grep -c REGRESSED` → 0; same for `is_regression` |
| Python clock anchors | `corpus/release-clocks.tsv:24-25` (S027/S028 fired at 3.15.0), `:30-31` (S040/S041 not-fired at 3.15.1) |
| curl development-label precedent | `corpus/SOURCES.md:35` (S029 anchor names 8.23.1), `corpus/release-clocks.tsv:26` (clock anchored 8.23.0, `derived:`) |
| Python feed identity rows | `corpus/SOURCES.md:42` (S036), `:46` (S039); `corpus/source-fetches.tsv:82` (S039 capture digest) |
| first-item counterexample | `corpus/lessons/round-26.md:91` (M26-2); chronology `:131-132` |
| quote locator | `corpus/rendered-text-v1.py:110` |
| working-tree rule (uncommitted, read 2026-10-21T15:27Z) | `corpus/release-clock.py:383-388` (`is_regression`), `:390-410` (`feed_floors`), `:567-578` (evaluate `REGRESSED`), `:793-795` (`--observe` `regressed`); fixtures `:1073-1087` (feed floor), `:1435`, `:1440-1443` (rc above downgrade); lesson `corpus/lessons/round-27.md:27`; integrated claim `PROVINCE.md:54` |
