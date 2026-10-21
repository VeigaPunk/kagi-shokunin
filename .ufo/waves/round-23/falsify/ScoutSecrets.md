# ScoutSecrets — round-23 credential-material sweep (falsification seat)

Snapshot: 2026-10-21T03:59Z. Base `d218603b74099ddca0bd8f869516fc41db0979bf` (`git rev-parse HEAD`, exit 0)
plus the uncommitted round-23 tree. Read-only except this file. No credential store read; no host gate,
no legacy claim-ledger verify, no claim-row audit; the only executed gate was the host-free census
selftest.

## Attacked

Every added line of the 9 modified files (259 added lines, from `git diff --unified=0`) and every line of
the 50 untracked files as they existed at snapshot time. Product surface = 20 files / 1,993 added-or-new
lines; wave scratch (`.ufo/waves/round-23/**`) = ~10,882 more lines, live and changing during the sweep.
Product artifact SHA-256 prefixes are recorded at the end so the scan is re-runnable against the same bytes.

Pattern classes:

- **Census SC_CREDENTIAL (7)**: 1Password secret-reference URI scheme; PEM private-key armour; GitHub
  classic PAT; AWS access-key id; Slack `xox` bot/app/user prefix; age secret key; Vault/OpenBao
  service/batch/recovery token (`hv`+`[sbr]`+dot). Assembly mirrors `corpus/sources-census.sh:128-135`.
- **Extended references**: GitHub fine-grained PAT; SSH public-key blob; PuTTY key header; JWT;
  `Bearer` header; secret-reference URI schemes (vault/ssm/secretsmanager/doppler/infisical/onepassword/
  keeper/aws-ssm); generic `password|secret|token|api_key = value`; PEM variants (RSA/OPENSSH/EC/DSA/
  ENCRYPTED); long base64 run (60+).
- **URL/cloud**: URL userinfo; URL query secret params; cloud/Slack/Vault env-var names;
  service-account JSON marker; kubeconfig keys; `Authorization`/`Cookie` header shapes.
- **Known token prefixes**: `sk-`/`sk-ant-`, GitLab PAT, GitHub OAuth variants, Google API/OAuth,
  Stripe, SendGrid, npm, Twilio, Telegram bot, Slack/Discord webhooks, Hugging Face, `BEGIN CERTIFICATE`.
- **Coverage-gap probes**: AWS `ASIA` session key id, Slack `xoxc/xoxd/xoxo`, legacy Vault `s.` token,
  fine-grained GitHub PAT.

Positive control: all 7 census classes fired on canonical synthetic shapes built in-memory from fragments;
negative control (sha256 line, https URL, `hvac` prose, `operations`, `monkey`) fired none except the
intentional long-base64 catch-all on the digest. Scanner is not vacuous.

## Commands and exits

| Command | Exit |
|---|---|
| `git rev-parse HEAD` | 0 (`d218603b…`) |
| `git status --porcelain=v1 -uall` | 0 (9 modified, 50 untracked) |
| `git diff --unified=0 -- <file>` per modified file, added-line extraction | 0 |
| `grep -nEi 'authorization\|cookie\|-H \|--header\|bearer\|basic ' corpus/source-fetches.tsv` | 1 (no match) |
| `grep -n 'KAGI12_POISON=op' SKILL.md` | 0 → line 643 |
| `bash corpus/sources-census.sh --selftest` | 0 — `SOURCES_CENSUS_SELFTEST: PASS (59 cases)`, incl. 8 credential cases, wall ~2.0 s |
| in-kernel regex sweep over 1,993 product lines + 10,882 wave-scratch lines | no shell exit; counts below |

The LSP device does not apply: the material is Markdown/TSV/JSON/shell/py text, and the one Python symbol
question (`closure-dispositions.py:118`) was answered by direct line read plus function context
(`resolve_pointer`, lines 110-124).

## Found

1. **No census-class credential material on any added line or new file.** C1–C7 hits: 0, product and
   wave scratch. Extended, URL/cloud, known-prefix, and gap-probe classes: 0. Auth/cookie-header shapes
   in `source-fetches.tsv`: 0. This includes `corpus/sources-census.sh`'s own added lines: the
   fragment-assembled needle source does not itself match, and the selftest's 8 credential cases pass
   (`PASS (59 cases)`, exit 0), confirming the scanner detects the shapes it claims to.
2. **One assignment-shaped false positive**, `corpus/closure-dispositions.py:118`: a local variable named
   `token` assigned a compiled regex (`masked span: ##### = ##.#######`). Not credential material; it is
   the fixed-pointer matcher in `resolve_pointer`.
3. **Two long-base64 candidates, both resolved to public GitHub URL paths** (structure-only masks, bytes
   not reproduced):
   - `.ufo/waves/round-23/parent-build/SourceS008.md:25` — path with a 40-char hex segment (commit pin)
     ending in a document name before `.rst`; report elides the prefix with U+2026.
   - `.ufo/waves/round-23/parent-build/SourceS010.md:42` — `https://github.` + 3/7/4/6/40-char path
     segments, final segment 40-char lowercase hex (commit URL).
   Neither is a token; both are documentation provenance links.
4. **Near-miss, not a leak**: `SKILL.md:643` (added line) contains the 1Password scheme literal followed
   by U+2026 and nothing else (`KAGI12_POISON=<scheme>…`), i.e. a deliberately truncated example with no
   authority/path. It correctly does not match the census class (which requires an alphanumeric after the
   scheme separator). No reference bytes present.
5. **All remaining long-base64 hits are hex digests** (14 product hits: 10 `source-fetches.tsv` rows, 2
   `stamps.tsv`, 1 `closure-dispositions.json:4`, 1 inside the `.pyc` string table). Expected
   sha256/SHA-1 provenance digests, not credentials.
6. **Incidental hygiene**: `corpus/__pycache__/closure-dispositions.cpython-314.pyc` is untracked in the
   lane. It carries no credential-shaped material beyond the one inherited hex digest, but a broad
   `git add -A` would commit a build artifact.

## Bounds the C1/C2/C3 claims must carry

- **Credential-scan scope is narrow.** `cred_scan` is invoked only for `corpus/SOURCES.md`
  (`corpus/sources-census.sh:307`) and each sourced `corpus/knowledge/*.md` entry inside the per-entry
  loop (`:333`). The header documents this (`:82-86` scope bound, `:87-91` needle list, plus the
  legacy-entry exclusion). It does **not**
  scan `corpus/source-fetches.tsv`, `corpus/closure-dispositions.{py,json}`, `corpus/fixtures/**`,
  `corpus/lessons/**`, `plans/**`, or top-level `LOG.md`/`SCORECARD.md`/`SKILL.md`. Any round-23 wording
  that implies repository-wide credential scanning overreaches; this sweep supplies the missing coverage
  for added lines only.
- **The census class list is seven named shapes**, and it is under-inclusive by design: it omits AWS
  `ASIA` session key ids, Slack `xoxc/xoxd` session/cookie prefixes, legacy Vault `s.` service tokens,
  and fine-grained GitHub PATs. All four gap probes returned 0 on the added lines, so this is a stated
  scanner bound, not a present leak.
- **Regex-line coverage, not entropy proof.** The sweep detects literal shapes on text lines; an encoded
  or split-across-lines secret would evade it (the 60+ base64 catch-all covered single-line blobs only and
  produced the two path false positives above). The compiled `.pyc` was scanned as bytes-as-latin-1.
- **Wave scratch is volatile.** `.ufo/waves/round-23/**` grew between the first and final pass
  (12,832 → 12,860 lines total); counts are a snapshot, and peers writing new reports after 03:59Z are not
  covered by this run. Product files were re-read for the final pass and are identified by digest below.
- **No claim is made about material outside the tree** (git history, other repositories, or credential
  stores), and none was read.

## Product artifact digests (SHA-256 prefixes, snapshot of this sweep)

```
95808e54d09fcbe8  LOG.md
d3214edbd617ea47  SCORECARD.md
dc5d9867a5f84ab7  SKILL.md
06dde644801bee13  corpus/SOURCES.md
017c59e52cb6cacb  corpus/__pycache__/closure-dispositions.cpython-314.pyc
c20c2d04a354b54b  corpus/claim-ledger.sh
6fa0c24fc696e82b  corpus/claim-ledger.tsv
f20f00d1be8d5098  corpus/closure-dispositions.json
6cc822785d2b93c6  corpus/closure-dispositions.py
04b915601d019540  corpus/fixtures/cells-hermetic/SCORECARD.md
1674d112af479ffd  corpus/fixtures/cells-hermetic/claims.tsv
c17f7e17ff89f255  corpus/fixtures/cells-hermetic/corpus/adjacency.tsv
29f98fbaaa2412f5  corpus/fixtures/cells-hermetic/corpus/fx-ok.sh
b521142b712e6329  corpus/fixtures/cells-hermetic/stamps.tsv
76b46fb4df2540c0  corpus/knowledge/op-ref-consumption.md
d55209887c13825c  corpus/lessons/round-23.md
ccc9ae6ec1b4bfa2  corpus/source-fetches.tsv
80966e208321348a  corpus/sources-census.sh
1e697b0179547a86  corpus/surface-census.sh
cb1287ba303a2694  plans/round-23.md
```

No installs or updates were performed.
