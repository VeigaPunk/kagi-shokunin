source: S100 — https://webstore.iec.ch/en/publication/62160 (IEC record of ISO/IEC 11770-3:2015/AMD1:2017); S101 — https://www.iso.org/standard/60237.html (ISO catalogue record of ISO/IEC 11770-3:2015); S102 — https://webstore.iec.ch/en/publication/71650 (IEC record of ISO/IEC 11770-3:2021); S113 — https://www.iso.org/standard/82709.html (ISO catalogue record of ISO/IEC 11770-3:2021, opened 2026-11-07); S114 — https://www.iso.org/standard/85929.html (ISO catalogue record of ISO/IEC 11770-3:2021/Amd 1:2025, opened 2026-11-07)
verified-at: 2026-11-05 (S100–S102); 2026-11-07 for S113 and S114 (opened) and S101 (re-fetched byte-identical to its round-45 capture)
recheck: 180d — `curl -fsSL -A 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0 Safari/537.36' 'https://www.iso.org/standard/60237.html' | grep -c 'Withdrawal of International Standard'` -> 2 (ran 2026-11-07; the round-45 line said 1, but the page carries the stage twice, in the stage line and in the life-cycle list, and the 2026-11-07 body is byte-identical to the round-45 capture); `curl -fsSL -A 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0 Safari/537.36' 'https://www.iso.org/standard/82709.html' | grep -c 'ISO/IEC 11770-3:2021/Amd'` -> 3 (ran 2026-11-07; counts every amendment of the 2021 edition the record lists, so a new amendment moves it — R55ScoutISO; the Amd-1-specific string, the first form of this command, would stay 3); `curl -fsSL -A 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0 Safari/537.36' 'https://www.iso.org/standard/85929.html' | grep -c 'International Standard published'` -> 2 (ran 2026-11-07; watches the amendment's own stage, added after R55ReviewerLanding F11)
ground: round 45 C2 (coverage) — the ISO/IEC 11770-3 mechanism standard, its edition and supersession status; the lane's corpus held no entry on it at BASE 0d0192f (`grep -l 11770 corpus/knowledge/*.md` was empty)
Reverify: R21-02
(R21-02 is the sources-census row: it re-verifies the citation chain only — every id on `source:` resolves to a `mined` row of `corpus/SOURCES.md` whose `used-by` lists this entry. It does not re-open the IEC/ISO catalogue pages or re-measure any edition status; `recheck:` is the content clock. There is no round-45 ledger row: the round-31/33/34 entries' rows `R31-02`, `R33-02` and `R34-03` run the identical census command with the identical snapshot, so this entry uses the canonical row.)

# ISO/IEC 11770-3: the 2015 edition is withdrawn and the 2021 edition is the one in force

ISO/IEC 11770-3 is the part of the ISO/IEC 11770 key-management series that
specifies key-management mechanisms based on asymmetric techniques. This entry
records one question only: which edition is in force, and what replaced the one a
reader may still hold. It does not describe the mechanisms, and it does not claim
the lifecycle requirements that the standard itself excludes.

## The 2015 edition is withdrawn

The ISO catalogue record for ISO/IEC 11770-3:2015 [S101] carries the stage
"Withdrawal of International Standard" [S101] and names the 2021 edition as the new
version. The page's own general-information block gives the 2015 edition's status
as withdrawn [S101]; the lane records the withdrawal stage, which the page dates
2021-10-22, as a paraphrase, not a quotation.

## The 2021 edition replaces it

The IEC record for ISO/IEC 11770-3:2021 [S102] is titled "ISO/IEC 11770-3:2021" and
gives it as an International Standard, edition 4.0, with a 2021-10-22 publication
date [S102]. The 2021 edition is the successor the 2015 catalogue record names [S101].

## The 2017 amendment is withdrawn too

The IEC record for ISO/IEC 11770-3:2015/AMD1:2017, the blinded Diffie-Hellman key
agreement amendment, carries the title "ISO/IEC 11770-3:2015/AMD1:2017" [S100]. The
record shows a withdrawal date in 2021 and names a newer amendment to the 2021
edition as the version that now exists [S100]. A reader who needs the amendment
should check that newer amendment, not the 2017 text. The newer amendment's
content is outside this entry.

## The 2021 edition carries Amendment 1:2025 (round 55)

The newer amendment the IEC record points to [S100] is ISO/IEC 11770-3:2021/Amd 1:2025
[S114]. Its ISO catalogue record is titled "ISO/IEC 11770-3:2021/Amd 1:2025"
[S114], with the subtitle "Amendment 1: TFNS identity-based key agreement", the
stage "International Standard published" (60.60) and a 2025-04 publication date
[S114]. The ISO catalogue record of the 2021 edition lists the same amendment in its
life cycle and still gives the 2021 edition as a published International Standard
(stage 60.60) [S113]. Read together (the lane's reading: the catalogue states
title, stage and date, not applicability), the amendment is published against the
2021 edition, so a reader holding the 2021 edition should read it with Amendment
1:2025, not the 2021 text alone. The amendment's mechanism content is outside this entry,
as the 2017 amendment's was. Both records were opened 2026-11-07 with the browser
user agent (the default user agent still receives HTTP 403); the stage, title and
publication date are the catalogue's statements on that day.

## Scope boundary

The 2015 catalogue record's abstract states that the edition does not cover certain
aspects of key management, including key lifecycle management and the generation,
validation and storage of asymmetric key pairs [S101]. This entry does not extend
the standard to those aspects. The lane's KMS-managed credential lifecycle ground is
held separately (round 34, `PROVINCE.md` core).

## Access note (correction of the staged package)

The staged entry this round was drafted from said the ISO catalogue page returned an
HTTP 403 challenge and could not be opened. On 2026-11-05 the page returned HTTP 403
to a default user agent and HTTP 200 to a browser user agent, so it was opened and
cited as S101 with the browser user agent. The web.archive.org snapshot listed in the
staged row timed out at 30 seconds and is not cited.

## What this entry does not establish

- It does not establish any relationship between this standard and any national
  adoption of it. A national text that adopts an edition must be checked against
  that edition's own record, which is outside this round.
- The page statuses are the catalogue's statements on the day opened; they are not
  an independent check of ISO's full publication history.

## Reference

- S100 — https://webstore.iec.ch/en/publication/62160 (fetched 2026-11-05)
- S101 — https://www.iso.org/standard/60237.html (fetched 2026-11-05, browser user agent)
- S102 — https://webstore.iec.ch/en/publication/71650 (fetched 2026-11-05)
- S113 — https://www.iso.org/standard/82709.html (fetched 2026-11-07, browser user agent)
- S114 — https://www.iso.org/standard/85929.html (fetched 2026-11-07, browser user agent)
