# R59ScoutSources — round 59, seat report (scout: the two declared transit sources, opened live)

Lane `/home/vgpnk/Projects/shokunin/kagi-shokunin`, branch `master`. BASE claimed
`5fa6e658f36bd9e440cb567fbbd2bfac88f868b6`. Read-only git/jj: no `git add/commit/stash/push`, no
mutating `jj`, no write into the fleet root, a sibling lane or the lane's git/jj index. The L1
(`KagiR59`) holds the canonical planner seat and is the sole integration owner and committer; this
seat returns findings and files only.

Predeclaration read before any work: `plans/round-59.md` (frozen; commit `af7b6651`) and
`corpus/lessons/round-58-verifier-spotcheck.md`. **No frozen predicate, target, POP, kill rule or
item condition was amended.**

Full evidence: `.ufo/waves/round-59/build/R59ScoutSources/sources.md` (URLs, access date, HTTP
status, bytes, sha256, header-removal note, the 60-row located-quote table, §Gaps) and
`.ufo/waves/round-59/build/R59ScoutSources/locate.txt` (raw locate outputs).

Tools: `curl`, `python3` 3.14.8 (stdlib only), `sha256sum` — all preinstalled. **No install or
upgrade was made**; the pacman channel is PAUSED host-wide (orchestrator ruling 2026-10-20) and
nothing here needed one. No tool was downgraded; no host service was restarted.

---

## 1. The two declared sources, opened live (2026-11-07)

| id | URL | HTTP | bytes | sha256 of body |
|---|---|---|---|---|
| S121 | https://openbao.org/docs/secrets/transit/ | 200 | 48604 | `d8879a2a4d784cd734bc32b3b60a0d1180a9373bff2e9b7d76a3bb7bce7b0a19` |
| S122 | https://openbao.org/docs/api/secret/transit/ | 200 | 267984 | `ad1a47d369be288c7091836fd1ebadc1534f33fb17780b9d7810d2ff808b657e` |

Both are OpenBao docs **Version 2.7.x** (`Version: Version 2.7.x`; body class `docs-version-2.7.x`)
— the same docs branch as the measured binary OpenBao v2.7.2. No redirect on either URL;
`content-length` equals the byte count on both.

Captures written by this seat (only these paths):

- `.ufo/waves/round-59/capture/S121.body`, `S121.headers`
- `.ufo/waves/round-59/capture/S122.body`, `S122.headers`
- `.ufo/waves/round-59/build/R59ScoutSources/sources.md`, `locate.txt`
- `.ufo/waves/round-59/w1/R59ScoutSources.md` (this report)

**Header removal.** Both header files had every `set-cookie:` / `cookie:` line removed before
writing — **0 such lines were present in either response**, so nothing was stripped; the one-line
removal note is appended at the end of each file. The two server-issued per-request correlation ids
per file (`x-github-request-id`, `x-fastly-request-id`) were additionally replaced by a placeholder.
No cookie value, session id or credential-shaped token is in any artifact; the bodies contain no
`hvs.`/`hvb.` shape.

## 2. Located quotes — 60 of 60, all against this seat's own capture

Verifier: `python3 corpus/rendered-text-v1.py locate .ufo/waves/round-59/capture/<id>.body '<quote>'`
run from the lane root; exit 0 iff `count >= 1`. Every quote ≤ 25 words, verbatim, and every one
returned `count>=1` (rc=0). Full table with per-quote locate output is in `build/R59ScoutSources/sources.md`
§2; raw outputs in `build/R59ScoutSources/locate.txt`.

The five plan mechanics each have located support:

| plan mechanic | carrying quotes |
|---|---|
| vault:v prefix | Q01, Q02, Q03 (+Q41 `vault:v2:` sample body) |
| rotate | Q04, Q05, Q06, Q08, Q36, Q40, Q54, Q62, Q63 |
| rewrap | Q07, Q09, Q17, Q18, Q34, Q41, Q49 |
| min_decryption_version | Q14, Q15, Q16, Q22, Q23, Q39, Q42, Q43, Q51, Q57 |
| convergent_encryption + context | Q10–Q13, Q24, Q26–Q30, Q32, Q35, Q37, Q38, Q60 |

Endpoint paths the trial will call, located on S122: `POST /transit/encrypt/:name` (Q47),
`POST /transit/decrypt/:name` (Q48), `POST /transit/rewrap/:name` (Q49),
`POST /transit/keys/:name/rotate` (Q50), `POST /transit/keys/:name/config` (Q51),
`POST /transit/keys/:name/trim` (Q53).

## 3. Statements that narrow or contradict the plan's mechanics (full text in sources.md §3)

- **N1/N2 — `min_decryption_version`**: the pages describe it as a *reversible rotation-policy* control
  ("in an emergency the min_decryption_version can be moved back", Q14) and say the boundary
  **archives** rather than deletes older versions (Q16). They couple it to `min_encryption_version`
  (Q22, Q23) and make `trim` the destructive control (Q42, Q43). **No page names an error, status
  code or refusal string** for a version below the floor.
- **N3 — rewrap is not a pure key-version migration**: S121 states "OpenBao will decrypt the value
  using the appropriate key in the keyring and then encrypted the resulting plaintext with the
  newest key in the keyring" (Q34). The plan's T3 wording "without a decrypt round trip" is
  **narrower than the page text**: no *client-side* plaintext round trip, but a server-side one.
  This is the most load-bearing narrowing for T3.
- **N4 — convergent mode is a key-creation value**: it "requires derived to be set to true" (Q12) and
  "the values set here cannot be changed after key creation" (Q31, Q37). A trial that creates a
  plain key and later enables convergent encryption cannot.
- **N5 — convergent mode has a nonce requirement**: the pages tie it to a client-supplied nonce of a
  fixed length (96-bit / 192-bit) and a nonce-uniqueness hazard (Q29, Q26, Q35), while the
  key-creation text says the nonce is *derived* (Q32). The plan's T5 mentions no nonce at all.
- **N6 — key-type limits**: rotate/rewrap "only supported with keys that support encryption and
  decryption operations" (Q40); imported keys need `allow_rotation` (Q54); **external keys do not
  support convergent encryption or context-derived keys** (Q24).
- **N7** — convergent-encryption *versions* (1/2/3) are a different axis from key versions (Q27, Q60).
- **N8/N9** — plaintext/ciphertext base64 requirements (Q19, Q21, Q46) and the prefix semantics
  (Q01–Q03): the `v1` is the **key version**, `vault` the product prefix.

## 4. §Gaps — mechanics with NO page support (sources.md §4, G1–G10)

The named error for a version below `min_decryption_version` (G1) and the tamper-refusal error (G2)
are nowhere on either page (a full-text scan for `failed to decrypt`, `invalid ciphertext`,
`cannot decrypt`, `permission denied`, `forbidden` returns 0 matches on both captures). Also
un-documented: that the ciphertext omits the plaintext (G3), the **converse** halves of the
determinism claims — different context ⇒ different ciphertext (G4, G9) and a non-convergent key ⇒
different ciphertext for identical plaintext (G5) — the explicit post-rotation and post-rewrap
end-to-end results (G6, G7, G10) and the no-nonce form of convergent mode (G8). Those legs are the
trial's to measure, not the pages' to quote.

## 5. Notes for the L1 (registry rows — the L1 appends them)

- `corpus/SOURCES.md` ends at **S120**; there is no S121 row at BASE, so S121/S122 are new rows.
  Recommended: tier A, `mined`, `opened 2026-11-07`, **recheck `180d`** (both pages are the current
  2.7.x branch; the CDN copy was fresh, `last-modified: Fri, 06 Nov 2026 09:07:02 GMT`).
- **Id-collision warning — RESOLVED by the L1 (KagiR59, 2026-11-07).** `.ufo/waves/round-58/capture/S121.body`
  exists but is a *different URL* — the rejected token-CLI page (32638 B, sha256 `37e706c2…`), which
  round 58 rejected and never gave a registry row. The two capture trees do not collide on disk
  (different round directories), but a checker that resolves a capture by **id** rather than by path
  would read the wrong body. **Decision: keep S121 = the transit concepts page and S122 = the transit
  API page.** The registry is the SSOT and both ids are free there; the round-58 file is an
  unreferenced staging capture and no manifest (`corpus/quote-bodies.tsv`,
  `corpus/recheck-captures.tsv`, `corpus/source-fetches.tsv`) binds it. The L1 lands the mitigation
  in the registry: each new row's anchor cell names the capture path explicitly and states that the
  round-58 staging file of the same id is the rejected token-CLI page, not this source. Nothing
  changes in this seat's captures.
- No secret value, token, cookie, session id or vault/item/field name appears in any artifact this
  seat wrote.

SEAT-STATUS: complete
