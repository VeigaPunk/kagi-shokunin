# K48ExecTrial — C1 candidate trial v1, hardened in scratch

Seat: executor (leaf). Scope: harden the C1 trial script; the lane tree was not edited (nothing under `corpus/` written).
Revision used for measurement: `52991e5da64cbacaa724b28b407cf5765fd21b41` (tree extracted to scratch; BASE `76da518f` untouched).

## Deliverables

| Path (under `kagi-shokunin/`) | What |
|---|---|
| `.ufo/waves/round-48/build/K48ExecTrial/sops-age-trial.sh` | final v1 candidate; land path `corpus/sops-age-trial.sh` |
| `.ufo/waves/round-48/build/K48ExecTrial/diff-vs-ref.patch` | `diff -u controls/fixtures/ref-sops-age-trial.sh <final>` (rc 1, 180 lines, hardening hunks only) |
| `.ufo/waves/round-48/build/K48ExecTrial/receipts.txt` | every command, rc, last line, plus full stdout/stderr of every run |
| `.ufo/waves/round-48/build/K48ExecTrial/note.md` | 10-line change log |

## Measured evidence (final bytes)

- `bash -n sops-age-trial.sh` — rc 0.
- `shellcheck -S style sops-age-trial.sh` — rc 0 (clean; the two `SC2094` annotations mark a false positive: the command reads `$W/plain.yaml` and writes `./f.yaml`).
- Direct run — `env -i HOME=<scratch>/h PATH=/home/vgpnk/.local/bin:/usr/bin:/bin TMPDIR=<scratch> bash sops-age-trial.sh --work <scratch>` — rc 0, 5/5 HOLDS, last line:
  `SOPS_AGE_TRIAL: HOLDS holds=5 broken=0 error=0 sops=3.13.3 age-keygen=v1.3.2`
- No sops on PATH — same argv with `PATH=/usr/bin:/bin` — rc 2, last line:
  `SOPS_AGE_TRIAL: SETUP holds=0 broken=0 error=0 reason=sops-not-on-PATH`
- Counter on an extracted tree at `52991e5` with the final script at `corpus/sops-age-trial.sh` and `controls/fixtures/ref-entry-measured.md` appended to `corpus/knowledge/sops-age-key-rotation.md`:
  `bash plans/round-48-c1.sh --tree <tree>` — rc 0, verbatim:

  ```
  C1_SOPS_AGE_TRIAL: value=5 discriminating=5 pins=1 setup_ok=1 nosecret=1 real_rc=0 none_rc=2 T1:real=HOLDS,shim=BROKEN,entry=1,ok=1 T2:real=HOLDS,shim=BROKEN,entry=1,ok=1 T3:real=HOLDS,shim=BROKEN,entry=1,ok=1 T4:real=HOLDS,shim=BROKEN,entry=1,ok=1 T5:real=HOLDS,shim=BROKEN,entry=1,ok=1
  ```

- Same counter `--tree` over the frozen fixture: identical line, `value=5` (parity; the hardening changed no measured token).
- Hostile caller env on the final bytes: with `SOPS_CONFIG=<scratch sops.yaml naming a throwaway recipient>` rc 0 and 5/5 HOLDS; with `SOPS_ENABLE_LOCAL_KEYSERVICE=false` rc 0 and 5/5 HOLDS. (Peer `K48Sentinel` measured the *fixture* at BROKEN holds=2 broken=3 and SETUP error=5 respectively; the `^SOPS_` sweep neutralizes both.)
- Secret scan: `grep -Rc 'AGE-SECRET-KEY[-]1'` and the full identity ERE `AGE-SECRET-KEY[-]1[0-9A-Z]{58}` (bracket form, identical match, so these artifacts do not carry the literal) over `sops-age-trial.sh`, `diff-vs-ref.patch`, `receipts.txt`, `note.md` → 0 matches in each; all run stderr empty; no key material printed by any run.
- Scratch: no `sops-age-trial.*` residue after the runs (receipts record the `find`); the scratch dir is removed on exit.

## What changed (robustness only)

1. `--work` arity: the fixture's `shift 2` on a lone `--work` loops forever; now exits 2 with usage. `--work=DIR` accepted.
2. `--help` via a `usage()` heredoc instead of `sed -n '2,34p' "$0"`.
3. Full `SOPS_*` environment sweep (prefix sweep + explicit list, incl. `SOPS_CONFIG`), replacing the fixture's fixed list.
4. Scratch confinement: `umask 077`, `--work` canonicalized (`pwd -P`, absolute), mktemp prefix re-asserted, scratch chmod 700, `HOME`/`XDG_*`/`TMPDIR` inside scratch, INT/HUP/TERM traps fail closed.
5. Identity hygiene: non-empty identity checks, `age1` public-key shape checks, the `AGE-SECRET-KEY` rejection kept.
6. Explicit rc checks on every setup step; `printf` for all lines; `set -o pipefail`; `LC_ALL=C`; shellcheck clean.
7. No shim/PATH/counter detection, no explicit `--config` (both named ceilings). T1..T5 logic, detail tokens, `TRIAL` grammar, final line and exit 0/1/2 unchanged.

## Risks / notes

- The sweep is `compgen -v | grep -E '^SOPS_'` (bash builtin; shebang is bash) and unsets only `^SOPS_`-prefixed names — `SOPSX` and other variables are untouched.
- `diff-vs-ref.patch` exits 1 by construction (the files differ); the patch contains only the hardening hunks above (no test-logic or token edits).
- Nothing is landed: `corpus/` is outside this seat's write scope. The wave must place the script at `corpus/sops-age-trial.sh` and append the measured section to the entry; the scribe's `Re-run:` line `bash corpus/sops-age-trial.sh --work <dir>` then binds.
- Counter scratch under `/fast/scratch/hyaku` is created/removed by the counter itself; this seat's scratch was removed on exit.
- Blocker: none.

SEAT-STATUS: complete
