# R56ReviewCounter-2 — frozen counter audit (round 56, C1 freshness)

Epoch-A record: `plans/round-56-c1.sh` at `42070de` (SHA256 `096251c9…`, 228
lines). Epoch-B re-audit: the same path at L1's re-predeclaration `5d9a157`
(SHA256 `6b132ea1…`) in §11. Both anchor sets are stated explicitly.

Audit target: the FROZEN counter `plans/round-56-c1.sh` at the predeclaration
revision, and its frozen companions (`corpus/recheck-replay.py`,
`corpus/recheck-captures.tsv`). All readings were made from a clone of the lane
at `42070de` so the counter bytes are the pinned ones, not the working tree
(epoch-B edits were in flight during the review; see §9).

- Lane: `/home/vgpnk/Projects/shokunin/kagi-shokunin`; HEAD at the epoch-A audit
  start was `42070de7770e1558adcf6aa7a7bc59309a9654d7`; HEAD is now
  `5d9a157…` (epoch-B) with further uncommitted worktree edits after it (§11.3)
- Seat: `R56ReviewCounter-2`; report path `.ufo/waves/round-56/w1/R56ReviewCounter.md`
- Observed answering model: the harness exposed no model identifier in-session;
  the session's project context names `amr/deepseek-v4.1-flash`. That is context,
  not an observation, and is recorded as such.

Epoch note: mid-review L1 (KagiR56a3) re-predeclared epoch-B at
`5d9a1571911ec38a456a40b443e19640abb9a88b`, then epoch-C at
`711e6393e68658f396918c07de253e5a5c74d1b4`, epoch-D at
`d36231871c864c930d3e7e33f9c5345b30ab4f98`, then epoch-E at
`dd31b7867723f89fc8f83e88cc7d98e17de26cf2`. §§1-10 are the epoch-A record at
`42070de`; §§11-14 re-audit B, C, D and E against their own hashes. Each anchor
set is stated explicitly; no epoch's numbers are reused for another.

## 0. Anchors (verified with `git show 42070de:<path> | sha256sum`)

| Artifact | SHA256 | Size |
|---|---|---|
| `plans/round-56-c1.sh` | `096251c9b7a7405dbae320eb4dbb3ef0a092cf5e530d2274de0b2e29509bde9a` | 228 lines |
| `corpus/recheck-replay.py` | `b7782f35c0c8bbaedac5f8f06eaadbc3ce4b8997be25e10f4224724013d799e8` | 333 lines |
| `corpus/recheck-captures.tsv` | `df46be5c92c7b4d5a8b7ad790371b5c3240c92f46460b8cfb69e9b75b7ecc762` | 10 data rows |
| `plans/round-56.md` | `d1bf8d2610ed50d46acda83e38c055e629d5e76d0b860d14665f2d223e0b8a07` | plan |
| `plans/round-56-controls.sh` | `633326a563c6d38e7933d0e88d3b395404f688dbef9ff8e1de7fffdbed48b094` | controls |
| `.ufo/waves/round-56/controls/controls-prefreeze.txt` | `3cc3e977eef7832f048a319bfd449cd0b6ecc575160b4905720285edabd65f42` | 12 MATCH |

Frozen predicate (`plans/round-56.md:15`), verbatim excerpt:

> `C1_REPLAY: value = REPLAYED when GUARD = 1, else FAIL; target 10 (BASE 0).`
> REPLAYED counts the 10 POP clocks for which (r1) … (r2) the manifest has
> exactly one data row for the URL whose id names exactly one 11-cell `mined`
> registry row containing the URL, (r3) the body is a confined regular file
> whose bytes and sha256 equal the row and which carries no HTTP status line or
> `set-cookie:` line, (r4) the counter's own replay of the stated filter equals
> the stated N, and (r5) the measured tree's own `recheck-replay.py` prints the
> MATCH line for that clock and ends `RECHECK_REPLAY: CLEAN`. GUARD = 1 iff all
> 10 clocks are PRESENT and the measured tree's gate `--selftest` exits 0 with
> last line `RECHECK_REPLAY_SELFTEST: PASS`.

Method: one clone at `42070de` (`git clone --shared`, root asserted); attack
trees built with `git archive 42070de`; every reading
`HYAKU_SCRATCH=<scratch> bash <clone>/plans/round-56-c1.sh (--tree <tree>|<rev>)`
with the counter's own rc captured. Raw commands and fixture definitions are in
`.ufo/waves/round-56/w1/R56ReviewCounter.d/readings.txt`.

Baseline readings reproduce the frozen record: `42070de` → `value=10 present=10
replayed=10 gate=1 guard=1`, rc 0; BASE `832ba6a` → `value=0 present=10
replayed=0 gate=0 guard=1`, rc 0 (`bad=r2-manifest` ×10). Independent
enumeration of the BASE knowledge population gives exactly 10 clocks in 8
entries, 8 grep / 1 pdf / 1 locate, matching POP (`:88-100`) clause for clause.

## 1. Predicate → code equivalence

| Predicate clause | Frozen code location | Verdict |
|---|---|---|
| `value = REPLAYED when GUARD=1, else FAIL`; target 10, BASE 0 | `:223` guard, `:226` val, `:227` print | equivalent; BASE 0 / 42070de 10 reproduced |
| POP = every backticked `curl … -> N` clock on a column-1 `recheck:` line at BASE; 10 clocks | literal POP table `:88-100` (frozen list, not computed) | equivalent at BASE (independent enumeration = 10/8 entries/3 forms); a later added clock is invisible to POP (see F7) |
| r1: BASE command + BASE N on its single column-1 `recheck:` line | `present()` `:116-124`, `read()` `:104-114`: regular non-symlink, exactly one `recheck:` line, exact backticked command, `->` + optional `count=` + N, `(?!\d)` | equivalent to r1; boundary errors: a second `recheck:` line deletes the clock (F6b); `-> 1x` is accepted as `-> 1` (F5) |
| r2: exactly one manifest row per URL; id names exactly one 11-cell `mined` registry row whose source cell contains the URL token | `manifest()` `:141-158`; `registry()` `:126-139`; check `:195-201` (`rr[0][7] == "mined"`, `c[3] in rr[0][1].split()`) | equivalent. `corpus/SOURCES.md:5` header is `id\|source\|kind\|tier\|scope\|anchor\|teaches\|status\|opened\|recheck\|used-by`, so index 7 is `status`; all 10 rows are 11-cell and plain-token URLs |
| r3: body_path repo-relative, no `..`, no symlink component, regular file, bytes+sha256 equal the row, no `HTTP/` start, no `set-cookie:` line | `:202-215` | equivalent to the letter; **body_path namespace/identity is unconstrained** (F3) |
| r4: counter replays the stated filter (grep; pdftotext\|grep; BASE normaliser locate) and gets N | `replay()` `:160-173`, call `:216`; BASE normaliser extracted at `:65` | equivalent; all 10 `replayed=N` at 42070de, forms exactly as stated |
| r5: measured tree's `recheck-replay.py` prints the MATCH line for the clock and ends `RECHECK_REPLAY: CLEAN` | shell `:69-76` (gate run `:71`, subprocess rc discarded), `gate_clean :183`, regex/accept `:219-220` | equivalent to the sentence as written — which is **string-only**. No gate digest, no gate rc, no regular-file requirement (F1, F2, F4) |
| GUARD = 1 iff all 10 PRESENT and the gate `--selftest` exits 0 with last line `RECHECK_REPLAY_SELFTEST: PASS` | `:68` `SELF_OK=1`; `:72` `SELF_OK=0` only when the gate exists; `:73-75` exit 0 + prefix `PASS*`; `:223` | code == counter header `:32-34`; the plan sentence differs (no “when the tree carries the gate”, no “starting”): a gate-absent tree is `guard=1` (F8); selftest case count/suffix unchecked |
| Fail closed: SETUP (exit 2) on bad revision/BASE/scratch/tools; missing file → conjunct 0; empty producer → not CLEAN | `setup()` and preflight `:45-56`; revision/population `:57-66`; `gate_lines`/`gate_clean` `:178-183` | equivalent; SETUP prints `C1_REPLAY: SETUP …` and exits 2, so it cannot be read as a pass; an empty gate output is `gate=0`, `value=0` |
| Input: a revision or `--tree DIR` | `:57-62` | after T is populated the two paths are identical; `--tree` copies any directory with `cp -a` (untracked files and `.git` included), revision mode uses `git archive`. The divergence is population-only (F9) |

## 2. Findings — (a) landings that score 10 without the gate being real

### F1 HIGH — A printer gate scores 10; r5 is a text obligation
Repro tree: `git archive 42070de` + `corpus/recheck-replay.py` replaced by a
12-line Python file (sha256 `4821ebda4351363b0be6f7a88116149151973a849334b0235d68abc8238b2b4f`)
that prints the ten exact `MATCH <entry>:<L> id=… form=… stated=N replayed=N`
lines and the CLEAN summary; no capture is opened, no filter is run.

```
command: HYAKU_SCRATCH=<s> bash <clone>/plans/round-56-c1.sh --tree <tree>/printer
observed: C1_REPLAY: value=10 present=10 replayed=10 gate=1 guard=1 (bad=none)   rc=0
```

The MATCH line grammar and the ids are public (manifest + gate output), so the
printer is trivial to construct. The value stays tied to real capture bytes only
because **the counter's own r4** replays them; r5 as frozen contributes nothing
but an assertion that the gate printed certain strings. The frozen counter has
no gate digest pin and no gate rc check (`grep -c 'GATE_SHA\|GATE_RC\|gate-digest' plans/round-56-c1.sh` = 0;
`:69-76`).

The pre-freeze control that claims to cover this does not: `plans/round-56-controls.sh:67`
writes a **bash** script to `corpus/recheck-replay.py`; the counter runs it with
`python3`, so both `--root` and `--selftest` raise SyntaxError. The receipt line
`CONTROL K1-F5-printer-gate expect=FAIL got=FAIL MATCH :: … guard=0` ends its
bad list with `selftest`, i.e. the FAIL is caused by SELF_OK, not by r5 detecting
a printer. A Python printer passes at value=10 (above). Severity high: the
capability claim is “a lane gate that replays”; the counter's 10 does not
measure the gate's replay logic.

### F2 HIGH — The gate path is not confined: a symlinked printer gate scores 10
The counter tests `[ -e "$T/corpus/recheck-replay.py" ]` (`:69`) and runs the
path; it does not require a regular file inside the tree, does not reject
symlinks, and has no digest. Repro: the same printer stored at
`.ufo/gate-printer.py`, with `corpus/recheck-replay.py` a symlink
`../.ufo/gate-printer.py` (portable to revision mode; both paths would be
committed):

```
observed: C1_REPLAY: value=10 present=10 replayed=10 gate=1 guard=1 (bad=none)   rc=0
```

An absolute symlink to an out-of-tree printer also reads 10 (host-dependent in
revision mode because the target must exist where the archive is measured). The
predicate says “the measured tree's own `recheck-replay.py`”; a symlink to bytes
outside the tree is not that. Same high severity class as F1: gate identity.

### F3 HIGH — `body_path` is unconstrained: a manifest-only forgery with no captures
r3 permits any regular file of the measured tree. Repro: the five manifest rows
`S055,S057,S067,S070,S074` re-pointed at the pre-existing lane file
`corpus/source-fetches.tsv` (bytes `64643`, sha256 `3ec6135d…`), with their five
capture bodies deleted from the tree:

```
command: bash <clone>/plans/round-56-c1.sh --tree <tree>/nocap
observed: C1_REPLAY: value=10 present=10 replayed=10 gate=1 guard=1 (bad=none)   rc=0
```

The frozen gate itself replays the TSV (it contains one occurrence of each
required phrase), so it prints MATCH too. The row's `http_status`/`fetched` are
never checked, and nothing binds `body_path` to a capture namespace, to a fetch
receipt, or to per-URL uniqueness. The plan's landing sentence says “the
committed body capture registered for that URL”; the code implements the weaker
r3 text. The named ceiling covers “a capture hand-written to carry the stated
counts”, which the TSV arguably is; but a pre-existing lane log is not a capture,
and the ceiling's provenance remedy (fetch receipt, non-author live re-fetch) has
no force inside the counter.

The declared ceiling is live and was reproduced: `S074.body` replaced by
`b"public comment period is CLOSED\n"` with the manifest re-bound → `value=10
present=10 replayed=10 gate=1 guard=1`, rc 0.

### F4 MEDIUM — The gate's own `--root` rc is discarded
`(cd "$SCR" && python3 … --root "$T" > "$GATE_OUT" 2>&1)` at `:71`; its rc is
never captured. Repro: a gate that prints the ten MATCH lines and CLEAN and then
exits 3:

```
observed: C1_REPLAY: value=10 present=10 replayed=10 gate=1 guard=1 (bad=none)   rc=0
```

The predicate r5 does not require rc, so code == predicate; but a gate that
declares its own failure is recorded as clean, and no control expects a nonzero
gate run. (Epoch-B's counter header adds a `GATE_RC` conjunct; not reviewed here.)

### F5 MEDIUM — A malformed N token is accepted as the stated N
`present()` uses `%d(?!\d)` (`:123`) and the gate's `CLOCK_RE` captures `(\d+)`
without a right boundary, so `-> 1x` is read as `-> 1`. Repro: `-> 1 (` rewritten
to `-> 1x (` in the betterleaks clock:

```
observed: C1_REPLAY: value=10 present=10 replayed=10 gate=1 guard=1   rc=0
gate:     … RECHECK_REPLAY: CLEAN (clocks=10 match=10 …)               rc=0
```

The value is not distorted (the prefix is still 1), but the plan's r1 token
grammar (`-> N` / `-> count=N`) admits a bare integer, and a non-conforming
statement passes. Same sentence-level looseness as the selftest prefix in F8.

## 3. Findings — (b) legit landings that score <10

### F6 MEDIUM — Three equivalence-class edits turn the claim off wholesale
All three follow the byte-exact r1/r2 clauses, so they are predicate-defined
rather than code divergences; they matter because they make the frozen counter
unmaintainable and they are not covered by any control.

| Repro | Edit | Observed |
|---|---|---|
| reword | betterleaks command single quotes → double quotes (same URL, same pattern, same fetch) | `value=FAIL present=9 replayed=9 gate=1 guard=0`, rc 0, `bad=absent:betterleaks…` |
| twoline | a second `recheck:` line added to the entry (the plan's POP definition speaks of “a column-1 `recheck:` line”, not one per file) | `value=FAIL present=9 replayed=9 gate=1 guard=0`, rc 0, same absent badge |
| urlslash | manifest S074 URL gains a trailing `/` (normalisation; entry unchanged) | `value=0 present=10 replayed=0 gate=0 guard=1`, rc 0; `r2-rows0:…ipd` plus `r5-gate` ×10 because the gate keys rows by exact URL and goes NO-CAPTURE → DRIFT |

Consequence: any future edit to a clock's command text, to the number of
`recheck:` lines, or to a manifest URL makes the frozen counter FAIL or zero
even though the stated fact is unchanged. At 42070de no such edit exists, so the
candidate reading is unaffected; the brittleness is in the next round's reuse.

### F7 MEDIUM — Global CLEAN couples the ten clocks to the whole lane population
An extra unsupported clock anywhere under `corpus/knowledge` makes the gate end
`DRIFT`; r5 requires the tree-wide CLEAN, so all ten POP clocks fail:

```
repro: prefreeze-controls.md recheck line replaced by
       `curl -fsSL https://example.invalid/x | sed -n 1p | grep -c needle` -> 1
observed: C1_REPLAY: value=0 present=10 replayed=0 gate=0 guard=1 (bad=r5-gate ×10)   rc=0
```

The ten clocks are present and replayed on their captures; a single unrelated
bad clock zeroes them. This is predicate-consistent (r5 says the gate “ends
RECHECK_REPLAY: CLEAN”) but means the claim is only re-readable while the entire
lane population is clean, and the `bad` list collapses distinct faults into the
same ten `r5-gate` badges.

## 4. Finding — (c) SETUP / empty-producer paths

No pass-shaped SETUP was found. `setup()` prints `C1_REPLAY: SETUP <reason>` and
exits 2 (`:45-56`); the controls' `pick()` yields an empty value for it, so a
SETUP can never compare equal to `10` or `FAIL`. An empty gate producer yields
`gate_lines = []` → `gate_clean = 0` (`:183`) → every r5 fails.

The remaining weak shape is the guard: a tree with **no gate at all** reads
`value=0 present=10 replayed=0 gate=0 guard=1` (repro `nogate`; rc 0). See F8.

## 5. Finding — (d) `--tree` versus revision paths

After T is populated the two paths are the same code (`:57-62`); the only
divergence is what populates T. Revision mode uses `git archive <rev>` (tracked
bytes only); `--tree` copies an arbitrary directory with `cp -a`, including
untracked files and `.git`. Consequences:

- The attack trees above are not commits, yet score 10 via `--tree`; the same
  bytes score the same once committed, because the post-population logic is
  identical. Revision mode at `42070de` reads `value=10 …`, rc 0 (verified from
  the clone), so the current frozen record is not a `--tree` artefact.
- The pre-freeze landing control is `--tree` only: `plans/round-56-controls.sh:21`
  builds REF from `git ls-files -co --exclude-standard` (tracked **plus
  untracked**), and `:42` runs `check K1-REF 10 ref`. No control measures a
  committed candidate in revision mode. That is a process gap: a landing whose
  gate/manifest/captures are uncommitted would pass the pre-freeze suite. The
  freeze commit `42070de` does track all of them (verified with `git ls-tree`),
  so the gap is not live at this revision.

## 6. Finding — (e) GUARD conjuncts weaker than stated

The plan sentence and the counter header are not the same sentence:

- Plan `:15`: “GUARD = 1 iff all 10 clocks are PRESENT and the measured tree's
  gate `--selftest` exits 0 with last line `RECHECK_REPLAY_SELFTEST: PASS`.”
- Counter header `:32-34`: “… and, **when the measured tree carries
  corpus/recheck-replay.py**, its `--selftest` exits 0 with a last line
  **starting** `RECHECK_REPLAY_SELFTEST: PASS`.”

Code follows the header (`:68` initialises `SELF_OK=1`; `:72` only sets it to 0
when the gate exists; `:73-75` requires exit 0 and a prefix match; `:223`
computes guard). Observed consequences:

- gate deleted (manifest + captures intact): `value=0 … guard=1`, rc 0 — the
  plan sentence would give guard=0. The output's `guard=1` therefore means
  “PRESENT ×10 and (no gate, or selftest self-passed)”, not “the gate is sound”.
- selftest last line `RECHECK_REPLAY_SELFTEST: PASS (0 cases, 13 failed)` with
  exit 0: `value=10 present=10 replayed=10 gate=1 guard=1`, rc 0. The plan's
  landing text says “a `--selftest` of 13 cases”; neither the case count nor the
  text after the prefix is checked. r5 itself only looks at the gate's last line
  (`:183`), so the gate's self-attestation is the only evidence for the gate.

## 7. Controls coverage assessment

The committed receipt (`3cc3e977`) is 12/12 MATCH. My re-run reproduced K1-BASE,
K1-REF and F1-F4 identically (my run was truncated by my own pipe at F4, so
F5-F10 are taken from the committed receipt plus direct runs above). Controls
that do work: deleted clock, restated N (to 2), body tamper, row drop, symlink
body, header bytes, unsupported clock (via the global DRIFT veto), selftest
FAILX, entry symlink.

Gaps, in order of importance:

1. F5's “printer gate” is bash-written-to-.py and fails via `selftest`, not via
   r5 (F1). No control uses a Python printer, a symlink gate, or a nonzero gate
   rc (F2, F4).
2. No control moves `body_path` outside a capture namespace or deletes captures
   while keeping the manifest self-consistent (F3).
3. No control exercises a reworded clock, a second `recheck:` line, or a
   normalised URL (F6), or a malformed N token (F5).
4. No revision-mode landing control (F9, §5).
5. `:49` F2 prints `AssertionError: inert edit …` into the receipt before its
   regex rewrite applies; the receipt preserves the traceback. Cosmetic, but the
   control is doing its edit in two steps and the first is inert.

Additional equivalences/divergences checked, no live effect at 42070de:

- Counter `registry()` skips fenced blocks (`:126-139`); gate `registry_rows`
  (`:115-122`) does not. `corpus/SOURCES.md` contains zero ``` fences
  (`grep -c '```' corpus/SOURCES.md` = 0), so both see one row per id.
- Counter requires the URL as a whitespace-delimited token of the source cell
  (`rr[0][1].split()`); the gate's regex allows the URL next to `(<` / `)>`.
  All 10 source cells carry the URL as a plain token, so both pass.
- Counter `manifest()` silently drops a non-7-column row (`:141-158`); the gate
  treats it as SETUP. The gate's SETUP makes `gate_clean=0`, so a malformed row
  cannot yield a false green, but faults collapse into `r5-gate` badges.
- The gate drops a symlinked knowledge entry (`recheck-replay.py:67`) and can
  print `CLEAN (clocks=9)`; the counter's `present()` treats the entry as absent
  → `present=9`, guard=0, `value=FAIL` (F10 receipt). The counter catches it;
  the gate run standalone would not.
- The counter exits 0 on `value=FAIL` (reword/twoline), and SETUP exits 2;
  admission must parse the `value=` token, not rc.

## 8. Declared ceilings confirmed

- Hand-written capture with a self-consistent manifest row: `S074.body =
  "public comment period is CLOSED\n"`, manifest re-bound → `value=10`, rc 0.
- Body path to a pre-existing lane file (not a capture): F3 → `value=10`, rc 0.
- `--selftest` self-attestation: zero-case/unchecked suffix → `guard=1` (F8).

## 9. Live epoch-B state (blocker sent; L1 decided re-predeclare)

During this audit the working tree held unfrozen edits. Observed hashes:
counter `35cdc09d…` (15736 B, mtime 2026-11-07 07:37:10 -0300) → `d2bcb790…`
(15746 B, 07:38:15) → `6b132ea1…`; gate `637c8184…` (07:35:34) → `2e9dfde3…`.
The worktree counter pins `GATE_SHA256_PIN=637c8184…`; run against revision
`42070de` (gate `b7782f35…`) it returns
`value=0 present=10 replayed=0 gate=0 guard=1 (bad=r5-gate ×10)`, rc 0 — the
frozen revision no longer reads 10 under worktree bytes. My blocker message
quoted these values; L1 (KagiR56a3) replied that re-predeclare is the decision; epoch-B landed at
`5d9a1571911ec38a456a40b443e19640abb9a88b` and is re-audited in §11 against that
hash. An epoch-B probe taken while the bytes were still moving (counter
`d2bcb790`, pin `637c8184`, copied gate `2e9dfde3`) returned 0 for both candidate
trees solely because the pin did not match the copied gate — confounded, not
evidence either way.

## 10. Residual risk and verification gaps

Residual risk:

- Even with correct captures, `value=10` does not establish that the gate
  replayed anything (F1, F2). Epoch-B's digest pin addresses gate identity; it
  does not address the body_path hole (F3) or the false negatives (F6).
- r3 permits any committed bytes, including non-capture files; the plan's
  provenance defence (fetch receipt, non-author re-fetch) is out-of-band and not
  enforced (F3).
- The frozen counter is population-coupled: PAP is literal BASE text, and r5 is
  tree-wide CLEAN (F6, F7). It cannot be re-read after any clock/manifest edit
  without a re-freeze.
- `guard=1` is weaker than its name (F8): PRESENT plus a self-attested selftest.

Verification gaps:

- No lane commit was created (forbidden), so revision-mode attack runs are
  argued from `:57-62` equivalence plus the verified revision-mode reading at
  `42070de`; the attack trees themselves are `--tree` runs.
- Epoch-B was not reviewed (moving target, new predeclaration pending).
- The live re-fetch leg (currency on the day) was not run; it is out of this
  seat and not part of the counter.
- My controls re-run was truncated by my own `sed -n 1,40p` SIGPIPE at F4;
  F5-F10 are taken from the committed receipt and the direct runs in §2-§6.

## 11. Epoch-B re-audit at `5d9a157` (hardened instruments)

L1 landed the epoch-B predeclaration `5d9a1571911ec38a456a40b443e19640abb9a88b`
and asked for all epoch-B evidence to be anchored there. Readings were made from
the same single clone, checked out at `5d9a157` (root asserted; one clone), with
attack trees built by `git archive 5d9a157`.

| Artifact | SHA256 |
|---|---|
| `plans/round-56-c1.sh` | `6b132ea1b521e698aaf4a1085e051087726c6b5ec840f60339b206abe02b269c` |
| `corpus/recheck-replay.py` | `2e9dfde326b29fb95f520c5d7f3a671836682b28025e4efc7887333257d4df51` (= `GATE_SHA256_PIN`; matches) |
| `corpus/recheck-captures.tsv` | `df46be5c92c7b4d5a8b7ad790371b5c3240c92f46460b8cfb69e9b75b7ecc762` (unchanged) |
| `plans/round-56.md` | `033f2104ef36b76e5d9de192878fb1b619808f1c9c63b2e310d074816a3e1679` |
| `plans/round-56-controls.sh` | `63cf806134bcb115368e59809ad54957750d7433d53f6979b256f662e3ddab8f` |
| `controls/controls-prefreeze-epochB.txt` | `709cf29a03f5ba9cc1c2eacb60036a23d5836803e655f4f0c0c91fefc8145aea` (16/16 MATCH, content verified) |
| `capture/fetch-receipt.json` | `080a04836c32ced34ffcd93c1e9574d395dacf0a0ffba720ce54d134292298bd` |

Baselines match L1's claims: `5d9a157` → `value=10 present=10 replayed=10 gate=1
guard=1`, rc 0; `42070de` → `value=0 … gate=0 guard=1`, rc 0 (`r5-gate` ×10,
gate-digest pin); BASE `832ba6a` → `value=0 … guard=1`, rc 0 (`r2-manifest` ×10).

### 11.1 Epoch-A holes that epoch-B closes

| Epoch-A attack | Epoch-A | Epoch-B (all rc 0) |
|---|---|---|
| printer gate (10 MATCH lines + CLEAN) | `value=10` | `value=0 present=10 replayed=0 gate=0 guard=1`, `r5-gate` ×10 (pinned digest rejects) |
| gate symlink to in-tree printer | `value=10` | `value=0`, `r5-gate` ×10 (final path component symlink rejected; `GATE_SHA="SYMLINK"`) |
| gate prints MATCH+CLEAN then exits 3 | `value=10` | the pin makes the bytes immutable, and r5 now requires the gate rc 0; shape not constructible |
| `-> 1x` malformed/restated token | `value=10` | `value=FAIL present=9 replayed=9 gate=1 guard=0` (`absent:betterleaks…`); N token right-bounded by non-digit non-letter |
| selftest `PASS (0 cases, 13 failed)` | `value=10 guard=1` | exact last line `RECHECK_REPLAY_SELFTEST: PASS (13 cases)` required; unmodified pinned gate, shape not constructible |
| gate absent (`nogate`) | `value=0 guard=1` | `value=0 guard=1` — unchanged; the guard is still presence+selftest only |

Epoch-B's r5 also requires the exact `RECHECK_REPLAY: CLEAN (clocks=10 match=10
mismatch=0 no_capture=0 bad_capture=0 unsupported=0 tool=0)` line, so a gate
that is CLEAN over 9 clocks no longer satisfies r5; the epoch-B controls receipt
shows `replayed=0` for K1-F1/F2/F10, consistent with that tightening.

### 11.2 Epoch-A holes that remain open in epoch-B

- **F3 (HIGH) — `body_path` is still not capture-confined.** The epoch-B gate
  adds `confined()` (`corpus/recheck-replay.py:207-223`) for symlinked
  knowledge/registry/manifest/normalizer inputs; `check_capture` (`:152-178`)
  still accepts any repo-relative regular file whose bytes/sha256 and replayed
  count match. Repro: rows `S055,S057,S067,S070,S074` re-pointed at
  `corpus/source-fetches.tsv` (bytes `64643`, sha256 `3ec6135d…`) with their five
  capture bodies deleted → `value=10 present=10 replayed=10 gate=1 guard=1`,
  rc 0. The epoch-B plan r3 still says only “the body is a confined regular
  file”, and the epoch-B control list (BASE, REF, F1, F2, F3-body-tampered, F4,
  F5/F5b/F5c, F11, F12, F6, F7, F8, F9, F10) has no non-capture body case.
  Actionable: add a capture-root requirement to r3 and the gate, or restate the
  named ceiling as “any committed bytes”. The digest pin does not touch this.
- **F6 (MEDIUM) — literal POP false negatives persist**: quotes-only reword →
  `value=FAIL present=9 replayed=9 gate=1 guard=0`; a second `recheck:` line →
  same `FAIL present=9`; manifest URL trailing `/` → `value=0` (`r2-rows0` +
  `r5-gate` ×10). All rc 0, same values as epoch-A.
- **F7 (MEDIUM) — tree-wide CLEAN veto persists**: one extra unsupported clock
  (`example.invalid | sed | grep`) in `prefreeze-controls.md` →
  `value=0 present=10 replayed=0 gate=0 guard=1`, rc 0.
- **F8 (LOW)** — gate-absent `guard=1` persists: `value=0 present=10
  replayed=0 gate=0 guard=1`, rc 0. The epoch-B plan's GUARD sentence (“… and the
  gate's `--selftest` exits 0 …”) still omits the “when the measured tree
  carries corpus/recheck-replay.py” conditional that the epoch-B counter header
  carries; the plan defers to the header, so code == header, but the plan read
  alone would put guard=0 on a gate-less tree. The observed reading keeps the
  gap visible.
- **Declared ceiling** — hand-written `S074.body` + re-bound manifest row →
  `value=10 present=10 replayed=10 gate=1 guard=1`, rc 0; unchanged.

Epoch-B verdict: gate identity, gate rc, the selftest string/count, and the
malformed-N boundary are closed by construction (digest pin + exact strings +
right-bounded token). The body-identity hole (F3) and the POP brittleness
(F6/F7) are untouched; a candidate that keeps the pinned gate bytes but
re-points `body_path` at a committed non-capture file still reads 10.

Candidate-side content edits present in the worktree after `5d9a157` were
checked against r1/r2 and do not break them: the `S113` registry row edit
(attestation wording for the default-UA 403 lesson) still yields 11 cells,
`status=mined`, and the URL as a source-cell token; the `cdp-bridge` entry edit
touches only its `source:` line, and its `recheck:` line still states
`... -> count=1` byte-for-byte. `corpus/SOURCES.md` contains no ``` fences, so
the counter's fence-skipping and the gate's non-skipping parsers still agree.

### 11.3 Post-commit worktree drift (measurement hazard)

After `5d9a157` was committed, the lane worktree kept moving. Observed at
07:50:08-07:50:48: `corpus/recheck-replay.py` `d4392ffe831560397fa35b4e84198b6ac75d5da8505a302ef3dcf6991080b274`
(18728 B) and `plans/round-56-c1.sh` `5e36726d…` then
`a3800be15e3f7b1471719351628e54fcdc837740c52bb35837654ed22b274bd7` (16909 B);
`git diff 5d9a157` shows +93/−23 across the two. Both are uncommitted and were
not reviewed. The epoch-B readings in §11 are anchored to the committed blobs
(counter `6b132ea1…`, gate `2e9dfde3…` = the pin); running the worktree counter
against `5d9a157` (or the worktree gate against the committed pin, or vice
versa) will read `gate=0`/`value=0` for a pin mismatch. Measure committed
hashes, not the worktree, and re-anchor if these edits become the candidate.

## 12. Epoch-C re-audit at `711e6393` (supersedes epoch-B)

L1 landed epoch-C `711e6393e68658f396918c07de253e5a5c74d1b4`; all epoch-C
evidence below is anchored there. The same single clone was fetched and checked
out at that revision; attack trees were built with `git archive 711e6393`.

| Artifact | SHA256 |
|---|---|
| `plans/round-56-c1.sh` | `7992ee6a97c9f1cfaf627c61322ecaf6aa0c31126a65f591567d7b6f7ee2802c` |
| `corpus/recheck-replay.py` | `e9b7e4b7aa1e8173c4bfc2e536ce6d1ed29c4c0d6ee5f46bfa1e63d3692a62b4` (= pin) |
| `corpus/recheck-captures.tsv` | `df46be5c92c7b4d5a8b7ad790371b5c3240c92f46460b8cfb69e9b75b7ecc762` |
| `plans/round-56.md` | `8beb24e94a08c3961f5217a3b4b98aadc46d56561fe3ec2254f13185d4cf6c9f` |
| `plans/round-56-controls.sh` | `b675baa5fad95bc663f49ca76ea13be84627db457af443f3b957144cd8ddd16c` |
| `controls/controls-prefreeze-epochC.txt` | `523aaa60946a1322441a22c820daf9cc84c9d7924aa1eaa8b4b338dcf5e8b6b2` (20/20 MATCH, 0 `tar:` errors; 21 `^CONTROL` lines incl instrument-hash lines) |

Baselines (all rc 0): `711e6393` → `value=10 present=10 replayed=10 gate=1
guard=1`; `5d9a157` → `value=FAIL present=10 replayed=0 gate=0 guard=0`
(`r5-gate` ×10 + `selftest` + `gate-digest`, old pin); `42070de` → the same
FAIL; BASE → `value=0 present=10 replayed=0 gate=0 guard=1` (`r2-manifest` ×10).

### 12.1 Holes closed by epoch-C

| Attack | Observed (rc 0) |
|---|---|
| printer gate (10 MATCH + CLEAN) | `value=FAIL present=10 replayed=0 gate=0 guard=0`; `r5-gate` ×10 + `selftest` + `gate-digest` |
| gate symlink to in-tree printer | `value=FAIL … gate=0 guard=0`; `r5-gate` ×10 + `selftest` |
| one row re-pointed outside the capture namespace (`S074` → `corpus/source-fetches.tsv`) | `value=0 … gate=0 guard=1`; per-row `r3-notcapture:…ipd` + `r5-gate` ×10 |
| five rows re-pointed at the same non-capture body, five captures deleted | `value=0 … guard=1`; `r2-manifest-malformed` ×10 |
| five rows sharing one capture-dir body (`.ufo/waves/round-56/capture/tsv.body`) | `value=0 … guard=1`; `r2-manifest-malformed` ×10 (bijection) |
| forged `fetched` (`not-a-date`) | `value=0 … guard=1`; `r2-manifest-malformed` ×10 |
| forged `http_status=999` | `value=0 … guard=1`; `r2-manifest-malformed` ×10 |
| `-> 1x` malformed N | `value=FAIL present=9 replayed=9 gate=1 guard=0`; `absent:betterleaks…` |

The printer's bad list now adds `gate-digest` and `selftest` and drives
`guard=0`, so the epoch-A/B gate-identity and body-identity holes are closed by
construction, and the manifest is checked as a whole (capture confinement,
ISO date, 2xx status, body_path/sha256 bijection).

### 12.2 Still open in epoch-C

- **F6 literal POP (MEDIUM)** — the three equivalence-class edits still fail:
  quotes-only reword → `value=FAIL present=9`; a second `recheck:` line →
  `value=FAIL present=9`; manifest URL trailing `/` → `value=0` (`r2-rows0` +
  `r5-gate` ×10). All rc 0.
- **F7 tree-wide CLEAN veto (MEDIUM)** — one extra unsupported clock in
  `prefreeze-controls.md` → `value=0 present=10 replayed=0 gate=0 guard=1`, rc 0.
- **F8 guard semantics (LOW)** — gate absent (`nogate`) → `value=0 guard=1`,
  rc 0. The epoch-C plan now defines this explicitly (“no gate file is present
  with non-pinned bytes, and, when the measured tree carries the pinned gate
  bytes, its `--selftest` exits 0…”), so code == plan; the reading still means a
  gate-less tree can carry `guard=1`, and the guard's name invites misreading.
- **Declared ceiling** — a hand-written capture placed inside the capture
  namespace with an ISO `fetched` and a 2xx status, manifest re-bound to its
  bytes/sha → `value=10 present=10 replayed=10 gate=1 guard=1`, rc 0. Epoch-C
  forces the path namespace and metadata but not provenance; this is the named
  “hand-written capture” ceiling.
- **Blunt manifest failure** — any single malformed manifest row (non-capture
  path, duplicate body, bad date/status) yields `r2-manifest-malformed` for all
  ten clocks, so one bad row zeroes the whole claim and per-row attribution is
  lost (fail-closed, coarse).

Epoch-C verdict: gate identity, gate rc, selftest string/count, body
confinement, manifest metadata/bijection, and the N boundary are closed. The
remaining holes are the literal-POP brittleness (F6), the tree-wide CLEAN veto
(F7), the guard semantics (F8), and the explicitly named hand-written-capture
ceiling. The candidate at `711e6393` reads 10; it must carry the pinned gate
bytes `e9b7e4b7…` and must not edit POP text or manifest URLs.

Measurement note: the lane worktree continued to move during this audit; all
epoch-C numbers are from the committed blobs above, not the worktree. The
epoch-B §11.3 drift hashes remain a record of the earlier window.

## 13. Epoch-D re-audit at `d3623187` (supersedes epoch-C)

L1 landed epoch-D `d36231871c864c930d3e7e33f9c5345b30ab4f98` to restore
case-insensitive column-0 header refusal and tighten the N boundary. All
epoch-D evidence below is anchored there; the same single-clone method was used
(`git fetch`; `git checkout d3623187`; trees from `git archive d3623187`).

| Artifact | SHA256 |
|---|---|
| `plans/round-56-c1.sh` | `82acbb2056aac6055a79f223a0e0abbb2cb24f11f01ca5ed12a230c8338bdc6a` |
| `corpus/recheck-replay.py` | `5165da2a6fced02fce82c92fc898553db9a6d3d702d9fc6d1ca3ba185e77b14f` (= pin) |
| `plans/round-56.md` | `4d837eb2d467064efedb9e25173c5bde82830e88c31754d7af1ac253c87b8b74` |
| `plans/round-56-controls.sh` | `9445a1ec208f2b8dad55da2694f4b7ebd2554e3ecd4196f15c5d5da4958882ce` |
| `controls/controls-prefreeze-epochD.txt` | `cc27bd96f13b22843993a4e0154f6b280766c69f2540d5433136ea360c19f6c9` (21/21 MATCH, 0 `tar:` errors) |

Baselines (rc 0): `d3623187` → `value=10 present=10 replayed=10 gate=1 guard=1`;
`711e6393` → `value=FAIL present=10 replayed=0 gate=0 guard=0` (`r5-gate` ×10 +
`selftest` + `gate-digest`); BASE → `value=0 present=10 replayed=0 gate=0
guard=1` (`r2-manifest` ×10). The epoch-D receipt carries 21 MATCH and no tar
errors.

### 13.1 Targeted regressions confirmed closed

| Case | Observed (rc 0) |
|---|---|
| body prefixed `Set-Cookie: x=1\r\n\r\n` (canonical case), manifest re-bound | `value=0 present=10 replayed=0 gate=0 guard=1`; `r3-headers:…ipd` + `r5-gate` ×10; gate standalone `RECHECK_REPLAY: DRIFT (clocks=10 match=9 … bad_capture=1)` |
| body prefixed `Http/2 200\r\n\r\n`, manifest re-bound | same `r3-headers` + `r5-gate` ×10 |
| `-> 1.0` | `value=FAIL present=9 replayed=9 gate=1 guard=0` (`absent:betterleaks…`) |
| `-> 1_0` | same `FAIL present=9` |

### 13.2 Carried from epoch-C (re-run on epoch-D, unchanged)

- printer gate → `value=FAIL present=10 replayed=0 gate=0 guard=0` (`r5-gate` ×10 + `selftest` + `gate-digest`).
- symlink gate → `value=FAIL … guard=0` (`r5-gate` ×10 + `selftest`).
- gate absent → `value=0 … guard=1`.
- five rows re-pointed at one non-capture body with captures deleted, and five rows sharing a capture-dir body → `value=0`, `r2-manifest-malformed` ×10.
- one row re-pointed outside the capture namespace → `value=0`, per-row `r3-notcapture:…ipd` + `r5-gate` ×10.
- hand-written capture inside the capture dir with ISO `fetched` + 2xx and manifest re-bound → `value=10 present=10 replayed=10 gate=1 guard=1` (named ceiling).
- reword → `FAIL present=9`; second `recheck:` line → `FAIL present=9`; manifest URL trailing `/` → `value=0` (`r2-rows0` + `r5-gate` ×10).
- extra unsupported clock → `value=0` (`r5-gate` ×10).

Epoch-D verdict: the case-insensitivity and N-boundary regressions are closed
and the epoch-C closures hold. The remaining items are the design-level ones:
literal-POP false negatives (F6), the tree-wide CLEAN veto (F7), the semantic
`guard=1` without a gate (F8), the named hand-written-capture ceiling, and the
blunt manifest failure that marks all ten clocks malformed for one bad row. The
candidate at `d3623187` reads 10 and must keep the pinned gate bytes
`5165da2a…`, leave POP text and manifest URLs untouched, and keep the bodies
inside the capture namespace with ISO dates and 2xx statuses.

## 14. Epoch-E re-audit at `dd31b786` (supersedes epoch-D)

L1 landed epoch-E `dd31b7867723f89fc8f83e88cc7d98e17de26cf2` to add tool
preflight guards and fix the plan's selftest token; verdict semantics are
disclosed as unchanged. All epoch-E evidence below is anchored there; the same
single-clone method was used (`git fetch`; `git checkout dd31b786`).

| Artifact | SHA256 |
|---|---|
| `plans/round-56-c1.sh` | `d468533fbf593c4b2a3a97dc513b9feb2cff765892c126c02d7c6ef40273a954` |
| `corpus/recheck-replay.py` | `5165da2a6fced02fce82c92fc898553db9a6d3d702d9fc6d1ca3ba185e77b14f` (= pin, unchanged from D) |
| `plans/round-56.md` | `212e2dd7ae71e3f056111e1a2c59d33151a3c51fee9f932bf2209ad2cb3d805d` (selftest token `PASS (20 cases)`) |
| `plans/round-56-controls.sh` | `01060f254b2ecfdb23f341a5cf0937aec32243230560809403ed67ea38b196e7` |
| `controls/controls-prefreeze-epochE.txt` | `b4ab59c5498272a7fe97d28f72bc06a1de66f06f2ef86783bbd09c8211fc711e` (22/22 MATCH, 0 `tar:` errors; 23 `^CONTROL` lines incl instrument) |

Baselines (rc 0): `dd31b786` → `value=10 present=10 replayed=10 gate=1 guard=1`;
`d3623187` → `value=10 … gate=1 guard=1` (as disclosed: E does not tighten the
verdict); BASE → `value=0 present=10 replayed=0 gate=0 guard=1` (`r2-manifest`
×10).

### 14.1 Tool preflight guards confirmed

The counter preflights `python3`, `grep`, `pdftotext`, `sha256sum`, `cut`,
`tail`, `timeout`, `git`, `tar` (`plans/round-56-c1.sh:58-66`). A PATH farm with
one binary removed:

| Case | Observed |
|---|---|
| `timeout` absent | `C1_REPLAY: SETUP no-timeout`, rc 2 |
| `sha256sum` absent | `C1_REPLAY: SETUP no-sha256sum`, rc 2 |
| normal PATH (control) | `C1_REPLAY: value=10 present=10 replayed=10 gate=1 guard=1`, rc 0 |

A missing tool therefore reads as SETUP (exit 2), not as a pass or a zero.

### 14.2 Carried subset re-run on epoch-E (unchanged)

- printer gate → `value=FAIL present=10 replayed=0 gate=0 guard=0` (`r5-gate` ×10 + `selftest` + `gate-digest`).
- gate absent → `value=0 … guard=1`.
- five rows re-pointed at one non-capture body with captures deleted → `value=0`, `r2-manifest-malformed` ×10.
- hand-written capture inside the capture dir with ISO `fetched` + 2xx and manifest re-bound → `value=10 present=10 replayed=10 gate=1 guard=1` (named ceiling).
- reword → `value=FAIL present=9`; extra unsupported clock → `value=0` (`r5-gate` ×10).

Epoch-E verdict: the tool guards and the selftest-token/doc fix are correct and
SETUP is distinguishable (rc 2). Verdict semantics are unchanged from D, as
disclosed. The remaining items are still the design-level ones: literal-POP
false negatives (F6), the tree-wide CLEAN veto (F7), the semantic `guard=1`
without a gate (F8), the named hand-written-capture ceiling, and the blunt
manifest failure that marks all ten clocks malformed for one bad row. The
candidate at `dd31b786` reads 10 and must keep the pinned gate bytes
`5165da2a…`, POP text, manifest URLs, and capture confinement + ISO/2xx.

## Receipts

`.ufo/waves/round-56/w1/R56ReviewCounter.d/readings.txt` — anchor hashes,
method, every command/rc/value, fixture definitions (printer gate, symlink-gate,
nocap, forge, reword, twoline, urlslash, restate1x, f8, zerocase), the epoch-A
record, the epoch-B re-audit, the epoch-C re-audit, the epoch-D re-audit, and
the epoch-E re-audit readings.
