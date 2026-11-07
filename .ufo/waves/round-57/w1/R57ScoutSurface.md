# R57ScoutSurface — independent re-derivation of the C1 POP reading

Seat: scout (wave w1, round 57 attempt 1). Lane `/home/vgpnk/Projects/shokunin/kagi-shokunin`,
branch `master`, claim BASE `1cda9e7ae4767b4133e283bfbc08266d4c86362d`.
Model observed: **MiniMax-M3.1-Flash** (`minimax-code/MiniMax-M3.1-Flash`).
Tools: `python3` 3.14.8 (stdlib only, `-I -B`), `git` 2.56.0, `bash`, `sha256sum`. No installs
(all tools pre-existing; `pacman` untouched — the seat directive pauses all pacman transactions).

Method note: my own census (`scratch/census/mycensus.py`, `scratch/census/mycensus.out`) was written
and run **before** `plans/round-57-c1-check.py` was read, as the assignment required. The checker
source was then read and compared. All mutation probes ran on **copies** in scratch
(`scratch/probe/p*`, `scratch/probe/m3*`); no lane file was mutated.

---

## 1. Verdict

**My independent census and the frozen checker agree exactly at BASE: value 3, population 16,
mismatches 3, unbound 0.** The three mismatches are the three the plan named. The `population=16`
figure and the per-class breakdown (`cases=3 match=7 epochs=2 clocks=2 pop=2`) are also exactly
reproduced by my own enumeration of the audited surface.

Where I **diverge** from the checker is not the count — it is that the checker's *class membership*
rules are lexical, and several numerically load-bearing statements of the same four classes sit
immediately outside them. I exhibit **seven** concrete evasion routes, each demonstrated by a
mutation that changes a stale number to a false one **without moving `value`**. These are the
closed-class ceiling, made concrete. Details in §5.

The checker is also **mis-labelled in one place and mis-bound in two**: §4.

---

## 2. The audited surface, enumerated line by line

Per the plan's POP, the surface is exactly:

| surface | file | lines (BASE) | note |
|---|---|---|---|
| `SCORECARD.md` `## Round 56 — post-move` | SCORECARD.md | 1844–1855 | runs to EOF (no further `^## `) |
| `LOG.md` `## Round 56 (` | LOG.md | 1924–1931 | runs to EOF |
| `corpus/lessons/round-56.md` header + `## Claims` | corpus/lessons/round-56.md | 1–6 (header through the blank after `Frozen plan:`) + 7–11 (`## Claims` up to `## Gate`) | |

I confirmed the boundaries independently: `awk 'NR>1844 && /^## /' SCORECARD.md` → empty;
`awk 'NR>1924 && /^## /' LOG.md` → empty; lesson `## Gate` is line 12.

**Out of surface** (I checked these explicitly because the plan's motivating evidence names them):
`SCORECARD.md:718` (capability row, `22 MATCH` naming `epochE.txt`) and `SCORECARD.md:731`
(appended note, naming `controls-prefreeze-epochD.txt`). Both sit in `## Capabilities` (line 696) /
after it — **outside** the audited surface. Probes P13 and P14 confirm: corrupting either to
`99 MATCH` / `epochZ.txt` leaves `value=3` unchanged. This matches the plan's own words
("the defect there is the reference, repaired with the same row and recorded, **not counted**").
**The checker's surface scoping is correct**, and the plan's "not counted" claim is verified.

---

## 3. Statement-by-statement census (mine vs checker)

Authority values (all measured at BASE, all rc=0):

- **A1 cases = 20** — `python3 -I -B corpus/recheck-replay.py --selftest` → `RECHECK_REPLAY_SELFTEST: PASS (20 cases)`
- **A2 receipts** — `^CONTROLS: match=N mismatch=0` in `.ufo/waves/round-56/controls/controls-prefreeze*.txt`:
  unlettered `prefreeze=12`, **B=16, C=20, D=21, E=22, F=23**. (No `epoch-A` receipt exists.)
- **A3 epochs = 6** — distinct `epoch-[A-F]` tokens in `plans/round-56.md` → A,B,C,D,E,F
- **A4 clocks = 10** — data rows of `corpus/recheck-captures.tsv` (5 comment lines + `id\t` header at line 6 → 10 rows)

`file:line` below is the **file** line; the checker's `STMT` line is section-relative (offset by
1843 for SCORECARD, 1923 for LOG, and lesson-relative for the lesson).

| # | file:line | class | stated | authority | verdict | checker `via=` |
|---|---|---|---|---|---|---|
| 1 | SCORECARD.md:1846 | MATCH | 23 | epochF receipt = 23 | **OK** | `receipt-epochF` |
| 2 | SCORECARD.md:1850 | CASES | 18 | A1 = 20 | **MISMATCH** | `recheck-replay-selftest` |
| 3 | SCORECARD.md:1850 | POP | 10 | A4 = 10 | **OK** | `pop-size` |
| 4 | SCORECARD.md:1850 | POP | 10 | A4 = 10 | **OK** | `pop-match` |
| 5 | SCORECARD.md:1850 | CLOCKS | 10 | A4 = 10 | **OK** | `manifest-data-rows` |
| 6 | LOG.md:1924 | EPOCHS | 4 | A3 = 6 | **MISMATCH** | `receipt-file-count` |
| 7 | LOG.md:1926 | MATCH | 16 | epochB receipt = 16 | **OK** | `nearest-epochB` |
| 8 | LOG.md:1926 | MATCH | 20 | epochC receipt = 20 | **OK** | `nearest-epochC` |
| 9 | LOG.md:1926 | MATCH | 21 | epochD receipt = 21 | **OK** | `nearest-epochD` |
| 10 | LOG.md:1926 | MATCH | 22 | epochE receipt = 22 | **OK** | `nearest-epochE` |
| 11 | LOG.md:1926 | MATCH | 23 | epochF receipt = 23 | **OK** | `nearest-epochF` |
| 12 | corpus/lessons/round-56.md:5 | MATCH | 23 | epochF receipt = 23 | **OK** | `receipt-epochF` |
| 13 | corpus/lessons/round-56.md:9 | CASES | 20 | A1 = 20 | **OK** | `recheck-replay-selftest` |
| 14 | corpus/lessons/round-56.md:9 | CASES | 20 | A1 = 20 | **OK** | `recheck-replay-selftest` |
| 15 | corpus/lessons/round-56.md:9 | EPOCHS | 3 | A3 = 6 | **MISMATCH** | `receipt-file-count` |
| 16 | corpus/lessons/round-56.md:9 | CLOCKS | 10 | A4 = 10 | **OK** | `manifest-data-rows` |

**Totals — mine: value 3, population 16, mismatches 3, unbound 0.**
**Checker: `value=3 population=16 mismatches=3 unbound=0 cases=3 match=7 epochs=2 clocks=2 pop=2 guard=1`.**
Exact agreement, including the per-class split. `bash plans/round-57-c1.sh 1cda9e7a…` →
`C1_CURRENT: value=3 population=16 gate=0 guard=1`, rc=0.

The three mismatches are precisely the plan's named three (cases 18→20, LOG epochs four→six,
lesson epochs Three→Six). **No UNBOUND statements exist at BASE** — every statement binds to an
authority. Note `unbound=0` is *printed as a literal* by the checker, not computed; it happens to
be true here, but the counter's `unbound=` field is a constant, so it can never report an
unbound statement. That is a reporting defect, not a counting one (the sibling gate
`corpus/current-claims.py` counts it properly — I confirmed its `unbound` variable is incremented).

### 3a. Class-evasion: statements of the four classes that the checker does **not** count

These are numeric statements of the four declared classes, inside the audited surface, that a
reader would take to be class members but that the checker's lexical rules skip.

| # | file:line | what it states | stated | authority | truth | why the checker skips it |
|---|---|---|---|---|---|---|
| E1 | SCORECARD.md:1850 | `10/10 MATCH` (the `RECHECK_REPLAY: CLEAN` pop fraction) — actually **is** matched (POP_RE) | 10/10 | A4=10 | true | — |
| E2 | **LOG.md:1928** | `` `RECHECK_REPLAY: CLEAN` only at 10/10. `` — the **same** pop fraction as SCORECARD:1850, but the sentence ends `10/10.` with **no `MATCH` word** | 10/10 | A4=10 | true | `POP_RE` requires the literal `N/N MATCH`; the trailing `.` breaks it |
| E3 | **LOG.md:1926** | `SIX epochs, each superseding the last` — the epoch count in words | SIX (6) | A3=6 | true | `EPOCHS_RE` requires the literal `W freeze epochs`; here it is `SIX epochs` |
| E4 | **LOG.md:1928** | `10 manifest rows bind URL → capture body` — the manifest row count, same quantity as `N clocks` | 10 | A4=10 | true | `CLOCKS_RE` requires the literal `N clocks` |
| E5 | **LOG.md:1930** | `all six stay 9 → 9` — "six" is the **axis** count, not epochs | six | n/a (axes=6) | true | word-number list, but no `freeze epochs` |
| E6 | **LOG.md:1931** | `candidate 10/guard=1 … BASE 0/guard=1` — the counter's own readings, incl. `10` = the pop size | 10, 0 | A4=10 | true | no `MATCH` token adjacency |
| E7 | **SCORECARD.md:1852** | `Registry stays 114` — the registry row count | 114 | SOURCES.md rows | true | no class shape |
| E8 | **LOG.md:1927 / lesson:9** | `a clock stated `-> 1` against a body giving 2` — a clock's stated vs actual count | 1, 2 | varies | historic | not a class shape |
| E9 | **SCORECARD.md:1850** | `population closed at 10` — the pop size again, in prose | 10 | A4=10 | true | no `N clocks` adjacency |
| E10 | **SCORECARD.md:1850** | `10/10` also appears as the `RECHECK_REPLAY: CLEAN` gate; and `grep/pdf/locate` filter forms | — | — | — | — |

**The load-bearing point:** E2, E3 and E4 are the *same three quantities* the class is supposed to
police (pop fraction, epoch count, clock count), stated in a shape one word away from the regex.
Each is currently **true**. That is the whole point of the class, and the class does reach them —
but only by lexical coincidence of the exact phrase. A future round that paraphrases the same
number into a neighbouring shape drops it out of the population with no `value` movement and no
`population` movement.

### 3b. Demonstrated evasion probes (all on scratch copies, all rc=0)

Each probe takes a statement that the class *should* police, makes it **false**, and shows the
counter's `value` does not notice.

| probe | edit | expected if policed | observed | verdict |
|---|---|---|---|---|
| **P1** | LOG.md:1926 `SIX epochs` → `SEVEN epochs` | epochs MISMATCH | `value=3 population=16` (unchanged) | **EVADES** — epoch count now false, undetected |
| **P2** | LOG.md:1928 `only at 10/10.` → `only at 3/10.` | pop MISMATCH | `value=3 population=16` (unchanged) | **EVADES** — pop fraction now false, undetected |
| **P5** | LOG.md:1924 `four freeze epochs land` → `four epochs land` | epochs MISMATCH | `value=2 population=15` | **EVADES by paraphrase** — dropping the word `freeze` removes the *falsely-stated* 4 from the population entirely; the stale claim is no longer counted at all (population 16→15) |
| **P6** | LOG.md:1928 `10 manifest rows` → `12 manifest rows` | clocks MISMATCH | `value=3 population=16` (unchanged) | **EVADES** — clock count now false, undetected |
| **P19** | SCORECARD.md:1850 `18 cases` → `18 selftest cases` | cases MISMATCH | `value=2 population=15` | **EVADES by paraphrase** — the stale "18" leaves the population; `CASES_RE` is `([0-9]+) cases` |
| **P7** | lesson:9 `selftest 18→20 cases` → `selftest 20→18 cases` | cases MISMATCH | `value=4` | **CORRECT** — `CASES_RE` matches the trailing `18 cases` |
| **P3** | SCORECARD.md:1850 `10/10 MATCH` → `9/10 MATCH` | pop MISMATCH | `value=4` | **CORRECT** — `POP_RE` fires |
| **P8** | SCORECARD.md:1852 insert `3 cases` (no `recheck-replay` on the line) | out-of-class → unbound | `value=4 population=17`, `UNBOUND` | **CORRECT-ish** — the checker emits `no-named-instrument` → UNBOUND, but the final line still prints `unbound=0` (see §4.3) |

**P5 and P19 are the important pair.** They do not merely hide a false number — they *delete the
statement from the population*. A statement that is not counted cannot be wrong. The population
floor (8) is what is supposed to catch a shrinking census, and P5/P19 do shrink it (16→15) while
still passing the floor; the landing only reads `value=0`, so a population that has quietly lost
its stale members reaches `value=0` with **one fewer check performed**. The `K1-F8` control
(delete the statements entirely → `population=13` → `FAIL`) covers gross shrinkage only.

### 3c. Other numeric shapes a reader could mistake for a class member

These are inside the surface and are *not* of the four classes; I list them so the class ceiling
is explicit rather than accidental.

| file:line | text | why a reader might mistake it |
|---|---|---|
| SCORECARD.md:1850 | `column-0 header refusal` | a `0` that is a column index |
| SCORECARD.md:1850 | `ISO/2xx/bijection` | `2xx` reads like a count |
| SCORECARD.md:1850 | `bijection refuses byte-identical bodies under two ids` | word-number `two`, near an epochs-style count |
| SCORECARD.md:1850 | `sha256+bytes+registry-row+capture-path` | `256`, a byte count |
| SCORECARD.md:1850 | `r1–r5` | a numeric range |
| SCORECARD.md:1846 | `epoch-E \`dd31b786\` and interim candidate \`bcf07e7\`` | revision hashes, and `epoch-E` is a **letter+revision** — exactly the `LETTER_REV_RE` anchor shape |
| LOG.md:1926 | `selftest 18` / `selftest 20` / `plan selftest token 18→20` | **selftest case counts stated without the word `cases`** — same authority as the CASES class, different shape |
| LOG.md:1926 | `-> 1x`, `-> 1.0`/`1_0`, `(?![0-9A-Za-z_.])` | numeric literals in a regex |
| LOG.md:1926 | `2026-13-40` (refused date), `F15`, `F28`, `F11b`, `m31`, `R56MutCounter-2` | control ids and dates |
| LOG.md:1926 | `GATE_SHA256_PIN \`b6959d6c\`` | hash + a `G`…`F` letter |
| LOG.md:1931 | `14 seats v1` | a wave-population count |
| lesson:9 | `grep -c ×8, pdftotext\|grep -c ×1, rendered-text locate ×1` | **the filter-form split — which I independently verified is exactly correct: grep ×8, pdf ×1, locate ×1** (my own parse of the 10 clocks) |
| lesson:9 | `10 clocks across 8 entries` | `8 entries` — I independently confirmed 8 distinct knowledge entries carry the 10 clocks |
| lesson:5 | `23 MATCH, 0 tar errors` | `0 tar errors` — a second number on a MATCH line |

---

## 4. Statements the checker misses or mis-binds

### 4.1 MIS-BOUND — the receipt-path rule is order-based, not adjacency-based

`plans/round-57-c1-check.py` binds `N MATCH` to a receipt path **by order of appearance**, not by
proximity:

```python
recs = RECEIPT_RE.findall(line)
if recs and len(recs) == len(ms):
    pairs = [(int(m.group(1)), recs[j]) for j, m in enumerate(ms)]
```

The `N MATCH` numbers and the receipt paths are zipped by index. Probe **P11** — one line with
`16 MATCH and 23 MATCH in \`…epochF.txt\` and \`…epochB.txt\`` — produces:

```
STMT SCORECARD:3 cls=match stated=16 auth=23 via=receipt-epochF MISMATCH
STMT SCORECARD:3 cls=match stated=23 auth=16 via=receipt-epochB MISMATCH
```

The text plainly pairs `16 MATCH` with `epochB` (16) and `23 MATCH` with `epochF` (23) by
adjacency — the correct reading — but the checker binds them crosswise and reports **two false
mismatches**. Probe **P15** (same facts, correct order `epochF` then `epochB`, matching the
number order) yields zero mismatches. So the checker's answer depends on whether the author
happened to list receipts in the same order as the numbers. The plan's POP text says the binding
is by **order** for the multi-receipt case, so the checker implements the plan as written — but the
plan's own wording is what makes this fragile, and the plan's "a statement's subject is resolved
by the line's own text" ceiling does *not* cover order-sensitivity.

The trigger condition is also brittle: the order branch fires only when `len(recs) == len(ms)`.
Probe **M3** (delete the receipt path from SCORECARD.md:1846, leaving `23 MATCH;`) makes the
checker fall back to the nearest-letter rule and bind `23 MATCH` to **epochE** (auth 22) → false
MISMATCH; the same holds for the lesson line in **M3b** (`LESSON:5 → nearest-epochE`).

### 4.2 MIS-BOUND (label) — `via=receipt-file-count` does not describe what is measured

The checker reports `via=receipt-file-count` for the EPOCHS class, and its docstring says the
authority is "the number of `.ufo/waves/round-56/controls/controls-prefreeze-epoch*.txt` files".
But `epoch_declared()` actually counts the **distinct `epoch-[A-F]` tokens in `plans/round-56.md`**:

```python
def epoch_declared(root):
    ... re.findall(r"epoch-([A-F])\b", text) ...
```

These two authorities are **not equal**: the tree has **5** lettered epoch receipt files
(`epochB…epochF`; there is no `epoch-A` receipt) but **6** distinct epoch tokens in the plan.
The count used (6) is the correct one for the plan's POP — it matches the plan's "six the plan
declares" — but the *label* is wrong, and anyone auditing by the label would recompute 5 and
conclude the checker is off by one. The plan's own motivating evidence says the lesson's
"Three freeze epochs" is wrong "against the six the plan declares", confirming 6 is intended.
**The value is right; the label is misleading.** Same pattern for `via=pop-size`/`pop-match` on the
`N/N MATCH` class, which is bound to `clocks_auth` for *both* halves — the numerator of a
pop-fraction is a match count, and binding it to the row count happens to be right only because
both are 10 here (P3: `9/10` → numerator 9 vs 10 → MISMATCH, which is the intended behaviour here
but is not what the label says).

### 4.3 MIS-REPORTED — `unbound=0` is a literal, not a measurement

```python
print(f"CURRENT_CLAIMS: value={value} population={population} "
      f"mismatches={bad} unbound=0 cases=...")
```

`unbound=0` is hard-coded. Probe **P4** (drop the backticks around the epoch-B revision in
LOG.md:1926) yields a genuine `UNBOUND` statement — `STMT LOG:3 cls=match stated=16 auth=none
via=nearest-epochA UNBOUND` — and the summary still prints `unbound=0`, folding it into
`mismatches=4`. The `value` is still correct (UNBOUND counts toward `bad`), but the **counter
line lies about its own breakdown**, and the plan's predicate names MISMATCH and UNBOUND as
separable terms. The committed sibling gate `corpus/current-claims.py` gets this right (it
increments a real `unbound` counter and prints it), so the two gates will **disagree in format**
even when they agree in value — a real hazard for kill-rule (c), which requires the two to agree.

### 4.4 MISSED — the checker never re-reads the surface's own receipt path for existence

`receipt_match()` returns `None` (→ UNBOUND) for epoch **A**, because no `epoch-A` receipt file
exists, while `plans/round-56.md` declares epoch A. Any future statement naming `epochA.txt`
would be UNBOUND, and — per §4.3 — the counter would report `unbound=0`.

### 4.5 MISSED (surface-relative line numbers) — the checker's `STMT` lines are section-relative

The checker prints `SCORECARD:3`, `LOG:1`, `LESSON:9`. These are **offsets inside the extracted
section**, not file lines. The real file lines are SCORECARD.md:1846, LOG.md:1924,
lesson:9. Anyone auditing by the printed line will look at the wrong line of a 1855-line file.
Not a counting defect, but the checker's `--verbose` output is the natural audit surface and it is
ambiguous.

### 4.6 MISSED (fragility) — the lesson surface window is whitespace-sensitive

`lesson_surface()` ends the header at "the first blank line after `Frozen plan:`". Probe **P9**
(delete that blank) shifts the reported line from `LESSON:9` to `LESSON:10` — the *same statement*
is re-counted at a different offset. Probe **P18** (delete both blanks) makes the header swallow
the `## Claims` body, so the lesson's epochs statement is counted **twice**
(`population=20`, `epochs=3`, `value=4`) — a whitespace-only edit changes the value. Probe **P12**
(insert a `## Extra` heading inside `## Claims`) truncates the claims section at the new heading;
here the value is unchanged, but the census silently loses whatever follows. This is a real
fragility of a surface defined by formatting.

---

## 5. Class-evasion candidates — named list

For each: the statement, why it escapes, and the mutation that proves it.

1. **E2 — LOG.md:1928 `only at 10/10.`** (pop fraction without the `MATCH` token). Escape: `POP_RE` needs `N/N MATCH`. Proof: **P2** (`3/10.` → `value` unchanged).
2. **E3 — LOG.md:1926 `SIX epochs`** (epoch count without `freeze`). Escape: `EPOCHS_RE` needs `W freeze epochs`. Proof: **P1** (`SEVEN epochs` → `value` unchanged).
3. **E4 — LOG.md:1928 `10 manifest rows`** (manifest row count without `clocks`). Escape: `CLOCKS_RE` needs `N clocks`. Proof: **P6** (`12 manifest rows` → `value` unchanged).
4. **P5 — paraphrase `four freeze epochs` → `four epochs`** (drops the stale claim out of the population entirely; `population` 16→15). The word `freeze` is load-bearing.
5. **P19 — paraphrase `18 cases` → `18 selftest cases`** (drops the stale claim out of the population; `population` 16→15). `CASES_RE` requires `N cases` adjacency.
6. **LOG.md:1926 `selftest 18` / `selftest 20` / `plan selftest token 18→20`** — the CASES class's own quantity (the instrument's selftest case count) stated without the word `cases`; the class never binds it. Currently true for epoch C/D/E, but it is the same authority the CASES class polices.
7. **LOG.md:1928 `RECHECK_REPLAY: CLEAN` only at 10/10** vs **SCORECARD.md:1850** `only at 10/10 MATCH` — the *same* pop-fraction fact is counted in one file and not the other, purely on the trailing token.

Secondary (shape, not class): **LOG.md:1927 / lesson:9** `-> 1` vs `giving 2` (a clock's stated vs
actual count); **SCORECARD.md:1850** `population closed at 10`; **SCORECARD.md:1852** `Registry stays 114`;
**LOG.md:1930** `all six stay 9 → 9`; **LOG.md:1931** `candidate 10/guard=1`.

---

## 6. Observations for the L1 (not counted, no action required of me)

- **The landing reads clean.** `bash plans/round-57-c1.sh HEAD` → `C1_CURRENT: value=0 population=16 gate=1 challenge=1 guard=1`, rc=0. The committed gate `corpus/current-claims.py` agrees with the frozen checker at both ends: BASE → `value=3 population=16`; HEAD → `value=0 population=16`. Kill-rule (c) (the committed gate's `--root` reading must equal the frozen checker's) **holds**.
- **All three repairs are genuine.** My independent authorities confirm the repairs are needed and that the repaired values are right: `18`→`20` cases (A1=20), `four`→`six` freeze epochs (A3=6), `Three`→`Six` freeze epochs (A3=6). Probe **P17** (all three applied) → `value=0 population=16`, matching the landing.
- **The lesson's `Three freeze epochs` sentence still enumerates only A–D** after the count word is repaired to `Six` (probe **P16**: `value` 3→2, the statement is counted but the *sentence* remains internally inconsistent — it says six and lists four). Same for the "three freeze epochs" wording in SCORECARD/LOG. Worth a prose pass, since the class only reads the count word.
- **Controls battery now reads 13 MATCH / 0 MISMATCH, rc=0.** Note: the lane amended the instruments **mid-seat** (11:31) while I was working; the first battery run I did read `match=10 mismatch=2` and threw two shell syntax errors (`plans/round-57-c1.sh: line 48: syntax error near unexpected token '}'`, `plans/round-57-controls.sh: line 109: base: command not found`) because it was executed against a half-written file. The re-run against stable files is clean. **`plans/round-57-c1-check.py` was NOT amended** — sha256 `19d75337ce37259b08eaa8b960eedddac68bec70ed4eab3f55f9d621e142f72c` before and after; the checker source I read is the one that produced every reading above.
- **Recommendation for the reusable gate `corpus/current-claims.py` (the C1 landing's deliverable):** it currently inherits the checker's lexical rules verbatim, so it inherits evasions 1–7 and the `unbound=0` literal. Since the class set is *declared closed*, this is a legitimate ceiling — but the plan should say plainly that the closed set is **lexically closed** (exact phrases only), not **semantically closed**, and the ceiling list should name the paraphrase routes P5/P19 explicitly. If the L1 wants the class to survive paraphrase, the regexes need `freeze epochs?` and `N cases` to tolerate an intervening adjective — that is a re-freeze, not a repair, and it is the L1's call, not mine.

---

## 7. Commands and rc (exact)

```
cd /home/vgpnk/Projects/shokunin/kagi-shokunin
git rev-parse --show-toplevel                          -> /home/vgpnk/Projects/shokunin/kagi-shokunin
git archive 1cda9e7ae4767b4133e283bfbc08266d4c86362d | tar -x -C <scratch>/base     rc=0
python3 -I -B corpus/recheck-replay.py --selftest      -> PASS (20 cases)              rc=0
grep -h '^CONTROLS:' .ufo/waves/round-56/controls/controls-prefreeze*.txt             rc=0
grep -o 'epoch-[A-F]' plans/round-56.md | sort -u       -> 6 tokens                    rc=0
awk '!/^#/ && !/^id\t/ && NF' corpus/recheck-captures.tsv -> 10 data rows                rc=0
ls .ufo/waves/round-56/controls/ | grep -c 'controls-prefreeze-epoch[A-F]\.txt' -> 5    rc=0
python3 -I -B plans/round-57-c1-check.py --root <scratch>/base --verbose               rc=1 (value=3)
bash plans/round-57-c1.sh 1cda9e7ae4767b4133e283bfbc08266d4c86362d                    rc=0 (value=3 population=16)
bash plans/round-57-c1.sh HEAD                                                         rc=0 (value=0 population=16)
python3 -I -B corpus/current-claims.py --root <scratch>/base                           rc=0 (value=3 population=16)
python3 -I -B corpus/current-claims.py --root <scratch>/head                           rc=0 (value=0 population=16)
HYAKU_SCRATCH=<scratch> bash plans/round-57-controls.sh                                 rc=0 (match=13 mismatch=0)
<19 mutation probes on scratch copies, each: python3 -I -B plans/round-57-c1-check.py --root <scratch>/probe/<id> --verbose>
sha256sum plans/round-57*.{md,sh,py}                                                   rc=0
```

**No git/jj mutation** in the lane, the fleet or a sibling (read-only `git archive`/`git show`/
`git log`/`git status`/`git diff` only). **No production file edited** — the only writes are this
report and `.ufo/waves/round-57/w1/R57ScoutSurface.d/receipt.txt`, both under my seat path, plus
scratch under `/fast/scratch/hyaku/kagi-r57/R57ScoutSurface/`. No secrets, tokens, cookies or
vault material read, captured or printed. No host sysctl/boot/auth mutation. No network access.

**Answering model observed: MiniMax-M3.1-Flash.**
