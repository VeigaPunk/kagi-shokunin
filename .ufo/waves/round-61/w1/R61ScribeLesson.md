# R61ScribeLesson — seat report (round 61 w1, lesson scribe)

SEAT-STATUS: complete

## Files written (all inside this seat's scope)

- `corpus/lessons/round-61.md` — the round lesson: `## Gate`, `## Mistakes`,
  `## Routed dispositions`, `## Wave`, `## Bounds`, `## Findings not covered by the frozen
  item set`. 18825 B.
- `.ufo/waves/round-61/build/R61ScribeLesson/` — receipts:
  `gate-quotes.txt`, `reject-candidate.txt`, `mistakes-evidence.txt`,
  `mistake-writescope.txt`, `mistake-trial-syntax.txt`, `c1-checker-i2-legs.txt`,
  `state-at-write.txt`, `notes.md`.
- `.ufo/waves/round-61/w1/R61ScribeLesson.md` — this report.

No other lane file was touched. No git/jj mutation was run anywhere; the lane HEAD is the
frozen predeclaration `8595018`.

## Behavior

- **Gate.** Three rows admitted (S125, S126, S127) with URL, access date 2026-11-07 and a
  ≤25-word located quote each, cited from the scout's ledger
  (`capture/notes.md` §1c, M3.1/M3.2, M4.3–M4.6) and re-resolved by this seat with
  `python3 corpus/rendered-text-v1.py locate` ⇒ `count=1` on all five quotes. One page
  opened and refused (`https://openbao.org/docs/configuration/seal/`: HTTP 200, 36231 B,
  sha256 `fcc49096…`; `threshold`/`key shares`/`progress`/`405`/`rekey`/`generate-root`
  all count 0 over the tag-stripped body) with a stated flip condition.
- **Mistakes.** Eight rows, each with class · evidence pointer · captured-by · fix, and a
  fix shown able to fail: M61-1 (round-60 D1), M61-2 (round-60 D7, 4/16), M61-3 (the
  report's unrouted 6/16 sibling), M61-4 (write scope, two instances: this seat's capture
  slip and the controls seat's `/tmp` trace), M61-5 (trial selftest parse error, fixed),
  M61-6 (C1 checker I2 legs, fixed), M61-7 (trial T4 route, fixed), M61-8 (C2 counter
  oracle gap, routed).
- **Routed dispositions.** D1–D7 ↔ I1–I7 with the carrying file and the state measured at
  write time; the checker reading quoted is `C1_ROUTED: value=0 population=7 i1..i7=1
  guard=1` rc 0 on the uncommitted working tree (`state-at-write.txt`), plus its
  `--no-challenge` leg.
- **Wave.** `pending results (the L1 appends the measured record)`; the dispatch's planned
  16-seat mix is quoted as the plan with its command, and no dead-seat count is stated.

## Findings handed to the L1

1. **C1 checker I2 legs (fixed during the wave, M61-6).** At 17:11 the checker read `i2=0`
   because (a) `plans/round-61-c1-check.py:377` splits the SKILL row on `|` without
   honouring the escaped `\|` in the entry-command cell (9 cells vs an 8-cell header, so
   the verdict-map cell was read as the selftest cell) and (b) `C2_PASS_RE` expects
   `(N cases)` while the script prints `(cases=N)`. The 17:12 checker (`d525ee28…`) reads
   `i2=1`. Receipt `c1-checker-i2-legs.txt`.
2. **I6's `-03:00` timestamps do not literally occur in `%ci` output** (`-0300`, space
   separator; literal count 0). The landed correction is satisfiable only under the
   normalisation the fix seat receipted. Reported, not amended.
3. **The round-60 report's `6/16 = 38 %` sibling figure is wrong and unrouted** (five
   attack seats ⇒ 5/16 = 31.25 %; `6/16` is 37.5 % even if the count were right). M61-3.
4. **The plan's motivating grep overstates its negative** (`grep -rlE 'unseal|shamir'
   corpus/knowledge/` ⇒ 6 at BASE, 7 now; `sops-age-key-rotation.md` measures a SOPS Shamir
   threshold).
5. **The C2 counter has no independent oracle** (reviewer §C2-3: a printer-stub trial reads
   `value=5 guard=1`). M61-8, routed to the next round's counter.

## Limits

- The C1 reading is on the uncommitted working tree; the committed-revision reading is the
  L1's.
- C2 is cited as state from the trial seat's receipts, not re-run by this seat.
- The wave record is pending `w1-results.json`.
- `capture/notes.md` appeared after this seat began; the quotes were first derived from the
  capture bodies and then re-aligned to the scout's ledger (both locators agree).

## Tooling

Nothing installed or upgraded. Read-only git, `python3`, `bash`, one `curl` fetch (the
rejected candidate), coreutils. Scratch `/fast/scratch/hyaku/kagi-r61/R61ScribeLesson/`
deleted before yield.
