# Entry03 — `cdp-bridge-1password`: byte-fresh pin, substantively historical

Seat: `KagiR22.Entry03` (read-only scout; no delegation). Audit date **2026-10-20**.
Target: `corpus/knowledge/cdp-bridge-1password.md` and its row `corpus/stamps.tsv:11`.
Read revision: base `c2cab35bc92e57e39e5489bac3386db078345b3f` (2026-10-19 22:05:06 -0300), worktree HEAD equal;
target blob `30b48fd3a4321a66afc485ee76a594c7c1095927`, sha256 `62020ad1…` (88 lines / 4320 bytes).
Axes: calibration, freshness. Wrote only this report; no host gate, no browser launch, no vault/UI, no install.

## Verdict

- **No stale-byte mismatch.** The stamp row equals the shipped bytes exactly; no re-pin is needed for drift. (OBSERVED)
- **Substantive freshness is not established and is partly contradicted.** The source substrate is absent, so the entry's code citations and quoted outputs cannot be re-read; two host observations no longer hold. (OBSERVED + INFERENCE)
- **A narrow appended correction is needed**, followed by a reviewed re-stamp in the same commit with the old row preserved. No deletion, no silent re-point, no rewrite of the 2026-09-28 text.

## 1. Stamp row vs actual bytes

| Field | Stamped (`stamps.tsv:11`) | Measured 2026-10-20 | Verdict |
|---|---|---|---|
| sha256 | `62020ad1ea4f879f84a9a50be921777ea43f4fe9308ccbf1434d45c7304fe1bb` | same | OK |
| lines | 88 | 88 (`wc -l`) | OK |
| bytes | 4320 | 4320 (`wc -c`) | OK |

- Committed bytes and worktree bytes are identical: `git show HEAD:corpus/knowledge/cdp-bridge-1password.md | sha256sum` → `62020ad1…`; `git diff --numstat HEAD -- <target>` is empty.
- Final byte is `0a` (final newline present); no CRLF or truncation artifact.
- Row history: `git log -S'cdp-bridge-1password.md' -- corpus/stamps.tsv` returns **one** commit, `2486643` (2026-09-28 22:27:11 -0300), with the same value. Round-21 `e1544c1` and base `c2cab35` did not touch it. **This row is not one of the previously dropped stamps** (bounded to this row).

## 2. What the matching stamp does and does not prove

Proves: the bytes a reader gets at `c2cab35` are the bytes that were pinned; no drift since `2486643`.
Does not prove: any host fact. `docs` mode would report this entry declared + pinned while both declared rows are `[substrate]`-tagged and therefore `DEFER reason=substrate-absent` (`claim-ledger.sh:397-399`). A green `docs` run for this entry means *declared and pinned*, not *fresh* — the exact overclaim this audit rejects (D2 below).

## 3. Measured host state (2026-10-20, read-only)

- `~/.local/bin/the-janitor` — absent; `~/.config/the-janitor`, `~/.local/state/the-janitor`, `~/.local/share/the-musketeer` — all absent. This confirms the round-18 measurement (`corpus/lessons/round-18.md:9-24`) and `corpus/README.md:117`.
- `~/.local/share/the-musketeer/chrome-profile/NativeMessagingHosts/com.1password.1password.json` — absent (entry:26-28 says "is present").
- `~/.local/share/burnerchrome/profile/NativeMessagingHosts` — exists, empty (`total 0`, mode 700, mtime 2026-10-03 21:14). `~/.local/bin/burner` and `burner-chrome` launch Chrome with `--user-data-dir=$HOME/.local/share/burnerchrome/profile`, loopback `9222`. **Not asserted as the bridge's new target**: `the-janitor`'s `MUSKETEER_CHROME_PROFILE` default is unreadable.
- `/opt/1Password/1Password-BrowserSupport` — present, mode `2755`, `7727200` bytes, mtime 2026-10-13 20:02, owned by `1password-beta 8.12.42_34.BETA-1`. The entry's existence/executable claim holds; the build is newer than the 2026-09-28 observation.
- `/usr/bin/op` — `2.41.0`, owned by `1password-cli 2.41.0-1` (entry says **2.35.0**).
- Package ledger (`/var/log/pacman.log`; no rotated file): earliest entry `2026-10-03T20:41:33+0000` base install to `/mnt`; `1password-cli` installed 2026-10-03 17:44:19 -0300 at `2.34.1-1`, upgraded 2026-10-11 to `2.40.0-2`, 2026-10-16 to `2.41.0-1`. **No 2.35.0 transaction exists in the current log.** (INFERENCE: the entry's 2.35.0 observation belongs to a host state predating this OS install; it cannot be re-derived from this ledger.)
- `curl -fsS --max-time 1 http://127.0.0.1:9222/json/version` → exit 7 (connection refused). The entry does not claim CDP is up; recorded so its "cdp … down" diagnostic is not misread as present state.
- Cross-domain note: `kake-shokunin/SKILL.md:159-161` still carries "Lease before browser." and names the shared `the-musketeer` profile at CDP `127.0.0.1:9222` (heading "§5"; read 2026-10-20). But `webzites` is not on `PATH` and `~/Projects/webzites` is absent, so the lease command cited at entry:78-79 is not executable on this host — consistent with the round-19 audit flag (`corpus/lessons/round-19-recensus.md:49`).

## 4. Calibration decisions (correct decision, not row count)

Scope note: this entry carries no vendor product-status, eligibility or plan claim, so the known E1/E3 overclaims have no counterpart here. The applicable bar is the corpus's historical-source convention (four sibling entries carry such errata) plus the pin. The decisions below reject the analogous overclaim for a host-fact entry: treating pin integrity as content freshness.

| # | Proposition | Decision | Basis |
|---|---|---|---|
| D1 | The stamp row is byte-fresh | **ACCEPT** | sha/lines/bytes all match; committed blob matches worktree |
| D2 | "Byte-fresh ⇒ the entry's content is substantively fresh" | **REJECT** (overclaim) | pin proves bytes, not host facts; source absent |
| D3 | The entry's host observations are reproducible now | **REJECT** | `op` 2.41.0; `the-musketeer` and its manifest absent; CDP down |
| D4 | The source-derived claims (line refs, quoted JSON, refusal text) are checkable now | **REJECT** | `~/.local/bin/the-janitor` absent; no copy in repo or transcripts (only prose mentions) |
| D5 | Delete, rewrite, or silently re-point the entry to `burnerchrome` | **REJECT** | append-only rule; knob default unknown; current burner NMH dir is empty, so re-pointing would be a new unverified claim |
| D6 | A narrow appended correction is warranted | **ACCEPT** | sibling entries received the same historical-source erratum in round 16; round-19 audit named this entry and said "mark the prose lines historical" (`round-19-recensus.md:49`) |
| D7 | Re-stamp in the same reviewed commit, recording the old row | **ACCEPT** | expectation migration; append changes bytes, so a stale row would otherwise be the only trace |
| D8 | `Reverify: R11-01, R11-02` currently exercises the entry | **REJECT** | both rows are `[substrate]`-tagged (`claim-ledger.tsv:15-16`); when the substrate returns `R11-02` exercises `cdp-bridge ensure` write/refusal on a scratch profile (`surface-census.sh:475-523`) — relevant to entry:30-46 only, not to entry:26-28, 48-64 |
| D9 | The `L22–26` header range vs the table's `L27` port row is a stale-byte artifact | **REJECT** | the contradiction is *inside* the pinned bytes (entry:3-4 vs entry:18-24); no source to adjudicate; must be re-derived, not "fixed" by guessing |
| D10 | This row is among the nine dropped stamps | **REJECT** (this row only) | single add at `2486643`, value never changed or removed in any commit |

## 5. Absent-source limits (exact)

| Citation in entry | Why it cannot be verified today |
|---|---|
| `the-janitor` L251–271 `cmd_cdp_ensure`, L273–291 `cmd_cdp_status` (entry:3-4) | binary absent; no copy in repo/transcripts |
| profile/port vars L22–26, `MUSKETEER_CDP_PORT` L27 (entry:4, 18-24) | binary absent; header range and table disagree |
| L109–111 / L110 handler-startup hint (entry:72-73) | binary absent |
| L325–328 `open-popup` refusal + quoted line (entry:59-62) | binary absent; refusal not re-elicitable |
| `cdp-bridge status` output contract (entry:48-55) | subcommand un-runnable |
| manifest `chmod 600` + two origin IDs (entry:33-46) | manifest absent at cited path; scratch probe is substrate-deferred |
| `op` version 2.35.0 (entry:28) | superseded: 2.41.0; not in current package ledger |
| NMH manifest "is present" (entry:26-28) | profile tree absent; contradicted by today's state |
| Falsification recipe (entry:84-88) | non-executable while the binary is absent |

## 6. Proposed appended correction (append-only)

Append one section after entry:88, separated by one blank line; **do not edit lines 1-88**:

`## Historical-source erratum — round-22 freshness audit (2026-10-20)`

Content (bounded, each claim measured above):
1. `Source-status: historical` — source-derived text at lines 3-6, 12-46, 48-64, 84-88 remains 2026-09-28 observation; no source bytes were read on 2026-10-20.
2. Named absence: `~/.local/bin/the-janitor`, `~/.config/the-janitor`, `~/.local/state/the-janitor`, `~/.local/share/the-musketeer`; therefore the cited ranges L22–27, L109–111, L251–271, L273–291, L325–328 and both quoted outputs are not re-readable/re-runnable.
3. Observation drift: `op` is `2.41.0` (`1password-cli 2.41.0-1`), not 2.35.0; the `the-musketeer` NMH manifest is absent; `/opt/1Password/1Password-BrowserSupport` is still present and executable (mode 2755, 7,727,200 bytes, mtime 2026-10-13) — existence holds, build identity unverified.
4. Scope refusal: the current host burner (`~/.local/share/burnerchrome/profile`, empty `NativeMessagingHosts`) is **not** asserted as the new target; the CLI's default knob cannot be read.
5. Re-verification requires the substrate restored at the pinned revision (`2408b0c9…`, 333 lines, `drift-baseline.tsv:1`) **or** a reviewed re-derivation of every line ref; the two declared rows stay deferred, not passed.
6. Recheck trigger (prose, not a legacy header): on substrate return, or on a 1Password CLI/desktop major release; reopen this erratum plus the 2026-09-28 text.
7. Explicit non-claims: no current hash, no behaviour claim, no lease-ownership change, no security posture, no depth claim.

**Preservation / expectation migration.** After the append, measure the new sha/lines/bytes and update `stamps.tsv:11` **in the same reviewed commit**; record the pre-append row `62020ad1… / 88 / 4320` as exact historic evidence in `corpus/lessons/round-22.md` (or the commit message). Sequence: append → measure → row update → commit. Do **not** change the `Reverify:` line (a second declaration breaks `docs`' exactly-one rule), do not add a `source:`/`verified-at:`/`recheck:` header block, do not rename/delete the entry, and do not re-pin without the append (that would launder the mismatch).

## 7. Exact recheck scope when the substrate returns

1. **Precondition pin:** `test -x ~/.local/bin/the-janitor`; `stat -c '%a %s'`; `wc -l`; `sha256sum`. Expected from `drift-baseline.tsv:1`: `755`, 333 lines, sha `2408b0c9…`. If the sha differs, **stop** treating the line refs as valid and re-derive by literal symbol search: `MUSKETEER_CHROME_PROFILE`, `NativeMessagingHosts`, `com.1password.1password.json`, `ONEPASSWORD_BROWSER_SUPPORT`, `MUSKETEER_CDP_PORT`, `cmd_cdp_ensure`, `cmd_cdp_status`, `open-popup`.
2. **Source re-read:** the ranges in entry:3-4, the quoted JSON at entry:35-42, the `L109–111` hint (entry:72-73) and the `L325–328` refusal (entry:62); record actual line numbers and content match/mismatch, including the `L22–26` vs `L27` discrepancy.
3. **Scratch writer:** `bash corpus/surface-census.sh --verbs` with a fresh `--verb-root` (row `R11-02`); expect `PROBE cdp-ensure-scratch: PASS` (manifest path = BrowserSupport, 2 origins, sole NMH entry, mode 600) and `PROBE cdp-ensure-missing-support: PASS` (exit 2, no file written). This covers entry:30-46 only; it does not test the live profile.
4. **Status probe:** `the-janitor cdp-bridge status`; record every field; compare with entry:48-55. No browser launch needed.
5. **Refusal probe:** `the-janitor cdp-bridge open-popup`; record exit and first stderr line; compare with entry:57-64. No vault DOM.
6. **Host observations (new, not reproduction):** `stat` on BrowserSupport; `op --version`; `stat` on the profile's NMH manifest. These replace the historical values; they do not reconcile them.
7. Only after 1-5 pass against the pinned revision (or a reviewed re-derivation) may a **new** correction mark this erratum discharged; never rewrite it.

## 8. Provenance (exact historic evidence)

| When | Evidence |
|---|---|
| 2026-09-28 22:27:11 -0300 | `2486643` added the entry, the `Reverify` line and the row `62020ad1… / 88 / 4320`; unchanged since |
| round 6 / r9 | `corpus/lessons/round-6-aggregator-audit.md:45` verified the `L22–26` ref by `sed -n` on the then-live host file |
| 2026-10-14 | `corpus/lessons/round-18.md:9-24` measures total substrate loss; `round-19-recensus.md:49` names `cdp-bridge-1password.md:78-79` and recommends marking the prose historical |
| 2026-10-19 19:45:42 -0300 | `e1544c1` (round-21) re-pinned other rows; this row untouched |
| 2026-10-19 22:05:06 -0300 | base `c2cab35`; row untouched |
| 2026-10-20 | this audit: byte match re-measured; host absence and `op` drift re-measured |

Bound carried: `corpus/knowledge/claim-ledger.md:387-395` (bound 17) already names this entry's `open-popup`/`op --version` lines as sentences no declared row touches. This audit confirms it and does not claim the bound is closed.

## 9. Remaining unknowns

1. Whether the-janitor's current revision still defaults to the-musketeer (source absent, no copy found).
2. Whether the manifest was actually present on 2026-09-28 (current OS install postdates it; prior state unrecorded).
3. Whether the two `allowed_origins` IDs are current for the installed 1Password beta `8.12.42_34.BETA-1` (vendor-side; not measured).
4. Whether `webzites lease acquire` semantics still match kake's note (command absent here).
5. The `L22–26` vs `L27` range discrepancy — needs source, not inference.

## 10. Limits and checks for the parent

- **No host gate was run** (`claim-ledger.sh verify/docs/cells`, `drift-pins.sh`, `surface-census.sh`, checklists). One passive loopback `curl` (exit 7) is disclosed above. No browser, no vault/account operation, no credentials, no package transaction.
- No `lsp` device is mounted in this session; all evidence is from text reads and metadata commands, not semantic-server proof.
- Working tree carried other seats' changes before this audit (`corpus/QUALITY.md`, `corpus/SOURCES.md`, `corpus/knowledge/onepassword-machine-credentials.md`, `corpus/knowledge/vault-openbao-token-lease-lifecycle.md`, untracked `corpus/lessons/round-22.md`); the audited target and `stamps.tsv` were clean and were not modified.
- Parent should run after integration: `bash corpus/claim-ledger.sh verify` (expect `deferred` includes R11-01/R11-02), `bash corpus/claim-ledger.sh docs` (expect this entry declared/pinned), a re-check that the post-append row equals `sha256sum/wc -lc` of the appended file, and `git diff --stat` to prove the append is additive. Do not run a host gate expecting a fresh verdict for this entry while the substrate is absent.
