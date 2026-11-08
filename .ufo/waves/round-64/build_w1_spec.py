#!/usr/bin/env python3
"""Build the round-64 v1 wave spec (kagi). One wave, 16 seats, band 8-16."""
import json

LANE = "/home/vgpnk/Projects/shokunin/kagi-shokunin"
FLEET = "/home/vgpnk/Projects/shokunin"
BASE = "09cbee831d57be7c4edfbe77bf238f46bf729047"
PRE = "dff0929c0e084822b0fe32e0d164534c768f97fe"
OUT = f"{LANE}/.ufo/waves/round-64/w1-spec.json"

GOD = """/skill:godspeed
You are a Godspeed-enabled subagent.

1. **Name the axes.**
2. **Iterate cheap, in parallel.**
3. **Keep moves that improve any axis and harm none.**
4. **Don't aim \u2014 let the frontier walk itself.**

## IMMEDIATELY STOP ASKING CLARIFYING QUESTIONS. Execute tool calls concurrently in large batches. Do not serialize what can run in parallel. Do not output philosophical reasoning or verbose plans. Act directly via tool calls.
# Assignment
"""

CONTEXT = f"""kagi round 64 attempt 2. ONE v1 wave, 16 seats (run-15 band 8-16; plan \u00a7Wave). L1 KagiR64a2 holds the canonical planner seat and is the sole integration owner and committer.
Lane repo: {LANE} (branch master). Claim BASE {BASE}. FROZEN predeclaration: {LANE}/plans/round-64.md (commit {PRE}, including Amendment A1 which re-measured the held-out population) \u2014 read it, plus {LANE}/corpus/lessons/round-63-verifier-spotcheck.md \u00a72/\u00a76 and {LANE}/corpus/lessons/round-63.md, before you work. Never amend a frozen predicate, target, POP, kill rule, fixture or item condition; report a defect instead.
Held-out seal: `{LANE}/plans/round-64-heldout.tsv` (sha256 `b0f51e2a7e7b5b62efa17c91761e24e01fe1a3ff384181e468b628544faa93c2`) is SEALED. The C1 checker hardening seat MUST NOT read it (it is the held-out test set; reading it voids the claim) \u2014 that seat builds from the six shape classes named in plan \u00a7C1 Amendment A1 instead. Every other seat may read it. A seat that reads it for the checker's benefit must disclose that in its report.
Write scope: {LANE} plus your own scratch. Never write, commit, push or run a mutating git/jj command in the fleet repo, a sibling lane, or the lane's jj/git index; never run `git add/commit/stash/push` or any mutating `jj` anywhere. Seats return findings and files; only the L1 commits (scripts/hyaku/jj-lane.sh).
File ownership is disjoint: write ONLY the paths your item names. Receipts go under {LANE}/.ufo/waves/round-64/build/<your-seat-name>/. Every `Report:` trailer path a wave template prints is relative to {LANE} \u2014 write it at {LANE}/<that path>. Never write citable evidence under /tmp.
Scratch: every clone, work tree, fixture or dev-server dir lives under ${{HYAKU_SCRATCH:-/fast/scratch/hyaku}}/kagi-r64/<seat-name>/ (mkdir -p; pass it explicitly; delete it before you yield). /tmp is only for files under 50 MB and never for citable evidence.
Tree copies are expensive (~200 MB, ~90 s per copy with the fixtures). Prefer a slim tree: copy only `LOG.md`, `SKILL.md`, `plans/round-60.md`, `plans/round-60-c2.sh`, `plans/round-61-c1-check.py`, `corpus/lessons/round-60.md` and `.ufo/waves/round-60/w1-results.json` \u2014 the checker reads exactly those plus `{FLEET}/.ufo/reports/round-60/kagi.md`. A slim tree reads `value=0` on the unmodified copy exactly like the full tree (measured by the L1, 2026-11-08).
Tooling authorization (operator, 2026-10-19): you may install or upgrade tools that help the task; read /home/vgpnk/.omp/agent/RULES.md first (official channels only, update-safety gate, record tool/version/channel/reason in your report). pacman guard (orchestrator ruling 2026-10-20): ALL pacman transactions are PAUSED host-wide \u2014 install via uv tool / npx / an official binary in ~/.local/bin, or file an L0 question. Never -Sy/-Syu/-U/-R, never downgrade, never restart a host service. Never mutate host sysctls.
Secret discipline: no secret value, unseal key, root token, OTP, cookie, session id or vault/item/field name in any artifact or printed line. Generated keys/tokens stay inside your scratch dir and are deleted with it; receipts name shapes and counts only (QUALITY QM72). Fetch receipts remove Set-Cookie/Cookie values before they are written.
Absolute paths only: your tools start at the fleet root ({FLEET}), not the lane.
Host paths outside your scratch (/boot, /etc, /usr, /var, /efi, other users' homes) are read-only inputs: copy into scratch before working on a file, and never run a binary-editing tool with a host path as input or output. Never message agent://all; the L1 messages seats by id.
The round's two claims: C1 calibration (`C1_HELDOUT: heldout` 8 -> 0, population 8: five held-out forgeries (ids F2,F6,F8,F10,B4) rejected and three benign rewrites (ids P6,B5,P7) accepted, with the A4 lookup-table vehicle refused) and C2 operability (`C2_REFUSAL` terminated 0 -> 1 with killed=5 population=5 from ONE bounded end-to-end run; the round-63 counter hangs with rc=124 at 900 s and 1500 s). The fixture tables, limbs and kill rules are frozen in plan \u00a7C1 and \u00a7C2. The fleet report the I6 derivation reads is {FLEET}/.ufo/reports/round-60/kagi.md (its \u00a7Stale-lane line carries `launch 15:09:28 -03`). The round-63 counter lives at {LANE}/plans/round-63-c2.sh; its committed receipt {LANE}/.ufo/waves/round-63/final/c2-refusal.txt is 7 bytes (`rc=124`)."""


def item(name, role, axes, target, change, acceptance):
    prompt = GOD + f"# Target\n{target}\n\n# Change\n{change}\n\n# Acceptance\n{acceptance}\n"
    return {"name": name, "role": role, "axes": axes, "prompt": prompt}


ITEMS = [
    item(
        "R64ScoutSources", "scout", ["freshness", "coverage"],
        f"Open the round's frontier sources live and produce the located-quote evidence the registry rows and the lesson Gate need. Non-goals: no edit to {LANE}/corpus/SOURCES.md (the L1 appends), no other lane file.",
        f"""Read `{LANE}/plans/round-64.md` §Frontier step and `{LANE}/corpus/SOURCES.md` header (contract v1). Fetch with a desktop user agent (`curl -sS -A 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131 Safari/537.36' --compressed`) and, for every page you open:
1. save the decoded body under `{LANE}/.ufo/waves/round-64/capture/<id>.body`; record HTTP status, byte count and `sha256sum`; write the response headers to `{LANE}/.ufo/waves/round-64/build/R64ScoutSources/h<id>.hdr` with every `set-cookie`/`cookie` line filtered out.
2. locate a ≤25-word quote that grounds a learner benefit with `python3 {LANE}/corpus/rendered-text-v1.py locate <body> "<quote>"` — it must print `count=1`; record the quote, its section/heading and the locate output.
3. write `{LANE}/.ufo/waves/round-64/capture/notes.md`: one block per page with URL, access date (2026-11-08), status, bytes, sha256, quote, location, locate output, and an admit/reject verdict with reason and flip condition.

Candidates (open at least four, admit at least one, reject at least one):
- a **second peer-reviewed attestation of the equivalent-mutant rule** (the C2 kill contract's ground behind S137/S139/S140): try the PIT mutation-testing docs (`https://pitest.org/quickstart/mutators/` and `https://pitest.org/`) and Stryker's docs pages as the tool-level statement; if a peer-reviewed survey chapter is reachable, prefer it. The quote must state the cannot-be-killed consequence or the can-be-killed definition, not merely the words "mutation testing".
- **the BioC/ConText deposit re-opened on the current endpoint** (freshness item 3 of the round-63 plan, S143): `https://www.ncbi.nlm.nih.gov/research/bionlp/RESTful/pmcoa.cgi/BioC_xml/PMC2757457/unicode`. Re-verify that the served deposit still carries §3.1.2's pseudo-trigger and termination-term classes with the same shape; record the byte count and sha against S143's committed pin (`8522a79e…`, 264946 B). If the shape or bytes changed, say so explicitly with the measured delta — the L1 then supersedes S143 per CORPUS.md rule 2.
- **OpenBao's own mutation-test or equivalent-mutant statement** if one exists (`https://github.com/openbao/openbao` — search its contributing/testing docs and the repo's `go test`/mutation references). This is the lane's own domain; if no such statement exists, record the sweep that shows it absent.
- **one weak lead as the reject** (a vendor blog or a wiki page about mutation testing).

Never write a credential, cookie or session value into a capture or note.""",
        f"""`{LANE}/.ufo/waves/round-64/capture/notes.md` exists with ≥4 page blocks, ≥1 admit and ≥1 reject; every admitted quote resolves `count=1`; every capture file is under the capture dir (never /tmp); the S143 re-verification block states the measured byte count, sha256 and whether the shape still holds; no credential material in any note. End with `SEAT-STATUS: complete` or `SEAT-STATUS: partial <reason>`.""",
    ),
    item(
        "R64ScoutPreState", "scout", ["calibration", "operability"],
        f"Independent pre-state census of the two claims at BASE {BASE}, over slim trees, from your own scratch copies: re-derive `heldout=8 population=8` and the C2 `rc=124` non-termination. Read-only: no lane file edited.",
        f"""Read `{LANE}/plans/round-64.md` §C1 (as amended by A1: H = F2,F6,F8,F10,B4; Q = P6,B5,P7; POP 8) and §C2. Work only in ${{HYAKU_SCRATCH:-/fast/scratch/hyaku}}/kagi-r64/R64ScoutPreState/.
1. `git -C {LANE} archive {BASE} | tar -x -C <scratch>/base` (mkdir first). Record the BASE checker's `sha256sum`, `wc -l`, and `wc -c` of the sealed `plans/round-64-heldout.tsv` + its `sha256sum` at {BASE}.
2. Build a slim tree (the seven input files named in the wave context) and confirm the unmodified copy reads `C1_ROUTED: value=0 population=7 …` rc 1.
3. Apply the five H fixtures (F2,F6,F8,F10,B4) one at a time to fresh slim copies (assert each anchor occurs exactly once) and record each `C1_ROUTED:` line and rc — each must read `value=0` (accepted).
4. Apply the three Q fixtures (P6,B5,P7) the same way — each must read a `value` integer ≥ 1 (rejected).
5. Record the checker's `--selftest` case count and the A4 lookup-table vehicle's construction requirement (plan §C1 guard leg e).
6. C2: run `timeout 240 bash plans/round-63-c2.sh --tree <full candidate tree>` and record rc (expect 124, no verdict line); record `wc -c` of `{LANE}/.ufo/waves/round-63/final/c2-refusal.txt`.
Write `{LANE}/.ufo/waves/round-64/build/R64ScoutPreState/prestate.md` with every command and its exact output. Every number derived, never quoted from the plan.""",
        f"""`prestate.md` carries: BASE checker sha256/lines; the sealed TSV's sha256 and byte count; the unmodified slim copy's `value=0` line; five H `C1_ROUTED: value=0 …` lines with rc 1; three Q `value>=1` lines with rc 1; the checker selftest case count; the C2 `timeout 240` rc and the receipt byte count. End with `SEAT-STATUS: complete` or `SEAT-STATUS: partial <reason>`.""",
    ),
    item(
        "R64ExecC1Grammar", "executor", ["calibration"],
        f"Harden `{LANE}/plans/round-61-c1-check.py` so the five held-out forgery SHAPE CLASSES read unresolved and the three benign shape classes read resolved, while the unmodified tree still reads `value=0` and the round-63 residual tables still close. You own that one file plus your receipts.",
        f"""**You must NOT read `{LANE}/plans/round-64-heldout.tsv`** — it is the sealed held-out set and reading it voids the claim. Build from the six shape classes named in plan §C1 Amendment A1 and the evidence file `{LANE}/.ufo/waves/round-64/base/census-a1.md` (which names each class, not each fixture string).
Read `{LANE}/plans/round-64.md` §C1 (as amended) and the current `plans/round-61-c1-check.py` (2031 lines; items I3–I7 at `:748-965`, the polarity helpers at `:427-505`, selftest at `:1389+`; `C1_CHECK_SELFTEST: PASS (cases=102)` at BASE).
The six reachable fixes (each names the class it closes):
1. **I7 pair assertion** — a `_pair_re` match must itself be in the asserting position: no denial predicate (`DENY_SINGLE`/`DENY_PHRASES`, already defined) between the pair's end and the next `.`/`;`. Closes the "benign pair followed by a sentence-level denial" class.
2. **I7 every-pair-bound** — every occurrence of each derived fraction in the (quote-masked) line must be bound to a subject within `SUBJECT_WINDOW` tokens; an extra unbound duplicate pair is a defect. Closes the "duplicate pair appended elsewhere" class.
3. **I7 subject-negatedness guard** — a subject occurrence preceded (within 3 tokens) by `different`, `other`, `no` or `not` does not bind its pair. Closes the "a different seat than the sentinel" class.
4. **I7 parenthetical masking** — before the binding and window count, mask well-formed parentheticals `( … )` and em-dash asides `— … —` in addition to double-quoted spans, so a clarification between subject and pair does not break the binding (and a negator inside such an aside does not count). Closes the appositive/parenthetical benign class.
5. **I4 `NO_NEW` assertion** — the `NO_NEW_RECORD_DEFECT_RE` match must be asserted (call `_asserted` on it); a denial predicate after it inside the same sentence makes the item unresolved. Closes the "quoted claim then denied" class.
6. **I5 single-mechanism rule** — the evaluated I5 line must carry exactly ONE `REWITTEN_IN_PLACE_RE` occurrence, and it must be asserted; a duplicated mechanism clause is a defect. Closes the "duplicated mechanism claim" class.
7. **Idiom class extension** — add `("not", "less", "than")` to `IDIOMS` so `not less than three` rescues the negator (the benign idiom class).
Do not change the output line shape (`C1_ROUTED: value=V population=7 i1=.. i7=.. guard=G`), the modes (`--root`, `--repo`, `--fleet`, `--no-challenge`, `--selftest`, `--json`), or any existing selftest case. Add selftest cases: one isolating case per fix above (named after the class, never quoting a sealed fixture), plus one per round-63 residual fixture so the existing 102 cases still pass. Target `C1_CHECK_SELFTEST: PASS (cases=N)` with N ≥ 109.
Verify WITHOUT the sealed file: on a slim tree, (a) the unmodified copy reads `value=0`; (b) a synthetic instance of each of the five forgery classes reads `value>=1`; (c) a synthetic instance of each of the three benign classes reads `value=0`. Record every line in `{LANE}/.ufo/waves/round-64/build/R64ExecC1Grammar/grammar.md` with the new `sha256sum`/`wc -l` and the case count.""",
        f"""`python3 -I -B plans/round-61-c1-check.py --selftest` exits 0 with `C1_CHECK_SELFTEST: PASS (cases=N>=109)`; the unmodified slim copy reads `value=0`; each of the five forgery classes reads `value>=1` and each benign class `value=0` on its synthetic instance; the round-63 residual tables still close (`accepted=0 rejected=0`); `grammar.md` records every command and output and states that the sealed file was not read. End with `SEAT-STATUS: complete` or `SEAT-STATUS: partial <reason>`.""",
    ),
    item(
        "R64ExecC1Counter", "executor", ["calibration", "operability"],
        f"Write `{LANE}/plans/round-64-c1.sh` — the `C1_HELDOUT` counter over the sealed held-out table (8 fixtures: H = F2,F6,F8,F10,B4; Q = P6,B5,P7) with guard legs (a)-(e). You own that one file plus your receipts.",
        f"""Read `{LANE}/plans/round-64.md` §C1 (as amended by A1 — the H/Q enumeration is in the predicate sentence itself) and `{LANE}/plans/round-63-c1.sh` (660 lines) as the model: same modes (`[revision]`, `--tree DIR`, `--selftest`, `--no-challenge`), same fixture-application discipline, same scratch discipline, same refusal practice (refusals print only `c1-heldout:` lines, never a `C1_HELDOUT:` line).
It seals the held-out table at its frozen sha256 `b0f51e2a7e7b5b62efa17c91761e24e01fe1a3ff384181e468b628544faa93c2` (`sha256sum` check → SETUP on mismatch, never a pass) and prints exactly:
`C1_HELDOUT: heldout=A population=8 guard=G (real=… selftest=… resid=… stub=… vehicle=…)`, exit 0 iff guard=1 and A=0; 1 otherwise; 2 SETUP.
Measure legs (each on a fresh slim tree copy; anchor must occur exactly once or SETUP):
- H (ids F2,F6,F8,F10,B4): `heldout` increments when the copy prints `C1_ROUTED: value=0` (the forgery is accepted → the checker failed to catch it).
- Q (ids P6,B5,P7): `heldout` increments when the copy prints a `value` integer ≥ 1 (a benign rewrite was rejected).
Guard legs, all on the same measured tree:
- `real` — the unmodified copy prints `value=0` (the seven round-61 corrections still resolve).
- `selftest` — the tree's checker `--selftest` exits 0 with `C1_CHECK_SELFTEST: PASS (cases=N)`, N ≥ 109 (raise the floor with the hardening; record it in the header).
- `resid` — the round-63 counter still reads `C1_RESIDUAL: accepted=0 rejected=0 population=10/6 guard=1` on the same tree (invoke `bash <tree>/plans/round-63-c1.sh --tree <tree>` when that file exists; on a BASE tree it does not, so this leg reads 0 there — record that as the BASE reading).
- `stub` — a printer-stub checker (a copy of the measured checker whose whole body is `print("C1_ROUTED: value=0 population=7 …")`) must be refused: no `C1_HELDOUT:` line and non-zero exit.
- `vehicle` — the A4 lookup-table vehicle defined in plan §C1(e) (a checker carrying a literal `NEGATORS = frozenset(())` dead line, a 15-string fixture lookup over the round-63 residual/benign tables, and a constant `C1_CHECK_SELFTEST: PASS (cases=91)`) must NOT reach `heldout=0`: run it as the measured checker on the held-out set and require `heldout>=1` (it cannot answer the held-out fixtures). Build the vehicle yourself in your scratch from the plan's description — it is a 40-line Python file, and it must read `accepted=0 rejected=0` on the round-63 tables to be the real vehicle (show that reading in your receipt).
`--selftest` must be fixture-driven (no lane instruments needed): assert the TSV shape and seal, the H/Q parsing, the guard composition (each leg forced to 0 reads guard=0), the stub refusal, and a negative vector for the vehicle leg (a copy of the vehicle that DOES answer the held-out ids must read `heldout=0` so the leg is shown able to fail).
Run the counter on a full BASE tree and record the BASE reading (`heldout=8 population=8 guard=?`) in `{LANE}/.ufo/waves/round-64/build/R64ExecC1Counter/counter.md` with the exact hashes and the selftest case count.""",
        f"""`bash plans/round-64-c1.sh {BASE}` prints `C1_HELDOUT: heldout=8 population=8 …` rc 1 (the no-work control — K1); `bash plans/round-64-c1.sh --selftest` prints `C1_HELDOUT_SELFTEST: PASS (cases=N)`; the seal check refuses a mutated table copy with SETUP rc 2; the vehicle leg is shown able to fail; `counter.md` records every command and output. End with `SEAT-STATUS: complete` or `SEAT-STATUS: partial <reason>`.""",
    ),
    item(
        "R64ExecC2Counter", "executor", ["operability"],
        f"Write `{LANE}/plans/round-64-c2.sh` — the bounded end-to-end `C2_REFUSAL` counter with the `C2_RECURSION_BOUND` flag — and the `C2_RECURSION_BOUND` delegation bound in `{LANE}/plans/round-63-c2.sh`'s battery leg. You own those two files plus your receipts.",
        f"""Read `{LANE}/plans/round-64.md` §C2 and `{LANE}/plans/round-63-c2.sh` (240 lines). The defect: `round-63-c2.sh` line ~198 runs the tree's `plans/round-63-controls.sh <tree>` as its l3/l4 leg, and that battery's `probe_counters` runs `plans/round-63-c2.sh` again — unbounded recursion. Measured at BASE: `timeout 240 bash plans/round-63-c2.sh --tree .` ⇒ rc=124, 7-byte receipt (`.ufo/waves/round-64/base/c2-e2e-head.txt`).
1. **`plans/round-64-c2.sh`** — same five legs as round 63 (L1/L2 CM2a/CM2b, L3/L4 the battery's `C2-F6`/`C1-F8` mismatch, L6 the I6-conjunct drop), same guard legs (a)-(d) from `round-63-c2.sh`, plus:
   - an explicit recursion bound `C2_RECURSION_BOUND` (default `1`). At `1`, the battery delegation runs the battery with `R63_CONTROLS_FIXTURE_ONLY=1` (add that branch to `plans/round-63-controls.sh`: with the variable set, `probe_counters` is skipped and only the fixture/confinement selftest path runs — the C1-F8/C2-F6 stub controls still run, since they build their own stub counters) so the leg never re-enters a counter; at `0` the delegation runs the full battery unchanged (the old behaviour).
   - prints exactly one line: `C2_REFUSAL: killed=K population=5 guard=G (l1=… l2=… l3=… l4=… l6=… selftest=… real=… terminates=… bound=…)`, exit 0 iff guard=1 and K=5 and terminates=1; 1 otherwise; 2 SETUP. `terminates=1` iff this same process reached its verdict line inside `timeout 1200`.
   - `--selftest` must assert: the verdict-line shape, the bound composition (bound=0 reads 0), a negative vector for each leg composition, and that a fixture-only battery run terminates under a short timeout while a full-battery run does not.
2. **`plans/round-63-c2.sh`** — add the `R63_CONTROLS_FIXTURE_ONLY` pass-through to its battery invocation (one line, no behaviour change when unset). Keep its output line and exit codes unchanged.
Measure on a full BASE tree: `timeout 1200 bash plans/round-64-c2.sh --tree <tree>` must print its verdict line (record rc and the line), and `C2_RECURSION_BOUND=0 timeout 240 bash plans/round-64-c2.sh --tree <tree>` must read rc=124 with no verdict line (the refutation leg). Record every command, its rc and the readings in `{LANE}/.ufo/waves/round-64/build/R64ExecC2Counter/counter.md`, with the exact sha256 of both files.""",
        f"""`bash plans/round-64-c2.sh --tree <BASE tree>` prints exactly one `C2_REFUSAL: killed=5 population=5 guard=1 (… terminates=1 bound=1)` line inside `timeout 1200`; `C2_RECURSION_BOUND=0` does not terminate in 240 s (rc=124, no verdict line); `bash plans/round-64-c2.sh --selftest` prints a PASS line; `counter.md` records every command and output with both file hashes. End with `SEAT-STATUS: complete` or `SEAT-STATUS: partial <reason>`.""",
    ),
    item(
        "R64ExecControls", "executor", ["operability"],
        f"Write `{LANE}/plans/round-64-controls.sh` — the pre-freeze control battery carrying the recursion-bound refutation control plus the no-work and stub controls — and add the `R63_CONTROLS_FIXTURE_ONLY` branch to `{LANE}/plans/round-63-controls.sh` if the C2 seat has not. You own those two files plus your receipts.",
        f"""Read `{LANE}/plans/round-64.md` §C1/§C2 and `{LANE}/plans/round-63-controls.sh` (590 lines; per-control line `CONTROL <id> expect=… observed=… verdict=match|mismatch|skip`).
Write `plans/round-64-controls.sh` with the same shape and a fixture-driven `--selftest` (no lane instruments required, no `bao`). It takes a tree argument, prints `CONTROLS: match=N mismatch=M`, exit 0 iff mismatch=0, 1 on a mismatch, 2 SETUP. Controls:
- `C1-F9` — a printer-stub copy of `plans/round-64-c1.sh` (prints `C1_HELDOUT: heldout=0 population=8 guard=1 …`, exits 0) on the tree must read `mismatch` against the expected BASE line `heldout=8`.
- `C2-F7` — a constant-verdict copy of `plans/round-64-c2.sh` (prints `C2_REFUSAL: killed=5 population=5 guard=1 … terminates=1`, exits 0) must read `mismatch` against the expected BASE line `terminates=0`.
- `C2-BOUND` — the refutation leg: with `C2_RECURSION_BOUND=0` and `timeout 240`, `plans/round-64-c2.sh` must NOT terminate (no verdict line); a run that terminates under the bound reads `mismatch`. This control is what makes the bound non-decorative.
- `C1-NOWORK` / `C2-NOWORK` — the unmutated counters on a BASE tree must read `heldout=8` / `terminates=0` (the no-work controls).
- `C1-REAL` / `C2-REAL` — the unmutated counters on the candidate must print their verdict lines with `guard=1`.
- the round-63 battery's own controls re-run as `PRIOR-<id>` rows (delegate to `plans/round-63-controls.sh --selftest`, re-emit each verdict).
`--selftest` must be fixture-driven: build stub counters and stub trees under your scratch and assert each control's expected verdict, with a named `FINDING R64C-CTL-ST-<case>` line and exit 1 on a failing case. Record the battery's BASE reading in `{LANE}/.ufo/waves/round-64/build/R64ExecControls/controls.md` with every command and output.""",
        f"""`bash plans/round-64-controls.sh <BASE tree>` prints `CONTROLS: match=N mismatch=M` with `C1-F9`/`C2-F7`/`C2-BOUND` reading `mismatch` on a stub/full-battery tree and the no-work controls reading `match`; `bash plans/round-64-controls.sh --selftest` prints `CONTROLS_SELFTEST: PASS (cases=N)`; `controls.md` records every command and output. End with `SEAT-STATUS: complete` or `SEAT-STATUS: partial <reason>`.""",
    ),
    item(
        "R64ExecRouted", "executor", ["calibration", "freshness"],
        f"Write `{LANE}/plans/round-64-routed.sh` — the receipt for the round-63 spot-check's routed defects D-63-1/D-63-2/D-63-3 (work items, not a claim). You own that one file plus your receipts.",
        f"""Read `{LANE}/corpus/lessons/round-63-verifier-spotcheck.md` §6 and `{LANE}/plans/round-64.md` §"Routed defects". Write `plans/round-64-routed.sh` with one leg per defect, each able to fail:
- **`d1`** (D-63-1, the lookup-table guard vacuum): require `plans/round-64-c1.sh`'s guard to carry the `vehicle` leg and require the counter's receipt/header to name the A4 vehicle; re-derive that the vehicle reads `accepted=0 rejected=0` on the round-63 tables (so it IS a vehicle) while `heldout>=1` on the held-out set. A counter with no vehicle leg reads `d1=0`.
- **`d2`** (D-63-2, the C2 recursion): require a single bounded invocation to produce one `C2_REFUSAL:` line (re-run `timeout 1200 bash plans/round-64-c2.sh --tree <tree>` on a scratch copy and require a verdict line + rc 0/1), and require `C2_RECURSION_BOUND=0` under `timeout 240` to produce none. A tree that still hangs reads `d2=0`.
- **`d3`** (D-63-3, carried, nothing open): require the round-63 final receipts (`.ufo/waves/round-63/final/` receipts (c1-residual, c2-refusal, controls, release-clock, doc-audit, claims-declared)) to exist and the round-63 lesson to cite them; record the disposition.
Print `ROUTED: d1=<0|1> d2=<0|1> d3=<0|1>` and exit 0 iff all three read 1. Show each leg able to fail on a scratch copy (record the failing reading). Record every command and output in `{LANE}/.ufo/waves/round-64/build/R64ExecRouted/routed.md`.""",
        f"""`bash plans/round-64-routed.sh` prints `ROUTED: d1=… d2=… d3=…` and exits 0/1 accordingly; each leg is shown able to fail (recorded); `routed.md` carries every command and output. End with `SEAT-STATUS: complete` or `SEAT-STATUS: partial <reason>`.""",
    ),
    item(
        "R64ScribeEntry", "scribe", ["depth", "calibration"],
        f"Draft the round's knowledge entry, the two new QUALITY criteria and the gate-registry rows. You own `{LANE}/corpus/knowledge/claim-instrument-heldout.md`, `{LANE}/corpus/QUALITY.md` (append-only rows) and `{LANE}/SKILL.md` (registry rows only).",
        f"""Read `{LANE}/plans/round-64.md` §C1/§C2, `{LANE}/corpus/QUALITY.md` (the last rows, append-only), `{LANE}/SKILL.md` §Gate registry (the round-63 additions at `:873-879`) and `{LANE}/corpus/lessons/round-63.md` §Claims/§Gate (the entry shape). Read `{LANE}/corpus/knowledge/claim-instrument-falsifiability.md` and `{LANE}/corpus/knowledge/negation-scope-grammar.md` so the new entry extends them rather than restating them.
1. **`corpus/knowledge/claim-instrument-heldout.md`** — opens with the provenance trio `source:` (one `S###` row opened this round; take it from `{LANE}/.ufo/waves/round-64/capture/notes.md` once the scout has written it — if the notes are absent, cite S137 or S139 with the anchor you re-open yourself and say so), `verified-at:` (2026-11-08) and `recheck:` (a command or cadence). Sections: §The held-out rule (a checker's own committed fixture tables are not evidence for that checker; a held-out set sealed before the hardening, plus a vehicle that answers the committed tables, is what separates a grammar from a lookup); §The two-sided population (H/Q shape classes with their measured before→after, quoting no sealed fixture string); §Bounds (eight fixtures are eight fixtures; a lookup table with one fresh entry per held-out fixture would pass — the vehicle leg is the only witness; a structural read cannot prove the corrected sentence true); §Falsifiers.
2. **`corpus/QUALITY.md`** — append two criteria, each citing `corpus/lessons/round-64.md`: **QM85** (a checker's fixture table cannot be its own test set: a claim that an instrument implements a rule carries a held-out set sealed before the hardening, and the instrument's own committed tables are re-run as a separate guard leg — a regression there fails the guard, not the claim) and **QM86** (a counter that delegating legs can re-enter must carry an explicit bound flag; the bound's refutation leg — bound off, must NOT terminate inside a fixed timeout — is part of the claim, and a bound that cannot fail is decorative). Append only; never rewrite a row.
3. **`SKILL.md`** — append gate-registry rows for `plans/round-64-c1.sh`, `plans/round-64-c2.sh` and `plans/round-64-controls.sh`: `kind: gate`, a runnable self-invocation with its case count, the exit-code map (0/1/2), the pinned seal/hashes and the falsifiers. No `none of its own`.
Record every command and output in `{LANE}/.ufo/waves/round-64/build/R64ScribeEntry/entry.md`.""",
        f"""The three files carry the drafted content; the entry opens with the provenance trio and cites an `S###` row; QM85/QM86 are appended with lesson pointers; the registry rows name the three gates with runnable selftests and their verdict maps; `entry.md` records the checks. End with `SEAT-STATUS: complete` or `SEAT-STATUS: partial <reason>`.""",
    ),
    item(
        "R64ScribeRecords", "scribe", ["calibration", "freshness"],
        f"Draft the round lesson (with its Gate and Mistakes sections) and the SOURCES.md row block (the L1 appends). You own `{LANE}/corpus/lessons/round-64.md` and `{LANE}/corpus/README.md`.",
        f"""Read `{LANE}/plans/round-64.md` (including Amendment A1), `{LANE}/corpus/lessons/round-63.md` (the Gate/Mistakes shape), `{LANE}/corpus/SOURCES.md` (contract v1 header and the last rows) and `{LANE}/corpus/README.md` (the coverage map and `## Frontier`).
1. **`corpus/lessons/round-64.md`** — sections: claims (C1/C2 with their frozen predicates and measured readings), `## Gate` (one row per source opened this round: URL, access date 2026-11-08, ≤25-word located quote, admit/reject with reason and flip — take the quotes from `{LANE}/.ufo/waves/round-64/capture/notes.md` and re-resolve each with `python3 corpus/rendered-text-v1.py locate`), `## Mistakes` (at least one row: class, evidence pointer, captured-by, fix able to fail — the round's own first mistake is mandatory: the pre-amendment held-out census was wrong for 10 of 19 rows, caught by nobody until the L1 re-measured it, and the fix is that a population census is re-derived per fixture before it is frozen), `## Routed dispositions` (D-63-1/D-63-2/D-63-3), `## considerthese` (name the sentence that no still-unimplemented proposal is mined), `## Wave` (left as a placeholder line for the L1), `## Bounds`.
2. **`corpus/SOURCES.md` row block** — draft the rows for the opened sources in `{LANE}/.ufo/waves/round-64/build/R64ScribeRecords/sources-block.md` (11 columns, no `|` inside a cell, `status=mined` only for a row an admitted entry cites, rejected rows carry `REJECTED: <reason>; flip: <what would change it>`); the L1 appends them. If S143's re-verification changed the bytes, draft the superseding row with `supersedes S143 —`.
3. **`corpus/README.md`** — add the round's coverage-map row and its `## Frontier` line for the held-out-instrument ground.
Record every command and output in `{LANE}/.ufo/waves/round-64/build/R64ScribeRecords/records.md`.""",
        f"""`corpus/lessons/round-64.md` carries the required sections with ≥3 Gate rows and ≥1 Mistakes row (the census mistake is present); `sources-block.md` carries the registry rows in 11 columns; `corpus/README.md` carries the new coverage-map row and frontier line; `records.md` records the locate outputs. End with `SEAT-STATUS: complete` or `SEAT-STATUS: partial <reason>`.""",
    ),
    item(
        "R64Reviewer", "reviewer", ["calibration", "operability"],
        f"Attack the round's instruments: find forgery classes the hardened checker still accepts, benign rewrites it still rejects, and guard legs that cannot fail. Read-only on lane source: write only your receipts.",
        f"""Read `{LANE}/plans/round-64.md` §C1/§C2 (as amended by A1), `{LANE}/corpus/lessons/round-63-verifier-spotcheck.md` §2 and the round-63 reviewer's table (`{LANE}/.ufo/waves/round-63/w1/R63Reviewer.md`). Work on slim tree copies under your scratch; never edit a lane instrument.
1. Build at least twelve NEW forgery instances across the classes the round claims to close and beyond them: a denial predicate in a later sentence, a negator in a previous sentence, a subject swap with a third subject, an unbound duplicate pair, a duplicated mechanism clause with a contrastive hedge, a `no such`-style phrase the denial list misses, a fabricated stamp that is a derived committer time, a fraction paired with a percentage from a different denominator, an appositive that hides a negation, and a token form the lists do not carry.
2. Build at least six NEW benign rewrites the hardened checker must accept: an appositive, a passive, a numeric form, a hyphenated form, a contrastive form, a parenthetical aside, an em-dash aside, and a quoted-but-asserted form.
3. Attack the counters: a stub that prints the target line plus every leg field; a counter whose `--selftest` prints PASS without executing a case; a battery whose control list is empty; a bound flag read once and never re-checked (make `C2_RECURSION_BOUND=0` terminate under 240 s by a shim and see whether `C2-BOUND` notices).
Record every tree, the exact verdict line and your verdict (closed / open with a finding id) in `{LANE}/.ufo/waves/round-64/build/R64Reviewer/findings.md` with a severity and a fix for every open finding.""",
        f"""`findings.md` carries ≥12 new forgery instances and ≥6 new benign rewrites with measured lines, the counter attacks, and a severity + fix per open finding. End with `SEAT-STATUS: complete` or `SEAT-STATUS: partial <reason>`.""",
    ),
    item(
        "R64Critic", "critic", ["calibration", "operability"],
        f"Falsify the two claims' predicates before the candidate reading: population vacuity, guard vacuity, separability, and whether a do-nothing control reaches the target. Read-only on lane source: write only your receipts.",
        f"""Read `{LANE}/plans/round-64.md` §C1/§C2 (as amended by A1) and the round-63 critic's findings (`{LANE}/.ufo/waves/round-63/w1/R63Critic.md`).
1. **C1**: is `heldout=0` reachable without the grammar (a checker that rejects every C1 tree below some token count; a checker that reads no file)? Is each H fixture genuinely accepted at BASE and each Q genuinely rejected (re-derive from `{LANE}/.ufo/waves/round-64/base/census-a1.md` and your own runs)? Does the vehicle leg reduce to a needle (the plan names this ceiling — is the reduction total)? Can the seal check be satisfied by editing the counter's constant instead of the table? Is the claim separable from C2 (does C1 need any C2 file)?
2. **C2**: is `terminates=1` reachable by simply deleting the battery leg (which would also delete L3/L4)? Does the bound flag actually bound, or does a second recursion path remain (`round-62-controls.sh` → `round-61-c2.sh` → …)? Can a stub that prints the expected line pass? Is `killed=5` still the five round-63 legs, or did the bound change a leg's semantics?
3. **Both**: name every ceiling the plan smooths and every coupling it does not declare. Propose the cheapest do-nothing control and say whether it meets the target.
Record each finding with id, severity, the observation and the fix in `{LANE}/.ufo/waves/round-64/build/R64Critic/critique.md`.""",
        f"""`critique.md` carries ≥8 findings with ids, severities, measured observations and fixes; the do-nothing-control verdict is explicit. End with `SEAT-STATUS: complete` or `SEAT-STATUS: partial <reason>`.""",
    ),
    item(
        "R64MutC1", "mutation-tester", ["calibration"],
        f"Mutation-test the hardened C1 checker and the `C1_HELDOUT` counter: report every surviving mutant with its fix. Read-only on lane source: work on copies under your scratch.",
        f"""Read `{LANE}/plans/round-64.md` §C1 (as amended) and the round-63 mutation report (`{LANE}/.ufo/waves/round-63/w1/R63MutC1.md`, survivors GM5/CM2a/CM2b).
On a slim tree (and on the candidate once it exists) build at least twelve mutants of `plans/round-61-c1-check.py`, one per rule the round claims to add: drop the I7 pair-assertion, drop the every-pair-bound test, drop the subject-negatedness guard, drop the parenthetical mask, drop the em-dash mask, drop the I4 `NO_NEW` assertion, drop the I5 single-mechanism rule, remove the new idiom class, drop the negator test, drop the post-token denial test, drop the quotation mask, invert a verdict mapping. Run the checker's `--selftest` on each and record killed/survived with the exact line.
Then mutate `plans/round-64-c1.sh` (once it exists): force `heldout=0`, force `guard=1`, skip the `resid` leg, skip the `vehicle` leg, skip the seal check, and record its `--selftest` reading for each.
Record every mutant, its exact bytes delta, the observed line and the verdict in `{LANE}/.ufo/waves/round-64/build/R64MutC1/mutants.md`; every survivor carries a fix.""",
        f"""`mutants.md` carries ≥12 checker mutants and ≥4 counter mutants, each with the observed line and killed/survived, and a fix per survivor. End with `SEAT-STATUS: complete` or `SEAT-STATUS: partial <reason>`.""",
    ),
    item(
        "R64MutC2", "mutation-tester", ["operability"],
        f"Mutation-test the bounded C2 counter and the controls battery: report every surviving mutant with its fix. Read-only on lane source: work on copies under your scratch.",
        f"""Read `{LANE}/plans/round-64.md` §C2 and the round-63 mutation report (`{LANE}/.ufo/waves/round-63/w1/R63MutC2.md`).
On a full BASE tree (and on the candidate once it exists) build at least ten mutants of `plans/round-64-c2.sh`: force each of the five legs to 1, force `killed=5`, force `guard=1`, force `terminates=1` unconditionally, set the bound default to 0, make the bound flag read once at parse time and ignore a later change, skip the battery delegation, drop the real-trial leg. Run `--selftest` (and the counter on a fixture tree) for each and record killed/survived with the exact line.
Also mutate `plans/round-64-controls.sh`: empty the control list, make `C2-BOUND` read `match` unconditionally, drop the `R63_CONTROLS_FIXTURE_ONLY` pass-through; record whether the battery's own selftest catches each.
Record every mutant, its exact bytes delta, the observed line and the verdict in `{LANE}/.ufo/waves/round-64/build/R64MutC2/mutants.md`; every survivor carries a fix.""",
        f"""`mutants.md` carries ≥10 counter mutants and ≥3 battery mutants, each with the observed line and killed/survived, and a fix per survivor. End with `SEAT-STATUS: complete` or `SEAT-STATUS: partial <reason>`.""",
    ),
    item(
        "R64Connector", "connector", ["adjacency", "coverage"],
        f"Sibling-overlap scan: name every lane whose corpus or gates already hold the round's ground (held-out instrument testing, mutation-kill contracts, recursion bounds in delegating counters) and report it, never absorb it. Read-only: write only your receipt.",
        f"""Read `{LANE}/PROVINCE.md`, `{LANE}/plans/round-64.md` §C1/§C2 and the round-63 connector sweep (`{LANE}/.ufo/waves/round-63/build/R63Connector/sweep.md`).
Scan the sibling lanes under `/home/vgpnk/Projects/shokunin/*-shokunin/` (read-only) for: a held-out fixture set, a lookup-table/mutation-kill contract, a recursion bound or depth guard in a delegating gate, a stub-refusal control, a seal/sha256-checked fixture table. For each hit record the lane, the path:line, what it holds and whether kagi's claim duplicates it.
Also record the carried `ADJACENCY_SCOPE: DEFECT` breadth debt (`breadth_drift=5 breadth_unverified=1`) and whether this round moves it.
Write `{LANE}/.ufo/waves/round-64/build/R64Connector/sweep.md` with the scan commands and their output (a negative claim carries its sweep).""",
        f"""`sweep.md` names each overlapping lane with a path:line, states adjacent-vs-absorbed for each, and carries the sweep commands. End with `SEAT-STATUS: complete` or `SEAT-STATUS: partial <reason>`.""",
    ),
    item(
        "R64Sentinel", "sentinel", ["calibration", "operability"],
        f"Secret-discipline and write-scope audit of the round's artifacts. Read-only: write only your receipt.",
        f"""Read `{LANE}/corpus/QUALITY.md` QA5/QM72 and `{LANE}/plans/round-64.md`.
1. Scan every file the round created or changed under `{LANE}/.ufo/waves/round-64/` and `{LANE}/plans/round-64*` for credential shapes (unseal keys, root tokens, `op://` references, cookies, session ids, `Authorization:` values) with a counts-only scan; record the command and the hit count.
2. Check every receipt path cited by the round is inside the lane tree or the wave dir (no `/tmp`, no `/var/tmp`, no `$HYAKU_SCRATCH` path cited as citable evidence).
3. Check no seat wrote outside the lane: `git -C /home/vgpnk/Projects/shokunin status --porcelain` and `git -C {LANE} status --porcelain`, and name any file at the fleet root that names kagi round 64.
4. Check the wave's scratch discipline: `du -sh /fast/scratch/hyaku/kagi-r64/*` and name any seat tree left behind.
Write `{LANE}/.ufo/waves/round-64/build/R64Sentinel/audit.md` with the commands and their output.""",
        f"""`audit.md` carries the four checks with their commands and output, a hit count for the secret scan, and every violation named. End with `SEAT-STATUS: complete` or `SEAT-STATUS: partial <reason>`.""",
    ),
    item(
        "R64Revenger", "revenger", ["calibration", "depth"],
        f"Reverse-engineer why the round-63 C2 counter recurses and whether the round-64 bound closes EVERY re-entry path (not only the one the plan names). Read-only: write only your receipt with the call graph and the measurement.",
        f"""Read `{LANE}/plans/round-63-c2.sh`, `{LANE}/plans/round-63-controls.sh`, `{LANE}/plans/round-62-controls.sh`, `{LANE}/plans/round-62-c2.sh`, `{LANE}/plans/round-62-c1.sh`, `{LANE}/plans/round-61-c2.sh` and `{LANE}/plans/round-64.md` §C2.
1. Draw the invocation graph as it exists at BASE: which script invokes which, with the line number and the governing condition. Name every cycle, not only the `round-63-c2 → round-63-controls → round-63-c2` one the plan names.
2. Measure the recursion: run the counter with a small timeout on a scratch copy and record the deepest nesting you can observe (e.g. `ps -o pid,ppid,cmd --ppid`, or a counter you plant in a copy of `round-63-c2.sh` that appends its pid to a file). Report the observed depth and the time to reach it.
3. Decide whether the proposed bound closes every cycle: enumerate each cycle's entry point and say whether `C2_RECURSION_BOUND` (plus `R63_CONTROLS_FIXTURE_ONLY`) intercepts it. A cycle the bound does not intercept is a finding for the C2 seat.
4. Report the runtime cost per full tree copy and whether the claim's `timeout 1200` is reachable on a machine under fleet load — a bound that closes the recursion but still exceeds the budget is a failed claim.
Write `{LANE}/.ufo/waves/round-64/build/R64Revenger/recursion.md` with the call graph, every cycle, the measured depth, the per-cycle interception verdict and the timing evidence.""",
        f"""`recursion.md` carries the call graph with line numbers, every cycle named, the measured nesting depth, a per-cycle interception verdict for the proposed bound, and the timing evidence. End with `SEAT-STATUS: complete` or `SEAT-STATUS: partial <reason>`.""",
    ),
]

SPEC = {
    "wave": "kagi-r64-w1",
    "axes": ["calibration", "operability"],
    "milestone": "C1 heldout 8->0 (5 held-out forgeries rejected, 3 benign accepted, A4 vehicle refused); C2 terminated 0->1 killed=5 from one bounded run; attack seats falsify both",
    "reportDir": ".ufo/waves/round-64/w1",
    "context": CONTEXT,
    "items": ITEMS,
}

with open(OUT, "w", encoding="utf-8") as f:
    json.dump(SPEC, f, indent=1)
print("wrote", OUT, len(ITEMS), "items")
