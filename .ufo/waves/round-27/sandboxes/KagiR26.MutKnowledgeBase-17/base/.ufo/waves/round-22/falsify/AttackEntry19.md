# AttackEntry19 — fresh falsification of integrated C2/C1: `corpus/knowledge/sops-age-key-rotation.md`

Seat: `KagiR22.AttackEntry19` (leaf, read-only; no delegation). Axes: **calibration**, **freshness**.
Fresh attack of the integrated round-22 tree after the build wave. No host gate, no launcher, no
package manager, no loopback/CDP probe was invoked. Public documentation GETs (three curl digest
fetches) and read-only git/hash commands only. Installs: none.

## Read state (exact)

| item | value |
|---|---|
| read revision | `8ada17a50a25a75e6fc4a8cf880c87a85c67c8a3` (HEAD) — identical to the measured integration landing; `git status --porcelain` on the entry: clean; the landing commit (2026-10-20T19:13:44−03:00) is the entry's last touch |
| frozen base (historical BEFORE) | `c2cab35bc92e57e39e5489bac3386db078345b3f` |
| manifest input pin, target | `corpus/knowledge/sops-age-key-rotation.md` — sha256 `a6b14ff7555fb972368d23e1e57bfb62170daa65ee4f2bd34521ff6819d407a7`, 112 lines, 7591 bytes |
| observed worktree bytes | sha256 `a6b14ff7…407a7`, 112 lines, 7591 bytes — **equals the manifest pin exactly** |
| `corpus/stamps.tsv` | sha256 `88bbe15bf708283e7ee2dc0b6eda15671bb0d4352d3a935a634001853a314a29` — equals manifest input |
| `corpus/claim-ledger.tsv` | sha256 `87fed349b7086893ea0a554f99bf857077db921d19dac82c0f68525777c3989a` — equals manifest input |
| `corpus/SOURCES.md` | sha256 `3ba44518e2508f517d117c4678b3225f36b787ad645d9baf456c2a2da9023af7` — equals manifest input |
| prior build-wave state of this entry | `.ufo/waves/round-22/build/Entry19.md`: at `c2cab35` the entry was `ea99430f0417f67a644f50309f08f0f4ce42bec526b1d909a6f932b5c7ff81a2`, 99 lines, 6796 bytes, stamp exact — independently reproduced below from git, not taken on faith |

The falsification input is the frozen manifest tree, not the historical base; every hash below was
measured on the integrated tree at `8ada17a`.

## 1. Byte lineage — pure append proven, nothing above the append moved

```
git show c2cab35…:corpus/knowledge/sops-age-key-rotation.md | sha256sum
  -> ea99430f0417f67a644f50309f08f0f4ce42bec526b1d909a6f932b5c7ff81a2   (99 lines / 6796 bytes)
cmp <(git show c2cab35…:<path>) corpus/knowledge/sops-age-key-rotation.md
  -> "cmp: EOF on /dev/fd/63 after byte 6796"
```

`cmp` reports EOF on the base side after byte 6796 with zero differing bytes before it: the
integrated file is the frozen-base bytes **plus exactly 795 appended bytes**. Consequences, all
proven rather than inferred:

- The header (`source:` S009–S011, `verified-at: 2026-10-19`, `recheck: on-release … 9b7b84e`),
  the whole body, the round-21 Erratum (line 96) and its two corrections are **byte-identical** to
  the frozen base. No text was rewritten, re-dated, or reordered anywhere above the append.
- The append is lines 100–112: one blank line + `## Clarification (round 22 — command-specific
  recipient changes)` (12 lines). It names its provenance:
  `build/Source10.md` and `build/Source11.md`; both exist in the frozen wave tree and were read.

## 2. Freshness reconciliation (C2) — stamp, membership, migrations

- **Stamp exact.** `corpus/stamps.tsv:30` pins `a6b14ff7…` / 112 / 7591 — equal to the current
  bytes in sha, lines, and bytes. No stale-stamp mismatch for this path; the re-pin moved with the
  bytes in the same landing commit (QM5 honored).
- **Membership retained, six additions, zero drops.** Diff `frozen/before/corpus/stamps.tsv` →
  current: this path appears as one same-path replacement (old row `ea99430f…/99/6796`, new row
  `a6b14ff7…/112/7591`); the only new members are `corpus/feature-claims.json`,
  `corpus/feature-claims.py`, `corpus/knowledge/feature-bound-credential-review.md`,
  `corpus/lessons/round-21-verifier-spotcheck.md`, `corpus/lessons/round-22.md`,
  `corpus/revision-audit.py` — exactly 6 added, 0 dropped, matching the manifest
  `expected.revision_audit {added: 6, dropped: 0, invalid: 0, missing: 0, stale: 0}`.
- **"Nine dropped stamps" reconciled without laundering.** This path was one of the nine
  `corpus/` re-pin pairs in round-21's `e1544c1` commit. The committed wave evidence
  `.ufo/waves/round-22/historical-correction-pins.json` (span `c41af82` → `e1544c1`) carries the
  exact old→new triple for this path:
  `9d73d218aabcfc708fca03bb09221ba6f57f9963b6e6de0df3a975bbf3241599` / 94 / 6257 →
  `ea99430f…81a2` / 99 / 6796, with `removed_members: []` and `new_members: []` — the nine deleted
  diff lines were in-place re-pins, zero members lost. The current round-22 span's old→new is
  recoverable from `frozen/before/corpus/stamps.tsv` → `corpus/stamps.tsv`, motivated by the
  795-byte clarification append. Do **not** restore any old pin: every replacement has a
  preserved, committed motivation.
- **Ledger expectation migrated with exact historic evidence.** `claim-ledger.tsv:52` row R21-02
  now expects `rows=21 A=19 B=0 C=2 queued=1 mined=19 rejected=1 entries_sourced=4 legacy=21`
  (matching the manifest `source_rows: 21, entries_sourced: 4, legacy_entries: 21`); its note
  preserves the old 16-row / 3-entry expectation in prose, and the exact old expectation line is
  byte-recoverable from `c2cab35:corpus/claim-ledger.tsv` and the `frozen/before` copy. No
  expectation was silently re-blessed; nothing was loosened to make a run green.
- **Pointer freshness independently reproduced (2026-10-20, this session).** All three recorded
  fetch digests reproduce exactly live:
  S011 `d0ab8b201f1a…c2e180c`, S009 `a840727ea1a8…5b50b76`, S010 `fed6b2e14524…112192e`
  (`curl -sL --max-time 20 <url> | sha256sum`, per the method logged in the registry rows).
  The S009–S011 registry rows' immutable fields are unchanged in the integrated `SOURCES.md`.
- **No re-dating.** `verified-at: 2026-10-19` was not rewritten by the integration; the
  Clarification adds no new verification date and claims no re-verification. Historic statements
  remain historic.

**Pointer freshness vs source facts, kept distinct:** what is *proven current* is the citation
chain — the three vendor page digests match their recorded pins, so the pointers the entry cites
still resolve to the same bytes. What is *not* a source fact here: SOPS runtime behavior was never
executed on this host, by the build wave or by this seat; the entry's "documented, not measured"
scope remains the only honest reading, and the integrated tree does not pretend otherwise.

## 3. Calibration adjudication (C1) — does the append mark every false reading?

The single genuine false reading in this entry is the §Three different objects table row (line
16): read as a universal promise, "does not change the data key, the encrypted values" is wrong
for `rotate` with add/remove flags — S011's rotate generates a new data key, re-encrypts all
values, and can add/remove keys in the same invocation (build Source11 q1–q3, located at
§`rotate` command). This is exactly the E1/E3-class shape: a general-sounding table cell that a
reader could overgeneralize.

The Clarification marks it without rewriting the pinned body:

- "separate operations, not a promise that every command changing recipients leaves the data key
  unchanged" — kills the universal reading;
- "updatekeys alone is the recipient-synchronization operation" — matches q1;
- "rotate operation can combine recipient additions/removals with creation of a new data key and
  re-encryption" — matches q2+q3;
- extends the round-21 custodians erratum to existing-file threshold behavior;
- "The footer commit is a docs repository revision, not a measured SOPS release/runtime version" —
  matches Source11 F2 (getsops/docs commit `9b7b84e…`, authored 2026-05-15, committed 2026-06-23)
  and is the correct pointer-vs-version honesty;
- "No SOPS execution occurred" — scope honesty preserved.

Adjudicated non-defects remain non-defects, and the integration correctly did not act on them:
D3 (S011 anchor omits §Direct Editing — enumeration gap, build-adjudicated no-action), D2 (age
attribution — the entry body already binds age recipients to S009 §Encrypting using age
explicitly). No E1/E3-class overclaim survives unmarked in the integrated tree.

## 4. Findings by severity

**None blocking; none major.**

- **LOW — residual under-coverage (not a false reading).** S010's first sentence gates editing as
  well as decryption ("to edit or decrypt"); the entry's §Key groups covers decryption gating
  only, and Source10 (C7) proposed appending this edit-side bound, plus PGP/KMS-only product-path
  bounding. Not appended. It is an omission, not an asserted falsehood — the entry never says key
  groups affect decryption only — and the bound is discoverable one hop away via the entry's
  `Reviews:` pointer to Source10.md. Residual, does not disqualify.
- **LOW — bound carried without an [INFERENCE] marker.** The Clarification's existing-file
  threshold sentence limits the claim in its own wording but does not use the [INFERENCE] marker
  Source10 proposed. Cosmetic.
- **INFO — R21-02 migrated in place.** Source11 F5 recommended an appended successor ledger row;
  the integration instead updated the expectation in place with the old value preserved in the
  row note and exactly recoverable from the frozen base. Legal under the documented
  current-executable-snapshot mode; recorded here because it deviates from the build report's
  preference, not because it is wrong.
- **INFO — verification depth of my live check.** I reproduced the three fetch digests
  (pointer-level identity). I did not re-extract located page quotes this session; the build
  wave's located quotes (≤25 words, with URLs and dates) stand as the content-level evidence.
  Netlify cache caveat from Source11 F1 (mitigated there by the raw-source cross-check) was not
  re-mitigated here.

## 5. Admissibility verdict (one)

**ADMISSIBLE.** The integrated round-22 state of `corpus/knowledge/sops-age-key-rotation.md` is
byte-exact against the frozen manifest input; the round-22 change is a proven pure append (795
bytes) whose corrections mark the one real false reading and add the docs-commit-vs-release bound,
without rewriting, re-dating, or laundering any prior text; the stamp was re-pinned exactly in the
same landing with membership retained; the historic `9d73d218…→ea99430f…` migration is preserved
with `removed_members: []`, so the "nine dropped stamps" reconcile as re-pins, not deletions; and
the citation pointers were independently reproduced live on 2026-10-20. No correction to the
integrated tree is proposed.

## 6. Residual risk and verification gaps

- Global `revision-audit.py` rerun over all 69 stamp rows (parent duty, once): this seat verified
  only this path's row plus the manifest-level hashes of the two TSVs and `SOURCES.md`.
- The six base-stale paths (`config-layering`, `handler-on-disk-state`, `handler-trust-boundary`,
  `janitor-env-contract`, `round-18.md`, `LOG.md`) now carry manifest-equal pins in the integrated
  stamps.tsv — observed via the same diff — but their content hashes were not each re-derived
  here beyond the manifest cross-check.
- SOPS runtime remains unmeasured by anyone; if a future falsifier fires (page digest drift,
  footer commit change, or a release changing `updatekeys`/`rotate` semantics), the entry's
  `recheck` scope in build/Entry19.md §5 is the exact procedure.
- Parent checks already authorized after integration (not run by me, mid-flight):
  global revision audit once; `bash corpus/sources-census.sh` and the feature/revision selftests
  against the migrated expectations (`repaired-checks.json` records them green at integration).

## Installs

None. No package transaction, tool install, or service change was performed.
