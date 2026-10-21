# SourceS047 — FAIL (narrow): registered `teaches` drops the page's GHES exclusion

**Verdict: FAIL (narrow, qualification-only).** The capture, identity, anchor, 21-word quote,
normalizer location and sha/bytes fields all verify. The registered `teaches`/`scope` cell is
broader than the captured page on one qualifier.

Candidate `62a33b1bd15217ed729df2ca40c8a30aba3076c0`. Cells cited from `git show 62a33b1b:<path>`:
- `corpus/SOURCES.md:54` — S047 row (absent at BASE: `git show BASE:corpus/SOURCES.md | grep -c S047` = 0, exit 1)
- `corpus/source-fetches.tsv:90` — 16-field provenance row
- `corpus/lessons/round-28.md:34` — Gate row; `corpus/README.md:241-243` — "registry rows only"
- `.ufo/waves/round-28/captures/S047.body` and `captures/metadata.json:60-75` (both committed at candidate)

**Status/eligibility/draft qualifiers (as registered):** status `mined`; tier A `docs`; opened
`2026-10-21`; recheck `90d`; used-by `corpus/lessons/round-28.md` only; frontier-only ("They are
registry rows only; no knowledge entry or coverage ground", `corpus/README.md:243`); page is a live
unversioned doc, not a draft/IPD; representation `decoded-http-body-volatile-v1` (raw digest is a
point attestation, normalized text is the stable identity).

## F1 — the failure: `teaches` omits the page's own GHES carve-out

`corpus/SOURCES.md:54` teaches: “immutable owner/repo-ID subjects for repositories created after
2026-07-15”, concluding “a quoted subject string is not a current template.”

Page, verbatim (capture normalized offset 9839; identical in my live re-fetch, `locate` count=1 on
both): “The sub claim in this example uses the previous format. Repositories created after July 15,
2026 use an immutable default subject format that includes owner and repository IDs (not available
on GitHub Enterprise Server).”

**Concrete counterexample:** a GitHub Enterprise Server repository created after 2026-07-15 does
not receive the immutable default subject format — the page says exactly that — so the registered
conclusion (“not a current template”) is false there. `scope`'s “GitHub only” does not exclude
GHES; this lane uses “GitHub.com” when it means the deployment (S019, `corpus/SOURCES.md:25`:
“GitHub.com/private-repository requirements remain separate qualifiers”). The cell as written
therefore overclaims the immutable-format scope.

**Fix advice (wording only):** append “(not available on GitHub Enterprise Server)” to the
parenthetical and narrow `scope` to deployments where the page's format applies. No capture,
identity, admission or digest change is implied.

## F2 — verified, not defects (the attack's other legs, all PASS)

| Check | Evidence | Result |
|---|---|---|
| identity | recomputed `sha256("S047\tmined\t<url>\n")` = `55e53959…43c9` == TSV col 3 | PASS |
| raw digest/bytes | `sha256sum captures/S047.body` = `bb94459d…ce2d`; `wc -c` 357518 == TSV cols 10-11 | PASS |
| row shape | 16 fields; one S047 row (`grep -c '^S047'` = 1); status/url/final/http/profile/fetched/representation/revision/normalization are census-legal | PASS |
| independent fetch | `curl` URL → HTTP 200, final URL identical, decoded 357518 B (exit 0) | PASS |
| freshness | two live re-fetches (my UA, Gate UA) raw `66d33e59…` / `ef9ec7c2…`, both normalized `c345f249…` = TSV col 15 (15403 B); capture-vs-live diff is 6 lines and my-UA-vs-Gate-UA is 2 lines, all Next.js chunk/build-ID strings, no text | PASS (declared volatile) |
| quote gate | 21 words (`wc -w` exit 0) ≤ 25; `rendered-text-v1.py locate` count=1 on capture and live (exit 0 both) | PASS |
| anchor | real `<h2 id="understanding-the-oidc-token">` (1 occurrence); quote inside it (normalized offsets: h2 8247 < quote 8558 < next section 10113) | PASS |
| legacy 301 | legacy security-hardening path → HTTP/2 301, `location: /en/actions/concepts/security/openid-connect` (exit 0) | PASS |
| no displayed version/date | rendered text has no version label/date; `2026-10-16`, `2026-03-10`, `2022-11-28` are script-JSON GHES/API values removed by the normalizer | PASS |
| scope core | page sentence “the cloud provider checks if the OIDC token's subject and other claims are a match for the conditions that were preconfigured” supports the claim-condition scope | PASS |

## F3 — boundary, not the verdict

`scope`'s “no audience/issuer matching rule (prose-absent)” holds only as “no specific rule text”: 0 `audience`/`issuer` words and no rule sentence, but the example JWTs carry `aud`/`iss` and the prose says “other claims are a match”; do not read it as “aud/iss are not matched”.

## Commands run (actual, exit)

| command | exit |
|---|---|
| `git -C <lane> rev-parse HEAD` → `62a33b1b…` | 0 |
| `curl -sS -L --compressed -A 'kagi-shokunin/1.0 (source verification)' -o S047.live.html -w 'http=%{http_code} final=%{url_effective} size=%{size_download}' <url>` → `http=200 final=<url> size=28482` (compressed; decoded 357518 B via `wc -c`) | 0 |
| `curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)' -o S047.gateua.html <url>` → 200, size=28442 | 0 |
| `sha256sum S047.live.html S047.gateua.html captures/S047.body` | 0 |
| `python3 -I -B corpus/rendered-text-v1.py digest` on capture, live and gateua bodies | 0 |
| `python3 -I -B corpus/rendered-text-v1.py locate` on capture and live bodies, with the quote → count=1 | 0 |
| `printf '%s' "<quote>" \| wc -w` → 21 | 0 |
| `grep -c 'id="understanding-the-oidc-token"' <live>` → 1 | 0 |
| `grep -oiE '\baudience\b\|\bissuer\b' <normalized>` → 0 | 0 |
| `curl -sS -o /dev/null -D - <legacy-path>` → 301, location exact | 0 |
| `diff <(tr '>' '\n' < capture) <(tr '>' '\n' < live)` → 6 changed lines, build IDs only | 1 (differences) |
| `git show 62a33b1b:corpus/SOURCES.md \| sed -n '54p'`; same for `source-fetches.tsv:90`, `lessons/round-28.md:34` | 0 |
| `git show BASE:corpus/SOURCES.md \| grep -c S047` → 0 | 1 (no match) |

## What I did NOT check

- No GHES page (the page's parenthetical suffices); no other source row (S044-S046, S048-S049) or C1/C2 fixture/tool; no lane census/gate/selftest in the lane checkout.
- No cloud-provider docs; no host-private reads, vault/account/handler/CDP contact, production edit, or tool install/update.

## Addendum — finding closed by successor S050 (HEAD 5e847472)

`corpus/SOURCES.md:57` registers S050 with scope “GitHub.com only; immutable-subject default is not available on GitHub Enterprise Server” and teaches “supersedes S047 — the immutable-subject format qualifier is GitHub.com-only (not available on GitHub Enterprise Server)”.
Same capture: `captures/S050.body` sha `bb94459d…` / 357518 B; `source-fetches.tsv:93` identity `6bfcc3b5…` = sha256(“S050\tmined\t<url>\n”), quote/location/normalized `c345f249…` identical.
`git diff 62a33b1b..HEAD` adds only S050/S051; S047:54 is untouched, so S047 itself still reads unqualified and closure rests on the supersession record (`corpus/lessons/round-28.md:133-134,143-144`).
**Verdict stands for S047:54 as written; the corpus-level overclaim is closed by S050.**
