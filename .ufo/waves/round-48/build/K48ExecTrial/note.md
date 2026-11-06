1. `--work` arity: the fixture's `shift 2` on a lone `--work` never advances (`$#` stays 1) and spins forever; now a missing/empty value prints usage and exits 2.
2. `--help`: replaced `sed -n '2,34p' "$0"` (breaks when the header moves) with a stable `usage()` heredoc; also accepts `--work=DIR`.
3. Environment sweep: unset every `^SOPS_`-prefixed variable (compgen) plus the documented list, now including `SOPS_CONFIG`; caller env can no longer redirect creation rules (peer-measured on the fixture: SOPS_CONFIG -> broken=3, SOPS_ENABLE_LOCAL_KEYSERVICE=false -> error=5).
4. Scratch: `umask 077`; `--work` parent canonicalized with `pwd -P` and required absolute; mktemp prefix re-asserted; scratch dir chmod 700.
5. HOME, XDG_CONFIG_HOME, XDG_CACHE_HOME and TMPDIR all confined to the scratch tree; INT/HUP/TERM traps remove it and fail closed with a SETUP line (exit 2).
6. Key hygiene: `-s` checks on generated identities, `age1` shape checks on A and B, the fixture's `AGE-SECRET-KEY` rejection kept; no key, plaintext or ciphertext reaches stdout (scan: 0 matches).
7. Every setup step (keygen, cat, plaintext, plaintext sha, sops AND age-keygen versions) now has an explicit rc/emptiness check instead of continuing on failure.
8. `printf` for all output lines, `cp --`/`cd --`/`cat --`, `set -o pipefail`, `LC_ALL=C`; shellcheck `-S style` is clean (two SC2094 annotations mark a false positive: reads `$W/plain.yaml`, writes `./f.yaml`).
9. No shim/PATH/counter detection and no explicit `--config` were added (both are named ceilings); T1..T5 logic, per-test detail tokens, `TRIAL` grammar, the final `SOPS_AGE_TRIAL:` line and exit 0/1/2 are unchanged.
10. Measured on the final bytes: counter `value=5` (rc 0), direct run 5/5 HOLDS (rc 0), no-sops run rc 2; frozen fixture through the same counter --tree also 5, so the hardened script is parity-equivalent.
