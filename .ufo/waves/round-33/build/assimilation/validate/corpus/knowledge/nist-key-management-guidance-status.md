source: S073 — https://csrc.nist.gov/pubs/sp/800/57/pt1/r5/final — Date Published, Supersedes and Document History — rendered-text-v1 sha256 `950ae8a8ad88da31`, fetched 2026-11-04; S074 — https://csrc.nist.gov/pubs/sp/800/133/r3/ipd — subtitle "(Initial Public Draft)", Date Published, Comments Due, Planning Note (06/30/2026) and Document History — rendered-text-v1 sha256 `955dd86653889462`, fetched 2026-11-04; S075 — https://csrc.nist.gov/pubs/sp/800/133/r2/final — Date Published, Supersedes and Document History — rendered-text-v1 sha256 `bb1cce593095f6c1`, fetched 2026-11-04
verified-at: 2026-11-04 — all three pages re-opened this round (HTTP 200, no redirect); raw bodies are non-reproducing at constant size (three independent fetches produced three different raw sha256 per page, at 47203, 45351 and 42741 bytes for the Rev. 5, Rev. 3 and Rev. 2 pages respectively), so identity here is the rendered-text-v1 normalized sha256 — captures .ufo/waves/round-33/build/nist-captures.tsv
recheck: 90d — `curl -fsSL 'https://csrc.nist.gov/pubs/sp/800/133/r3/ipd' | grep -c 'public comment period is CLOSED'` -> 1 (ran 2026-11-04)
ground: NIST key-management draft status — distinguish final guidance from initial public drafts before adopting controls

# NIST key-management guidance status: Rev. 5 final is the baseline, Rev. 6 and SP 800-133 Rev. 3 are drafts

A control that cites a draft is a defect, and drafts move. This entry fixes the
status of the two key-management documents a control can cite — SP 800-57
Part 1 and SP 800-133 — each with a final revision to cite and a newer draft not
to, as observed on 2026-11-04.

## The status table

| publication | status on 2026-11-04 | date | what to cite |
|---|---|---|---|
| SP 800-57 Part 1 **Rev. 5** | **Final** — served at `/final`; Document History "05/04/20: SP 800-57 Part 1 Rev. 5 (Final)" [S073] | May 2020 | this one — it is the published Part 1 |
| SP 800-57 Part 1 **Rev. 6** | **Initial Public Draft**, comment period closed 2026-02-05 [S049] | 2025-12-05 (draft) | **nothing** — no final exists |
| SP 800-133 **Rev. 2** | **Final** — served at `/final`; Document History "06/04/20: SP 800-133 Rev. 2 (Final)" [S075] | June 2020 | this one — current final key-generation guidance |
| SP 800-133 **Rev. 3** | **Initial Public Draft** — subtitle "(Initial Public Draft)"; "Comments Due: June 16, 2026 (public comment period is CLOSED)" [S074] | April 17, 2026 (draft) | **nothing** — draft only |

One row rests on a different footing: the Rev. 6 status comes from the lane's
existing row S049, opened 2026-10-21, which is pre-existing, is not re-proposed
here, and is deliberately absent from this entry's `source:` line.

## Reading the status signals

- **The URL path is the first signal.** `/final` and `/ipd` are different pages:
  the Rev. 5 and Rev. 2 finals are served at `/final` [S073, S075], the Rev. 3
  draft at `/ipd` [S074].
- **The subtitle is asymmetric.** Only a draft page carries the parenthetical:
  the Rev. 3 page reads "NIST SP 800-133 Rev. 3 (Initial Public Draft)" [S074],
  while the Rev. 5 and Rev. 2 pages go from title straight to Date Published with
  no status label at all [S073, S075]. The label confirms drafts; it can never
  confirm a final.
- **The `status` form field is chrome.** All three pages carry
  `<input type="hidden" name="status" value="Final,Draft" />` [S073, S074, S075] —
  the publication-filter form, identical on final and draft pages, and not a
  per-publication status.
- **Comments Due is annotated in place.** "Comments Due: June 16, 2026 (public
  comment period is CLOSED)" [S074]. A closed comment period means the draft is
  frozen, not that it was adopted.
- **Document History is the authoritative publication record** — the served
  heading is "Document History", not "Revision History". It ends at the (Final)
  entry for Rev. 5 [S073] and Rev. 2 [S075], while the Rev. 3 page carries a
  single "(Draft)" entry, "04/17/26: SP 800-133 Rev. 3 (Draft)" [S074].
- **A Planning Note dated after the comment period records availability, not
  adoption:** "The public comments received are now available." (Planning Note,
  06/30/2026) [S074].

## The operational rule

1. **Cite the final publication, never the IPD.** For key-management guidance
   today that is SP 800-57 Part 1 Rev. 5 [S073] and SP 800-133 Rev. 2 [S075].
2. **A closed comment period is not a final.** Both Rev. 6 and SP 800-133 Rev. 3
   are frozen drafts [S049, S074]; adopting their text as a control is a citation
   error, not a conservative choice.
3. **Re-check before adoption.** The Rev. 3 draft already carries a post-comment
   Planning Note [S074] and is one step from a final; a 90-day cadence on the
   draft page is the cheap guard — the same cadence S049's row declares for
   Rev. 6.
4. **Rev. 5 supersedes Rev. 4 of 01/28/2016, and Rev. 2 supersedes Rev. 1 of
   07/23/2019** [S073, S075] — a control citing "SP 800-57" without a revision is
   citing an unknown version.

## What this entry does not establish

- It covers **Part 1 of SP 800-57 only**. Parts 2 and 3 were not opened for this
  entry and their status is not established here.
- It establishes publication status, **not** the substance of any control. Page
  metadata and abstracts were read; the PDF normative text was not.
- It does not cover NIST publications outside the key-management family (for
  example the CSRM or CSF profiles that map key-management controls).
- It does not establish what the Rev. 6 draft changes: S049 registers its draft
  status only, and no Rev. 6 document was opened this round. The claim that a
  control must not cite the Rev. 6 draft is an inference from that status, not a
  reading of the Rev. 5 page, which names no Rev. 6 [S073].

## Gate note (round 33)

Corrections made against the re-opened captures, `nist-captures.tsv`:

- The staged prose said a CSRC page carries a **status line under the title**
  (Final / Initial Public Draft). Re-opened, that holds only for drafts: the
  Rev. 5 and Rev. 2 pages carry no status label [S073, S075]. The signal list now
  says so and adds the `status` form field, which reads `Final,Draft` on all
  three pages.
- The staged anchor cell said "§Revision History"; the served heading is
  "Document History" [S073, S074, S075]. Corrected.
- The staged `recheck:` command matched `Comments Due: June 16, 2026 (public comment period is CLOSED)` as one string and returns 0 on the page as served today, because `<strong>Comments Due:</strong>` splits the label from the value. Replaced with the substring that is contiguous in the body, which returns 1.
- The staged paraphrase of the Planning Note ("records that comments were
  received and published") was replaced with the sentence the page prints.
- The staged campaign sha256 prefixes do not reproduce as raw-body hashes: three
  independent fetches this round produced three different raw sha256 values at
  identical byte counts. The entry pins the rendered-text-v1 sha256 instead,
  which was identical across all three fetches.
- The staged row's trailing clause "must not cite the Rev. 6 draft" is not on the
  Rev. 5 page, which names no Rev. 6; the Rev. 6 status is attached to S049 only.
- Two readings sit outside the capture rows' quoted cells and are stated with their own one-line checks: the Rev. 5 Supersedes field (Rev. 4, 01/28/2016) is on the same pinned body (`950ae8a8…`) and `curl -fsSL 'https://csrc.nist.gov/pubs/sp/800/57/pt1/r5/final' | grep -c 'SP 800-57 Part 1 Rev. 4 (01/28/2016)'` -> 1; and every Rev. 6 date (2025-12-05 draft, 2026-02-05 comment close) plus S049's opened date 2026-10-21 are S049's registered values, not re-read this round.
- No capture contradicts a date or supersession claim in the staged table: May
  2020, June 2020, 05/04/20, 06/04/20, 01/28/2016, 07/23/2019, April 17, 2026,
  June 16, 2026 and 06/30/2026 all re-locate verbatim in the re-opened bodies;
  every one of them except 01/28/2016 also appears literally in a capture row.

---

Gate: admitted round 33 from merge/kagi (assimilation); sources re-opened 2026-11-04; see corpus/lessons/round-33.md §Gate.
