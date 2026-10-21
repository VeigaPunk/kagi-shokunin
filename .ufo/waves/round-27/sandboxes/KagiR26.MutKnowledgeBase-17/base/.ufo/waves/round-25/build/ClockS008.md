# ClockS008 — C3 per-row release clock for SOURCES row S008 (SOPS upstream README)

Row: `corpus/SOURCES.md` S008 — "SOPS upstream README — https://raw.githubusercontent.com/getsops/sops/main/README.rst",
kind=code, tier=C, teaches "SOPS recipient, key-group, and data-key rotation mechanics",
anchor "§Documentation; upstream `main` snapshot opened 2026-10-19", verdict REJECTED,
recheck=**on-release**. Anchored identity per `corpus/source-fetches.tsv:61`: commit
`453e7e6a` (40-hex `453e7e6ab01b1340dca9f9025fd8430229320f97`), decoded body sha256
`63cb0a462ce23574365c0b692aa09ea2f632f4b4df2b5f4186d8c004b57e3440`, 1909 bytes.

## Release identity decision: case (a) — versioned product with official release feed

SOPS is a versioned product (tags v3.x.y) whose official feed is the maintainer's GitHub
releases stream (`getsops/sops`). The row's page is a `main`-branch snapshot, so its
anchored version is a commit, not a tag; the governing clock is the release feed plus the
branch tip.

## Commands and evidence (sandbox /fast/scratch/kagi-r25/ClockS008, 2026-10-21)

All fetches: `curl -fsSL --compressed -A 'kagi-shokunin-round25/1.0 (documentation verification)'`.

1. Fresh page re-open:
   `curl -o fetch/readme-main.rst -w '%{http_code}' https://raw.githubusercontent.com/getsops/sops/main/README.rst`
   → **HTTP=200**, 1909 bytes, sha256
   **63cb0a462ce23574365c0b692aa09ea2f632f4b4df2b5f4186d8c004b57e3440** — byte-identical
   to the row's recorded fetch (`source-fetches.tsv:61`). Page unchanged.
2. Feed attempt (official REST): `https://api.github.com/repos/getsops/sops/releases/latest`
   → **HTTP 403**, `x-ratelimit-remaining: 0` (shared-IP unauthenticated limit; auth headers
   are out of bounds per context). Recorded as UNRUN via that endpoint; used the
   vendor-owned Atom mirror of the same feed instead.
3. Feed opened: `https://github.com/getsops/sops/releases.atom` → HTTP 200, sha256
   `47a224ad71435b7f5cae863bc96c01468bfed482636045fc307430983b072ff6`. First `<entry>`:
   title **v3.13.3**, `updated` **2026-07-23T05:29:11Z**, link
   `https://github.com/getsops/sops/releases/tag/v3.13.3`.
4. Git cross-check (shallow `git fetch --depth=600` of `getsops/sops` in sandbox):
   `git rev-parse main` → `453e7e6a…` = **anchored commit is the current tip** (anchor
   committed 2026-10-20T06:33:58+02:00, subject "Merge pull request #2326 …");
   `git merge-base --is-ancestor v3.13.3 main` → **yes** (47 commits on main after
   v3.13.3); `git log -n1 -- main -- README.rst` → README.rst last touched
   2026-05-15 ("Fix minimum Go version in contributor docs.").
5. Normalizer (copied, sha256 `7d6bfe8154898f8584e213bcf98936a0819ace75fd80f3dcc87bce1edd1dc7bf`,
   same bytes as lane copy):
   `python3 rendered-text-v1.py digest fetch/readme-main.rst` →
   `raw_sha256=63cb0a…e3440 bytes=1909 normalized_sha256=4dd7e969ed6f99d77145f72fa6b87d7d7601c76490e56221f3bb90fa1dbb0d79 normalized_bytes=1448` (exit 0).
   Quote checks: `grep -Fc 'You can find the SOPS documentation on'` → **1** (raw-literal-v1
   row quote locates verbatim, line 18); script `locate` with the full raw quote
   (containing RST `` `<https://getsops.io/>` ``) → count=0, because v1's tag rule
   `<[^>]+>` strips RST angle-bracket URLs — the row's declared raw-literal-v1 profile is
   the correct one; script `locate 'You can find the SOPS documentation on'` → count=1.

## Verdict: NOT-FIRED

- Latest release **v3.13.3** (2026-07-23) predates the anchored snapshot
  `main@453e7e6a` (2026-10-20); no release has been published past the anchored version.
- The anchored branch tip itself has not moved: `main` tip == anchor commit, and the page
  bytes are identical to the recorded fetch. Nothing the on-release clock watches has moved.

Does S008's teaches still hold? The row is REJECTED; the rejection stands. Fresh README
`grep -icE 'updatekeys|rotat|key group|recipient'` → **0 lines**; §Documentation (line 18)
still reads verbatim: "You can find the SOPS documentation on `getsops.io
<https://getsops.io/>`_ under `\"Docs\" <https://getsops.io/docs/>`_." — lifecycle
mechanics remain delegated to getsops.io; the flip condition ("an upstream README revision
that restores lifecycle mechanics") has not triggered.

## Proposed release-clocks.tsv line (tab-separated)

```
S008	release-feed	https://github.com/getsops/sops/releases.atom	getsops/sops main@453e7e6a (README sha256 63cb0a462ce23574)	v3.13.3	2026-10-21	not-fired
```

## SOURCES-row candidate for the feed

| S008-F | SOPS releases (GitHub Atom feed) — https://github.com/getsops/sops/releases.atom | release-feed | A | Official maintainer release stream for SOPS; governs on-release rechecks of upstream `main` snapshots cited by source rows | First `<entry>`: v3.13.3, published 2026-07-23, opened 2026-10-21 | Quote: "v3.13.3" (first `<entry><title>`, `updated` 2026-07-23T05:29:11Z, entry link `…/releases/tag/v3.13.3`). Fetch sha256: `47a224ad71435b7f5cae863bc96c01468bfed482636045fc307430983b072ff6`. | candidate | 2026-10-21 | on-release | — |

## Tooling

No installs; used host `curl`, `python3`, `git` (no pacman; paused per context).
api.github.com UNRUN this window: HTTP 403 rate-limited (`x-ratelimit-remaining: 0`);
official `releases.atom` + git tag object (`26e2f4784ca61353082c32dbd987c25eda086dc9`,
tagger Felix Fontein) independently confirm the v3.13.3 identity and date.
