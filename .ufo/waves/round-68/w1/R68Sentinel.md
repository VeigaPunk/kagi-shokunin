# Round 68 — R68Sentinel: security & abuse review of the widened census binding

Seat: sentinel (attack, 1 of 15). Lane `kagi-shokunin`, branch master, claim BASE
`d3b2a4e8eed710277951e430efd3d27b5983033c`. Frozen predeclaration
`plans/round-68.md`, landed `23a8e0290d8d3a6f1de16eafce40fd1a189ef636`.

**Read-only on the lane.** No lane file was edited by this seat; no git command
mutated anything; nothing was committed; no fleet path and no sibling lane was
touched. Every tree under test is a private copy under
`${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r68/R68Sentinel/` (deleted on
yield). Receipts copied into `.ufo/waves/round-68/w1/R68Sentinel/receipts/`.

**The gate moved during this seat.** R68ExecGate owns
`corpus/sources-census.sh` and was editing it while this seat ran. Five
distinct byte-states were observed and measured:

| label | sha256 of `corpus/sources-census.sh` | when |
|---|---|---|
| `BASE` | `e7aacecdfcf06ed6303f5272cd0d3bd6a20d16fdbf0f064a4c68aae940e1d10f` | BASE and HEAD at seat start (= the round-67 landed gate) |
| `R1` | `6173eab7b7a2b705b111ea6b3e8f325d2285dda6ed6bc1f08df82acc66e89269` | first widened revision observed |
| `R2` | `d74a4183355988f986fcfac2e80fcdeea06c1074c2fd105679ea03f1ed8922dd` | second |
| `R3` | `fd3cb5981f1d1caaddc5b23c209dd399b3b02aa35374d622763deb319e33d9f6` | third |
| `R4` | `6f18c608052fccf9d15e2f48ef4d68b13d164c0ac5c342872582702da9fb5f21` | fourth |
| `R5` | `84725a7e9930f1b2c686139c5e2a3f916f873f5a9123f9bc07407cdbd2d04c4d` | fifth (last observed) |

Every result below names the byte-state it was measured on. The classes are
byte-independent (they are properties of the rule); the *counts* are not, and
each count is quoted with the tree it came from.

**This seat's report is written against a moving target and says so.** R68ExecGate
owns `corpus/sources-census.sh` and was iterating on it throughout this seat;
the selftest went `FAIL (98 cases, 3 failed)` → `2 failed` → `1 failed` across
the revisions above, and the last observed state (`R5`) still has one red
case. **§6 is written against `R3`/`R4`, where three cases were red; against
`R5` the survivor is `capture-token-slashslash` alone.** The remaining
findings (F1, F3–F10) are properties of the rule and of the counter's parsing
contract, not of a byte-state, and they hold at every revision observed.

## 1. What was measured, and against what

Two instruments:

1. **the landed gate itself** (`corpus/sources-census.sh` copied into a
   private tree, invoked exactly as the lane invokes it:
   `bash corpus/sources-census.sh verify --root .`), and
2. **a reference widened gate** (`receipts/refgate.py`) implementing the
   *frozen* §C1 reason set — `capture-whitespace`, `capture-token`,
   `normalized-digest-mismatch`, file-level `SC_FETCH cr-in-tsv` — so that
   the classifier boundary could be attacked *before* the gate landed and the
   same battery re-run against it afterwards.

The reference gate is a test instrument, **not** a substitute for the landed
gate: the landed gate is what the round's counter will measure, and the
reference is only what let the boundary be probed in parallel with the
executor's work.

Tooling: no tool was installed or upgraded by this seat. Everything ran on the
host's existing `bash`, `python3` (3.14), `gawk` 5.4.1, `git`, `coreutils`,
`sed`, `grep`. The operator tooling directive is satisfied vacuously: **no
install, no update, no version change, no channel used.** The tools above are
the host's pre-existing ones.

## 2. The fail-open battery — the requested constructions

Full table: `receipts/battery-results.tsv` (reference gate, both classifier
variants) and `receipts/landed-gate-battery.tsv` (the landed gate). Verbatim
stdout: `receipts/battery-detail.txt`, `receipts/landed-gate-battery.txt`.

Each row is a mutation of the **anchor** row's cells (or of the tree's files)
on a private copy. `LANE` = the landed gate of the day; `REF` = the reference
widened gate.

| # | construction | BASE gate (`e7aacecd`) | landed widened gate | reference widened gate |
|---|---|---|---|---|
| 1 | `.ufo/waves/` symlink chain → out-of-tree body | `FAILED` `capture-outside-root` | `FAILED` `capture-outside-root` | `FAILED` `capture-outside-root` |
| 2 | in-tree **hardlink** → out-of-tree body (same bytes, `nlink=2`) | **`CLEAN`** | **`CLEAN`** | **`CLEAN`** |
| 3 | capture path replaced by a **directory** | `FAILED` `capture-missing` | `FAILED` `capture-missing` | `FAILED` `capture-missing` |
| 4 | col 16 = path + **NUL byte** | **`CLEAN`** | **`CLEAN`** | **`CLEAN`** |
| 5 | col 16 token is a `.ufo/waves/` path but its **realpath escapes** | `FAILED` `capture-outside-root` | `FAILED` `capture-outside-root` | `FAILED` `capture-outside-root` |
| 6 | **NUL byte anywhere** in `corpus/source-fetches.tsv` | **`CLEAN`** | **`CLEAN`** | **`CLEAN`** |
| 7 | **CR inside a quote column only** (col 13) | **`CLEAN`** | `FAILED` `SC_FETCH cr-in-tsv` | `FAILED` `SC_FETCH cr-in-tsv` |
| 8 | col 15 = `-` under `rendered-text-v1` | `FAILED` (pre-existing `SC_FETCH normalized-digest`) | `FAILED` `normalized-digest-mismatch` + `SC_FETCH` | `FAILED` `normalized-digest-mismatch` |
| 9 | **id cell emptied** | `FAILED` (pre-existing `SC_FETCH`) | `FAILED` (pre-existing `SC_FETCH`) | n/a (no `SC_FETCH` in the reference) |
| 10 | **id cell shifted** (extra tab, 17 fields) | `FAILED` (pre-existing `SC_FETCH nf=17`) | `FAILED` (pre-existing `SC_FETCH nf=17`) | n/a |
| 11 | **duplicate row** | `FAILED` (`SC_FETCH duplicate-provenance`) | `FAILED` (`SC_FETCH duplicate-provenance`) | n/a |
| 12 | **M1** col 16 + one space | **`CLEAN`** | `FAILED` `capture-whitespace` | `FAILED` `capture-whitespace` |
| 13 | **M2** col 16 comma-joined | **`CLEAN`** | `FAILED` `capture-whitespace` | `FAILED` `capture-whitespace` |
| 14 | **M3** whole TSV rewritten CRLF | **`CLEAN`** (`path_rows=0 prose=157`) | `FAILED` `SC_FETCH cr-in-tsv` | `FAILED` `SC_FETCH cr-in-tsv` |
| 15 | **M4** one hex digit of col 10 | `FAILED` `capture-digest-mismatch` | `FAILED` `capture-digest-mismatch` | `FAILED` `capture-digest-mismatch` |
| 16 | **M5** col 15 replaced by another 64-hex | **`CLEAN`** | `FAILED` `normalized-digest-mismatch` | `FAILED` `normalized-digest-mismatch` |
| 17 | **M6** capture body + 1 byte | `FAILED` `capture-bytes-mismatch` | `FAILED` `capture-bytes-mismatch` | `FAILED` `capture-bytes-mismatch` |
| 18 | col 16 = **mixed prose** naming the path | **`CLEAN`** | `FAILED` `capture-token` | `FAILED` `capture-token` |
| 19 | col 16 = **`~/`**form | **`CLEAN`** | `FAILED` `capture-token` | `FAILED` `capture-token` |
| 20 | col 16 = **`//`**form | **`CLEAN`** | `FAILED` `capture-outside-root` | `FAILED` `capture-outside-root` |
| 21 | col 16 = prose naming no `.ufo/waves/` token | `CLEAN` (prose) | `CLEAN` (prose) | `CLEAN` (prose) |
| 22 | col 16 = `../`+path | `FAILED` `capture-outside-root` | `FAILED` `capture-outside-root` | `FAILED` `capture-outside-root` |
| 23 | col 16 re-pointed at a **non-`.ufo/waves/` repo path** | `FAILED` (`capture-bytes-mismatch` + `capture-digest-mismatch`) | **`CLEAN`** | **`CLEAN`** |
| 24 | col 16 re-pointed at a **sibling `.ufo/waves/` body** | `FAILED` | `FAILED` | `FAILED` |
| 25 | **normalizer stub** (count=1 always; digest echoes the row's own col 15) | **`CLEAN`** | **`CLEAN`** | **`CLEAN`** |
| 26 | normalizer stub **+ a quote absent from the body** | **`CLEAN`** (`located=37` — the stub's `count=1` satisfies it) | **`CLEAN`** | **`CLEAN`** |

### 2.1 The round's three routed defects are closed at the gate; two residual classes are not

The round-67 closure routed three defects (`.ufo/waves/round-67/w1/R67Revenger.md`
§3, `corpus/lessons/round-67-verifier-spotcheck.md` §Routed defects 1–3).
Measured on the landed widened gate:

- **Routed 1 (prose escape hatch)** — closed for whitespace, comma-join and
  whole-file CRLF (rows 12–14 above: BASE `CLEAN`, widened `FAILED`). The
  BASE gate's whole-file-CRLF reading was `path_rows=0 bound=0 located=0
  prose=157` — every row became prose and the binding was entirely
  disengaged; the widened gate refuses the file at file level.
- **Routed 2 (col 15 never recomputed)** — closed (row 16: BASE `CLEAN`,
  widened `FAILED` `normalized-digest-mismatch`).
- **Routed 3 (S166's own capture outside the population)** — closed by the
  re-cut: S166's col 16 is now the pure path, and the row binds
  (`path_rows=38 bound=38 located=38` on the lane at R4).

**Not closed, and the plan names one of them as a ceiling:**

- **The hardlink class (row 2) survives every revision.** An in-tree hardlink
  to an out-of-tree body with the same bytes binds and reads `CLEAN`; the
  attested bytes can then change from outside the tree, and only a *second*
  run sees it. This is round-67's `C2` and the plan's stated ceiling
  ("hardlink durability (C2 of the revenger) … stay ceilings"). **Severity:
  medium, accepted ceiling, point-in-time by design.** The smallest
  remediation is a `stat -c %h` check per bound row, but the reason set is
  frozen this round, so it belongs to a later round's reason set, not here.
- **The truthy-normalizer class (rows 25–26) survives every revision,
  including the widened one.** A tree that ships a `corpus/rendered-text-v1.py`
  whose `locate` answers `count=1` for anything and whose `digest` echoes the
  row's own col 15 reads `CLEAN` **even when the declared quote is absent from
  the body** (row 26: `located=38` on a tree whose quote does not exist in its
  body). This is round-67's `C4`.

## 3. The normalizer boundary (asked for explicitly)

> *"replace `corpus/rendered-text-v1.py` in a scratch copy with a stub that
> answers count=1 and a digest equal to the row's col 15 — does the gate read
> CLEAN?"*

**Yes. The gate reads `CLEAN`.** Measured on the landed widened gate:

```
construction: corpus/rendered-text-v1.py replaced by a stub that answers
  locate→count=1 for any file and digest→ the row's OWN col 15 (read out of
  the tree's own corpus/source-fetches.tsv)
LANE gate rc=0
SOURCES_CAPTURES: CLEAN (path_rows=38 bound=38 located=38 prose=120)
SOURCES_CENSUS: CLEAN (rows=158 …)

with the same stub AND col 13 replaced by "zzz absent phrase zzz":
LANE gate rc=0
SOURCES_CAPTURES: CLEAN (path_rows=38 bound=38 located=38 prose=120)
SOURCES_CENSUS: CLEAN (rows=158 …)
```

**Which guard should bind it, and is it counter-only?**

The plan says so itself, in its *Bounds* section: *"a gate cannot vouch for
itself (C4's normalizer-tamper class stays counter-guarded, never
gate-guarded)."* **That is correct and this is the accepted ceiling.** The
gate cannot bind this class: the gate is the thing being audited, and the
instrument it trusts (`CAP_NORM`) is a file inside the audited tree. Any gate
rule that reads the tree's own normalizer is satisfied by a tree that ships a
truthy one. This is round-67's `C4` and it is **explicitly accepted by the
frozen plan**.

**The binding guard is the counter's, and it already exists in the round-67
counter.** Measured (`receipts/counter-guards.txt`, G2):

```
=== G2 the tree's normalizer is a TRUTHY STUB ===
rc=1 C1_READTHROUGH: bound=37 located=37 caught=5/6 guard=0
   c1-readthrough: guard-f candidate=045edcb02f2baace base=14f6ca6ab742296f verdict=DIFFERS
```

Guard **(f)** — *instrument identity* — fires: the candidate's
`corpus/rendered-text-v1.py` hashes differently from the BASE copy, so
`guard=0` and the counter exits 1. The same class also drops `caught` from
`6/6` to `5/6` (the quote leg stops being caught), which is a second,
independent signal.

**And measured against the LANDED round-68 counter, the class is bound.** The
landed counter's guard list is (a)–(e) — there is **no instrument-identity
leg** in the frozen plan's guard list, so the binding here is different in
kind: it is the **M5 mutation leg**. Measured live (`receipts/forgery-proof-live.txt`):

```
tree = lane tree with ONLY corpus/rendered-text-v1.py stubbed:
  c1-verified: derived verified=38 col15=33 path_rows=38 bound=38 located=38 prose=120 mixed=none total=158 malformed=0
  c1-verified: guard-a verdict=CLEAN rc=0 ... gate_fields=match adjacent=True
  c1-verified: mut-m5 id=S167 reasons=none crlf=0 verdict=CLEAN rc=0 ... detail=col15-hexflip
  c1-verified: guard a=1 b=0 c=0 d=skip e=1 defe defects=0
  C1_VERIFIED: verified=38 col15=33 caught=5/6 guard=0

CONTROL — the same tree with the trusted normalizer restored:
  c1-verified: guard-b selftest rc=0 cases=98
  c1-verified: mut-m5 id=S167 reasons=S167:normalized-digest-mismatch crlf=0 verdict=FAILED rc=1 ... detail=col15-hexflip
  C1_VERIFIED: verified=38 col15=33 caught=6/6 guard=0
```

**The counter is not fooled.** With the stub, `caught` drops 6/6 → 5/6 and
`guard` reads 0; with the trusted normalizer restored, `caught` reads 6/6.
The mechanism is the M5 leg: with the stub the gate reads the col-15 mutation
as `CLEAN` (`reasons=none`), so the leg is not counted. Guard (b) also
fires, because the tree's own selftest breaks on the stub.

**Critically, the counter's own derivation stayed honest.** Its
`locator_script()` prefers `BASE_TREE`, then `LANE`, and only falls back to
`TREE` — so with no `--base-tree` it resolved to the **lane's** copy, and the
counter's `verified=38 col15=33` was computed with the trusted instrument even
while the gate read the tree's stub. That fallback order is correct and
should be kept.

**Severity: accepted ceiling, and now measured as bound.** The smallest
remediation is **none in the gate** — it is not fixable there, and the plan
says so. The round's record should state *how* the class is bound (the M5
mutation leg, plus guard (b)) rather than implying an identity guard exists:
the round-68 plan's frozen guard list (a)–(e) has none, whereas the
round-67 counter had guard (f). A reader who checks the plan for a guard (f)
will not find one.

## 4. Receipt and evidence forgery (asked for explicitly)

> *"can a seat make the counter print `guard=1` while its own scratch tree was
> never measured (e.g. an env var, a PATH shim, a stray `SOURCES_CAPTURES:`
> line in the tree)?"*

Measured on the round-67 counter (the only counter in the tree; the round-68
counter does not exist yet — `plans/round-68-c1.sh` is absent), plus the
landed gate. Full output: `receipts/counter-guards.txt`, `receipts/forgery-detail.txt`.

### 4.1 Env var — **not forgeable**

Six env vars were swept, each set to a value that would make a naive counter
pass (`SOURCES_CAPTURES`, `SOURCES_CENSUS`, `GUARD=1`,
`C1_VERIFIED=verified=37 col15=32 caught=6/6 guard=1`, `HYAKU_SCRATCH`,
`C1_KEEP_SCRATCH`). Every one produced the **identical** verdict line:

```
env HYAKU_SCRATCH=…                 -> rc=1 verdict=C1_READTHROUGH: bound=37 located=37 caught=6/6 guard=0
env C1_KEEP_SCRATCH=1               -> rc=1 verdict=C1_READTHROUGH: bound=37 located=37 caught=6/6 guard=0
env SOURCES_CAPTURES=CLEAN (…)      -> rc=1 verdict=C1_READTHROUGH: bound=37 located=37 caught=6/6 guard=0
env SOURCES_CENSUS=CLEAN (rows=157) -> rc=1 verdict=C1_READTHROUGH: bound=37 located=37 caught=6/6 guard=0
env GUARD=1                         -> rc=1 verdict=C1_READTHROUGH: bound=37 located=37 caught=6/6 guard=0
env C1_VERIFIED=… guard=1           -> rc=1 verdict=C1_READTHROUGH: bound=37 located=37 caught=6/6 guard=0
```

The counter reads no verdict-controlling environment variable. **Severity:
none.**

### 4.2 PATH shim — **not forgeable, but the mechanism is worth naming**

- **A `python3` shim** that answers every `locate` with `count=1` makes the
  **gate** print `SOURCES_CENSUS: SETUP (rendered-text-v1 output unexpected)`
  and exit 2 — the shim's output does not match the expected shape, and the
  gate's `cap_locate` fails closed. The shim cannot make the gate read CLEAN.
- **A `bash` shim** that fakes a clean gate run makes the counter read
  `caught=0/6 guard=0` and exit 1: the counter's own derivation is computed
  in-process and cross-checked against the gate's stdout, so a faked gate
  output fails the cross-check.

**Severity: none.** But note the *shape* of the defence: the counter's
protection here is that its derivation is **independent** of the gate's
stdout, not that the gate is trusted. The round-68 counter must preserve
that independence for the col-15 count.

### 4.3 A stray `SOURCES_CAPTURES:` line in the tree — **the one live forgery class**

This is the class that works, and it works because the gate's findings carry
**tree-controlled text** into stdout.

**Construction.** A file in `corpus/knowledge/` whose *name* contains a
newline and a forged summary line. The gate's `SC_ENTRY_CITE` finding prints
the entry's relative path, so the newline in the name becomes a newline in
stdout:

```
corpus/knowledge/evil
FINDING SC_CAPTURE id=S167 capture-digest-mismatch
SOURCES_CAPTURES: FAILED (defects=1 path_rows=38 bound=37 located=37 prose=120)
SOURCES_CENSUS: FAILED (findings=1 rows=158).md
```

Measured stdout of the landed gate on that tree:

```
FINDING SC_CAPTURE id=S167 capture-digest-mismatch
SOURCES_CAPTURES: FAILED (defects=1 path_rows=38 bound=37 located=37 prose=120)
SOURCES_CENSUS: FAILED (findings=1 rows=158).md id=S001 used-by-omits-entry
SOURCES_CAPTURES: CLEAN (path_rows=38 bound=38 located=38 prose=120)
SOURCES_CENSUS: FAILED (findings=1 rows=158)
```

**The forgery works — but only against a counter that checks the reason alone.**
I decomposed the round-67 counter's `parse_gate_run` + `leg_caught` and fed
it the captured stdout of the injected tree (`receipts/parse_probe.py`):

```
=== DECOMPOSITION: which defence stops the injection? ===

(1) NAIVE reason-grep only (no cross-check):
    grep '^FINDING SC_CAPTURE id=S167 capture-digest-mismatch$' -> True
    => a leg whose check is ONLY the reason grep reads CAUGHT on a tree
       whose gate found nothing.  THE INJECTION FORGES A CATCH.

(2) summary 'defects' == len(findings) cross-check:
    gate's own summary state = CLEAN (no 'defects' field) -> None
    len(findings) = 1
    None != 1 -> leg refused

(3) last-match summary/verdict parsing:
    SOURCES_CAPTURES: lines seen = 2 -> counter reads the LAST:
       SOURCES_CAPTURES: CLEAN (path_rows=38 bound=38 located=38 prose=120)
    SOURCES_CENSUS:   lines seen = 2 -> counter reads the LAST:
       SOURCES_CENSUS: FAILED (findings=1 rows=158)

=> the injection is stopped ONLY by (2) and (3). (1) alone is fooled.
```

Read that precisely: **a leg whose acceptance test is only "does a line
`FINDING SC_CAPTURE id=<target> <reason>` appear in stdout" is fully
forgeable by a filename.** The round-67 counter happens to refuse it, and it
refuses it for two reasons that are *not* the reason a reader would expect:
the summary-state/`defects` cross-check (2), and last-match parsing (3). Both
are incidental properties of that file's implementation, not stated
requirements of the frozen predicate.

**Severity: HIGH for a counter that does not carry both defences.** The
round-68 counter is a *new* file (`plans/round-68-c1.sh`, R68ExecCounterC1's)
and its reason set is *wider* — `capture-whitespace`, `capture-token` and
`normalized-digest-mismatch` are three new reason strings to match — so it
has strictly more lines to mis-parse than round 67 did, and the frozen
predicate's own six-leg table gives each leg a *specific expected reason*,
which is exactly the shape the injection forges.

### 4.3a THE FORGERY IS REAL — I PROVED IT AGAINST THE LANDED COUNTER

The round-68 counter landed (`plans/round-68-c1.sh`, sha
`4461be43…`) while this seat was finishing. Its `leg_caught` was, at that
byte-state, exactly the vulnerable shape:

```python
def leg_caught(parsed, kind, anchor_id):
    if not (parsed["rc"] == 1 and parsed["verdict"] == "FAILED"):
        return False
    if kind == "m3":
        return len(parsed["crlf_findings"]) >= 1
    reason = EXPECT_CAPTURE[kind]
    return any(fid == anchor_id and why == reason
               for (fid, why) in parsed["cap_findings"])
```

**I built the attack tree and ran it against that counter.** The tree is the
lane's tree with two changes and nothing else: (1) a truthy
`corpus/rendered-text-v1.py` (so the gate can never detect a col-15
mismatch), and (2) one file in `corpus/knowledge/` whose *name* carries
newlines and four forged `FINDING SC_CAPTURE id=S167 …` lines plus a forged
`FINDING SC_FETCH cr-in-tsv`. The gate's own stdout on that tree:

```
FINDING SC_ENTRY_CITE entry=corpus/knowledge/e
FINDING SC_CAPTURE id=S167 capture-whitespace
FINDING SC_CAPTURE id=S167 capture-digest-mismatch
FINDING SC_CAPTURE id=S167 capture-bytes-mismatch
FINDING SC_CAPTURE id=S167 normalized-digest-mismatch
FINDING SC_FETCH cr-in-tsv
SOURCES_CAPTURES: CLEAN (path_rows=38 bound=38 located=38 prose=120)
SOURCES_CENSUS: FAILED (findings=1 rows=158)
```

Replaying the counter's own `leg_caught` over that stdout, **all six legs
forge as CAUGHT**:

```
cap_findings parsed: [('S167','capture-whitespace'), ('S167','capture-digest-mismatch'),
                       ('S167','capture-bytes-mismatch'), ('S167','normalized-digest-mismatch')]
verdict (LAST)     : FAILED
summary (LAST)     : {'state': 'CLEAN', …}
  m1 -> True    m2 -> True    m3 -> True
  m4 -> True    m5 -> True    m6 -> True
```

**The attack works.** A tree can make the counter read `caught=6/6` on six
mutations the gate never actually caught, by shipping one filename.

**And the counter seat fixed it, crediting this finding by name.** The
counter at sha `4461be43…` (later revised) now carries every cross-check this
seat specified, with the comment *"Forgery resistance (R68Sentinel)"*:

```python
def leg_caught(parsed, kind, anchor_id):
    if not (parsed["rc"] == 1 and parsed["verdict"] == "FAILED"):
        return False
    if parsed["verdict_findings"] is None:
        return False
    if parsed["verdict_findings"] != parsed["all_findings"]:
        return False
    if parsed["summary"] is not None and parsed["summary"]["state"] == "FAILED":
        if parsed["summary"]["fields"].get("defects") != len(parsed["cap_findings"]):
            return False
    …
```

**Severity: HIGH (now closed at the counter, unclosed at the gate).** The
counter is defended; **the gate still prints the forged lines.** A gate-side
one-line hardening remains available and is the smaller, more durable fix —
escape the newline in the `SC_ENTRY_CITE` detail (`printf %q`, or
`tr '\n' ' '`) — which removes the primitive at its root and protects every
future consumer of this gate's stdout, not just this round's counter. I have
offered it to R68ExecGate. **Recommendation to the L1: treat the gate-side
escape as still-open**, because the counter's defence is a property of one
consumer's parser rather than of the gate.

**The two cross-checks exist and hold — I verified them on the landed gate's
own output.** On a tree made to fail (col 10 of the anchor zeroed):

```
FINDING lines printed: 1 | verdict says findings= 1     EQUAL? True
SC_CAPTURE lines: 1      | summary defects= 1            EQUAL? True
```

The gate's `finding()` increments its counter once per printed line
(`finding() { printf 'FINDING %s %s\n' "$1" "$2"; FINDINGS=$((FINDINGS + 1)); }`),
so `SOURCES_CENSUS: FAILED (findings=K …)` always equals the number of
`FINDING` lines, and `SOURCES_CAPTURES: FAILED (defects=N …)` always equals
the number of `FINDING SC_CAPTURE` lines. **Both equalities break the moment
a line is injected** — the injected line raises the line count above the
gate's own count without raising the gate's counter. That is the cheapest
possible cross-check for the counter to carry, and it is what makes the
injection detectable at all.

**Smallest remediation (counter-side, one line each) — now implemented:**
1. require the summary's `defects` to equal the number of `FINDING SC_CAPTURE`
   lines **and** the verdict's `findings=N` to equal the number of `FINDING`
   lines;
2. parse the summary and the verdict as the **last** matching line of stdout
   (or better: the line immediately preceding the verdict), not the first;
3. bind each leg's expected reason to the **mutated id** *and* require the
   finding to be counted in the verdict's own `findings=N`.

### 4.4 A constant-printer gate — **refused**

A tree whose `corpus/sources-census.sh` prints the CLEAN line and exits 0
without reading a byte:

```
=== G1 the tree's gate is a CONSTANT PRINTER (prints CLEAN, reads nothing) ===
rc=1 C1_READTHROUGH: bound=37 located=37 caught=0/6 guard=0
```

`caught` collapses to `0/6` and the counter refuses. The round-68 plan's kill
rule ("a count produced by a constant printer … is refused by guard (c) and by
the mutation legs") is satisfied by the existing instrument.

### 4.5 The one forgery the counter *cannot* see

A gate that is a constant printer **plus** a truthy normalizer (G3) still
reads `caught=0/6 guard=0`, and the counter's own derivation reports a
`derived-defect S167 capture-missing` — the counter notices on its own. This is
the right behaviour: the counter's derivation is the witness.

## 5. The calibration conflict — the most consequential finding

This is a **C2 (calibration)** finding, and it is the one the sentinel's axes
weigh most.

### 5.1 The frozen predicate's numbers do not match the tree

`plans/round-68.md` §C1 freezes:

```
C1_VERIFIED: verified=37 col15=32 caught=6/6 guard=1
```

and states the move is *"BASE verified=36 col15=31 → verified=37 col15=32"*,
with *"S166's row, re-cut to the pure path `.ufo/waves/round-67/capture/S166.body`,
is the +1."*

Measured on the tree as it stands:

| tree | verified | col15 | prose | defects |
|---|---|---|---|---|
| BASE (`d3b2a4e`), **strict** reading | 36 | 31 | 120 | 1 |
| BASE, permissive reading | 37 | 32 | 120 | 0 |
| lane worktree (R4, S166 re-cut **and S167 added**) | **38** | **33** | 120 | 0 |

The BASE numbers depend on which reading of `verified` is used, and the plan
does not say which. Under the plan's own *classification rule* ("a `col16`
cell is **legal** iff it either names no `.ufo/waves/` whitespace-delimited
token at all (frozen `prose`, never read) or is exactly one such path with no
other content (frozen `path`, read and bound)"), BASE's S166 cell — the
mixed prose `"§1.2 Concept Overview; capture .ufo/waves/round-67/capture/S166.body"` —
names a `.ufo/waves/` token and is **not** exactly that path, so it is a
**defect**, not prose: BASE `verified=36`. Under a permissive reading (bind
the first `.ufo/waves/` token wherever it appears) BASE already reads 37, and
the "+1" the plan attributes to the S166 re-cut does not exist.

**Both readings are defensible; the plan does not choose, and the frozen
predicate's `verified=37` is only reachable under the permissive reading.**

### 5.2 The +1 is already spent — and a second +1 arrived

The plan attributes the +1 to S166's re-cut. But the wave also landed **S167**
(the plan's own frontier step: *"One source opened this round … **S167** … One
row admitted, tier A if the § is primary, `mined`, `checked-out-side
capture`"*). S167's row is in `corpus/source-fetches.tsv` with
col 16 = `.ufo/waves/round-68/capture/S167.body` — a **pure path**, so it is
in the population. Measured on the lane at R4:

```
SOURCES_CAPTURES: CLEAN (path_rows=38 bound=38 located=38 prose=120)
```

**38, not 37.** The lane's own gate reads `path_rows=38`, and an independent
derivation (my own code, not the gate's) reads `verified=38 col15=33`.

So the frozen predicate `verified=37 col15=32` is **not reachable on the tree
the wave produced**: the frontier step the plan itself mandates adds a capture
row, and the S166 re-cut adds another. The plan's §C1 arithmetic
("S166's row … is the +1") was written before S167 landed, and the plan's own
target was measured against a 37-row population that no longer exists.

**This is not an implementation defect. It is a frozen-predicate/tree
mismatch, and it is exactly the class the round-67 revenger named `C0` for
S166 and the round-67 lesson named the QM90 class.** The counter cannot
resolve it: the plan says *"The counter may not hard-code any of the three
numbers"* and the kill rule is *"the target is missed if `verified < 37`"* —
`38 ≥ 37` passes the kill rule, but the **frozen final line** the counter
must print is `verified=37 col15=32`, and a counter that prints its derived
`38`/`33` will not match the frozen predicate string.

**Severity: HIGH — a claim-calibration defect that will surface at the
counter's exit.** This is a plan-vs-tree arithmetic conflict, not a gate
bug, and the plan is frozen: **the L1 (KagiR68) must reconcile it.** The
smallest reconciliation, without amending a predicate, is to state in the
round's record that the frozen numbers were pinned against the pre-S167
population and that the derived numbers on the landed tree are
`verified=38 col15=33` — with the counter's line carrying the *derived*
values, and the plan's frozen `verified=37 col15=32` recorded as the
pre-S167 baseline. **The counter must not hard-code 37/32 to match the
string**, because the plan forbids it and because hard-coding is the
constant-printer failure the round's own guard (c) exists to catch.

### 5.3 The BASE blindness witness is 2/6, not 0/6

The plan's motivating evidence says the six legs are the round's blind
classes, and the claim summary states *"BASE … caught=0/6"*. Measured on the
BASE gate (`e7aacecd`) over the BASE tree with the plan's six legs and the
plan's anchor derivation (`receipts/base-legs.txt`):

```
BASE anchor (LAST capture-path-shaped row that binds): line 199 id=S156
M1 col16 trailing space      rc=0 expected=capture-whitespace           SURVIVED
M2 col16 comma-joined        rc=0 expected=capture-whitespace           SURVIVED
M3 whole TSV CRLF            rc=0 expected=SC_FETCH cr-in-tsv           SURVIVED
M4 col10 hex digit           rc=1 expected=capture-digest-mismatch      CAUGHT
M5 col15 borrowed digest     rc=0 expected=normalized-digest-mismatch   SURVIVED
M6 body +1 byte              rc=1 expected=capture-bytes-mismatch       CAUGHT
BASE caught = 2/6 (the plan's motivating evidence claims 0/6)
```

M4 and M6 are caught by the **BASE** gate — they are round-67 classes, not
round-68 ones. The plan's six legs mix four round-68 classes (M1, M2, M3, M5)
with two round-67 classes (M4, M6) that the BASE gate already caught. **A
counter that expects `caught=6/6` against a gate that catches 4/6 of the
round-68 classes plus 2/6 of the round-67 ones is fine; a counter that
reports the BASE blindness witness as `0/6` is not.** The plan's own guard
(c) — "the BASE gate on the escaped-CRLF copy prints `SOURCES_CENSUS: CLEAN`"
— is measured true (M3 above: BASE reads `CLEAN` with `path_rows=0`), so the
guard as written is satisfied. But the *claim summary's* "caught=0/6" is
wrong and must not be copied into the round record.

**Severity: MEDIUM (calibration of the round's own record).** Smallest
remediation: the round's claim text states the BASE blindness witness as
**2/6 on the plan's six legs, of which the four round-68 classes (M1, M2, M3,
M5) are the blind ones** — the guard (c) witness stays the CRLF copy.

## 6. The gate's own selftest is RED — a live blocker for guard (b)

The plan's guard (b) requires: *"`bash corpus/sources-census.sh --selftest`
exits 0 printing `SOURCES_CENSUS_SELFTEST: PASS (N cases)` with `N >= 89`"*.

**Measured on the landed gate in the lane worktree: it exits 1 and prints
`FAIL`.** The reading improved as R68ExecGate worked, but it has not gone
green during this seat:

| byte-state | selftest reading |
|---|---|
| `R3` (`fd3cb598…`) | `SOURCES_CENSUS_SELFTEST: FAIL (98 cases, 3 failed)` |
| `R4` (`6f18c608…`) | `SOURCES_CENSUS_SELFTEST: FAIL (98 cases, 2 failed)` |
| `R5` (`84725a7e…`, last observed) | `SOURCES_CENSUS_SELFTEST: FAIL (98 cases, 1 failed)` |

The three cases that were red at `R3`:

```
case capture-symlink-escape: FAIL (exit 1 want 1; want SC_CAPTURE findings=1; last=SOURCES_CENSUS: FAILED (findings=1 rows=4))
case capture-whitespace-cr:  FAIL (exit 1 want 1; want SC_CAPTURE findings=1; last=SOURCES_CENSUS: FAILED (findings=1 rows=4))
case capture-token-slashslash: FAIL (exit 1 want 1; want SC_CAPTURE findings=1; last=SOURCES_CENSUS: FAILED (findings=1 rows=4))
```

At `R5` the survivor is `capture-token-slashslash` alone.

I instrumented a copy of the gate (adding a `DEBUGOUT` dump on failure — the
instrumented copy lived only in scratch) and reproduced each case by hand
against the `R3` bytes:

**`capture-whitespace-cr`** — the fixture writes `col16 = <path> + CR`, and the
gate strips a trailing CR from the location (`floc=${floc%$'\r'}`) and fires
the **file-level** `SC_FETCH cr-in-tsv` instead. The selftest expects an
`SC_CAPTURE … capture-whitespace` finding:

```
FINDING SC_FETCH cr-in-tsv
SOURCES_CAPTURES: CLEAN (path_rows=1 bound=1 located=1 prose=3)
SOURCES_CENSUS: FAILED (findings=1 rows=4)
```

The gate's behaviour is *defensible* — the plan freezes a file-level
`SC_FETCH cr-in-tsv` precisely so that a CR anywhere is caught once — but the
case still expects the cell-level reason. (At `R4` this case's expected
`findings` count was raised to `2`, and at `R5` it passes: R68ExecGate
resolved it.)

**`capture-token-slashslash`** — the fixture writes
`col16 = //.ufo/waves/round-00/capture/c1.body`. The case table's `xreason`
field says `capture-token` (`corpus/sources-census.sh:1030` at `R5`), while
the gate emits `capture-outside-root`:

```
FINDING SC_CAPTURE id=S001 capture-outside-root
SOURCES_CAPTURES: FAILED (defects=1 path_rows=1 bound=0 located=0 prose=3)
SOURCES_CENSUS: FAILED (findings=1 rows=4)
```

**The case table and the gate disagree about which reason a `//`-form
location produces.** The gate's own classifier treats a leading `//` as an
absolute location (`[[ $loc == /* ]]` → `path` → `capture-outside-root`);
the case expects the `capture-token` reason that the plan's prose gives the
`~/` and `//` forms. One of the two is wrong and the round must choose
deliberately — it is not a cosmetic difference: the plan's frozen reason set
lists `capture-token` as covering *"a `~/` or `//` form"*, so the **case
table** states the plan's intent and the **gate** implements a different
classification. This is the survivor at `R5`.

**`capture-symlink-escape`** — the fixture writes the symlink target one level
too shallow (`../../../../` from `.ufo/waves/round-00/capture/` reaches the
tree root, not outside it), so the link resolves *inside* the tree to a
**nonexistent** file and the gate correctly reports `capture-missing`, not
`capture-outside-root`. Measured:

```
=== CASE capture-symlink-escape ===
FINDING SC_CAPTURE id=S001 capture-missing
SOURCES_CAPTURES: FAILED (defects=1 path_rows=1 bound=0 located=0 prose=3)
```

with the depth arithmetic verified separately: four `..` from
`.ufo/waves/round-00/capture/` resolves to the tree root (inside), five
resolves outside. **The gate's logic is right; the fixture's depth is wrong.**
(At `R4`/`R5` this case passes — the fixture was corrected.)

**Severity: HIGH — a live blocker.** Guard (b) of the frozen predicate was
failing on every byte-state observed during this seat. This is the executor's
file (`corpus/sources-census.sh`, R68ExecGate's), so the fix is
R68ExecGate's to make, but it must be made before the counter can read
`guard=1`. Two of the three failures were **fixture** defects (the symlink
depth; the CR case expecting the cell-level reason where the gate reports the
file-level one); the third is a **case-table vs gate** reason disagreement
on the `//`-form, which is a real decision the round has to make. **None of
them is a binding defect: every mutation the selftest names is correctly
refused by the gate.** The gate is right and its own expectations were wrong
— which is the cheapest kind of failure to fix and the most embarrassing to
leave red, because the round's guard (b) is exactly the check that would have
caught it.

**The re-measurement the L1 should run before the counter:** the selftest
must read `SOURCES_CENSUS_SELFTEST: PASS (98 cases)` and exit 0 **on the
committed bytes**, and the `//`-form's reason must be settled in the plan or
in the case table — not left as a disagreement between them.

## 7. The population-narrowing fail-open (a genuine trade the plan does not price)

This is a class the plan's own rule creates, and it is the one a future round
should price.

The widened rule redefines `prose` as *"names no `.ufo/waves/` whitespace-
delimited token"*. The round-67 gate's population was *"any path-shaped
location"*. The widened population is therefore **narrower**. A bound row
re-pointed at a path that carries no `.ufo/waves/` token leaves the
population entirely:

```
construction: col16 = "corpus/knowledge/source-capture-binding.md"
BASE gate      rc=1  SOURCES_CAPTURES: FAILED (defects=2 path_rows=37 bound=36 located=36 prose=120)
landed widened rc=0  SOURCES_CAPTURES: CLEAN (path_rows=37 bound=37 located=37 prose=121)
reference      rc=0  SOURCES_CAPTURES: CLEAN (path_rows=37 bound=37 located=37 prose=121)
```

**The BASE gate caught the re-point (the row's bytes no longer match the
declared digest). The widened gate does not: the row silently becomes prose,
the capture it used to name is no longer bound, and the summary reports
`prose=121` — one row quietly dropped from the checked population with no
finding.**

**Severity: MEDIUM.** Two mitigations already exist, and the second is the
one that matters:

- The plan's C1 `verified` definition is *"rows whose col 16 is a repo-relative
  capture path **or** whose col 16 contains a whitespace-delimited token that
  is a repo-relative `.ufo/waves/` capture path"* — the **first** disjunct
  keeps path-shaped non-`.ufo/waves/` rows in the *counter's* population even
  though the gate drops them. The counter's derivation therefore covers what
  the gate does not. **The counter must use the plan's two-disjunct
  definition, not the gate's narrower one**, or the counter will agree with the
  gate on a tree where a capture is unbound.
- The plan's guard (a) requires *"the gate's four counts equal to this
  counter's derivation"*. If the counter derives under the two-disjunct
  definition and the gate counts under the narrower one, the two counts
  differ on any tree with a re-pointed row, and **guard (a) fails** — the
  contradiction is caught. That is the right shape: the counter is the
  witness. But it means **the counter and the gate must implement different
  populations on purpose**, and the counter seat needs to know that, because
  implementing them the same way is what makes the re-point invisible to both.

## 8. The classifier boundary: `contains` vs `prefix`

The plan's frozen classification rule is *"names no `.ufo/waves/`
whitespace-delimited token"*, and its reason set names `capture-token` as
covering *"a `~/` or `//` form"*. Those two sentences force a specific
reading: the token test must be a **contains** test (a token *containing*
`.ufo/waves/`), not a prefix test (a token *starting with* `.ufo/waves/`).

```
'~/.ufo/waves/round-67/capture/S166.body'   contains=True  prefix=False
'//.ufo/waves/round-67/capture/S166.body'   contains=True  prefix=False
'./.ufo/waves/round-67/capture/S166.body'   contains=True  prefix=False
'.ufo//waves/round-67/capture/S166.body'    contains=False prefix=False
```

Measured difference between the two readings of the *reference* gate on the
same tree:

| construction | REF `contains` | REF `prefix` |
|---|---|---|
| col16 = `~/`+path | `FAILED` `capture-token` | **`CLEAN`** |
| col16 = `//`+path | `FAILED` `capture-token` | **`CLEAN`** |
| col16 = `../`+path | `FAILED` `capture-token` | **`CLEAN`** |

Under a **prefix** reading the `~/` and `//` forms are prose and are never
read — the exact round-67 `C1` escape the round claims to close, reintroduced
through the classifier.

**Severity: HIGH if the landed gate uses the prefix reading; none if it uses
the contains reading.** The landed gate as measured uses a **contains** test
(`case $tok in *".ufo/waves/"*)`), and its `~/`-form and mixed-prose cases
produce `capture-token` — **the landed gate is on the correct side of this
boundary.** This finding is therefore recorded as a *pin*, not a defect: the
selftest cases `capture-token-tilde` and `capture-token-mixed-prose` are what
hold it there, and they must not be removed or weakened. The `//`-form case
(`capture-token-slashslash`) is currently failing for an unrelated reason
(§6) and, while it is red, the `//`-form's classification is unpinned.

## 9. The NUL-byte class (a gap neither the plan nor the revenger closed)

Both the BASE gate and the landed widened gate read `CLEAN` on a TSV
containing a NUL byte, and on a col 16 ending in a NUL byte:

```
nul-byte-in-col16   LANE rc=0  SOURCES_CAPTURES: CLEAN (path_rows=38 bound=38 located=38 prose=120)
nul-byte-in-tsv     LANE rc=0  SOURCES_CAPTURES: CLEAN (path_rows=38 bound=38 located=38 prose=120)
```

**Why it is invisible.** The reason is a reader divergence, measured
byte-exactly:

| reader | a row whose col 16 is `f16<NUL>TAIL` |
|---|---|
| GNU awk 5.4.1 `-F'\t'` | `NF=16`, `$16` = `f16\x00TAIL` (NUL **preserved**) |
| bash `read -r` (16 vars) | `$16` = `f16TAIL` (NUL **silently dropped**) |

The gate's row loop is a bash `while IFS=$'\t' read -r …` loop, so the NUL
is dropped before the cell is classified — the cell arrives as the clean path.
The plan's file-level check is `SC_FETCH cr-in-tsv`, a **CR** check; there is
no NUL counterpart. A NUL byte is not whitespace and not a CR, so it does not
trigger `capture-whitespace`, and it is not a legal path character, so it does
not make the cell non-shaped.

**Severity: LOW–MEDIUM.** The practical effect is narrow: the NUL is dropped
by the reader, so the cell is *bound as if it were the clean path* — the
declared bytes are still checked. The residue is that the row on disk and the
row as the gate reads it are **not the same bytes**, and a byte-level auditor
reading the TSV with a NUL-preserving reader (as any future counter written
in Python would) sees a different col 16 than the gate does. That is a
divergence between the instrument and the file, which is the class the round
is about.

**Smallest remediation:** a file-level NUL check alongside the CR check
(`grep -q $'\0'`), or make the file-level check cover both bytes. The reason
set is frozen this round, so this belongs to a later round's reason set —
but it should be *named* in the round's ceiling list so it is not
rediscovered as a surprise.

## 10. The boundary that stays — confirmed

Read on the landed gate's executable lines (comments excluded):

- **No credential material is read.** The only files the gate opens are
  `corpus/SOURCES.md`, `corpus/knowledge/*.md`, `corpus/source-fetches.tsv`,
  `corpus/inrow-pins.tsv`, the capture bodies its own rows name, and its
  sibling `rendered-text-v1.py`. The credential scan
  (`cred_scan`) runs over `SOURCES.md` and the knowledge entries only and
  prints **`file:line` only** — never the matched bytes:
  `while IFS= read -r n; do finding SC_CREDENTIAL "$2:$n"; done < <(grep -nE -- "$CRED_RE" "$1" | cut -d: -f1)`.
  No `op`, `vault`, `openbao` or `sops` invocation appears in any executable
  line; the tokens `op`, `gh`, `curl` and `vault` occur **only inside the
  credential-needle fragments and the request-profile string literal**
  (`curl-fsSL-compressed-v1`), which are compared, never executed.
- **No vault contact.** Nothing in the gate opens a vault, a session, or a
  credential store. The knowledge entries it reads *describe* vault surfaces
  in prose; the gate never touches one.
- **No network.** No `curl`, `wget`, `nc`, `ssh` or `git` invocation in any
  executable line. The gate is a pure function of committed bytes.
- **Nothing that would have crossed it, and nothing came close.** The one
  place where untrusted bytes meet stdout is the finding detail (§4.3), and
  the bytes that flow there are **paths and ids from the tree's own files** —
  not credentials, not capture bodies, not network material. The capture
  bodies are read for `sha256sum` and `stat` only; their content is never
  printed, only their digests and byte counts.

**Severity: none — this boundary holds.** It is recorded because the round
widened what the gate *reads* (more capture bodies, more cells) and the
question "does the widened gate touch anything it should not?" deserves an
explicit, measured answer.

## 11. Findings, ranked

| # | finding | severity | where it binds |
|---|---|---|---|
| **F1** | The frozen predicate `verified=37 col15=32` is unreachable on the landed tree: the wave's own frontier step (S167) added a capture row, and the lane's gate reads `path_rows=38 bound=38 located=38`, independently derived `verified=38 col15=33`. The plan's "+1 is S166's re-cut" arithmetic is pre-S167. | **HIGH** (calibration) | L1 KagiR68 — the record must state the pre-S167 baseline and the derived numbers; the counter must print derived values, never hard-code 37/32. |
| **F2** | The landed gate's own `--selftest` exits 1 with `FAIL` — `3 failed` at `R3`, `2 failed` at `R4`, `1 failed` (`capture-token-slashslash`) at `R5`, the last observed. Guard (b) of the frozen predicate was therefore failing on every byte-state observed. The failures were **fixture/case-table** defects (symlink depth off by one; the CR case expecting the cell-level reason where the gate reports the file-level one; the `//`-form's expected reason disagreeing with the gate). The gate's binding logic is correct in every case. | **HIGH** (blocks guard (b)) | R68ExecGate — fix the fixtures/case table, not the binding; re-measure the selftest on the committed bytes. |
| **F3** | A tree-controlled **filename** in `corpus/knowledge/` injects forged `FINDING SC_CAPTURE …` / `SOURCES_CAPTURES: …` / `SOURCES_CENSUS: …` lines into the gate's stdout. **Proved live against the landed round-68 counter**: on an attack tree (truthy normalizer + one injecting filename) the pre-fix `leg_caught` read **all six legs as CAUGHT**. The counter seat then implemented the cross-checks this finding specified (credited "R68Sentinel"); the same tree now reads `caught=0/6 guard=0`. **The gate still prints the forged lines** — only the consumer is defended. | **HIGH** (proved; counter closed, **gate still open**) | R68ExecGate — escape the newline in the `SC_ENTRY_CITE` detail (one line) to remove the primitive at its root; the L1 should treat the gate-side escape as still-open, because the counter's defence is a property of one consumer's parser, not of the gate. |
| **F4** | The truthy-normalizer class (round-67 `C4`) survives the widening, and the widening **adds a second trust-dependent check** (col 15 recomputation) through the same tree-controlled instrument. **Measured live against the landed counter**: the counter is NOT fooled — `caught` drops 6/6 → 5/6 and `guard` reads 0 — because the M5 mutation leg sees the gate read the col-15 mutation as CLEAN. The counter's `locator_script()` resolves to the trusted normalizer, so its own derivation stayed honest (`verified=38 col15=33`). The plan's frozen guard list (a)–(e) has no instrument-identity leg; the binding is the mutation leg. | **MEDIUM** (accepted ceiling; **now measured as bound**) | L1 KagiR68 — record that the C4 class is bound by the M5 leg, not by an identity guard; no counter change required. |
| **F5** | The widened population is **narrower** than round 67's: a bound row re-pointed at a non-`.ufo/waves/` path becomes prose and its capture is silently unbound (`CLEAN`, `prose=121`), where the BASE gate caught the same re-point. Only the counter's two-disjunct `verified` definition covers it. | **MEDIUM** | R68ExecCounterC1 — derive under the plan's *two-disjunct* definition, so guard (a) fires on the divergence. |
| **F6** | The BASE blindness witness is **2/6 on the plan's six legs**, not the claim summary's "0/6": M4 (col 10 hex) and M6 (body byte) are caught by the BASE gate. The four round-68 classes (M1, M2, M3, M5) are the blind ones. Guard (c) as written is satisfied (the CRLF copy reads `CLEAN`). | **MEDIUM** (calibration of the record) | L1 KagiR68 / R68ScribeLesson — the round's claim text must not say 0/6. |
| **F7** | A **NUL byte** in the TSV is dropped by bash `read` but preserved by awk, so the row the gate reads is not the row on disk; the file-level check covers CR only. No finding is produced. | **LOW–MEDIUM** | later round's reason set; name it in this round's ceiling list. |
| **F8** | The hardlink class survives every revision (round-67 `C2`, the plan's stated ceiling). | **MEDIUM** (accepted ceiling) | later round's reason set. |
| **F9** | The `//`-form's expected reason disagrees between the gate's case table (`capture-token`) and the gate's behaviour (`capture-outside-root`), so the `//`-form's classification is **unpinned** while that case is red — and the plan's frozen reason set lists `capture-token` as covering the `//` form, so the *gate* is the side that departs from the plan. | **MEDIUM** (a pin at risk) | R68ExecGate + L1 KagiR68 — resolve with F2; the plan's reason set and the gate must agree. |
| **F10** | The plan's `verified` definition has two readings (strict / permissive) that give different BASE numbers (36 vs 37); the plan does not choose, and the frozen target `verified=37` is reachable only under the permissive one. | **MEDIUM** (calibration) | L1 KagiR68 — state the reading in the round's record. |
| — | Env-var, PATH-shim, and constant-printer forgeries: **all refused**. | none | — |

## 12. What I did not do, and the limits of these measurements

- **I did not edit the lane.** Every file I touched is under my scratch tree
  or is my own report and receipts. The gate moved five times under me
  because R68ExecGate owns it; I re-measured on each byte-state and quoted
  the hash with each result rather than chasing a moving target.
- **The round-68 counter landed during this seat** (`plans/round-68-c1.sh`,
  sha `4461be43…` and later revisions; `plans/round-68-c2.sh` also landed).
  I re-measured against it: the §4.3 forgery was **proved live** against its
  pre-fix `leg_caught`, and the counter seat then implemented the
  cross-checks, after which the same tree reads `caught=0/6 guard=0`
  (`receipts/forgery-proof-live.txt`). The §4.4 constant-printer and §4.1/§4.2
  env- and PATH-shim results were measured against the round-67 counter and
  hold by the same reasoning for the round-68 counter (whose `locator_script`
  and `parse_gate_run` I read).
- **Guard (c) of the landed counter read `SETUP` throughout this seat** —
  "rendered-text-v1.py absent beside the gate" — because the `git show`
  fallback extracts only `corpus/sources-census.sh` into the scratch work
  dir, with no sibling normalizer. R68ExecCounterC1 identified and fixed this
  while I was measuring; **I have not re-measured guard (c) after that fix**,
  so my report does not claim a reading for it.
- **I did not run the lane's fleet wrapper** (`scripts/sources-census.sh
  validate --root … kagi`) — that is the L1's guard (d) leg and the lane's
  own boundary; my seat is read-only on the lane and the wrapper touches the
  fleet tree. The counter's guard (d) read `venue=skip` on every tree I
  measured, because none of them was the lane itself.
- **Untested:** bind mounts and concurrent-writer races (the hardlink class is
  their deterministic proxy); a NUL byte in a *capture body* rather than in
  the TSV; a UTF-8 or multi-byte whitespace character (U+00A0, U+2028) in a
  location cell — `[[:space:]]` in the C locale does not match them, so they
  would survive `trim` as ordinary characters and be classed `token` rather
  than `whitespace`; a `col16` cell whose `.ufo/waves/` token is a *prefix*
  of the path rather than the whole path (`.ufo/waves/` alone, which names a
  directory, not a file).
- **One dead end, recorded:** my first attempt to instrument the gate's
  selftest copied the gate into a directory without its sibling
  `rendered-text-v1.py`, and every capture case failed with
  `SETUP (rendered-text-v1.py absent beside the gate)`. That was my
  harness's error, not the gate's; the instrumented copy was re-made inside a
  full tree copy and the three failures were then reproduced by hand. The
  dead end is left in the scratch transcript rather than the receipts.

## 13. Receipts

All under `.ufo/waves/round-68/w1/R68Sentinel/receipts/` (paths relative to
the lane root):

```
battery-results.tsv      the 26-construction battery, reference gate, both
                          classifier variants, verdict + findings per case
battery-detail.txt        the same battery, verbatim stdout per construction
landed-gate-battery.tsv   the same battery against the LANDED gate (R3 bytes)
landed-gate-battery.txt   the same, verbatim stdout
base-legs.txt             the BASE blindness control: the plan's six legs on
                          the BASE gate + BASE tree, with the anchor derivation
counter-guards.txt        G0–G5: control, constant-printer gate, truthy
                          normalizer, combined, PATH shims
forgery-detail.txt        A–E: self-consistent normalizer stub (with and
                          without an absent quote), PATH shims, env sweep,
                          stray SOURCES_CAPTURES: line via a filename
population.txt            the population-narrowing re-point battery; the two
                          population definitions compared; contains-vs-prefix
build_tree.py             class-tree builder (private copies; lane never written)
battery.py                the battery driver
battery2.py               the landed-gate battery driver
base_control.py           the BASE blindness control
forgery.py                the forgery battery
counter_guards.py         the counter-guard battery
injection.py              the stdout-injection and population battery
injection.txt             its verbatim output
parse_probe.py            the counter-parser decomposition: which defence stops
                          the injected finding (reason-grep vs the
                          defects==findings cross-check vs last-match parsing)
crosscheck-equalities.txt the two cross-checks (verdict findings=N == FINDING
                          lines; summary defects=N == SC_CAPTURE lines)
                          verified on the landed gate's own output
forgery-proof-live.txt    the stdout-injection forgery proved LIVE against the
                          landed round-68 counter: the attack tree, the gate's
                          own stdout on it, the leg-by-leg replay that reads
                          all six legs as CAUGHT on the pre-fix counter, the
                          same tree reading caught=0/6 guard=0 on the patched
                          counter, and the truthy-normalizer probe with its
                          control
classify.py               the widened-rule classifier (strict / permissive)
measure_targets.py        independent verified/col15 derivation
refgate.py                the reference widened gate (test instrument)
```

Scratch root `${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r68/R68Sentinel/`
was deleted on yield, after the receipts above were copied into the wave
directory.

Report: .ufo/waves/round-68/w1/R68Sentinel.md
