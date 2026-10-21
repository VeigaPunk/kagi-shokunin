# FDeriveVault — round-28 falsify: G2 (Vault feed S034) group lowered, S012 unaffected

**Verdict: PASS for pinned candidate 62a33b1** on this carrier — G2 rejected with exactly the four typed `DERIVATION` findings; S012 unaffected — **plus one honest residual limit** (§4): the G2 lowering moves the shared vault feed floor, so "S012 unaffected" holds only in the narrow sense that no new finding names S012. The residual does **not** make G2 pass CLEAN.

Method: `git archive` of the pinned rev into an isolated sandbox (`.ufo/waves/round-28/sandboxes/FDeriveVault/`), never the lane checkout; exported trees deleted after retaining small receipts (`receipts/`, 44 KB). No network: the observe probe served the **authentic cached** Vault feed body `.ufo/waves/round-26/build/ClockS024-artifacts/vault-releases.atom`, sha256 `e41bc579…388670ba` == the sha256 recorded for S034 at `corpus/source-fetches.tsv:77` and in every S012/S013/S022/S023/S024 receipt record.

## 1. G2 fixture, independently authored (not the frozen tool's builder)

Table-only edit of `corpus/release-clocks.tsv`: feed S034's four author-declared `derived:` rows **S013, S022, S023, S024** get `anchored_version = observed_version = 2.1.9` (canonical, lower) and `verdict = not-fired`; exactly those four are mirrored (`parsed_version`, `verdict`) into a copy of the default receipt `.ufo/waves/round-26/observe-2.json` (`corpus/release-clock.py:547`). **S012 untouched** in table and receipt. Command `python3 -I -B g2.py <tree> CAND` (sandbox/g2.py).

- **62a33b1 cand → exit 1**, no traceback in stdout or stderr: `DERIVATION S013` / `DERIVATION S022` / `DERIVATION S023` / `DERIVATION S024`, then `RELEASE_CLOCK: FAILED (on_release=30 bound=30 unbound=0 observed=26 fired=3 derived=11)`.
- **3553d49 BASE → exit 0**, no traceback: `RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=3 derived=15)` — BASE accepts the forgery, as the plan predicts.
- **cand mutant (§3) → exit 0**: `RELEASE_CLOCK: CLEAN … fired=3 derived=15`.

**Exact typed category: `DERIVATION`** — not `RECEIPT-MISMATCH`/`INCONSISTENT`/`REGRESSED`. No fired verdict is written for the forged rows (`observed=26` not 30, `derived=11` not 15 — the four forged rows leave the counted set). Exit 1, not 0 and not 2.

**S012 unaffected, three ways** (`receipts/probe-perrow.txt`): (1) `S012` appears in **no** finding line (named ids = exactly {S013,S022,S023,S024}); (2) S012 keeps `verdict=fired`, `observed=2.2.0`, `anchor=v1.21.x` and is counted in `fired=3`, same as BASE G2 and the control; (3) S012 is not a `derived:` row, so C2 does not apply by construction (`corpus/release-clock.py:618`: `if (is_derived and not non_canonical and …)`).

## 2. Frozen counting command, cross-check

`python3 -I -B .ufo/waves/round-28/tools/c2-measure.py 62a33b1… CAND <out.json>` → **exit 0**, `"C2_MEASURE CAND: groups_accepted_clean=0/4 derivation_exact=4/4 control_clean=True default_exit=0"`. G2 block: `exit=1`, `findings=["DERIVATION S013","DERIVATION S022","DERIVATION S023","DERIVATION S024"]`, `finding_categories=["DERIVATION"×4]`, `named_ids=[S013,S022,S023,S024]`, `derivation_exact=true`, `accepted_clean=false`; control `CLEAN (…fired=3 derived=15)` exit 0. My independent fixture reproduces the tool's G2 findings exactly (`receipts/c2-measure-cand-62a33b1.json`).

## 3. Candidate code path, and proof the finding is the new rule

- `corpus/release-clock.py:349` `derived_anchor_bound(feed_anchor, anchored)` — binding predicate (anchor CELL only, never `teaches`).
- `corpus/release-clock.py:618-625` — enforcement: `if (is_derived and not non_canonical and feed_source is not None and not derived_anchor_bound(feed_source["anchor"], anchored)): errors.add(("DERIVATION", source_id))`.
- `corpus/release-clock.py:713` `print_result` prints `"%s %s" % (category, row_id)` ⇒ the line is exactly `DERIVATION S013`.
- Binding datum `corpus/SOURCES.md:40` (S034) anchor cell `Entry titled v2.2.0, tag link /releases/tag/v2.2.0, updated 2026-10-15T18:50:14Z; …` → stable-token set `{2.2.0}` ≠ `{2.1.9}` ⇒ unbound. `corpus/lessons/round-28.md:77`, `corpus/QUALITY.md:135` (QM28), `corpus/README.md:238` agree.
- **Not a receipt artifact:** the same G2 table edit with the receipt **not** mirrored → exit 1 with **both** `DERIVATION` and `RECEIPT-MISMATCH` on the same four rows (`receipts/probes-observe.txt` O2). DERIVATION is raised independently of the receipt path; the frozen fixture's receipt mirror is what keeps the category set purely `DERIVATION`. A generic receipt mismatch is **not** passed off as proof of the new rule.
- **Mutation witness** (sandbox only, production untouched): forcing `derived_anchor_bound` to return `True` restores `RELEASE_CLOCK: CLEAN (…fired=3 derived=15)` exit 0 on the same G2 fixture (`receipts/g2-MUT.txt`) — the rule, and only the rule, rejects G2.

## 4. Residual risk found on this carrier

**The G2 lowering moves the vault feed floor, and S012 has no anchor of its own.** `feed_floors` (`corpus/release-clock.py:440-460`) takes the **max numeric anchor over every row on the feed URL**. The vault feed's only numeric anchors are the four derived rows (S012's own anchor `v1.21.x` is non-numeric and contributes nothing), so lowering the group to 2.1.9 lowers the shared floor from 2.2.0 to 2.1.9 — and that floor is S012's **only** regression guard. Measured (`receipts/probe-floor.txt`): a stale S012 (observed 2.1.9) with the group untouched is `REGRESSED S012` at floor 2.2.0 in **both** revs; with the G2 lowering the floor is 2.1.9 and at BASE the run is `passed=True, errors=[]` — the stale S012 silently accepted — while the candidate gives `DERIVATION`×4, `passed=False`. The candidate still does **not** flag S012 itself: the forgery is caught only because the four derived rows are. If the forger *also* rewrites the S034 anchor cell, the compound run goes CLEAN at the candidate too (`receipts/probe-compound.txt`, `c3-cand-compound-with-sources-edit`: `passed=True, errors=[]`), carrying the stale S012 with it. This is C2's documented scope ("consistency between two committed files, not tamper evidence"), not a regression — but S012's own regression protection is defeatable through the same forgery. Named as a next step at `corpus/lessons/round-28.md:97-98` ("A derived row's id is not yet required in its feed row's scope list").

Other probes, all candidate (receipts in `receipts/`):
- **Partial lowering** (S013+S022 → 2.1.9, S023/S024 left at 2.2.0): exit 1, `DERIVATION S013/S022` **plus** `REGRESSED S013/S022` (untouched rows keep the floor at 2.2.0) — still refuses.
- **Forger edits the registry too** (S034 anchor cell → 2.1.9): exit 0 `CLEAN` — the disclosed limit at `corpus/lessons/round-28.md:95-98`, confirmed reachable, not a new defect.
- **Re-point** S013 to feed S033 keeping forged 2.1.9 → `DERIVATION S013` still fires (S033 names 3.13.3); re-point *and* self-consistent (3.13.3) → no DERIVATION: the disclosed re-point limit.
- **Observe mode, offline:** `--observe` writes `parsed_version=2.2.0, verdict=fired` for the four forged rows (the live feed really is at 2.2.0), then **exits 1** with `DERIVATION` on exactly those four; **BASE writes the same fired receipts and also exits 1** — pre-existing, not introduced by this candidate; what the candidate adds is the typed refusal. No traceback either rev.

## 5. What I did NOT check

- Did **not** re-run broad round gates/selftests in the lane checkout; the only selftest run was the candidate's own `python3 -I -B corpus/release-clock.py --selftest` → `RELEASE_CLOCK_SELFTEST: PASS (106 cases)` exit 0, inside the sandbox.
- Did **not** decompose G1/G3/G4 (S033/S035/S037); out of my carrier. Did **not** test live network feeds (none used). Did **not** audit C1 (`NON-CANONICAL`), ledger/stamps/self-counts, docs agreement, or the conformance tooling — other seats' carriers. Did not check `--observe` receipt content for other feeds (stubbed, so their RECEIPT-MISMATCHs in §4 are stub artifacts).
- Lane HEAD moved to `5e847472a66fe0b41bfc4c374a3659eace3bd4f8` ("falsifier repairs") during my run. Per L1's instruction I kept the **original candidate** results (all runs were against the exported `62a33b1` tree) and did not re-measure against 5e84747.

## Commands and exit codes

    git archive 62a33b1 | tar -x -C sandbox/cand      # exit 0 (read-only git)
    git archive 3553d49 | tar -x -C sandbox/base      # exit 0
    python3 -I -B g2.py <cand>    CAND   # clock exit 1 (wrapper exit 0)
    python3 -I -B g2.py <base>    BASE   # clock exit 0 (wrapper exit 0)
    python3 -I -B g2.py <mutant>  MUT    # clock exit 0 (wrapper exit 0)
    python3 -I -B .ufo/waves/round-28/tools/c2-measure.py 62a33b1… CAND out.json  # exit 0
    python3 -I -B corpus/release-clock.py --selftest        # exit 0, PASS (106 cases)

Tooling: no installs; system `python3` (3.14) only. No production file edited; the only writes are this report and the sandbox `receipts/`.
