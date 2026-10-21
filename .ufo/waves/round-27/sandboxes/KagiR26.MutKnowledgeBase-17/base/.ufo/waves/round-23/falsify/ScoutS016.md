# ScoutS016 — S016 provenance vs declared captures (round-23 falsification)

Seat: leaf scout, read-only on the lane. Assigned question: compare S016's in-row
digest and quote with the declared captures in `corpus/source-fetches.tsv`, and
state whether the gate's legacy bound handles S016 honestly. All paths below are
relative to `/home/vgpnk/Projects/shokunin/kagi-shokunin`.

## Verdict

- **The legacy bound itself is honest and operative, but the gate is RED as it
  stands on disk.** `SC_FETCH` never compares legacy in-row digests to captures
  (`corpus/sources-census.sh:299-303`), and both the gate header
  (`corpus/sources-census.sh:67-70`) and the round-23 lesson
  (`corpus/lessons/round-23.md:107-113`, S016 named at `:112`) state that bound.
  The gate does not claim S016's digest is verified; D7 explicitly records that it
  matches neither capture representation. No false verification claim.
- **Concrete defect (C2/D7 does not reproduce on the tree I measured):** at
  `sha256 80966e208321348aad0ae6dd5b65987bccc4901e99fcba9f94feedd150228781`,
  `bash corpus/sources-census.sh verify` exits **1** with
  `corpus/sources-census.sh: line 242: S007: unbound variable`, before any fetch
  row is read. `SUPERSEDED` is assigned at `corpus/sources-census.sh:242` but is
  no longer declared at `corpus/sources-census.sh:229`
  (`declare -A FURL=() FINROW=() FSEEN=() FDIG=() FNRM=()`), and the script runs
  under `set -u`; indexing an undeclared array with `S007` is an arithmetic
  subscript and dies. The first `supersedes` cell in registry order is S019's
  `supersedes S007` (`corpus/SOURCES.md:25`). The claimed
  `SOURCES_CENSUS: CLEAN ...` exit 0 (`LOG.md:1194-1199`) **does not reproduce**.
- **Calibration gap that hides it:** `bash corpus/sources-census.sh --selftest`
  still prints `SOURCES_CENSUS_SELFTEST: PASS (59 cases)` exit 0 at that same
  file hash. No fixture row carries a `supersedes S…` teaches cell, so the crash
  path is never exercised. Green selftest, red real gate.
- **Runtime proof the defect is exactly the missing declaration:** pre-seeding
  the associative array in the caller (no file edit) yields the exact claimed
  line and exit:
  `SOURCES_CENSUS: CLEAN (rows=26 A=24 B=0 C=2 queued=1 mined=24 rejected=1 entries_sourced=4 legacy=21)` exit 0.

This measurement is point-in-time. The file moved during the audit: an earlier
read in this run showed `declare -A FURL=() FINROW=() FSEEN=() SUPERSEDED=()` and
no `FDIG/FNRM`; the current file has mtime `2026-10-21 00:57:55 -0300`
(`03:57:55Z`), size 36022, and the hash above. It stayed at that hash from
`03:59:38Z` through `04:00:32Z`. If the implementer restores the declaration,
re-run before scoring; until then the claim is falsified.

## S016-specific measurements

| fact | evidence |
|---|---|
| S016 row is `mined` (so no fetch suppression applies), URL `https://openbao.org/docs/concepts/tokens/`, quote 22 words, in-row digest `c083fdca8645f6248a3c42a8c0b912b356de281dc2da0099668a7850ba348380` | `corpus/SOURCES.md:22` |
| S026 row is `mined`, teaches `supersedes S016`, same URL, carries the same quote sentence | `corpus/SOURCES.md:32` |
| S026 capture: `decoded-http-body-volatile-v1`, sha256 `5229521866ce21fa8cd8f8ecf63d696877b8cb0a2ec25e89de683557b385f82c`, 47384 bytes, `rendered-text-v1` normalized sha256 `ed949658b434fa769b89c682160f77ad153f5c6657808706db5858506ce0d2e3`, location `Token hierarchies and orphan tokens` | `corpus/source-fetches.tsv:46` |
| S021 is the other capture for the same URL (different quote/location); its capture agrees with S026 on raw and normalized digests | `corpus/source-fetches.tsv:41` |
| S016 has **no** row in `source-fetches.tsv`, and `c083fdca…` occurs nowhere in it (`grep` exit 1, 0 rows) | command below |
| S016's row quote and S026's declared capture quote are byte-identical (22 words) | command below |
| Re-fetch of the registered URL with the declared request profile reproduces S026's **raw digest and byte count exactly** and its **normalized digest exactly**; the quote is present in rendered text | command below |
| S016's `c083fdca…` matches none of: live raw, live normalized (ed949658…), tags-removed-to-empty normalization, unescape-before-strip normalization | command below (`match_inrow []`) |

So S016's in-row value is genuinely an undocumented-representation historical
observation, as declared; the same URL's current bytes are bound by S026 with a
declared representation. The gate correctly refuses to present S016's digest as
verified. What it does **not** do (even with the declaration fixed) is enforce
anything about supersession: `SUPERSEDED` is populated at
`corpus/sources-census.sh:242` and read nowhere else (`grep -n SUPERSEDED` returns
only that line). Consequences observed:

- A consumer can keep citing the superseded, undocumented-digest row and pass
  `SC_ENTRY_CITE`, because S016 remains `mined`.
  `corpus/knowledge/vault-openbao-token-lease-lifecycle.md:3` still cites S016
  (not S026); `corpus/README.md:78` still points at `S012–S016`. S026's used-by is
  only `corpus/lessons/round-23.md` (`corpus/SOURCES.md:32`). The corrective
  capture is therefore not wired to the active consumer entry.
- The bound is not id-scoped in code: any registry row carrying a shaped 64-hex
  in-row digest bypasses the capture requirement
  (`corpus/sources-census.sh:299-303`), not just S001–S016. Today S024–S026 carry
  no in-row digest, so there is no live violation, but a future row can be
  admitted with an unverified historical-shaped digest. The header text
  (`corpus/sources-census.sh:67-70`) frames the exemption as legacy-specific;
  the code is digest-presence-specific.

## Commands and exits (all run in this audit)

1. `bash corpus/sources-census.sh verify` → exit **1**;
   stderr `corpus/sources-census.sh: line 242: S007: unbound variable`.
   Run repeatedly, `03:59:38Z`–`04:00:32Z`, same hash, same exit.
2. `bash corpus/sources-census.sh --selftest` → `SOURCES_CENSUS_SELFTEST: PASS
   (59 cases)`, exit **0** (same file hash before and after: `80966e20…`).
3. `bash -c 'set -- verify; declare -A SUPERSEDED=(); source ./corpus/sources-census.sh'`
   → `SOURCES_CENSUS: CLEAN (rows=26 A=24 B=0 C=2 queued=1 mined=24 rejected=1
   entries_sourced=4 legacy=21)`, exit **0**. (No lane file edited; the array is
   pre-seeded in the caller to isolate the defect.)
4. `awk -F'\t' '$1=="S016"' corpus/source-fetches.tsv | wc -l` → `0`;
   `grep -n 'c083fdca8645f6248a3c42a8c0b912b356de281dc2da0099668a7850ba348380'
   corpus/source-fetches.tsv` → exit **1**.
5. Quote equality: shell extraction of the S016 row quote vs field 13 of the
   S026 row → `equal=YES`, `words=22`.
6. Row-identity arithmetic: `printf 'S026\tmined\thttps://openbao.org/docs/concepts/tokens/\n'
   | sha256sum` → `0be2cff96b982a3557e21dcbd0e768b57ecdc1f8b02b085ce25bb556516aa2ee`,
   matching `corpus/source-fetches.tsv:46` field 3; same check for S021 →
   `c921ab096d16a013bedc04026e50594dc158cd719cebd194f26b78d1053d0860`,
   matching `:41`. Captures are internally bound to their registry identities.
7. `curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation
   verification)' https://openbao.org/docs/concepts/tokens/ | python3 -c '<digest
   + rendered-text-v1 normalization>'` → exit **0**; output:
   `raw_sha256 5229521866ce21fa8cd8f8ecf63d696877b8cb0a2ec25e89de683557b385f82c`,
   `raw_bytes 47384`, `norm_sha256
   ed949658b434fa769b89c682160f77ad153f5c6657808706db5858506ce0d2e3`,
   `quote_ascii_present True`, `match_inrow []`. That raw/normalized pair is
   exactly `corpus/source-fetches.tsv:46`; the 2026-10-21 capture reproduces.
8. `git status --short` (read-only) → `M corpus/SOURCES.md`,
   `M corpus/sources-census.sh`, `?? corpus/source-fetches.tsv`; the round-23
   implementation is uncommitted as stated.

## Adjacent observation (outside the S016 row; routed, not scored here)

`corpus/source-fetches.tsv` has 10 capture rows but **9** distinct URLs, not 7:
`awk -F'\t' '!/^#/ && NF==16 {print $4}' corpus/source-fetches.tsv | sort -u | wc -l`
→ `9` (S021 and S026 share the OpenBao tokens URL). This contradicts the
`10 declared captures over 7 URLs` wording (`LOG.md:1202`, parent C2 summary).
The registry/staleness result above is independent of this count.

## Remaining unknowns

- Whether S016's `c083fdca…` was the sha256 of some 2026-10-19 representation of
  the page. No archived 2026-10-19 bytes were fetched; under the declared bound
  this is unknowable from the current capture and not claimed by the round.
- Whether the implementer intends to restore `SUPERSEDED=()` and/or consume the
  map; the crash is a one-token declaration gap, but the dead supersession check
  is a design gap beyond it.
- Whether consumer migration from S016 to S026 is intended this round; D7 only
  says the old rows keep historical values and are never silently rewritten.

## Read-only statement

No production edits, no `corpus/`/script/ledger/stamp/SCORECARD/LOG/lesson writes,
no git/jj mutation, no installs, no pacman, no host/service/compositor changes, no
credential or private-config reads. The only file written by this seat is this
report. The census `verify` and `--selftest` are host-free; no host-bound row or
legacy claim-ledger verify was executed.
