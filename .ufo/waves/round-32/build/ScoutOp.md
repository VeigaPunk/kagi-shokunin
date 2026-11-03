# ScoutOp Findings Report: 1Password CLI 2.41.1 Release History Binding (S072)

- **Seat:** `ScoutOp`
- **Role:** `scout` (leaf, read-only web access, no subagents)
- **Wave / Round:** `kagi-r32-build` / Round 32
- **Host Date:** 2026-11-03
- **Lane Root:** `/home/vgpnk/Projects/shokunin/kagi-shokunin`
- **Target:** Open 1Password CLI release history for version 2.41.1 and bind it as lane sourced row `S072` (supporting C2 freshness).

---

## 1. Installed CLI Version

Command run:
```bash
op --version
```
- **Exit code:** `0`
- **Exact stdout:** `2.41.1`

---

## 2. Release History Fetch Receipt

- **Attempted URL 1 (primary):** `https://app-updates.agilebits.com/product_history/CLI2`
  - **Fetch command:** `curl -fsSL --max-time 30 -w "%{http_code} %{url_effective}\n" https://app-updates.agilebits.com/product_history/CLI2 -o /home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-32/build/src-open/S072-body.html`
  - **HTTP status:** `200`
  - **Effective URL:** `https://app-updates.agilebits.com/product_history/CLI2`
  - **Fetch date:** 2026-11-03
  - **Fallback URLs tried:** None required (primary URL succeeded immediately).
- **Body destination:** `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-32/build/src-open/S072-body.html`
- **Byte count:** `516927` bytes (`wc -c`)
- **Decoded body SHA256 (`fsha`):** `d1fc423ba0ec4119679d9f9631031fb30834fb4da13cd701a410057b256d8209`
- **Rendered-text-v1 normalized SHA256 (`fnsha`):** `75b1684edfce6c3dea2cfbd341e3e653595d87045ff0416bda2f98ee62a08a37`
- **Normalized byte count:** `142634` bytes (computed via `python3 corpus/rendered-text-v1.py digest`)

---

## 3. Entry Details for Version 2.41.1

- **Article element in HTML:** `<article id="v2410101">` (lines 812–1061)
- **Printed release date:** `2026-10-21`
- **Build number:** `#2410101`
- **Located quote stating 2.41.1 release/version (<=25 words):**
  > `"2.41.1 (build #2410101 ) – released 2026-10-21"`
  - **Word count:** 7 words (ASCII words / whitespace-delimited tokens)
  - **Location / Anchor:** `§"2.41.1 (build #2410101) – released 2026-10-21" entry heading` (HTML article lines 814–824)
  - **Verification:**
    ```bash
    python3 corpus/rendered-text-v1.py locate .ufo/waves/round-32/build/src-open/S072-body.html "2.41.1 (build #2410101 ) – released 2026-10-21"
    # Output: RENDERED_TEXT_V1_LOCATE: count=1
    # Exit code: 0
    ```
  - **Tag-stripping note:** In raw HTML lines 817–818:
    `&nbsp;(build <a href="#v2410101" title="2.41.1 - build #2410101">#2410101</a>)`
    The `<a>` tag boundary replaces with spaces during `rendered-text-v1` processing before whitespace normalization, leaving `#2410101 )` (space before the closing parenthesis).
- **Summary of 2.41.1 changes in entry:**
  - "This release updates Go and the CLI base image to pull in the latest security fixes, and `op read` help text includes an example of reading a file attachment."
  - Improvements: `op read` help text now includes an example of reading a file attachment (`{TW-1440}`).
  - Security: Updated CLI base image on linux/amd64 and linux/arm64 to latest hardened build (`{INFRASEC-1908, INFRASEC-1824}`); updated Go to 1.26.10 (`{INFRASEC-1824}`).

---

## 4. Search for `op run`, `--env-file`, and `dotenv` Handling in 2.41.x

A thorough scan of 2.41.x releases in the fetched history was performed:

1. **In 2.41.1 specifically (`<article id="v2410101">`, lines 812–1061):**
   - Command: `sed -n '812,1061p' src-open/S072-body.html | grep -iE 'op run|--env-file|dotenv'`
   - **Exit code:** `1`
   - **Result:** None found. Version 2.41.1 has no mentions of `op run`, `--env-file`, or dotenv handling.

2. **In 2.41.0 (`<article id="v2410001">`, lines 1064–1318, released 2026-10-12):**
   - Command: `sed -n '1064,1318p' src-open/S072-body.html | grep -iE 'op run|--env-file|dotenv'`
   - **Exit code:** `0`
   - **Located quotes for `op run`:**
     - "This release makes the `--environment` flag for `op run` generally available, so you can retrieve and use secrets from 1Password Environments in your scripts and programs."
     - "`op run` now supports the `--environment` flag to load secrets from 1Password Environments. {1461}"
     - "Reduced `op run --environment` network requests from 6 to 4. {DW-1414}"
   - **Matches for `--env-file` or `dotenv`:** None found in 2.41.0 (`grep -iE '\-\-env-file|dotenv'` on 2.41.0 lines exits `1`).

3. **In 2.41.0-beta.01 (`<article id="v2410001" class="beta">`, lines 1845–2070, released 2026-10-01):**
   - Mentions `op run --environment` identical to 2.41.0. No mention of `--env-file` or dotenv handling.

4. **Page-wide context on `--env-file` and `dotenv`:**
   - `--env-file` / `dotenv` appear only in earlier historical versions (2.7.0 `--env-file` flag renamed, 2.8.0 multiline fixes, 2.18.0 precedence fixes) or in later beta 2.43.0-beta.02 (line 773: output `--format` flag adds `dotenv` option for 1Password Environment secrets).

---

## 5. Registry Row Draft (`corpus/SOURCES.md`)

- **Draft file path:** `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-32/build/S072-row.md`
- **S072 Unused check:**
  ```bash
  grep -c '^| S072 ' /home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/SOURCES.md
  # Output: 0
  # Exit code: 1
  ```
- **Draft row (11 columns, NF=13):**
```markdown
| S072 | 1Password CLI Release Notes — https://app-updates.agilebits.com/product_history/CLI2 | docs | A | op CLI 2.41.1 release identity | entry heading §"2.41.1 (build #2410101) – released 2026-10-21" (build #2410101, article id v2410101), fetched 2026-11-03; in-round capture 2026-11-03 in corpus/source-fetches.tsv | 1Password CLI version 2.41.1 was released on 2026-10-21 under build #2410101 to update Go and the CLI base image for security fixes and include an op read attachment example in help text. | mined | 2026-11-03 | 180d | corpus/knowledge/op-ref-consumption.md |
```

---

## 6. Provenance Capture Row Draft (`corpus/source-fetches.tsv`)

- **Draft file path:** `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-32/build/S072-capture-row.tsv`
- **Schema verification:** 16 tab-separated columns matching S070/S071 shape.
- **Computed row identity digest (`frow`):**
  `printf 'S072\tmined\thttps://app-updates.agilebits.com/product_history/CLI2\n' | sha256sum`
  → `10793c3ff18817d3f1d745b1551901f36fda7a7eb830e0e511d33201f1bacc30`
- **Validation against `corpus/sources-census.sh` SC_FETCH rules:**
  - `fid`: `S072` (valid ID format)
  - `fstatus`: `mined` (valid enum)
  - `frow`: valid 64-hex matching `sha256(id\tstatus\turl\n)`
  - `furl` & `ffinal`: valid HTTPS URL
  - `fhttp`: `200`
  - `fprof`: `curl-fsSL-compressed-v1`
  - `ffet`: `2026-11-03`
  - `frep`: `decoded-http-body-volatile-v1`
  - `fsha`: 64-hex (`d1fc423ba0ec4119679d9f9631031fb30834fb4da13cd701a410057b256d8209`)
  - `fbytes`: `516927`
  - `frev`: `-`
  - `fquote`: `2.41.1 (build #2410101 ) – released 2026-10-21` (7 words <= 25 words)
  - `fnorm`: `rendered-text-v1`
  - `fnsha`: 64-hex (`75b1684edfce6c3dea2cfbd341e3e653595d87045ff0416bda2f98ee62a08a37`)
  - `floc`: `§"2.41.1 (build #2410101) – released 2026-10-21" entry heading` (length 62 >= 8)
  - Validation script output: `Findings count: 0` (clean pass).

- **Draft capture row content (tab-separated):**
```tsv
S072	mined	10793c3ff18817d3f1d745b1551901f36fda7a7eb830e0e511d33201f1bacc30	https://app-updates.agilebits.com/product_history/CLI2	https://app-updates.agilebits.com/product_history/CLI2	200	curl-fsSL-compressed-v1	2026-11-03	decoded-http-body-volatile-v1	d1fc423ba0ec4119679d9f9631031fb30834fb4da13cd701a410057b256d8209	516927	-	2.41.1 (build #2410101 ) – released 2026-10-21	rendered-text-v1	75b1684edfce6c3dea2cfbd341e3e653595d87045ff0416bda2f98ee62a08a37	§"2.41.1 (build #2410101) – released 2026-10-21" entry heading
```

---

## 7. Artifacts Written

1. `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-32/build/src-open/S072-body.html`
2. `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-32/build/S072-row.md`
3. `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-32/build/S072-capture-row.tsv`
4. `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-32/build/ScoutOp.md`

Scratch workspace `/fast/scratch/hyaku/kagi-r32/ScoutOp/` was initialized and cleaned.
No lane-tracked files or fleet-root files were modified.
