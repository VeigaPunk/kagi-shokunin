# SrcOpenA — scoped findings (round-31 BUILD, C2 source re-open, group A)

Re-opened the five staged sources that fall to group A (staged S052–S056 → lane S061–S065) with
`curl -fsSL --max-time 30 '<url>'`, on 2026-11-03.

**Outcome:** 5/5 HTTP 200, 5/5 quotes located, 0 REFUSED, 0 fetch failures.

| draft → final | HTTP | bytes | representation | locate (rendered/raw/flat) | location |
|---|---|---|---|---|---|
| A1→S061 AWS create-oidc | 200 | 51283 | decoded-http-body-v1 | 1/1/1 | `claims_supported` → `aud` bullet |
| A2→S062 AWS condition keys | 200 | 185044 | decoded-http-body-v1 | 1/**0**/**0** | §Available keys for AWS OIDC federation |
| A3→S063 STS AssumeRoleWithWebIdentity | 200 | 51850 | decoded-http-body-v1 | 1/1/1 | §Request Parameters → `Audience` |
| A4→S064 GCP best practices (301 → docs.cloud.google.com) | 200 | 211206 | volatile | 1/**0**/1 | §Protecting against spoofing threats (h2) |
| A5→S065 GCP WIF ja | 200 | 174357 | volatile | 1/1/1 | heading 属性条件 (h3), first paragraph |

Artifacts (mine, complete):

- `.ufo/waves/round-31/src-open/group-a.tsv` — 5 rows × 16 columns; column 1 `A1..A5`
  (placeholder), column 3 already `sha256("S0xx\tmined\t<registered url>\n")` for the final id;
  every field passes a scratch reimplementation of the census's 14 per-field rules (5/5, exit 0).
- `.ufo/waves/round-31/src-open/group-a-receipts.txt` — argv/exit/HTTP/final-URL/raw sha/size,
  two stability probes, normalized digest, quote+word count, locate counts, location; ends with a
  READY-TO-APPEND block already substituted to `S061..S065`.

Findings the L1 must not lose:

1. **A2 quote is markup-split** (hard wrap + `<a>` around `AssumeRoleWithWebIdentity`): raw grep 0,
   rendered locate 1. A `recheck:` needle authored from it must use `rendered-text-v1`.
2. **A4 quote is line-wrapped**: raw one-line grep 0, newline-flattened grep 1, rendered locate 1.
3. **A4's staged anchor label is imprecise**: the sentence is in the h2 **Protecting against
   spoofing threats**, not a §Best practices bullet list (that is the page *title*). The audience
   claim in the entry's table belongs at h3 **Use the URL of the workload identity pool provider as
   the audience**, which states the default expected audience is the
   `iam.googleapis.com/…/providers/PROVIDER_ID` URL.
4. **A1 paraphrase drift**: the page says "The URL should not contain a port number" (a directive);
   the staged entry's "normally no port" is a normality claim. Citation survives, wording should be
   re-grounded — a cheap flip candidate for the entry gate.
5. **A4 registered URL is a 301** to `docs.cloud.google.com`; registry URL must stay the staged
   `cloud.google.com` (the census compares `url`, not `final-url`).
6. **A4/A5 are byte-volatile** (per-request CSP nonce): raw sha is a point attestation, normalized
   text digest is stable across probes (`92c7db2c…`, `7a5a1c57…`). Declared
   `decoded-http-body-volatile-v1`.
7. **0/5 staged sha16 prefixes reproduce** today (`c69aea10…`→`141dd481…`, `c65b05fe…`→`fb5b2e35…`,
   `e5349f6c…`→`a08888ce…`, `ac85362d…`→`116398b3…`, `97c3149d…`→`0179cc57…`); they differ from the
   first byte, so no truncated/offset variant explains them. A1–A3 are byte-stable across three
   fetches (page rebuild since 2026-10-23); A4/A5 cannot be pinned raw at all. No UA/encoding
   variants were probed — the round's network declaration allows only the declared profile.
   Every staged quote still locates, so no teaching is affected.
8. **Column-3 trap**: the digest is final-id based while column 1 is `A1..A5`. Substitute both
   together (map A1→S061 … A5→S065); any other id assignment needs a recomputed column 3.

Not run by design: lane census, any gate, build/lint/test. Scratch
`/fast/scratch/hyaku/kagi-r31/src-opena/` was deleted after the receipts were written.
