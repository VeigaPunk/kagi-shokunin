#!/usr/bin/env python3
"""Build the round-63 v1 wave spec (kagi). One wave, 16 seats, band 8-16."""
import json

LANE = "/home/vgpnk/Projects/shokunin/kagi-shokunin"
FLEET = "/home/vgpnk/Projects/shokunin"
BASE = "0c07aab8df64b673a54a5113aebd7f34b622adbc"
PRE = "12c9e4284d6de52ba61fcc656165cd24e8b74480"
OUT = f"{LANE}/.ufo/waves/round-63/w1-spec.json"

GOD = """/skill:godspeed
You are a Godspeed-enabled subagent.

1. **Name the axes.**
2. **Iterate cheap, in parallel.**
3. **Keep moves that improve any axis and harm none.**
4. **Don't aim \u2014 let the frontier walk itself.**

## IMMEDIATELY STOP ASKING CLARIFYING QUESTIONS. Execute tool calls concurrently in large batches. Do not serialize what can run in parallel. Do not output philosophical reasoning or verbose plans. Act directly via tool calls.
# Assignment
"""

CONTEXT = f"""kagi round 63 attempt 1. ONE v1 wave, 16 seats (run-15 band 8-16; plan \u00a7Wave). L1 KagiR63 holds the canonical planner seat and is the sole integration owner and committer.
Lane repo: {LANE} (branch master). Claim BASE {BASE}. FROZEN predeclaration: {LANE}/plans/round-63.md (commit {PRE}) \u2014 read it, plus {LANE}/corpus/lessons/round-62-verifier-spotcheck.md \u00a72/\u00a76 and {LANE}/corpus/lessons/round-62.md, before you work. Never amend a frozen predicate, target, POP, kill rule, fixture or item condition; report a defect instead.
Write scope: {LANE} plus your own scratch. Never write, commit, push or run a mutating git/jj command in the fleet repo, a sibling lane, or the lane's jj/git index; never run `git add/commit/stash/push` or any mutating `jj` anywhere. Seats return findings and files; only the L1 commits (scripts/hyaku/jj-lane.sh).
File ownership is disjoint: write ONLY the paths your item names. Receipts go under {LANE}/.ufo/waves/round-63/build/<your-seat-name>/. Every `Report:` trailer path a wave template prints is relative to {LANE} \u2014 write it at {LANE}/<that path>. Never write citable evidence under /tmp.
Scratch: every clone, work tree, fixture or dev-server dir lives under ${{HYAKU_SCRATCH:-/fast/scratch/hyaku}}/kagi-r63/<seat-name>/ (mkdir -p; pass it explicitly; delete it before you yield). /tmp is only for files under 50 MB and never for citable evidence.
Tooling authorization (operator, 2026-10-19): you may install or upgrade tools that help the task; read /home/vgpnk/.omp/agent/RULES.md first (official channels only, update-safety gate, record tool/version/channel/reason in your report). pacman guard (orchestrator ruling 2026-10-20): ALL pacman transactions are PAUSED host-wide \u2014 install via uv tool / npx / an official binary in ~/.local/bin, or file an L0 question. Never -Sy/-Syu/-U/-R, never downgrade, never restart a host service. Never mutate host sysctls.
Secret discipline: no secret value, unseal key, root token, OTP, cookie, session id or vault/item/field name in any artifact or printed line. Generated keys/tokens stay inside your scratch dir and are deleted with it; receipts name shapes and counts only (QUALITY QM72). Fetch receipts remove Set-Cookie/Cookie values before they are written.
Absolute paths only: your tools start at the fleet root ({FLEET}), not the lane.
OpenBao binary for trials: /home/vgpnk/.local/bin/bao (v2.7.2, sha256 9c5f36287c673f386e1533e9c044169a248e4ee50dd54810fa766e95bd41b788). Throwaway servers only, bound to 127.0.0.1, started under `setpriv --pdeathsig KILL`. OpenBao 2.7.2 on this host has NO `file` storage backend (`unknown storage type file`); use `storage "raft"` (with node_id/api_addr/cluster_addr) or `storage "inmem"`.
Host paths outside your scratch (/boot, /etc, /usr, /var, /efi, other users' homes) are read-only inputs: copy into scratch before working on a file, and never run a binary-editing tool with a host path as input or output. Never message agent://all; the L1 messages seats by id.
The round's two claims: C1 calibration (C1_RESIDUAL accepted 10 -> 0 AND rejected 6 -> 0: the C1 checker's residual polarity classes close on both sides) and C2 operability (C2_REFUSAL killed 0 -> 6: the claim counters and the measured counter refuse the six named surviving mutants). The fixture tables and legs are frozen in plan \u00a7C1 and \u00a7C2; the fleet report the I6 derivation reads is {FLEET}/.ufo/reports/round-60/kagi.md (its \u00a7Stale-lane line carries `launch 15:09:28 -03`)."""


def item(name, role, axes, target, change, acceptance):
    prompt = GOD + f"# Target\n{target}\n\n# Change\n{change}\n\n# Acceptance\n{acceptance}\n"
    return {"name": name, "role": role, "axes": axes, "prompt": prompt}


ITEMS = [
    item(
        "R63ScoutSources", "scout", ["freshness", "coverage"],
        f"Open the round's candidate sources live and produce the located-quote evidence the registry rows and the lesson Gate need. Non-goals: no edit to {LANE}/corpus/SOURCES.md (the L1 appends), no other lane file.",
        f"""Read `{LANE}/plans/round-63.md` §Frontier step and `{LANE}/corpus/SOURCES.md` header (contract v1). Fetch with a desktop user agent (e.g. `curl -sS -A 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131 Safari/537.36' --compressed`), and for every page you open:
1. save the decoded body under `{LANE}/.ufo/waves/round-63/capture/<id>.body`; record HTTP status, byte count and `sha256sum`.
2. locate a <=25-word quote that grounds a learner benefit with `python3 {LANE}/corpus/rendered-text-v1.py locate <body> "<quote>"` \u2014 it must print `count=1`; record the quote, its location (section/heading) and the locate output.
3. write `{LANE}/.ufo/waves/round-63/capture/notes.md`: one block per page with URL, access date (2026-11-07), status, bytes, sha256, quote, location, locate output, and an admit/reject verdict with reason and flip condition.

Candidates (open at least three, admit at least two, reject at least one):
- negation scope and pseudo-negation: the ConText paper (Harkema et al., J Biomed Inform 2009) via the NLM PMC deposit \u2014 search `https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=pmc&term=ConText+negation+experiencer+temporal` and then `efetch.fcgi?db=pmc&id=<pmcid>&retmode=xml`. The quote must name the pseudo-negation or termination-term class (the idiom/contrastive exception list's ground), not merely the word "negation".
- mutation testing's equivalent-mutant problem: `https://ieeexplore.ieee.org/document/5661753` (Jia & Harman 2011) is a paywall lead \u2014 if the abstract does not carry a locatable sentence about equivalent mutants, reject it with the measured reason; a university PDF or the authors' page that carries the definition is the admit candidate.
- one weak lead (a vendor blog or a wiki page) as the reject if the two above both admit.
Never write a credential, cookie or session value into a capture or note; strip `Set-Cookie`/`Cookie` lines from headers you record.""",
        f"""`{LANE}/.ufo/waves/round-63/capture/notes.md` exists with >=3 page blocks, >=2 admits and >=1 reject; every admitted quote resolves `count=1`; every capture file is under the capture dir (never /tmp); no credential material in any note. End with `SEAT-STATUS: complete` or `SEAT-STATUS: partial <reason>`.""",
    ),
    item(
        "R63ScoutPreState", "scout", ["calibration", "operability"],
        f"Independent pre-state census of the two claims at BASE {BASE}: re-derive accepted=10, rejected=6 and killed=0 from your own scratch copies. Read-only: no lane file edited.",
        f"""Read `{LANE}/plans/round-63.md` §C1 and §C2 (the frozen fixtures and legs). Work only in ${{HYAKU_SCRATCH:-/fast/scratch/hyaku}}/kagi-r63/R63ScoutPreState/.
1. `git -C {LANE} archive {BASE} | tar -x -C <scratch>/base` (mkdir the dir first). Record the BASE checker's `sha256sum` and `wc -l`.
2. Build the ten forgery copies from the plan's §C1 table (each substitution must occur exactly once; assert the count) and run `python3 -I -B plans/round-61-c1-check.py --root <copy> --repo {LANE} --no-challenge` in each. Record the `C1_ROUTED:` line and rc for all ten.
3. Build the six benign copies the same way and record their `C1_ROUTED:` lines and rc.
4. Record the unmodified copy's line and the checker's `--selftest` case count.
5. C2 legs: copy `plans/round-62-c1.sh` twice \u2014 CM2a replaces `stub=0; [[ $stub_c1 -eq 1 && $stub_c2 -eq 1 ]] && stub=1` with `stub=1`; CM2b appends a line `SL_OK=1` before the closing brace of `stub_leg`. Run `bash <copy> --selftest --tree <base>` from inside the copy's tree (the script resolves its TSVs from its parent dir); record rc and the last line. Copy `plans/round-61-c1-check.py` with `ok = len(qualifying) >= 3 and bool(superseded) and not denied` replaced by `ok = len(qualifying) >= 3 and not denied` and run `--selftest`; record rc and the last line. Write the two stub counters the plan's L3/L4 name (a file printing the target verdict line and exiting 0) and record their output and rc. Record `grep -c 'C1-F8\\|C2-F6' plans/round-62-controls.sh`.
Write `{LANE}/.ufo/waves/round-63/build/R63ScoutPreState/prestate.md` with every command and its exact output. Every number derived, never quoted from the plan.""",
        f"""`prestate.md` carries: BASE checker sha256/lines; ten `C1_ROUTED: value=0 …` lines with rc 1; six `C1_ROUTED: value=1 …` lines with rc 1; the unmodified copy's line; CM2a and CM2b `C1_COUNTER_SELFTEST: PASS (8/8 checks)` rc 0; the GM5 mutant's `C1_CHECK_SELFTEST: PASS (cases=75)` rc 0; both stub counters' target lines rc 0; the battery control count 0. End with `SEAT-STATUS: complete` or `SEAT-STATUS: partial <reason>`.""",
    ),
    item(
        "R63ExecC1Grammar", "executor", ["calibration"],
        f"Harden `{LANE}/plans/round-61-c1-check.py` so the ten frozen forgery fixtures read unresolved and the six frozen benign fixtures read resolved, while the unmodified tree still reads `value=0`. You own that one file plus your receipts.",
        f"""Read `{LANE}/plans/round-63.md` §C1 (the fixture tables, the hardened grammar, the negator/denial/idiom lists) and the current `plans/round-61-c1-check.py` (1710 lines; items I3\u2013I7 at `:617-800`, the QM79 grammar at `:340-424`, selftest at `:1082+`).
Implement exactly the plan's rules:
- **Polarity (I3/I4/I5).** A token is asserted iff no negator sits between the nearest `.` or `;` before it and the token (window capped at 24 tokens), no denial predicate sits between the token and the nearest `.` or `;` after it (capped at 24 tokens), no idiom immediately precedes it, and no negator before it is followed by `but` before the token. Mask double-quoted spans that END before the token before the test (the superseded quotation is not the correction's assertion).
- **I3** accepts `A3 item 2` or `item 2 of A3` in the 12-token anchor window.
- **I4** accepts `three` or the digit `3` (word-boundary). **I5** accepts `rewritten in place` or `rewritten in-place`.
- **I6** derives the superseded record's stamp from `{{fleet}}/.ufo/reports/round-60/kagi.md` \u00a7Stale-lane (`launch HH:MM:SS`); the correction line's quoted superseded span's `HH:MM:SS` set must equal exactly that stamp. Add a `--fleet <dir>` argument (default `/home/vgpnk/Projects/shokunin`); a missing or unreadable report is SETUP (exit 2), never a silent pass. Keep the launch line, the >=3 derived committer stamps and the denial-phrase exclusion.
- **I7** binds each derived fraction to its subject: `3/16 = 18.75 %` within 8 tokens after the `literal reading` subject, `4/16 = 25 %` within 8 tokens after the `sentinel` subject (whitespace-tolerant, quoted spans masked).
Negators (case-insensitive, word-boundary): `not`, `no`, `never`, `neither`, `nor`, `without`, `none`, `n't`, `hardly`, `barely`, `scarcely`, `rarely`, `seldom`, `no longer`. Denial predicates: `denies`, `denied`, `deny`, `refutes`, `refuted`, `refute`, `is false`, `are false`, `not true`, `untrue`, `not the case`, `no such`. Idioms: `not only`, `not merely`, `not just`, `no fewer than`, `no less than`.
Keep the output line shape (`C1_ROUTED: value=V population=7 i1=.. i7=.. guard=G`), the modes (`--root`, `--repo`, `--fleet`, `--no-challenge`, `--selftest`, `--json`) and every existing selftest case. Add selftest cases: one per forgery fixture (F1..F10 must read unresolved on its copy), one per benign fixture (P1..P6 must read resolved), one isolating case for I6's superseded-stamp conjunct (the GM5 mutant must fail) and one that removes the negator test (must fail). Target `C1_CHECK_SELFTEST: PASS (cases=N)` with N >= 91.
Run all sixteen fixtures yourself on copies under your scratch; record every `C1_ROUTED:` line and rc in `{LANE}/.ufo/waves/round-63/build/R63ExecC1Grammar/grammar.md` together with the new `sha256sum` and `wc -l` of the checker and the selftest case count.""",
        f"""`python3 -I -B plans/round-61-c1-check.py --selftest` exits 0 with `C1_CHECK_SELFTEST: PASS (cases=N>=91)`; the unmodified BASE copy reads `value=0`; F1..F10 each read `value>=1`; P1..P6 each read `value=0`; the GM5 mutant fails the selftest with a named FAIL line; `grammar.md` records every command and output. End with `SEAT-STATUS: complete` or `SEAT-STATUS: partial <reason>`.""",
    ),
    item(
        "R63ExecC1Counter", "executor", ["calibration", "operability"],
        f"Write `{LANE}/plans/round-63-c1.sh` (the C1_RESIDUAL counter) and add the two missing selftest cases to `{LANE}/plans/round-62-c1.sh` (CM2a, CM2b). You own those two files plus your receipts.",
        f"""Read `{LANE}/plans/round-63.md` §C1 (the frozen predicate, the two fixture tables, the kill rules) and `{LANE}/plans/round-62-c1.sh` (451 lines; `stub_leg` at `:258`, the stub composition at `:324`, the selftest at `:370-451`).
1. **`plans/round-63-c1.sh`** \u2014 model it on `plans/round-62-c1.sh` (same modes, same fixture-application discipline, same scratch discipline, same `--selftest`). It carries the ten forgery and six benign fixtures as two committed TSVs (`plans/round-63-residual.tsv`, `plans/round-63-benign.tsv`, header `id<TAB>file<TAB>anchor<TAB>replacement`, ids F1..F10 and P1..P6, byte-exact from the plan) and prints exactly:
`C1_RESIDUAL: accepted=A rejected=R population=10/6 guard=G (real=… selftest=… prior=… para=… stub=…)`, exit 0 iff guard=1 and A=0 and R=0; 1 otherwise; 2 SETUP.
Guard legs: (a) the unmodified copy reads `value=0`; (b) the tree's checker `--selftest` exits 0 with `C1_CHECK_SELFTEST: PASS (cases=N)` N >= 91; (c) the five round-62 bypass fixtures (B3..B7, reuse `plans/round-62-bypass.tsv`) each read `value>=1`; (d) the three round-62 paraphrases (reuse `plans/round-62-paraphrase.tsv`) each read `value=0`; (e) a printer-stub checker is refused (no verdict line, non-zero rc). `--selftest` must cover: TSV shape, fixture-applied-exactly-once, the checker's selftest PASS, the unmodified value parse, the stub refusal, and a negative vector for `stub_leg` (a good tree must read `SL_OK=0`).
2. **`plans/round-62-c1.sh`** \u2014 extract the stub composition into a `stub_calc` function and add two selftest cases: one where `stub_c1=0` (or `stub_c2=0`) must make the composition read 0 (kills CM2a), and one running `stub_leg` on the unmodified tree that must read `SL_OK=0` (kills CM2b). Keep `C1_COUNTER_SELFTEST: PASS (N/N checks)` with N >= 10 and a named `FINDING`/failed-case line on a failing case.
Run the counter on an extracted `{BASE}` tree and record the BASE reading (`accepted=10 rejected=6`), the selftest readings of both counters and the exact hashes in `{LANE}/.ufo/waves/round-63/build/R63ExecC1Counter/counter.md`.""",
        f"""`bash plans/round-63-c1.sh {BASE}` prints `C1_RESIDUAL: accepted=10 rejected=6 population=10/6 guard=0` rc 1 (the no-work control); `bash plans/round-63-c1.sh --selftest` prints `C1_RESIDUAL_SELFTEST: PASS`; `bash plans/round-62-c1.sh --selftest` prints `C1_COUNTER_SELFTEST: PASS (N/N checks)` with N >= 10; the CM2a and CM2b mutants each make that selftest FAIL with a named finding; `counter.md` records every command and output. End with `SEAT-STATUS: complete` or `SEAT-STATUS: partial <reason>`.""",
    ),
    item(
        "R63ExecC2Counter", "executor", ["operability"],
        f"Write `{LANE}/plans/round-63-c2.sh` (the C2_REFUSAL counter) and add the missing `needle-ma` SETUP guard to `{LANE}/plans/round-62-c2.sh`. You own those two files plus your receipts.",
        f"""Read `{LANE}/plans/round-63.md` §C2 (the frozen predicate, the six legs, the kill rules) and `{LANE}/plans/round-62-c2.sh` (331 lines; the M-A leg at `:277-288` has no `setup needle-ma`, the M-B leg at `:289-300` has `setup needle-mb`).
1. **`plans/round-62-c2.sh`** \u2014 add `[ "$ma_applied" = 1 ] || setup needle-ma` before the M-A run (the S3 fix: a zero-match needle is a SETUP, never a surviving mutant). Keep the output line and exit codes unchanged.
2. **`plans/round-63-c2.sh`** \u2014 model it on `plans/round-62-c2.sh` (same scratch discipline, same `--selftest` style with named `FINDING` lines). It runs the six legs and prints exactly:
`C2_REFUSAL: killed=K population=6 guard=G (l1=… l2=… l3=… l4=… l5=… l6=… selftest=… real=…)`, exit 0 iff guard=1 and K=6; 1 otherwise; 2 SETUP.
Legs: L1/L2 apply the CM2a/CM2b mutations to the tree's `plans/round-62-c1.sh` and require its `--selftest` to exit non-zero with a named `FINDING`; L3/L4 run the battery (`bash plans/round-63-controls.sh <tree>`) and require its `C2-F6`/`C1-F8` control lines to read `mismatch`; L5 runs the tree's `plans/round-62-c2.sh --tree <s3-tree>` (a copy whose `plans/round-61-c2.sh` carries neither the `# BEGIN-DECIDE` marker nor the BASE aggregation text) and requires `SETUP needle-ma` with exit 2; L6 applies the GM5 mutation to the tree's checker (`ok = len(qualifying) >= 3 and bool(superseded) and not denied` -> `ok = len(qualifying) >= 3 and not denied`) and requires its `--selftest` to exit non-zero printing `C1_CHECK_SELFTEST: FAIL`.
Guard: (a) the unmutated `plans/round-62-c1.sh --selftest` exits 0; (b) the counter's own `--selftest` exits 0 printing `C2R63_SELFTEST: PASS`; (c) the real trial reads `value=5 shims=5 vectors=ok/5` (run `bash plans/round-62-c2.sh --tree <tree>` once, heavy); (d) the battery's existing controls match with 0 skips.
Run it on an extracted `{BASE}` tree and record `killed=0 population=6` (the no-work control), the selftest readings and the exact hashes in `{LANE}/.ufo/waves/round-63/build/R63ExecC2Counter/counter.md`.""",
        f"""`bash plans/round-63-c2.sh {BASE}` prints `C2_REFUSAL: killed=0 population=6 guard=0` rc 1 (the no-work control); `bash plans/round-63-c2.sh --selftest` prints `C2R63_SELFTEST: PASS`; `bash plans/round-62-c2.sh --tree <s3-tree>` prints `SETUP needle-ma` rc 2 while the unmodified tree still reads its verdict; `counter.md` records every command and output. End with `SEAT-STATUS: complete` or `SEAT-STATUS: partial <reason>`.""",
    ),
    item(
        "R63ExecControls", "executor", ["operability"],
        f"Write `{LANE}/plans/round-63-controls.sh`: the pre-freeze control battery carrying the two new stub controls (C1-F8, C2-F6) plus the no-work and forgery controls. You own that one file plus your receipts.",
        f"""Read `{LANE}/plans/round-63.md` §C1/§C2 (the frozen predicates and the six legs) and `{LANE}/plans/round-62-controls.sh` (the 14-control battery; per-control line `CONTROL <id> expect=<…> observed=<…> verdict=match|mismatch|skip`).
Write `plans/round-63-controls.sh` with the same shape and a fixture-driven `--selftest` (no lane instruments, no `bao`): it takes a tree argument and prints `CONTROLS: match=N mismatch=M`, exit 0 iff mismatch=0, 1 on a mismatch, 2 SETUP. Controls:
- `C1-F8`: a printer-stub copy of `plans/round-63-c1.sh` (prints `C1_RESIDUAL: accepted=0 rejected=0 population=10/6 guard=1 …`, exits 0) run on the tree must read `mismatch` against the independently expected BASE line (`accepted=10 rejected=6`).
- `C2-F6`: a constant-verdict copy of `plans/round-63-c2.sh` (prints `C2_REFUSAL: killed=6 population=6 guard=1 …`, exits 0) run on the tree must read `mismatch` against the expected BASE line (`killed=0`).
- `C1-NOWORK`: `plans/round-63-c1.sh <tree>` must read `accepted=10 rejected=6` (the no-work control).
- `C2-NOWORK`: `plans/round-63-c2.sh <tree>` must read `killed=0` (the no-work control).
- `C1-REAL` / `C2-REAL`: the unmutated counters on the tree must print their verdict lines with `guard=1` (the positive controls; a blanket refusal is not a gain).
- the round-62 battery's own controls re-run as `PRIOR-<n>` rows (delegate to `plans/round-62-controls.sh <tree>` and re-emit its per-control verdicts).
`--selftest` must be fixture-driven: build stub counters and stub trees under your scratch and assert each control's expected verdict, with a named `FINDING R63C-CTL-ST-<case>` line on a failing case. Record the BASE battery reading (the two new controls mismatch, the no-work controls match) in `{LANE}/.ufo/waves/round-63/build/R63ExecControls/controls.md` with every command and output.""",
        f"""`bash plans/round-63-controls.sh <extracted-BASE-tree>` prints `CONTROLS: match=N mismatch=M` with `C1-F8` and `C2-F6` reading `mismatch` and the no-work controls reading `match`; `bash plans/round-63-controls.sh --selftest` prints `CONTROLS_SELFTEST: PASS (cases=N)`; `controls.md` records every command and output. End with `SEAT-STATUS: complete` or `SEAT-STATUS: partial <reason>`.""",
    ),
    item(
        "R63ExecRouted", "executor", ["calibration", "freshness"],
        f"Write `{LANE}/plans/round-63-routed.sh`: the receipt for the round-62 spot-check's three routed defects (D-A, D-B, D-C). You own that one file plus your receipts.",
        f"""Read `{LANE}/corpus/lessons/round-62-verifier-spotcheck.md` §6 (D-A, D-B, D-C) and `{LANE}/plans/round-62-routed.sh` (146 lines; the round-62 routed legs `d1`..`d5`).
Write `plans/round-63-routed.sh` with one leg per defect, each able to fail:
- `da` \u2014 report counts that do not re-derive: re-derive the two round-62 counts from committed bytes (`git -C {LANE} show 60b5b7b:plans/round-61-c1-check.py | wc -l` vs `git -C {LANE} show c840739:plans/round-61-c1-check.py | wc -l`; the same pair for `plans/round-61-c2.sh`) and require the round-63 lesson's correction line to carry both measured values and the command. A correction that restates the report's figure reads `da=0`.
- `db` \u2014 one receipt per gate verdict line: require `.ufo/waves/round-63/final/{{c1-residual,c2-refusal,controls,release-clock,doc-audit,claims-declared}}.txt` to exist, each to carry its label line, and `LOG.md` to cite each path. A missing receipt or an uncited path reads `db=0`.
- `dc` \u2014 the case enumeration: require the lesson's case list to name every case the instruments' own selftest counts claim (parse the `cases=N` figures and the lesson's enumerated list; a list shorter than the count reads `dc=0`).
Print `ROUTED: da=<0|1> db=<0|1> dc=<0|1>` and exit 0 iff all three read 1. The legs read the working tree; the L1 runs it after integration. Record the BASE reading (all three 0 before the fixes) in `{LANE}/.ufo/waves/round-63/build/R63ExecRouted/routed.md` with every command and output.""",
        f"""`bash plans/round-63-routed.sh` prints `ROUTED: da=… db=… dc=…` and exits 0/1 accordingly; each leg is shown able to fail on a scratch copy (record the failing reading); `routed.md` records every command and output. End with `SEAT-STATUS: complete` or `SEAT-STATUS: partial <reason>`.""",
    ),
    item(
        "R63ScribeEntry", "scribe", ["depth", "calibration"],
        f"Draft the round's knowledge entry, the two QUALITY criteria and the gate-registry rows. You own `{LANE}/corpus/knowledge/negation-scope-grammar.md`, `{LANE}/corpus/QUALITY.md` (append-only rows) and `{LANE}/SKILL.md` (registry rows only).",
        f"""Read `{LANE}/plans/round-63.md` §C1, `{LANE}/corpus/QUALITY.md` (the QM rows; append-only), `{LANE}/SKILL.md` §Gate registry (the round-62 additions at `:857-871`) and `{LANE}/corpus/lessons/round-62.md` §Gate (the entry shape).
1. **`corpus/knowledge/negation-scope-grammar.md`** \u2014 opens with `source:` (the admitted `S###` row the scout's capture grounds, plus the URL and anchor), `verified-at:` (2026-11-07) and `recheck:` (the command or cadence). Sections: §The rule (sentence scope, the closed negator/denial/idiom lists, the contrastive exception, the quotation mask); §The two-sided test (recall fixtures F1..F10, precision fixtures P1..P6, the measured before→after); §Bounds (a closed-list floor, a structural read cannot prove the sentence true); §Falsifiers (a forgery that keeps every token and uses none of the lists; a benign rewrite the grammar rejects). Cite the `S###` row on the `source:` line.
2. **`corpus/QUALITY.md`** \u2014 append two criteria, each citing `corpus/lessons/round-63.md`: QM83 (a polarity item tests the token in the asserting position over the sentence scope, with a closed negator/denial/idiom list, and a quotation of the superseded text is masked, never counted as the correction's assertion) and QM84 (a claim counter's guard must carry a negative vector for every leg it composes, and a zero-match needle is SETUP, never a surviving mutant). Append only; never rewrite a row.
3. **`SKILL.md`** \u2014 append gate-registry rows for `plans/round-63-c1.sh`, `plans/round-63-c2.sh` and `plans/round-63-controls.sh`: `kind: gate`, a runnable self-invocation (`--selftest` with a case count), the exit-code map, and the falsifiers. No `none of its own`.
Record every command and its output in `{LANE}/.ufo/waves/round-63/build/R63ScribeEntry/entry.md`.""",
        f"""The three files carry the drafted content; the entry opens with the provenance trio and cites an `S###` row; the QUALITY rows are appended with QM83/QM84 ids and lesson pointers; the registry rows name the three gates with runnable selftests; `entry.md` records the checks. End with `SEAT-STATUS: complete` or `SEAT-STATUS: partial <reason>`.""",
    ),
    item(
        "R63ScribeRecords", "scribe", ["calibration", "freshness"],
        f"Draft the round lesson's Gate and Mistakes sections and the SOURCES.md row block (the L1 appends). You own `{LANE}/corpus/lessons/round-63.md` and `{LANE}/corpus/README.md`.",
        f"""Read `{LANE}/plans/round-63.md` §C1/§C2/§Frontier step, `{LANE}/corpus/lessons/round-62.md` (the Gate/Mistakes shape), `{LANE}/corpus/SOURCES.md` (contract v1 header and the last rows) and `{LANE}/corpus/README.md` (the coverage map and `## Frontier`).
1. **`corpus/lessons/round-63.md`** \u2014 sections: claims (C1/C2 with their frozen predicates and measured readings), `## Gate` (one row per source opened this round: URL, access date, <=25-word located quote, admit/reject with reason and flip \u2014 take the quotes from the scout's `capture/notes.md` and re-resolve each with `python3 corpus/rendered-text-v1.py locate`), `## Mistakes` (at least one row: class, evidence pointer, captured-by, fix able to fail), `## Routed dispositions` (D-A/D-B/D-C), `## considerthese`, `## Wave` (filled by the L1), `## Bounds`.
2. **`corpus/SOURCES.md` row block** \u2014 draft the rows for the admitted and rejected sources in a receipt file `{LANE}/.ufo/waves/round-63/build/R63ScribeRecords/sources-block.md` (11 columns, no `|` inside a cell, `status=mined` only for a row an admitted entry cites, rejected rows carry `REJECTED: <reason>; flip: <what would change it>`); the L1 appends them to the registry.
3. **`corpus/README.md`** \u2014 add the round's coverage-map row and its `## Frontier` line for the negation-scope ground.
Record every command and its output in `{LANE}/.ufo/waves/round-63/build/R63ScribeRecords/records.md`.""",
        f"""`corpus/lessons/round-63.md` carries the required sections with >=3 Gate rows and >=1 Mistakes row; `sources-block.md` carries the registry rows in 11 columns; `corpus/README.md` carries the new coverage-map row; `records.md` records the locate outputs. End with `SEAT-STATUS: complete` or `SEAT-STATUS: partial <reason>`.""",
    ),
    item(
        "R63Reviewer", "reviewer", ["calibration", "operability"],
        f"Attack the round's instruments and fixtures: find forgery trees beyond the frozen ten that the hardened checker still accepts, benign rewrites it still rejects, and guards the counters do not exercise. Read-only on lane source: write only your receipts.",
        f"""Read `{LANE}/plans/round-63.md` §C1/§C2, `{LANE}/corpus/lessons/round-62-verifier-spotcheck.md` §2 and the round-62 reviewer's table (`{LANE}/.ufo/waves/round-62/w1/R62Reviewer.md` §1). Work on your own scratch copies of the tree; never edit a lane instrument.
1. Build at least twelve new forgery trees the frozen set does not name: a hedge negator outside the closed set, a denial verb outside the closed set, a negation in a previous sentence, a token inside a quotation with the denial outside, a subject swap with a third subject, a fabricated stamp that is a *derived* committer time, a fraction paired with a percentage derived from a different denominator, and a token form the grammar does not list.
2. Build at least six new benign rewrites the hardened grammar must still accept (an appositive, a passive, a numeric form, a hyphenated form, a contrastive form, a quoted-but-asserted form).
3. Attack the counters: a stub that prints the target line plus the leg fields; a counter whose `--selftest` prints PASS without executing a case; a battery whose control list is empty.
Record every tree, the exact `C1_ROUTED:`/verdict line and your verdict (closed / open with the finding id) in `{LANE}/.ufo/waves/round-63/build/R63Reviewer/findings.md` with a severity and a fix for every open finding.""",
        f"""`findings.md` carries >=12 new forgery trees and >=6 new benign rewrites with measured lines, the counter attacks, and a severity + fix per open finding. End with `SEAT-STATUS: complete` or `SEAT-STATUS: partial <reason>`.""",
    ),
    item(
        "R63Critic", "critic", ["calibration", "operability"],
        f"Falsify the two claims' predicates before the candidate reading: causal separability, population vacuity, guard vacuity, and whether a do-nothing control can reach the target. Read-only on lane source: write only your receipts.",
        f"""Read `{LANE}/plans/round-63.md` §C1/§C2 and the round-62 critic's findings (`{LANE}/.ufo/waves/round-62/w1/R62Critic.md`).
1. **C1**: is `accepted=0 AND rejected=0` reachable by a trivial change (e.g. a checker that reads no file, or one that rejects everything)? Is each fixture's anchor unique in the tree? Does the I6 derivation depend on a fleet path that the measured tree cannot see? Is the `N >= 91` floor reachable without a case per fixture class? Is the claim separable from C2 (does C1 need any C2 file)?
2. **C2**: is each leg's BASE reading real (does the mutation actually survive at BASE)? Does L5's SETUP depend on L1/L2's fix? Does the battery's `mismatch` reading depend on C1's hardening? Can a stub that prints the expected line pass?
3. **Both**: name every ceiling the plan smooths and every coupling it does not declare. Propose the cheapest do-nothing control and say whether it meets the target.
Record each finding with id, severity, the observation and the fix in `{LANE}/.ufo/waves/round-63/build/R63Critic/critique.md`.""",
        f"""`critique.md` carries >=8 findings with ids, severities, measured observations and fixes; the do-nothing-control verdict is explicit. End with `SEAT-STATUS: complete` or `SEAT-STATUS: partial <reason>`.""",
    ),
    item(
        "R63MutC1", "mutation-tester", ["calibration"],
        f"Mutation-test the hardened C1 checker and the C1_RESIDUAL counter: report every surviving mutant with its fix. Read-only on lane source: work on copies under your scratch.",
        f"""Read `{LANE}/plans/round-63.md` §C1 and the round-62 mutation report (`{LANE}/.ufo/waves/round-62/w1/R62MutC1.md`, survivors GM5/CM2a/CM2b).
On an extracted `{BASE}` tree (and on the candidate tree once it exists) build at least twelve mutants of `plans/round-61-c1-check.py`: drop the negator test, drop the post-token denial test, drop the idiom exception, drop the contrastive exception, drop the quotation mask, widen/narrow the window, drop the I3 subject alternative, drop the digit/hyphen token forms, drop the I6 superseded-stamp conjunct, drop the I7 subject binding, invert a verdict mapping, make an item return HOLD unconditionally. Run the checker's `--selftest` on each and record killed/survived with the exact line.
Then mutate `plans/round-63-c1.sh` (once it exists): force `accepted=0`, force `guard=1`, skip the stub leg, skip the prior/paraphrase guards, and record its `--selftest` reading for each.
Record every mutant, its exact bytes delta, the observed line and the verdict in `{LANE}/.ufo/waves/round-63/build/R63MutC1/mutants.md`; every survivor carries a fix.""",
        f"""`mutants.md` carries >=12 checker mutants and >=4 counter mutants, each with the observed line and killed/survived, and a fix per survivor. End with `SEAT-STATUS: complete` or `SEAT-STATUS: partial <reason>`.""",
    ),
    item(
        "R63MutC2", "mutation-tester", ["operability"],
        f"Mutation-test the C2_REFUSAL counter, the controls battery and the measured counter's guard: report every surviving mutant with its fix. Read-only on lane source: work on copies under your scratch.",
        f"""Read `{LANE}/plans/round-63.md` §C2 and the round-62 mutation report (`{LANE}/.ufo/waves/round-62/w1/R62MutC2.md`, survivors S1–S4).
On an extracted `{BASE}` tree (and on the candidate tree once it exists) build at least ten mutants: force each of the six legs to 1, force `killed=6`, force `guard=1`, skip the battery delegation, make L5 read `killed=2` instead of SETUP, drop the real-trial leg. Run `plans/round-63-c2.sh --selftest` (and the counter on a fixture tree) for each and record killed/survived with the exact line.
Also mutate `plans/round-62-c2.sh`'s new `needle-ma` guard (remove it) and `plans/round-63-controls.sh`'s control list (empty it) and record whether the battery's own selftest catches each.
Record every mutant, its exact bytes delta, the observed line and the verdict in `{LANE}/.ufo/waves/round-63/build/R63MutC2/mutants.md`; every survivor carries a fix.""",
        f"""`mutants.md` carries >=10 counter mutants and >=2 battery mutants, each with the observed line and killed/survived, and a fix per survivor. End with `SEAT-STATUS: complete` or `SEAT-STATUS: partial <reason>`.""",
    ),
    item(
        "R63Connector", "connector", ["adjacency", "coverage"],
        f"Sibling-overlap scan: name every lane whose corpus or gates already hold the round's ground (negation-scope grammar, mutation-kill contracts, stub-refusal counters) and report it, never absorb it. Read-only: write only your receipt.",
        f"""Read `{LANE}/PROVINCE.md`, `{LANE}/plans/round-63.md` §C1/§C2 and the round-62 connector sweep (`{LANE}/.ufo/waves/round-62/build/R62Connector/sweep.md`).
Scan the sibling lanes under `/home/vgpnk/Projects/shokunin/*-shokunin/` (read-only) for: a negation/polarity grammar, a pseudo-negation or idiom list, a mutation-kill contract, a stub-refusal counter, a sentence-scope window, a superseded-stamp derivation. For each hit record the lane, the path:line, what it holds and whether kagi's claim duplicates it.
Also record the carried `ADJACENCY_SCOPE: DEFECT` breadth debt (`breadth_drift=5 breadth_unverified=1`) and whether this round moves it.
Write `{LANE}/.ufo/waves/round-63/build/R63Connector/sweep.md` with the scan commands and their output (a negative claim carries its sweep).""",
        f"""`sweep.md` names each overlapping lane with a path:line, states adjacent-vs-absorbed for each, and carries the sweep commands. End with `SEAT-STATUS: complete` or `SEAT-STATUS: partial <reason>`.""",
    ),
    item(
        "R63Sentinel", "sentinel", ["calibration", "operability"],
        f"Secret-discipline and write-scope audit of the round's artifacts: no credential material, no /tmp evidence, no host-path writes, no sibling-lane writes. Read-only: write only your receipt.",
        f"""Read `{LANE}/corpus/QUALITY.md` QA5/QM72 and `{LANE}/plans/round-63.md`.
1. Scan every file the round created or changed under `{LANE}/.ufo/waves/round-63/` and `{LANE}/plans/round-63*` for credential shapes (unseal keys, root tokens, `op://` references, cookies, session ids, `Authorization:` values) with a counts-only scan; record the command and the hit count.
2. Check every receipt path is inside the lane tree or the wave dir (no `/tmp`, no `/var/tmp`, no `$HYAKU_SCRATCH` path cited as evidence).
3. Check no seat wrote outside the lane: `git -C /home/vgpnk/Projects/shokunin status --porcelain` and `git -C {LANE} status --porcelain`, and name any file at the fleet root that names kagi round 63.
4. Check the wave's scratch discipline: `du -sh /fast/scratch/hyaku/kagi-r63/*` and name any seat tree left behind.
Write `{LANE}/.ufo/waves/round-63/build/R63Sentinel/audit.md` with the commands and their output.""",
        f"""`audit.md` carries the four checks with their commands and output, a hit count for the secret scan, and every violation named. End with `SEAT-STATUS: complete` or `SEAT-STATUS: partial <reason>`.""",
    ),
]

SPEC = {
    "wave": "kagi-r63-w1",
    "axes": ["calibration", "operability"],
    "milestone": "C1 C1_RESIDUAL accepted 10->0 and rejected 6->0 (the C1 checker's residual polarity classes close on both sides); C2 C2_REFUSAL killed 0->6 (the claim counters and the measured counter refuse the six named surviving mutants); attack seats falsify both",
    "reportDir": ".ufo/waves/round-63/w1",
    "context": CONTEXT,
    "items": ITEMS,
}

with open(OUT, "w", encoding="utf-8") as f:
    json.dump(SPEC, f, indent=1)
print("wrote", OUT, len(ITEMS), "items")
