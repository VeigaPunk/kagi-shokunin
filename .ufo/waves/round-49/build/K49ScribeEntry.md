# K49ScribeEntry — draft entry section, supersession note, capability row, PROVINCE bullet (round 49)

Seat: K49ScribeEntry (leaf; no subagent dispatch). Date: 2026-11-06.
Output is **draft text only**: nothing in `corpus/`, `plans/`, `SCORECARD.md` or
`PROVINCE.md` was modified. The frozen instruments (`plans/round-49.md`,
`plans/round-49-c1.sh`, `plans/round-49-c2.sh`, `plans/round-49-controls.sh`,
`.ufo/waves/round-49/controls/fixtures/*`) were read, never edited.
No trial, counter, claim-ledger verify or self-counts run was executed by this
seat; every measurement below is a placeholder for the candidate run.

## Inputs read (read-only)

- `/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/knowledge/vault-openbao-token-lease-lifecycle.md`
  (176 lines, sha256 `4932f37f6e4bc0cf312f9d844b1ab215cb66248846664715515e0fa8d7b17298`,
  identical at BASE `89afe91878f10805921d3caa67d28d21b33226da` and the
  predeclaration commit `082bfb3f6baa2407df2a23c0489043495b4dce4d`).
- `/home/vgpnk/Projects/shokunin/kagi-shokunin/plans/round-49.md` (§Axes, §C1, §C2).
- `/home/vgpnk/Projects/shokunin/kagi-shokunin/plans/round-49-c1.sh` (predicate header,
  `PINS`, the SH1..SH5 shim bodies, and the `entry_line()` awk at lines 104-111).
- `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-49/controls/fixtures/openbao-token-trial.ref.sh`
  (full file, 7112 bytes) and `…/fixtures/entry-measured.ref.md`.
- `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-49/controls/controls-prefreeze.txt`
  (19/19 MATCH) and `…/controls/tool-install.txt`.
- `git -C /home/vgpnk/Projects/shokunin/kagi-shokunin show 89afe91878f10805921d3caa67d28d21b33226da:corpus/knowledge/sops-age-key-rotation.md`
  (the round-48 `## Measured (round 48 …)` section and its supersession note).
- `/home/vgpnk/Projects/shokunin/kagi-shokunin/SCORECARD.md` §Capabilities (table at
  lines 696-717; the SOPS/age row is line 713) and
  `/home/vgpnk/Projects/shokunin/kagi-shokunin/PROVINCE.md` (the `Core, round 48`
  bullet at line 93, followed by the `Adjacent` bullet at line 94).

No writes outside
`/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-49/build/K49ScribeEntry*`
and `/fast/scratch/hyaku/kagi-r49/K49ScribeEntry/` were made.

## 1. Entry section to append (verbatim draft)

Append after the entry's last line (`… No Vault or OpenBao runtime, account or
token operation was performed for these corrections.`) with one blank line
before the heading; the heading starts at column 0. The text is append-only:
it removes or rewrites no existing line, and the five `- T<n> ` lines each carry
`OpenBao 2.7.2` on the same physical line (required by the counter's
`entry_line()`).

```markdown
## Measured (round 49 — OpenBao 2.7.2 dev server, 127.0.0.1, throwaway tokens)

Measured 2026-11-06 on this host by executing the round-49 trial
`corpus/openbao-token-trial.sh --work <scratch dir>`; its five tests and its
`TRIAL T<n> HOLDS|BROKEN|ERROR …` / `OPENBAO_TRIAL: …` lines are those frozen in
the reference fixture
`.ufo/waves/round-49/controls/fixtures/openbao-token-trial.ref.sh`. One
throwaway `bao server -dev` was started on 127.0.0.1 at a random free port, with
in-memory storage and a random root token kept only in the scratch tree and
deleted with it; every caller `BAO_*`/`VAULT_*` variable was unset, `HOME`
pointed into that tree, and no real vault, account, credential or Kubernetes API
was touched. The binary is the official OpenBao 2.7.2 linux_amd64 release
(`~/.local/bin/bao`, sha256 `9c5f3628…b788`; receipt
`.ufo/waves/round-49/controls/tool-install.txt` — `checksums.txt` and the GitHub
asset digests match, the `.gpgsig` and `.sigstore.json` assets were **not**
verified). The trial printed one `TRIAL T<n> HOLDS …` line per test and ended
`OPENBAO_TRIAL: <detail from measured-at-candidate>`.

Supersession note (append-only entry): the `Scope:` sentence at `:9` ("vendor
documentation only; nothing was deployed or probed") and the first sentence of
§How kagi uses this (`:76`, "kagi runs neither product") describe the entry
before round 49. For the five OpenBao token mechanisms below they are
superseded: a throwaway dev server was started (not deployed) and these token
and lease behaviours were probed on it. Vault is still not run — no Vault token,
lease or KV mechanism is measured here, and nothing below is Vault/OpenBao
parity. The `[INFERENCE from S015 + S016]` reading under §OpenBao tokens
(`:58-60`) stays an inference: the trial runs no Kubernetes cluster and calls no
TokenReview API, so it cannot measure what a Kubernetes-side revocation does to
an already-issued token. What the trial establishes is one host, one release,
dev mode: a single `bao server -dev` with in-memory storage, HTTP on 127.0.0.1,
no storage backend, no seal or unseal operation, no HA, no TLS and no policy
model beyond the `default` policy and the two trial policies (`child-maker`,
`pki-issue`). A dev server is not a production configuration; none of this is
evidence about a deployed or production Vault/OpenBao, and `verified-at:
2026-10-19` remains the date the documentation was read, not the date of these
runs.

- T1 non-root TTL: with OpenBao 2.7.2, a non-root token was created with `bao token create -policy=default -ttl=2s` and looked up once immediately and once after a 4 s sleep; observed `TRIAL T1 <detail from measured-at-candidate>`, the fixture's detail fields being `ttl=2s`, the answer before the TTL and the answer after it — measures S016 §Token Time-To-Live, "Every non-root token has a time-to-live" and "After the current TTL is up, the token will no longer function".
- T2 explicit max TTL cap: with OpenBao 2.7.2, a token was created with `-ttl=60s -explicit-max-ttl=5s`, `bao token renew -increment=3600` was requested with it, and it was looked up again after a 7 s sleep; observed `TRIAL T2 <detail from measured-at-candidate>`, the fixture's detail fields being the granted `lease_duration` against the requested 3600 s and the answer after the cap — measures S016 §Token Time-To-Live as this entry reads it ("an explicit max TTL is a hard cap").
- T3 batch token: with OpenBao 2.7.2, a batch token was created (`bao token create -type=batch -ttl=60s`), asked to renew itself, and then revoked by the root token; observed `TRIAL T3 <detail from measured-at-candidate>`, the fixture's detail fields being renew-ok, revoke-ok and whether the batch token still answers a lookup — measures S016 §Token type comparison, "Batch tokens: not renewable and not manually revocable".
- T4 orphan login token: with OpenBao 2.7.2, userpass was enabled, a token holding a `child-maker` policy created a child token and logged in through userpass, and the parent token was then revoked; observed `TRIAL T4 <detail from measured-at-candidate>`, the fixture's detail fields being the login token's `orphan` value, the child's answer after the parent's revocation and the login token's answer — measures S016 §Token hierarchies and orphan tokens: logging in "with any other (non-token) auth method" yields an orphan token, so parent-tree revocation does not reach it.
- T5 lease revoked with its token: with OpenBao 2.7.2, a PKI mount issued a certificate with `generate_lease=true` (lease TTL 10 m) under a token created with `-ttl=3s`, and the lease was looked up before and 5 s after issuance; observed `TRIAL T5 <detail from measured-at-candidate>`, the fixture's detail fields being the lease's answer before and after the token's TTL — measures S016 §Token Time-To-Live, "it, and its associated leases, are revoked".

Each test has a designated falsifier shim in `plans/round-49-c1.sh` (SH1
token-lookup-always-succeeds, SH2 create-drops-explicit-max-ttl, SH3
create-drops-batch-type, SH4 userpass-login-returns-a-child-token, SH5
create-drops-ttl) that flips it to BROKEN; a HOLDS row excludes that falsifier
under these conditions, it is not a proof of the mechanism in general.

Re-run: `bash corpus/openbao-token-trial.sh --work <dir>` (starts and kills its
own throwaway dev server, throws the server state and tokens away on exit;
needs `bao` and `python3` on `PATH`).

**Does not establish:**

- One host, one release, dev mode: everything above is OpenBao 2.7.2 from the
  official linux_amd64 release on this host, against one `bao server -dev` with
  in-memory storage. A dev server is not a production configuration — no storage
  backend, no seal or unseal operation, no HA, no TLS, no policy model beyond
  the trial policies — and another release or a production cluster may behave
  differently.
- No Vault: no Vault binary or server was run, so no Vault token, lease or KV
  mechanism is measured and no Vault/OpenBao parity is established.
- No Kubernetes: no cluster and no TokenReview call; the `[INFERENCE]` at `:58`
  stays an inference.
- No real secret or account: the only credentials are the random dev root token
  and a random userpass password, both created in scratch and deleted with it;
  the trial prints neither the root token, a created token value nor the
  password.
- Mechanism scope: the five sentences listed, at token TTLs of 2–60 s and
  observation windows of 4–7 s; periodic tokens, the 32-day system default max
  TTL, mount tuning beyond the PKI mount's `max-lease-ttl=1h`, and auth-method
  max TTLs are not exercised, and PKI is the only lease-issuing engine used
  (no database, transit or other engine).
- A trial that detects its designated shims is a ceiling: T1..T5 passing
  excludes the five named falsifiers under these conditions; it does not
  establish that no other implementation or configuration could satisfy the
  entry's sentences for a different reason.
```

## 2. Supersession note — scope checklist (drafted inside §1)

| required element | drafted location | text |
|---|---|---|
| `Scope:` sentence at `:9` ("nothing was deployed or probed") superseded | §1, supersession paragraph | names `:9` and quotes "vendor documentation only; nothing was deployed or probed"; says "started (not deployed) … probed" for these five mechanisms only |
| `How kagi uses this` ("kagi runs neither product") superseded | §1, supersession paragraph | names `:76` and quotes the sentence; limits supersession to the five OpenBao token mechanisms |
| Vault still not run | §1 paragraph + second "Does not establish" bullet | "no Vault binary or server was run" |
| `[INFERENCE]` at the K8s/TokenReview line stays an inference | §1 paragraph + third bullet | names `:58-60`; "runs no Kubernetes cluster and calls no TokenReview API" |
| what the trial does and does not establish; one host, one release, dev mode, in-memory storage, not production | §1 paragraph + "Does not establish" bullets 1-6 | one host, one release (2.7.2), `bao server -dev` in-memory, no storage backend/seal/HA/TLS, "not a production configuration" |

The entry's other erratum text (rounds 21/22), its `§Does not establish`
bullet on Vault token mechanics, its absence-sweep bullet and its `§Falsifier`
are untouched and remain in force.

## 3. SCORECARD §Capabilities row (draft, not applied)

Insert as the last row of the table (after the `SOPS/age access-vs-rotation
trial` row at line 713, before the blank line and the "Rows enter only through
demonstrated execution" paragraph at line 715). Column shape is the table's:
`| Capability | What it can now do | Evidence pointer | First-working round |`.

```markdown
| OpenBao token/lease lifecycle trial | execute the documented OpenBao token and lease mechanics end to end against a throwaway `bao server -dev` on 127.0.0.1 with in-memory storage and a random root token kept only in scratch: a non-root token stops at its TTL, a 3600 s renewal request past an explicit max TTL is granted no more than the cap and the token is then refused, a batch token is neither renewable nor manually revocable, a userpass login token is an orphan so revoking its creator leaves it alive while the creator's child token dies, and a token's lapse revokes the PKI lease it issued; five designated falsifier shims (SH1..SH5) each flip one test to BROKEN, and a missing tool exits 2 without a HOLDS line | `bash corpus/openbao-token-trial.sh --work <dir>` ⇒ `OPENBAO_TRIAL: <detail from measured-at-candidate>`; frozen counter `plans/round-49-c1.sh` (target 5, BASE 0 absent); `corpus/knowledge/vault-openbao-token-lease-lifecycle.md` §Measured (round 49) | 49 |
```

The round-48 note paragraph ("Rows enter only through demonstrated execution…")
names 40 as the latest first-working round; that sentence is outside this
seat's item and was left untouched for the round's owner to update (see §8).

## 4. PROVINCE.md bullet (draft, not applied)

Insert after the `Core, round 48` bullet (line 93) and before the `Adjacent —
report, don't absorb` bullet (line 94), keeping the existing bullet style.

```markdown
- **Core, round 49 — OpenBao token and lease lifecycle, executed:** `corpus/openbao-token-trial.sh` runs the mechanics of `knowledge/vault-openbao-token-lease-lifecycle.md` on OpenBao 2.7.2 (official release binary in `~/.local/bin`, sha256-pinned) against a throwaway `bao server -dev` on 127.0.0.1 with in-memory storage and a random root token kept only in scratch — T1 a non-root token stops at its TTL, T2 an explicit max TTL caps a requested 3600 s renewal and the token is refused after it, T3 a batch token is neither renewable nor manually revocable, T4 a userpass login token is an orphan, so revoking its creator leaves it alive while the creator's child token is revoked, T5 a token's lapse revokes the PKI lease it issued — and each test flips under a falsifier shim (`plans/round-49-c1.sh`). No real vault, account, credential or Kubernetes cluster is touched; Vault is still not run; one host, one release, dev mode (entry §Measured, §Does not establish).
```

## 5. Placeholders (the only non-observed fields)

`<detail from measured-at-candidate>` appears 6 times: the section's run
summary line and one per `- T<n> ` line. Each stands for the trial's own
`TRIAL T<n> HOLDS|BROKEN|ERROR <detail>` remainder / `OPENBAO_TRIAL: …` summary
printed by the candidate run. No other field is a placeholder; every other
number, command and quote comes from the reference fixture, the entry, S016 or
the plan.

## 6. Checks run by this seat (format only — not C1, not a measurement)

Command set and output are in the receipt
`.ufo/waves/round-49/build/K49ScribeEntry-format-check.txt`; the draft text
checked was `/fast/scratch/hyaku/kagi-r49/K49ScribeEntry/section.md`
(sha256 `53ec46de7689678035522f3fa80cb8ee08b57fa2ee5cc7e084b92618c339240a`, byte-identical to the fenced text in §1 and therefore re-derivable from this report):

- heading exact-match (`== "## Measured (round 49 — OpenBao 2.7.2 dev server, 127.0.0.1, throwaway tokens)"`) ⇒ `1`, rc 0.
- replica of `plans/round-49-c1.sh` `entry_line()` for `T1`..`T5` ⇒ `1 1 1 1 1`, rc 0 each.
- `grep -cE '^- T[1-5] '` ⇒ 5.
- `grep -cE '^## '` ⇒ 1 (the section cannot be cut short by a second `## `).
- kill-rule shapes: `r49-[0-9a-f]{24}` ⇒ 0; `(^|[^A-Za-z0-9])(s|b|r)\.[A-Za-z0-9]{20,}` ⇒ 0; `password=[0-9a-f]{32}` ⇒ 0 (`grep -c` rc 1 = zero matches).

These checks exercise the draft's text only. They are not the C1 counter and
say nothing about whether the trial holds; the C1/C2 values at the candidate
are the wave's to measure.

## 7. Traceability map

| drafted claim | source |
|---|---|
| five tests, their order, tokens, sleeps, fields | `openbao-token-trial.ref.sh` lines 45-127 (`report`, `tok`, `alive` at 45-52; T1-T5 at 54-127) |
| `TRIAL T<n> …` / `OPENBAO_TRIAL: …` grammar; `--work`; exit 0/1/2; `bao`/`python3` required; dev server killed and `$D` removed on exit | `openbao-token-trial.ref.sh` lines 1-8 (header/grammar), 21-22 (`bao`/`python3` checks), 27-28 (cleanup), 129-131 (summary, exit) |
| random free port, 127.0.0.1, `-dev` in-memory, random root token never printed, `BAO_*`/`VAULT_*` unset, `HOME` in scratch | reference fixture lines 23-42 |
| OpenBao 2.7.2 official linux_amd64 release; sha256 `9c5f3628…b788`; `checksums.txt` + asset digests match; `.gpgsig`/`.sigstore.json` not verified | `controls/tool-install.txt`; `plans/round-49.md` §C1 tool paragraph |
| SH1..SH5 names and behaviours | `plans/round-49-c1.sh` lines 63-84 (`mkshim` definition + the five shim bodies) |
| `entry_line()` requirement (`- T<n> ` at column 0 + `OpenBao 2.7.2`) | `plans/round-49-c1.sh` lines 104-111 |
| S016 quotes: "Every non-root token has a time-to-live"; "After the current TTL is up, the token will no longer function"; "it, and its associated leases, are revoked"; batch tokens not renewable/not manually revocable; orphan login token; "with any other (non-token) auth method" | entry §OpenBao tokens (`:49-63`) and round-22 erratum (`:113-132`), S016 (Version 2.7.x) |
| "an explicit max TTL is a hard cap" | entry `:56` (the entry's reading of S016 §Token Time-To-Live) |
| scope/How-kagi line numbers `:9`, `:76`, inference `:58-60` | `grep -n` on the entry at HEAD `082bfb3f` (identical to BASE) |
| fallback expectation and absence-at-BASE framing in the capability row | `plans/round-49.md` §C1 predicate + `controls/c1-base.txt` |

## 8. Conflicts and observations for the judge (verbatim, not adjudicated)

1. `plans/round-49.md` §C1 places the `[INFERENCE]` at "`:58`". The token
   `[INFERENCE from` is on line 58, but the sentence it opens runs to line 60
   ("… will never revoke a token / before the returned TTL has expired"
   (§The general case). [INFERENCE from / S015 + S016] A Kubernetes-side
   revocation therefore shortens neither login / acceptance nor an
   already-issued OpenBao token; an operator must revoke it.). The draft cites
   `:58-60`; the plan's `:58` is correct for the marker, not the sentence span.
2. The frozen fixture's entry section
   (`.ufo/waves/round-49/controls/fixtures/entry-measured.ref.md`) uses the
   heading `## Measured (round 49 — OpenBao 2.7.2 dev server, reference
   fixture)` and five one-line T entries; the assignment's required heading is
   `… 127.0.0.1, throwaway tokens`. The controls' K1-P admitted either (its
   `entry_line()` matches any `## Measured (round 49` heading), so this is a
   difference, not a defect.
3. `plans/round-49.md` says the dev root token shape is `r49-<24 hex>`. The
   draft never writes that shape: this report and the section name the token in
   words only ("a random root token"), and the kill-rule shapes read 0 (§6).
4. The trial's summary field is `bao=$VER`, where `VER` is `awk '{print $2}'`
   of `bao version`; `tool-install.txt` records that line as
   `OpenBao v2.7.2 (9e0a0d3c…), committed 2026-10-26T20:32:27Z`, so the summary
   field should read `bao=v2.7.2` while the entry's required literal is
   `OpenBao 2.7.2`. The draft keeps both forms distinct and uses a placeholder
   for the summary so no version string is claimed unmeasured.
5. The SCORECARD note paragraph after the capabilities table still says "The
   latest first-working round in this table is 40" and the "Current readings at
   round 48" line is unchanged. Adding the round-49 row makes the first
   sentence stale; that sentence is not in this seat's item and is reported,
   not edited.
6. Candidate-writer check before landing: the drafted intro sentence says the
   trial's five tests and its output grammar "are those frozen in the reference
   fixture". If the hardened `corpus/openbao-token-trial.sh` changes a test body
   or a detail-field name in a way that makes that false, that sentence and the
   "fixture's detail fields" clauses must be adjusted to the script actually
   run. The counter checks only the `- T<n> ` prefix and the `OpenBao 2.7.2`
   literal, not these clauses. As of the read recorded in §11 that sentence is still true of the
   landed script; re-check if it changes again before landing.

## 9. Out of scope (not done by this seat)

- No measurement: no `bao` server, no `corpus/openbao-token-trial.sh` run, no
  `plans/round-49-c1.sh`, no `plans/round-49-c2.sh`, no `corpus/self-counts.py`,
  no claim-ledger verify.
- No edits to the entry, `SCORECARD.md`, `PROVINCE.md`, `plans/`, `corpus/`,
  registries, `.ufo/state` or any sibling repo; no `git add`/commit/checkout.
- C1's trial script itself, its hardening and its receipts belong to the
  execution seats; C2's stamp/README edits belong to the C2 seat.

## 10. Refusal-boundary compliance

No OpenBao server was started by this seat (none was needed: no measurement).
No token, root token, password, private key, cookie or vault field was read,
printed or written; the draft contains none and the kill-rule greps read 0. No
`~/.config/sops`, `~/.ssh` or real key file was read; no 1Password, `op`,
the-janitor, vault or account was contacted; no `op://` reference was written;
no package manager, sysctl, service or `~/.local/bin` entry was touched; no
remote write was made. Host binaries `~/.local/bin/bao|sops|age-keygen` were
not replaced or invoked.

## 11. Candidate-tree observation (read-only; not a measurement)

At 2026-11-06T21:14Z the lane's working tree carried an untracked
`corpus/openbao-token-trial.sh` (8221 bytes) plus the execution seat's
`.ufo/waves/round-49/build/K49ExecTrial/diff-vs-reference.patch`. Both were
read, neither was run by this seat:

- the patch's hunks touch the header comment, `cleanup()` and the INT/TERM/HUP
  traps, the `BAO_*`/`VAULT_*` unset loop, server start (retry on a fresh random
  127.0.0.1 port, readiness wait 300×0.1 s, `wait` on the server PID) and an
  explicit `cleanup` before `exit`; no T1..T5 body, `report` string, sleep or
  `OPENBAO_TRIAL:` summary line changes;
- `grep -n 'report T[1-5]' corpus/openbao-token-trial.sh` shows the reference's
  detail strings unchanged (`ttl=2s alive-before=… alive-after-4s=…`;
  `renew-increment=3600 granted=… alive-after-7s=…`;
  `renew-ok=… revoke-ok=… alive-after=…`;
  `login-orphan=… child-alive-after-parent-revoke=… login-alive=…`;
  `lease-ttl=10m token-ttl=3s lease-before=… lease-after-5s=…`).

Consequence: the drafted intro sentence and the "fixture's detail fields"
clauses match the landed script as of that read. The measured values remain the
execution seats' to produce and the C1 counter's to judge; this seat produced
none.
