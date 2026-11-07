# R54ExecLiveOp — independent live leg for C1 (round 54)

Seat: executor, live re-observation and re-measurement leg (leaf; no subagent dispatch).
Candidate: `ede4373afa07a33e24cbd35e9fd33fc2fddf2f14`, extracted with `git archive` to scratch `/fast/scratch/hyaku/kagi-r54/R54ExecLiveOp/cand`. The lane tree was not mutated; no git add, commit, stash, checkout, switch, or reset was run.
Receipts copied to `.ufo/waves/round-54/build/R54ExecLiveOp.receipts/` (observe-check.json, feed.xml, sha256.txt).

## Verdict

C1 reproduces independently. All 32 release-clock records agree with the frozen receipt on id, parsed_version, verdict, and sha256. The op 2.42.0 archive matches the frozen zip and binary hashes, and its signature verifies against key 3FEF9748469ADBE15DA7CA80AC2D62742012EA22. The dotenv byte probe is CLEAN on 2.42.0 and on the installed 2.41.1. A silent stub reads DRIFT, not CLEAN, so the probe is not vacuous.

One caveat, stated plainly: the byte contract is identical on 2.41.1 and 2.42.0. The S072 "fired" verdict is a release-event trigger. The probe result does not show a behaviour change in op.

## Leg 1 — release clock re-observation (candidate tree)

Command: `cd $S/cand && TMPDIR=$S python3 corpus/release-clock.py --observe $S/observe-check.json`
Exit: 0 (service `r54-observe` exited 0).

Comparison against `.ufo/waves/round-54/final/observe-r54.json` (ids equal; 32 rows each; diff_rows=0):

| id | parsed_version | verdict | sha256 prefix | agree |
|---|---|---|---|---|
| S005 | None | quote-located | 54953095c930 | MATCH |
| S006 | None | quote-located | 9aecbd8d0263 | MATCH |
| S007 | None | quote-located | 6b4e78533fb2 | MATCH |
| S008 | 3.13.3 | not-fired | 47a224ad7143 | MATCH |
| S009 | 3.13.3 | not-fired | 47a224ad7143 | MATCH |
| S010 | 3.13.3 | not-fired | 47a224ad7143 | MATCH |
| S011 | 3.13.3 | not-fired | 47a224ad7143 | MATCH |
| S012 | 2.2.1 | fired | 3cbfdd86d1b4 | MATCH |
| S013 | 2.2.1 | fired | 3cbfdd86d1b4 | MATCH |
| S014 | 2.7.2 | fired | a54d1a5314ca | MATCH |
| S015 | 2.7.2 | fired | a54d1a5314ca | MATCH |
| S016 | 2.7.2 | fired | a54d1a5314ca | MATCH |
| S017 | None | quote-located | c8378f18c70f | MATCH |
| S018 | None | quote-located | 5c226c064138 | MATCH |
| S019 | None | quote-located | 6b4e78533fb2 | MATCH |
| S020 | None | quote-located | 9aecbd8d0263 | MATCH |
| S021 | 2.7.2 | fired | a54d1a5314ca | MATCH |
| S022 | 2.2.1 | fired | 3cbfdd86d1b4 | MATCH |
| S023 | 2.2.1 | fired | 3cbfdd86d1b4 | MATCH |
| S024 | 2.2.1 | fired | 3cbfdd86d1b4 | MATCH |
| S025 | 2.7.2 | fired | a54d1a5314ca | MATCH |
| S026 | 2.7.2 | fired | a54d1a5314ca | MATCH |
| S027 | 3.15.2 | fired | 9ba8856e5866 | MATCH |
| S028 | 3.15.2 | fired | 9ba8856e5866 | MATCH |
| S029 | 8.23.0 | not-fired | 788e97f81654 | MATCH |
| S030 | None | quote-located | 8d43350a0a36 | MATCH |
| S031 | None | quote-located | b2057fec4bac | MATCH |
| S032 | None | quote-located | 6b4e78533fb2 | MATCH |
| S072 | 2.42.0 | fired | 2dce505aedfb | MATCH |
| S098 | None | quote-located | 68e34b8ba02d | MATCH |
| S103 | 3.13.3 | not-fired | 47a224ad7143 | MATCH |
| S104 | 1.3.2 | not-fired | 32517112c2ec | MATCH |

Newer releases: none. No parsed_version differs from the frozen receipt.

Note: S112 has no separate row among the 32. It is the feed registry row that S072 binds to (`corpus/release-clocks.tsv` line 30), and S072's record carries the same URL.

Live feed check (public GET of `https://releases.1password.com/developers/cli/index.xml`, run separately): the newest `1Password CLI X.Y.Z` title is 2.42.0. The sha256 of the fetched body is `2dce505aedfb66f207701c4d96cb1c337f025cb6305817885c6c7f74665405e2`, equal to the S112 capture. Size 45175 bytes.

## Leg 2 — op 2.42.0 archive, signature, sha256

Download: `curl -fsSL --retry 2 -o $S/op.zip https://cache.agilebits.com/dist/1P/op2/pkg/v2.42.0/op_linux_amd64_v2.42.0.zip` → 16233648 bytes, exit 0.
Unzipped to `$S/op2/` (`op`, `op.sig`).

Hashes:
- `261fe3844a43e7e83a3d85e8a9f36411729436a1d3add1dc7dd46cbbceebe9e5  op.zip` (matches receipt `zip_sha256`)
- `8585aa02644f71c05b268125d0b474fd0d8ed606176b3878517cb79d280cfc92  op2/op` (matches receipt `op_sha256`)
- `e810d04ea0d03244957fca30720c972c29ef97055febf760163915b191a88418  op2/op.sig`

Signature: key 3FEF9748469ADBE15DA7CA80AC2D62742012EA22 was already present in the local keyring, so no keyserver fetch was needed.
`gpg --verify op.sig op` → `Good signature from "Code signing for 1Password <codesign@1password.com>" [unknown]`; WARNING: key not certified with a trusted signature (the local trust level is unknown, the signature itself is good). Exit 0.
Status line: `[GNUPG:] VALIDSIG 3FEF9748469ADBE15DA7CA80AC2D62742012EA22 2026-11-04 1793825235 0 4 0 1 10 00 3FEF9748469ADBE15DA7CA80AC2D62742012EA22`

## Leg 3 — op-ref probe, --dotenv-bytes

Command pattern: `cd $S/cand && TMPDIR=$S OP_REF_OP_BIN=<bin> bash corpus/op-ref-probe.sh --dotenv-bytes; echo exit=$?`

Run A — op 2.42.0 (`$S/op2/op`):
```
DOTENV_BYTES_CASE id=escaped-lf status=PASS
DOTENV_BYTES_CASE id=trailing-lf status=PASS
DOTENV_BYTES_CASE id=newline-only status=PASS
DOTENV_BYTES_CASE id=single-literal status=PASS
DOTENV_BYTES_CASE id=double-multiline status=PASS
DOTENV_BYTES_CASE id=single-multiline status=PASS
OP_DOTENV_BYTES: CLEAN (checks=6 failed=0)
exit=0
```

Run B — installed `/usr/bin/op` (2.41.1), comparison:
```
DOTENV_BYTES_CASE id=escaped-lf status=PASS
DOTENV_BYTES_CASE id=trailing-lf status=PASS
DOTENV_BYTES_CASE id=newline-only status=PASS
DOTENV_BYTES_CASE id=single-literal status=PASS
DOTENV_BYTES_CASE id=double-multiline status=PASS
DOTENV_BYTES_CASE id=single-multiline status=PASS
OP_DOTENV_BYTES: CLEAN (checks=6 failed=0)
exit=0
```

Confirmed `/usr/bin/op --version` → `2.41.1`. No other op subcommand was run. `op` was not installed or replaced.

## Leg 4 — negative control (silent stub)

Stub: `$S/null-op.sh` = `#!/bin/sh` / `exit 0`, printing nothing. Run with `OP_REF_OP_BIN=$S/null-op.sh`:
```
DOTENV_BYTES_CASE id=escaped-lf status=FAIL reason=exit-or-bytes
DOTENV_BYTES_CASE id=trailing-lf status=FAIL reason=exit-or-bytes
DOTENV_BYTES_CASE id=newline-only status=FAIL reason=exit-or-bytes
DOTENV_BYTES_CASE id=single-literal status=FAIL reason=exit-or-bytes
DOTENV_BYTES_CASE id=double-multiline status=FAIL reason=exit-or-bytes
DOTENV_BYTES_CASE id=single-multiline status=FAIL reason=exit-or-bytes
OP_DOTENV_BYTES: DRIFT (checks=6 failed=6)
exit=1
```
Verdict: DRIFT, exit 1. Not CLEAN. The probe is not vacuous against a silent op.

## Harm and scope checks

- The candidate tree was extracted read-only into scratch; no lane file was edited.
- No write outside `.ufo/waves/round-54/build/R54ExecLiveOp*` and scratch.
- No op subcommand except `--version` and the lane probe; no sign-in; no account or vault contact; no op:// reference written anywhere.
- Nothing installed. The downloaded binary stays in scratch and was passed by absolute path. No ~/.local/bin, /usr, or pacman action.
- Public GET only: the op archive, the release feed, and the observe run's public fetches.

## Tools

No tools were installed or upgraded. gpg, unzip, curl, and the installed op 2.41.1 were already present and used as-is.

## Open items for main agent

- Run `bash corpus/op-ref-probe.sh --dotenv-bytes` verification is consistent with the frozen receipt. The byte contract does not distinguish 2.41.1 and 2.42.0. The "fired" verdict is a release-event trigger, not a behaviour change.
- The final observe receipt's S072 record and the S112 feed have the same URL, but the 32 rows do not include a separate S112 row. This is consistent with the lane design (S112 is the feed registry row); flagged for the record only.
