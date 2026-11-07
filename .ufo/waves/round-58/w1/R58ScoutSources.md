# R58ScoutSources — round 58, seat report (scout: the two declared policy sources, opened live)

Lane `/home/vgpnk/Projects/shokunin/kagi-shokunin`, branch master. BASE `1b13f5dad921f8901f56d30c428f89614dd74d8a`
(present). Read-only git; no `git add/commit/stash/push`, no mutating `jj`, no write outside this
seat's build dir and the round capture dir. The L1 (`KagiR58`) holds the canonical planner seat and is
the sole integration owner and committer; this seat returns findings and files only.

Predeclaration read before work: `plans/round-58.md` (frozen; C2 POP T1–T5 names S118/S119 and the
five mechanics), `corpus/lessons/round-57-verifier-spotcheck.md`, and the L1's amendment A2 (whitespace-
collapsed quote comparison). **No frozen predicate, target, POP or kill rule was amended.**

Tools: `curl` 8.23.0, `python3` 3.14.8 (stdlib only), `sha256sum` (GNU coreutils) — all preinstalled
system binaries; **no installs** were made (ALL pacman transactions are PAUSED host-wide). The
verifier used is the lane's own committed normalizer `corpus/rendered-text-v1.py`
(`--selftest` → `PASS (cases=22)`). Model observed for this seat: minimax-code/MiniMax-M3.1-Flash.

Full evidence: `.ufo/waves/round-58/build/R58ScoutSources/report.md` and
`.ufo/waves/round-58/build/R58ScoutSources/quote-locate-receipt.tsv` (command-by-command, with exit codes).

---

## 1. The two declared sources, opened live

| id | URL | HTTP | bytes | sha256 of decoded body |
|---|---|---|---|---|
| S118 | https://openbao.org/docs/concepts/policies/ | 200 | 122498 | `a55ff1a4caf12c3a62bcaab61ff95fef1d382cba01da5dbd4521dbfbca6e1468` |
| S119 | https://openbao.org/docs/commands/policy/ | 200 | 32520 | `0472f29373a98f6dd1260aa6ca4d1bd80de9d4642a75c8df94bd22e47e0263e7` |

Both are OpenBao docs **Version 2.7.x** (`Version: Version 2.7.x` marker + `docs-version-2.7.x` body
class) — the same branch as the measured binary OpenBao v2.7.2. No redirect on either URL.

**Two independent fetchers agree byte-for-byte.** My fetch (lane-canonical UA) and the r58 scribe's
fetch (browser UA, different working dir) produce the same sha256 for both pages — the pages are
stable and the L1's landed digests are correct.

## 2. Located quotes — every frozen C2 ground, at count=1

Verifier: `python3 corpus/rendered-text-v1.py locate .ufo/waves/round-58/capture/<id>.body '<quote>'`
(exit 0 iff count ≥ 1). All quotes ≤ 25 words.

| frozen ground | quote | anchor | locate |
|---|---|---|---|
| T1 deny-by-default | "Policies are deny by default" | H1 «Policies» intro | count=1 |
| T1 empty policy | "so an empty policy grants no permission in the system" | H1 «Policies» intro | count=1 |
| T1 cannot update/delete | "the token cannot update or delete" | §Policy syntax | count=1 |
| T2 `*` last char only | "It is not a regular expression and is only supported as the last character of the path" | §Policy syntax danger box | count=1 |
| T2 `secret/bar/*` example | `"secret/bar/zip", "secret/bar/zip/zap", but not "secret/bars/zip"` | §Policy syntax | count=1 |
| T3 deny precedence | "This always takes precedence regardless of any other defined capabilities" (+ "including sudo") | §Capabilities `deny` bullet | count=1 |
| T4 `+` one segment | "a + can be used to denote any number of characters bounded within a single path segment" | §Policy syntax `+` paragraph | count=1 |
| T5 union | "If the same pattern appears in multiple policies, we take the union of the capabilities" | §Policy syntax priority note | count=1 |
| T5 highest-priority only | "we take only the highest-priority match from those policies" | §Policy syntax priority note | count=1 |
| S119 write path | "write Uploads a named policy from a file" / "Usage: bao policy <subcommand> [options] [args]" | §Usage | count=1 |

**Verdict: ACCEPT S118, ACCEPT S119.** Every mechanic the frozen C2 POP names is grounded in a located,
≤ 25-word quote on the declared pages, with the live heading anchor recorded.

## 3. Probe verdicts

| probed URL | result | bytes | sha256 | verdict |
|---|---|---|---|---|
| https://openbao.org/docs/api/system/policies/ | 200, no redirect, real mechanism page | 47012 | `9b13c6d9456583a11f51c0aa36fc5896ff66587d980054f1c17120174288542c` | **ACCEPT as a new registry row (S120)** |
| https://openbao.org/docs/commands/token/ | 200, no redirect, real mechanism page | 32638 | `37e706c2b2047d474dc84ad20f09b6f35c5d5c328f4fcff1298079c1c17ead28` | **REJECT as a registry row — scope, not a stub** (token-cli/lease scope is already registered by S016/S021) |
| https://openbao.org/api-docs/system/policies/ | 200 but a **343 B `meta http-equiv="refresh"` stub**, canonical `/docs/api/system/policies/`, no mechanism text | 343 | `0f6bae878df5cd74e5afa51f77887b540a26b1358e3d098480f9337646214a57` | **REJECT — redirect stub** (the same shape as the r57-rejected `/api-docs/system/audit/`, 334 B) |
| https://openbao.org/api-docs/commands/token/ | **HTTP 404** | 3484 | — | REJECT — no such path |

Both URLs I was asked to probe are **real pages**; the stub/redirect family is the legacy `/api-docs/…`
URL shape, which I re-probed for the contrast and which the r57 lesson already rejected once.

S120 adds two mechanics no registered row carries: **"A deleted policy set on a token acts as an empty
policy"** (§Delete ACL policy — the API-level form of T1's empty-policy consequence) and **"Once a policy
is updated, it takes effect immediately to all associated users"** (§Create/Update/Patch ACL policy —
the property the trial's write-then-read ordering relies on). Both locate at count=1.

## 4. Two defects found in the L1's already-landed S118/S119 rows (reported, not fixed — the L1 owns the lane files)

1. **The landed capture-row quote for S118 does not locate.** `corpus/source-fetches.tsv` col 13 for S118
   reads `Policies are deny by default, so an empty policy grants no permission in the system.` →
   `RENDERED_TEXT_V1_LOCATE: count=0`. The page marks "deny by default" in `<strong>`, so the rendered
   text is `…deny by default , so an empty policy…` (a space before the comma). The located forms are
   the two fragments "Policies are deny by default" and "so an empty policy grants no permission in the
   system". The same non-locating sentence is in the S118 `teaches` cell, which also carries a
   lower-case "this always takes precedence …, including \`sudo\`" (count=0; the live text capitalises
   "This" and writes `sudo` in `<code>`), and the S119 `teaches` cell carries
   "The \`policy\` command groups …" with backticks (count=0). **This is the D4/D12 defect class the
   round-58 plan's I3 condition is built to catch**, and it would leave the lesson Gate row unlocatable.
   Replacements that all return count=1: Q1–Q10 (S118) and Q11–Q13 (S119) in the build report.
2. **Both landed provenance rows' `location` points at the scribe's build dir**
   (`.ufo/waves/round-58/build/R58ScribeEntry/capture/S118.body` / `…S119.body`). Those files exist and
   are byte-identical to the canonical `.ufo/waves/round-58/capture/<id>.body` this seat wrote, so the
   digest pin holds either way — but the round capture dir is the stable path (r55/r57 convention).
   Recommend re-pointing both `location` cells; no digest changes.

**Registry recipe for the L1 (fixture-verified on a scratch copy, not applied to the lane).** Adding
S120 needs three aligned things: (1) a 13-column `corpus/SOURCES.md` row with status `mined`, tier `A`,
the exact URL in the source cell and `used-by` = `corpus/knowledge/openbao-acl-policy-semantics.md`;
(2) one 16-column `corpus/source-fetches.tsv` row with
`row_identity_sha256 = efe4289072b6be149332cb644267198b5e2ab1b0dd045f029a91ab45c41968a4`
(= `sha256("S120\tmined\thttps://openbao.org/docs/api/system/policies/\n")`; the trailing `/` matters),
`request_profile curl-fsSL-compressed-v1`, `representation decoded-http-body-v1`, quote
`A deleted policy set on a token acts as an empty policy`, `normalization rendered-text-v1`,
`normalized_sha256 4af1e7f730b3c7548cd37bc10ed39206b96e38fceb1b4922e7dcb7234060c669`,
`location .ufo/waves/round-58/capture/S120.body`; (3) a column-1 `cites:` line on the knowledge entry
naming S120 (the entry currently has none), otherwise the census reports `SC_USEDBY_NOCITE` for the new
row. Scratch-fixture result with all three in place:
`SOURCES_CENSUS: CLEAN (rows=120 … captures=120 …)`; with step 3 omitted the fixture reports
`FINDING SC_USEDBY_NOCITE id=S120 path=corpus/knowledge/openbao-acl-policy-semantics.md`. The exact row
strings are in the build report §4.

## 5. Cookie/credential hygiene (QM72)

No response carried a `Set-Cookie` or `Cookie` header (0 lines each), so there was no cookie value to
remove; the headers files are sanitized anyway by a stated rule and say so in their own first lines
(`Set-Cookie`/`Cookie` → `<header removed (QM72): …>`, 0 applied; `x-github-request-id` /
`x-fastly-request-id` → `<value removed (QM72): …>`, 1 each). No cookie, session id, token or other
credential-shaped string appears in any file this seat wrote. No `bao` server was started and no vault
was opened by this seat.

## 6. Files written

```
.ufo/waves/round-58/capture/{S118,S119,S120,S121}.body        (decoded bodies)
.ufo/waves/round-58/capture/{S118,S119,S120,S121}.headers      (sanitized, QM72)
.ufo/waves/round-58/capture/fetch-receipt.txt
.ufo/waves/round-58/build/R58ScoutSources/report.md
.ufo/waves/round-58/build/R58ScoutSources/quote-locate-receipt.tsv
.ufo/waves/round-58/w1/R58ScoutSources.md                    (this file)
```

Nothing else in the lane was touched: no `corpus/`, no `plans/`, no fleet-root file, no sibling lane.
Scratch under `${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r58/R58ScoutSources/` is deleted before yield.

## 7. Handoff

- **L1 (KagiR58):** apply the §4 recipe (three parts) for S120; re-point the two landed `location`
  cells to the round capture dir; replace the four non-locating quote strings (S118 capture quote,
  S118 `teaches`, S119 `teaches`) with the located forms in the build report §2. The scribe's capture
  copies and mine are byte-identical, so nothing else must change.
- **R58ScribeLesson:** the `## Gate` row for S118/S119/S120 can be written from build report §5 —
  use the **live** heading wording (D12): `Policy syntax`, `Capabilities`, `Usage`,
  `Create/Update/Patch ACL policy`, `Delete ACL policy`.
- **Unresolved / not mine:** the round-58 lesson does not exist yet; the knowledge entry names only
  S118/S119 and must record S120 on a `cites:` (or `source:`) line if S120 is added. No policy
  *semantics* were exercised here — every claim above is a documented claim; the trial receipts are the
  behavioural evidence.
