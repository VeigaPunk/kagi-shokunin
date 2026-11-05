# K41ReviewJournal — attacks on C1 (`corpus/expect-journal.sh`, frozen rules R1–R4)

Basis: plans/round-41.md §C1 (frozen) and plans/round-41-c1.sh (frozen counter). Every attack is a
delta on the counter's own fixture block (BASE 6cc8850 ledger as base; P0 = 6f1588c ledger + its
round-40 journal `.ufo/waves/round-40/expectation-migrations.json`). Ledger columns: 0=id, 1=command,
2=expect.

Standing L1 command after landing (one per attack; `$S` is the attack's fixture root, built exactly
like the counter's `python3 - "$ROOT" <<'PY'` block plus the delta named in the attack):

```
bash corpus/expect-journal.sh --base-ledger "$S/base-ledger.tsv" --ledger "$S/<attack>-ledger.tsv" --journals "$S/<attack>-journals"
```

rc 0 = accept, 1 = refuse, 2 = setup. Refusal line shape: `EXPECT_JOURNAL: REFUSE <CLASS> <ID>`.

---

## A1 — journal entry in a non-`.json` file
- **Attacks:** R1, the clause "in some `*.json` file under `--journals`" (the file-suffix gate on where a migration entry may live).
- **Construction:** F1 fixture verbatim (R13-01 expect := `^[0-9]+$`, entry removed from `expectation-migrations.json`), then the R13-01 entry document is placed back as `<attack>-journals/migrations.jsonl` (a valid JSON document, wrong suffix). Delta from counter F1: one file rename.
- **Predicted verdict under the frozen rules:** REFUSED, `UNJOURNALED R13-01`, rc 1. The only file present is not a `*.json` file, so R1's precondition "must have a migration entry with that id in some `*.json` file" fails. If the gate globs every file regardless of suffix, it ACCEPTS — that is a counter disagreement with the frozen token, and F1-style concealment (renaming the journal) would then defeat the gate.
- **Escape it must not allow:** renaming the journal to `.jsonl`, `.JSON`, `.json.bak`, or stashing the entry in a sibling non-JSON doc.

## A2 — duplicate migration id inside one journal
- **Attacks:** R1 + R2 quantification ("a migration entry with that id … that entry's `old_expect`"). The frozen text never says whether the rule is checked on the FIRST entry with the id, on ALL entries, or on ANY.
- **Construction:** F2 fixture verbatim, except the R21-02 entry appears twice: first a faithful copy (old_expect = the true base census expect `^SOURCES_CENSUS: CLEAN \(rows=93 …\)$`, new_expect = candidate), second the forged one (old_expect := its new_expect). Delta from counter F2: append one duplicate array element.
- **Predicted verdict:** counter disagreement risk, resolved by implementation choice. Under an all-entries reading (R2 must hold for every entry carrying the id) the run is REFUSED `OLD_MISMATCH R21-02` rc 1. Under a first-match reading the gate ACCEPTS rc 0 and the forged duplicate rides along. The frozen sentence cannot distinguish these, so the L1 run decides; this ambiguity is logged in ambiguities.md (item 3).
- **Why it matters:** a journal that appends a decoy-clean entry ahead of a forged one would then pass a first-match gate while F2's token is never produced.

## A3 — trailing carriage return on an expect cell
- **Attacks:** R2 NEW_MISMATCH ("equals the candidate ledger expect literally") and R3 (ends-with-`$` anchor check) — both are byte-literal comparisons whose CR sensitivity is unstated.
- **Construction:** F3's ledger forgery with a raw CR byte: R13-01 expect := `^54$<CR>` (hex `5E 35 34 24 0D`), journal left as the committed round-40 entry (new_expect `^54$`). Delta from counter F3: one extra byte in the expect cell.
- **Predicted verdict:** REFUSED with two lines, `EXPECT_JOURNAL: REFUSE NEW_MISMATCH R13-01` and `EXPECT_JOURNAL: REFUSE NOT_LITERAL R13-01` (the value does not end with `$` and its interior differs from the base), rc 1; final line `EXPECT_JOURNAL: REFUSED (violations=2)`. If the gate normalizes CRLF on read (or the JSON side is compared after `.rstrip()`), it ACCEPTS — divergence from "literally".
- **Cross-check:** the pre-change `claim-ledger.sh verify` would separately FAIL R13-01 on this ledger (`^54$\r` cannot match output `54`), so an accepting journal-gate would leave a live contradiction between the two gates.

## A4 — row id with trailing whitespace in the journal
- **Attacks:** R1's id match ("a migration entry with that id") — literal string equality of the id field.
- **Construction:** F1's ledger forgery (R13-01 expect := `^[0-9]+$`, entry kept), with the journal entry's id mutated to `"R13-01 "` (trailing space). Delta from counter F1: one character inside the JSON.
- **Predicted verdict:** REFUSED `UNJOURNALED R13-01` rc 1 — no entry with the exact id exists. If the gate trims ids (or matches by prefix), it ACCEPTS: an unjournaled loosening concealed by whitespace.
- **Symmetric probe worth one extra fixture:** the same trailing space on the LEDGER row id (`"R13-01\t…"`) — then the candidate row's id differs from base, no row is "present in both" under literal pairing, and every frozen class goes quiet while `claim-ledger.sh` idref would flag nothing (the row still exists). Predicted ACCEPTED — recorded as a gap of the frozen row-pairing rule, not a refusal.

## A5 — journal entry for an unchanged row (orphan must warn, not refuse)
- **Attacks:** R4 (`WARN ORPHAN <ID>` — "warning, not a refusal") and the final-line contract (`CLEAN` with a warning line still on stdout, rc 0).
- **Construction:** P0 fixtures unmodified (ledger = P0), journal = round-40 journal plus one extra entry `{id: "R11-04", command: <its ledger command>, old_expect: <its ledger expect>, new_expect: <same>, reason: "probe"}` for a row that did not change from base. Delta from counter P0: one appended array element.
- **Predicted verdict:** ACCEPTED rc 0 with `EXPECT_JOURNAL: REFUSE`-free output, one `WARN ORPHAN R11-04` line, final line `EXPECT_JOURNAL: CLEAN (changed=<n of the six> journaled=<n+1>)`. If the gate refuses (any rc 1 / REFUSE line), the gate violates R4 outright — a false positive that would also poison real rounds, since stale journal entries are routine.
- **Kill-rule link:** none directly, but a gate that orphans-refuse would fail the P0 control only if P0's journal contained an orphan (it does not), so this attack is the only probe of R4.

## A6 — row deleted from the candidate ledger
- **Attacks:** the frozen set {R1, R2, R3, R4} as a totality — no class speaks about a base row that is ABSENT from the candidate ledger.
- **Construction:** P0 ledger with the R31-02 line removed entirely (an inherited census row); journal unchanged. Delta from counter P0: one deleted ledger line.
- **Predicted verdict:** ACCEPTED rc 0. R1 quantifies over "a row present in both ledgers"; R3 over "every candidate expect that changed"; a deleted row is in neither population. This is a genuine blind spot, not a refusal: deleting a row hides its drift from the journal gate (the pre-change `claim-ledger.sh verify` also stays silent on the deletion itself; only doc-side idref/citation audits could notice a dangling id). The attack is recorded so the round report can state the gate's coverage honestly: the gate referees CHANGES, never REMOVALS.
- **Predicted counter reading if wired into `round-41-c1.sh`:** N contribution 0 (no frozen token).

## A7 — loosened expect hidden in a second row of the same id
- **Attacks:** R1's row pairing ("a row present in both ledgers whose … expect … differs") under id duplication in the candidate.
- **Construction:** P0 ledger plus one appended duplicate of R13-01 whose expect is `^[0-9]+$` (original row untouched, journal untouched). Delta from counter F1: the forgery is an added row instead of an edit.
- **Predicted verdict:** REFUSED `UNJOURNALED R13-01` rc 1 under a row-wise pairing (the appended row's expect differs from the base expect for that id). ACCEPTED rc 0 under an implementation that keys the ledger by id and keeps only the first (or last) occurrence — the second row then never enters the comparison. The frozen sentence cannot separate the two readings; logged as ambiguities.md item 2. The L1's post-landing run decides which reading the shipped gate implements.
- **Cross-check:** `claim-ledger.sh verify` itself would run BOTH R13-01 rows; the loosened duplicate passes verify (still matches output), so only the journal gate can catch the concealment.

## A8 — properly journaled command rebind must be ACCEPTED (positive-path probe)
- **Attacks:** R1+R2 in the legitimate direction: the gate must not refuse a real, fully journaled migration — the exact operation round-41's landing performs on the six round-40 rows.
- **Construction:** F4's ledger forgery (R24-06 command := `echo 'ROW_IDENTITY: scorecard-rounds count=54 sha256=52e7ba8d9b4de4a3aa7543b7f0370361dd17c2ae18b98c0c318618917dfe50c7'`) WITH a complete journal entry for R24-06: command equals the candidate command literally, old_expect equals the base expect (`^ROW_IDENTITY: … 0cbb2da2…$` is NOT touched — expect never changed), new_expect equals the candidate expect (`^ROW_IDENTITY: … 52e7ba8d…$`, unchanged from P0). Delta from counter F4: one journal entry added.
- **Predicted verdict:** ACCEPTED rc 0, final `EXPECT_JOURNAL: CLEAN (changed=1 journaled=1)` (R1 satisfied by the new entry; all three R2 literals hold; R3 vacuous since the expect did not change). A refusal here (`COMMAND_MISMATCH R24-06` despite the entry) is a gate defect: it would make every future command rebind unadmittable and contradict the kill-rule clause that only UNJOURNALED six-row refusals block C1.

## A9 — half-escaped literal (`[` left bare)
- **Attacks:** R3's interior-escape rule ("every regex metacharacter in the interior … is escaped with a backslash").
- **Construction:** F3 variant: R13-01 expect := `^5[4]$` (journal new_expect := same). The value is anchored but `[` and `]` are bare metacharacters.
- **Predicted verdict:** REFUSED `NOT_LITERAL R13-01` rc 1. If the gate only checks `^`/`$` anchoring and skips the interior scan, it ACCEPTS a class-bearing expect — a loosening (`^5[4]$` matches any output starting `5` ending `4`) that passes as "literal".
- **Edge the interior scan must also survive:** `^54$` → `^\^54\$$`-style double-escaping and `\\[` (escaped backslash before a bare `[`); the frozen text says "escaped with a backslash" but not whether the scanner parses escape pairs. Logged as ambiguities.md item 6.

## A10 — over-escaped "literal" that can never match output (disclosed-ceiling probe)
- **Attacks:** the disclosed ceiling: "the gate does not re-run commands (a journal's literal `new_expect` that disagrees with real output is the job of `claim-ledger.sh verify`, not this gate)".
- **Construction:** R13-01 expect := `^\^54\$$` (starts `^`, ends `$`, every interior metacharacter backslash-escaped), journal new_expect := the same string. Under a character-class-scanning R3 this is a fully literal anchored expression.
- **Predicted verdict:** ACCEPTED rc 0 — and correctly so under the frozen division of labor: the string can only match the literal text `^54$`, never the actual output `54`, and catching that is `claim-ledger.sh verify`'s job (which FAILs the row). The attack documents the ceiling's shape so the round report can cite it as disclosed, not missed: the journal gate bounds the SYNTAX of loosening, not its SEMANTICS.
- **Predicted counter reading:** 0 (acceptance is the frozen-correct outcome).

## A11 — unjournaled AND non-literal at once (token overlap)
- **Attacks:** the counter's counting line: `grep -qxF "EXPECT_JOURNAL: REFUSE $4"` per token — whether multi-violation output still counts each frozen token.
- **Construction:** ledger with R13-01 expect := `^[0-9]+$` AND its journal entry removed AND a second violation planted on R24-06 (command rebound, entry removed) — i.e. F1+F3 plus a command-side sibling. Delta from counter F1: one extra forged row.
- **Predicted verdict:** REFUSED rc 1 with at least three lines: `UNJOURNALED R13-01`, `NOT_LITERAL R13-01`, `UNJOURNALED R24-06`, final `EXPECT_JOURNAL: REFUSED (violations>=3)`. The frozen text mandates "one per violation, on stdout", so every individual token remains greppable and the counter's `check f1`/`check f3` both count this fixture as refused. If the shipped gate prints only the FIRST violation per run, F1-style fixtures that also trip R3 would be miscounted — the L1 run on this fixture decides.

---

### Coverage summary
| Attack | Frozen clause probed | Predicted |
|---|---|---|
| A1 | R1 file-suffix | refuse UNJOURNALED |
| A2 | R2 entry quantification | implementation-divergent (flagged) |
| A3 | R2/R3 byte-literal + anchor | refuse NEW_MISMATCH + NOT_LITERAL |
| A4 | R1 id literalism | refuse UNJOURNALED |
| A5 | R4 orphan | accept + WARN ORPHAN (rc 0) |
| A6 | row deletion (gap) | accept (blind spot, recorded) |
| A7 | R1 row pairing under dup id | refuse UNJOURNALED (row-wise) / accept (id-keyed) |
| A8 | legitimate journaled rebind | accept (positive control of the accept path) |
| A9 | R3 interior escape | refuse NOT_LITERAL |
| A10 | disclosed ceiling | accept (by design) |
| A11 | counter token overlap | refuse, all tokens greppable |

All constructions are deltas on the counter's committed fixture block (plans/round-41-c1.sh); none
requires network, host state, or anything outside the four committed fixtures (BASE 6cc8850 ledger,
P0 ledger, P0 journal).
