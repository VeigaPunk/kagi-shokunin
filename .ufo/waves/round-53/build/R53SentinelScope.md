# R53SentinelScope — secret-hygiene and scope sweep of round-53 committed bytes

Seat: R53SentinelScope (leaf, no dispatch). Lane: `/home/vgpnk/Projects/shokunin/kagi-shokunin`.
BASE `c1953d4afc19a5a336a58685c00ab5260bcfea1c` → CANDIDATE `36d0a86a7539890eb079d893c9a58e37e84d953d`.
Scratch: `/fast/scratch/hyaku/kagi-r53/R53SentinelScope` (the candidate tree was extracted there with
`git archive 36d0a86 | tar -x -C <scratch>/cand`; 7958 files, 176 MB; removed after the sweep, the
seat scratch now holds only `changed.txt` and `live-age.atom`, 44 KB). Read-only throughout; no
mutation of the lane, the fleet, or any host path. No token, key, password, cookie or vault field
value is reproduced in this file — matches are reported as shape/offset only.

Surface: 38 paths from
`git diff --name-only c1953d4a 36d0a86` (25 lane files + 13 control-fixture copies under
`.ufo/waves/round-53/controls/fixtures/ref/c1/`).

## Verdict

No secret, key, password, wrapping token, cookie or session header is present in the round's
committed bytes. Two provenance defects (one field value, one out-of-lane evidence dependency)
and one pre-existing adjacency defect are reported; none is a disclosure.

## Findings

### N1 — low — misattributed `<updated>` field for the age v1.3.2 feed entry

Sites (both this round's added bytes):

- `corpus/SOURCES.md:118` (S111 row, evidence cell): "Entry titled age v1.3.2, tag link
  /releases/tag/v1.3.2, **updated 2026-08-29T17:55:50Z**".
- `corpus/lessons/round-53.md` §Gate (S111 bullet): "the entry's `<updated>` is
  **2026-08-29T17:55:50Z**, the same release day the S104 tag page shows."

Committed evidence disagrees. In the committed capture
`.ufo/waves/round-53/capture/S111.body`:

- entry `age v1.3.2` has `<updated>2026-08-29T18:12:38Z</updated>` (S111.body:10) and
  `<title>age v1.3.2</title>` (S111.body:12);
- entry `age v1.3.1` has `<updated>2026-08-29T17:55:50Z</updated>` (S111.body:23).

So the cited value belongs to the sibling v1.3.1 entry, not to the entry the row names. (The
release *page* time is `datetime="2026-08-29T17:55:36Z"` per the live tag page, so S104's
"released this 29 Aug 17:55" is correct; only the S111 feed-field value is wrong.)

Exploit/abuse path: a reader auditing S111 against its own committed body finds a field value that
does not exist for the named entry; the row's evidence cell cannot be reproduced field-for-field.
No security consequence — the load-bearing claims are unaffected (quote anchor byte-verified, gate
parses `1.3.2`, verdict `not-fired` is right).

Impact: field-level provenance defect only; teaching ("newest stable = v1.3.2"), quote
(`<title>age v1.3.2</title>` at byte 725) and clock pin all stand.

Smallest remediation: in both sites state `18:12:38Z` as the v1.3.2 entry's `<updated>` and keep
`17:55` for the S104 release page. Cosmetic, one line each; no counter or ledger binding reads
these fields.

### N2 — info — committed evidence depends on an absolute path outside the lane

`corpus/lessons/round-53.md:53` (`## Assimilation`):
`grep -rilE 'releases\.atom|release clock|age-keygen|FiloSottile' /home/vgpnk/Projects/shokuknow/merge/kagi | wc -l` prints `0`.

Checked: the path exists, and I reproduced the `0`. It is the cross-lane staged merge package
(`MERGE-REPORT.md`: "Staged by corpus-expansion-1", 81 knowledge files, first staged id S052), not
the lane. This is the same path rounds 48, 49, 50, 51 and 52 used for `## Assimilation`
(`round-5{0,1,2}.md`, `round-4{8,9}.md`), so it is conventional, and the `0` is genuine for that
package. The lane's own `corpus/` does contain 26 files matching the same regex, which is expected
and does not contradict the claim.

Exploit/abuse path: none today; the sting is that a committed claim's only support is a directory
outside the lane that the lane does not control — if the staging tree is pruned, the claim becomes
unverifiable and silently true-looking.

Impact: verifiability, not correctness.

Smallest remediation: name the tree's state in the sentence (e.g. "the staged merge package as of
its last staging, 2026-10-24"), so the claim is bound to a snapshot a reader can date.

### N3 — info — pre-existing (BASE, not this round) evidence command points at a missing worktree

`corpus/SOURCES.md:140` contains a search command over
`/home/vgpnk/Projects/shokunin/.tower/worktrees/kaika/fleet-ledger/.ufo/...`. `test -e` says that
path does not exist. `git blame -L 140,140` attributes the line to `064d4b6` (not this round), so it
is out of this round's byte surface; recorded only because the seat asked for host paths outside the
lane and because a missing evidence path is the same failure class as N2.

Smallest remediation: none this round (read-only for this seat); route to the lane owner as a
standing evidence-hygiene item.

### N4 — none — S111.body carries public release metadata only

`.ufo/waves/round-53/capture/S111.body` (40379 B, sha256
`32517112c2ecb63ce97dfbbdf9c47569678738fda984da524b2cd38129d8f21d`):

- content is the GitHub Atom feed for `FiloSottile/age` releases: 10 `<entry>` elements, titles /
  `<updated>` / tag links / release-note prose only;
- 8 `age1…` strings are **recipient** (public) values from upstream release notes, plus one
  `AGE-SECRET-KEY-PQ-1...` documentation prefix placeholder with a literal `...` and no key body
  (`&lt;code&gt;AGE-SECRET-KEY-PQ-1...&lt;/code&gt;`); no `AGE-SECRET-KEY-1…` identity string,
  no `-----BEGIN` block;
- 0 hits for `cookie|set-cookie|authorization|bearer|x-api-key|sessionid|csrf|login|oauth|access_token`;
- all outbound references are `https://` (github.com only, no query strings);
- authenticity: a plain GET of `https://github.com/FiloSottile/age/releases.atom` returned HTTP 200,
  40379 B, and is **byte-identical** to the committed body (same sha256) — the capture is a real
  fetch, not a constructed body. This is one of the few legible answers to the round's named ceiling
  ("a hand-forged receipt ... scores; the live leg is the non-author check"): the feed leg checks out.

### N5 — none — `op://` markers only; no resolvable reference path added

`SKILL.md` is the only changed file containing `op://`: 16 markers at BASE and 16 at candidate
(unchanged), all either the bare scheme (`op://`, 9) or `op://…` with an ellipsis and no path
segment (7). No `op://<vault>/<item>/<field>` triple is committed, and no new `op://` text was added
this round. Nothing resembling a vault item name was written into the round's bytes.

### N6 — none — no cookie/session/auth-header material in any changed file

Pattern `set-cookie|cookie:|session(id|token)|authorization:|bearer <tokenish>|x-api-key|csrf|_gh_sess|logged-in`
over all 38 changed paths → 3 hits, all code prose, none a credential:

- `corpus/release-clock.py:155` — the string list `"session", "session_id", "sessionid", "token"` in
  `path_carries_secret()`'s `secret_routes` (a URL-path heuristic);
- `SKILL.md:86` — prose about a companion `client.py` sending an `Authorization: Basic` header;
- `.ufo/waves/round-53/controls/fixtures/ref/c1/corpus/release-clock.py:155` — the fixture copy of
  the same line.

### N7 — none — counters honour the scratch contract

- `plans/round-53-c1.sh:46` `SCR=${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r53/c1.$$`, `:48`
  `trap 'rm -rf -- "$SCR"' EXIT`;
- `plans/round-53-c2.sh:38`/`:40` — same shape;
- `plans/round-53-controls.sh:13` `SCR="${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r53"`, `:15`
  `W=$(mktemp -d "$SCR/controls.XXXXXX") || exit 2`, `:16` `trap 'rm -rf -- "$W"' EXIT`.
- Literal `/tmp` in the round's plans and plan document: **0** (`plans/round-53.md`,
  `round-53-c1.sh`, `round-53-c2.sh`, `round-53-controls.sh`). `TMPDIR` is never needed because no
  step writes a temp file outside `$SCR` (`git archive` streams to `tar`, `mktemp` is scoped).
- The `:-` form means an empty `HYAKU_SCRATCH` falls back to the default, so `$SCR`/`$W` can never
  be empty or `/` when passed to `rm -rf`; the traps are single-quoted with the variable expanded at
  exit, so the same value that was created is the one removed.

### N8 — none — quote-body anchors all verify (including the new S111 row)

`corpus/quote-bodies.tsv` column 3 is a **byte offset**, not a line number (header:
`id  body_path  offset  quote`). Checked every row by slicing the named body at the offset:
9/9 rows match their quote exactly, including `corpus/quote-bodies.tsv:10` →
`.ufo/waves/round-53/capture/S111.body` offset 725 → `<title>age v1.3.2</title>`.
(The file has 338 text lines; offset 725 is the intended byte position. `first_true_offset == 725`.)

### Other checks that came back clean

- `observe-r53.json` (31 observations; keys `clock,http_status,id,located,observed_at,parsed_version,sha256,url,verdict`):
  no query strings, no credentials in any URL, all `https://`, hosts limited to
  `1password.com, curl.se, github.com, html.spec.whatwg.org, infra.spec.whatwg.org,
  www.1password.dev, www.python.org, www.unicode.org`. Verdicts `fired 13 / quote-located 11 /
  not-fired 7`. Its sha256 equals the digest the lesson cites
  (`f927b4318dee90ad3e2a8e2f899fcd2e37c43e833e7c3c3705aa5b5723d37c9a`), and the S104 row's
  `sha256` equals the committed S111.body digest.
- Timestamp sanity: local clock is `-0300`; `observe-r53.json` mtime `2026-11-07 00:48:16 -0300`
  = `03:48:16Z`, later than every `observed_at` (`03:02:31Z`–`03:02:40Z`) and than the candidate
  commit time `03:49:25Z`. No observation post-dates its own receipt.
- Host-path inventory over the 38 changed paths: `/home/vgpnk` appears on 4 lines only —
  `corpus/lessons/round-53.md:53` (N2), `corpus/SOURCES.md:140` and its fixture copy
  `controls/fixtures/ref/c1/corpus/SOURCES.md:140` (N3, pre-existing), and
  `controls/census-start.txt:20` (in-lane path, benign). No `/mnt`, `/media`, `/nix`, `~`-relative or
  Windows path is added. The only `/fast/...` references are the declared scratch default
  (`${HYAKU_SCRATCH:-/fast/scratch/hyaku}`) in the three plan scripts and the pre-existing
  convention line `SKILL.md:824`; `LOG.md`/`SCORECARD.md` matches were the substring
  `mid/fast/strong`, not paths.
- `.ufo/waves/round-53/expectation-migrations.json`: 9 rows (`R13-01 R21-02 R24-06 R31-02 R33-02
  R34-03 R36-02 R36-03 R38-01`), keys `id,command,old_expect,new_expect,reason`; 0 hits for the
  secret patterns. No path escapes the lane.
- High-entropy sweep (`[A-Za-z0-9+/_=-]{40,}`, Shannon > 4.2, 44+ chars) over all changed files:
  145 hits, all URLs, in-lane paths, commit-ish slugs or the public `age1…` recipient examples above;
  no opaque token-shaped string.

## Commands run (exact)

```
git -C <lane> diff --name-only c1953d4afc19a5a336a58685c00ab5260bcfea1c 36d0a86a7539890eb079d893c9a58e37e84d953d      -> 38 paths
git -C <lane> archive 36d0a86a75 | tar -x -C <scratch>/cand                                                             -> exit 0, 7958 files
python3 <parser over diff -U0>  # secret shapes hvs.|s.|age1|AGE-SECRET-KEY-|-----BEGIN|op://|ghp_|gho_|github_pat_|xox[baprs]-|AKIA|eyJ|sk-|ssh-…|BaoToken|VAULT_TOKEN|root_token|unseal_key|password[:=]
    -> 16 hits, all age1… public recipients in S111.body (8) + its fixture copy (8); exit 0
grep -acEi 'hvs\.|AGE-SECRET-KEY-[A-Z0-9]|-----BEGIN|op://|ghp_|AKIA|Bearer |xox[baprs]-|eyJ…'  (per file, 38 files) -> only AGE-SECRET-KEY (2, doc placeholder) + op:// (16, SKILL.md)
grep -acEi 'set-cookie|cookie:|session…|authorization:|bearer …|x-api-key|csrf|_gh_sess|logged-in'  (38 files) -> 3 hits (1 each: release-clock.py:155, SKILL.md:86, fixture copy:155)
grep -acE '/tmp/' <38 files>                                                                                            -> 0 hits (exit 1)
grep -acE '/(home|root|etc|var|usr|opt|srv|boot)/' <38 files>                                                           -> 10 files, 10 lines, inspected individually
grep -c 'HYAKU_SCRATCH\|trap .*EXIT\|mktemp\|/tmp' plans/round-53-{c1,c2,controls}.sh                                    -> see N7
python3 <quote-bodies validator: body[offset:offset+len(quote)] == quote>                                               -> 9/9 match, 0 bad
curl -sS --max-time 25 -o live-age.atom https://github.com/FiloSottile/age/releases.atom                                -> HTTP:200 bytes:40379, curl exit 0
sha256sum <committed S111.body> <live-age.atom>                                                                          -> both 32517112c2ecb63ce97dfbbdf9c47569678738fda984da524b2cd38129d8f21d, byte-identical
curl -sS --max-time 25 -o rel-v132.html https://github.com/FiloSottile/age/releases/tag/v1.3.2                           -> HTTP:200 bytes:153073, curl exit 0; datetime="2026-08-29T17:55:36Z"
grep -rilE 'releases\.atom|release clock|age-keygen|FiloSottile' /home/vgpnk/Projects/shokuknow/merge/kagi | wc -l      -> 0 (reproduces the lesson)
test -e /home/vgpnk/Projects/shokunin/.tower/worktrees/kaika/fleet-ledger                                                -> MISSING
sha256sum .ufo/waves/round-53/final/observe-r53.json                                                                     -> f927b4318dee…37c9a (matches lesson)
git blame -L 140,140 corpus/SOURCES.md                                                                                   -> 064d4b6 (pre-existing)
```

## Out of scope / not run

- `claim-ledger.sh verify` (not named by this item).
- No `op`, `the-janitor`, `bao`, `sops -d` or `age -d` invocation, no vault or account contact, no
  read of `~/.config/sops`, `~/.ssh` or any key file. The only network traffic was two plain GETs of
  public GitHub pages (recorded above).
- Nothing was installed or upgraded.

SEAT-STATUS: complete
