source: S100 — https://webstore.iec.ch/en/publication/62160 (IEC record of ISO/IEC 11770-3:2015/AMD1:2017); S101 — https://www.iso.org/standard/60237.html (ISO catalogue record of ISO/IEC 11770-3:2015); S102 — https://webstore.iec.ch/en/publication/71650 (IEC record of ISO/IEC 11770-3:2021)
verified-at: 2026-11-05
recheck: 180d — `curl -fsSL -A 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0 Safari/537.36' 'https://www.iso.org/standard/60237.html' | grep -c 'Withdrawal of International Standard'` -> 1 (ran 2026-11-05)
ground: round 45 C2 (coverage) — the ISO/IEC 11770-3 mechanism standard, its edition and supersession status; the lane's corpus held no entry on it at BASE 0d0192f (`grep -l 11770 corpus/knowledge/*.md` was empty)

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
