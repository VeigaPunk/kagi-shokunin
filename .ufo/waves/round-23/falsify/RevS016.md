# RevS016 — S016→S026 supersession and C2 freshness (round 23, falsification)

Seat: `RevS016`. Base: `d218603b74099ddca0bd8f869516fc41db0979bf`. During the audit the lane
advanced through eight round-23 commits to `58bd8d7` (HEAD, 2026-10-21 01:16:35). At the final
measurement the census (`2d1bbbe3…`), `source-fetches.tsv` (`6e26e140…`), `SOURCES.md`
(`c6ea91ab…`), closure script/JSON, claim ledger and lesson (`ae29c16c…`) all match HEAD; the gates
read those committed files.
Scope: adversarial re-measurement of the S016 supersession story, the S026 locator fix, and the C2
`SC_FETCH` freshness gate. Read-only on the lane; the only lane file written is this report. All
mutation fixtures were built under `/tmp`; no lane corpus/script/ledger/evidence file was edited.

## Measurement snapshots (the tree moved during the run)

| snapshot | time (-03:00) | `corpus/sources-census.sh` | `corpus/source-fetches.tsv` | lesson | gate result |
|---|---|---|---|---|---|
| A | 2026-10-21T01:02:09 | `80966e208321348aad0ae6dd5b65987bccc4901e99fcba9f94feedd150228781` (mtime 00:57:55) | `ccc9ae6ec1b4bfa2ea8d879762a8fca18a84673145b54a04f39530de2d65a0af` | read at the time as “seven distinct URLs” | **exit 1, shell crash** (see §4.2) |
| B | 2026-10-21T01:03:30 | `24d834cc85344b762b485ef2b1c44cdbddab4e641f96acbaf2853823b02af057` | `ccc9ae6e…` | `bce51c92…` (nine URLs) | exit 0, CLEAN |
| C | 2026-10-21T01:05:47 | `24d834cc…` (mtime 01:02:21) | `a78fde7b1560660109939b3467562b9f6e17e20769843df5af25576479dc1cc3` (mtime 01:04:32) | `2f53cf690d81666a4b2510e6b611bd55cdf61a260020c28c6480d788183dcf53` (mtime 01:04:15) | exit 0, CLEAN |
| D (intermediate) | 2026-10-21T01:08:54 | `6d4190a7…` | `846b2037…` (mtime 01:06:58) | `cf79cd0c…` | exit 0, CLEAN; header now said no equality while the code still enforced it |
| E (intermediate) | 2026-10-21T01:10:59 | `511deb27…` | `6e26e140…` | `900eadcb…` | exit 0, CLEAN; equality blocks removed; header, claim and code agree |
| F (intermediate) | 2026-10-21T01:14:30 | `511deb27…` | `6e26e140…` | `93df7d34…` | exit 0, CLEAN; C1 selftest now 14 |
| G (intermediate) | 2026-10-21T01:16:21 | `2d1bbbe3…` | `6e26e140…` | `4e8ab66f…` | exit 0, CLEAN; C1 CLEAN fixed=6 reported=3, selftest 14 |
| H (final) | 2026-10-21T01:17:42 | `2d1bbbe36ed21c2755d604937dc10d91fa71645847c82124bf729f4c8e0b95bc` | `6e26e14032729070f38b5e0cb90914385f04c0ef9f4fe1db210af6439191094d` | `ae29c16c9f367df9088d21fa0c6cf42ca1d11e99517512fab325c7bf99866b86` | exit 0, CLEAN; HEAD `58bd8d7`; measured paths committed/clean |

`corpus/SOURCES.md` was `06dde644…` through snapshot E and advanced at 01:13:51 to
`c6ea91ab2468352263a7442a2ff7815084d68374c94433bbb6b4cccc639c632d` by appending the Round-23
lead-disposition prose; the S016 row (`:22`, no-LF hash `2452a1c2…`), S026 row (`:32`, with-LF hash
`56ebd042…`) and Paths line (`:38`) are byte-identical. Snapshot H is the final measurement; G→H
changes only the lesson file (hash `ae29c16c…`, key lines 29/43/60/61/115/120/175/177 unchanged)
and commits the measured worktree at HEAD `58bd8d7`. B–H
differ in tsv/census header wording, lesson line shifts, census implementation cleanup, the C1
disposition split (fixed=7/reported=2 → fixed=6/reported=3) and the C1 selftest count (13 → 14);
the S026 row (`source-fetches.tsv:46`) is byte-identical throughout, so the content verdicts below
hold at every snapshot. At E/F/G/H the cross-capture equality checks are gone, resolving the C/D-time
contradiction (§4.3). Snapshot A is reported only where the transient matters.

HEAD at the final measurement is `58bd8d7`; `git log --oneline d218603..HEAD` shows eight
round-23 commits (`e1884c6` … `58bd8d7`). The measured `sources-census.sh`, `source-fetches.tsv`,
`SOURCES.md`, closure script/JSON, claim ledger and lesson hashes all match HEAD (`git status`
clean for these paths); `corpus/stamps.tsv` may still be a worktree edit.

## What I attacked

1. Why S016 needed supersession: non-reproducible pin, line-wrapped quote, missing supersession edge.
2. Whether S026 fixes the locator (representation, digest, quote, section) and leaves Vault/KV claims untouched.
3. C2 operability: the real-tree `SC_FETCH` run and its 59-case selftest, plus fail-closed probes on the
   declared fields (quote, raw digest, normalized digest, supersession target).
4. Cheap cross-axis checks: C1 closure gate and C3 hermetic-cells gate, because the milestone covers
   closure/provenance/cells and the judged axes are calibration/freshness/operability.

## 1. Why S016 needed supersession — all three causes confirmed

### 1.1 Non-reproducible in-row pin

`corpus/SOURCES.md:22` records:

`Fetch sha256: c083fdca8645f6248a3c42a8c0b912b356de281dc2da0099668a7850ba348380`

Live re-fetch with the declared request profile:

```
curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)' \
  -o /tmp/r23tokens.html https://openbao.org/docs/concepts/tokens/ -w 'http=%{http_code} final=%{url_effective} size=%{size_download}\n'
# http=200 final=https://openbao.org/docs/concepts/tokens/ size=12527
# exit 0
sha256sum /tmp/r23tokens.html ; wc -c /tmp/r23tokens.html
# 5229521866ce21fa8cd8f8ecf63d696877b8cb0a2ec25e89de683557b385f82c  /tmp/r23tokens.html
# 47384 /tmp/r23tokens.html
```

Rendered-text normalization (the S026 declaration: strip script/style, tags→single space,
`html.unescape`, collapse whitespace, trim, UTF-8):

```
# 14,571 characters / 14,608 UTF-8 bytes
# ed949658b434fa769b89c682160f77ad153f5c6657808706db5858506ce0d2e3
```

The legacy pin matches none of the representations I tested:

| representation | value | matches `c083fdca…`? |
|---|---|---|
| decoded HTTP body | 47,384 B, `52295218…` | no |
| rendered-text-v1 | `ed949658…` | no |
| gzip transfer entity (`curl -sS -H 'Accept-Encoding: gzip'`, 12,527 B) | `5ae6661f19819fd51d3f132711406ae1c0ef744c76413d1d59f261978c019867` | no |
| CRLF-normalized variant | `11053405089f09cc344180d7a9bd974a2014ce9f6608735d588d6d8aeb1cdf7b` | no |
| zero-width-stripped variant | `c3d072d7985d2be7789ecfc5c33251d819ba8d73b71c9e1774a8e3f0459a3e78` | no |

This confirms the lesson's bounded statement (`corpus/lessons/round-23.md:115-116`: S016's
`c083fdca…` matches neither raw `52295218…` nor normalized `ed949658…`) and SourceS016 §4. It does
not prove the 2026-10-19 bytes are stale; no 2026-10-19 snapshot was replayed. `brotli`/`deflate`
requests returned the identity body (47,384 B, `52295218…`), so no separate compressed entity was
observed for those encodings.

Coverage fact: `awk -F'\t' '$1=="S016"' corpus/source-fetches.tsv | wc -l` → `0`. S016 has no
declared provenance row; the only pin is the legacy one. The gate's own coverage rule
(`corpus/sources-census.sh:57`) is “in-row `Fetch sha256:` **or** a provenance row”, so S016 passes
coverage without any reproducible pin.

### 1.2 Line-wrapped quote with no declared normalization

The served raw body at byte offset 29,523 contains:

```
...all of its child tokens -- and all\nof their leases -- are revoked as well...
```

`"When a parent token is revoked, all of its child tokens -- and all of their leases -- are revoked as well."`
is an exact substring count `0` in the raw body and count `1` after whitespace collapse. The upstream
mdx at the pinned commit is also line-wrapped:

```
curl -fsSL --compressed -A '...' -o /tmp/tokens.mdx \
  https://raw.githubusercontent.com/openbao/openbao/ec6ba09f484bf01d5892e3bcac63084127be2f27/website/content/docs/concepts/tokens.mdx
# http=200, transfer 5,457 B, decoded file 15,269 B
# sha256 f05ae2babff6eb97b51a7f21943c3279f50da033469540badb46c7780812ab28
# exact quote count 0; whitespace-collapsed count 1
# repr: 'When a parent token is revoked, all of its child tokens -- and all\nof their leases -- are revoked as well.'
```

S016's row quotes the sentence without declaring a normalization (`corpus/SOURCES.md:22`), so a
byte-contiguity check fails and a lenient check passes without recording why. This is exactly the
defect S026's `rendered-text-v1` declaration addresses.

### 1.3 Missing supersession edge

S016 remains an ordinary active row: `status=mined`, no disposition field, and
`sed -n '22p' corpus/SOURCES.md | grep -c S026` → `0`. The consuming entry still cites S016:

- `corpus/knowledge/vault-openbao-token-lease-lifecycle.md:3` (`source:`) and `:5` (`recheck:`) name S016 and not S026.
- `grep -c S026 corpus/knowledge/vault-openbao-token-lease-lifecycle.md` → `0`.
- `corpus/SOURCES.md:38` (Paths) still routes `S012 → S013 → S014 → S015 → S016` with no supersession annotation.
- S026's only used-by consumer is `corpus/lessons/round-23.md` (`corpus/SOURCES.md:32`), and
  `corpus/lessons/round-23.md:29` is the only place the edge is written.

The edge is prose in S026's description cell; it is not a machine field. On the final snapshot the
gate contains no supersession code at all:

```
grep -n 'supersed' corpus/sources-census.sh
# NO_SUPERSEDES_CODE
```

A mutation of the edge target still passes: copy the final tree to `/tmp/r23s`, replace
`supersedes S016` with `supersedes S999`, run the final gate copy:

```
FINDING: none
SOURCES_CENSUS: CLEAN (rows=26 A=24 B=0 C=2 queued=1 mined=24 rejected=1 entries_sourced=4 legacy=21)
exit 0
```

So the “missing supersession edge” was not fixed at the machine level; it was moved from S016 to
S026 as prose. S016's row is byte-stable (see §2), which is good for history, but a pointer follower
still lands on the non-reproducible pin.

## 2. Does S026 fix the locator? — confirmed at row/content level, not propagated

S026 (`corpus/SOURCES.md:32`) is a new A/mined row for the same URL, with
`supersedes S016 — record the quote under rendered-text-v1 and the current decoded-body digest`.
Its provenance row is `corpus/source-fetches.tsv:46`:

```
S026  mined  0be2cff96b982a3557e21dcbd0e768b57ecdc1f8b02b085ce25bb556516aa2ee
  https://openbao.org/docs/concepts/tokens/  …  200  …  2026-10-21
  decoded-http-body-volatile-v1
  5229521866ce21fa8cd8f8ecf63d696877b8cb0a2ec25e89de683557b385f82c  47384  -
  "When a parent token is revoked, … are revoked as well."
  rendered-text-v1  ed949658b434fa769b89c682160f77ad153f5c6657808706db5858506ce0d2e3
  Token hierarchies and orphan tokens
```

Confirmations:

- **Row identity:** all 10 provenance rows recompute
  `sha256("id\tstatus\turl\n")` correctly (`row_identity_ok 10 bad []`), including S026's
  `0be2cff9…`.
- **URL/status:** URL equals the S016/S026 source cell exactly (trailing slash preserved); status
  `mined` matches the registry. The final gate confirms this on the real tree.
- **Raw digest/bytes:** live fetch reproduces `52295218…` at `47,384` bytes exactly.
- **Normalized digest:** live normalization reproduces `ed949658…` (`14,571` chars, `14,608` bytes)
  exactly.
- **Quote:** 22 whitespace tokens; exact substring count `1` in the normalized text and `0` in raw;
  located under the `h2` with unquoted `id=token-hierarchies-and-orphan-tokens`, whose rendered
  text is “Token hierarchies and orphan tokens” (the declared location). The heading-id parser must
  tolerate unquoted attributes; the observed HTML uses `id=…` for all `h2` ids.
- **S016 row untouched:** `sed -n '22p' corpus/SOURCES.md | tr -d '\n' | sha256sum` →
  `2452a1c2562216df7261e2f9e263f6d348451838898afa08c5803f51fc640e06` (685 chars), matching
  SourceS016's recorded row hash; the base and current line are identical with newline
  (`066d4a7e…`, 695 B). The old row was not silently rewritten.

**Not propagated:** S026 is not cited by the consuming knowledge entry; E3's `source:`/`recheck:`
lines and the Paths line still resolve to S016 (§1.3). The corrected active locator is reachable
only by reading S026 or the lesson. This is consistent with the round's own debt note
(`corpus/lessons/round-23.md`, M23-2: supersession/used-by edges are prose-only routed debt), but a
claim that “S026 fixes the locator” must say **row-level locator only**.

## 3. Vault/KV claims — confirmed untouched

- S026's description explicitly bounds itself: “with no Vault-token or KV-retention claim”
  (`corpus/SOURCES.md:32`), and its only quote is the OpenBao parent-token/lease sentence.
- The Vault/OpenBao knowledge entry is byte-identical to the base:
  `git diff --stat d218603 -- corpus/knowledge/vault-openbao-token-lease-lifecycle.md` → empty;
  sha256 `4932f37f6e4bc0cf312f9d844b1ab215cb66248846664715515e0fa8d7b17298`.
- The only knowledge file changed relative to base `d218603` is
  `corpus/knowledge/op-ref-consumption.md` (SETUP/DRIFT probe wording), now committed in the
  round-23 series, which contains no Vault/KV claim from this surface.
- S026 is not cited by the Vault/OpenBao entry (`grep -c S026` → `0`), so it neither widens nor
  rewrites the Vault/KV claims.

Verdict: **confirmed**; the fix is OpenBao-token-scoped. The unpropagated edge is an OpenBao-token
consumer issue, not a Vault/KV spill.

## 4. C2 gate and freshness — final run green, with live defects and hard bounds

### 4.1 Final gate and selftest (snapshot H)

```
bash corpus/sources-census.sh
SOURCES_CENSUS: CLEAN (rows=26 A=24 B=0 C=2 queued=1 mined=24 rejected=1 entries_sourced=4 legacy=21)
exit 0

bash corpus/sources-census.sh --selftest
SOURCES_CENSUS_SELFTEST: PASS (59 cases)
exit 0
```

So the final snapshot supports the C2 claim's gate line and its “selftest 59 cases” count. The 59
cases include 12 `fetch-*` cases (`corpus/sources-census.sh:542-553`).

### 4.2 Transient real-tree crash at snapshot A (observed, then resolved)

At census sha `80966e2…` (mtime 00:57:55) the real gate did not run:

```
bash corpus/sources-census.sh
corpus/sources-census.sh: line 242: S007: unbound variable
exit 1
```

Cause: the file used `SUPERSEDED[$fid]` at line 242 but the associative array was not declared at
line 229 (`declare -A FURL=() FINROW=() FSEEN=() FDIG=() FNRM=()`), under `set -uo pipefail`
(line 107). The first real registry row whose description starts `supersedes S…` is S019 → S007
(rows S019→S007, S020→S006, S022→S012, S023→S013, S025→S014, S026→S016), so the loop crashed on
`S007` before any semantic check finished.

The 59-case selftest was still green at snapshot A because the selftest base fixture
(`corpus/sources-census.sh:332-350`) has no `supersedes` row; the path was real-tree-only. A
diagnostic copy outside the lane with only `SUPERSEDED=()` added to the declaration produced the
exact expected line:

```
bash /tmp/r23census-patched.sh --root /home/vgpnk/Projects/shokunin/kagi-shokunin
SOURCES_CENSUS: CLEAN (rows=26 A=24 B=0 C=2 queued=1 mined=24 rejected=1 entries_sourced=4 legacy=21)
exit 0
```

At final snapshots C/D/E/F/G/H the parser was removed entirely (`grep 'supersed'` → none) and the real gate is
green. This transient is therefore **not** a current gate failure, but it is a calibration fact:
the 59-case selftest did not prove the real-tree gate runs; it proved finding ids on a fixture whose
registry lacks the supersession shape. Any claim citing the selftest as gate evidence should pin the
script hash and say so.

### 4.3 Cross-capture equality: transient contradiction at C/D, resolved at E

At snapshots C/D the declaration and the implementation disagreed:

- `corpus/source-fetches.tsv:17-21` said of `decoded-http-body-volatile-v1`: the normalized digest
  is “a more stable point attestation, still chrome-sensitive, never a drift pin. **No
  cross-capture equality is enforced.**”
- `corpus/sources-census.sh:64-66` said “Captures are point attestations: no cross-capture
  equality is enforced, only one provenance row per id.”
- `corpus/lessons/round-23.md:61` (C2) said only “census `SC_FETCH` enforces shape, identity, URL
  and row-identity digest; captures are point attestations” — no equality claim.
- `corpus/sources-census.sh:275-289` nevertheless enforced equality: non-volatile rows had to agree
  on the raw digest (`FDIG`, lines 279-284) and rendered-text rows on the normalized digest
  (`FNRM`, lines 285-289); the comment at 275-276 said “Two captures of one URL under one
  representation must agree.”

Mutation proof at D:

```
# S026 normalized_sha256 := 0*64
FINDING SC_FETCH id=S026 same-url-normalized-disagreement url=https://openbao.org/docs/concepts/tokens/
SOURCES_CENSUS: FAILED (findings=1 rows=26)
exit 1
```

At snapshot E (still true at F/G/H; `sources-census.sh` `511deb27…`, mtime 01:10:59) the `FDIG`/`FNRM` blocks were
deleted (the diff against the D-time script removes the 16-line block) and the `fetch-disagree`
selftest expectation changed from `findings=2` to `findings=1`; the selftest still passes 59 cases.
Header, C2 claim and code now agree: **no cross-capture equality is enforced**. The two current
rows (S021 and S026, same URL, both normalized `ed949658…`) happen to agree, but the gate no longer
checks it. This was a live-tree transient, not a defect in the final snapshot; a claim must pin
`2d1bbbe3…` (or later; G only removes the now-unused `FDIG`/`FNRM` declarations).

### 4.4 `SC_FETCH` does not verify quote presence, location, or digest-vs-bytes

Fail-closed probes on copies of the final tree (script `2d1bbbe3…`; the same probes passed at `511deb27…`):

| mutation | result at G |
|---|---|
| S026 quote replaced by a fabricated 13-word sentence absent from the page | `SOURCES_CENSUS: CLEAN …` exit 0 |
| S026 raw `sha256` := `f`*64 on a `decoded-http-body-volatile-v1` row | `SOURCES_CENSUS: CLEAN …` exit 0 |
| S026 `normalized_sha256` := `0`*64 | `SOURCES_CENSUS: CLEAN …` exit 0 (failed at D, before the equality blocks were removed) |
| `supersedes S016` → `supersedes S999` | `SOURCES_CENSUS: CLEAN …` exit 0 |

What the gate actually verifies: field shape, registry id/status/URL equality, the row-identity
digest, 16-column shape, 25-word quote bound, location length ≥8, normalization enum and duplicate
provenance. At E it does **not** cross-check captures and never fetches or recomputes a digest from
bytes. Therefore:

- A fabricated quote passes; the quote's truth rests on the auditor's capture, not the gate.
- Corrupted raw and normalized digests pass when their shape is valid 64-hex; only the registry
  row-identity digest is recomputed.
- S026's locator correctness is established here by independent re-fetch (§2), not by `SC_FETCH`.

This is a bound, not necessarily a defect (the header says “declared representation”), but the C2
claim must not imply the gate verifies the quote or the digest against bytes.

### 4.5 Cardinality: 10 rows over 9 distinct URLs, not 7

```
awk -F'\t' '!/^#/ && NF==16' corpus/source-fetches.tsv | wc -l          # 10
awk -F'\t' '!/^#/ && NF==16 {print $4}' corpus/source-fetches.tsv | sort -u | wc -l  # 9
grep -c 'Fetch sha256:' corpus/SOURCES.md                                # 16
```

S021 and S026 share `https://openbao.org/docs/concepts/tokens/`; the other eight URLs are distinct.
The current lesson is correct (`corpus/lessons/round-23.md:177`: “over nine distinct URLs”), and the
registry distinct-URL count is 19 (`corpus/SOURCES.md` rows; matches lesson:175). The task brief's
“over 7 URLs” is stale — it matches the S017–S023 subset (seven rows/URLs) and was the lesson text
observed before its 01:04 edit. The claim must say **nine**, not seven.

## 5. C1 and C3 cross-checks — green as claimed, with their own bounds

### C1 closure dispositions

```
python3 corpus/closure-dispositions.py
CLOSURE_DISPOSITIONS: CLEAN (obligations=15 fixed=6 reported=3 operator_owned=1 no_action=5 rejected=0 pointers=15)
# earlier in the run it was fixed=7 reported=2; the JSON/ledger were then updated together
exit 0

python3 corpus/closure-dispositions.py --selftest
CLOSURE_DISPOSITIONS_SELFTEST: PASS (14 cases)     # final snapshot H; it was 13 earlier in the run
exit 0
```

Matches the final C1 claim (15 obligations, 14-case selftest; `corpus/lessons/round-23.md:60` also
says 14). The task brief's “selftest 13” was the count observed earlier and is stale. Bound, stated by the gate itself:
`corpus/closure-dispositions.py:9,41-44` says it never decides whether a fix is good; a `fixed`
pointer proves a reviewed record exists at the path. Claim row `R23-02`
(`corpus/claim-ledger.tsv:60`) also says “Records existence, not fix quality.” So “fixed pointers
resolve” is calibrated; “the fixes are verified” would not be.

### C3 hermetic cells

Exact `R23-01` command (`corpus/claim-ledger.tsv:59`):

```
bash corpus/claim-ledger.sh cells --root corpus/fixtures/cells-hermetic \
  --claims corpus/fixtures/cells-hermetic/claims.tsv \
  --stamps corpus/fixtures/cells-hermetic/stamps.tsv \
  --scorecard corpus/fixtures/cells-hermetic/SCORECARD.md \
  --docs corpus/fixtures/cells-hermetic/SCORECARD.md
CELL_AUDIT: CLEAN (cells=6 row_pointed=6 stamp_pointed=1 uncited=0 missing_ids=0 rows_run=2 row_deferred=0 row_failures=0 stale_pointers=0 self_skipped=0 orphans=0)
exit 0
```

This matches the R23-01 regex exactly, including `rows_run=2` and `self_skipped=0`. Bound: it is the
hermetic fixture root only; the round's own M23-3 says the real-tree `cells` claim is not made.

## 6. Bounds the C2 claim must state

1. **Nine URLs, not seven.** 10 capture rows (S017–S026) over 9 distinct URLs; S021 and S026 share
   the OpenBao tokens URL. The final lesson says nine; the brief's seven is stale.
2. **Pin the gate hash.** At `sources-census.sh` `80966e2…` the real gate exited 1 with
   `line 242: S007: unbound variable` while the 59-case selftest passed; at the final `2d1bbbe3…`
   the real gate exits 0 with the exact CLEAN line. A gate claim must name the hash (and the
   selftest does not prove the real-tree path).
3. **No cross-capture agreement is verified.** At the final snapshot `source-fetches.tsv:21`,
   `sources-census.sh:64-66` and lesson:61 all say captures are point attestations; the C/D-time
   `FDIG`/`FNRM` equality blocks are gone. Corrupting either the raw or the normalized digest (valid
   64-hex shape) passes CLEAN. Do not claim the gate cross-checks S021/S026 agreement.
4. **`SC_FETCH` is not a content verifier.** A fabricated ≤25-word quote and corrupted raw or
   normalized digests all pass CLEAN. The quote's presence under its section and the digest-vs-bytes
   identity rest on the auditor's re-fetch (done here), not on the gate.
5. **Supersession is prose-only.** S026's `supersedes S016` is not parsed or resolved; `supersedes
   S999` passes CLEAN. S016 stays `mined` with no disposition; E3's `source:`/`recheck:` and the
   Paths line still resolve to S016. The corrected locator is row-level; it is not reachable from
   the consuming knowledge entry.
6. **Legacy pins remain exempt.** S016 has no provenance row and its `c083fdca…` pin is
   non-reproducible under the tested representations; the gate's in-row-pin-or-provenance disjunction
   still covers it. S026 does not replace S016's pin in E3; it is a separate active row.
7. **Vault/KV untouched is confirmed.** S026 disclaims Vault/KV; the Vault/OpenBao knowledge entry is
   byte-identical to base. Do not let the OpenBao-token consumer gap be read as a Vault/KV change.

## 7. Limits of this audit

- The tree was live: several different census/tsv/lesson hashes were observed. Snapshot H is pinned
  above; later edits could change any statement here.
- No lane file was modified except this report. All mutation fixtures were under `/tmp`.
- HEAD advanced externally from `d218603` to `def9bc2e` during the audit; this seat made no
  `git`/`jj` mutation or commit.
- No `git`/`jj` mutation, no commits, no installs, no pacman, no host/package/service/boot changes,
  no vault/account/handler commands, no credential contents, no live private config.
- Network was limited to public documentation re-fetches with the allowed profile (tokens page,
  upstream mdx at the named commit, gzip transfer entity).
- I did not run the parent's 43 claim-ledger row audits. The C1/C3 named gates were run directly;
  the R23-01 command was run as written, not through a legacy row engine.
- No deployed OpenBao/Vault instance or runtime behavior is claimed. “Non-reproducible” for S016
  means not reproduced from the representations tested here; it is not proof of staleness, and no
  2026-10-19 snapshot was available.
