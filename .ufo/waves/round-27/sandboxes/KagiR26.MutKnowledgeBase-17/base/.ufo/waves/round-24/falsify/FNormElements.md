# FNormElements — C2 script/style opener regex + malformed-opener regression

Seat KagiR24-2.FNormElements-9 (leaf, no subagents). Frozen revision
`c5ef9e92201b6c36396301f12b23740565bf86a0`: lane HEAD equals it; `git diff --stat
<rev> -- corpus/rendered-text-v1.py .ufo/waves/round-24/normalizer-replay.json`
empty; sandbox copy `cmp`-identical to the reviewed file. Axes: operability
(clean-env run + selftest), freshness (replay receipt + public-byte fixture),
calibration (expected bytes fixed by hand from the declared rules BEFORE any run,
hashed with `sha256sum` — never recomputed via the normalizer's own logic).
No installs; pacman untouched.

## Sandbox and runs (all exit codes observed)
Sandbox `/fast/scratch/kagi-r24-recovery/KagiR24-2.FNormElements-9` (clone
`--no-hardlinks`, checkout frozen rev THERE). Every run:
`env -i PATH=/usr/bin:/bin HOME=<empty $SB/home> python3 corpus/rendered-text-v1.py …`;
fixtures written `printf '%s'` (no trailing newline), expected text hand-derived
from docstring rules 2-3 (:61-62 regexes) before execution.

1. `--selftest` → `RENDERED_TEXT_V1_SELFTEST: PASS (cases=20)`, rc=0. Exact-string
   asserts on 18 CASES + strict-utf8 (expects raise) + quote-collapse-only.
2. F1 `V<script-foo>VISIBLE<script>code</script>TAIL` → expected `V TAIL` (6 bytes,
   sha256 bd833997ea2fa025ead66c7d70c49ad1d9655050c1f7cd01401df7ccecaa68ff) → MATCH,
   rc=0. `locate F1.in 'VISIBLE'` → `count=0` rc=1; `locate F1.in 'TAIL'` → `count=1` rc=0.
3. F2 `A<script>x</script b="c">B` → expected `A x B` (5 bytes, 803321233553aea9cdb8c83d1c8f8a6a6cd43de75205ccda601de7d6f21abbf2)
   → MATCH rc=0.
4. F3 `U<script` → expected `U<script` (8 bytes, 4df67398c66989411da51b58408fd205a8963c0d8a8f07339039a85764ac20cd)
   → MATCH rc=0.
5. Public: `curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation
   verification)' https://example.com/` → fetch_rc=0, 577 bytes, raw sha256
   25ddf2c883e0d1958ea971d279a7e4f0fd446724ee3db7db19dadabd4a62e484; body contains a
   real `<style>…</style>` and `<script src=/s.js></script>`. Hand-derived normalized
   text (171 bytes) → `normalized_sha256=06fe21c5fbf716d5b7fc1ef87cd418a375d9523ad36a951a1e3182a8f42526af`
   MATCH rc=0; `locate … 'monitoring purposes.'` → `count=1` rc=0.

## Findings by severity

**MED (prose/behavior precision, regex contract itself unbroken) — closer identity
overclaimed; visible text silently swallowed.** F1: opener `<script-foo>` passes
`\b` (`t`|`-` boundary) and `[^>]*`=`-foo`; backref `\1` captured only `script`
(:61), so closer `</script>` pairs with an opener whose element name is
`script-foo` — contradicting docstring :17-18 "the closing tag must name the same
element". Observable widening vs element semantics: browser-visible text `VISIBLE`
is removed (`locate count=0`). The regex IS the declaration and is the frozen
round-23 generator pattern (:19-22; freshness-locked, replay 10/10), so this is a
prose + selftest gap, not an unauthorized code change: the only malformed case
(:141) pins the `broken</script>`-inside-opener shape, not the `<script-foo>`
swallow. Falsifier: none observed. Repair (not applied): selftest case
`("script-hyphen-opener", b"V<script-foo>VISIBLE<script>code</script>TAIL", "V TAIL")`
plus prose corrected to "same `script|style` alternative".

**LOW — end-tag with attributes defeats removal entirely (silent narrowing).** F2:
`</script b="c">` fails `</script\s*>`, the whole element match fails, and script
body `x` survives as visible text (`A x B`). Docstring never states the closer must
be attribute-free. Not covered by CASES. No widening; removal narrows.

**INFO — unclosed opener survives literally.** F3 `U<script` → `U<script`, honest
per :17 ("must close with '>' before the body"; TAG_RE also needs `>`). Unpinned by
CASES.

**PASS — selftest assertions.** 20/20 exact-string; any failure prints FAIL with
failed count and rc=1 (:168-171), matching documented :51. `script-word-boundary`
(`<scripture>` kept) and `script-shortest-match` pin the `\b` and non-greedy guards.

**PASS — no undocumented browser-equivalence promise.** Normalizer declares regex
semantics only; sole spec citation is the rejected WHATWG ASCII-whitespace
alternative (rule 5, S030 rejected row). `(?i)browser` over `corpus/` and
`.ufo/waves/round-24/`: hits are 1Password BrowserSupport surfaces (unrelated),
dispatch task phrasing "browser-equivalent read" (scout instruction, not contract),
and the explicit guard "Do not claim regex rendering equals browser HTML parsing"
in falsify-spec/falsify-dispatch. No file promises regex≈browser parsing; F1/F2 are
reported as element-semantics divergences only.

**PASS — freshness cross-check.** normalizer-replay.json: `matches: 10`, S017-S026
all `match: true`, replayed==declared digests; docstring's ASCII-only claim (fails
exactly S022/S023/S024 = 3/10) consistent with plans/round-24.md and the S030
rejection. Public run exercised both element removals on live markup.

## Residual risk / coverage gaps
- Replay receipt records digest equality only; the ten round-23 bodies were not
  re-fetched in this bounded run (F1-F3 + one public page only).
- The three malformed shapes my fixtures pin are absent from committed CASES; a
  future normalizer edit could flip any of them with selftest still PASS.
- F1 severity is doctrine-dependent: under "the regex is the declaration" it is LOW
  prose precision; under element semantics it is MED silent widening. Stated MED
  with that split explicit.
- One public page ≠ malformed-markup coverage; no browser differential run or claimed.
