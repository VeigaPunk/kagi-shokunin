# OpenBao audit devices: the API enable path needs a config flag, the default device HMACs with a per-instance salt, and log_raw discloses the client token in cleartext

source: S115 (https://openbao.org/docs/audit/, §Enabling and disabling audit devices, the options table, §Blocked audit devices; OpenBao docs Version 2.7.x, opened 2026-11-07); S116 (https://openbao.org/docs/commands/audit/, §Examples and the disable warning; Version 2.7.x, opened 2026-11-07)
verified-at: 2026-11-07 (both pages fetched as decoded bodies and read as rendered text; the five behaviours below executed against OpenBao 2.7.2 and independently probed by a second seat)
recheck: on-release — on an OpenBao release, re-open S115 §Enabling and disabling audit devices and the options table, compare the docs Version label to 2.7.x, and re-run `bash corpus/openbao-audit-trial.sh --work <scratch dir>` against the new binary
Reverify: R21-02
(R21-02 is the sources-census row: it re-verifies the citation chain only — every id on `source:` resolves to a `mined` row of `corpus/SOURCES.md` whose `used-by` lists this entry. It does not re-open the page or run OpenBao; `recheck:` is the content clock, the trial is the behaviour check.)

Scope: OpenBao 2.7.2 only, the `file` audit device, a throwaway dev server with in-memory
storage. The Vault audit pages are not used as evidence for OpenBao behaviour and the reverse
does not follow. The trial never touches a deployed audit pipeline, a real log sink or a real
token; it measures the binary's own defaults.

## Why it matters for secrets operations

An audit device is the record of who read which secret. Its two settings decide how much that
record exposes: by default most request/response strings are HMACed with a per-device salt, so
the log is correlatable but not readable; `log_raw=true` turns the same record into plaintext,
including the client token itself. The salt is created per device instance, so a disable and
re-enable breaks every previously recorded HMAC value — an operator cannot compare an old log
line to a new one after the device is recreated. And since OpenBao 2.3.2 the API enable path is
gated behind `unsafe_allow_api_audit_creation`, so the documented `bao audit enable` example
fails on a default server: an audit plan that assumes the CLI example works has no audit device
at all, which is the worst outcome (silent non-auditing).

## Measured (round 57 — OpenBao 2.7.2 dev servers, 127.0.0.1, file audit devices)

Sourced from S115/S116 (Version 2.7.x, opened 2026-11-07; captures
`.ufo/waves/round-57/capture/S115.body` sha256 `76339ff7…0d79090c6`, 41787 B and
`S116.body` sha256 `3dc88732…0d9905ce`, 33338 B). `bash corpus/openbao-audit-trial.sh
--work <scratch dir>` drives the `bao` CLI on PATH against throwaway `bao server -dev`
instances (in-memory storage, `setpriv --pdeathsig KILL`, output discarded). No token or value
is on any argv: the random root token reaches the server through `BAO_DEV_ROOT_TOKEN_ID` and the
client through `BAO_TOKEN`, values are written as `v=-` from stdin, and values are random `r57-`
nonces that are never printed. Each test prints `TRIAL T<n> HOLDS|BROKEN|ERROR <detail>`; the run
ends `OPENBAO_AUDIT_TRIAL: HOLDS|BROKEN|ERROR holds=<n> broken=<n> error=<n> bao=<version>`
(exit 0/1/2). A second seat (R57Labrat) re-measured the same mechanics independently on this
host with a curl-level probe.

| # | Documented behaviour | Measured on 2.7.2 (round 57) | Where the docs stand |
|---|---|---|---|
| T1 | "Audit devices must be enabled by a root user using `bao audit enable` or using the audit stanza." (S115) | On a default `bao server -dev`, `bao audit enable file file_path=<scratch>` exits 2 with `cannot enable audit device via API; use declarative, config-based audit device management instead`. With `unsafe_allow_api_audit_creation = true` in the server config the same command exits 0 and `bao audit list` shows `file/`; a second `-path=file2 ... log_raw=true` device is also accepted. | The CLI example (S116 §Examples) and the S115 enable sentence do not name the config flag; the API path is not available by default. |
| T2 | "Most strings contained within requests and responses are hashed with a salt using HMAC-SHA256." (S115) | `bao write -format=json sys/audit-hash/file input=<nonce>` returns `hmac-sha256:<64 hex>`; the same input returns the same hash, a different input a different one; the KV write's audit record carries that same hash at least twice (request and response echo) and the nonce plaintext zero times; `sha256(<nonce>)` does not equal the logged hash, so it is a salted HMAC and not a bare digest. | Consistent. |
| T3 | "log_raw (bool: false) - If enabled, logs the security sensitive information without hashing, in the raw format." (S115) | The `log_raw=true` device's log contains the value in plaintext (7 occurrences for one write/read pair across the run) and the client token in cleartext (17 occurrences); the default device's log contains neither (0 and 0). | Consistent, and narrower than the practical fact: the cleartext token is not just "information", it is the credential itself. |
| T4 | "even if you re-enable the audit device at the same path, as a new salt will be created for hashing." (S116) | With API creation enabled, `bao audit disable file/` exits 0, the re-enable exits 0, and `sys/audit-hash/file` of the same input returns a different HMAC after the cycle. A config-managed device is a different case: `bao audit disable file/` on route (B) exits 2 with `cannot disable configuration-managed audit device`; the labrat measured the same salt rotation via config removal plus SIGHUP. | Consistent for the API path; the config-managed path has no API disable. |
| T5 | Non-audited paths list: `sys/init sys/seal-status sys/seal sys/unseal sys/leader sys/health sys/storage/raft/bootstrap sys/storage/raft/join` (S115) | `bao status` (sys/seal-status) adds no audit entry (`"path":"sys/seal-status"` count 0) while a KV read in the same window adds entries (`"path":"secret/data/t5"` count 4) and the log grows. | Consistent. |

Provenance of the measured bytes: the trial was measured at
`corpus/openbao-audit-trial.sh` sha256 `7e64519466bfd7baf51f66d4bc71da09f30845d41d0fb10f36fcf24eec5b0bd3`
(10922 B); the earlier `3e8bcc4c3993980ca41f7781f2fb8f2b8ca19b9a4257b08b70ac79d8e61487fb` run (10674 B) carried the
same verdicts but placed the audit-hash input and the token-pattern on `grep`/`bao` argv, which this entry's
"no value on any argv" sentence would have made false; the fix moves both to stdin and the verdicts were
re-measured (`TRIAL T1..T5 HOLDS`, `OPENBAO_AUDIT_TRIAL: HOLDS holds=5 broken=0 error=0 bao=v2.7.2`).

Operational notes measured beside the tests (same runs): `bao audit list` with no device prints
`No audit devices are enabled.` and exits 2 (rc 2 is not an error here); every successful enable
writes one `sys/audit/test` probe record; a write's audit record is echoed under both
`type=request` and `type=response`, so a naive count of a value's hash double-counts; the first
write to a new key audits as operation `create`, later writes as `update`.

## Does not establish

- One binary (OpenBao 2.7.2, `9e0a0d3c…`), one host, dev-server in-memory storage: nothing here
  is a deployment, a durable audit sink, an audit-device failure/blocking behaviour, or a policy
  about who may read the log.
- The T4 salt claim is measured as disable + re-enable on the API path and, independently, as a
  config-removal + SIGHUP cycle; the file contents of the two logs are not compared line by line.
- T3's token count is a count of the client token string in the raw file; it does not measure
  how long the token remained valid or who could read the file (mode `0600`, scratch only).
- The docs page's Version label is 2.7.x; a later release can change either side.

## Falsifiers

- A default `bao server -dev` accepting `bao audit enable` without the config flag.
- An audit-hash output that is not `hmac-sha256:` prefixed, or equal to `sha256(input)`.
- A `log_raw=true` device whose log does not contain the value in plaintext.
- A re-enable at the same path that keeps the previous HMAC for the same input.
- An entry for `sys/seal-status` in a default (non-`log_raw`) audit log.
