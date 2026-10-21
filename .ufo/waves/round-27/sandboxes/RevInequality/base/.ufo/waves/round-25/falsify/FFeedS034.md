# FFeedS034 — source re-open

Revision: `82745e2c60e726b49499b8f309529935dc4eff2b` (frozen clone at `/fast/scratch/kagi-r25/FFeedS034-4/lane`).
Verdict: **no actionable falsifier**. Calibration PASS; operability PASS; freshness PASS. No production file changed except this report.

## Committed evidence

- `corpus/SOURCES.md:40`: S034 URL is `https://github.com/hashicorp/vault/releases.atom`; kind `code`, tier `A`; scope is Vault's newest stable `X.Y.Z` release identity for S012, S013, S022–S024 clocks, excluding `sdk/` module tags and `-rc` prereleases. Quote is `<title>v2.2.0</title>` (1 whitespace-delimited word).
- `corpus/source-fetches.tsv:77`: mined; HTTP 200; profile `curl-fsSL-compressed-v1`; opened 2026-10-21; representation `decoded-http-body-volatile-v1`; SHA-256 `e41bc5793403136a07c68d7d107fe3e9d68b834f51bd4d77cad5c13a388670ba`; 303995 bytes; declared quote and locator `raw-literal-v1`.
- Lesson Gate `corpus/lessons/round-25.md:83-91` says all five feeds were opened with that profile and the quote located in the decoded body; S034 is admitted tier A and the quote is reported at the first stable entry, updated `2026-10-15T18:50:14Z`. Lines 107-109 explicitly state new feed rows use `recheck: 90d`, not an on-release clock.

## Independent re-open

Clone argv: `git clone -q --no-hardlinks /home/vgpnk/Projects/shokunin/kagi-shokunin /fast/scratch/kagi-r25/FFeedS034-4/lane && git -C /fast/scratch/kagi-r25/FFeedS034-4/lane checkout -q 82745e2c60e726b49499b8f309529935dc4eff2b && git -C /fast/scratch/kagi-r25/FFeedS034-4/lane rev-parse HEAD`.
Stdout: `82745e2c60e726b49499b8f309529935dc4eff2b`; exit 0.

Public fetch argv: `env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/FFeedS034-4/home curl -fsSL --compressed -A 'kagi-shokunin-round25/1.0 (documentation verification)' -o /fast/scratch/kagi-r25/FFeedS034-4/evidence/S034.body -w 'http_status=%{http_code}\nurl_effective=%{url_effective}\n' https://github.com/hashicorp/vault/releases.atom`.
Stdout: `http_status=200`, `url_effective=https://github.com/hashicorp/vault/releases.atom`, `curl_exit=0`, `303995 /fast/scratch/kagi-r25/FFeedS034-4/evidence/S034.body`, SHA-256 `e41bc5793403136a07c68d7d107fe3e9d68b834f51bd4d77cad5c13a388670ba`; shell exit 0.

Parser/locator argv: `env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/FFeedS034-4/home PYTHONDONTWRITEBYTECODE=1 python3 -B -c 'import importlib.util, pathlib; root=pathlib.Path("/fast/scratch/kagi-r25/FFeedS034-4/lane"); path=root/"corpus/release-clock.py"; spec=importlib.util.spec_from_file_location("release_clock",path); module=importlib.util.module_from_spec(spec); spec.loader.exec_module(module); body=pathlib.Path("/fast/scratch/kagi-r25/FFeedS034-4/evidence/S034.body").read_bytes(); quote="<title>v2.2.0</title>"; text=body.decode("utf-8"); print("decoded_utf8=PASS"); print("raw_literal_v1_located=%s" % (quote in text)); print("quote_word_count=%d" % len(quote.split())); print("quote_occurrences=%d" % text.count(quote)); print("release_parser=%s" % module.parse_latest_version(body)); print("has_rc_title=%s" % ("v2.2.0-rc1" in text)); print("has_sdk_tag=%s" % ("sdk/v0.26.0" in text));'`.
Stdout: `decoded_utf8=PASS`; `raw_literal_v1_located=True`; `quote_word_count=1`; `quote_occurrences=1`; `release_parser=2.2.0`; `has_rc_title=True`; `has_sdk_tag=True`. Exit 0.

This directly exercises `parse_latest_version` in the frozen clone. Its rules at `corpus/release-clock.py:530-580` accept exact stable `X.Y.Z` titles/tag links and take the maximum across entries; the parser returns `2.2.0` despite the same feed containing `v2.2.0-rc1` and `sdk/v0.26.0`. The fresh body size and digest equal the committed capture row. Since that row explicitly labels the representation volatile, a future digest mismatch alone would not falsify the historical capture.

## Clock handshake and limits

`corpus/release-clock.py:365-367` populates the clock set only from rows with `recheck == "on-release"`; `:409-418` explicitly rejects an on-release feed source so a feed cannot clock itself. S034 is `90d`, while `corpus/release-clocks.tsv:9-10,19-21` binds Vault on-release sources to S034. The committed `.ufo/waves/round-25/observe-1.json` observations for S012/S013/S022-S024 report HTTP 200, parsed version `2.2.0`, the same SHA-256, and their expected fired/not-fired verdicts; the lesson records this handshake at lines 113-125.

Residual risk: the committed capture body itself is not retained as a separate artifact; the row, lesson, committed observation, and same-day matching re-fetch support the claim, but the volatile digest is not a permanent identity guarantee.

UNRUN: full `verify`/`cells` (forbidden per-seat); full `release-clock.py --observe` (not needed for the scoped S034 parser check). LSP status/references/definition/diagnostics unavailable: `read xd://lsp` returned `No such tool`; conclusions above are from the cited committed rows, code, and direct parser output, not grep semantics. No tools installed.