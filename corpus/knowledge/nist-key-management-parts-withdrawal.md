source: S076 — https://csrc.nist.gov/pubs/sp/800/57/pt2/final — §Withdrawn on, §Superseded by, §Document History (08/25/05) — rendered-text-v1 sha256 `a4dad4f29c355b74`, fetched 2026-11-04; S077 — https://csrc.nist.gov/pubs/sp/800/57/pt3/final — §Withdrawn on, §Superseded by, §Document History (12/28/09) — rendered-text-v1 sha256 `1047a8228fc6392a`, fetched 2026-11-04; S078 — https://nvlpubs.nist.gov/nistpubs/Legacy/SP/nistspecialpublication800-57p2.pdf — "Withdrawn NIST Technical Series Publication" wrapper: Withdrawal Date, Withdrawal Note, Superseding Publication(s) — fetch sha256 `68266cb10868a1fe`, fetched 2026-11-04; S079 — https://nvlpubs.nist.gov/nistpubs/Legacy/SP/nistspecialpublication800-57p3.pdf — "Archived NIST Technical Series Publication" wrapper: Withdrawal Date, Withdrawal Note, Superseding Publication(s) — fetch sha256 `52b9a7d321ab0f81`, fetched 2026-11-04; S080 — https://csrc.nist.gov/pubs/sp/800/57/pt2/r1/final — §Date Published, §Supersedes, §Planning Note (07/01/2025), §Document History (05/23/19) — rendered-text-v1 sha256 `810b05568ddcea52`, fetched 2026-11-04; S081 — https://csrc.nist.gov/pubs/sp/800/57/pt3/r1/final — §Date Published, §Supersedes, §Planning Note (07/01/2025), §Document History (01/22/15) — rendered-text-v1 sha256 `c504bce605fd09ab`, fetched 2026-11-04; S082 — https://csrc.nist.gov/pubs/sp/800/131/a/r2/final — §Date Published, §Supersedes, §Planning Note (10/21/2024), §Document History (03/21/19) — rendered-text-v1 sha256 `ff257649b6da6458`, fetched 2026-11-04
verified-at: 2026-11-04 — all seven URLs fetched this round by this seat and every quoted string re-located in the normalized text (count=1 each); the two PDFs re-hash to the campaign capture's fetch sha256
recheck: 365d — `curl -fsSL 'https://nvlpubs.nist.gov/nistpubs/Legacy/SP/nistspecialpublication800-57p2.pdf' | pdftotext -layout - - | grep -c 'has been withdrawn (archived)'` -> 1 (ran 2026-11-04)
ground: Round-2 ledger item 7 — "SP 800-57 Part 2 and Part 3 substance" — and the status correction that item 7 exposed
Reverify: R33-02

# SP 800-57: two of the three parts are withdrawn, and their CSRC pages still print "(Final)"

**This entry corrects the status teaching proposed in round 2.** Round 2's
family-status teaching recorded Part 2 as finalised in 2005 and Part 3 as
finalised in 2009, on the strength of their CSRC publication pages. Both
documents are withdrawn. The pages do say so — each now carries a "Withdrawn
on" field and a "Superseded by" link [S076][S077] — but their Document History
still prints "(Final)", and the documents themselves open with a withdrawal
wrapper [S078][S079]. A revision history is therefore the wrong place to look
for currency.

## What the documents say

| Document | CSRC page says | The document itself says |
|---|---|---|
| SP 800-57 Part 2 (August 2005) | Document History "08/25/05: SP 800-57 Part 2 (Final)"; "Withdrawn on May 23, 2019"; "Superseded by SP 800-57 Part 2 Rev. 1" [S076] | "The attached publication has been withdrawn (archived), and is provided solely for historical purposes." Withdrawal Date **May 23, 2019**; withdrawal note: "SP 800-57 Part 2 is superseded in its entirety by the publication of SP 800-57 Part 2 Revision 1." [S078] |
| SP 800-57 Part 3 (December 2009) | Document History "12/28/09: SP 800-57 Part 3 (Final)"; "Withdrawn on January 22, 2015"; "Superseded by SP 800-57 Part 3 Rev. 1" [S077] | "The attached publication has been archived (withdrawn), and is provided solely for historical purposes." Withdrawal Date **January 2015** (the page carries the day: 22 January 2015); note names "Part 3 Revision 1 (January 2015)" [S079] |

Note the different wording on the two wrappers: Part 2 is stamped "**Withdrawn**
NIST Technical Series Publication" and Part 3 "**Archived** NIST Technical
Series Publication" [S078][S079]. Both mean the same thing for a citation.

## What is actually current

- **SP 800-57 Part 2 Rev. 1** — Date Published May 2019, Document History
  "05/23/19: SP 800-57 Part 2 Rev. 1 (Final)", Supersedes "SP 800-57 Part 2
  (08/25/2005)", DOI `https://doi.org/10.6028/NIST.SP.800-57pt2r1` [S080].
- **SP 800-57 Part 3 Rev. 1** — Date Published January 2015, Document History
  "01/22/15: SP 800-57 Part 3 Rev. 1 (Final)", Supersedes "SP 800-57 Part 3
  (12/28/2009)", DOI `https://doi.org/10.6028/NIST.SP.800-57pt3r1` [S081].
- Both Rev. 1 pages carry a Planning Note dated 07/01/2025: "This publication is
  currently being reviewed." [S080][S081]. A review is not a withdrawal; a control
  citing Rev. 1 today cites a current document that is under review, and should
  watch that note rather than re-reading the "(Final)" history line.

A control that cites "SP 800-57 Part 2" or "SP 800-57 Part 3" without a revision
is citing a document withdrawn in May 2019 and January 2015 respectively — more
than seven years ago in both cases at this entry's verification date.

## The reference the Rev. 6 draft substitutes

SP 800-131A Rev. 2 is the published final transition guidance on its page: Date
Published March 2019, Supersedes "SP 800-131A Rev. 1 (11/06/2015)", Document
History "03/21/19: SP 800-131A Rev. 2 (Final)", DOI
`https://doi.org/10.6028/NIST.SP.800-131Ar2` [S082]. The page's only Revision 3
reference is its Planning Note dated 10/21/2024: "An initial public draft of
Revision 3 has been posted for public comment through December 4, 2024." [S082]
So Rev. 3 was an open draft as of that note, and the page records no Rev. 3 final.

The premise carried from the staged draft — that the Rev. 6 draft removes Part 1's
own algorithm-approval time frames and points at SP 800-131A instead — is **not
established by the seven documents opened here**. They are the two Part 2/Part 3
pages, the two legacy wrappers, the two Rev. 1 pages and the 131A Rev. 2 page;
none states what Rev. 6 contains. What they do establish is the operational half:
131A Rev. 2 is the final on record and the page's newest Rev. 3 signal is an
initial public draft, so a control that needs an algorithm's approval horizon
cites Rev. 2 by revision [S082]. Rev. 6's own content stays a lead: the lane's
Rev. 6 row registers only its draft status (S049).

## The rule

1. **A revision history that says "(Final)" is not a currency check.** The Part 2
   and Part 3 pages print "(Final)" and a "Withdrawn on" date side by side
   [S076][S077]; currency comes from that field, from the wrapper, or from the
   successor's "Supersedes" cell [S078][S079][S080][S081].
2. **Cite the Rev. 1 of each part** [S080][S081], by revision and by DOI, and
   carry the DOI in the citation.
3. **Check the transition reference separately from Part 1** [S082]; the
   approval-horizon rule lives in SP 800-131A, and the newest Rev. 3 signal on
   its page is a 2024 initial public draft.

## What this entry does not establish

- It does not read the substantive text of Part 2 Rev. 1 or Part 3 Rev. 1. The
  round-2 ledger asked for their *substance*; this entry establishes their status
  and identity, which is what the withdrawal question required. Their normative
  content remains unread.
- It does not cover SP 800-131A's transition tables, only its status.
- It does not change anything about Part 1: the Rev. 1 pages' "Publication Parts"
  field lists SP 800-57 Part 1 Rev. 5 [S080][S081], and this entry does not assess
  Part 1's own revision status.
- It does not establish what the Rev. 6 draft changes, as stated above.

## Re-grounding notes (round 33)

- The staged title said the CSRC pages "do not say so". Re-opened this round, both
  pages carry "Withdrawn on May 23, 2019" and "Withdrawn on January 22, 2015" with a
  "Superseded by" link [S076][S077]. Corrected: the trap is the "(Final)" history
  line, not silence on the page.
- The staged prose said the parts had been "withdrawn for between eleven and twenty
  years". That bound does not survive the dates: Part 2 was withdrawn in May 2019,
  which is seven years before this verification. Replaced with the two withdrawal
  dates and a "more than seven years" floor.
- The staged entry gave Part 3's withdrawal as "January 2015", the wrapper's month
  only; the page prints 22 January 2015 [S077][S079]. Both forms are now recorded
  against their own source.
- Added the 07/01/2025 "currently being reviewed" Planning Notes on both Rev. 1
  pages, which the staged entry did not carry [S080][S081].
- The staged claim about what the Rev. 6 draft substitutes is now marked not
  established by this entry's sources, above.
