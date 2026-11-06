# K48Connector — sibling-overlap scan for round 48 C1/C2

Seat: K48Connector (leaf). Lane: kagi-shokunin, branch master, measured BASE `76da518fcc3029e738648bd6fd4ba5571df01c1c`;
predeclaration `164f0ea5…` + amendment A1 `52991e5d…` (lane HEAD at scan time: `52991e5`).
Scope: 21 `*-shokunin` dirs under `/home/vgpnk/Projects/shokunin`; the 20 non-kagi siblings scanned read-only.
Every count below is from a command in the receipt `K48Connector/scan-receipt.txt` (copied next to this file).

Claims under scan (as frozen by the L1, not restated):

- **C1** = `C1_SOPS_AGE_TRIAL`: the lane executes the SOPS/age access+rotation mechanics its
  `corpus/knowledge/sops-age-key-rotation.md` documents — `corpus/sops-age-trial.sh` runs T1..T5 against real
  sops 3.13.3 / age-keygen 1.3.2, each test flipping to `BROKEN` under its designated falsifier shim; target 5, BASE 0.
- **C2** = `C2_CAPABILITY_READINGS`: the `SCORECARD.md` `## Capabilities` table's stated readings (`cmd` ⇒ `out`)
  versus the same commands' executed output at the measured revision; 10 frozen keys; target 0, BASE 3 (K02/K07/K10).

## 1. Commands and counts

| # | command (lane root `/home/vgpnk/Projects/shokunin`) | count |
|---|---|---|
| 1 | `ls -d ./*-shokunin \| wc -l` | **21** (20 siblings after excluding kagi) |
| 2 | per-lane `grep -rIow 'sops'` over `PROVINCE.md SKILL.md corpus/SOURCES.md corpus/knowledge` | **0** in all 20 |
| 3 | per-lane `grep -rIo 'age-keygen'` over the same four surfaces | **0** in all 20 |
| 4 | per-lane `grep -rIoE 'getsops'` | **0** in all 20 |
| 5 | per-lane `grep -rIoE 'updatekeys\|update_keys'` | **0** in all 20 |
| 6 | per-lane `grep -rIo 'Shamir'` | **1** (kotodama, false positive: a cited author's surname) |
| 7 | per-lane `grep -rIoE 'age1[a-z0-9]'` | **1** (kengaku, false positive: the word `age10` inside `page105`) |
| 8 | whole-lane `grep -rIw --exclude-dir=.git --exclude-dir=.ufo 'sops'` | kotodama **9**, souji **6**; 0 elsewhere |
| 9 | `grep -rIw 'sops\|age-keygen\|getsops' templates scripts .ufo/gates` (fleet root, read-only) | **0** |
| 10 | per-lane `⇒` count inside each `## Capabilities` section | **0** in all 20 siblings; **11 arrows / 6 lines** in kagi `SCORECARD.md:696+` |
| 11 | `grep -rIoE '`<cmd>` ⇒ `<out>`'` at lane root (`SCORECARD/PROVINCE/SKILL`) | **6** non-kagi (all kumitate, all arithmetic derivations, none a `cmd ⇒ out` reading); **29** in kagi `SCORECARD.md` |
| 12 | per-lane `shim` / `falsifier` / `capabilit` / `evidence pointer` over the four surfaces | matrix in §3 |

## 2. Domain hits (SOPS / age / getsops / Shamir / updatekeys) — every non-zero line, classified

| lane | path:line | kind | content (abridged) | kagi C1 relation |
|---|---|---|---|---|
| souji | `tools/souji-preservation-evidence.py:392` and `tools/souji-evidence-cache.py:301` (plus 4 archived copies under `census/round-26`, `census/round-32`) | **execution** (path constant in a runnable tool) | `PROTECTED_PAIRS = (… (".config","sops") …)` — a *protection denylist*: the tool refuses to touch `~/.config/sops` | **Supporting prior art, not overlap.** The fleet already treats `~/.config/sops` as a protected surface; souji forbids reading it — the same boundary kagi's refusal rule states. Nothing to absorb. |
| kotodama | `reports/round-86/evidence/S925.txt:32945,33258,35295,75280,80190,80192,80195`; `reports/round-98/evidence/S998.txt:30976`, `S998.html:21449` | documentation (dictionary/report evidence text) | the English/Scots noun *sops* ("bread soaked in broth") | none — lexical false positive |
| kotodama | `corpus/knowledge/civilizations/levant-canaan-phoenician.md:15` | documentation | co-author *Orit Shamir* | none — surname |
| kengaku | `corpus/knowledge/webarena-task-spec-audit.md:119` | documentation | `full-page105` matched by `age1[a-z0-9]` | none — substring |
| tsukuroi | `.ufo/waves/round-19/l1-capture/siblings/kagi/c2cab35bc92e/PROVINCE.md:61,63` | documentation (an **archived snapshot of kagi's own PROVINCE**) | the SOPS line plus "Sweep: round-21 connector over every `*-shokunin` `PROVINCE.md`/`SKILL.md`/corpus — no sibling claims SOPS, OpenBao…" | precedent only: it is kagi's own text captured by tsukuroi's L1, not a sibling claim |

Domain verdict: **no sibling lane documents, claims, or executes SOPS/age.** No `age`/`age-keygen` invocation exists in any
sibling `plans/` or `corpus/` (probe: `grep -rIl -E 'age --encrypt|age -r |age-keygen' */plans */corpus` → 0 files outside kagi).
C1's *subject* therefore has no competitor; the prior art it can cite is on the *mechanism* only (§3).

## 3. Gate-pattern hits (shim / falsifier / capabilities-evidence drift), execution vs documentation

Per-lane line counts over the four named surfaces (command #12), highest-first:

```
chousa     shim=39 falsifier=12 capabilit=15 evptr=4     kumitate  shim=31 falsifier=1  capabilit=25 evptr=2
kengaku    shim=107 falsifier=60 capabilit=59 evptr=0    kotodama  shim=35 falsifier=3  capabilit=25 evptr=11
kaidoku    shim=70 falsifier=0  capabilit=241 evptr=3    tsukuroi  shim=4  falsifier=43 capabilit=160 evptr=30
tabi       shim=3  falsifier=75 capabilit=95 evptr=2     souji     shim=5  falsifier=1  capabilit=8  evptr=5
revenger   shim=2  falsifier=1  capabilit=83 evptr=0     tameshi   shim=0  falsifier=13 capabilit=27 evptr=0
mori       shim=4  falsifier=13 capabilit=36 evptr=1     kake      shim=2  falsifier=8  capabilit=37 evptr=4
kama       shim=4  falsifier=1  capabilit=56 evptr=1     kasegi    shim=0  falsifier=3  capabilit=21 evptr=3
kotoba     shim=3  falsifier=8  capabilit=48 evptr=0     mado      shim=4  falsifier=0  capabilit=40 evptr=1
lore       shim=0  falsifier=6  capabilit=7  evptr=2     audio / game-dev-2d / game-dev-3d: ≤3 except capabilit
```

The hits that matter, each classified:

| lane | path:line | kind | content (abridged, verified) | relation to kagi C1/C2 |
|---|---|---|---|---|
| chousa | `SKILL.md:102` | **execution** (gate registry row) | round-37 C1 counter: "`2/7` (C1: **five shim cells move the verdict**) and `3/7` (C2 …)" — the shim cells are the discrimination measure | **C1 mechanism prior art to cite.** kagi's "each test flips to BROKEN under its designated falsifier shim" is the same instrument, applied to a binary instead of a gate script. |
| chousa | `corpus/evidence/round39/c1-count.py:183-199` | **execution** | `shimdir = …/r39-shimdir`; writes a `bash` shim (`0o755`) and an `envshim` dir; five cells = `path_bash_shim_echo`, `path_bash_shim_suppress`, `path_env_shim*` | prior art for *how* a falsifier shim is built (a PATH dir ahead of the real tool). Cite, do not absorb: chousa's shims target shell builtins/gates, kagi's target `sops`/`age-keygen`. |
| chousa | `corpus/evidence/round39/claims.md:20,67-80` | documentation (frozen contract) | "the PATH `bash` shim (echo re-add and suppress shapes — the hostile-drift vector)"; "a shim cannot interpose on the capture in either place" | prior art for the *falsifier must be able to interpose* rule; supplies kagi's T-test design its wording-level precedent. |
| chousa | `corpus/knowledge/capture-path-pin-r41.md` | documentation | PATH-pin capture knowledge | optional citation for kagi's `env -i` PATH discipline. |
| kumitate | `corpus/knowledge/executable-scorecard.md:1-20` + `scripts/proxy-check.mjs:245` | **execution** | `PROXY: DRIFT (<KIND term=… declared=… computed=… delta=…>)`; exit 0 match · 1 drift · 2 fail-closed | **C2 mechanism prior art to cite.** Nearest fleet analogue of "stated value vs executed/recomputed value", but its stated side is a pinned *stanza*, not a capability-table `cmd ⇒ out` cell. |
| kumitate | `SCORECARD.md:1963-1990` (`## Capabilities`) | documentation (table shape) | columns `Capability \| What it can now do \| Evidence pointer \| First-working round`; evidence pointers are `node scripts/…` → `VERDICT` strings using `→` (U+2192), never `⇒` pairs | the fleet's own capabilities-table shape; 0 `⇒` pairs in that section (command #10). kagi's C2 tightens the pointer into a checked reading. |
| kumitate | `scripts/readme-map.mjs:21,54-65` | **execution** | `README_MAP: DRIFT … uncovered:<path> / orphan-row:<path> / outside-map:<path>` — a bimap binding stated rows to live files, naming *which* row drifted | C2-adjacent prior art for *naming the offending row* rather than printing a bare count. Cite when hardening C2's `detail` output. |
| kengaku | `plans/round44_c2_verify.py:1-20` (+ `round3x_c1_verify.py`, `round5x_c2_audit.py`) | **execution** | per-round counters that pin every input by digest and run gates as subprocesses, then print `checks=11 defects=0` / `PREDICATE C2 pass` | prior art for C2's *frozen-key + digest-pin + exit-code* discipline; it does **not** read a capabilities table, so no predicate overlap. |
| tsukuroi | `SKILL.md:1652` | documentation | "each row's entry carries commands + falsifier" | prior art for the "command plus its falsifier" row shape kagi's C1 entry paragraph uses. |
| tabi / kengaku / mori | `tabi/SKILL.md:874,976,1140`; `kengaku/corpus/knowledge/attribution-interval-calibration.md:96,166`; `mori` falsifier lines | documentation | "route by falsifier", "Falsifier: the metric claim fails if …" | vocabulary precedent for a falsifier sentence per claim; no executable shim, no overlap with kagi's T1..T5. |

## 4. Adjacent-domain surface (1Password / `op://`) — the only real province contact

Counted with `grep -rIn -wE '1Password|onepassword|op://'` over `PROVINCE.md SKILL.md`:

| lane | path:line | kind | content | verdict |
|---|---|---|---|---|
| kaidoku | `PROVINCE.md:51,162` | **execution** (static analysis) | asar/Electron analysis of the 1Password app bundle (`analyze_javascript_application`) | not vault ops — reads a binary, never a credential. No C1 overlap (C1 is sops/age only). |
| tsukuroi | `SKILL.md:70-71` | **execution** (packaging facts) | `/usr/bin/op` 2755 root:onepassword-cli; `/opt/1Password/1Password-BrowserSupport` | package/ownership surface; kagi's PROVINCE already routes "tsukuroi tracks the 1Password packages". No overlap. |
| tsukuroi | `SKILL.md:884` | execution (journal capture) | `failedhist=8[app-com.onepassword.OnePassword@autostart.service,…]` | unit-failure telemetry, not custody |
| tabi | `SKILL.md:2970` | documentation | 1Password native-messaging bridge "is kagi's custody surface … kagi's" | explicit deferral to kagi — reinforcing, not contested |
| souji | `SKILL.md:68` | documentation | "Credentials, tokens, `op://` refs, `.env` content — kagi's province; souji …" | explicit deferral |
| revenger | `SKILL.md:130` | documentation (hygiene rule) | "no … `op://` references" in outputs | hygiene filter, not custody |
| tameshi | `SKILL.md:533` | documentation (policy) | refuses `op://`-carrying paths | hygiene filter |
| kengaku | `SKILL.md:673` | **execution** (`stage-scan` gate) | "a pre-stage credential-pattern" scan | hygiene filter over its own inputs |

None of these execute SOPS/age or assert a capability-reading contract. Four lanes state in writing that credential
custody is kagi's — the strongest available evidence that kagi's province is uncontested in this round's subjects.

## 5. Fleet contract (read-only, root)

`AXES.md:57-64` defines the capabilities table as `name → what it can now do → evidence pointer (command or path) →
first-working round`, rows entering "only through a round that demonstrates the capability running".
`templates/round-prompt.md:26` requires "the new capability **runs**, its output verifies, and its row enters the
SCORECARD capabilities table in the same round".

Consequence for C2: the fleet contract permits an evidence pointer that is a bare command **or path** and does not
require its output. C2 is therefore a *strengthening* of the fleet contract, not a contradiction of it — and no
sibling lane can be cited as having already met that stronger form. The 6 non-kagi backticked `⇒` pairs are arithmetic
derivations inside kumitate prose (e.g. `` `C1 8/8 × 74/114` ⇒ `floor(6.49…)` ``), not executed readings.

## 6. Verdicts (one per claim)

| claim | verdict | basis |
|---|---|---|
| **C1** — execute SOPS/age access+rotation with per-test falsifier shims | **prior-art** (cite, do not absorb) | subject unclaimed: 0 real SOPS/age hits in 20 siblings' four named surfaces and 0 `age`/`sops` executions fleet-wide; mechanism precedent exists in chousa's PATH-shim cells (`SKILL.md:102`; `round39/c1-count.py:183-199`) and the fleet's "capability runs" contract (`AXES.md:57-64`, `templates/round-prompt.md:26`). No sibling can demonstrate the predicate. |
| **C2** — capabilities-table stated readings vs executed output, 10 frozen keys | **prior-art** (cite, do not absorb) | idiom unique fleet-wide: 0 `⇒` pairs in every sibling `## Capabilities`; 0 non-kagi `cmd ⇒ out` readings. Mechanism precedent: kumitate `PROXY: DRIFT (declared=… computed=… delta=…)` (`scripts/proxy-check.mjs:245`, `corpus/knowledge/executable-scorecard.md:1-20`) and `README_MAP: DRIFT … uncovered:<path>` (`scripts/readme-map.mjs:54-65`). The predicate itself is kagi's alone. |

No claim is **contested**: no sibling asserts a competing capability over SOPS/age or over the capabilities-table readings.
No hit is a reason to change C1/C2 — the frozen predicates, counters, controls and targets are not this seat's to touch.

## 7. Risks and second-order effects (stated, not smoothed)

1. **Citation overreach.** chousa's shim cells measure *verdict movement* of gate scripts; kagi's measure *binary
   substitution* inside an `env -i` trial. Quoting chousa as if it validated a binary shim would be a false
   precedent — cite it for the mechanism (`PATH` interposition, five named cells, per-cell verdict flip), and let
   T1..T5 stand on their own receipts.
2. **Refusal boundary crosses souji's constant.** souji protects `~/.config/sops`; kagi's trial must never read it.
   Consistent today (kagi's trial runs under `env -i` with a scratch-generated throwaway identity), but any future
   variant that resolves `$HOME` inside the trial would collide with souji's protection rule. Flag to the L1, do not fix here.
3. **C2 last-occurrence brittleness (checked, currently absent).** The counter takes the *last* `` `<cmd>` ⇒ `<out>` `` pair
   in the measured revision. At `52991e5` each of the ten frozen stated commands occurs exactly once inside
   `## Capabilities` (19-line section), and the K03/K04 pair does not cross-match — verified by running the counter's own
   regex on the extracted section:
   `bash corpus/laneguard.sh --selftest` → `['LANE_GUARD_SELFTEST: detected=3 mutants=3 clean=ok']`;
   `--no-mutate` → `['detected=0']`. The hazard is real for a *future* round: adding a capability row that restates any
   K0x command silently re-points that key's stated reading. A reader of C2 should know the rule is positional.
4. **`⇒` vs `→` divergence.** kumitate's table uses `→`; kagi's uses `⇒`. A cross-lane reviewer grepping for either can
   conclude the wrong thing. Tooling that ever generalizes C2 across lanes must accept both.
5. **Scratch/HOME hygiene.** Every command above ran with the real `HOME` and no `env HOME=` override; no fixture repo,
   no private key, no `~/.config/sops`, `~/.ssh` or vault contact was created or read (probe scope was lane text only).

## 8. Verification actually run

- Receipt: `K48Connector/scan-receipt.txt` — 12 recorded commands, each with its `### EXIT:` line (all `0` except two
  `grep`-no-match exits `1`, which are the negative results themselves).
- Section extraction for §7.3: `awk '/^## /{insec=($0=="## Capabilities"); next} insec' SCORECARD.md` → 19 lines at
  `52991e5`; the ten stated commands then probed one by one (`occurrences=1` for each) and their readings resolved
  through the counter's own regex.
- Not run, by assignment: the lane's claim-ledger verify, self-counts, and the C1/C2 counters themselves (host-heavy;
  this item names no counter).
- Limits: the scan is lexical over the four named surfaces plus a whole-lane `sops`/`age-keygen` sweep excluding
  `.git`/`.ufo`; a sibling that spelled the tools differently (e.g. `getsops/sops`, `age` alone, `SOPS_AGE_KEY`) would
  be caught only by the `getsops` and `age1` patterns — both returned 0/1-false-positive. Archived `.ufo/waves`
  captures were excluded from counts deliberately (§2 row for tsukuroi is the one exception, reported because it is a
  snapshot of kagi's own text).

SEAT-STATUS: complete
