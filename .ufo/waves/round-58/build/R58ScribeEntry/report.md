# R58ScribeEntry — rationale and provenance for the ACL-policy entry

Seat: R58ScribeEntry (scribe). Round 58, attempt 1. Lane
`/home/vgpnk/Projects/shokunin/kagi-shokunin`, HEAD at start `0085a5f76c9dc7e977f6606324e873d25b4fc44d`
(predeclaration only; the round-58 instruments and trial did not exist on disk when this seat
ran). I wrote no git/jj command and no registry row.

Written surfaces:

| path | bytes | lines | sha256 |
|---|---|---|---|
| `corpus/knowledge/openbao-acl-policy-semantics.md` | 17095 | 202 | `f9d3d930e1c4373d6c0118a4425f5e539caaae81a2481df39d872e4a4fa1a051` |
| `.ufo/waves/round-58/build/R58ScribeEntry/capture/S118.body` | 122498 | — | raw `a55ff1a4caf12c3a62bcaab61ff95fef1d382cba01da5dbd4521dbfbca6e1468` |
| `.ufo/waves/round-58/build/R58ScribeEntry/capture/S119.body` | 32520 | — | raw `0472f29373a98f6dd1260aa6ca4d1bd80de9d4642a75c8df94bd22e47e0263e7` |

Normalized (rendered-text-v1) digests: S118 `9e6355bb51a3f6385c1345f0e2162dc10de8e46fd61110d7f41e195e38173292`
(34984 B); S119 `b0dbef2282defcfbafe1bff9553f5c10cdd637b880e654d77a5f34b364a725f1` (1826 B).
Both pages report `Version 2.7.x` in the body.

## 1. How the pages were obtained

The scout's `.ufo/waves/round-58/capture/` did not exist when this seat ran, so I fetched both
pages myself and kept the bodies under this seat's build dir (never `/tmp`):

```
curl -sS -L --compressed -A "<browser UA>" -o S118.body https://openbao.org/docs/concepts/policies/   # 200
curl -sS -L --compressed -A "<browser UA>" -o S119.body https://openbao.org/docs/commands/policy/      # 200
```

No cookie jar was used and nothing from `Set-Cookie`/`Cookie` was written. The fetch profiles and
digests above are what a re-fetch must reproduce; if the scout's independent fetch differs, both
digests stand side by side — I did not paper over a mismatch because none had appeared yet.

## 2. Anchors actually used (live heading ids)

S118 (`https://openbao.org/docs/concepts/policies/`): the page introduction, before the first h2
(the deny-by-default sentence and the empty-policy consequence); `#policy-syntax` (h2 Policy
syntax — the read-only example, the exact/`*`/`+` examples, the priority-rules warning, the
canonicalization warning); `#capabilities` (h3 — the `deny`, `sudo`, `scan` bullets and the
list/scan prefix paragraph); `#templated-policies`/`#examples`; `#parameter-constraints`;
`#fine-grained-control`; `#path-expiration`; `#filtering-list-or-scan-results` (h5);
`#built-in-policies`/`#default-policy`/`#root-policy`; `#root-protected-api-endpoints`;
`#tokens`.

S119 (`https://openbao.org/docs/commands/policy/`): `#examples`, `#usage`.

Heading labels are quoted as the live text renders them; the pages carry a zero-width space on
each heading, which the normalizer keeps, so no heading string is quoted verbatim anywhere in
the entry (only body sentences are).

## 3. Every quote used, with its anchor and located result

All located with `python3 corpus/rendered-text-v1.py locate <capture> QUOTE`; every one returned
`count=1`. Word counts are the normalized quote's token counts, all ≤ 25.

| # | quote | page / anchor | words |
|---|---|---|---|
| 1 | `Policies are deny by default` | S118 page introduction (H1 Policies, before the first h2) | 5 |
| 2 | `so an empty policy grants no permission in the system` | S118 page introduction (same paragraph) | 10 |
| 3 | `the token cannot update or delete` | S118 §Policy syntax (read-only example) | 6 |
| 4 | `an attached token cannot read "secret/food"` | S118 §Policy syntax (exact-path example) | 6 |
| 5 | `It is not a regular expression and is only supported as the last character of the path` | S118 §Policy syntax (danger box) | 17 |
| 6 | `but not "secret/bars/zip"` | S118 §Policy syntax (prefix example) | 3 |
| 7 | `This always takes precedence regardless of any other defined capabilities` | S118 §Capabilities (`deny` bullet) | 10 |
| 8 | `including sudo` | S118 §Capabilities (`deny` bullet, same sentence) | 2 |
| 9 | `can be used to denote any number of characters bounded within a single path segment` | S118 §Policy syntax (`+` paragraph) | 15 |
| 10 | `we take the union of the capabilities` | S118 §Policy syntax (warning note) | 7 |
| 11 | `we take only the highest-priority match from those policies` | S118 §Policy syntax (warning note) | 9 |
| 12 | `Allows access to paths that are root-protected` | S118 §Capabilities (`sudo` bullet) | 7 |
| 13 | `Allows recursively listing ("scanning") values at the given path` | S118 §Capabilities (`scan` bullet) | 9 |
| 14 | `listing always operates on a prefix` | S118 §Capabilities (list/scan paragraph) | 6 |
| 15 | `OpenBao will sanitize request paths to be prefixes` | S118 §Capabilities (same paragraph) | 8 |
| 16 | `are not supported for policies used with the version 2 kv secrets engine` | S118 §Parameter constraints (warning) | 13 |
| 17 | `Ensure that any path segments refer to an engine's canonicalized variants` | S118 §Policy syntax (warning) | 11 |
| 18 | `the policy's name as a pointer or symlink to its set of rules` | S118 §Policy authorization workflow | 13 |
| 19 | `the contents of policies are parsed in real-time whenever the token is used` | S118 §Tokens | 13 |
| 20 | `There is no way to modify the policies associated with a token once the token has been issued.` | S118 §Tokens | 18 |
| 21 | `Uploads a named policy from a file` | S119 §Usage (subcommand list) | 7 |
| 22 | `Prints the contents of a policy` | S119 §Usage (subcommand list) | 6 |
| 23 | `This is an idempotent operation.` | S118 §Deleting policies | 5 |
| 24 | `cannot be removed` | S118 §Default policy | 3 |
| 25 | `By default, it is attached to all tokens` | S118 §Default policy | 8 |
| 26 | `A root user can do anything within OpenBao.` | S118 §Root policy | 8 |
| 27 | `Capabilities usually map to the HTTP verb, and not the underlying action taken.` | S118 §Capabilities (verb warning) | 13 |
| 28 | `the highest-priority match` | S118 §Policy syntax (warning note) | 3 |
| 29 | `any number of characters` | S118 §Policy syntax (`+` paragraph) | 4 |
| 30 | `bounded within a single path segment` | S118 §Policy syntax (`+` paragraph) | 6 |
| 31 | `By granting list or scan capabilities on a path, all results are returned from the plugin` | S118 §Filtering list or scan results | 16 |
| 32 | `including entries which correlate to paths the token cannot access` | S118 §Filtering list or scan results | 10 |
| 33 | `only visible entries` | S118 §Filtering list or scan results | 3 |
| 34 | `Specific paths in a policy can be set to automatically remove access at a point in time.` | S118 §Path expiration | 17 |
| 35 | `The capabilities associated with a path take precedence over permissions on parameters.` | S118 §Fine-grained control | 12 |
| 36 | `regardless of any other defined capabilities` | S118 §Capabilities (`deny` bullet) | 7 |

One further quoted token, `Version`, is the docs' own version label (it appears as
`Version: Version 2.7.x`); it is used in the `recheck:` line as a label name, not as evidence.

The priority-rule paragraph is **paraphrased**, not quoted: the page states the five comparisons
as an ordered list, and a verbatim reproduction would be five separate quotes of comparable
length for no gain in location value. The paraphrases are faithful to the rendered order
(first wildcard earlier → lower; ends in `*` → lower; more `+` segments → lower; shorter →
lower; lexicographically smaller → lower) and the page's own `secret/*` vs `secret/+/+/foo/*`
example is named as the third rule's worked case.

## 4. What I refused to state, and why

- **Any measured verdict.** The trial (`corpus/openbao-policy-trial.sh`), `plans/round-58-c2.sh`,
  `plans/round-58-c1*` did not exist on disk at HEAD `0085a5f`; no receipt existed. The entry
  therefore carries documented mechanics + the trial's frozen designated observables only, and
  says so in its `Scope` and `verified-at:` lines. The measured table is left as the skeleton in
  §6 below and belongs to the L1.
- **The KV v2 path mapping as a page rule.** S118's own templated example splits
  `secret/data/...` (create/update/patch/read/delete) from `secret/metadata/...` (`list`), but
  that is an example on a templated-policy page, not a sentence defining the mapping. The entry
  states the mapping as the lane's, names the page example as corroboration, and names the trial
  as the thing that measures it. A late cross-check (the trial script landed at 12:07, after the
  first draft) found that the trial's policies use `secret/data/...` only and it has no `list`
  test, so the entry now says the `data/` half is the exercised one and marks the `metadata/`
  `list` half **not measured** rather than claiming the whole mapping was executed.
- **Naming the OpenBao release-clock row id (S090) inside the entry.** `sources-census.sh`
  finding `SC_BODY_CITE` makes any registry id in an entry's text that is not on its `source:`
  or `cites:` line a finding, and a `cites:` id also requires that row's `used-by` to list the
  entry — a registry edit that is the L1's, not mine. So the `recheck:` line states the cadence
  (`on-release`) instead of the row id. The clock row is **S090**
  (`https://github.com/openbao/openbao/releases.atom`, newest stable `v2.7.2`); the L1 can either
  keep the cadence wording or add `cites: S090` together with S090's `used-by` cell.
- **A `deny` on a lower-priority pattern beating a higher-priority allow (and the reverse).**
  The page's `deny` bullet says "This always takes precedence regardless of any other defined
  capabilities", and the same page's priority note says only "the highest-priority match" is
  taken. Read together those sentences imply a lower-priority `deny` is never consulted, but
  that is a textual reading, not a measurement, and T3 puts the deny on the narrower
  (higher-priority) pattern so it does not settle the combination. The entry states the reading
  as a reading under §Bounds and lists both directions as falsifiers; I did not present the
  inference as a documented fact or as a measured result.
- **Whether `+` matches an empty segment.** "any number of characters" reads as possibly empty;
  "bounded within a single path segment" reads as requiring a segment. The page's examples are
  all mid-path and non-empty. Stated as open in §Bounds; the trial's zero-segment leg is the
  check.
- **What a `*` that is not in final position does** (literal character, rejected policy, or
  glob). The page only forbids it; the entry states the prohibition and makes the behaviour a
  falsifier rather than a claim.
- **The default policy's exact contents.** The page says OpenBao is not prescriptive about them,
  so the entry says only what the page says (self-lookup and cubbyhole grants, removable only by
  excluding it at token creation) and does not assert the upstream file's rules.
- **`sudo`, `scan`, templated policies, identity templating, parameter constraints.** Documented
  in the sources, not measured here; named as unmeasured in §Bounds.
- **No claim that the entry is landed, stamped, or registry-linked.** Those are the L1's.

## 5. Gate-facing notes for the L1

1. `source:` names S118/S119; `sources-census.sh` needs both rows `mined` with
   `used-by: corpus/knowledge/openbao-acl-policy-semantics.md` (the L1 said it will append them).
2. `Reverify: R21-02` is present exactly once, per the L1's confirmation; R21-02 is a live row in
   `corpus/claim-ledger.tsv`. `corpus/claim-ledger.sh docs` also requires a
   `corpus/stamps.tsv` row for the entry — the L1 adds the stamp. Run at this seat's tree
   (`.ufo/waves/round-58/build/R58ScribeEntry/docs-audit.txt`): `entries=39 row_linked=36
   by_hand=3 undeclared=0 missing_ids=0 unpinned=1 duplicate_reasons=0 floor=20`, exit 1, and the
   single `UNPINNED` line names this entry — i.e. nothing but the missing stamp, which is the
   L1's write.
3. `corpus/README.md` line 67 states `35 row-linked / 3 by-hand / 38 pinned`; with this entry it
   is `36 row-linked / 3 by-hand / 39 pinned`, and the entry table (line 86 is the r57 audit
   entry) needs a row. Both are round-level self-descriptions the L1 owns.
4. Citation-gate ordering: the entry names `corpus/openbao-policy-trial.sh` (in `recheck:`) and
   `.ufo/waves/round-58/build/R58ScribeEntry/capture/S118.body` / `S119.body`. The trial script
   must be committed in the same landing or earlier, and the two capture bodies must be committed,
   or `claim-ledger.sh citations` will read unresolved tokens.
5. The registry rows should record the captures this seat fetched if the scout's bytes differ;
   the same page, two fetches, two tags — never one digest silently replacing the other.

## 6. DRAFT measured table (skeleton for the L1 — not part of the lane entry)

Fill the third column from the trial receipts; do not copy this block into
`corpus/knowledge/openbao-acl-policy-semantics.md` unfilled. Baseline vector `HHHHH`; shims
SH1→`BHHHH`, SH2→`HBHHH`, SH3→`HHBHH`, SH4→`HHHBH`, SH5→`HHHHB`.

| # | mechanic | measured on 2.7.2 (round 58) | receipt |
|---|---|---|---|
| T1 | deny by default; exact path reach; read grant cannot update | `T1 ______` | `.ufo/waves/round-58/…/receipt-real.txt` |
| T2 | `*` suffix prefix glob; exact path misses the longer name | `T2 ______` | … |
| T3 | narrower `deny` outranks a broader allow | `T3 ______` | … |
| T4 | `+` one segment; two segments and zero segments refused | `T4 ______` | … |
| T5 | same-pattern union; different patterns take the exact `update` | `T5 ______` | … |
| — | summary line | `OPENBAO_POLICY_TRIAL: ______ holds=_ broken=_ error=_ bao=_` | … |
| — | no-`bao` PATH leg | `SETUP`, rc 2, no `HOLDS` | … |
| — | PATH-wrapper leg | flips T5 only | … |
| — | counter line | `C2_POLICY_TRIAL: value=5 tests=5 pass=5 shims=5 vectors=ok/5 guard=1` | `plans/round-58-c2.sh` output |

Two sentences I would add to the entry once the receipts exist (and only then): the T3
lower-priority-deny question resolved or left open by the measured vector, and the T4
empty-segment result stated against §Bounds.

## 7. Cross-check against the landed instruments (read-only)

The instruments appeared on disk after the entry's first draft; I re-read the entry against them
and corrected one claim (the KV v2 `list` half, §4). Nothing here is a measured verdict.

- `corpus/openbao-policy-trial.sh`, 271 lines / 13640 B, sha256
  `1f1eed9d872a1a1367d737d63a45f1d8eb2c9fe6fa322d5e96a95dba934d0b4a`, untracked at HEAD.
  Its test policies: T1 a zero-rule policy plus a `read` grant on `secret/data/t1`; T2
  `secret/data/bar/*` and `secret/data/food` with the longer `secret/data/food2`; T3
  `secret/data/t3/*` read plus `secret/data/t3/locked` deny; T4 `secret/data/+/teamb`; T5
  `secret/data/t5a` in two policies and `secret/data/t5b*` vs exact `secret/data/t5b`. Every
  policy path is `secret/data/...`; there is no `list` and no `secret/metadata/...` test.
- Its per-test detail strings (the instrument's own assertions, not results): T1
  `empty-token-denied=1 read-allowed=1 value-roundtrip=1 update-denied=1`; T2
  `descendant=2 sibling-denied=1 exact-allowed=1 longer-name-denied=1`; T3
  `broad-allowed=1 denied-path-denied=1`; T4
  `one-segment=1 two-segments-denied=1 zero-segments-denied=1`; T5
  `union-read=1 union-update=1 union-delete-denied=1 prio-read-denied=1 prio-update=1 caps=update`.
  These match the entry's "what the trial asserts" column, including T5's exact `update` winning.
- `plans/round-58-c2.sh` (7639 B) is present and untracked; the counter line shape is the plan's.
- Receipts were written at 12:10 under `.ufo/waves/round-58/build/R58ExecTrial/`
  (`receipt-ref-real.txt`, `receipt-ref-real2.txt`, `receipt-ref-none.txt`,
  `receipt-ref-wrap.txt`, `receipt-sh1.txt`…`receipt-sh5.txt`, `legs-rc.txt`,
  `wrapper-capabilities-lie.sh`). I did **not** read the verdict-bearing receipts: the entry
  must not carry a verdict and the table belongs to the L1. `legs-rc.txt` carries only the two
  leg exit codes (`none-leg rc: 2`, `wrap-leg rc: 1`).
- Scoped citation check on the entry: `bash corpus/claim-ledger.sh citations --docs
  corpus/knowledge/openbao-acl-policy-semantics.md` ⇒
  `CITATION_GATE: CLEAN (cites=8 docs=1 unresolved=0 ephemeral=0 labeled=0)`, exit 0. (The full
  tree-wide run is slower than a 240 s slice and was not used; it also reports a pre-existing
  `LOG.md:1945 corpus/lessons/round-58.md (local)` unresolved token that is outside this seat.)

## 8. Housekeeping

- No tool installed or upgraded; no `pacman` transaction; no host sysctl touched.
- No scratch tree was created (`${HYAKU_SCRATCH}/kagi-r58/R58ScribeEntry/` unused, nothing to
  delete); no file was written under `/tmp`.
- No secret, token, cookie, session id or vault/item/field name appears in the entry, this report,
  or the captures.
- Every path in the entry was written absolute-relative to the lane (`.ufo/…`, `corpus/…`).
