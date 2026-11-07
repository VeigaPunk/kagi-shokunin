# R56LabratCeiling — ceiling probe: how hand-written must a scoring capture be?

Seat R56LabratCeiling, 2026-11-07. Lane `/home/vgpnk/Projects/shokunin/kagi-shokunin`, BASE `832ba6a53d6a76706b5c80bce2278683dea33d42`, predeclaration (= lane HEAD during this probe, `git log -1` → `42070de7770e1558adcf6aa7a7bc59309a9654d7`). Observed answering model of this seat session: `zai/glm-5.3-flashx` (workstation context field; not inferred from the prompt).

## Method (no lane mutation)

- Probe trees extracted once with `git archive 42070de… | tar -x` into `/fast/scratch/hyaku/kagi-r56/R56LabratCeiling/{base,p0,p1,p2,p3}` — the tracked state at the predeclaration equals the working tree for every measured file (`git status --porcelain` shows modifications only under `.ufo/waves/round-56/build*` and untracked `w1/` scratch; none in `corpus/`, `plans/`, or the captures).
- Counter run from the lane read-only: `bash plans/round-56-c1.sh --tree <probe-tree>` (frozen instrument; the script writes only its own `c1.$$` scratch).
- Gate run per tree: `python3 -I -B <tree>/corpus/recheck-replay.py --root <tree>`.
- Harness: `R56LabratCeiling.d/probe.sh`, full log `R56LabratCeiling.d/run2.log` (two independent runs, identical output — deterministic).

## P0 — baseline (untouched tree)

```
bash plans/round-56-c1.sh --tree p0   → C1_REPLAY: value=10 present=10 replayed=10 gate=1 guard=1 (bad=none)  rc=0
python3 -I -B p0/corpus/recheck-replay.py --root p0 → rc=0, RECHECK_REPLAY: CLEAN (clocks=10 match=10 …)
  line 9: MATCH corpus/knowledge/secret-scanning-detection-vs-validation.md:4 id=S054 form=grep stated=1 replayed=1
```

Committed S054 body: 38524 bytes, sha256 `7cf6efb50ab892347b1fa3bee77592603b371b066b6b1659fcc2c56a62e6eff7`; its own `grep -c` of the phrase gives 1.

## Probe A (P1) — fully hand-written capture, self-consistent row, garbage metadata, receipt deleted

S054.body replaced with 4 hand-written lines (255 bytes, sha256 `493dd16b4a79143072f96c99c9e984ebfd3f4ca4b6974ea7f19f8826d009dbc4`) containing the phrase `it can also log in to confirm if that secret is live or not` exactly once (`grep -c` → 1, the stated N). Manifest row edited in place:

```
before: S054→…2026-11-07^I200^I38524^I7cf6efb5…
after:  S054→…1999-01-01^I999^I255^I493dd16b…      (fetched and http_status set to garbage on purpose)
```

`fetch-receipt.json` deleted from the tree. Result:

```
bash plans/round-56-c1.sh --tree p1   → C1_REPLAY: value=10 present=10 replayed=10 gate=1 guard=1 (bad=none)  rc=0
gate → rc=0, CLEAN (clocks=10 match=10), MATCH … id=S054 form=grep stated=1 replayed=1
```

**The headline reading stays value=10.** A 255-byte synthetic body with an invented `fetched=1999-01-01`, invented `http_status=999`, and no fetch receipt at all scores identically to the real capture.

## Probe B (P2) — body with the phrase ZERO times, manifest bytes+sha256 forged to match

Body: 66 bytes, sha256 `d0cc5265a8b8d2dc769805de1699997cce9361f3591798addbe797b2f65bb248`, phrase absent; row's `bytes`/`sha256` recomputed to match (the "forgery"). Result:

```
counter → C1_REPLAY: value=0 present=10 replayed=0 gate=0 guard=1 rc=0
  bad=…,r4-replay0:secret-scanning-detection-vs-validation.md:README.md,…(9× r5-gate:…)
gate → rc=1, MISMATCH … id=S054 form=grep stated=1 replayed=0, DRIFT (mismatch=1)
```

**r3 does NOT catch it** (the row is self-consistent, so the digest conjunct passes silently); **r4 catches it**: the counter's own `grep -c -e '<phrase>'` on the body returns 0 ≠ stated 1, and the gate prints MISMATCH. The other nine clocks also drop because the gate's last line is `DRIFT`, so `gate=0` fails r5 tree-wide — the headline collapses to 0, not `FAIL` (guard stays 1: all clocks PRESENT, selftest passes).

## P3 — same zero-phrase body with the ORIGINAL manifest row (no forgery)

```
counter → value=0 … bad=…,r3-digest:secret-scanning-detection-vs-validation.md:README.md,…  rc=0
gate → rc=1, BAD-CAPTURE … id=S054 reason=bytes:.ufo/waves/round-56/capture/S054.body, DRIFT (bad_capture=1)
```

r3 catches only the lazy substitution (byte count/sha256 disagree with the row); recomputing two columns defeats it.

## Exactly which manifest fields an attacker must keep consistent

| Field | Checked? | Constraint that must hold |
|---|---|---|
| `id` | r2 | names exactly one `corpus/SOURCES.md` registry row (outside fences), 11 cells, status cell `mined`, clock URL a whitespace token of the source cell |
| `url` | r2/r5 | byte-equal to the clock's URL; exactly one data row per URL |
| `body_path` | r3 | repo-relative, no `..`, no symlink component, regular file |
| `bytes` | r3 | equal to the body's actual byte count |
| `sha256` | r3 | equal to the body's sha256 |
| `fetched` | **not consulted** | free — P1 used `1999-01-01`, value stayed 10 |
| `http_status` | **not consulted** | free — P1 used `999`, value stayed 10 |
| (body content) | r3 header-bytes + r4 | must not begin `HTTP/<digit>` nor carry a `^set-cookie:` line (any case); must make the **stated filter** yield exactly the stated N (grep / pdftotext\|grep / rendered-text-v1 locate) — this is the only semantic content check that exists |

Fetch receipt: `grep -c fetch-receipt plans/round-56-c1.sh` → 0, same for `corpus/recheck-replay.py` → 0 (the only near-hit is the gate's docstring "fetch receipt beside the body"); empirically P1 deleted `capture/fetch-receipt.json` entirely and value stayed 10. **Neither instrument reads the receipt — confirmed.** `fetched`/`http_status` appear only in the two header-literal constants (`plans/round-56-c1.sh:153`, `corpus/recheck-replay.py:52`); grep shows no other consultation.

## Ceiling, precisely stated

The committed-bytes ceiling costs an attacker: (1) any body whose replay of the one stated filter equals the stated N — for the three grep-form clocks a one-line file containing the phrase once suffices (here 255 bytes); (2) two recomputed manifest columns (`bytes`, `sha256`). `fetched`, `http_status` and the entire fetch-receipt file are unexamined; there is no provenance, TLS, header, size, or live-site cross-check anywhere in the gate or the counter. Minimum forge: `printf` one line + `sha256sum` + two column edits ≈ a minute of work, and C1_REPLAY reads value=10. The only instrument that fires is the filter-count consistency the claim itself declares (r4), and it fires only for counts, never for origin. This is exactly the named ceiling of plans/round-56.md — measured, not assumed; the non-author live re-fetch (separate leg) remains the only real provenance control.

## Bounds observed

Scratch `/fast/scratch/hyaku/kagi-r56/R56LabratCeiling/` deleted before yield (receipt copies retained in `R56LabratCeiling.d/`). No lane, fleet, or sibling writes; no git mutation anywhere; no tools installed (python3/grep/pdftotext already present; pacman untouched); no credential-shaped material read (receipt inspected as key names only).
