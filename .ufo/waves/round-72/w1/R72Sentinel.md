Author: R72Sentinel (sentinel)

# Round 72 — kagi — sentinel seat report

Scope: the round's new bytes (12 captures under `.ufo/waves/round-72/capture/`, the round-72
receipt, `corpus/clock-rearm.tsv`, `corpus/release-clocks.tsv`, `corpus/release-clock.py`,
`corpus/SOURCES.md`, `corpus/source-fetches.tsv`) and the frozen counters
`plans/round-72-c1.sh` / `plans/round-72-c2.sh` / `plans/round-72-controls.sh`.

Candidate `a947a42c52dc5b64cc9be1eef98207712fca7c42`; BASE `b2f3dd661abda0ebd09b3f8ffc3f64904606d4d9`.
All work ran from `/home/vgpnk/Projects/shokunin/kagi-shokunin`; scratch
`/fast/scratch/hyaku/kagi-r72/R72Sentinel` (removed on exit). No lane file outside
`.ufo/waves/round-72/w1/R72Sentinel/` was written; no mutating git/jj command was run in the lane
or the fleet repo.

Tools: `python3` 3.14 (stdlib only — `hashlib`, `re`, `json`, `subprocess`, `tarfile`, `glob`,
`urllib.parse`), `git` read-only (`show`, `archive`, `ls-files`, `status`, `rev-parse`), GNU `tar`,
GNU `coreutils` (`sha256sum`, `realpath`, `cmp`, `mktemp`). No tool was installed or upgraded this
seat, so no tooling authorization entry is owed.

---

## 1. Secret / credential scan of the round's new bytes

**Result: no credential material, no private material, no token-shaped string that is not already
committed at BASE. Counts only; no matched bytes are printed anywhere in this report or in the
cited receipts.**

Scanned: the 12 new captures, `.ufo/waves/round-72/final/observe-r72.json`,
`corpus/clock-rearm.tsv`, and the three frozen counters plus `plans/round-72.md`.

Needles (counts in `w1/R72Sentinel/evidence-secret-scan-counts.txt`): AWS access-key id, GitHub
PAT / classic token, Slack token, Google API key, Stripe key, PEM private-key armour, JWT,
`hvs.` / `s.` / `b.` / `r.` Vault-family token, bearer header, basic-auth URL, `op://` reference,
`~/.vault-token` / `/etc/vault.d` path, `~/.ssh` path, ≥60-char base64 blob, ≥32-hex string,
`password|secret|api_key|token|credential :=` assignment, `aws_secret_access_key`,
`Authorization:` header, `client_secret`.

Structural pass (no value emitted; only length, character-class, enclosing HTML class / JSON key /
tag, and entropy class): `w1/R72Sentinel/evidence-url-structure.txt`.

Findings by class, with the BASE precedent each matches:

| class | count | files | disposition |
|---|---|---|---|
| `searchOnlyApiKey` 32-hex in a vendor page's inline `algoliaConfig` JSON | 1 each in S013, S022, S023, S024 | public vendor docs search key, shipped in the page's own JS | **digest-identical to BASE** — round-47 `S013.body`/`S022.body`/`S023.body`/`S024.body` carry the same 1 occurrence each (hash-verified equal) |
| `b.`/`s.`-prefixed Vault-family token in an OpenBao docs code span (`class="token"`) | 2 each in S016, S021, S026 | vendor documentation example token in `class="token"` markup, `prism-code` | **digest-identical to BASE** — round-47 captures carry the same 2 each (hash-verified equal) |
| `password|token|credential :=` assignment | 20 in S024, 4 in S174 | S024 = Vault API docs example `X-Vault-Token` header value in prose; S174 = Vault release-feed item text (`auth/token/...` endpoint names in a changelog) | **digest-identical to BASE** for S024 (20 in both, hash-verified equal); S174 is a GitHub release Atom feed whose text is the upstream changelog |
| 64-hex digest | 1 each in S013, S022, S023, S024 (a `<meta content=...>` page digest) | page-integrity digest in the vendor page markup | page digest, not a credential |
| 64-hex digest | 32 in the receipt | the receipt's per-observation `sha256` field | the receipt's own field, by design |
| 64-hex digest | 10 in `clock-rearm.tsv` | the ledger's `sha256` column | the ledger's own field, by design |
| `Authorization:` header text | 2 in S174 | a Vault changelog line naming `X-Vault-Token` as a header, with the *header name* as the match | a header name in prose, no credential value |
| email-shaped strings | 2 in S014, 4 in S022, 2 in S025, 6 in S175 | upstream author/contributor addresses in vendor docs and in the OpenBao release-feed item metadata | public upstream attribution |
| `user:pass@host` shapes | 4 each in S013, S022, S023, S024; 3 in S175 | **regex artifact** — masked structural analysis shows the match is a JSON `"url"` value in the page's `__NEXT_DATA__` blob, e.g. masked `#####://###.#########.###"},"#########":{"@####`; a strict `urlsplit` pass over all 199 distinct `(scheme, host)` URL pairs in the 12 captures finds **0 URLs with userinfo** | no credential |

A second-pass scan (scheme-less `user:pass@host`, e-mail, PEM armour, cookie headers, bearer,
Vault-family tokens) over the 12 captures returns only the classes above; the three
`scheme_less_userinfo` hits in S175 are `Signed-off-by: Author Name <local@host>` attributions in
the OpenBao release feed (masked shape `######:####.######@#######-#####.##`).

**No `Set-Cookie` / `Cookie` value and no `__cf_bm` value appears in any round-72 capture**
(QM72). The round-72 capture directory holds page bodies and two release-feed bodies only — no
`.headers` / `.meta` file was committed, so no server-issued credential could ride in one.

The one committed byte with a non-default worktree mode is `.ufo/waves/round-72/final/observe-r72.json`
at `0600`; git records it `100644`, so the committed mode is the normal one and no other reader is
affected.

Precedent check: for every id whose capture class is flagged above, the round-72 capture carries
**the same number of occurrences, at the same digest, as the BASE-committed round-47 capture of
the same page** (verified by hashing each match and comparing sets — see
`w1/R72Sentinel/evidence-secret-scan-counts.txt` and the per-class equality table reproduced in the
seat transcript). Round 72 adds no new token-shaped material to the lane.

The receipt itself: 32 observations, 15 distinct URLs, no observation carries `error`, no URL
carries userinfo or a query string, and every `observed_at` is `2026-11-09T04:01:37Z`–`…:45Z`.

---

## 2. Counter safety: can a crafted input escape the tree, execute code, or reach a non-public URL?

The counter was attacked as a black box. Nine fixture trees were built from the candidate
`a947a42c` (each with exactly **one** injected mutation) and each was run through the **unmodified
frozen** `plans/round-72-c1.sh --tree <fixture>`. Full transcripts:
`w1/R72Sentinel/evidence-counter-fixtures.txt`.

### 2.1 The counter executes candidate-supplied Python — and the LIVE leg can be forged

`plans/round-72-c1.sh:67` runs the LIVE observation as

```
python3 "$W/base/corpus/release-clock.py" --root "$T" --observe "$W/live.json"
```

i.e. the **BASE-pinned** gate, but pointed at the candidate tree with `--root "$T"`. The BASE gate's
`load_normalizer(root)` (`corpus/release-clock.py:725`) does
`spec.loader.exec_module(module)` on `root/corpus/rendered-text-v1.py` — the **candidate's** file,
not BASE's. The counter's own `rt` (line 152) is correctly pinned to BASE for the quote-locate
step, but the LIVE-observation path is not: it hands the tree a `__main__` module reference.

Consequences, both demonstrated:

**(a) Arbitrary code execution with the counter's privileges.** Fixture `exec2`: one line appended
to the candidate's `corpus/rendered-text-v1.py` writes a marker file on import. The counter run
produced `T-NORMALIZER-EXECUTED` (`w1/R72Sentinel/evidence-exec-proof.txt`) and still printed
`value=10`. The same holds for the candidate's own `corpus/release-clock.py`: fixture `fakegate2`
keeps the two lines the counter greps for and appends a marker write; the counter run produced
`T-RELEASE-CLOCK-EXECUTED` and printed `value=10`.

**(b) The LIVE leg — the one thing that is supposed to bind the claim to the vendor's *actual*
current release — can be forged.** Fixture `forge`: the candidate's normalizer, at import, rebinds
`__main__.parse_latest_version` to a stub. The counter's live observation then reports
`2.2.1` for the OpenBao rows whose real feed says `2.7.2`, and the six OpenBao rows fail as
`live=2.2.1` (value drops to 4 — the stub is caught only because it is *wrong*).

The decisive case is the **A/B pair**, run back to back on the same day against the same vendor
state:

| fixture | mutation | counter verdict |
|---|---|---|
| `ab/A_f6_only` | **exactly** the F6 control from `plans/round-72-controls.sh` (fabricated release 2.7.3, self-consistent feed/table/receipt/ledger) | `value=4 rows_passing=4` — matches the frozen expected verdict |
| `ab/B_f6_plus_override` | the **same** F6 mutation **plus** the parser override | `value=10 rows_passing=10` |

So the F6 control — the one control whose whole purpose is "LIVE kills the six OpenBao rows" — is
defeated by a single extra line in a file the counter never pins. The frozen controls suite
(`plans/round-72-controls.sh`) has no control of this shape: F1–F10 mutate the table, the ledger,
the receipt, the registry, the census and the shipped gate, but **none of them mutates
`corpus/rendered-text-v1.py`**, which is the file the counter loads into the BASE gate.

For completeness, the forged live receipt is observable: on the B fixture the BASE gate's own
observation for the OpenBao rows reads `parsed_version=2.7.3` while the real feed says `2.7.2`,
and the same run reports `REGRESSED` on twelve unrelated rows — the stub parser ignores the body.

This is **not** a defect in the candidate `a947a42c`: the candidate's
`corpus/rendered-text-v1.py` is byte-identical to BASE (verified with `git diff BASE candidate --
corpus/rendered-text-v1.py`, empty). It is a defect in the **counter's** trust boundary — and the
counter is frozen, so the finding is a report, not a patch.

### 2.2 A symlink in the tree redirects the sha check to bytes outside the tree

The counter's ledger-binding leg (`plans/round-72-c1.sh:183–190`) does:

```
cp = os.path.normpath(os.path.join(T, cpath))
... and cpath.startswith(".ufo/waves/round-72/") and cp.startswith(T + os.sep)
    and os.path.isfile(cp) and sha(cp) == csha and ...
```

`cp.startswith(T + os.sep)` is a **string-prefix test on the un-resolved path**, and
`os.path.isfile` / `sha()` follow symlinks. So a capture path that is a symlink to a file outside
the tree satisfies every check while the bytes hashed are not the tree's.

Fixture `symlink`: `S013.page.body` replaced by a symlink to a file outside the tree whose content
is the S013 quote; the ledger's `sha256`/`bytes` updated to match. The counter printed
`ID S013 anchor=2.2.1 PASS` and `value=10 rows_passing=10`. Confirmed directly:

```
lexical path inside T: True
realpath inside T     : False
```

The same escape was reproduced through the counter's **own** revision path, not just `--tree`:
fixture `gitsym` is a real git repo whose committed tree contains the symlink; `git archive HEAD |
tar -x` preserves it (verified), and the counter run on the extracted tree printed
`ID S013 anchor=2.2.1 PASS` / `value=10`. So a *landed* tree carrying such a symlink would pass.

Two important scoping facts, which bound this finding:

- The lane's own `corpus/sources-census.sh` **already has the right check**: it resolves capture
  paths with `realpath -m` and refuses `capture-outside-root` (`corpus/sources-census.sh:384`).
  Fixture `dirsym` (the whole capture *directory* replaced by a symlink) is caught by the census
  (`SC_CAPTURE id=S174 capture-outside-root`), so the counter's `census=0` leg fails and the
  counter prints `value=0`.
- But the census reads **`corpus/source-fetches.tsv`**, and it does **not** read
  `corpus/clock-rearm.tsv` at all (`grep -c clock-rearm corpus/sources-census.sh` → `0`). The ten
  clock-rearm capture paths are `*.page.body` files, and the census binds `source-fetches.tsv`
  rows by their col-16 *location*, which for these ten ids is **prose** (`§Lease, renew, and
  revoke`, `POST /:secret-mount-path/config parameters, max_versions`), not a path. So the ten
  round-72 page captures are the one capture population in the lane with **no** realpath-resolving
  instrument at all: the census does not cover them, and the counter that does cover them uses a
  lexical prefix test.

Fixture `traversal` shows the lexical check does catch `../` escapes in the ledger
(`value=9`, `S013 FAIL ledger-binding`) — the gap is specifically the **symlink** case, which
`normpath` does not resolve.

### 2.3 A capture whose bytes are fabricated passes VERIFIED

Fixture `fakecap`: `S013.page.body` (261 663 bytes of vendor page) replaced by a **58-byte** file
containing nothing but the S013 quote, with the ledger's `sha256`/`bytes` updated to match. The
counter printed `ID S013 anchor=2.2.1 PASS` and `value=10 rows_passing=10`.

This is not a counter bug — it is the counter doing exactly what its frozen header says (bind by
sha256 + byte count + quote located ≥ 1). It is a **coverage ceiling the plan does not name**: the
predicate's VERIFIED leg binds the capture to the ledger's own digest, and the ledger is part of
the same candidate tree, so the pair is self-consistent for any bytes the author chooses. The
round-72 captures carry no independent provenance row (unlike `source-fetches.tsv`, whose col-10
digest the census recomputes against a real fetch). The plan's uncounted conjuncts U1–U4 name the
semantic leg, the non-F observations, LIVE's later-release behaviour and the feed parser — none
names "the capture body may be authored rather than fetched".

### 2.4 Non-public URLs and redirects are refused — the BASE gate's public-address checks hold

Good news, and it is worth recording because the counter hands the tree a URL-fetching code path.

- `valid_public_https_url` (BASE gate) rejects `http://`, any port ≠ 443, embedded credentials,
  any query string, `localhost` / `*.localhost` / `*.local`, and any literal non-global IP
  (`192.168.1.1`, `127.0.0.1`, `0.0.0.0`, `169.254.169.254`, `[::1]` all → `False`).
- `public_addresses` resolves DNS and refuses a host that resolves to a non-global address:
  `localhost` → `host resolves to a non-public address`; `metadata.google.internal` → `host lookup
  failed`.
- `redirect_allowed` refuses cross-origin redirects and refuses a redirect into a credential-shaped
  path; `NoRedirectHandler` plus the origin pin keeps the fetch on one origin.
- Fixture `nonpublic`: the candidate's `S013` feed_url rewritten to `https://192.0.2.1/latest/meta-data/`
  (TEST-NET-1) → the counter prints
  `SETUP (live observation failed for an F id (network?)) value=0`, i.e. it **fails closed**, and no
  packet left the host.
- The gate's own `path_carries_secret` guard strips query strings and long token-shaped path
  segments from the receipt's recorded URL.

So a crafted `feed_url` **cannot** make the counter fetch a non-public address, and the shipped
gate's public-address checks are the reason.

### 2.5 A symlinked receipt also passes

Fixture `receiptsym`: the round-72 receipt path replaced by a symlink to a copy of itself outside
the tree. The counter printed `value=10 rows_passing=10` — the receipt's sha256 check
(`sha(rpath) == m.group(1)`) hashes the *target*, not a tree-resident file. Same lexical-vs-realpath
gap as §2.2, one level up: the default-receipt identity leg is satisfied by an out-of-tree file.

---

## 3. Does any round-72 change widen the release-clock gate's network surface?

**No. The gate's fetch set is unchanged; the two new registry rows add no new host and no new
URL.**

Computed statically from both trees (the gate observes exactly the `on-release` registry rows that
have exactly one clock row, fetching the clock row's `feed_url` for feed clocks and the registry
row's own URL for rendered-quote clocks):

```
== BASE b2f3dd66 ==            == CANDIDATE a947a42c ==
  on-release rows that fetch: 32    on-release rows that fetch: 32
  distinct URLs: 15                distinct URLs: 15
  hosts: 1password.com, curl.se, github.com, html.spec.whatwg.org,
         infra.spec.whatwg.org, releases.1password.com, www.1password.dev,
         www.python.org, www.unicode.org          (identical set)
```

The two new registry rows are `S174` (Vault releases feed) and `S175` (OpenBao releases feed). Both
carry `recheck=90d`, **not** `on-release`, so the gate's eligible set is unchanged; and their URLs
(`github.com/hashicorp/vault/releases.atom`, `github.com/openbao/openbao/releases.atom`) are the
**same two URLs** already fetched for `S034`/`S035` and `S012` — no new host, no new path, no new
scheme. The round-72 receipt confirms it at the wire level: 32 observations, 15 distinct URLs, and
the URL set is **identical** to the round-54 receipt's (set difference in both directions: `NONE`).

The re-arm re-points ten `on-release` clocks from `S034`/`S035` to `S174`/`S175`; since both pairs
name the same feed URLs, the bytes on the wire are the same two Atom feeds.

The one genuinely new network activity in round 72 is the counter's own LIVE observation (a
`--observe` run over the tree, hitting those same 15 URLs), and it is the plan's declared LIVE leg
(U3 notes it binds vendor state at measurement time).

---

## 4. Independent verification of the candidate (not the counter)

Because §2 shows the counter can be made to say `value=10`, the counter's own verdict on the
candidate is not sufficient evidence. I re-verified the ten ledger bindings from the committed
bytes with the **BASE-pinned** `corpus/rendered-text-v1.py` and the BASE-pinned quote column,
independently of the counter:

```
S013 sha_ok=True bytes_ok=True quote_count=1 declared=1 -> PASS
S014 sha_ok=True bytes_ok=True quote_count=1 declared=1 -> PASS
S015 sha_ok=True bytes_ok=True quote_count=1 declared=1 -> PASS
S016 sha_ok=True bytes_ok=True quote_count=1 declared=1 -> PASS
S021 sha_ok=True bytes_ok=True quote_count=1 declared=1 -> PASS
S022 sha_ok=True bytes_ok=True quote_count=1 declared=1 -> PASS
S023 sha_ok=True bytes_ok=True quote_count=1 declared=1 -> PASS
S024 sha_ok=True bytes_ok=True quote_count=3 declared=3 -> PASS
S025 sha_ok=True bytes_ok=True quote_count=1 declared=1 -> PASS
S026 sha_ok=True bytes_ok=True quote_count=1 declared=1 -> PASS
ALL TEN VERIFIED INDEPENDENTLY: True
```

Each capture's sha256 and byte count match its `clock-rearm.tsv` row, and each id's BASE-declared
fetch quote locates the declared number of times under BASE's normalizer. The candidate's
`corpus/rendered-text-v1.py` is byte-identical to BASE, so the counter's LIVE leg on this
candidate is not forgeable by the §2.1 route: the candidate's own numbers hold.

---

## 5. Summary of what I can and cannot assert

- **Asserted**: the round-72 bytes carry no credential or private material; every flagged
  token-shaped string is either the file's own digest field or is byte-identical to BASE-committed
  precedent; the shipped gate's public-address checks hold and a non-public `feed_url` fails closed;
  the round-72 change does not widen the gate's network surface; the candidate's ten re-arms verify
  independently of the counter.
- **Asserted (counter defects, candidate-clean)**: the frozen C1 counter executes candidate-supplied
  Python inside the BASE-pinned gate and can be made to forge its LIVE verdict (defeating F6 with
  one extra file mutation, no control of which exists); its capture/receipt containment test is a
  lexical prefix test that a symlink defeats, and the census's realpath-resolving check does not
  cover `corpus/clock-rearm.tsv`, so the ten round-72 page captures have no realpath-resolving
  instrument; the VERIFIED leg binds a capture only to the tree's own self-declared digest.
- **Not asserted**: whether the ten captures are the *live* bytes the vendor served at fetch time
  (that is the semantic/freshness leg U1 and the round-47 `teaching-holds` judgment, outside this
  seat); whether the re-armed anchors are the right *policy* call (QM23/QM24/QM28, the reviewer and
  critic seats); and whether a later release invalidates the landing (U3, explicitly).

Remediation is out of scope for this seat — the plan and counters are frozen, and the sentinel seat
is an attack seat, not an integration owner. The smallest remediation for each defect is recorded
in the finding lines below for the L1 to route.

## 6. Hygiene

- Scratch `/fast/scratch/hyaku/kagi-r72/R72Sentinel` removed on exit; `/fast/scratch/hyaku/kagi-r72/l1`
  never touched.
- One fixture (`exec`) wrote a marker into the lane checkout because it used a relative path; I
  removed the stray `fx/` directory I created (`git status` shows no `fx/` entry) and re-ran the
  demonstration with an absolute marker path. No lane file was modified by me; the pre-existing
  modifications to `SCORECARD.md`, `corpus/lessons/round-71.md` and `corpus/release-clock.py` are
  other seats' work and were left alone.
- At most 2 counter runs were in flight; no fetches outside the counter's own 15 URLs, no loops of
  requests, no `op`, no vault, no credential read.

## 7. Cited evidence (in this seat's directory)

- `w1/R72Sentinel/evidence-secret-scan-counts.txt` — needle-by-needle counts over the new bytes.
- `w1/R72Sentinel/evidence-url-structure.txt` — per-file distinct-URL counts, userinfo count.
- `w1/R72Sentinel/evidence-exec-proof.txt` — the `T-NORMALIZER-EXECUTED` marker written by the
  counter run on the `exec2` fixture.
- `w1/R72Sentinel/evidence-counter-fixtures.txt` — the nine fixture transcripts plus the A/B pair.

FINDING SE-1 neutral — no credential or private material in the 12 new captures, the receipt, clock-rearm.tsv or the counters; every token-shaped hit is a digest field or byte-identical to BASE-committed round-47 precedent, and no URL in any capture carries userinfo.
FINDING SE-2 falsifies-number — the frozen C1 counter executes the candidate's corpus/rendered-text-v1.py inside the BASE-pinned gate (release-clock.py:725 exec_module on --root T), so one appended line there forges the LIVE verdict: F6 alone reads value=4 as predeclared, F6 plus that line reads value=10, and no F-control of the round mutates that file.
FINDING SE-3 falsifies-number — the counter's capture and receipt containment test is a lexical prefix test on the unresolved path (plans/round-72-c1.sh:183-190), so a committed symlink redirects the sha check to bytes outside the tree and still reads value=10, while the census's realpath-resolving capture-outside-root check does not read corpus/clock-rearm.tsv and so never covers the ten round-72 page captures.
FINDING SE-4 neutral — the round-72 change does not widen the release-clock gate's network surface: BASE and candidate fetch the same 32 on-release rows over the same 15 distinct URLs on the same 9 hosts, S174/S175 carry recheck=90d rather than on-release and reuse the S034/S035 feed URLs, and the round-72 receipt's URL set equals the round-54 receipt's exactly.
FINDING SE-5 neutral — the shipped gate's public-address checks hold against a crafted feed_url: a TEST-NET-1 address, a bare IP, localhost, a non-global-resolving host and any cross-origin or credential-path redirect are all refused and a non-public feed_url fails the counter closed at SETUP with value=0, so no crafted input reaches a non-public URL.
FINDING SE-6 falsifies-wording — the VERIFIED leg binds a capture only to the tree's own self-declared digest, so a 58-byte file containing nothing but the quote satisfies it and reads value=10; the plan's uncounted conjuncts U1-U4 name the semantic leg, the non-F observations, LIVE's later-release behaviour and the feed parser, but name no ceiling for a capture body that was authored rather than fetched.
SEAT-STATUS: complete
