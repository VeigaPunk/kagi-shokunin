# ConnectOverlap — cross-ownership interface audit (round 22 falsification)

Axes: **calibration**, **freshness**. Leaf connector seat; no delegation, no production edit, no test or fixture authored by this seat.

**Verdict: bounded corroboration — no mismatched interface/claim found.** The new calibrated qualifier checker does not claim research-method (chousa) or sibling secret-scanner ownership at the executable, artifact, or documentation layer. One non-obvious coupling (`review` provenance is digest-pinned but never evaluated) is reported as a proposed next-round move, not as a defect. No axis is claimed as improved.

## Exact read revision

- `git rev-parse refs/heads/master` → `8ada17a50a25a75e6fc4a8cf880c87a85c67c8a3`; `HEAD^{tree}` → `d12afd7a545e86f21eb9acac567d10de774df50f`.
- Historical base `c2cab35bc92e57e39e5489bac3386db078345b3f` is BEFORE only; it is not this audit's input.
- Freeze authority: `.ufo/waves/round-22/integration-manifest.json`, observed SHA-256 `31e604021a0b7d9409b238cbbfceaaf5735066f82b3e0e450d73bafb6a1b5911`.

Observed hashes (read-only `sha256sum`), all matching the manifest:

| input | observed SHA-256 |
|---|---|
| `corpus/feature-claims.py` | `9f6a7e355b74d8f051ecbe1c39334280625d8910f2568b567979639264d074af` |
| `corpus/feature-claims.json` | `a506cea7ef26f731721ebd9fa22fb77f50c40b1f4a939cded26e6bb3f2b503aa` |
| `corpus/knowledge/feature-bound-credential-review.md` | `0d186f58836b8edcaadd675c8e74640ce2e66ec19f88adc10247cbfd194a24fe` |
| `corpus/SOURCES.md` | `3ba44518e2508f517d117c4678b3225f36b787ad645d9baf456c2a2da9023af7` |
| `corpus/QUALITY.md` | `dc2f5fe27935c3e238c0992cb14a4285bbee5edd902e2174b963561bcc84c09d` |

## Claim under test

`PROVINCE.md:76-78` states that "Local typed-review and revision-accounting fixtures do not absorb research method, secret-scanner ownership, browser leases or authenticated endpoint operations from siblings." The new capability is `corpus/feature-claims.py` plus its pinned artifact `corpus/feature-claims.json`. The question is whether any of that checker's code, artifact fields, or doc surfaces claims either ownership.

## Evidence: the checker is bounded at all three layers

**Code layer.**

- `corpus/feature-claims.py:4`: "closed-record reviewer, not prose NLP and not a source-truth oracle."
- `corpus/feature-claims.py:59-61`: "review-artifact pins, not vendor truth claims."
- Imports (`:10-20`) contain no network client, no `socket`/`urllib`/`http`/`requests`, and no environment read. The only `https://` occurrence is `:347`, which validates the `url` field's scheme and is never fetched.
- Sole `subprocess` use (`:863-875`) re-invokes this same script during `--selftest`; it is not a shell-out to a sibling gate, census, scanner, or vendor tool.
- All reads go through `_read_beneath` (`:250-291`), confined to the selected root and the `--claims`/`--input` relative paths (O_NOFOLLOW per component, regular-file check, size and inode/mtime recheck).
- Non-selftest paths write nothing. `--selftest` writes only under `tempfile.TemporaryDirectory` (`:888`).
- `grep -nE "scan|scanner|census|quality|hygiene|secret-shaped|tripwire" corpus/feature-claims.py corpus/feature-claims.json` → **0 matches**.
- `grep -nE "SOURCES|sources-census|claim-ledger|transcript|PROVINCE|SKILL|QUALITY" corpus/feature-claims.py` → matches are only the gate's own default claims path (`:24`), the `PINNED_SOURCES_SHA256` constant name (`:62`), and self-referential `corpus/feature-claims.json` fixture/help strings (`:916-928`, `:1007`). None names `corpus/SOURCES.md`, a sibling lane, or another gate.
- `claim-ledger.sh:161` (`PYTHON_SCRIPT_RE`) allows the two script tokens as ledger **row commands**; that is bookkeeping of an existing gate, not an import of the qualifier into the census or credential path.

**Artifact layer** (`corpus/feature-claims.json` `review.limits`, lines 8-14):

- "Typed records only: no free-prose parsing, NLP, or claim about arbitrary sentences."
- "Admission means required qualifiers and pinned quote bindings match this review artifact; it does not prove source truth or deployed behavior."
- "URLs are inert metadata; the gate never fetches them."
- "The label authority field records provenance; author/construction labels are not outside-verifier agreement or a calibration scalar."

`review` is required as a top-level key (`feature-claims.py:744`), but its only content use is the digest check at `:748`; no code path reads its fields, i.e. it is inert provenance, not evaluated input.

**Documentation layer.**

- `SKILL.md:701-702`: "The feature reviewer checks a fixed, reviewed source/anchor vocabulary, not vendor truth."
- `SCORECARD.md:769`: scope is "the closed reviewed source vocabulary and typed records, not arbitrary prose, vendor truth or outside agreement."
- `corpus/knowledge/feature-bound-credential-review.md:30-32`: "`R21-02` checks the source-registry citation chain only. It does not reopen pages or establish vendor truth."
- Same file `:26-28` delegates un-represented qualifiers: "For source qualifiers not represented by a typed review gate, perform the public-page review directly."

Together these are declarations of **non-ownership**: no vendor-truth claim, no citation-chain claim, no search-adequacy claim, no credential-detection claim.

## Sibling map (checked, not inferred)

- `chousa-shokunin/PROVINCE.md:3`: "deep-research method (調査) — the reusable craft of source research"; `chousa-shokunin/SKILL.md:3` lists "verify this claim", "primary source", "citation chain" as triggers. The new checker adjudicates one caller-supplied *typed* record against a fixed vocabulary; `--input` carries no expected label, authority, or free-prose claim, and the verdict is explicitly catalog-relative.
- `kagi-shokunin/PROVINCE.md:63`: chousa owns the research method; "chousa, kasegi and kumitate run their own secret-shaped tripwires over their outputs (hygiene filters, not vault ops)". The round's credential sweep (`.ufo/waves/round-22/credential-sweep-integration.json`, scope "new round evidence files and added lines of changed owned artifacts") is exactly that class of self-hygiene over kagi's own outputs. It is evidence JSON, not a production gate, and the qualifier neither invokes nor claims it.
- `kaidoku-shokunin` reads 1Password binaries statically and `tsukuroi-shokunin` tracks 1Password packages; neither claims feature-status adjudication, and the new checker does not touch binaries or packages.

**Tension examined and rejected.** `QUALITY.md` QA10 prescribes following and opening each feature-specific status link — a traversal step that resembles chousa's craft. But `PROVINCE.md:63` states the specific test as "`SOURCES.md` restates neither method nor admission bar"; `QUALITY.md` is kagi's own admission bar for its own entries (derived from the outside verifier's finding), and no kagi artifact claims to define or own the fleet method. Applying a method to one's own admission decisions is not claiming the method.

## Executed corroboration (owned local fixture, read-only phases)

| command | exit | observed last line |
|---|---:|---|
| `python3 corpus/feature-claims.py --phase after` | 0 | `FEATURE_CLAIMS: CLEAN phase=after admitted=4 false_claims=0 bar_failures=0 false_admissions=0 misses=0 unjudgeable=0` |
| `python3 corpus/feature-claims.py --phase before` | 1 | `FEATURE_CLAIMS: FAILED phase=before false_claims=2 bar_failures=8 false_admissions=0 misses=0 finding=FC-RUNTIME-CONSTRAINT` |
| `python3 corpus/feature-claims.py --phase boundary` | 2 | `FEATURE_CLAIMS: CANNOT_EVALUATE phase=boundary unjudgeable=3 finding=FC-UNKNOWN-FEATURE` |

These match the manifest's `feature_after_admits: 4`, `feature_before_rejections: 10`, `boundary_unjudgeable: 3`. The output counts decisions per cell; it does not emit an authored-row accuracy scalar. `--input` was not exercised by this seat; sibling reports already cover it and I do not re-claim those results.

## Residual interface risks (not ownership claims; no axis harm observed)

**R1 — `review` provenance is immutable-by-code (low; freshness coupling).** `feature-claims.py:748` pins `review` by digest; no code path reads its fields. Correcting a provenance sentence (`axis`, `base_revision`, `opened_at`, `scope`, or a limit) therefore requires editing `PINNED_REVIEW_SHA256` in code; a copy of the artifact with only `review` edited returns exit 2 `FC-REVIEW-PIN` by the code path at `:748`, read here but not mutated. The evaluated data is separately pinned (sources/features/records/transitions/boundary), so the review pin adds no decision integrity. This is the only place where the qualifier touches research-record content, and it is coupling, not a claim.

**R2 — `prior_registry_sha256` is undocumented (low; interface documentation).** The field appears on 2 of 9 catalog sources (S013, S021) and is accepted by `feature-claims.py:333,343` without any production-doc definition. Its values are the `corpus/SOURCES.md` capture digests of the same URLs (S013 → registry S013 `ae321512…`; S021 → registry S016 `c083fdca…`). The gate never reads `corpus/SOURCES.md`; the catalog is a second registry linked only by that optional field. A registry byte edit is still caught by the stamp (`corpus/SOURCES.md` is a stamped member, `corpus/stamps.tsv:60`), so this is a documentation gap, not a freshness hole. The S020 digest's own reproducibility problem is already filed by `ReopenSource13`; it is not re-asserted here.

## Proposed move (one, bounded; next round, not this wave)

Decouple review provenance from the trust pin. Keep `review` in the artifact as documented inert provenance and pin only the evaluated members (sources, features, records, transitions, boundary records), or move `review` to a sibling file that is not digest-checked. This removes the only place where an edit to research-record text forces a gate exit, and it changes no adjudication.

- **Axes:** calibration — decision outputs unchanged (no harm, no gain); freshness — provenance corrections no longer require a code-pin edit (small gain); no other axis touched.
- **Risks:** a consumer that treats the review narrative as tamper-evident loses that property; mitigate by stating in `review.limits` that the block is provenance, not an evaluated pin. Applying it now would change frozen input hashes mid-falsification, so it belongs after this wave.
- **Acceptance:** (i) `--phase before|after|boundary` outputs and exits byte-identical to the frozen run; (ii) in an isolated fixture, editing only `review.opened_at` yields the same decisions instead of exit 2; (iii) source/feature/record/transition/boundary tampering still returns its existing `FC-*` findings.

## Limits and non-claims

- No vendor page reopened, no network GET, no host loopback/health/CDP, no package manager or launcher, no installation, no credential sweep run by this seat, no census/ledger/revision-audit/transcript gate executed, no production file modified.
- I did not re-adjudicate vendor truth, outside agreement, or either axis score. This report is one boundary decision, not an accuracy scalar, and it does not admit or integrate anything.
- Overlap avoided: `MutCrossProduct`, `MutMissingEligibility`, `MutStatusSwap`, `MutUnknownEvidence`, `SentinelClaimInput` are not duplicated; `ReopenSource13`'s S020 digest finding is referenced only as context.

## Checks the parent should run after integration

1. `python3 corpus/feature-claims.py --selftest` (expect `PASS cases=10`), then `--phase after` (0, 4 admits), `--phase before` (1, 10 rejects), `--phase boundary` (2, 3 unjudgeable) — confirms the three claim decisions on the integration tree.
2. `bash corpus/sources-census.sh` and `bash corpus/claim-ledger.sh verify` on the integration host, if those rows are authorized there — confirms the new artifact/stamp membership still lines up. Neither was run here: host-bound rows are outside this wave's boundary.
