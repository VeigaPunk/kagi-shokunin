# R57Labrat — independent probe: audit HMAC defaults, `log_raw`, salt rotation

Seat: R57Labrat (labrat, attack share 5/12), wave round-57/w1. Lane
`/home/vgpnk/Projects/shokunin/kagi-shokunin`, branch master, claim BASE
`1cda9e7ae4767b4133e283bfbc08266d4c86362d` (observed tip at probe time
`7aa1f4726e1f6bcdc8411d1a8b21828d49785173`, frozen instruments unchanged:
plan 5773c1a4…, c1-check 19d75337…, c1.sh 3104b06f…, c2.sh 3de6b4de…,
controls 6796ae70…). The probe is independent of the trial draft: every
command below was authored and run by this seat, not the trial script.

Binary: `/home/vgpnk/.local/bin/bao`, OpenBao v2.7.2
(`9e0a0d3c3504a0a00b45e61355afac5e35c78379`, committed 2026-10-26),
SHA256 `9c5f36287c673f386e1533e9c044169a248e4ee50dd54810fa766e95bd41b788`.
No package/tool was installed or updated in this seat (pacman paused; nothing
needed). Answering model observed in the harness-provided session context:
`amr/deepseek-v4.1-flash`.

Method: throwaway `bao server -dev` on 127.0.0.1, in-memory storage, server-
generated random root token read only from the scratch server output (never
printed, never on argv), a 160-bit random nonce written via stdin to
`secret/data/probe` (`bao kv put -mount=secret probe value=-`), and a JSON
analyzer that emits only booleans, shapes, paths and truncated digests. Four
runs: (1) default dev server, API enable attempted; (2) dev + documented
`unsafe_allow_api_audit_creation = true` and CLI/API enable; (3) declarative
`audit` stanzas + SIGHUP; (4) `/sys/audit-hash` cross-check. Receipts:
`.ufo/waves/round-57/w1/R57Labrat.d/`.

## Findings — five-line table

| # | Hypothesis | Observed (ids/digests) | Verdict |
|---|---|---|---|
| F1 | A default `file` audit device HMACs the written value in both request and response entries and never stores the plaintext (type set `request`/`response` only) | Default log 27 entries (14 request, 13 response). Value at `request.data.data.value` and `response.data.data.value`, form `hmac-sha256:` + 64 hex, one digest `9026895605d48a51`; nonce plaintext occurrences 0; token plaintext occurrences 0 | **CONFIRMED** |
| F2 | The logged value is the device's *salted* HMAC of the plaintext, stable within one salt, and request HMAC equals response HMAC | `POST /v1/sys/audit-hash/file` rc 200 → `hmac-sha256:`+hex exactly equal to the logged hex (before `56ef5ac99b29…`, after `a44a5729886d…`); `sha256(nonce)` ≠ logged hex; request-vs-response digest equal `true`; repeated writes of the same value share one digest (`9026895605d48a51`, and `2a84f3cdf9b1ad50` after re-enable) | **CONFIRMED** |
| F3 | A second device with `log_raw=true` stores the same value in raw form while the default device keeps HMACing it (per-device isolation) | Raw log 32 entries: plaintext value under `request.data.data.value`/`response.data.data.value`, 10 occurrences, prefix `plain-nonce`, length 40; default log over the same window: 0 occurrences. Raw log also carries the client token in cleartext (62 token occurrences) vs 0 in the default log | **CONFIRMED** |
| F4 | Disable + re-enable at the same audit path creates a new salt: same value, different HMAC; still deterministic and value-dependent within each salt | API route: disable rc 0 (`DELETE` 204), re-enable rc 0 (`PUT` 204); digest `9026895605d48a51` → `2a84f3cdf9b1ad50`; second write after re-enable identical (`2a84f3cdf9b1ad50`); different value → `a39805c505dbf45c`. Declarative route: HUP-remove then HUP-re-add → `bca9f7647501dedd` → `7472b3b058d905f0`. Salt rotation also confirmed positively by `/sys/audit-hash` equality before/after | **CONFIRMED** |
| F5 | `bao audit enable file file_path=…` works on a plain `bao server -dev` (the route the frozen trial's T1/T3/T4 name) | rc 2, HTTP 400, body `cannot enable audit device via API; use declarative, config-based audit device management instead` (same for `-path=file2 … log_raw=true` and for re-enable). It works only with `unsafe_allow_api_audit_creation = true` in the dev config, or via declarative `audit` stanzas; `bao audit disable file/` on a config-managed device fails rc 2 `cannot disable configuration-managed audit device` | **FALSIFIED** (default availability) |

Verdict on the three assigned questions: yes, audit entries HMAC values by
default (F1/F2); `log_raw=true` changes it per device only (F3); disable +
re-enable changes the salt (F4). The operability surprise is F5.

## Exact commands and rc

Run 1 — **default** `bao server -dev -dev-listen-address=127.0.0.1:48509`
(in-memory, random token; receipt `run1-commands.tsv`, refusal text
`run1-enable-default.refusal.txt`):

| label | rc | command |
|---|---|---|
| audit-list-before | 2 | `bao audit list` → `No audit devices are enabled.` |
| enable-default | 2 | `bao audit enable file file_path=$W/audit-default.log` → 400 `cannot enable audit device via API; use declarative, config-based audit device management instead` |
| audit-list-default | 2 | `bao audit list -detailed` |
| kv-put-v1 / kv-put-v2 / kv-get-v1 | 0 | `printf %s NONCE \| bao kv put -mount=secret probe value=-` / `bao kv get -mount=secret probe` (unaudited: no device could be enabled) |
| enable-file2-raw | 2 | `bao audit enable -path=file2 file log_raw=true file_path=$W/audit-raw.log` → same 400 |
| audit-disable-file | 0 | `bao audit disable file/` → `Success! Disabled audit device (if it was enabled) at: file/` |
| reenable-file | 2 | `bao audit enable file file_path=$W/audit-after.log` → same 400 |

Run 2 — dev server with config `unsafe_allow_api_audit_creation = true`
(receipts `run2-commands.tsv`, `run2-summary.json`, `run2-list-*.txt`). All
rc 0 except the first list (no device yet, rc 2):
`bao audit enable file file_path=$W2/audit-default.log`;
`printf %s NONCE | bao kv put -mount=secret probe value=-` (×2);
`bao kv get -mount=secret probe`;
`bao audit enable -path=file2 file log_raw=true file_path=$W2/audit-raw.log`;
`printf %s NONCE | bao kv put …`; `bao kv get …`;
`bao audit disable file/`; `bao audit enable file file_path=$W2/audit-after.log`;
`printf %s NONCE | bao kv put …` (×2); `bao kv get …`;
`printf %s NONCE2 | bao kv put …`; `bao audit list -detailed`.

Run 3 — dev server started with config carrying declarative stanzas
(receipts `run3-commands.tsv`, `run3-summary.json`, `run3-list-*.txt`):

```hcl
audit "file" "file"  { options { file_path = "<scratch>/audit-default.log" } }
audit "file" "file2" { options { file_path = "<scratch>/audit-raw.log"; log_raw = "true" } }
```

`bao audit list -detailed` rc 0, rows `file/` (file_path=…) and `file2/`
(file_path=… log_raw=true). Then `kill -HUP $SPID` after deleting the `file`
stanza → `file/` gone, `file2/` remains (rc 0); `kill -HUP $SPID` after
re-adding `file` with a new file_path → `file/` back (rc 0); two `kv put` and
one `kv get` rc 0; `bao audit disable file/` rc 2, 400
`cannot disable configuration-managed audit device` (`run3-disable-declarative.refusal.txt`),
device still listed afterwards.

Run 4 — `/sys/audit-hash` cross-check (receipt `run4-result.json`):
`PUT sys/audit/file` 204, `PUT secret/data/probe` 200,
`POST sys/audit-hash/file {"input": <nonce>}` 200 (`hmac-sha256:`),
logged hex == audit-hash hex `true`; `DELETE sys/audit/file` 204,
`PUT sys/audit/file` 204, `POST sys/audit-hash/file` 200,
logged == audit-hash `true`, before ≠ after, `sha256(nonce) ≠ logged HMAC`
(`hmac_is_not_bare_sha256: true`).

## Shapes and gotchas (for T1–T4 assertions)

- Entry types: only `request` and `response`. `bao audit list` with zero devices
  prints `No audit devices are enabled.` **and exits 2** — do not read rc 2 as
  an error there.
- Every enable writes one initial `sys/audit/test` probe record, and
  enable/disable calls are themselves audited by devices already enabled. The
  first write to a new KV key audits as operation `create`, later writes as
  `update`.
- Response records echo the whole request object: for a KV write,
  `request.data.data.value` appears in both the `request` and the `response`
  record, so "count records containing the value field" double-counts. The
  write response body itself carries only metadata; `response.data.data.value`
  appears on reads.
- Default HMAC coverage observed on paths: `auth.accessor`, `auth.client_token`,
  `request.client_token`, `request.client_token_accessor`,
  `request.data.data.value`, `response.data.data.value`, and option strings
  (`request.data.options.log_raw` is hashed because the CLI sends it as the
  string `"true"`). Non-string JSON scalars pass through unhashed, per docs.
- `log_raw=true` is a full token-disclosure switch: 62 (run 2) / 84 (run 3)
  cleartext client-token occurrences in the raw logs, 0 in the default logs.
  Any trial assertion that only counts the written value understates the
  exposure.
- `log_raw` is per device: with both devices enabled, the value is plaintext
  only in the raw device's log and stays `hmac-sha256:` in the default log.
- `bao audit list -detailed` columns: `Path Type Description Replication
  Options`; options render as `file_path=… log_raw=true` (raw) and
  `file_path=…` (default).
- Salt rotation is authoritative via `/sys/audit-hash`: the computed HMAC
  equals the logged HMAC before and after re-enable, and the two differ.

## Cleanup and no-survivor check

Each run killed its own process group (`setsid` PGID, `kill -TERM -- -PGID`,
then KILL after 5 s); every run printed `SURVIVOR_PID: none` and
`PORT_LISTENERS: 0` for its port (48509, 46413, 59963, 47223). Final check at
the end of the seat: `ss -ltn` shows none of those four ports listening, and
`pgrep -af 'bao server'` shows no process whose command line references this
seat's scratch path. Scratch tree `/fast/scratch/hyaku/kagi-r57/R57Labrat/`
(server output containing the dev token, all four audit logs including the
raw plaintext log) was deleted before yield; none of it was copied into the
lane. Receipts under `R57Labrat.d/` were audited: no `hvs.`/`s.` token values,
no `Root Token:` value, no 40-hex nonce, no 64-hex HMAC, no vault material —
only the four scripts' literal `sed 's/^Root Token: //p'` pattern text.

Wave-level observation, not this seat's process: at final check two foreign
`bao server -dev` processes were live — PID 2340010 on 127.0.0.1:8299
(`-dev-root-token-id=probe-dev-token`) and PID 2421609 on 127.0.0.1:8298 with
`-config=/fast/scratch/hyaku/kagi-r57/R57ScoutSources/probe/dev-audit.hcl`
(`-dev-root-token-id=probe-dev-token2`). They belong to another seat's scratch;
I did not touch them. They do put a token-shaped string on argv (visible in
`ps`), so if a wave-level "no secret on argv" assertion is evaluated, those
processes would fail it.

## Residual risk / bounds

One binary (OpenBao 2.7.2) on one host, dev mode with in-memory storage; no
deployment, cluster, or restart-persistence claim. The salt finding rests on
HMAC inequality plus `/sys/audit-hash` equality; the salt value itself is
never exposed by the API. `log_raw` output was judged by shape and count inside
scratch and never committed. The `unsafe_allow_api_audit_creation` route is an
operator opt-in, not the default posture; the declarative route is the
recommended path and was verified separately, including its SIGHUP add/remove
semantics.

## Receipts (sha256, `.ufo/waves/round-57/w1/R57Labrat.d/`)

```
c7e5515fdd7375e14838c6bc4e72ca3cf70f8f0d294bbd18bec48d2afd6d8ac2  probe.sh
ab89ed120675a8776d328965957e569fe2199de316f7f7d846b732bd99f00d22  probe_analyze.py
bc638688d815f0959a555ad1fb08c69adb8c40567e02a10ff3ac77718e2b51b5  probe2.sh
d3da16edbaf007a7e69d84f66cfe4528488e703bad86cb014f67e93042fece16  probe3.sh
c45a1d42786737d50ca1c233ff518c73cdaf632e869eb11a1c35c00a018e1881  probe4.sh
be0731ae722cd2f106e487f57c1da399e3087ed6ebfcbb6ab7a841f270e1248b  probe4.py
297f654f600ef617e20f2f33e2d459f025fc9366af5c653a08ca436ef5a97fff  run1-commands.tsv
188003151723c385fd4dbb2cb3d13d1e022bab4467e7da849be8f6cbbbe338a3  run1-enable-default.refusal.txt
64ac640f67453671eefaf4f6b4c30e45acd284d8f5a5cc8fa22b0d686f1eccc2  run2-commands.tsv
a1aac364825b9e6b5f91848f16f0cfad39a736b38e780aefb43e26e05c091992  run2-summary.json
b35d71f7bae9977eb478600f68df68051d84c80239e60048725307c842207b6d  run2-list-default.txt
d4ede9b25694f10eb98f85bbc11883bd939e7a65a69e18f3c926deb6819197c9  run2-list-after.txt
949036955d2d388961aed9b6e27447194502a56330e72989f2201173aaf6f50b  run3-commands.tsv
e7cc9e35ea0f5cc61560c24feb8c1bd271424f30c57fd850b6147563ae2987a3  run3-summary.json
31ae2b5b0e766ba298893fe37c7452f74cd9e2f9322e51e8cd41671ea1f05cc3  run3-list-declarative.txt
8422031cb373ce5b560e3642c3e23b6035965287028e774f426ff10fde623482  run3-hup-remove.txt
bb92e826a1a6794e224dd246949d00e8406a71c5b714af450ebbdcf3f5883af2  run3-hup-readd.txt
f39a99c55b97a6483ad4b93faf2667fdbd617f7344bb46904a70d073b61dfc00  run3-disable-declarative.refusal.txt
85e9125e56cfa809a377d8187515660066bc79a089feeeb2b31b8022c6d56e8b  run4-result.json
```
