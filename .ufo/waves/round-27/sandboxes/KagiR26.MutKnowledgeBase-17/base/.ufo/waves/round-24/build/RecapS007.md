# S007 live recapture

Date: 2026-10-21. Row: `corpus/SOURCES.md:13` contains a legacy historical in-row `Fetch sha256:` pin. S007 is also recorded in the 2026-10-21 census capture (`corpus/source-fetches.tsv:60`). The declared profile is `curl-fsSL-compressed-v1` (`corpus/source-fetches.tsv:12-16`), whose decoded-body convention removes Content-Encoding with curl.

## Fetch and digest

Command:

```sh
curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)' -o /tmp/kagi-r24-RecapS007-2/s007.body -w '%{url_effective} %{http_code}\n' 'https://www.1password.dev/brokered-access'
```

Exit code: 0. Output: `https://www.1password.dev/brokered-access 200` (final URL; HTTP 200).

Command: `python3 /home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/rendered-text-v1.py digest /tmp/kagi-r24-RecapS007-2/s007.body` — exit 0 (`corpus/rendered-text-v1.py:39-44`).

```text
RENDERED_TEXT_V1: raw_sha256=67f690e21116a3644be8cff57058293150b8b03fc305ffa15dc3af63fa43c312 bytes=1199447 normalized_sha256=f3861c172c370dd10ef8a9289857b0b59c5b07a9d16f2f7cf25aeb02738cc6e9 normalized_bytes=6049
```

The decoded HTTP body is 1,199,447 bytes. Historical row pin `e4aef238bb5c93080bc0e1cc2156d0f8d19c9291dbbee60193bd42485686f818`: raw match **no**; normalized match **no**. The registry warns that original in-row Fetch hashes have undocumented representation and a changed raw hash alone is not proof of semantic drift (`corpus/SOURCES.md:87-89`).

The independent recapture matches the census row’s final URL, HTTP status, raw digest, byte count, and normalized digest; the census row marks its representation `decoded-http-body-volatile-v1` (`corpus/source-fetches.tsv:60`). It does not reproduce the older in-row pin.

## Quote locations

Counts are the exact row quote strings; `locate` uses exact substring matching on normalized text (`corpus/rendered-text-v1.py:101-116`). Heading context is from the captured page's nearest preceding actual HTML heading; tab labels are noted separately.

- Quote `only remain accessible for the duration of the workflow`: command `python3 /home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/rendered-text-v1.py locate /tmp/kagi-r24-RecapS007-2/s007.body 'only remain accessible for the duration of the workflow'` — exit 0, count=1. Nearest heading: H1 `Set up 1Password Credential Broker to allow your team to access secrets in their workflows (public preview)`.
- Quote `All configured claims must match`: command `python3 /home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/rendered-text-v1.py locate /tmp/kagi-r24-RecapS007-2/s007.body 'All configured claims must match'` — exit 0, count=1. Nearest actual heading: H2 `Add an integration`; the text is within the `Custom Workflow (OIDC)` tab.
- Quote `the token value is your integration key`: command `python3 /home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/rendered-text-v1.py locate /tmp/kagi-r24-RecapS007-2/s007.body 'the token value is your integration key'` — exit 1, count=0. The closest live sentence (17 words), under H2 `Add an integration` in the `GitHub Actions` tab, is: “The token value is your integration key, which is required to decrypt secrets in your team’s workflows.” The only difference in the searched phrase is the live sentence’s initial capital `T`; the capitalization-adjusted query `The token value is your integration key` returned count=2, exit 0 (the sentence is also present in the Custom Workflow tab).

## Scope/teaches assessment

**Partly.** The live H1 still labels the guide “(public preview),” and the underlying identity-verification, configured-claim, workflow-duration, and integration-key mechanisms remain stated. The qualifier must not be read as uniform feature status: S019 explicitly supersedes S007’s uniform-status/eligibility reading, not these mechanisms (`corpus/SOURCES.md:25,81-86`). Exact live sentences include: “When a team member runs a workflow, 1Password validates the identity of the workload using an OIDC token.” “Secrets are only accessible after a workload has been verified, and only remain accessible for the duration of the workflow.” “All configured claims must match to verify the workload’s identity.” The integration-key sentence is quoted above. Thus the page continues to ground the mechanisms, but its guide-level preview label alone does not establish each workflow feature’s status.