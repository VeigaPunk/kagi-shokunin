# rows-draft.md — K48ScoutSources, round 48
# Two DRAFT census rows for corpus/SOURCES.md (the L1/scribe owns landing them; this seat
# does not edit corpus/). Schema: the 11-column contract of /home/vgpnk/Projects/shokunin/CORPUS.md
# §"SOURCES.md — where a shokunin learns" (id | source | kind | tier | scope | anchor | teaches |
# status | opened | recheck | used-by). No literal or escaped `|` inside any cell.
#
# Next free id check (frozen command from the seat brief):
#   grep -oE '^ {0,3}\|[[:space:]]*S[0-9]{3,}' corpus/SOURCES.md | grep -oE 'S[0-9]+' | sort | tail -1
#   -> S102
# S103 and S104 are unoccupied: `grep -nE '\|\s*S10[3-4]\s*\|' corpus/SOURCES.md` returns no row.
# (The census itself counts 102 rows at BASE: "SOURCES_CENSUS: CLEAN (rows=102 ...)".)
#
# Row shape modelled on S092/S093 (the two release-tag-page rows, same GitHub tag-page shape
# as the SOPS/age pages opened here) and on S033 (the SOPS release-identity feed row this
# round's release anchor extends).
#
# ---------------------------------------------------------------------------------------------
# DRAFT ROW S103 (11 columns; the line below is the literal row to append)
# ---------------------------------------------------------------------------------------------
# | S103 | SOPS release tag page v3.13.3, GitHub — https://github.com/getsops/sops/releases/tag/v3.13.3 | docs | A | SOPS release identity for the tag v3.13.3: the version whose official linux.amd64 binary the round-48 C1 counter pins, and whose release notes the trial's measured behavior is read against | Page title “Release v3.13.3 · getsops/sops · GitHub”; release datetime 2026-07-23T05:27:57Z in the page body; asset sops-v3.13.3.linux.amd64 named on the page; opened 2026-11-06 | The tag page names v3.13.3 as a signed release (23 Jul 2026) and publishes the sops-v3.13.3.linux.amd64 asset, so the pinned trial binary and the release identity are the same version. Quote: “<title>Release v3.13.3 · getsops/sops · GitHub</title>” (page title, byte offset 17271; raw-literal-v1). | mined | 2026-11-06 | 90d | corpus/knowledge/sops-age-key-rotation.md |
#
# | S104 | age release tag page v1.3.2, GitHub — https://github.com/FiloSottile/age/releases/tag/v1.3.2 | docs | A | age release identity for the tag v1.3.2: the version whose official linux-amd64 archive supplies the age-keygen binary the round-48 C1 counter pins, and the release notes that bound age's own input acceptance | Page title “Release age v1.3.2 · FiloSottile/age · GitHub”; release datetime 2026-08-29T17:55:36Z in the page body; asset age-v1.3.2-linux-amd64.tar.gz named on the page; opened 2026-11-06 | The tag page names v1.3.2 as a release (29 Aug 2026) whose notes state tightened input acceptance, so the age-keygen binary the trial pins belongs to that release. Quote: “<title>Release age v1.3.2 · FiloSottile/age · GitHub</title>” (page title, byte offset 17271; raw-literal-v1). | mined | 2026-11-06 | 90d | corpus/knowledge/sops-age-key-rotation.md |
#
# ---------------------------------------------------------------------------------------------
# FIELD-BY-FIELD JUSTIFICATION
# ---------------------------------------------------------------------------------------------
# S103
#   id          S103 — next free id after S102 (verified above).
#   source      Title — canonical URL, per contract ("source — title — canonical URL or DOI").
#                The em dash separates title from URL; no `|` inside the cell.
#   kind        docs — a GitHub release page is a documentation surface; S092/S093 (same
#                tag-page shape) use docs, S033 (Atom feed) uses code. Contract enum allows both.
#   tier        A — the project's own release page, primary for "which version is v3.13.3".
#   scope       Narrowed to the version identity of the tag the C1 counter pins, NOT sops
#                behaviour (S009-S011 carry behaviour). Tier is scoped to this scope.
#   anchor      Page title + the release datetime string in the body (2026-07-23T05:27:57Z,
#                one occurrence in the body) + the asset name + the open date. Never a bare
#                homepage; the tag page URL plus its title and datetime is the revision.
#   teaches     One grounded learner benefit: the tag page names v3.13.3 as a signed release
#                and publishes the exact linux.amd64 asset the counter pins. The ≤25-word
#                quote is the page title; its byte offset in the fetched body is 17271.
#   status      mined — cited by the entry named in used-by.
#   opened      2026-11-06 (the fetch date).
#   recheck     90d — matches S092/S093 (release tag pages) and S033; a tag page does not
#                change under a new release the way a "newest stable" feed does.
#   used-by     corpus/knowledge/sops-age-key-rotation.md — the entry the round-48 trial
#                measures; the entry's `source:` line must name S103 for the census's
#                SC_USEDBY_NOCITE / SC_ENTRY_CITE checks to pass.
#
# S104
#   kind        docs (same reasoning; the age release page is a GitHub release page).
#   tier        A — the age project's own release page.
#   scope       age release identity for the pinned tag only. It does NOT claim anything
#                about age's cryptography, key format, or the trial's SOPS semantics.
#   anchor      Page title + release datetime 2026-08-29T17:55:36Z (one occurrence) + asset
#                age-v1.3.2-linux-amd64.tar.gz + opened date.
#   teaches     The tag page names v1.3.2 as a release whose notes state tightened input
#                acceptance; the age-keygen binary the counter pins (sha256 0a0009db…) was
#                taken from that release's archive (see .ufo/waves/round-48/controls/
#                tool-install.txt). Quote: the page title, byte offset 17271.
#   recheck     90d; status mined; opened 2026-11-06; used-by as above.
#
# ---------------------------------------------------------------------------------------------
# LOCATED-QUOTE EVIDENCE (see located-quotes.txt for the exact commands and exit codes)
# ---------------------------------------------------------------------------------------------
# S103  python3 corpus/rendered-text-v1.py locate bodies/sops-v3.13.3.html \
#         'Release v3.13.3 · getsops/sops · GitHub'
#       -> RENDERED_TEXT_V1_LOCATE: count=1   exit 0
#       raw-literal form '<title>Release v3.13.3 · getsops/sops · GitHub</title>' is present
#       byte-for-byte at offset 17271 of the raw body (verified by slicing the bytes), which
#       is the raw-literal-v1 capture profile S092/S093 use for tag pages.
#       Auxiliary located strings on the same page: 'sops-v3.13.3.linux.amd64' (count=2),
#       'ghcr.io/getsops/sops:v3.13.3' (count=3).
# S104  python3 corpus/rendered-text-v1.py locate bodies/age-v1.3.2.html \
#         'Release age v1.3.2 · FiloSottile/age · GitHub'
#       -> RENDERED_TEXT_V1_LOCATE: count=1   exit 0
#       raw-literal form '<title>Release age v1.3.2 · FiloSottile/age · GitHub</title>' at
#       raw byte offset 17271.
#       Auxiliary: 'age v1.3.2 is a minor release with a wide range of fixes and hardening
#       improvements' (count=1) — the release-notes sentence on the same page.
#
# ---------------------------------------------------------------------------------------------
# SIBLING-SEAT OVERLAP (observed; the L1 must pick one row set, not both)
# A sibling seat in this wave, .ufo/waves/round-48/build/K48ExecSources/rows.md, has independently
# drafted rows for the same two urls under the same ids S103/S104. Its rows use kind=code (the
# S033 shape: "SOPS release identity: the v3.13.3 tag is the project's current stable release,
# pinned as the version an installed sops must report"), anchored on "Release page title and
# Latest badge, release line 'released this 23 Jul 05:27'"; mine use kind=docs (the S092/S093
# shape, the same GitHub tag-page URL), anchored on the release datetime string and the asset
# name, with the raw <title>…</title> quote at byte offset 17271. Only ONE S103/S104 pair can
# land (the census rejects a duplicate id). The two are compatible in substance: both pin the
# release identity of the tag the C1 counter's binaries come from, and both quotes locate
# (mine measured count=1 for each; the sibling's release line "released this 23 Jul 05:27" and
# "released this 29 Aug 17:55" is present in the same bodies). This seat does not choose; it
# reports that the ids are contested and that a duplicate id would be a census SC_DUP finding.
#
# ID-COLLISION WARNING (measured; for the L1, not a blocker for this seat)
# ---------------------------------------------------------------------------------------------
# The staged merge package /home/vgpnk/Projects/shokuknow/merge/kagi/SOURCES.append.md
# (read-only, 172 rows, "Nothing was written into the lane repo") already assigns ids S103 and
# S104 to DIFFERENT sources (S103 = 国家标准全文公开系统 GB/T 17901.1-2020 catalogue record;
# S104 = 阿里云帮助文档 云效 code scanning). Its id space is stale — the report's own header says
# "lane registry currently holds 51 rows; first staged id is S052", while the live lane registry
# now holds 102 rows — and it already collides with 51 live lane ids (S052-S102, every one with
# a DIFFERENT url). Measured: merge rows 172, lane rows 102, same id AND same url = 0,
# same id with a different url = 51, merge-only ids = 121.
# Consequence for round 48: S103/S104 ARE the correct next free ids in the LIVE lane registry
# (the brief's frozen command returns S102), and the merge package is not the lane's registry.
# If the L1 prefers to leave the staged package's S103/S104 untouched, the alternatives are
# S105/S106 (the merge package also uses those, for the KeyHog README and CRYPTREC) or any id
# above the merge package's S223 ceiling. This seat does not decide; it reports the collision.
#
# ---------------------------------------------------------------------------------------------
# CAPTURE-ROW (corpus/source-fetches.tsv) SHAPE THE L1/SCRIBE MUST ALSO LAND
# ---------------------------------------------------------------------------------------------
# The census (corpus/sources-census.sh) requires every registry row to have either an in-row
# `Fetch sha256:` pin or a corpus/source-fetches.tsv provenance row; a row id later than S016
# cannot certify itself with a bare in-row pin (SC_INROW "inrow-pin-not-historical"), so a
# capture row is REQUIRED for S103/S104. The capture row's 16 columns and the identity digest
# are computed here so the scribe does not have to derive them:
#
#   identity digest = sha256("<id>\t<status>\t<url>\n")
#     S103 -> db9eea5d4dfa82c068f46570a6285fa7b345fb30dd2924e576dba9f9a601a8e2
#     S104 -> da9d408cfc2d97263bcf07b8b3ff430c5ecdd1cf5db56a9e5857e3f3835f023c
#   (verified against the frozen formula on an existing row: S092's capture column 3 equals
#    sha256("S092\tmined\thttps://github.com/hashicorp/vault/releases/tag/v2.2.1\n"))
#
#   S103<TAB>mined<TAB>db9eea5d4dfa82c068f46570a6285fa7b345fb30dd2924e576dba9f9a601a8e2<TAB>
#   https://github.com/getsops/sops/releases/tag/v3.13.3<TAB>
#   https://github.com/getsops/sops/releases/tag/v3.13.3<TAB>200<TAB>curl-fsSL-compressed-v1<TAB>
#   2026-11-06<TAB>decoded-http-body-volatile-v1<TAB>
#   52d588dc1d68733699af82dd37bac3ce0bb5539dddf2a39fbfea5fb1e3b15026<TAB>177580<TAB>-<TAB>
#   <title>Release v3.13.3 · getsops/sops · GitHub</title><TAB>raw-literal-v1<TAB>-<TAB>
#   tag-page-title-byte-offset-17271
#
#   S104<TAB>mined<TAB>da9d408cfc2d97263bcf07b8b3ff430c5ecdd1cf5db56a9e5857e3f3835f023c<TAB>
#   https://github.com/FiloSottile/age/releases/tag/v1.3.2<TAB>
#   https://github.com/FiloSottile/age/releases/tag/v1.3.2<TAB>200<TAB>curl-fsSL-compressed-v1<TAB>
#   2026-11-06<TAB>decoded-http-body-volatile-v1<TAB>
#   3c0ebda1384bf1f70c8daf47d18d864541bfa062c1a0fc11fc2f677f4ae79a9b<TAB>154312<TAB>-<TAB>
#   <title>Release age v1.3.2 · FiloSottile/age · GitHub</title><TAB>raw-literal-v1<TAB>-<TAB>
#   tag-page-title-byte-offset-17271
#
# Notes for the scribe, all measured here:
#  - column 9 representation: use decoded-http-body-volatile-v1 (the S092/S093 choice for a
#    GitHub tag page). The census accepts decoded-http-body-v1 or -volatile-v1.
#  - column 14 normalization: raw-literal-v1, because the quote is a literal <title>…</title>
#    byte string; column 15 must then be "-" (the census rejects a normalized digest when the
#    normalization is raw-literal-v1).
#  - column 13 quote word count: 6 (S103) and 7 (S104) — both ≤25, as the census requires.
#  - column 16 location must be ≥8 characters: "tag-page-title-byte-offset-17271" qualifies.
#  - The live digest of a GitHub tag page is not stable across fetches; if the capture body is
#    committed from this fetch, the capture row's digest/bytes MUST be this fetch's values
#    (52d588dc…/177580 and 3c0ebda1…/154312), otherwise the census SC_FETCH digest check
#    fails. This is why the S092/S093 profile is "volatile".
#  - corpus/quote-bodies.tsv: adding S103/S104 there is optional for the census but is what the
#    located-quote gate (corpus/quote-locate.py) checks. If the L1 adds them, the manifest
#    needs body_path + offset + quote, and the body bytes must satisfy the capture row's
#    sha256/byte count. The natural committed bodies are the ones this seat saved under
#    .ufo/waves/round-48/build/K48ScoutSources/bodies/ (public pages).
#
# ---------------------------------------------------------------------------------------------
# CENSUS / GATE CONSEQUENCES THE LANDING MUST SATISFY (all measured, not assumed)
# ---------------------------------------------------------------------------------------------
# 1. SC_USEDBY_NOCITE / SC_ENTRY_CITE: corpus/knowledge/sops-age-key-rotation.md currently
#    carries ONE `source:` line naming S009; S010; S011. The census's src_field() reads only
#    that first `source:` line, and SC_ENTRY_HEADER fails a file with more than one
#    column-1 `source:` line, so S103/S104 must be APPENDED to that same line (as
#    "S103 (...), S104 (...)"), not added as a second `source:` line.
# 2. SC_MINED_UNUSED: both rows are mined, so used-by may not be "—" or "-".
# 3. SC_CREDENTIAL: the credential-shaped regex is scanned over SOURCES.md and every sourced
#    entry. Neither draft row contains credential-shaped text.
# 4. The fleet census (scripts/sources-census.sh) raises W04 "duplicate url across scopes"
#    only for the SAME url in two scopes. S103's and S104's urls are new; S033's feed url
#    (github.com/getsops/sops/releases.atom) is a different url from S103's tag page, so no
#    W04 is introduced. (The BASE census already prints 19 W04 lines for other ids; the count
#    must not grow.)
# 5. corpus/release-clocks.tsv: an on-release registry row MUST have exactly one clock row
#    (release-clock.py reports UNBOUND otherwise). S103/S104 are drafted with recheck=90d, so
#    they need no clock row. If the L1 prefers on-release, a clock row is required and the
#    age tag page is not a feed surface — this seat did not open one.
# 6. C2's frozen key K02 (`python3 -I -B corpus/quote-locate.py`) is a MISMATCH at BASE:
#    stated "QUOTE_LOCATE: CLEAN located=5 rows=5", executed "QUOTE_LOCATE: CLEAN
#    located=8 rows=8" (measured here, exit 0). The manifest corpus/quote-bodies.tsv holds 8
#    rows. If the L1 adds S103/S104 to that manifest, the executed count becomes 10 rows and
#    the stated reading in SCORECARD.md §Capabilities must be re-measured — landing the rows
#    and fixing K02's stated reading are coupled. This seat did not edit SCORECARD.md.
