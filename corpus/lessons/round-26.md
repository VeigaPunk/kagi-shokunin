source: S039, S040, S041
verified-at: 2026-10-21 — exact public Python feed/re/html URLs re-opened; no installed-runtime, account, vault, handler or CDP probe
recheck: on-release — S040/S041 are rearmed at named3.15.1 anchors; observe a new receipt and re-open each teaching on the next Python release; S039 feed inventory also has a90d review

# Round 26 — respond to drift without rewriting history

Frozen BASE: `1bf3eec48d3761580ffd375c88143232485ae814`.
Declared claim C1: freshness, 9 → 9 (one of the tied-lowest axes), bounded
Python 3.15.1 drift response; `plans/round-26.md`. No new knowledge ground,
capability, runtime upgrade, score inflation, retirement or promotion is
claimed. The round-25 C2 lone-layout outcome remains explicitly INCOMPLETE
with 48 fleet-absent citations, not fixed or credited CLEAN here.

## Gate

L1 opened all three exact URLs on 2026-10-21 with the declared
`curl-fsSL-compressed-v1` profile. HTTP/final URL/digests/lengths/located
quotes and exact argv are in `.ufo/waves/round-26/captures/metadata.json`;
the captured public bodies are retained beside it. Every quote below is at
most 25 whitespace-delimited words. Registry admission uses QUALITY QA1,
QA2, QA3, QA4, QA6, QA9 and QM14/QM16/QM23, not a new source method.

| Candidate | Decision and basis | URL, access date, located quote |
|---|---|---|
| S039, supersedes S036's current-version reading only | ADMIT tier A, mined; the fetched feed's maximum stable semantic version is 3.15.1, not its first entry 3.14.9; 3.16.0a1 is excluded. The original 3.15.0 observation remains history. | https://www.python.org/downloads/feed.rss ; 2026-10-21; “<title>Python 3.15.1</title>” (Python 3.15.1 item title, pubDate Wed, 21 Oct 2026 09:59:50 +0000) |
| S040, supersedes S027's documentation-version locator only | ADMIT tier A, mined; the served document title now says Python 3.15.1. Unicode whitespace, str.isspace(), no-break spaces and ASCII-flag qualification remain documented. | https://docs.python.org/3/library/re.html ; 2026-10-21; “Matches Unicode whitespace characters (as defined by str.isspace() ).” (Regular expression syntax → special sequences → backslash-s entry, rendered text) |
| S041, supersedes S028's documentation-version locator only | ADMIT tier A, mined; the title now says Python 3.15.1. The first sentence still converts named/numeric references to Unicode and the second retains valid/invalid HTML 5 rules. Tag-removal order is local code, not a source-doc claim. | https://docs.python.org/3/library/html.html ; 2026-10-21; “This function uses the rules defined by the HTML 5 standard for both valid and invalid character references” (html.unescape(s), second sentence) |
| Feed release identity proves changed normalizer semantics | REJECT QA3/QA9; a version change does not establish any changed teaching or implementation behavior. Flip: a scoped source/code change plus reproduced behavior delta. | Same opened feed and re/html URLs above; both relied-on teachings remain present. |
| Python docs version proves the installed interpreter was upgraded | REJECT QA3/QM2; documentation is not a host runtime probe and no upgrade was performed. Flip: an explicitly authorized runtime measurement, separately scoped. | The fetched HTML titles are documentation labels only. |
| Historical CLEAN means current vendor truth | REJECT QA4/QM14/QM23; R25-04 is pinned receipt consistency, not network observation. Flip: a newly named observation and explicit current profile with drift disposition. | `.ufo/waves/round-26/observe-run.json`: the new receipt makes the old profile return RECEIPT-MISMATCH S027/S028, exit 1. |

**Existing registry cells (status/recheck/used-by), old → new:** none.
S039 is a new dated90d feed inventory; S040/S041 are new on-release
successors. Their draft90d cadence was rejected before landing and changed
90d → on-release (QM24, M26-3 below). S027/S028 retain their original
on-release cadence and original3.15.0 anchors, now observed fired; no old
source row is demoted or silently re-anchored. Sources38 → 41, all three new rows
tier A/mined, no new governed coverage ground. Required census receipts
are `.ufo/waves/round-26/census-start.json` and `census-end.json` in that
wave directory once final measurement is recorded.

**Outside admit/reject spot-check:** pending parent closure. All dispatched
children remain lane authors; their agreement cannot improve discernment
or check SHONEN boxes.

## Observation and explicit current profile

The original round-25 receipt SHA256 is
`b74c8ee30aaeaf7a867f9bbad39ea42e94f199da69ebd01d0e391d2e8b349f92`.
It is unchanged. The historical gate code, source/capture/binding tables and
original receipt are preserved together in the frozen snapshot. The ACTIVE
binding table, default receipt path/digest and R25-04 expectation migrate
explicitly to the NEW rearmed receipt (see Final rearm correction below);
an offline CLEAN still means selected receipt consistency, not live truth.

`python3 -B corpus/release-clock.py --observe .ufo/waves/round-26/observe-1.json`
created a NEW receipt: 28 observations, failed=0, fired=3. As expected,
evaluating that receipt against the old profile returned exit1 with exactly
S027/S028 mismatched: FAILED, observed26, fired1. The observer's fired3 and
the old-profile evaluator's fired1 are different denominators, not conflicting
outputs or a suppressed failure. S012 is the older fired Vault anchor;
S027/S028 now observe stable 3.15.1 against retained 3.15.0 anchors.

The historical snapshot under `.ufo/waves/round-26/frozen/` contains the
BASE source/capture tables and original gate code, the first new28-record
receipt, the original round25 receipt, and paired before/after binding
profiles. Its after profile changes only S027/S028's observation fields
and notes. It documents the bounded drift response but does NOT include
S039–S041 or re-arm future clocks. Replay it with the explicit frozen-root
argument, never as the active profile.

The ACTIVE rearm snapshot is `.ufo/waves/round-26/rearmed/`; it includes
the current41-row registry and new30-record receipt. Run
`bash .ufo/waves/round-26/tools/replay-current.sh before` and `after`.
Before has the original28-binding table: expected exit1, UNBOUND S040/S041
and named receipt mismatches, observed26/bound28/on_release30. After
changes S027/S028's observation fields and adds S040/S041 bindings at
their named3.15.1 anchors: expected exit0 CLEAN30/observed30/fired3,
derived15. Both are controlled claim-only profiles, not full-ledger BASE
commits. The wrapper pins each checksum-manifest digest OUTSIDE the
snapshot, checks that literal pin and then every input digest before
evaluation. Editing a receipt plus its checksum manifest is still
snapshot_tampered/exit2. Exact outputs and measured revision are appended
after final immutable measurement; no unrun check is called passing.

## Mistakes

| id | class | evidence | captured-by | fix / counterexample |
|---|---|---|---|---|
| M26-1 | stale-premise: a retained observation profile is not a current one | New receipt against unchanged BASE bindings: `.ufo/waves/round-26/observe-run.json`, exit1, RECEIPT-MISMATCH S027/S028. This is normal vendor drift, not falsification of the truthful round-25 historical receipt. The mistake would be reporting the old default CLEAN as a fresh observation. | QM14/QM23; the old default proves receipt consistency only | Preserve history, select the new byte-pinned current profile explicitly, retain fired anchors, and re-open both documentation teachings; paired same-receipt before/after differs only in the two observation bindings and must turn named red to CLEAN. |
| M26-2 | parser-assumption, recurring counterexample to round25 M25-5 | New feed's first item is Python3.14.9, while maximum stable semantic version is3.15.1; `.ufo/waves/round-26/captures/S039.body`. | QM23 and the existing max-stable parser, not a new implementation fix | Reuse the already-correct parser and preserve this real backport-first feed as a failure-capable fixture; a first-entry reading must fail the expected3.15.1 control. No parser improvement is credited. |
| M26-3 | freshness harm in the L1's first candidate: successor clocks demoted to90d | CritNoAxisHarm: S040/S041 draft90d successors would leave only the old, already-fired3.15.0 clocks. A future3.15.2 would not change their fired bit; the initial28-record snapshot excluded the successors. | none — QM23 required observable bindings but did not require a superseding teaching to be rearmed; new QM24 records this gap | Reject draft90d → on-release, bind both successors at named3.15.1, migrate the active default explicitly, preserve the old receipt/code/tables separately; missing-successor controls must fail UNBOUND and a future3.15.2 fixture must fire the rearmed successors. |

## Limits and retained debt

- Same-day timestamps establish the two retained observations' order, not an
  authenticated vendor history. Feed publication times do not prove when the
  earlier cached response was generated or when docs changed at the origin.
- The two Python teachings were re-opened and located, not proven equivalent
  over all Python versions, runtimes, Unicode data or normalizer inputs.
- A feed misses docs-only edits. A quote clock misses changes outside its
  declared quote. S017/S020 second-locator and S032 both-panel limitations
  remain explicit; matching a page today is not continuous coverage.
- C2 remains INCOMPLETE/48 in a lone clone. Knowledge-entry numeric debt,
  historical non-reproducing pins, S029's development-label correction and
  absent janitor substrate remain unclosed and are not regraded here.
- Wave source reports are advisory and may overstate their probes. In
  particular ClockS030's statement that the repo has no normalizer script is
  false: `corpus/rendered-text-v1.py` is the single declaration. Its custom
  normalizer is not adopted. ClockS005/S007/S032 ran normalizer selftests
  despite the mid-flight no-tests instruction; those runs are not credited
  as final verification. No whole-round no-tests attestation is made.
- ClockS026 flags a pre-existing scope qualifier: normal parent revocation
  revokes children/leases, whereas `auth/token/revoke-orphan` deliberately
  orphans children. Its source row is historical; the unqualified broader
  reading is flagged here, not adopted as a new current claim or silently
  fixed. No Vault-token or KV-retention parity follows.

## Routed closure and author-side review dispositions

The outside round25 closure is fleet MANIFEST ledger rounds[410], committed
at `ff47be96994cfb99d7f6305c009c0c867eae64d8`, reviewer CloseKagi25.
It admitted the bounded round25 work, agreed its sampled admits/reject,
explicitly retained C2 INCOMPLETE/48 and routed D1 (Python feed drift) plus
D2 (C1 is not complete corpus or digit coverage). This supersedes the earlier
round25 lesson's pending-closure statements as a dated successor, without
rewriting them. It verified no SHONEN box and is not a round26 outside
discernment check; all four boxes remain author [~].

- **CritChronology accepted:** the feed's 3.15.1 pubDate is
  `2026-10-21 09:59:50 +0000`, earlier than the retained Python observations
  at `2026-10-21T11:31:53Z`. The new Python observations are
  `2026-10-21T13:36:36Z`. Cached-edge versus backdated insertion is
  unresolved; neither “released since review” nor “round25 mismeasured”
  is admitted. CritCurrentTruth's 13:08:09 time belongs to the feed's
  3.14.9 backport, not 3.15.1, and is rejected as chronology evidence.
- **CritReceiptRewrite accepted in scope:** preserve the historical receipt
  byte-for-byte and keep its matching code/tables together in the frozen
  replay. The candidate proposal to leave the operational default historical
  was superseded by the explicit rearm migration below; no history is
  overwritten and no new receipt-comparison tool is invented after its
  assigned executor died.
- **CritCurrentTruth accepted with later rearm correction:** all active
  operational descriptions must name the NEW pinned default and distinguish
  it from live observation. Both the first observer's fired3 and old-profile
  evaluator's fired1 remain evidence, never equivalent counts.
- **CritSourceConjunction accepted:** receipt drift alone says nothing
  about doc clauses. The additional per-clause checks below name all
  relied-on statements; the local ordering/flag facts cite local code.
  This is a correction to any broader round25 reading of “re-verified” from
  one quote; the original lesson is not rewritten. No whole-page semantic
  equivalence or installed-Python3.15.1 behavior is claimed.

### Per-clause source support, not one-quote completeness

All external clauses below were opened at the same exact three URLs in the
Gate above on 2026-10-21; the archived captured bodies are the authority for
this point observation. Each located quote is at most25 words. The final
clause-check receipt records counts and input digests.

| Clause | Located quote and anchor |
|---|---|
| S040 Unicode str whitespace | “Matches Unicode whitespace characters (as defined by str.isspace() ).” — re special-sequences backslash-s, str subsection |
| S040 no-break-space inclusion | “non-breaking spaces mandated by typography rules in many languages.” — same str subsection, next sentence |
| S040 ASCII qualification | “if the ASCII flag is used.” — same str subsection, final sentence; the bracketed whitespace class precedes it |
| S041 named/numeric conversion | “Convert all named and numeric character references” and “to the corresponding Unicode characters.” — html.unescape(s), first sentence |
| S041 HTML5 valid/invalid rules | “This function uses the rules defined by the HTML 5 standard for both valid and invalid character references” — html.unescape(s), second sentence |
| Local default Unicode flag selection and ordering | `corpus/rendered-text-v1.py:65-75`: WS_RE is compiled without ASCII; TAG_RE substitution precedes html.unescape, then WS_RE substitution. These are code facts, not claims attributed to Python documentation. |

The clause observations are not new continuously monitored clocks. The
single-quote blind spot remains explicitly open; a source edit outside a
declared capture quote can survive that clock. QA3/QA9/QM16/QM23 already
bar the broader reading; no ungrounded new quality criterion is added.

Cross-lane findings are routed, not absorbed: connectors found chousa's
Python datetime source and kengaku's re/json sources may share the served
3.15.1 docs label. IDs are lane-local (their S027/S028 are not kagi's).
This lesson's S039–S041 mean kagi's own registry only. Runtime/package
management stays outside the claim; no sibling source is rewritten.

## Final rearm correction — supersedes the first candidate

CritNoAxisHarm exposed a real harm, so the initial draft was not retained:
keeping only already-fired old anchors and90d successors would weaken
future release detection. The active table now marks S027/S028 fired at
observed3.15.1 (original3.15.0 anchors unchanged) and adds S040/S041 with
named3.15.1 anchors and not-fired observations, bound to feed S039. Their
cadence is on-release. Derived anchors remain15, not17.

A NEW `.ufo/waves/round-26/observe-2.json` records30 observations with
failed0/fired3; the first round26 receipt and original round25 receipt
are both retained. Active default path, literal digest and R25-04 pattern
migrate by a named old/new record in
`.ufo/waves/round-26/expectation-migrations.json`; there is no compatibility
alias or hidden fallback to the old receipt. Selftest expectations stay67
because selection defaults changed, not evaluator behavior.

The stronger claim “current default is always vendor truth” is rejected:
this is still a dated point observation, re-armed for the next explicit
observation. One release feed supports both doc rows; two clock/teaching
dispositions are not two independent release observations.

### Residual guidance clarifications

FinalHistory found that the original receipt was retained but lacked a
named replay command. Its separate command is:

```sh
python3 -B .ufo/waves/round-26/frozen/release-clock.py --root .ufo/waves/round-26/frozen/before --receipt "$(realpath .ufo/waves/round-26/frozen/observe-round25.json)" --receipt-sha b74c8ee30aaeaf7a867f9bbad39ea42e94f199da69ebd01d0e391d2e8b349f92
```

Expected historical verdict: CLEAN28/observed28/fired1; final measurement
runs this once separately, not through the wrapper's round26 receipt
selection. FinalGuidance's stale wrapper comment and index “active” label
were corrected; its pending-output observations are closed only by the
final executed receipts, never by a prediction. The active receipt's
S027/S028 observations are `2026-10-21T13:43:24Z`; its successor
S040/S041 observations are `2026-10-21T13:43:27Z`. These are observation
times, not authenticated release-publication times.

FinalSnapshot's producer-boundary findings were accepted: a missing or
unreadable checksum manifest now returns typed snapshot_tampered/exit2;
the replay interpreter uses isolated `-I -B` startup so unlisted sibling
Python modules are not import inputs. The recorder compares expected.json
against literal verdict authority and the complete checksum digest map,
and checks that the rearmed after-snapshot equals measured production.
Its final negatives include input-only, input-plus-manifest and missing
manifest controls. This is evidence-producer hardening, not a new gate.

FinalRearm also names an inherited limit, not fixed or hidden here:
the evaluator defines fired as observed-version unequal to anchor, not
strictly newer. A stale/cropped feed could regress and un-fire an older
anchor; no monotonic-history guarantee is made. The retained3.15.0
anchors are fired **in this dated3.15.1 observation**, not promised always
fired. Future3.15.2 testing is a synthetic observer/parser control using
the real captured feed with only its3.15.1 item title changed, not proof
that the vendor has released3.15.2 or a complete end-to-end live run.

FinalLoneScope found a candidate-blocking citation defect before final
execution: a slash-joined prose shorthand was tokenized as a nonexistent
lane-local path, which would make both layouts BROKEN and prevent the
honest lone INCOMPLETE verdict. It was replaced with the equivalent
“corpus or digit coverage”; no citation classification or C2 policy was
changed. Its static BASE-reconciled finding is retained in the residual
report, and the final suite must re-establish both layout verdicts.

FinalInstrument's environment and invalid-success findings were accepted:
the recorder now whitelists its environment before Git setup or any gate,
uses a scratch HOME/TMPDIR, checks complete verdict lines rather than
truncated counts, and retains prior records plus a failed recorder-crash
record if execution raises. The command invoking the recorder uses isolated
Python startup. Its before/after source and binding counts are parsed from
the actual BASE and measured Git blobs, not copied from prose.

The fleet citation mirror intentionally resolves sibling/fleet targets
against the live fleet checkout; it is a dated layout check, not a frozen
snapshot of every sibling. The claim's clock snapshots and producer inputs
are separately pinned. Source re-openings and all residual reviews remain
lane-authored advice; none supplies outside admission or a SHONEN [x].

Process conformance: the full round prompt, godspeed, fleet SSOT and
canonical protocol/corpus/learning were loaded before implementation.
Redundant canonical MISSION/AXES copies and the incident appendix were
opened later; no claim of perfect literal load order is made. A few BUILD
seats ran normalizer selftests despite the mid-flight restriction and
created corpus bytecode, which L1 removed as generated scaffolding. No
whole-round no-tests/no-private-read attestation is made; no vault action
or host-row consent is credited. No tool was installed or updated.
