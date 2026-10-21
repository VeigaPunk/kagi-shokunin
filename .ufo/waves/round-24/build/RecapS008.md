# S008 — legacy in-row pin recapture

## Registry claim

`corpus/SOURCES.md:14` records the moving URL `https://raw.githubusercontent.com/getsops/sops/main/README.rst`, the historical in-row `Fetch sha256` pin `63cb0a462ce23574365c0b692aa09ea2f632f4b4df2b5f4186d8c004b57e3440`, teaches scope “SOPS recipient, key-group, and data-key rotation mechanics,” and quote “You can find the SOPS documentation on getsops.io”. The row is `rejected`. The declared fetch profile is documented at `corpus/source-fetches.tsv:12-16`.

## Live `main` recapture

Command (declared profile; decoded HTTP body saved in the scratch directory):

```sh
mkdir -p /fast/scratch/kagi-r24/seats/RecapS008-2 && cd /fast/scratch/kagi-r24/seats/RecapS008-2 && curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)' -o s008-main.rst -w '%{url_effective} %{http_code}\n' https://raw.githubusercontent.com/getsops/sops/main/README.rst
```

Exit: 0. `curl -w` output: `https://raw.githubusercontent.com/getsops/sops/main/README.rst 200` (HTTP 200).

```sh
python3 /home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/rendered-text-v1.py digest /fast/scratch/kagi-r24/seats/RecapS008-2/s008-main.rst
```

Exit: 0. `RENDERED_TEXT_V1: raw_sha256=63cb0a462ce23574365c0b692aa09ea2f632f4b4df2b5f4186d8c004b57e3440 bytes=1909 normalized_sha256=4dd7e969ed6f99d77145f72fa6b87d7d7601c76490e56221f3bb90fa1dbb0d79 normalized_bytes=1448`.

- Decoded body: 1,909 bytes; raw SHA-256: `63cb0a462ce23574365c0b692aa09ea2f632f4b4df2b5f4186d8c004b57e3440`.
- Historical in-row pin: **raw match: yes**; **normalized match: no** (`4dd7e969ed6f99d77145f72fa6b87d7d7601c76490e56221f3bb90fa1dbb0d79`).

## Quote location and live scope

```sh
python3 /home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/rendered-text-v1.py locate /fast/scratch/kagi-r24/seats/RecapS008-2/s008-main.rst 'You can find the SOPS documentation on getsops.io'
```

Exit: 1 (the normalizer defines 1 as not found: `corpus/rendered-text-v1.py:101-112`). Output: `RENDERED_TEXT_V1_LOCATE: count=0`.

Closest live sentence, 12 whitespace-delimited words, at `s008-main.rst:18`, under the `Documentation` heading (`s008-main.rst:15-16`):

> You can find the SOPS documentation on `getsops.io <https://getsops.io/>`_ under `"Docs" <https://getsops.io/docs/>`_.

**Scope/teaches: no** for the stated recipient, key-group, and data-key rotation mechanics. The README's summary only identifies supported file formats and encryption backends (`s008-main.rst:4-5`); the closest sentence above directs readers to the docs instead of describing those mechanics. Thus the existing `rejected` classification remains supported. The quoted span is not a literal normalized-text hit because the README expresses the link using reStructuredText markup.

## `main` revision cross-check

GitHub API command:

```sh
curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)' https://api.github.com/repos/getsops/sops/commits/main | python3 -c "import json,sys; d=json.load(sys.stdin); print(d['sha']); print(d['commit']['committer']['date']); print(d['commit']['message'].splitlines()[0])"
```

Exit: 0. API returned commit **`453e7e6ab01b1340dca9f9025fd8430229320f97`** (40 hex; committer date `2026-10-20T04:33:58Z`).

Fetched and digested that revision's README:

```sh
curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)' -o /fast/scratch/kagi-r24/seats/RecapS008-2/s008-453e7e6.rst -w '%{url_effective} %{http_code}\n' https://raw.githubusercontent.com/getsops/sops/453e7e6ab01b1340dca9f9025fd8430229320f97/README.rst
python3 /home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/rendered-text-v1.py digest /fast/scratch/kagi-r24/seats/RecapS008-2/s008-453e7e6.rst
```

Both commands exited 0; fetch output was `https://raw.githubusercontent.com/getsops/sops/453e7e6ab01b1340dca9f9025fd8430229320f97/README.rst 200`. The pinned-commit body has the same 1,909-byte raw SHA-256 and 1,448-byte normalized SHA-256 as the `main` fetch, confirming the captured README bytes came from that revision at the time of observation.

Normalizer selftest also exercised: `python3 /home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/rendered-text-v1.py --selftest` — exit 0, `PASS (cases=16)`. No tools were installed or updated.
