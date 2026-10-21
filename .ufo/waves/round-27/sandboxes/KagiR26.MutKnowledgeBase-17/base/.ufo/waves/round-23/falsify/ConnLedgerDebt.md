# ConnLedgerDebt — parent-audit findings vs round-23 dispositions

Seat: ConnLedgerDebt (connector, leaf, read-only). No subagent dispatch. No production
edit; the only write is this file. No install, no network fetch, no host gate, no legacy
`claim-ledger.sh verify`, no host-bound ledger row.

## 0. What was attacked

The round-23 build wave is 43 claim-ledger row audits + 23 source-row audits under
`.ufo/waves/round-23/parent-build/`. The round's own claim is that inherited/parent
findings are "reported as debt, not credited" (`LOG.md` Round 23, final paragraph;
`SCORECARD.md:844`). I tested that claim: every explicit finding (F*/M*/Finding N,
"one real contradiction", a consumer-visible risk with a falsifier) was mapped to

- **FIXED** — a tree change in this round closes it;
- **DEBT** — named in a durable disposition surface (`corpus/lessons/round-23.md`
  D1–D9/M23-*; `SCORECARD.md` "Remaining named debt"; `LOG.md` Round 23;
  `corpus/closure-dispositions.json`; a row note/declared bound);
- **BOUND** — a pre-existing or newly declared accepted bound, not a drop;
- **DROPPED** — no fix, no debt pointer, no bound. A falsify seat that re-checks it
  does not count as a disposition.

Selection rule: material findings only (defect, contradiction, gate-coverage gap, or
risk with a stated fix). "What C1/C3 must retain" paragraphs and pure narrative are
not counted as findings. Severity is the parent's own (HIGH/MED/LOW) where stated.

### Snapshot (the tree moved during the audit — this is part of the finding)

All paths relative to `/home/vgpnk/Projects/shokunin/kagi-shokunin`. Pinned at
2026-10-21T04:16:25Z:

| artifact | sha256 (first 16) |
|---|---|
| `corpus/sources-census.sh` | `2d1bbbe36ed21c27` |
| `corpus/source-fetches.tsv` | `6e26e14032729070` |
| `corpus/lessons/round-23.md` | `4e8ab66f3e14c850` |
| `corpus/claim-ledger.tsv` | `ed125ca5aefb4bc6` |
| `SCORECARD.md` | `94a34c9fd0de49e8` |
| `LOG.md` | `d052458cfc0854b1` |

(Mtimes moved continuously during the audit and are deliberately not quoted; the
hashes are the anchor.)

Observed churn during the falsify wave (same paths, minutes apart):
`corpus/sources-census.sh` `24d834cc` → `6d4190a7` → `511deb27` → `2d1bbbe3`;
`round-23.md` `2f53cf69` → `993e114a` → `7a8e3b45` → `03d17afb` → `49632920` →
`4e8ab66f`; `claim-ledger.tsv` `a59dbbc`/`0d3d7500` → `3634eb71` → `59869459` →
`ed125ca5`; `SCORECARD.md` `1d7210b3` → `7dc220f6` → `5948e4fd` → `94a34c9f`.
`parent-build/` grew from 58 to 66 reports between 01:03 and 01:14, the last being
`ClaimR22X01.md`; `ClaimR22X01.md` was absent when my map began.

Consequence: line anchors below are for the pinned snapshot; the quoted text is the
stable anchor. A later reader MUST re-anchor by content, not by line number.

### Commands actually run (exit codes)

```
python3 corpus/closure-dispositions.py                     # exit 0
  CLOSURE_DISPOSITIONS: CLEAN (obligations=15 fixed=7 reported=2 operator_owned=1 no_action=5 rejected=0 pointers=15)
python3 corpus/closure-dispositions.py --selftest          # exit 0, PASS (13 cases)
bash corpus/sources-census.sh --selftest                   # exit 0, PASS (59 cases)
bash corpus/claim-ledger.sh cells --root corpus/fixtures/cells-hermetic \
  --claims .../claims.tsv --stamps .../stamps.tsv \
  --scorecard .../SCORECARD.md --docs .../SCORECARD.md      # exit 0
  CELL_AUDIT: CLEAN (cells=6 row_pointed=6 stamp_pointed=1 uncited=0 missing_ids=0 rows_run=2 row_deferred=0 row_failures=0 stale_pointers=0 self_skipped=0 orphans=0)
bash corpus/checklist-run.sh --selftest                    # exit 0, PASS (34 cases)
bash corpus/drift-pins.sh --selftest                       # exit 0, PASS (13 cases)
grep -c '^## Round ' SCORECARD.md                          # 27, exit 0
```

In-memory predicate demonstrations (no files created):

```
bash -c 'e="^OP_REF_SELFTEST: PASS \(36 cases\)"; l="OP_REF_SELFTEST: PASS (36 cases) skipped=1"; [[ $l =~ $e ]] && echo MATCH'
  # MATCH  → R12-02's ERE is a prefix match
printf '# own\t/HOME/x\n' | grep -cE '^# own[[:space:]]+.HOME/'     # 1 → `.HOME/` accepts an arbitrary char
printf 'op%ss_%0600d\n' '' 0 | wc -w                                # 1 → a 600+ char token is one word
```

Static negative checks (read-only): `grep -c 'ops_' corpus/sources-census.sh` = 0;
`cred_scan` calls at `sources-census.sh:286` (SOURCES.md) and `:312` (sourced entries)
only — never on `corpus/source-fetches.tsv`; quote bound `:266` (`wc -w`), location
bound `:274` (`${#floc} -ge 8`); README hardlink claim at `corpus/README.md:36`;
`drift-pins.sh:428` is the only `ln` (symlink), nlink branch at `:133-136`;
`scope-gate.sh:48` says "missing/empty input file is a setup error"; `checklist-run.sh`
has no delegate-existence test; `op-ref-probe.sh`, `checklist-run.sh`,
`transcript-scan.sh`, `scope-gate.sh`, `corpus/README.md` have no diff vs `d218603`
(`git diff --stat` empty).

## 1. Headline

**117 material findings across 66 parent reports: 19 fixed (one partial), 11 reported
debt, 9 covered by a declared bound, 78 silently dropped.** The class-level debt list
(`SCORECARD.md:859-862`) has five items; `LOG.md:1218-1220` names four; the lesson
M-table has four rows. Those pointers cover a minority of the audit.

The round did consume some parent findings during the wave (DEEP default, R21-01 note,
C2 representation/normalization, S014/S016/S018/S019/S020/S022 captures, the same-URL
rule removal, D3 caveat, C3 fixture growth). Those fixes are real in the tree. But they
were applied while the parent reports were still landing, and none of the 78 dropped
items below is named in a durable surface at the snapshot.

## 2. FIXED (19)

| id | seat / finding | tree evidence |
|---|---|---|
| F01 | ClaimR11X02 — `DEEP` in the environment escalates the safe set to the deep set (side effects, not just verdict) | `corpus/surface-census.sh:82` adds `DEEP=""`; diff vs `d218603` is exactly this line |
| F02 | ClaimR13X01 — round-heading count 25→27 with migration | `corpus/claim-ledger.tsv` R13-01 expect `^27$`; `grep -c '^## Round ' SCORECARD.md` = 27, exit 0 |
| F03 | ClaimR16X02 §7 primary — C3 fixture reusing real rows false-fails at `--root` | fixture has fixture-local `claims.tsv`/`stamps.tsv`/`SCORECARD.md`/`adjacency.tsv`; R23-01 CLEAN `rows_run=2 row_failures=0`, exit 0 |
| F04 | ClaimR21X01 — note said a missing `op` binary reads as DRIFT exit 1; code prints SETUP exit 2 | `claim-ledger.tsv` R21-01 note ("SETUP exit 2 (op-ref-probe.sh:525-526)"); `corpus/knowledge/op-ref-consumption.md:362-365`; `LOG.md:1209-1212` |
| F05 | SourceS008 M1 — rendered-text quote not a byte substring, normalization undeclared | `round-23.md:46-53` + `source-fetches.tsv:25-30`: rendered-text-v1, strip/unescape/collapse/trim, quotes not raw substrings |
| F06 | SourceS008 M3 — two different byte domains labelled "the S008 line hash" | `round-23.md:44-49` + TSV header `:15-21`: representation/bytes declared next to digest; legacy bounded |
| F07 | SourceS009 — feed/print/undecoded bytes could be attested as "representation" | `sources-census.sh:257`: representation closed to `decoded-http-body-v1`/`-volatile-v1` |
| F08 | SourceS010 — gzip vs identity wire bytes make "Fetch sha256" ambiguous | representation mandatory, digest/bytes are the decoded body (TSV header `:15-21`; census `:257`) |
| F09 | SourceS014 — non-literal quote, under-declared anchor, unreproducible digest | S025 correction row (lesson Gate table; `SOURCES.md` S025) |
| F10 | SourceS016 — non-reproducible pin, line-wrapped quote, missing supersession edge | S026 correction row (lesson Gate table; `SOURCES.md` S026) |
| F11 | SourceS018 M1 — digest is a one-day point observation with no representation | TSV `S018` row (volatile, fresh digest, normalized, quote, location) |
| F12 | SourceS019 F1/F2 — stored bytes not reproducible; HTML vs markdown representation | TSV `S019` row (volatile, decoded body, rendered-text quote) |
| F13 | SourceS020 F1 — declared normalizer omitted the trim step | TSV header `:26-30` and lesson `:46-47` now declare "trim both ends" |
| F14 | SourceS020 F4 — SPOT-03 called S020–S023 "historical records" although S020 is active | `corpus/closure-dispositions.json` SPOT-03 note: "remain active admitted evidence" |
| F15 | SourceS020 F8 — header said same-URL raw agreement unconditionally; code exempted volatile; no volatile test | code now has no same-URL rule at all, header says "no cross-capture equality" (`:64-66`), `fetch-disagree` expects one finding (`:553`) |
| F16 | SourceS022 F1/F2/F3 — no provenance, "fetched bytes" ambiguous, one URL/two digests | TSV `S022` row; decoded-body domain; id-keyed rows |
| F17 | SourceS013 F4 — per-row TSV vs one URL/two operative digests | id-keyed TSV; duplicate-provenance; no URL-keyed equality |
| F18 | SourceS017 C-1 — chrome-coupled normalized digest vs a enforced same-URL equality | the equality rule was removed (`sources-census.sh` fetch block; header `:64-66`), matching lesson `:52-54` |
| F19 | ClaimR17X02 §5(b) — hermetic kill test: cite the stamped data file, not only the count row | fixture freshness cell cites `corpus/adjacency.tsv` and stamps it (partial: the real `SCORECARD.md:844` cell was not changed — see X40) |

## 3. REPORTED DEBT (11)

| id | seat / finding | pointer |
|---|---|---|
| D01 | ClaimR11X08 F1 citations red at base; F2 SKIP-SELF absorbed by CLEAN | `round-23.md` D9 paragraph + M23-3; `SCORECARD.md:859-861`; `LOG.md:1218` |
| D02 | ClaimR11X09 §7 — no selftest case for an id-shaped positional | `round-23.md:86-92` ("not claimed as fixed"); closure JSON D3 note |
| D03 | ClaimR13X01 rec 2 — identity-free round-heading count | `SCORECARD.md:862` |
| D04 | ClaimR13X03 F1/F4 — R13-03 cannot pass `verify`; `row_pointed` overstates executed checks | D9 + M23-3 class; `SCORECARD.md:860` |
| D05 | ClaimR15X02 — R23-01 cannot pin the real-tree arm | `round-23.md:127-135` ("real-tree claim is not made") |
| D06 | ClaimR15X03 — fixture-local claims/stamps make a green fixture silent about real rows | `round-23.md:156-169` C3 fixture contract (fixture-local data, pinned `row_deferred`/`self_skipped`) |
| D07 | ClaimR16X03 — host-count breadth rows | `LOG.md:1218-1220` ("live-count breadth rows") |
| D08 | ClaimR18X02 primary — single-backslash guard not implemented | `SCORECARD.md:861-862`; `LOG.md:1219` |
| D09 | Legacy in-row branch class (S001/S003/S005/S013/S015/S016/S021/S023) — presence-only, never compared | `round-23.md:108-119` D7; TSV header `:34-36`; census header `:67-69` (instance gaps remain: S001/S002/S003/S011/S015 are not named — see X53/X58/X64) |
| D10 | Consumer/used-by edges invisible to the census (S012 F2/F4, S018 M2, S019 F3, S022 F4) | `round-23.md:149` M23-2 (named consumers) |
| D11 | SourceS013 F3 — used-by bullet/erratum inversion | already routed in round-22 `build/Source13.md`; not this round's obligation |

## 4. DECLARED BOUND (9)

| id | seat / finding | bound |
|---|---|---|
| B01 | ClaimR14X01 — `DOC_AUDIT` is declaration coverage, not runnable verification | `corpus/knowledge/claim-ledger.md:234-236` |
| B02 | ClaimR21X04 — count certifies membership, not identity | R21-04 note ("Counts rows, not calibration or source truth"); `SCORECARD.md:380-390` mutate ceiling |
| B03 | SourceS016 rec 4 — remove the in-row-or-row disjunction | plan C2 declares the OR branch; D7 bounds legacy pins (a design choice, not a fix) |
| B04 | SourceS005/S009 — quote/location not content-checked | TSV header `:25-27`: "declared quote, shape-checked only: <=25 ASCII words, not verified against the page bytes or the location" |
| B05 | SourceS002 — alt-text quote not representable under rendered-text-v1 | TSV header `:15-25`: point attestation, volatile chrome-sensitive, `raw-literal-v1` allowed (normalizer-as-code remains X53) |
| B06 | SourceS020 F5 — normalized digest is chrome-coupled | TSV header `:19-21` ("still chrome-sensitive, never a drift pin"); lesson `:50-54` |
| B07 | SourceS023 F1 — superseded legacy pins pass on shape | TSV header `:34-36` legacy bound (by-id reporting remains X75) |
| B08 | SourceS011 — legacy in-row quote/digest unreconciled | same legacy class bound (the instance is not named — X58) |
| B09 | SourceS012 F1 — S012's teaches sentence overclaims the JWT-role scope | S022 supersedes the scope; row kept immutable by design |

## 5. SILENTLY DROPPED (78)

Severity: **H** = safety/false-green on a shipped claim; **M** = measurable gate/doc
gap; **L** = calibration/prose/hypothetical. "Missing" names the disposition that does
not exist at the snapshot.

### 5.1 Claim rows (51 + 1 retired)

| id | seat — finding | sev | missing disposition |
|---|---|---|---|
| X01 | ClaimR11X01 — `scanned=[0-9]+` accepts 0; deleting `# scan` directives keeps CLEAN; no sibling pins the scan set | H | ERE floor / sibling pin / debt |
| X02 | ClaimR11X03 — `PASS (16 cases)` cannot distinguish executed from skipped | M | executed-count clause / debt |
| X03 | ClaimR11X04 — any nonzero membership passes; a baseline+`FILES` shrink stays green | M | exact count/identity / debt |
| X04 | ClaimR11X05 — `README.md:36` advertises `symlink+hardlink`; only `ln -s` exists (`drift-pins.sh:428`), nlink branch `:133-136` untested; case-count substitution invisible | H | README correction / hardlink case / debt |
| X05 | ClaimR11X06 — R11-06 accepts the gate's own seeded worst case (`HITS=2`, fake vault ref + credential row); F1w/F3 variants also pass | H | exact-line/set check / debt |
| X06 | ClaimR11X07 — credential/account tripwire never asserted independently | M | tripwire case / debt |
| X07 | ClaimR11X07 — `python3`-absent path prints the static OK line claiming the wal case ran | M | skip verdict / debt |
| X08 | ClaimR11X09 §6 — R11-09/R18-03 not run under `CLAIM_LEDGER_DEPTH=1`; receipt records no environment | M | runner env / debt |
| X09 | ClaimR11X10 — `grep -c` counts comments/blank lines the loader skips (F1/F1b/F2) | M | loader-identical count / debt |
| X10 | ClaimR11X11 — 35 non-comment lines is satisfiable by a blank line; declaration set/class not pinned | M | composition row / debt |
| X11 | ClaimR12X01 F1 — inherited env reference makes `op run` contact the vault; header "no vault contact, no approval prompt" is false; can block for 300 s | H | env isolation / safety-claim errata + debt |
| X12 | ClaimR12X01 F2 — CLEAN counts (oprun/refs/divergent/edge/sig) not pinned; deleting a shape passes same regex | M | exact-line ERE / debt |
| X13 | ClaimR12X01 F3 — eight scored cells and two Reverify sets rest only on deferred rows; `cells` counts them as `row_pointed` | M | per-cell disposition / debt |
| X14 | ClaimR12X01 F4 — note says "at v2", probe is v4; CLEAN carries no op version/handler digest | L | note/identity / debt |
| X15 | ClaimR12X02 §2 — note says "four POLICY cases" (source seeds five fixtures); POLICY fixtures do not discriminate clauses | L | note correction |
| X16 | ClaimR12X02 §6 — R12-02 ERE lacks `$`; `... PASS (36 cases) skipped=1` matches (demonstrated MATCH) | H | one-char ERE fix / debt |
| X17 | ClaimR12X03 §6 — committed verdict can attribute a pass to a revision where it is impossible; C1 D6 cannot see `measured_commit` | M | checker / debt |
| X18 | ClaimR13X01 rec 1 — note not corrected (malformed-heading tooth not attributed to `cells`; 24+1 split absent) | L | note correction (duplicate sentence was removed, but not this) |
| X19 | ClaimR13X01 rec 3 — CLEAN line does not declare the scored population | L | line change / debt |
| X20 | ClaimR13X02 — SKIP-SELF predicate `*claim-ledger.sh*` untested; stem mutant survives selftest and R23-01 | M | case / debt (M23-3 covers the class, not this mutation) |
| X21 | ClaimR13X03 F2 — `row_deferred` is always 0 through `verify`; no tagged-row cells case | M | case / debt |
| X22 | ClaimR13X03 F3 — no executed real-scorecard receipt since round 17; UNCITED cell found by reading, pointer changed by hand | H | receipt / debt |
| X23 | ClaimR15X01 F1 — E4 removes whole lines containing an allowlisted vault prefix, so a mixed line with a real reference counts `hits=0`; file is unstamped; `SC_CREDENTIAL` does not scan it | H | line-level exemption fix / debt |
| X24 | ClaimR15X02 — note says terminal 33 (actual 34); `duplicate reason` listed under POLICY but is DUPLICATE-REASON; `padded reason` omitted | L | note correction (QM14) |
| X25 | ClaimR15X04 — E9 rename/lead swap passes; R15-04 ERE still `^[EH][0-9]+` | M | `^[EH][1-8]` fix / debt |
| X26 | ClaimR15X05 — `delegated` counts by prefix and never checks the delegate path exists; `--ratio` executes nothing | M | existence check / debt |
| X27 | ClaimR15X05 §7 — note's "wrong at every revision" historical clause not reconciled | L | erratum |
| X28 | ClaimR16X01 — deferral hides sibling-lane basis decay; `SCORECARD.md:333` "every baseline re-derives" is false | M | errata / debt |
| X29 | ClaimR16X01 F2 — predicate too narrow; note omits fleet-layout dependence (unlike R11-08) | L | note fix / debt |
| X30 | ClaimR16X02 §3 — note "43 partition + 18 breadth" is stale (actual 44 non-breadth + 17 breadth); one duplicate mutation | L | note correction |
| X31 | ClaimR16X02 §7 secondary — a cell's "43 selftest cases" can contradict the cited row's 61 and `cells` stays CLEAN | M | numeric compare / supersession marker |
| X32 | ClaimR16X02 §7 adjacent — `scope-gate.sh:48` says empty input is SETUP exit 2; code treats empty as DEFECT exit 1 (selftest enshrines it) | L | prose fix / debt |
| X33 | ClaimR16X04 F1/F1b — R16-04 measures spelling: `.HOME/` accepts `/HOME/` or `XHOME/` (demonstrated 1); absolute respelling false-fails; `[[:space:]]` counts a space-separated line the gate treats as prose | M | predicate fix / debt |
| X34 | ClaimR16X04 F2 — note's rationale ("prose lines start with `# own`; naive count 9") is refuted; 9 is `5 # own + 4 # owner` | L | note correction |
| X35 | ClaimR16X05 — a naive append fuses into the last (unterminated) row; R16-05 still prints 4 while the gate sees 3 groups | M | append normalization test / debt |
| X36 | ClaimR16X06 — count 8 can pass while the gate parses 7 or 0 boundaries; M1 (tab→space) survives; M2 fixture repaired by L1 | H | set/identity check / debt |
| X37 | ClaimR17X01 — foreign-root breadth failure is reported as substrate absence; after restore it fails without output | M | debt / classification |
| X38 | ClaimR17X02 Finding A — count row vs parser grammar/content; misses 6 of 9 shipped falsifiers; stale "derives" claim | M | debt |
| X39 | ClaimR17X02 Finding B — `SCORECARD.md:325` attributes substrate declaration to R17-02, which declares no substrate dependence (QM11) | M | erratum |
| X40 | ClaimR17X02 §5 primary — round-23 cell `SCORECARD.md:844` says "four declared breadth pins are unchanged" but cites only R17-02; a count-preserving swap stays CLEAN | H | cite `corpus/adjacency.tsv` / errata |
| X41 | ClaimR17X03 — `cells` CLEAN with a deferred derivation row and a count-preserving swap; `.HOME` wildcard | H | ERE/cell-pointer fix / debt |
| X42 | ClaimR18X01 — partial substrate return stays CLEAN; R18-01 note still claims "fails on both exit and verdict … IS the return-detection signal"; errata to `substrate-deferral.md:55`/`SCORECARD.md:322` absent | H | note/errata / debt |
| X43 | ClaimR18X02 secondary — tag count is a line count, not a set; a tag can move to a comment and keep 11; `deferred` not pinned | M | set identity / debt |
| X44 | ClaimR18X03 — no case runs an untagged row under forced `KAGI_SUBSTRATE=absent`; unquoting `'[substrate]'` over-matches | M | case / debt |
| X45 | ClaimR21X01 broader — untagged external-absence row has no unmeasurable class; a red row can be SETUP exit 2 but is reported as claim failure | M | debt / verdict class |
| X46 | ClaimR21X02 — pinned line is a histogram; an id rename with identical counts prints byte-identical CLEAN | H | id-set row / debt |
| X47 | ClaimR21X03 — R1 pin counts cases only; R2 selftest can pass while real data aborts | M | identity/rig case / debt |
| X48 | ClaimR22X01 §5 (late-landing) — the only Vault admission is locked to a superseded id | M | none (report arrived after dispositions; no lesson/debt entry) |
| X49 | ClaimR22X02 — mutant P (one-token path predicate) survives the feature-claims selftest | M | case / debt |
| X50 | ClaimR22X03 — equal-count swap among post-base additions invisible to revision-audit | M | set identity / debt |
| X51 | ClaimR22X04 — `cases=17` certifies count, not case identity | M | identity pin / debt |
| X52 | *(retired)* ClaimR22-01 — the report landed at 01:14; no missing-report claim is made. Its finding is X48. | — | — |

### 5.2 Source rows (27)

| id | seat — finding | sev | missing disposition |
|---|---|---|---|
| X53 | SourceS002 — `rendered-text-v1` cannot represent the alt-text quote; `raw-literal-v1` drops the normalized identity; normalizer is prose only | M | committed normalizer / explicit per-row choice |
| X54 | SourceS003 — QM3: legacy in-row branch not counted in the verdict line; S003 is unreproducible and unnamed in M23-1 | H | `fetch_inrow_only` count or finding |
| X55 | SourceS004 §6 — `cred_scan` never reads `source-fetches.tsv`; `CRED_RE` has no service-account-token alternative; quote bound is words only (600+ chars = 1 word, demonstrated) | H | `cred_scan "$fetchf"` + needle + char cap, or an explicit "quotes are not credential-scanned" bound |
| X56 | SourceS004 §7 — CLEAN line does not count declared vs in-row-only provenance | H | QM3-compliant counters |
| X57 | SourceS007 — no provenance row for S007 (`.md` representation); knowledge entry `source:` still omits S017–S020; S007 quote normalization unreconciled | M | row/entry fix or debt |
| X58 | SourceS008 M2 — `on-release` does not bound a mutable `main`; trigger not widened | M | recheck fix / debt |
| X59 | SourceS011 §4.1/4.2 — in-row quote under neither normalization; rendered-text-v1 does not reproduce recorded digests; hash domain inconsistent across artifacts | M | named instance in D7 + normalizer code |
| X60 | SourceS012 F3 — quote is a sentence fragment whose scope is not the row's | L | debt |
| X61 | SourceS012 F5 — "newest pinned v1.21.x" refuted by selector; recheck text does not say to re-read the version label | L | debt/erratum |
| X62 | SourceS012 F6 — `release_status` bound to `S012-audience`, which states no release status; no S022/S023 in `feature-claims.json` | L | debt |
| X63 | SourceS013 F2 — anchor/date claim was a text-extraction artifact; exact selector/`dateModified` not carried | L | debt/erratum |
| X64 | SourceS013 F5 — one quote/location cannot cover a two-clause `teaches` | L | schema bound/debt |
| X65 | SourceS015 (late-landing) §6 — S015 is active `mined` but its only provenance is an in-row digest reproducing under 0/520 representations; census cannot distinguish it from declared provenance; M23-1/D7 omit S015 | H | provenance row / `legacy_only` counter |
| X66 | SourceS016 rec 5 — `proof_class` not recorded (docs label vs deployed product) | L | debt |
| X67 | SourceS017 C-2 — `S017-runtime` quote uses ASCII `'`, page uses U+2019; the quote is not in the bytes its digest identifies; no representation declared | M | representation declaration / QM14 re-quote |
| X68 | SourceS020 F2 — supersession is not modeled by SC_FETCH; active supersession (not just legacy) is prose-only; plan states no bound | M | scoped supersedes or explicit bound |
| X69 | SourceS020 F3 — only half of S020's teaching has provenance; one-quote-per-id blocks a second row | M | (id,location) keying or bound |
| X70 | SourceS020 F6 — `feature-claims.json:189-190` binds path values the S020 page does not carry | L | drop bindings / errata |
| X71 | SourceS020 F7 — lesson names captures `56ade2d0…`/`cbd70b29…`; TSV records `53dfeac5…`; the recorded capture is not traceable in the lesson | M | name the recorded capture |
| X72 | SourceS020 F9 — TSV location truncated `New in this release` vs exact H2 `New in this release: Custom OIDC workflows` | L | exact heading |
| X73 | SourceS021 §6 — S021/S026 URL is a moving version route; revision `-`; moving-ref detection is URL-pattern only; anchor names a version family the URL lacks | M | revision requirement / header correction |
| X74 | SourceS021 secondary — C1 D7 pointer (`source-fetches.tsv`) reaches the digest half only, not the stale §Gate prose half | L | pointer/errata |
| X75 | SourceS022 F5 — "mandatory `bound_audiences`" qualifier absent from every round-23 prose location | L | qualifier in lesson/row |
| X76 | SourceS023 F1 residual — superseded legacy pins pass shape-only; no by-id reporting in the CLEAN line | M | id list / bound |
| X77 | SourceS023 F3 — the KV note quote is unattested (not in raw bytes; the TSV attests S013's quote); second quote/locator not allowed | M | second quote / locator column |
| X78 | SourceS023 F5 — `etag`/`date` not recorded for volatile rows; "reproduced" means same CDN object | L | record headers / bound |
| X79 | SourceS023 F6 — M23-2 names consumers for S012/S018 only; S023's consumers (entry `:166-169`, `README.md:140-141`, lesson, TSV) are unlisted | M | extend M23-2 / edges |

(Counts: X01–X51 = 51 claim findings; X52 retired; X53–X79 = 27 source findings.
Table total **78 dropped**, hence 19 fixed + 11 debt + 9 bound + 78 dropped = **117
material findings**.)

## 6. Contradictions (not smoothed)

1. **C1 `fixed=7` included a disposition whose own note conceded debt — resolved
   mid-audit, by integration, not by the gate.** At the pinned snapshot
   (`corpus/closure-dispositions.json` before 04:16), D3 was `"disposition": "fixed"`
   with note "…id-shaped positionals remain routed debt (ClaimR11X09)", while
   `round-23.md:86-92` said the gap is "not claimed as fixed"; the gate printed
   `fixed=7`. Post-snapshot the JSON was retyped to `"reported"` (current JSON
   `67ac1a42…`, current gate line `fixed=6 reported=3`). The type/note mismatch is
   resolved, but the gate itself only checks pointer existence and one-disposition-per-id
   — it could not see the mismatch; a live editor did. That is the self-certification
   class the C1 claim is supposed to consume, and it is the strongest evidence that
   `R23-02`'s "records existence, not fix quality" bound is load-bearing.
2. **The lesson's own mistake sweep is false at the snapshot.** `round-23.md:153`:
   "Sweep that looked for a fourth mistake and found none" — while `M23-4` exists at
   `round-23.md:150` (misrooted seat reports). The sweep sentence was not updated when
   M23-4 was appended.
3. **`SCORECARD.md:844` asserts "the four declared breadth pins are unchanged" while
   citing only R17-02**, which cannot see a count-preserving swap (ClaimR17X02 §5;
   ClaimR17X03). The C3 fixture itself now demonstrates the correct pattern (cite and
   stamp `corpus/adjacency.tsv`); the real cell was not fixed.
4. **The audit population moved while being audited.** 66 parent reports landed between
   00:56 and 01:14; the implementation artifacts changed at least four times each in the
   same window (hash sequence above). Eight reports (R11X11, R13X02, R15X01, R16X05,
   R16X06, R18X03, S015, R22X01) arrived after the lesson's M-table and the debt list
   were authored, so their findings cannot have been consumed. Any statement that the
   round "reports inherited parent findings" is true only for the items listed in
   §3–§4; for the rest it is false at the snapshot.
5. **C2's own provenance is not asserted for the artifact set.** The round requires
   `measured_commit` for verdicts (D6) but leaves 10+ uncommitted artifacts changing
   during falsification. `CELL_AUDIT`/`CLOSURE_DISPOSITIONS`/`SOURCES_CENSUS` lines are
   reproducible only against a hash, and the round publishes no hash manifest for the
   audited tree. This is the same "digest with no declared representation" defect M23-1
   names, one level up.

## 7. Bound the claim must state

1. **SC_FETCH is a shape/identity gate, not a quote or credential gate.** Quote is
   `wc -w ≤25` (`sources-census.sh:266`), location is `≥8 chars` (`:274`), and no
   `cred_scan` reads the fetch file (`:286`, `:312`). The TSV header now says
   "shape-checked only" (`:25-27`); the lesson's "located quote" wording (plan C2 and
   `round-23.md:108-110`) must repeat that bound, and the claim must state that a
   vendor sample token pasted as a quote passes the gate.
2. **Legacy presence ≠ provenance.** 16 in-row pins are presence-only; the audit
   measured non-reproduction for at least S001, S002, S003, S011, S012, S013, S014,
   S015 and S016. D7 names only four. State "presence-only; non-reproduction confirmed
   for 9 of 16" (or name them), and either add a `legacy_only` counter or say the
   verdict cannot distinguish declared from in-row-only.
3. **C1's fixed count must pin the disposition JSON, not quote a moving number.**
   At the pinned snapshot the line said `fixed=7` with D3 typed `fixed`; after D3 was
   retyped it says `fixed=6 reported=3` (current JSON `67ac1a42…`). The claim should
   say "obligations=15, fixed=6, reported=3 (D3 guard fixed; id-shaped positional case
   reported)", and any report quoting `fixed=7` is reading a stale byte set.
   `R23-02` itself says it "records existence, not fix quality" (row note).
4. **R23-01 is parser evidence only.** It preserves none of the 43 real rows
   (ClaimR12X01 F3). `CELL_AUDIT: CLEAN` on the fixture says nothing about a scored
   real cell, and the fixture's `fx-ok.sh` stamp is inert (lesson C3 contract says so).
5. **Same-URL equality is now zero** (code, TSV header `:21`, lesson `:54`) — good, but
   the claim must also state that the normalized digest is chrome-sensitive and is not
   a content identity (the header does; the plan's "Digests are point attestations"
   wording should absorb it).
6. **R18-01's note overclaims return detection.** A partial/non-identical return with
   the handler absent stays CLEAN (ClaimR18X01 §4). The note (`claim-ledger.tsv` R18-01)
   still says "fails on both exit and verdict … IS the return-detection signal". Either
   correct the note or bound the claim to "flips only when some pin holds exactly".
7. **The round has no frozen audit snapshot.** The final verification must record
   sha256 for every artifact it measured (not only `measured_commit`), or the
   parent/falsify reports and the claim refer to different bytes.

## 8. Proposed move (one, bounded)

**Make the parent audit a second obligation source in the existing C1 disposition
gate, instead of a prose debt list.**

Concretely: add `corpus/parent-audit-dispositions.tsv` (or a second `source` in
`closure-dispositions.json`) with one row per material parent finding —
`id, seat, finding, severity, disposition ∈ {fixed, reported, dropped, operator-owned,
no-action}, pointer` — and extend `corpus/closure-dispositions.py` only at its source
layer: parse the audit's report set, require exactly one disposition per material
finding, require every `fixed`/`reported` pointer to resolve and name the finding id,
and require every `dropped` row to carry a pointer to a `SCORECARD.md` named-debt line
or an accepted-bound paragraph. Seed it with §2–§5 of this report (117 rows: 19
fixed + 11 reported + 9 bound + 78 dropped).

Why this move: the round already has the right mechanism (typed disposition +
pointer resolution) but applies it only to the *outside* closure. The build wave that
produced the round's own claims is left on prose. This is a compatible synthesis of
the round's C1 mechanism, the C2 provenance discipline (declare the representation of
the finding, not just the digest), and the D9/SKIP-SELF accounting rule (count what
was not executed). Axes: **calibration** primary (no silent drops; fixed count cannot
absorb `reported`), **freshness** (forces the C2 prose/code contradictions and the
moving-snapshot issue into a recorded row), **operability** (no host execution; the
existing pointer resolver runs offline; no new runtime).

Risks: pointer existence is not fix quality (CritSelfCert); finding IDs are
narrative, so the seed must be append-only and keyed by `seat#n`, not by heading;
"dropped with a reason" can become a rubber stamp — hence the rule that a dropped row
must point at an existing debt/bound line. A 118-row first seed is large; bound it to
the material findings this report names, not to every sentence in the 66 reports.

Verification of the move (in a `/tmp` copy, no production write): remove one
disposition → exit 1 `missing`; point a `fixed` row at a file that exists but does not
name the id → exit 1 `pointer-id`; mark a dropped row with a pointer to a missing
SCORECARD line → exit 1; unmodified seed → exit 0. The round's existing 13-case
selftest already covers those exit semantics for the current source; the extension
should reuse them.

## 9. Limits

- Read-only: no scratch fixture was created or mutated; no network; no host gate; no
  legacy `verify`; no host-bound row. The credential/quote fail-open in X55 is shown
  by code and the in-memory word count, not by a mutating census run.
- The tree changed during the audit (hash table above). Findings were verified against
  the pinned snapshot; line numbers may have moved. The substantive dropped items
  (README hardlink, `ops_`/cred scan, R15-02/R16-02/R18-01 notes, R12-02 ERE, R21-02
  histogram, R17-02/R17-03 cells) were re-checked at the latest hash and were
  unchanged.
- Severity is the parent's, not a re-derived score. "Dropped" means "no disposition
  found", not "the finding is true"; several are hypothetical risks the parent itself
  labelled proposals. The reproducible defects among them (X04, X11, X16, X23, X33,
  X36, X42, X46, X54, X55, X65) do not depend on that labeling.
- The parent audit population is complete at the snapshot: 66 files = 43 claim-row
  reports + 23 source-row reports, matching the plan's 66 seats. It was *not* complete
  when the falsify wave began: 58 files at 00:56, 65 at 01:07, 66 at 01:14. Eight
  reports (R11X11, R13X02, R15X01, R16X05, R16X06, R18X03, S015, R22X01) landed after
  the lesson's M-table and the debt list were authored, so their findings (X10, X20,
  X23, X35, X36, X44, X65, X48) could not have been dispositioned.
