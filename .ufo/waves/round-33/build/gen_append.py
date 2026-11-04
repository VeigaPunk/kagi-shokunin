import json, pathlib, hashlib, csv

LANE = pathlib.Path("/home/vgpnk/Projects/shokunin/kagi-shokunin")
W = LANE / ".ufo/waves/round-33/build"
IDMAP = {}
for line in (LANE / ".ufo/waves/round-33/assimilation/id-map.txt").read_text().splitlines():
    if line.startswith("#") or not line.strip():
        continue
    st, ln, url = line.split("\t")
    IDMAP[st] = (ln, url)

caps = {}
for line in (W / "nist-captures.tsv").read_text().splitlines():
    f = line.split("\t")
    assert len(f) == 14, (len(f), f[0])
    caps[f[0]] = f

META = {
 "S061": dict(
  title="NIST SP 800-57 Part 1 Rev. 5, Recommendation for Key Management: Part 1 – General",
  kind="spec", tier="A", recheck="180d", used="corpus/knowledge/nist-key-management-guidance-status.md",
  scope="the final NIST key-management Part 1 publication page: revision, publication date and the parts list; no control text",
  anchor="Documentation block, field Document History (same block: Date Published May 2020; Publication Parts SP 800-57 Part 2 Rev. 1, Part 3 Rev. 1); captured 2026-11-04 (corpus/source-fetches.tsv)",
  teaches="Rev. 5 of May 2020 is the published Part 1: its Document History ends at the (Final) entry and its parts list names only the Rev. 1 Parts 2 and 3. Quote: “05/04/20: SP 800-57 Part 1 Rev. 5 (Final)”. The page names no Rev. 6 — the draft's status is row S051's, not this row's."),
 "S062": dict(
  title="NIST SP 800-133 Rev. 3 (Initial Public Draft), Recommendation for Cryptographic Key Generation",
  kind="spec", tier="A", recheck="90d", used="corpus/knowledge/nist-key-management-guidance-status.md",
  scope="SP 800-133 Rev. 3 publication status only: an initial public draft whose comment period is closed; no adopted guidance",
  anchor="page title and Documentation header; Document History 04/17/26: SP 800-133 Rev. 3 (Draft); Planning Note 06/30/2026; captured 2026-11-04 (corpus/source-fetches.tsv)",
  teaches="Rev. 3 exists only as an initial public draft: the title carries (Initial Public Draft), the history has a (Draft) entry and no Final entry. Quote: “Comments Due: June 16, 2026 (public comment period is CLOSED)”. A closed comment period is not adoption."),
 "S063": dict(
  title="NIST SP 800-133 Rev. 2, Recommendation for Cryptographic Key Generation",
  kind="spec", tier="A", recheck="180d", used="corpus/knowledge/nist-key-management-guidance-status.md",
  scope="the final NIST key-generation recommendation that a Rev. 3 draft would supersede",
  anchor="Documentation block, field Document History (Date Published June 2020; Supersedes SP 800-133 Rev. 1 of 07/23/2019; DOI 10.6028/NIST.SP.800-133r2); captured 2026-11-04 (corpus/source-fetches.tsv)",
  teaches="Rev. 2 of June 2020 is the current final key-generation guidance and supersedes Rev. 1. Quote: “06/04/20: SP 800-133 Rev. 2 (Final)”. The page carries no later final."),
 "S079": dict(
  title="NIST SP 800-57 Part 2 (August 2005), Recommendation for Key Management: Part 2",
  kind="spec", tier="A", recheck="365d", used="corpus/knowledge/nist-key-management-parts-withdrawal.md",
  scope="the 2005 Part 2 CSRC publication page: its withdrawal date, its superseding revision, and the (Final) Document History line that contradicts them",
  anchor="alert block id pub-withdrawn-message between the breadcrumb and the page title (Dublin Core title ends (Withdrawn)); Document History 08/25/05; captured 2026-11-04 (corpus/source-fetches.tsv)",
  teaches="The 2005 Part 2 is withdrawn and superseded, and this page states it in one block while its Document History still prints (Final). Quote: “Withdrawn on May 23, 2019”. A revision-history (Final) line is not a currency check."),
 "S080": dict(
  title="NIST SP 800-57 Part 3 (December 2009), Recommendation for Key Management: Part 3",
  kind="spec", tier="A", recheck="365d", used="corpus/knowledge/nist-key-management-parts-withdrawal.md",
  scope="the 2009 Part 3 CSRC publication page: its withdrawal date, its superseding revision, and the (Final) Document History line that contradicts them",
  anchor="alert block id pub-withdrawn-message between the breadcrumb and the page title (Dublin Core title ends (Withdrawn)); Document History 12/28/09; captured 2026-11-04 (corpus/source-fetches.tsv)",
  teaches="The 2009 Part 3 is withdrawn and superseded; the alert block gives the exact day, which the PDF wrapper does not. Quote: “Withdrawn on January 22, 2015”. The three parts therefore carry three vintages — 2020, 2019, 2015 — so a citation must name the part and the revision."),
 "S083": dict(
  title="NIST SP 800-57 Part 2 (August 2005), Recommendation for Key Management: Part 2 — Best Practices for Key Management Organization",
  kind="spec", tier="A", recheck="365d", used="corpus/knowledge/nist-key-management-parts-withdrawal.md",
  scope="the withdrawal status of the 2005 Part 2 document itself, as its PDF wrapper states it",
  anchor="PDF page 1 Warning Notice wrapper: banner Withdrawn NIST Technical Series Publication, must-notice line, Withdrawal Date and Withdrawal Note; captured 2026-11-04 (corpus/source-fetches.tsv)",
  teaches="The 2005 Part 2 is a withdrawn document: its wrapper names the withdrawal date and the successor, so a revision-less Part 2 citation cites a superseded text. Quote: “SP 800-57 Part 2 is superseded in its entirety by the publication of SP 800-57 Part 2 Revision 1.”"),
 "S084": dict(
  title="NIST SP 800-57 Part 3 (December 2009), Recommendation for Key Management — Part 3: Application-Specific Key Management Guidance",
  kind="spec", tier="A", recheck="365d", used="corpus/knowledge/nist-key-management-parts-withdrawal.md",
  scope="the withdrawal status of the 2009 Part 3 document itself, as its PDF wrapper states it",
  anchor="PDF page 1 Archived NIST Technical Series Publication wrapper: notice line, Withdrawal Date January 2015 and Withdrawal Note; captured 2026-11-04 (corpus/source-fetches.tsv)",
  teaches="Part 3 has been withdrawn since January 2015, and its wrapper names the successor. Quote: “SP 800-57 Part 3 is superseded in its entirety by the publication of SP 800-57 Part 3 Revision 1 (January 2015).”. The wrapper's own Latest revision line renders a wrong series number and is not evidence."),
 "S085": dict(
  title="NIST SP 800-57 Part 2 Rev. 1, Recommendation for Key Management: Part 2 — Best Practices for Key Management Organizations",
  kind="spec", tier="A", recheck="365d", used="corpus/knowledge/nist-key-management-parts-withdrawal.md",
  scope="the publication status, supersession and canonical DOI of the Part 2 revision that is current, plus the live review note the page carries",
  anchor="Documentation block, field Document History (Date Published May 2019; Supersedes SP 800-57 Part 2 of 08/25/2005; DOI 10.6028/NIST.SP.800-57pt2r1); Planning Note 07/01/2025; captured 2026-11-04 (corpus/source-fetches.tsv)",
  teaches="The citable Part 2 is Rev. 1 of May 2019 with a stable DOI, and the page carries a 2025 planning note that it is under review. Quote: “05/23/19: SP 800-57 Part 2 Rev. 1 (Final)”. A stable DOI is not a stable document — the note is the currency signal."),
 "S086": dict(
  title="NIST SP 800-57 Part 3 Rev. 1, Recommendation for Key Management — Part 3: Application-Specific Key Management Guidance",
  kind="spec", tier="A", recheck="365d", used="corpus/knowledge/nist-key-management-parts-withdrawal.md",
  scope="the publication status, supersession and canonical DOI of the Part 3 revision that is current, plus the live review note the page carries",
  anchor="Documentation block, field Document History (Date Published January 2015; Supersedes SP 800-57 Part 3 of 12/28/2009; DOI 10.6028/NIST.SP.800-57pt3r1); Planning Note 07/01/2025; captured 2026-11-04 (corpus/source-fetches.tsv)",
  teaches="The citable Part 3 is Rev. 1 of January 2015 with a stable DOI, and the page carries a 2025 planning note that it is under review. Quote: “01/22/15: SP 800-57 Part 3 Rev. 1 (Final)”. Watch the note, not the (Final) history line."),
 "S087": dict(
  title="NIST SP 800-131A Rev. 2, Transitioning the Use of Cryptographic Algorithms and Key Lengths",
  kind="spec", tier="A", recheck="365d", used="corpus/knowledge/nist-key-management-parts-withdrawal.md",
  scope="the publication status of SP 800-131A, the current final transition guidance, and the state of its Revision 3 as this page records it",
  anchor="Documentation block, field Document History (Date Published March 2019; Supersedes SP 800-131A Rev. 1 of 11/06/2015; DOI 10.6028/NIST.SP.800-131Ar2); Planning Note 10/21/2024; captured 2026-11-04 (corpus/source-fetches.tsv)",
  teaches="Rev. 2 of March 2019 is the newest final on this page; Revision 3 appears only in a planning note that posted an initial public draft. Quote: “An initial public draft of Revision 3 has been posted for public comment through December 4, 2024.”. The page records no Rev. 3 final."),
}

rows, fetches = [], []
for staged, (lane_id, url) in sorted(IDMAP.items(), key=lambda kv: kv[1][0]):
    c = caps[staged]
    m = META[staged]
    assert c[1] == url, (staged, c[1], url)
    quote, loc = c[10], c[11]
    assert len(quote.split()) <= 25, (staged, len(quote.split()))
    row = f"| {lane_id} | {m['title']} — {url} | {m['kind']} | {m['tier']} | {m['scope']} | {m['anchor']} | {m['teaches']} | mined | 2026-11-04 | {m['recheck']} | {m['used']} |"
    assert row.count("|") == 12, (lane_id, row.count("|"))
    rows.append(row)
    rep = "decoded-http-body-volatile-v1" if url.startswith("https://csrc.nist.gov") else "decoded-http-body-v1"
    rid = hashlib.sha256(f"{lane_id}\tmined\t{url}\n".encode()).hexdigest()
    fetches.append("\t".join([lane_id, "mined", rid, url, c[2], c[3], "curl-fsSL-compressed-v1",
                              c[4], rep, c[6], c[5], "-", quote, "rendered-text-v1", c[9], loc]))

(W / "sources-append.md").write_text("\n".join(rows) + "\n")
(W / "fetches-append.tsv").write_text("\n".join(fetches) + "\n")
print("rows", len(rows), "fetches", len(fetches))
print(rows[0][:200])
print(fetches[0][:200])
