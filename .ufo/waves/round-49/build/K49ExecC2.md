# K49ExecC2 — round-49 C2 candidate (calibration: self-counts STALE/SETUP 6 → 0)

Seat: K49ExecC2 (leaf executor). Lane: `/home/vgpnk/Projects/shokunin/kagi-shokunin`, branch `master`.
BASE `89afe91878f10805921d3caa67d28d21b33226da`; predeclaration `082bfb3f6baa2407df2a23c0489043495b4dce4d`.
Built and measured in a scratch `git clone --shared` at
`/fast/scratch/hyaku/kagi-r49/K49ExecC2/c` (toplevel asserted = that dir), detached at BASE.
**The lane tree was not edited.** Fixture commit: `378c991a832ccd94e5d3477b89c40fa5059e1aca` (`fixture`).

## Result

| measurement | command | BASE | candidate |
|---|---|---|---|
| frozen C2 counter | `bash plans/round-49-c2.sh <rev>` / `--tree <dir>` | `value=6` | `value=0` |
| `claim-ledger.sh docs` | `bash corpus/claim-ledger.sh docs` | `BROKEN (entries=36 row_linked=32 by_hand=3 undeclared=1 … unpinned=1 …)`, rc 1 | `CLEAN (entries=36 row_linked=33 by_hand=3 undeclared=0 missing_ids=0 unpinned=0 duplicate_reasons=0)`, rc 0 |
| `self-counts.py` | `python3 corpus/self-counts.py` | `stale=3 … setup=3` (rc 2) | `stale=0 … setup=0`, `policy=2` (rc 2 by design) |
| migration journal | `bash corpus/expect-journal.sh --base-ledger … --ledger … --journals …` | — | `EXPECT_JOURNAL: CLEAN (changed=2 journaled=2)`, rc 0 |

Verbatim counter lines (frozen instrument, unmodified):

```
BASE:      C2_SELF_COUNTS: value=6 keys=6 lines=63 self_counts_rc=2 SC-SKILL-STAMPS=STALE PV-STAMPS=STALE RD-STAMPS=STALE RD-DOCS-ROWLINKED=SETUP RD-DOCS-BYHAND=SETUP RD-DOCS-ENTRIES=SETUP
           SELF_COUNTS: POLICY (claims=63 stale=3 unlocated=0 ambiguous=0 policy=2 setup=3)
candidate: C2_SELF_COUNTS: value=0 keys=6 lines=63 self_counts_rc=2 SC-SKILL-STAMPS=OK PV-STAMPS=OK RD-STAMPS=OK RD-DOCS-ROWLINKED=OK RD-DOCS-BYHAND=OK RD-DOCS-ENTRIES=OK
           SELF_COUNTS: POLICY (claims=63 stale=0 unlocated=0 ambiguous=0 policy=2 setup=0)
```

## Every changed line

| file:line | old | new |
|---|---|---|
| `corpus/knowledge/iso-11770-3-edition-status.md:5` | *(absent)* | `Reverify: R21-02` |
| `corpus/knowledge/iso-11770-3-edition-status.md:6` | *(absent)* | sources-census parenthetical in the shape `sops-age-key-rotation.md:6` / `onepassword-machine-credentials.md:6` / `vault-openbao-token-lease-lifecycle.md` carry: R21-02 re-verifies the citation chain only (every `source:` id resolves to a `mined` `corpus/SOURCES.md` row whose `used-by` lists this entry), never page content, `recheck:` is the content clock; plus the reason no round-45 row exists (`R31-02`/`R33-02`/`R34-03` run the identical census command with the identical snapshot) |
| `corpus/README.md:65` | `122 rows (112 at round 37, …` | `124 rows (round 49: +1 for the round-45 ISO entry pin; the live count was already 123 at BASE because the round-42 lesson pin left this statement at 122; 112 at round 37, …` (history parenthetical kept) |
| `corpus/README.md:67` | `32 row-linked / 3 by-hand / 35 pinned (round 33: …` | `33 row-linked / 3 by-hand / 36 pinned (round 49: the round-45 ISO/IEC 11770-3 edition entry is now declared row-linked to R21-02 and pinned; round 33: …` (history kept) |
| `SKILL.md:46` | `(122 stamps + 86 claims + claim ids` | `(124 stamps + 86 claims + claim ids` |
| `PROVINCE.md:73` | ``verify` (122 revision stamps + 86 claim rows;` | ``verify` (124 revision stamps + 86 claim rows;` |
| `corpus/claim-ledger.tsv:28` (R12-03) | expect `^122$` | expect `^124$` + round-49 migration clause appended to the note |
| `corpus/claim-ledger.tsv:32` (R14-01) | expect `^DOC_AUDIT: CLEAN \(entries=35 row_linked=32 by_hand=3 undeclared=0 missing_ids=0 unpinned=0` | expect `^DOC_AUDIT: CLEAN \(entries=36 row_linked=33 by_hand=3 undeclared=0 missing_ids=0 unpinned=0 duplicate_reasons=0\)$` + round-49 migration clause in the note |
| `corpus/stamps.tsv` rows 5, 37, 97, 121, 124 | see “stamp rows” below | same |

No other line changed: `git diff --stat BASE HEAD` = 6 files, +13/−10; row count of `claim-ledger.tsv` unchanged (86).

## Why these six keys were red at BASE

1. `docs` was BROKEN: the round-45 ISO entry (`072bb0b`) landed with **no** `Reverify:` line and **no** stamp row,
   so `entries=36` with `undeclared=1 unpinned=1`, exit 1. `RD-DOCS-*` bind to `ledger:R14-01`, whose command is
   `bash corpus/claim-ledger.sh docs`; a non-zero exit is `SETUP` in `self-counts.py`, hence three `SETUP` keys.
2. The stated stamp count was 122 in `SKILL.md:46`, `PROVINCE.md:73`, `corpus/README.md:65` while
   `grep -c '[^[:space:]]' corpus/stamps.tsv` printed **123** — the round-42 lesson pin
   (`corpus/lessons/round-42.md`, commit `0cb7814`) joined the set without a migration. Hence three `STALE` keys.
   `R12-03` (the row that defines that number) still said `^122$` at BASE.

## R14-01 expectation migration (drafted, applied in the fixture, gate-validated)

`migration.json` (delivered beside this report) records both rows; `expect-journal.sh` reads
`migrations[]` with `id/command/old_expect/new_expect` and refuses anything else:

- `R14-01` — command `bash corpus/claim-ledger.sh docs`
  - old: `^DOC_AUDIT: CLEAN \(entries=35 row_linked=32 by_hand=3 undeclared=0 missing_ids=0 unpinned=0`
  - new: `^DOC_AUDIT: CLEAN \(entries=36 row_linked=33 by_hand=3 undeclared=0 missing_ids=0 unpinned=0 duplicate_reasons=0\)$`
- `R12-03` — command `grep -c '[^[:space:]]' corpus/stamps.tsv`
  - old: `^122$` → new: `^124$`

The new `R14-01` expect is fully literal and anchored (expect-journal rule R3), replacing the old prefix form with
the complete final line. Gate run: `EXPECT_JOURNAL: CLEAN (changed=2 journaled=2)`, rc 0 — i.e. the only two rows
whose expect changed are the two journaled ones, and both new expects equal the candidate expect literally.

BASE red witness: `verify --only` is **not supported** (`grep -c -- '--only' corpus/claim-ledger.sh` = 0; the usage
block lists `verify|citations|cells|docs`, `stamp`, `--selftest`). The narrowest supported mode is the row's own
command: `bash corpus/claim-ledger.sh docs` → `DOC_AUDIT: BROKEN (…)`, rc 1 at BASE. For R12-03 the row's own
command printed `123` against `^122$`.

## Stamp rows changed (safe restamp)

`stamp` replaces the whole row set, so every pinned path was named again plus the new one:
`mapfile -t P < <(cut -f1 corpus/stamps.tsv)` (123 paths) → `bash corpus/claim-ledger.sh stamp "${P[@]}" corpus/knowledge/iso-11770-3-edition-status.md`
→ `STAMPED: n=124 out=…/corpus/stamps.tsv`.

| row | line | old sha (12) | new sha (12) | lines | bytes |
|---|---|---|---|---|---|
| `corpus/claim-ledger.tsv` | 5 | `6e16d8a1cd48` | `30a26a0d84e7` | 104 | 49750 → 50612 |
| `corpus/knowledge/iso-11770-3-edition-status.md` | 37 | *(new row)* | `87378a21a737` | 67 | 4441 |
| `corpus/README.md` | 97 | `aa8baef93cfd` | `1eb7d7f0c7c6` | 254 | 35282 → 35530 |
| `PROVINCE.md` | 121 | `62864009b527` | `305948f70b9c` | 110 | 20632 (unchanged) |
| `SKILL.md` | 124 | `9d909ca109b9` | `b845f5c9464f` | 831 | 83627 (unchanged) |

No other stamp row moved (verified by diffing the pre-stamp copy against the regenerated file: exactly these five
paths). `corpus/claim-ledger.sh` and `corpus/self-counts.py`/`.tsv` are byte-identical to BASE, so the counter's
G1/G2 guards hold; G3 (every BASE knowledge entry present) and G4 (no BASE stamp path dropped) hold — 124 ⊇ 123.

## What the counter proves, and what it does not

- Proves: the six frozen keys' statements now equal their live sources in the measured revision, and the
  `docs` row's command exits 0 with the declared counts. The counter's own guards (G1–G6) all passed
  (`lines=63`, `self_counts_rc=2`, POLICY set exactly `PV-FEEDTOKEN-SHAPES,PV-FEEDTOKEN-SELFTEST`).
- Does not prove: that the ISO entry's *content* is true (R21-02 checks the citation chain, not page content),
  that other rows are green (full `verify` was not run — not named by this item), or that the two POLICY keys
  are correct (they are the operator-routed R29-01/R29-02 boundary and stay POLICY by design; `self-counts.py`
  exits 2 because of them at BASE and at the candidate alike).

## Routed findings (not applied — outside this seat's patch)

1. **`R21-02`/`R31-02`/`R33-02`/`R34-03` are stale at BASE.** All four run `bash corpus/sources-census.sh` and
   expect `rows=98 … entries_sourced=14`; the live census prints
   `rows=104 A=100 B=2 C=2 queued=1 mined=99 rejected=4 entries_sourced=15 legacy=21 captures=104 inrow=16 inrow_only=0 inrow_nonreproducing=12`.
   The registry grew after round 30 (S100–S104 and the round-47/48 rows) without migrating these rows. The new
   declaration points at `R21-02` because it is the canonical row every other source-backed entry uses and no
   round-45 row exists; `docs` only requires the id to resolve, so the pointer is valid, but the row itself is red
   until a separate migration lands. This is pre-existing at BASE (not caused by this patch) and is not one of the
   six C2 keys.
2. **`R12-03` was already stale at BASE** (live 123 vs `^122$`) since `0cb7814`; the migration above records both
   the inherited +1 and this patch's +1 rather than hiding it.
3. **Round-45 landed the ISO entry undeclared and unpinned** — the defect this patch closes; the round-45 landing
   did not run `docs`.

## Reproduction

```
S=/fast/scratch/hyaku/kagi-r49/K49ExecC2; mkdir -p "$S"
git clone -q --shared /home/vgpnk/Projects/shokunin/kagi-shokunin "$S/c"
git -C "$S/c" rev-parse --show-toplevel            # must print $S/c
git -C "$S/c" checkout -q --detach 89afe91878f10805921d3caa67d28d21b33226da
git -C "$S/c" apply <this dir>/candidate.patch
git -C "$S/c" -c user.name=fixture -c user.email=fixture@scratch.invalid commit -qam fixture
bash /home/vgpnk/Projects/shokunin/kagi-shokunin/plans/round-49-c2.sh --tree "$S/c"   # value=0
bash /home/vgpnk/Projects/shokunin/kagi-shokunin/plans/round-49-c2.sh 89afe91878f10805921d3caa67d28d21b33226da  # value=6
```

## Safety

No OpenBao/Vault/1Password/SOPS contact, no `bao` process, no token or secret read or written (C2 is calibration
only). No host mutation, no package operation, no tool install. No `git add/commit` outside the scratch fixture;
no mutating `jj`. Lane writes limited to `.ufo/waves/round-49/build/K49ExecC2*`. Scratch removed on exit.

## Deliverables (`.ufo/waves/round-49/build/K49ExecC2/`)

- `candidate.patch` — `git -C "$D" diff BASE HEAD` (113 lines, 6 files)
- `migration.json` — the two-entry expectation journal (round-46 shape; validated by `expect-journal.sh`)
- `receipts.txt` — every command, rc and verbatim output
- this report

## Risks

- The patch changes four stamped docs and the ledger; any later edit to those files without a restamp makes
  `verify` report `STALE` (by design — the stamp is the revision pin).
- The new `R14-01` expect is anchored at the end of the line; a future extra field in the `DOC_AUDIT: CLEAN` verdict
  (e.g. a new counter) would make the row red rather than silently pass — intended, but it means the next
  verdict-shape change needs a journaled migration.
- `R21-02`'s staleness (finding 1) will keep `verify` red on four rows until routed; the C2 counter does not read it.

SEAT-STATUS: complete
