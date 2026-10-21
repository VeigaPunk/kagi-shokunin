# CritSourced — round-27 C2 sourced-claim attack (KagiR26.CritSourced-17)

Lane-authored advice from a critic seat. This is not non-author closure, and it carries no SHONEN mark.
BASE `0a47dd189356ea66ec83c3891eed54526e95b89b`. "WT" means the uncommitted L1 working tree on top of BASE, read on 2026-10-21. S042 and S043 exist only in WT.
Axes judged: calibration and freshness. I also looked at the false-provenance sub-axis.
I ran nothing: no selftests, no measures, no gates, and no network fetches. Every finding below comes from reading code and captures.

## Verdict

S042 (SemVer 2.0.0 §11.2) and S043 (PyPA version specifiers) ground one thing only: an ordering function on two version strings that already conform to the scheme. The REGRESSED rule also rests on three further premises that neither source states for CPython, Vault, OpenBao, SOPS or curl:

- **T1, project tier.** The vendor numbers its stable tags in increasing order.
- **T2, release tier.** The anchor and the observation sit in the same release tier: stable/final versus a development or prerelease label.
- **T3, feed tier.** The observation is complete with respect to the tier the anchor was taken from.

The lesson already rejects the T3 overclaim (`corpus/lessons/round-27.md` Gate, row "A release-ordering spec proves a vendor's feed is complete or monotonic"). T1 and T2 are not scoped anywhere. In addition, the WT code and selftest comments claim an un-fire guard that the rule does not implement.

Overall: the "Sourced" claim in `plans/round-27.md:32` is an **overclaim as worded, but fixable with text plus one QM clause**. The behavior that results from it fails safe on the downgrade-lie shape, so it is not a tradeoff that the Rust judge has to reject.

## Attack 1 (primary): the spec is scoped to adopters, and the strict-X.Y.Z guard cannot see release tier

### Evidence

- **SemVer is scoped to adopters.** `.ufo/waves/round-27/captures/S042.body:439` says "Software using Semantic Versioning MUST declare a public API". The monotonicity premise is a MUST for adopters only (`S042.body:447`: "Each element MUST increase numerically").
- **The S042 row disclaims vendor adoption.** WT `corpus/SOURCES.md:49` says "Vault, OpenBao, SOPS, curl and CPython are not asserted to follow SemVer's API semantics, only the numeric core ordering is used". The lesson Gate row for S042 repeats this. So T1 is assumed but has no source.
- **PEP 440 is scoped to distributions, not CPython.** `S043.body:360` says "a scheme for identifying versions of Python software distributions". Its monotonicity MUST (`S043.body:500`, "Final releases within a project MUST be numbered in a consistently increasing fashion") binds PyPI projects. CPython interpreter releases on `python.org/downloads/feed.rss` are not distributions under that spec. WT `SOURCES.md:50` calls S043 "CPython-style", which is a domain transfer the page itself does not make.
- **The guard is purely syntactic.** WT `corpus/release-clock.py:369-386`: `numeric_version` accepts any cell matching `[0-9]+\.[0-9]+\.[0-9]+` and `is_regression` orders those cores. The anchor's release tier (dev label, docs build, prerelease) lives in the SOURCES `anchor` prose and the row note, and the rule never reads it.
- **SemVer orders prereleases below their release core.** `S042.body:519` (§11.3) says "When major, minor, and patch are equal, a pre-release version has lower precedence than a normal version". Stripping a dev label down to its bare core discards exactly the precedence information S042 supplies.

### Counterexample, built from the lane's own rows

**Setup.**
- S029's anchor names a development label: BASE `corpus/SOURCES.md:35` reads "curl 8.23.1 man page".
- BASE `SOURCES.md:43` (S037) says "S029's anchor names 8.23.1, which is curl's unreleased development label", and BASE `corpus/release-clocks.tsv:26` cites `curlver.h 8.23.1-DEV`.
- `version_is_named` (BASE `release-clock.py:341-346`) finds `8.23.1` in that anchor, so a **non-derived** row passes `anchor_ok` (WT `:541`).

**The row.** `S029 feed S037 https://curl.se/info 8.23.1 8.23.0 2026-10-21 <verdict> <note without "derived:">`

**What happens.**

| Revision | Verdict cell | Result |
|---|---|---|
| BASE | `fired` | CLEAN. This is a lie: curl has released nothing past the anchor. |
| WT | `fired` or `not-fired` | REGRESSED, exit 1, via WT `:542-547`. |

The WT result fails safe, but its provenance is false. The code comment at WT `:543-545` says the feed is "stale/cropped/rolled-back", yet `curl.se/info` is accurate. The real fault is a dev-tier anchor compared against a stable-tier observation.

**The silent-miss case (freshness harm).** When curl ships 8.23.1, the rule records equality and `not-fired` at both BASE and WT (WT `:556`). By §11.3, the release is newer than the `8.23.1-DEV` snapshot the teaching was mined from, so the clock should fire and the teaching should be re-verified.

**Current exposure.** The live table avoids this only because round 25 chose to derive S029 at 8.23.0 (`release-clocks.tsv:26`). Nothing in code, in QM25 (WT `corpus/QUALITY.md:132`), or in the six new selftests (WT `:1026-1043`, all stable-tier `1.2.x` fixtures) requires that choice. Anchors at the same structural risk are the four non-derived numeric Python documentation-title anchors: S027, S028, S040 and S041 (`release-clocks.tsv:24,25,30,31`). [INFERENCE, unverified] `docs.python.org/3/` is built from the maintenance branch, so a title showing `3.15.1` may carry post-release (`3.15.1+`) content. I did not fetch this to confirm.

**Impacted axes:**
- Calibration: the claim states more sourcing than it has.
- Freshness: a dev-label anchor never fires on its own release.
- False provenance: the REGRESSED comment blames the feed.

### Tier-scoping needed

| Tier | What has to hold | Current grounding | Smallest honest treatment |
|---|---|---|---|
| T1 project | The vendor's stable tags increase numerically. | None. S042 and S043 bind adopters only. | Declare it in S042/S043 scope and in QM25 as a lane assumption. Alternatively, open project-tier rows. Candidates, none fetched: CPython `sys.hexversion` docs, curl `curlver.h` `LIBCURL_VERSION_NUM` comment. I know of no Vault, OpenBao or SOPS statement. |
| T2 release | The anchor is a stable/final core, not a dev label or docs build. | Not checked. `derived:` rows satisfy it by construction, since the anchor is a newest-stable feed observation. | QM25 clause: a numeric anchor naming a development or prerelease label MUST be bound `derived:` at the newest stable release (the S029/S037 pattern). The strict-X.Y.Z cell guard does not detect tier. |
| T3 feed | The feed window is complete for the anchor's tier. | Explicitly rejected in the lesson Gate. | Already handled. Only align the code comment (next section). |

I checked the cross-series max with no defect found. `parse_latest_version` takes the max over the whole feed window, across series (BASE `:685-699`). Several anchors are series-scoped ("2.7.x", S014–S026). A cross-series max is always at least the series max, so that scoping cannot produce a false REGRESSED or hide a real one for these rows.

## Attack 2 (secondary, calibration): the un-fire guard is claimed but not implemented

**What is claimed.**
- WT `release-clock.py:543-545` says the rule is "never an un-fire of an earlier anchor".
- WT `:1027-1029` says "red-before: both lies were accepted CLEAN at round-26 BASE".
- `plans/round-27.md:27-28` lists un-firing an already-fired predecessor as part of the defect being fixed.

**Why it does not hold.**
- `is_regression` compares each row only with its **own** anchor. An un-fire means re-observing a fired row at exactly its anchor: S027 or S028, anchor 3.15.0, observed 3.15.0, `not-fired`. That passes WT `:556` as a valid `not-fired` row.
- In the rollback fixture (`.ufo/waves/round-27/tools/c2-measure.py:27-28`), the WT run can only exit 1 because the successor rows S040 and S041 (anchor 3.15.1) trip REGRESSED. The un-fired S027/S028 rows themselves are still counted as observed.
- Take away the numeric successor and the un-fire is CLEAN at WT. That state exists between a fire and its rearm, for example mid-round 26 before S040/S041 were opened, or for any future fired row without a successor yet.
- The lesson's own Limits (`corpus/lessons/round-27.md:92`) do state "does not detect a feed that silently drops the newest release while still showing an equal or newer version", which covers this case. The code comment and selftest comment contradict that Limits text.

**The selftest is not red-before as claimed.** `downgrade un-fire refused` (WT `:1032-1034`: anchor 1.2.3, observed 1.1.9, `not-fired`) was **INCONSISTENT** at BASE, not CLEAN. BASE `:527-531` requires `observed == anchor` for `not-fired`. So the comment's "both … accepted CLEAN" is false for that case. The case also does not model the real un-fire shape: a row equal to its own anchor after a prior, higher fired observation.

**Impacted axes:**
- Calibration: the comment overclaims.
- Freshness: an un-fire is caught only when a successor happens to exist.

## Smallest safe correction (for L1 to integrate; I edited nothing)

1. **`plans/round-27.md:32` and QM25.** Write "Sourced" as "the ordering function is S042 §11.2 (S043 corroborating for Python-distribution numbering only). Vendor monotonicity (T1) is a declared lane assumption, and release-tier equality (T2) is enforced by binding dev or prerelease anchors `derived:`." Add the T2 sentence to QM25.
2. **WT `SOURCES.md:50` (S043).** Replace "CPython-style" with "Python software distributions (PyPA). CPython interpreter tags are not distributions under this spec; used as corroborating ordering only."
3. **WT `release-clock.py:543-545`.** Change the comment to "observation numerically below this row's anchor; the feed window or the anchor tier needs re-verification". Drop "never an un-fire of an earlier anchor".
4. **WT `release-clock.py:1027-1029`.** Make the red-before claim per-case: "fired lie: CLEAN at BASE; un-fire-below-anchor: INCONSISTENT at BASE". Optionally rename that case, since it is not an un-fire.
5. **Optional, a real change rather than text.** Add one selftest with a non-derived anchor naming a dev label (anchor `8.23.1`, observed `8.23.0`). Its expected outcome documents the T2 limit. I would not add a high-water/un-fire check this round: it needs prior-receipt state, which grows scope.

None of these weakens the REGRESSED rule. The downgrade-lie fix (BASE CLEAN to WT REGRESSED, per `.ufo/waves/round-27/c2-before.json` `lie`) stands.

## What I did NOT check (none of these counts as a pass)

- I did not execute `corpus/release-clock.py --selftest`, `c2-measure.py`, or the default receipt run. I also did not check the exact-set semantics of `run_case`'s expected errors (WT `:937`).
- I did not fetch any vendor versioning statement: curl `docs/versions.html` or `curlver.h`, the Python `sys.hexversion` docs, or HashiCorp, OpenBao or SOPS release policies. Every project-tier candidate named above is unverified.
- I did not check whether the `docs.python.org/3/` title core matches a stable or a branch build. That remains [INFERENCE].
- I did not review C1 (knowledge bindings, `self-counts.tsv`) or the ledger pins.
- I made no installs or updates.
