# AttackEntry04 — falsification of integrated C2 for `corpus/knowledge/checklist-execution.md`

Seat: `KagiR22.AttackEntry04` (leaf reviewer; no subagents; no host gates run; no installs).
Axes: **calibration** (erratum coverage of the build-wave findings) and **freshness**
(stamp/pin integrity, unchanged-prefix proof, no laundering). Lane freeze observed:
`falsify-start.json` `write_freeze` honored; only this report was written.

## 0. Read revisions and identities (exact)

| Object | Identity |
|---|---|
| Base (frozen BEFORE, historical) | `c2cab35bc92e57e39e5489bac3386db078345b3f` |
| Integration landing (read at `git rev-parse HEAD`) | `8ada17a50a25a75e6fc4a8cf880c87a85c67c8a3` (2026-10-20) |
| Worktree state at read time | clean for target + `corpus/stamps.tsv` (`git status --porcelain` empty) |
| Frozen BEFORE blob (base) | sha256 `2216efe217a9dc6ccd47f4372f485efb0cae81613da7650c788c06f7a52e58c8`, 190 lines, 13369 bytes |
| Integrated (current) file | sha256 `485e219a06c5b92f964620e6c2cab3ef35e1aef024aa7b0ce3bb89affba81fd6`, 206 lines, 14264 bytes |
| Manifest input for this path | `485e219a…81fd6`, 206/14264 — **exact** match to current worktree bytes (no in-flight divergence) |
| Current stamp row (stamps.tsv line 14) | `485e219a…81fd6` 206 14264 — **exact** |
| Frozen-before stamp row (stamps.tsv line 12) | `2216efe2…52e58c8` 190 13369 — matches frozen-before stamps.tsv digest `0ce7fa4f…c14e5b` (line-12 content confirmed against manifest `frozen/before/expected.json`) |

## 1. Changed-or-not verdict: CHANGED, append-only, exact accounting

- Only commit touching the file in `c2cab35..8ada17a`: `8ada17a`.
- `cmp` of the full 13369-byte frozen blob against the first 13369 bytes of the
  current file: **PREFIX_IDENTICAL** (byte-for-byte, no newline truncation, no
  mid-file edit, no reordering). The frozen-before text is proven byte-for-byte
  preserved as the current prefix.
- Whole-file diff `c2cab35 → 8ada17a`: exactly one hunk `191c191,207` — a pure
  EOF append of 16 lines (190→206). The appended block is `## Erratum (round 22 —
  historical execution and locator scope)` plus its body.
- **No laundering**: zero historic bytes deleted or rewritten; the wrong round-15
  span (D1) and the r9 attribution (D2) remain visible in the preserved body; the
  old stamp triple `2216efe2/190/13369` is preserved verbatim as `old_stamp` in
  `pin-migrations-integration.json` (38 stamp_changes, 0 removed_members).

## 2. Stamp-record reconciliation (freshness, exact)

- Old triple `2216efe2… / 190 / 13369` = frozen-before stamps.tsv line 12 = base
  blob identity. **No value drift between snapshot and base blob** (unlike the
  six stale rows; this file was pin-current at base).
- Migration record (`pin-migrations-integration.json` `stamp_changes[?]`, keyed by
  path, present, no duplicate): old triple matches frozen-before row exactly;
  new triple matches current row exactly; `base_observed` confirms the old pin
  was exact **at base** (so this is a deliberate, evidence-backed restamp, not
  drift repair).
- Integration pin check: `STAMPED: n=69`, `stamp_exit 0`; audit
  `REVISION_AUDIT: CLEAN (stale=0 missing=0 dropped=0 added=6 invalid=0)` with
  ADDED members exactly the six new corpus members. Membership grew 63→69,
  removed_members: 0. No dropped member; the nine round-21 replaced lines are a
  pre-integration historical span (`c41af82 → e1544c1`), not this file's event.

## 3. Erratum coverage vs build/Entry04.md findings D1–D5 (calibration)

| Finding | Entry04 build claim | Erratum text | Covered? |
|---|---|---|---|
| D1 wrong span `L420–447` | heading L420, items L431–453 at `587fda0`; L447 not an endpoint in any revision | "Use the named SKILL checklist section rather than the old numeric span; its heading and item endpoints do not share one range." | ✅ (naming Entry04.md as the narrowing authority; span not re-stated — correct, avoids a new unverified span) |
| D2 r9 attribution off-by-one | phrase absent r9, first r10, through r13, removed r15 | "The old scorecard phrase's historical revision attribution is narrowed in `…build/Entry04.md`" | ✅ (explicit delegation to the audit; no restated wrong claim) |
| D3 substrate loss / CLEAN baseline historic | round-15 baseline measured on substrate that has been absent since 2026-10-14; H8 vacuous pass | "historical — the round-15 CLEAN checklist baseline and handler-dependent row outcomes above are not current executions on an absent-substrate host. … Deferred live rows stay unverified." | ✅ |
| D4 allowlist provenance (2 docs + 1 fixture) | three matches = 2 documented + 1 selftest fixture | "The hygiene allowlist provenance includes a synthetic selftest fixture, not only documented prose examples." | ✅ |
| D5 modes sentence omits `--ratio` | modes list omits `--ratio`; R15-05 declares it | "The modes description also includes `--ratio` (declared by R15-05), which does not execute checklist rows." | ✅ |
| H8 vacuous-pass caveat | entry §6.5 "asserts its scope" fails on absent-substrate host | "A passing file-absence condition is not proof that the intended host file was inspected." | ✅ (generalized but directly covers the vacuous-pass class) |

All six findings covered; no false reading is left unmarked, none erased, none
silently rewritten. (D1/D2 covered by explicit pointer to Entry04.md — this is
admissible because `…/build/Entry04.md` is itself a committed artifact of the same
landing commit `8ada17a`, not an ephemeral scratch note; the pointer resolves within
the frozen tree.)

The erratum adds the correct negative rule: byte-pin exactness proves pointer
integrity only, **not** that host-dependent source facts are current — exactly the
"pointer freshness vs unavailable source facts" distinction the falsify dispatch
asks for. The entry's host-dependent facts (live gate outputs, H8 socket counts,
scheduling observation) are marked historical; they remain unreproducible here
(unavailable source facts — no host gate run, per boundary; substrate absent per
build evidence), while the byte layer is fully proven fresh at this landing.

## 4. One admissibility verdict

**ADMIT.** The integrated change to this entry is a pure EOF append, byte-proven
(no prefix mutation), whose stamp migration is fully documented
(old triple preserved, new triple exact, base_observed exact, 0 removed members,
audit CLEAN), and whose appended erratum marks every D1–D5 finding from
build/Entry04.md without deleting or rewriting any historic sentence — no
laundering. Restamp is correct: the bytes actually changed (append), so keeping
the old pin would have been a false claim of unchanged bytes; the old triple is
preserved in the migration record as required by QM14.

## 5. Residual risk / verification gaps (not defects in this entry)

1. The erratum's D1/D2 narrowings **delegate** rather than restate: the entry itself
   no longer carries the corrected span/attribution facts inline (they live in
   `build/Entry04.md` §1/§3-C). If a future reader treats the erratum as complete
   without following the pointer, the historic text still contains the false span
   as its only inline description. Mitigated by: Entry04.md is committed in the
   same tree; the erratum says "narrowed", not "corrected to X". Not laundering;
   an explicit, resolvable pointer. Low risk.
2. The erratum states "No checklist or host gate was executed for this static
   correction" — consistent with this seat's observation boundary and the build
   wave's read-only posture; **no runtime counter-evidence exists**. I did not
   (and must not) run the gate; the parent's global single revision-audit rerun
   remains parent duty; I analyzed this entry independently, and my independent
   stamp-row checks agree with `integration-pin-check.json`.
3. Host-dependent facts remain unverified at runtime (E-gate outputs, H8, timers,
   crontab) — unavailable source facts, correctly marked historical by the
   erratum rather than re-verified by restamping. Nothing in the integrated tree
   claims they are current.
4. `git status --porcelain` confirms the live lane is clean for the target and
   stamps.tsv at read time; bytes I hashed are the landing-commit bytes.

## 6. Checks the parent should run after integration

- `python3 corpus/revision-audit.py --history c2cab35bc92e57e39e5489bac3386db078345b3f` (parent's global single rerun)
- The pin-identity triple-check for this path (stamps.tsv line 14 vs worktree vs
  `8ada17a` blob) — all three passed in this seat already; parent may re-run as part of the global audit.
