# SelfInvSkill3 — C1 inventory, SKILL.md:261–390 (current-tense numeric self-claims)

Seat KagiR25.SelfInvSkill3-2 (leaf, read-only). BASE 4587c61a348e4528717404a68912c373f3ef4d03: lane HEAD verified; tracked tree clean (only `?? .ufo/waves/round-25/`, `?? plans/round-25.md`). Live values come from sandbox clone `/fast/scratch/kagi-r25/SelfInvSkill3/lane` (HEAD = BASE) under `env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/SelfInvSkill3/home`. Installs/updates: none. Lane edits: none.

| file:line | phrase | CURRENT/HISTORICAL | claimed | live | source (ledger id or command) | STALE? |
|---|---|---|---|---|---|---|
| SKILL.md:266 | (bounds 17–23 in `corpus/knowledge/claim-ledger.md`) | CURRENT (pointer) | 17–23 | 7 numbered bounds exist: 17 at claim-ledger.md:380 … 23 at :414; section :308–456 holds 30 | [C-bounds] → 7 | NO |
| SKILL.md:278 | `all six axes exactly once` | CURRENT (criterion) | 6 | 6 axis names at claim-ledger.sh:862 (AXES_RE :844); die at :866; SCORECARD `## Round 24 — post-move` has 6 axis rows | [C-axes] → 6; ledger R11-09 `--selftest` → `SELFTEST: PASS (151 cases)`, ok-case 74 `cells-six-axis-guard` | NO |
| SKILL.md:361–362 | disagree on eight of the line shapes a real env file contains (measured, `op` 2.35.0 | CURRENT (measured count) | 8 | **5**: op-ref-probe.sh:92 DIVERGENT_CONTRACT has 5 keys; op-ref-consumption.md:60–63 "five symmetric-difference keys"; SKILL.md:31 `divergent=5` for the same op 2.35.0 fixture | [C-eight] → 5; R12-01 (`bash corpus/op-ref-probe.sh`) UNRUN (host op + handler); R12-01 expect is `divergent=[1-9][0-9]*` (positivity only) | **YES** |
| SKILL.md:294–296 | Round 11's first contact fixed four committed defects | HISTORICAL (round 11) | 4 | round-11.md:42–54: four numbered defects (2× `local://`, 1× kotoba path, 1× bare host file) | [C-r11] → 4 | NO (dated; matches) |
| SKILL.md:303 | round-11 narrative and the four gate defects | HISTORICAL (round 11) | 4 | round-11.md:75 `## Four gate defects, three caught before landing`; items at :80, :86, :90, :95 | [C-r11] → 4 | NO (dated; matches) |
| SKILL.md:312 | port 40961 already has an OpenCode server | CURRENT | 40961 | no lane source (host handler config) | none | UNVERIFIED |
| SKILL.md:314 | readiness loop expired (120 probes, 60–300 s) | CURRENT | 120; 60–300 s | no lane source | none | UNVERIFIED |
| SKILL.md:321 | `1, ~2 s` | CURRENT | ~2 s | no lane source (one-off measurement, op-ref-consumption.md:57) | none | UNVERIFIED |
| SKILL.md:325 | `steps: 4` on the janitor agent | CURRENT | 4 | committed pin drift-symbols.tsv:23 `^steps: 4` on janitor.md:6 | pin (lane file; host-live unverified) | NO vs pin |
| SKILL.md:334 | (client.py, default 3600 s) | CURRENT | 3600 | value unpinned; drift-symbols.tsv:18 pins only the symbol at line 74 | none | UNVERIFIED |
| SKILL.md:337 | read by `_serve`, L194–210 | CURRENT | 194; 210 | 194 pinned drift-symbols.tsv:14 (OP_ACCOUNT 196 at :15); 210 unpinned | pin | NO (194) / UNVERIFIED (210) |
| SKILL.md:341 | (verified tmux 3.7b) | CURRENT | 3.7b | tool version; no lane source | none | UNVERIFIED |
| SKILL.md:351 | `MODEL_ENDPOINT` (L19) | CURRENT | 19 | pinned drift-symbols.tsv:12 → 19 | pin | NO vs pin |
| SKILL.md:355 | until L19 is updated too | CURRENT | 19 | same pin | pin | NO vs pin |
| SKILL.md:359 | `cmd_refs` L234 | CURRENT | 234 | no pin (no drift-symbols row) | none | UNVERIFIED |
| SKILL.md:360 | `cmd_run` L248 | CURRENT | 248 | pinned drift-symbols.tsv:30 → 248 | pin | NO vs pin |
| SKILL.md:354 | round-3 drift fix is one JSON field | HISTORICAL (round 3) | 1 | opencode.json:16 baseURL, pinned drift-symbols.tsv:21 | pin | NO (dated) |

**CURRENT stale claims: 1** (SKILL.md:361–362, "eight"; live 5).
Other CURRENT: 2 lane-checked clean (:266, :278); 5 host lines agree with committed pins (:325, :337 start, :351, :355, :360); 6 host lines unverifiable from the lane tree (:312, :314, :321, :334, :341, :359).
Outside range, not inventoried: SKILL.md:392 `claims 8` (host dead config.json).
Not artifact counts, excluded: :262 `row_linked*2 < entries` and `ceil(n/2)` (gate formula); exit codes throughout; :271 `R12-01..03` (example id); :282–283 stamp column names; :298 allowlist tokens; :330–335 knob names (completeness claim, no number); :390 "none today" (project-config count, host state, not a lane artifact).

## Commands (sandbox `$L`=/fast/scratch/kagi-r25/SelfInvSkill3/lane; `env -i PATH=/usr/bin:/bin HOME=$H`)
- [C-bounds] `grep -cE '^(1[7-9]|2[0-3])\. \*\*' corpus/knowledge/claim-ledger.md` → 7; `sed -n 308,456p … | grep -cE '^[0-9]+\. \*\*'` → 30; heading `## Bounds` at 308, `## Falsifiers` at 457.
- [C-axes] `sed -n 862p corpus/claim-ledger.sh | tr ' ;' '\n\n' | grep -cE '^(depth|coverage|operability|freshness|calibration|adjacency)$'` → 6; `sed -n '/^## Round 24 — post-move/,/^## /p' SCORECARD.md | grep -cE '^\| *(axis names) *\|'` → 6 (pre-move section also 6).
- [R11-09] `bash corpus/claim-ledger.sh --selftest` (cwd $L) → exit 0, `SELFTEST: PASS (151 cases)`; `ok-case  74 cells-six-axis-guard exit=2`.
- [C-eight] `eval "$(grep -E '^DIVERGENT_CONTRACT=' corpus/op-ref-probe.sh)"; echo ${#DIVERGENT_CONTRACT[@]}` → 5 (KAGI12_B KAGI12_D kagi12_lower 1KAGI12X KAGI12_L); `sed -n 31p SKILL.md | grep -o 'divergent=[0-9]*'` → divergent=5; knowledge `sed -n 43,58p … | grep -cE '^\| \`'` → 16, `grep -c '| agree |'` → 5, `grep -c '| agree when'` → 1, non-agree 10.
- [C-r11] `sed -n 42,54p corpus/lessons/round-11.md | grep -cE '^[1-4]\. '` → 4; `grep -n 'Four gate defects'` → 75.
- [host-scope] `find . -path ./.git -prune -o -path ./.jj -prune -o \( -name 'the-janitor*' -o -name client.py -o -name janitor.md \) -print | wc -l` → 0 (handler is host-only; adjacency `# own` rows, R16-04 note).
- [git] lane: `git rev-parse HEAD` → 4587c61a348e4528717404a68912c373f3ef4d03; `git status --short` → the two untracked paths only (status may refresh the index stat cache; disclosed). Sandbox clone + checkout exit 0.
- UNRUN: R12-01 `bash corpus/op-ref-probe.sh` (needs op + handler on host; forbidden for this seat). No other gate mode run; no verify, cells, citations or docs.

## Findings
1. C1 rule gap: round-25.md:32–33 exempts round-dated numbers only in LOG/lessons/SCORECARD. SKILL.md:294–296 and :303 are round-dated but live in SKILL.md, so the literal rule does not exempt them; they pass only because round-11.md agrees.
2. The eight is unbound. R12-01's expect accepts any positive count; the printed `divergent=` is `${#DIVERGENT_CONTRACT[@]}` (op-ref-probe.sh:463–468), a constant rather than a measurement. The 5 appears only in R12-01's note.
3. Three "line shapes" counts coexist: 5 (op-ref-consumption.md:60–63), 10 (§2 non-agree rows, :43–58), 7 (surface-census.md:153, "4 of 7 line shapes listed"). The only derivation of 8 I found is a hand count of SKILL.md:365–378 (export, spaces, lowercase, quoted ref, duplicates, `$`-expansion, quote-strip, `#`-comment; precedence and masking excluded). No lesson or knowledge doc says "eight" for this.
4. SKILL.md:31 (outside range) states `divergent=5` for the same op 2.35.0 fixture, contradicting :361 inside the same file.
5. Freshness: op 2.35.0 is never re-measured. op 2.41.0 was measured 2026-10-19 for the byte arm only (R21-01). The probe is host-only, so it stays UNRUN here.
6. Planner options: correct :361 to the contract's five and tighten R12-01 expect to `divergent=5`; or keep a prose count and add a row whose command yields it. Either removes the unbound number.
7. Line pins: drift-symbols.tsv:12/:14/:23/:30 commit L19, L194, `steps: 4` and L248. They agree with SKILL, but only as line pins; C1's rows:/ledger: model cannot bind a line number to a ledger value.
