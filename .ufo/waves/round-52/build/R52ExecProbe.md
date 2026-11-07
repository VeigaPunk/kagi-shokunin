# R52ExecProbe — HTTP second method for C2 rewrap probe facts (round-51 D1)

Status: COMPLETE. Axes: (A) pinned-binary identity/sha held; (B) CLI probe values reproduce;
(C) HTTP-API probe equals CLI probe creation paths (incl. originals, two HTTP clients);
(D) no secret on argv, no tokens printed/persisted outside scratch, servers killed, scratch-only effects.

No tool installs: used pinned `~/.local/bin/bao`, `curl`, `python3` (stdlib) only.
`pacman` never run. `~/.local/bin/bao` never written.

## Pin check

- Command: `sha256sum ~/.local/bin/bao`
- Expected (plans/round-52-c2.sh PIN_BAO): `9c5f36287c673f386e1533e9c044169a248e4ee50dd54810fa766e95bd41b788`
- Observed: `9c5f36287c673f386e1533e9c044169a248e4ee50dd54810fa766e95bd41b788` (match)
- `bao version`: `OpenBao v2.7.2 (9e0a0d3c35…)`

## C2 counter run on BASE

- Command: `bash /home/vgpnk/Projects/shokunin/kagi-shokunin/plans/round-52-c2.sh 1d984adaa4a5c66ea9f24cb95bf79ffbca16c32b`
- Exit: `0`; wall 4.35 s. Output (receipt `.ufo/waves/round-52/build/R52ExecProbe/c2-base.out`, copy in scratch):
  `C2_REWRAP_STATEMENTS: value=2 assertions=2 guard=1 probe=1 obs_helper=sys/wrapping/wrap obs_kv=secret/data/<path> uncorrected=[corpus/knowledge/vault-openbao-token-lease-lifecycle.md:292 corpus/lessons/round-51.md:22]`
- CLI-probe facts from counter: `obs_helper=sys/wrapping/wrap`, `obs_kv=secret/data/<path>`
  (`<path>` is the counter's normalisation of `secret/data/r52probe`).

## Independent HTTP probe (this seat)

Method (pinned binary only as server, as assigned): throwaway `bao server -dev`
(`env -i HOME=<scratch>/home PATH=/usr/bin:/bin BAO_DEV_ROOT_TOKEN_ID=<rand> setpriv --pdeathsig KILL ~/.local/bin/bao server -dev -dev-listen-address=127.0.0.1:<random-port> -dev-no-store-token`),
root token only via `BAO_DEV_ROOT_TOKEN_ID` env → scratch header file used by `curl -H @file`;
never on argv, never printed. Two independent HTTP clients both ran the full chain:
(1) Python stdlib `urllib` (token in `X-Vault-Token` header from scratch file, in-process);
(2) `curl` with `-H @root.hdr` (`http-curl.sh`, header file, body files, `--data @file`).
Chains: (a) `POST /v1/sys/wrapping/wrap {"v":"r52probe"}` (+ `X-Vault-Wrap-TTL: 120s`,
required or 400 `endpoint requires response wrapping to be used`), `POST /v1/sys/wrapping/lookup`
on original, `POST /v1/sys/wrapping/rewrap`, lookup on rewrapped;
(b) `POST /v1/secret/data/x`, `GET /v1/secret/data/x` with `X-Vault-Wrap-TTL: 120s`, lookup on
original, rewrap, lookup on rewrapped. Values-only results in `http-results.json`
(urllib run) and `http-curl.out` (curl run); both receipt copies committed under
`.ufo/waves/round-52/build/R52ExecProbe/`.

### Four creation paths, plus originals (values only, no tokens)

| # | Token | creation_path |
|---|-------|---------------|
| (a1) helper ORIGINAL (sys/wrapping/wrap), lookup | `sys/wrapping/wrap` |
| (a2) helper REWRAPPED (after sys/wrapping/rewrap), lookup | `sys/wrapping/wrap` |
| (b1) KV ORIGINAL (wrapped `kv get` of secret/data/x), lookup | `secret/data/x` |
| (b2) KV REWRAPPED (after rewrap), lookup | `secret/data/x` |

Raw receipt ends (urllib): `helper_REWRAPPED_lookup_creation_path=sys/wrapping/wrap`,
`kv_REWRAPPED_lookup_creation_path=secret/data/x`, `ALL-HTTP-OK`, exit `0`.
Raw receipt ends (curl): `curl helper REWRAPPED lookup creation_path=sys/wrapping/wrap`,
`curl kv REWRAPPED lookup creation_path=secret/data/x`, `CURL-PROBE-OK`, exit `0`.

## Comparison and verdict

- HTTP (both clients) rewrapped helper path `sys/wrapping/wrap` == C2 CLI probe `obs_helper=sys/wrapping/wrap`. **AGREE.**
- HTTP (both clients) rewrapped KV path `secret/data/x` == C2 CLI probe `obs_kv=secret/data/<path>` after the counter's documented `<path>` normalisation of its probe path `secret/data/r52probe` (this seat used `secret/data/x`; the origin is the KV read path in both). **AGREE.**
- Originals round-trip unchanged (`sys/wrapping/wrap` → same; `secret/data/x` → same), so rewrap here
  preserves creation_path in both directions; no discrepancy surfaced.
- Residual risk: HTTP probe used `secret/data/x` where the counter uses `secret/data/r52probe` (by
  assignment); normalisation `^secret/data/r52probe$` → `secret/data/<path>` is the counter's own,
  and the mechanism (path = the KV endpoint read) is identical. Not a code path difference.

## Hygiene

- Tokens: only in scratch (`root.token`, `root.hdr`, in-memory). Never printed, never argv, never
  committed. Only creation-path *values* are in `http-results.json`/report.
- Servers: my PIDs killed by PID (`kill <pid>`); re-verified `server down` and no running `bao`
  process with my scratch HOME remains. Other seats' `bao server -dev` processes were not touched.
- Scratch: `$HYAKU_SCRATCH/kagi-r52/R52ExecProbe` (receipts: `c2-base.out`, `http-results.json`,
  `http-curl.out`, `http-curl.sh`, `port.txt`). Report + receipts also at
  `.ufo/waves/round-52/build/R52ExecProbe.md` and `.ufo/waves/round-52/build/R52ExecProbe/`.
  (Note: `trap 'rm -rf -- "$S"' EXIT` was not armed on this shell; scratch retained for parent inspection.)
- Risks/blockers: none remaining. First curl run hit a parser bug (`d.get("wrap_info")` nil check);
  fixed and re-ran on a fresh server — final receipt above is the passing run.
