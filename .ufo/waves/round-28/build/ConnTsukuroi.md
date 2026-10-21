# ConnTsukuroi — sibling-overlap scan for round 28 (C1 canonical version tokens, C2 derived-anchor binding)

Item: read-only overlap scan of `/home/vgpnk/Projects/shokunin/tsukuroi-shokunin` (update-safety gate,
pacman vercmp-style ordering) against kagi C1/C2. Sibling read at **HEAD `a61db549c6c425e6a865885009b278f62ae6ef0f`**
(working tree dirty from sibling's own rounds; blob shas below are `git rev-parse HEAD:<path>`).
kagi citations are at BASE `3553d499577084a6c98d7078906017840bbf7b28`; `corpus/release-clock.py`
sha256 `53823416d267e886d780fc347f6ef6f347592ba117ebc296e2148e88a2a136dc`, `corpus/SOURCES.md`
sha256 `daa3af5ed8440532a2ef73c36189f42f0a9b85c73cdbcb1bc81ff7227b8efd5f` — both byte-identical to the lane tree.
Nothing was written in the sibling repo; all runs were in my sandbox.

## Findings (frozen-text / predicate defects first; report, not redefinition)

**F1 — the frozen C1 fixture F1 is masked at BASE by two mechanisms, so its before-class is neither MISHANDLED nor TYPED.**
`release-clock.py:425-444` (`receipt_matches`) compares the table's `observed_version` to the receipt's
`parsed_version` with `norm_version` string equality (`:443-444`), and the default receipt is digest-pinned
(`:28 DEFAULT_RECEIPT_SHA256`, applied at `:1745`). Runs (sandbox roots = BASE tree, receipt copied in):
- table-only edit (F1 as frozen): `python3 -I -B base/corpus/release-clock.py --root f1` → exit 1,
  `RECEIPT-MISMATCH S040`, `FAILED (… observed=29 …)`, **no traceback, no typed canonicality finding**.
- table + receipt co-edit (`S040 parsed_version=3.15.01`): exit 1, `RECEIPT-MISMATCH S040/S041`,
  `observed=0` (bundle invalidated by the digest pin; sha of my edited receipt `d8a9c327…` vs pin `13b8540c…`).
- control: `--root base` → exit 0, `RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=3 derived=15)` — exactly the plan's string.
The leading-zero fired read is reachable (a) only through `--observe` (F3, below) or (b) by also re-pinning the
digest constant — a source edit the frozen fixture text does not name. A measure script following the frozen
list literally will score F1 as a third class, so "MISHANDLED k/4 → 0/4" is not achievable as written for F1.

**F2 — the frozen F4 fixture is already handled at BASE in the observe path; the traceback is table-only.**
`observe_one` catches it: `release-clock.py:822` `except (OSError, ValueError) as exc: receipt["error"] = str(exc)`.
Offline stub of `request_body` (synthetic RSS bodies, no network), calling BASE `observe_one`:
`F3 (title "Python 3.15.01") -> verdict=fired, parsed=3.15.01`; `F4 (4301-digit patch) -> verdict=None,
error="Exceeds the limit (4300 digits)…"`, no traceback. So F4 at BASE is neither MISHANDLED (exit 1, no
traceback, no CLEAN, no fired observation) nor TYPED (the error string is not a typed finding naming the feed).
The >4300-digit `ValueError` traceback is real but only via the table path: `numeric_version` `:369-380`
(`tuple(int(part) …)` at `:380`) reached from `evaluate` `:567`; reproduced: table-only oversize edit → exit 1,
stderr `ValueError: Exceeds the limit (4300 digits) …` (F2 fixture). Same limit hit in `parse_latest_version`
`:760` (`max(stable, key=lambda v: tuple(int(part) …))`) — but there it is caught at `:822`.

**F3 — C2's literal rule is satisfied by all 15 derived rows at BASE (control safe), but its binding primitive
misattributes a defective registry token.** Predicate `version_is_named(sources[feed_source_id]["anchor"], anchored)`
(`release-clock.py:341-347`, string-escaped with lookarounds) over the BASE table: 15/15 `named=True`
(rows at `corpus/release-clocks.tsv:5-8,10-13,18-23,26`; feeds S033/S034/S035/S037), so the derived check
cannot disturb the CLEAN30 control. Counterexample: editing only `corpus/SOURCES.md:41` (S035) `v2.7.1`→`v2.7.01`
makes the rule flag **S014, S015, S016, S021, S025, S026** (6 rows) while the defect is in the registry row.
C1's frozen scope ("a version token used for an anchor, a table observation or a feed entry") does not cover
the registry anchor cell that C2 *reads*, so that token has no canonicality owner.

**F4 — C2 aliases derived anchors to a live registry anchor: a legitimate feed advance turns the default run red
for every derived row of that feed until re-anchoring.** The frozen G1–G4 fixtures lower both sides together,
so the feed-advance-only case is unpinned; it is a fail-closed cascade (the round-27 CritFinalC2 #3 shape), not
a defect, but L1 should know it is unmeasured.

## Sibling overlap — mechanisms, exact paths, disposition

| Sibling mechanism | Path:line @ HEAD blob | kagi touch point | Absorb or contradict |
|---|---|---|---|
| pacman `vercmp` direction (external alpm) | `tools/tsukuroi-census.sh:384` (VERCMP), `:1609-1610`, `:1631-1632`; blob `4610af7b3450…` | C1 ordering/canonicality | **Contradicts** if adopted: `vercmp 3.15.01 3.15.1` → `0`, `vercmp 3.15.001 3.15.01` → `0` (measured, exit 0). alpm normalizes numeric segments, so a comparator can never see C1's defect. C1 must stay lexical before any `int()` |
| version join keyed on version **strings** | `tools/tsukuroi-census.sh:1411-1430` (`version_join`, `rv[k] == inst[k]`) | C1 token equality | **Same class, opposite disposition**: a token differing only in spelling falls into `D` then `vercmp`=0 → `diff_unk` (silently folded into an aggregate), not a typed finding |
| silent canonicalization of dotted numbers | `tools/check-recheck-commands.py:496-498` (`section_key`, `".".join(str(int(part)) …)`; blob `830c442fd09d…`) | C1 canonicality | **Absorbs** (`07.2` ≡ `7.2`) where C1 must reject; carries the same `int()` hazard — replicated `section_key("1."+"1"*4301)` → `ValueError: Exceeds the limit (4300 digits)` |
| declared version bound to cited text | `tools/check-boot-chain.py:378-382` `BOOTCHAIN-VERSION` "claimed VERSION {version} appears in no cited line" (blob `81d331b81083…`) | **C2's closest analog** | Compatible: exact-substring, fail-closed, typed finding |
| closed typed error-code binding | `tools/_revision.py:172-193` (`E_INVALID`/`E_BRANCH_MISSING`/`E_NOT_LANDED`/`E_NOT_PUSHED`; blob `d646f9cc2930…`) | C1/C2 typed findings | Reusable pattern: a closed code set per defect class, so a fixture can assert "names a typed finding for this row/feed" instead of matching prose |
| announced-threshold reading of a public feed | `corpus/knowledge/arch-news-gate-2026.md:19-40` ("below the article's version threshold", "newer than the announced minimum") | C1 freshness axis | Narrative `[obs]/[inf]/[unk]` prose, no executable version-token rule; nothing to absorb |

**PROVINCE / adjacency verdict: no overlap claim to absorb or contradict.** tsukuroi's PROVINCE.md:3-6 owns
"package state … update-safety questions" (host pacman objects); its only kagi-facing rows are handoffs
`ADJ-02` (`PROVINCE.md:47`, blob `e1787e38f83e…`) and `OUT-003` (`:123`), both about credential-bearing
helpers — no row claims release-feed version identity. kagi's `corpus/adjacency.tsv` has no tsukuroi row
(`grep -c tsukuroi` → 0); it partitions host paths, not mechanisms. The two lanes compare *different objects*
(installed package `epoch:pkgver-pkgrel` vs documentation/feed release identity), so C1/C2 neither absorb nor
contradict sibling ground. The only real hazard is a reviewer's naming collision: kagi's S042 numeric-core rule
is not pacman ordering and must not be "aligned" with `vercmp`.

## Proposed move (one, bounded — advice to L1)

In C2's derived branch at `release-clock.py:565-566`, before applying `version_is_named`, apply **C1's own
canonicality predicate to the token read out of the feed row's anchor cell**, and attribute a failure to the
*feed row* with its own typed code (e.g. `DERIVED-FEED-NONCANONICAL <feed_source_id>`), not to the derived rows;
only then compare. This closes the one place C2 reads a token outside C1's scope (F3 counterexample: 6-row
misattribution, defect actually in `SOURCES.md:41`), is 15/15 clean at BASE either way, and leaves the control
string unchanged. Affected axes: calibration (improves: correct attribution, one finding instead of six, no
false cascade); freshness (neutral); no runtime/substrate surface touched. It is a synthesis of C1's predicate
with C2's binding rather than a new mechanism, and it is separable from both claims.

**Risks:** (a) check order matters — a non-canonical token on the *derived row itself* must stay C1's finding,
so the feed-token check must not pre-empt C1's row-level rule; (b) F4's coupling (feed advance) stays unmeasured;
(c) F1/F2/F4 fixture classes above need an explicit third-class record in the measure script, or the frozen
before/after counts cannot be reported honestly.

## Verification (what I ran)

All in `.ufo/waves/round-28/sandboxes/ConnTsukuroi/`; BASE tree via `git archive 3553d49… | tar -x` (exit 0).
- control: `python3 -I -B base/corpus/release-clock.py --root base` → exit 0, CLEAN30 string above.
- F1 (table-only), F1b (table+receipt), F2 (oversize table) → exits 1 as described; F2 stderr traceback shown.
- F3/F4: BASE `parse_latest_version` and `observe_one` with a stubbed `request_body` (no network) → `fired` / caught error.
- C2 predicate over BASE sources+table → 15/15 `named=True`; S035-anchor mutation → 6 flagged rows.
- sibling: `vercmp 3.15.01 3.15.1` → `0` (exit 0); `vercmp 3.15.001 3.15.01` → `0`; `vercmp 1:1.0 2.0` → `1`;
  `section_key` replicate → `ValueError` at 4301 digits; sibling files read only (`grep`/`sed`/`rev-parse`).

**Lane hygiene (not mine, not deleted):** `corpus/__pycache__/release-clock.cpython-314.pyc` is untracked in the
lane checkout, mtime `2026-10-21 14:14:57 -0300`; my imports wrote only inside my sandbox (sandbox copies at
14:07:38 / 14:08:43), so this is another seat's import without `-B`. L1 should decide whether it must be removed
before closure (it dirties `git status` at a round whose census is cleanliness-sensitive).

**Not checked:** no live `--observe` (no network used; F3/F4 exercised through stubs); tsukuroi's own gates,
selftests or selftest counts were **not run** (contract: no lane gates in a lane checkout); tsukuroi's
`measure-update-recheck.py` version handling beyond `QU_ROW`/`QUERY_ROW` regexes (`:53-54`, no digit bounds,
not exercised); kagi's round-28 counting tools do not exist yet at BASE, so I could not run them;
`vercmp` semantics for non-numeric/epoch-tagged tokens were sampled, not exhaustively mapped.
**Tooling:** nothing installed or upgraded (no pacman/uv/npx/cargo transaction).
