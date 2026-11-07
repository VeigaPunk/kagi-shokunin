# R56Scribe — round 56 lesson draft (freshness, C1 stated-clock offline replay)

Seat: `R56Scribe` (scribe, leaf — no dispatch). Lane `/home/vgpnk/Projects/shokunin/kagi-shokunin`, branch `master`, BASE `832ba6a53d6a76706b5c80bce2278683dea33d42`. Lane HEAD at start `42070de7770e1558adcf6aa7a7bc59309a9654d7`; lane HEAD at report `5d9a1571911ec38a456a40b443e19640abb9a88b` (epoch-B predeclaration, landed while this seat measured). No production file was edited; nothing committed, pushed, or deployed. Report written 2026-11-07; measurements 10:24Z–10:52Z.

Observed answering model: `amr/deepseek-v4.1-flash` — the harness's workstation block; no model variable is exposed in the seat process (`env | grep -i model` empty), so this is the harness-reported string, not an inference from the prompt. (The L1's 429 wake error names its own model; that is not this seat's.)

## Behavior — what this seat produced

1. `R56Scribe.d/lesson.md` — draft of `corpus/lessons/round-56.md` (latest write 2026-11-07T10:52Z): the seven-source `source:` line; `## Claims` (C1 predicate verbatim + r1–r5 + epoch-A/B/C readings + the capability row + run/add/replace/repair instructions); `## Gate` (seven reopened bodies with access date 2026-11-07, status, bytes, SHA256 and a located ≤25-word quote with byte offset/line and E49-1 word count; the three reused captures; the reject sample; the discernment sample; the row/used-by audit); `## Mistakes` M56-1…M56-8 plus the M55-2 closure paragraph; the round-55 closure defects D1–D5; `## Routed`; `## Frontier`; `## Assimilation`; `## considerthese`.
2. This report and the receipts under `R56Scribe.d/`.
3. No scorecard draft (a parallel `w1/R56Scribe.d/scorecard.md` exists from another seat; this seat's assignment was the lesson).

**Superseded copy in the commit:** `5d9a157` committed an earlier epoch-A version of `build/R56Scribe.d/lesson.md` (36 732 B). The current working-tree file is the epoch-A→B→C rewrite and is the one to read; the committed copy is not the draft of record.

## Claim draft — one claim, freshness, proposed not admitted

- **C1 freshness (capability): stated-clock offline replay, 0 → 10.** Frozen predicate (verbatim): `C1_REPLAY: value = REPLAYED when GUARD = 1, else FAIL; target 10 (BASE 0).`
- Population: 10 clocks in 8 knowledge entries, forms grep 8 / pdf 1 / locate 1; the manifest binds 10 URLs (S101/S113/S114 reused; S054/S055/S057/S067/S070/S074/S078 new 2026-11-07 bodies).
- Measured:
  - BASE (`832ba6a`) `bash plans/round-56-c1.sh 832ba6a…` ⇒ `C1_REPLAY: value=0 present=10 replayed=0 gate=0 guard=1`, rc 0 (controls K1-BASE; `build/R56ExecHarm.d/c1-base.out`).
  - Epoch-B reference (`5d9a157`) ⇒ `value=10 present=10 replayed=10 gate=1 guard=1 (bad=none)`, rc 0 (K1-REF; `R56ExecHarm.d/c1-cand.out`; reproduced by R56ReviewCounter, R56ReviewGate, R56Sentinel, R56Scribe).
  - Epoch-C working-tree reference ⇒ `value=10 … guard=1`, rc 0 (`R56Scribe.d/epochC-probes.txt`).
  - Gate `python3 -I -B corpus/recheck-replay.py` ⇒ 10 MATCH + `RECHECK_REPLAY: CLEAN (clocks=10 match=10 mismatch=0 no_capture=0 bad_capture=0 unsupported=0 tool=0)`, rc 0; `--selftest` ⇒ `RECHECK_REPLAY_SELFTEST: PASS (13 cases)`, rc 0 (`R56Scribe.d/probes.txt`).
  - Controls: epoch B `CONTROLS: match=16 mismatch=0` (canonical `controls/controls-prefreeze-epochB.txt`); epoch-C working tree 20 controls, R56Scribe run `CONTROLS: match=20 mismatch=0` (`R56Scribe.d/controls-epochC-r56scribe.txt`); canonical epoch-C receipt pending.
  - Live leg: 0/10 live mismatches on 2026-11-07 (R56ExecLive; evidence verified, not re-run by this seat).
- **Admission is not taken by this draft.** At the epoch-C snapshot the blockers are: (i) the epoch-C instruments are **uncommitted** (re-freeze + candidate reading required); (ii) the S113 anchor-cell edit in `corpus/SOURCES.md` violates the registry's append-only rule if it lands; (iii) the canonical epoch-C controls receipt and the mutation seats' reports were pending. The epoch-B header-shape false green is **fixed** in the epoch-C working tree (see F2).

## Instrument epochs (exact bytes)

| epoch | revision | plan | counter | gate | controls | controls reading |
|---|---|---|---|---|---|---|
| A | `42070de` | `d1bf8d26…b8a07` | `096251c9…9bde9a` | `b7782f35…d799e8` | original 12-control file | 12 MATCH |
| B | `5d9a157` | `033f2104…e1679` | `6b132ea1…b269c` (`GATE_SHA256_PIN=2e9dfde3…d4df51`) | `2e9dfde3…d4df51` | `63cf8061…ab8f` | 16 MATCH |
| C | `5d9a157` + working tree | `033f2104…e1679` (unchanged) | `d4dc9ddc…a77c3` (`GATE_SHA256_PIN=d4392ffe…80b274`) | `d4392ffe…80b274` | `57a18b4a…37f337` | 20 MATCH (R56Scribe run; canonical pending) |

Manifest `corpus/recheck-captures.tsv` `df46be5c92c7b4d5a8b7ad790371b5c3240c92f46460b8cfb69e9b75b7ecc762` (unchanged A→C). Committed at `5d9a157`: `corpus/SOURCES.md` `fa69564f610e5192093b05ae17c9ee385aa607586cc219d0e33460985ab12936`; cdp entry `bf6052bcc70bc682c89a07c673ad5ca247cbff65c9c8143f442004b9324c1476`. Working tree at epoch C: `corpus/SOURCES.md` `299903cfb8d38760440d16ae3a5119154f14ec128619710101ca8c59af3a4edb` (S113 anchor edit, uncommitted); cdp entry `d16ae5a5c7de53a8a6b0dd2311223ca9b6a77ce9efb38e84e8323807544537a4` (source-line provenance edit, uncommitted).

Snapshot block: `R56Scribe.d/snapshotC/measured-at.txt` = `2026-11-07T10:43:54Z`; epoch-C measurements at 10:51–10:52Z.

## Gates / readings (commands, rc, outputs)

| check | command | rc | output |
|---|---|---|---|
| gate, lane root | `python3 -I -B corpus/recheck-replay.py` | 0 | 10 MATCH; `RECHECK_REPLAY: CLEAN (clocks=10 match=10 mismatch=0 no_capture=0 bad_capture=0 unsupported=0 tool=0)` |
| gate selftest | `python3 -I -B corpus/recheck-replay.py --selftest` | 0 | `RECHECK_REPLAY_SELFTEST: PASS (13 cases)` |
| counter, BASE | `bash plans/round-56-c1.sh 832ba6a53d6a76706b5c80bce2278683dea33d42` | 0 | `value=0 present=10 replayed=0 gate=0 guard=1` |
| counter, epoch-B reference | `bash plans/round-56-c1.sh --tree <5d9a157 tree>` | 0 | `value=10 present=10 replayed=10 gate=1 guard=1 (bad=none)` |
| counter, epoch-C reference | same, current working-tree gate/SOURCES/cdp | 0 | `value=10 present=10 replayed=10 gate=1 guard=1 (bad=none)` |
| epoch-B controls | `bash plans/round-56-controls.sh .` | 0 | `CONTROLS: match=16 mismatch=0` |
| epoch-C controls | same, current 20-control script | 0 | `CONTROLS: match=20 mismatch=0` (R56Scribe run) |
| epoch-B printer | tree with the 12-line printer at the gate path | 0 | `value=10 present=10 replayed=10 gate=1 guard=1` (epoch-A counter `096251c9…`; same printer under epoch B `value=0`) |
| epoch-B header shape | S054 body prefixed with six `curl -v` lines + manifest fixed | 0 | **`value=10`** (epoch B — the defect) |
| epoch-C header shape | same tree, current gate/counter | 0 | **`value=0 … r3-headers`**, gate `RECHECK_REPLAY: DRIFT (clocks=10 match=9 … bad_capture=1)` rc 1 |
| epoch-A C32 | restate-N + second matching line + fixed row | 0 | `value=FAIL present=9 replayed=9 gate=1 guard=0` (expected refusal) |
| default-UA probe | `curl -s -o /dev/null -w '%{http_code}' <url>` (no headers stored) | 0 | S113 403/5448, S114 403/5448, S101 403/5448 |
| R4 reject check | `curl -fsSL openid-connect-core-1_0.txt`; `sha256sum`; `grep -c` | 0 | 200; sha `aa28dd92…bf25e`; 306342 B; `grep -c 'It MUST contain the OAuth 2.0'` = 0 |
| R6 reject check | `curl -s -o /dev/null -w '%{http_code} %{size_download}' …/trufflehog/v3/README.md` | 0 | 404, 14 B |

Receipts: `R56Scribe.d/probes.txt` (gate, selftest, hashes, epoch-B printer, default-UA, header scan), `R56Scribe.d/epochA-receipts.txt` (printer 10, C32 FAIL), `R56Scribe.d/epochB-probes.txt` (epoch-B header shape 10), `R56Scribe.d/epochC-probes.txt` (epoch-C reference 10, header shape 0/r3-headers, gate DRIFT rc 1), `R56Scribe.d/controls-epochB-r56scribe.txt` (16/16, F2 traceback), `R56Scribe.d/controls-epochC-r56scribe.txt` (20/20), `R56Scribe.d/snapshotC/` (hash block), `R56Scribe.d/epochA/` (epoch-A counter copy).

## Row audit — `opened` / `status` / `recheck` / `used-by`

- **No registry row was added or removed** at `42070de` or `5d9a157`; the epoch-A/B commits did not touch `corpus/SOURCES.md` (`git show 5d9a157:corpus/SOURCES.md` = `fa69564f…`), and the census start/end count is 114 rows.
- **`opened` must not change.** `CORPUS.md` §SOURCES.md: `opened` is the date the row's author opened the source; rule 2 is append-only and permits only `status`, `recheck` and `used-by` in place. The seven reopened rows keep 2026-11-03 (S054/S055/S057/S067/S070) and 2026-11-04 (S074/S078); S101 2026-11-05; S113/S114 2026-11-07. A landing that rewrites `opened` is a contract defect.
- **`status` stays `mined`** for all ten (each is cited by a knowledge entry).
- **`recheck` cadence unchanged:** S054/S055/S057/S070/S113/S114 180d; S067 730d; S074 90d; S078 365d; S101 90d.
- **`used-by` is the only permitted in-place change.** The round-56 lesson's `source:` line names the seven reopened rows, so each row's used-by should gain `corpus/lessons/round-56.md`, logged old → new (current cells are listed in the lesson §Gate). If the landing does not add the lesson to a row, no change is logged for it.
- **S113 working-tree edit (`299903cf…`, uncommitted) extends the anchor cell's default-UA parenthetical with the receipt sentence** — not a permitted in-place field. See F1. The S113 row's used-by already lists `corpus/lessons/round-55.md`; adding `round-56.md` is permitted only if the lesson's `source:` names S113 (this draft does not; S113 is recorded as a reused capture).
- **cdp entry working-tree edit (`d16ae5a5…`, uncommitted)** changes the `source:` provenance line and leaves the `recheck:` line unchanged; the gate still MATCHes S070. This is an entry edit, not a registry row.
- **`source-fetches.tsv` unchanged by design:** S057, S070 and S074's 2026-11-03/04 rows carry digests that differ from the round-56 captures (volatile representation class); the round-56 manifest is the replay binding, not a rewrite of history.

## Findings (freeze-relevant, exact evidence)

### F1 — CONTRACT — the working-tree S113 anchor edit is not an append-only change
`git diff 5d9a157 -- corpus/SOURCES.md` shows one line changed: S113's anchor cell's default-UA parenthetical is extended with `the default user agent receives HTTP 403 — probed on this URL 2026-11-07, receipt .ufo/waves/round-56/capture/rejections/S113-default-ua.body, HTTP 403, 5448 B, sha256 ce3cb7f2…`. Working-tree sha `299903cfb8d38760440d16ae3a5119154f14ec128619710101ca8c59af3a4edb` vs commit `fa69564f610e5192093b05ae17c9ee385aa607586cc219d0e33460985ab12936`. `CORPUS.md` §SOURCES.md rule 2: "Only `status`, `recheck` and `used-by` change in place … A correction is a new row whose `teaches` opens `supersedes S0NN —`." The census does not check this. Recommendation: revert the anchor edit; record the receipt in the lesson and/or a new superseding row; only `status`/`recheck`/`used-by` may change in place. The underlying claim is **true** (default UA 403 on the S113 URL, measured twice on 2026-11-07; 5448 B Cloudflare interstitial), so no narrowing of the assertion is needed — only the edit shape.

### F2 — FIXED IN THE EPOCH-C WORKING TREE (pending freeze) — r3 header refusal covered only column-0 lines in epoch B
Epoch-B evidence: `plans/round-56-c1.sh:262` `startswith(b"HTTP/")` and gate `:174` `re.match(rb"HTTP/\d", ...)`; a `curl -v`-shaped S054 body (`< HTTP/1.1 200 OK`, `< set-cookie: session=demo-not-a-real-value`, manifest fixed to 38698 B/true sha) read `C1_REPLAY: value=10 present=10 replayed=10 gate=1 guard=1` rc 0 (`R56Scribe.d/epochB-probes.txt`; R56ReviewGate F1, R56Sentinel F1 found the class). Epoch-C fix: `re.search(rb"(?m)^(?:HTTP/\d|< HTTP/\d|< set-cookie\s*:|set-cookie\s*:)", data)` in both instruments; the same tree now reads `value=0 … r3-headers` and the gate `RECHECK_REPLAY: DRIFT (clocks=10 match=9 mismatch=0 no_capture=0 bad_capture=1 unsupported=0 tool=0)` rc 1 (`epochC-probes.txt`); control `K1-F7b-trace-headers` added and reads 0/0 MATCH; the gate's selftest gained a non-zero-offset trace case. Remaining: a leading-whitespace `Set-Cookie:` (not `< `) is still not refused, and there is no commit-time hook. Freeze epoch C and keep K1-F7b; name the whitespace-led shape as a ceiling or widen the regex.

### F3 — MEDIUM — the frozen controls receipt still carries an AssertionError traceback
Canonical `controls/controls-prefreeze-epochB.txt` lines 20–23: `assert t!=s, "inert edit …"` → `AssertionError: inert edit corpus/knowledge/betterleaks-detection-vs-validation.md`; `plans/round-56-controls.sh:49-50` still contains the inert literal and the same-old/same-new no-op (the real restatement is the regex at 51–54). The battery reads 16/16 (and the epoch-C 20-control battery also carries the traceback in R56Scribe's run); the verdict is unaffected, the receipt's provenance is noisy. R56Sentinel F2 and this seat agree. The receipt also carries `tar: … Cannot stat: .ufo/waves/round-56/build-{dispatch.json,spec.json,ready,swarm-registry.json}` because those tracked epoch-A files were deleted in the working tree after the commit — evidence noise, not a control failure.

### F4 — MEDIUM — the seat-proposed 39-control battery is not usable as evidence and its one MISMATCH does not reproduce
`build/R56ExecControls.d/controls.sh` at 10:35Z aborted with a bash parse error at line 168 (`bash: … syntax error near unexpected token '('`, rc 2) when run `--only '^C32'`; later `bash -n` read rc 0 (the file was being edited). Its receipt line `CONTROL C32-FC-restated-with-fresh-capture … MISMATCH` reports got `value=10`; this seat applied the same mutation to an epoch-A archive (restate betterleaks `-> 1` to `-> 2`, append a second matching line to S055.body, rewrite the manifest row) and the epoch-A counter read `C1_REPLAY: value=FAIL present=9 replayed=9 gate=1 guard=0` rc 0 — the intended refusal (`R56Scribe.d/epochA-receipts.txt`). The MISMATCH is a harness artifact, not a counter false-green. Do not cite that battery; the epoch-B/C batteries are the frozen/working instruments.

### F5 — MEDIUM — transfer-size vs decoded-byte labels
R56ScoutSources' rejection R4 records `70623 B` for `openid-connect-core-1_0.txt`; the stored body is 306342 B at sha `aa28dd92…` (same digest as the seat's). `70623` is curl's compressed `%{size_download}`. Same class in `R56ExecLive.d/S055.live.txt` (`size_download=5483` vs 13252 decoded) and R56Sentinel F4. Record `wc -c` of the stored body wherever a byte count is compared to a manifest/capture row.

### F6 — INFO — S074 raw-body provenance is not byte-reproducible
Five independent 2026-11-07 fetches gave five raw digests at the identical 45351 B (committed `df32e64b…`, `3a4c80b3…`, `a2c937f4…`, `2689fd4c…`, `d53b29ce…`, `83f550d9…`; R56ScoutSources), and R56Sentinel's `e16254f6…` differed in 583/45351 bytes inside Cloudflare email-obfuscation ciphertext/tokens. The declared normalizer is stable: `normalized_sha256=955dd8665388946280b67fdcbd9e9c7cfa3d5343b54f223daf5cba40ebeb7fab`, 5636 bytes, on the capture and all five live fetches; the clock phrase is on unchanged line 435. The lesson's S074 Gate entry states this bound; the plan's raw-sha provenance ceiling fails only on this URL. The other six new URLs and the three ISO captures re-fetched byte-identically.

### F7 — INFO — mid-round re-freeze and kill-rule coupling
The lane HEAD moved `42070de` → `5d9a157`, then the working tree gained epoch-C instrument edits and the two production-file edits, while this seat measured (epoch A → B → C). The lesson pins each epoch and uses epoch C for the current draft. The kill rule's pathspec is `plans/round-56.md plans/round-56-c1.sh plans/round-56-controls.sh`; `corpus/recheck-replay.py` is not in it — the counter's `GATE_SHA256_PIN` couples the gate (a candidate gate edit reads `value=0`, fail-closed), but the kill-rule diff alone would not show it. State the coupling or add the gate to the pathspec in the next predeclaration (KagiR56a3's message).

### F8 — INFO — word-count discrepancies in peer reports
Using the lesson's counting rule (`printf '%s' "<quote>" | wc -w`): S054 20, S055 9, S057 7, S067 16, S070 17, S074 10, S078 14. R56ExecLive's table says S055 8, S070 18, S074 7 for the same/near-same quotes; the lesson uses the rule's counts. This is a counting discrepancy, not an evidence dispute.

### F9 — INFO — parallel scribe draft
`w1/R56Scribe.d/lesson.md` and `w1/R56Scribe.d/scorecard.md` exist from another scribe seat (mtime 07:45; it cites intermediate epoch-B counter `1e57445c…`/gate `637c8184…`). This seat's draft is independent at `build/R56Scribe.d/lesson.md` and pins epochs A/B/C. The L1 should reconcile the two, not merge blindly; the `w1` draft's S113-cell claim reflects the same working-tree edit F1 flags.

### F10 — INFO — deleted tracked build files in the working tree
`git status` shows `D .ufo/waves/round-56/build-dispatch.json`, `build-spec.json`, `build.ready`, `build/swarm-registry.json` (committed at `42070de`, deleted after). This is workspace churn, not this seat's write; it produces the `tar: Cannot stat` lines in the controls receipts. No action by this seat (host guard: observed, not deleted).

## Cross-seat evidence used (verified, not re-run)

- R56ExecLive: 10/10 live and offline, 9/10 byte-identical re-fetches, S074 volatile (`.ufo/waves/round-56/build/R56ExecLive.md`).
- R56ScoutSources: seven URL reopens, eleven rejections, S113 default-UA probe, S074 five-digest note (`.ufo/waves/round-56/build/R56ScoutSources.md`, `.d/candidate-rejections.tsv`).
- R56Sentinel: capture hygiene (0 cookie/header lines), QM72 prefix gap, S074 FET, no commit hook (`.ufo/waves/round-56/build/R56Sentinel.md`).
- R56ReviewCounter: epoch-A printer false green, K1-F5 vacuity, `-> 1x`, selftest case count, rc semantics, F1–F11 (`.ufo/waves/round-56/build/R56ReviewCounter.md`).
- R56ReviewGate: r3 header gap, CLEAN-prefix/rc gap, population bound, manifest status/fetched, locate rc, registry weakness (`.ufo/waves/round-56/build/R56ReviewGate.md`).
- R56ExecHarm: BASE/candidate readings, census, quote-locate, declared claims, gate/selftest (`.ufo/waves/round-56/build/R56ExecHarm.d/`).
- KagiR56a3: epoch-B predeclaration `5d9a157` and kill-rule coupling note (IRC).

## Out of scope / not done

- No candidate reading; no admission verdict; no SCORECARD row committed (other seats' drafts exist).
- No live re-fetch by this seat except the two rejection checks (R4/R6) and the default-UA status probes; the ten-clock live truth is R56ExecLive's receipt.
- No mutation-testing runs; R56MutGate/R56MutCounter reports were pending/partial at draft time.
- No production edits, no commits/pushes, no tool installs, no git/jj mutation (only `git archive/show/rev-parse/diff`, read-only).
- Scratch `/fast/scratch/hyaku/kagi-r56/R56Scribe/` deleted before yield (an earlier copy was deleted externally mid-run; the receipts in `.d/` and this report carry the outputs; the epoch-A printer/C32 were rebuilt once to restore the receipt).
- No secrets/cookies/headers captured or printed; the default-UA probes saved status only; the capture bodies' cookie/header counts are 0.

## Artifacts (relative to /home/vgpnk/Projects/shokunin/kagi-shokunin)

- `.ufo/waves/round-56/build/R56Scribe.md` — this report.
- `.ufo/waves/round-56/build/R56Scribe.d/lesson.md` — lesson draft.
- `.ufo/waves/round-56/build/R56Scribe.d/probes.txt`, `epochA-receipts.txt`, `epochB-probes.txt`, `epochC-probes.txt`, `controls-epochB-r56scribe.txt`, `controls-epochC-r56scribe.txt`.
- `.ufo/waves/round-56/build/R56Scribe.d/snapshotC/` — `measured-at.txt`, `hashes.txt`, copies of the six measured files.
- `.ufo/waves/round-56/build/R56Scribe.d/epochA/` — the epoch-A counter copy used for the printer/C32 receipts.

-- Report trailer: R56Scribe, 2026-11-07, files changed: none in production (this report + `.d/` receipts only); candidate reading: none; open blocker: F1 (S113 anchor edit shape) and the uncommitted epoch-C instruments (re-freeze); epoch-B header defect F2 fixed in the epoch-C working tree; model: `amr/deepseek-v4.1-flash` (harness context).
