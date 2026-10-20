# Source08 — S008 re-open: SOPS upstream README (round 22)

Seat: `KagiR22.Source08` (leaf scout, read-only). Axes: **calibration**, **freshness**.
No source-registry edit, no stamp/ledger edit, no install, no SOPS execution.

## Re-open record

- **URL:** https://raw.githubusercontent.com/getsops/sops/main/README.rst
- **Access date:** 2026-10-20 — HTTP 200 at 21:34:42Z (local 18:34:42 −03); re-hashed 21:39Z.
- **Bytes:** 1909 / 60 lines. **sha256** `63cb0a462ce23574365c0b692aa09ea2f632f4b4df2b5f4186d8c004b57e3440` — identical to the 2026-10-19 fetch recorded in the S008 row.
- **Headers observed:** `content-length: 1909`; `etag: "90bfe9e7d7b62a6656991851a7070e14bfe9c84e7a247f1562a065f8508be7c3"` (Fastly ETag, not a Git object id); `cache-control: max-age=300`.
- **Located quote** (§Documentation, line 18, rendered): “You can find the SOPS documentation on getsops.io under “Docs”.” — 10 words; the raw RST carries the two target URLs as reST link markup.
- **Anchored content:** lines 4–5 formats/backends; §Documentation; §Security; §License (MPL-2.0); §Authors (Mozilla 2015 → CNCF Sandbox 2023); §Credits. No command, config, recipient, key-group, or rotation text.
- **Product / path / status / eligibility qualifiers:** SOPS upstream `getsops/sops`, path `README.rst` only (the `docs/` subtree was not opened here); raw `main` file with no embedded version/commit (`no commit/version displayed` is literally true); current bytes equal the README at tag `v3.13.3` (released 2026-07-23) and the stub first shipped in `v3.13.1` (released 2026-05-16); public source file, no account/plan eligibility gate.
- **Falsifier:** a re-fetch whose sha256 differs from `63cb0a46…3440`; any commit after `50c790bf` restoring recipient/key-group/data-key text to README.rst; or https://getsops.io/docs/ no longer resolving (it returned HTTP 200 at 21:36:38Z today).

## Pin history (exact, GitHub commits API)

| revision | date (UTC) | README | sha256 | relevance |
|---|---|---|---|---|
| `50c790bf3e035a0dacca6424638343b200c657c4` | 2026-05-15T12:53:29Z | 60 lines / 1909 B | `63cb0a46…3440` | “Fix minimum Go version in contributor docs.” = current `main` bytes |
| `2905020350cc1a434b9cbd1637c468e4bf998692` | 2026-05-15T12:47:09Z | 59 / 1908 | `1a5a2d49…ad16` | “Redirect documentation to getsops.io.” — the commit that removed the mechanics |
| `1cb4eee2d8fed076670f86c9b6379629d1219f9b` | 2026-05-03T10:02:29Z | 2409 / 93476 | `188656a8…32a2` | “Add documentation.” = README at tag `v3.13.0`; contains age recipients (l.215), `updatekeys` (l.275), `rotate` (l.681), key groups (l.971) |
| tag `v3.12.0` README | released 2026-03-18 | 2380 lines | `c4ffd1b0…a2e1` | also contains `updatekeys`/`rotate` |

The row’s flip is therefore **historically demonstrated, not hypothetical**: every README revision before `29050203` carried the E2 mechanics; only the post-redirect main is a pointer stub.

## Associated entry claims — comparison

| # | claim (verbatim) | location | verdict |
|---|---|---|---|
| 1 | “contains no age-recipient, key-group, or data-key rotation procedure for E2” | `corpus/SOURCES.md:14` (S008 `teaches`) | **CONFIRMED** — artifact has no such procedure |
| 2 | “§Documentation; upstream `main` snapshot opened 2026-10-19, no commit/version displayed” | same row, `anchor` | **CONFIRMED as description**; pin debt: commit is now identifiable as `50c790bf`, release identity `v3.13.3` |
| 3 | “the raw upstream README.rst was also opened and is not cited — it now carries no usage text, only a pointer to getsops.io” | `corpus/knowledge/sops-age-key-rotation.md` header | **CONFIRMED** for “no usage text”; “only a pointer” is imprecise — the README also states formats/backends, backend list, MPL-2.0, authors. Not a decision error; optional one-line erratum in any future touch |
| 4 | “S008, the SOPS README now a pointer stub” | `LOG.md:1001–1004` | **CONFIRMED** — 1909-byte stub, no mechanics |
| 5 | “S008 SOPS README as support for E2 → rejected row” / “README carries no lifecycle mechanics” | `corpus/lessons/round-21.md:49`, `round-21-verifier-spotcheck.md:12` | **CONFIRMED** |
| 6 | “The rejected S008 is inside the sixteen opened sources, not an extra item added to that set. Its rejection stays recorded.” | live uncommitted round-22 Search-log erratum in `corpus/SOURCES.md` | **CONFIRMED** — S008 is one of S001–S016 and remains `rejected` |
| 7 | no entry cites S008 | `used-by` = `—`; census reject-shape CLEAN | **CONFIRMED** |

No associated claim overclaims S008 as mechanism support; the known E1/E3 overclaims concern different sources and are not adjudicated here.

## Calibration decision (QM13 framing)

- **Required decision:** reject S008 as mechanism support for E2; admit only bounded, feature-scoped facts.
- **Reject:** no age-recipient, key-group, or data-key rotation procedure exists in the artifact.
- **Bounded admission (product-scope only):** formats YAML/JSON/ENV/INI/BINARY; backends AWS KMS, GCP KMS, Azure Key Vault, HuaweiCloud KMS, age, PGP; documentation delegated to getsops.io; project/license identity.
- **False-admission traps avoided:** treating the backend list as recipient configuration; treating the §Documentation pointer as rotation content; attributing getsops.io page text (S009–S011) to this URL.
- **Decisions on re-open:** 1/1 correct reject; 0 false admissions; 0 missed overclaims. No new decision row was authored (QM13: decisions, not row counts).
- **E1/E3:** S008 bears on neither; no outside-agreement claim is made from this seat.

## Freshness and pin debt

### S008 itself
- Content is **not stale**: same sha across 2026-10-19 and 2026-10-20, and no commit has touched README.rst since 2026-05-15.
- The row is already byte-pinned in `teaches`; the only missing identity is the commit/release, now resolved to `50c790bf` / `v3.13.3`.
- **Recheck-clock mismatch:** URL is `main`, but `recheck` is `on-release`. Historic evidence for the gap: the stripping commit `29050203` (2026-05-15T12:47:09Z) reached a tag in `v3.13.1` the next day, but the release interval `v3.13.1`→`v3.13.2` was 45 days — a main-only restoring commit could sit unreleased that long. Proposed migration (only if the field is mutable; it is unvalidated free text in `sources-census.sh`): `on-release or README.rst commit on main`. Otherwise record the commit pin in the round-22 lesson/ledger note.
- **No superseding row is needed:** every immutable field re-verified true; the rejection verdict, scope, quote, and byte pin stand; a duplicate row for the same URL would inflate `rows`/tier counts without adding a decision. If the owner insists on in-row commit identity, that is a metadata migration, not a new source.

### Adjacent C2 evidence (for KagiR22; exact old/new values)

**1. The nine “deleted” stamp lines are nine in-place re-stamps.** `git diff aea7a4301 e1544c194 -- corpus/stamps.tsv` = 16 additions / 9 deletions, but path-set diff: **0 paths removed**, 7 paths added (`QUALITY.md`, `SOURCES.md`, the three round-21 knowledge entries, `lessons/round-21.md`, `sources-census.sh`), rows 56→63. The nine changed paths (old sha12/lines/bytes → new):

| path | old | new |
|---|---|---|
| `corpus/claim-ledger.tsv` | `c8369a51` 49/13981 | `8a4019cf` 54/16986 |
| `corpus/knowledge/op-ref-consumption.md` | `dcd93894` 307/21164 | `b195cc69` 372/25290 |
| `corpus/op-ref-probe.sh` | `509f084a` 660/28660 | `0f1945e8` 788/34362 |
| `corpus/README.md` | `6ddda47d` 86/18689 | `6837d22b` 118/22365 |
| `LOG.md` | `e6db90d2` 762/56847 | `60a8fd36` 1043/74864 |
| `PROVINCE.md` | `ffe644a7` 53/8172 | `4a346e2d` 62/10586 |
| `SCORECARD.md` | `f3e61bfe` 446/66069 | `29f9f023` 691/87010 |
| `SHONEN.md` | `efe81fa7` 11/4695 | `1bb89fc5` 12/1312 |
| `SKILL.md` | `c2b3151c` 663/57062 | `df05677f` 665/58395 |

This reconciles the outside verifier’s “9 lines deleted” without laundering: the rows were re-stamped after their content changed, and the migration is reconstructible from the old/new values above (QM14).

**2. Committed base `c2cab35b` stale stamps = 6:** the five named-debt rows (`knowledge/config-layering.md`, `handler-on-disk-state.md`, `handler-trust-boundary.md`, `janitor-env-contract.md`, `lessons/round-18.md` — `lessons/round-21.md` §Named debt says re-pinning without review would “bless edits no round claimed”) plus `LOG.md`, which `c2cab35` extended by 7 lines after its `e1544c1` stamp.

**3. Live worktree adds 4 more stale stamps** (uncommitted pre-wave edits, `git status` confirms): `corpus/SOURCES.md`, `corpus/QUALITY.md`, `knowledge/onepassword-machine-credentials.md`, `knowledge/vault-openbao-token-lease-lifecycle.md`. Measured audit at 21:37Z: **63 rows, 53 exact, 10 mismatched, 0 missing paths** (so the row set did not shrink; `R12-03`’s `63` still matches).

**4. `corpus/SOURCES.md` stamp migration (exact):** stamp row = `db134917…b332` / 43 lines / 14261 bytes, which is **exactly** the frozen-base `c2cab35b` file. Live at 21:39:21Z = `ebf88646…f4de2` / 66 lines / 18222 bytes. Cause is other lanes’ pre-wave additions (S017–S021, the round-22 search-log erratum and lesson), not S008: the S008 line is byte-identical to base (line sha256 `771e4306…321b` both sides), and the file moved 16757 → 17417 → 18222 bytes during this seat.

**5. `R21-02` expectation migration (do not update from a moving tree):** pinned expect `rows=16 A=14 B=0 C=2 queued=1 mined=14 rejected=1 entries_sourced=3 legacy=21` matches `c2cab35b` exactly. Observed `bash corpus/sources-census.sh` at 21:36Z: `CLEAN (rows=20 A=18 B=0 C=2 queued=1 mined=18 rejected=1 entries_sourced=3 legacy=21)` exit 0 — same contract, four new rows. At final snapshot 21:39:21Z: `FAILED (findings=1 rows=21)` with `SC_USEDBY_NOCITE id=S021 path=corpus/lessons/round-22.md`, because a sibling was mid-write. The ledger row should be re-pinned only after writers stop, recording old value, motivating rows (S017–S020 feature-specific sources; S021), and the observed CLEAN check above.

## Limits and unresolved

- No SOPS execution; no vendor documentation re-mined (S009–S011 belong to their own seats); GitHub API calls were unauthenticated and limited to path history/tags/releases.
- `claim-ledger.sh verify` was not run; the `R21-02` statement is a direct string comparison against the measured census output, not a ledger verdict.
- [INFERENCE] The four live extra stamp mismatches are pre-wave worktree edits, evidenced by `git status` and base-vs-worktree comparison; they are not committed migration records yet (QM14 requires one).
- The 21:39Z census FAIL is an in-flight sibling write, not an S008 defect and not this seat’s edit.
- Nothing installed or updated; no host, vault, account, fleet-repo, or lane-state operation.

**Report: `.ufo/waves/round-22/build/Source08.md`**
