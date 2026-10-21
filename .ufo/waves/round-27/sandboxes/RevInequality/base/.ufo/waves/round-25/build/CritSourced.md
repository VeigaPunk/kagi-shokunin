# CritSourced — round-25 BUILD advisory
Axes: calibration, operability, freshness. No admission/judgment or production edits.
Frozen code/registry revision: `4587c61a348e4528717404a68912c373f3ef4d03`; design reviewed: working-tree `plans/round-25.md:56-85`.
Scope: initial registry snapshot ends at S032 (`corpus/SOURCES.md:38`); proposed S033+ rows and the round-25 Gate were not present when inspected. This is a build-risk review, not a final-candidate verdict.

## Exercised evidence / exact effective commands
Path aliases below: `D=/fast/scratch/kagi-r25/KagiR25.CritSourced-2`, `L=$D/lane`, `S=/home/vgpnk/Projects/shokunin/kagi-shokunin`.
Except directory creation, every shell argv below had prefix `env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/KagiR25.CritSourced-2/home`; cwd for probes was `$L`.
- `mkdir -p "$D/home" && git clone -q --no-hardlinks "$S" "$L" && git -C "$L" checkout -q 4587c61a348e4528717404a68912c373f3ef4d03 && git -C "$L" rev-parse HEAD`: exit 0; stdout `4587c61a348e4528717404a68912c373f3ef4d03` (the git invocations individually used the isolation prefix).
- `curl -fsSL --compressed -A 'kagi-shokunin-round25/1.0 (documentation verification)' --max-time 30 -o "$D/sops-latest.json" -w 'http=%{http_code} type=%{content_type} final=%{url_effective} bytes=%{size_download}\n' https://api.github.com/repos/getsops/sops/releases/latest`: exit 0; HTTP 200, `application/json; charset=utf-8`, final URL unchanged, transfer bytes 5268.
- Same curl argv with output `$D/openbao-latest.json` and URL `https://api.github.com/repos/openbao/openbao/releases/latest`: exit 0; HTTP 200, same content type, final URL unchanged, transfer bytes 23329.
- `sha256sum "$D/sops-latest.json" "$D/openbao-latest.json"`: exit 0; respectively `d96c4282d3d1353956448163a45ed121fb8b4ac68a5e858298824a6ea022c693`, `a771067e6ff39a58a83f0abc7744825c94068c509c87e3daa4ea74ec6f5e8bc1`.
- `wc -c "$D/sops-latest.json" "$D/openbao-latest.json"`: exit 0; decoded-body bytes `42533`, `347747` (total `390280`).
- `python3 corpus/rendered-text-v1.py locate "$D/openbao-latest.json" 'The unauthenticated "Root Token Generation" and "Rekey" endpoints'`: exit 1; `RENDERED_TEXT_V1_LOCATE: count=0`.
- `read` JSON query `.body | contains("The unauthenticated \"Root Token Generation\" and \"Rekey\" endpoints")` on that same file: `true` (tool read, no process exit code).
- `python3 corpus/rendered-text-v1.py locate "$D/openbao-latest.json" '"tag_name": "v2.7.1"'`: exit 1, count=0; changing only the quote to `'"tag_name":"v2.7.1"'`: exit 0, count=1.
- Same two locator invocations for `$D/sops-latest.json`, `v3.13.3`: colon-space quote exit 1/count=0; compact quote exit 0/count=1.
- Opened API metadata: SOPS `/id=358471161`, `/tag_name=v3.13.3`, `/published_at=2026-07-23T05:27:57Z`; OpenBao `/id=401006883`, `/tag_name=v2.7.1`, `/published_at=2026-10-01T14:03:19Z`. Both `/draft=false`, `/prerelease=false`.

## Numbered counterexamples / risks
1. **HIGH — prospective citation is not yet sourced frontier evidence** (freshness, calibration).
   Evidence: `plans/round-25.md:60,70-71,82-83` promises S033+; the reviewed registry has none. `../templates/round-prompt.md:49-53,73-74` requires an opened-this-round row actually cited by landed claim evidence; `../CORPUS.md:105,112-118` requires the row author's opening plus a located ≤25-word Gate quote.
   Concrete falsifier: finish C3 with all 28 rows bound/observed but only old S001-S032 references, or with a new feed ID mentioned only in the plan and no cited evidence/lesson. A CLEAN clock count cannot establish this requirement. Candidate closure check: UNRUN.
   Smallest safe correction: actually open the selected feed as its row author, append the next unused row, and cite that ID in C3's landed binding/evidence and lesson `source:`; Gate records URL, access date, exact quote and JSON pointer/section. A scout receipt is not evidence that a different row author opened it.
   Same-day is not same-round: S027-S032 already have 2026-10-21 dates (`corpus/SOURCES.md:33-38`); `corpus/lessons/round-24.md:193-201` places S032 in round 24. Existing rows may be reopened and cited with round-25 evidence; their original date alone cannot prove that reopening.

2. **HIGH — tier-A metadata must not become invented product/doc identity** (calibration, freshness).
   Eligible opened feeds: [getsops/sops](https://api.github.com/repos/getsops/sops/releases/latest) and [openbao/openbao](https://api.github.com/repos/openbao/openbao/releases/latest) are primary maintainer-release metadata, hence A **for that scope**; use `dataset` for API data. Official vendor release-note pages may be `docs`/A; unopened candidates here remain UNRUN, not verified feed rows.
   Evidence: `../CORPUS.md:89-100` scopes A and enumerates kinds; `community` is never A, and invented kinds `api`/`feed` violate the enum. A release feed does not establish installed version, a docs commit-to-release mapping, or that a lifecycle claim still holds.
   Concrete falsifier: bind S009's docs commit `9b7b84e297bdabc9c78e571c1e6db43dcd69454a` (`corpus/SOURCES.md:15`) to SOPS `v3.13.3` by inequality; or call `2.7.x != v2.7.1` a newly observed release for S014-S016/S021/S025-S026 (`:20-22,27,31-32`). These unequal identifiers do not establish a post-verification release event and can remain unequal forever. Candidate mutation: UNRUN.
   Smallest safe correction: require genuinely commensurate, evidenced version identities; never invent an exact baseline from a commit or wildcard. For moving live docs use the permitted quote clock with its actual narrower meaning; preserve old registry anchors. Feed firing still needs separate re-verification of the affected claim (`plans/round-25.md:65-66`).

3. **HIGH, OBSERVED — JSON is not rendered HTML** (operability, freshness, calibration).
   Concrete falsifier: the OpenBao human-readable `/body` quote exists after JSON decoding, yet the committed locator returns exit 1/count=0; even whitespace added around a JSON colon changes exact quote location. This is representation mismatch, not source contradiction.
   Evidence: probe outputs above; `corpus/rendered-text-v1.py:10-43,70-83` strips HTML/unescapes HTML entities but never decodes JSON string escapes. Prior lesson explicitly rejects representation-confused quote failures (`corpus/lessons/round-24.md:205-210`).
   Smallest safe correction: JSON feeds are allowed; use a short exact raw field quote (e.g. `"tag_name":"v2.7.1"`) located at `/tag_name`, with release id/tag/date in the anchor, and existing `raw-literal-v1` capture semantics. Parse the root `tag_name` as JSON for clock observation, not the first number/name/asset in the response. Do not relabel decoded JSON text as rendered-text-v1.
   Adding `json-v1` as an undeclared capture normalization is not a shortcut: `corpus/sources-census.sh:279-283` accepts only rendered-text-v1/raw-literal-v1. Dynamic enum falsifier: UNRUN; branch is explicit.

4. **MEDIUM — inherited capture profile and compressed size can create false provenance** (calibration, operability).
   Concrete falsifier: copying these captures with `bytes=5268/23329` claims transfer sizes as decoded-body sizes; observed files are 42533/347747. Calling our round25-UA requests `curl-fsSL-compressed-v1` also contradicts its fixed round23-UA declaration (`corpus/source-fetches.tsv:14-18`).
   Evidence: exact curls/wc above; `corpus/sources-census.sh:266,268-270` checks declared profile/shape, not whether the claimed request actually produced the body. A new feed's digest alone is insufficient (`:56-70`).
   Smallest safe correction: record actual decoded-body sha/length and final URL/status; document and accept a distinct round25 request-profile without rewriting old profile meaning. Keep the existing raw-literal normalization; no second research/admission method is needed.

5. **MEDIUM — new feed rows can invalidate the fixed 28-row after denominator** (freshness, operability).
   Evidence: `plans/round-25.md:56-70` says every on-release row and after bound=28; new rows still require their own recheck cell (`../CORPUS.md:105-106`).
   Concrete falsifier: append S033 with `recheck=on-release` but fill only the original 28 bindings; it is now the 29th required binding. Conversely, silently excluding feed rows contradicts “every.” Candidate execution: UNRUN.
   Smallest safe correction: give polling feeds an honest explicit cadence, or include them in bindings and report the actual enlarged population. Do not overwrite old source cells to manufacture 28; any existing status/recheck/used-by changes need old→new lesson entries (`../CORPUS.md:116-118`).

6. **MEDIUM — `/latest` is not every release and a tag is not semantic re-verification** (freshness, calibration).
   Evidence: opened [GitHub endpoint documentation](https://docs.github.com/en/rest/releases/releases#get-the-latest-release), “Get the latest release”: latest published full release; excludes prereleases/drafts and documents created_at ordering. The same page's `make_latest` parameter permits explicit latest designation. It is not a universal publication-time/SemVer maximum oracle.
   Concrete falsifier: a relevant prerelease, non-latest maintenance release, or docs-only change occurs while `/latest.tag_name` is unchanged. A stable-tag equality check misses that trigger; a changed tag alone likewise does not show S009/S015's mechanism was rechecked. Synthetic future-event probe: UNRUN.
   Smallest safe correction: bind each row to the actual relevant release stream/identity and retain fresh claim-specific verification receipts for fired rows. If the desired scope includes those events, replacing it with stable-only polling or quote presence is a narrowing/tradeoff, not an automatically harmless improvement; the canonical judge owns that decision.

No tool installs/updates. No real-lane verify/cells, host/vault/account operations, credential reads, subagents, background jobs, Git-index mutations, or runtime/judge invocations. Production C3 implementation, final source census, and closure verification: UNRUN.
