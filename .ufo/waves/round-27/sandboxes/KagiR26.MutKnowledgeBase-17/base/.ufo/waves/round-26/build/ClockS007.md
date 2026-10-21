# ClockS007 — round 26 C1 freshness, SOURCES row S007

Seat: `KagiR26.ClockS007` (leaf scout, no subagents). Access: 2026-10-21T13:36:43Z.
Observed BASE: `1bf3eec48d3761580ffd375c88143232485ae814` (`git rev-parse HEAD` in
production, read-only; worktree carries only untracked `.ufo/waves/round-26/` and
`plans/round-26.md`). No tools installed. No production/registry writes. Supporting
artifacts: `.ufo/waves/round-26/sandboxes/ClockS007/{body.html,headers.txt,rendered-text-v1.BASE.py}`.

## Bounded result

**Unchanged — teaching holds; clock `quote-located` re-observes.** The single public
source (https://www.1password.dev/brokered-access) is byte-identical to the
round-25 capture. S007 is a 1Password Credential Broker row, not a Python row:
the Python3.15.1 / S027/S028 normalizer comparison does **not apply** to this seat
(no Python documentation was fetched). The round-25 receipt and its S007 line are
preserved as historical; nothing here supersedes them.

## Rows under clock (BASE)

- `corpus/SOURCES.md:13` S007 — teaches public-preview identity verification,
  configured-claim matching, workflow-duration access, integration-key handling;
  anchors: page title, introduction, §GitHub Actions, §Custom Workflow (OIDC);
  "current page has no displayed version/date". Reading partly superseded by S019
  (`SOURCES.md:25`, uniform-status) and S032 (`SOURCES.md:38`, lowercase quote).
- `corpus/release-clocks.tsv:4` — `S007 rendered-quote - - - - 2026-10-21 quote-located
  unversioned guide (www.1password.dev changelog 404; no public feed)`.
- `corpus/source-fetches.tsv:60` — HTTP 200, raw `67f690e2…3c312`, 1199447 B,
  `decoded-http-body-volatile-v1`, quote "only remain accessible for the duration of
  the workflow", rendered-text-v1 `f3861c17…cc6e9`.
- `corpus/inrow-pins.tsv:13` — in-row pin `e4aef238…` classified `non-reproducing`.

## Commands and observed output (sandbox cwd)

```
git -C <prod> show 1bf3eec4…:corpus/rendered-text-v1.py > rendered-text-v1.BASE.py
sha256sum → 7d6bfe81…dc7bf (identical to production working copy)

curl -fsSL --compressed -A 'kagi-shokunin-round26/1.0 (documentation verification)' \
  -D headers.txt -o body.html https://www.1password.dev/brokered-access
→ HTTP:200 bytes:166493 url:https://www.1password.dev/brokered-access  EXIT:0
sha256sum body.html → 67f690e21116a3644be8cff57058293150b8b03fc305ffa15dc3af63fa43c312 (1199447 B)
headers: date Wed, 21 Oct 2026 13:36:43 GMT; etag W/"z6d2q9klrgppcp"; age 46365;
  server Vercel; x-vercel-cache MISS; cache-control no-store…; text/html; charset=utf-8
JSON-LD in body: "dateModified":"2026-08-17T22:36:47.823Z" (sole value)

curl … https://www.1password.dev/changelog → HTTP:404  EXIT:0   (declared-clock note re-probed)

python3 rendered-text-v1.BASE.py --selftest → PASS (cases=22) EXIT:0
python3 rendered-text-v1.BASE.py digest body.html
→ raw_sha256=67f690e2…3c312 bytes=1199447
  normalized_sha256=f3861c172c370dd10ef8a9289857b0b59c5b07a9d16f2f7cf25aeb02738cc6e9 normalized_bytes=6049
```

Raw sha, size, and rendered digest all equal `source-fetches.tsv:60`. The in-row pin
`e4aef238…` still does not reproduce (unchanged `non-reproducing` state, not new drift).

## Quote locates (rendered-text-v1 `locate`, case-sensitive)

| quote (≤25 words) | anchor | count | exit |
|---|---|---|---|
| "only remain accessible for the duration of the workflow" (clock-bound) | introduction | 1 | 0 |
| "All configured claims must match" | §Custom Workflow (OIDC) | 1 | 0 |
| "The token value is your integration key" (S032 form) | both Add-an-integration paths | 2 | 0 |
| "the token value is your integration key" (S007 original lowercase) | — | 0 | 1 |
| "a supported integration in their 1Password Business account" (`S007-business`) | introduction | 1 | 0 |
| "Set up 1Password Credential Broker … their workflows (public preview)" (`S007-guide-title`) | title/nav | 3 | 0 |
| "public preview" | title/nav/intro | 7 | 0 |
| "public beta" | — | 0 | 1 |
| "OP_INTEGRATION_KEY" | §GitHub Actions | 1 | 0 |

## Teaching-by-teaching

1. Workflow-duration access — **holds** (clock-bound quote count 1).
2. Configured-claim matching — **holds**: "All configured claims must match to verify
   the workload's identity."
3. Public-preview label — **holds** at guide level only (count 7; "public beta" 0).
   The S019 limit stands: the guide label is not per-workflow status.
4. Integration key — **holds** in S032's case-correct form; S007's lowercase excerpt
   still fails (count 0 / exit 1), as recorded round 24.

## Counterexamples / calibration notes (actionable, no production edit made)

- **Paraphrase, not quote:** S007's teaching cell says "require a GitHub organization
  secret for the integration key"; the literal `organization secret` locates **0**.
  The page reads "follow the steps to add a new secret for your GitHub organization.
  . Set the secret name to OP_INTEGRATION_KEY". So the paraphrase is supported, but it
  must not be cited as a quote. `knowledge/onepassword-machine-credentials.md:25`
  ("stored as an organization secret") is the same paraphrase.
- **Scope boundary:** this is GitHub-only. The Custom Workflow path says instead
  "configure the key as a secret that can be retrieved at runtime". Any generalisation
  to "every Broker integration stores an org secret" would be a counterexample.
- **Clock limitation (docs-only):** no feed exists. The changelog returns 404, and the
  JSON-LD `dateModified` 2026-08-17 is page metadata, not a release version. The
  `quote-located` verdict tests only the one bound quote. It does not show the whole
  page is unchanged; the byte-identical raw sha shows that for this fetch alone.
  `age: 46365` with `x-vercel-cache: MISS` means the edge served HTML about 12.9 h old.
  So "unchanged" holds for what the CDN served at 13:36Z, not necessarily the origin.

## Remaining unknowns

- The custom-workflow sub-page (`brokered-access/custom-workflow`) was not opened;
  per-workflow release status stays unverified (unchanged from rounds 21–22).
- Nothing was checked against the Python 3.15.0 → 3.15.1 docs: that is out of scope
  for S007. That comparison belongs to the S027/S028 seats.
