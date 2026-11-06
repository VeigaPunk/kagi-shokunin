# K49ScoutSources — round 49 seat report (reconnaissance: merge package, considerthese, round-48 routed items, OpenBao docs)

Seat: K49ScoutSources (scout, leaf member — no subagent dispatch).
Lane: /home/vgpnk/Projects/shokunin/kagi-shokunin, branch master.
BASE for every "still open at BASE?" reading: `89afe91878f10805921d3caa67d28d21b33226da`.
Predeclaration: `082bfb3f6baa2407df2a23c0489043495b4dce4d`.
Date: 2026-11-06.

Write scope touched: only `.ufo/waves/round-49/build/K49ScoutSources.md` and
`.ufo/waves/round-49/build/K49ScoutSources/openbao-tokens-20261106.body` (a public page
capture), plus the scratch tree under `$HYAKU_SCRATCH/kagi-r49/K49ScoutSources/`.
Nothing in `corpus/`, `plans/`, `SCORECARD.md`, `LOG.md`, `SKILL.md`, `PROVINCE.md` or any
sibling repo was edited. No git mutation of any kind in the lane or the fleet (only read-only
`git show`/`log`/`ls-tree`/`status`/`archive`/`clone --shared` into scratch, plus
`git rev-parse --show-toplevel` assertions on the scratch clones). No tool was installed or
upgraded by this seat; `~/.local/bin/bao` was read only by hash and by the counter's own pin
check, and pacman was never invoked.

Scratch: `$HYAKU_SCRATCH` defaulted to `/fast/scratch/hyaku`; all clones lived in
`/fast/scratch/hyaku/kagi-r49/K49ScoutSources/` and were removed on exit.

---

## 1. The staged merge package — `/home/vgpnk/Projects/shokuknow/merge/kagi/` (READ-ONLY)

### 1.1 What is in the package

```
$ ls -la /home/vgpnk/Projects/shokuknow/merge/kagi
-rw-r--r--  1 vgpnk vgpnk   35545 Oct 24 23:33 MERGE-REPORT.json
-rw-r--r--  1 vgpnk vgpnk   16169 Oct 24 23:33 MERGE-REPORT.md
-rw-r--r--  1 vgpnk vgpnk  166212 Oct 24 23:33 SOURCES.append.md
drwxr-xr-x  1 vgpnk vgpnk      12 Oct 24 23:33 knowledge
```

`knowledge/` holds one tree: `knowledge/corpus/knowledge/` with **81** `.md` files
(`find … -type f | wc -l` → 81). There is **no** `amendments/` directory
(`find … -type d -name amendments` → empty), although the report's adopt-checklist step 5
refers to one.

`MERGE-REPORT.md` head: "Staged by `corpus-expansion-1`. **Nothing was written into the lane
repo.**" — 172 proposed SOURCES rows accepted / 0 refused, 81 proposed knowledge entries,
rounds 1–16, "lane registry currently holds **51** rows; first staged id is **S052**".

### 1.2 Is there a staged theme on OpenBao / Vault tokens, leases, or self-count / stamp calibration?

**No — on all three counts.** Measured over the whole package (not just the report):

```
$ for t in openbao OpenBao hashicorp HashiCorp vault Vault renew calibrat self-count stamps; do
    printf '%-12s %s\n' "$t" "$(grep -rI -- "$t" /home/vgpnk/Projects/shokuknow/merge/kagi/ 2>/dev/null | wc -l)"; done
openbao     0
OpenBao     0
hashicorp   0
HashiCorp   0
vault       0
Vault       1
renew       0
calibrat    0
self-count  0
stamps      0
```

* **OpenBao / HashiCorp / Vault tokens:** zero hits for `openbao`, `OpenBao`, `hashicorp`,
  `HashiCorp`, `vault` anywhere in the package. The single `Vault` occurrence is a *disclaimer*
  in a staged entry, not a theme:
  `/home/vgpnk/Projects/shokuknow/merge/kagi/knowledge/corpus/knowledge/oidc-federation-trust-policy.md:90`
  — "It does not cover the **Vault-side** audience check on a JWT/OIDC login (lane rows
  S012/S022), which is the consuming side of the same idea." That entry is the round-1 staged
  OIDC trust-policy entry; it explicitly defers the Vault side back to the lane's own rows.
* **Leases:** every `lease` hit in `SOURCES.append.md` is the substring of `release`/`releases`:
  `grep -oiE '.{0,12}lease.{0,12}' …/SOURCES.append.md | grep -viE 'release'` → empty. The 17
  raw `lease` hits are all inside the word "release"/"releases". The three `TTL` hits are all
  TruffleHog cache-TTL rows (S147 `pkg/cache/cache.go`, `trufflehog-verification-cache-bounds-r38.md`,
  `trufflehog-verification-decision-paths.md`), not OpenBao token TTLs.
* **Self-count / stamp calibration:** zero hits for `calibrat`, `self-count` or `stamps` in the
  entire package — the merge package never touches the lane's self-count machinery.

**Candidate entries with paths: none for this round's theme.** The nearest staged neighbours
(adjacent subject, not this round's claim) are, all under
`/home/vgpnk/Projects/shokuknow/merge/kagi/knowledge/corpus/knowledge/`:
`oidc-federation-trust-policy.md` (round1 — the only file that mentions Vault at all, and only
to disclaim it), `cloud-kms-key-lifecycle-custody.md`, `trufflehog-verification-lifecycle.md`,
`trufflehog-verification-cache-bounds-r38.md`, `secret-scanning-verification-status-taxonomy-r37.md`.
Conclusion for the wave: **the merge package contributes nothing to round 49's OpenBao/lease
or self-count work; it is out of scope for this round.**

### 1.3 One live hazard in the package that the L1 must not walk into (id space)

The staged id space is **stale against the live lane registry**:

```
$ grep -oP '^\| S\K[0-9]+' …/merge/kagi/SOURCES.append.md | sort -u | wc -l   → 172  (S052 … S223)
$ grep -oP '^\| S\K[0-9]+' corpus/SOURCES.md | sort -u | wc -l                → 104  (S001 … S104)
$ comm -12 staged_ids lane_ids | wc -l                                     → 53   (S052 … S104)
```

53 staged ids collide with live lane rows, and they are **not** the same pages — e.g. staged
`S052` is "AWS IAM User Guide, Create an OpenID Connect (OIDC) identity provider", while the
lane's `S052` is "The Atom Syndication Format (RFC 4287)". The report's own
"first staged id is **S052**" line is written against a 51-row registry that no longer exists
(lane holds 104 at BASE). Also **7 staged knowledge files already exist in the lane** with
different bytes (`betterleaks-detection-vs-validation.md`, `cdp-bridge-1password-oidc-workflow.md`,
`nist-key-management-guidance-status.md`, `nist-key-management-parts-withdrawal.md`,
`oidc-federation-trust-policy.md`, `secret-scanning-detection-vs-validation.md`,
`trufflehog-verification-lifecycle.md` — every one `DIFFERS` from the staged copy, lane copy
larger). The report's adopt-checklist step 6 covers a *duplicate target* only for S092, so the
other six would be overwritten silently. Round 49 lands **S105** (per its own candidate commit
message), which is above the package's used range but below its ceiling S223 — a future
adopter must renumber before appending. Nothing in this round's write scope touches the
package; this is reported, not applied.

---

## 2. `considerthese/` — newest file and the unimplemented proposals

```
$ ls -la --time-style=full-iso /home/vgpnk/Projects/shokunin/kagi-shokunin/considerthese/
2026-10-19.md  5725  2026-10-19 22:08
2026-10-20.md  9048  2026-10-20 19:13
2026-10-21.md  9455  2026-10-21 08:49
2026-10-22.md 10626  2026-10-25 03:45
2026-10-23.md  3065  2026-10-25 03:45
2026-10-24.md  2295  2026-10-25 03:45
2026-10-25.md  5255  2026-10-29 00:36
2026-10-26.md  3681  2026-10-29 00:36   ← newest by mtime and by name
```

**Newest file: `considerthese/2026-10-26.md`** (both the largest mtime and the latest date;
`ls -t` lists it first). It is a HOLD-era reflection: round-28 close, the `release-clock.py`
`STABLE_TITLE_RE` fail-open, and the "self-claims of totality" lesson. Its section
`## Self-improvement suggestions (proposals only, not applied)` is at **line 47**, with four
proposals at lines 49, 55, 60, 64.

### 2.1 Is there a still-unimplemented proposal this round's claims fit?

**Yes — proposal 3, and this round's C2 is exactly its class.** Verbatim, with line numbers:

```
considerthese/2026-10-26.md:60-63
3. **Mark known-defective instrument output.** Until D1 is fixed, have
   `release-clock.py` (or its wrapper) append a `KNOWN_DEFECT: D1` qualifier to a
   `CLEAN` verdict, so nobody quotes a CLEAN result without the caveat.
```

The proposal's *rule* (a verdict from an instrument with an open defect must never be quoted
bare) is already a lane quality criterion — `corpus/QUALITY.md:238` (QM55), which cites
`considerthese/2026-10-26.md` proposal 3 by name — but the *implementation* is absent:
`grep -c 'KNOWN_DEFECT' corpus/release-clock.py` → **0** at BASE. So the proposal is still
unimplemented in the instrument.

**Why this round's claims fit it.** Round 49's C2 is the calibration claim that the lane's
*stated* self-counts agree with the *executed* state; the C1 predicate additionally requires
the entry to carry a `## Measured (round 49` section naming the tool version. Both are the
"don't quote a bare verdict" rule applied to the round's own instruments: the round-49 C2
counter's own guard G5 keeps the two operator-routed reds visible
(`PV-FEEDTOKEN-SHAPES`, `PV-FEEDTOKEN-SELFTEST`) rather than allowlisting them away, which is
QM55's rule made executable. The lesson draft (K49ScribeLesson) should cite QM55 + proposal 3
as the standing precedent rather than invent a new criterion.

**Caveat the L1 must not paper over:** proposal 3's *premise* ("Until D1 is fixed") is **false
at BASE** — round 47 found the D1 fail-open no longer reproduces, and this seat re-confirmed it
at BASE:

```
$ python3 -  # loads corpus/release-clock.py at BASE and calls its own STABLE_TITLE_RE.match
'Python 3.15.1'  -> 3.15.1
'Python 3.15.1.' -> 3.15.1     ← the period-suffixed title IS matched now
'Python 3.15.01.'-> 3.15.01
'v3.13.3'        -> 3.13.3
```

So the proposal must be cited as its **rule** (QM55), not taken as a D1 repair. The other three
proposals do not fit this round: 1 (repair-only release path under a HOLD) and 2
(machine-readable lane status) are operator policy / bookkeeping — note SCORECARD.md:14
already carries a `lane-status:` line, so proposal 2 is partly superseded — and 4
(`considerthese/BACKLOG.md`) is bookkeeping no claim needs; the file
`considerthese/BACKLOG.md` does not exist (`test -e` → absent).

The **lesson-level** theme (not a proposal, but the same class) is at
`considerthese/2026-10-26.md:33-36`: "**Self-claims of totality are bounded by the
fixtures.** … Read the lane's 'total' as 'total over the fixtures I wrote' until a differential
or adversarial check says otherwise." Round 48's lesson already recorded this as "the class C2
measures". Round 49's C2 is a second instance of it, and this round's C1 (an executed trial
against a real `bao server -dev`, not a documented-only claim) is the differential check the
sentence asks for.

---

## 3. Round-48 `§Routed` — which of the 9 routed items are still open at BASE

Source: `corpus/lessons/round-48.md:58-68` (`## Routed (named, not claimed this round)`).
Every check below is read-only at BASE `89afe91878f10805921d3caa67d28d21b33226da`.

| # | routed item | still open at BASE? | one-line command + output |
|---|---|---|---|
| 1 | **SD10 into `corpus/self-description-sweep.sh`** — header reads "SD1–SD9" | **YES — open** (2nd round carried) | `git show 89afe91:corpus/self-description-sweep.sh \| sed -n '2p'` → `# self-description-sweep.sh — round 34, self-description counter (SD1–SD9).` |
| 2 | **round-47 C2 predicate prose (E48-1) appended to `plans/round-47.md`** | **NO — closed** (appended by the round-49 candidate commit) | at BASE: `git show 89afe91:plans/round-47.md \| grep -c 'E48-1'` → `0`; at the round-49 candidate `a74ae53` the row exists and `git log --oneline -1 a74ae53` names "E48-1 appended to plans/round-47.md" |
| 3 | **S098 is a `rejected` row with `recheck: on-release`** | **YES — open** (unchanged since round 46 D-7) | `git show 89afe91:corpus/SOURCES.md \| sed -n '105p' \| grep -o '\| rejected \| 2026-11-05 \| on-release \|'` → `\| rejected \| 2026-11-05 \| on-release \|` |
| 4 | **R25-02 / R29-01 / R29-02 open operator-routed reds** | **YES — open** | `git show 89afe91:SCORECARD.md \| sed -n '14p'` → `lane-status: open — as-of:2026-11-04 — dispatch unblocked; 3 operator-routed reds (R25-02,R29-01,R29-02) stay red`; and the C2 counter's G5 keeps them: `bash corpus/self-counts.py` at BASE prints `POLICY PV-FEEDTOKEN-SHAPES ledger:R29-02 command not allowlisted` / `POLICY PV-FEEDTOKEN-SELFTEST ledger:R29-01 command not allowlisted` |
| 5 | **normalizer gap on the Vault lease page's MDX block** | **YES — open** (normalizer unchanged) | `git log --oneline 252ef1ca..89afe91 -- corpus/rendered-text-v1.py` → **empty** (0 commits); the gap itself re-measured below |
| 6 | **C1 named ceilings (shim-detection by the trial; explicit `--config` bypass of SH5)** | **YES — open as ceilings**; and the round-49 trial does **not** repeat them (it is not the round-48 trial) | round-48's committed trial: `git show 89afe91:corpus/sops-age-trial.sh \| grep -cE 'printenv\|/proc/self\|readlink\|realpath\|--config'` → **0** (it neither inspects its own PATH/shim bytes nor passes `--config`); the ceiling is a property of the *counter design*, not of the committed script — round-49's own plan names the equivalent ceilings ("a trial that detects the counter's shims … a trial that calls the HTTP API directly (curl) bypasses every shim") |
| 7 | **C2 named ceiling: K07's `claims=N` is revision-bound; the line must name the revision it measured** | **YES — open** (and now *firing*, see below) | at BASE `git show 89afe91:SCORECARD.md \| sed -n '717p' \| grep -o 'claims=23'` → `claims=23`; at the round-49 candidate the manifest gains two rows, so the executed reading moves to 25 while the stated line still says 23 — measured: `bash corpus/claims-declared.sh --root .` in a scratch clone of `a74ae53` → `CLAIMS_DECLARED: CLEAN (claims=25)` vs stated `claims=23` |
| 8 | **`python3 corpus/self-counts.py` reads `SELF_COUNTS: POLICY (claims=63 stale=3 …)`; SKILL.md:46, PROVINCE.md:73, corpus/README.md:65 say 122 stamps, the table holds 123** | **YES — open at BASE** — this is precisely round 49's C2 target (6 → 0) | BASE (clean clone, `git clone --shared` of 89afe91, `python3 corpus/self-counts.py`): `STALE SC-SKILL-STAMPS SKILL.md:46 claimed=122 live=123` / `STALE PV-STAMPS PROVINCE.md:73 claimed=122 live=123` / `STALE RD-STAMPS corpus/README.md:65 claimed=122 live=123` / `SETUP RD-DOCS-ROWLINKED ledger:R14-01 exit=1 expected=0` (×3) → `SELF_COUNTS: POLICY (claims=63 stale=3 unlocated=0 ambiguous=0 policy=2 setup=3)` |
| 9 | **C2 counter ceilings (D-9): a duplicated / fenced / comment-wrapped `## Capabilities` heading lets a stated reading escape the section reader** | **YES — open** (counter unchanged; candidate uses none of the shapes) | `git show 89afe91:plans/round-48-c2.sh \| sed -n '46p'` → `awk '/^## /{ insec = ($0 == "## Capabilities"); next } insec' "$W/scorecard.md" > "$W/cap.md"`; `git log --oneline 164f0ea..89afe91 -- plans/round-48-c2.sh` → **empty** (frozen, never amended); the shape is harmless in the round-49 candidate because round 49's C2 counter does not read SCORECARD at all (`grep -c SCORECARD plans/round-49-c2.sh` → 0) |

**Summary: 8 of the 9 round-48 routed items are still open at BASE; only #2 (E48-1 appended to
`plans/round-47.md`) has since been closed, and it was closed by the round-49 candidate commit
itself.** Three of the eight are directly re-taken by this round: #8 → round 49's C2 (6 → 0),
#6 → round 49's C1 named ceilings (same class, re-named in the plan), #7 → now material,
because the round-49 candidate's two new manifest rows move the executed `claims-declared`
count from 23 to 25 while `SCORECARD.md:717` still states `claims=23`.

### 3.1 Re-measurement of routed #5 (the normalizer MDX gap), with the raw/normalised contrast

Committed Vault-lease capture at BASE: `.ufo/waves/round-47/capture/S013.body` (the lane's own
capture for S013/S023). Raw grep vs the lane's normalizer:

```
$ grep -o "does not issue leases" .ufo/waves/round-47/capture/S013.body | wc -l   → 2
$ python3  # corpus/rendered-text-v1.py normalize_bytes() on the same bytes
   raw hits: 2   normalized hits: 1
```

The two raw occurrences are at byte offsets 115350 and 251305; the second one (the MDX
`mdx("p",null,…)` payload) sits **inside a `<script>` block** (last `<script` at 135219, last
`</script` at 9807) and is therefore removed by step 2 of `rendered-text-v1`, while the visible
HTML copy at 115350 survives. So the routed statement stands exactly as round 47 left it: the
block is in the raw text and gone from the normalised text, so any verdict that relies on the
normalizer to see it would report a false loss. The registry's own S013 quote ("All dynamic
secrets in Vault are required to have a lease.") is unaffected — it survives normalisation
(`normalized contains: True`), and so does the KV sentence. Nothing about item 5 has moved.

---

## 4. `https://openbao.org/docs/concepts/tokens/` — headings and the docs Version label

Fetch (public read, no form post, no remote write):

```
$ curl -fsSL -o openbao-tokens.html https://openbao.org/docs/concepts/tokens/ ; echo "rc=$?"
rc=0
$ sha256sum openbao-tokens.html → ea9bdafe74102b20b62c620b88b0e90feea12bda80fffb832fb31c77f50548ef
$ wc -c openbao-tokens.html     → 47384
```

The body is copied into this seat's report dir as
`.ufo/waves/round-49/build/K49ScoutSources/openbao-tokens-20261106.body` (same bytes).

### 4.1 The docs Version label

```
$ grep -oE 'Version: [^<]*|docusaurus_version[^>]*|version-[0-9][^"<]*' openbao-tokens.html | sort -u
Version: Version 2.7.x
docusaurus_version content=2.7.x /
version-2.7.x docs-doc-page docs-doc-id-concepts/tokens
```

**Version label: `Version: Version 2.7.x`** (`docusaurus_version content=2.7.x`), page title
`Tokens | OpenBao`, canonical `https://openbao.org/docs/concepts/tokens/`. This matches what
the lane's registry rows already record ("OpenBao 2.7.x" in S016/S021/S026) and what the
round-49 entry cites — **no drift in the docs version label**.

### 4.2 Section headings (h1–h4, in document order)

```
h1: Tokens
h2: Token formats
h2: Token types
h2: The token store
h2: Root tokens
h2: Token hierarchies and orphan tokens
h2: Token accessors
h2: Token Time-To-Live, periodic tokens, and explicit max TTLs
h3: The general case
h3: Explicit max TTLs
h3: Periodic tokens
h2: CIDR-Bound tokens
h2: Token types in detail
h3: Service tokens
h3: Batch tokens
h3: Token type comparison
h3: Service vs. batch token lease handling
h4: Service tokens
h4: Batch tokens
```

19 headings (1 h1, 8 h2, 8 h3, 2 h4). These are the headings the round-49 C1 tests cite:
§Token Time-To-Live (T1/T2/T5), §Token type comparison (T3), §Token hierarchies and orphan
tokens (T4), and §Service vs. batch token lease handling (T5's lease half). Note the "Service
vs. batch token lease handling" sub-headings appear twice under different parents (h3 and h4),
which is why the page's own TOC lists `Service tokens` / `Batch tokens` twice — a locator that
keys on heading text alone must disambiguate by level.

### 4.3 The three quotes the round-49 entry leans on still locate in the live body

```
'When a parent token is revoked, all of its child tokens -- and all of their leases -- are revoked as well.'  → True
'Every non-root token has a time-to-live (TTL) associated with it'                                                → True
'before the returned TTL has expired'   (entry line 58's [INFERENCE] anchor)                                    → True
'it, and its associated leases, are revoked'                                                                     → True
```

(The first is the S016 registry row's own quote, verbatim.)

### 4.4 Byte-level relation to the lane's committed capture — worth recording

The lane's committed capture for this URL is
`.ufo/waves/round-26/build/ClockS016-evidence/tokens.html`
(sha256 `5229521866ce21fa8cd8f8ecf63d696877b8cb0a2ec25e89de683557b385f82c`, 47384 B — the
digest the registry's `corpus/source-fetches.tsv` S016 row pins, `decoded-http-body-volatile-v1`).
Today's live body is the **same byte count (47384) but a different digest**, and the difference
is entirely in the Docusaurus build-hash strings:

```
$ cmp …/ClockS016-evidence/tokens.html openbao-tokens.html
differ: char 2710, line 1
$ python3  # byte-level diff of the two 47384-byte bodies
differing bytes: 492 of 47384, in 136 contiguous runs
  bytes 2709-2716: A=b'f04…e9fc' B=b'eb1…80b1'      ← styles.<hash>.css
  bytes 2760-2767: A=b'ad4a98e2' B=b'640503f7'      ← runtime~main.<hash>.js
  bytes 2815-2821: A=b'aa34622'  B=b'3cfed04'        ← main.<hash>.js
  bytes 3951+     : the remaining 133 runs are docusaurus per-element build ids (Ay6→PoK, ubui→A07R, jRBr→wPnK, …)
```

**Heading set and order are identical** to the committed capture (19 headings, `only in
round-26: []`, `only in live: []`, `same order: True`), and all four quotes above locate in
both. So the *teaching content* of the page is unchanged since the 2026-10-21 capture; only
Docusaurus' own asset hashes moved. This is the same volatility class the lane already records
for this row (`decoded-http-body-volatile-v1`, and `corpus/inrow-pins.tsv` classifies the
historical in-row pin `c083fdca…` as `non-reproducing` with the note "pin c083fdca… vs capture
raw 52295218… / normalized ed949658…"). **No registry write was made by this seat**; a new row
for this page is the ExecSources seat's call, and if one is opened it must carry today's
digest `ea9bdafe…` and 47384 B, not the 2026-10-21 pair.

---

## 5. Incidental findings the wave should know (read-only, no action taken)

1. **Routed #7 is now firing, not merely named.** The round-49 candidate adds two rows to
   `corpus/claims-declared.tsv` (49/C1/operability, 49/C2/calibration) and a
   `## Round 49 — post-move` heading to SCORECARD.md. Measured in a scratch clone of the
   candidate `a74ae53`: `bash corpus/claims-declared.sh --root .` → `CLAIMS_DECLARED: CLEAN (claims=25)`,
   while `SCORECARD.md`'s "Current readings" line still states `claims=23`. Round 48's frozen
   C2 counter keys K07 on exactly this reading, so re-running `plans/round-48-c2.sh` against the
   round-49 candidate would read K07 MISMATCH. Round 49's own C2 counter does not read
   SCORECARD (`grep -c SCORECARD plans/round-49-c2.sh` → 0), so the round-49 predicate is
   unaffected — but the *stated reading* in SCORECARD is now stale, which is precisely the
   QM60 defect class. Worth a lesson line and, if the L1 wants, a current-readings line.
2. **`plans/round-49-c2.sh`'s G-guard does not cover `corpus/claim-ledger.tsv`**, where the
   six keys' live sources are *defined*. This is stated in the candidate-side leg's own header
   (`leg-c2-live-sources.sh`): a candidate can repoint R12-03/R14-01 at a stub printing the
   numbers the documents already state and read `value=0` with the repo state unchanged. The
   leg accordingly requires the two source rows to be byte-identical to BASE and re-derives all
   six quantities independently. At the candidate the leg reads
   `LEG_C2: FAIL rev=a74ae53 source-redefined: R12-03 R14-01` — because the candidate
   *migrated* those two rows' expectations (`^122$` → `^124$`; `entries=35 row_linked=32` →
   `entries=36 row_linked=33 by_hand=3 … duplicate_reasons=0`) while keeping their **command
   columns byte-identical** (`grep -c '[^[:space:]]' corpus/stamps.tsv` and
   `bash corpus/claim-ledger.sh docs` respectively). The migration is what makes C2 honest (the
   old expectations were stale), so the leg's row-identity check and the candidate's necessary
   migration are in tension; the discriminator is the command column, not the whole row.
   Not this seat's call to resolve — reported for the L1/critic.
3. **The round-45 undeclared entry is what makes three of the six C2 keys SETUP**, and the
   round-49 candidate fixes it correctly: at BASE the docs audit reads
   `DOC_AUDIT: BROKEN (entries=36 row_linked=32 by_hand=3 undeclared=1 missing_ids=0 unpinned=1
   duplicate_reasons=0 floor=18)` with `UNDECLARED corpus/knowledge/iso-11770-3-edition-status.md
   (no Reverify line)` and `UNPINNED … (knowledge entry is not a row in the stamps file)`.
   This seat reproduced the fix in a scratch clone: adding `Reverify: R21-02` to that entry plus
   one stamps row turns the audit into
   `DOC_AUDIT: CLEAN (entries=36 row_linked=33 by_hand=3 undeclared=0 missing_ids=0 unpinned=0
   duplicate_reasons=0)`, and the six keys then read `STALE SC-SKILL-STAMPS claimed=122 live=124`,
   `STALE PV-STAMPS claimed=122 live=124`, `STALE RD-STAMPS claimed=122 live=124`,
   `STALE RD-DOCS-ROWLINKED claimed=32 live=33`, `OK RD-DOCS-BYHAND claimed=3 live=3`,
   `STALE RD-DOCS-ENTRIES claimed=35 live=36` — i.e. the documented counts must move to
   124 / 33 / 3 / 36. The candidate's stated counts are exactly those.
4. **`considerthese/BACKLOG.md` does not exist** and no receipt-checking gate exists
   (`grep -rln 'GATE_NAME' corpus/` → empty), so round-49's quoted gate outputs are not
   receipt-bound by any instrument.

---

## 6. Scope and honesty statement

* All four questions answered above with a command and its output, or a file:line.
* No `Report:` path other than this file was written.
* No edit was made to `corpus/`, `plans/`, `SCORECARD.md`, `LOG.md`, `SKILL.md`, `PROVINCE.md`,
  `SHONEN.md`, `SKILL.md`, `PROVINCE.md`, `README.md`, `QUALITY`, `SOURCES.md`, any registry
  row, `MANIFEST.json`, `.ufo/state`, `.ufo/watchdog.log`, the fleet root, or any sibling repo.
* No git mutation (no add/commit/stash/checkout/switch/reset/pull/push, no mutating jj) was
  performed in the lane or the fleet. Scratch clones were made with `git clone --shared` and
  their top level asserted with `git rev-parse --show-toplevel` before use.
* No `bao` server was started by this seat, no token was created, read, printed or stored; the
  only OpenBao artefact is a public documentation page body (one HTTP GET, no form post, no
  remote write) and the lane's already-committed capture.
* Nothing was fabricated: the fetch in §4 ran and its output is quoted; the round-49 candidate
  leg outputs are quoted from `.ufo/waves/round-49/final/candidate-legs.txt` as they stand.

**Remaining unknowns (not measured here, and not claimed):** whether the round-49 C1 trial
discriminates under the real `bao` binary (the ExecTrial seat's measurement); whether the
round-49 C2 counter reads 0 at the candidate (the C2 seat's measurement); and whether the L1
lands a new registry row for the OpenBao tokens page (the ExecSources seat's call). This seat
read the candidate tree only to check routed items against BASE; it made no change to it.
