# K37ConnFeeds — sibling-overlap scan (round 37, wave build, read-only)

Question: does any sibling lane already register or claim the three release-feed surfaces that
round 37 supersedes (hashicorp/vault releases.atom, openbao/openbao releases.atom, python.org
downloads feed.rss) or the candidate ids S089/S090/S091?

Scope: read-only greps over the 20 sibling lane repos (`/home/vgpnk/Projects/shokunin/*-shokunin`,
minus kagi). No writes to any lane, git, or jj state. Scratch: `/fast/scratch/hyaku/kagi-r37/K37ConnFeeds`
(empty; removed before yield).

## Verdict

- Target surfaces: **0 sibling lanes** register or claim any of the three feed URLs in `corpus/`
  or in SOURCES.md, and **0 sibling lanes** carry a version anchor for vault v2.2.x, openbao v2.7.x, or
  python 3.15.x feed identity. No sibling overlaps the C2 predicate.
- S089/S090/S091: 16 sibling lanes use these ids for **unrelated** rows (lane-local numbering). The ids
  name no release feed in any sibling. No sibling cites kagi's S034/S035/S039/S089–S091.
- Ownership of release-feed identity as a domain: **no sibling claims it.** Only kagi has
  `corpus/release-clock.py` and `corpus/release-clocks.tsv`; 0 sibling lanes ship a release-clock file.
- Adjacent (different surface, same mechanism): kaidoku, kama, mado, kengaku, kotoba, tsukuroi (table
  below). Classified ADJACENT, not OVERLAP.
- Ownership-adjacent code reuse: chousa (transplant proposal for the release-clock.py validated-address
  contract), kake (review of urlsplit/S111 stripping at release-clock.py:176–306), souji (census
  classification of kagi release-clock.py as OVERLAP/complementary). These review kagi's code; none claims
  the release-feed domain.

CONNECTOR OVERLAP lanes hit on the three target surfaces or on S089–S091 as release-feed identity:
**0**. (Definition used: a SOURCES.md row or corpus file in a sibling that names one of the three feed URLs,
or a version anchor for it, or a row that uses S089–S091 as a release-feed identity.)

## Commands (exact) and measured output

Setup and positive control (kagi itself must hit, or the greps are blind):

    cd /home/vgpnk/Projects/shokunin
    grep -rl -F -- 'hashicorp/vault/releases.atom' kagi-shokunin/corpus kagi-shokunin/knowledge
    -> kagi-shokunin/corpus/SOURCES.md, corpus/lessons/round-25.md, corpus/lessons/round-36-verifier-spotcheck.md,
       corpus/lessons/round-36.md, corpus/lessons/round-37.md, corpus/release-clocks.tsv, corpus/source-fetches.tsv
    (7 files: positive control passes. Note: `knowledge/` does not exist in any lane, including kagi.)

Per-URL corpus count, all 20 siblings (sibling loop, `grep -rl -F` over `$d/corpus` and `$d/knowledge`):

    for d in *-shokunin (minus kagi); for u in hashicorp/vault/releases.atom openbao/openbao/releases.atom python.org/downloads/feed.rss;
      grep -rl -F -- "$u" "$d/corpus" "$d/knowledge" | wc -l
    -> 0 for all 20 lanes, all 3 URLs (60 of 60 cells zero).

Corpus layout check: every sibling has `corpus/`; none has `knowledge/` (`corpus=y knowledge=n` for all 21 repos).

Whole-tree exact-URL count (all files, `.git` and `node_modules` excluded):

    https://github.com/hashicorp/vault/releases.atom      : 0 files
    https://github.com/openbao/openbao/releases.atom      : 0 files
    https://www.python.org/downloads/feed.rss             : 2 files (both kake .ufo wave evidence)

Corpus-only exact-URL count (`$d/corpus` only): 0 / 0 / 0 across all siblings.

Substring count (`releases.atom` or `feed.rss`, any feed), whole sibling tree, file counts per lane:

    kaidoku 61, kake 10, kama 19, kotoba 35, mado 7, mori 9, tameshi 1, tsukuroi 2; the other 12 lanes 0.
    213 matching lines in total. Spot-checked: Ghidra, sasquatch, squashfs-tools, GoReSym, omacom/omarchy,
    anomalyco/opencode, example.com fixtures; python.org only in kake .ufo wave bodies.

SOURCES.md feed-URL rows in siblings (`grep -nE 'releases\.atom|feed\.rss' $d/corpus/SOURCES.md`):

    kaidoku  L35  S029  Ghidra upstream Go version range; "releases feed https://github.com/NationalSecurityAgency/ghidra/releases.atom"  (Ghidra, not a target surface)
    kotoba   L64  S051  opencode release compare; "releases.atom:27" cited as a locator inside the anchor (not a feed registration)
    No sibling SOURCES.md has a row for vault, openbao, or python.org feed.rss.

S089/S090/S091 ids, `grep -nE '^\| *S(089|090|091) *\|' $d/corpus/SOURCES.md`:

    16 lanes: chousa, kaidoku, kake, kama, kasegi, kengaku (S090–S091 only), kotoba, kotodama, kumitate,
    mado, mori, revenger, souji, tabi, tameshi, tsukuroi.
    Every hit is a different subject (e.g. chousa S089 AVerImaTeC; kake S089 RFC 3986; kama S089 git(1);
    mado S089 omarchy walker; tsukuroi S089 pacman(8)). None names a release feed.

Version anchors for the target feeds, `grep -rnE 'v2\.2\.[0-9]|v2\.7\.[0-9]|Python 3\.15\.[0-9]' --include=SOURCES.md $d/corpus`:
    Only Python-language and Python-3.15.x documentation rows (kaidoku S266/S267/S287/S292/S293; chousa S063;
    kake S100). None is a feed-identity anchor. No `v2.2.1`, `v2.7.2`, or `Python 3.15.2`-as-feed row exists in any
    sibling. Vault and openbao version anchors: 0 in any sibling SOURCES.md.

Release-clock ownership:

    find $d -iname 'release-clock*' -o -iname 'release_clock*' -o -iname '*release-feed*'  (excl .git, .ufo, node_modules)
    -> no files in any sibling (kagi only has corpus/release-clock.py).
    grep -rIl -F 'release identity' $d/corpus -> kaidoku 3, kama 3, kengaku 3, kumitate 1, mado 1 (all non-feed subjects)
    grep -rIl -F 'release-clock.py' --exclude-dir=.ufo $SIB -> souji 3 (census files only)
    grep -rIl -F 'release-clock.py' --exclude-dir=.git $d/.ufo -> chousa 3, kake 12, kama 6, kengaku 2, kotodama 3,
       kumitate 2, mado 2, revenger 2, souji 3, tabi 2, tameshi 6, tsukuroi 5 (wave artifacts; only chousa, kake, souji sampled)

## Per-lane table

Columns: vault / openbao / python.org feed.rss = count of corpus/ files with the exact URL (all 0).
"Whole tree" = files anywhere in the lane with the feed substring (`releases.atom` or `feed.rss`).
Claim class: ADJACENT = a registry row or claim about release identity of a different surface;
OVERLAP = same surface (none found).

| lane | vault | openbao | python feed | whole-tree substring files | S089–S091 in SOURCES | release-identity or feed claim | class |
|---|---|---|---|---|---|---|---|
| audio | 0 | 0 | 0 | 0 | none | none | — |
| chousa | 0 | 0 | 0 | 0 | yes (AVerImaTeC, etc.) | release-clock code-pattern transplant proposal (.ufo round-30) | code-reuse, not feed |
| game-dev-2d | 0 | 0 | 0 | 0 | none | none | — |
| game-dev-3d | 0 | 0 | 0 | 0 | none | none | — |
| kaidoku | 0 | 0 | 0 | 61 | yes (cargo-auditable, rea-agents, uv) | S029 Ghidra releases.atom; S139 squashfs release identity via api.github.com releases; S041 WABT release identity | ADJACENT (different surfaces) |
| kake | 0 | 0 | 0 (corpus) / 2 (.ufo body) | 10 | yes (RFC 3986, WHATWG, UAX15) | python.org feed.rss in round-35 security-txt census HTML body only (not a registry row) | ADJACENT at most (wave body) |
| kama | 0 | 0 | 0 | 19 | yes (git docs) | S482 llama.cpp release b11889 via gh api; "release identity" rows | ADJACENT (different surface) |
| kasegi | 0 | 0 | 0 | 0 | yes (ISO, AISI) | none | — |
| kengaku | 0 | 0 | 0 | 0 | S090–S091 only | S100 "release identity" of Terminal-Bench task tree (not a feed) | term overlap only |
| kotoba | 0 | 0 | 0 | 35 | yes (Claude/Codex/VS Code docs) | S051 opencode release compare; "releases.atom:27" is a locator in the anchor | ADJACENT (text only) |
| kotodama | 0 | 0 | 0 | 0 | yes (Goldin-Meadow etc.) | none | — |
| kumitate | 0 | 0 | 0 | 0 | yes (oh-my-pi, Node docs) | "release identity" in README/knowledge (omp release, not feed) | term overlap only |
| lore | 0 | 0 | 0 | 0 | none | none | — |
| mado | 0 | 0 | 0 | 7 | yes (walker, host logs) | S037 XDPH upstream release identity (pinned version, not feed) | ADJACENT (different surface) |
| mori | 0 | 0 | 0 | 9 | yes (Linux v7.2 sources) | none in corpus | — |
| revenger | 0 | 0 | 0 | 0 | yes (Ghidra Book, PBA) | none | — |
| souji | 0 | 0 | 0 | 0 | yes (git docs) | census classifies kagi release-clock.py as OVERLAP/complementary (code, not domain) | code review only |
| tabi | 0 | 0 | 0 | 0 | yes (DevTools, Playwright) | none | — |
| tameshi | 0 | 0 | 0 | 1 | yes (Stryker, sysexits, gitrevisions) | none | — |
| tsukuroi | 0 | 0 | 0 | 2 | yes (pacman(8), paccache) | pacman/mkinitcpio upstream release behavior rows (not feed identity) | term overlap only |

Lanes hit on the three target surfaces: 0 of 20. Lanes with any ADJACENT registry-level claim: 4
(kaidoku, kama, mado, kotoba-text-only). Lanes with a code-level or census-level reference to kagi's
release-clock.py: 4 (chousa, kake, souji, plus the .ufo-only references listed above).

## Ownership question (answer)

No sibling claims release-feed identity as a domain. The closest to a domain claim is kaidoku: it owns
the release identity of its upstream tools (Ghidra, squashfs-tools, WABT, GoReSym) and registers
upstream release feeds in its registry (S029, S139). That is ADJACENT: the mechanism is the same
(feed/release-identity row), the surfaces differ, and no kaidoku row names vault, openbao, or python.org.
kama's release-identity rows (llama.cpp via gh api) are the same class. Neither claims the three
C2 surfaces; neither has a version anchor for them; neither uses S089–S091 for those surfaces.

Only kagi owns a release-clock implementation (`corpus/release-clock.py` plus `corpus/release-clocks.tsv`).
Siblings reference that script as code (chousa: validated-address contract to transplant; kake:
urlsplit/S111 conflict review; souji: census OVERLAP/complementary classification). That is code adjacency
for kagi's own tool, not a competing claim on the feed domain.

## Id hazard (not an ownership claim)

S089–S091 are used for unrelated rows in 16 sibling lanes. That is lane-local numbering: no sibling's
S089–S091 names a release feed, so the round-37 ids do not collide with a sibling's claim on the same
surface. The hazard already noted in kagi's lesson (kaidoku absent-defect register S090/S091) is the
same class; it matters only if a row is moved across lanes, and the id-collision guard covers that.

## Limits (honest)

- Read-only greps only. No sibling file was opened in full except the rows quoted above.
- Substring "releases.atom"/"feed.rss" counts include wave artifacts that quote other feeds; I
  did not read all 213 matching lines, only the sample reported.
- The `.ufo` release-clock mentions are counted, not read individually (only chousa, kake, souji sampled).
- No install was performed. No tools were added. No pacman use. No writes outside the seat path.

CONNECTOR OVERLAP: DONE 0
