# CritQuoteShape — round 23 falsification (critic seat)

**Verdict: DEFECT (calibration; fixable).** `SC_FETCH` checks only the shape of the quote and location fields. On a byte copy of the current real tree, a fabricated quote with a plausible location prints the same `SOURCES_CENSUS: CLEAN (rows=26 …)` line, exit 0, that `R21-02` pins.

Two sub-checks named in the plan do not hold as written:
- **"location present":** a blank location passes.
- **"quote bound":** a blank quote passes, and a 60-word quote passes when its words are joined by U+2009.

**Disclosure is partial and contradicted.**
- What is disclosed: `lesson:187` says "quote text is not substring-checked", and `claim-ledger.tsv:52` says "no network/content validation".
- What still overclaims: `lesson:106-108` (D7 "bind … located quote"), `source-fetches.tsv:2,25,30` and the `SC_FETCH` header's STATED BOUND, which covers only the legacy digests.
- What is disclosed nowhere: that the location is never checked, the blank-field acceptance, and the separator bypass.

Attacked: `corpus/sources-census.sh:266-267` (quote) and `:274` (location). Axes: calibration (primary), freshness, operability.

## Measurement conditions (the tree moved during the wave)

All runs were on 2026-10-21 between 00:59 and 01:06 -0300. Production files changed while I was measuring, so every result below is pinned to a sha256.

| file | digests observed (old → new) | relevance |
|---|---|---|
| `corpus/sources-census.sh` | `80966e20…` (mtime 00:57:55) → `24d834cc…` (01:02:21) | quote/location rules are byte-identical in both. All counterexamples ran on `24d834cc…`; sha was checked before and after each run, with no change. |
| `corpus/source-fetches.tsv` | `ccc9ae6e…` → `a78fde7b…` (01:04:32) | only S022's location changed (see F3) |
| `corpus/lessons/round-23.md` | `d5520988…` → `bce51c92…` → `2f53cf69…` (01:04:15) | cited lines are from `2f53cf69…` |
| others cited | `SOURCES.md` `06dde644…`; `plans/round-23.md` `cb1287ba…`; `claim-ledger.tsv` `0d3d7500…` | — |

Gate code at `24d834cc…`:
- `:108` `export LC_ALL=C`
- `:245` `while IFS=$'\t' read -r … fquote fnorm fnsha floc`
- `:266` `words=$(printf '%s' "$fquote" | wc -w)`
- `:267` `[[ -n $fquote && $words -le 25 ]] || finding SC_FETCH "id=$fid quote"`
- `:274` `[[ ${#floc} -ge 8 ]] || finding SC_FETCH "id=$fid location"`

Nothing else reads columns 13 (quote) or 16 (location). No fetched bytes or normalized text are committed, so no committed check can tie a quote to its page. `normalized_sha256` covers the whole page text, not the quote. S021 and S026 carry different quotes under the same `ed949658…`.

## Commands run and exits

1. **Real tree, gate `80966e20…`:** `bash corpus/sources-census.sh` (cwd lane), run twice.
   - Both times: `corpus/sources-census.sh: line 242: S007: unbound variable`, **exit 1, no verdict line**.
   - Concurrent `bash corpus/sources-census.sh --selftest` → `SOURCES_CENSUS_SELFTEST: PASS (59 cases)`, exit 0. See F6.
2. **Real tree, gate `24d834cc…`:**
   - `bash corpus/sources-census.sh` → `SOURCES_CENSUS: CLEAN (rows=26 A=24 B=0 C=2 queued=1 mined=24 rejected=1 entries_sourced=4 legacy=21)`, exit 0.
   - `bash corpus/sources-census.sh --selftest` → `PASS (59 cases)`, exit 0. All 12 `fetch-*` cases are ok.
3. **Counterexample harness.** Each case ran `bash /home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/sources-census.sh verify --root /tmp/critquoteshape.bugyp62z/case-<name>`.
   - Fixtures: a copy of the base fixture, made by extracting `base_fixture()`/`rep()` verbatim from the gate; or a byte copy of the real `SOURCES.md`, `source-fetches.tsv`, `knowledge/`, `lessons/` (TSV `ccc9ae6e…`).
   - Each case changes one TSV field. `diff -rq` confirmed each mutation was non-inert.
   - Controls: base fixture → CLEAN rows=4, exit 0; real copy → the `R21-02` CLEAN line, exit 0.
4. **Reproduction script.** `bash /tmp/critquoteshape.bugyp62z/repro.sh` → script exit 0. Full text and output are in the appendix; anyone can re-run it.
5. **Public re-fetch:** `curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)' <url>` for each of the 9 distinct TSV URLs. Body captured from stdout; every exit 0.
   - Raw sha256 and byte counts equal the TSV for S017–S019 and S021–S026. S020 differs, as expected for its volatile representation.
   - My rendered-text-v1 implementation (strip script/style, tags → single space, `html.unescape`, `\s+` → space, trim) reproduces **all 10** declared `normalized_sha256` values.
   - Every shipped quote occurs ≥1 time in its normalized page. Every fabricated quote below occurs **0** times.
6. **`wc` probe** (GNU coreutils `wc` 9.12): 60 words joined by each separator, `printf '%s' "$Q" | wc -w` under `LC_ALL=C`.
   - NBSP U+00A0 and U+2060 → 60.
   - U+2009, U+202F, U+2002, U+2007, U+205F, U+1680, U+3000 → **1**. Under `C.UTF-8` these count 60.

## Counterexamples

| case | fixture | mutation (TSV column) | census exit | verdict / findings |
|---|---|---|---|---|
| CE-A (primary) | real copy | S023 col 13: `All static secrets in Vault are required to have a lease.` (one-word inversion; 0 occurrences on the page). Location left as `Lease, renew, and revoke`. | **0** | same CLEAN line as `R21-02` |
| CE-B | real copy | S024 col 13: `max_versions (int: 0) – Versions are kept forever; Vault never deletes an old version of a key.` (0 occurrences; contradicts the registry's own `Quote:` at `SOURCES.md:30`). S022 col 16: `Token hierarchies and orphan tokens` (a heading from another page). | **0** | CLEAN |
| R3 | real copy | S026 col 13: `Revoking a parent token never affects its child tokens or their leases.` (0 occurrences). S021 has the same URL and the same normalized digest, so the new same-URL agreement check at `:285-290` passes. | **0** | CLEAN |
| R5 | real copy | S025 col 16: foreign heading `Token hierarchies and orphan tokens` | **0** | CLEAN |
| CE-C | real copy | S021 col 13 = `" "` (one space, 0 words); col 16 = 8 spaces | **0** | CLEAN |
| CE-D | real copy | S026 col 13 = 60 × `word` joined by U+2009 (`wc -w` = 1) | **0** | CLEAN |
| R7 | real copy | S023 col 13 = the declared quote extended to 60 consecutive words of the real page text, joined by U+2009 | **0** | CLEAN |
| B1 / B6 | base | S002 fabricated quote. B6 additionally sets digest = sha256(""), bytes=1, a fabricated normalized digest, and a foreign location. | **0** | CLEAN rows=4 |
| B2 / B3 | base | blank quote (`" "`) / blank location (8 spaces) | **0** | CLEAN |
| B4b / B4c | base | 60 words joined by U+2009 / U+3000 | **0** | CLEAN |
| NEG (live check) | real copy | S026 col 13 = 26 ASCII-space words | 1 | `FINDING SC_FETCH id=S026 quote` |
| NEG (live check) | real copy / base | 60 words joined by NBSP | 1 | `FINDING SC_FETCH id=S0xx quote`. `wc` 9.12 treats NBSP as a separator. |
| B5 | base | empty quote `""` | 1 | findings `normalization`, `normalized-digest-not-applicable`, `location`, and **no `quote` finding** (F5) |

## Findings

- **F1 — fabricated quotes pass (calibration).** The quote rule only requires a non-empty field with ≤25 C-locale `wc -w` tokens. The location rule only requires 8 or more bytes. Neither is tied to page bytes, the registry anchor, or the other copies of the quote. A semantically inverted quote under a plausible heading (CE-A) prints the identical pinned CLEAN line. **This is a tradeoff to state, not to code away:** the gate is offline by design (header: "no network").

- **F2 — the plan's named checks do not hold (fixable defect).** `plans/round-23.md:29` promises "quote bound, location present".
  - CE-C: a zero-word quote and an all-space location pass.
  - CE-D and R7: >25-word quotes pass through C-locale tokenization.
  - TSV header `:25` says "<=25 whitespace-separated words"; U+2009 is whitespace to a reader, but the gate does not count it as a separator.

- **F3 — a wrong location shipped and the gate could not see it (data instance, now corrected).**
  - At TSV `ccc9ae6e…`, `source-fetches.tsv:42` had location `JWT verification, Vault 1.17 note`.
  - In normalized text the quote sits at offset 3538: after H1 `Use JWT/OIDC authentication` (2921) and before the first H2 `OIDC authentication` (4457). The only `JWT verification` heading is an H3 at offset 10630. The registry anchor (`SOURCES.md:28`) correctly says `Introduction Vault 1.17 note`.
  - The census was CLEAN on the wrong value (real-copy control). It was also CLEAN on the corrected value: my R4 case, and the in-tree fix to `Introduction, Vault 1.17 Note` at `a78fde7b…`.
  - `RevS022.md:72-85` found this independently. A manual re-fetch fixed it; the gate never flagged it.

- **F4 — duplicate authority (calibration).** The S024–S026 quotes exist in three places:
  - TSV column 13;
  - the `Quote: “…”` text in `SOURCES.md:30-32`;
  - `lesson:27-29`.

  Today the three agree, but no gate compares them. CE-B shows the TSV can contradict the registry and still pass.

- **F5 — a known lesson regressed (minor).**
  - `:245` reads the TSV with `IFS=$'\t' read`, which collapses empty fields. The lane recorded exactly this hazard at `claim-ledger.sh:116-118` (round-11 A15; `LOG.md:291`), and `split_tab` exists to avoid it.
  - Still fail-closed: a shortened row always leaves `floc` empty.
  - But the empty quote is misattributed (B5), and no selftest case covers an empty or blank quote.

- **F6 — the selftest PASS did not mean the real tree runs (operability, transient).**
  - At gate `80966e20…`, line 242 wrote to an undeclared `SUPERSEDED` array under `set -u`. The real tree aborted (exit 1, no verdict line, against the header's "VERDICT (last line, always)").
  - At the same moment `--selftest` printed PASS (59), because the fixture has no `supersedes S…` row.
  - Fixed at `24d834cc…` by deleting the dead loop. The fixture still lacks this real-tree row shape.

- **F7 — premature provenance (calibration).**
  - `lesson:179` says "The 64-seat falsification wave confirmed the three claims and named these bounds".
  - At the lesson's mtime (01:04:15), 18 report files existed in `falsify/`, and this seat's had not been written. This seat falsifies two named C2 sub-checks (F2).
  - The sentence credits the whole wave with confirmation before the wave finished.

## Does the lesson or report disclose the bound?

| place | text | status |
|---|---|---|
| `corpus/lessons/round-23.md:185-187` | "C2's SC_FETCH is shape-and-identity, not content verification … quote text is not substring-checked" | **partial.** Silent on location, blank fields and the separator bypass. |
| `corpus/claim-ledger.tsv:52` (R21-02 note) | "no network/content validation by this command" | discloses, but only in general terms |
| `corpus/lessons/round-23.md:106-108` (D7) | "`SC_FETCH` bind every row … to … row-line digest and located quote" | **overclaim**; contradicts `:187` in the same file |
| `corpus/source-fetches.tsv:2` | "D7: bind every mined row's quote and digest to a declared representation" | **overclaim**, no bound |
| `corpus/source-fetches.tsv:25,30` | "located quote, <=25 whitespace-separated words"; "section/heading the quote was located under" | describes intent, which the gate does not enforce |
| `corpus/sources-census.sh:56-75` (`SC_FETCH` header) | "it declares … quote normalization, normalized digest and location"; the STATED BOUND covers legacy digests only | **no quote or location bound**; this is what `-h` shows a future reader |
| `plans/round-23.md:24-29` | "located ≤25-word quote" … "quote bound, location present" | names checks the code does not enforce (F2) |

## The bound the C2 claim must state

> `SC_FETCH` checks that `quote` and `location` are present and have the right shape; it does not check their content. A quote is non-empty and has ≤25 tokens as counted by `wc -w` under `LC_ALL=C`; a location is free text of ≥8 bytes. No committed bytes bind either one to the page. `normalized_sha256` identifies the whole normalized page, not the quote. Copies of the quote in `SOURCES.md` and the lesson are not compared with the TSV. Whether a quote is really located is established only by a manual re-fetch: 10/10 shipped quotes were found in their pages on 2026-10-21, and S022's location was corrected after review.

## Smallest safe correction

1. **Text (required).**
   - Change D7 (`lesson:106-108`) and `source-fetches.tsv:2` from "bind … located quote" to "carry a declared, shape-checked quote and location".
   - Add the bound above to the `SC_FETCH` STATED BOUND (`sources-census.sh:67-75`) and to `lesson:185-187`.
   - Change `lesson:179` so confirmation is credited only to reports that have landed, or write it after the wave closes.
2. **Code (about 3 changed lines plus 3 selftest cases, so that the plan's named checks become true).**
   - `:266` count in UTF-8: `LC_ALL=C.UTF-8 wc -w`, or reject U+2000–U+200A, U+202F, U+205F, U+3000 and U+1680 in `fquote`.
   - `:267` require `words -ge 1`.
   - `:274` require `${#floc} -ge 8 && $floc =~ [^[:space:]]`.
   - Add selftest cases for a blank quote, a blank location, and a 26-word U+2009-joined quote.
   - Optionally move `:245` to `split_tab`-style parsing, so an empty quote raises `quote`.
3. **Data:** none outstanding. S022 is already corrected at `a78fde7b…`.
4. **Optional capability for a later round (not needed this round once the bound is stated).** Add an opt-in networked `--refetch` reviewer mode that re-applies rendered-text-v1 and asserts that the quote occurs in the page and that the declared heading comes before it. My script reproduced all 10 normalized digests and located all 10 quotes, so this is feasible.

**For the judge:** F1 is a tradeoff and must be stated, which is now only half done. F2 and F5 are fixable defects measured against the round's own plan. F4 is a duplicate authority. F6 is transient but shows the selftest fixture lacks real-tree row shapes. F7 must not reach the report as written.

## Limits

- I did not re-audit per-row raw digests; the RevS0xx seats own that. Raw matches were observed only as a by-product of the re-fetch.
- The S022 heading offsets come from my own normalization. It reproduces the author's declared normalized digests exactly.
- I did not run a legacy `claim-ledger.sh verify` or any host-bound row.
- No installs or updates.
- Scratch `/tmp/critquoteshape.bugyp62z` was removed at 01:08 -0300 (`test ! -e` confirmed). The appendix script recreates its own `mktemp -d` dirs and needs no scratch.
- My only lane write is this file.

### Post-write drift (01:08–01:09 -0300)

After this report was written, the lane moved to lesson `cf79cd0c…` and TSV `846b2037…`. The gate is unchanged at `24d834cc…`.

| item | where it is now | status |
|---|---|---|
| D7 "bind … located quote" | still at `lesson:106-108` | overclaim remains |
| "The 64-seat falsification wave confirmed the three claims" (F7) | moved to `lesson:183` | unchanged |
| "quote text is not substring-checked" | moved to `lesson:191` | unchanged |
| `source-fetches.tsv:2` | now reads "bind every mined row WITHOUT an in-row pin to a declared representation" | no longer names the quote; the quote overclaim there is gone |
| `source-fetches.tsv:25` | "located quote, <=25 whitespace-separated words" | unchanged |
| S022 location | `Introduction, Vault 1.17 Note` | still the corrected value |

F1, F2, F4 and F5 depend only on gate code, which is byte-identical at `24d834cc…`, so they still apply. I re-grepped F7's sentence at `lesson:183`. F6 was transient. I did not re-run the census against TSV `846b2037…`.

## Appendix — `repro.sh` (run: `bash /tmp/critquoteshape.bugyp62z/repro.sh`, exit 0)

```bash
#!/usr/bin/env bash
set -uo pipefail
L=/home/vgpnk/Projects/shokunin/kagi-shokunin
G="$L/corpus/sources-census.sh"
TS=$(printf 'word\xe2\x80\x89%.0s' $(seq 60))            # 60 words, U+2009 THIN SPACE
NB=$(printf 'word\xc2\xa0%.0s' $(seq 60))                # 60 words, U+00A0 NBSP
W26=$(printf 'w%d ' $(seq 26))                           # 26 ASCII-space words
fresh() { local t; t=$(mktemp -d) && mkdir -p "$t/corpus" && cp -R "$L/corpus/SOURCES.md" "$L/corpus/source-fetches.tsv" "$L/corpus/knowledge" "$L/corpus/lessons" "$t/corpus/" && printf '%s' "$t"; }
edit() { awk -F'\t' -v OFS='\t' -v id="$2" -v c="$3" -v v="$4" '$1==id && !/^#/ {$c=v} {print}' "$1/corpus/source-fetches.tsv" >"$1/f" && mv -- "$1/f" "$1/corpus/source-fetches.tsv"; }
run() { local out rc; out=$(bash "$G" verify --root "$2" 2>&1); rc=$?
  printf '%-34s exit=%s findings=[%s] last=%s\n' "$1" "$rc" "$(grep '^FINDING' <<<"$out" | paste -sd ';' -)" "${out##*$'\n'}"; rm -rf -- "$2"; }
echo "gate sha256 before: $(sha256sum "$G" | cut -c1-64)"
T=$(fresh); run control-unmodified "$T"
T=$(fresh); edit "$T" S023 13 'All static secrets in Vault are required to have a lease.'; run CE-A-S023-inverted-quote "$T"
T=$(fresh); edit "$T" S024 13 'max_versions (int: 0) – Versions are kept forever; Vault never deletes an old version of a key.'
            edit "$T" S022 16 'Token hierarchies and orphan tokens'; run CE-B-S024-quote+S022-foreign-loc "$T"
T=$(fresh); edit "$T" S021 13 ' '; edit "$T" S021 16 '        '; run CE-C-S021-blank-quote+blank-loc "$T"
T=$(fresh); edit "$T" S026 13 "$TS"; run CE-D-S026-60-words-thinspace "$T"
T=$(fresh); edit "$T" S026 13 "${W26% }"; run NEG-S026-26-ascii-words "$T"
T=$(fresh); edit "$T" S021 13 "$NB"; run NEG-S021-60-words-nbsp "$T"
echo "gate sha256 after:  $(sha256sum "$G" | cut -c1-64)"
```

Output (01:05:17 -0300, TSV `a78fde7b…`):

```
gate sha256 before: 24d834cc85344b762b485ef2b1c44cdbddab4e641f96acbaf2853823b02af057
control-unmodified                 exit=0 findings=[] last=SOURCES_CENSUS: CLEAN (rows=26 A=24 B=0 C=2 queued=1 mined=24 rejected=1 entries_sourced=4 legacy=21)
CE-A-S023-inverted-quote           exit=0 findings=[] last=SOURCES_CENSUS: CLEAN (rows=26 A=24 B=0 C=2 queued=1 mined=24 rejected=1 entries_sourced=4 legacy=21)
CE-B-S024-quote+S022-foreign-loc   exit=0 findings=[] last=SOURCES_CENSUS: CLEAN (rows=26 A=24 B=0 C=2 queued=1 mined=24 rejected=1 entries_sourced=4 legacy=21)
CE-C-S021-blank-quote+blank-loc    exit=0 findings=[] last=SOURCES_CENSUS: CLEAN (rows=26 A=24 B=0 C=2 queued=1 mined=24 rejected=1 entries_sourced=4 legacy=21)
CE-D-S026-60-words-thinspace       exit=0 findings=[] last=SOURCES_CENSUS: CLEAN (rows=26 A=24 B=0 C=2 queued=1 mined=24 rejected=1 entries_sourced=4 legacy=21)
NEG-S026-26-ascii-words            exit=1 findings=[FINDING SC_FETCH id=S026 quote] last=SOURCES_CENSUS: FAILED (findings=1 rows=26)
NEG-S021-60-words-nbsp             exit=1 findings=[FINDING SC_FETCH id=S021 quote] last=SOURCES_CENSUS: FAILED (findings=1 rows=26)
gate sha256 after:  24d834cc85344b762b485ef2b1c44cdbddab4e641f96acbaf2853823b02af057
```
