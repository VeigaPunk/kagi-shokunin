# FRecapS001 — C2 S001 live-source check

## Result

- **S001 does not falsify C2 on the observed 2026-10-21 capture.** The live quote remains present; the committed capture metadata and the `non-reproducing` pin classification match an independent fetch. Severity: no S001 defect found. The historical pin's representation and reproducibility remain unknown.
- Bounds: isolated clone checked out at frozen revision `c5ef9e92201b6c36396301f12b23740565bf86a0`; one registry row and its 2026-10-21 live URL fetch only. This does not establish historical page bytes or the correctness of the full S001–S016 census.

## Observations

- Frozen `corpus/SOURCES.md:7` identifies **Load secrets into scripts**, `https://www.1password.dev/cli/secrets-scripts`, scope “1Password CLI process-lifetime Environment-variable delivery,” and quote “provisioned for the duration of the process.” Its historical `Fetch sha256` is `9f9d7283c2659d23c9ede72d96a31690533678b28437b2b22f73b2b73370c439`.
- Reopened the registered URL in the isolated checkout using `env -i PATH=/usr/bin:/bin HOME=<sandbox>/home curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)' 'https://www.1password.dev/cli/secrets-scripts' -o <sandbox>/S001.body -w '%{url_effective} %{http_code}\n'`. Exit 0; stdout: `https://www.1password.dev/cli/secrets-scripts 200`.
- Frozen `corpus/rendered-text-v1.py digest <sandbox>/S001.body` exited 0 and returned `raw_sha256=e72ab5f3f85e238bc109a1737161eec8425a016f003b7c84be09990d62cf4e0b bytes=1228087 normalized_sha256=a8be89d90b8c673914b539a7aa9d12d3c63f9c9283865ba08ddb6f2d049ec580 normalized_bytes=7116`. `sha256sum` independently returned the same raw digest. `locate <sandbox>/S001.body 'provisioned for the duration of the process.'` exited 0: `RENDERED_TEXT_V1_LOCATE: count=1`.
- The sentence in the fetched page says: “1Password CLI runs the application or script in a subprocess with the environment variables stored in your 1Password Environment provisioned for the duration of the process.” It supports the row's process-lifetime scope at fetch time.
- `corpus/source-fetches.tsv:54` matches the independent response URL/status, 2026-10-21 date, fetch profile, decoded-body byte count, raw digest, `rendered-text-v1` normalized digest, and quote anchor. `corpus/inrow-pins.tsv:7` retains the historical hash and labels it `non-reproducing`; neither current digest equals that pin. Thus the current capture metadata is consistent and the classification agrees with the declared raw/normalized comparison.

## Interpretation and limits

- The older pin is explicitly documented in `corpus/source-fetches.tsv:39-43` and `corpus/inrow-pins.tsv:1-6` as a historical observation with undocumented representation. Its mismatch against today's raw and normalized forms does **not** show the original capture was false, identify its representation, or prove page drift. No original S001 body/representation was available to reproduce historically.
- The current capture is not an undocumented representation presented as current: the TSV names the decoded HTTP body representation and `rendered-text-v1` normalizer. The static `read` URL view served alternate Markdown; it was only a quote cross-check, not used for the curl digest or represented as that capture.
- `xd://lsp` is unavailable (`No such tool`); this Markdown registry row has no code definitions/callers. Text search only located the row; the quote verification is from the reopened page and fetched body.
- No checks of the broader census/selftests were run; no tools were installed or updated.