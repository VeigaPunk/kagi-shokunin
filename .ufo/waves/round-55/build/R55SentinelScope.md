# R55SentinelScope — scope, refusal-boundary and misroot sentinel (round 55 landing)

Measured revision (BASE): `ebe095857a734caf5efdd7bd776feb22b4e23972`
Measured revision (CANDIDATE, = lane HEAD): `348aa3b8ea7298aeb2f4d69db321fe827a92ae4f`
Lane: `/home/vgpnk/Projects/shokunin/kagi-shokunin` (branch master)
Fleet root: `/home/vgpnk/Projects/shokunin`
Receipts: `.ufo/waves/round-55/build/R55SentinelScope.d/` — `scan.sh` (reproducible, read-only), `scan-out.txt` (its full output), `diffstat.txt`, `namestatus.txt`
Scratch: `$HYAKU_SCRATCH/kagi-r55/R55SentinelScope/` (`/fast/scratch/hyaku/...`), removed by EXIT trap in `scan.sh`

Both hashes above were obtained with
`git -C /home/vgpnk/Projects/shokunin/kagi-shokunin rev-parse ebe095857a734caf5efdd7bd776feb22b4e23972 348aa3b8ea7298aeb2f4d69db321fe827a92ae4f`
(exit 0) and are written literally; no `$(...)` is left unexpanded in this header.

Everything below is reproducible by `bash .ufo/waves/round-55/build/R55SentinelScope.d/scan.sh` (exit 0, 1.2 s). The script never prints a needle, a cookie value or any credential shape — only file:line, counts and cookie names.

---

## Verdict table

| # | Check | Verdict |
|---|---|---|
| 1a | Diff touches only lane paths | PASS — 51 files, 0 absolute/`..` paths |
| 1b | No credential-shaped string in added lines | PASS — 0 hits over 8433 added lines, needle set 7/7 sensitive, 0 false positive on a plain URL |
| 1c | No `op://` reference, userinfo URL, or private/internal host in added lines | PASS — 0 / 0 / 0 |
| **1d** | **No cookie value committed in added lines** | **FAIL — `set-cookie: __cf_bm=…` committed at `capture/S113.headers:8` and `capture/S114.headers:8` (finding F1)** |
| 2 | Captures and rejection receipts hold only public catalogue pages | PASS with one note — both `S113`/`S114` bodies are the ISO catalogue pages they claim (digests and sizes reconcile with `source-fetches.tsv`); all three rejection receipts are public pages (one is a public 403 interstitial, which is the point of that receipt) |
| 3 | No untracked fleet-root file naming kagi / round-55 (misroot) | PASS — 5 status entries, 0 naming kagi/round-55/r55 |
| 4 | No `/tmp/` scratch path cited in committed files of this round | PASS — 0 occurrences in the whole diff and in added lines |
| 5 | No CSRF/session token literal in added lines | PASS — 0 for `form_key=`, `PHPSESSID=`, `mage-cache-sessid=`, `X-Magento-Form-Key`, `csrf_token=` |

**No misroot attributable to kagi round 55.**

---

## Check 1 — scope of the landing

```
$ git -C <lane> diff --stat ebe0958… 348aa3b…
 51 files changed, 8433 insertions(+), 60 deletions(-)
$ git -C <lane> diff --name-status ebe0958… 348aa3b… | wc -l
51
```
Top-level groups touched: `.ufo` 22, `corpus` 21, `plans` 4, `LOG.md`, `SCORECARD.md`, `PROVINCE.md`, `SKILL.md`. All are inside the lane repository; the fleet root is untouched by this commit (see check 3).

**1a — path escape:** `awk '{print $2}' namestatus.txt | grep -cE '(^/|(^|/)\.\.(/|$))'` → `0`. No absolute path, no `..` component, no submodule/gitlink entry (`--name-status` shows only `A`/`M` of blobs).

**1b — credential needles.** The census ERE was reassembled verbatim from the lane's own `corpus/sources-census.sh` (fragments evaluated at runtime, 137 bytes assembled) so this seat carries no needle literal:

```
[1b] CRED_RE assembled from corpus/sources-census.sh (137 bytes)
[1b] needle_families_detected=7/7
[1b] false_positive_on_plain_url=0 (expect 0)
[1b] added_lines_scanned=8433
[1b] credential_shape_hits=0
```
The 7/7 line matters: the first pass of this seat's harness dropped the `scheme=op` line while extracting the fragments, which produced 332 bogus hits (the ERE degenerated to `://[A-Za-z0-9_-]` and matched every URL). The corrected harness is proven sensitive on all seven census needle families (`op` scheme, PEM armour, `ghp_`, `AKIA`, `xox[baprs]-`, `AGE-SECRET-KEY-`, `hv[sbr].`) and proven non-matching on a plain `https://` URL before the 0-hit result is trusted. Families covered by the census ERE: 1Password secret-reference scheme, PEM private-key armour, GitHub classic PAT, AWS access-key id, Slack token prefixes, age secret keys, Vault/OpenBao service/batch/recovery tokens.

**1c — private endpoints:**
```
[1c] userinfo_embedded_urls=0 (expect 0)
[1c] private_host_shapes=0 (expect 0)   # localhost|127.0.0.1|10.x|192.168.|.internal|the-janitor
```
Every host occurring in added lines is a public vendor/catalogue/standards host (`www.iso.org`, `webstore.iec.ch`, `www.w3.org`, `openbao.org`, `developer.hashicorp.com`, `docs.github.com`, `raw.githubusercontent.com`, `api.github.com`, `releases.1password.com`, `app-updates.agilebits.com`, `csrc.nist.gov`, `web.cmp.usercentrics.eu`, `cdn.matomo.cloud`, `rum.hlx.page`, plus social/CDN assets). Four hosts warrant a note and are all *inside captured page markup*, not endpoints the lane contacted: `opb-test.iso.ch` (an ISO OBP test host named in an HTML comment), `gitlab.hyva.io` (a URL inside a JS comment in the IEC storefront body), `ruby.ops.iec.ch` / `paymentshub.weareplanet.com` (asset hosts). None is reachable from a lane script.

`op://` does not appear in any added line: `git diff <BASE> <CAND> --diff-filter=AM | grep '^+' | grep -c 'op://'` → `0`. Five added lines contain the two-character sequence `op:`, and all five are the substring inside CSS/JS `top:` declarations in captured page markup (`top: calc(…)`, `scroll({top: 0…})`, `top: ${…}px`), not the 1Password secret-reference scheme. No addition carries a secret reference.

**1d — cookie values. FINDING F1 (below).**

---

## Check 2 — captures and rejection receipts

Committed digests reconcile exactly with the registry, so the bodies are the fetches they claim:

```
[2] committed capture digests (sha256, size):
     S113 d8dfe35408b17b02845dc0cf19f774bc6cc6b8dcbfe1636e22bb6b13dfa64357 90604
     S113 registry  d8dfe35408b17b02845dc0cf19f774bc6cc6b8dcbfe1636e22bb6b13dfa64357 90604
     S113 meta      200 text/html;charset=UTF-8 https://www.iso.org/standard/82709.html 20762
     S114 8bb88d88ff21d4488cf2205d9655a7fcbdeb3601616bdf4f5767dce13c449bdf 85138
     S114 registry  8bb88d88ff21d4488cf2205d9655a7fcbdeb3601616bdf4f5767dce13c449bdf 85138
     S114 meta      200 text/html;charset=UTF-8 https://www.iso.org/standard/85929.html 19428
[2] capture titles:
     S113 ISO/IEC 11770-3:2021 - Information security — Key management — Par…
     S114 ISO/IEC 11770-3:2021/Amd 1:2025 - Information security — Key managem…
```
The `meta` sizes (20762 / 19428) are wire (gzip) sizes and the registry sizes (90604 / 85138) decoded sizes; `content-encoding` is present in both header dumps, so the pair is consistent rather than contradictory. `rejections/S114-refetch.meta` records `sha256 8bb88d88ff21d448` — identical to the committed `S114.body` prefix, i.e. the refetch really did reproduce the body.

Rejection receipts:

| file | meta first line | body | public? |
|---|---|---|---|
| `default-ua_85929.meta` | `403 text/html; charset=UTF-8` | 5448 B, `<title>Just a moment...</title>` (Cloudflare interstitial) | public 403 — *not* a catalogue page, but it exists precisely to record the default-UA rejection, and its meta says 403. The single `@` in the body is the CSS token `@media`. |
| `S114-refetch.meta` | `200 … 19428` | not kept (identical to `S114.body`) | public |
| `webstore_iec_ch_en_publication_107179.meta` | `200 text/html; charset=UTF-8 124027` | 429695 B decoded, `<title>ISO/IEC 11770-3:2021/AMD1:2025 \| IEC</title>` | public IEC catalogue page |
| `www_iso_org_contents_data_standard_08_27_82709_detail_rss.meta` | `200 application/rss+xml;charset=UTF-8 592` | 1371 B decoded, ISO per-standard feed for 82709 | public |

No captured body or receipt carries a credential shape (check 1b covered every added line, bodies included), a CSRF/session token literal (check 5), or a userinfo URL (check 1c). The IEC storefront body contains *code that manipulates* `form_key`/`mage-messages` cookies; it contains no cookie or `form_key` **value** (0 literal matches).

---

## Check 3 — fleet-root misroot sweep

```
$ git -C /home/vgpnk/Projects/shokunin status --porcelain | wc -l
5
[3] entries_naming_kagi_round55_r55=0 (expect 0)
      M .scratch/goal-20261103-hyaku-run15.md
      M .scratch/run15-state.json
     ?? .scratch/run15-wrapup/misroot-cff0b4cb/
     ?? f.txt
     ?? trail-ids.txt
```
None of the five names kagi, round-55 or r55; a `find .scratch -iname '*kagi*' -o -iname '*round-55*' -o -iname '*r55*'` returns nothing. The `misroot-cff0b4cb/` directory is unrelated to this lane (`versions.html`, `w4lines.txt`, sibling `round-84-kama.misroot-overwrite.md`) — it is an earlier wave's artefact, named "misroot" by whoever parked it, and is not a consequence of round 55. **Nothing moved, nothing edited**; reported only, per assignment.

---

## Check 4 — `/tmp/` citations

```
$ git -C <lane> diff ebe0958… 348aa3b… | grep -c '/tmp/'
0
[4] /tmp/ in added lines=0 (expect 0)
```
Zero in the whole diff and in added lines, in any of the 51 files.

Informational, not a failure: scratch paths *do* appear, all of them the sanctioned `$HYAKU_SCRATCH` default and all of them reproducible rather than host-bound —

```
     1 .ufo/waves/round-55/controls/census-start.txt
     1 plans/round-55-c1.sh
     1 plans/round-55-c2.sh
     1 plans/round-55-controls.sh
```
The three plans use `${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r55/<counter>.$$` — parameterised with `$$`, so no run collides with another and the root is overridable. `census-start.txt` cites `/fast/scratch/hyaku/kagi-r55/l1/basecensus/corpus/SOURCES.md` as the *input of a recorded run*, which is the designated scratch volume, not `/tmp`. Both satisfy the assignment's scratch rule.

---

## FINDING F1 — a `Set-Cookie` value is committed in the round's new `.headers` capture artifacts

**Severity: MEDIUM as an artifact-class defect / LOW for this instance.**
**Kind: refusal-boundary (kagi binding: "never print, copy, commit or paste any … cookie") + reusable-hazard.**
**Confidence: confirmed from local evidence only — no network fetch was made by this seat.**

**Evidence (values never printed):**
```
[2] Set-Cookie lines committed (file:line, cookie NAME only, value never printed):
     S113.headers:8 cookie=__cf_bm value_len=312
     S114.headers:8 cookie=__cf_bm value_len=313
[1c] set-cookie|jsessionid|awsalb|__cf_bm hits in added lines:
           1 .ufo/waves/round-55/capture/S113.headers
           1 .ufo/waves/round-55/capture/S114.headers
```
`.ufo/waves/round-55/capture/S113.headers:8` and `S114.headers:8` each contain a full `set-cookie: __cf_bm=<opaque value>; …` response header, both added by this landing (`A` in `--name-status`). The two values differ from each other (distinct digests of the value field), so they are two live per-fetch tokens, not one copied string.

**Exploit path.** Anyone who can read the lane repository — a clone, a mirror, a fork, a CI log that echoes a diff, or an agent transcript that greps a capture — obtains the `__cf_bm` cookie that the fetch of `https://www.iso.org/standard/82709.html` / `…/85929.html` received. `__cf_bm` is Cloudflare bot-management state bound to the issuing client's IP and user-agent with a lifetime of roughly 30 minutes; it authorises nothing except passing Cloudflare's bot check from that address, so replay value is small and time-boxed. I did not attempt replay and do not operationalise it.

The real hazard is the **artifact class**, not this instance. `.headers` dumps are new to the lane: `ls .ufo/waves/*/capture/*.headers` finds exactly these two files — every earlier round kept header dumps in scratch (`/fast/scratch/kagi-r25/…/evidence/*.headers`). The round therefore introduces a committed-artifact type whose whole purpose is to store raw response headers, against sites the lane will keep probing. The same recipe applied to a catalogue or docs site that answers with `JSESSIONID`, `sessionid`, `connect.sid` or an auth cookie would commit a bearer credential outright. **No gate would catch it, and the gap is two-deep.** First, the census credential ERE (7 families, verified 7/7 sensitive) contains no cookie needle. Second — and decisive — `cred_scan` is *called on only two surfaces*: `corpus/SOURCES.md` (line 348) and each `corpus/knowledge/*.md` entry (line 389). A file under `.ufo/waves/*/capture/` is never opened by the credential scan at all, and `corpus/claim-ledger.sh` has no header check either (`grep -c headers` → 0 on both gates). The lane's census would therefore print `SOURCES_CENSUS: CLEAN` over a committed `Set-Cookie: session=…` even if a cookie needle were added tomorrow.

**Impact.** No secret material, no key, no vault field and no account access leaks: `__cf_bm` is not an authenticating credential. Impact is (i) a literal breach of the lane's stated refusal boundary, and (ii) a silent, gate-invisible path by which a future round can commit a real session cookie.

**Smallest remediation.**
1. Mask the two values in place — keep the field name as evidence, replace the value with a fixed marker, e.g. `set-cookie: __cf_bm=<redacted>; …` — in `capture/S113.headers:8` and `capture/S114.headers:8`. Nothing downstream depends on the value: `grep -rlE 'capture/S11[34]\.headers' corpus/ plans/` → `0` references, no `*.tsv` has a `headers` column, and both gates ignore `.headers` entirely, so deletion of the two files is an equally sound (and simpler) alternative that costs no evidence — `.meta` already records status, content-type, URL and wire size.
2. Close the class. A needle alone is not enough (see the two-deep gap above). Either (a) stop committing header dumps — the natural fix, since the lane has kept them in scratch for every earlier round and `.meta` already carries status, content-type, URL and wire size — or (b) add a cookie needle to the census `CRED_RE` (fragment-assembled, existing style) **and** extend `cred_scan` over `$ROOT/.ufo/waves/*/capture/*.headers`, with one `m_cred_*` selftest case per new surface. Option (a) removes the hazard with no new gate surface; option (b) keeps the header evidence and makes future cookies a hard failure.

**Not in this seat's write scope** — `corpus/` and the capture directory are read-only for R55SentinelScope; this is a report, not a change.

---

## Minor observations (no verdict impact)

- `capture/S113.headers` and `S114.headers` are CRLF dumps: all 15 lines of each file end in `\r\n` (curl `-D` writes the on-wire form). Both start correctly with `HTTP/2 200` and both close with a blank line as the header terminator. Harmless for a `splitlines()` reader, but a `while read` loop without `IFS=` trimming would see field names like `set-cookie\r` and a field-name comparison would silently miss — worth stating explicitly if a capture parser is ever added.
- `rejections/default-ua_85929.body` is a Cloudflare interstitial, not the ISO catalogue page. It is the correct record for a 403 rejection receipt and its `.meta` says `403`, but it should not be read as a catalogue capture if the rejection is later promoted.
- The `webstore_iec_ch_en_publication_107179.body` rejection receipt is 429 695 B of Magento/Hyva storefront — 64 % of the 669 984 bytes of wholly new files in this landing (`git diff --diff-filter=A … | xargs stat -c%s | awk '{s+=$1}'`) — for a source that was rejected as duplicate ground. Keeping it is defensible (it is the evidence for the rejection) but it is the file most likely to carry cosmetic surprises from the publisher's storefront JS.

---

## Commands run (exact, in order)

```
git -C <lane> rev-parse ebe095857a734caf5efdd7bd776feb22b4e23972 348aa3b8ea7298aeb2f4d69db321fe827a92ae4f   # exit 0
git -C <lane> rev-parse HEAD                                                                                  # 348aa3b8…
git -C <lane> diff --stat <BASE> <CAND>            # exit 0, 51 files
git -C <lane> diff --name-status <BASE> <CAND>     # exit 0, 51 rows
git -C <lane> diff <BASE> <CAND>                   # exit 0, 8818 lines
bash .ufo/waves/round-55/build/R55SentinelScope.d/scan.sh   # exit 0, all sections
git -C /home/vgpnk/Projects/shokunin status --porcelain      # exit 0, 5 entries
grep -c '/tmp/' <diff>                                       # 0
sha256sum .ufo/waves/round-55/capture/S113.body S114.body     # match source-fetches.tsv col 10
```
Last output line of the receipt run: `bash scan.sh` → `exit=0`; final section ends with
`any column|field named headers in corpus/*.tsv: 0`.

No `git add/commit/checkout/reset/stash/push`, no `jj`, no pacman, no network fetch, no op invocation, no read of `~/.config/sops`, `~/.ssh`, `~/.config/op` or any key file, no host mutation. All writes are `../build/R55SentinelScope.md` and `../build/R55SentinelScope.d/*` plus the scratch dir, which the EXIT trap removed.
