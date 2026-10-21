# FRecapS007 — C2 scoped falsification

- **Frozen lane:** `c5ef9e92201b6c36396301f12b23740565bf86a0`; BASE `4f94b52a3cdfaa289d779bd8a2afcd0b1fcd9105`.
- **Scope:** S007 only. Sandbox existence check/directory creation (`test ! -e ... && mkdir -p .../home`) and read-only lane `git rev-parse HEAD`/`git log` precheck ran in the ambient shell; clone/checkout, curl and normalizer execution used `env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r24-recovery/FRecapS007-9/home`. The isolated clone was made with `git clone --no-hardlinks /home/vgpnk/Projects/shokunin/kagi-shokunin /fast/scratch/kagi-r24-recovery/FRecapS007-9/repo`, then checked out at the frozen revision. No production files or lane Git index were changed; no tools installed.

## Fresh capture and pin classification

Reopened registered URL `https://www.1password.dev/brokered-access` with the declared curl profile and `corpus/rendered-text-v1.py` from the frozen clone.

```text
curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)' -o /fast/scratch/kagi-r24-recovery/FRecapS007-9/s007.body -w '%{url_effective} %{http_code}\n' 'https://www.1password.dev/brokered-access'
exit 0; https://www.1password.dev/brokered-access 200
python3 /fast/scratch/kagi-r24-recovery/FRecapS007-9/repo/corpus/rendered-text-v1.py digest /fast/scratch/kagi-r24-recovery/FRecapS007-9/s007.body
exit 0; raw_sha256=67f690e21116a3644be8cff57058293150b8b03fc305ffa15dc3af63fa43c312 bytes=1199447
        normalized_sha256=f3861c172c370dd10ef8a9289857b0b59c5b07a9d16f2f7cf25aeb02738cc6e9 normalized_bytes=6049
```

These observed URL/status/raw digest/size/normalized digest match S007 in `corpus/source-fetches.tsv:60` and `.ufo/waves/round-24/capture-evidence.json:81-92`; metadata consistency of that 2026-10-21 capture is **PASS**. The in-row historical pin in `corpus/SOURCES.md:13` is `e4aef238bb5c93080bc0e1cc2156d0f8d19c9291dbbee60193bd42485686f818`: it matches neither this raw digest nor this normalized digest. `corpus/inrow-pins.tsv:13`'s `non-reproducing` classification is therefore **PASS for comparison against this capture**. It does not establish what representation generated the historical pin or prove the original capture false; the registry explicitly says the historical representation is undocumented (`SOURCES.md:95-97`). Historical reproduction remains **UNKNOWN** without the old bytes/representation.

The current row does not disguise an undocumented representation: `source-fetches.tsv` declares `decoded-http-body-volatile-v1` for the curl-decoded raw body and `rendered-text-v1` for normalization. Its header says volatile raw/normalized hashes are point observations, not cross-capture drift pins. The normalizer documents strict UTF-8, script/style and tag removal, HTML entity decoding, Unicode whitespace collapse/trim; it does not case-fold.

## Quote check and falsifier

Exact fresh-body quote commands and results:
- `python3 /fast/scratch/kagi-r24-recovery/FRecapS007-9/repo/corpus/rendered-text-v1.py locate /fast/scratch/kagi-r24-recovery/FRecapS007-9/s007.body "only remain accessible for the duration of the workflow"`: exit 0/count 1.
- `python3 /fast/scratch/kagi-r24-recovery/FRecapS007-9/repo/corpus/rendered-text-v1.py locate /fast/scratch/kagi-r24-recovery/FRecapS007-9/s007.body "All configured claims must match"`: exit 0/count 1.
- `python3 /fast/scratch/kagi-r24-recovery/FRecapS007-9/repo/corpus/rendered-text-v1.py locate /fast/scratch/kagi-r24-recovery/FRecapS007-9/s007.body "the token value is your integration key"`: exit 1/count 0; `python3 /fast/scratch/kagi-r24-recovery/FRecapS007-9/repo/corpus/rendered-text-v1.py locate /fast/scratch/kagi-r24-recovery/FRecapS007-9/s007.body "The token value is your integration key"`: exit 0/count 2.

Thus the current page supports the phrase/mechanism, but the registry's lowercase text is **not an exact quote** under its declared case-sensitive normalizer. This is a **medium-severity row-level quote-fidelity falsifier**, not a falsifier of the pin classification or of the mechanism's meaning.

**Scoped result:** S007's fresh recapture metadata and `non-reproducing` comparison are supported; one of its three registry quotations fails exact reproduction. This single-row result does not establish C2's all-row census. No full harness or gate was run.
