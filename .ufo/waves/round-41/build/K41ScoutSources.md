# K41ScoutSources — round 41 (kagi, attempt 1), scout seat

Deliverable dir: `.ufo/waves/round-41/build/K41ScoutSources/`
(`notes.md`, `s095-cmp.txt`, `datawalk-c1.txt`, `capture/S095.body`, `capture/S096.body`,
`capture/S097.body`, `capture/S098.body`).
Scratch `/fast/scratch/hyaku/kagi-r41/K41ScoutSources` deleted on yield. Lane not written
(no git mutation, no `corpus/` edit, no `corpus/SOURCES.md` edit, no `claim-ledger.sh verify`).
Tooling installs: **none** (curl/python3/cmp/sha256sum/wc/git already present).

**S095 re-open: IDENTICAL to the round-40 capture.** `curl -fsSL --compressed
https://docs.python.org/3/library/re.html` exit 0; sha256
`ef2d8abe698b74bbee5259f02599f9b6bf023733d47bb4c7003ac1277bf469b1`; 257722 bytes;
`cmp` vs `.ufo/waves/round-40/capture/S095.body` exit 0 (no differing byte offsets);
`<title>re — Regular expression operations &#8212; Python 3.15.2 documentation</title>`.
Frozen quote locate on the live body: `RENDERED_TEXT_V1_LOCATE: count=1`, exit 0; same on the
committed capture body (exit 0); raw offset 75897 in both.

**S096 re-open: IDENTICAL.** sha256 `570d72c3910b313e905246e75b3238522d6c26194ffd33c1f4112c4f0d3fbab5`;
20100 bytes; `cmp` exit 0; `<title>html — HyperText Markup Language support &#8212; Python 3.15.2 documentation</title>`.
Quote locate live `count=1` exit 0, committed capture `count=1` exit 0; raw offset 13521 both.

**C1 data-walk (read-only, `git show` only):** (a) **8** P0 expects carry an unescaped interior
metacharacter — R11-01, R11-02, R11-04, R11-06, R11-08, R12-01 (unanchored) and R13-03, R31-01
(anchored); full R3 projection 71/86 satisfy, 15 do not (pre-existing debt; R3 fires only on
changed rows). (b) ids in BASE `6cc8850` absent at P0 `6f1588c` = **0** (both ledgers 86 rows,
identical id set). (c) changed ids BASE->P0 = **6** (R13-01, R21-02, R24-06, R31-02, R33-02,
R34-03), equal to the round-40 journal id set exactly (`changed-not-journaled=[]`,
`journaled-not-changed=[]`); all six R3-satisfying and all six R2 bindings (old_expect ==
BASE expect, command == candidate command, new_expect == candidate expect) check True.

**Counters/controls read at the predeclaration tree `5142b52`:** `round-41-c1.sh` -> 0 exit 0
(no gate file yet); `round-41-c2.sh` -> 1 exit 0; controls exit 0 with c1-blanket-refuse 0,
c1-blanket-accept 0, c1-no-gate 0, c2-decoy-superseded 2, C2 BASE 1.

**Supplementary (plan §Shape scout scope).** S097 candidate live: sha256 `e2992e17…`, 815447
bytes, `http=200` final `https://docs.python.org/3/builtins/stdtypes.html` (first hop 301);
locates for the `str.isspace()` sentence, the `Zs` definition sentence and `IDEOGRAPHIC SPACE`
all exit 0. S098 candidate live: sha256 `68e34b8b…`, 199607 bytes; `White_Space` locate exit 0
(count 4) but `\p{White_Space}` locate exit 1 and the literal is absent from the body. Probe:
`str.isspace()` vs UTS#18 `White_Space` differ on exactly `0x1c 0x1d 0x1e 0x1f` (isspace-True only),
corroborating the plan's S098 reject.

**Defects / routing (not fixed in the lane).**
1. Literal U+3000 bytes are absent from both served 3.15.2 `re` and `stdtypes` bodies (re-measured),
   so the U+3000 example must be grounded in S097's `Zs` sentence or the lesson Gate, never in a
   raw-literal claim on S095 — confirms the plan's step-5 treatment and M40-5.
2. `/3/library/stdtypes.html` 301-redirects to `/3/builtins/stdtypes.html`; a `source-fetches.tsv`
   row for S097 must record `url` **and** `final_url` with the final-hop `http_status` 200, or the
   census will classify it non-reproducing.
3. The 15 R3-unsatisfying expects are dormant debt at P0: if the gate's R3 is applied to all rows
   instead of only changed rows, positive control P0 is refused and the C1 counter reads 0. R3 must
   stay scoped to changed rows (plan wording).
4. C2 (b)'s binding already holds on committed bytes (S095 fetch-row column-10 sha == capture body
   sha; locate exit 0), so the C2 rewrite needs no new capture — only a non-superseded `S###`
   citation plus the frozen quote. Superseded ids: S006 S007 S012 S013 S014 S016 S027 S028 S034
   S035 S036 S039 S040 S041 S047 S049 (S095 is not superseded; S027 is — hence the decoy's (a)=0).
