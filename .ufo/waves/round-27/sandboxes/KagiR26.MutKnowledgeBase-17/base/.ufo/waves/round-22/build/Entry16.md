# Entry16 — `corpus/knowledge/op-cli-surface.md` freshness and calibration audit

Axes: **calibration (C1)** and **freshness (C2)**. Read-only audit; no host gates run, no vault/account reads, no handler execution, no installs, no service or config changes.

Read revision: `c2cab35bc92e57e39e5489bac3386db078345b3f` (HEAD; `git rev-parse HEAD` matched `plans/round-22.md`). At read time the audited entry and `corpus/stamps.tsv` were clean; sibling round-22 edits appeared in the worktree during the audit and do not include either file. Entry bytes: `2ac8f081724c9bd8368211276472da3bdb6ed0d6ccaf4492cea92e94e35da52b`, 117 lines, 6667 bytes. Ledger anchors read: `corpus/stamps.tsv` = `0ce7fa4f97faef5ea8317fadaf5e412e8e5bfef2db532d57cb92b8af43c14e5b` (63 rows); `corpus/claim-ledger.tsv` = `8a4019cfc1eec916f30a8958fbc3ca2d30e59632e0f1d5d843cea6d1c24faa97`. Audit date: 2026-10-20.

## Decision summary

Correct decisions, not authored counts. "Accept" = the claim survives this audit as stated; "reject" = the claim as stated is not established; a bounded variant may still be admitted.

| id | decision put to the record | verdict | basis |
|---|---|---|---|
| D1 | Accept the stamp row as the pin for the bytes read | **accept** | Recomputed sha256/lines/bytes match exactly; row present once at `corpus/stamps.tsv:24` |
| D2 | Read the entry as current for the installed `op` | **reject** | Host `op` is 2.41.0; the entry records 2.35.0 as a 2026-09-28 observation |
| D3 | Treat the `the-janitor` claims as currently verified | **reject** | Handler and its config/state dirs are absent; both `Reverify:` rows are `[substrate]`-tagged and would defer, not pass |
| D4 | Read the endpoint-drift section as current host state | **reject** | No listener on 8080/34113/40961; the cited explicit overlay file is absent |
| D5 | Accept the plain-env `op run` row's "no vault contact" as measured | **reject as measured; admit bounded** | Only exit 0 in ~0.02 s and no prompt were observed; no network instrumentation. The round-21 scratch-HOME arm (`R21-01`) supports the bounded reading but proves byte fidelity, not network absence |
| D6 | Accept "reads on-disk account registration" as an observation | **reject as measured; accept as help-level attribution** | The observation is exit 0 without auth/prompt. The 2.41 help text says "locally configured" and "set up on this device", which supports the mechanism, but no `op account list` call was made (live-account/PII rule) |
| D7 | Accept `whoami` exit 1 as a "predictor" of readiness death | **reject as general; admit single-case inference** | One observed 2026-09-28 path; not a measured predictor |
| D8 | Treat `Reverify: R11-02, R12-01` as coverage of this entry | **reject** | The declaration resolves, but it is a pointer, not relevance: the rows cover the `refs`/`op run` subset only; auth, signin, endpoint and stop claims have no re-run row |
| D9 | Land a dated append-only erratum | **accept** | Current-tense claims rest on absent sources, and the version is superseded; this is the round-21 M1 class, not a gate failure |
| D10 | Re-pin by re-stamping the whole ledger as-is | **reject** | Five sibling rows are currently stale; a whole-set `stamp` would silently bless bytes no round reviewed (see §7) |

Ten decisions: 2 accept, 8 reject, with bounded admissions for D5–D7.

## 1. Stamp row: no stale-byte mismatch, no dropped pin

Current row (`corpus/stamps.tsv:24`):

```
corpus/knowledge/op-cli-surface.md	2ac8f081724c9bd8368211276472da3bdb6ed0d6ccaf4492cea92e94e35da52b	117	6667
```

- `sha256sum corpus/knowledge/op-cli-surface.md` → `2ac8f081724c9bd8368211276472da3bdb6ed0d6ccaf4492cea92e94e35da52b`; `wc -lc` → `117 6667`. Exact match. No `STALE`, no `MISSING`.
- `git diff --stat HEAD -- corpus/knowledge/op-cli-surface.md corpus/stamps.tsv` is empty; the working file is the committed file.
- Provenance of the pin: created in `301b9ec` (round 11, 2026-09-28T20:08:39-03:00) as `9bb1cfc2…` / 115 / 6641. Re-pinned in `2486643` (round 14, 2026-09-28T22:27:11-03:00) to `2ac8f081…` / 117 / 6667. The round-14 entry diff is exactly the `Reverify:` declaration plus its blank line (+2 lines, +26 bytes), and the stamp row changed in the same reviewed commit. Unchanged in every later stamps commit (`e1544c1`, `c41af82`, `fecee87`, `bc1af88`, `8a6ec16`, `587fda0`).
- Drop check: the path is present in all nine commits that touch `corpus/stamps.tsv`. The union of paths in all committed stamp revisions minus the current set is empty (0 rows). This entry has never been dropped in committed history.
- The nine deletions reported by the outside verifier are therefore not corroborated for this path by this repository's committed stamps history. That is a scope limit, not a denial: an uncommitted/in-flight run or an external baseline could still contain them.

## 2. Substantive freshness: the pin is honest, the host moved

| claim area | as recorded | observed 2026-10-20 (read-only) | classification |
|---|---|---|---|
| `op` version (entry lines 3, 15) | `2.35.0` at `/usr/bin/op`, observed 2026-09-28 | `op --version` → `2.41.0`, exit 0; `pacman -Qo /usr/bin/op` → `1password-cli 2.41.0-1` | **stale current reading**; dated row remains historically true |
| `the-janitor` source (lines 3–4, 17–18, 23–32, 55–68, 93–100) | source path and line refs L183, L194–210, L228–235 | `~/.local/bin/the-janitor` absent; `~/.config/the-janitor` absent; `~/.local/state/the-janitor` absent | **absent source**; historical only |
| endpoint drift (lines 72–91) | 8080 = Jitsi Jetty, 34113 = llama.cpp, 40961 = OpenCode | no listener on 8080/34113/40961 (`ss -tlnp`); `curl --max-time 2` to 8080 and 34113 `/health` → connection refused (curl exit 7) | **not current**; the 2026-09-28 drift is historical |
| overlay pin (line 72) | `opencode.json` pins `qwen-local` at `http://127.0.0.1:8080/v1` | Explicit overlay `~/.config/the-janitor/opencode.json` (the path named in `config-layering.md:19`) is absent. The global `~/.config/opencode/opencode.json` present today is 95 bytes with keys `$schema`, `autoupdate`, `theme`, no `provider` block and no `127.0.0.1:8080` string | **source absent / pin not locatable today** |
| `op` CLI shape (lines 15–21) | commands and flags at 2.35.0 | Help-level only: `op run --env-file`, `--no-masking`, `op signin --raw`, `op account list`, `op account get`, `op whoami` still present; global `--format` accepts `json` | **shape survives at help level; behavior not re-measured** |
| `op account list` JSON shape (line 16) | one-element array, four string fields | **not re-run** (live-account/PII rule) | unverified |
| `whoami` exit 1 / signin death / stop idempotence / refs behavior | observed 2026-09-28 | **not re-run** (no handler; no live auth) | unverified; historical |

The key distinction: there is **no stale-byte mismatch** in the stamp, but there is **substantive staleness** in the host/source state the entry describes. The stamp proves which revision was read, not that the revision is current.

## 3. Absent-source limits

- The cited handler is absent at its exact path, and the whole `~/.config/the-janitor` and `~/.local/state/the-janitor` trees are absent. The entry's source line, line references, auth matrix, `refs` mechanism, readiness-loop claim and `stop` claim cannot be checked against source today.
- `R11-02` and `R12-01` both carry the literal `[substrate]` tag (`corpus/claim-ledger.tsv:16,26`). Under `claim-ledger.sh`'s `substrate_present()` (`corpus/claim-ledger.sh:138–146,397–400`) they would print `DEFER <id> reason=substrate-absent` and not run. Deferral is explicitly not a pass (`corpus/knowledge/substrate-deferral.md` §Bounds.1). No gate was run in this audit; this is a code-level expectation, not an observed gate result.
- `op account list --format=json` is a live-account read whose output the entry itself classifies as PII. It was not run, so the four-field shape is not re-verified.
- No vault contact, sign-in, `op run` against a ref, or handler execution was performed. The `op --version` and `--help` reads are local binary reads; they establish no vault behavior.
- The global `~/.config/opencode/opencode.json` is not the cited overlay. It was inspected at key level only (no values), and its lack of a provider block does not by itself prove the overlay never pinned 8080; the overlay is simply absent.

## 4. Calibration findings (feature-specific, bounded)

1. **Plain-env `op run` "no vault contact" (line 20) is stronger than the measurement.** The observation was exit 0 in ~0.02 s and no prompt. Round 21's byte arm ran plain-value `op run` under `env -i` with scratch HOME/XDG and no account (`corpus/knowledge/op-ref-consumption.md` §11; `R21-01`), which is consistent with no vault contact, but that arm's stated purpose is byte fidelity, not a network-absence proof. Defensible wording: "exit 0 in ~0.02 s with no prompt observed; no network/vault contact was measured; the scratch-HOME byte arm succeeded without account state."
2. **"reads on-disk account registration" (line 16) is a mechanism attribution, not a measured observation.** The observed facts are exit 0 and no auth/prompt. The 2.41 help text (`op account` → "locally configured"; `op account list` → "accounts set up on this device") supports the attribution, but the entry presents it as a property of the call. Attribute it to the vendor help text or label it inference; do not let it stand as a measured read path.
3. **"cheapest predictor" (lines 67–68) generalizes one path.** The record shows one failed `request` after `whoami` exit 1. Admit: "in the single 2026-09-28 path observed, `whoami` exit 1 preceded the readiness-loop death." Do not present it as a validated predictor.
4. **M1 recurrence (round-21 mistake class).** `corpus/lessons/round-21.md` M1 names current-voice claims about files absent from the host. This entry asserts the `cmd_serve` auth path, L183/L228–235 and `the-janitor` rows in current voice while the file is absent. The entry was not in M1's evidence list; it is the same class and needs the same append-only treatment.
5. **Declaration is a pointer, not coverage.** The `Reverify:` line resolves and the stamp row exists, so `docs`-mode membership passes, but `R11-02`/`R12-01` cover only the `refs`/`op run` subset. The entry's auth and endpoint claims are not re-run by either row. This is the already-recorded "pointer, not relevance" bound (`corpus/claim-ledger.sh` header), instantiated here.
6. **No E1/E3-type vendor adjudication is involved in this entry.** It has no `source:` registry row and no product/status/eligibility qualifier from S001–S016. Do not import E1/E3 verdicts into it; conversely, this entry cannot be used as evidence for or against those admits.

## 5. Proposed appended correction

Append-only; original lines 1–117 remain byte-identical. Proposed block (not applied by this seat):

```markdown
## Erratum (round 22, freshness audit 2026-10-20; appended, text above unchanged)

The bytes above remain the revision pinned at `corpus/stamps.tsv:24`
(`2ac8f081…da52b`, 117 lines / 6667 bytes). A recomputation on 2026-10-20
matched, so there is no stale-byte mismatch and this row is not a dropped pin.

What is stale is the host/source state, not the file:

- `op --version` at `/usr/bin/op` now returns `2.41.0` (`1password-cli 2.41.0-1`,
  `pacman -Qo`), not the `2.35.0` recorded in the dated rows above. Those rows
  remain 2026-09-28 observations; current `op` behaviour was not re-measured.
  Help-level presence only: `op run --env-file` and `--no-masking`,
  `op signin --raw`, `op account list/get`, and `op whoami` still appear.
- `~/.local/bin/the-janitor`, `~/.config/the-janitor` and
  `~/.local/state/the-janitor` are absent, so the `cmd_serve` auth path,
  L183/L228–235 and every `the-janitor` row above are historical and
  unverified today. `R11-02` and `R12-01` are both `[substrate]`-tagged and
  would defer on this host; a defer is not a pass.
- No process listened on `127.0.0.1:8080`, `:34113` or `:40961` (`ss -tlnp`);
  both `/health` probes were refused (`curl` exit 7). The 2026-09-28
  Jetty/llama.cpp drift is historical, not a current endpoint claim. The
  explicit overlay (`~/.config/the-janitor/opencode.json`) is absent, and the
  global `~/.config/opencode/opencode.json` present today has no `provider`
  block and no `127.0.0.1:8080` string.
- Calibration bounds: the plain-env row's "no vault contact" was inferred from
  exit 0 in ~0.02 s, not measured; read it as "no prompt observed and no
  refusal in that run". The `whoami`→readiness "predictor" is a single
  observed path, not a measured predictor. `op account list --format=json`
  was not run (PII and live-account rule), so its four-key shape is not
  re-verified; its "on-disk registration" wording is supported by the 2.41
  help text, not by a call recorded here.

Re-verification requires restored authorized sources and a separately
authorized live probe; this erratum records no new `op` behaviour.
```

Do **not** change the `Source:` line, the `Reverify:` line, the dated table rows, or any line reference. Do **not** add a `source:`/`recheck:` legacy header for this entry; that is outside this audit's scope.

## 6. Exact recheck scope

### Already performed (2026-10-20, read-only, no vault/account)

| check | result |
|---|---|
| `sha256sum` + `wc -lc` on the entry | `2ac8…` / 117 / 6667, matches stamp row |
| `sha256sum` on `stamps.tsv` and `claim-ledger.tsv` | `0ce7fa…`, `8a4019…` |
| `git log`/`git show` on the entry and stamps history | provenance above; zero committed drops |
| `op --version` | `2.41.0`, exit 0 |
| `pacman -Qo /usr/bin/op` | `1password-cli 2.41.0-1` |
| `op --help`, `op run --help`, `op signin --help`, `op account list --help`, `op account get --help`, `op whoami --help` | flags/commands listed above; help only |
| path presence: handler, config/state dirs, overlay, global config | handler/config/state/overlay absent; global config present (95 bytes, no provider) |
| `ss -tlnp` for 8080/34113/40961 | no listeners |
| `curl --max-time 2` to 8080/34113 `/health` | connection refused, exit 7 |

### Deferred — requires authorization and/or restored substrate

- `op account list --format=json` — live-account/PII read; if ever authorized, record only element count and key names, never values.
- `the-janitor whoami` — exit code only; do not paste output.
- `the-janitor run` missing-command / missing-env-file guards — exit 2 and exact text; no `op` exec.
- `op run --env-file=<plain fixture>` — authorized live check; record exit, timing, prompt presence, stream emptiness; no network claim without instrumentation.
- `op run --env-file=<ref fixture>` signed out under `timeout 30` — would attempt vault contact; prohibited in this wave; requires explicit operator authorization.
- `the-janitor stop` idempotence — mutates the live session-id file; run only against a scratch state dir.
- `bash corpus/surface-census.sh --verbs` (`R11-02`) and `bash corpus/op-ref-probe.sh` (`R12-01`) — host gates; not run here.
- Endpoint `/metrics` body check — moot while no listener exists; re-check only if a handler is restored and the endpoint claim is being made current.

### Post-restoration order (authorized source review, not a live vault run)

1. `test -x ~/.local/bin/the-janitor`; record `sha256sum`, `wc -lc`, mtime.
2. Re-read L183, L194–210 and L228–235 in the restored handler; compare to the entry's line refs.
3. `the-janitor whoami`; record exit code only.
4. Guard probes (missing command, missing env file); record exit 2 and exact text.
5. Re-run `surface-census.sh --verbs` and `op-ref-probe.sh`; record verdicts and defer reasons, not just exit.
6. Only with separate authorization and a signed-out account: the `op run` plain/ref pair under the stated bounds; record stream emptiness and exits, never values.
7. Re-check ports only if the handler is running; record whether 8080 is again occupied and by what, without relying on `/metrics`.

## 7. Ledger expectation migration (exact, no laundering)

- Today's row is correct and must not change unless the entry's bytes change. Do not re-stamp merely to refresh a date.
- If the erratum in §5 lands, the entry's sha/lines/bytes change. The **same reviewed commit** must update only the `corpus/knowledge/op-cli-surface.md` row and must record the old→new evidence:
  `2ac8f081… 117 6667` → `<new-sha> <new-lines> <new-bytes>`.
  The old row remains in Git history; this is the preservation record.
- **Do not run a whole-set `stamp` now.** Five sibling rows are currently stale with observed bytes:
  - `corpus/knowledge/config-layering.md` row `848b8e50… 109 6621`, actual `9d4ac8c2… 136 8088`
  - `corpus/knowledge/handler-on-disk-state.md` row `811572dc… 247 17609`, actual `df6a5e5d… 277 19329`
  - `corpus/knowledge/handler-trust-boundary.md` row `263c7b0e… 285 17669`, actual `fa17fff3… 316 19410`
  - `corpus/knowledge/janitor-env-contract.md` row `88dca63a… 90 5111`, actual `dac43ef9… 113 6372`
  - `corpus/lessons/round-18.md` row `614335f2… 73 4216`, actual `b00b7dd8… 80 4557`
  `stamp PATH…` replaces the whole row set (`corpus/claim-ledger.sh:225–293`), so passing all 63 paths would silently re-pin these five. Passing only this path is refused by the shrink guard; `--prune` must not be used.
- Acceptable migrations, in preference order:
  1. A reviewed one-row patch of `corpus/stamps.tsv` (all other rows byte-identical), with the old→new digest in the commit message and the erratum. This is the non-laundering minimal move.
  2. A full `stamp` run only after every one of the five stale rows above has been separately reviewed and its change explained; otherwise option 1.
- No deletion, no `--prune`, no re-pin of an unchanged file, no re-pin that hides another entry's unreviewed edit.

## Provenance, limits, and non-actions

- Base/HEAD: `c2cab35bc92e57e39e5489bac3386db078345b3f`. Last entry commit: `2486643` (2026-09-28T22:27:11-03:00). Last stamps commit: `e1544c1` (2026-10-19T19:45:42-03:00); the row was a context line there and in `c41af82`/`fecee87`.
- Earlier absence records cross-checked: `corpus/knowledge/substrate-deferral.md` (host census 2026-10-14) and `corpus/knowledge/config-layering.md` (path-presence metadata 2026-10-15). Today's check confirms the same absence.
- No production file, live lane state, config, state, service, package transaction, boot setting or credential was modified **by this seat**. The worktree shows sibling round-22 modifications (`corpus/QUALITY.md`, `corpus/SOURCES.md`, `corpus/knowledge/onepassword-machine-credentials.md`, `corpus/knowledge/vault-openbao-token-lease-lifecycle.md`, new `corpus/knowledge/feature-bound-credential-review.md`, `corpus/lessons/round-22.md`, `plans/round-22.md`); none of those corpus entries were used as evidence for the audited facts, and `corpus/knowledge/op-cli-surface.md` plus `corpus/stamps.tsv` remain unmodified. No `op account list`, `op whoami`, `op signin`, `op run`, or handler command was executed. No `surface-census.sh`, `op-ref-probe.sh`, `claim-ledger.sh`, `drift-pins.sh` or other host gate was run.
- Point-in-time limits: `ss`/`curl` show absence at one moment; they do not explain why the services stopped. The global `opencode.json` is not the cited overlay. The five sibling stale rows are reported as observed bytes, not adjudicated.
- The proposed erratum is text only; this seat did not edit the entry or the stamp ledger.

Report: `.ufo/waves/round-22/build/Entry16.md`
