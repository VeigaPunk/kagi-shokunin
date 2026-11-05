# Round 36 — sentinel review (seat SentinelBound)

Subject: everything round 36 would push. The lane tree moved while this review
ran (the L1 is the sole integration owner and was landing), so the review is
recorded in two phases with the exact bytes each phase measured. Nothing below
is a summary of a summary: every number is from a command run here.

| phase | time (UTC) | lane HEAD | working-tree modifications | new files |
|---|---|---|---|---|
| T0 | 2026-11-04T~21:10Z | `09f27e2e16c26484b2675aa2a2b1e2ca4d3d1d8d` | `corpus/release-clock.py`, `corpus/release-clocks.tsv` | — |
| T1 | 2026-11-05T00:16Z | same | `SCORECARD.md`, `corpus/SOURCES.md`, `corpus/claim-ledger.tsv`, `corpus/release-clock.py`, `corpus/release-clocks.tsv` | `plans/round-36-c3.sh` |

Frozen instrument commit `cb8cb659e84240a8db12e4f7b4a0def5068baf7e`; frozen plan
`09f27e2e…`. T1 subject hashes (`sha256sum`, recorded in
`../SentinelBound/subject-sha.txt` and `snapshot2.txt`):

```
a53c0aa0df9ed85a193c4d3300943ebe4268e5e463222483a881ae792b2a3983  SCORECARD.md
1d3baf2bb4168a85dd7f8615950b5443b1015b384ee120e541813174d99e58e3  corpus/SOURCES.md
757788698c53ca604aab92816f927a074a4125a0c10de4efcf5811da3aa54c62  corpus/claim-ledger.tsv
5356c3aa812b5109ddcf70b7caa105667eb0dd1655bff313bce4620c3e4b1284  corpus/release-clocks.tsv
b18444f8f821c314719c91acf83bba3ad76731c7f787995b2783b1db8d2fa960  corpus/release-clock.py
adc20b1eb861dcad30cfada0b1912240e5bde8a88ddf3ec1344302bee266f759  plans/round-36-c3.sh
3f611eec30d4a48f4f389bb1a630551d77110d92fb97eee954eeb6f7c8558727  .ufo/waves/round-36/controls/observe-live.json
```

The receipt digest recomputed here **matches** the frozen claim, the F4 pin
`DEFAULT_RECEIPT_SHA256`, and `plans/round-36.md`. F1 (the two `## Round 36`
tables) and F2 (the capability count) are present at T1 and were reviewed as
bytes; at T0 they were absent, which is why the T0 phase could only review the
described content.

---

## Check 1 — credential material, private paths, user names, tokens

Swept at T1: every pushed file — `SCORECARD.md`, `corpus/SOURCES.md`,
`corpus/claim-ledger.tsv`, `corpus/release-clocks.tsv`, `corpus/release-clock.py`,
`plans/round-36-c3.sh`, and the receipt — plus every note string in the TSV (all
31 non-empty lines, 9 tab fields each).

```
$ for f in <pushed files>; do for pat in 'op://' 'sk-' 'ghp_' '/home/' '@'; do
      grep -c -- "$pat" "$f"; done; done

file                                op://  sk-  ghp_  /home/  @
SCORECARD.md                          0     6    0      0     1
corpus/SOURCES.md                     0     0    0      1     0
corpus/claim-ledger.tsv               0     0    0      0     0
corpus/release-clocks.tsv             0     0    0      0     0
corpus/release-clock.py               0     0    0      0     0
plans/round-36-c3.sh                  0     0    0      0     0
observe-live.json                     0     0    0      0     0
```

Every non-zero hit, with its line and why it is not credential material:

| hit | content | status |
|---|---|---|
| `SCORECARD.md` ×6 `sk-` | substring of `handler-on-disk-state` / `…-disk-state.md` in historical round rows (L67, 481, 506, 521, 541, 560) | **pre-existing**, none in the round-36 diff (`git diff -U0 -- SCORECARD.md \| grep '@'` returns only `@@` hunk markers) |
| `SCORECARD.md:112` ×1 `@` | `exec op run --env-file="$ENV_FILE" -- "$@"` inside a historical prose snippet | **pre-existing** shell positional parameter, not an address or token |
| `corpus/SOURCES.md:117` ×1 `/home/` | ``grep -cE '^\| S[0-9]{3} ' /home/vgpnk/Projects/shokunin/.tower/worktrees/kaika/fleet-ledger/.ufo/waves/kaika-w1/kagi-art.md`` — a round-21 research note | **pre-existing host-private path + user name**, untouched by this round (`git diff -U0 -- corpus/SOURCES.md \| grep -c '/home/'` → 0). Routed below; not in this round's push |

Host/user-shape sweep over the receipt and the TSV (`grep -cE`): `vgpnk` 0/0,
`/Users/` 0/0, `C:\\` 0/0, `file://` 0/0, `localhost` 0/0, `127\.0\.0\.1` 0/0,
`BEGIN` 0/0, `PRIVATE` 0/0, `user=` 0/0, `passwd` 0/0. The only `password`
substring hits are the vendor names — `grep -o -E '[0-9a-zA-Z]*password[0-9a-zA-Z.]*'`
yields exactly `1password` ×2, `1password.com` ×3, `1password.dev` ×5.

High-entropy sweep — `[A-Za-z0-9+/=_\-]{32,}`, every distinct match classified:

```
receipt (34 matches): 12 distinct 64-hex = sha256 of fetched public response
        bodies (content digests, no pre-image); 3 non-hex, all public URL paths
        (com/blog/1password-credential-broker-public-preview,
         dev/brokered-access/custom-workflow/, dev/brokered-access/github-actions/)
release-clock.py (5): 1 distinct 64-hex = 3f611eec… (the F4 pin);
        3 non-hex = the same two URL paths + the selftest callable name
        `receipt_action=mutate_receipt_values`
release-clocks.tsv: 0 matches of any length ≥32
```

**Result: 0 credential-shaped hits in the pushed bytes.** The only high-entropy
material is content-addressing of public documentation bodies and of the receipt
itself.

TSV structural check (a note field is the injection surface for a smuggled row):
31 non-empty lines = header + 30 rows; every row exactly 9 tab fields; 0
duplicate ids; 0 control characters; 0 non-ASCII; 20 `feed` rows all `https://`;
10 `rendered-quote` rows all `-`/`-`; `anchored_version` unchanged on all 30.

## Check 2 — the fetches were unauthenticated public reads

**Receipt records** (`json.load` over 30 observations):

```
format        release-clock-observations-v1
record keys   clock, http_status, id, located, observed_at, parsed_version,
              sha256, url, verdict  — these nine on all 30, no other key
http_status   200 (30/30; no other value appears)
scheme        https (30/30)
hosts         github.com, www.python.org, curl.se, 1password.com,
              www.1password.dev, html.spec.whatwg.org, infra.spec.whatwg.org
userinfo      none (`@` in any url: [] ; query/fragment: [])
auth-ish keys none — no field name matching auth|header|cookie|token|secret|
              key|bearer|cred exists on any record
bodies        not stored; only their sha256
verdicts      fired 15, quote-located 10, not-fired 5
```

**Request path** (`corpus/release-clock.py`, unchanged by F4):

- `request_body()` L740-779: the only header ever set is
  `{"User-Agent": USER_AGENT}` (L751). No `Authorization`, no cookie, no netrc.
- `make_public_opener()` L292-297: `ProxyHandler({})` — **empty proxy map**, so a
  credentialed `HTTP(S)_PROXY`/`ALL_PROXY` in the environment cannot be attached;
  plus `NoRedirectHandler` and `PinnedHTTPSHandler` (address-pinned TLS between
  validation and connect, so no DNS-rebinding swap).
- `valid_public_https_url()` L172-: rejects `username`/`password` userinfo, any
  query string, non-443 ports, loopback/`.local`/non-global literals, and calls
  `path_carries_secret()` (L151-169) which rejects ≥32-hex, ≥40-char token slugs
  and JWT-shaped 3-dot segments, plus 1Password account/app/auth/login/vault
  routes. `redirect_allowed()` keeps a redirect on the same origin.
- `grep -n "environ\|getenv\|netrc\|Authorization\|cookie"` → the only
  `Authorization`/proxy occurrences are **selftest assertions** (L1497,
  L1620-1655) that *require* `get_header("Authorization") is None`,
  `proxy_lookup == []` and no `ProxyHandler` in the opener.

Executed, not read:

```
$ python3 corpus/release-clock.py --selftest
rc=0
RELEASE_CLOCK_SELFTEST: PASS (116 cases)
stderr: (empty)
```

## Check 3 — the refusal boundary

The brief cites `PROVINCE.md §Refusals`; no such heading exists
(`grep -n "Refusals" PROVINCE.md` → rc 1). The boundary is:

> `PROVINCE.md:6` — **Refuses:** anything outside this domain; report
> cross-domain evidence back to the orchestrator rather than absorbing it.

> `PROVINCE.md:83` — **Deliberate refusals:** vault-side structure (which
> vaults/items/fields exist) stays unmapped — mapping it would put ref paths in
> a durable artifact; `op` item-level reads stay unexercised; the CDP
> lease/profile ownership question is reported to the integrator, never
> adjudicated here.

and the concrete bar (`corpus/QUALITY.md:24`):

> | QA5 | No credential material, ever: no secret value, token, session id,
> vault/item/field name, or 1Password secret reference (the `op` scheme URI;
> this file does not spell it, so the pre-commit sweep stays empty) — including
> in examples copied from vendor docs. |

Applied:

- **Ref paths in a durable artifact** (L83): 0 `op://` occurrences in the
  receipt, the TSV, `SCORECARD.md`, `SOURCES.md`, `claim-ledger.tsv`,
  `release-clock.py` and `round-36-c3.sh`. No vault/item/field name is written
  anywhere in the push; the notes name public release tags and doc pages only.
- **`op` item-level reads unexercised** (L83): the 30 records are anonymous GETs
  of 7 public hosts; `release-clock.py` contains no `op` invocation
  (`grep -n "op run\|op read"` → none), and `round-36-c3.sh` only `exec`s the
  Python gate.
- **Domain fit** (L6): release-clock observation is the lane's own declared gate
  (`PROVINCE.md` lists `corpus/release-clock.py`), not a sibling mechanism.
- **The four cited SOURCES rows** (`corpus/SOURCES.md:40,41,47,48` — S034
  hashicorp/vault releases.atom, S035 openbao/openbao releases.atom, S040
  docs.python.org/3/library/re.html, S041 docs.python.org/3/library/html.html)
  expose public URLs, public tag names (`v2.2.0`, `v2.7.1`), page titles
  (`Python 3.15.1 documentation`), located quotes of public prose and
  tier/date/cadence cells. At T1 their only change is the recheck date cell
  `2026-10-21 → 2026-11-04` (`git diff -U0 -- corpus/SOURCES.md` shows four
  rows, one cell each) — no new field class, no account, tenant, ref path or
  private host.

## Check 4 — execution surface of F1-F4 (and the T1 additions)

| item | bytes | new execution surface |
|---|---|---|
| F1 | `SCORECARD.md` `## Round 36 — pre-move` / `— post-move` tables, naming `R25-02` (FAIL), `R29-01`, `R29-02` (POLICY) | none — markdown tables; the only commands named are relative, pre-existing gate invocations |
| F2 | capability row `--selftest` `59 cases` → `70 cases`, 59 retained as the `R21-03` record | none — one integer cell; the row's command stays `bash corpus/sources-census.sh` |
| F3 | TSV data | none — no cell is executed |
| F4 | 3 string literals (pin, default path, help text) | none — no new import, subprocess or file read |
| T1 add: `claim-ledger.tsv` rows `R36-01..03` | 3 rows: `bash plans/round-36-c1.sh`, `bash plans/round-36-c2.sh`, `bash plans/round-36-c3.sh` | relative commands, no options, no expansion, no `op` surface |
| T1 add: `plans/round-36-c3.sh` | 6-line wrapper: `exec python3 corpus/release-clock.py` | inherits the gate's own confinement; `bash -n` rc 0; no absolute path, no unquoted expansion |

Evidence:

```
$ git diff -U0 -- corpus/release-clock.py | grep -E '^\+[^+]'
+DEFAULT_RECEIPT_SHA256 = "3f611eec30d4a48f4f389bb1a630551d77110d92fb97eee954eeb6f7c8558727"
+        return root / ".ufo" / "waves" / "round-36" / "controls" / "observe-live.json"
+    parser.add_argument("--receipt", metavar="FILE", help="retained observation receipt (default is the round-36 rearmed receipt)")

$ git diff -U0 | grep -E '^\+' | grep -E '/(home|usr|etc|var|tmp|fast|opt)/'
(no executable line; the only /home/ in the whole push is the pre-existing SOURCES.md:117 research note)

$ git diff -- corpus/claim-ledger.tsv | grep -E '^\+[^+]'
+R36-01	bash plans/round-36-c1.sh	^0$	0	300	…
+R36-02	bash plans/round-36-c2.sh	^0$	0	120	…
+R36-03	bash plans/round-36-c3.sh	^RELEASE_CLOCK: CLEAN \(…\)$	0	120	…

$ bash -n plans/round-36-c3.sh   → rc 0
$ grep -nE '/home|/tmp|`|\$\(' plans/round-36-c3.sh
7:root=$(cd "$(dirname "$0")/.." && pwd)      # same root resolution as the frozen c1/c2
```

The F4 default path is **relative to the resolved root**
(`receipt_path(root, None)` → `root / ".ufo" / …`), so the committed code carries
no absolute path; `--receipt` stays gated on `--receipt-sha` (L2116-2124, 64
lowercase hex enforced). Ledger row `R36-03`'s expected line matches the gate's
actual output exactly, so the new wrapper cannot mask a different verdict.

Fail-closed behaviour of the repointed default, executed against scratch copies
of the lane tree (`--root` pointed at the copy; the lane was not touched):

```
A. default receipt ABSENT     -> rc=1  RELEASE_CLOCK: FAILED (… observed=0 …)
                                 per-row "NOT OBSERVED S0xx"   (not CLEAN, not 0)
B. default receipt TAMPERED   -> rc=1  RELEASE_CLOCK: FAILED (… observed=0 …)
   (one parsed_version mutated)  per-row "RECEIPT-MISMATCH S0xx" — the
                                 DEFAULT_RECEIPT_SHA256 pin fires
C. real lane tree             -> rc=0  RELEASE_CLOCK: CLEAN (on_release=30
                                 bound=30 unbound=0 observed=30 fired=15 derived=15)
```

## Findings

No blocking finding against the pushed bytes. Six items; five informational, one
routed for an operator/L1 decision.

0a. **F3 changes 15 rows beyond the 15 drifting ones (scope, not security).**
   Per-row diff against `HEAD:corpus/release-clocks.tsv` — 30/30 rows touched:

   ```
   ('observed_version','observed_at','verdict','note') x12  S012 S013 S014 S015
        S016 S021 S022 S023 S024 S025 S026
   ('observed_version','observed_at','note')          x3   S027 S028 S040
   ('observed_at','note')                             x15  S005 S006 S007 S008
        S009 S010 S011 S017 S018 S019 S020 S029 S030 S031 S032
   ```

   (15 rows moved `observed_version` — exactly the C2 population; the 3 keeping
   `fired` are S012, S027, S028 as the frozen plan states. `anchored_version`,
   `clock`, `feed_source_id`, `feed_url` changed on no row.)

   The third class already agreed with the receipt; only `observed_at` moved
   2026-10-21 → 2026-11-04 and the note gained "re-observed unchanged by the
   round-36 receipt". Receipt-grounded and truthful (all 30 records carry
   `observed_at` 2026-11-04), but C2 counts only `clock=feed` rows' version and
   verdict, so **those 15 edits are unmeasured by the claim they ship with**, and
   the brief said "Nothing else changes". Reported so the byte delta is visible;
   no change required on security grounds.

0b. **Pre-existing committed session-cookie capture (routed, out of this round's
   push).** The round-36 receipt stores no headers at all
   (`grep -rlI -i "set-cookie\|authorization:" .ufo/waves/round-36/` → rc 1,
   none). Round-26 evidence does: `git grep -lI -i "set-cookie:" -- '.ufo/**'`
   → **68 tracked files** —

   ```
   .ufo/waves/round-26/build/ClockS011-evidence/feed.headers:15:set-cookie: _gh_sess=upBf1dqeafWghPVQ8tqorf7rFnJhjGaATXMIV6Me2IWr9VWVe%2F…
   .ufo/waves/round-26/build/ClockS011-evidence/feed.headers:16:set-cookie: _octo=GH1.1.610277763.1792589794; …
   .ufo/waves/round-26/build/ClockS011-evidence/feed.headers:17:set-cookie: logged_in=no; …
   .ufo/waves/round-26/build/ClockS005.headers.txt:10:set-cookie: unleash-session-id=417117027; path=/;
   ```

   Every GitHub line says `logged_in=no`; the `_ct`/`unleash-session-id` values
   are anonymous short-lived markers. No account scope, no bearer token, no
   `Authorization` header. Severity **low**, but by shape it is the "session id"
   class QA5 forbids in a durable artifact, and it is committed history —
   redacting now would not remove it from git. `corpus/` itself is clean
   (`git grep -lI "_gh_sess\|unleash-session-id" -- ':!*.headers.txt'` matches
   `.ufo/` only). Needs an L1/operator decision (accept as historical anonymous
   capture, or add a `transcript-scan`-class gate and decide history). This seat
   holds no edit rights in the lane.

0c. **`corpus/SOURCES.md:117` carries a host-private absolute path and the user
   name** (`/home/vgpnk/Projects/shokunin/.tower/worktrees/kaika/…`) in a tracked
   durable artifact. Pre-existing round-21 research note, untouched by this round
   (diff count 0). Same routing as 0b: low, and a redaction would need a history
   decision. Reported because the brief's `/home/` sweep must surface it.

1. **`plans/round-36-c2.sh` trusts the receipt by path, not by digest.** It
   checks `-s` and `format` only; the sha256 pin lives only on
   `release-clock.py`'s default path (F4) and in `plans/round-36.md` prose. A
   forged receipt placed at the committed path would satisfy C2. Frozen
   instrument, not a candidate edit; routed to the calibration/claim owner.
2. **`receipt_path(root, selected)` accepts a relative `--receipt` that may
   escape `root` via `..`.** Bounded: `--receipt` requires a caller-supplied
   `--receipt-sha` matching the bytes. Pre-existing, untouched by F4.
3. **`write_receipt()` refuses an existing path or symlink**
   (`os.path.lexists` → SETUP) and writes via `NamedTemporaryFile` + `os.link` in
   the target directory (L919-941) — no symlink-following write, no clobber. It
   is why the receipt is `0600` on disk and `100644` in git (public digests only).
4. **F4 supersedes the round-26 receipt without destroying it** (C2 kill rule:
   "any historical receipt is rewritten or deleted rather than superseded → C2
   fails"): `.ufo/waves/round-26/observe-2.json` still exists, is tracked, and its
   sha256 `13b8540c78b9de07bc184894583a368472fd1f2f04a898220bf7c29d2648a169` is
   exactly the pin F4 replaced. Custody intact; the new pin is the new receipt's
   own digest, recomputed here rather than copied from the claim.

## T2/T3 update — what resolved, what the block is

The tree kept moving after T1. Measured again at T2 (00:26Z) and T3 (00:29Z),
same lane HEAD:

| reading | T1 | T2 | T3 |
|---|---|---|---|
| `bash plans/round-36-c1.sh` | 3 rc0 | 0 rc0 | 0 rc0 |
| SD5 | 0 | — | 0 |
| **SD6** (frozen must stay 5) | **6** | — | **5** |
| stale | 3 | — | 0 |
| `bash plans/round-36-c2.sh` | 0 rc0 | 0 rc0 | 0 rc0 |
| `bash plans/round-36-c3.sh` | CLEAN rc0 | CLEAN rc0 | CLEAN rc0 |

Resolved between T1 and T3 (no longer findings): `SCORECARD.md:1404`'s
"4 → 0" (now true), `corpus/claim-ledger.tsv:98` `R36-01`'s `^0$` (now matches),
and the `stale=3` component — `SKILL.md:46`, `PROVINCE.md:73`,
`corpus/README.md:64` claimed 79 ledger rows against a live 82 after
`R36-01..03` landed, and were corrected (`stale=0`). `corpus/SOURCES.md` was
reverted to HEAD (`b974504e…`) before T2, so the four cited rows ship unchanged.

**The block is `SCORECARD.md:1409`, and it is a landing condition, not a
credential issue.** That row cites `.ufo/waves/round-36/build/ConnScope/ConnOverlap.md`.
SD6 is the `UNRESOLVED` set of `bash corpus/claim-ledger.sh citations` (sweep
L22, L398-412), so with `SCORECARD.md` bytes **identical** (`a53c0aa0…`) in both
runs:

```
T1: MISMATCH SD6 SCORECARD.md:1409 .ufo/waves/round-36/build/ConnScope/ConnOverlap.md (ufo)
    -> SD6 = 6     (the file did not exist; created 00:25Z)
T3: (no such line) -> SD6 = 5     (the file exists, the citation resolves)
```

The file is **untracked** (`.ufo/waves/round-36/build/` is `??`). At the landing
revision: commit that artifact with the row → SD6 = 5, kill rule satisfied,
C1 = 0 admissible; do not commit it → SD6 = 6, `plans/round-36.md` §C1 kill rule
("SD6 differs from 5 at the landing revision → C1 fails, admission withheld")
fires **while `bash plans/round-36-c1.sh` still prints 0**. The counter cannot
see its own kill rule, so the readiness must be checked against the landing set,
not the counter.

## Verdict

**CLEAR on the four assigned security checks** — no credential material, no
private path or user name in the pushed data, every fetch an unauthenticated
public read, nothing the refusal boundary forbids, and no new execution surface
in F1-F4 or the T1 additions.

**BLOCK on one landing condition:** `SCORECARD.md:1409` cites an untracked seat
build artifact; the row must ship with that file committed (or cite a tracked
path), otherwise SD6 = 6 at the landing revision and C1 fails by its own frozen
kill rule.

Routed, not blocking: 0b (68 tracked round-26 header captures with anonymous
session ids) and 0c (`SOURCES.md:117` host path) are pre-existing exposures in
bytes this round does not push; both need an L1/operator decision.

Honesty note: the tree moved through four snapshots during this review (T0 → T3).
Every reading above is bound to the hashes printed beside it; if the L1 changes
those bytes again, the sweep must be re-run, not assumed. The T1 numbers are kept
rather than overwritten — they are what the claim looked like before the fixes.
