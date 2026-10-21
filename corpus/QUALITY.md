# QUALITY — kagi's admission bar

What clears `corpus/knowledge/`, and what a weak source or entry looks like in
the secrets & vault ops domain. Created round 21 (no bar existed before:
`test -e corpus/QUALITY.md` → exit 1 at `aea7a43`). Tier definitions live in
`corpus/SOURCES.md` (contract v1); this file does not restate them.

Criteria are append-only: a criterion is superseded by a new row that names
the row it replaces, never rewritten. Every criterion cites the lesson that
produced it.

## Admission bar (round 21)

An entry is admitted only when **every** row below holds. A candidate that
fails one is rejected with that row's id as the reason, in the round lesson's
`## Gate`.

| id | criterion | weak-material signal | lesson |
|---|---|---|---|
| QA1 | Every domain claim cites a `corpus/SOURCES.md` row that is tier A **for that scope**, plus an anchor (section/heading + revision or date). A tier C row never stands alone. | a bare homepage, a product page, or a secondary write-up carrying a mechanism claim | `corpus/lessons/round-21.md` §Gate (a product page opened and rejected as mechanism support); §Mistakes M12 (a citation whose target does not carry the claim) |
| QA2 | Release status is part of the claim: preview, IPD/draft, Enterprise-only and version-scoped behaviour are stated in the sentence that uses them. | "is", "supports", "guarantees" with no status or version | `corpus/lessons/round-21.md` §Gate (Credential Broker is a public preview; the research candidate "Broker removes every secret from CI" rejected); `corpus/lessons/round-20.md` §Byte frontier (observations scoped to op 2.40.0) |
| QA3 | The entry states what it does **not** establish, and never widens a measured or documented path into a general contract. | "complete", "all", "removes every" | `corpus/lessons/round-20.md` §Gate (six PASS rows refused as a "complete dotenv contract") |
| QA4 | Each entry names a falsifier (the observation that would make it wrong) and a `recheck:` trigger (cadence or release event). | a fact with no way to notice it went stale | `corpus/lessons/round-21.md` §Gate (0 of 21 legacy entries carried a `recheck:` line at `aea7a43`); `corpus/lessons/round-18.md` §"The defect worth fixing" (substrate loss found only by a re-census, no trigger) |
| QA5 | No credential material, ever: no secret value, token, session id, vault/item/field name, or 1Password secret reference (the `op` scheme URI; this file does not spell it, so the pre-commit sweep stays empty) — including in examples copied from vendor docs. | an example command or JSON pasted verbatim from documentation | `corpus/lessons/round-1.md` §"Rules extracted (carry forward)" |
| QA6 | A count carries its command; a negative claim carries its sweep; a quote names its location. | "none", "never", "N rows" without the command that produced it | `corpus/lessons/round-1-aggregator-audit.md` §Audit findings (the unreproducible counts behind the fleet `CORPUS.md` rules); `corpus/lessons/round-21.md` §Mistakes M11 (an absence sweep falsified by its own needle) |
| QA7 | Lane fit: the ground is secrets & vault ops and no sibling lane's `PROVINCE.md` or corpus claims it; contested ground is reported, not absorbed. | the entry restates another lane's mechanism (endpoints, prompts, scanning tooling) | `corpus/lessons/round-16.md` §1–§2 (ownership partition) |
| QA8 | Distinct custody boundaries stay distinct: process-scoped delivery, token lifetime, lease lifecycle, recipient access and data-key rotation are never collapsed into one "short-lived" or "rotated" claim. | "short-lived", "rotated", "revoked" applied to a different object than the source names | `corpus/lessons/round-21.md` §Gate (rejected research candidates) |

## Criteria from mistakes (round 21)

One row per mistake class in `corpus/lessons/round-21.md` §Mistakes that no row
of the admission bar above captured (`captured-by (before)` = `none` there;
both surfaces were checked). `M8` — the honest stop — is the model, not a
defect, and takes no criterion. Each row states the observation that fails it;
each lesson cell points at the round's row and the original evidence lesson.

| id | criterion | weak signal | lesson |
|---|---|---|---|
| QM1 | A property of a source the host no longer carries (hash prefix, mode, line count) appears only under an explicit historical marker; an unmarked current-voice assertion of an absent file fails. Distinct from QA4: a `recheck:` trigger does not require an absent source's lines to be marked historical. | a sha256 prefix, mode or line count stated in present tense about a path `test -e` no longer finds | `corpus/lessons/round-21.md` §Mistakes M1; `SCORECARD.md` §Round-19 correction (line 454) |
| QM2 | An exit-code or mechanism attribution carries the command and the host it was measured on; an attribution that was never re-run is cited only with its original measurement context, never as current behaviour. | "`<tool>` exits N" or "fails on …" with no command or host | `corpus/lessons/round-21.md` §Mistakes M2; `corpus/lessons/round-15.md` §Corrigendum (line 112) |
| QM3 | Every skip, unverified branch or printed FAIL is counted in the verdict line or fails the run; a summary counts failures as well as catches. | a `CLEAN`/`PASS` last line with `skipped=` or `unverified=`, or a `FAIL` line above it, exit 0 | `corpus/lessons/round-21.md` §Mistakes M3; `corpus/lessons/round-10.md` (lines 44, 63); `corpus/lessons/round-16.md` (line 68) |
| QM4 | A selftest advertises only the isolation it proves: a case that touches the real substrate prints an explicit SKIP naming the reason, and the case count does not absorb it. | a case advertised as sandboxed or hermetic that executes the real handler, or that fails only on a substrate-absent host | `corpus/lessons/round-21.md` §Mistakes M4; `corpus/lessons/round-18.md` §The defect worth fixing, item 1 |
| QM5 | An artifact lands only with its stamp and its claim row updated in the same commit, and `verify` is run before the commit; a pin that lags the artifact's bytes is a defect, not inherited debt. | a commit adds artifact bytes while a grep for its capability in the claim ledger returns 0, or the stamp's bytes differ from `wc -lc` | `corpus/lessons/round-21.md` §Mistakes M5; `corpus/lessons/round-20.md` §What was actually inherited |
| QM6 | Round identity is `(lane, max recorded + 1)`: a reused launch counter is a dated re-execution, never a new round id and never a verified-round count. | two records carrying one round label; a launch number quoted as a round count | `corpus/lessons/round-21.md` §Mistakes M6; `SCORECARD.md` §Current baseline — round-16 re-dispatch (line 468) |
| QM7 | A placeholder token in a durable artifact fails the stamp; `<FILL …>`, `<LINES>` and `TODO` are allowed only in an uncommitted draft, and a named-debt row is not the fix. | `<…>`, `TODO` or `FILL` tokens in a tracked file; the same debt row open across rounds | `corpus/lessons/round-21.md` §Mistakes M7; `corpus/lessons/round-19-recensus.md` §Named debt (line 40) |
| QM8 | A wave's lane comparisons name the revision each lane read, and the author stops writing at the declared freeze; numbers that moved between dispatch and summary are re-measured and the movement reported. | "the freeze was stale on arrival"; a canned comparison against a revision that no longer exists | `corpus/lessons/round-21.md` §Mistakes M9; `corpus/lessons/round-12.md` §L2 wave (lines 84-98) |
| QM9 | Every mode named in help or docs is reachable in the parser and dispatch and proven by a case; a mutation that cannot fire is a setup error, not a pass. | `unknown argument` for a documented flag; a mutation count that never inspects the mutated bytes | `corpus/lessons/round-21.md` §Mistakes M10; `corpus/lessons/round-16.md` §Defects found while landing, items 6–7 |
| QM10 | An absence claim is re-run on the tree that contains the claiming sentence, with a needle that excludes it; a sweep whose pattern matches its own text is not evidence of emptiness. Distinct from QA6: carrying a sweep is not a sweep that can return the claiming line. | a "`grep …` is empty" sentence whose pattern occurs in the swept tree; an "unreachable" reading with no counting command | `corpus/lessons/round-21.md` §Mistakes M11; `corpus/lessons/round-14.md` (line 139); `corpus/lessons/round-19-recensus.md` §Audit detail (line 49) |
| QM11 | A citation to another artifact names that record's actual subject; an attribution the cited row does not carry is removed and the underlying question is reported unassigned. | the cited row resolves but is about a different surface; "ownership ruling remains honestly unassigned" | `corpus/lessons/round-21.md` §Mistakes M12; `corpus/lessons/round-17.md` §4 (lines 100-103) |

## Criteria from the round-21 post-landing review

The round's own critic failed two admitted entries on scope after `c41af82`
landed (`corpus/lessons/round-21.md` §Post-landing review). The bar above did
not catch it; these rows are what it lacked. Rows above are unchanged.

| id | criterion | weak signal | lesson |
|---|---|---|---|
| QA9 | Every qualifier on the source sentence travels with the claim: product, code path (e.g. the Kubernetes JWT provider, not "any IdP"), plan/eligibility and per-feature release status. A table row or sentence that spans two products or two paths cites a source for each part; a part with no source is withdrawn, not generalised. | a "Vault/OpenBao" or "IdP, Kubernetes" label resting on one product's page; a guide-level "preview" applied to every workflow; "never expires" where the page only says "issues no lease" | `corpus/lessons/round-21.md` §Post-landing review (E1, E3 findings) |
| QM12 | Supersedes QM5's "`verify` is run before the commit" clause for hosts where `claim-ledger.sh verify` would read host-private surfaces: the substitute is every ledger row whose command touches no host-private surface re-run individually against the commit tree (exit + last line), the stamp file checked with `sha256sum --check`, and the skipped rows listed by id with the reason. A landing that does neither fails. | "rows were re-run" with no row list; `verify` claimed on a host where it was not run | `corpus/lessons/round-21.md` §Post-landing review (QM5 unmet as written); §Named debt (`R18-01` reads host files) |

Locator note: QM1 and QM6 cite `SCORECARD.md` lines 454 and 468; the round-21
move-log rows moved those sections by four lines. Their section names
(§Round-19 correction, §Current baseline — round-16 re-dispatch) are the
anchors.

## Criteria from the outside round-21 admit disagreement (round 22)

| id | criterion | weak signal | lesson |
|---|---|---|---|
| QA10 | Supplements QA9: follow and open each feature-specific status link before admitting a release-status claim. Record the feature, eligible plan/deployment, status and scope-specific source for each product independently. A guide-level label, unopened link, missing eligibility, or one product's page for another fails admission; preserve the rejected reading and append the correction. | calling both Broker workflows public preview; omitting Business eligibility; supporting OpenBao claims only with Vault documentation | `corpus/lessons/round-22.md` §Mistakes M22-1 and §Gate; outside `corpus/lessons/round-21-verifier-spotcheck.md` §Adjudication |
| QM13 | An authored count of criteria, rows or headers is not calibration. A calibration claim names decisions, independent source-grounded expected outcomes, misses and false admissions, and must fail a known bad admit while retaining a bounded valid control. A typed-record gate checks only its declared representation, not arbitrary prose or vendor truth; outside agreement remains a non-author duty. | more rows declared as a discernment move; selftests or L2 consensus claimed as outside agreement | `corpus/lessons/round-22.md` §Mistakes M22-2; outside `corpus/lessons/round-21-verifier-spotcheck.md` §Adjudication |
| QM14 | Revision-pin and expectation changes preserve the previous state in a committed migration record with old/new values, motivating correction and observed checks. Restore dropped stamp membership or explicitly justify each removal; a fresh hash does not make historical source facts current. | restamping to hide stale knowledge; silent deletion of stamp rows; expectation rewrites with no old-value evidence | `corpus/lessons/round-22.md` §Mistakes M22-3 and §Revision accounting |

QA10 application: a status occurrence in shared navigation, CSS, a sidebar
or a related product does not satisfy the feature's own status anchor.
Bind the status to its own title/H1 or explicitly named status region and
keep a same-page status-swap rejection beside a valid control. This is the
concrete counterexample in the round-22 lesson, not a new countable criterion.

QM13 application from round-22 falsification: a CLEAN summary does not
establish the claimed command selection or authorization scope. If a
secrets/vault gate receipt contradicts its argument parser or membership
arithmetic, retain exact argv/cwd/stdout or quarantine the claim; never
invent missing semantics. In particular, legacy `verify` positional IDs
were not row selectors. Its unauthorized host-gate results are not a
substitute for QM12's explicit safe-row accounting.

## Criteria from the outside round-23 spot-check (round 24)

Each row turns one routed defect of `corpus/lessons/round-23-verifier-spotcheck.md`
§Routed defects into a reusable bar; the fix that first satisfies it is named in
`corpus/lessons/round-24.md` §Routed defect dispositions.

| id | criterion | weak signal | lesson |
|---|---|---|---|
| QM15 | Supplements QM12: a gate entry point that can reach a host-private read is default-deny. A ledger row that reads host-private surfaces carries `[host]` or `[substrate]`; `verify`/`cells` skip such rows by id unless the caller passes an explicit per-invocation consent flag (no inherited environment variable), and an untagged row that invokes a declared host-reading script outside its host-free arguments is refused, not run. `~`, absolute and `..` arguments and bash options are refused in row commands. | "never run `verify` on this host" as prose only; a host row that runs because a tag was forgotten; a consent variable inherited from a parent shell | `corpus/lessons/round-23-verifier-spotcheck.md` §Routed defects D4 and §Weighing the waves (M23-5); `corpus/lessons/round-24.md` §Routed defect dispositions |
| QM16 | Supplements QM14: freshness provenance separates current captures from historical pins. Every permitted legacy in-row pin is classified against a same-day capture by a verdict the gate recomputes from digests; only the named historical population keeps an in-row-only exemption; every normalized digest uses ONE committed, selftested normalizer whose decode, element, tag/comment, entity, whitespace-class, trim and encode rules are explicit and source-cited. | a pin "required for coverage, never compared"; the same normalizer described three ways; a quote rule stated as "collapse whitespace" with no class | `corpus/lessons/round-23-verifier-spotcheck.md` §Routed defects D5, D6; `corpus/lessons/round-24.md` §Gate |
| QM17 | Supplements QM13: a review Gate records each admitted, rejected, superseded/demoted or withdrawn candidate with its decision and basis; an aggregate count or "excluded 0" does not stand in for the rejected candidates. | a Gate with admits only; supersession recorded as prose elsewhere | `corpus/lessons/round-23-verifier-spotcheck.md` §Discernment spot-check and §Routed defects D8; `corpus/lessons/round-24.md` §Gate |
| QM18 | A ledger row whose note describes a MEMBERSHIP (rows, ids, pins, paths, cases) pins that membership's identity, not only its cardinality; a count-preserving swap of members must fail some ledger row. Blank lines are not members. | `grep -c` rows whose notes say "membership", "declares N rows", "holds N ids"; a count that a rename keeps green | `corpus/lessons/round-24.md` §Mistakes M24-3 and §C3 identity contract |

## Criteria from fresh round-24 falsifiers

| id | criterion | weak signal | lesson |
|---|---|---|---|
| QM19 | Supplements QM3/QM13: a measurement control requires a valid whole-process receipt (exit, final summary, complete claim population, expected skips/failures); absent failure text alone is not success. A timeout, setup/policy refusal, truncation or unaccounted row is invalid, never a surviving mutant. | a nonzero pristine process booked green because no selected FAIL line appeared | `corpus/lessons/round-24.md` §Mistakes M24-10 |
| QM20 | Supplements QM15: declared host-free invocation vectors are closed; static validation runs before recursion skips, and script expansion, attached path operands and symlinked ancestors are checked before launch. A trusted reviewed script allowlist is not a sandbox for arbitrary wrappers. | a lexical basename/argument prefix accepted before expansion or alias resolution; invalid or missing self invocation called CLEAN | `corpus/lessons/round-24.md` §Mistakes M24-8/M24-9 |

QM18 application: name the identity projection explicitly. A path-key digest
does not bind every row column; a test-case-name digest does not bind its
behavioral assertion body. Fresh evidence and rejected broader reading:
`plans/round-24.md` R24-C6 and `corpus/lessons/round-24.md` recovery Gate.

## Criteria from the round-25 build

| id | criterion | weak signal | lesson |
|---|---|---|---|
| QM21 | Supplements QA6/QM13: a current-tense number a committed doc states about this lane's own artifacts is bound to the live source that defines it (`corpus/self-counts.tsv`: `rows:`, a non-host row's live `ledger:` verdict, or a host row's committed `expect:` pin). A "round N" tag does not make a number historical; only an explicit history clause with a newer value beside it does. | the ledger pin moved while the prose copy stayed (SKILL.md:46 63/39 vs 83/61 for three rounds) | `corpus/lessons/round-25.md` M25-1, R25-C6 |
| QM22 | Supplements QM3/QM15: an outcome that depends on a layout the checkout lacks is printed and counted as INCOMPLETE, never CLEAN and never a bare failure; the row still runs, so lane-owned defects stay UNRESOLVED; any doubt about the layout keeps it fleet. | a whole-row skip that ends CLEAN, or a lone clone reporting the same `FAIL … exit-mismatch` as a real defect | `corpus/lessons/round-25.md` M25-3, R25-C1..C3 |
| QM23 | Supplements QA4/QM14: an `on-release` recheck names one observable release identity — an official feed that is itself a registry row, or the declared capture quote of an unversioned page — and is observed; a derived anchor says `derived:`, a fired clock is re-verified in the lesson, never silently re-pinned. | `on-release` with no feed; first-entry or any-version feed parsing; a fired verdict with no re-verification | `corpus/lessons/round-25.md` R25-C7, R25-C8, §Clock observations |

## Criterion from the round-26 rearm rejection

| id | criterion | weak signal | lesson |
|---|---|---|---|
| QM24 | Supplements QM23: a successor to an on-release teaching retains release-driven rechecking and is bound at its named current release; preserving an already-fired predecessor is not rearming. Active default/receipt/table/expectation migration is explicit and retains the original historical receipt with matching inputs. A missing-successor binding must fail UNBOUND, and a later-release fixture must fire the successor. | replacing on-release with90d while calling the old permanently-fired clock sufficient; changing default pins without an old/new journal; treating the historical profile as current | `corpus/lessons/round-26.md` M26-3 and §Final rearm correction; CritNoAxisHarm |

## Criteria from the round-27 build

| id | criterion | weak signal | lesson |
|---|---|---|---|
| QM25 | Supplements QM23/QM24: a release clock orders strict X.Y.Z versions numerically (S042 §11.2; S043 as supporting evidence). An observation older than its own numeric anchor, or than any numeric anchor on the same feed, or (when observing) than the row's previously recorded observation, is a typed `REGRESSED` finding that fails the run — never a fired release. An observation EQUAL to the feed's highest anchor cannot be told from a legitimate state on offline replay, and non-numeric, two-component or prerelease anchors are not ordered: both are declared limits, never covered by wording. An anchor that names a development or prerelease label is bound `derived:` at the released version. | `observed != anchor` treated as a release; a rollback or un-fire fixture that still ends CLEAN; fired count unchanged across a downgrade; a "never an un-fire" sentence the code cannot back | `corpus/lessons/round-27.md` M27-1; CritC2Rollback, CritC2NonNumeric, CritSourced |
| QM26 | Supplements QM21: current-tense numbers about lane artifacts inside `corpus/knowledge/*.md` are bound like SKILL/PROVINCE/README numbers. Excluded by rule and named: dated measurement/source-basis sections, Evidence/Erratum/Round-N history, positional case indexes, numbers with no lane-local pinned source, and per-round counts that move every round (written as a pointer to their ledger row instead). A number an erratum concedes stays in scope where the body states it: a once-true value keeps its history clause beside the current one; a never-true value is marked misstated. A locator captures the current value only; repeated copies on the line are tied with a backreference. | a knowledge reproduction block quoting a selftest count three rounds stale; a correction note elsewhere instead of a clause beside the number; a binding that captures one of two copies | `corpus/lessons/round-27.md` M27-2; CritC1Population, CritC1AppendOnly, CritCounting |
| QM27 | Supplements QM25: a release clock names a version only in canonical token form — every strict X.Y.Z component is `0` or has no leading zero (S045, SemVer §2) and stays within a declared lexical length bound decided before any int() (S044; S046: int() itself accepts leading zeros). A non-canonical anchor, observation or newest feed entry is a typed `NON-CANONICAL` finding that fails the run; it is never ordered, compared, fired, written as a verdict, or turned into a traceback. A lower non-canonical feed entry may be ignored only because it cannot be the newest release; a tie or a higher one fails the feed. | `3.15.01` string-unequal to `3.15.1` and read as fired; a 4301-digit component crashing `int()`; a canonicality test written as `str(int(x)) == x`; dropping a non-canonical newest entry silently | `corpus/lessons/round-28.md` M28-2; RevC1Bound, CritC1Vacuity, SentFeedTokens |
| QM28 | Supplements QM23/QM24: a `derived:` release-clock anchor is bound, not trusted — its strict X.Y.Z anchor must be the one stable X.Y.Z its feed row's anchor CELL names (never `teaches`; prerelease/build siblings and longer components are different tokens; a cell naming two versions binds none), else a typed `DERIVATION` finding in every mode. This is consistency between two committed files, not tamper evidence: a forger who edits both, or re-points the row to another feed, still passes until the feed row's scope is bound too. | "derived anchors are unverifiable by design"; whole-row scanning that finds `8.23.1` in curl's teaches; `version_is_named` accepting `2.2.0` inside `v2.2.0-rc1` as the binding | `corpus/lessons/round-28.md` M28-3; CritC2Vacuity, SentDerivedForgery, RevC2Exactness |
| QM29 | Supplements QM6/QM8: a round's claims file is committed ALONE (with its START census receipt) before any work commit; its frozen text and counting commands never change afterwards, and a plan correction is appended only before the first work commit — a later clarification goes in the lesson. A check of this must fail on a round that broke it (round 27: plan first landed with 1,873 work paths, no START census). | a plan first committed with candidate code; a START census reconstructed from the previous round's end receipt; a frozen scope widened by an appended correction after measurement | `corpus/lessons/round-28.md` M28-1; ScoutMistakeSweep, RevengeR27Timeline, CritConformanceFix |
