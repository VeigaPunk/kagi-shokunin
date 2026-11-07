#!/usr/bin/env python3
"""Build the round-62 v1 wave spec (kagi). One wave, 14 seats, band 8-16."""
import json, os

LANE = "/home/vgpnk/Projects/shokunin/kagi-shokunin"
BASE = "60b5b7b60b76629633110a5b4adac883193c8b2a"
PRE = "8e5463c7937dccdd97fd5a812b8091f83b708aa7"
OUT = f"{LANE}/.ufo/waves/round-62/w1-spec.json"

GOD = """/skill:godspeed
You are a Godspeed-enabled subagent.

1. **Name the axes.**
2. **Iterate cheap, in parallel.**
3. **Keep moves that improve any axis and harm none.**
4. **Don't aim \u2014 let the frontier walk itself.**

## IMMEDIATELY STOP ASKING CLARIFYING QUESTIONS. Execute tool calls concurrently in large batches. Do not serialize what can run in parallel. Do not output philosophical reasoning or verbose plans. Act directly via tool calls.
# Assignment
"""

CONTEXT = f"""kagi round 62 attempt 1. ONE v1 wave, 14 seats (run-15 band 8-16; plan \u00a7Wave plan). L1 KagiR62 holds the canonical planner seat and is the sole integration owner and committer.
Lane repo: {LANE} (branch master). Claim BASE {BASE}. FROZEN predeclaration: {LANE}/plans/round-62.md (commit {PRE}) \u2014 read it, plus {LANE}/corpus/lessons/round-61-verifier-spotcheck.md \u00a77 and {LANE}/corpus/lessons/round-61.md, before you work. Never amend a frozen predicate, target, POP, kill rule or item condition; report a defect instead.
Write scope: {LANE} plus your own scratch. Never write, commit, push or run a mutating git/jj command in the fleet repo, a sibling lane, or the lane's jj/git index; never run `git add/commit/stash/push` or any mutating `jj` anywhere. Seats return findings and files; only the L1 commits (scripts/hyaku/jj-lane.sh).
File ownership is disjoint: write ONLY the paths your item names. Receipts go under {LANE}/.ufo/waves/round-62/build/<your-seat-name>/. Every `Report:` trailer path a wave template prints is relative to {LANE} \u2014 write it at {LANE}/<that path>. Never write citable evidence under /tmp.
Scratch: every clone, work tree, fixture or dev-server dir lives under ${{HYAKU_SCRATCH:-/fast/scratch/hyaku}}/kagi-r62/<seat-name>/ (mkdir -p; pass it explicitly; delete it before you yield). /tmp is only for files under 50 MB and never for citable evidence.
Tooling authorization (operator, 2026-10-19): you may install or upgrade tools that help the task; read /home/vgpnk/.omp/agent/RULES.md first (official channels only, update-safety gate, record tool/version/channel/reason in your report). pacman guard (orchestrator ruling 2026-10-20): ALL pacman transactions are PAUSED host-wide \u2014 install via uv tool / npx / an official binary in ~/.local/bin, or file an L0 question. Never -Sy/-Syu/-U/-R, never downgrade, never restart a host service. Never mutate host sysctls.
Secret discipline: no secret value, unseal key, root token, OTP, cookie, session id or vault/item/field name in any artifact or printed line. Generated keys/tokens stay inside your scratch dir and are deleted with it; receipts name shapes and counts only (QUALITY QM72). Fetch receipts remove Set-Cookie/Cookie values before they are written.
Absolute paths only: your tools start at the fleet root (/home/vgpnk/Projects/shokunin), not the lane.
OpenBao binary for trials: /home/vgpnk/.local/bin/bao (v2.7.2, sha256 9c5f36287c673f386e1533e9c044169a248e4ee50dd54810fa766e95bd41b788). Throwaway servers only, bound to 127.0.0.1, started under `setpriv --pdeathsig KILL`. OpenBao 2.7.2 on this host has NO `file` storage backend (`unknown storage type file`); use `storage "raft"` (with node_id/api_addr/cluster_addr) or `storage "inmem"`.
Host paths outside your scratch (/boot, /etc, /usr, /var, /efi, other users' homes) are read-only inputs: copy into scratch before working on a file, and never run a binary-editing tool with a host path as input or output. Never message agent://all; the L1 messages seats by id.
The round's two claims: C1 calibration (the C1 checker's negation/swapped-pairing bypass class, accepted 5 -> 0) and C2 operability (the C2 counter's guard and self-invocation, killed 0 -> 3). The five bypass fixtures and three paraphrase fixtures are frozen in plan \u00a7C1; the three C2 legs (M-A, M-B, G) in plan \u00a7C2."""


def item(name, role, axes, target, change, acceptance):
    prompt = GOD + f"# Target\n{target}\n\n# Change\n{change}\n\n# Acceptance\n{acceptance}\n"
    return {"name": name, "role": role, "axes": axes, "prompt": prompt}


ITEMS = [
    item(
        "R62ScoutSources", "scout", ["freshness", "coverage"],
        f"Open the round's candidate sources live and produce the located-quote evidence the registry rows and the lesson Gate need. Non-goals: no edit to {LANE}/corpus/SOURCES.md (the L1 appends), no other lane file.",
        f"""Read `{LANE}/plans/round-62.md` §Frontier step and `{LANE}/corpus/SOURCES.md` header (contract v1). Fetch with a desktop user agent (e.g. `curl -sS -A 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131 Safari/537.36' --compressed`), and for every page you open:
1. save the decoded body under `{LANE}/.ufo/waves/round-62/capture/<id>.body`; record HTTP status, byte count and `sha256sum`.
2. locate a <=25-word quote that grounds a learner benefit with `python3 {LANE}/corpus/rendered-text-v1.py locate <body> "<quote>"` \u2014 it must print `count=1`; record the quote, its location (section/heading) and the locate output.
3. write `{LANE}/.ufo/waves/round-62/capture/notes.md`: one block per page with URL, access date (2026-11-07), status, bytes, sha256, quote, location, locate output, and an admit/reject verdict with reason.

Candidates (open at least three, admit at least two, reject at least one):
- mutation testing, the kill/survive definition: `https://pitest.org/` and `https://stryker-mutator.io/docs/` (also `https://stryker-mutator.io/docs/mutation-testing/` if it exists). A page that only markets a product without defining a killed/surviving mutant is a reject with reason and flip.
- negation detection: `https://pubmed.ncbi.nlm.nih.gov/11554662/` (Chapman et al., NegEx). If the abstract does not carry a locatable sentence about identifying negated findings, reject it with the measured reason.
- one lead you judge weak (e.g. a wiki page) as the reject if the two above both admit.
Never write a credential, cookie or session value into a capture or note; strip `Set-Cookie`/`Cookie` lines from headers you record.""",
        f"""`{LANE}/.ufo/waves/round-62/capture/notes.md` exists with >=3 page blocks, >=2 admits and >=1 reject; every admitted quote resolves `count=1`; every capture file is under the capture dir (never /tmp); no credential material in any note. End with `SEAT-STATUS: complete` or `SEAT-STATUS: partial <reason>`.""",
    ),
    item(
        "R62ScoutPreState", "scout", ["calibration", "operability"],
        f"Independent pre-state census of the two claims at BASE {BASE}: re-derive accepted=5, killed=0 and guard=1 from your own scratch copies. Read-only: no lane file edited.",
        f"""Read `{LANE}/plans/round-62.md` §C1 and §C2 (the frozen fixtures and legs). Work only in ${{HYAKU_SCRATCH:-/fast/scratch/hyaku}}/kagi-r62/R62ScoutPreState/.
1. `git -C {LANE} archive {BASE} | tar -x -C <scratch>/base` (mkdir the dir first). Record the BASE checker's `sha256sum` and `wc -l`.
2. Build the five bypass copies from the plan's §C1 table (each substitution must occur exactly once; assert the count) and run `python3 -I -B plans/round-61-c1-check.py --root <copy> --repo {LANE} --no-challenge` in each. Record the `C1_ROUTED:` line and rc for all five and for the unmodified copy.
3. Copy `plans/round-61-c2.sh` twice: M-A replaces the main aggregation block (`value=0` + the `[ "$pass" = 5 ] … value=5` block) with `value=5`; M-B replaces `    && broken41 "${{OUT[sh$n]}}" && shims_ok=$((shims_ok+1))` with `    ; shims_ok=$((shims_ok+1))`. Run `bash plans/round-61-c2.sh --selftest` in each copy; record rc and the last line.
4. Build a guard-challenge copy: replace `corpus/openbao-seal-trial.sh` with a 2-line stub that exits 0 and prints nothing; run `bash plans/round-61-c2.sh --tree <copy>`; record the `C2_SEAL_TRIAL:` line and rc.
5. Record the BASE selftest case counts: `python3 -I -B plans/round-61-c1-check.py --selftest` and `bash plans/round-61-c2.sh --selftest`.
Write `{LANE}/.ufo/waves/round-62/build/R62ScoutPreState/prestate.md` with every command and its exact output. Every number derived, never quoted from the plan.""",
        f"""`prestate.md` carries: BASE checker sha256/lines; five `C1_ROUTED: value=0 …` lines with rc 1; the unmodified copy's line; M-A and M-B `C2_SELFTEST: PASS (cases=11)` rc 0; the stub tree's `value=0 … guard=1` rc 1; both selftest case counts. End with `SEAT-STATUS: complete` or `SEAT-STATUS: partial <reason>`.""",
    ),
    item(
        "R62ExecC1Grammar", "executor", ["calibration"],
        f"Harden `{LANE}/plans/round-61-c1-check.py` so the five frozen bypass fixtures read unresolved while the unmodified tree still reads `value=0`. You own that one file plus your receipts.",
        f"""Read `{LANE}/plans/round-62.md` §C1 (the item table, the hardened grammar and the negator set) and the current `plans/round-61-c1-check.py` (1454 lines; items I3–I7 at `:521-690`, selftest at `:1082`).
Implement exactly the plan's five rules:
- I3: an occurrence of `withdrawn` whose 12-token window before it contains `A3 item 2` and whose 5-token window before it (truncated at the nearest `.`, `;` or `:`) contains no negator.
- I4/I5: no negator in the 5-token window before `three` / `rewritten in place` (same truncation).
- I6: the correction line must also carry a `HH:MM:SS` time that is neither the launch line's time nor a derived committer time (the superseded paragraph's stamp).
- I7: the derived fraction and its derived percentage must be paired in one expression (`3/16 = 18.75 %`, `4/16 = 25 %`, whitespace-tolerant).
Negators: `not`, `no`, `never`, `neither`, `nor`, `without`, `none`, `n't` (case-insensitive, word-boundary); `not only` immediately before the match is not a negator. Keep the output line shape (`C1_ROUTED: value=V population=7 i1=.. i7=.. guard=G`), the modes (`--root`, `--repo`, `--no-challenge`, `--selftest`, `--json`) and every existing selftest case.
Add selftest cases: B3..B7 (each must read unresolved on its copy), P3..P5 (each must read resolved), and one case that removes the negator test (must fail). Target `C1_CHECK_SELFTEST: PASS (cases=N)` with N >= 57.
Run the five fixtures and the three paraphrases yourself on copies under your scratch; record every `C1_ROUTED:` line and rc in `{LANE}/.ufo/waves/round-62/build/R62ExecC1Grammar/grammar.md` together with the new `sha256sum` and `wc -l` of the checker.""",
        f"""`python3 -I -B plans/round-61-c1-check.py --selftest` exits 0 with `C1_CHECK_SELFTEST: PASS (cases=N>=57)`; the unmodified BASE copy reads `value=0`; B3..B7 each read `value>=1` with exactly their own item 0; P3..P5 read `value=0`; `grammar.md` records every command and output. End with `SEAT-STATUS: complete` or `SEAT-STATUS: partial <reason>`.""",
    ),
    item(
        "R62ExecC1Counter", "executor", ["calibration", "operability"],
        f"Write `{LANE}/plans/round-62-c1.sh`, `{LANE}/plans/round-62-bypass.tsv` and `{LANE}/plans/round-62-paraphrase.tsv` per the frozen C1 predicate. You own those three files plus your receipts.",
        f"""Read `{LANE}/plans/round-62.md` §C1 (frozen predicate, fixture tables, kill rules) and the house counter shape `{LANE}/plans/round-61-c1.sh` (108 lines).
`round-62-bypass.tsv` and `round-62-paraphrase.tsv`: header `id<TAB>file<TAB>anchor<TAB>replacement`, one row per fixture exactly as the plan's tables state (no tabs inside a cell). The counter:
- modes: `[revision]` (default BASE), `--tree DIR`, `--no-challenge`, `--selftest`; scratch under ${{HYAKU_SCRATCH:-/fast/scratch/hyaku}}/kagi-r62/R62ExecC1Counter (honour TMPDIR; no write inside the measured tree).
- resolve the tree (revision → `git archive` into scratch; `--tree` → use as given), then run the tree's `plans/round-61-c1-check.py --selftest` and require `C1_CHECK_SELFTEST: PASS (cases=N)` with N >= 57 BEFORE any verdict.
- for each bypass fixture: copy the tree, apply the substitution (exactly one occurrence, else SETUP), run the checker `--no-challenge`, parse `value=`; accepted++ iff value==0.
- guard legs: (a) the unmodified copy reads value=0; (b) selftest PASS N>=57; (c) a stub-checker tree (checker replaced by a file printing a constant `C1_ROUTED: value=0 …` line) produces no `C1_BYPASS:` verdict and a non-zero exit; (d) the three paraphrase fixtures each read value=0.
- print exactly one line: `C1_BYPASS: accepted=A population=5 guard=G (real=… selftest=… stub=… paraphrase=…)`; exit 0 iff guard=1 and accepted=0; 1 otherwise; 2 SETUP.
Receipts in `{LANE}/.ufo/waves/round-62/build/R62ExecC1Counter/`: the BASE run (`bash plans/round-62-c1.sh {BASE}` \u2192 accepted=5 guard=0, rc 1), the candidate run (`--tree {LANE}` \u2192 accepted=0 guard=1, rc 0), `--selftest`, the stub tree and a paraphrase run, plus `sha256sum` of the three files.""",
        f"""The three files exist; the BASE run prints `accepted=5 population=5` and the candidate run `accepted=0 population=5 guard=1` with the stated exit codes; the stub tree yields no verdict line and a non-zero exit; receipts carry every command and output. End with `SEAT-STATUS: complete` or `SEAT-STATUS: partial <reason>`.""",
    ),
    item(
        "R62ExecC2Counter", "executor", ["operability"],
        f"Harden `{LANE}/plans/round-61-c2.sh` (markers, `decide`, shim aggregation, guard observables, selftest) and write `{LANE}/plans/round-62-c2.sh` per the frozen C2 predicate. You own those two files plus your receipts.",
        f"""Read `{LANE}/plans/round-62.md` §C2 (frozen predicate, legs M-A/M-B/G, kill rules) and the current `plans/round-61-c2.sh` (389 lines; aggregation at `:320-325`, selftest at `:150-205`, guard at `:380`).
Hardening of `plans/round-61-c2.sh`:
- put `# BEGIN-DECIDE` / `# END-DECIDE` around a `decide()` function that takes the six leg values (pass, shims, none, selftest, ops, t2w) and echoes the value 0|5; the main path calls it.
- put `# BEGIN-SHIMS` / `# END-SHIMS` around a `shim_count()` function that takes the five shim output files and echoes 0..5; the main path calls it.
- `--selftest` must call both functions with positive and negative vectors (e.g. `decide 5 5 1 1 1 1` = 5, `decide 4 5 1 1 1 1` = 0, `decide 5 4 1 1 1 1` = 0, `shim_count` on a bad vector < 5) so a constant-returning mutant fails a case; keep every existing case and reach `C2_SELFTEST: PASS (cases=N)` with N >= 17.
- the guard must require each leg's expected observable (the trial's `SEAL_SELFTEST: PASS (cases=N)` line, the ops argv shapes, the T2 markers), not just a captured rc, so a valid-sha256 stub trial that prints nothing reads `guard=0`.
- the real trial must still read `value=5 … shims=5 vectors=ok/5`.
`plans/round-62-c2.sh`: modes `[revision]`/`--tree DIR`/`--selftest`; legs M-A (replace the lines strictly between the DECIDE markers with `  echo 5`), M-B (replace the lines strictly between the SHIMS markers with `  shims_ok=5`) \u2014 each must make the measured counter's `--selftest` exit non-zero printing a named `FINDING`; G (a copy whose trial is a valid-sha256 stub that prints nothing must read `guard=0`); guard (a) unmutated selftest PASS N>=17, (b) the counter on the real trial reads value=5 shims=5. Print exactly one line: `C2_HARDENED: killed=K population=3 guard=G (ma=… mb=… g=… selftest=… real=…)`; exit 0 iff guard=1 and killed=3; 1 otherwise; 2 SETUP.
Receipts in `{LANE}/.ufo/waves/round-62/build/R62ExecC2Counter/`: the BASE run (`bash plans/round-62-c2.sh {BASE}` \u2192 killed=0 guard=0, rc 1), the candidate run (\u2192 killed=3 guard=1, rc 0), the selftest, the three legs, the real-trial line, and `sha256sum` of both files. The real trial starts throwaway OpenBao servers: 127.0.0.1 only, `setpriv --pdeathsig KILL`, scratch only.""",
        f"""Both files exist; the BASE run prints `killed=0 population=3` and the candidate run `killed=3 population=3 guard=1`; the real trial reads `value=5 … shims=5`; the stub-trial tree reads `guard=0`; receipts carry every command and output; no secret shape in any receipt. End with `SEAT-STATUS: complete` or `SEAT-STATUS: partial <reason>`.""",
    ),
    item(
        "R62ExecControls", "executor", ["calibration", "operability"],
        f"Write `{LANE}/plans/round-62-controls.sh`, the pre-freeze control battery for both claims, and run every leg that the instruments already support. You own that one file plus `{LANE}/.ufo/waves/round-62/controls/`.",
        f"""Read `{LANE}/plans/round-62.md` (both predicates and kill rules) and the house battery `{LANE}/plans/round-61-controls.sh` (813 lines, 18 controls).
The battery must, from a BASE extraction and a candidate tree:
- K1-BASE: BASE tree \u2192 C1 accepted=5, C2 killed=0 (the do-nothing control).
- C1-F1..C1-F5: each bypass fixture applied to the candidate tree \u2192 the hardened checker reads `value>=1` (the forgery is rejected).
- C1-F6: a stub-checker tree \u2192 the C1 counter prints no verdict line and exits non-zero.
- C1-F7: the three paraphrase fixtures on the candidate tree \u2192 `value=0` (no false positive).
- C2-F1..C2-F3: M-A, M-B and G on the candidate tree \u2192 killed (non-zero selftest with a `FINDING`; `guard=0` for G).
- C2-F4: the real trial on the candidate tree \u2192 `value=5 … shims=5`.
- C2-F5: a constant-verdict counter copy \u2192 refused.
Each control prints `CONTROL <id> expect=<…> observed=<…> verdict=match|mismatch`; the battery ends `CONTROLS: match=N mismatch=M`, exit 0 iff mismatch=0. Write the receipt to `{LANE}/.ufo/waves/round-62/controls/controls-prefreeze.txt`; if an instrument is not yet present, record `CONTROL <id> observed=absent verdict=skip` and say so \u2014 the L1 re-runs the full battery before the candidate reading.""",
        f"""`plans/round-62-controls.sh` exists, is executable, honours HYAKU_SCRATCH, and its receipt `controls-prefreeze.txt` carries one line per control with expect/observed/verdict and the final `CONTROLS:` line; every skipped control names the absent instrument. End with `SEAT-STATUS: complete` or `SEAT-STATUS: partial <reason>`.""",
    ),
    item(
        "R62ScribeEntry", "scribe", ["depth", "freshness"],
        f"Draft `{LANE}/corpus/knowledge/claim-instrument-falsifiability.md`: the instrument contract entry for the round's two claims. You own that one file plus your build receipts.",
        f"""Read `{LANE}/plans/round-62.md`, the house entry shape (`{LANE}/corpus/knowledge/claim-ledger.md` and `checklist-execution.md`: header lines `source:`, `verified-at:`, `recheck:`, `Reverify:`), `{LANE}/corpus/QUALITY.md` (the admission bar QA1–QA9 and QM rows) and `{LANE}/.ufo/waves/round-62/capture/notes.md` when it exists.
Sections:
- **The bypass class** — a token-presence test accepts a negation (`not withdrawn`, `no three`, `not rewritten in place`) and a swapped pairing (`3/16 = 25 %`); the five measured trees and their readings.
- **The polarity rule** — the closed negator set, the 5-token window with the `.`/`;`/`:` truncation, the `not only` idiom, the 12-token `A3 item 2` window for I3.
- **The pairing rule** — a fraction and its percentage must be derived from the same pair and adjacent in one expression.
- **The mutation-kill contract** — a gate's `--selftest` must execute its own aggregation; a constant-aggregation mutant and an unconditional-aggregation mutant must fail it; a guard must have a challenge leg that reads 0 on a valid-but-incomplete tree.
- **§Measured** — accepted 5\u21920 over the five fixtures; killed 0\u21923 over M-A/M-B/G; the real trial unchanged at value=5 shims=5. Every number carries its command.
- **§Bounds** — the five fixtures are the reviewer's five (a sixth class is a new defect); a structural read proves assertion, not truth; the negator window is a floor; two mutation classes are not a complete set; the real leg needs `bao`.
- **§Falsifiers** — >=8 observations that would make the entry wrong.
Header: `source:` cites the new rows (S128/S129 as the L1 will assign; if the capture notes name different ids, use those and say so in your notes), `recheck: 180d`, `Reverify:` a claim row id (`R62-01`/`R62-02` placeholders are acceptable; the L1 re-points them). No credential material, no `|` inside a table cell, every count with its command.""",
        f"""The file exists with the seven sections and the header lines; >=8 falsifiers; every number carries its command; no credential material; the entry names the two claims' before\u2192after readings. Write `notes.md` with anything you could not ground. End with `SEAT-STATUS: complete` or `SEAT-STATUS: partial <reason>`.""",
    ),
    item(
        "R62ScribeRecords", "scribe", ["calibration", "operability"],
        f"Land the round's record surface: SKILL.md gate-registry rows (routed D2), QUALITY criteria QM81/QM82, and the `{LANE}/corpus/lessons/round-62.md` draft. You own those three files plus your receipts.",
        f"""Read `{LANE}/plans/round-62.md` §Routed-defect work items and §Frontier step, `{LANE}/corpus/lessons/round-61-verifier-spotcheck.md` §7, `{LANE}/SKILL.md:695-860` (the gate-registry tables and the round-58/59/60 additions), `{LANE}/corpus/QUALITY.md` tail (QM78–QM80) and `{LANE}/corpus/lessons/round-61.md` (house shape).
1. `SKILL.md`: add `## Gate registry — round-61 additions` with one row each for `plans/round-61-c1-check.py`, `plans/round-61-c2.sh`, `corpus/openbao-seal-trial.sh` and `## Gate registry — round-62 additions` with one row each for `plans/round-62-c1.sh`, `plans/round-62-c2.sh`, `plans/round-62-controls.sh`. Columns exactly as the existing table (`name | kind | entry command | verdict map | selftest | pinned values | write scope | owner`); a `kind: gate` row's selftest cell carries the runnable `--selftest` spelling and its case count, never `none of its own` (QM76).
2. `corpus/QUALITY.md`: append `QM81` (a structural item tests its token in the asserting position: a negation or a swapped pairing keeps every token and must read unresolved; a token-presence test is a declared ceiling) and `QM82` (a gate's self-invocation mode must execute its own aggregation; a constant or unconditional aggregation mutant must fail it, and a guard must read 0 on a valid-but-incomplete tree). Each cites `corpus/lessons/round-62.md` and the measured evidence (the five fixtures, M-A/M-B/G).
3. `corpus/lessons/round-62.md`: `## Gate` (for every new SOURCES row: URL, access date, <=25-word located quote \u2014 take them from `{LANE}/.ufo/waves/round-62/capture/notes.md` when it exists, else `pending capture`; plus >=1 admit and >=1 reject with reason and flip), `## Mistakes` (>=2 rows, shape `class \u00b7 evidence pointer \u00b7 captured-by \u00b7 fix`, each fix shown able to fail), `## Corrections` (the routed D1/D2/D4/D5 dispositions), `## Routed dispositions` (table D1\u2013D5 \u2192 item/file/state), `## Wave` (`pending results` \u2014 the L1 fills it from `w1-results.json`).
Never invent a number: every count carries its command. Never rewrite an existing line: append, and state what it supersedes (QM78).""",
        f"""`SKILL.md` carries the two new registry sections with six rows in the house column format; `QUALITY.md` carries QM81 and QM82 with evidence pointers; `corpus/lessons/round-62.md` carries the five sections, >=2 mistakes with fixes, and the Gate admit/reject pair. End with `SEAT-STATUS: complete` or `SEAT-STATUS: partial <reason>`.""",
    ),
    item(
        "R62Reviewer", "reviewer", ["calibration", "operability"],
        f"Attack both claims and their instruments. Read-only: no production file changed; receipts under `{LANE}/.ufo/waves/round-62/build/R62Reviewer/`.",
        f"""Read `{LANE}/plans/round-62.md` (both predicates), `{LANE}/corpus/lessons/round-61.md` and `{LANE}/.ufo/waves/round-61/build/R61Reviewer/findings.md` (the five bypasses this round closes).
1. Build >=6 NEW bypass trees beyond the frozen five: e.g. `never withdrawn`, `hardly withdrawn`, `not merely three`, `three` inside a quotation followed by a denial, a swapped pairing written with `%` glued (`3/16 = 25%` with `18.75` elsewhere), an I6 line with a fabricated `HH:MM:SS` stamp that is not in the derived set. Run the hardened checker (`plans/round-61-c1-check.py`, once the executor's version exists; otherwise the BASE bytes) on each and record accepted/rejected.
2. Attack the counters: a stub checker (`C1_BYPASS` must not print), a counter whose fixture application matches 0 times (must be SETUP, never accepted=0), a receipt that names a revision that does not exist, a paraphrase that the hardened grammar rejects (false positive).
3. Attack the C2 legs: a counter that prints `killed=3` without running the legs; a guard that reads 1 on the stub-trial tree; a real-trial receipt that cannot be re-derived.
Write `findings.md`: a table `id | attack | command | observed | verdict` and a `## Defects` section with ids and the fix each needs. Every "accepted" or "killed" you report must be reproduced by a command you ran.""",
        f"""`findings.md` carries >=8 attacks with command and observed output, a `## Defects` section, and no claim you did not run. End with `SEAT-STATUS: complete` or `SEAT-STATUS: partial <reason>`.""",
    ),
    item(
        "R62Critic", "critic", ["calibration", "operability"],
        f"Falsify the two predicates before the candidate reading. Read-only: receipts under `{LANE}/.ufo/waves/round-62/build/R62Critic/`.",
        f"""Read `{LANE}/plans/round-62.md` (frozen predicates, kill rules, populations) and `{LANE}/corpus/QUALITY.md` QM78–QM80.
Attempt at least six falsifications, each with a command and its observed output:
1. the do-nothing control: a tree with no round-62 work must read C1 accepted=5 and C2 killed=0 (build it from `git archive {BASE}`).
2. causal separability: C1's reading must not change when the C2 files are absent, and C2's must not change when the C1 files are absent.
3. fixture vacuity: a tree where a bypass anchor occurs twice (or zero times) must make the counter SETUP/fail closed, never count as rejected.
4. guard leg (c): a stub checker must not reach a verdict line.
5. guard leg (d): a benign paraphrase must read resolved; find a reasonable rewrite the hardened grammar rejects, if one exists.
6. the C2 guard: a valid-sha256 stub trial must read `guard=0` after the hardening, and the real trial must still read value=5.
7. the claim's arithmetic: re-derive 5 and 3 from the committed fixtures/legs, not from the plan's prose.
Write `critique.md` with the attempts, the observed output, and a `## Defects` section (id, severity, fix). If a predicate is unsound, say exactly which clause and why.""",
        f"""`critique.md` carries >=6 attempts with commands and observed output, plus a `## Defects` section; no unrun claim. End with `SEAT-STATUS: complete` or `SEAT-STATUS: partial <reason>`.""",
    ),
    item(
        "R62MutC1", "mutation-tester", ["calibration"],
        f"Mutation battery over the hardened C1 grammar and counter. Read-only: receipts under `{LANE}/.ufo/waves/round-62/build/R62MutC1/`.",
        f"""Read `{LANE}/plans/round-62.md` §C1 and the hardened checker/counter once they exist (otherwise the BASE bytes, and say so).
Apply >=8 mutants, each to its own copy in scratch, and record whether the checker's `--selftest` or the counter's guard kills it:
- remove the negator test from I3/I4/I5 (one mutant each);
- shrink the negator window to 0 tokens;
- drop the I6 superseded-stamp requirement;
- drop the I7 pairing (back to independent tokens);
- make the counter count `value>0` as accepted;
- make the counter's stub leg return 1;
- make the counter's paraphrase leg skip.
For each: the exact substitution, the command, the observed rc/last line, and `killed|survives`. Write `mutants.md` with the census (`MUTANTS: killed=K survives=S population=P`) and a `## Survivors` section naming each survivor as a defect with the fix.""",
        f"""`mutants.md` carries >=8 mutants with substitution, command, observed and verdict; the census line is derived; every survivor is named as a defect. End with `SEAT-STATUS: complete` or `SEAT-STATUS: partial <reason>`.""",
    ),
    item(
        "R62MutC2", "mutation-tester", ["operability"],
        f"Mutation battery over the hardened C2 counter. Read-only: receipts under `{LANE}/.ufo/waves/round-62/build/R62MutC2/`.",
        f"""Read `{LANE}/plans/round-62.md` §C2 and the hardened `plans/round-61-c2.sh` / `plans/round-62-c2.sh` once they exist (otherwise the BASE bytes, and say so).
Apply >=8 mutants, each to its own copy in scratch, and record whether the counter's `--selftest` or its guard kills it:
- `decide()` returns 5 always;
- the shim aggregation returns 5 always;
- the guard ignores the trial's `SEAL_SELFTEST` observable;
- the selftest skips its negative vector (only positive cases);
- the M-A needle matches zero times (the counter must SETUP, not read killed);
- the counter's exit code is always 0;
- the G leg reads the unmutated tree instead of the stub tree;
- the real-trial leg is skipped but the guard still reads 1.
For each: the exact substitution, the command, the observed rc/last line, and `killed|survives`. Write `mutants.md` with the census (`MUTANTS: killed=K survives=S population=P`) and a `## Survivors` section naming each survivor as a defect with the fix.""",
        f"""`mutants.md` carries >=8 mutants with substitution, command, observed and verdict; the census line is derived; every survivor is named as a defect. End with `SEAT-STATUS: complete` or `SEAT-STATUS: partial <reason>`.""",
    ),
    item(
        "R62Connector", "connector", ["adjacency", "coverage"],
        f"Sibling-overlap sweep and `considerthese/` mining for the round's ground. Read-only: receipts under `{LANE}/.ufo/waves/round-62/build/R62Connector/`.",
        f"""Read `{LANE}/plans/round-62.md`, `{LANE}/PROVINCE.md` §Adjacent and `{LANE}/corpus/README.md` (coverage map, overlaps).
1. Sweep every `*-shokunin` lane under /home/vgpnk/Projects/shokunin for ground this round touches: a gate whose self-invocation mode executes its aggregation; a structural record check with a polarity/negation test; a mutation-kill census; a guard challenge leg. Search `PROVINCE.md`, `SKILL.md`, `corpus/knowledge/`, `corpus/lessons/` and `plans/` for the terms (`mutation`, `negation`, `polarity`, `selftest`, `guard`, `bypass`). Report each hit with lane, path and whether it duplicates or is adjacent; never absorb.
2. Read `{LANE}/considerthese/` (operator-authored input; never edit). Pick at most ONE still-unimplemented proposal that fits this round's claims, open what it points at, and say whether it grounds a lesson, a QUALITY criterion or a SOURCES row. If nothing fits, say so with the sweep.
Write `sweep.md` (lanes searched, hits, duplicate/adjacent verdict) and `considerthese.md` (proposal, file+date, grounding, decision).""",
        f"""`sweep.md` names every lane searched and each hit with a duplicate/adjacent verdict; `considerthese.md` names at most one proposal with its grounding and decision, or the sweep that found none. No sibling file edited. End with `SEAT-STATUS: complete` or `SEAT-STATUS: partial <reason>`.""",
    ),
    item(
        "R62Sentinel", "sentinel", ["calibration", "adjacency"],
        f"Security and scratch-discipline review of the round's instruments and receipts. Read-only: receipts under `{LANE}/.ufo/waves/round-62/build/R62Sentinel/`.",
        f"""Read `{LANE}/plans/round-62.md`, `{LANE}/corpus/QUALITY.md` (QA5, QM72) and the round's new files once they exist (`plans/round-62-c1.sh`, `plans/round-62-c2.sh`, `plans/round-62-controls.sh`, `plans/round-62-bypass.tsv`, `plans/round-62-paraphrase.tsv`, `corpus/knowledge/claim-instrument-falsifiability.md`).
Check at least eight items, each with a command and observed output:
1. no credential material in any round artifact or receipt (scan for token/key/OTP/cookie shapes and for `op://`-style references \u2014 do not spell the scheme in your receipt);
2. the counters honour HYAKU_SCRATCH and TMPDIR and write nothing outside their scratch (run one with `HYAKU_SCRATCH=/proc` \u2014 it must fail closed, not write);
3. no write inside the measured tree (`find <tree> -newer <marker>` after a run);
4. the fixtures read only repo text, never a host-private path;
5. the C2 real-trial receipts carry shapes/counts only, no share, token or OTP value;
6. no host mutation by any instrument (no sysctl, pacman, service restart, no write under /boot, /etc, /usr, /var);
7. the wave's scratch dirs are removable and the round leaves none behind;
8. the counters' `--selftest` modes run with no network and no `bao` where they claim to.
Write `sentinel.md` with the checks, observed output, and a `## Findings` section (id, severity, fix).""",
        f"""`sentinel.md` carries >=8 checks with commands and observed output and a `## Findings` section; any credential-shaped hit is reported as a defect without quoting the value. End with `SEAT-STATUS: complete` or `SEAT-STATUS: partial <reason>`.""",
    ),
]

spec = {
    "wave": "kagi-r62-w1",
    "axes": ["calibration", "operability"],
    "milestone": "C1 C1_BYPASS accepted 5->0 (the C1 checker's negation/swapped-pairing bypass class closed); C2 C2_HARDENED killed 0->3 (the C2 counter's guard and self-invocation can fail); attack seats falsify both",
    "reportDir": ".ufo/waves/round-62/w1",
    "context": CONTEXT,
    "items": ITEMS,
}
os.makedirs(os.path.dirname(OUT), exist_ok=True)
with open(OUT, "w") as f:
    json.dump(spec, f, indent=1)
print("wrote", OUT, "items", len(ITEMS))
roles = {}
for it in ITEMS:
    roles[it["role"]] = roles.get(it["role"], 0) + 1
print("roles", roles)
attack = sum(roles.get(r, 0) for r in ("reviewer", "critic", "mutation-tester", "labrat"))
print("attack", attack, "/", len(ITEMS), "=", round(100.0 * attack / len(ITEMS), 2), "%")
