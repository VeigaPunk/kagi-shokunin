# SrcPep440IntNorm — PEP 440 "Integer Normalization" (source opening, round 28)

Recorder `KagiR28.SrcPep440IntNorm-7`, opened 2026-10-21. Sandbox `.ufo/waves/round-28/sandboxes/SrcPep440IntNorm/`. All lane files cited are sha256-identical between the working tree at `bdf90f58` and BASE `3553d49` (checked).

## Source identity

| field | value |
|---|---|
| URL / final URL | `https://packaging.python.org/en/latest/specifications/version-specifiers/` (identical, no redirect) |
| HTTP | 200, `text/html; charset=utf-8` |
| title | `<title>Version specifiers - Python Packaging User Guide</title>`; H1 `Version specifiers` |
| bytes / sha256 | 116603 / `4e53ed8342a069865ad05d26f5e492ecbca45ddc78abb58fd7dc6bf630eb5442` (raw body, saved `pep440-version-specifiers.html`) |
| declared-profile capture | `curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)'`: exit 0, 200, 23965 transferred, decoded 116603, **same sha256**, `cmp` exit 0 (`pep440-declared-profile.html`) |
| normalized | `rendered-text-v1` digest exit 0: `31e3f241a30e8d5928a38971904d31c96dde9bc6f76b79fa0f053d8f42411666`, 49801 bytes |
| page date | "Last updated on Oct 12, 2026" (raw offset 110509) |

Freshness: raw digest = `corpus/source-fetches.tsv:86` field 10, normalized digest = field 15 of that row (S043, fetched 2026-10-21). The page is byte-identical to S043's recorded capture.

## Findings

1. **Duplicate URL — yes, exactly one existing row.** `corpus/SOURCES.md:50` (S043) is the only occurrence (`grep -n 'version-specifiers' corpus/SOURCES.md` exit 0, 1 match). No W04 today. START census carries 11 W04 (`.ufo/waves/round-28/census-start.txt:2-12`); own enumeration gives 9 duplicated URLs over 20 rows = 11 extra rows, i.e. W04 fires once per row after the first on a URL. A new row adds exactly one line: `W04 S0NN duplicate url packaging.python.org/en/latest/specifications/version-specifiers/ across scopes` (message shape copied from recorded lines; emitter not found — see Not checked).

2. **"Extend S043" is contract-forbidden; the real choice is new-row vs no-row.** `/home/vgpnk/Projects/shokunin/CORPUS.md:116-117` (SOURCES contract v1, frozen): "**Append-only.** Only `status`, `recheck` and `used-by` change in place ... A correction is a new row whose `teaches` opens `supersedes S0NN —`." S043's `scope`, `anchor`, `teaches` cannot gain the normalization facet in place. Most same-URL additional rows are `supersedes` corrections (S019/S020/S022/S023/S025/S026, S032, S039–S041); S021 is the one same-URL row that states a distinct scope without `supersedes`, so a non-correction duplicate has a precedent — it still carries a W04.

3. **Quote trap: the rendered locator rejects the source period.** The source sentence ends `<code>9000</code>.`; tag→space makes the rendered text `9000 .`, so the 19-word variant with `9000.` locates **0 times (exit 1)**. The 18-word variant without the period locates **once (exit 0)**. The mechanism sentence also locates once (exit 0). Both are in `#integer-normalization`.

4. **Which rule C1 must follow: canonical-form rejection (SemVer §2), not PEP 440 normalization.** BASE half-normalizes, and that split is the defect: `corpus/release-clock.py:369-380` `numeric_version('3.15.01') == (3, 15, 1)`; `:383-386` `is_regression('3.15.1','3.15.01')` is `False` (already PyPA-style equality); `:582` then compares raw strings and fires. Completing the normalization would make the leading-zero token *equal* and silently suppress the finding the frozen C1 predicate requires ("typed finding ... never a release event"). The clock's currency is vendor feed titles/tags (CPython, Vault, OpenBao, SOPS, curl), not Python distribution version identities. This page is the rejected *alternative*, not the rule.

5. **Boundedness intersects this page's mechanism; calibration cross-check on S042.** PEP 440 normalizes "via the `int()` built in"; CPython 3.14.8 raises `ValueError` above 4300 digits (measured: 4301-digit component and 5000-digit all-zero component, both exit 1), and `numeric_version` is called at `release-clock.py:577` and `:385-386` before any typed finding, so the bound must be lexical, before `int()`. This row complements the round's int-limit row; it is not a substitute. Separately, S042's registered anchor/scope is §11 Precedence item 11.2 for numeric ordering (`corpus/SOURCES.md:49`), but the plan's canonicality cites **S042 §2** — outside that row's anchor and scope; if the lesson cites §2, a §2 row is needed (`SrcSemverSec2`, also a duplicate URL). This page cannot fill that gap: it documents the opposite semantics.

6. **PEP 440 normalization is not a total canonicalizer.** The same section exempts alphanumeric local segments (`1.0+foo0100` "is already in its normalized form"), so even an adopted normalization would still need a separate lexical rule for arbitrary tokens.

## Curation proposal (ADMIT as tier A spec; do NOT extend S043)

- `source`: `Version specifiers — Integer Normalization (Python Packaging User Guide) — https://packaging.python.org/en/latest/specifications/version-specifiers/`
- `kind`: `spec`; `tier`: **A** (primary normative PyPA specification of the normalization rule; tier scoped to the normalization facet only, never to the lane's canonicality rule).
- `anchor`: `§Version scheme → Normalization → Integer Normalization (#integer-normalization); page Last updated on Oct 12, 2026, fetched 2026-10-21`
- `teaches` (paste-ready, no `|`): `PEP 440 normalizes integer version components through int(), so a PyPA-normalizing reader equates a leading-zero token with its canonical form (09000 → 9000; hence 3.15.01 would read as 3.15.1 [INFERENCE from the quoted rule]); the round-28 clock rejects the token as non-canonical (S042 §2) and must not adopt this normalization. Quote: “This means that an integer version of 00 would normalize to 0 while 09000 would normalize to 9000” (Integer Normalization).`
- `scope`: `PEP 440 integer normalization of version components: leading zeros are stripped via int() so 09000 reads as 9000; the normalization alternative the round-28 canonical-token rule rejects (contrast only, not the clock's rule)`
- **Quote** (18 words, located once, exit 0): `This means that an integer version of 00 would normalize to 0 while 09000 would normalize to 9000` — locator `Version specifiers → Version scheme → Normalization → Integer Normalization (#integer-normalization)`.
- `status`: `mined` only if `corpus/lessons/round-28.md` or a knowledge entry exists and names the id on its `source:` line; otherwise `queued` with `—` (else `SC_USEDBY_MISSING`/`SC_USEDBY_NOCITE` or `SC_MINED_UNUSED`, `corpus/sources-census.sh:215,229-231`). `opened` 2026-10-21; `recheck` `180d` (match S042/S043; never `on-release`, `release-clock.py:511,518` `UNBOUND`).
- **id**: L1 assigns. `ScribeSourcesRows.md:16`, `SrcCve202010735.md:67`, `SrcFrontierOidc.md:65`, `SrcFrontierScanning.md:37` all propose S044 — the collision is L1's; this row is S045+ if S044 goes to the int-limit doc.
- **Provenance row required** (one per registry row): `S0NN  mined  <sha256(id\tstatus\turl\n)>  <url>  <url>  200  curl-fsSL-compressed-v1  2026-10-21  decoded-http-body-volatile-v1  4e53ed83…  116603  -  <quote above>  rendered-text-v1  31e3f241…  §Version scheme → Normalization → Integer Normalization (#integer-normalization)`. Field 3 for `S044/mined` = `f0f933d04a853396e540b588a520e8dd0a19ac65efaa061589de23b9734f0576` (recompute if id/status changes; formula verified against `sources-census.sh:262` and S043's row).
- **Cost**: a new row + capture prints `rows=44 ... captures=44` (A=42, mined=40), so `corpus/claim-ledger.tsv:52` (R21-02 pins `rows=43 ... captures=43`) must migrate, as in `.ufo/waves/round-27/expectation-migrations.json`.
- **If L1 chooses no row**: do not cite S043 for the normalization claim (its scope is ordering only, `corpus/SOURCES.md:50`); state the contrast as lesson prose and record it as unregistered.

**REJECT?** No — it grounds the stated purpose (normalization semantics and the contrast). But it does **not** ground a leading-zero-rejection rule and cannot serve as C1's required "row opened this round" (that is the int-limit documentation). Citing it as the canonicality source would invert the rule.

## Commands run (exit codes)

| command | exit | result |
|---|---|---|
| `curl -sS -L … -o pep440-version-specifiers.html`; declared-profile `curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 …'` | 0;0 | 200/116603/sha 4e53ed83…; decoded 116603, same sha, `cmp` 0 |
| `python3 -I -B base/corpus/rendered-text-v1.py digest pep440-version-specifiers.html` | 0 | 4e53ed83…/116603 → 31e3f241…/49801 |
| `… locate` 18-word quote; with `9000.`; S043 ordering quote | 0;1;0 | count=1; count=0; count=1 |
| import BASE `release-clock.py`; probe `3.15.01` / 4301 digits | 0 | `False`, `True`, `(3,15,1)`, `ValueError: Exceeds the limit (4300 digits)` |
| `int("09000")`; `int("1"*4301)`; `int("0"*5000)` | 0;1;1 | 9000; ValueError; ValueError |
| `printf 'S043\tmined\t<url>\n' \| sha256sum`; `bash corpus/sources-census.sh` (sandbox BASE) | 0;0 | 0865363f… matches `source-fetches.tsv:86`; `CLEAN (rows=43 … captures=43)` |
| duplicate-URL enumeration; sha256 equality working tree vs BASE (5 corpus files) | 0;0 | 9 URLs/20 rows/11 extra; all `SAME` |

No tool installed or upgraded; network used only for the two fetches of the assigned URL.

## Not checked

- `semver.org` §2 itself (owned by `SrcSemverSec2`); I relied on the plan's citation and S042's registered §11 anchor — the §2 sentence is not re-verified here.
- The fleet W04 emitter: the path cited in `.ufo/reports/round-12/mado.md:223` no longer exists; the "across scopes" suppression condition is untested and the 11→12 count is arithmetic plus message format [INFERENCE].
- The frozen C1 fixtures/measure (`C1Patch`/`XMeasure` own them); F1's defect is shown at function level, not by running the frozen harness.
- The round-28 lesson text (not yet written); the `used-by` constraint is taken from the census code.
- No lane gate or selftest was run in the lane checkout; the census ran only on my sandbox BASE copy. Id assignment and the S044 collision are L1's integration decision.
