# RAttackC3 — independent source re-open receipts (item 3)

Attack seat RAttackC3, 2026-11-03, Linux host (Arch, python3 3.14.8).
Profile used: `curl -fsSL` (the rows' declared recheck profile); digests with `sha256sum`;
normalized digests with the lane's one committed normalizer
`corpus/rendered-text-v1.py` (digest mode). No proxy, no cache flags.
Two formal receipts (S053, S059) per the attack item; four auxiliary re-opens recorded
because they were one command away. Comparison to `final/c3/src-open/` receipts was
NOT possible: that directory did not exist at attack time (see report §6).

## Formal receipt 1 — S053 (staged S066) Gitleaks README at the pinned commit

```
url:    https://raw.githubusercontent.com/gitleaks/gitleaks/b58d3f102cf3a2c84cb7f923d05c25c9b1aed84b/README.md
cmd:    curl -fsSL '<url>' | sha256sum
out:    65e87e68f4a16aefa1f1fba55b2e7a9b9bc8716393b7ddb013fc7c7bef4e4bc1
match:  campaign pin `65e87e68f4a16aef` (row S053 anchor / capture TSV) — EXACT, full 64 hex
also:   curl -fsSL 'https://raw.githubusercontent.com/gitleaks/gitleaks/master/README.md' | sha256sum
        -> 65e87e68f4a16aef... (identical: master README bytes == pinned-commit bytes today)
ls-remote refs/heads/master -> 5f6ec56cfa6f8c67648d863582c7ae2f206d5c1c
        (matches capture-TSV revision cell exactly)
quote:  grep -c '**detecting** secrets like passwords, API keys, and tokens in git repos, files'
        -> 1  (entry 1's quote locates VERBATIM incl. the ** markers)
config: grep -n -E 'secretGroup|entropy' -> `secretGroup = 3` (line 291), entropy
        comments at lines 290/293 — §"Configuration" rule fields present as anchored
```
Result: REPRODUCED (digest, quote, anchor fields, moving-ref revision all agree).

## Formal receipt 2 — S059 (staged S072) TruffleHog docs, Reverify secrets

```
url:    https://trufflesecurity.com/docs/reverify-secrets
cmd:    curl -fsSL '<url>' | sha256sum     (fetched twice, ~1 h apart)
out:    b4790c43398da9db6aa07b2dd883ecbad33e2e593c8f5cd4a30a90328eae3e0a   (both fetches)
match:  capture-TSV raw digest b4790c43... EXACT; campaign anchor pin 2997de91... NOT
        reproduced (page bytes differ from 2026-10-23 — representation is volatile/point)
quote:  grep -c 'Secret reverification is currently only supported for secrets that have
        been detected within a GitHub or Slack integration' -> 1  (FULL sentence locates)
para:   grep -o 'Whenever TruffleHog scans an integrated source[^<]\{0,120\}' -> locates
stamp:  page carries rendered `Updated<!-- --> <!-- -->06 Jul 2026` (react comment
        markers interrupt the plain-text form; anchor stamp "Updated 06 Jul 2026" is
        CONFIRMED in-round)
normalized digest (lane normalizer, rendered-text-v1):
        python3 corpus/rendered-text-v1.py digest <fetched file>
        -> raw_sha256=b4790c43... bytes=99172 normalized_sha256=df607e982176c63e8118f491aeddebb7eeaa527fe942dd752a4223331ce2fb00 normalized_bytes=1418
match:  capture-TSV normalized digest df607e98... — EXACT (independent reproduction of
        the one-committed-normalizer value, QM16)
```
Result: QUOTE + STAMP + NORMALIZED DIGEST REPRODUCED; raw digest is a new point
attestation (expected for this representation class, not a content contradiction —
the round-22 lesson: quotes/anchors are the content check).

## Auxiliary in-round evidence (same day, same profile)

- **S054** (staged S067) TruffleHog README at pinned commit d6ea4a52...:
  sha256 `068fbb5c93eb993d877b...` == campaign pin `068fbb5c93eb993d` EXACT;
  full validation sentence "For every secret TruffleHog can classify, it can also log in
  to confirm if that secret is live or not" -> count 1; `## Validation ✅` at line 51,
  `## 1: Scan a repo for only verified secrets` at line 183; `--results` flags present
  (15 matches). REPRODUCED. (Capture TSV additionally re-captures current main:
  raw 7cf6efb5..., revision 240ccdd9... — main moved past the pin; consistent shapes.)
- **S055** (staged S068) Betterleaks README: sha256 `f61c3993fd48dfb9...` == campaign
  pin EXACT; "Scans detect secrets without credential provider requests by default"
  -> 1; `Expr` x5, `BPE` x1, `BETTERLEAKS_VALIDATE` x1; blog-list line 8 shows three
  Substack posts + one aikido.dev article; `v1.x` branch line at 31; 'CEL' occurs only
  inside the blog-title pun "Express YourCELf" — the README nowhere states CEL.
- **S056** (staged S069) GitHub API recheck re-run exactly as the stripped prose
  command: today prints `False 2774 2026-11-03T00:45:58Z` (campaign pin: `False 2322
  2026-10-22T21:28:27Z`). Load-bearing `fork: false` REPRODUCES; stars/last-push moved
  (old→new belongs in the lesson Gate). Response sha16 today `7387064618752b50`
  (point attestation; capture TSV records its own 2026-11-03 capture b7e19953...).
- **S057** (staged S070) verification-caching: raw sha256 today `0beb84fec97fa0ac...`
  == capture TSV EXACT; needle "Each cache entry expires after three hours" -> 1;
  stamp 06 Jul 2026 confirmed (same rendered form as S059); normalized digest
  independently reproduced with `corpus/rendered-text-v1.py`:
  `5e697b14d10802cbb06d2c2eba91aaca206f10827360cc04206c21e8b397bc9c` == TSV EXACT.
- **S058** (staged S071) how-we-handle-your-data: raw sha256 today
  `2c85abe9e3f842a7...` == capture TSV EXACT; needle "Credentials are verified using
  safe, read-only API calls" -> 2 (matches the strip-file expectation).
- **S060** (staged S073) notify-results: raw sha256 today `8c0a977c75286c17...` ==
  capture TSV EXACT; `sendUnverified` -> 2; stamp "Updated 14 Aug 2026" -> 1 (confirmed).

Net: 8/8 rows re-opened in-round by this seat; 5/8 raw digests byte-reproduced
(S053, S054-at-pin, S055, S057, S058, S060 — six actually), 2/2 rendered normalized
digests independently reproduced, all needles locate, all three stamps confirm.
No source contradicts its staged quote.
