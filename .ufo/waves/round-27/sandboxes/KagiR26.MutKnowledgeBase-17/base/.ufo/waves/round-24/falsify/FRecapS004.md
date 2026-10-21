# FRecapS004 — bounded C2 falsification

- Frozen revision: `c5ef9e92201b6c36396301f12b23740565bf86a0`; original BASE: `4f94b52a3cdfaa289d779bd8a2afcd0b1fcd9105`.
- Axes: operability (isolated execution), freshness (source/capture reproduction), calibration (pin/category/row identity consistency).
- Bounds: S004 only; one public GET on 2026-10-21; named evidence and the plan-named normalizer. No gate/harness, host-private reads, production fixes, or C1/C3 admission claim.
- Result: **PASS for the exercised S004 checks; no C2/S004 counterexample found.** Severity: none observed. Historical 2026-10-19 capture reproducibility remains **UNKNOWN**, not disproved.

## Observed source and metadata

- Registered/reopened URL: https://www.1password.dev/service-accounts/security ; final URL identical, HTTP 200, curl exit 0.
- `corpus/SOURCES.md:10`: mined; opened 2026-10-19; historical pin `19bcf13eacd212b54db578ed7b1fdaa7341756ab73a6bd4f61d4b0012c7d2d60`.
- `corpus/source-fetches.tsv:57`: one S004 capture dated 2026-10-21; `decoded-http-body-volatile-v1`, `rendered-text-v1`, 1,221,922 decoded bytes. Its raw/normalized hashes exactly equal the freshly fetched values below.
- `corpus/inrow-pins.tsv:10`: same historical pin and capture date; `non-reproducing` is correct because that pin equals neither the stored raw hash nor the stored normalized hash. The fresh body also matches neither historical pin domain.
- `.ufo/waves/round-24/build/RecapS004.md:5-10` agrees with both metadata rows and today's byte/hash/quote observations, including 8,654 normalized bytes. This is direct recapture reproduction, not merely agreement between metadata files.
- Both source quotes occur once under the stated headings: “you choose the vaults it can access and its level of access.” under Access control; “You can rotate or revoke service account tokens.” under Token rotation and revocation.
- Interpretation [INFERENCE, high confidence]: separate vault-permission and token-lifecycle controls are supported by these two source sections; no cross-product or stronger revocation guarantee is established.
- No undocumented representation is promoted to current in the scoped evidence: `SOURCES.md:95-97,118-123`, `source-fetches.tsv:17-23,37-43`, and `inrow-pins.tsv:1-6` explicitly bound old pins as historical, undocumented observations and disallow drift conclusions. The row's “current page” wording is explicitly dated 2026-10-19.

## Executed commands and receipts

All subprocesses used `env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r24-recovery/FRecapS004-9/home`; HOME was newly created for this seat. Commands below omit this repeated prefix. Repository cwd was `/fast/scratch/kagi-r24-recovery/FRecapS004-9/repo`; body path `../S004.body` is inside this seat's sandbox.

1. `mkdir -p /fast/scratch/kagi-r24-recovery/FRecapS004-9/home`; `git clone --no-hardlinks /home/vgpnk/Projects/shokunin/kagi-shokunin /fast/scratch/kagi-r24-recovery/FRecapS004-9/repo`; `git -C /fast/scratch/kagi-r24-recovery/FRecapS004-9/repo -c core.hooksPath=/dev/null checkout --detach c5ef9e92201b6c36396301f12b23740565bf86a0`; `git -C /fast/scratch/kagi-r24-recovery/FRecapS004-9/repo rev-parse HEAD`: all exited 0; rev-parse stdout was `c5ef9e92201b6c36396301f12b23740565bf86a0`.
2. `curl -fsSL --compressed --connect-timeout 15 --max-time 45 -A 'kagi-shokunin-round23/1.0 (documentation verification)' -o /fast/scratch/kagi-r24-recovery/FRecapS004-9/S004.body -w '%{url_effective} %{http_code}\n' 'https://www.1password.dev/service-accounts/security'`: exit 0; stdout `https://www.1password.dev/service-accounts/security 200`.
3. `python3 -B corpus/rendered-text-v1.py digest ../S004.body`: exit 0; stdout:
```text
RENDERED_TEXT_V1: raw_sha256=beb67f2d0b8b4e77108766f134fb9bf21943331d9ab4d9bdbe083f655336b055 bytes=1221922 normalized_sha256=ed6f87eb0ff199bba950554fe7cffae41a0f8b52e50b1571a7425f1c6e309c4a normalized_bytes=8654
```
4. `python3 -B corpus/rendered-text-v1.py locate ../S004.body 'you choose the vaults it can access and its level of access.'`: exit 0; stdout `RENDERED_TEXT_V1_LOCATE: count=1`.
5. `python3 -B corpus/rendered-text-v1.py locate ../S004.body 'You can rotate or revoke service account tokens.'`: exit 0; stdout `RENDERED_TEXT_V1_LOCATE: count=1`.
6. `printf 'S004\tmined\thttps://www.1password.dev/service-accounts/security\n' | sha256sum` (both processes separately env-isolated): exit 0; stdout `536d0643594fd99b6bf066914a0df4e6874e546812818eda4315b639b8fb9138  -`, matching capture row identity.
7. `python3 -IB -c` with the following code: exit 0; stderr empty. It reused the committed v1 normalizer, not an alternative digest representation:
```python
import pathlib, re, runpy
v1 = runpy.run_path("corpus/rendered-text-v1.py")
s = v1["SCRIPT_STYLE_RE"].sub(" ", pathlib.Path("../S004.body").read_text(encoding="utf-8"))
heading = ""
quotes = ("you choose the vaults it can access and its level of access.", "You can rotate or revoke service account tokens.")
for part in re.split(r"(?is)(<h[1-6]\b[^>]*>.*?</h[1-6]\s*>)", s):
    text = v1["normalize_text"](part)
    if re.match(r"(?is)<h[1-6]\b", part):
        heading = text
    for quote in quotes:
        if quote in text:
            pos = text.index(quote)
            print("HEADING:", heading)
            print("CONTEXT:", text[max(0, pos-100):pos+len(quote)+100])
```
Stdout (heading labels retain the page's leading U+200B):
```text
HEADING: ​ Access control
CONTEXT: When creating a service account, you choose the vaults it can access and its level of access. The service account only returns information from vaults it can access. You can also give service a
HEADING: ​ Token rotation and revocation
CONTEXT: You can rotate or revoke service account tokens. You might want to revoke or rotate a service account token if a service account token became compro
```

## Limits and falsifier

- High confidence for the saved response, metadata consistency, and quote locations; no universal stability or semantic-drift claim follows from one response. The original 2026-10-19 bytes/transform are not established by the named committed evidence. Current equality with the 2026-10-21 capture does not explain the older pin or prove it false.
- Falsifiers sought: wrong category for stored digests; mismatched source identity/date; absent/mislocated quotes; or an undocumented historical hash asserted current. None was observed within this scope.
- `read xd://lsp` returned `No such tool`; no server was available and no semantic-LSP proof is claimed. Static `normalize_text`/`normalize_bytes` and CLI paths were read at `corpus/rendered-text-v1.py:61-79,95-117,175-186`.
- No tool installs/updates. Only this report was written in the lane; experiment artifacts remain in the uniquely named sandbox.
