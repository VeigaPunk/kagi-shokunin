# OpenBao KV v2: check-and-set, soft delete, destroy, max-versions and metadata delete are distinct version operations

source: S110 (https://openbao.org/docs/secrets/kv/kv-v2/, §Usage → §Writing/Reading arbitrary data (the `-cas` paragraph), §Deleting and destroying data, the metadata examples; OpenBao docs Version 2.7.x, opened 2026-11-07)
verified-at: 2026-11-07 (S110 fetched and read as rendered text; the five mechanics below executed against OpenBao 2.7.2)
recheck: on-release — on an OpenBao release, re-open S110 §Deleting and destroying data and the `-cas` paragraph, compare the docs "Version" label to 2.7.x, and re-run `bash corpus/openbao-kv-versions-trial.sh --work <scratch dir>` against the new binary
cites: S024 (named in the body as the Vault KV v2 row this OpenBao entry does not extend; cross-reference; recorded round 55)
Reverify: R21-02
(R21-02 is the sources-census row: it re-verifies the citation chain only — every id on `source:` resolves to a `mined` row of `corpus/SOURCES.md` whose `used-by` lists this entry. It does not re-open the page or run OpenBao; `recheck:` is the content clock, the trial is the behaviour check.)

Scope: OpenBao only, the KV secrets engine version 2 at the dev server's default `secret/`
mount. A Vault fact is never extended to OpenBao or the reverse: the Vault KV v2 API row S024
(`max_versions` as a backend configuration parameter) is a documentation fact about Vault and
is not re-measured here.

## Why it matters for secrets operations

A KV v2 key is a stack of versions, and the four ways of "removing" a value differ in what can
be recovered: a soft delete hides one version and can be undone; a destroy erases one version's
data for good; a max-versions limit silently drops the oldest version on the next write; a
metadata delete removes every version and the key's history. Rotation runbooks that say "delete
the old secret" must name which one they mean, and a writer that must not overwrite a concurrent
rotation uses check-and-set.

## Measured (round 52 — OpenBao 2.7.2 dev server, 127.0.0.1, KV v2 version lifecycle)

Sourced from S110 (https://openbao.org/docs/secrets/kv/kv-v2/, Version 2.7.x, opened 2026-11-07;
capture `.ufo/waves/round-52/capture/S110.body`, decoded body sha256 `6cfd72ec…7e02b1587`,
83532 B). Every quote below is located with `python3 corpus/rendered-text-v1.py locate
<capture> "<quote>"` → `count=1`.

`bash corpus/openbao-kv-versions-trial.sh --work <scratch dir>` drives the `bao` CLI against a
throwaway `bao server -dev` (in-memory storage, started under `setpriv --pdeathsig KILL`, output
discarded). No secret is put on a command line: the random root token reaches the server through
`BAO_DEV_ROOT_TOKEN_ID` and the client through `BAO_TOKEN`, and each value is written as `v=-`
from stdin. Values are random `r52-` nonces; none is printed. A refusal counts only when the exit
status is non-zero AND the server's refusal text is on stderr; an answer that does not parse is
`ERROR`. Each test prints `TRIAL T<n> HOLDS|BROKEN|ERROR <detail>`; the run ends
`OPENBAO_KV_TRIAL: HOLDS|BROKEN|ERROR holds=<n> broken=<n> error=<n> bao=<version>` and exits 0
(all HOLDS), 1 (any BROKEN) or 2 (setup failure or any ERROR).

- T1 check-and-set (OpenBao 2.7.2): on an existing key, `kv put -cas=0` is refused with
  `check-and-set parameter did not match the current version`; `-cas=1` (the current version) is
  accepted; repeating `-cas=1` (now stale) is refused with the same text; the key holds the value
  of the accepted write — measures S110, “In order for a write to be successful, cas must be set
  to the current version of the secret.”
- T2 soft delete (OpenBao 2.7.2): after `kv delete` the latest version reads `data: null` with a
  `deletion_time` set and `destroyed: false`; `kv undelete -versions=1` restores the value —
  measures S110 §Deleting and destroying data, “When deleting data the standard bao kv delete
  command will perform a soft delete.”
- T3 destroy (OpenBao 2.7.2): after `kv destroy -versions=1` and a following
  `kv undelete -versions=1`, the version reads `data: null`, `destroyed: true`, no
  `deletion_time` — measures S110, “A version's data is permanently deleted only when the key has
  more versions than are allowed by the max-versions setting” (the same sentence continues with
  `bao kv destroy`). The trial does not assert the undelete's exit status (here and in T5); on
  2.7.2 it was read by hand as rc 0 with empty stderr (R52ReviewerTrial D2, routed).
- T4 max-versions (OpenBao 2.7.2): with `kv metadata put -max-versions=2`, writing a third version
  drops version 1 (`kv get -version=1` refused, `No value found at`), while versions 2 and 3 read
  back their values — measures the same S110 sentence as T3, its max-versions half.
- T5 metadata delete (OpenBao 2.7.2): after `kv metadata delete`, versions 1 and 2 are refused
  (`No value found at`) even after an `kv undelete -versions=1,2`, and `kv metadata get` is refused
  — measures S110, “Permanently delete all metadata and versions for a key”.

Bounds (named ceilings):

- One OpenBao version (2.7.2), the dev server's in-memory storage, the KV v2 `secret/` mount with
  no `cas_required` and no `delete_version_after`; a production storage backend, replication or a
  mount-level `max_versions` is not exercised.
- T3 and T4 show that the data is no longer served; they do not show that the storage backend has
  erased the bytes.
- A trial that detects its designated client-side shims (plans/round-52-c1.sh SH1..SH5) excludes
  those five lying CLIs; it does not establish that no other implementation could satisfy these
  sentences for a different reason. The round-52 counter checks printed verdicts, not execution:
  R52CriticC1 built trials that fingerprint the shims by junk calls, or by the creation order of
  the run dirs, and print the expected vectors (F2, F5b) or run only T1 (F6), and scored 5. The
  committed trial is the reference body (kill rule), and its real runs make 31 `bao` calls each,
  including every mechanic's subcommand (`.ufo/waves/round-52/final/c1-execution-evidence.txt`).
- Routed trial defects (R52ReviewerTrial, not fixed: the trial's non-comment lines are frozen this
  round): a JSON answer of the wrong shape makes T4/T5 read BROKEN instead of ERROR (D1); the
  start retry waits on a wedged server without a bound (D3); a SIGKILL leaves the trial's scratch
  dir, which holds no secret (D4).
