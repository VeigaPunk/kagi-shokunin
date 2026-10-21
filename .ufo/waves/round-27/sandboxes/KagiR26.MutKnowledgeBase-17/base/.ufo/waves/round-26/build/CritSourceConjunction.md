# CritSourceConjunction — one quote vs. multi-clause S027/S028 teachings

Seat `KagiR26.CritSourceConjunction` (critic, leaf). Observed BASE `1bf3eec48d3761580ffd375c88143232485ae814` (`git log -1 --format=%H`; worktree has only the untracked `plans/round-26.md` and `.ufo/waves/round-26/`). Axes: freshness, calibration. No production edits, no repo code executed, no installs. Network: only the three declared URLs (S027, S028, S036), fetched once each on 2026-10-21T13:38:00Z.

## Verdict

**Overclaim risk found (calibration, fixable).** Round 26 C1 says "Python source teachings are re-opened/reverified" (`plans/round-26.md:7`). Neither instrument the plan relies on can establish that for S027/S028 as written.

- The release-clock receipt never opens the doc pages for feed clocks.
- The single declared capture quote covers only one of S027's three source clauses and one of S028's two source clauses. The remaining clauses are either outside the quote or are facts about the code, not the docs.

A 3.15.1 docs edit that deleted the uncovered clauses would leave every current instrument green. The teaching itself did **not** drift: both declared entry blocks are byte-identical between the 3.15.0 and 3.15.1 builds. The defect is in what the evidence is allowed to say, not in the teaching.

## The attack

### 1. The feed receipt is not a teaching check

For `clock == "feed"`, `observe_one` fetches only `values["feed_url"]` (`corpus/release-clock.py:708`) and leaves `"located": None` (`:716`, `:727-734`). `receipt_matches` *requires* `located is None` for feed rows (`:393-398`).

S027 and S028 are feed rows bound to S036 (`corpus/release-clocks.tsv:24-25`). The round-26 receipt confirms this (`.ufo/waves/round-26/observe-1.json`, sha256 `9a1cefec…`):

`{"id":"S027","clock":"feed","url":"https://www.python.org/downloads/feed.rss","parsed_version":"3.15.1","located":null,"verdict":"fired",…}`, and the same for S028.

So "compares exact S027/S028 identities in old/new receipts" (`plans/round-26.md:7`) measures only feed drift (3.15.0 → 3.15.1). It cannot ground any statement about `re.html` or `html.html`.

### 2. The one declared quote vs. each clause

The quotes come from `corpus/SOURCES.md:33-34` and `corpus/source-fetches.tsv:70-71`. Line numbers below refer to the fresh 3.15.1 bodies in my sandbox.

| row | clause in `teaches` | where it is actually grounded | in the declared quote? |
|---|---|---|---|
| S027 | whitespace class is Unicode, per `str.isspace()` | `re.html:780` | **yes** |
| S027 | "including no-break spaces" | `re.html:781-782` ("…for example the non-breaking spaces mandated by typography rules…") | no |
| S027 | "an ASCII collapse needs the ASCII flag" | `re.html:783` ("Matches `[ \t\n\r\f\v]` if the ASCII flag is used.") | no |
| S027 | "The normalizer's whitespace class is…" | code: `corpus/rendered-text-v1.py:67` (`WS_RE = re.compile(r"\s+")`, unflagged), applied to `str` at `:74` | no (not a doc fact) |
| S028 | converts named and numeric references | `html.html:228-230` | **yes** |
| S028 | "under HTML 5 rules" | `html.html:230-232` ("This function uses the rules defined by the HTML 5 standard for both valid and invalid character references…") | no |
| S028 | "after tag removal, so escaped markup survives as text" | code: `rendered-text-v1.py:72-73` (`TAG_RE.sub` then `html.unescape`); selftest `escaped-tag-survives` at `:132` | no (not a doc fact) |

The prior seats already conceded this gap:

- Round-24 FSourceS028: "The source does not establish local step ordering; the code does."
- Round-25 FClockS028: "PARTIAL if taken as the whole teaching."

The overclaim then propagated anyway:

- Round-25 ClockS028:70-71: "the row's quote still locates … the entity-step teaching (named+numeric refs, HTML5 rules, after tag removal) is unchanged".
- `corpus/lessons/round-25.md:129-130` lists "Python S027/S028 at 3.15.0" among "re-verified teachings".

Round 26's ClockS027/S028 and XCapturePython prompts ask to "locate exact S027/S028 teachings". If they locate only the capture quote, the same broadening repeats.

### 3. Counterexample (raw mutants, sandbox only)

I deleted only the uncovered clauses from fresh copies and counted raw matches with `rg -c`:

```text
sed '781,783d' re.body > re.mutant-no-ascii-nbsp.body          # sha256 f41b79cf…
  re.body                       quote_raw=1 nbsp_clause=1
  re.mutant-no-ascii-nbsp.body  quote_raw=1 nbsp_clause=0  (re.ASCII-flag sentence at :783 gone)
sed -e '230s/.*/characters.<\/p>/' -e '231,232d' html.body > html.mutant-no-html5.body   # sha256 440f578d…
  html.body                     quote_raw=1 html5_clause=1
  html.mutant-no-html5.body     quote_raw=1 html5_clause=0
```

In both mutants the declared quote still locates once, and the feed receipt cannot see the change. A "teaching holds" disposition based on the quote plus the receipt would therefore be false for a page that had dropped the ASCII-flag, no-break-space or HTML 5 clauses.

These counts are raw-byte only. I did not run `rendered-text-v1.py locate`; the quote's text lies wholly in untouched lines (`re.html:780`, `html.html:228-230` prefix), so normalized locate is expected to stay `count=1` [INFERENCE].

## What actually drifted (bounded, for the disposition count)

**Fresh fetch.** Declared profile `curl-fsSL-compressed-v1` (`source-fetches.tsv:14-15`), `env -i PATH=/usr/bin:/bin`, every request HTTP 200, final URL equal to the request URL, exit 0:

| object | sha256 | bytes | identity |
|---|---|---|---|
| `re.html` | `0724d815…c8aa5` | 251811 | title "Python 3.15.1 documentation", footer 13:02 UTC |
| `html.html` | `8a541381…a7122` | 20100 | title "Python 3.15.1 documentation", footer 13:02 UTC |
| `feed.rss` | `11c86a34…ca66b` | 3357 | items Python 3.14.9, 3.15.1, 3.16.0a1, 3.15.0, … |

The feed sha256 equals the receipt's S027/S028 `sha256`.

**Comparison against 3.15.0.** The only 3.15.0 bodies left are *uncommitted* round-25 scratch:

- `/fast/scratch/kagi-r25/ClockS027-2/re.html`, sha256 `453e9e17…` (the round-25 07:27 build)
- `/fast/scratch/kagi-r25/ClockS028/fresh-S028.html`, sha256 `cd1a74e6…`

Neither is the committed pin. The committed pins are `d85d77e3…` and `b4594556…`, from an earlier 05:52 build. Results:

- **Whole-page diff, 3.15.0 → 3.15.1:** 6 changed lines on each page (12 `<`/`>` lines). All of them are the version label (title, search title, two breadcrumbs), the `documentation_options.js?v=` hash, and the footer timestamp.
- **S027 entry block** (`re.html:780-784`): `old27.entry` = `new27.entry` = sha256 `6d0e7fc4…`, `diff` exit 0.
- **S028 entry block** (`html.html:226-236`): `old28.entry` = `new28.entry` = sha256 `e135a859…`, `diff` exit 0.

So the drift disposition is **version-label and build only; zero clause-text drift in either declared entry**. This is author-side point evidence against an unretained scratch body, not a committed receipt.

**Version-pinned URLs.** The `/3.15/` alias also serves 3.15.1 now: peer `ClockS027-artifacts/re315.body` is byte-identical to `re3.body`, sha256 `0724d815…`. It cannot stand in for 3.15.0. Peer file `ClockS028-evidence/html3150rel.body` carries a 3.15.0 title, but its URL is not recorded in its headers and it is not a registry-declared source.

## Smallest safe correction

1. **Do not let the feed receipt or the single capture quote carry "teaching re-verified".** Record S027/S028 dispositions per clause, e.g. `S027: quote-located; ascii-flag: located; nbsp: located; normalizer-class: code rendered-text-v1.py:67,74`.
   - Give the no-break-space, ASCII-flag and HTML 5 clauses their own ≤25-word located quotes from the declared pages:
     - S027: "Matches [ \t\n\r\f\v] if the ASCII flag is used."
     - S027: "for example the non-breaking spaces mandated by typography rules in many languages."
     - S028: "This function uses the rules defined by the HTML 5 standard for both valid and invalid character references"
   - Cite the code clauses to `rendered-text-v1.py` and selftest `escaped-tag-survives`, never to the Python docs.
2. If extra quotes are not added, **reject the overclaim in the text**: "declared quote locates; other clauses observed in surrounding text, not bound". Superseding rows S040/S041, if minted, must state that the anchor/version changed (3.15.0 → 3.15.1) while the teaching text is unchanged. They must not state "teaching re-verified".
3. Keep round 25 append-only. Do not edit `lessons/round-25.md:129-133` or round-25 ClockS028. Name their "re-verified teachings" broadening as a round-26 correction instead.

## Limits

- The teaching applies to docs as served, not to the interpreter that runs the normalizer. Round-25 ClockS027 recorded `/usr/bin/python3 3.14.8`; whether its `str.isspace()` Unicode database matches the 3.15.x docs was not checked [INFERENCE: possible divergence].
- I did not run `release-clock.py`, `rendered-text-v1.py`, the selftests or any gate.
- Sandbox artifacts: `.ufo/waves/round-26/sandboxes/CritSourceConjunction/` (`re.body`, `html.body`, `feed.body`, `fetched_at.txt`, `{old,new}{27,28}.entry`, two `*.mutant*.body`).
