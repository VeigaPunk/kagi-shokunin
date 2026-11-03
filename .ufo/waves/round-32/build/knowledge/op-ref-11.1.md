### 11.1 Re-measure on op 2.41.1 (round 32)

Installed CLI at measurement: `op --version` → `2.41.1` (first field, exit 0, 2026-11-03; receipt `.ufo/waves/round-32/build/probe/op-version.txt`). The §11 text above stays as written (its own scope: op `2.40.0`–`2.41.0`); this subsection re-runs the same six-class byte check on the installed release and adds no new class.

Command and expected last line (identical to §11): `bash corpus/op-ref-probe.sh --dotenv-bytes` → six `DOTENV_BYTES_CASE id=<id> status=PASS` lines, then `OP_DOTENV_BYTES: CLEAN (checks=6 failed=0)`, exit 0. Measured 2026-11-03 on 2.41.1: exit 0, six PASS, that last line (receipt `.ufo/waves/round-32/build/probe/base-probe.txt`).

Counting command (frozen, `plans/round-32.md` C2), run from the lane root:

    V=$(op --version | awk '{print $1}')
    awk '/^## 11\./{f=1;next} /^## /{f=0} f' corpus/knowledge/op-ref-consumption.md | grep -c "op \`$V\`"
    bash corpus/op-ref-probe.sh --dotenv-bytes; echo "exit=$?"

At BASE the second line prints `0` (the range named op `2.40.0` and op `2.41.0` only) and this subsection makes it print `1`; the frozen predicate is `BYTE_PIN: CURRENT`.

Six classes, unchanged from §11 — ids and the bytes the child receives for `KAGI16_VALUE` (`dotenv_bytes()`): `escaped-lf` → `alpha` LF `beta` (`616c7068610a62657461`); `trailing-lf` → `alpha` LF LF (`616c7068610a0a`); `newline-only` → one LF (`0a`); `single-literal` → `alpha` `\` `n` `beta` (`616c7068615c6e62657461`); `double-multiline` and `single-multiline` → `alpha` LF `beta` (`616c7068610a62657461`). This round asserts no byte change on 2.41.1: six PASS is the whole claim.

**Sourced.** `corpus/SOURCES.md` **S072** — 1Password CLI release history, `https://app-updates.agilebits.com/product_history/CLI2`, accessed 2026-11-03; its 2.41.1 entry reads `2.41.1 (build #2410101 ) – released 2026-10-21` (capture `.ufo/waves/round-32/build/src-open/S072-body.html`). The row records that URL, that access date and its located quote; this subsection cites it for the installed release's identity, not as evidence about bytes.

**Does not establish.** Representation fidelity for these six classes on op `2.41.1` only: no ref-resolved value, no item read, no vault or account fact, and no handler behaviour — `the-janitor` is absent from this host and nothing ran through it. The downstream `$(...)` trailing-LF loss in §11 is a shell fact, not re-measured here. Scoped to the exact version string above; a later release is unmeasured until the `on-release` clock fires.

**Falsifier.** Any `DOTENV_BYTES_CASE … status=FAIL`, or a `DRIFT`/`SETUP` verdict, from `bash corpus/op-ref-probe.sh --dotenv-bytes` on a newer op release falsifies the corresponding class for that release; `recheck: on-release of op`.
