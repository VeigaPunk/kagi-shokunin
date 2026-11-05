# K41ReviewJournal — §C1 sentence-by-sentence ambiguity review

Method: every normative sentence of plans/round-41.md §C1 is listed with the counter line
(plans/round-41-c1.sh) that resolves it — or fails to. "Unresolved" = two conforming implementations
can disagree while both claim the frozen text.

## 1. R1 — row pairing key
- Sentence: "R1 `UNJOURNALED <ID>`: a row present in both ledgers whose command (column 2) or expect (column 3) differs from the base must have a migration entry with that id in some `*.json` file under `--journals`."
- Ambiguity: "a row present in both ledgers" — paired by row id, by ordinal position, or by (id, command) pair? Duplicate ids (attack A7) and reordered rows are unpaired under id-keying vs line-keying.
- Resolved by counter: **partially.** `edit_row(p0, "R13-01", 2, …)` matches `f[0] == rid` for EVERY line (`out.append` unconditional), so the counter's own forgery tooling is row-wise/id-wise indifferent, and `run_gate`/`check` never constrain pairing. The fixture inputs happen to have unique ids, so the counter does not resolve the duplicate-id case. UNRESOLVED by the frozen corpus; decided only by the gate implementation (A7 run).

## 2. R1 — "differs" comparison mode
- Sentence: same as above ("whose command … or expect … differs from the base").
- Ambiguity: byte-exact string compare vs whitespace/CR-normalized compare (attack A3's trailing CR and A4's id whitespace probe both pivot here).
- Resolved by counter: **no.** The counter never exercises a near-miss byte. UNRESOLVED; the shipped gate decides.

## 3. R2 — which entry, when several carry the id
- Sentence: "R2 `OLD_MISMATCH <ID>`: that entry's `old_expect` equals the base expect literally." (and the two sibling R2 sentences).
- Ambiguity: "that entry" is anaphoric to R1's "a migration entry with that id" — but nothing forbids two entries with the same id (attack A2). First-wins, last-wins, all-must-hold, and any-must-hold are four conforming readings.
- Resolved by counter: **no.** `mig(doc, rid)` returns the FIRST match, but it only builds fixtures (F2/F3 edit the single committed entry); `check` greps output tokens. The all-vs-first quantification is UNRESOLVED by the frozen corpus.

## 4. R2 — "literally" on JSON-decoded strings
- Sentence: "equals the base expect literally" / "equals the candidate ledger expect literally".
- Ambiguity: after JSON decoding, `\u005e` and `^` are the same string — clearly fine — but CRLF in a TSV cell, Unicode NFC/NFD, and trailing whitespace are not addressed. "Literally" most naturally means byte-exact post-decode; a normalizing implementation also reads as conforming.
- Resolved by counter: **implicitly for the happy path.** F2's `m["old_expect"] = m["new_expect"]` is a raw dict assignment (no normalization), and the token grep `grep -qxF` is byte-exact — so the counter's own string handling is byte-exact. Normalization inside the gate remains unconstrained. UNRESOLVED at the margins (A3).

## 5. R3 — the population of R3
- Sentence: "R3 `NOT_LITERAL <ID>`: every candidate expect that changed from base is a fully literal anchored expression: starts with `^`, ends with `$`, and every regex metacharacter in the interior (`. [ ] ( ) * + ? { } | ^ $`) is escaped with a backslash."
- Ambiguity (a): "that changed from base" — a base expect that is ALREADY non-literal and unchanged escapes R3 by design; a candidate expect that changed AND whose row has no journal entry violates both R1 and R3 — the plan says "one per violation", so both lines print; no ambiguity, resolved by the final-line sentence.
- Ambiguity (b): "interior" — does it exclude position 0 (`^`) and the last position (`$`) only, or every escaped position? `^$` (empty match) has empty interior → literal. `^a$` fine. Over-escaping (`\^`) counts as "escaped" under a naive scan (A10). Whether the scanner must PARSE escape pairs (`\\[` = escaped backslash then bare `[`) is unspecified.
- Resolved by counter: **no.** F3 exercises exactly one non-literal value (`^[0-9]+$`); the counter's `check f3 … "NOT_LITERAL R13-01"` only fixes the token, not the scanner semantics. UNRESOLVED for escape-pair edge cases.

## 6. R4 — orphan accounting
- Sentence: "R4 `WARN ORPHAN <ID>` (warning, not a refusal): a journal entry for a row that did not change."
- Ambiguity: does an orphan entry count into `journaled=<n>` of the final `CLEAN` line? Is `changed=<n>` counted per row or per changed field (a row changing BOTH command and expect — one or two)? Neither is stated.
- Resolved by counter: **no.** P0's fixture journal has no orphans and all six entries correspond to changed rows, so neither number is ever pinned by the counter's P0 acceptance (`rc = "0"` check only). UNRESOLVED; cosmetic but report-visible.

## 7. Interface — exit codes and line placement
- Sentence: "Interface (frozen): `bash corpus/expect-journal.sh --base-ledger FILE --ledger FILE --journals DIR`. Exit 0 accept, 1 refuse, 2 setup. Refusal lines: `EXPECT_JOURNAL: REFUSE <CLASS> <ID>`, one per violation, on stdout."
- Ambiguity: where WARN ORPHAN lines go (stdout with the refusals, per "Refusal lines … on stdout" silence about warnings); whether stdout-vs-stderr is enforced for setup errors (rc 2's output channel unspecified).
- Resolved by counter: **partially.** `run_gate` captures `> "$ROOT/out.$$" 2>&1` (both streams merged) and `check` greps the merged file, so the counter works whichever channel each line uses — the frozen counter deliberately does not pin the channel. WARN placement UNRESOLVED but consequence-free for counting.

## 8. Final line format
- Sentence: "Final line `EXPECT_JOURNAL: CLEAN (changed=<n> journaled=<n>)` or `EXPECT_JOURNAL: REFUSED (violations=<n>)`."
- Ambiguity: "final line" of stdout or of the merged output? The counter reads rc first and greps tokens anywhere in merged output, never the final line — so a gate that prints a trailing human note after the verdict would still be counted correctly, though it violates the frozen text.
- Resolved by counter: **no** (counter is deliberately final-line-agnostic; the plan sentence is stricter than the counter enforces).

## 9. Selftest case count
- Sentence: "Selftest: `--selftest` runs the four forgeries and P0 on scratch fixtures and prints `EXPECT_JOURNAL_SELFTEST: PASS (cases=<n>)`."
- Ambiguity: `<n>` is never fixed (5? 9?). No kill rule references it.
- Resolved by counter: **not applicable** — the C1 counter never runs `--selftest`; the number is free. Cosmetic.

## 10. Counter predicate — the "exact line" and rc coupling
- Sentence: "prints ONE unsigned integer N = the number of the four forgeries F1–F4 that the gate refuses with its frozen token (rc 1 and the exact line `EXPECT_JOURNAL: REFUSE <token>`)…"
- Ambiguity: "<token>" in the sentence vs the table's tokens WITH ids (`UNJOURNALED R13-01`). The counter settles it: `grep -qxF "EXPECT_JOURNAL: REFUSE $4"` with `$4` = e.g. `UNJOURNALED R13-01` — full-line, id included.
- Resolved by counter: **yes** (`check() { … grep -qxF … }`, rc equality `"$rc" = "1"`).

## 11. Counter predicate — P0 gatekeeping
- Sentence: "…counted only if the gate accepts the positive control P0 (rc 0). If P0 is refused or the gate is missing, N = 0."
- Ambiguity: none material — P0 is pinned to `(base 6cc8850 ledger, P0 ledger, P0 journal)` by the fixture block (`BASE=…`, `P0=…`, `JOURNAL_PATH=…`, `git show` triple).
- Resolved by counter: **yes** (`rc=$(run_gate …p0…); if [ "$rc" != "0" ]; then echo 0; exit 0; fi`).

## 12. Forgery table — "its" and the echo target
- Sentence (F2 row): "R21-02 journal `old_expect` := its `new_expect`; ledger unchanged." / (F4 row): "R24-06 command rebound to an `echo` of its expected line; journal unchanged".
- Ambiguity: "its" — resolved by the counter: F2 mutates the R21-02 entry's own new_expect into old_expect (`m = mig(f2j, "R21-02"); m["old_expect"] = m["new_expect"]`); F4's echo string is hard-coded to R24-06's candidate expect interior (`ROW_IDENTITY: scorecard-rounds count=54 sha256=52e7ba8d…`), which matches the P0 ledger cell byte-for-byte (verified this seat: clone F4 ledger col1 == `echo 'ROW_IDENTITY: …52e7ba8d…'`).
- Resolved by counter: **yes.**

## 13. Kill rule — which base for the landing check
- Sentence: "Kill rule: C1 is not admitted if … any of the six round-40 migrations (R13-01, R21-02, R24-06, R31-02, R33-02, R34-03) is refused by the gate at the round-41 landing."
- Ambiguity: "refused by the gate at the landing" — against WHICH base ledger? If the base is the claim BASE 19025d9 ledger (which already contains the round-40 migrations), the six rows are unchanged at landing and can never be refused — the clause is vacuous. If the base is 6cc8850 (round-40 claim BASE), the six rows changed and must be journaled — the clause has teeth. The plan does not say; the counter's fixture block uses `BASE=6cc8850…` as `--base-ledger` for ALL its gate runs, which is the only committed reading.
- Resolved by counter: **implicitly yes (6cc8850), but the plan sentence alone is ambiguous.** The L1's landing check must reuse 6cc8850 or the clause dies silently.

## 14. Journals directory semantics
- Sentence: "…in some `*.json` file under `--journals`."
- Ambiguity: recursion depth unbounded? Symlinks followed? Case sensitivity of the `.json` suffix? (Attack A1.) Also: which FILE wins when the same id appears in two different `*.json` files under the tree — same quantification hole as item 3, one level up.
- Resolved by counter: **partially.** The counter's journals dir holds exactly one file (`expectation-migrations.json`, written by `write_journal`), directly under `--journals` — the shallowest possible reading. Depth/two-file cases UNRESOLVED.

## 15. Separability and ceilings
- Sentence: "Separability: C1 reads only P0 (fixed committed revisions) and the gate; it does not read C2's registry rows." / "Ceilings, disclosed in advance: the gate does not re-run commands …; it does not judge the reason text."
- Ambiguity: none — the counter's inputs are exactly the two ledgers, the journal, and the gate (`git show` triple + `$GATE`); the ceiling is consistent with A10's predicted acceptance.
- Resolved by counter: **yes.**

## Bottom line
Items 10, 11, 12, 15 are pinned by the counter code. Items 7, 8 are partially pinned. Items 1, 2, 3,
4, 5, 6, 9, 13, 14 remain implementation-charged: the frozen sentences under-determine behavior that
the landing run will silently fix. None of the unresolved items blocks the frozen counting of F1–F4;
the material ones for honesty of the claim are 3 (entry quantification), 7/13 (pairing/kill-rule
base), and 5 (escape-pair scanning).
