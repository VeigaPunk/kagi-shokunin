# KnowCdpBridge1Password — C1 inventory / C2 freshness, `knowledge/cdp-bridge-1password.md`

Seat: `KagiR26.KnowCdpBridge1Password-17` (leaf scout, no dispatch, no edits to production).
BASE: `0a47dd189356ea66ec83c3891eed54526e95b89b` (HEAD == BASE, verified).
Target: `corpus/knowledge/cdp-bridge-1password.md` — 100 lines, 5023 bytes,
sha256 `d6833b54e8658a93dca5dbc51299ad82f50d33ae28fedeb6d85f305632528db3`;
worktree == `git show 0a47dd18:…` (identical sha256); `git status --porcelain` for the file
empty. Stamp row `corpus/stamps.tsv:29` carries the same sha/lines/bytes (matches).
No gate, selftest, ledger row, formatter or host probe was executed.

## Verdict

**Zero in-population current-tense numbers.** No binding row for this entry belongs in
`corpus/self-counts.tsv`; every digit-bearing line falls in an excluded class, and the two
nearest candidates (`two allowed extension IDs`; `op 2.35.0`) fail on *representation* and on
*absent host source*, not merely on judgment. Adding a `KN-CDP-*` row here would be padding
with an invented source. (OBSERVED for the digit census and the sources; INFERENCE for the
population judgment.)

This entry is therefore a counterexample to a table that treats "has digits" as "has bindable
numbers", and a counterexample to the idea that the round-27 binder covers every knowledge
entry: it covers 7 of 25, by stated rule.

## Method

Population rule read from `corpus/self-counts.tsv:53-57` (round-27 block), `corpus/QUALITY.md:118`
(QM21) and `:133` (QM26), and `corpus/lessons/round-27.md:39-47`. A number is current when it
states an artifact's *present size* with no newer value in the same clause; excluded by rule:
dated measurement sections, Erratum/Evidence/Round-N history, host/substrate observations,
positional case indexes, vendor facts, and counts with no lane-local pinned source.

I enumerated every line carrying a digit token with an explicit regex
(`[0-9][0-9A-Za-z._–-]*`, script in the transcript; not persisted) and classified each.
Lines 1-100 are all accounted for below.

## 1. Binding rows (self-counts.tsv format) — none

| id | doc | locator | source | extract | note |
|---|---|---|---|---|---|
| _(no rows: empty population)_ | | | | | |

## 2. Every digit-bearing line, exact text and disposition

| line | exact text (fragment) | token(s) | class | disposition |
|---|---|---|---|---|
| 1 | `# 1Password ↔ Chrome CDP bridge` | `1Password` | brand token (digit inside a word) | not a number |
| 3 | `Source: `~/.local/bin/the-janitor` `cmd_cdp_ensure` (L251–271),` | `251–271` | line range of an **absent host** artifact | OUT: host/substrate observation; erratum `:92-93` names "line ranges … original observations" |
| 4 | `` `cmd_cdp_status` (L273–291), profile/port vars (L22–26); observed host state `` | `273–291`, `22–26` | same | OUT, same |
| 5 | `2026-09-28 (`ls`, `op --version`, `tmux ls`). …` | date | dated measurement | OUT: date, not a count |
| 8 | `Reverify: R11-01, R11-02` | `11-01`, `11-02` | claim IDs (not quantities) | OUT: identifiers; the list length is not stated |
| 12, 16, 37, 46, 62 | `1Password …` | `1Password` | brand | not a number |
| 20 | ``\| `MUSKETEER_CHROME_PROFILE` \| `~/.local/share/…` \| L23 \|`` | `23` | host line number | OUT: absent handler; erratum; also `:96-98` records the L22–26 vs L23–27 disagreement as unverified |
| 21 | ``\| NMH dir \| `$PROFILE/NativeMessagingHosts` \| L24 \|`` | `24` | host line number | OUT, same |
| 22 | ``\| NMH manifest \| `…/com.1password.1password.json` \| L25 \|`` | `25` | host line number (plus filename digits) | OUT, same |
| 23 | ``\| `ONEPASSWORD_BROWSER_SUPPORT` \| `/opt/1Password/1Password-BrowserSupport` \| L26 \|`` | `26` | host line number | OUT, same |
| 24 | ``\| `MUSKETEER_CDP_PORT` \| `9222` \| L27 \|`` | `9222`, `27` | config literal + host line number | OUT: literal value, not a count; host line number |
| 26-28 | `Observed on this host: … is present; `op` is `/usr/bin/op` version **2.35.0**.` | `2.35.0` | vendor version + dated host observation | OUT: vendor fact (explicitly out of scope) and historical per erratum `:92` ("version") |
| 32 | `Refuses with exit 2 (`the-janitor: BrowserSupport missing: <path>`) when the` | `2` | exit code | OUT: not a count; behavior under erratum |
| 33 | `… writes the manifest `chmod 600`:` | `600` | file mode | OUT: mode, not a count |
| 36 | `{ "name": "com.1password.1password",` | name digits | identifier | not a number |
| 40-41 | `chrome-extension://aeblfdkh…/`, `…gejiddoh…/` | hex ID strings | identifiers | not numbers |
| 44 | `The two allowed extension IDs are the only origins that may talk to the host —` | word `two` | membership count in a word | OUT: not an integer (binder extract must be `[0-9]+`, `corpus/self-counts.py:110-124`); no lane-local source (see §3) |
| 45 | `a third ID silently gets nothing` | ordinal word | ordinal | not a number |
| 52 | `` and finally `cdp 127.0.0.1:9222 up\|down` from `` | `127.0.0.1`, `9222` | address + port literal | OUT: not a count |
| 53 | `` `curl -fsS --max-time 1 http://127.0.0.1:9222/json/version` `` | `1`, `9222` | timeout literal, port | OUT: literals |
| 62 | `exit 2 (L325–328). The 1Password unlock/approval popup is a human surface;` | `2`, `325–328` | exit code + host line range | OUT: not a count; absent handler |
| 70 | `… not running with `--remote-debugging-port=9222`` | `9222` | port literal | OUT |
| 71 | `` `cdp-bridge ensure` (idempotent, 600) `` | `600` | mode | OUT |
| 72 | `… the same hint the handler startup prints (`the-janitor` L110)` | `110` | host line number | OUT: absent handler |
| 73 | `… then retry (L109–111)` | `109–111` | host line range | OUT: absent handler |
| 77 | `Port `9222` and the `the-musketeer` Chrome profile are **shared** with the` | `9222` | port literal | OUT: not a count (but see §4: a present-tense *host* claim) |
| 87 | `` `the-janitor cdp-bridge open-popup` exits 2 with the quoted refusal. Neither `` | `2` | exit code | OUT; `both` (line 87-88) is a word, not an integer |
| 90 | `## Erratum (round 22 — historical source boundary)` | `22` | round id | OUT: history marker |
| 100 | `` Scoped audit: `kagi-shokunin/.ufo/waves/round-22/build/Entry03.md`. `` | `22`, `03` | round/path ids | OUT: identifiers |

Totals: 31 digit-bearing lines (regex census; lines 1,3,4,5,8,12,16,20-24,26-28,32,33,36,37,
46,52,53,62,70-73,77,87,90,100), plus three word-number candidates at lines 44, 45 and 87-88
(`two`, `third`, `both`); 0 in-population. No line states a count, size, bound or
membership of a **lane-owned** file in present tense.

## 3. Source search (why no lane-local source exists for the nearest candidates)

- **Origin count (`two`, line 44).** The only repo occurrence of
  `aeblfdkhhhdcdjpifhhbdiojplfjncoa` is `corpus/knowledge/cdp-bridge-1password.md:40`
  (`grep -rn`, whole tree minus `.ufo`; OBSERVED). A `rows:` source would be the entry
  citing itself. `corpus/surface-census.sh` independently asserts the same facts when
  the handler runs (`:490` `check mode 600`, `:499` `check json-path`, `:500`
  `check origins 2`, `:501` `check nmh-entries 1`, `:511` `check exit 2`), but that is a
  script body, not a data file: `rows:` counts data lines,
  and the ledger row that would carry it (`R11-02`, `corpus/claim-ledger.tsv:16`) pins
  `^SURFACE_CENSUS_VERBS: CLEAN \(pass=[1-9][0-9]* skip=[0-9]+\)` — pass/skip, not origins.
  So no `ledger:`/`expect:` extract can yield `2` here. This mirrors the round-27 precedent
  for `OP_REF_PROBE checks=44` (`corpus/lessons/round-27.md:39-47`): a value the row does not pin
  is not bound.
- **Handler line ranges (lines 3-4, 20-24, 62, 72-73).** No tracked copy of the handler
  exists: the only tracked files whose *names* contain `janitor` are three knowledge entries
  (`git ls-files | grep -i janitor`; OBSERVED), and `corpus/surface-census.sh` invokes
  `"$JANITOR"` by path without embedding it. `R18-01`
  (`corpus/claim-ledger.tsv:48`) pins drift counts, not line ranges; `R11-01`/`R11-02`
  (`corpus/claim-ledger.tsv:15-16`) are `[substrate]` rows and their pins are census/probe summaries. The erratum
  `:96-98` says the range disagreement "remains unverified until the handler source returns".
  No lane-local source exists; binding would require inventing one.
- **`op 2.35.0` (line 28).** Vendor version; a host observation dated 2026-09-28. The round-22
  audit (`.ufo/waves/round-22/build/Entry03.md` §3, tracked at BASE) reports a later host
  reading `2.41.0` / package `1password-cli 2.41.0-1`; **I did not re-measure it** (no host
  probe allowed/run), so that value is quoted as the audit's record, not as current state.

## 4. C2 / freshness

- The entry has **no `on-release` and no `recheck:` line**: only `Reverify: R11-01, R11-02`
  (line 8) and `Recheck on authorized source/substrate restoration` (line 99). Both are
  substrate-event triggers, not release clocks.
- `corpus/release-clocks.tsv` (31 lines, 30 data rows) has **no** `cdp`/`janitor`/`musketeer`/
  `1password-cli` row (`grep -niE`, OBSERVED). `corpus/release-clock.py` reads
  `corpus/SOURCES.md` (`:59`) and `corpus/release-clocks.tsv` (`:100`); it does not read
  `corpus/knowledge/*.md`. The new `numeric_version`/`is_regression` typing
  (`corpus/release-clock.py:369-390`, `:542-546`, `:588`, `:762`) therefore **cannot fire on this
  entry**, and there is no anchor/observation pair here to regress. That is the correct
  outcome, not a gap: the entry states no numeric release identity.
- The new REGRESSED rule would only touch this domain if someone turned `2.35.0` into an
  anchor. That would be wrong twice: (i) it is a dated host observation under the round-22
  erratum, and (ii) `2.41.0 > 2.35.0` anyway, so it would read "fired", not "REGRESSED";
  either way it would be a release-event claim with no declared feed identity (QM23), and the
  substrate needed to re-derive it (`the-janitor`) is absent.
- **Boundary observation, not a defect I can close:** the erratum (`:92-93`) names the version
  as historical but does not print the newer live value *beside* it; the newer reading lives
  only in the round-22 audit. QM21's strongest form ("history clause with a newer value beside
  it") would put it inline. I recommend **no** `KN-*` row (vendor fact, out of C1 population);
  if L1 wants the stricter form, append the audit's dated 2.41.0 reading to the erratum with
  its measurement record. (INFERENCE: judgment, and I did not measure the host.)
- A related present-tense *host* sentence I did **not** count as a number and did not resolve:
  `Port 9222 … are shared with the webzites kimi fleet` (line 77). It is a port literal, not a
  count; C2 has no anchor/observation pair for it; the round-22 audit found the cited
  `webzites` command not on PATH and the `the-musketeer` profile absent. Left as reported
  substrate debt, named here so it is not mistaken for a silent pass.

## 5. Binder blindness (acceptance counterexample)

`corpus/self-counts.py:306-325` opens only the docs named by table rows. No row names this
doc (`python3` count over `corpus/self-counts.tsv`: 56 rows, 18 `KN-*` rows over 7 docs —
`adjacency-breadth`, `adjacency-scope`, `checklist-execution`, `claim-ledger`, `drift-gate`,
`op-ref-consumption`, `surface-census`; `cdp` absent). Consequence (INFERENCE from the code
path, **not executed**): a one-digit mutation anywhere in this entry leaves the binder CLEAN.
C1's "one-digit mutation turns the binder STALE" acceptance therefore cannot be demonstrated
on this entry; it must be shown on a file that has a `KN-*` row — e.g. the round-27 lesson's
declared vector `c1-measure.py --mutate KN-LEDGER-REPRO-SELFTEST`
(`corpus/lessons/round-27.md:86`, M27-2). That run is L1's, not mine.

## 6. What I did NOT check (unrun ≠ pass)

- Did not run `corpus/self-counts.py`, `c1-measure.py`, the ledger (`verify`/`cells`/`docs`) or
  the release-clock selftest; no gate receipt exists from this seat.
- Did not probe the host: no `test -e` on the handler, no `op --version`, no
  `ls` of profiles, no CDP request. Host state is quoted only from the round-22 audit record
  and `corpus/knowledge/substrate-deferral.md`.
- Did not audit the other 24 knowledge entries, the stamp/declaration counts, `corpus/SOURCES.md`
  or the C2 fixtures.
- Did not verify the entry's vendor/mechanism claims (NMH behaviour, extension-ID refusal
  semantics); they are outside a number-inventory item and their source is absent.

## 7. Confidence

- **OBSERVED:** file identity at BASE, all digit-token lines, zero `KN-*` row for this doc,
  binder code paths and capture rules, no release-clocks row, no tracked handler copy, stamp row
  match.
- **INFERENCE:** the population judgment (excluded classes); the binder-blindness consequence.
- **UNKNOWN / left open:** whether L1 accepts the `2.35.0` boundary note; whether the lane
  later decides to bind handler line ranges once substrate returns (the erratum forbids guessing
  until then).

Tool installs/updates this seat: none.
