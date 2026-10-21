# Round 24 C1 — inherited-consent falsification

Frozen lane revision: `c5ef9e92201b6c36396301f12b23740565bf86a0`; original BASE: `4f94b52a3cdfaa289d779bd8a2afcd0b1fcd9105`. The isolated checkout was at the frozen revision in `/fast/scratch/kagi-r24-recovery/FPolicyConsent-9/tree`.

Axes: operability only (C1); freshness and calibration are outside this consent slice. `lsp` was unavailable (`read xd://lsp` → `No such tool`); source references below are direct reads, not semantic-server results. No source files were edited.

## Findings (severity order)

### HIGH — Default `verify` runs unregistered Bash targets

C1's safe-by-default interpretation is only closed over the declared script list. `ALLOWED_RE` permits `bash` (`corpus/claim-ledger.sh:235`); `HOST_SCRIPT_RE` names seven scripts (`:174`); `host_invocation()` treats a non-matching script as not-host (`:217-220`); and the default skip is conditional on a `[host]`/`[substrate]` note (`:516-530`). A regular Bash target outside that list can therefore reach the launch at `:536-539` without `--allow-host-rows`.

Fresh fixture reproduction on c5: an untagged `R1-01` command `bash corpus/new-host-reader.sh` used a scratch-only script that writes `MARKER` to the fixture root. Command: `env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r24-recovery/FPolicyConsent-9/home bash /fast/scratch/kagi-r24-recovery/FPolicyConsent-9/tree/corpus/claim-ledger.sh verify --root /fast/scratch/kagi-r24-recovery/FPolicyConsent-9/probe --claims /fast/scratch/kagi-r24-recovery/FPolicyConsent-9/probe/claims.tsv --stamps /fast/scratch/kagi-r24-recovery/FPolicyConsent-9/probe/stamps.tsv` → exit 0, stdout `CLAIM_LEDGER: CLEAN (claims=1 deferred=0 stamped=1 ids=1 cited=0 labeled_ids=0 orphans=1 host_skipped=0)`; scratch marker existed with `MARKER\n`. No host/private path was read. The consequence that an unregistered reader body could read host files is **[INFERENCE]**, not an observed read.

Falsifier: reject unregistered Bash targets before launch (or narrow the documented guarantee to tagged rows and the enumerated registry). The current `policy-bash-option` and symlink cases do not cover a new regular script/copy.

### LOW — Frozen plan still documents ambient authorization

`plans/round-24.md:16-17` says host rows run when `KAGI_HOST_ROWS=run`; the current source header says no environment variable is honored (`corpus/claim-ledger.sh:106-111`), initializes `ALLOW_HOST=0` (`:129`), and sets it only on parsed `--allow-host-rows` (`:286-300`). This is a plan/source contract mismatch, not a reproduced ambient-consent bypass.

## Targeted ambient-consent path — PASS

The new selftest has a negative case setting both `KAGI_HOST_ROWS=run` and `ALLOW_HOST=1` and expecting `HOST-SKIP` (`corpus/claim-ledger.sh:1571`), plus a parser-flag control (`:1572`). I supplemented its output-only assertion with a scratch marker fixture:

- Tagged fixture row `bash corpus/drift-pins.sh`, note `[host]`; environment included `KAGI_HOST_ROWS=run ALLOW_HOST=1`, with no CLI flag. The command above with `claims.tsv` for that row returned exit 0; stdout was `HOST-SKIP R1-01 reason=host-row-not-authorized` then `CLAIM_LEDGER: CLEAN (claims=1 deferred=0 stamped=1 ids=1 cited=0 labeled_ids=0 orphans=1 host_skipped=1)`; marker absent.
- Same fixture with explicit `--allow-host-rows` and neither opt-in environment variable returned exit 0; stdout was `CLAIM_LEDGER: CLEAN (claims=1 deferred=0 stamped=1 ids=1 cited=0 labeled_ids=0 orphans=1 host_skipped=0)`; only the scratch stub ran and wrote `MARKER\n`.
- The earlier `ProbeHostEvasion.md` `bash -o`/`-O` bypass does not reproduce at c5: `policy_check` rejects Bash options at `:256-259`; `-o posix` and `-O extglob` each returned exit 2 with `POLICY R1-01 reason=bash-option` / `CLAIM_LEDGER: POLICY (claims=1 policy=1 stamped=1)`, and neither wrote the marker. Current selftest covers `-o` (`:1346`, `:1580`).

Thus the specific inherited-environment claim passes for a tagged row. No real host row, host gate, host-private path, or network action was executed; the only permitted execution in the scratch control was the inert marker stub.

## Residual risk and verification gaps

The committed after receipt is for `735123d532387caccdbf04cb0303217d2483de73`, not c5; `final-verification.json:17` says the gate code was unchanged after that commit. `tripwire-after.txt:1-5` records `total=0 complete=4/4 host_skip_lines=48`, but all four gate invocations exit 1 with FAIL/BROKEN summaries. `host-tripwire.sh:41-55` stubs six named scripts and counts only listed population command strings; the zero is not proof that arbitrary/unregistered Bash readers or every host-file access is absent. The c5 fixture probe is the only runtime experiment here; no full selftest or tripwire was run for this seat.