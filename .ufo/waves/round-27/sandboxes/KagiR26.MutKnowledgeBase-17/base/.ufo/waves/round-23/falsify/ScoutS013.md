# ScoutS013 — S013 provenance under the round-23 D7 legacy bound

Read-only falsification seat, round 23. Repository `/home/vgpnk/Projects/shokunin/kagi-shokunin`,
HEAD `d218603b74099ddca0bd8f869516fc41db0979bf` plus the uncommitted round-23 tree.

Snapshot audited (observed, unchanged through the last re-run):

| file | sha256 | mtime |
|---|---|---|
| `corpus/sources-census.sh` | `80966e208321348aad0ae6dd5b65987bccc4901e99fcba9f94feedd150228781` | 2026-10-21 00:57:55 -0300 |
| `corpus/SOURCES.md` | `06dde644801bee13736fca21d9ecadec83086ea1f5de77043394a62d2d525b29` | (unmodified by this seat) |
| `corpus/source-fetches.tsv` | `ccc9ae6ec1b4bfa2ea8d879762a8fca18a84673145b54a04f39530de2d65a0af` | (unmodified by this seat) |

## What I attacked

1. S013's in-row digest and quote against the only declared capture of its URL in
   `corpus/source-fetches.tsv` (S023, same URL).
2. Whether the `SC_FETCH` legacy bound produces the claimed `SOURCES_CENSUS: CLEAN ... exit0`
   verdict, and whether it can distinguish a real historical pin from an arbitrary 64-hex string.

No fetch was performed: the 2026-10-19 bytes are unreconstructable (the parent seat records no
archive coverage for that date), and a 2026-10-21 GET cannot reproduce them. The decisive evidence
is local: the row bytes, the declared capture, and the gate code.

## Observed facts

### S013 row and the declared capture

- `corpus/SOURCES.md:19` — S013, status `mined`, URL
  `https://developer.hashicorp.com/vault/docs/concepts/lease`, quote
  “All dynamic secrets in Vault are required to have a lease.”, anchor includes
  “current Vault docs have no displayed version/date, opened 2026-10-19”,
  `Fetch sha256: ae321512d37ae70bc19e7b8698217ce8af0d3000bb76fe04039870bff25b8bf5`, opened
  2026-10-19.
- `corpus/source-fetches.tsv:43` — S023, same URL, status `mined`, raw
  `de5f8836b268372b5af165fa46d3c80195554f110f881723d606c6cc8bcc3802`, 261632 bytes,
  representation `decoded-http-body-volatile-v1`, fetched `2026-10-21`, quote identical to S013's,
  normalization `rendered-text-v1`, normalized
  `0e62e05612eaa7ddb5145fb8d17618f37a503b20c5ee58b46ab3476d8a4e7b76`, location
  `Lease, renew, and revoke`.
- There is no S013 provenance row: `grep -n '^S013' corpus/source-fetches.tsv` exits 1; the URL is
  represented only by S023.
- Programmatic comparison (python3, exact strings):
  URL equal; quote equal byte-for-byte; `ae3215…` differs from raw `de5f88…` and from normalized
  `0e62e0…`.
- Row-identity binding works: `printf 'S023\tmined\thttps://developer.hashicorp.com/vault/docs/concepts/lease\n' | sha256sum`
  = `131e6a2015a202cebc9305a0943b4d62d66de343bfc97e2211ad7fc66cfed5b2`, exactly column 3 of the
  S023 row.

### The lane already records the S013 digest as unreproducible

- `corpus/lessons/round-23.md:110-111`: “S012/S013's in-row digests do not reproduce under any
  tested representation”.
- `LOG.md:1213-1215`: same statement; “only the declared captures in source-fetches.tsv are active
  provenance”.
- `.ufo/waves/round-23/parent-build/SourceS013.md:60` marks the value
  “**UNREPRODUCIBLE / CONTRADICTED elsewhere**”; F1 at `:104-106` states it “contradicts the
  committed provenance record (`de5f88…`)”.
- `corpus/SOURCES.md:104-105` says “fresh-wave raw-HTML GETs reproduced the S017/S018/S019, S013 and
  S021 catalog captures.” Read as the in-row pin this would contradict the three records above;
  `.ufo/waves/round-22/build/Source12.md:132` says the registered S013 value “also mismatches”
  today's `de5f88…`. The sentence is ambiguous rather than demonstrably false (“catalog captures”
  likely means the round-22 measurement catalog), but the registry wording invites the wrong
  reading. Confidence that this is a wording defect: high; that it is a falsehood: low.

### The legacy bound is stated and implemented as stated

- `corpus/sources-census.sh:67-69`: “STATED BOUND: legacy in-row digests are historical point
  observations with undocumented representation -- required for coverage, never compared to
  captures.”
- `corpus/source-fetches.tsv:34-36`: same caveat; `:2` nevertheless says “D7: bind every mined
  row's quote and digest to a declared representation” — false for the 16 legacy rows, including
  S013. The caveat is the operative text; the summary line overstates scope.
- Implementation: `sources-census.sh:299-304` — a row with an in-row digest gets only a 64-hex
  shape check, then `continue`; a row without one needs a provenance row.
- The plan states the same scope: `plans/round-23.md:24-26` (“legacy in-row pins (S001–S016) are
  classified historical and never compared to fresh captures”).

### Primary defect: the gate cannot produce its claimed verdict

`sources-census.sh:242` assigns `SUPERSEDED[$fid]=1`, but `SUPERSEDED` is not among the arrays
declared at `:229` (`FURL FINROW FSEEN FDIG FNRM`). With `set -uo pipefail` (`:107`), an undeclared
array is indexed, so the key `S007` is evaluated arithmetically and the unset variable `S007` is a
fatal unbound-variable error.

The awk at `:243-246` emits exactly `S007, S006, S012, S013, S014, S016` from the live registry
(verified by running that awk standalone, exit 0). S013 is in the crashing set via
`SOURCES.md:29` (`supersedes S013`); S019's `supersedes S007` (`SOURCES.md:25`) is read first and
aborts the loop.

Reproduction (three runs, identical):

```
$ cd /home/vgpnk/Projects/shokunin/kagi-shokunin
$ bash corpus/sources-census.sh
corpus/sources-census.sh: line 242: S007: unbound variable
$ echo $?
1
```

No `SOURCES_CENSUS:` verdict line is printed. This is the exact command in `corpus/claim-ledger.tsv:52`
(R21-02, expected `^SOURCES_CENSUS: CLEAN ...$`, exit 0), so the round-23 claimed After state is not
reproducible at this snapshot.

Isolation (only the missing declaration changed, in a `/tmp` copy; no lane edit):

```
$ cp -a corpus /tmp/s013probe/corpus; cp corpus/sources-census.sh /tmp/s013probe/census.sh
# add SUPERSEDED=() to the `declare -A` at /tmp/s013probe/census.sh:229
$ bash /tmp/s013probe/census.sh verify --root /home/vgpnk/Projects/shokunin/kagi-shokunin
SOURCES_CENSUS: CLEAN (rows=26 A=24 B=0 C=2 queued=1 mined=24 rejected=1 entries_sourced=4 legacy=21)
$ echo $?
0
```

The selftest is green and blind to this branch:

```
$ bash corpus/sources-census.sh --selftest
SOURCES_CENSUS_SELFTEST: PASS (59 cases)
$ echo $?
0
```

The fixture rows use `teaches one` / `teaches two` (`sources-census.sh:360-361`), and `supersede`
occurs nowhere else in the script except the live matcher at `:245`; no case exercises a
`supersedes S###` teaches cell. The fix is either adding `SUPERSEDED=()` to `:229` or deleting the
dead loop at `:242-246` — the array is populated and never read. The selftest needs a superseding
fixture row either way.

### Mutation matrix for the S013 legacy bound (same `/tmp` tree, patched script)

| mutation | result | exit |
|---|---|---|
| S013 digest replaced by 64 × `a` | `SOURCES_CENSUS: CLEAN ...` | 0 |
| S013 quote replaced by “Fabricated sentence with no captured support anywhere.” | `SOURCES_CENSUS: CLEAN ...` | 0 |
| S013 `Fetch sha256:` removed entirely | `FINDING SC_FETCH id=S013 missing-provenance`; `SOURCES_CENSUS: FAILED (findings=1 rows=26)` | 1 |

So the bound is exactly presence-only. Any 64-hex string and any quote pass; only absence fails.

## Verdict on the legacy bound and S013

- The bound is **honestly disclosed**: the census header, the TSV caveat, and the plan all say
  legacy pins are historical and are never compared to captures, and the code matches that text.
  The gate does not silently pretend to verify the digest.
- The bound is **weak assurance**, not provenance: for S013, `CLEAN` certifies only that the row
  carries a well-formed 64-hex string. The string differs from both declared values of the same URL,
  the lane's own lesson and parent audit call it unreproducible, and the registry row carries no
  per-row historical marker (only `corpus/feature-claims.json:84` records it as
  `prior_registry_sha256`). The quote, by contrast, is verbatim identical to the fresh S023 capture,
  so quote-level corroboration exists even though no gate compares it.
- At the audited snapshot the question is moot in practice: **the gate crashes before evaluating
  S013 or any other row**, so the claimed `CLEAN` verdict does not exist. The missing
  `SUPERSEDED` declaration is the concrete defect; the selftest's lack of a superseding fixture is
  the durable coverage gap that let it through.

### Secondary observations (adjacent, not the assigned defect)

- `LOG.md:1202` says “10 declared captures over 7 URLs”. The table has 10 rows over **9** unique
  URLs: `awk -F'\t' 'length($0)>0 && $0 !~ /^#/ {print $4}' corpus/source-fetches.tsv | sort -u | wc -l`
  = 9 (S021 and S026 share `https://openbao.org/docs/concepts/tokens/`). Seven is the count of rows
  S017–S023 before the three correction rows; the sentence is stale.
- The same-URL raw-agreement check added at `sources-census.sh:284-289` is inert on the current
  table: all 10 captures declare `decoded-http-body-volatile-v1`
  (`awk ... '{print $9}' ... | sort | uniq -c` = 10 volatile), and the TSV header (`:11-13`) says raw
  agreement applies only to non-volatile representations. Only the normalized comparison (`:290-294`)
  runs, and its only same-URL pair is S021/S026, which agree. The parent F1 recommendation — compare
  an in-row pin with the declared capture for the same URL — is not implemented; `:282-283` explicitly
  excludes in-row digests.

## Remaining unknowns

- Whether the crash is a transient mid-edit state. The hash and mtime above are the audited snapshot;
  adding the declaration restores the exact claimed line (proven in `/tmp`), but the selftest gap
  remains after any such fix.
- The 2026-10-19 representation and request method for S013: undocumented and unrecoverable; no
  fetch can decide it.
- Whether `corpus/SOURCES.md:104-105`'s “catalog captures” was intended to exclude the in-row digest.
  [INFERENCE] It most likely refers to the round-22 measurement catalog, but the sentence should be
  reworded to avoid implying the pin reproduced.

## Read-only disclosure

Wrote only this report. Temp artifacts: `/tmp/s013probe/` (corpus copy + patched script), `/tmp/s013_*.out`.
No lane file, `.ufo` evidence, scorecard, ledger, stamp, sibling lane, or state file was modified. No
network fetch, no git/jj mutation, no claim-ledger verify, no host/package/service command, no
install or update.
