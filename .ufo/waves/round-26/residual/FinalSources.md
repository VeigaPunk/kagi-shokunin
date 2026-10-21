# FinalSources — round-26 residual review of S039–S041 source grounding

Seat: `KagiR26.FinalSources` (reviewer, residual wave)
Candidate: `d30c9892a7377b8b5a51817d1db8b81eaddcc397`; frozen BASE `1bf3eec48d3761580ffd375c88143232485ae814`.
Scope: freshly re-open all 3 new source URLs S039–S041 and verify located quotes (≤25 words), title 3.15.1, no-break-space and ASCII qualifiers, HTML5 valid/invalid clauses, lane-code facts not attributed to docs, admit/reject scope, no outside discernment.

## Method actually exercised

Working directory: `.ufo/waves/round-26/sandboxes/FinalSources/` (unique sandbox; candidate blobs extracted with `git show`, never the working tree).

Re-opened each URL with the exact argv recorded in `.ufo/waves/round-26/captures/metadata.json` (`curl -fsSL --compressed --max-time 60 -A 'kagi-shokunin-round23/1.0 (documentation verification)'`):

| id | URL | HTTP | effective URL | bytes | fresh sha256 | matches recorded |
|---|---|---|---|---|---|---|
| S039 | `https://www.python.org/downloads/feed.rss` | 200 | same URL | 3357 | `11c86a3481551067676403f66bc23b3d7dd1f5de14f32bbacafed239d13ca66b` | yes, byte-equal to `source-fetches.tsv:82` and captures metadata |
| S040 | `https://docs.python.org/3/library/re.html` | 200 | same URL | 251811 | `0724d8159158bdc1c92a212a2345ab1dc599343b8a35b0fa5682384af30c8aa5` | yes, byte-equal to `source-fetches.tsv:83` |
| S041 | `https://docs.python.org/3/library/html.html` | 200 | same URL | 20100 | `8a54138162e47f1bb285f07404309df8556f004ff371140bbbb38d9be70a7122` | yes, byte-equal to `source-fetches.tsv:84` |

So the served bodies this run are byte-identical to the candidate's captures — zero content drift since the wave's fetch. Locate/digest checks were run with the committed instrument `corpus/rendered-text-v1.py` on the fresh bodies.

## Findings — all checks pass; no defects found in scope

### S039 (feed, raw-literal-v1 profile)

- Quote `<title>Python 3.15.1</title>`: `wc -w` = 2 ≤ 25 (rule: `corpus/sources-census.sh:277-278` — `words=$(printf '%s' "$fquote" | wc -w); [[ -n $fquote && $words -le 25 ]]`). Literal occurs exactly once in the fresh body (`grep -o` count = 1).
- Feed facts in `SOURCES.md:46` / `source-fetches.tsv:82` verified against the served items: full item list is 3.14.9 (pubDate Wed, 21 Oct 2026 13:08:09 +0000), 3.15.1 (09:59:50), 3.16.0a1 (13 Oct), install-manager 26.4, 3.15.0, 3.15.0rc3, 3.11.17, 3.10.22, 3.12.15, 3.14.8. Confirmed: 3.15.1's pubDate matches the recorded anchor `Wed, 21 Oct 2026 09:59:50 +0000`; the first item is the older-series 3.14.9 backport; 3.16.0a1 is a prerelease; no stable item newer than 3.15.1 exists, so "newest stable semantic version is 3.15.1" is true of this fetch.
- Scope cell bounds hold: the row claims only "CPython stable release identity at this fetch," explicitly disclaiming installed-runtime or semantic-change evidence. The feed itself says nothing about either — accurate.

### S040 (re.html, rendered-text-v1 profile)

- `python3 corpus/rendered-text-v1.py digest S040.body` → `RENDERED_TEXT_V1: raw_sha256=0724d815… bytes=251811 normalized_sha256=bbeb9d7c317cab01806f4238c293fecc424af4c95e91ad9a288f2d0d93d6f544` — equal to `source-fetches.tsv:83` and captures metadata. `locate` → `RENDERED_TEXT_V1_LOCATE: count=1` for the recorded quote `Matches Unicode whitespace characters (as defined by str.isspace() ).` (`wc -w` = 9 ≤ 25).
- Title verified: served `<title>` is `re — Regular expression operations &#8212; Python 3.15.1 documentation`; anchor cell `SOURCES.md:47` "title Python 3.15.1 documentation" is honest.
- Full `\s` entry in the normalized fresh text: `\s For Unicode (str) patterns: Matches Unicode whitespace characters (as defined by str.isspace() ). This includes [ \t\n\r\f\v] , and also many other characters, for example the non-breaking spaces mandated by typography rules in many languages. Matches [ \t\n\r\f\v] if the ASCII flag is used.` — supports the teaches cell's Unicode/`str.isspace()` claim, the no-break-space inclusion, and the "unless ASCII matching is requested" qualifier (`re.ASCII` entry also confirms ASCII-only `\s`). The lesson's per-clause quotes (`lessons/round-26.md:163-165`) each locate on the fresh body: "non-breaking spaces mandated by typography rules in many languages." (count 1, 9 words) and "Matches [ \t\n\r\f\v] if the ASCII flag is used." (count 1).
- The cell's disclaimer "No installed-interpreter upgrade or complete normalizer equivalence follows" is appropriate scope, not overreach.

### S041 (html.html, rendered-text-v1 profile)

- `digest` → `raw_sha256=8a541381… normalized_sha256=ef8996ed93adc1b8f88a14d8c7580712f7c2060ad9e592160c92e84cf2cdb17c` — equal to `source-fetches.tsv:84`. `locate` → count=1 for `This function uses the rules defined by the HTML 5 standard for both valid and invalid character references` (`wc -w` = 18 ≤ 25).
- Title verified: `html — HyperText Markup Language support &#8212; Python 3.15.1 documentation`; anchor "title Python 3.15.1 documentation" honest.
- Both clauses verified in the fresh normalized text of `html.unescape(s)`: first sentence "Convert all named and numeric character references … to the corresponding Unicode characters." (locate count 1 each) and second sentence "This function uses the rules defined by the HTML 5 standard for both valid and invalid character references, and the list of HTML 5 named character references." The teaches cell's "under HTML 5 rules for valid and invalid references" is verbatim-supported.
- Lane-fact separation is explicitly correct: `SOURCES.md:48` ends "Tag-removal-before-unescape order belongs to the lane implementation, not this documentation." Verified the documentation says nothing about tag removal — `rendered-text-v1.py`'s step order (tags before entities) is indeed lane code (tool steps 3–4), not a doc claim. No lane fact is attributed to the docs anywhere in S039–S041 cells or `lessons/round-26.md:25-27,163-167` (lesson:27 restates "Tag-removal order is local code, not a source-doc claim").

## Admit/reject scope

- `git diff BASE..candidate -- corpus/SOURCES.md corpus/source-fetches.tsv` is purely additive: 0 deleted lines; additions are exactly the three rows (SOURCES.md:46-48, fetches:82-84), the lineage bullet (SOURCES.md:61), and the round-26 PRISMA paragraph (SOURCES.md:71). No old source/status/recheck/used-by cells changed — consistent with `expectation-migrations.json`'s claim "No old source/status/recheck/used-by changes."
- The paragraph's "Identified 3 URLs, screened 3, included 3 correction rows S039–S041; excluded 0 source URLs" is honest: `Where searched` names only the three re-opened URLs, and there are no new `rejected`-status rows in the diff. It claims no discernment beyond the three fetched URLs ("the exact Python release RSS and the registered re/html documentation URLs only"), and the stop rationale is bounded to the two relied-on teachings. The rejected-inference sentence ("release identity alone proves neither a semantic change nor an installed runtime upgrade") is a scope disclaimer, not an outside-discernment assertion.
- Recheck cadences: S039 `90d` (feed-row convention, matches S036 `90d` at `SOURCES.md:42`), S040/S041 `on-release` (matches S027/S028 at `SOURCES.md:33-34`), consistent with the accepted rearm in `plans/round-26.md:17-32`; binding rows exist at `corpus/release-clocks.tsv:30-31` (feed S039, named anchor `3.15.1`, observed `3.15.1`, `not-fired`), so the on-release rows are bound — consistent with the `RELEASE_CLOCK` population (binding coherence is FinalInstrument's axis; recorded here only as observed registry consistency).
- `used-by` = `corpus/lessons/round-26.md`, which exists in the candidate and cross-maps every clause (`lessons/round-26.md:163-167`).

## Minor observations (informational, not defects)

1. S041's bound quote omits the sentence's final `.` (and the trailing clause "and the list of HTML 5 named character references"). Locate uses substring count, so it binds honestly; within the ≤25-word bound this is a permissible truncation, and S028's historical quote does end with its period — noting only for fidelity completeness.
2. S040's bound quote (9 words) is a strict sub-string of S027's quote (drops the "For Unicode (str) patterns:" lead-in). The unicode-str qualifier still sits adjacent in the served text, and the anchor/teaches cells carry the str-pattern context, so no ground is lost; noted in case a future reviewer wants the fully-qualified quote.
3. S039's teaches cell calls 3.14.9 "the older-series backport" — verified (pubDate 13:08 newer than 3.15.1's 09:59 but series 3.14); the feed also contains 3.14.8, so "first item" wording in the cell ("the first item is the older-series 3.14.9 backport") is precise, not a claim that it is the only 3.14 item.

## Residual risk

- The check is a point re-fetch on 2026-10-21, identical-day to the wave's capture; byte-equality confirms the recorded rows describe what is served now, but a same-day re-serve cannot detect drift that occurs later — that is what the `90d`/`on-release` rechecks are for.
- I verified grounding only; I did not re-run the fleet census, the release-clock evaluate, or any production suite (L1's job after integration).
- [INFERENCE] `wc -w` counts `<title>Python` and `3.15.1</title>` as 2 words for S039; the census rule applies the same `wc -w` to the TSV field, so the measurement method matches the gate's own method.

## Verdict

All three new source URLs re-open clean: fresh bodies are byte-identical to the candidate captures (same sha256), every bound quote locates within the 25-word bound under the declared profile, both doc pages serve the 3.15.1 title, the no-break-space and ASCII-flag clauses are verbatim in the served `\s` entry, the HTML5 valid/invalid clause is verbatim in the served `unescape` entry, and lane-implementation facts are explicitly and correctly disclaimed rather than attributed to the docs. Admit/reject scope is honest and additive-only. **No defects found in this lane's scope.**
