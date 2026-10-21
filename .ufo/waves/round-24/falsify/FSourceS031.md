# FSourceS031 — C2 source S031 (HTML comment `>` leak bound)

Seat: KagiR24-2.FSourceS031-9 · 2026-10-21 · lane rev c5ef9e92201b6c36396301f12b23740565bf86a0
Sandbox: /fast/scratch/kagi-r24-recovery/KagiR24-2.FSourceS031-9 (clone --no-hardlinks, checkout c5ef9e9; empty HOME for runs). No installs. No production edits.

## Committed claims under attack

- corpus/SOURCES.md S031: spec, tier A, scope "HTML comment data may contain `>` (bounds rendered-text-v1's tag-only comment rule)", anchor §13.1.6 Comments (#syntax-comments), opened 2026-10-21, status mined, used-by corpus/lessons/round-24.md.
- corpus/source-fetches.tsv:74: row_identity_sha256=9f75df3d…, capture sha256=04b65bf0…, bytes=89196, normalized_sha256=f8974683…, location "13.1.6 Comments".
- corpus/lessons/round-24.md:50: admit (mined); quote (§13.1.6 Comments): "The text is allowed to end with the string " <! ", as in <!--My favorite operators are > and <!--> ." — 22 words ≤ 25 (wc -w = 22).

## Freshness — live reopen (all three digests reproduced same-day)

- `curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)' https://html.spec.whatwg.org/multipage/syntax.html -o S031-live.html` → exit 0; sha256 04b65bf0b4b5f3bb3815999ab499af980fa09b8832f02c1686c544ab8e79a52d, 89196 bytes — both exactly the committed capture values.
- `env -i HOME=<empty> PATH=/usr/bin:/bin python3 corpus/rendered-text-v1.py digest ../S031-live.html` → exit 0; raw=04b65bf0… bytes=89196 normalized=f8974683… normalized_bytes=31992 — normalized digest matches the committed rendered-text-v1 column.
- `locate` with the exact committed quote → `RENDERED_TEXT_V1_LOCATE: count=1`, exit 0 — reproduces the lessons receipt (count 1).
- `printf 'S031\tmined\t<url>\n' | sha256sum` → 9f75df3da25f56d105b4b2504f28a4360c94cdaa9bd345ea0a48c17898f1dc11 — matches row_identity_sha256; S031 row has the declared 16 columns.
- Volatile-v1 caveat honored: these are point attestations, not drift pins; equality here is same-day, not a stability claim.

## Operability — anchor and quote in the live page

- Live line 880: `<h4 id=comments><span class=secno>13.1.6</span> Comments…`; line 883: `<dfn id=syntax-comments>Comments</dfn>` — "§13.1.6 Comments (#syntax-comments)" resolves; the h4 id is `#comments`, the dfn carries `#syntax-comments`, so the committed anchor names a real element.
- Live lines 890-892 (raw source): `…is allowed to end with the string "<code>&lt;!</code>", as in <code>&lt;!--My favorite operators are > and &lt;!--></code>.` The spec's own example contains a literal `>` inside comment data; the grammar (line 885) prohibits only leading `>`/`->`, embedded `<!--`, and trailing `<!-` — so "comment data may contain `>`" is a sound reading of the normative text. Tier A for this narrow syntax scope is correct.

## Calibration — actual script step vs claimed support

- v1's actual step (frozen rev): `TAG_RE = re.compile(r"<[^>]+>")` substitutes `<`-through-first-`>` with a space, after script/style removal, before html.unescape. A comment with an inner `>` therefore loses its head and leaks its tail; no comment pass exists.
- Executed proof, not reading: `--selftest` → `PASS (cases=20)` incl. `case comment-gt: ok`, fixture `a<!-- x > y -->b` → `a y -->b`. This is exactly SOURCES.md's teaches: "leak the tail of a comment… v1 keeps that behaviour (selftest comment-gt) rather than adding a comment pass."
- No committed text claims regex rendering equals browser HTML parsing. Support runs spec-syntax fact → regex consequence; the wave-1 report (.ufo/waves/round-24/build/SrcHtmlComments.md) set that limit and the committed rows preserve it (the spec grounds legality; the selftest grounds v1's output).
- Minor (low, informational): SOURCES.md scope says "tag-only comment rule" while plans/round-24.md:35 declares "no separate comment rule". The teaches field and selftest resolve it (the bound is the generic tag rule applied to comments), but the scope wording alone slightly over-specifies a comment-specific rule.
- Minor (low, informational): the wave-1 report's explicit withdrawal condition ("if a reopened grammar disallows `>` in comment data") is not carried into any committed S031 row; committed flip machinery is recheck=on-release only. No admission/rejection inconsistency: all three artifacts say admit (mined); the only round-24 reject/flip pair is S030.

## Verdict

- Operability PASS (anchor + quote live and located), freshness PASS (raw, normalized, and identity digests all reproduced today), calibration PASS (selftest-executed leak bound matches the claimed support; no parser-equivalence overclaim).
- Falsifier found: none. Severity: none blocking; two low/informational observations above (scope wording; uncommitted flip condition). No production changes made, per assignment.
