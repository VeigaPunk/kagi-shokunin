# AttackEntry09 — falsification of integrated C2 for `corpus/knowledge/drift-gate.md`

Seat: AttackEntry09, reviewer, leaf member (no dispatch). Wave: kagi-r22-falsify.
Axes: **calibration, freshness**. Frozen base: `c2cab35bc92e57e39e5489bac3386db078345b3f`.
Measured integration landing read from branch `master` tip: **`8ada17a50a25a75e6fc4a8cf880c87a85c67c8a3`** (confirmed
by `git branch --show-current` + `git rev-parse HEAD`; never inferred from detached HEAD).
Method: read-only bytes + git objects + frozen-before copies. No host gate run, no host file read,
no installs, no production writes. Only file written: this report.

## 1. Frozen-input identity (named hashes from `integration-manifest.json`)

| Input | manifest sha256 | observed | verdict |
|---|---|---|---|
| `corpus/knowledge/drift-gate.md` | `ca3702fce29c0b1ba1349c49fdfb30478a06296c0227140245cbab79b2714da2` (14000 B / 215 ln) | identical (`sha256sum`/`wc -lc`) | matches |
| `corpus/stamps.tsv` | `88bbe15bf708283e7ee2dc0b6eda15671bb0d4352d3a935a634001853a314a29` (7213 B / 69 ln) | identical | matches |
| `corpus/claim-ledger.tsv` | `87fed349b7086893ea0a554f99bf857077db921d19dac82c0f68525777c3989a` (17770 B / 58 ln) | identical | matches |
| `corpus/drift-baseline.tsv` | `90c2d7a52360e97201b6fb766cd8f26fc653daa2a38bcefc40edcac6576c1bda` | identical | matches |
| `corpus/drift-pins.sh` | `c138d34c7f0dfe950fce0e5e6672cc788b5ad080bc388d4aef118db0e6c70feb` | identical | matches |
| `corpus/drift-symbols.tsv` | `dca651da9183e92ea74c61e687d89912e0ed38d79962fab0000331c4a36e515e` | identical | matches |

The working tree was **not** dirty for any attacked path (`git diff` empty for the doc and stamps);
the frozen manifest hashes equal the observed tree bytes at the landing commit.

## 2. Frozen-before vs current bytes — exact provenance of every change

The frozen-before corpus copy (`frozen/before/corpus/knowledge/drift-gate.md`) does **not exist**
(no such file; the frozen-before corpus carries only SOURCES.md, QUALITY.md, stamps.tsv,
claim-ledger.tsv and two knowledge entries). Two independent BEFORE sources were used instead:

- Frozen-before `corpus/stamps.tsv` row 17 (hash `0ce7fa4f97faef5ea8317fadaf5e412e8e5bfef2db532d57cb92b8af43c14e5b`,
  byte-identical to `git show c2cab35:corpus/stamps.tsv` — verified by diff, exit 0):
  `corpus/knowledge/drift-gate.md	c58dc5787a39c014884410e25cf6b6f6c0d1de77b2ad5d03726c773d04f0d0a0	201	13232`
- The base commit's own blob, extracted read-only to `/tmp/kagi-r22-ae09/old.md`:
  sha256 `c58dc578…0d0a`, 201 lines, 13232 bytes — exactly the frozen stamp values.

**Unchanged-prefix proof:** the first 13232 bytes of the current 14000-byte file hash and compare
equal to the base blob (`cmp` exit 0; prefix sha256 `4ebc269a1616855159faf255e9452a4be1d7042dc29cb20670f4fa48ae17821b`;
append-only tail sha256 `5635df8322ec8132ad9646fa46cb00335e4f4481080da5ad5800e55a6ff03dde`).
The only structural edit is one byte: the base file's final line had **no trailing newline**;
the integrated file adds a newline after "policy hooks." before the append. `git diff c2cab35..8ada17a`
reports exactly `15 insertions(+), 1 deletion(-)`, and the "deletion" is that newline join.
No base byte is otherwise altered — the appended correction **does not launder**; the superseded
text (lines 97 `644/755` class, lines 5–6 `L292–298`, lines 15–16 `git show HEAD:` command)
remains present verbatim, as required.

Appended block (lines 201–215): `## Erratum (round 22 — class labels and historical locators)`
covering (a) the overbroad "everything else, mode 644/755" class with the 600-row fact and the
no-secret-material policy framing, (b) the PROTOCOL anchor + `ea77bf0` anchor for the printer-era
count, and (c) the explicit statement that historical host CLEAN results remain measurements at
their recorded dates.

## 3. Stamp record reconciliation (freshness)

Current `corpus/stamps.tsv` row 19 (was 17 at base; two tool rows added above it):
`ca3702fce29c0b1ba1349c49fdfb30478a06296c0227140245cbab79b2714da2  215  14000` — exact against
observed bytes. The old expectation is not deleted: `pin-migrations-integration.json` records the
full old/new pair for this path (old_stamp line verbatim, `base_observed` sha/lines/bytes,
new_stamp line, disposition "Reviewed current round-22 artifact; historical source facts remain
historical. See round-22 lesson and named per-entry audit."). `removed_members` is an empty list;
membership moved 63 → 69 (6 added: two Python tools, feature-claims JSON, new entry, round-22
lesson, round-21-verifier-spotcheck lesson — the six ADDED lines of the revision audit).
`integration-pin-check.json` shows `STAMPED: n=69`, exit 0, and
`python3 corpus/revision-audit.py --history c2cab35…` → `CLEAN (stale=0 missing=0 dropped=0 added=6 invalid=0)`,
exit 0. No silent deletion, no unexplained rewrite for this entry.

## 4. Build/Entry09.md agreement

Committed `.ufo/waves/round-22/build/Entry09.md` (blob `ac017051e37388444d82865e99703ccd0c7c064f`,
11056 bytes, 173 lines — identical in both `8ada17a` and the in-flight snapshot `2039511`) prescribed
append-only correction of S1/S2/S3 plus same-commit stamp regeneration and a SCORECARD sweep.
The landing commit implements it: the erratum covers S1 (:97 class), S2 (:5–6 anchor) and S3 (:15–16
command); the stamp row was regenerated in the same commit; the old blob stays in git history.
**Residual gap:** Entry09's step 4 (sweep `SCORECARD.md:19`, which still carries the same stale
`PROTOCOL.md:292-298` range and the un-anchored `git show HEAD:…` command at current bytes) is
**not** covered by the drift-gate erratum and I found no erratum in SCORECARD.md (grep `Erratum`
in SCORECARD.md and SKILL.md: zero hits). SCORECARD.md:19's wording is arguably an in-record
historical claim (round-9 state), but Entry09 itself ordered the sweep; the integrated tree
contains no visible record that the sweep was adjudicated. This is a freshness/traceability
residual, not a false integrated claim about drift-gate.md itself.

## 5. Independent verification of the erratum's factual content (calibration)

- 600-row claim: `awk` over `corpus/drift-baseline.tsv` finds exactly one hashed row with mode 600
  (line 15, NativeMessagingHosts manifest, sha `05e1cd94…ce9b`); hashed-mode histogram **600×1, 644×5, 755×3**. Erratum's class correction is factually right.
- `ea77bf0` claim: `git show ea77bf0:kagi-shokunin/corpus/drift-pins.sh | grep -c baseline` → **0** (verified against the parent repo).
- PROTOCOL anchor: at parent `4c81066` (`2026-09-28 17:46:51 -0300`) the Drift-pins bullet sits at
  L292–298 with the then wording "a pin only counts if…"; at parent HEAD the bullet is L370 with
  "A pin counts only if…". Erratum's historic-locator framing is correct.
- `grep -c baseline` at the lane base blob → **16** (confirmed; the un-anchored command is indeed
  false as written today, and the erratum anchors it).

## 6. Pointer freshness vs unavailable source facts — correctly separated

The erratum's final sentence states host CLEAN results remain historical and that no private host
file was read and no live gate run in round 22. The build report likewise marked host verdicts
(`DRIFT_PINS: CLEAN`, selftest pass) UNADMITTED/deferred to a parent recheck. This is the correct
boundary: the stamp migration proves pointer integrity only, never currentness of host facts;
the four R22 ledger rows measure feature-claims/revision-audit executions, none of which re-verifies
host-private drift facts. No byte hash in the wave is presented as re-verifying the absent host
observations. No laundering or promotion of absent source facts to current was found for this entry.

## 7. Side observation (no action requested, recorded for completeness)

`--all` shows five additional commits (2026-10-20 19:13:43 -0300, author `kagi-shokunin`) not on
`master`: three full-tree snapshots (`0b07548`, `2848356`, `2039511`, tree `be60d5d2…`) that are
byte-identical to each other, one pruned snapshot (`a09a7ae`, tree `ca48c820…`, same 29 non-.ufo
production files), and one intermediate (`c1e1c42`). Their `drift-gate.md` and `stamps.tsv` blobs
are identical to `8ada17a`'s for every attacked path (`git diff 0b07548 a09a7ae` on both paths:
empty), so they do not alter this entry's verdict. Ancestry: `8ada17a` does NOT contain them and
vice versa (parallel tip vs orphaned snapshots). Also, the round-9 original blob
(`2c552e74…`, 12962 bytes, 196 lines, "19 rows", no `Reverify:` line) persists in the object store
via `e64e81b` — this is the documented round-9→round-13→round-14 doc-byte lineage, each paired
with a regenerated same-commit stamp row (visible in `git rev-list --all -- corpus/stamps.tsv`
output); no dropped member.

## Verdict (single admissibility verdict)

**ADMIT** the integrated C2 revision accounting for `corpus/knowledge/drift-gate.md`: frozen-before
expectation preserved by name and value; the 201→215-line change is proven byte-prefix-preserving
(append-only erratum + trailing-newline join) with the old sha retained in history and in the
migration record; the new stamp row matches observed bytes exactly in the landing commit; the
erratum's three factual corrections independently verify; pointer freshness is honestly separated
from unavailable host facts. No silent deletion, no laundering, no stale-byte mismatch.

Residual risk (does not overturn the verdict): Entry09's SCORECARD:19 sweep step has no visible
integrated adjudication record; parent should either record that adjudication or run the named
grep sweep when re-running the revision audit globally. Named parent checks (not run here):
`bash corpus/claim-ledger.sh verify` (no STALE/MISSING for this doc), `python3 corpus/revision-audit.py --history c2cab35…`, and the two Entry09 §Recheck grep sweeps over
`PROTOCOL.md:292` / `git show HEAD:corpus/drift-pins.sh`.
