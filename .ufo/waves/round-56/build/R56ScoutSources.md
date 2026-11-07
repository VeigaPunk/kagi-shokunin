# R56ScoutSources — round 56 source reopen, clock recheck, and frontier rejections (freshness)

Seat: R56ScoutSources (leaf member; no subagents dispatched). Date of measurement: 2026-11-07.
Lane: `/home/vgpnk/Projects/shokunin/kagi-shokunin`, BASE `832ba6a53d6a76706b5c80bce2278683dea33d42`,
branch `master`, working-tree HEAD `42070de7770e1558adcf6aa7a7bc59309a9654d7`.
Observed answering model (from the session's own record, `PI_SESSION_FILE` model_change entries, not
from the prompt): `minimax-code/MiniMax-M3.1-Flash`.

Tools used, all preinstalled (no install, no pacman transaction): `curl 8.23.0`,
`python3 3.14.8`, `pdftotext 26.10.0` (poppler), host `grep`.
Scratch (deleted before yield): `/fast/scratch/hyaku/kagi-r56/R56ScoutSources/`.

Receipts (paths relative to the lane root):
`.ufo/waves/round-56/build/R56ScoutSources.d/live-reopen.tsv`,
`.ufo/waves/round-56/build/R56ScoutSources.d/clock-replay.tsv`,
`.ufo/waves/round-56/build/R56ScoutSources.d/candidate-rejections.tsv`,
`.ufo/waves/round-56/build/R56ScoutSources.d/s113-default-ua.txt`.

Instrument hashes measured this seat (sha256):
`corpus/recheck-replay.py` = `b7782f35c0c8bbaedac5f8f06eaadbc3ce4b8997be25e10f4224724013d799e8`,
`corpus/recheck-captures.tsv` = `df46be5c92c7b4d5a8b7ad790371b5c3240c92f46460b8cfb69e9b75b7ecc762`,
`plans/round-56.md` = `d1bf8d2610ed50d46acda83e38c055e629d5e76d0b860d14665f2d223e0b8a07`,
`plans/round-56-c1.sh` = `096251c9b7a7405dbae320eb4dbb3ef0a092cf5e530d2274de0b2e29509bde9a`,
`plans/round-56-controls.sh` = `633326a563c6d38e7933d0e88d3b395404f688dbef9ff8e1de7fffdbed48b094`.

## Verdict

**All ten stated clocks are true today, live, and true offline on the committed captures. Every
one of the seven URLs the round opened was reopened independently; six re-fetch byte-identically,
one (S074) re-fetches at a different raw digest but an identical normalized digest. Eleven
candidate sources are rejected. The S113 default-UA assertion (round-55 spot-check D3) is
TRUE — its receipt, not its claim, was wrong.**

| check | result |
|---|---|
| stated clocks replayed live (exact command forms) | 10/10 equal the stated N |
| stated clocks replayed offline on the committed captures | 10/10 MATCH |
| seven round-56 capture URLs reopened | 7/7 HTTP 200; 6/7 byte-identical, 1/7 normalized-identical |
| three already-committed ISO captures reopened (S101/S113/S114) | 3/3 byte-identical |
| source census after the round | `kagi ok …/corpus/SOURCES.md`, rc 0, 19 W04 (same count as `.ufo/waves/round-56/controls/census-start.txt`) |
| rows appended by this seat | 0 (SOURCES.md untouched; `git diff --stat -- corpus/SOURCES.md corpus/knowledge/` empty) |

## 1. The seven reopened URLs — recheck quote and expectation

Request profile: `curl -fsSL --compressed --max-time 60 -o <body> -w '%{http_code} %{size_download}
%{url_effective} %{content_type}' <url>`. No `-D`, no `-i`: no response header was requested or
stored (QM72). Bodies went to scratch only; the committed captures were not overwritten.

| id | URL | HTTP | decoded B | live sha256 | vs committed capture |
|---|---|---|---|---|---|
| S054 | `https://raw.githubusercontent.com/trufflesecurity/trufflehog/main/README.md` | 200 | 38524 | `7cf6efb50ab892347b1fa3bee77592603b371b066b6b1659fcc2c56a62e6eff7` | identical |
| S055 | `https://raw.githubusercontent.com/betterleaks/betterleaks/main/README.md` | 200 | 13252 | `f61c3993fd48dfb973652b9676697f4d37404fad9f30748c2003127eb81a73b1` | identical |
| S057 | `https://trufflesecurity.com/docs/verification-caching` | 200 | 110710 | `221d80fae1227db73c5f65ff71080d72e6e91666856a1dd8e1e2d402dfe9604b` | identical |
| S067 | `https://openid.net/specs/openid-connect-core-1_0.html` | 200 | 437508 | `4d016752a645e8a3c259baa4173b5a90cb6c82898ce868fc8444adde262a5aed` | identical |
| S070 | `https://www.1password.dev/brokered-access/custom-workflow` | 200 | 268454 | `5c226c06413854281f229aa0831f3fa7b9e63cdd3d2a4bf761f2226652a1c0dd` | identical |
| S074 | `https://csrc.nist.gov/pubs/sp/800/133/r3/ipd` | 200 | 45351 | `3a4c80b3b3c53dfc974243cb4c4b7835c1c1c06bb34bb8135dd9a6f2be9854ab` | **raw digest differs, normalized digest identical** |
| S078 | `https://nvlpubs.nist.gov/nistpubs/Legacy/SP/nistspecialpublication800-57p2.pdf` | 200 | 622785 | `68266cb10868a1fee83fb8bcebbee9573fc738cee9141ee94d03649bad8538d5` | identical |

Each committed capture's manifest row also matches the file on disk (bytes + sha256), and none
of the seven begins with `HTTP/` or carries a `set-cookie:` line (`grep -a -c` ⇒ 0 on all;
S078 is `%PDF-1.6`).

### S074 — the one body whose raw digest does not reproduce (honest note)

The round's named ceiling says capture provenance is "the fetch receipt plus a non-author live
re-fetch". For S074 the live re-fetch does **not** reproduce the committed raw sha256
(`df32e64b9cce734698974dde083feeeaa7d34eef2e6c6391c7694ea7f29c3688`). Five independent fetches
today produced five distinct raw digests at constant 45351 B:

```
df32e64b…3688   committed capture
3a4c80b3…54ab   fetch A
a2c937f4…c8c8   fetch B
2689fd4c…ab44   fetch C
d53b29ce…c827   fetch D
83f550d9…2fda   fetch E (exact clock form, no --compressed)
```

The variation is confined to 8 lines: four Cloudflare `email-protection` rot13 token blocks and
the `__CF$cv$params` `r:`/`t:` challenge parameters (diff line numbers 416, 438, 655, 690).
The clock's own phrase sits on unchanged line 435 of every fetch. Under the lane's declared
normalizer the body **is** stable: `rendered-text-v1.py digest` gives
`normalized_sha256=955dd8665388946280b67fdcbd9e9c7cfa3d5343b54f223daf5cba40ebeb7fab`,
`normalized_bytes=5636` on the committed capture and on all five live fetches. This is the
behaviour the entry already declares (`corpus/knowledge/nist-key-management-guidance-status.md:2`,
"raw bodies are non-reproducing at constant size"), so the claim is unaffected — the replay is on
committed bytes — but a reader who takes "non-author live re-fetch" as a *raw-sha256* reproduction
check fails it on S074 and only on S074.

### Recheck quote and expectation, per clock

Every stated clock's own command was run live (network) with the exact form written in the
knowledge entry, and separately replayed offline against the committed capture.

| id | entry:line | form | stated | live | offline replay | quote located in the live body |
|---|---|---|---|---|---|---|
| S054 | `secret-scanning-detection-vs-validation.md:4` | grep | 1 | 1 | 1 | line 53: "For every secret TruffleHog can classify, it can also log in to confirm if that secret is live or not." |
| S055 | `betterleaks-detection-vs-validation.md:4` | grep | 1 | 1 | 1 | line 66: "Scans detect secrets without credential provider requests by default." |
| S057 | `trufflehog-verification-lifecycle.md:4` | grep | 1 | 1 | 1 | byte offset 61737: "Each cache entry expires after three hours." (in the page's editor payload) |
| S067 | `oidc-federation-trust-policy.md:3` | grep | 1 | 1 | 1 | line 1061: "It MUST contain the OAuth 2.0 `<tt>client_id</tt>`" |
| S070 | `cdp-bridge-1password-oidc-workflow.md:3` | locate | count=1 | count=1 | count=1 | `RENDERED_TEXT_V1_LOCATE: count=1` on the live body; the raw HTML carries the sentence twice, the normalizer resolves it to 1 |
| S074 | `nist-key-management-guidance-status.md:3` | grep | 1 | 1 | 1 | line 435: "Comments Due: June 16, 2026 (public comment period is CLOSED)" |
| S078 | `nist-key-management-parts-withdrawal.md:3` | pdf | 1 | 1 | 1 | pdftotext line 5: "The attached publication has been withdrawn (archived), and is provided solely for historical purposes." |
| S101 | `iso-11770-3-edition-status.md:3` cmd 1 | grep | 2 | 2 | 2 | lines 751 and 1071: "Withdrawal of International Standard" (stage line 95.99, life-cycle list) |
| S113 | `iso-11770-3-edition-status.md:3` cmd 2 | grep | 3 | 3 | 3 | lines 917, 918, 1224: "ISO/IEC 11770-3:2021/Amd 1:2025" |
| S114 | `iso-11770-3-edition-status.md:3` cmd 3 | grep | 2 | 2 | 2 | lines 848 and 1072: "International Standard published" (stage 60.60) |

Ten stated clocks across eight knowledge entries in three filter forms (grep 8, pdf 1, locate 1)
— the population the plan states. Every one: stated == live == offline.

Offline gate cross-check, run on the lane working tree:
`python3 corpus/recheck-replay.py` ⇒ ten `MATCH` lines, last line
`RECHECK_REPLAY: CLEAN (clocks=10 match=10 mismatch=0 no_capture=0 bad_capture=0 unsupported=0
tool=0)`, rc 0.

The three ISO captures the round did **not** open were re-fetched independently anyway, with the
browser user agent the entry's `recheck:` line declares (`curl -fsSL -A 'Mozilla/5.0 (X11; Linux
x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0 Safari/537.36'`), and all three
reproduce byte-identically: S101 `2e4c1524ec05865536f819db68c56494d97fc67cb490df4f5d4b1ca85b7b0c80`
85615 B (the round-45 capture), S113 `d8dfe35408b17b02845dc0cf19f774bc6cc6b8dcbfe1636e22bb6b13dfa64357`
90604 B, S114 `8bb88d88ff21d4488cf2205d9655a7fcbdeb3601616bdf4f5767dce13c449bdf` 85138 B (the
round-55 captures). The round-55 line's claim that S101's 2026-11-07 body is byte-identical to
the round-45 capture holds today.

## 2. S113 default-UA assertion (round-55 spot-check D3) — the claim is true

D3 said: the S113 row asserts "the default user agent receives HTTP 403", but the only default-UA
receipt on file was taken on the **S114** URL (`82709` was never probed with the default agent).

Probe on the S113 URL itself, default curl UA, no headers requested or stored:

```
curl -sSL --max-time 60 -o <body> -w '%{http_code} %{size_download} %{content_type}' \
  'https://www.iso.org/standard/82709.html'
  ⇒ 403  5448  text/html; charset=UTF-8   body <title>Just a moment...</title>   rc 0
curl -fsSL --max-time 60 -o <body> -w '%{http_code}' 'https://www.iso.org/standard/82709.html'
  ⇒ 403, curl rc 22, 0 body bytes
```

Same on the other two ISO URLs: `https://www.iso.org/standard/85929.html` ⇒ 403 / 5448 B, and
`https://www.iso.org/standard/60237.html` ⇒ 403 / 5448 B.

**Finding: the parenthetical is TRUE for the S113 URL. D3's defect is the receipt's URL, not the
assertion.** A lesson that records it as a false claim and narrows the sentence would retire a
correct statement.

Two things the lane should fix before the lesson text is written:

1. The tree already carries a body-only receipt,
   `.ufo/waves/round-56/capture/rejections/S113-default-ua.body` (5448 B,
   sha256 `ce3cb7f2eb0efeba38faff1ded3186218ad9df51e4b22b795d0688fa2eb3893c`, committed in
   `42070de`), but **no `.meta` beside it**. Round 55's equivalent is a pair —
   `capture/rejections/default-ua_85929.meta` recording `403 text/html; charset=UTF-8` next to
   its body. Without the status record the tree alone does not show that this body is a 403.
   The bytes are not a stable identifier either: my four independent probes each returned 5448 B
   with a *different* sha256 (`f80447da…`, `c6708a21…`, `1c158a54…`, `f3305b66…`), and the
   committed body differs from my first probe in 1902 byte positions. Only the status is stable.
   Recommend a `.meta` file recording `403 text/html; charset=UTF-8` beside the committed body.
2. The correction sentence. Suggested narrow replacement for the S113 row's parenthetical, if the
   lane wants the claim narrowed to what one probe on one day supports:

   > `the default user agent receives HTTP 403 (Cloudflare interstitial, probed on this URL 2026-11-07)`

   The clause "on this URL" is the whole of D3: it converts a receipt taken on a sibling URL
   into a receipt taken on the URL the row is about. A still-narrower variant, if the lane
   prefers to state only what the receipt carries:
   > `a default-agent request for this URL received HTTP 403 on 2026-11-07; the 403 body is a
   > Cloudflare challenge page whose bytes are not stable, so only the status is recorded`

   No edit to `corpus/SOURCES.md` was made by this seat (append-only rule, `CORPUS.md` §SOURCES.md
   rule 2: only `status`, `recheck` and `used-by` change in place).

## 3. Frontier source rejections

Eleven candidates screened, all public GET, no headers stored; full table with reasons and flips
in `.ufo/waves/round-56/build/R56ScoutSources.d/candidate-rejections.tsv`.

| id | candidate | HTTP | B | sha256 | rejection |
|---|---|---|---|---|---|
| R1 | `https://www.1password.dev/brokered-access/custom-workflow/` | 200 | 268454 | `5c226c06…c0dd` | same URL as S070 modulo trailing slash, byte-identical body; S070 holds the runtime mechanics, S018 the feature status |
| R2 | `…/custom-workflow#step-2` | 200 | 268454 | `5c226c06…c0dd` | a fragment addresses no distinct document; byte-identical to the S070 capture |
| R3 | `https://trufflesecurity.com/docs/verification-caching/` | 200 | 110710 | `221d80fa…604b` | same document as S057; identical body |
| R4 | `https://openid.net/specs/openid-connect-core-1_0.txt` | 200 | 70623 | `aa28dd92…f25e` | duplicate ground with S067, and `grep -c 'It MUST contain the OAuth 2.0'` = 0 on it (the .txt reads `MUST contain the OAuth 2.0 "client_id" …`, no leading "It"), so it cannot serve as the S067 clock's capture |
| R5 | `https://raw.githubusercontent.com/betterleaks/betterleaks/v1.x/README.md` | 200 | 8202 | `5164be30…52e5` | the v1 branch does not carry the S055 clock sentence (`grep -c` = 0); the S055 row already records that v1 lives on `v1.x` |
| R6 | `https://raw.githubusercontent.com/trufflesecurity/trufflehog/v3/README.md` | 404 | 14 | — | no such branch artifact; the S054 URL is `main` |
| R7 | `https://trufflesecurity.com/docs/verification` | 404 | 0 | — | no such page (curl rc 22 with `-f`) |
| R8 | `https://csrc.nist.gov/pubs/sp/800/133/r3/final` | 404 | 7379 | — | no final SP 800-133 Rev. 3 exists ("Page Not Found \| CSRC"), so the draft row S074's ground is complete |
| R9 | `https://csrc.nist.gov/pubs/sp/800/133` | 404 | 7375 | — | no publication-family index at this path |
| R10 | `…/nistspecialpublication800-57p3.pdf` | 200 | 663635 | `52b9a7d3…8c3a3` | byte-identical to the registered S079 fetch (`corpus/source-fetches.tsv:122`); duplicate ground |
| R11 | `http://nvlpubs.nist.gov/…/nistspecialpublication800-57p2.pdf` (http) | 200 | 622785 | `68266cb1…38d5` | the same PDF artifact as S078 reached by redirect; identical digest, canonical https URL already holds it |

### S070 and S018 — same URL, distinct scope, no rows appended

The two rows differ in the URL *spelling* only: S018 carries
`https://www.1password.dev/brokered-access/custom-workflow/` (trailing slash) and S070 carries
`https://www.1password.dev/brokered-access/custom-workflow`. Both spellings return the **same
body, byte-identically** (sha256 `5c226c06413854281f229aa0831f3fa7b9e63cdd3d2a4bf761f2226652a1c0dd`,
268454 B) — measured by this seat, R1 above.

The scopes are distinct, which is what makes the pair legitimate rather than a duplicate:
S018's scope cell reads *"Page title, introduction, Step 1, Step 3 note; unversioned live docs
opened 2026-10-20"* (feature status and prerequisites), S070's reads *'page title "(public beta)",
§"Step 2. Connect your Environment to your workflow" … and §"Step 3: Use your Environment in your
workflow"'* (runtime mechanics).

The census already classifies the pair correctly: `scripts/sources-census.sh` `url_of()`
(`scripts/sources-census.sh:600-605`) strips the trailing slash before keying, so both spellings
land on one url key, and the pair is reported as the expected cross-scope warning —
`kagi W04 S070 duplicate url www.1password.dev/brokered-access/custom-workflow across scopes`,
rc 0, 19 W04 total, identical to the round-start receipt
`.ufo/waves/round-56/controls/census-start.txt`. **No rows were appended by this seat.**

## 4. Harm / non-mutation evidence

- `git diff --stat -- corpus/SOURCES.md corpus/knowledge/` ⇒ empty. No production file was edited.
- `git status --porcelain -- corpus/ .ufo/waves/round-56/capture/ plans/` ⇒ empty; the gate
  instruments and the seven captures are as committed in `42070de`.
- `scripts/sources-census.sh validate --root /home/vgpnk/Projects/shokunin kagi` ⇒ `kagi ok
  /home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/SOURCES.md`, rc 0, 19 W04 (same count as
  round start).
- No cookie, session id or vault material was read, captured or printed. No response header was
  requested (`-D`/`-i` never used). The only credential-shaped check run was a *count* over the
  403 challenge bodies: `grep -a -c -i -e 'set-cookie' -e '__cf_bm' -e 'cf_clearance'` ⇒ 0.
- Scratch `/fast/scratch/hyaku/kagi-r56/R56ScoutSources/` deleted before yield.

## 5. Unresolved / limits of this seat

- The S074 raw-digest volatility is characterised, not fixed. It is upstream behaviour of the
  publisher's edge (Cloudflare), matches the entry's own declaration, and does not affect the
  committed-bytes replay. If the lane wants the capture set's provenance check to be raw-sha256
  based, S074 is the row that will fail it.
- The 403 interstitial's byte instability means no digest of a 403 body is a durable receipt;
  only the status is. This affects the S113 rejection receipt's evidential value and is why the
  `.meta` recommendation in §2 matters.
- I did not re-measure the counter's own control battery (`.ufo/waves/round-56/controls/
  controls-prefreeze.txt`, 12 MATCH / 0 mismatch as committed) beyond reading it and running the
  gate on the working tree; control-battery adequacy is the controls seat's scope.

## Trailer

- `.ufo/waves/round-56/build/R56ScoutSources.md` — this report.
- `.ufo/waves/round-56/build/R56ScoutSources.d/live-reopen.tsv` — the seven reopened URLs with
  status, bytes, sha256 and capture comparison.
- `.ufo/waves/round-56/build/R56ScoutSources.d/clock-replay.tsv` — per-clock stated / live /
  offline replay, and the gate's own output.
- `.ufo/waves/round-56/build/R56ScoutSources.d/candidate-rejections.tsv` — the eleven rejections
  with status, bytes, sha256, reason and flip.
- `.ufo/waves/round-56/build/R56ScoutSources.d/s113-default-ua.txt` — the S113 default-UA probe
  receipt and the suggested correction sentence.
