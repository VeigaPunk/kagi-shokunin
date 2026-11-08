# R66ScribeRecords — seat report

Seat: `R66ScribeRecords` (scribe; axes calibration + freshness). Lane
`kagi-shokunin`, branch master, claim BASE
`d549ee6eb8770a49938b78f49cf79e36d9c1c2e8`. Frozen plan `plans/round-66.md`
(landed `ddcd46bb4f9378f3cc3a659e4851e1cb126b02ca`). Wave `kagi-r66-w1`, 14 seats.

Role note: the L1 (`KagiR66`) owns `corpus/lessons/round-66.md`,
`corpus/SOURCES.md`, `corpus/source-fetches.tsv` and the integration commit. It
redirected this seat mid-flight to a bounded, read-only verification job
("do not write `corpus/lessons/round-66.md`"; write only inside this seat's
receipt directory). **This seat wrote no lane file outside
`.ufo/waves/round-66/w1/R66ScribeRecords/`, and ran no mutating git/jj
command.**

## What I did

Independently re-verified the round's frontier and its landed registry rows,
using the lane's own committed instruments (`corpus/rendered-text-v1.py`,
`sha256sum`, `cmp`, the lane and fleet census scripts) against **committed
lane bytes**, not scratch copies.

Two deliverables, both inside `.ufo/waves/round-66/w1/R66ScribeRecords/`:

- **`gate-verify.md`** — every row in the lesson's `## Gate` table: URL, access
  date, ≤25-word quote, and the `rendered-text-v1.py locate` output against the
  committed capture; plus the rows whose quote does **not** locate, named.
- **`frontier-verdicts.md`** — my three frontier measurements with exact
  commands, marked as a second independent reading of `R66ScoutSources`.

## Findings

**Verified sound (6 checks).** The S164 quote locates `count=1` in the
committed `.ufo/waves/round-66/capture/S148.body`; the same quote locates in
the eutils capture; both refusal quotes (`Client Challenge`,
`Just a moment... Enable JavaScript and cookies to continue`) locate `count=1`
in the scout's committed captures; the S148/S156/S164 fetch-row identity
digests recompute byte-for-byte; the S164 anchor path exists with the S148
pin; the lane census reads `SOURCES_CENSUS: CLEAN (rows=156 …)` and the fleet
wrapper `kagi ok`, both rc 0.

**Two defects in rows landed this round** — both in `corpus/source-fetches.tsv`,
both on rows added in this round, and **neither caught by any lane gate**:

1. **S155's provenance row carried another body's normalized digest.** Column 15
   declared `4d966ff9…` — that is the **BioC** body's rendered-text-v1 digest.
   The body its own column 16 names (`.ufo/waves/round-66/capture/S155.body`,
   the eutils carrier) normalizes to `5f509414…`, which is what the
   historical S135 row for the same body already carries. The census checks
   column 15's *format* only, never its *value* against the named capture, so
   CLEAN read with the mismatch in place. **One-token fix.**
2. **S156's declared quote did not locate in the capture its row named.**
   Column 13 joined two halves the JSON body does not join (the connector is
   `", "detail": "`), so `locate` read `count=0` against
   `.ufo/waves/round-66/capture/S156-429.body`. Each half locates; the whole
   JSON value locates. The census checks the quote's *word count* only, and
   `corpus/quote-bodies.tsv` lists neither S155, S156 nor S164, so
   `quote-locate.py` does not check them either.

This is the round's own subject matter — a binding that points at the wrong
bytes, and a quote the named capture does not contain — landing in the very
rows the round added. **Both were the L1's to fix; I did not edit them.**

> **Both were fixed by the L1 in the working tree after I reported them
> (~06:49), and I re-verified both.** S155's column 15 now reads `5f509414…`
> and matches the body its column 16 names; S156's column 13 now reads
> `Maximum 3 requests per second per user` and locates `count=1`. A full
> re-sweep of every fetch row whose column 16 names an existing file now
> reads **35 of 36 quotes locating** — the one remaining failure is **S115's**,
> pre-existing from round 57 and outside this round's scope. (The fixes were
> in the working tree but not yet committed when I re-checked; the committed
> blob at `cfafdb1` still carries the defective values.)

**One lesson-cell claim contradicted by measurement — STILL OPEN.** The
lesson's S165 Gate cell says the served 200 body "differs from the pin by one
byte — the `<date>` stamp `20261108`→`20261108` (no change measured this
window)". The served body is **byte-identical** to the pin (`cmp` → 0 differing
bytes; same sha256, same 264946 B, on three fetches across two user agents).
The one-byte delta that does exist is the historical round-63 → round-64 pair
(offset 128, `7`→`8` — the service's own date stamp), already recorded in the
S148 row's anchor cell. The cell also is prose, not a located quote, so
`locate` reads `count=0` — the plan's frontier step requires a ≤25-word
located quote per candidate. The committed lesson at `cfafdb1` and the
working-tree lesson are byte-identical for this cell (`git diff --stat` empty),
so this one is unaddressed.

**One records gap — STILL OPEN.** The plan's frontier step names **three**
candidates; the lesson's Gate table carries two rows and omits candidate 2
(the eutils recheck refresh) and candidate 3 (the equivalent-mutant weak
lead). The scout measured both (`R66ScoutSources/notes.md` §2, §3a–§3c) and
my own reading reproduces both verdicts — the eutils digest still equals
S135's pin, and both refusal pages still refuse — but the *lesson's* Gate does
not record them, and the plan asks for the candidate decisions to be in the
lesson's Gate.

**Calibration (my seat's axis).** My ACM DL 403 body differs from the scout's
in bytes and is unstable across my own consecutive fetches (5662 B
`96b3a70a…`, then 5684 B `8a073d03…`, then 5684 B `2de1db61…`; the scout
measured 5684 B `ad4c63cc…`) — a third independent observation of the same
instability, from two seats, on a body neither seat can pin. That *strengthens*
the REJECT: the record grounds nothing. The Springer body, by contrast, I
reproduced byte-identical across two consecutive fetches and against the
scout's committed capture — the stability claim holds.

**Freshness (my seat's other axis).** The carrier itself is fresh: the BioC
deposit re-opened live three times on 2026-11-08 (two user agents, 20 s apart)
returns the pin's bytes exactly, and the eutils carrier still matches S135's
pin. What is *not* fresh is the provenance layer: two cells point at bytes
other than the ones they name, and no lane gate reads either cell's value.

## Out of scope / not mine

`corpus/lessons/round-66.md`, `corpus/SOURCES.md`,
`corpus/source-fetches.tsv`, `corpus/knowledge/*`, the plan, the three
counters, the control battery, `SKILL.md`, `SCORECARD.md`, `LOG.md` and the
lane report are all the L1's or other seats'. The S115 non-locating quote
(`corpus/source-fetches.tsv`, round-57, pre-existing) is reported as context
only — it is not this round's row and I did not touch it.

## Secret discipline

No secret value, token, cookie or vault reference path was printed, copied or
stored. The two ACM DL 403 bodies carry a live Cloudflare `__cf_chl_tk`
challenge token, so **their bodies were not stored** — only digests and byte
counts (`receipts/acm-403-digests.txt`). The stored Springer interstitial
(3038 B) scanned clean for `_csrf`/`csrf`/`__cf_chl`/`token`/`secret`/`cookie`
(0 hits). The NCBI bodies are the public BioC/PMC deposits; a credential scan
over my copies found 0 hits. No response headers were captured.

## Tooling

No installs. Everything used was already on the host: `bash`, `curl`,
`python3` (the lane's own `corpus/rendered-text-v1.py`), `sha256sum`, `cmp`,
`awk`, `grep`, `git` (read-only: `show`, `diff`, `status`, `log`, `archive`).

## Scratch

Scratch root `/fast/scratch/hyaku/kagi-r66/R66ScribeRecords/`, created with
`mkdir -p`, `TMPDIR` exported into every child, **deleted on exit**
(`trap 'rm -rf -- "$S"' EXIT`). Receipts were copied into
`.ufo/waves/round-66/w1/R66ScribeRecords/receipts/` first.

## Artifact paths

- `.ufo/waves/round-66/w1/R66ScribeRecords/gate-verify.md`
- `.ufo/waves/round-66/w1/R66ScribeRecords/frontier-verdicts.md`
- `.ufo/waves/round-66/w1/R66ScribeRecords/receipts/springer-challenge.body`
- `.ufo/waves/round-66/w1/R66ScribeRecords/receipts/acm-403-digests.txt`
- `.ufo/waves/round-66/w1/R66ScribeRecords.md` (this file)

Report: .ufo/waves/round-66/w1/R66ScribeRecords.md
