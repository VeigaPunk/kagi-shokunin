# R52ScoutSource — independent source re-opening for C1 (S110) and C2 (rewrap page)

Seat: `R52ScoutSource` (scout, leaf — no subagent dispatch).
Lane: `/home/vgpnk/Projects/shokunin/kagi-shokunin`, branch `master`, BASE `1d984adaa4a5c66ea9f24cb95bf79ffbca16c32b`.
Date of work: 2026-11-06/07 (host clock; HTTP `date:` headers read `Sat, 07 Nov 2026 02:03:27 GMT`).
Write scope honoured: only this file and `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-52/build/R52ScoutSource/`.
No lane file was edited; no git mutation was performed (read-only `git status`/`diff`/`rev-parse` only).
No OpenBao server was started by this seat; no token, secret or key material was read, printed or stored.

## 0. Commands run (receipts)

```
mkdir -p /fast/scratch/hyaku/kagi-r52/R52ScoutSource \
         /home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-52/build/R52ScoutSource
curl -sSL --compressed -w '%{http_code}' -o <name>.body <url>      # ×6, exit 0 each
python3 corpus/rendered-text-v1.py locate <file> "<quote>"          # exit 0 on count≥1, 1 on count=0
python3 corpus/rendered-text-v1.py digest <file>
sha256sum /home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-52/capture/S110.body
```

Tool: `curl` (`/usr/bin/curl`) + `python3` (`/usr/bin/python3`), both already present — **no package was installed or upgraded this seat**, so the tooling directive produced no install record.

Scratch: `/fast/scratch/hyaku/kagi-r52/R52ScoutSource` (created, empty at yield — no clone, archive or fixture was needed; the fetched bodies live in the seat build dir as required).
All fetched bodies are saved in `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-52/build/R52ScoutSource/`:
`S110.body`, `REWRAP.body`, `CAND_KVAPI.body`, `CAND_UNDELETE.body`, `CAND_DESTROY.body`, `CAND_METADATA.body`,
each with its rendered-text twin (`*.rendered.txt`), plus the empty `*.err` (stderr) files from curl — **no fetch failed**.
A machine-readable receipt (`receipts.txt`, name/HTTP/bytes/sha256/URL for all six fetches, the L1 capture hash and the
curl stderr sizes) sits in the same directory.

## 1. Fetch table (URL, HTTP status, bytes, sha256, quote counts, verdict)

Entry quotes (from the reference fixture
`.ufo/waves/round-52/controls/fixtures/ref/corpus/knowledge/openbao-kv-v2-version-lifecycle.md`):
**T1** "In order for a write to be successful, cas must be set to the current version of the secret." ·
**T2** "When deleting data the standard bao kv delete command will perform a soft delete." ·
**T3/T4** "A version's data is permanently deleted only when the key has more versions than are allowed by the max-versions setting" ·
**T5** "Permanently delete all metadata and versions for a key".

| URL | HTTP | bytes | sha256 (decoded body) | quote counts in that body (T1/T2/T3T4/T5) | verdict |
|---|---|---|---|---|---|
| `https://openbao.org/docs/secrets/kv/kv-v2/` (S110) | 200 | 83532 | `6cfd72eca347d0dfbcea73ad429ae5db3f01f2710cd794a473b00047e02b1587` | 1 / 1 / 1 / 1 | **ADMIT as the C1 source** — byte-identical to the L1 capture (§2) |
| `https://openbao.org/docs/api/secret/kv/kv-v2/` | 200 | 127677 | `9c1fa5b1e88f1fff0fe1e7db08132d83690e1121f429fc3c47cbe650c6e4cb1c` | 2 / 0 / 0 / 0 | **REJECT as an additional C1 registry row** (§3a) |
| `https://openbao.org/docs/commands/kv/undelete/` | 200 | 33415 | `51f8474193986446b321d99d68b4ae20f4a773c4692ab14a00af8216d7f52113` | 0 / 0 / 0 / 0 | **REJECT** (§3b) |
| `https://openbao.org/docs/commands/kv/destroy/` | 200 | 33330 | `8f84287044cd45997d6cdcd579dc94ca970dfe84a1d24bdd64472512053b4600` | 0 / 0 / 0 / 0 | **REJECT** (§3c) |
| `https://openbao.org/docs/commands/kv/metadata/` | 200 | 44332 | `fcec3920e5f6fa934a08d1e4b8858ba04a9a3ea6bc227e5aefc893352041ad0b` | 0 / 0 / 0 / 0 | **REJECT** (§3d) |
| `https://openbao.org/docs/api/system/wrapping-rewrap/` (C2) | 200 | 38748 | `7173f3a6b1bcf004e7cd2888b46874911b2573c577e0e9d944a7bafef42a3ee9` | 0 / 0 / 0 / 0 | **source for C2** — see §4 |

Normalized digests (`rendered-text-v1.py digest`, `raw_sha256` = the sha256 column above):
S110 `6bbd6c4cc131b898965fd573ac68d8307bfc84172ad59874d1188394903b31b6` (15529 norm bytes) ·
REWRAP `33bcc5f2fe8eb9e76ca3428a761d8470b09118733c69c9432d26343cd72c7784` (2904) ·
CAND_KVAPI `c978d7cc2d05ffdb23e060387ddb339349d634c96177227ab926e288233ed87d` (20847) ·
CAND_UNDELETE `534c3060e3c6c7a2d4a48dff3cc01994b189eb9610f59e452db56b0f4168a952` (2313) ·
CAND_DESTROY `ab973ce91709279913604a2c007266f19a6b2ade1f197d9815339d5a80795c25` (2293) ·
CAND_METADATA `e7518888e726f1297dfc15e67a729fa8043cf554c41dfe8e95961e3d91e9ad95` (5582).

Freshness: every page carries the docs label **"Version 2.7.x"** (the rendered text of each of the five OpenBao pages
contains a `Version: Version 2.7.x` line — S110 at `S110.rendered.txt:52`, CAND_KVAPI:39, CAND_UNDELETE:80,
CAND_DESTROY:80, CAND_METADATA:80, REWRAP:86) and every response header shows
`last-modified: Fri, 06 Nov 2026 09:06:36–09:07:02 GMT` — i.e. the docs set was rebuilt within ~17 h of this fetch.
All six fetches returned HTTP 200 on the first attempt; no redirect chain other than the site default was observed
(`curl -sSL` exit 0, empty stderr).

## 2. C1: S110 re-opened independently — byte-identical to the L1 capture

* L1 capture `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-52/capture/S110.body`:
  `sha256 6cfd72eca347d0dfbcea73ad429ae5db3f01f2710cd794a473b00047e02b1587`, 83532 B.
* My independent fetch of the same URL: HTTP 200, 83532 B, **identical sha256** → the capture is current and the page
  has not changed between the L1 fetch and this seat's re-open.
* `rendered-text-v1.py digest` on both: `normalized_sha256=6bbd6c4c…4903b31b6`, 15529 normalized bytes — identical.

Quote location on **both** bodies (capture and my own fetch), `python3 corpus/rendered-text-v1.py locate <file> "<quote>"`:

| quote | capture | my fetch | last output line |
|---|---|---|---|
| T1 (cas) | count=1 (rc 0) | count=1 (rc 0) | `RENDERED_TEXT_V1_LOCATE: count=1` |
| T2 (soft delete) | count=1 (rc 0) | count=1 (rc 0) | `RENDERED_TEXT_V1_LOCATE: count=1` |
| T3/T4 (max-versions/destroy sentence) | count=1 (rc 0) | count=1 (rc 0) | `RENDERED_TEXT_V1_LOCATE: count=1` |
| T5 (metadata delete) | count=1 (rc 0) | count=1 (rc 0) | `RENDERED_TEXT_V1_LOCATE: count=1` |

The four quote strings were also extracted **verbatim from the reference fixture entry** (with its embedded newlines,
regex `“([^”]+)”`) and located against the capture: all four → `count=1`, rc 0. The entry's claim
"Every quote below is located with … → `count=1`" is **confirmed**.

Where each quote lives in S110 (rendered line numbers of `S110.rendered.txt`):
T1 at 220–227 (§Usage, the `-cas` paragraph); T2 at 407–412 (§Deleting and destroying data);
T3/T4 at 414–421 (the same paragraph, "…only when the key has more versions than are allowed by the max-versions
setting, or when using `bao kv destroy`"); T5 at 572 (§policy/`kv metadata delete` example block).

Supporting facts that S110 does contain for the trial's own mechanics (each `count=1` on S110):
"Soft deletes do not remove the underlying version data from storage" · "Also remember that soft deletes do not
remove any underlying version data from storage" · "In order to write to a soft deleted key, the cas parameter must
match the key's current version" · "handles undeleting versions" · "Destroying a version permanently deletes the
underlying data" · "Deleting the metadata key will cause all metadata and versions for that key to be permanently
removed" · "Once a key has more versions than max versions the oldest versions are cleaned up" ·
"Delete-version-after settings will apply only to new versions" · "Max versions changes will be applied on next
write" · "If set to 0 a write will only be allowed if the key doesn’t exist as unset keys do not have any version
information".

**Conclusion for C1:** the source S110 stands as the citation for all five mechanics the trial measures; the entry's
four quotes and its source line are accurate and fresh. No wording problem found in the entry.

## 3. Adjacent candidate pages — admit/reject as an additional C1 registry row

Decision rule applied (from the seat spec): **a row is admitted only if the entry would cite a fact the S110 page
lacks.** Every fact the entry currently cites is on S110 (§2 table), so no candidate page is admitted *as the entry
stands*. Each candidate nevertheless holds facts S110 lacks; those facts become the flip condition.

### 3a. `https://openbao.org/docs/api/secret/kv/kv-v2/` — **REJECT** (as an additional C1 row)

Reason: it is the HTTP API reference, not the CLI/KV-v2 semantics page the entry measures. The entry's five
mechanics (`kv put -cas`, `kv delete`/`kv undelete`, `kv destroy`, `kv metadata put -max-versions`, `kv metadata
delete`) are all CLI-level and all already cited from S110; the entry cites nothing from this page. It also
duplicates S110's cas sentence (T1 appears twice here, `count=2`), so it adds no new citation for T1.

Facts it holds that S110 **lacks** (count in candidate / count in S110):

| fact | candidate | S110 |
|---|---|---|
| "When 0 is used or the value is unset, OpenBao will keep 10 versions." | 1 | 0 |
| "This value applies to all keys, but a key's metadata setting can overwrite this value." | 1 | 0 |
| "If not set, the backend’s configured max version is used." | 2 | 0 |
| "If true all keys will require the cas parameter to be set on all write requests." (engine-level `cas_required`) | 1 | 0 |
| "If set, specifies the length of time before a version is deleted." (engine-level `delete_version_after`) | 1 | 0 |
| "Once a key has more than the configured allowed versions, the oldest version will be permanently deleted." | 3 | 0 |
| subkeys endpoint text / JSON-merge-patch endpoints | 1 | 0 |

Flip condition: an entry line that states the **mount-level config precedence** (backend default 10 versions, a key's
metadata overwrites the backend value) or the **engine-wide `cas_required`/`delete_version_after`** semantics would
cite a fact absent from S110, and this row would then be admitted (tier A, `mined`).

### 3b. `https://openbao.org/docs/commands/kv/undelete/` — **REJECT**

Reason: the entry's T2 cites S110's soft-delete sentence and the restore is *measured*, not read off this page; S110
already contains "The `bao kv undelete` command handles undeleting versions" and the `bao kv undelete -mount=secret
-versions=2 my-secret` example, so this page adds no citation for the claim actually made.

Facts it holds that S110 lacks: "Specifies the version number that should be made current again." (1 / 0) and the
"K/V Version 2 … not available for Version 1" note (1 / 0).

Flip condition: an entry line stating that undelete makes **that version current again** (not merely readable), or
that `kv undelete` is **KV-v2-only**, would need this page.

### 3c. `https://openbao.org/docs/commands/kv/destroy/` — **REJECT**

Reason: T3's cited sentence is on S110, and S110 already carries "Destroying a version permanently deletes the
underlying data" (count=1) plus the `bao kv destroy -mount=secret -versions=2 my-secret` example; nothing the entry
says needs this page.

Facts it holds that S110 lacks: "If no key exists at the path, no action is taken." (1 / 0); the `-versions`
int-list flag semantics "The versions to destroy. Their data will be permanently deleted." (1 / 0 vs S110's prose
variant).

Flip condition: an entry statement that `kv destroy` on a **missing key is a silent no-op** (operationally relevant
for runbooks and idempotent rotation), or that documents `kv destroy -versions` as a required int list, would cite
this page.

### 3d. `https://openbao.org/docs/commands/kv/metadata/` — **REJECT** (closest of the four to a flip)

Reason: T4's and T5's cited sentences are on S110. Note the entry's T4 quote is the *T3/T4* sentence
("permanently deleted only when the key has more versions than are allowed by the max-versions setting"), which S110
carries verbatim (count=1); S110 additionally has the weaker metadata-section wording "Once a key has more versions
than max versions the oldest versions are cleaned up" (count=1). So S110 already underwrites T4 without this page.

Facts it holds that S110 lacks:

| fact | candidate | S110 |
|---|---|---|
| "Once a key has more than the configured allowed versions the oldest version will be permanently deleted" | 2 | 0 |
| "Deletes all versions and metadata for a key in the KV store" | 1 | 0 |
| "Any changes to the Delete-Version-After setting will only be applied to new versions." | 1 | 0 |
| "If not set, the backend’s configured max version is used." | 2 | 0 |
| "-max-versions (int: 0) - The number of versions to keep per key." | 1 | 0 |
| example with the **equals form** the trial runs: `bao kv metadata put -mount=secret -max-versions=5 creds` | 1 | 0 (S110 shows only the space form `-max-versions 2`) |

Flip condition: (i) an entry line that cites the metadata CLI's own "permanently deleted" wording for the
max-versions drop, or its "Deletes all versions and metadata for a key" wording for T5, or the
`Delete-Version-After applies only to new versions` rule; **or** (ii) an entry/trial note that documents the
`-max-versions=2` **equals** flag form the trial actually executes — that form is documented here and nowhere on
S110 (S110 shows `-max-versions 2` with a space, `S110.rendered.txt:480`). Either would justify a registry row.

### 3e. Cross-page observation (operability, C1)

The reference trial script
`.ufo/waves/round-52/controls/fixtures/ref/corpus/openbao-kv-versions-trial.sh` runs
`bao kv metadata put -max-versions=2 secret/t4` (line 173) and `bao kv put … -cas=0 / -cas=1`
(lines 131–133). The `-cas=N` equals form **is** shown on S110 (`$ bao kv put -mount=secret -cas=1 my-secret foo=aa
bar=bb`, `S110.rendered.txt:229`), but the `-max-versions=2` equals form is **not** shown on S110 — only the space
form is. This is a documentation-coverage gap in the cited source, not a defect in the trial (the CLI accepts the
equals form and the trial measures it). It is the one candidate-page fact (CAND_METADATA) that an entry line could
plausibly want to cite; recorded here so the C1 author/next round can decide, not as a demand.

## 4. C2: the rewrap API page — exactly what it does and does not say about `creation_path`

Source fetched: `https://openbao.org/docs/api/system/wrapping-rewrap/` → HTTP 200, 38748 B,
sha256 `7173f3a6b1bcf004e7cd2888b46874911b2573c577e0e9d944a7bafef42a3ee9`, docs label "Version 2.7.x"
(saved as `REWRAP.body` / `REWRAP.rendered.txt`).

**What the page actually contains (rendered text, verbatim):**

* Endpoint description: "The `/sys/wrapping/rewrap` endpoint can be used to rotate a wrapping token and refresh its
  TTL." and "This endpoint rewraps a response-wrapped token. **The new token will use the same creation TTL as the
  original token and contain the same response. The old token will be invalidated.** This can be used for long-term
  storage of a secret in a response-wrapped token when rotation is a requirement."
* Sample payload: `{ "token": "abcd1234..." }`; Sample request: `POST /sys/wrapping/rewrap` with
  `--header "X-Vault-Token: ..." --data @payload.json http://127.0.0.1:8200/v1/sys/wrapping/rewrap`.
* Sample response: `data: null`, and a `wrap_info` block with `token`, `ttl: 300`, `creation_time`, and
  **`"creation_path": "sys/wrapping/wrap"`**.
* Page also states: "The old token will be invalidated." (`count=1` — the fact the round-51 rejected row named as
  its flip condition).

**Exactly what that says about `creation_path`:** the string `creation_path` occurs **exactly once** in the whole page
(`REWRAP.rendered.txt:164`, inside the sample response JSON). The prose mentions "creation" only as "creation TTL"
and in the JSON keys `creation_time`/`creation_path` — there is **no prose sentence about a creation path anywhere**
on the page. The word "input" does not occur on the page at all (grep count 0).

**Does the page state the input token's creation path? No.** The page's only statements about the *relationship*
between input and output tokens are "the same creation TTL as the original token", "contain the same response", and
"The old token will be invalidated." The sample response shows an example output whose `creation_path` happens to be
`sys/wrapping/wrap`; the page nowhere says where the *input* token came from, and nowhere says that the output's
`creation_path` is copied from, or stamped independently of, the input's.

**Consequence for round-51 closure D1.** The BASE lane statements —
`corpus/knowledge/vault-openbao-token-lease-lifecycle.md:292` ("the rewrap API page's sample response shows
`sys/wrapping/wrap` for a rewrapped token, which this binary does not do") and
`corpus/lessons/round-51.md:22` ("the page's sample response shows creation path `sys/wrapping/wrap` for a
rewrapped token, which OpenBao 2.7.2 does not do") — rest on reading the sample's `creation_path` as a statement
about **every** rewrapped token. The page does not make that statement, and the sample's `creation_path` value is
**fully consistent** with the binary's measured behaviour that a rewrap preserves the input's creation path
(helper-origin input → `sys/wrapping/wrap`; KV-origin input → `secret/data/<path>`): a helper-made input rewrapped
does read `sys/wrapping/wrap`, so the sample shows nothing the binary contradicts. The lane's original reading is
therefore an over-read (`doc-over-read`), exactly as D1 characterises it.

**The appended correction lines in the working tree are textually supported by the page.** The candidate
correction (in `corpus/knowledge/vault-openbao-token-lease-lifecycle.md` and `corpus/lessons/round-51.md`, both
append-only) says, in substance: the rewrap page's sample response never states its input token's creation path, so
a sample showing `sys/wrapping/wrap` is consistent with the binary for a helper-made input; the sentence claiming a
binary/documentation disagreement is withdrawn; the measured fact (rewrap preserves the input's creation path) stands.
My source evidence supports every clause of that: `creation_path` appears once, in the sample response only; there is
no prose about creation paths; the page says "same creation TTL … same response" and "The old token will be
invalidated"; the sample's `sys/wrapping/wrap` is exactly what a helper-origin input yields under the measured
preserve-the-path behaviour.

Two residual precision notes for the C2 author (not blockers, and the counter's lexical scope is not mine to widen):
1. The page does **not** state that the output's `creation_path` is preserved from the input — it is silent on
   creation paths entirely. The correction's wording "never states its input token's creation path" is exactly
   right; the phrase "so a sample showing `sys/wrapping/wrap` is consistent with the binary" is a statement of
   non-contradiction, which is what the page supports.
2. The page **does** state one thing the round-51 rejected row listed as its flip condition — "The old token will
   be invalidated." (`count=1`). That is a genuine additional fact the page holds (distinct from the "rotation"
   framing) and it is the natural flip for a future registry row; it is not needed by, and does not affect, the D1
   correction.

## 5. Findings (weaknesses of the frozen instruments — reported, never edited)

* **F1 (minor, C1 citation breadth).** The entry's T4 rests on the T3/T4 sentence "…permanently deleted only when
  the key has more versions than are allowed by the max-versions setting". That sentence supports the drop; the
  *specific* CLI wording the trial executes (`kv metadata put -max-versions=2`, equals form) is documented only on
  the kv-metadata page, not on S110 (S110 shows the space form). Not a defect in the claim — S110 does underwrite the
  max-versions mechanic ("Once a key has more versions than max versions the oldest versions are cleaned up",
  count=1) — but the cited page is silent on the exact flag form used. Flip: see §3d(ii).
* **F2 (minor, C2 lexical).** The C2 counter's assertion pattern is lexical; the same over-read in different words
  could survive in prose the pattern does not match (the plan already names `SCORECARD.md:1778` as such an instance).
  This seat's source re-opening confirms the underlying page semantics but does not and cannot widen the lexical
  population; the round-52 erratum remains the right instrument.
* **F3 (informational).** All five OpenBao pages were rebuilt on 2026-11-06 (headers `last-modified` 09:06–09:07
  GMT) and my S110 fetch is byte-identical to the L1 capture, so the C1 citation chain is fresh as of this wave; the
  capture hash in the plan and in `corpus/source-fetches.tsv` (`6cfd72ec…7e02b1587`, 83532 B) is reproducible.

## 6. Confidence

* §2 (S110 byte-identity, four quote counts) — **high**: reproduced by two independent sha256/digest runs and eight
  `locate` invocations, all rc 0 with `count=1`.
* §3 verdict set — **high** for the four rejects (each rests on an explicit "count in candidate vs count in S110"
  pair, and on the entry's own cited-fact list, which is complete in §2).
* §4 (rewrap page semantics) — **high**: the whole page was rendered and read; `creation_path` occurs once, the
  word "input" occurs zero times, and the three input/output sentences are quoted verbatim.
* The page-vs-binary agreement asserted in §4 is **not** re-measured by this seat (no server was started; that is
  the C2 counter's PROBE). The page-side half — that the page never states the input's creation path and is
  therefore not contradicted by a binary that preserves it — is what this seat verified.
