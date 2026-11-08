# R67Sentinel — security and scope audit (round 67, kagi)

Seat: `R67Sentinel` (sentinel; axes calibration, freshness). Lane
`kagi-shokunin` (branch master). Claim BASE
`076701a11a58e3eb58d996b4c76c5e18071fb179`. Frozen plan `plans/round-67.md`
(landed `aa8807e443166f45485e1aada2989f646efc707c`, never amended).

Scope: security and scope audit of round 67 — credential shapes, write scope,
execution surfaces, and the confinement of the two new counters. Receipts in
`.ufo/waves/round-67/w1/R67Sentinel/`. Nothing in the lane was edited by this
seat; every probe ran against scratch copies.

## Verdict summary

| id | severity | class | state |
|---|---|---|---|
| **V-1** | HIGH | scope / trust boundary | **open** — the C1 counter's "independent derivation" reads the normalizer from the tree it measures, so the frozen target is reachable on a tree whose quotes do not locate |
| **V-2** | MEDIUM | scope / code execution | **open** — the landed census gate executes `python3` from the tree it audits (BASE ran no `python3` at all) |
| **V-3** | MEDIUM | write scope | **open** — a round-66 seat report was reconstructed under `.ufo/waves/round-66/`, outside the allowed set and not named by any plan leg |
| **V-4** | MEDIUM | scope / silent population shrink | **open** — a trailing space in the location cell removes a row from the checked population with a CLEAN verdict |
| **V-5** | LOW | write scope (operator-side) | **open, carried** — the fleet-root `__pycache__` artifact routed as D-66-2 is still staged; it predates this wave |

Closed: the credential scan, the write-scope sweep apart from V-3/V-5, the
execution audit, and both counters' write confinement.

`credential material CLEAN`

---

## V-1 (HIGH, open) — the counter's cross-check is a tautology: both sides
## run the tree's code

**Exploit path.** `plans/round-67-c1.sh` derives `bound`/`located` itself so
the frozen kill rule is measured rather than hard-coded, and guard (a)
"cross-checks" the gate's four counts against that derivation. But
`locate_quote()` resolves the normalizer as
`os.path.join(tree, "corpus/rendered-text-v1.py")` — **the copy inside the
measured tree** — and the tree's own `corpus/sources-census.sh` reads the
same file (`CAP_NORM="$ROOT/corpus/rendered-text-v1.py"`). A tree that ships
a normalizer reporting `count=1` therefore moves both sides of the
cross-check together, and the cross-check cannot see the move. This is
exactly the class the plan's kill rule names: "A count produced by a
constant printer … must be refused by guard (c) and by the mutation legs:
the counter may not hard-code any of the three numbers." The *number* is
not hard-coded; the *oracle* is supplied by the subject.

**Evidence** (scratch copy of the lane; every rendered-text-v1 path row's
quote replaced by a non-locating string; the tree ships a normalizer that
reports `count=1` for every quote except the two sentinel strings the
instruments themselves place in the tree):

```
GATE on the tree:      SOURCES_CAPTURES: CLEAN (path_rows=36 bound=36 located=36 prose=120)
                       SOURCES_CENSUS: CLEAN (rows=156 …)
C1 COUNTER on the tree: derived path_rows=36 bound=36 located=36 prose=120
                       guard-a verdict=CLEAN … gate_fields=match
                       guard-b selftest rc=0 cases=88
                       C1_READTHROUGH: bound=36 located=36 caught=6/6 guard=1
```

The frozen target is reached on a tree whose declared quotes **do not
locate**. Control — the same broken tree with the lane's real normalizer:

```
SOURCES_CAPTURES: FAILED (defects=31 path_rows=36 bound=36 located=5 prose=120)
SOURCES_CENSUS: FAILED (findings=31 rows=156)
```

The gate's own `--selftest` also passes (`PASS (88 cases)`) because the
selftest fixtures resolve their normalizer from the gate's `SCRIPT_DIR`, not
from the tree — so the selftest cannot witness this class either.

**Impact.** The claim C1_READTHROUGH is not falsifiable against a tree that
controls its own normalizer; `located=36` can be printed for a tree whose
every declared quote is absent from its capture body. That is the round's
whole target: "the census reads each declared capture's bytes and quote".

**Smallest remediation** (measured, not proposed): change one line in
`plans/round-67-c1.sh` so the derivation uses a normalizer **outside** the
measured tree — `os.path.join(LANE, "corpus/rendered-text-v1.py")` in place
of `os.path.join(tree, …)`. On the same liar tree the derivation then reads
`located=5` while the gate reads `located=36`; the two disagree
(`guard-a … gate_fields=differ`) and the cross-check becomes a real check.
The patched copy was run from scratch; the lane's counter was not edited.
The complementary fix — pinning the tree's normalizer digest against the
lane's committed digest before either side executes it — closes the same
hole from the gate's side.

**Owner.** `R67ExecCounterC1` (sole writer of `plans/round-67-c1.sh`) and
`R67ExecGate` (sole writer of `corpus/sources-census.sh`). The L1 is the
integration owner.

## V-2 (MEDIUM, open) — the census gate executes code from the tree it audits

**Exploit path.** The landed `corpus/sources-census.sh` resolves
`CAP_NORM="$ROOT/corpus/rendered-text-v1.py"` and falls back to `SCRIPT_DIR`
only when the tree has none; `cap_locate()` then runs
`python3 "$CAP_NORM" locate "$file" "$quote"`. So `verify --root DIR`
**executes `DIR/corpus/rendered-text-v1.py`**. BASE ran no `python3` at all
(`grep -c python3` = 0 on BASE's bytes; 3 on the landed bytes) — this is a
new execution surface introduced by this round.

**Evidence.** A scratch tree carrying a marker-writing `rendered-text-v1.py`
makes the gate create that marker when run with `--root` against it:
`MARKER_PRESENT: the gate executed corpus/rendered-text-v1.py FROM THE
AUDITED TREE`. The BASE gate against the same tree: `BASE_MARKER_ABSENT`.

**Impact.** A tree that can write one file can run arbitrary code inside the
gate process, and — because the verdict's `located` count comes from that
program — can decide the verdict. This is the write-side twin of V-1.

**Smallest remediation.** Prefer the gate's own committed normalizer
(`$SCRIPT_DIR/rendered-text-v1.py`) over the tree's, or verify the tree
copy's sha256 against the lane's committed digest before executing it.

## V-3 (MEDIUM, open) — write outside the allowed set: a reconstructed
## round-66 seat report

The allowed set is `{lane}/.ufo/waves/round-67`, `{lane}/plans`,
`{lane}/corpus`, `{lane}/{SCORECARD,SKILL,PROVINCE,LOG}.md`. Seven
kagi-lane paths fall outside it. Three are **plan-mandated L1 repairs** and
are closed: `claim-falsification.tsv` (C2 leg L4), `claims.json` (leg L5),
`final/c3-base.txt` (leg L6, whose first seven lines are the required
provenance header).

The remaining four are **not named by any plan leg**:

```
.ufo/waves/round-66/w1/R66ScribeEntry.md
.ufo/waves/round-66/w1/R66ScribeEntry/authoritative-census.txt
.ufo/waves/round-66/w1/R66ScribeEntry/citations-gate.txt
.ufo/waves/round-66/w1/R66ScribeEntry/ledger-verify-full.txt
```

written 08:12–08:15 today, inside the lane but under `round-66/`. The file
repairs the round-66 closure's routed defect ("13 of 14 seats filed;
`R66ScribeEntry` did not" — `LOG.md:2108`, spot-check §1/§2b) and carries a
§5 headed "Round-67 handoff", so it is a **round-67-written artefact sitting
at a round-66 path**. Attribution is not derivable from the bytes: no seat
scratch holds a file whose sha256 matches (`694dc357…`), and the L1's
scratch holds only the three receipts, not the report.

**Impact.** A later auditor reading `.ufo/waves/round-66/w1/` will take
`R66ScribeEntry.md` for a round-66 seat's own filing. That is the same
shape as the round-66 defect this round is repairing (a receipt that does not
exist where the record says it does, and a record that does not say where it
came from) — the inverse of the defect, but the same confusion.

**Smallest remediation.** Name the provenance in the file's own header (the
way `final/c3-base.txt` does), and record it in the round-67 lesson's
dispositions so the round-66 tree is not read as a round-66 filing. Not a
sibling-lane or fleet-root write; the lane's own `.ufo/`.

## V-4 (MEDIUM, open) — a one-byte edit silently removes a capture row
## from the checked population

**Exploit path.** The location column's shape test is
`^[A-Za-z0-9._][A-Za-z0-9._/-]*$`. A **trailing space** fails it, so the row
stops being capture-path-shaped and is counted as prose — and the frozen
contract says prose rows are "counted as prose and never checked". The gate
reads:

```
SOURCES_CAPTURES: CLEAN (path_rows=35 bound=35 located=35 prose=121)
SOURCES_CENSUS: CLEAN (rows=156 …)
```

No digest check, no size check, no quote check runs for that row; no finding
is raised; the exit code is 0. The row's capture binding is simply gone.

**Evidence.** `bin/probe-paths.sh` P6 (scratch copy; S164's location given a
trailing space). The counter does catch it — the C1 counter's own derivation
reads the same `path_rows=35`, and its population guard refuses
(`SETUP m1-no-same-size-different-sha-capture-target`; the guard-pop leg
compares the derived ids against the BASE registry's 36 capture ids). So the
class is **silent in the gate** and caught only in the counter.

**Impact.** The gate's own verdict can be made CLEAN while one capture row's
binding is unverified — the exact blindness class QM94 was written for,
re-entering through the shape test rather than through the path check.

**Smallest remediation.** The frozen reason vocabulary has no "shape-invalid"
member, so the change that keeps the frozen interface byte-identical is to
make the shape test tolerate a trailing space (the row then stays in the
population and fails closed on the digest/realpath check instead). Failing
closed on a shape-invalid row with an existing reason is the alternative.

## V-5 (LOW, open, operator-side, carried) — the fleet-root `__pycache__`

```
A scripts/hyaku/__pycache__/prefile-falsification.cpython-314.pyc
```

mtime 07:23:55, **before** the kagi wave launched (07:38:09). This is
round 66's routed D-66-2 (operator-side; `scripts/` is not a lane write
path). It is carried, not created this round, and the deletion is
operator-side — named here, not performed. The lane's own lesson already
records it.

---

## 1. Credential-shape scan — CLEAN

Full receipt: `R67Sentinel/01-credential-shape-scan.txt`.

Every file this round creates under `.ufo/waves/round-67/` and every file the
lane changed or added relative to BASE was scanned for `op://` refs, PEM
blocks, `gh` tokens, AWS access-key ids, age secret keys, JWTs, bearer
headers, `Set-Cookie`, npm/Anthropic/Slack tokens, and long hex/base64
blobs. 824 shape matches, **all** classified by value:

- 4 distinct 40-hex values — git commit ids, each verified with
  `git cat-file -t` ⇒ `commit` (BASE, the round-67 freeze, the round-66 tip,
  one more);
- 45 distinct 64-hex values — sha256 content digests, each re-derived as the
  digest of a file that exists in the tree (capture bodies, receipts);
- 7 `op://…` matches, all in `SKILL.md`, all the six-character placeholder
  `op://…` (U+2026 ellipsis) confirmed byte-wise — no `op://vault/item/field`
  path, no `op.env` value, no account value, no session id anywhere in the
  round's bytes.

Two refinements were applied to the scanner after the BASE reference run so
the counts are honest rather than inflated (a base64 run inside a hex digest
is the same bytes; a base64 run that is really a path is a path). The
BASE-only classes `bearer-header`, `set-cookie` and `generic-api-secret`
appear **only** in the lane's own pre-existing hygiene documentation and in
**no** file this round created.

**credential material CLEAN**

## 2. Write-scope audit

Full receipt: `R67Sentinel/02-write-scope-audit.txt`.

Fleet-wide sweep from the wave launch: 231 kagi-lane writes inside the
allowed set; 7 outside (3 plan-mandated L1 repairs, 4 = V-3); 19 fleet-root
paths (all the orchestrator's own state and other lanes' rounds —
`MANIFEST.json`'s content is byte-identical to HEAD, so its touch is a
rewrite with the same bytes); 1025 sibling-lane files (the concurrent rounds
kama r97, souji r88, tsukuroi r96, tameshi r95, chousa r90/91, tabi r87).
A content sweep for kagi round-67 bytes across all 19 sibling lanes returned
**none**.

## 3. Execution audit

Full receipt: `R67Sentinel/03-execution-audit.txt`.

- **No `op` / `op run` / `op read` / vault or account contact.** A 5-second
  process sampler over the whole window saw exactly one `op`-shaped process:
  pid 1103474 `op daemon`, parented by `systemd --user`, started **04:32:32
  — 3 h 05 min before the wave launched**. The janitor substrate is absent
  on this host. No `op` install, config write, or session file.
- **No host-sysctl mutation.** The `find /proc/sys -newermt` hits are a
  procfs artifact (a procfs node's mtime is its last *read*): demonstrated by
  `/proc/sys/vm/swappiness`'s mtime advancing across two `stat` calls with no
  write, while `/proc/sys/kernel/hostname` kept its boot-time mtime.
- **No pacman.** `/var/log/pacman.log` mtime is 2026-11-05, three days
  before this round. Nothing was installed by any channel this round, so no
  install needs recording.
- **No fleet-root or sibling-lane edit by a kagi seat** (above).
- **The only network is the declared RFC 9530 fetch**: one capture,
  `.ufo/waves/round-67/capture/S166.body` (67152 B, sha256 `544dbb7d…`); no
  other `.body`/`.headers` file was created anywhere under the fleet root in
  the window; no `Set-Cookie` value or session id was captured.

## 4. Counter confinement

Full receipt: `R67Sentinel/04-counter-confinement.txt`.

**Writes — confined.** Both counters (`plans/round-67-c1.sh` sha256
`67fb72e5…`, `plans/round-67-c2.sh` sha256 `c80f4441…`) write **only** under
their `--scratch` argument: 0 files created inside `--tree`, 0 in the lane,
0 in the fleet root, 0 in `/tmp`, 0 left under scratch (the work directory is
removed on exit). Both **refuse** a scratch inside the measured tree
(`SETUP scratch-inside-measured-tree` / `SETUP scratch-inside-tree`, exit 2)
and **refuse** an absurd `--tree` (`/etc`, `<lane>/../../etc`) with exit 2
rather than measuring it. The C1 counter hardlinks the tree it clones and
unlinks before rewriting, so no mutation writes through into the source: the
lane's `source-fetches.tsv` and S143 capture body had **identical sha256 and
byte count** before and after a full counter run.

**The residual risk is read-side**, and it is V-1/V-2 above.

## 5. Capture-path confinement

Full receipt: `R67Sentinel/05-capture-path-confinement.txt`.

Traversal, escape-by-symlink, absolute location and hardlink are all refused
(`capture-outside-root`, `capture-missing`, `capture-digest-mismatch`); a
`..` that canonicalises back inside the tree and a doubled-slash/`./` prefix
resolve to the same legal file and are digest-bound as expected. The one
open class is the silent population shrink (V-4).

## 6. The round's own readings (context for the L1, not the seat's claim)

```
bash corpus/sources-census.sh                → SOURCES_CAPTURES: CLEAN (path_rows=36 bound=36 located=36 prose=120)
                                                 SOURCES_CENSUS: CLEAN (rows=156 …)                    exit 0
bash corpus/sources-census.sh --selftest     → SOURCES_CENSUS_SELFTEST: PASS (88 cases)              exit 0
bash plans/round-67-c1.sh --tree <lane>       → C1_READTHROUGH: bound=36 located=36 caught=6/6 guard=1  exit 0
bash plans/round-67-c2.sh --tree <lane>       → C2_FIDELITY: mismatches=0 population=7 guard=1         exit 0
```

The gate's existing `SOURCES_CENSUS:` format string is byte-identical to
BASE's, and the new `SOURCES_CAPTURES:` line is printed immediately before
it, exactly as the frozen interface requires. The SC_CAPTURE reason
vocabulary on the landed bytes is exactly the frozen set
{`capture-outside-root`, `capture-missing`, `capture-digest-mismatch`,
`capture-bytes-mismatch`, `quote-not-located`}.

**These readings are the lane's claims, not this seat's.** V-1 shows the C1
reading is not falsifiable against a tree that supplies its own normalizer;
the seat does not certify `located=36` as a measurement of the quotes.

---

## Bytes this audit was measured against

The three instruments moved **after** the audit was measured (other seats were
still editing them when this report was filed). The findings above are
stated against these exact digests, and each was re-checked against the
current bytes at filing time:

| instrument | sha256 audited | sha256 at filing | V-1/V-2 still present at filing? |
|---|---|---|---|
| `plans/round-67-c1.sh` | `67fb72e5b7518b6e3f0098c359d4ae49f5a8617b830d5ec85b11d130600062ad` | `ac7a81a069932054a8dd062a688caa5d6812fc7acde93848eaf9952fa43c084c` | **yes** — `locate_quote()` still resolves `os.path.join(tree, "corpus/rendered-text-v1.py")` (line 240) |
| `plans/round-67-c2.sh` | `c80f4441a04a21ca02522afaad394f4f7f34177f11fe9f739786e6be41d13cf1` | `d4deb7356aa6fd99d3b5c8df524393fca97166501bbeb080e4b7ca4e8ce0d9e4` | n/a (no finding) |
| `corpus/sources-census.sh` | `232fd182900cdc3a5d6ad09607767e06814678146b1feff7ec9c2e1b93fcbfab` | `46de3d8c115ee121e0ae2a0fe55da34c7f821635a0f9ecb651e49f6e5498dbac` | **yes** — `CAP_NORM="$ROOT/corpus/rendered-text-v1.py"` (line 299), the `SCRIPT_DIR` fallback only when the tree has none |

The SC_CAPTURE reason vocabulary is unchanged at filing time and is exactly
the frozen set. The L1 must re-measure V-1 and V-2 against the **landed**
digests before closing them; this report does not certify the current bytes.

## Ceilings of this audit

- The audit is read-only against the lane; no probe wrote into it, and every
  finding above is measured on scratch copies (except the lane-reading
  counters and the gate's own `--selftest`).
- V-1 was demonstrated with a normalizer that special-cases two sentinel
  strings the instruments place in the tree. A less conspicuous liar (one
  that reports `count=1` for every quote) was also measured and is caught by
  the gate's own selftest; the general statement is that **any** tree-supplied
  normalizer that reports `count>=1` for the declared quotes reaches the
  target, and the class is closed only by pinning the normalizer's bytes.
- Attribution of the four round-66 files (V-3) is unresolved: the bytes do
  not name their writer and no seat scratch holds a matching copy.
- The fleet-root and sibling-lane sweeps are mtime-based over the wave
  window; a write that preserved an mtime would not appear. The content
  sweep across sibling lanes is independent of mtime and returned nothing.
