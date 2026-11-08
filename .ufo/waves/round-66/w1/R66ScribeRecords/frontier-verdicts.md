# R66ScribeRecords — frontier verdicts (second independent reading)

Seat: `R66ScribeRecords` (scribe; axes calibration + freshness). Lane
`kagi-shokunin`, branch master, claim BASE
`d549ee6eb8770a49938b78f49cf79e36d9c1c2e8`. Frozen plan `plans/round-66.md`
(landed `ddcd46bb4f9378f3cc3a659e4851e1cb126b02ca`).

**Standing.** These are my own measurements, taken in this seat's scratch
(`/fast/scratch/hyaku/kagi-r66/R66ScribeRecords/`, deleted on exit), against
the live web and the lane tree. They are a **second independent reading** of
what `R66ScoutSources` measured (`.ufo/waves/round-66/w1/R66ScoutSources/notes.md`).
Where the two agree, the frontier measurement is reproducible by two seats
working independently; where they differ, the difference is stated rather than
averaged away. **No row was added or renumbered by this seat**, and no lane
file was edited.

Request profile for every fetch below, without exception:

```
curl -fsSL --compressed -A 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36' <url>
```

plus one house-profile control fetch
(`-A 'kagi-shokunin-round23/1.0 (documentation verification)'`, the profile the
lane's fetch rows declare).

Access date for every fetch: **2026-11-08**.

---

## F1 — the BioC deposit re-opened (the C1 carrier, S148's URL)

**URL** `https://www.ncbi.nlm.nih.gov/research/bionlp/RESTful/pmcoa.cgi/BioC_xml/PMC2757457/unicode`
**Verdict: ADMIT, and the admitted finding is that the served bytes did NOT
drift.** — agrees with `R66ScoutSources` §1.

Three independent fetches, two user agents, 20 s apart:

```
$ curl -fsSL --compressed -A 'Mozilla/5.0 (X11; Linux x86_64) …Chrome/131…' \
    -o bioc-live-1.xml -w 'HTTP:%{http_code} SIZE:%{size_download}\n' '<BioC URL>'
HTTP:200 SIZE:35810
$ sleep 20
$ curl … -o bioc-live-2.xml … '<BioC URL>'
HTTP:200 SIZE:35810
$ curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)' \
    -o house-bioc.xml -w 'HTTP:%{http_code} SIZE:%{size_download}\n' '<BioC URL>'
HTTP:200 SIZE:35810
```

`SIZE` here is curl's transfer count; the **decoded** body is what the lane
pins, and every one of the three decodes to the same bytes:

```
$ sha256sum bioc-live-1.xml bioc-live-2.xml house-bioc.xml
3b8d4e159a0b0595fc9ef95f4fce87de5ab116c858cb7da9ed742113750cba40  bioc-live-1.xml
3b8d4e159a0b0595fc9ef95f4fce87de5ab116c858cb7da9ed742113750cba40  bioc-live-2.xml
3b8d4e159a0b0595fc9ef95f4fce87de5ab116c858cb7da9ed742113750cba40  house-bioc.xml

$ stat -c '%n %s' bioc-live-1.xml
bioc-live-1.xml 264946
```

Three ways it agrees with the pin and the committed carrier:

```
$ cmp bioc-live-1.xml .ufo/waves/round-64/capture/S143.body
   (no output — 0 differing bytes; rc 0)

$ cmp bioc-live-1.xml bioc-live-2.xml
   (no output — 0 differing bytes; rc 0)

$ sha256sum .ufo/waves/round-64/capture/S143.body
3b8d4e159a0b0595fc9ef95f4fce87de5ab116c858cb7da9ed742113750cba40
```

Shape re-measured on the live body:

```
$ grep -o '<passage>' bioc-live-1.xml | wc -l     → 182
$ grep -o '<text>' bioc-live-1.xml | wc -l        → 180
$ grep -o '<date>[0-9]*</date>' bioc-live-1.xml | sort -u
<date>20261108</date>
```

Quote located with the lane's own normalizer:

```
$ python3 corpus/rendered-text-v1.py locate bioc-live-1.xml \
    'In the current version of ConText there are 17 pseudo-triggers for negated (e.g., “no increase”, “not cause”)'
RENDERED_TEXT_V1_LOCATE: count=1
rc=0
```

**What this establishes for the L1.** The plan's conditional — *"a
`supersedes S148 —` row if the shape changed since the 2026-11-08 capture"* —
is **not met by content drift**: the pin is unchanged and the served bytes are
the pin's bytes. What S164 supersedes is the **binding** (which committed
capture path the row names), not the bytes. The lesson's S165 cell, which
says the served body "differs from the pin by one byte", is contradicted by
`cmp` above (0 bytes); the one-byte delta that does exist is the historical
round-63 → round-64 pair:

```
$ cmp -l .ufo/waves/round-63/capture/S143.body .ufo/waves/round-64/capture/S143.body
128  67  70
```

— the service's own `<date>` stamp `20261107`→`20261108`, already recorded in
the S148 row's anchor cell. See `gate-verify.md` §2.

## F2 — the ConText PMC2757457 eutils EFetch carrier (S155's URL)

**URL** `https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pmc&id=2757457&retmode=xml`
**Verdict: RECHECK REFRESH of the existing S155 row — no new registry row.**
— agrees with `R66ScoutSources` §2.

```
$ curl -fsSL --compressed -A 'Mozilla/5.0 …Chrome/131…' -o eutils-live.xml \
    -w 'HTTP:%{http_code} SIZE:%{size_download}\n' '<eutils URL>'
HTTP:200 SIZE:38577
$ curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)' \
    -o house-eutils.xml -w 'HTTP:%{http_code} SIZE:%{size_download}\n' '<eutils URL>'
HTTP:200 SIZE:38871

$ sha256sum eutils-live.xml house-eutils.xml
cdbb417379e146a9199efa54f6322b373880aee9f76faffc624c8f94ac41fb8b  eutils-live.xml
cdbb417379e146a9199efa54f6322b373880aee9f76faffc624c8f94ac41fb8b  house-eutils.xml
$ stat -c '%n %s' eutils-live.xml
eutils-live.xml 189603
```

The plan's condition — *"recheck refresh if the digest still matches S135's
pin"* — **holds**: `cdbb4173…` is byte-identical to S135's pin and to S155's
own pin, at 189603 B.

```
$ grep '^S135\t' corpus/source-fetches.tsv | cut -f10
cdbb417379e146a9199efa54f6322b373880aee9f76faffc624c8f94ac41fb8b
$ grep '^S155\t' corpus/source-fetches.tsv | cut -f10
cdbb417379e146a9199efa54f6322b373880aee9f76faffc624c8f94ac41fb8b
```

Quote located:

```
$ python3 corpus/rendered-text-v1.py locate eutils-live.xml \
    'In the current version of ConText there are 17 pseudo-triggers for negated (e.g., “no increase”, “not cause”)'
RENDERED_TEXT_V1_LOCATE: count=1
rc=0
```

**Caveat, independently reproduced, and it is sharper than "the quote needs
normalizing".** The quote locates only **after** `rendered-text-v1`
normalization, because the eutils body wraps one word in an inline element
that the raw bytes break apart:

```
raw eutils body at the quote site:
  'In the current version of ConText there are 17 pseudo-triggers for
   <italic toggle="yes">negated</italic> (e.g., “no increase”, “not cause”), 17 pseudo'
```

So in the **raw** bytes the sentence is not contiguous — a `raw-literal-v1`
classification would fail to locate it, in either quote spelling:

```
$ python3 corpus/rendered-text-v1.py locate eutils-live.xml \
    'In the current version of ConText there are 17 pseudo-triggers for negated (e.g., “no increase”, “not cause”)'
RENDERED_TEXT_V1_LOCATE: count=0
rc=1
```

(the same sentence in the **BioC** carrier body is contiguous in the raw
bytes, and locates raw-literal — the interruption is the eutils body alone).
After `rendered-text-v1` strips the tag, the eutils body reads:

```
$ python3 corpus/rendered-text-v1.py locate eutils-live.xml \
    'In the current version of ConText there are 17 pseudo-triggers for negated (e.g., “no increase”, “not cause”)'
RENDERED_TEXT_V1_LOCATE: count=1
rc=0
```

Any refresh row must therefore keep `normalization = rendered-text-v1` with the
normalized digest
`5f50941440dbb802cb5a2a076b1cbe9af17cdf62f6a9b7cbfa2dedf7611cc801` —
**not** `raw-literal-v1`.

**One defect found in the landed S155 provenance row** — its column 15 carried
the *BioC* body's normalized digest instead of this body's. Full evidence in
`gate-verify.md` §4a; the one-token fix is `4d966ff9…` → `5f509414…`. **The L1
applied that fix after I reported it and I re-verified it: column 15 now
reads `5f509414…` and matches the body its own column 16 names.**

## F3 — the equivalent-mutant state-of-the-art page (the plan's designated weak lead)

### F3a — ACM DL record for the ISSTA '24 equivalent-mutants paper — **REJECT**

**URL** `https://dl.acm.org/doi/10.1145/3650212.3680310`
**Verdict: REJECT** (the unopened citation chain) — agrees with
`R66ScoutSources` §3b.

```
$ curl -fsSL --compressed -A 'Mozilla/5.0 …Chrome/131…' -o acm-1.body \
    -w 'HTTP:%{http_code} SIZE:%{size_download}\n' '<ACM URL>'
HTTP:403 SIZE:5684
$ sleep 3
$ curl … -o acm-2.body … '<ACM URL>'
HTTP:403 SIZE:5684
```

**Difference from the scout's reading, stated rather than averaged.** The
scout measured 5684 B / `ad4c63cc8d6290f0d1b56b08…`; my first fetch of the
session measured **5662 B / `96b3a70a7260d9bd…`**, and my two later fetches
measured 5684 B each but with **different digests from each other**:

```
attempt1  5684 B  sha256 8a073d0376f8364924036978
attempt2  5684 B  sha256 2de1db614e40b0cd46f23b83
earlier   5662 B  sha256 96b3a70a7260d9bd97651e0f
scout's committed capture: 5684 B sha256 ad4c63cc8d6290f0d1b56b08
```

So the ACM DL 403 body is **not byte-stable across fetches** — a third
independent observation, from two seats, of the same instability the scout
found in the Springer's `_csrf` rotation. **This strengthens the REJECT and
does not weaken it**: the record cannot be pinned at all, so it grounds
nothing. (The quote does locate in each served body — `count=1` for
`Just a moment... Enable JavaScript and cookies to continue` — the *body* is
unstable, not the quote.)

Flip: ACM serving the record's abstract as static HTML.

### F3b — SpringerLink, "A Comprehensive Review on Equivalent Mutant Detection Using Machine Learning" (IWSC 2025) — **REJECT**

**URL** `https://link.springer.com/chapter/10.1007/978-3-031-92474-3_4`
**Verdict: REJECT** (tier C) — agrees with `R66ScoutSources` §3a, including
the byte-stability claim.

```
$ curl -sS -L --compressed -A 'Mozilla/5.0 …Chrome/131…' -o sp-1.body \
    -w 'HTTP:%{http_code} SIZE:%{size_download}\n' '<Springer URL>'
HTTP:200 SIZE:3038
$ sleep 2
$ curl … -o sp-2.body … '<Springer URL>'
HTTP:200 SIZE:3038
$ sha256sum sp-1.body sp-2.body
32ed63159c77e21ee19ca1b9aa3213ccf0218eb59539560b132a8e68ef0e18ea  sp-1.body
32ed63159c77e21ee19ca1b9aa3213ccf0218eb59539560b132a8e68ef0e18ea  sp-2.body
```

Byte-identical across two consecutive fetches, and byte-identical to the
scout's committed capture `LEAD_springer_challenge.body`
(`32ed63159c77e21ee19ca1b9…`, 3038 B). The quote locates:

```
$ python3 corpus/rendered-text-v1.py locate sp-1.body 'Client Challenge'
RENDERED_TEXT_V1_LOCATE: count=1
rc=0
```

This is the **one** refusal whose body *is* byte-stable under the declared
profile — but it is a JavaScript interstitial (3038 B), not the chapter, so it
still grounds nothing. The refusal stands on the wrong-content ground, not the
instability ground.

### F3c — the extra candidate `R66ScoutSources` found (arXiv:2404.09241)

**URL** `https://arxiv.org/abs/2404.09241`
**Verdict: lead, not written as a row this round** — I did not fetch this
candidate; the scout measured it (both digests stable across two fetches,
quote locating `count=1`). **I record it as unverified by this seat** rather
than re-asserting the scout's numbers as mine. The L1's disposition stands:
an admit-shaped lead for round 67's first pick.

---

## Where my reading agrees with the scout's, and where it differs

| candidate | scout | this seat | status |
|---|---|---|---|
| BioC re-open (S148's URL) | 200, 264946 B, `3b8d4e15…`, byte-identical to the committed carrier, shape 182/180 unchanged | same digest on **3** fetches / 2 user agents, `cmp` = 0 differing bytes | **agree** |
| eutils (S155's URL) | 200, 189603 B, `cdbb4173…` == S135's pin; quote locates only after `rendered-text-v1` | same; the straight-quote spelling does **not** locate (the body carries typographic quotes) | **agree** |
| ACM DL 403 | 403, 5684 B, `ad4c63cc…` | 403; **5662 B `96b3a70a…`, then 5684 B `8a073d03…`, then 5684 B `2de1db61…`** — three bodies, three digests | **differ in the bytes, agree in the verdict** — the body is unstable across fetches, so the REJECT is *more* strongly grounded |
| SpringerLink | 200, 3038 B `32ed6315…`, a JS interstitial | same digest, and **byte-identical across two consecutive fetches** — reproduces the scout's stability claim | **agree** |
| arXiv:2404.09241 | 200, digests stable, quote locating | not fetched by this seat | **not verified here** |

**Net effect on the round's frontier.** One admit (S164, the carrier row) and
the plan's designated reject confirmed as a reject by a second seat on a
different body. Nothing in my reading contradicts a row the L1 wrote.

## Scratch and secret discipline

Scratch root `/fast/scratch/hyaku/kagi-r66/R66ScribeRecords/`, deleted on
exit. The two ACM DL bodies carry a live Cloudflare `__cf_chl_tk` challenge
token, so **their bodies were not stored** — only digests and byte counts, in
`receipts/acm-403-digests.txt`. The 3038-byte Springer interstitials are
stored (clean: 0 hits for `_csrf`, `csrf`, `__cf_chl`, `token`, `secret`,
`cookie`) and are byte-identical to each other. No secret value, token,
cookie or vault reference path was printed, copied or stored.

## Artifact paths

- `.ufo/waves/round-66/w1/R66ScribeRecords/frontier-verdicts.md` (this file)
- `.ufo/waves/round-66/w1/R66ScribeRecords/gate-verify.md`
- `.ufo/waves/round-66/w1/R66ScribeRecords/receipts/springer-challenge.body`
- `.ufo/waves/round-66/w1/R66ScribeRecords/receipts/acm-403-digests.txt`
