# ScoutS001 — S001 provenance vs. declared captures (round 23 falsify)

- Audit window: 2026-10-21 00:58–01:04 -03.
- Tree: `/home/vgpnk/Projects/shokunin/kagi-shokunin`, base `d218603b74099ddca0bd8f869516fc41db0979bf` plus the uncommitted round-23 tree.
- Snapshot mtimes used for citations: `corpus/sources-census.sh` 01:02:21.501, `corpus/source-fetches.tsv` 00:55:22.892, `corpus/SOURCES.md` 00:49:17.583.
- Attacked: whether S001's in-row `Fetch sha256:` and quote are honestly represented by `corpus/source-fetches.tsv`, and whether `SC_FETCH`'s legacy bound handles S001 as stated.
- **Verdict: bound confirmed for S001; no S001 provenance defect found.** S001 has no declared capture; its in-row digest is a non-reproducing historical point observation; the gate enforces only presence and 64-hex shape for it — exactly what both round-23 artifacts state. One transient gate crash was observed mid-audit and fixed at 01:02:21 (section 4); it is not a standing S001 defect.

## 1. S001 row and declared-capture inventory (observed)

Row `corpus/SOURCES.md:7`:

- id `S001`, status `mined`, URL `https://www.1password.dev/cli/secrets-scripts`.
- quote `“provisioned for the duration of the process.”` under `§Use `op run` to pass environment variables from a 1Password Environment`.
- in-row digest `9f9d7283c2659d23c9ede72d96a31690533678b28437b2b22f73b2b73370c439` (64 lowercase hex; the awk extractor at `corpus/sources-census.sh:239` captures it).

No capture covers S001 (all commands run from the lane root):

- `awk -F'\t' '$1=="S001"{n++} END{print n+0}' corpus/source-fetches.tsv` → `0`, exit 0.
- `grep -c 'https://www.1password.dev/cli/secrets-scripts' corpus/source-fetches.tsv` → `0`, exit 1.
- Hypothetical registry identity `printf 'S001\tmined\thttps://www.1password.dev/cli/secrets-scripts\n' | sha256sum` → `9c4a65d1725c8753e0c444dc212c6a061d3c662e33bb31941c7d1bc9840ebc27`; `grep -c 9c4a65d1… corpus/source-fetches.tsv` → `0`, exit 1.
- Inventory: 10 data rows, `S017`–`S026`, over **9** distinct exact URLs (`corpus/source-fetches.tsv:41,46`: `S021`/`S026` both `https://openbao.org/docs/concepts/tokens/`). S001's URL is not among them.

So there is nothing in `source-fetches.tsv` to compare S001's digest or quote against. The declared bound is the only applicable contract.

## 2. What the gate actually enforces for S001 (observed)

Stated bound:

- `corpus/sources-census.sh:67-69`: "legacy in-row digests are historical point observations with undocumented representation -- required for coverage, never compared to captures."
- `corpus/source-fetches.tsv:34-36`: "Legacy in-row `Fetch sha256:` values (S001-S016) are historical point observations with undocumented representation; the census requires their presence but does not compare them to these captures."

Implemented branch `corpus/sources-census.sh:294-300`: for every registry id, if an in-row digest exists, only `^[0-9a-f]{64}$` is checked and the loop `continue`s; otherwise provenance coverage is required. No URL, byte, quote, or normalized-text check touches S001.

Mutants applied to a pristine `cp -a corpus` copy at `/tmp/s001-audit.oYx6xU`, run with the 01:02:21 script via `bash corpus/sources-census.sh verify --root "$T"`:

| mutant | change in copy | observed result |
|---|---|---|
| baseline | none | `SOURCES_CENSUS: CLEAN (...)`, exit 0 |
| A | S001 digest → 64 × `a` | `SOURCES_CENSUS: CLEAN (...)`, exit 0 |
| B | S001 digest → `deadbeef` | `FINDING SC_FETCH id=S001 inrow-digest-malformed`; `FAILED (findings=1 rows=26)`, exit 1 |
| C | S001 quote → `fabricated sentence absent from the page.` | `SOURCES_CENSUS: CLEAN (...)`, exit 0 |
| D | `Fetch sha256:` clause removed | `FINDING SC_FETCH id=S001 missing-provenance`; `FAILED (findings=1 rows=26)`, exit 1 |

Interpretation: a fabricated but well-shaped digest (A) and a fabricated quote (C) pass; a malformed digest (B) and removal (D) fail. This is precisely "presence + shape required, value/quote not compared". The bound is mechanically honest for S001; it is a coverage-and-shape bound, not a content proof.

## 3. Independent live re-measurement of the S001 row (observed)

Fetch profile was the declared one (`corpus/source-fetches.tsv:12-13`), with output flags added for measurement:
`curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)' <url> -o <file> -w 'HTTP=%{http_code} bytes=%{size_download} final=%{url_effective}\n'`.

Calibration first, on a declared capture URL:

- `https://openbao.org/docs/concepts/tokens/` → HTTP 200; decoded file 47,384 B; raw sha256 `5229521866ce21fa8cd8f8ecf63d696877b8cb0a2ec25e89de683557b385f82c`; rendered-text-v1 normalized sha256 `ed949658b434fa769b89c682160f77ad153f5c6657808706db5858506ce0d2e3`.
- These equal the declared `S021`/`S026` rows exactly: sha256, `bytes=47384`, normalized digest (`corpus/source-fetches.tsv:41,46`). My normalization reimplementation (strip `script`/`style`, tags → single space, `html.unescape`, collapse `\s+` → space, trim, UTF-8) is therefore calibrated to the declared capture domain. (`%{size_download}` reports wire bytes, 12,527; the declared byte domain is the decoded body, 47,384, per `corpus/source-fetches.tsv:15-16`.)

S001 target:

- `https://www.1password.dev/cli/secrets-scripts` → HTTP 200, final URL unchanged; decoded file 1,228,087 B; raw sha256 `e72ab5f3f85e238bc109a1737161eec8425a016f003b7c84be09990d62cf4e0b`.
- Declared rendered-text-v1 normalization → `a8be89d90b8c673914b539a7aa9d12d3c63f9c9283865ba08ddb6f2d049ec580` (7,116 UTF-8 bytes).
- The row's quote occurs exactly once in the rendered text, in the sentence "…the environment variables stored in your 1Password Environment provisioned for the duration of the process."; the row's heading `Use op run to pass environment variables from a 1Password Environment` is present. No displayed version/date text was found for the terms `last updated`, `updated`, or `version`, so the row's "no displayed version/date" note is not contradicted.
- `9f9d7283…` matches none of six domains tried: raw bytes; rendered-text-v1 (`\s+` collapse); rendered-text-v1 (ASCII whitespace collapse); tags → empty; unescape-before-tag-strip; lowercase. It is therefore not reproducible from today's page under the declared or adjacent representations.

The row's `9f9d7283…` was already classified HISTORICAL/non-reproducing with today's HTML = `e72ab5f3…` in `.ufo/waves/round-23/parent-build/SourceS001.md:50,59`; my fetch independently reproduces that raw value. The quoted content is still live; only the digest is unverifiable.

**Conclusion for the assigned question:** the legacy bound handles S001 honestly. Its digest is a historical observation with no declared representation and no capture; the gate says so and behaves accordingly. Its quote is still present on the live page. Confidence: high for gate behavior and fetch results; the 2026-10-19 representation behind `9f9d7283…` is genuinely unrecoverable from the lane (no byte snapshot).

## 4. Transient observed during the audit (not standing at 01:03:39)

At script mtime 00:57:55, `bash corpus/sources-census.sh` on the live tree:

- exit 1, empty stdout, stderr `corpus/sources-census.sh: line 242: S007: unbound variable`; no `FINDING` line and no verdict line.
- Cause: the snapshot's `declare -A` at line 229 listed `FURL FINROW FSEEN FDIG FNRM` but not `SUPERSEDED`, while line 242 executed `SUPERSEDED[$fid]=1`. Under `set -u`, bash evaluated the subscript `S007` arithmetically, hitting the unbound variable `S007`.
- Isolation: running the same script on a pristine corpus copy with only `BASH_ENV='declare -A SUPERSEDED=()'` produced `SOURCES_CENSUS: CLEAN (rows=26 A=24 B=0 C=2 queued=1 mined=24 rejected=1 entries_sourced=4 legacy=21)`, exit 0.
- `bash corpus/sources-census.sh --selftest` was green on that same snapshot: `SOURCES_CENSUS_SELFTEST: PASS (59 cases)`, exit 0, because the fixture registry contains no `supersedes Sxxx` cell. The live registry has six such rows (`corpus/SOURCES.md:25,26,28,29,31,32`).
- Fixed by 01:02:21 (the dead `SUPERSEDED` block was removed). At 01:02:24 and 01:03:39, `bash corpus/sources-census.sh` → `SOURCES_CENSUS: CLEAN (rows=26 A=24 B=0 C=2 queued=1 mined=24 rejected=1 entries_sourced=4 legacy=21)`, exit 0; `--selftest` at 01:03 → `PASS (59 cases)`, exit 0.
- Recorded for operability/calibration only; not an S001 provenance defect. Another falsify report observed the same window (`.ufo/waves/round-23/falsify/MutFetchRemove.md:194`).

## 5. Count correction relevant to the brief (already fixed in-tree)

At 00:58 the lesson said "10 declared provenance rows (S017-S026) over seven distinct URLs"; measured distinct exact URLs = **9** (the pair `S021`/`S026` shares one). The brief's "10 captures over 7 URLs" repeats that stale value. At 01:02:31 the lesson/LOG/SCORECARD were edited to nine: `corpus/lessons/round-23.md:170`, `LOG.md:1202`, `SCORECARD.md:840`. No standing defect at report time.

## 6. Residual unknowns and non-blocking notes

- The representation behind S001's `9f9d7283…` is unknown and not recoverable from this lane; no byte snapshot exists. The parent-build artifact reports 2026-10-19 HTML `24d1aecd…`, `.md` `43b9a0c7…`, and archive `94553c66…`, all different; I did not independently reproduce those three.
- Minor documentation mismatch, not an S001 issue: `corpus/sources-census.sh:64-66` says two provenance rows for one URL must agree on the raw digest, while the implementation at `:279-284` skips raw agreement for `decoded-http-body-volatile-v1`; `corpus/source-fetches.tsv:17-19` documents the volatile exception. All 10 current captures are volatile, so the enforced same-URL check is the normalized one (`:285-290`), which currently passes (`ed949658…` for both `S021` and `S026`).
- I did not fetch S001's `.md`/archive alternates or the remaining capture URLs; that was outside the assigned bound question.

## 7. Selected command log (exact, from the lane root)

| command | exit | result |
|---|---|---|
| `bash corpus/sources-census.sh --selftest` | 0 | `PASS (59 cases)` (run at 00:58 and 01:03) |
| `bash corpus/sources-census.sh` (snapshot 00:57:55) | 1 | `line 242: S007: unbound variable`, no verdict |
| `bash corpus/sources-census.sh` (snapshot 01:02:21) | 0 | `CLEAN (rows=26 A=24 B=0 C=2 queued=1 mined=24 rejected=1 entries_sourced=4 legacy=21)` |
| `awk -F'\t' '$1=="S001"{n++} END{print n+0}' corpus/source-fetches.tsv` | 0 | `0` |
| `grep -c 'https://www.1password.dev/cli/secrets-scripts' corpus/source-fetches.tsv` | 1 | `0` |
| `awk -F'\t' '!/^#/ && NF==16 {print $4}' corpus/source-fetches.tsv \| sort -u \| wc -l` | 0 | `9` |
| `curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)' https://openbao.org/docs/concepts/tokens/ -o /tmp/r23-s026.html -w 'HTTP=%{http_code} bytes=%{size_download}\n'` | 0 | `HTTP=200`, decoded 47,384 B, sha256 `52295218…` = declared `S021`/`S026` |
| `curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)' https://www.1password.dev/cli/secrets-scripts -o /tmp/r23-s001.html -w 'HTTP=%{http_code} bytes=%{size_download}\n'` | 0 | `HTTP=200`, decoded 1,228,087 B, sha256 `e72ab5f3…` |
| copy mutants A–D via `bash corpus/sources-census.sh verify --root /tmp/s001-audit.oYx6xU` | 0/1 | A, C: `CLEAN`, exit 0; B: `inrow-digest-malformed`, exit 1; D: `missing-provenance`, exit 1 |

No lane file was modified; the mutant copy and fetched bytes lived temporarily under `/tmp` and were removed after measurement. No installs, no host gates, no credential reads.
