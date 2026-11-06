# K48ScoutSources — round 48 seat report (frontier sources for C1)

Seat: K48ScoutSources (scout, leaf member — no subagent dispatch).
Lane: /home/vgpnk/Projects/shokunin/kagi-shokunin, branch master.
BASE: 76da518fcc3029e738648bd6fd4ba5571df01c1c.
Date: 2026-11-06 (all fetches 20:20–20:22 UTC).

Write scope touched: only `.ufo/waves/round-48/build/K48ScoutSources/` (this file's sibling
directory) and the scratch tree under `$HYAKU_SCRATCH/kagi-r48/K48ScoutSources/`. Nothing in
`corpus/`, `plans/`, `SCORECARD.md`, `LOG.md` or any sibling repo was edited. No git mutation
of any kind (the only git calls were `git init -q` inside my own scratch tree and
`git rev-parse --show-toplevel` to assert its top level, plus read-only `rev-parse`/`archive`
style reads of the lane). No tool was installed or upgraded by this seat: `sops` 3.13.3 and
`age-keygen` 1.3.2 were already present at the pinned sha256 (L1 receipt
`.ufo/waves/round-48/controls/tool-install.txt`), and pacman is paused host-wide, so no channel
of RULES.md was entered.

Deliverables in `.ufo/waves/round-48/build/K48ScoutSources/`:
`fetch-log.tsv`, `located-quotes.txt`, `rows-draft.md`, `assimilation-considerthese.md`,
`bodies/` (the five public pages + the two supplementary asset listings).

---

## 1. Five fetches (public reads only, no form posts)

Command per URL:
`curl -sSL --compressed -A 'Mozilla/5.0' -o <out> -w '%{http_code}' <url>`;
sha256 and byte count taken over the saved decoded body.

| UTC | http | bytes | sha256 | url |
|---|---|---|---|---|
| 2026-11-06T20:20:01Z | 200 | 29301 | `a840727ea1a8faa05e547f59766f608cbff81b28a66d1507a614d18d25b50b76` | https://getsops.io/docs/usage/identities/age/ |
| 2026-11-06T20:20:03Z | 200 | 36366 | `fed6b2e145246ebcd2de4d8133945a8cb744331a20f5ef509980b77ef112192e` | https://getsops.io/docs/usage/identities/key-groups/ |
| 2026-11-06T20:20:06Z | 200 | 33153 | `d0ab8b201f1a6d5f5751e1f261f904822492c530bdcdc5a4db9a8e178c2e180c` | https://getsops.io/docs/usage/key-management/ |
| 2026-11-06T20:20:06Z | 200 | 177580 | `52d588dc1d68733699af82dd37bac3ce0bb5539dddf2a39fbfea5fb1e3b15026` | https://github.com/getsops/sops/releases/tag/v3.13.3 |
| 2026-11-06T20:20:08Z | 200 | 154312 | `3c0ebda1384bf1f70c8daf47d18d864541bfa062c1a0fc11fc2f677f4ae79a9b` | https://github.com/FiloSottile/age/releases/tag/v1.3.2 |

Supplementary (same clock minute, recorded separately in `fetch-log.tsv`):
`https://github.com/getsops/sops/releases/expanded_assets/v3.13.3` → 200, 88705 bytes,
`6a432824014da8cd9a764b52707b0edda1a7896c3caf21bf3598aaec1709edfa`;
`https://github.com/FiloSottile/age/releases/expanded_assets/v1.3.2` → 200, 76869 bytes,
`35b8ed1e90e05199e316500c823e9c3a6e9142f789cc54f297b0f9afbe3dfcb4`.

**The three getsops.io bodies reproduce the committed capture digests byte-for-byte.** Compared
against `corpus/source-fetches.tsv` rows S009/S010/S011 (raw sha256 column 10, byte count
column 11) and against `corpus/inrow-pins.tsv` (verdict `reproduces-raw`):

| id | committed raw sha256 | live raw sha256 | committed bytes | live bytes | verdict |
|---|---|---|---|---|---|
| S009 | `a840727e…b50b76` | `a840727e…b50b76` | 29301 | 29301 | identical |
| S010 | `fed6b2e1…2192e` | `fed6b2e1…2192e` | 36366 | 36366 | identical |
| S011 | `d0ab8b20…e180c` | `d0ab8b20…e180c` | 33153 | 33153 | identical |

So the three documented pages have not changed since the 2026-10-21 capture, and the rows'
`Fetch sha256:` pins still reproduce raw.

---

## 2. S009 / S010 / S011 re-opened: located counts and footers

Locator: `python3 corpus/rendered-text-v1.py locate <body> '<quote>'` (exit 0 if count ≥ 1,
exit 1 if count = 0). Full transcript in `located-quotes.txt`.

| row | quote located | count | exit |
|---|---|---|---|
| S009 | `It is also possible to use updatekeys , when adding or removing age recipients.` (the capture-row spelling, `source-fetches.tsv` col 13) | 1 | 0 |
| S009 | `It is also possible to use \`updatekeys\`, when adding or removing age recipients.` (the registry-row spelling, backticks included) | 0 | 1 |
| S010 | `keys from multiple groups are required to decrypt a file.` | 1 | 0 |
| S010 | `By default, the threshold is set to the number of key groups` (the T5 sentence) | 1 | 0 |
| S011 | `Use updatekeys if you want to add a key without rotating the data key.` (capture spelling) | 1 | 0 |
| S011 | `Use updatekeys if you want to add a key without rotating the data key` (the brief's spelling) | 1 | 0 |
| S011 | `Use \`updatekeys\` if you want to add a key without rotating the data key.` (registry spelling) | 0 | 1 |

Reading: the S009 and S011 registry rows quote the sentence with markdown backticks; the served
page renders `<code>updatekeys</code>`, and rendered-text-v1 replaces the tag with one space, so
the backticked spelling does not locate while the capture spelling does. Both spellings refer
to the same live sentence — this is the same class of defect the round-24 recovery fixed for
S007/S032 (a quoted form that does not locate). The `quote-bodies.tsv` gate does not cover
S009–S011 (the manifest holds only S089–S093 and S100–S102), so nothing fails today; if the
L1 ever adds S009–S011 to that manifest, the capture spelling is the one that locates.

**"Last modified" footers — all three still name the anchor the rows claim:**

```
$ grep -o 'Last modified May 15, 2026[^)]*)' bodies/<each>.html | head -1
Last modified May 15, 2026: Add page descriptions. (9b7b84e)
```

- S009 body: `2026-05-15` present; `9b7b84e297bdabc9c78e571c1e6db43dcd69454a` present (2 occurrences).
- S010 body: same — `2026-05-15` and the full `9b7b84e…` commit present.
- S011 body: same — `2026-05-15` and the full `9b7b84e…` commit present.

No drift: the docs anchor `9b7b84e` of 2026-05-15 is unchanged on all three pages, so the
`on-release` clocks for S009–S011 are not fired by a docs change.

---

## 3. Two new release-identity sources and the draft census rows

Full draft, field-by-field justification, the required `source-fetches.tsv` capture rows with
their pre-computed identity digests, and the gate consequences: **`rows-draft.md`**.

Next free id (the brief's frozen command):
`grep -oE '^ {0,3}\|[[:space:]]*S[0-9]{3,}' corpus/SOURCES.md | grep -oE 'S[0-9]+' | sort | tail -1`
→ **S102**. S103 and S104 are unoccupied in the live registry (census at BASE:
`SOURCES_CENSUS: CLEAN (rows=102 …)`).

Draft rows (both parse as 11 columns: `NF=13`, no empty cell, no `|` inside a cell):

- **S103** — SOPS release tag page v3.13.3, GitHub —
  `https://github.com/getsops/sops/releases/tag/v3.13.3` | docs | A | release identity for the
  tag v3.13.3 (the version whose official `linux.amd64` binary the C1 counter pins) | anchor:
  page title, release datetime `2026-07-23T05:27:57Z`, asset `sops-v3.13.3.linux.amd64`,
  opened 2026-11-06 | teaches: the tag page names v3.13.3 as a signed release (23 Jul 2026) and
  publishes the pinned asset; quote `<title>Release v3.13.3 · getsops/sops · GitHub</title>`
  (page title, byte offset 17271) | mined | 2026-11-06 | 90d |
  corpus/knowledge/sops-age-key-rotation.md
- **S104** — age release tag page v1.3.2, GitHub —
  `https://github.com/FiloSottile/age/releases/tag/v1.3.2` | docs | A | release identity for
  the tag v1.3.2 (the version whose official `linux-amd64` archive supplies the pinned
  `age-keygen`) | anchor: page title, release datetime `2026-08-29T17:55:36Z`, asset
  `age-v1.3.2-linux-amd64.tar.gz`, opened 2026-11-06 | teaches: the tag page names v1.3.2 as a
  release whose notes state tightened input acceptance; quote
  `<title>Release age v1.3.2 · FiloSottile/age · GitHub</title>` (page title, byte offset 17271)
  | mined | 2026-11-06 | 90d | corpus/knowledge/sops-age-key-rotation.md

Located-quote evidence for both (rendered-text-v1, exit 0):
`Release v3.13.3 · getsops/sops · GitHub` → count=1;
`Release age v1.3.2 · FiloSottile/age · GitHub` → count=1;
auxiliary on the same pages: `sops-v3.13.3.linux.amd64` count=2, `ghcr.io/getsops/sops:v3.13.3`
count=3, `age v1.3.2 is a minor release with a wide range of fixes and hardening improvements`
count=1. Both raw `<title>…</title>` strings are present byte-for-byte at offset **17271** of
their bodies (sliced and compared), which is the raw-literal-v1 capture profile S092/S093 use
for GitHub tag pages.

**Dry-run of the landing (in scratch, never in the lane).** I copied the lane tree to scratch,
appended the two rows to `corpus/SOURCES.md`, added the two `corpus/source-fetches.tsv` capture
rows, appended S103/S104 to the entry's single `source:` line, and ran the lane's own gates:

```
$ bash corpus/sources-census.sh
SOURCES_CENSUS: CLEAN (rows=104 A=100 B=2 C=2 queued=1 mined=99 rejected=4 entries_sourced=15
legacy=21 captures=104 inrow=16 inrow_only=0 inrow_nonreproducing=12)          exit 0
$ bash /home/vgpnk/Projects/shokunin/scripts/sources-census.sh validate --root <fleetroot> <tree>
tree  W04  S019 … (19 lines, the same set as BASE)
tree  ok  …/corpus/SOURCES.md                                                  exit 0
$ python3 -I -B corpus/quote-locate.py
QUOTE_LOCATE: CLEAN located=10 rows=10                                         exit 0
```

(the last run had S103/S104 added to `corpus/quote-bodies.tsv` with committed bodies at
`.ufo/waves/round-48/capture/S103-sops-tag.body` and `…/S104-age-tag.body`.)
So: no new census finding, no new fleet W04, and the located-quote gate extends cleanly.

**Coupling the L1 must respect (measured).** C2's frozen key K02 is a BASE MISMATCH: SCORECARD's
`## Capabilities` states `QUOTE_LOCATE: CLEAN located=5 rows=5` while the command executes
`QUOTE_LOCATE: CLEAN located=8 rows=8` (measured here at BASE, exit 0; the manifest holds 8
rows). If S103/S104 are added to `corpus/quote-bodies.tsv`, the executed reading becomes
`located=10 rows=10`, so landing the rows and fixing K02's stated reading must be done
together. This seat did not edit SCORECARD.md.

**Sibling-seat overlap (observed).** The sibling seat `K48ExecSources`
(`.ufo/waves/round-48/build/K48ExecSources/rows.md`) has independently drafted S103/S104 for
the same two urls. Its rows use `kind=code` (the S033 shape, anchored on "Release page title and
Latest badge, release line 'released this 23 Jul 05:27'"); mine use `kind=docs` (the S092/S093
shape — the same GitHub tag-page URL — anchored on the release datetime string and the asset
name, with the raw `<title>…</title>` quote at byte offset 17271). Both quote forms locate in
the same bodies. Only one pair can land: a second S103 is a census `SC_DUP` finding. The L1
picks.

**ID-collision warning.** The staged merge package
`/home/vgpnk/Projects/shokuknow/merge/kagi/SOURCES.append.md` (read-only) already assigns
S103/S104 to different sources, and its id space is stale: merge rows 172, lane rows 102, same
id AND same url = 0, same id with a different url = 51 (S052–S102), merge-only ids = 121.
S103/S104 are nonetheless the correct next free ids in the LIVE lane registry; if the L1 wants
to leave the staged package alone, S105/S106 or anything above the package's S223 ceiling are
free in the live registry. The L1 decides; this seat only reports it.

---

## 4. considerthese/ and the merge report — one line each

- **considerthese/2026-10-26.md** (newest of eight daily files): **no SOPS/age or
  capability-table theme** — it is a HOLD-era lane-status reflection (round-28 close, the
  `corpus/release-clock.py` `STABLE_TITLE_RE` fail-open, "self-claims of totality are bounded
  by the fixtures"); its single `age` hit is the phrase "open-round age clock" (a round's age,
  not the age tool). Nothing there changes the round-48 source plan.
- **`/home/vgpnk/Projects/shokuknow/merge/kagi/MERGE-REPORT.md`**: **no SOPS/age or
  capability-table theme** — it is a staged corpus-expansion package (172 proposed SOURCES
  rows, 81 proposed knowledge entries; NIST SP 800-57/131A, Chinese GB/T 17901, secret-scanner
  validity tiers). Zero matches for `sops|age|key.rotation|shamir|updatekeys`; the one
  `capabilit` hit is the unrelated file title
  `corpus/knowledge/trufflehog-verification-capability-r42.md`; the only `SCORECARD` mention is
  an adopt-checklist instruction.

---

## 5. Cross-check against the pinned binaries (read-only)

```
$ ~/.local/bin/sops --version --disable-version-check      -> sops 3.13.3 (latest)
$ ~/.local/bin/age-keygen --version                         -> v1.3.2
$ sha256sum ~/.local/bin/sops ~/.local/bin/age-keygen
e5bec3346a873ae91d871550f3e698c1aad962aff462a080e40f25fde17fef6b  /home/vgpnk/.local/bin/sops
0a0009db842259d6717f7eeb30acb6b90d2a2eb924c6acd0a0db0ca1f1537899  /home/vgpnk/.local/bin/age-keygen
```

Both match `PIN_SOPS` / `PIN_AGEKEYGEN` in `plans/round-48-c1.sh` and the L1's
`tool-install.txt`; the reported versions match the two release identities the two drafted rows
would pin (sops v3.13.3, age v1.3.2). The age release page never mentions `age-keygen` by name
(`grep -c age-keygen` = 0) — the link from the release to the binary is the archive
`age-v1.3.2-linux-amd64.tar.gz` named on the expanded-assets listing, and the draft row is
scoped to the release identity, not to age's behaviour.

## 6. Remaining unknowns (not measured here)

- The C1 trial script `corpus/sops-age-trial.sh` does not exist at BASE (the counter reads
  `value=0 absent=1`, which is the BASE state, not a failure); whether the five tests
  discriminate under the real binaries is the executing seat's measurement, not this seat's.
- Whether the L1 lands S103/S104 at all, and with which ids, is the L1's call.
- The live digest of a GitHub tag page is volatile: a re-fetch will not reproduce
  `52d588dc…`/`3c0ebda1…`. If the L1 commits these bodies as capture bodies, the capture rows
  must carry these exact digests and byte counts, or SC_FETCH fails.
