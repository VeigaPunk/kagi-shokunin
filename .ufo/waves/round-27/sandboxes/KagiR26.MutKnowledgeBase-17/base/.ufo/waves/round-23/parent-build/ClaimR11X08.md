# ClaimR11X08 — R11-08 `bash corpus/claim-ledger.sh citations`

Scope: one claim row, read-only. No command from the ledger, no sibling gate, no
write outside this file. No tool installs.

## Revision observed

- Repo `kagi-shokunin`, HEAD `d218603b74099ddca0bd8f869516fc41db0979bf`; working
  tree clean except the untracked `.ufo/waves/round-23/`.
- Row: `corpus/claim-ledger.tsv:22` — expect `^CITATION_GATE: CLEAN \(cites=[1-9][0-9]*
  docs=[1-9][0-9]* unresolved=0 ephemeral=0`, exit `0`, timeout `300`; row text
  unchanged since round 11 (`301b9ec`).
- Last whole-corpus receipt: `.ufo/waves/round-22/final-verification.json:38`
  (`safe_rows[2]`), bound to `h1 = 8ada17a…` (file line 2): exit 0, last
  `CITATION_GATE: CLEAN (cites=1210 docs=63 unresolved=0 ephemeral=0 labeled=13)`,
  `seconds=40.372`. That is the **historical** evidence. No whole-corpus receipt
  exists for HEAD (`grep -rho 'CITATION_GATE: CLEAN (cites=…' .ufo` finds only
  `docs=63`, twice; `docs=64` never).

## Obligation → implementation (causality, not line count)

`corpus/claim-ledger.sh:1014-1023` — `citations` exits 1 iff
`CIT_UNRESOLVED>0 || CIT_EPHEMERAL>0` (1016, 1019); otherwise prints CLEAN, exit 0.
Doc set `default_docs` (518-530) is 7 root docs + 25 `corpus/knowledge/*.md` +
32 `corpus/lessons/*.md` = 64 today. The causal clauses are therefore
`unresolved=0 ephemeral=0`. `cites` is incremented *before* resolution (545, 561)
and includes labeled/ephemeral tokens; `docs` counts every opened doc, including
docs with no citations. The row's `[1-9][0-9]*` floors are count shape only — the
corpus documents this deliberately: "the ledger row asserts only the verdict + the
non-zero shape of the counts" (`corpus/knowledge/claim-ledger.md:290-296`).

Last-line rule: `verify_claims` takes the last non-empty line and applies exit
equality first (400-446); the summary is emitted after all detail lines
(1014-1023), and the h1 receipt's `last` field confirms the summary is final.
**Verdict form, exit 0 and 300 s are justified**: the measured 40.372 s leaves
~7× headroom; the prefix-anchored ERE intentionally tolerates `labeled=N)`.

## Finding 1 — the frozen expectation is not produced at HEAD (false-FAIL / stale pin)

Three class-shaped tokens in the default doc set cannot resolve:

| pointer | class | why |
|---|---|---|
| `corpus/lessons/round-22-verifier-spotcheck.md:52` | local | one token `'corpus/knowledge/handler-trust-boundary.md','corpus/knowledge/janitor-env-contract.md` (both files exist; the comma-joined *list* is one token) |
| same file `:53` | local | `'corpus/lessons/round-18.md','LOG.md']` (both exist; same join) |
| same file `:62` | ufo | `.ufo/waves/round-22/frozen/before/` — exists only under `kagi-shokunin/.ufo`; `cite_target` maps `.ufo/` to `$ROOT/../.ufo` (485-487) = the *main* repo `.ufo`, which has no `waves/round-22` |

`norm_tok` (492-516) strips quotes/punctuation but not the internal `','`, so a
comma-joined path list is classified as one path. Derived summary at HEAD:
`CITATION_GATE: BROKEN (cites=1378 docs=64 unresolved=3 ephemeral=0 labeled=13)`,
exit 1 → `verify_claims` reports `FAIL … reason=exit-mismatch exit=1 want=0`, and
`verify` is red for this row.

Cause: `d218603` adds exactly one file, this 184-line lesson (`git show --stat`),
*after* the h1 receipt; it is not in `corpus/stamps.tsv`. The lesson is a fenced
`text` block (lines 50-53) plus prose at 62; marker regex
`MARK_RE` (453) finds no dead-marker on those lines, so they are not labeled.

Evidence level: **derived**, not executed. The shipped `norm_tok`/`cite_class`/
`cite_target` were re-run verbatim in bash against the shipped doc set; the same
scan reproduces the h1 receipt's `labeled=13` and its exact LABELED lines
(`SKILL.md:295,635`, `claim-ledger.md:24,25,122,123`), which is the fidelity
anchor. The conclusion is robust even if the exact `cites` differs by a token:
at least the two joined lists cannot resolve in any layout.

## Finding 2 — consumer-visible false-clean: SKIP-SELF + a scored cell

- `cells_evidence` skips every cited row whose command contains `claim-ledger.sh`
  (816-819) and only increments `CL_SELF_SKIP`.
- The cells failure predicate (1006) does **not** include `CL_SELF_SKIP`; the
  CLEAN summary prints it as a count (1011-1012).
- `SCORECARD.md:75` — Round 11 post-move `freshness` cell — uses R11-08 as its
  evidence ("`CITATION_GATE` on the shipped docs, re-run by `R11-08`"). It is
  `row_pointed` and then skipped.
- Today R11-08 is red (Finding 1). So `CELL_AUDIT: CLEAN … self_skipped=N` is
  reachable while a scored freshness cell's evidence row fails, and no cells
  clause can see it.

Minimal synthetic falsifier (proposal for L1; not executed here): scratch root
with a stub `corpus/claim-ledger.sh` whose `citations` mode exits 1; claims row
`R9-01	bash corpus/claim-ledger.sh citations	^CITATION_GATE: CLEAN	0	5`; a
`## Round 9 — post-move` cell whose evidence column cites `R9-01`. `cells --root
SCRATCH` prints `SKIP-SELF R9-01` and `CELL_AUDIT: CLEAN … self_skipped=1`, while
`verify --root SCRATCH` FAILs R9-01. Expected correct behavior: a skipped cited
row must not be silently absorbed by a CLEAN verdict (e.g. fail on
`self_skipped>0` unless the row is separately re-run).

## [substrate] / SKIP-SELF / hermetic

- **[substrate]**: absent, and must stay absent. `substrate_present()` (140-151)
  tests `$HOME/.local/bin/the-janitor`; `citations` never touches it. Tagging the
  row would turn a real citation failure into `DEFER` on handler-absent hosts —
  a false clean. The real host dependence is *layout*, and it is untagged.
- **SKIP-SELF**: preserves boundedness (no nested unbounded audit), not the
  obligation. The obligation survives only through `verify` at the integration
  revision; `cells` must never be read as having re-run this row.
- **Hermetic synthetic mode**: `cite_target` escapes `$ROOT` for `.ufo/`, `ufo/`
  and `*-shokunin/` (480-490). A scratch root placed as `<fresh-parent>/kagi-shokunin`
  resolves those classes against `<fresh-parent>/.ufo` — so a hermetic fixture
  must either build `<fresh-parent>/.ufo` and sibling dirs, or use corpus-local
  tokens only; and the scratch root must not sit inside the fleet root, or real
  host trees are read. The row's argv has no `--docs`, so a hermetic copy must
  also carry all 7 root docs plus `corpus/README.md` (else `die "doc not found"`,
  exit 2).

## What C1 / C3 must retain for this row

- **C1 (closure disposition)**: compute the disposition from the *current*
  revision's pointer set — not from `cites=1210 docs=63` (h1) and not from the
  floor regexes. Record the three concrete pointers above. A scoped
  `citations --docs <one file>` run (as in `.ufo/waves/round-22/build/Entry06.md:247`)
  does **not** discharge R11-08. `labeled=` is unbounded and unasserted — the only
  silent-growth channel; C1 should report it, not consume it as assurance.
- **C3 (hermetic cells)**: retain R11-08 as *carried, not verified* (SKIP-SELF);
  retain the `<fresh-parent>/.ufo` construction rule; never run the live gate
  (use a scratch copy or the synthetic fixture above). R11-08 is not a
  substrate-touching command, but the audit contract forbids executing it live.

## Fix recommendation (for the single L1)

1. Doc fix, either arm: split the two hex-list lines into separated tokens and
   cite the lane tree as `kagi-shokunin/.ufo/waves/round-22/frozen/before/`
   (sibling class, resolves; established at `corpus/README.md:126` and
   `corpus/lessons/round-20.md:3`); **or** label those lines dead. Re-stamp only
   if the file is pinned (it is not in `stamps.tsv` today).
2. Gate fix (mechanism): in `norm_tok`/`citations`, split on `','` boundaries
   before classification so a comma-joined list of existing files cannot become a
   phantom path. This is the false-FAIL shape that recurs.
3. Harden the row: assert `labeled=` (or a labeled *set*) so dead-citation growth
   is not invisible; do not add `[substrate]`.
4. C3: make a cited-but-SKIP-SELF row a visible obligation, not a CLEAN-absorbed
   count (bounded re-entry still possible: re-run such rows once in a child
   process with depth+1, or fail the cell audit when `self_skipped>0`).

## Limits

- No gate, ledger row, or sibling gate was executed. Finding 1 is a static
  re-derivation with the shipped functions on the shipped doc set; exact
  `cites`/`labeled` may shift with any doc edit, and only an execution at the
  integration revision can pin it.
- I did not evaluate other rows; a `cells` CLEAN at HEAD may still be blocked by
  sibling rows, which I did not run.
- The `.ufo/` and sibling mappings assume the fleet parent is
  `/home/vgpnk/Projects/shokunin`; a differently rooted checkout changes the `ufo`
  arm (and the row note's lone-clone failure still applies).
- Timeout headroom is measured from the h1 receipt (40.372 s), not re-timed here.
