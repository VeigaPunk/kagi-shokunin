source: S125 — https://openbao.org/docs/concepts/seal/ (§Why?, §Shamir seals, §Unsealing, §Sealing, §Auto unseal, §Recovery key, §Rotation, §Seal migration, §Migration steps; OpenBao docs Version 2.7.x, opened 2026-11-07); S126 — https://openbao.org/docs/commands/operator/rekey/ (the deprecation note, §Usage, §Output options, §Command options, §Backup options; Version 2.7.x, opened 2026-11-07); S127 — https://openbao.org/docs/commands/operator/generate-root/ (the v2.6.0 endpoint note, §Usage, §Output options, §Command options; Version 2.7.x, opened 2026-11-07); the round-61 trial `corpus/openbao-seal-trial.sh`, whose receipts under `.ufo/waves/round-61/build/R61ExecTrial/` are the only behavioural evidence in §Mechanics
verified-at: 2026-11-07 (all three pages fetched as decoded bodies and read as rendered text; every quoted page sentence below is located by `python3 corpus/rendered-text-v1.py locate <capture> QUOTE` against the round-61 capture, with the locate count stated; the five T-mechanics were executed against OpenBao 2.7.2 by `corpus/openbao-seal-trial.sh` in two byte-identical runs (`receipt-real-1.txt`, `receipt-real-2.txt`), whose receipt lines — not the frozen plan — are the only behavioural evidence in §Mechanics; the rekey mechanism and the `rotate-keys` rotation are the round-61 Revenger's, read-only on a copy of the binary at sha256 `9c5f36287c673f386e1533e9c044169a248e4ee50dd54810fa766e95bd41b788`, receipt `.ufo/waves/round-61/build/R61Revenger/rekey.md`)
recheck: 180d — on the next cadence re-open S125 §Shamir seals/§Unsealing/§Sealing/§Auto unseal, S126 §Usage and S127 §Usage, compare the docs `Version` label to 2.7.x, and re-run `bash corpus/openbao-seal-trial.sh --work <scratch dir>` against the then-current binary (the lane has no bound on-release clock for these pages; S090 is a 90d feed row)
Reverify: R21-02
cites: S090 (named in the recheck line as the lane's 90d release-feed row for the OpenBao server release identity; cross-reference, not this entry's support; recorded round 63)
(R21-02 is the sources-census row: it re-verifies the citation chain only — every id on `source:` resolves to a `mined` row of `corpus/SOURCES.md` whose `used-by` lists this entry. It does not re-open the page or run OpenBao; `recheck:` is the content clock, the executed trial named there is the behaviour check.)

# OpenBao seal/unseal: the Shamir shares are operator-held, the threshold is stateful, and the sealed state answers 503 while seal-status stays readable

Scope: OpenBao 2.7.2 (the binary on this host) against the OpenBao documentation labelled
Version 2.7.x, one throwaway server at a time bound to 127.0.0.1, the default Shamir seal,
and the five operations the round's frozen plan names (init, unseal, seal, generate-root,
rekey). A Vault fact is never extended to OpenBao or the reverse; a 2.7.2 fact is never
extended to another release. This entry is written in two voices and keeps them apart: the
documented mechanics are the pages' sentences, each with a located quote, while §Mechanics
is only what a receipt line from the round-61 run shows. Where a page sentence has no
receipt behind it, the entry says `documented, not measured` and the claim does not become
behavioural.

## Why it matters for secrets operations

The seal is the root of every other custody property the lane holds. The chain is stated in
one sentence and it is a chain of *different* keys: "most OpenBao data is encrypted using the
encryption key in the keyring; the keyring is encrypted by the root key; and the root key is
encrypted by the unseal key" (count=1). Everything a secrets operator protects — tokens,
leases, KV versions, transit keys, audit salts — sits behind the root key, and the root key
is behind the unseal key. So the question of who can read this vault reduces to who holds
the unseal key, and the Shamir seal is the mechanism that turns one key into `n` shares any
`t` of which reconstruct it.

That reduction is what makes the seal a *custody* subject rather than a crypto subject. The
server stores the root key — but only encrypted: "The root key is stored alongside all other
OpenBao data, but is encrypted by yet another mechanism: the unseal key" (count=1). The
unseal key itself is not a stored object; it exists as shares handed to operators at
initialization. The page's own framing is distribution, not storage: "Instead of
distributing the unseal key as a single key to an operator" (count=1) the key is split, and
"each share of the root key" can be kept "on a distinct client machine for better security"
(count=1). The operational consequence is blunt: lose `n-t+1` shares and the data is gone;
lose `t` shares to one party and that party can unseal. The server cannot help in either
direction, because it never holds the reconstruction material.

The second reason is the asymmetry between the two directions. Sealing is cheap — "Sealing
only requires a single operator with root privileges" (count=1) and "This will throw away the
root key in memory and require another unseal process to restore it" (count=1). Unsealing is
expensive — it needs `t` distinct share holders, and the page calls that out as an
operational burden: "unsealing it using Shamir is a very manual process" (count=1). An
attacker who steals a root token can therefore deny service by sealing, but cannot read data;
an attacker who collects `t` shares can unseal but does not need a token at all. The two
compromise classes are different, and a runbook that treats a root token and a set of unseal
shares as one credential has merged them wrongly.

The third reason is that the threshold is not a static check. The shares are presented one at
a time, the progress is held by the server, and — as §Mechanics measures — a repeated share
does not count twice. That is what makes "3 of 5" a statement about three distinct holders
rather than three submissions.

## Documented mechanics (S125/S126/S127, Version 2.7.x, opened 2026-11-07)

Captures: `.ufo/waves/round-61/capture/S125.body`, decoded body sha256
`643c78c956d8c2106f8cbbab3ffcefff43e4f90a0f06faeaad666a613063ff65` (44279 B),
rendered-text-v1 sha256 `5c66447172e1ad55071ed691adfeef15101f27c3f1e3c17c9fb70b5a8abbcbd4`
(12406 B); `.ufo/waves/round-61/capture/S126.body`, sha256
`53a4574a942e4da8ac8f763af66fe07f33941f98a9ec815eda16d34329c0630a` (44328 B),
rendered-text-v1 sha256 `c107fdfc674283db598deb0d771a867c5a3ff736b91b937c582e01246422f530`
(5427 B); `.ufo/waves/round-61/capture/S127.body`, sha256
`4adb6eb414a8119225e2b3936b99ffb395966cea347f2964f43cedfbe26459aa` (38368 B),
rendered-text-v1 sha256 `106d2259869582dee5bb820786210539dbcd51d3865d0e95222905e4ddda5f80`
(4474 B). All three pages carry the label `Version 2.7.x`. The captures were produced by the
round-61 scout; the fetch command and user agent are not recorded in any receipt this seat
read, so the capture's own provenance is the scout's word plus the bytes. This seat's
independent fetch, with a desktop browser user agent, produced byte-identical bodies (`cmp`
against each capture, HTTP/2 200, no `set-cookie:`/`cookie:` header line present in any of
this seat's responses). The normalizer is the one declared in
`corpus/rendered-text-v1.py`; it replaces every HTML tag with a space, so a quote that spans
an inline `<code>` element shows that space (that is why `sys/init .` and `-init .` carry the
spacing they do below). Each quote below was located against the capture named here and
locates `count=1` unless stated otherwise.

| # | mechanic | documented rule (anchor, located quote) | what the round-61 trial asserts (frozen in `plans/round-61.md` §C2) |
|---|---|---|---|
| T1 | init splits the unseal key into shares and returns them once | S125 §Shamir seals: "The default OpenBao config uses a Shamir seal." (count=1); "OpenBao uses an algorithm known as Shamir's Secret Sharing to split the key into shares." (count=1); "A certain threshold of shares is required to reconstruct the unseal key, which is then used to decrypt the root key." (count=1) | `operator init -key-shares=5 -key-threshold=3` returns 5 shares and threshold 3; `sys/seal-status` reads `initialized=true sealed=true t=3 n=5`; and no file under the storage path contains any of the five base64 shares (custody: shares are held by operators, never by the server). |
| T2 | unseal is stateful, ordered-free, and counts distinct shares | S125 §Shamir seals: "the shares are added one at a time (in any order) until enough shares are present to reconstruct the key and decrypt the root key" (count=1); §Unsealing: "This process is stateful: each key can be entered via multiple mechanisms from multiple client machines and it will work." (count=1) | One share ⇒ `progress 1/3`, `sealed=true`; the SAME share again ⇒ progress stays `1/3`; a second distinct share ⇒ `2/3`; a third ⇒ `sealed=false`, `t=3 n=5`. |
| T3 | seal discards the in-memory root key; the sealed server refuses work but answers status | S125 §Sealing: "There is also an API to seal the OpenBao. This will throw away the root key in memory and require another unseal process to restore it." (count=1); "Sealing only requires a single operator with root privileges." (count=1); "It can't be accessed again without access to the root key shares." (count=1); §Why?: "The only possible operations are to unseal the OpenBao and check the status of the seal." (count=1) | With the root token, `operator seal` ⇒ `sealed=true`; an authenticated request while sealed ⇒ HTTP 503; `sys/seal-status` without a token ⇒ HTTP 200. |
| T4 | generate-root turns a quorum of shares into a fresh root token, and the OTP is the second factor | S127 §Usage: "The operator generate-root command generates a new root token by combining a quorum of share holders." (count=1); "A base64-encoded one-time-password (OTP) provided via the -otp flag." (count=1); "The resulting token is XORed with this value when it is returned." (count=1); "Use the -decode flag to output the final value." (count=1); §Command options: "Decode and output the generated root token. This option requires the -otp flag be set to the OTP used during initialization." (count=1); S125 §Auto unseal: "When using a Shamir seal the unseal keys must be provided to authorize these operations." (count=1) | `operator generate-root -init` yields a nonce, an OTP and `required=3`; three shares progress 1, 2, 3 to `complete=true` with an encoded token; `-decode` with the OTP yields a 26-character token that authenticates (HTTP 200 on `sys/seal-status`); `-decode` with a wrong OTP does not yield that token. |
| T5 | `operator rekey` is documented, and this build refuses it | S126 the deprecation note: "Note: operator rekey command is deprecated, please use rotate-keys instead." (count=1); §Usage: "The operator rekey command generates a new set of unseal keys." (count=1); "This operation is zero downtime, but it requires the OpenBao is unsealed and a quorum of existing unseal keys are provided." (count=1); §Command options: "Number of key shares to split the generated master key into." (count=1) and "Number of key shares required to reconstruct the root key." (count=1) | `operator rekey -init -key-shares=3 -key-threshold=2` exits non-zero with HTTP 405 `unsupported operation` on both the raft server and an `inmem` server, while S126 documents the command — a measured docs-vs-binary divergence, not a citation. |

### The chain the seal protects

The page's recap is the whole model in one sentence: "most OpenBao data is encrypted using
the encryption key in the keyring; the keyring is encrypted by the root key; and the root key
is encrypted by the unseal key" (count=1). Two consequences follow that a custody review has
to state. First, the *barrier* key and the *unseal* key are different keys with different
lifecycles. The page's §Rotation describes the auto-unseal case only: the unseal key "can be
rotated using a normal bao operator rotate-keys operation from the CLI or the matching API
calls" (count=1), "The rotation is authorized by meeting the threshold of recovery keys"
(count=1), and "the new barrier key is wrapped by the HSM or KMS and stored like the previous
key; it is not returned to the users that submitted their recovery keys" (count=1). The
Shamir equivalent is not described on this page, and the inference that a Shamir rotation
re-wraps the root key rather than re-encrypting data is stated here as an inference, not as a
documented fact or a measured one. Second, a backup of the storage directory is not a backup
of the vault: it carries the encrypted root key and cannot be opened without the shares. That
is why the shares are the only thing that must survive a disaster, and why they must not be
stored next to the data they unlock.

The page also fixes what "sealed" means operationally: "In this state, OpenBao is configured
to know where and how to access the physical storage, but doesn't know how to decrypt any of
it" (count=1). The server can find its data and cannot read it. That is the state a stolen
disk yields, and it is the state the trial's T3 puts a live server into on purpose.

### Shamir is the default, and the shares are the custody unit

"The default OpenBao config uses a Shamir seal" (count=1), and the split is described as a
distribution decision: "Instead of distributing the unseal key as a single key to an
operator" (count=1) the key is split, with "A certain threshold of shares" required "to
reconstruct the unseal key, which is then used to decrypt the root key" (count=1). The page's
security argument for the split is placement: "This allows each share of the root key to be
on a distinct client machine for better security" (count=1).

What the page does *not* say is that the shares are never written by the server. Its
statements are about the root key's storage ("The root key is stored alongside all other
OpenBao data, but is encrypted by yet another mechanism: the unseal key", count=1) and about
distribution to operators; the words `persisted`, `not stored`, `never stored` and
`duplicate` each locate `count=0` on all three captures. The non-persistence of the shares is
therefore a *measured* property in this entry (T1's storage sweep), not a documented
prohibition — and §Bounds states exactly how far that sweep reaches.

### Unsealing is stateful and per-node

The unseal process is "stateful: each key can be entered via multiple mechanisms from
multiple client machines and it will work" (count=1), and shares are "added one at a time
(in any order) until enough shares are present" (count=1). Two operational facts follow that
are easy to miss in a runbook. First, the progress belongs to the server, not the client: a
share submitted from one machine advances the same counter a share submitted from another
machine would advance. Second, the threshold is per node, not per cluster: "when using the
Shamir seal with multiple nodes, each node must be unsealed with the required threshold of
shares. Partial unsealing of each node is not distributed across the cluster" (count=1). A
three-node cluster with `t=3` therefore needs nine share submissions, not three, and the
shares must be presented to each node.

The page never says what happens when the same share is submitted twice. `duplicate`,
`already` and `same share` each locate `count=0`; the closest sentence is the "in any order"
one, which says nothing about repetition. That is the gap T2 fills, and the answer matters:
if a repeated share advanced the counter, a single holder could satisfy a `3-of-5` threshold
alone by submitting one share three times, and the threshold would be a submission count
rather than a holder count.

### Sealing is the cheap direction

"There is also an API to seal the OpenBao. This will throw away the root key in memory and
require another unseal process to restore it" (count=1). The page is explicit about the
asymmetry: "Sealing only requires a single operator with root privileges" (count=1), and the
motive is incident response — "if there is a detected intrusion, the OpenBao data can be
locked quickly to try to minimize damages" (count=1). After sealing, "It can't be accessed
again without access to the root key shares" (count=1).

The page also enumerates the three ways a node leaves the unsealed state: "It is resealed via
the API (see below)." / "The server is restarted." / "OpenBao's storage layer encounters an
unrecoverable error." (each count=1). A restart resealing the node is the fact that makes
"unsealed" a runtime property rather than a persisted one, and it is why an unattended
restart of a Shamir-sealed server is an outage until a quorum arrives.

What the page does not give is the *observable* of a request made while sealed. It says
"almost no operations are possible" and that the two that remain are unsealing and checking
the seal's status (count=1 each), but `503` and `service unavailable` each locate `count=0`,
and the endpoint name `seal-status` locates `count=0`. T3 measures both: the authenticated
request gets HTTP 503, and `sys/seal-status` answers without a token.

### Auto Unseal moves the custody, it does not remove it

"Auto Unseal was developed to aid in reducing the operational complexity of keeping the
unseal key secure" and "delegates the responsibility of securing the unseal key from users to
a trusted device or service" (count=1 each). At startup the server "will connect to the
device or service implementing the seal and ask it to decrypt the root key OpenBao read from
storage" (count=1). The custody does not disappear; it moves to the KMS/HSM and to the
credentials that can call it. The page states the dependency in the strongest terms: if the
seal mechanism "becomes unavailable, or deleted before the seal is migrated, then there is no
ability to recover access to the OpenBao cluster until the mechanism is available again", and
if its keys are permanently deleted "the OpenBao cluster cannot be recovered, even from
backups" (count=1 each).

The threshold survives the move in a different object. "There are certain operations in
OpenBao besides unsealing that require a quorum of users to perform, e.g. generating a root
token. When using a Shamir seal the unseal keys must be provided to authorize these
operations. When using Auto Unseal these operations require recovery keys instead" (count=1
each). So the quorum is not a Shamir artefact; it is a property of privileged operations, and
the share type changes with the seal type.

### Recovery keys are authorization, not decryption

The page's warning is unambiguous: "Recovery keys cannot decrypt the root key, and thus are
not sufficient to unseal OpenBao if the Auto Unseal mechanism isn't working. They are purely
an authorization mechanism" (count=1 each). "Just as the initialization process with a Shamir
seal yields unseal keys, initializing with an Auto Unseal yields recovery keys" (count=1),
and recovery-key generation "can be delayed until after initialization by setting
recovery_shares=0 on the call to sys/init ." (count=1). S125 §Initialization documents the
three flags (`recovery-shares`, `recovery-threshold`, `recovery-pgp-keys`) and one
guard: "Additionally, OpenBao will refuse to initialize if the option has not been set to
generate a key, and no key is found" (count=1) — so the recovery-key split is a decision taken
at init or not at all, and a misconfigured seal fails initialization rather than starting
without a recovery path. The operational reading: under Auto
Unseal the shares an operator holds cannot unseal anything; they can only authorize
operations on a server the KMS has already unsealed. A runbook that treats recovery keys as
break-glass unseal material has the wrong key class.

### Seal migration is the one operation that cannot be done without downtime

"The Seal migration process cannot be performed without downtime" (count=1), and the page's
own migration steps require both seals to be available during the migration and a backup
first. The direction matters for custody: migrating from Shamir to Auto Unseal converts the
Shamir shares into recovery keys, and migrating the other way converts recovery keys into
Shamir unseal keys (S125 §Migration steps). This entry does not measure any of it; it is
`documented, not measured` and named in §Bounds.

## Mechanics (measured, round 61 — OpenBao 2.7.2, 127.0.0.1, raft and inmem)

Executed by `corpus/openbao-seal-trial.sh` (round 61): throwaway `bao server` processes bound
to 127.0.0.1 under `setpriv --pdeathsig KILL`, `tls_disable = 1`, storage in scratch
(`storage "raft"` for the main run, `storage "inmem"` for the T5 second leg), and `bao`
resolved through PATH only. No real vault, account or secret is touched; every share, OTP and
generated token is created inside the run and dies with the scratch directory. Receipts:
`.ufo/waves/round-61/build/R61ExecTrial/receipt-real-1.txt` and `receipt-real-2.txt` (two
independent runs, byte-identical, sha256
`421689decca5043a369988922e0e8bd6d4a45c16edf3222b13c02d5952f44c56`), the five shim runs
`receipt-shim-SH1.txt`–`receipt-shim-SH5.txt`, the fail-closed leg `receipt-nobao.txt`, and
the fixture-driven `receipt-selftest.txt` / `receipt-selftest-mutant.txt`.

The trial prints one `TRIAL T<n> HOLDS|BROKEN|ERROR <detail>` line per test and one
`OPENBAO_SEAL_TRIAL: HOLDS|BROKEN|ERROR holds=<n> broken=<n> error=<n> bao=<ver>` summary
line, and exits 0 only when all five hold.

| # | mechanic | measured on 2.7.2 | receipt line |
|---|---|---|---|
| T1 | init share/threshold arithmetic and non-persistence | `operator init -key-shares=5 -key-threshold=3` returned exactly five distinct 43-character base64 shares (`shares=1`); `sys/seal-status` read `initialized=true sealed=true t=3 n=5` (`status=1`); a `grep -rlF` sweep of the raft storage path for the five share strings found no file (`nopersist=1`) | `TRIAL T1 HOLDS shares=1 status=1 nopersist=1` |
| T2 | unseal threshold and duplicate-share refusal | one share ⇒ `progress=1/3` with `sealed=true`; the **same** share again ⇒ the progress stays `1/3` (`same-share-again=progress=1/3`); a second distinct share ⇒ `progress=2/3`; a third ⇒ `sealed=false t=3 n=5` | `TRIAL T2 HOLDS progress=1/3 same-share-again=progress=1/3 progress=2/3 sealed=false t=3 n=5` |
| T3 | seal and the sealed-state request | `operator seal` ⇒ `sealed=true` (`seal=1`); `GET /v1/sys/mounts` with the root token while sealed ⇒ HTTP 503 (`auth503=1`); `GET /v1/sys/seal-status` without a token ⇒ HTTP 200 (`status200=1`) | `TRIAL T3 HOLDS seal=1 auth503=1 status200=1` |
| T4 | generate-root with OTP decode | `operator generate-root -init` returned a nonce, a 26-character OTP and `required=3` (`req3=1`); three shares submitted with the nonce progressed 1, 2, 3 to `complete=true` with an encoded token (`prog=1`); `-decode` with the OTP yielded a 26-character token (`tlen=26`) that answered 200 on `/v1/auth/token/lookup-self` (`ls=200`, auth-required) and 200 on `sys/seal-status` (`ss=200`); `-decode` with a wrong OTP yielded a 26-character string (`wl=26`) that `/v1/auth/token/lookup-self` refused (`wls=403` in this run; the trial records the code rather than asserting it, and `wdrc=0` is the CLI's exit status for the wrong decode) | `TRIAL T4 HOLDS req3=1 prog=1 dec=1 wrong=1 tlen=26 ls=200 ss=200 wl=26 wls=403 wdrc=0` |
| T5 | rekey refused on this build (docs vs binary) | `operator rekey -init -key-shares=3 -key-threshold=2` failed with HTTP 405 `unsupported operation` on **both** the raft server (`raft405=1`) and the inmem server (`mem405=1`) | `TRIAL T5 HOLDS raft405=1 mem405=1` |

Both runs end `OPENBAO_SEAL_TRIAL: HOLDS holds=5 broken=0 error=0 bao=v2.7.2` and exit 0, and
the two receipt files are byte-identical, so every row above is backed twice by the same
bytes. The five `TRIAL` lines appear exactly once each per run.

The five shims each flip exactly their designated test and nothing else; each shim run exits 1
with `holds=4 broken=1 error=0`:

| shim | receipt line that moved | vector |
|---|---|---|
| SH1 | `TRIAL T1 BROKEN shares=0 status=1 nopersist=1` | `BHHHH` |
| SH2 | `TRIAL T2 BROKEN progress=1/3 same-share-again=progress=1/3 progress=2/3 sealed=false t=3 n=5` | `HBHHH` |
| SH3 | `TRIAL T3 BROKEN seal=1 auth503=0 status200=1` | `HHBHH` |
| SH4 | `TRIAL T4 BROKEN req3=1 prog=1 dec=0 wrong=0 tlen=26 ls=200 ss=200 wl=26 wls=400 wdrc=0` | `HHHBH` |
| SH5 | `TRIAL T5 BROKEN raft405=1 mem405=0` | `HHHHB` |

What a shim proves has to be stated precisely, because it is weaker than it looks: the shim is
a `KAGI_SEAL_SHIM` value that makes the trial force its own designated flag to `0`. It
therefore demonstrates that each test's verdict is computed from its own flag and that
flipping one flag changes exactly one test's verdict — a **verdict-mapping** falsifier. It does
not simulate a different binary response, so it cannot by itself distinguish *the binary held*
from *the trial read the binary's answer into the wrong flag*; that distinction rests on the
two real runs and on the Revenger's independent probes, not on the shims.

A PATH with no `bao` prints `OPENBAO_SEAL_TRIAL: SETUP no bao on PATH` and exits 2 with no
`TRIAL` line (`receipt-nobao.txt`), so the trial is not silently scoring a missing binary. The
fixture-driven `--selftest` (no `bao`, no network) prints `SEAL_SELFTEST: PASS (cases=63)` and
exits 0; the mutated copy whose shim resolution is broken prints
`FINDING F-STUB-SH1-VEC` / `FINDING F-SHIM-MATRIX` / `SEAL_SELFTEST: FAIL (cases=63 failed=2)`
and exits 1 (`receipt-selftest-mutant.txt`), so the selftest can fail with a named finding id.

## Docs vs binary (what the pages say and what the run shows)

These rows are the places where a page sentence and the executed run pull apart, or where the
page is narrower than what the trial had to do. The binary side of each row cites a receipt
from `.ufo/waves/round-61/build/R61ExecTrial/` (the trial's own run) or from
`.ufo/waves/round-61/build/R61Revenger/rekey.md` (the round's reverse-engineering of the
rekey refusal, read-only on a copy of the binary whose sha256 is
`9c5f36287c673f386e1533e9c044169a248e4ee50dd54810fa766e95bd41b788`); where neither receipt
carries the fact, the row says `not measured` rather than borrowing a value from the plan.

| # | topic | page says | run shows | reading |
|---|---|---|---|---|
| D1 | whether `operator rekey` works | S126 documents the command in full — §Usage, §Output options, §Command options and §Backup options — with the deprecation note "operator rekey command is deprecated, please use rotate-keys instead." (count=1) | HTTP 405 with body `{"errors":["unsupported operation"]}` on **both** the raft server and the inmem server under the default listener; the CLI exits 2 (`Revenger §1.2, §1.3`) | the page describes a command this build refuses. Deprecation and absence are different states, and the page's note names neither a removal version nor a refusal; an operator following S126 on 2.7.2 gets an error the page does not predict. |
| D2 | what the 405 *is* | S126 says nothing about a refusal; `405` and `unsupported operation` each locate `count=0` on all three captures | a **registration gate, not a removal**: `internal/http/handler.go:181-195` mounts `/v1/sys/rekey/{init,update,verify}` only when the listener sets `disable_unauthed_rekey_endpoints = false` explicitly (absent and `true` both leave them unmounted); unmounted, `rekeyPaths()` in `internal/vault/logical_system_paths.go:753-809` gives those paths no `Callback`, and `sdk/framework/backend.go:239-273` maps a nil callback to `logical.ErrUnsupportedOperation` → HTTP 405 (`Revenger §2.3–§2.5`) | the code is compiled, linked and functional — `go tool nm` shows the handlers and `BarrierRekeyInit`/`RekeyUpdate`/`RekeyVerify`, and no rekey function returns `ErrUnsupportedOperation` (`Revenger §2.1–§2.2`). The default configuration simply does not route the paths. The two backup paths keep their callbacks: `GET /v1/sys/rekey/backup` returns 400 `no backed-up keys found` and `DELETE` returns 204 (`Revenger §1.2`). |
| D3 | the order of the refusal | S126 says nothing; `unauthenticated` locates `count=0` | the same paths are declared in `PathsSpecial.Unauthenticated` (`internal/vault/logical_system.go:108-121`), so an anonymous request and a bogus-token request both get **405, not 403** (`Revenger §1.2, §2.6`) | the 405 is not an auth failure. A client that retries with a token, or a runbook that reads 405 as a token problem, is chasing the wrong cause. |
| D4 | what enabling the flag does | S126 does not mention the flag; `disable_unauthed_rekey_endpoints` locates `count=0` | with `disable_unauthed_rekey_endpoints = false`: anonymous `POST /v1/sys/rekey/init` → 200 + nonce, `GET` → 200, `POST update` → 400 on a bogus key, `DELETE` → 204; completion still needs `threshold` current shares (`Revenger §4, §5`) | enabling the flag exposes **unauthenticated** start/status/update/cancel. It widens the attack surface and should be bounded to a planned rotation on a listener untrusted clients cannot reach. |
| D5 | the supported rotation path | S126's deprecation note points at `rotate-keys` (count=1); S125 §Rotation names `bao operator rotate-keys` (count=1) but describes the auto-unseal case only | `operator rotate-keys` completes a **full** rotation on raft and inmem: `-init -key-shares=3 -key-threshold=2` → rc 0, nonce, `0/3`; three current shares → a new 3-key set; after `operator seal`, old share 1 is accepted as `1/2` and old share 2 is refused 400 `invalid key: failed to decrypt keys from storage: cipher: message authentication failed` (progress reset); new shares 1+2 unseal (`sealed=false t=2 n=3`); the existing root token still answers 200 (`Revenger §4`) | the working path is measured end-to-end. Old shares are refused at **reconstruction**, not at submission — a single submission cannot tell an operator whether a share is still valid. |
| D6 | `-target=recovery` on a shamir server | S126 documents `-target (string: "barrier")` and says "recovery" only applies when HSM support is enabled or using Auto Unseal (count=1) | `operator rekey -init -target=recovery` → 404 `unsupported path` under the default config (`/v1/sys/rekey-recovery-key/init` is not registered); with the flag, 400 `recovery rekeying not supported` on shamir; `rotate-keys -target=recovery` → 400 `recovery keys not supported` (`Revenger §1.3, §4`) | the documented flag has no working route on a shamir server; the page's qualifier is correct and stronger than its wording suggests. |
| D7 | the docs' silence on the whole mechanism | S126's capture has `count=0` for `disable_unauthed_rekey_endpoints`, `405`, `unsupported operation` and `unauthenticated` | the measured 405, the flag experiment and the working `rotate-keys` path (`Revenger §1–§5`) | the gap is wider than deprecation: the documented command hard-fails under the default configuration, the page does not say so, and the page never names the listener flag that would make it work. |
| D8 | the sealed-state HTTP status | S125 says "almost no operations are possible" and that the remaining two are unsealing and checking the seal's status (count=1 each); `503` and `service unavailable` each locate `count=0` | `TRIAL T3 HOLDS seal=1 auth503=1 status200=1`: an authenticated `GET /v1/sys/mounts` while sealed returned 503 (`receipt-real-1.txt`) | the page states the rule and not the observable. A client that treats every non-200 as a dead server will misread a sealed-but-healthy server; the measured status is what a probe should key on. |
| D9 | the seal-status endpoint and its authentication | S125 says "check the status of the seal" (count=1) and never names an endpoint; `seal-status` locates `count=0` on all three captures | `TRIAL T3 HOLDS ... status200=1`: `GET /v1/sys/seal-status` without a token returned 200 (`receipt-real-1.txt`) | the unauthenticated readability of seal status is the operational fact that makes a sealed server distinguishable from a dead one. The page implies it ("The only possible operations are to unseal the OpenBao and check the status of the seal.", count=1) but does not name the path or the auth requirement. |
| D10 | whether a repeated share counts | S125 says shares are "added one at a time (in any order)" (count=1) and never addresses repetition; `duplicate`, `already` and `same share` each locate `count=0` | `TRIAL T2 HOLDS ... same-share-again=progress=1/3 ...`: the same share presented twice leaves the progress at `1/3` (`receipt-real-1.txt`) | if the binary counted a repeated share, `t` would be a submission count and one holder could satisfy the threshold alone. The page's silence is the gap; the measured refusal is the security property. |
| D11 | whether the server persists the shares | S125 says the root key "is stored alongside all other OpenBao data, but is encrypted by yet another mechanism: the unseal key" (count=1); `persisted`, `not stored` and `never stored` each locate `count=0` | `TRIAL T1 HOLDS ... nopersist=1`: a `grep -rlF` sweep of the raft storage path for the five share strings found no file (`receipt-real-1.txt`) | the page's model implies the shares are held by operators, but it never states a non-persistence rule. The measured sweep is the evidence; §Bounds limits it to a substring search over the files present at that moment. |
| D12 | the generated root token's shape | neither page states a length or a prefix for the generated token; `hvs.` locates `count=0` and the only `26` occurrences on all three captures are the copyright year | `TRIAL T4 HOLDS ... tlen=26 ...`: the decoded token is 26 characters and answers 200 on `/v1/auth/token/lookup-self` (`receipt-real-1.txt`) | the token's shape is measured, not documented. An operator validating a decoded token by length has no page to cite. |
| D13 | what the OTP protects | S127: "The resulting token is XORed with this value when it is returned" (count=1) and `-decode` "requires the -otp flag be set to the OTP used during initialization" (count=1) | `TRIAL T4 HOLDS ... dec=1 wrong=1 ... wls=403`: the right OTP yields a token that authenticates; a wrong OTP yields a different 26-character string that `/v1/auth/token/lookup-self` refuses (403 in this run; the trial records the code rather than asserting it) (`receipt-real-1.txt`) | this row is agreement, not divergence: the page's XOR sentence predicts exactly the two-leg test. It is recorded because the *negative* leg (wrong OTP) is what makes the OTP a second factor rather than a formatting step. |
| D14 | the endpoint the CLI uses for generate-root | S127 note: "As of v2.6.0, this command uses the new and authenticated /sys/generate-root-token endpoint instead of the deprecated and unauthenticated /sys/generate-root endpoint." (count=1) | `not measured` — the trial drives the CLI, which chooses the endpoint; the trial does not call either endpoint directly | `documented, not measured`. The page's note is a version boundary a client author must know, but this entry did not observe which endpoint the 2.7.2 CLI hit. |
| D15 | PGP-encrypted shares and the rekey backup options | S126 documents `-pgp-keys`, `-backup`, `-backup-retrieve` and `-backup-delete` (each count=1) | `not measured` — no PGP key and no backup/restore leg in the trial; the Revenger measured only that the backup routes keep callbacks (400 `no backed-up keys found`, 204) | `documented, not measured` for the PGP and backup semantics; the route existence is measured. These are the parts of the rekey surface that only exist with PGP custody. |

### Page gaps the trial had to measure (absence checks, this seat's counts)

The strings below are what a reader would expect to find if the pages documented the
observable. Each locates `count=0` on all three captures except where noted; the counts are
substring counts over the rendered-text-v1 bytes of each capture (the same bytes
`corpus/rendered-text-v1.py` produces), and the exact per-pattern table is
`.ufo/waves/round-61/build/R61ScribeEntry/quote-locations.md` §Absence checks. The last column
names the measured row that fills the gap.

| gap | page does not state | absence check | measured row that fills it |
|---|---|---|---|
| G1 | whether the shares are persisted anywhere under the storage path | `persisted` 0/0/0, `not stored` 0/0/0, `never stored` 0/0/0 | T1 (storage sweep) |
| G2 | whether a repeated share advances the unseal progress | `duplicate` 0/0/0, `already` 0/0/0, `same share` 0/0/0 | T2 |
| G3 | the HTTP status of a request made while sealed | `503` 0/0/0, `service unavailable` 0/0/0 | T3 |
| G4 | the seal-status endpoint path and its auth requirement | `seal-status` 0/0/0 | T3 |
| G5 | the length or prefix of a generated root token | `hvs.` 0/0/0; `token length` 0/0/0 | T4 |
| G6 | the refusal text and status for `operator rekey` on a build without it | `405` 0/0/0, `unsupported operation` 0/0/0 | T5 and `Revenger §1.2` |
| G7 | which endpoint the 2.7.2 CLI uses for generate-root | the page names both endpoints but not which the CLI chooses at 2.7.2 | **no receipt line** — `documented, not measured` (D14) |
| G8 | whether recovery keys can unseal | the page *does* state it ("Recovery keys cannot decrypt the root key", count=1) | not a gap; `documented, not measured` here (no auto-unseal) |
| G9 | the listener flag that routes the rekey endpoints | `disable_unauthed_rekey_endpoints` 0/0/0 | `Revenger §4, §5` (the three-way flag experiment) |
| G10 | that the rekey paths are unauthenticated | `unauthenticated` 0/0/0 | `Revenger §1.2, §2.6` (anonymous and bogus-token requests both read 405) |
| G11 | the supported rotation path and what it does to old shares | the page's only `rotate-keys` mentions are the deprecation note and the auto-unseal §Rotation paragraph (count=2 on S126, count=2 on S125); no sentence says what a completed rotation does to the old shares | `Revenger §4` (old shares refused at reconstruction, new shares unseal, root token survives) |

## Custody: shares are operator-held, the threshold is stateful, the OTP is the second factor

Every sentence below that says a T-row *measures* or *adds* is backed by the receipt named in
§Mechanics (the two real runs are byte-identical). The rekey material (D1–D7) is backed by the
Revenger receipt.

**The shares are the custody unit, and the server does not keep them.** The page's model puts
the root key in storage encrypted by the unseal key, and puts the unseal key in the hands of
operators as Shamir shares (count=1 each sentence). The trial's T1 adds the negative half the
page never states: a sweep of the storage path for the five base64 share strings finds none of
them. Operationally: the storage directory is not a backup of the vault, and the shares are
the only artefact that must survive a disaster while never living beside the data they
unlock. §Bounds limits the sweep to a substring search over the files present at that moment;
it does not prove that no derivative of a share is stored.

**The threshold counts distinct holders, not submissions.** S125's "in any order" sentence
(count=1) describes order, not repetition; the page is silent on duplicates (G2). The trial's
T2 measures the answer: presenting the same share twice leaves the progress at `1/3`. That is
the property that makes `3-of-5` mean three people (or three machines) rather than three
requests from one, and it is the difference between a threshold and a rate limit. A runbook
that says to submit any share three times is wrong on this build, and the page would not have
told the author so.

**The OTP is the second factor in root-token regeneration.** `generate-root` needs a quorum
of shares, so the share holders can always mint a root token among themselves — unless the
result is locked to something they do not all hold. S127's mechanism is that lock: the
generated token "is XORed with this value when it is returned" (count=1), and `-decode`
"requires the -otp flag be set to the OTP used during initialization" (count=1). The encoded
token in the init response is therefore not a usable credential; only the OTP holder can turn
it into one. The custody reading is a separation of duties: the quorum authorizes, the
initiator (who generated and holds the OTP) alone can use the result. A runbook that logs the
encoded token and the OTP together has collapsed the two factors back into one. T4 measures
both legs — the right OTP yields a working token, a wrong OTP does not — and D8 records that
this is the one place a page sentence predicts the measured shape exactly.

**The sealed state refuses work but answers status.** S125 says only unsealing and checking
the seal's status remain possible (count=1) and never names the status code or the endpoint
(G3, G4). T3 measures the pair: an authenticated request while sealed returns HTTP 503, and
`sys/seal-status` answers HTTP 200 without a token. That pair is what lets a monitor tell
"sealed" from "down" — a distinction with real operational value, because the remedy for one
is a quorum of humans and the remedy for the other is a process restart.

**Sealing and unsealing are different privileges.** Sealing needs one root-privileged
operator (count=1); unsealing needs `t` share holders (count=1). A stolen root token can
therefore deny service but cannot read data, and a stolen quorum can read data but does not
need a token. A custody review should keep those two compromise classes separate rather than
collapsing them into one verdict.

**`operator rekey` is documented and refused — by a registration gate, not by missing code.**
S126 describes a command that rotates the unseal shares with zero downtime and a quorum of
existing shares (count=1 each sentence), and the deprecation note points at `rotate-keys`
(count=1). The 2.7.2 binary answers `operator rekey -init` with HTTP 405 `unsupported
operation` on both storage backends, and the round's reverse-engineering shows why: the mux
mounts `/v1/sys/rekey/{init,update,verify}` only when the listener sets
`disable_unauthed_rekey_endpoints = false` explicitly; unmounted, the sys-backend path table
gives those paths no callback and the framework maps the nil callback to
`ErrUnsupportedOperation` (D2). The handlers, `BarrierRekeyInit` and the rest of the rekey
stack are compiled and linked — the command would work if the flag were set. Three custody
consequences follow. First, a share-rotation runbook written from S126 fails at step one on a
default listener, and the page never names the flag (D7). Second, enabling the flag is itself
a custody decision: it exposes **unauthenticated** start/status/update/cancel on those paths
(D4), so it should be bounded to a planned rotation on a listener untrusted clients cannot
reach. Third, the supported path is `rotate-keys`, and it is measured end-to-end: a full
rotation from 5 shares/3 threshold to 3/2, after which the old shares are refused at
reconstruction with a message-authentication failure, the new shares unseal, and the existing
root token still authenticates (D5). Because a single old share is accepted as `1/2` before
the reconstruction fails, an operator cannot test whether a share is still valid with one
submission — the check needs the threshold and the failure.

### Decision table (derived from the documented mechanics; the measured column is §Mechanics)

| situation | observable | action | basis |
|---|---|---|---|
| a node restarted and is not serving | `sys/seal-status` answers with `sealed=true` while ordinary requests are refused | deliver `t` distinct shares to **that node** (`bao operator unseal`); a cluster's other nodes do not unseal it | S125 §Unsealing ("each node must be unsealed with the required threshold of shares"); T3 |
| a monitor sees refusals from an otherwise live server | seal-status readable, requests refused | page the share holders, not the process owner: the remedy is a quorum, not a restart | T3; S125 §Why? |
| one share is suspected compromised | you still hold the other shares and know the threshold | rotate the share set with `bao operator rotate-keys -init -key-shares=N -key-threshold=M` plus `t` current shares; do **not** use `operator rekey` on a default listener (405), and do not leave `disable_unauthed_rekey_endpoints = false` set afterwards | D5 (full rotation measured); D1–D4; S125 §Rotation |
| the root token is suspected compromised | the server is unsealed and you still hold `t` shares | seal the node (one root-privileged operator), then regenerate a root token with `generate-root` and a fresh OTP; revoking the old token is a separate token operation this entry does not measure | S125 §Sealing; S127; §Bounds |
| shares are lost below `t` | `sealed=true` with no path forward | there is no recovery: the root key is stored only encrypted by the unseal key, and a storage backup does not carry the shares | S125 §Why? (the chain); §Bounds |
| a `generate-root` run is in progress | a nonce and an encoded token exist | the encoded token is not a credential; only the OTP holder can decode it, so the OTP must not be logged beside it | S127; T4 |

The table is a synthesis of the page sentences and the measured rows, not a new measurement.
Where a row's action depends on a measured value, the value is the one §Mechanics records.

## Bounds (does not establish)

- **One host, one version pair.** OpenBao 2.7.2 on this host against pages labelled Version
  2.7.x. A later release can change any rule above; the `recheck:` line is the clock that
  would notice. No other OpenBao or Vault version was run, and no Vault behaviour is claimed.
- **Dev-shaped servers only.** Throwaway `bao server` processes bound to 127.0.0.1 with
  `tls_disable = 1`, `storage "raft"` (single node) and `storage "inmem"`, started under
  `setpriv --pdeathsig KILL`. No TLS listener, no mTLS, no client certificates, no listener
  tuning, no namespaces, no HA cluster, no performance replication, no audit device enabled
  during the run.
- **No auto-unseal, no recovery keys, no HSM/KMS.** Every server uses the default Shamir
  seal. The recovery-key path, `recovery_shares=0`, `-target=recovery`, and the whole Auto
  Unseal custody argument are `documented, not measured`.
- **No seal migration.** S125's migration procedure — both seals available, downtime, standby
  order, quorum retention — is documented and not exercised. The entry claims nothing about
  what a migration does to existing shares.
- **No PGP-encrypted shares and no rekey backup/restore.** `-pgp-keys`, `-backup`,
  `-backup-retrieve` and `-backup-delete` are documented and not exercised; the trial's T5
  never gets far enough to use them on this build.
- **The storage sweep is a substring search, not a proof of absence.** T1 greps the files
  present under the storage path at that moment for the five base64 share strings. It does not
  prove that no derivative (a hash, an encrypted blob, a log line) of a share is stored, and
  it does not cover files written after the sweep.
- **One backend pair, one refusal.** The 405 is measured on 2.7.2 with `raft` and `inmem`.
  Another backend or another build may answer differently; the entry does not generalize.
- **The generated root token is not inspected.** T4 asserts that the decoded token
  authenticates (HTTP 200 on `sys/seal-status`) and does not measure its policies, TTL,
  renewal, revocation, or whether it is a `root` token by any other observable than access.
- **No real vault.** No production server, no operator's actual shares, no real root token,
  no customer data. Every credential in the run is generated inside it and deleted with the
  scratch directory.
- **The rekey mechanism is established by source, symbols and a flag experiment, not by an
  instruction-level decompile.** The gate rests on (a) the source at the binary's exact commit
  `9e0a0d3c…`, (b) the binary's HCL key and parser error string, and (c) a three-way
  experiment (flag absent → 405, `true` → 405, `false` → 200). The instruction-level branch on
  the flag is an inference from those three, and the Revenger records it as such.
- **`rotate-keys` was measured from 5 shares/3 threshold to 3/2 on raft and inmem only.** Other
  share counts and thresholds, other backends, a rotation under Auto Unseal, and a rotation
  with PGP-encrypted output are unmeasured.
- **`-target=recovery` was measured only on a shamir server** (404 under the default config,
  400 `recovery rekeying not supported` with the flag). The auto-unseal recovery-key rekey
  success path needs a KMS/HSM and is unmeasured.
- **The flag experiment used throwaway servers.** `disable_unauthed_rekey_endpoints = false`
  was measured on a scratch listener; the entry does not claim what a production listener
  would expose beyond the endpoints it measured.
- **The pages' own labels.** All three say Version 2.7.x; the exact patch the pages describe
  is not pinned by the label, and the binary is 2.7.2.

## Falsifiers

Each line names an observation that would break the measured claim it sits under.

- T1: `operator init -key-shares=5 -key-threshold=3` returning a different number of shares or
  a different threshold; `sys/seal-status` not reading `initialized=true sealed=true t=3 n=5`;
  or any of the five base64 shares found in a file under the storage path. Any of these breaks
  the claim that init returns 5 shares at threshold 3 and that the server does not persist them.
- T2: a repeated share advancing the progress past `1/3`; a second distinct share not
  advancing to `2/3`; or a third distinct share not unsealing. The first would make the
  threshold a submission count; the others would break the stateful-progress claim.
- T3: `operator seal` not setting `sealed=true`; an authenticated request while sealed
  returning anything other than HTTP 503; or `sys/seal-status` requiring a token. The last
  would break the sealed-but-monitorable reading.
- T4: `-init` not returning a nonce, an OTP and `required=3`; three shares not reaching
  `complete=true`; `-decode` with the right OTP not yielding a token that authenticates; or
  `-decode` with a wrong OTP yielding the same token. The last would make the OTP a
  formatting step rather than a second factor.
- T5: `operator rekey -init -key-shares=3 -key-threshold=2` succeeding on this build; or
  failing with a status other than 405 `unsupported operation` (which would mean the refusal
  is a different gate — auth, path, or a validation error — and not the missing operation).
- T5 / rekey: `operator rekey -init` succeeding on a listener that does **not** set
  `disable_unauthed_rekey_endpoints = false`; or the 405 persisting when the flag is
  explicitly `false`; or an anonymous request to `sys/rekey/init` returning 403 rather than
  405 (which would mean the auth check ran before the path was resolved). Any of these breaks
  the registration-gate reading.
- `rotate-keys`: a completed rotation after which an old share still contributes to
  reconstruction; or a rotation after which the existing root token stops authenticating; or
  new shares that do not unseal at the new threshold. Any of these breaks the measured
  full-rotation claim.
- Custody: a share found in the storage directory; a repeated share counting twice; an
  encoded generate-root token authenticating before `-decode`; or a root token decoded with
  the wrong OTP.
- Bounds: any claim here that an auto-unseal path, a recovery key, a seal migration, a PGP
  share, a cluster, a TLS listener, a non-default storage backend or a real vault was
  exercised by this round.

SEAT-STATUS: complete
