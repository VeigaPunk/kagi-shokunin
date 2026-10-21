# Source01 — S001 re-open: calibration verdicts and freshness reconciliation

Axes: **C1 calibration** (feature-specific source/status/eligibility/product/path adjudication of S001-bound claims) and **C2 freshness** (stale revision stamp and pin reconciliation with exact historic evidence).
Scope: source S001 only, plus its feature-specific links for qualifiers. No registry edits, no entry edits, no account/vault/CLI execution.
Access: 2026-10-20 (HTTP `Date: Tue, 20 Oct 2026 21:34:42 GMT`; second header read 21:36:39 GMT).

## Read revision

- Base: `c2cab35bc92e57e39e5489bac3386db078345b3f` (frozen base).
- Working tree as read (uncommitted, not mine):
  - `corpus/SOURCES.md` — `+S017–S020` and a round-22 search-log erratum (`git diff` index `36e166f..58e9a3f`), observed 18:34 local.
  - `corpus/knowledge/onepassword-machine-credentials.md` — round-22 erratum appended (`git diff` index `d69e058..f441495`).
  - `corpus/lessons/round-22.md` exists (8,506 bytes, 18:37), so S017–S020 `used-by` paths resolve.
- S001 row itself is unchanged from `e1544c1` (pin still `9f9d7283…`, verified 18:39).
- Id space moved mid-lane: S021 (OpenBao re-pin, Source16) landed at 18:38. **Next free id is S022.**

## S001 source record (today's revision)

| field | value |
|---|---|
| URL | https://www.1password.dev/cli/secrets-scripts |
| Title | Load secrets into scripts |
| Accessed | 2026-10-20T21:34Z (`curl -sSL --compressed`, no query string, HTTP 200, `cf-cache-status: HIT`, `age: 11455`) |
| Anchor | §Use `op run` to pass environment variables from a 1Password Environment |
| Quote (7 words) | “provisioned for the duration of the process.” |
| Product | 1Password CLI (`op run`) with 1Password Environments |
| Path | `op run` loading variables from a 1Password Environment; the same page separately documents `op run` with secret references and `op --env-file` under different headings |
| Status | docs page; **no beta/preview label anywhere on the page** (the only “New!” string is the Credential Broker banner); no displayed version/date |
| Eligibility | §Requirements lists only: “Sign up for 1Password.” / “Install 1Password CLI.” / store secrets in the account. **No plan tier.** Environments adds desktop-app and admin-policy requirements on its own page, not here |
| Revision metadata | JSON-LD `dateModified` `2026-10-19T21:23:28.252Z` — present in the HTML, not displayed |
| Falsifier | A revision in which the anchored sentence no longer scopes provisioned variables to process duration, the anchor section is removed/renamed, or §Requirements gains a plan gate. Any of these reopens the teaching; the pin alone does not |

Feature-specific links opened for qualifiers (not registry rows): `/cli/reference/commands/run` and `/cli/secrets-environment-variables` (same duration scoping for the general `op run`/secret-reference path), `/environments` (desktop app + Owner/Administrator policy).

## C1 — adjudicated decisions for S001-bound claims

Scored on decisions, not rows authored: **4 accept, 7 reject**. Each control is failable from S001 (or the named feature link) alone.

| # | claim (source of claim) | verdict | reason |
|---|---|---|---|
| A1 | “`op run` runs the application/script in a subprocess with Environment variables provisioned for the duration of that process” (E1 item 1, first sentence) | **ACCEPT** | Exact anchored sentence present verbatim today and in the 2026-09-08 capture |
| A2 | “neither establishes that the Service Account token itself becomes short-lived or expires when the child process ends” (E1 §Does not establish) | **ACCEPT** | Correct absence statement: S001 has no token-lifetime text (grep: `token`/`lifetime`/`expire` only in the banner, the SA recommendation, and a personal-token shell-plugin sentence) |
| A3 | `op run` eligibility is the §Requirements set: 1Password signup + CLI install + secrets in the account | **ACCEPT** | Three-item list, no plan gate; reject any Business/EPM import into this path |
| A4 | The `op run --env-file` / secret-reference path also ends at process exit | **ACCEPT, different citation** | Supported by `/cli/reference/commands/run` — “secrets made available as environment variables only for the duration of the subprocess.” — and by `/cli/secrets-environment-variables`; **not** by S001's anchored sentence, which sits under the Environment heading |
| R1 | “`op run` requires 1Password Business / EPM Business” | **REJECT** | Eligibility imported from S019/S020 (Broker); S001 §Requirements has no plan |
| R2 | “`op run` makes the machine credential short-lived / the Service Account token expires with the subprocess” | **REJECT** | Round-21 rejected claim. S001 scopes the *delivered environment*; token controls are S004's separate subject |
| R3 | “S001 establishes the Service Account token's lifetime” | **REJECT** | Page only recommends Service Accounts and vault restriction; no lifetime statement |
| R4 | “S001 is undated / carries no revision metadata” | **REJECT as stated** | True only as “no *displayed* date”. The page carries JSON-LD `dateModified`; see C2 for why it is a build stamp, not a content revision |
| R5 | “S001's pin `9f9d7283…` still matches; the source is unchanged” | **REJECT** | Pin does not reproduce under any tested serialization (C2) |
| R6 | “The page content changed at 2026-10-19T21:23:28Z” | **REJECT (laundering)** | That stamp is shared sub-second by five unrelated pages and is a site build time, not a content revision |
| R7 | “The Environment path works with the CLI alone” (setup claim) | **REJECT** | `/environments` §Requirements: “Install and sign in to 1Password for Mac, Windows, or Linux.” and an Owner/Administrator must “turn the Environments policy on” |

Binding correction proposed for E1 item 1, second sentence (“…not the lifetime of the Service Account token… [S001, S004]”): S001 supports only “this sentence describes the delivered environment”; the token-lifetime negative is an absence inference. Best form: drop S001 from that bracket for the negative and cite S004 for token controls, or write “S001 says nothing about token lifetime.” Substance is not wrong; the bracket overreaches by one clause.
The round-22 erratum's sentence “Workflow-duration delivery is not expiry of a Service Account token” is correctly scoped to [S019, S020] but is still a scope inference, not a source statement; label it `[INFERENCE]` if the gate treats labels as evidence.

## C2 — freshness reconciliation with exact historic evidence

### Pin reproduction (2026-10-20, URL exactly as registered)

| derivation | digest | note |
|---|---|---|
| recorded in SOURCES.md S001 (2026-10-19) | `9f9d7283c2659d23c9ede72d96a31690533678b28437b2b22f73b2b73370c439` | not reproduced |
| decompressed HTML, `curl -sSL --compressed` | `24d1aecd2b5713e2decfae9151107421a261c4c998bfb0b74f8ada29856e7a84` (1,227,782 bytes; ETag `W/"i8hkm8rx5oqb8o"`) | stable across repeat/method/UA, `http`, non-`www`, trailing slash, query, `developer.1password.com` redirect |
| gzip wire bytes / brotli wire bytes | `7d05199d…` / `e4ef166d…` | encoding-dependent, unusable as a pin |
| tag-stripped text | `e7fa934fbf1d3150799dbb32696aec74a7b05c851396a89fedd2fc6df79dcd51` (7,369 chars) | not the pin |
| Mintlify Markdown (`.md`, also `Accept: text/markdown`) | `43b9a0c7cbfe76e17b76e003497e8303874731cf12c2d9b175e77fe81675e95a` (7,187 bytes) | stable across query string; contains no `_next/static` and no `dateModified` — content-only serialization |
| Markdown minus 4-line index block | `cee265ab49c837f39241a58209770ce1314089e7664f9222759d20121c46369d` | neither |

**Method control:** the same command reproduces two non-1Password rows exactly — S009 `a840727e…` and S010 `fed6b2e1…` match today's bytes. So the registry's working method is decompressed HTML, and the S001 mismatch is not a guess about method.

**Cross-source control:** all checked 1password.dev pins mismatch today — S002 `68017d4c…` → `9e00e86dafcf8058332a74dfff983bd242c5d62b62109ffb6d495fd35c5b1cea`; S003 `7f6d3b49…` → `0daffd88fb69359d0fe6947f6521c45f0a11224ec16edbdc72ad5a9dad44a451`; S004 `19bcf13e…` → `7e6f04088407b7ae388a4a27c33b6575c3819586aeac746910a96176f8924923`; S007 `e4aef238…` → `896c780b243ebd1659dea22d6e46a1d4b2b74639adfde7ed22d8b362fc3b4a9f`. S007's own page date is 2026-08-17 — if that stamp is a content date, as its divergence from the build cluster suggests, its content has not been edited since August — yet its bytes differ.

### Cause: build-coupled HTML

- `dateModified` is a **site build stamp**, not a page revision: it is `2026-10-19T21:23:27.8–28.3Z` across S001, S002, S003, S004, `/cli/get-started`, `/environments`, `/service-accounts`, `/cli/secret-references` — sub-second agreement across unrelated pages. S007, which carries an explicit page date, keeps `2026-08-17T22:36:47.823Z`, so the stamp can differ when a page supplies one.
- The build injects hashed assets: unique `_next/static/*.js|*.css` paths are **50 today vs 41 in the 2026-09-08 capture, overlap 2**. Any deploy therefore changes every page's HTML bytes without touching prose.
- Consequence: an HTML sha256 is a **build identifier**, not a source revision. Expect all 1password.dev HTML pins to fail at each deploy; do not read failure as content change, and do not re-pin silently.

### Semantic evidence and what stays unknown

- Wayback capture `20260908142005` (page stamp `2026-09-04T17:57:16.231Z`) contains the anchored sentence verbatim and the same Credential Broker banner — the teaching predates the current build and the banner is **not** new today.
- No Wayback capture exists for `2026-10-01…2026-10-20` (CDX returns `[]`; only one collapsed digest in Sep–Oct). The 2026-10-19 pre-build bytes are therefore unrecoverable, and any content diff across the 2026-09-04 → 2026-10-19T21:23 build is **UNKNOWN**. Record it as unknown; do not assert “no change” or “changed”.
- Everything checkable today is unchanged in substance: anchor verbatim, §Requirements unchanged, no status/eligibility label added, page still documents the same five loading methods.

### Reconciliation rule (no deletion, no laundering)

1. Keep the old pin as history; never replace it in place.
2. Record the new pin with **declared derivation, byte length, access timestamp, URL form** and the page's machine stamp *labelled as a build stamp*.
3. Record semantic diff as `UNKNOWN` unless a captured prior revision proves it.
4. Separate `STALE` (reproducible pin differs) from `UNREPRODUCIBLE` (no declared derivation matches); S001 is the second today, while S002/S003/S004/S007 are the first under the established method.

### Gate gap

`corpus/sources-census.sh` contains **zero** `sha256` references (`grep -c sha256` = 0); it enforces `recheck:`/`verified-at:` presence and the `used-by` handshake only. No tool recomputes SOURCES pins, so a stale or unreproducible pin is invisible to every gate. Minimum fix: a `--pins` mode that recomputes declared pins, emits `SC_PIN_STALE` / `SC_PIN_UNREPRODUCIBLE` (distinct), and never rewrites.

## Proposed superseding row (only if the integrator wants a live pin under S022)

Precedent exists in the working tree: S019/S020 use “supersedes S007/S006” without rewriting them. Same pattern, pin-only:

| S022 | Load secrets into scripts — https://www.1password.dev/cli/secrets-scripts | docs | A | 1Password CLI process-lifetime Environment-variable delivery — re-pin of S001 at the 2026-10-19T21:23:28Z site build | §Use `op run` to pass environment variables from a 1Password Environment; JSON-LD `dateModified` 2026-10-19T21:23:28.252Z (build stamp, not a content revision), accessed 2026-10-20T21:34Z | Process-lifetime delivery. Quote: “provisioned for the duration of the process.” Fetch sha256 `24d1aecd2b5713e2decfae9151107421a261c4c998bfb0b74f8ada29856e7a84` (decompressed HTML, `curl -sSL --compressed`, no query; 1227782 bytes; ETag `W/"i8hkm8rx5oqb8o"`). Supersedes S001's pin `9f9d7283c2659d23c9ede72d96a31690533678b28437b2b22f73b2b73370c439`, retained as historic; semantic diff across the build is UNKNOWN (no 2026-10-19 capture). | mined | 2026-10-20 | 90d | corpus/knowledge/onepassword-machine-credentials.md |

Optional stronger pin, if the registry accepts a second derivation: content serialization `curl -sSL --compressed <url>.md` = `43b9a0c7cbfe76e17b76e003497e8303874731cf12c2d9b175e77fe81675e95a`, 7,187 bytes, no build assets. Its stability across deploys is plausible but **unproven** — no historical `.md` capture exists.

## Limits and unknowns

- Edge cache: `cf-cache-status: HIT`, `age: 11455` (~3 h 11 m). The served revision may lag origin; all values are as served to this host at 21:34Z.
- No October Wayback capture; no pre-build 2026-10-19 bytes; the exact content diff is unknown.
- I did not execute `op`, touch any account/vault, or test runtime behavior; nothing here measures CLI behavior.
- `dateModified` semantics inferred from the sub-second cluster and S007's differing explicit date; it is recorded as a build stamp with that evidence, not as established Mintlify documentation.
- S001 is not claimed to be one of the “nine previously dropped stamps”; this lane supplies the reconciliation pattern and one verified instance, not that census.

## Checks the parent should run after integration

1. `bash corpus/sources-census.sh` — exit 0/1/2; confirm S022 (if added; S021 is Source16's OpenBao row) passes id shape and `used-by` cite, and that S017–S020 still resolve `corpus/lessons/round-22.md`.
2. Pin reproduction (today's build only): `curl -sSL --compressed https://www.1password.dev/cli/secrets-scripts | sha256sum` → `24d1aecd…`.
3. If `.md` pin adopted: `curl -sSL --compressed https://www.1password.dev/cli/secrets-scripts.md | sha256sum` → `43b9a0c7…`.
4. If a `--pins` mode lands: confirm it distinguishes `STALE` from `UNREPRODUCIBLE` and refuses to rewrite without `--repin`, and that S009/S010 still verify.

No packages installed, no upgrades, no account or credential operations; only HTTP GETs and one Wayback CDX query.

Report: .ufo/waves/round-22/build/Source01.md
