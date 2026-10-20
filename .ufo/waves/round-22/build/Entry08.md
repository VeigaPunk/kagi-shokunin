# Entry08 — freshness/calibration audit: `credential-isolation.md` + its stamp row

Seat: `KagiR22.Entry08` (leaf scout, read-only). Round 22, axes **calibration** and **freshness**.
Read revision: `c2cab35bc92e57e39e5489bac3386db078345b3f` (frozen base). Working tree at first read:
only `?? .ufo/waves/`, `?? plans/round-22.md`. Sibling lanes wrote tracked files after my stamp sweep;
the separation is recorded in §2. No host gate was run; no build/lint/test/formatter; no install.
No depth claim and no legacy-header work.

## Verdict

| Question | Answer |
|---|---|
| Stale-byte mismatch for this entry? | **No.** All four stamp columns match exactly. |
| Substantive freshness verified? | **No — not measurable.** All sources cited by the entry are absent on this host. |
| Is the entry one of the six stale stamps? | **No.** |
| Is the entry one of the "nine deletions"? | **No.** The nine are row replacements, not membership loss (§3). |
| Is an appended correction to this entry needed? | **No** for truth or for the round-16 qualification rule. One **inbound pointer fix** in another file is needed (§4). |
| Restamp / delete / prune the row? | **No.** Any of those would be laundering or an unrecorded deletion. |

Classification: **byte-fresh, substantively unverified (substrate absent)**. The stamp proves the corpus
text has not drifted since round 14; it does not prove any host claim.

## 1. Byte audit (measured)

Stamp row, `corpus/stamps.tsv:16`:

```
corpus/knowledge/credential-isolation.md	03570c6578e3c9232e0babc23f3c249347502526cdddfa9e612fc3f126e113b3	78	3986
```

Measured with the same four columns `stamp_cmp()` compares (`corpus/claim-ledger.sh:334-350`):

- `sha256sum` → `03570c6578e3c9232e0babc23f3c249347502526cdddfa9e612fc3f126e113b3` (equal)
- `wc -l` → `78` (equal)
- `wc -c` → `3986` (equal)
- `stamp_cmp` return would be `0` (fresh); a final newline is present (78 lines at 3986 bytes).

History (all read-only Git inspection):

- The row was **added at `2486643`** (round-14, 2026-09-28 22:27:11 −0300) with these exact values and
  has been **byte-identical in every later `stamps.tsv` revision**: `2486643`, `587fda0`, `8a6ec16`,
  `bc1af88`, `fecee87`, `c41af82`, `e1544c1`. It is absent at `4b8c018` (round-13, 33 rows).
- The entry's **last content edit is `2486643`**; `git show 2486643:corpus/knowledge/credential-isolation.md | sha256sum`
  = `03570c6578e3…` — identical to HEAD. The pin and the content were created in the same commit, so
  there was never a window in which the pin lagged the bytes.
- `c2cab35` changed three files (`LOG.md`, `README.md`, `considerthese/2026-10-19.md`); **zero** of them
  match `credential`. The entry was untouched by the integration commit.
- `before.json` (`stale_stamps`, `stale_count: 6`) does **not** list this entry.

## 2. Ledger sweep and the six-vs-five discrepancy

At the base snapshot (before sibling writes), all 63 stamp rows compared read-only
(`sha256sum`/`wc -l`/`wc -c` per path):

- exact: 57
- stale: `corpus/knowledge/config-layering.md`, `corpus/knowledge/handler-on-disk-state.md`,
  `corpus/knowledge/handler-trust-boundary.md`, `corpus/knowledge/janitor-env-contract.md`,
  `corpus/lessons/round-18.md`, `LOG.md`
- missing / not-a-file: 0

This reproduces `before.json.stale_stamps` exactly (6, not 5). The plan's "five stale stamps" is the
round-21 lesson list (`corpus/lessons/round-21.md:85`, which names the same five files minus `LOG.md`).
`LOG.md` is the **later change**: `c2cab35` appended 7 lines (`1043→1050`, `74864→75404` per
`git diff c2cab35^ c2cab35 -- LOG.md`) without restamping. So the honest split is:

- 5 inherited stale stamps (four round-16-qualified entries + `round-18.md`), intentionally left unpinned
  by round 21 because re-pinning would bless unclaimed edits;
- 1 stale stamp (`LOG.md`) created by the integration commit itself — a generated log, but still a real
  unexplained mismatch until the integrator either restamps it with a recorded migration or records it
  as deliberate.

After sibling lanes wrote (second sweep): 11 stale = the six above **plus** the five in-flight modified
files (`corpus/claim-ledger.sh`, `corpus/QUALITY.md`, `corpus/SOURCES.md`,
`corpus/knowledge/onepassword-machine-credentials.md`,
`corpus/knowledge/vault-openbao-token-lease-lifecycle.md`). Those five are lane work, not inherited
debt, and must not be counted as round-22 findings. `credential-isolation.md` matched in both sweeps.

## 3. The "nine deletions" are restamps, not deletions

Command evidence: `git show c41af82 -- corpus/stamps.tsv` = **9 removed lines, 16 added lines**.
The nine removed paths are each re-added **in the same commit** with a new row. All nine rows are
reproduced verbatim below; each path is present in both revisions (membership check: zero paths lost):

```
OLD corpus/claim-ledger.tsv	c8369a51869bc6ffbf8602d460a59ad8f10a5fc309a95e68ed0c3178bcacda8d	49	13981
NEW corpus/claim-ledger.tsv	873eecf0e1809aef0ef1c97613f671312f1f19c4e50f1bde60edab440476a64e	54	16743
OLD corpus/knowledge/op-ref-consumption.md	dcd9389415efff269bc738e1409d6aae72fdb9970b1f8f6f109b96bc3391718a	307	21164
NEW corpus/knowledge/op-ref-consumption.md	b195cc69840b0b6df65e578d86c0457a4a74b1660dca2e8f4513275a190143dd	372	25290
OLD corpus/op-ref-probe.sh	509f084ad33229db5b7421e1da948c02f9d191a6098f7a449341cf9adc95da1c	660	28660
NEW corpus/op-ref-probe.sh	0f1945e8d8a8fc56aaee256180cd7badde466bc8ac91503aa1e1853e79044f4c	788	34362
OLD corpus/README.md	6ddda47d8babffe68bbef905eb37396d20c45a5c39fe217d1e5b91a981ddb292	86	18689
NEW corpus/README.md	21b7ce097d83db472f439a5f90bb58d084fd7e53da254a969b7f344d233290ae	118	22198
OLD LOG.md	e6db90d2a37c4b347e5b9a4e2373d1fc3a8a2747a9746be361358c04eb817e9b	762	56847
NEW LOG.md	5bd53b1416b5d580f631da5163f828203706c6786e50f84e74af213ac7318b26	1031	73471
OLD PROVINCE.md	ffe644a7b2cecfc8169de8393937214f563570a8413912069568fb7065648e17	53	8172
NEW PROVINCE.md	b8aa53827b5ce01dddf7dcf88d0f7afffe9b3ae011b3a74f8c76148faa2bff97	62	10429
OLD SCORECARD.md	f3e61bfe2e7878cb8a3ffe22bde79dd7b8479f416d4c8fa628468981fb58c113	446	66069
NEW SCORECARD.md	bbbc6f825e33a2c7a08956cfb6fbd1f5b224c757afd943d4d264b8327a5d1414	680	85780
OLD SHONEN.md	efe81fa75cc139e382a0b156074b541410434238163a7270f254cd3daad5c728	11	4695
NEW SHONEN.md	1bb89fc5c006f4a9f22a9e121f4533c15f65993a1db1b3d32fa81c57bb5c4277	12	1312
OLD SKILL.md	c2b3151c58dd81a856b283302c6fa365f26b348d42a74c9fbb16d45827c8be48	663	57062
NEW SKILL.md	030e14751b854df7554a9098147ae3d2f0357384a2739277e318f13b2a978ce5	665	58237
```

The +7 remaining added rows are new pins (`QUALITY.md`, `SOURCES.md`, three round-21 entries,
`round-21.md`, `sources-census.sh`). Note `SHONEN.md` shrank 4695 → 1312 bytes: a content rewrite,
but the path and its pin survived — again a restamp, not a deletion.

Set-level proof: for every revision of `corpus/stamps.tsv` (`4b8c018 → e1544c1`), the **path set never
loses a member**; row counts are `33 → 44 → 48 → 52 → 54 → 56 → 63 → 63`. The post-landing correction
`e1544c1` likewise removed 13 and re-added 13 rows with no membership change.

Conclusion: "nine deletions" is a `git diff | grep '^-'` line count of one landing commit, i.e. nine
**expectation migrations** (same path, new sha/lines/bytes). No historical stamp member was dropped;
`stamp`'s per-path shrink guard (`corpus/claim-ledger.sh:236-256`, refusal text at `:255`) was not bypassed and no `--prune`
appears in history. `credential-isolation.md` is in neither the nine nor the thirteen.

## 4. Calibration findings (feature-specific, bounded)

**4a. No hash assertion in current voice — correctly outside round-16's four-entry scope.**
The entry contains no `sha256` fragment; its header is `Source: …` + `All read 2026-09-28`
(`credential-isolation.md:3-5`). Round 19 named the defect class as current-voice hash/identity
assertions in four entries, and round 16 qualified exactly those four (`SCORECARD.md` §Round-19
correction and §Round-16 re-dispatch: `SOURCE_FRESHNESS: entries=4 historical=0 unqualified=4
absent_sources=3/3`; `f4a8dd9` errata in `config-layering`, `handler-on-disk-state`,
`handler-trust-boundary`, `janitor-env-contract`). This entry was not in that measured set and has no
hash to qualify. Appending "historical" prose solely for symmetry would be a **calibration judgment,
not a correction**.

**4b. Real inbound pointer drift (exact, byte-checkable).**
`corpus/knowledge/control-plane-hardening.md:31` cites `credential-isolation.md L37–51`.

- At the revision the pointer was written (`51c9d30`, round 7), `credential-isolation` L37–51 was
  exactly `## Agent permissions are deny-all + one tool` through `…no unrelated work.` (verified:
  `git show 51c9d30:corpus/knowledge/credential-isolation.md | sed -n '37,51p'`).
- `2486643` inserted the `Reverify: R11-01, R11-04` block + blank line at L7, shifting everything
  below by **+2**. The same 15 lines are now **L39–53**; `control-plane-hardening.md` was not
  re-anchored (its `2486643` diff only adds its own `Reverify` line).
- Today the citation lands on the `status`/`fallback disabled` bullet (L37) through the middle of the
  invariants (L51): two leading lines that were not intended, two trailing lines omitted.

Proposed minimal correction (in `control-plane-hardening.md`, **not** in this entry):
`L37–51` → `L39–53`. Drift-proof alternative: cite the section heading
`§Agent permissions are deny-all + one tool`.

Exact expectation migration if that fix lands (same commit, measured in memory against the clean file):

```
corpus/knowledge/control-plane-hardening.md
OLD dad0b983369f558bfd130f68d598561ba0a07974cff1c50cae583b7d7e2feaa7	182	10575
NEW 74130fc1b8ec637ea98a84e3e4a79e75e82474701c9bc510bd5c232b5801e7d4	182	10575
```

Lines and bytes are **unchanged**; only the sha differs. A count-only check would miss this edit; the
sha column catches it. `control-plane-hardening.md` is currently byte-exact against its pin, so an
edit without a same-commit re-pin turns it into a seventh stale row.

**4c. Provenance completeness of the entry header.**
The header names four sources; the body additionally cites `client.py` (L57) and
`~/.local/state/tac/handoff-status.json` (L66). Both are in the drift surface: `client.py` is hashed
(`8179b241…`), `handoff-status.json` is **NOHASH** (mode+lines only, by the private-custody policy in
`drift-pins.sh`). Therefore the `steps: 4` precedent's content is not byte-pinned, and the caveat's
`client.py` claim is pinned only transitively through R11-04.

**4d. The numbers no row asserts.** `claim-ledger.md` §Bounds, Class 6 (`:389-390`) names
`credential-isolation`'s "20 vars" count among the sentences no row touches. Precise statement: the
count is **not printed by any row**, but it is *conditionally reproducible* from the hash-pinned
`the-janitor` bytes; do not call it "unverifiable". The entry changed `~19` → `20` at `e64e81b`
(round 9) — a content edit on the same host read. Likewise `759 bytes` (L31) is not in
`drift-baseline.tsv` (which pins sha+lines+mode, not bytes), though it is recomputable from the pinned
artifact.

**4e. Non-issues.** `corpus/transcript-scan.sh:82` writes "credential-isolation.md L214-219"; in
context that is the *source* range quoted by the entry (the entry is 78 lines), not a pointer into the
entry — not stale. `corpus/op-cli-surface.md:57` cites "§1", which is anchor-stable.

## 5. Absent-source limits (measured today, 2026-10-20)

`stat` results for every surface the entry cites or uses:

| Surface | Status |
|---|---|
| `~/.local/bin/the-janitor` | absent (also the substrate-detection predicate, so R11-01/R11-04 **DEFER**) |
| `~/.config/the-janitor/` | directory absent (so `opencode.json`, `client.py` absent) |
| `~/.config/opencode/agents/janitor.md` | absent (`agents/` subtree absent) |
| `~/.config/opencode/tools/janitor_auth.ts` | absent (`tools/` subtree absent) |
| `~/.local/state/the-janitor/`, `~/.local/state/tac/` | absent (so `handoff-status.json` absent) |
| `~/.config/opencode/` | **present but reduced**: `cli.json`, `opencode.json`, `service.json`; `opencode.json` is 5 lines/95 B/`fb067af0…` vs baseline 455 lines/`b270d762…` — changed revision, and **not one of this entry's sources** |

Consequences, bounded:

1. The entry's `Reverify: R11-01, R11-04` resolves to real rows (`claim-ledger.tsv:15,18`), both
   carrying the literal `[substrate]` tag. Under `substrate-deferral.md`'s contract they are
   `DEFER reason=substrate-absent`, never FAIL and never PASS. The link is honest but **unmeasured**;
   `deferred=N` is evidence of absence, not evidence the claims hold.
2. `R18-01` records the all-GONE drift verdict at 2026-10-14 (`files_ok=0 files_bad=15 …
   symbols_bad=20`). Today one baseline path exists at a **different** revision, which still counts
   `bad`; that does not resurrect any source of this entry.
3. No claim in the entry was re-verified by this audit. A byte pin is not a freshness verdict.

## 6. Conditional re-verifiability and provenance

`corpus/drift-baseline.tsv` has exactly **one commit** (`e64e81b`, 2026-09-28) and pins full sha256 for
`the-janitor` (`2408b0c9…57edd`), `client.py` (`8179b241…ce51`), the model overlay
(`a318e719…`), `janitor.md` (`c17e2638…`), and `janitor_auth.ts` (`2382d5af…`). That is the same day as
the entry's "All read 2026-09-28", so the source revision is **contemporaneous and content-addressed**,
not retro-fitted. If the substrate returns with those hashes, every static claim in the entry is about
exactly the bytes it was written against.

## 7. Appended-correction decision

**No correction is required in `credential-isolation.md`.**

- No sentence is falsified by any evidence available on this host.
- The header is past-tense dated, contains no hash asserted as current, and the stamp is exact.
- The round-16 rule as measured does not cover it (§4a).

The only required repair is **external** and mechanical: the `+2` pointer fix in
`control-plane-hardening.md` (§4b), with its stamp migration recorded.

If the integrator nevertheless wants entry-local absence provenance, an append is permitted **only**
under this shape (mirrors the round-16 errata, e.g. `handler-trust-boundary.md` §Historical-source
erratum):

```
## Historical-source status — round 22 (2026-10-20)
Source-status: historical — the four sources above were last read 2026-09-28 and are
absent on this host; recheck is deferred (substrate-deferral.md, R18-01), not passed.
```

Do **not** write "reverified", "current", or a new hash. An append changes the bytes, so the same
commit must re-pin the row and record the migration. Restamping with no content change is a no-op
(hash identical) and improves nothing; restamping an appended file without recording old→new is the
laundering pattern C2 forbids.

## 8. Exact proposed recheck scope (run only when the substrate is present)

Order matters: presence first, bytes second, semantics third. Expected values are the entry's own
claims; any mismatch is drift to adjudicate, **not** a licence to restamp the entry.

```bash
# S0 presence (same predicate as claim-ledger.sh substrate_present)
test -x "$HOME/.local/bin/the-janitor"; echo $?        # today 1; 0 = run S1+

# S1 bytes — R11-04 baseline (e64e81b)
sha256sum "$HOME/.local/bin/the-janitor" \
          "$HOME/.config/the-janitor/opencode.json" \
          "$HOME/.config/opencode/agents/janitor.md" \
          "$HOME/.config/opencode/tools/janitor_auth.ts" \
          "$HOME/.config/the-janitor/client.py"
# expect 2408b0c9…57edd / a318e719… / c17e2638… / 2382d5af… / 8179b241…ce51

# S2 cmd_serve anchors (the-janitor L186–226)
sed -n '186,226p' "$HOME/.local/bin/the-janitor"
# L194–210 two auth paths; L212–213 the "keep every model credential out" comment;
# L214–219 the unset list; L225 exec opencode serve --hostname 127.0.0.1 --port 40961
sed -n '190,191p;222,225p' "$HOME/.local/bin/the-janitor"   # XDG mkdir/chmod 700, env redirect, exec

# S3 the count (no asserting row; extract shape-dependent)
sed -n '212,219p' "$HOME/.local/bin/the-janitor"            # count unset operands; entry claims 20

# S4 model overlay
wc -c "$HOME/.config/the-janitor/opencode.json"             # expect 759
# keys: enabled_providers == ["qwen-local"]; model == small_model ==
# qwen-local/Qwen3-Coder-30B-A3B-Instruct-UD-IQ2_XXS; baseURL 127.0.0.1:8080/v1;
# autoupdate false; share "disabled"; default_agent "janitor"

# S5 agent contract
sed -n '1,12p' "$HOME/.config/opencode/agents/janitor.md"
# mode: primary; steps: 4; permission {"*": deny, janitor_auth: allow}

# S6 auth tool
wc -l "$HOME/.config/opencode/tools/janitor_auth.ts"        # expect 14
# stdin/stdout/stderr all ignore; exactly AUTH_OK (0) / AUTH_REQUIRED

# S7 runtime status (R11-01 arm; no vault read)
the-janitor status
# expect authorization process_memory_only; endpoint http://127.0.0.1:8080/v1; fallback disabled

# S8 precedent record (NOHASH: read only janitor_provenance, record no values)
# ~/.local/state/tac/handoff-status.json — the "maximum-steps text" precedent

# S9 caveat source
sed -n '22,38p' "$HOME/.config/the-janitor/client.py"       # request() pins "agent": "janitor"
```

Coverage mapping: R11-04 covers S1 (+S0); R11-01 covers S0 + surface modes/runtime shapes; S2–S9 are
reader steps with no asserting row (S3 and the 759-byte count are the named Class-6 gaps).

Stop condition: if S1 hashes differ from `drift-baseline.tsv`, the entry must **not** be re-stamped or
"refreshed". Record the drift, treat the source revision as changed, and re-adjudicate the affected
claims; a new human read is required before any new stamp row.

## 9. Append-only preservation requirement (if any edit is ever made here)

1. **Byte-prefix preservation.** The current 3986 bytes are the historic record. A pure append must
   satisfy `head -c 3986 <new-file> | sha256sum` = `03570c6578e3…`. Any rewrite that fails this is a
   content change and must be justified line-by-line, not presented as an append.
2. **Heading census.** The file has 7 heading lines:
   - `# Credential isolation of the janitor handler`
   - `## Authorization lives in one process`
   - `## Model boundary is fixed`
   - `## Agent permissions are deny-all + one tool`
   - `## Caveat: the ceiling binds the *agent*, not the port (round 7)`
   - ``## The `steps: 4` cap is load-bearing``
   - `## Falsification`

   This exact file already lost a section heading to an anchored `edit` in round 14, caught by a
   post-edit census and restored (`corpus/lessons/round-14.md:123-127`). Re-run the census after any
   edit.
3. **One `Reverify:` line.** The docs audit refuses two (`corpus/claim-ledger.sh:878`, exit 2) and
   refuses a `Reverify`-prefixed non-declaration. Do not touch L7 unless the pointer set genuinely
   changes.
4. **Stamp coupling.** An append/repin must update `corpus/stamps.tsv:16` in the **same commit** and
   record the migration explicitly (`old sha/lines/bytes → new`). No `--prune`, no row deletion, no
   row-set regeneration that could drop other paths (the guard would refuse it anyway).
5. **History stays history.** Do not rewrite "All read 2026-09-28"; do not add a `verified 2026-10-20`
   marker derived from a byte pin.

## 10. Limits of this audit

- Read-only. Only `read`/hash/stat/git-inspection used. No `corpus/*.sh` executed; no host gate run;
  no vault, account, service, package, or boot operation; no secret value printed (host config files
  were hashed/line-counted only).
- The six-stale count is a base-snapshot measurement; the working tree now carries five sibling edits
  that add five more stale rows (§2). Neither set is attributable to this entry.
- Unresolved: whether round 22 wants entry-local absence provenance. That is a policy choice, not a
  missing fact; my recommendation is no append (§7).
- No depth claim; no header-count freshness proxy; no outside-lane agreement claimed.

## 11. Checks the parent should run after integration

- `bash corpus/claim-ledger.sh docs` — expect `undeclared=0 missing_ids=0 unpinned=0`; entry count will
  be 25 in the current tree (24 at base + the in-flight `feature-bound-credential-review.md`).
- `bash corpus/claim-ledger.sh verify` — expect `DEFER` for R11-01/R11-04 (substrate absent); after any
  append or pointer fix, confirm the touched stamps are re-pinned and no new stale row appears beyond
  the inherited five + `LOG.md`.
- `bash corpus/claim-ledger.sh citations --docs corpus/knowledge/control-plane-hardening.md` after the
  `L39–53` fix.
- Heading census and prefix check from §9 if the entry is edited.
