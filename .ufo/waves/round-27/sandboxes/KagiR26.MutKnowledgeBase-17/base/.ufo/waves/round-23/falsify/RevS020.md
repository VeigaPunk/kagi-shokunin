# RevS020 — S020 fetch provenance + round-23 C1/C2/C3 falsification

Measured 2026-10-21T04:03–04:08Z on base `d218603b74099ddca0bd8f869516fc41db0979bf`
plus the uncommitted round-23 tree. Read-only on the lane: no production edits, no
git/jj mutation, no host/fleet gate, no secrets. Scratch only under `/tmp`.

## Snapshot (the tree moved during review)

| file | sha256 at final measurement |
|---|---|
| `corpus/sources-census.sh` (35725 B, mtime 01:02:21) | `24d834cc85344b762b485ef2b1c44cdbddab4e641f96acbaf2853823b02af057` |
| `corpus/source-fetches.tsv` | `846b203734bcddce6c16e8346eea20bb1613b23c6607366b608c7afd41a4ae76` |
| `corpus/lessons/round-23.md` (moving: `2f53cf69…` → `993e114a…` → this) | `cf79cd0c85d981a0d062eaa306bddee4de4fc31291c81c84699e135e4be535de` |
| `corpus/SOURCES.md` | `06dde644801bee13736fca21d9ecadec83086ea1f5de77043394a62d2d525b29` |
| `corpus/closure-dispositions.json` (moved twice, both CLEAN) | `00fbf48d3ea233d01a7d56ae6ca3291955df82ea522a91e3f3d7dc5644c535e8` |
| `corpus/closure-dispositions.py` | `bf6154b170c6db6e46291044a6d3f078119f013619279fb66fbcbd07e18eb003` |
| `corpus/claim-ledger.tsv` | `0d3d75008122c49c58e3a6ff8a1b481ad1accda6f717cc2eb74b5a05b8e3b866` |
| `corpus/fixtures/cells-hermetic/{claims,stamps,SCORECARD,corpus/fx-ok.sh,corpus/adjacency.tsv}` | `1a073771…`, `401ebb3c…`, `23583252…`, `29f98fba…`, `fa15a53c…` |

Pre-fix census snapshot A: 36022 B, reconstructed sha256
`80966e208321348aad0ae6dd5b65987bccc4901e99fcba9f94feedd150228781` (see F1).
Every pass/fail below is tied to these bytes; re-run on the final landed bytes.

## 1. S020 re-measurement — PASS (no wrong digest)

Exact fetch (run 3×, exit 0 each):

```
curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)' \
  -o /tmp/revs020_bodyN.html -w 'http_code=%{http_code}\nurl_effective=%{url_effective}\n' \
  'https://1password.com/blog/1password-credential-broker-public-preview'
```

Third response: `HTTP/2 200`, `date: Wed, 21 Oct 2026 04:03:19 GMT`,
`content-type: text/html; charset=utf-8`, `content-encoding: gzip`;
`url_effective` equals the registered URL (no redirect).

| check | declared (`source-fetches.tsv:40`) | measured |
|---|---|---|
| URL == registry extraction (`SOURCES.md:26`) == final_url | `https://1password.com/blog/1password-credential-broker-public-preview` | equal |
| status vs registry | `mined` | `mined` |
| row identity `sha256(id<TAB>status<TAB>url<LF>)` | `c1ce1e05d3cca13412de51bb3f662a6f9ef631f0452f43753a3ad915394b4cc5` | recomputed equal |
| decoded bytes | `190261` | 190261 on all 3 GETs |
| raw sha256 | `53dfeac555f8beb1aaf3d0c2114ee75aaaf5199e0b84a0b71fc70de0bfd132cd` | `249d96d5…`, `5993530a…`, `4b4158b5…` (expected mismatch; volatile) |
| normalized sha256 | `20b4fd86dada5f63406432238384aa475b0cf8cb3a8e4045bd021cae0691804f` | recomputed equal 3/3 |
| quote | 19 whitespace words | present at normalized offset 4470, 19 words |
| location | `New in this release` | h2 is `New in this release: Custom OIDC workflows` (prefix) |

Normalization was recomputed exactly as declared (strip `script`/`style`, tags →
single space, `html.unescape`, collapse whitespace, trim, UTF-8). Digest was
`20b4fd86…` on all three GETs. Alternate order (unescape before tag-strip) gives
`cdfcd99e…`, so the declared digest specifically pins the documented order.
The raw-digest variance is the declared per-response Cloudflare token:
`cmp -l body1 body2 | wc -l` = 22 differing bytes, confined to the two
`/cdn-cgi/l/email-protection#…` hrefs at constant 190,261 B; normalized text
identical. That re-confirms `decoded-http-body-volatile-v1` rather than exposing
a stale digest. Exactly one `S020` provenance row (`grep -c '^S020'` = 1).

Non-finding: `SOURCES.md:26`'s anchor `Introduction; …` is not a literal heading
(no h1–h3 named Introduction; count 0 in raw and normalized text), but the
pre-first-h2 intro at normalized offset 1366 carries “Enterprise Password Manager
Business” — the EPM Business eligibility the row scopes. It is a prose locator
for the intro, not a broken heading pointer.

## 2. Findings (severity order)

### F1 — Census gate was non-executing on the pre-fix snapshot (High then; resolved in flight; still a selftest blind spot)

On snapshot A (36022 B, `sha256 80966e20…`), `bash corpus/sources-census.sh`
exited 1 with **no verdict line**:

```
corpus/sources-census.sh: line 242: S007: unbound variable
```

Cause: `SUPERSEDED[$fid]=1` at A:242 where `fid=S007`; `SUPERSEDED` was never
declared (`declare -A ST=() UB=() TI=()` at A:203, `declare -A FURL=…` at A:229),
so bash evaluated the subscript arithmetically under `set -u` and expanded the
variable `S007`. Minimal reproduction: `bash -c 'set -u; SUPERSEDED[S007]=1'` →
same error; `declare -A SUPERSEDED=()` survives. The block was dead code
(`SUPERSEDED` is never read), and the 59-case selftest still passed because its
fixture registry teaches cells are `teaches one/two/three/four` (A:392–395) and
`supersedes` appeared only in the extractor (A:245) — no self-test case
exercised it.

Reproduced from the reconstructed A bytes in `/tmp` (reverse of the probe patch):
same line, same error, exit 1.

Current snapshot B (`24d834cc…`, 35725 B) deletes exactly that 5-line block
(`diff` A→B shows only its removal). On B: `bash corpus/sources-census.sh` →
`SOURCES_CENSUS: CLEAN (rows=26 A=24 B=0 C=2 queued=1 mined=24 rejected=1 entries_sourced=4 legacy=21)`,
exit 0; `--selftest` → `PASS (59 cases)`, exit 0. Standing gate is green, but the
C2 claim must name the bytes/commit on which the real-tree run was made, and the
“59 cases” bound must not be presented as protection against this class — the
selftest cannot see a `supersedes S###` registry cell.

### F2 — `source-fetches.tsv` header contradicts the executable check (Medium; standing)

- `corpus/source-fetches.tsv:21`: “**No cross-capture equality is enforced.**”
- `corpus/sources-census.sh:275`: “Two captures of one URL under one
  representation must agree.” — enforced at `:288`
  (`same-url-normalized-disagreement`) and `:282` (raw, non-volatile).

Mutation proof in a `/tmp` copy: set `S026`’s `normalized_sha256` to `0*64` →
`FINDING SC_FETCH id=S026 same-url-normalized-disagreement url=https://openbao.org/docs/concepts/tokens/`,
`SOURCES_CENSUS: FAILED (findings=1 rows=26)`, exit 1.

The lesson’s C2 row (`round-23.md:61`) now says only “captures are point
attestations” and no longer states the enforced relation, so the three artifacts
disagree: header says no equality, code enforces it, claim omits it. Fix the
header or remove the check; an auditor reading the stated bound gets the
opposite of the executable behavior.

### F3 — R23-01 note still says “one local script row” (Low; standing)

`corpus/claim-ledger.tsv:59` note: “… the fixture root holds its own
claims/stamps/scorecard/docs and **one local script row** …”. The committed
fixture has two claim rows — `R90-01` `bash corpus/fx-ok.sh` and `R90-02`
`grep -cE '^# no-enumerate[[:space:]]+.HOME/' corpus/adjacency.tsv` — and the
pinned expectation requires `rows_run=2`. The lesson now says “two local-only
rows” (`round-23.md:156–160`); the ledger prose is the stale copy. Behavior
unaffected.

### F4 — W04 observable is not produced by the named command (Low; verification gap)

`bash corpus/sources-census.sh` prints one verdict line; it emits no W04.
`grep -rn W04 corpus/*.sh corpus/*.py` → no matches; W04 appears only in
`corpus/lessons/*` and `LOG.md`, and `round-22-verifier-spotcheck.md:115`
attributes the five lines to `kagi ok …/corpus/SOURCES.md`. `command -v kagi`
is empty and I did not run it (fleet/host gate, out of lane). So
`round-23.md:177–179`’s “census … five W04 warnings … `rows=26`” reproduces the
exit-0/rows=26 half through the corpus gate but not the W04 half. Name the exact
`kagi ok` invocation, or drop W04 from the corpus-gate criterion.

## 3. Claim confirmations

- **C1 — confirmed.** `python3 corpus/closure-dispositions.py` →
  `CLOSURE_DISPOSITIONS: CLEAN (obligations=15 fixed=7 reported=2 operator_owned=1 no_action=5 rejected=0 pointers=15)`,
  exit 0; `--selftest` → `PASS (13 cases)`, exit 0. Independent parse of
  `corpus/lessons/round-22-verifier-spotcheck.md`: 9 `- D<n>` bullets, 5
  admit/reject spot rows, 1 `**ADMITTED.**` → 15. JSON: 15 unique rows, classes
  9 routed-defect / 5 spot-decision / 1 adjudication, dispositions 7 fixed /
  5 no-action / 2 reported / 1 operator-owned; source sha
  `65a5b3de…` equals the pin (independently recomputed). Stated bound: pointer
  resolution, not fix quality.
- **C2 — confirmed on current bytes, with F2/F4.** `bash corpus/sources-census.sh`
  → CLEAN `rows=26`, exit 0; selftest 59 PASS. `grep -c 'Fetch sha256:'` = 16;
  10 provenance rows; 16+10 = 26. Distinct provenance URLs = 9 (10 rows;
  S021/S026 share one URL) — now matching `round-23.md:174` and
  `SCORECARD.md:840`; registry distinct URLs = 19. The S020 row passes every
  `SC_FETCH` check.
- **C3 — confirmed.** Exact R23-01 command exit 0; last line byte-identical
  (`grep -Fx` exit 0):
  `CELL_AUDIT: CLEAN (cells=6 row_pointed=6 stamp_pointed=1 uncited=0 missing_ids=0 rows_run=2 row_deferred=0 row_failures=0 stale_pointers=0 self_skipped=0 orphans=0)`.
  Mutation test (copy fixture to `/tmp`, change `fx-ok.sh` output) →
  `FAIL R90-01 reason=verdict-not-final exit=0`, then
  `CELL_AUDIT: BROKEN (… row_failures=1 …)`, exit 1. The fixture is five files
  with 2 claim rows and 2 stamp rows; both stamp hashes recompute (`fx-ok.sh`
  `29f98fba…`, `adjacency.tsv` `c17f7e17…`), matching the corrected lesson
  contract. F3 is the remaining stale prose.

## 4. Residual risk and verification gaps

- The lane mutated during this review (census A→B; lesson three hashes; JSON
  twice; TSV twice). All statements above apply only to the hashes in the
  snapshot table. The final integration must re-run the named gates on the
  final bytes and record the commit.
- The census selftest has no `supersedes S###` registry case; F1’s class was
  invisible to 59/59. Add a case if the block is ever reintroduced.
- W04/fleet census (`kagi ok`) was not run: `kagi` is not on PATH and a fleet/
  host gate is outside this lane. The corpus-gate half is verified; the W04
  half is not.
- S020 normalized stability is same-day evidence (3/3 GETs on 2026-10-21). The
  header correctly states the digest is chrome-sensitive across days; the raw
  digest is intentionally unreproducible and is not a defect.
- No production edits, no git/jj mutation, no host or credential access; only
  public documentation GETs and `/tmp` scratch.

## 5. Post-measurement delta (2026-10-21T04:12:10Z) — lane still mutating

After the body above was written, the lane changed again. Snapshot C:

| file | sha256 |
|---|---|
| `corpus/sources-census.sh` (34805 B, mtime 01:10:59) | `511deb2730614663c86beb9b6793b54eea75ce8a9dbe4f1cf372999697339b58` |
| `corpus/source-fetches.tsv` | `6e26e14032729070f38b5e0cb90914385f04c0ef9f4fe1db210af6439191094d` |
| `corpus/closure-dispositions.py` (mtime 01:08:16) | `cfa2c46ae0730730722b62c7078c38b138fc17ac9876ba15e26eff53cdf71de7` |
| `corpus/lessons/round-23.md` (mtime 01:11:27) | `49632920e11189562ade4410c002f51206b33c66e9ce57805efcc940fa81f699` |
| `corpus/claim-ledger.tsv` | `5986945977b658d9f02b6af0f80146da6065eab41a28265d67b590394992069c` |
| `corpus/closure-dispositions.json` | `00fbf48d3ea233d01a7d56ae6ca3291955df82ea522a91e3f3d7dc5644c535e8` (unchanged) |
| `corpus/SOURCES.md` | `06dde644801bee13736fca21d9ecadec83086ea1f5de77043394a62d2d525b29` (unchanged) |

Re-measured on C:

- **F1** — `bash corpus/sources-census.sh` → `SOURCES_CENSUS: CLEAN (rows=26 …)`,
  exit 0; `--selftest` → `PASS (59 cases)`, exit 0. `grep -n supersedes
  corpus/sources-census.sh` → 0 matches; the crashing block is gone. The A-snapshot
  crash remains historical. The lesson now states the selftest does not certify
  the in-row branch (`round-23.md:205–209`), matching the gap measured here.
- **F2 — resolved in flight.** The same-URL comparison was deleted:
  `grep -n 'same-url\|FDIG\|FNRM'` finds only the declaration at `:229`, and the
  S026 mutation that previously produced `same-url-normalized-disagreement` now
  returns `SOURCES_CENSUS: CLEAN (rows=26 …)`, exit 0. `source-fetches.tsv:21`
  (“No cross-capture equality is enforced”) is now true. Residual risk: the gate
  no longer detects conflicting same-URL declarations; no artifact may claim it
  does.
- **F3 — persists.** `claim-ledger.tsv:59` still says “one local script row”
  while the pinned expectation is `rows_run=2` and the lesson says two rows.
- **F4 — persists.** The corpus census emits no W04; `kagi` is not on PATH and
  was not run. The W04 half remains unverified.
- **C1** — `closure-dispositions.py` gained a 14th case (`pointer-symlink`);
  `--selftest` → `PASS (14 cases)` exit 0; the gate → CLEAN (obligations=15 …
  pointers=15) exit 0; the JSON source pin still matches. The lesson C1 row now
  says 14 cases; the falsify brief’s “selftest 13” is stale as of 04:08:16Z.
- **C2** — CLEAN `rows=26`, exit 0; the S020 row still reproduces identity,
  bytes (190,261), normalized digest `20b4fd86…`, and quote on the newest TSV
  (`6e26e140…`).
- **C3** — the exact R23-01 command still prints the pinned
  `CELL_AUDIT: CLEAN (… rows_run=2 …)`, exit 0.

The lane changed three times in ~10 minutes (census `24d834cc` → `511deb27`;
lesson `2f53cf69` → `993e114a` → `49632920`; TSV `846b2037` → `6e26e140`).
Every certification above is bound to the hashes named; the final integration
must re-run the named gates on the final landed bytes.
