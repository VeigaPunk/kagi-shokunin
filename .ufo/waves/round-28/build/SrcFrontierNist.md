# SrcFrontierNist — SP 800-57 Part 1 status opening (round 28)

BASE `3553d499577084a6c98d7078906017840bbf7b28`. Target opened 2026-10-21. Captures under
`.ufo/waves/round-28/sandboxes/SrcFrontierNist/`. No tool installs; no lane gate run; no
production write. This report is advice, not a closure mark.

## Findings
**F1 — the target is Final, not an IPD.** `https://csrc.nist.gov/pubs/sp/800/57/pt1/r5/final` →
HTTP 200, final URL unchanged, `text/html; charset=utf-8`, decoded body 47,027 bytes. Exact title
(`dcterms.title`, `r5-final.census.html:17`): “NIST Special Publication (SP) 800-57 Part 1 Rev. 5,
Recommendation for Key Management: Part 1 – General”. Date Published “May 2020” (`:423`;
`citation_publication_date 2020/05/04`, `:27`); DOI `10.6028/NIST.SP.800-57pt1r5`; Supersedes
“SP 800-57 Part 1 Rev. 4 (01/28/2016)” (`:432`); Document History “10/08/19 … (Draft)” →
“05/04/20 … (Final)” (`:519-520`). No Comments-Due field (`grep -c` = 0).
**F2 — a Rev. 6 draft EXISTS.** `https://csrc.nist.gov/pubs/sp/800/57/pt1/r6/ipd` → HTTP 200,
decoded body 47,868 bytes. Exact title (`dcterms.title`/`og:title`, `r6-ipd.census.html:17,38`):
“NIST Special Publication (SP) 800-57 Rev. 6 (Draft), Recommendation for Key Management: Part 1 –
General”; H1 “NIST SP 800-57 Rev. 6 (Initial Public Draft)”. Date Published December 5, 2025
(`:427`; citation `2025/12/05`, `:28`); Comments Due “February 5, 2026 (public comment period is
CLOSED)” (`:429`); DOI `10.6028/NIST.SP.800-57pt1r6.ipd`; history holds only the 12/05/25 Draft
entry (`:533`). No `Supersedes` field: only the announcement says “proposed changes from Revision
5” (`:453`). Calibration note: the `<title>` tag drops “Part 1” while `dcterms.title` keeps it.
**F3 — no Rev. 6 final on the routes checked.** `/r6/final`, `/r6/draft`, `/r6`, `/r6/ipd2`,
`/r6/2pd` → HTTP 404 (`r6-r6-final.html`, `r6-r6-draft.html` saved). The All Public Drafts listing
(200) carries exactly one 800-57 row — “SP 800-57 Rev. 6 (Initial Public Draft)”, 12/05/2025,
Draft, link `/pubs/sp/800/57/pt1/r6/ipd` (`drafts-listing.html`); the Final Pubs listing (200,
1,274,851 bytes) carries “SP 800-57 Part 1 Rev. 5 (Final)” and no Part 1 Rev. 6
(`final-pubs.html`). [Negative observations dated 2026-10-21; an unchecked route could exist.]
**F4 — calibration hazard: the target has no forward pointer.** `rendered-text-v1 locate "Rev. 6"`
on the target: count=0, exit 1; `"Revision 6"`: count=0, exit 1. A row admitted only on the target
establishes “Rev. 5 is Final” but cannot establish currency, and the page itself gives a reader no
signal that Rev. 6 exists.
**F5 — raw body is response-coupled; normalized text is stable.** Three same-day target captures
differ in raw sha256 (`9d81a09a…`, `3e392ac5…`, `879c7193…`) at identical 47,027 bytes: Cloudflare
email-protection tokens and `__CF$cv$params` nonces differ (`diff` lines 431, 688, 724). All three
normalize to `950ae8a8ad88da31fa82856e9f8db0306e8422b3c175300c4eb18fa3d08c562e` (5,548 bytes).
Rev. 6 raw `ae999e96…`/`1020904f…`/`332208e3…`, normalized
`d900f1ea2867f9991a47abdb6175cbe235ea7d4c3aa773c5f26af950d0bb1cd1` (6,175 bytes). Representation
must be `decoded-http-body-volatile-v1`; the raw digest is a point attestation.
**F6 — `%{size_download}` under `--compressed` is not the decoded-body size.** The exact-profile
fetch reported `size_download` 9,404 / 9,995 while `wc -c` gives 47,027 / 47,868. SC_FETCH checks
only `^[1-9][0-9]*$` (`corpus/sources-census.sh:270`), so a compressed count would pass the gate
but be false. Record `wc -c` of the decoded body.
**F7 — no duplicate URL.** `grep -c 'csrc.nist.gov'` over `corpus/SOURCES.md`,
`corpus/source-fetches.tsv`, `corpus/inrow-pins.tsv` → 0/0/0 (exit 1 = no match). The only NIST
text in SOURCES.md is the lead at `corpus/SOURCES.md:83` (no URL) and the 800-133 lead at `:84`.
Adding either URL creates no W04 line; the 11 START W04 lines are pre-existing duplicate URLs,
none NIST (`.ufo/waves/round-28/census-start.txt:2-12`).

## Row recommendation

**ADMIT the Rev. 6 IPD as the round's NIST status row. REJECT the assigned target as the sole row
for this purpose.** The target grounds “Rev. 5 is Final” (F1) but cannot answer the lead's “whether
Rev. 6 draft exists” branch (F4); a row teaching “Final” without a currency qualifier is the
stale-status failure. The target page is truthful and citable — reject the *use*, not the page.
Flip: admit it as a companion historical-status row if L1 wants the last-final identity in-registry,
or when a Rev. 5 mechanism teaching is adopted. If L1 admits only the target, its scope must carry
“no currency claim — Rev. 6 exists as an IPD”, which needs evidence from outside the row.

Tier **A** (primary NIST publication page, authoritative for its own status/date/DOI), kind
`spec`. Id: next free — S044/S045 are claimed at
`.ufo/waves/round-28/build/ScribeSourcesRows.md:1,34-39`, S046 at the earliest for a feed row
(`SrcFeedPythonCurl.md:23`).

```
| S0xx | NIST SP 800-57 Part 1 Rev. 6, Initial Public Draft — https://csrc.nist.gov/pubs/sp/800/57/pt1/r6/ipd | spec | A | SP 800-57 Part 1 Rev. 6 publication status: Initial Public Draft published 2025-12-05, comment period closed 2026-02-05, no Rev. 6 final published (r6/final HTTP 404 on 2026-10-21); status metadata only, not final guidance and not an adopted key-management control | Announcement (#pub-announcement), Comments Due (#pub-comments-due), Document History (#pub-history-container); fetched 2026-10-21 | SP 800-57 Part 1 Rev. 6 exists only as an Initial Public Draft whose comment period has closed; no final is published, so its text cannot be cited as final guidance. Quote: “The initial draft of NIST SP 800-57 Part 1 Revision 6 is available for comment through February 5, 2026.” (#pub-announcement). | mined | 2026-10-21 | 90d | corpus/lessons/round-28.md |
```

Provenance row (16 tab-separated columns; decoded 47,868 B, quote 19 words, locate count=1):

```
<ID>	mined	<IDENTITY>	https://csrc.nist.gov/pubs/sp/800/57/pt1/r6/ipd	https://csrc.nist.gov/pubs/sp/800/57/pt1/r6/ipd	200	curl-fsSL-compressed-v1	2026-10-21	decoded-http-body-volatile-v1	332208e34d9a1f7825077b8ee380dc616dba8c95b938b0ff8b2167420612cf21	47868	-	The initial draft of NIST SP 800-57 Part 1 Revision 6 is available for comment through February 5, 2026.	rendered-text-v1	d900f1ea2867f9991a47abdb6175cbe235ea7d4c3aa773c5f26af950d0bb1cd1	#pub-announcement (Announcement); #pub-comments-due (Comments Due: February 5, 2026 (public comment period is CLOSED))
```

`<IDENTITY>` = `printf '<ID>\tmined\t<URL>\n' | sha256sum` (`corpus/sources-census.sh:263`).
Precomputed: S046+r6 `486334f40f6a47f218b1515ecabece2d3e901777fac53c6c908a7cec1e477939`;
S047+r6 `eddb5b08c1c5dfa4baae4b98aaa799a4cb3375acd4e15a4ba05f70adbb77b2f4`.

Companion row, only if L1 admits the target (r5 identity S047+r5
`9b30b6ba9e62a4713e8474972a51533cfda7f84e9456375c1e6d150584acfe09`; capture raw
`879c7193edda4a8e818731954222b069908f53d557d3e38a50ea25cdd67811b9`, 47,027 bytes; quote
`SP 800-57 Part 1 Rev. 5 (Final)`, 7 words, locate count=1; normalized
`950ae8a8ad88da31fa82856e9f8db0306e8422b3c175300c4eb18fa3d08c562e`; location
`#pub-history-container (Document History, 05/04/20 Final entry)`):

```
| S0xx | NIST SP 800-57 Part 1 Rev. 5, Final — https://csrc.nist.gov/pubs/sp/800/57/pt1/r5/final | spec | A | Rev. 5 final status only: published May 2020 (citation date 2020/05/04), superseding Rev. 4; no currency claim — Rev. 6 exists as an IPD | Document History (#pub-history-container, 05/04/20 entry), Date Published (#pub-release-date); fetched 2026-10-21 | SP 800-57 Part 1 Rev. 5 is Final, not an IPD; its own history records the 2019 draft and the 2020 final. Quote: “SP 800-57 Part 1 Rev. 5 (Final)” (Document History, 05/04/20 entry). | mined | 2026-10-21 | 90d | corpus/lessons/round-28.md |
```

Row-slot side effects: any admitted row moves the count-only pin R21-02 (`corpus/claim-ledger.tsv:52`,
`rows=43 … captures=43`) and requires the lesson's `source:` line to name the id
(`corpus/sources-census.sh:354`); both are L1/scribe work. The +1 row/+1 capture arithmetic is
inference, not measured.

## Commands run (sandbox-only)

| command | exit | result |
|---|---|---|
| `curl -sS -L -o nist-800-57-pt1-r5.html <target>` | 0 | 200, 47,027 B, sha `9d81a09a…` |
| `curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)' <target>` | 0 | 200, decoded 47,027 B, sha `879c7193…`, normalized `950ae8a8…` |
| same profile on `/r6/ipd` | 0 | 200, decoded 47,868 B, sha `332208e3…`, normalized `d900f1ea…` |
| `curl -sS -o /dev/null -L -w '%{http_code}'` on `/r6/{final,draft,ipd2,2pd}` and `/r6` | 0 | 404 ×5 |
| `curl -fsSL --compressed … /publications/{draft-pubs,final-pubs}` | 0 | 200; only Rev. 6 IPD draft, only Part 1 Rev. 5 final |
| `python3 -I -B rendered-text-v1.py digest/locate <capture>` | 0 | digests above; proposed quotes count=1 |
| `… locate r5-final "Rev. 6"` / `"Revision 6"` | 1 | count=0 (no forward pointer) |
| `grep -c 'csrc.nist.gov' corpus/{SOURCES.md,source-fetches.tsv,inrow-pins.tsv}` | 1 | 0/0/0 (no match) |
| `git cat-file -p BASE:corpus/rendered-text-v1.py > …/norm/…` | 0 | 192 lines, run from sandbox only |
## What I did NOT check

- No SP 800-57 Part 1 PDF (Rev. 5 or Rev. 6) was opened; no normative key-management mechanism
  (cryptoperiod, key states, storage) was read, so no mechanism/control claim is possible. The
  Rev. 5 IPD page (`/r5/ipd`, HTTP 200) and the Rev. 6 “public comments received” PDF were not opened.
- Rev. 6 second-draft routes beyond those listed, and JS-rendered CSRC search results, were not
  checked; the 404s and listings are dated page observations, not exhaustiveness proofs. Part 2/
  Part 3 and SP 800-133 Rev. 3 status were not checked.
- No lane gate/census/selftest was run and no sandbox row was integrated; the templates above are
  unverified drafts (SC_FETCH requires the provenance row, `corpus/sources-census.sh:328`).
- No `source:` line in `corpus/lessons/round-28.md` exists yet; the used-by citation is a
  prerequisite, not a fact. Response variance across other user agents/IPs was not tested; only
  two curl profiles were used (normalized text identical).
