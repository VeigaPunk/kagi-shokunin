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
