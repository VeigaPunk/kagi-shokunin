# S015 C2 recapture falsification

- Frozen lane revision: `c5ef9e92201b6c36396301f12b23740565bf86a0` (observed `HEAD`; sandbox clone checked out the same revision).
- Scope/bounds: S015 only. Read `corpus/SOURCES.md:21`, `corpus/source-fetches.tsv:68`, `corpus/inrow-pins.tsv:21`, and `.ufo/waves/round-24/build/RecapS015.md`; did not verify the other 15 pins, census, or C2 aggregate. Production files were not changed. No tools installed.

## Reopen and reproduction

Reopened the registered URL using the declared user agent and `curl -fsSL --compressed` in the unique sandbox with `env -i PATH=/usr/bin:/bin` and an empty sandbox `HOME`:

```text
curl exit 0
stdout:
https://openbao.org/docs/auth/jwt/oidc-providers/kubernetes/ 200
4e3fdb7d2628f11584690f7eb856186283c688bad09ec8a77e509ab133edbf2f  S015.body
55824
```

`corpus/rendered-text-v1.py digest S015.body` (sandbox clone, exit 0) returned:

```text
RENDERED_TEXT_V1: raw_sha256=4e3fdb7d2628f11584690f7eb856186283c688bad09ec8a77e509ab133edbf2f bytes=55824 normalized_sha256=2732189767e6663d9994b7d7f5d20cab6c4d5b28ede6f73c5f2cfb4707a2aab8 normalized_bytes=8724
```

Final URL/status, byte count, raw and normalized digests all match the 2026-10-21 `source-fetches.tsv` S015 record and the build receipt. `locate` on the quote without Markdown backticks, `The JWT auth engine does not use Kubernetes' TokenReview API during authentication`, exited 0 with `count=1`. The same query with literal Markdown backticks around `TokenReview` exited 1 with `count=0`; the fetched HTML's `<code>` tags normalize away, while the quote argument's backticks do not. The supporting sentence `This means tokens that have been revoked by Kubernetes will still be considered valid by OpenBao until their expiry time.` located once (exit 0). Thus the live wording and revocation interpretation in the receipt are supported; the backtick mismatch is representation/formatting, not claim absence.

## Classification and limits

- **Verdict: PASS for this S015 recapture and classification; UNKNOWN for the original pin's representation/provenance.** The historical in-row pin is `a0a2b227a7a91b7af0033a9fc665d319776d2d03aa09341620f9abee2f195fd4` (registry opened 2026-10-19). It equals neither the reopened raw digest (`4e3f…`) nor the reopened `rendered-text-v1` digest (`2732…`), so `non-reproducing` is correct *against the 2026-10-21 capture's two declared digest domains*.
- This does **not** establish that the 2026-10-19 observation was false or that the page changed: no original response bytes or representation declaration for that old pin were present in the scoped evidence. `inrow-pins.tsv:1-6` explicitly calls it a historical point observation of an undocumented representation and says it is not evidence of page change. The `source-fetches.tsv` schema names `decoded-http-body-volatile-v1` (decoded body, volatile raw HTML), `rendered-text-v1`, and says these are point attestations, not drift pins.
- No undocumented representation is called current in the scoped artifacts: the unlabeled 2026-10-19 pin remains explicitly historical; the 2026-10-21 capture declares its request profile, decoded-body representation, and normalizer. The reopened digests describe only the observed 2026-10-21 response.
- **Severity/falsifier:** no S015 C2 counterexample observed; residual historical-provenance uncertainty only. A preserved 2026-10-19 body plus its declared digest domain matching `a0a2…` would change the historical reproducibility assessment; a current body that failed the declared quote or contradicted the revocation sentence would overturn the content finding. Neither is observed here.
