# SourceS049 — NIST SP 800-57 Part 1 Rev. 6 IPD row (candidate 62a33b1b)

**VERDICT: FAIL (narrow — scope/grounding in `anchor` + `teaches` only).** The registered URL, byte count, row identity, retained raw digest, rendered-text-v1 digest, 19-word Gate quote (count=1) and every Rev. 6 status fact reproduce. The failure is that `anchor`/`teaches` assert Rev. 5's publication status, which the registered S049 page never states and which has no registered row (`corpus/lessons/round-28.md:37` marks r5/final NOT REGISTERED); the “no Rev. 6 final” negative also lacks the page's Document-History anchor and the contract-required sweep. No production edit; no lane gate/selftest run.

Row under test (candidate `62a33b1bd15217ed729df2ca40c8a30aba3076c0`):
- `corpus/SOURCES.md:56` — S049 registry row (11 cells; awk NF=13).
- `corpus/source-fetches.tsv:92` — 16-field capture row.
- `corpus/lessons/round-28.md:36` — Gate admission; `:37` — r5/final NOT REGISTERED; `:1` — `source:` list.
- BASE `3553d499`: `git show BASE:corpus/SOURCES.md | grep -c '^| S049 '` → 0, so the row is candidate-introduced.

**Status/eligibility/draft qualifiers (as registered):** status `mined` (registry and capture agree; lesson cites S049 at `:1` and `:36`); kind `spec`, tier A for the declared status-only scope; opened `2026-10-21`; recheck `90d`; used-by `corpus/lessons/round-28.md` only. Draft/IPD qualifiers are present and correct for Rev. 6: “Initial Public Draft”, “closed-comment draft”, “not final guidance and not an adopted control”; the page is not a final publication. Representation `decoded-http-body-volatile-v1`: the raw digest is a point attestation, the normalized text is the stable identity.

## F1 — scope overclaim: Rev. 5 status is not on the registered page

`SOURCES.md:56` anchor: “…publication page fetched 2026-10-21 **(Rev. 5 final remains the published Part 1)**”; teaches: “…**must cite Rev. 5 final**, not Rev. 6 IPD text…”. The declared scope is “SP 800-57 Part 1 Rev. **6** publication status only”.

My capture (retained `captures/S049.body` and two live GETs) contains `Rev. 5` = 0, `r5/final` = 0, `Supersedes` = 0; `Revision 5` = 1, only “Some of the proposed changes from Revision 5 include:”. The page's Document History is one current entry: “12/05/25: SP 800-57 Rev. 6 (Draft)” (`#pub-history-container`, `data-total="1"`, `data-current-document='true'`). The page therefore cannot ground the parenthetical or the “must cite Rev. 5 final” clause.

The Rev. 5 fact is true: I fetched `https://csrc.nist.gov/pubs/sp/800/57/pt1/r5/final` myself — HTTP 200, 47,027 B, Document History “05/04/20: SP 800-57 Part 1 Rev. 5 (Final)” (current), quote count=1 — but that page is explicitly NOT REGISTERED (`lessons/round-28.md:37`) and is outside the row's Rev. 6 scope. This is a grounding/registry defect, not a false fact.

**Concrete counterexample:** the registered page has no sentence saying Rev. 5 is final or current; the anchor cell's parenthetical is not an anchor to this page (contract v1: anchor = exact section/heading/page/line + revision).

## F2 — the negative claim is true but not anchored or swept in the row

Scope: “no Rev. 6 final at fetch”; teaches: “Rev. 6 exists only as a closed-comment draft”. The page's `#pub-history-container` (one current Draft entry, no `Supersedes`) is the element that grounds the draft-only status, but the registered anchor names only Announcement (`#pub-announcement`) and Comments Due (`#pub-comments-due`). Contract v1 rule 5 (“A negative claim carries its sweep”) is not met by the row or Gate; the 404/listings sweep exists only in the build scout (`build/SrcFrontierNist.md` F3), which this attack forbids treating as verification.

My independent sweep (exit 0 each): `/r6/final`, `/r6/draft`, `/r6` → 404 ×3; final-pubs listing 200, 1,274,851 B, 800-57 entries = Part 1 Rev.5 (Final), Part 2 Rev.1 (Final), Part 3 Rev.1 (Final), `Rev. 6` count 0; draft-pubs listing 200, 290,636 B, one 800-57 entry “SP 800-57 Rev. 6 (Initial Public Draft)”. The claim is true on these routes; the row must carry the sweep or the `#pub-history-container` anchor.

## F3 — verified, not defects

| Check | Evidence | Result |
|---|---|---|
| source | live HTTP 200 at registered URL, final URL identical; header h3 `#pub-header-display-container` “NIST SP 800-57 Rev. 6 (Initial Public Draft)”; `dcterms.title` keeps “Part 1” (the `<h1>` itself is the Recommendation title) | PASS |
| Rev. 6 scope | “Date Published: December 5, 2025” (`2025-12-05`); “Comments Due: February 5, 2026 (public comment period is CLOSED)”; one current Draft history entry; no `Supersedes` | PASS |
| anchor ids | `#pub-announcement` 1 occurrence, quote in its `<p>` after `<h4>Announcement</h4>`; `#pub-comments-due` 1 occurrence on the Comments Due span | PASS |
| Gate quote | 19 words (`wc -w` exit 0), ≤25; `rendered-text-v1.py locate` count=1 on retained capture and both live bodies (exit 0); byte-identical across SOURCES cell 7, TSV col 13, lesson `:36`, and the page | PASS |
| identity/sha/bytes | `sha256("S049\tmined\t<url>\n")` = `159f992e…d993` == TSV col 3; retained raw `783c37dc…7d4d` == col 10; `wc -c` 47,868 == col 11; normalized `d900f1ea…1cd1` == col 15 | PASS |
| live volatility | two live GETs: raw `023d3cc9…` / `3e800c19…`, both 47,868 B, both normalized `d900f1ea…`; 554 differing bytes are Cloudflare email-protection tokens and `__CF$cv$params` nonces | PASS (declared volatile) |
| status/profile | TSV col 2 `mined` == registry; profile `curl-fsSL-compressed-v1`; status 200; fetched 2026-10-21; revision `-` | PASS |

## Commands run (actual, exit)

```
git -C <lane> rev-parse HEAD                                      # 0  62a33b1b…
curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)' <S049-url>   # 0,0; 200; 47,868 B each
sha256sum fetch/body1.html fetch/body2.html                       # 0  023d3cc9… / 3e800c19…
python3 norm.py digest fetch/body1.html                            # 0  d900f1ea…, 47,868 B, norm 6,175
python3 norm.py digest fetch/body2.html                            # 0  d900f1ea… (same)
python3 norm.py locate fetch/body1.html '<quote>'                  # 0  count=1
python3 norm.py locate fetch/body2.html '<quote>'                  # 0  count=1
sha256sum <lane>/.ufo/waves/round-28/captures/S049.body; wc -c     # 0  783c37dc…; 47,868
python3 norm.py digest captures/S049.body                          # 0  783c37dc…/d900f1ea…
python3 norm.py locate captures/S049.body '<quote>'                # 0  count=1
printf 'S049\tmined\thttps://csrc.nist.gov/pubs/sp/800/57/pt1/r6/ipd\n' | sha256sum   # 0  159f992e…
printf '%s' '<quote>' | wc -w                                      # 0  19
python3 - <<'PY' (quote equality; re counts; line numbers)         # 0  True; 56,92,36; Rev.5=0, Revision 5=1
curl -sS -o /dev/null -L -w '%{http_code}' <r6/final|r6/draft|r6> # 0  404,404,404
curl --http1.1 -fsSL --compressed … final-pubs                    # 0  200; 1,274,851 B (first HTTP/2 try exit 92, truncated 572,808 B)
curl -fsSL --compressed … draft-pubs                              # 0  200; 290,636 B; one 800-57 entry
curl -fsSL --compressed … r5/final                                # 0  200; 47,027 B; “SP 800-57 Part 1 Rev. 5 (Final)” count=1
```

`norm.py` is a byte copy of `corpus/rendered-text-v1.py` (`sha256 7d6bfe8154898f8584e213bcf98936a0819ace75fd80f3dcc87bce1edd1dc7bf`, both files).

## Not checked / bounds

- No SP 800-57 Part 1 PDF (Rev. 5 or Rev. 6) opened; no key-management mechanism or control claim read.
- The 404s and two listings are dated point observations, not exhaustive route/search coverage; an unlisted Rev. 6 final route is not excluded by the page alone.
- No lane census/gate/selftest executed; no production edit; no vault/account/handler/CDP contact; no host-private reads; no tool installs.
- Other source rows (S044–S048) not touched. Out-of-row observation: `corpus/README.md:114` still points at `SOURCES.md` §Leads “(unopened)” for NIST while `README.md:241-243` records S049 opened; a stale index line, not a claim in S049.

**Fix advice (wording/registry only):** drop the parenthetical from `anchor` and the “must cite Rev. 5 final” clause from `teaches`, or register the r5 page as its own row (scope “Rev. 5 final status only; no currency claim”) and cite it; add `#pub-history-container` to `anchor` and record the no-final sweep in the scope or Gate. No capture, identity, byte or digest change is implied.

## Repair check — 5e847472 (S051 successor; finding closed, ≤10 lines)

**F1/F2 status: CLOSED by S051.** `corpus/SOURCES.md:58` adds S051 with scope “Rev. 6 Initial Public Draft publication and closed comment period only; no latest-final or adopted-control claim”, an anchor without the Rev. 5 parenthetical, and a teaches opening exactly `supersedes S049 — … not which revision is the latest final or which control must be adopted.` The lesson records it at `:134,:143` (“S051 supersedes S049's unsupported latest-final / adoption claim. Existing rows remain immutable.”); S049 (`:56`) is untouched, the contract-rule-2 correction.
Capture: `corpus/source-fetches.tsv:94` identity `88967f02…28f4` recomputes from `S051\tmined\t<url>`; same URL, `783c37dc…7d4d`, 47,868 B, `d900f1ea…1cd1`, quote/location identical to `:92`; `captures/S051.body` is byte-identical to `S049.body`. F2 is moot (S051 asserts no “no final”/“exists only”). Residual (not reopened): `captures/metadata.json` still lists only S044–S049; the declared TSV row is present, so this is sidecar bookkeeping for L1. No new fetch, no gate run.
