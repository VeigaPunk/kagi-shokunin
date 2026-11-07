#!/usr/bin/env python3
"""Build the kagi round-61 v1 wave spec (16 seats). Idempotent; writes w1-spec.json."""
import json
import os

HERE = os.path.dirname(os.path.abspath(__file__))
LANE = "/home/vgpnk/Projects/shokunin/kagi-shokunin"
W = os.path.join(LANE, ".ufo/waves/round-61")

GOD = """/skill:godspeed
You are a Godspeed-enabled subagent.

1. **Name the axes.**
2. **Iterate cheap, in parallel.**
3. **Keep moves that improve any axis and harm none.**
4. **Don't aim — let the frontier walk itself.**

## IMMEDIATELY STOP ASKING CLARIFYING QUESTIONS. Execute tool calls concurrently in large batches. Do not serialize what can run in parallel. Do not output philosophical reasoning or verbose plans. Act directly via tool calls.
# Assignment
"""

CTX = """kagi round 61 attempt 1. ONE v1 wave, 16 seats (run-15 band 8-16; plan §Wave plan). L1 KagiR61 holds the canonical planner seat and is the sole integration owner and committer.
Lane repo: /home/vgpnk/Projects/shokunin/kagi-shokunin (branch master). Claim BASE c940f51689d702f1786989d56ad4663833c1452e. FROZEN predeclaration: /home/vgpnk/Projects/shokunin/kagi-shokunin/plans/round-61.md (commit 8595018164f7421864254c6c5ca762b8f201e8be) — read it, plus /home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/lessons/round-60-verifier-spotcheck.md, before you work. Never amend a frozen predicate, target, POP, kill rule or item condition; report a defect instead.
Write scope: /home/vgpnk/Projects/shokunin/kagi-shokunin plus your own scratch. Never write, commit, push or run a mutating git/jj command in the fleet repo, a sibling lane, or the lane's jj/git index; never run `git add/commit/stash/push` or any mutating `jj` anywhere. Seats return findings and files; only the L1 commits (scripts/hyaku/jj-lane.sh).
File ownership is disjoint: write ONLY the paths your item names. Receipts go under /home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-61/build/<your-seat-name>/. Every `Report:` trailer path a wave template prints is relative to /home/vgpnk/Projects/shokunin/kagi-shokunin — write it at /home/vgpnk/Projects/shokunin/kagi-shokunin/<that path>. Never write citable evidence under /tmp.
Scratch: every clone, work tree, fixture or dev-server dir lives under ${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r61/<seat-name>/ (mkdir -p; pass it explicitly; delete it before you yield). /tmp is only for files under 50 MB and never for citable evidence.
Tooling authorization (operator, 2026-10-19): you may install or upgrade tools that help the task; read /home/vgpnk/.omp/agent/RULES.md first (official channels only, update-safety gate, record tool/version/channel/reason in your report). pacman guard (orchestrator ruling 2026-10-20): ALL pacman transactions are PAUSED host-wide — install via uv tool / npx / an official binary in ~/.local/bin, or file an L0 question. Never -Sy/-Syu/-U/-R, never downgrade, never restart a host service. Never mutate host sysctls.
Secret discipline: no secret value, unseal key, root token, OTP, cookie, session id or vault/item/field name in any artifact or printed line. Generated keys/tokens stay inside your scratch dir and are deleted with it; receipts name shapes and counts only (QUALITY QM72). Fetch receipts remove Set-Cookie/Cookie values before they are written.
Absolute paths only: your tools start at the fleet root (/home/vgpnk/Projects/shokunin), not the lane.
OpenBao binary for trials: /home/vgpnk/.local/bin/bao (v2.7.2, sha256 9c5f36287c673f386e1533e9c044169a248e4ee50dd54810fa766e95bd41b788). Throwaway servers only, bound to 127.0.0.1, started under `setpriv --pdeathsig KILL`. OpenBao 2.7.2 on this host has NO `file` storage backend (`unknown storage type file`); use `storage "raft"` (with node_id/api_addr/cluster_addr) or `storage "inmem"`.
Host paths outside your scratch (/boot, /etc, /usr, /var, /efi, other users' homes) are read-only inputs: copy into scratch before working on a file, and never run a binary-editing tool with a host path as input or output. Never message agent://all; the L1 messages seats by id."""

ITEMS = []


def add(name, role, axes, target, change, accept):
    ITEMS.append({
        "name": name,
        "role": role,
        "axes": axes,
        "prompt": GOD + "# Target\n" + target.strip() + "\n\n# Change\n" + change.strip()
        + "\n\n# Acceptance\n" + accept.strip() + "\n",
    })


# ---------------------------------------------------------------- scouts
add(
    "R61ScoutSealDocs", "scout", ["freshness", "coverage"],
    """Open the three seal/seal-key documentation sources this round declares, live, and produce the located-quote evidence the registry rows and the lesson Gate need. Non-goals: no edit to corpus/SOURCES.md (the L1 appends), no trial design, no other lane file.""",
    """Fetch, with a desktop browser user agent, and keep the decoded body of:
- S125 https://openbao.org/docs/concepts/seal/ -> /home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-61/capture/S125.body
- S126 https://openbao.org/docs/commands/operator/rekey/ -> .../capture/S126.body
- S127 https://openbao.org/docs/commands/operator/generate-root/ -> .../capture/S127.body
Record for each: HTTP status, final URL, byte count, sha256 of the decoded body, fetch command, access date and the user agent string. Remove any Set-Cookie/Cookie value before writing anything.
Then write /home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-61/capture/notes.md with one section per source and, for each mechanic below, a located quote of at most 25 words with its section heading and a byte offset or line number in the captured body that resolves with `grep -c` or `python3`:
1 (S125) Shamir key shares and the threshold: how many shares are generated and how many are required to unseal; whether shares are stored by the server; the seal/unseal state machine; 2 (S125) what the unseal progress/nonce means and whether a repeated share counts; 3 (S126) the documented `operator rekey` command shape, its `-init`/`-nonce`/`-verify` flags and any stated backend or seal restriction; 4 (S127) generate-root: the OTP role, `required`/`progress`/`complete`, `-decode`, and what the encoded token is XORed with; 5 (S126/S127) any sentence that states a rekey or generate-root operation is unsupported, refused or unavailable on a backend.
Mark anything the page does not state as `NOT STATED`; never infer a mechanic.""",
    """All three bodies exist under .ufo/waves/round-61/capture/, each sha256 in notes.md equals `sha256sum` of the body, and every quoted phrase resolves verbatim in its body (show the resolving command per quote). End with `SEAT-STATUS: complete` or `SEAT-STATUS: partial <reason>`.""",
)

add(
    "R61ScoutRouted", "scout", ["calibration"],
    """Independently re-derive every number `plans/round-61.md` §C1 compares for items I1–I7 from the lane repository at BASE c940f51, and report any number the plan states wrongly. Non-goals: no lane file edits, no fixes (the L1 lands them), no counter code.""",
    """Work read-only. For each item run the derivation yourself and record the command, the raw output and the value:
I1 result count and the `R60MutCounters` output byte length from `.ufo/waves/round-60/w1-results.json`; the R37/§Bounds lines in `corpus/lessons/round-60.md`.
I2 `grep -n 'round-60-c2.sh' SKILL.md` and the selftest cell of that row; whether `plans/round-60-c2.sh` accepts `--selftest` (read its argument parser).
I3 `plans/round-60.md` §A3 item 2 text; `grep -niE 'form|content-type' .ufo/waves/round-60/final/l1-probe.txt`; the M60-2 line in the round-60 lesson.
I4 the round-60 report's quality-trend sentence (fleet path /home/vgpnk/Projects/shokunin/.ufo/reports/round-60/kagi.md) and the round-60 lesson's §Bounds text.
I5 `git diff --numstat 14a6c07d 818d2a82 -- LOG.md` and the round-60 LOG wave line.
I6 `.ufo/watchdog.log` launch/complete lines for kagi round=60; `git log --format='%ci' a677c78e..818d2a82` (list them).
I7 the role mix of `.ufo/waves/round-60/w1-results.json`: which of {reviewer, critic, mutation-tester, labrat, sentinel} are present, and the total.
Also report whether `plans/round-61.md` states the correct BASE commit and whether each item's required condition is stated so a checker can read it from bytes alone (name any ambiguity with the exact sentence).""",
    """Write `.ufo/waves/round-61/build/R61ScoutRouted/rederive.md`: one row per item (plan's number, re-derived number, command, agree/disagree), then a `## Ambiguities` section. End with `SEAT-STATUS: complete` or `SEAT-STATUS: partial <reason>`.""",
)

# -------------------------------------------------------------- executors
add(
    "R61ExecTrial", "executor", ["operability"],
    """Write and prove `corpus/openbao-seal-trial.sh` in the lane: the executed OpenBao seal / unseal key-share custody trial `plans/round-61.md` §C2 declares. You own that one file plus your build receipts.""",
    """Read `plans/round-61.md` §C2 (frozen). Implement:
- `bash corpus/openbao-seal-trial.sh [--work DIR] [--selftest]` starts throwaway `bao server` processes on 127.0.0.1 under `setpriv --pdeathsig KILL`, resolves `bao` through PATH only (never an absolute path), and runs T1–T5 from the frozen POP:
  T1 init: a raft-backed server (`storage "raft"` with node_id/api_addr/cluster_addr) is initialized `-key-shares=5 -key-threshold=3`; assert 5 shares and threshold 3 in the init output, `initialized=true sealed=true t=3 n=5` in `sys/seal-status`, and that no file under the storage path contains any of the five base64 shares.
  T2 unseal threshold: one share -> progress 1/3 and sealed; the SAME share again -> progress stays 1/3; a second distinct share -> 2/3; a third -> sealed=false t=3 n=5.
  T3 seal: with the root token `operator seal` -> sealed=true; an authenticated request while sealed -> HTTP 503; `sys/seal-status` without a token -> HTTP 200.
  T4 generate-root: `-init` yields nonce/otp and `required=3`; three shares progress 1,2,3 to complete with an encoded token; `-decode` with the OTP yields a 26-character token that authenticates (200 on sys/seal-status); `-decode` with a wrong OTP does not yield that token.
  T5 rekey refused: `operator rekey -init -key-shares=3 -key-threshold=2` exits non-zero with HTTP 405 `unsupported operation` on BOTH the raft server and an `inmem` server.
- `KAGI_SEAL_SHIM=SH1..SH5` flips exactly its designated test's verdict client-side (baseline vector HHHHH; SH1 -> BHHHH, SH2 -> HBHHH, SH3 -> HHBHH, SH4 -> HHHBH, SH5 -> HHHHB). An unknown shim is `SETUP` exit 2.
- No `bao` on PATH -> `SETUP no bao on PATH`, exit 2, no HOLDS line.
- `--selftest` is fixture-driven (a stub-`bao` harness; no OpenBao binary, no network) with at least 8 cases: honest baseline holds=5 exit 0; each shim flipping exactly its own test exit 1; an injected `ERROR` exit 2; unknown shim exit 2; no-bao exit 2; a failing case prints a named `FINDING SEAL-ST-...` id.
- Output line: `OPENBAO_SEAL_TRIAL: HOLDS holds=5 broken=0 error=0 bao=v2.7.2` (or `BROKEN holds=<n> broken=<m> …`), rc 0/1/2. Print no key, token, OTP or nonce value; name shapes and counts only.
Run it for real twice (two independent runs, receipts under your build dir), run each shim, run the no-bao leg and the selftest, and record every receipt.""",
    """`bash corpus/openbao-seal-trial.sh --work <scratch>` twice: both receipts end `HOLDS holds=5 broken=0 error=0`, rc 0. Each shim receipt reads `BROKEN holds=4 broken=1` with exactly its own test moved. The no-bao leg reads `SETUP no bao on PATH` rc 2 with no HOLDS line. `--selftest` prints `SEAL_SELFTEST: PASS (cases=N)` with N >= 8, rc 0, and a mutated copy of the script exits 1 with a named FINDING. Write `receipts.md` indexing every receipt. End with `SEAT-STATUS: complete` or `SEAT-STATUS: partial <reason>`.""",
)

add(
    "R61ExecCounterC1", "executor", ["calibration"],
    """Write the C1 counter and its checker: `plans/round-61-c1.sh` (thin driver) and `plans/round-61-c1-check.py` (the seven-item checker with `--selftest`). You own those two files plus your build receipts. Model them on `plans/round-60-c1.sh` and `plans/round-60-c1-check.py`.""",
    """Read `plans/round-61.md` §C1 (frozen) and `plans/round-60-c1-check.py` for the house style: `python3 -I -B`, `--root`, `--repo`, `--no-challenge`, `--json`, output `C1_ROUTED: value=V population=7 i1=.. i7=.. guard=G`, exit 0 iff guard=1 and V==0, 1 otherwise, 2 SETUP, and a `--selftest` that builds fixture trees in a scratch dir (honouring TMPDIR/--work) and proves each item can read 0 and 1 plus the guard challenge.
Implement the seven items exactly as the plan states them, deriving every compared number from the measured tree or a named revision:
I1 after the R37 line in `corpus/lessons/round-60.md`, a `supersedes R37` line stating `results=<R> output=<B>` (R and B derived from `.ufo/waves/round-60/w1-results.json`) and naming `mutants.md`.
I2 `bash <tree>/plans/round-60-c2.sh --selftest` exits 0 printing `C2_SELFTEST: PASS (cases=N)` N>=6; a mutated copy exits non-zero with a named FINDING; the SKILL.md row for `plans/round-60-c2.sh` carries `--selftest` and not `none of its own`.
I3 `plans/round-60.md` carries after §A6 a `^## Amendment A7` heading naming `A3 item 2`, `form`, `l1-probe.txt` and stating `withdrawn`; the round-60 lesson carries a line naming `M60-2`, `A3 item 2`, `second instance`.
I4 the round-60 lesson carries a `supersedes the round-60 quality-trend sentence` line quoting `no new record defect`, naming D1, D2, D3 and stating `three`.
I5 `LOG.md` carries after the round-60 wave line a `supersedes the round-60 LOG wave line` line naming `818d2a82` and `14a6c07d`, stating `insertions=1 deletions=1` and `rewritten in place`; with `--repo`, derive the two numbers from `git diff --numstat 14a6c07d 818d2a82 -- LOG.md`.
I6 the round-60 lesson carries a `supersedes the round-60 stale-lane paragraph` line naming `2026-11-07T15:03:17-03:00 launch kagi round=60` and at least three `-03:00` timestamps that each occur in `git log --format='%ci' a677c78e..818d2a82` (derived when `--repo` is given).
I7 the round-60 lesson carries a `supersedes the round-60 attack-share arithmetic` line stating `3/16`, `4/16`, `18.75` and `25`, with 3/4/16 derived from the round-60 results role mix.
The guard: all seven items evaluated (no skip), and on a copy of the measured tree whose only delta is `deletions=1` -> `deletions=2` in the I5 line the checker prints exactly value+1; a printer stub that always prints value=0 must fail that challenge. The checker must never execute a lane gate other than the two `--selftest` invocations I2 names, must not write inside the measured tree, and must delete its scratch.""",
    """`bash plans/round-61-c1.sh c940f51` (BASE) prints `C1_ROUTED: value=7 population=7 i1=0 i2=0 i3=0 i4=0 i5=0 i6=0 i7=0 guard=0` (or `value=FAIL` with the diagnostic `value=7 population=7`), rc 1. `python3 -I -B plans/round-61-c1-check.py --selftest` prints `C1_CHECK_SELFTEST: PASS (cases=N)` with N >= 20, rc 0. The guard challenge leg fires (value+1 on the deletions=2 delta; the printer stub fails). Write `receipts.md` with the BASE reading, the selftest receipt and the challenge receipts. End with `SEAT-STATUS: complete` or `SEAT-STATUS: partial <reason>`.""",
)

add(
    "R61ExecCounterC2", "executor", ["operability"],
    """Write `plans/round-61-c2.sh`: the C2 counter that scores the seal trial's value 0..5 with a guard. You own that one file plus your build receipts. Model it on `plans/round-60-c2.sh`.""",
    """Read `plans/round-61.md` §C2 (frozen) and `plans/round-60-c2.sh` for the house style. `bash plans/round-61-c2.sh [revision | --tree DIR]` materialises the revision into a scratch dir (`git archive`), then:
- runs `corpus/openbao-seal-trial.sh --work <scratch>` twice independently and requires both `HOLDS holds=5 broken=0 error=0` rc 0;
- runs each `KAGI_SEAL_SHIM=SH1..SH5` and requires `BROKEN holds=4 broken=1` with exactly its own test moved (vector `sh1=BHHHH … sh5=HHHHB`);
- runs the no-bao leg (a PATH without bao) and requires `SETUP` rc 2 and no HOLDS line;
- runs the trial's `--selftest` and requires `SEAL_SELFTEST: PASS (cases=N)` N>=8 rc 0;
- scans the trial and its receipts for secret-shaped material (unseal key/root token/OTP/nonce values) and requires none;
- guard=1 iff every leg above ran and the trial file's sha256 is recorded.
Output: `C2_SEAL_TRIAL: value=V tests=5 pass=P shims=S vectors=ok/5 selftest=1 guard=G (absent)` with the same field order as the round-60 counter; exit 0 iff guard=1 and V==5, 1 otherwise, 2 SETUP. At BASE (no trial) it must print `value=0 … (absent)` rc 1. Never write inside the measured tree; honour TMPDIR/--work; delete scratch.""",
    """`bash plans/round-61-c2.sh c940f51` prints `C2_SEAL_TRIAL: value=0 tests=5 pass=0 shims=0 vectors=0/5 selftest=0 guard=0 (absent)`, rc 1. On the current tree with the trial present it prints `value=5 tests=5 pass=5 shims=5 vectors=ok/5 selftest=1 guard=1`, rc 0 (coordinate with R61ExecTrial's file; if the trial is not yet landed, record the absent leg and re-run when it appears). Write `receipts.md`. End with `SEAT-STATUS: complete` or `SEAT-STATUS: partial <reason>`.""",
)

add(
    "R61ExecFixRecords", "executor", ["calibration"],
    """Land five of the seven C1 corrections in the lane's record files: I1, I3, I4, I6, I7 in `corpus/lessons/round-60.md` and `plans/round-60.md`, and I5 in `LOG.md`. You own exactly those three files (append-only edits) plus your build receipts. Do NOT touch SCORECARD.md, SKILL.md, plans/round-60-c2.sh, corpus/SOURCES.md or any round-61 file.""",
    """Read `plans/round-61.md` §C1 (frozen) and `corpus/lessons/round-60-verifier-spotcheck.md` §7. Append, never rewrite:
- In `corpus/lessons/round-60.md`: a correction block that (a) states `supersedes R37` with `results=<R> output=<B>` derived from `.ufo/waves/round-60/w1-results.json` and names `mutants.md`; (b) states `supersedes the round-60 quality-trend sentence`, quotes `no new record defect`, names D1, D2, D3 and states `three` new record defects; (c) states `supersedes the round-60 stale-lane paragraph`, names the driver line `2026-11-07T15:03:17-03:00 launch kagi round=60`, and carries at least three `-03:00` committer timestamps that each occur in `git log --format='%ci' a677c78e..818d2a82`; (d) states `supersedes the round-60 attack-share arithmetic` with `3/16`, `4/16`, `18.75` and `25`, deriving 3/4/16 from the round-60 results role mix; (e) adds a line naming `M60-2`, `A3 item 2` and `second instance`.
- In `plans/round-60.md`: after the §A6 block, append `## Amendment A7` naming `A3 item 2`, `form`, `l1-probe.txt` and stating the item is `withdrawn`.
- In `LOG.md`: after the round-60 wave line, append a line stating `supersedes the round-60 LOG wave line`, naming `818d2a82` and `14a6c07d`, `insertions=1 deletions=1`, and `rewritten in place`.
Every number must be re-derived by you with a command you paste into your receipts; do not copy a number from the plan without re-deriving it. Keep the append-only convention: the superseded text stays and the correction points at it.""",
    """Write `.ufo/waves/round-61/build/R61ExecFixRecords/rederive.md` with one command+output per number you wrote, and `diff.md` showing the three files' appended blocks. Confirm `git -C /home/vgpnk/Projects/shokunin/kagi-shokunin diff --numstat` shows additions only (0 deletions) for the three files. End with `SEAT-STATUS: complete` or `SEAT-STATUS: partial <reason>`.""",
)

add(
    "R61ExecC2Selftest", "executor", ["operability"],
    """Give `plans/round-60-c2.sh` its own fixture-driven `--selftest` with a red witness and re-register its `SKILL.md` row (C1 item I2). You own `plans/round-60-c2.sh` and the one `SKILL.md` registry row plus your build receipts.""",
    """Read `plans/round-61.md` I2 (frozen), `corpus/QUALITY.md` QM76 (a `kind: gate` row carries a runnable self-invocation mode) and the round-60 counter.
- Add `--selftest` to `plans/round-60-c2.sh`: build fixture trees in a scratch dir (honour TMPDIR/--work) that exercise the counter's own verdict mapping without any real trial — at least 6 cases: absent trial -> value=0 rc 1; a fixture with all five legs satisfied -> value=5 rc 0; each of: a broken shim vector, a missing second real run, a no-bao leg that prints HOLDS, a selftest that fails, a secret-shaped string in a receipt -> value<5 rc 1 with the named conjunct in the output. Failing cases print a named `FINDING C2-ST-...` id. Unknown flag -> SETUP exit 2.
- Prove it can fail: a mutated copy of the counter whose verdict mapping is inverted (or whose shim-vector comparison is dropped) must exit non-zero with a named FINDING; keep that receipt.
- Update the `SKILL.md` gate-registry row whose name cell contains `plans/round-60-c2.sh`: its selftest cell must read `bash plans/round-60-c2.sh --selftest` with the case count and the red-witness note, and must no longer contain `none of its own`. Change nothing else in SKILL.md.""",
    """`bash plans/round-60-c2.sh --selftest` prints `C2_SELFTEST: PASS (cases=N)` with N >= 6, rc 0; the mutated copy exits 1 with a named `FINDING`; the `SKILL.md` row carries `--selftest` and not `none of its own`. Write receipts + `diff.md` (the SKILL.md row old->new). End with `SEAT-STATUS: complete` or `SEAT-STATUS: partial <reason>`.""",
)

add(
    "R61ExecControls", "executor", ["calibration", "operability"],
    """Write and run `plans/round-61-controls.sh`: the pre-freeze control battery `plans/round-61.md` §Control plan declares. You own that one file and `.ufo/waves/round-61/controls/` plus your build receipts.""",
    """Read `plans/round-61.md` §Control plan and `plans/round-60-controls.sh` for the house style. The battery runs on scratch copies (honour TMPDIR/--work) and prints one `CONTROL <id> <verdict>` line per control plus a final `CONTROLS: match=<N> mismatch=<M>`:
- C1-NOWORK: the BASE tree read by `plans/round-61-c1-check.py --no-challenge` prints `value=7 population=7`.
- C2-NOWORK: the BASE tree read by `plans/round-61-c2.sh` prints `value=0 … (absent)`.
- C1-F1..C1-F7: seven forgery controls, each on a copy of the candidate tree, breaking exactly one item's substance while leaving satisfied-looking text: F1 a R37 correction with the wrong result count; F2 a SKILL.md selftest cell naming a script with no `--selftest`; F3 an A7 amendment that withdraws nothing; F4 a quality-trend correction naming two of three ids; F5 a LOG correction with `deletions=2`; F6 a stale-lane correction with an invented timestamp; F7 a `round-60-c2.sh` whose verdict mapping is inverted. Each must read exactly 1 on its own item and 0 on the others (`--no-challenge`).
- C1-STUB: a printer stub that always prints `value=0` must fail the checker's challenge leg.
- C2-SH1..SH5: each `KAGI_SEAL_SHIM=SHn` run reads `BROKEN holds=4 broken=1` with exactly test n moved.
If an instrument is not yet landed when you start, write the battery against the frozen plan's conditions, run what exists, and re-run when the instrument appears (poll the file path a few times, do not wait forever). Record every command and its raw output.""",
    """`bash plans/round-61-controls.sh` prints `CONTROLS: match=<N> mismatch=0` and the receipt `.ufo/waves/round-61/controls/controls-prefreeze.txt` holds every `CONTROL ` line. A control that cannot run yet is printed `CONTROL <id> SKIP <reason>` and counted as a mismatch, not a match. End with `SEAT-STATUS: complete` or `SEAT-STATUS: partial <reason>`.""",
)

# ----------------------------------------------------------------- scribes
add(
    "R61ScribeEntry", "scribe", ["depth", "coverage"],
    """Draft the knowledge entry `corpus/knowledge/openbao-seal-key-custody.md` and the two coverage-map rows it needs in `corpus/README.md`. You own those two files plus your build receipts. Non-goals: no SOURCES.md edit (the L1 appends), no trial code, no SCORECARD.md.""",
    """Read `plans/round-61.md` §C2, the round-60 entry `corpus/knowledge/openbao-approle-secret-id-custody.md` for the house shape, and whatever the trial receipts under `.ufo/waves/round-61/build/R61ExecTrial/` carry by the time you write (if the trial is not landed, write the entry against the frozen POP and mark each unmeasured row `pending receipt` — never invent a result).
The entry opens with `source:` (S125, S126, S127 plus the trial script path), `verified-at:` and `recheck:`. Sections: the five measured mechanics (T1–T5) as a table with the observed value and the receipt that carries it; a `Docs vs binary` table (S126 documents `operator rekey`, the 2.7.2 binary answers HTTP 405 `unsupported operation` on raft and inmem — record what S126 actually says and what the trial measured); the custody reading (shares are operator-held, not server-persisted; the duplicate-share refusal; the OTP is the second factor in root-token regeneration; the sealed state answers 503 while seal-status stays readable); `§Bounds` (one host, one version pair, dev-shaped servers, no auto-unseal, no recovery keys, no seal migration, no real vault); `§Falsifiers` (the commands that would break each row).
In `corpus/README.md`, add the entry's coverage-map row and the round-61 lesson row (the lesson file is `corpus/lessons/round-61.md`), matching the existing table shape.""",
    """Both files exist with the entry's provenance trio on the first three lines, the five measured rows each naming a receipt path, the docs-vs-binary table, bounds and falsifiers. `grep -c '^source:' corpus/knowledge/openbao-seal-key-custody.md` = 1. Write `notes.md` naming every claim you could not ground. End with `SEAT-STATUS: complete` or `SEAT-STATUS: partial <reason>`.""",
)

add(
    "R61ScribeLesson", "scribe", ["calibration"],
    """Draft `corpus/lessons/round-61.md`: the round lesson with `## Gate`, `## Mistakes`, `## Routed dispositions` and the wave record. You own that one file plus your build receipts.""",
    """Read `plans/round-61.md`, `corpus/lessons/round-60.md` (house shape) and `corpus/lessons/round-60-verifier-spotcheck.md` §7.
Write:
- `## Gate`: for every new SOURCES row (S125/S126/S127) the URL, the access date, and a <=25-word located quote grounding `teaches` (take them from `.ufo/waves/round-61/capture/notes.md` when it exists; otherwise mark `pending capture` and say so). At least one admit and at least one reject with reason and flip condition (a rejected candidate may be a page that states nothing measurable, or an out-of-scope OpenBao page you opened and refused).
- `## Mistakes`: one row per mistake mined this round, shape `class · evidence pointer · captured-by · fix`, with a fix shown able to fail. Mine at least: the round-60 mutation-tester record error (D1) and the round-60 report arithmetic (D7), plus any mistake this round's own instruments produced.
- `## Routed dispositions`: a table of the seven round-60 routed defects D1–D7 with the item id (I1–I7), the file that carries the fix and the state at the time you write.
- `## Wave`: the seat list and role mix from `.ufo/waves/round-61/w1-results.json` when it exists (otherwise `pending results`), with the dead-seat count derived from that file, never assumed.
Never invent a number: every count carries its command. Never write a verdict the receipts do not carry.""",
    """The file exists with the four sections; every quoted phrase resolves in its capture; every count names its command; the `## Mistakes` table has >=2 rows with a fix each. Write `notes.md` listing anything you could not ground. End with `SEAT-STATUS: complete` or `SEAT-STATUS: partial <reason>`.""",
)

# ------------------------------------------------------------------ attack
add(
    "R61Reviewer", "reviewer", ["calibration"],
    """Attack C1 items I1–I7 and the two counters. Read-only: report findings, change no production file. Your job is to find the item that reads satisfied while its substance is absent, and the counter that cannot fail.""",
    """Read `plans/round-61.md` §C1 and §C2, then the instruments as they land (`plans/round-61-c1-check.py`, `plans/round-61-c1.sh`, `plans/round-61-c2.sh`, `corpus/openbao-seal-trial.sh`, the five record-file corrections). Re-read a path a few times before concluding it is absent.
For each of I1–I7: construct the cheapest tree that satisfies the item's literal condition while the routed defect is still unfixed (a wording-only correction, a receipt naming the wrong file, a timestamp that occurs elsewhere, a fraction that is arithmetically right but names the wrong population). Report the exact condition text that lets it through, with the command and the observed output.
For each counter: does the guard fire? Does a printer stub pass? Can a shim vector be satisfied by a constant? Does `--no-challenge` change the value? Does the counter write inside the measured tree or leak scratch? Does it honour TMPDIR? Run `--selftest` and the BASE leg yourself.
Also check the frozen predicate's arithmetic: population 7, target 0, and whether any item's condition is vacuous on the BASE tree (an item that reads 1 at BASE inflates the BASE reading and voids K2).""",
    """Write `.ufo/waves/round-61/build/R61Reviewer/findings.md`: one row per item (id, attack, command, observed, verdict `holds`/`bypass`), one row per counter defect, and a `## Predicate arithmetic` section. Every finding names the file:line it attacks. End with `SEAT-STATUS: complete` or `SEAT-STATUS: partial <reason>`.""",
)

add(
    "R61Critic", "critic", ["calibration", "operability"],
    """Falsify both claims' predicates: show whether the C1 target is reachable by a do-nothing tree, whether the C2 value can be reached without the claimed mechanics, and whether any item or test is vacuous. Read-only: findings only.""",
    """Read `plans/round-61.md` in full, then:
- C1: build the do-nothing control yourself (BASE tree, checker `--no-challenge`) and a "records-only" tree (corrections appended with invented numbers) — does the checker's derivation actually catch the invented numbers? Try at least three: a wrong result count, a wrong byte length, a timestamp that exists in the range but on a different commit.
- C2: can value=5 be reached without a real OpenBao server (a stub `bao` on PATH that prints the expected lines)? Does the counter's real-run leg distinguish a stub from the binary (sha256, version line, server log)? Does T5's 405 expectation hold on a second storage backend, and is 405 distinguishable from a permission error?
- Vacuity: for each of the five C2 tests, name the condition that would still pass if the mechanic were absent.
- Trade check: does any change in the round lower an axis (a gate weakened to make a claim pass, a selftest case removed, a SKILL.md row degraded)? Read the diffs, not the summaries.""",
    """Write `.ufo/waves/round-61/build/R61Critic/falsify.md`: one section per attack with command + observed output + verdict, and a `## Vacuity` table for the five tests. End with `SEAT-STATUS: complete` or `SEAT-STATUS: partial <reason>`.""",
)

add(
    "R61MutCounters", "mutation-tester", ["calibration"],
    """Mutation-test the round's instruments: the C1 checker, the C2 counter, the seal trial and the control battery. Report killed/survived mutants with the exact mutation and the command that shows it. Read-only on production files: mutate copies in scratch.""",
    """Read `plans/round-61.md`, then mutate COPIES in your scratch dir (never the lane files):
- `plans/round-61-c1-check.py`: at least 8 mutants — drop an item's comparison, invert a verdict, skip an item, make the guard always 1, make the challenge delta a no-op, accept a wrong byte length, accept a timestamp not in the range, accept a fraction with the wrong denominator.
- `plans/round-61-c2.sh`: at least 5 mutants — accept one real run, drop a shim vector, accept a stub `bao`, ignore the secret scan, accept selftest N<8.
- `corpus/openbao-seal-trial.sh`: at least 5 mutants — drop the duplicate-share check, drop the non-persistence check, drop the 503 check, accept a wrong OTP, drop the inmem leg of T5.
For each mutant record: file, mutation (unified diff), expected verdict, observed rc/output, killed/survived. A survivor is a finding: name the line that should have caught it.""",
    """Write `.ufo/waves/round-61/build/R61MutCounters/mutants.md` with the table and a final `MUTANTS: total=<N> killed=<K> survived=<S>` line, plus `raw/` holding each mutant's diff and output. End with `SEAT-STATUS: complete` or `SEAT-STATUS: partial <reason>`.""",
)

add(
    "R61Sentinel", "sentinel", ["adjacency", "operability"],
    """Security review of the round's artifacts: secret-shaped material, scratch confinement, host mutation, and the trial's server posture. Read-only: findings only.""",
    """Read `plans/round-61.md`, the trial, the counters and every receipt under `.ufo/waves/round-61/`.
Check and report each with a command:
1 No unseal key, root token, OTP, nonce value, cookie or session id appears in any committed artifact or receipt (scan with a shape-based pattern; a 26-char `s.` token, a base64 44-char share, a UUID nonce, a 26-char OTP). Report counts, never the matched value.
2 The trial's servers bind 127.0.0.1 only, are started under `setpriv --pdeathsig KILL`, use throwaway storage in scratch, and leave no listener behind after the run (`ss -ltn` before/after).
3 No artifact writes outside the lane repo and scratch; no `/tmp` citable evidence; scratch dirs are deleted.
4 No host mutation: no sysctl, no service restart, no package manager, no write to /boot, /etc, /usr, /var, another lane or the fleet repo.
5 The trial refuses to run against an ambient `BAO_ADDR`/`VAULT_ADDR`/`BAO_TOKEN`/`VAULT_TOKEN` (an ambient-env leg) and does not read a real `~/.vault-token`.
6 The counters do not execute arbitrary lane scripts beyond the two `--selftest` invocations the plan names, and do not follow symlinks out of the tree.""",
    """Write `.ufo/waves/round-61/build/R61Sentinel/security.md`: one row per check with command, observed, verdict, and a `## Findings` list ordered by severity with the file:line. End with `SEAT-STATUS: complete` or `SEAT-STATUS: partial <reason>`.""",
)

add(
    "R61Connector", "connector", ["adjacency", "coverage"],
    """Sibling-overlap and assimilation sweep: does any sibling lane hold OpenBao seal/unseal key-share ground or the trial+counter pattern, what does the shokuknow `merge/kagi/` package stage, and is there one still-unimplemented `considerthese/` proposal that fits this round? Read-only: findings only.""",
    """Work read-only over:
- every `/home/vgpnk/Projects/shokunin/*-shokunin/PROVINCE.md`, `SKILL.md` and `corpus/SOURCES.md` for seal/unseal/Shamir/rekey/generate-root ground (record the sweep command and the hit count per lane);
- `/home/vgpnk/Projects/shokuknow/merge/kagi/` — read `MERGE-REPORT.md`, list the staged entries and their `SOURCES.append.md` ids, and say whether any staged theme fits this round's claims (do not run any campaign tool; the repo is read-only);
- `/home/vgpnk/Projects/shokunin/kagi-shokunin/considerthese/` — the newest file's still-unimplemented proposals; pick at most one that fits this round and name the file, the proposal and the lane-bar evidence it would need (open what it points at; the reflection is a pointer, not evidence).
Also check the fleet's other lanes for a counter named `C2_SEAL_TRIAL` or a `round-61` claim that would collide with this lane's ground.""",
    """Write `.ufo/waves/round-61/build/R61Connector/sweep.md`: the sibling sweep table (lane, hit count, command), the shokuknow section (staged entries, fit verdict), the considerthese section (file, proposal, fit, evidence needed) and a `## Collisions` line. End with `SEAT-STATUS: complete` or `SEAT-STATUS: partial <reason>`.""",
)

add(
    "R61Revenger", "revenger", ["depth", "freshness"],
    """Reverse-engineer the measured rekey refusal: why does OpenBao 2.7.2 answer HTTP 405 `unsupported operation` on `sys/rekey/init`, and what does the binary actually implement? Read-only on host binaries: work on copies in scratch. Findings only.""",
    """Read `plans/round-61.md` §C2 T5 and the S126 capture when it lands.
1 Reproduce the 405 on a throwaway raft server and on an inmem server; record the exact request (method, path, body shape) and the response headers/body.
2 Find the route in the binary: `strings`/`go tool nm`-style inspection of a COPY of `/home/vgpnk/.local/bin/bao` in your scratch (never the host file) for `sys/rekey`, `rekey/init`, `unsupported operation`, and the handler that returns 405. Report the symbol/route evidence you find and what you could not resolve.
3 Check whether the CLI's `-target=recovery` or `operator rekey -verify` reaches a different route, and whether `sys/rotate` (barrier key rotation) is the supported successor — measure what each returns.
4 State the operational consequence for key-share custody: if rekey is unavailable, what does an operator do to change shares/threshold (re-init, seal migration, a new cluster)? Ground each claim in a measured command or a located quote; mark inference as `[INFERENCE]`.""",
    """Write `.ufo/waves/round-61/build/R61Revenger/rekey.md`: the reproduction (commands + raw responses), the binary evidence with the commands used, the alternative routes table, and the custody consequence with `[INFERENCE]` labels where the evidence stops. End with `SEAT-STATUS: complete` or `SEAT-STATUS: partial <reason>`.""",
)

SPEC = {
    "wave": "kagi-r61-w1",
    "axes": ["calibration", "operability"],
    "milestone": "C1 C1_ROUTED 7->0 (seven round-60 routed record defects resolved and re-checkable); C2 C2_SEAL_TRIAL 0->5 (executed OpenBao seal/unseal key-share custody trial with its own --selftest); attack seats falsify both",
    "reportDir": ".ufo/waves/round-61/w1",
    "context": CTX,
    "items": ITEMS,
}

os.makedirs(W, exist_ok=True)
with open(os.path.join(W, "w1-spec.json"), "w") as fh:
    json.dump(SPEC, fh, indent=1)
print("items", len(ITEMS), "roles", sorted({i["role"] for i in ITEMS}))
