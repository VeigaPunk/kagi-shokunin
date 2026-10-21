# RevS017 — S017 provenance falsification (round 23)

Seat: falsification, leaf. Read-only on the lane. No production edit, no host gate, no
install, no secret access, no git/jj mutation (only `git show`/`status`/`diff` reads).
C1 and C3 were left to their seats; C2's named host-free gates were run because they are
part of the claim under attack.

## 0. Snapshot and movement (the tree was integrated while auditing)

Measurement snapshot pinned 2026-10-21T04:12Z (later lesson drift is recorded in item 7
below); local mtimes are -0300.

| file | sha256 | mtime |
|---|---|---|
| `corpus/source-fetches.tsv` | `6e26e14032729070f38b5e0cb90914385f04c0ef9f4fe1db210af6439191094d` | 01:10:37 |
| `corpus/sources-census.sh` | `511deb2730614663c86beb9b6793b54eea75ce8a9dbe4f1cf372999697339b58` | 01:10:59 |
| `corpus/lessons/round-23.md` | `49632920e11189562ade4410c002f51206b33c66e9ce57805efcc940fa81f699` | 01:11:27 |
| `LOG.md` | `57dc73966c6f9e56dcd83b035ca851054ee80fe512866de5607039d1486ef43f` | 01:11:27 |
| `SCORECARD.md` | `7dc220f625bea84146e17e9fe67230a7eb6e504ff4aab718beda6e05987805d7` | 01:11:27 |
| `corpus/SOURCES.md` | `c6ea91ab2468352263a7442a2ff7815084d68374c94433bbb6b4cccc639c632d` | 01:11:27 |

Movement observed while auditing (recorded, not inferred):

1. **~00:56 local.** LOG, SCORECARD and the lesson read "7 URLs" / "seven distinct URLs";
   the TSV header called the normalized digest "the stable declared identity"; the census
   (`24d834cc…`) enforced same-URL normalized equality for volatile rows.
2. **01:02:31–01:04:32.** The counts were corrected to "9"/"nine"; the TSV header became
   "the normalized digest is a more stable point attestation, still chrome-sensitive,
   never a drift pin. No cross-capture equality is enforced."
3. **01:06:58.** TSV `846b2037…`, lesson `993e114a…`; S017 row unchanged.
4. **01:08–01:10.** TSV `7101bdd0…`; lesson added the M23-1 cross-capture fix record.
5. **01:10:59.** Census replaced (`511deb27…`): the `FDIG`/`FNRM` same-URL comparison was
   removed and `fetch-disagree` re-pinned to expect 1 finding.
6. **01:11:27.** TSV `6e26e140…`, lesson `49632920…`, LOG, SCORECARD and SOURCES moved
   again. The S017 row **content is invariant in every snapshot** (only its line number
   moved, 37 → 38); counts stay 10 rows / 9 distinct URLs.
7. **01:14:03 (latest observed).** The lesson moved to
   `93df7d345554b99c1daf87fb75234ba273cff0d2fc8be691a4d5df56f0242cb4`. This report's
   lesson line numbers are pinned to the 01:11:27 read; against the latest read the same
   content sits at M23-1 `:146` (was `:145`), source accounting `:172-175` (was
   `:171-174`) and the W04 acceptance `:178-179` (was `:177-178`). The sentences
   themselves — including "no cross-capture equality is enforced" at `:54` and D1 at
   `:66` — are unchanged.

Both named gates were re-run on the final state:

```
bash corpus/sources-census.sh            # exit 0
SOURCES_CENSUS: CLEAN (rows=26 A=24 B=0 C=2 queued=1 mined=24 rejected=1 entries_sourced=4 legacy=21)
bash corpus/sources-census.sh --selftest # exit 0
SOURCES_CENSUS_SELFTEST: PASS (59 cases)
```

## 1. Verdict

**The S017 row reproduces field-for-field.** I found no wrong digest, no stale capture,
and no row-identity defect. C2's implementation/declaration contradiction was real at
01:06:58 and was **repaired in-flight at 01:10:59** (R1). The remaining defects are
narrative: W04 attribution (L1), a pre-move anachronism (L2), the stale dispatch count
(I1), and an honest bound (I2).

## 2. S017 re-measurement (declared vs independently measured)

Declared row: `corpus/source-fetches.tsv` (S017; line 38 in the final snapshot, line 37
earlier — content identical). Registry row: `corpus/SOURCES.md:23`, row+LF sha256
`1127ecdbcc15508703abc97b40867ca01513385b2598c83b60e9ed6e29bdb73a`, identical at base
`d218603b` and in every head snapshot (the registry row was not touched this round).

| field | declared | measured independently |
|---|---|---|
| id / status | `S017` / `mined` | registry status cell `mined` (`SOURCES.md:23`, field 9) |
| url | `https://www.1password.dev/brokered-access/github-actions/` | registry-extracted string identical (trailing slash included) |
| final_url | `https://www.1password.dev/brokered-access/github-actions` | `%{url_effective}` identical after one 308 (`location: /brokered-access/github-actions`) |
| http_status | `200` | 200 on the redirect target |
| request_profile | `curl-fsSL-compressed-v1` | ran exactly `curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)'` |
| fetched | `2026-10-21` | today; live page re-fetched twice, byte-identical |
| representation | `decoded-http-body-volatile-v1` | response `content-encoding: br`; decoded body 1,215,460 B vs 164,494 B transfer |
| sha256 | `62953bb47db1af593c522b06c4f12c6a89853dd0a8fb718118189349213f478d` | identical on two independent GETs (`sha256sum s017.html s017b.html`; `cmp` IDENTICAL) |
| bytes | `1215460` | identical file size |
| revision | `-` | not a moving-ref URL; `-` correct |
| quote | `Use 1Password Credential Broker to access secrets in GitHub Actions at runtime (public preview)` | present 3× in `rendered-text-v1`; 14 words (`awk -F'\t' '$1=="S017"{print $13}' … \| wc -w` → `14`); at `<title>` and the single `<h1 id="page-title">` |
| normalization | `rendered-text-v1` | declared order reproduced: strip `script`/`style`, tags→single space, `html.unescape`, `\s+`→space, trim, UTF-8 |
| normalized_sha256 | `2a39cb1691b24f492dd4ad5a126538df35f865c15cd5f46a35e405a5282781c7` | reproduced, 5,577 B normalized text. Order matters: unescaping before tag strip gives `4dcea60f…`, so the declared order is the attested one |
| location | `page title/H1` | accurate; the quote is the H1 and the `<title>` prefix |
| row_identity_sha256 | `916f8afe83ee4c74312087b450b2351b164caf85d397511da447700a76cf423f` | reproduced twice: from the TSV literal and from the census's own registry extraction (`sources-census.sh:251`), `printf 'S017\tmined\t<url>\n' \| sha256sum` |

Checks run and exits:

```
curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)' \
  -o s017.html 'https://www.1password.dev/brokered-access/github-actions/'   # exit 0
sha256sum s017.html                                                          # 62953bb4…, exit 0
stat -c%s s017.html                                                         # 1215460
# second GET -> s017b.html; cmp -s s017.html s017b.html                      # IDENTICAL
printf 'S017\tmined\thttps://www.1password.dev/brokered-access/github-actions/\n' | sha256sum
                                                                            # 916f8afe…, exit 0
python3 <normalizer as declared>                                            # 5577 B, 2a39cb16…
```

The quote, the Business-account prerequisite and the "public preview" status are all
present in the fetched text (introduction: "If an administrator has connected your GitHub
organization to your 1Password Business account, …"; badge "Public Preview"). No
staleness: the 2026-10-20 round-22 catalog digest `937f68…` (1,215,155 B,
`.ufo/waves/round-22/build/BuildQualifierGate.md:33`) differs from today's `62953bb4…`
(1,215,460 B), consistent with the declared volatile *raw* representation, while the
article subtree digest is unchanged (R1).

## 3. Findings (severity order)

### R1 — Resolved in-flight: the gate enforced the same-URL rule its declarations denied (was Medium; residual Low)

Observed at the 01:06:58 snapshot:

- Declared bound: `corpus/source-fetches.tsv:19-21` ("still chrome-sensitive … **No
  cross-capture equality is enforced**") and `corpus/lessons/round-23.md:52-54` (same).
- Implemented rule: `corpus/sources-census.sh:275-291` (snapshot `24d834cc…`) emitted
  `same-url-normalized-disagreement` at `:288` for every `rendered-text-v1` row,
  including volatile rows; only the raw comparison was volatile-exempt (`:279-283`). Its
  comment justified this with "site chrome and per-response tokens change the bytes,
  **not the article**".
- Measurement: `rendered-text-v1` is whole-page, so the assumption was false. Wayback
  `id_` payloads: 2026-10-06 (1,204,919 B) and 2026-10-12 (1,202,335 B) normalize to
  `7227ed88319b10c3ca6f6418fc41c0b8d12ac2ee17d9354a18b0927797d833c9`; the 2026-10-21
  capture normalizes to `2a39cb16…81c7`. The `id="content-area"` subtree normalizes to
  `3e15d76578e0c09290272c158b824b0609c0e6a033f324ff324f34dc6b93594e` on all three dates;
  the 10-12→10-21 word diff is exactly one insertion:
  `… Plugins Claude Code (beta) Cursor (beta) Credential Broker …`.
  Consequence: a re-opened S017 row after any sidebar edit would have raised
  `same-url-normalized-disagreement` on an unchanged article.

Fix observed at 01:10:59 (`511deb27…`): the `FDIG`/`FNRM` comparison is gone;
`fetch-disagree` now expects 1 finding (`sources-census.sh:553`, mutation at `:426`) and
the selftest enforces that count; the lesson records the policy as mistake M23-1
(`corpus/lessons/round-23.md:145`). Final gates: CLEAN exit 0, selftest PASS 59.

Residual (Low): `FDIG`/`FNRM` remain declared but unused (`sources-census.sh:229`) —
dead declarations from the removed rule; the case name `fetch-disagree` now denotes the
opposite of its content (it pins the absence of an extra finding). The contradiction was
first raised at `.ufo/waves/round-23/parent-build/SourceS017.md:113-140` (C-1); I
independently re-measured it while it was live and confirm the final tree resolves it.

### L1 — W04 is attributed to the census, but the census cannot print it (live)

`corpus/lessons/round-23.md:66-67` says "The census prints five W04 duplicate-URL
warnings", and `:177-178` makes "exit 0 with the same W04 warnings" an end-of-round
condition for the census. Measured on the final snapshot: `bash corpus/sources-census.sh`
emits exactly one line (the CLEAN line) and zero W04 lines; `grep -rn 'W04' corpus/*.sh`
finds no producer in base or head; `command -v kagi` returns nothing. The round-22 lesson
attributes W04 correctly to `kagi ok …/corpus/SOURCES.md`
(`corpus/lessons/round-22-verifier-spotcheck.md:115`). The C2 acceptance command cannot
satisfy the wording at `:177-178`; the parent must quote `kagi ok` for W04, not the
census.

### L2 — New "pre-move" scorecard row cites round-23 artifacts (live)

`SCORECARD.md:824` heads a new table "Round 23 — pre-move (repo HEAD `d218603`,
round-22 close)", but its coverage row at `:829` says "S024-S026 correct locators, not new
governed surfaces" and is tagged "round 11". At `d218603` the registry ends at S023
(`git show d218603b:corpus/SOURCES.md | grep -c 'S024'` → `0`); S024-S026 are added by
this round. A pre-move cell that names post-move ids is an anachronism in the historical
snapshot. (The post-move coverage row at `:840` is now correct: it calls S024 the new
frontier row and says the captures cover nine URLs.)

### I1 — The dispatched C2 count ("over 7 URLs") is wrong; measured 9 (tree says 9)

`.ufo/waves/round-23/falsify-spec.json` (mtime 00:56:29) and the dispatched prompt say "10
declared captures S017-S026 over 7 URLs". Measured: 10 rows over **9** distinct exact URL
strings; the only duplicate is `openbao.org/docs/concepts/tokens/` (S021 and S026). Under
the lane's own exact-string convention (base 23 rows → 18 URLs; head 26 → 19, as
`corpus/lessons/round-23.md:171-174` states), 9 is the count; even a prefix-family
collapse gives 8, not 7. The artifacts were corrected during the audit to "nine"/"9"
(`LOG.md:1202`, `corpus/lessons/round-23.md:174`, `SCORECARD.md:840`). The dispatch text
and any parent report that repeats "7" are stale.

### I2 — Honest bound: the gate shape-checks the capture columns, it does not fetch

`final_url` and `http_status` are regex checks only (`sources-census.sh:253-254`);
`sha256`/`bytes` are shape checks (`:258`); `normalized_sha256` is a shape check (`:270`).
S017's values are verified by my independent GET, not by the gate. This is disclosed as a
point attestation (`corpus/lessons/round-23.md:50-52`), so it is a bound, not a defect —
but C2's "declared representation/normalization" should not be read as the census
verifying representation contents.

## 4. Residual risk and verification gaps

- No capture bytes are retained in-repo (only the TSV digests). An offline auditor cannot
  recompute either digest; the gate cannot either. My re-fetch is the only verification,
  and the live page can drift.
- The volatile label is conservative for S017 today: two same-day GETs are byte-identical;
  the observed variation is cross-day chrome (R1).
- The Wayback payloads are third-party archival bytes, used only for the 10-06/10-12
  cross-day comparison; they are not the S017 row's declared representation.
- The documented normalization is order-sensitive (tags→space before `html.unescape`);
  other plausible orders produce a different digest. The TSV states the order, and the
  declared value reproduces only under it.
- The final tree was still moving when this report was written (integration wave at
  01:11:27); the hashes above pin the last observed state, and the S017 row content is
  invariant across every snapshot read.
- Out of seat: C1 closure dispositions and C3 cells fixture were not audited; the parent's
  43 claim-ledger row audits were not repeated.

## 5. Compliance

Writes: this report only in the lane, plus `/tmp/revs017` scratch. One first write
resolved against the session cwd (the fleet root) and briefly created
`.ufo/waves/round-23/falsify/RevS017.md` there; it was moved to this lane path within the
same minute, and no file from this seat remains in the fleet tree. No installs. No
host/package/service changes. No secrets, vault, or account commands. `git` used read-only
(`show`, `status`, `diff`). The census and its selftest are host-free and were the only
lane gates run.
