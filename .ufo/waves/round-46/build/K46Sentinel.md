# K46Sentinel — round-46 security and refusal-boundary review

Seat: sentinel (read-only). Lane: `/home/vgpnk/Projects/shokunin/kagi-shokunin`, branch `master`.
Reviewed at `44808ced56359c98f35995178fb24a6482899263` (HEAD at review), BASE `f5977284a8ce5bab09252be8196ee5dc18489926`.
Scope was the round-46 change surface: `corpus/release-clock.py --observe` (fetch, redirects, body
caps, URL validation, receipt writing), the planned default-receipt repoint, and
`plans/round-46-c1.sh` / `plans/round-46-c2.sh` (scratch, `rm -rf` scope, trap, `HYAKU_SCRATCH`,
archive extraction), plus the refusal boundary over `.ufo/waves/round-46/**` and `plans/round-46*`.
No lane file outside this seat's `build/K46Sentinel*` path was created or modified; no git/jj
mutation was run; no live `--observe` was run by this seat.

Receipts (all in this directory, sha256 as written):

| receipt | sha256 | content |
|---|---|---|
| `probes.txt` | `503cb13ff179778abc6ebaa40b8d2d4169a9dd1f75514dfc9e30411ca5219962` | probe outputs P0–P6 |
| `probes.py` | `1faf91127e5655ad87eb9350ff8d3f368b49062b381daa56e382e81457c5ee4d` | the probe program (`python3 -B`) |
| `refusal-scan.txt` | `c617a41a012db59e1344ccb1d80419870c9d8e0c65d081839263a593479eec9c` | refusal-boundary scan, 2026-11-06T19:02:12Z, 85 files |
| `refusal-scan.sh` | `f25a4fce8b47f7e9032121c3cbf9a6a738eb5dee02a7e29d51e64f4afb351e16` | re-runnable scan (excludes this directory) |

Instrument bytes were re-hashed at 2026-11-06T15:52Z and matched the predeclaration's
`.ufo/waves/round-46/controls/instrument-sha256.txt` exactly: `corpus/release-clock.py`
`b18444f8…`, `plans/round-46.md` `a78ef77e…`, `-c1.sh` `e3ec7ea0…`, `-c2.sh` `0572caae…`,
`round-46-controls.py` `651607c5…`, `corpus/claims-declared.sh` `ec0adffe…`,
`corpus/release-clocks.tsv` `5356c3aa…`, `controls/c2-positive-observe.json` `15ae4ead…` — no drift
at that instant. The wave then applied the candidate to the lane working tree while this review
ran (still uncommitted at 16:04Z; `git diff` = 11 files). The applied `corpus/release-clock.py`
(working-tree sha256 `88aaabb7…`) changes exactly three lines — the default pin to `6091c529…`, the
default path to `.ufo/waves/round-46/final/observe-r46.json`, and the `--receipt` help string — and
does not touch the fetch, URL-validation, redirect or receipt-write logic, so the controls below
still describe the candidate's code. Those working-tree edits are outside this seat's write scope
and were not made by it; the committed blobs at `44808ce` still hash to the frozen values, and the
closure should pin at the candidate commit.

## Findings

| id | severity | surface | status |
|---|---|---|---|
| S-01 | Low (tool gap; instance resolved in-tree) | observe receipt parent | resolved 16:01Z; tool gap open |
| S-02 | Low | fetch error handling | open |
| S-03 | Low | observe output path resolution | open |
| S-04 | Low | redirect provenance | open |
| S-05 | Low | receipt read bound | open |
| S-06 | Low | counter scratch creation | open (frozen counter) |
| S-07 | Low | `C1_TREE` write target / archive trust | open (frozen counter) |
| S-08 | Low (verify) | default-repoint doc coherence | applied in working tree; verify at commit |
| S-09 | Info (trust boundary) | counters execute measured code | named, no action |
| S-10 | Info (restated ceiling) | receipt authenticity | declared ceiling confirmed |
| S-11 | Low (local misuse) | `$REV` argv handling | open (frozen counter) |
| S-12 | Medium (resolved in working tree) | draft pin vs final receipt sha | pin now `6091c529…`; verify at commit |

### S-01 — Low (tool gap; instance resolved in-tree) — `write_receipt` cannot create the receipt's parent; the plan's directory did not exist when the wave started

- **Pointer:** `corpus/release-clock.py:919-950` (`write_receipt`; `os.path.lexists` at 928,
  `tempfile.NamedTemporaryFile(dir=str(output_path.parent))`, `setup("cannot write observation
  receipt: %s")` at 950); plan sentence `plans/round-46.md:82` ("one live `--observe` writes
  `.ufo/waves/round-46/final/observe-r46.json`").
- **Evidence:** at 15:52Z `ls -ld .ufo/waves/round-46/final` → `No such file or directory`, so the
  plan's command as written would have exited 2 with a SETUP line. Probe P3 confirms the tool
  behaviour: `write_receipt(<dir>/no-such-dir/observe-r46.json, [])` → `SetupError: cannot write
  observation receipt: FileNotFoundError`; read-only parent → `PermissionError` (`probes.txt`).
  Load-bearing detail: at 16:01Z the wave created the directory and ran the named command —
  `.ufo/waves/round-46/final/observe-run.txt` records
  `python3 -B corpus/release-clock.py --observe .ufo/waves/round-46/final/observe-r46.json
  (cwd lane)` → `RELEASE_CLOCK_OBSERVE: wrote 29 observations (failed=0 fired=13 regressed=0)`,
  and the receipt is in place (10,575 bytes, sha256 `6091c529…`, `observed_at`
  2026-11-06T19:01:14–19:01:16Z, 29 records, all 200, no errors).
- **Failure path (still true of the tool, not of this round):** any future `--observe` to a
  not-yet-created directory exits 2 with no receipt; C2's PINNED leg then reads nothing and scores
  0. The round-46 instance is resolved by the `mkdir`/observe recorded in `observe-run.txt`.
- **Impact:** no security impact; an operability trap that was avoided here by creating the parent
  first. No action needed for this round; the tool gap is a later-round item.
- **Smallest remediation:** have `write_receipt` create the parent (or keep the plan's `mkdir -p`
  as a stated step). Re-observing to an existing path requires removing the old receipt first:
  `write_receipt` intentionally refuses an existing file or symlink (verified, P3).

### S-02 — Low — one malformed feed aborts the whole observation run (`http.client.HTTPException` is uncaught)

- **Pointer:** `corpus/release-clock.py:909-914` (catches `urllib.error.URLError`, `UnicodeError`,
  `(OSError, ValueError)` only); `:977-980` (list comprehension builds every receipt before
  `write_receipt` is called).
- **Evidence:** probe P1 against `observe_one` with a stub opener: `BadStatusLine` → **UNCAUGHT**,
  `IncompleteRead` → **UNCAUGHT**; `RemoteDisconnected` and `ConnectionResetError` are caught
  (they are `OSError` subclasses). `http.client.HTTPException` is not an `OSError`.
- **Failure path:** a feed that returns a malformed status line or truncates a chunked body
  (`BadStatusLine`, `IncompleteRead`) raises past `observe_one`; the comprehension aborts, no
  receipt is written, and `main` prints a traceback (rc 1). A single broken or hostile feed host
  therefore destroys the round's freshness evidence rather than recording one failed record.
- **Impact:** availability/evidence loss for C2; no confidentiality or integrity boundary crossed.
- **Smallest remediation (later round; do not change the frozen counters):** add
  `http.client.HTTPException` to the except tuple at `:913` and record
  `type(exc).__name__`; optionally write per-row receipts incrementally. Not applied here.

### S-03 — Low — `--observe OUT` resolves against the process cwd, not `--root`

- **Pointer:** `corpus/release-clock.py:919-920` (`Path(os.path.abspath(...))`), `:2104`
  (`--observe` takes a raw path), and the plan's lane-relative path at `plans/round-46.md:82`.
- **Failure path:** an executor running from scratch (`cwd=$HYAKU_SCRATCH/...`) writes
  `$PWD/.ufo/waves/round-46/final/observe-r46.json`; the lane tree gains no receipt, so C2
  PINNED/DEFAULT read nothing and the candidate scores 0. Silent (the command succeeds). The
  round-46 run did not hit this: `final/observe-run.txt` records `(cwd lane)`; keep that precondition
  for any re-run.
- **Smallest remediation:** run the observe from the lane root or absolute-path the output; if the
  tool is touched later, resolve a relative `--observe` path against `--root`.

### S-04 — Low — the receipt records the requested URL, not the post-redirect URL

- **Pointer:** `corpus/release-clock.py:740-767` (manual same-origin redirect loop),
  `:858-868` (`receipt["url"] = safe_receipt_url(url)`); `request_body` returns no final URL.
- **Failure path:** a same-origin redirect (allowed by design: scheme/host/port equal,
  `:230-249`) can serve the body from a different path than the one recorded; the receipt's
  `sha256` then attests content the recorded URL never named. Cross-origin, credential-path and
  1Password path-change redirects are denied (`redirect_allowed`, probed by the draft's fixtures),
  so this is a provenance weakness, not a boundary bypass.
- **Smallest remediation (optional):** return and record `final_url` (and hop count) when it
  differs from the requested URL.

### S-05 — Low — the receipt is read into memory before the pinned digest is checked

- **Pointer:** `corpus/release-clock.py:508-521` (`Path(path).read_bytes()` then the
  `expected_sha256` comparison; no size bound, no `lstat`/`S_ISREG`, symlinks followed).
- **Evidence:** the observe writer caps bodies at 8 MiB (`MAX_BODY_BYTES`, `:32`) but the *reader*
  of that receipt has no cap. The BASE default receipt is 10,916 bytes; the C2 counter hashes and
  reads the candidate's receipt on every measure (`plans/round-46-c2.sh:63`).
- **Impact:** a committed multi-GB receipt (or a symlink to a large regular file) is read and
  hashed by every default replay; self-inflicted DoS on measurement, no leak (a digest mismatch or
  JSON failure fails closed).
- **Smallest remediation:** `os.lstat` + `S_ISREG` + a size cap (e.g. 16 MiB) before hashing;
  refuse symlinks, as the writer already does.

### S-06 — Low — counters create scratch with a PID-suffixed `mkdir -p`, not `mktemp -d`

- **Pointer:** `plans/round-46-c1.sh:41-43`, `plans/round-46-c2.sh:34-36`
  (`SCR=${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r46/{c1,c2}.$$`; `mkdir -p -- "$SCR/t" …`;
  `trap 'rm -rf -- "$SCR"' EXIT`).
- **What is sound:** every expansion is quoted; `${VAR:-default}` treats empty as unset, so `SCR`
  cannot become `/` or empty; `rm -rf` always targets two extra components plus a PID; the trap is
  installed immediately after `mkdir`, before any extraction or write; `/fast/scratch` is
  `drwxr-xr-x vgpnk` (same-user only, verified), so cross-user symlink pre-creation is not
  reachable.
- **Residual:** a same-user stale directory adopted by PID reuse is deleted by the trap; a
  pre-created symlink at `…/c1.<pid>` would be *followed* by `mkdir -p` and by the later
  `sed > "$m"`, writing through it (the trap's `rm -rf` removes the link, not the target). Scratch
  is per-seat in this wave, so the practical exposure is a self-inflicted misfire. Also, when
  `mkdir -p "$SCR/t" "$SCR/hs"` fails after creating `$SCR/t`, `setup scratch` exits before the
  trap is installed, leaving that one directory behind.
- **Smallest remediation (frozen counter — later round or L0):** `SCR=$(mktemp -d
  "${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r46/c1.XXXXXX")`, the pattern the gate itself
  already uses at `corpus/claims-declared.sh:37`; install the trap on the next line.

### S-07 — Low — `C1_TREE` is a write target and the trees are extracted without a repo guard

- **Pointer:** `plans/round-46-c1.sh:46-51` (`cp -a "$C1_TREE"/. "$T"/` or
  `git archive "$REV" | tar -x -C "$T"`), `:66-78` (mutants written to `$T/corpus/…`). C2's tree
  is read-only (`plans/round-46-c2.sh:39-47`).
- **Failure path:** `C1_TREE` is documented as "a fixture tree, used by the pre-freeze controls
  only", but nothing refuses `C1_TREE=$REPO`: the counter would then write seven
  `corpus/claims-declared.<name>.sh` files into the lane (a write outside the seat's scope), and
  `cp -a` of the lane (including `.jj/`) would be copied into scratch first. Archive extraction of
  a *candidate* tree is the same class: a committed symlink named `corpus/claims-declared.m1.sh`
  would be followed by `sed > "$m"` (see S-09).
- **Smallest remediation:** refuse a `C1_TREE`/`C2_TREE` that resolves to or inside `$REPO`
  (exit 2 SETUP); extraction could use `tar -x --no-overwrite-dir` plus a pre-scan for symlinks
  under `corpus/`. Frozen counters: record for a later round.

### S-08 — Low, verify — the default repoint must also correct the `--help` sentence

- **Pointer:** `corpus/release-clock.py:2105` (`--receipt` help: "default is the round-36 rearmed
  receipt"); `receipt_path` default at `:545-547`; `DEFAULT_RECEIPT_SHA256` at `:28`. The plan
  names the path, the digest and SKILL.md, not line 2105.
- **Status:** the K46ExecClocks draft diff already replaced that string
  (`build/K46ExecClocks/release-clock.diff:25-26`), and the working-tree candidate now carries the
  updated help (line 2105: "default is the round-46 observe-r46 receipt; the round-36 and round-26
  receipts stay citable with `--receipt/--receipt-sha`"). Verify it survives the commit; otherwise
  `--help` misstates the default, the same instrument-drift class as M46-1.

### S-09 — Info — the counters execute the measured tree's code (trust boundary, not a bypass)

- **Pointer:** `plans/round-46-c1.sh:57-64,100` (`bash corpus/claims-declared.sh` and every mutant);
  `plans/round-46-c2.sh:49-58` (`python3 corpus/release-clock.py` from the archive tree);
  `corpus/release-clock.py:725-733` (`--observe` imports `corpus/rendered-text-v1.py`).
- **Statement:** the measured candidate runs with the counter's privileges; the counters are not an
  isolation boundary. A candidate-controlled normalizer could do anything the user can, and C1's
  `sed > "$m"` follows a committed symlink at that exact name (S-07). This is inherent to
  measurement by execution and is why the non-author live re-observation (plan kill rule, S-10)
  matters. No change this round; name it in the lesson.

### S-10 — Info — receipt authenticity is a declared ceiling, restated

- **Pointer:** `plans/round-46.md:138-143` (ceiling K2-F4 = 29); `plans/round-46-c2.sh:63`
  (`RSHA` is computed from the same candidate file that is then parsed).
- **Statement:** neither counter attests provenance; PINNED/FRESH read a candidate-authored JSON
  whose `observed_at`/`sha256` are unauthenticated fields. The controls receipt confirms K2-F4=29.
  The only leg that can distinguish a fetched receipt is the non-author live re-observation named
  in the C2 kill rules; that artifact now exists (`build/K46ReviewerLive/obs.json`, 18:53Z, 29×200),
  and the closure should record that it ran and that the feed versions agreed.

### S-11 — Low (local misuse) — `$REV` reaches git without `--end-of-options`

- **Pointer:** `plans/round-46-c1.sh:50-51`, `plans/round-46-c2.sh:43-44`
  (`git cat-file -e "$REV^{commit}"`, then `git archive "$REV" | tar -x`).
- **Failure path:** a rev beginning with `-` is parsed as an option; most option-looking revs fail
  `cat-file -e` and become SETUP, but the guard is incidental, not designed. The caller is the
  closure/operator, so impact is local misuse, not an untrusted-input boundary.
- **Smallest remediation:** pass `--end-of-options` (git ≥ 2.20) or validate `$REV` against
  `[0-9a-f]{7,64}`. Frozen counters: later round.

### S-12 — Medium (resolved in the working tree) — the draft's pinned digest and the receipt at the plan path disagreed

- **Pointer:** `build/K46ExecClocks/release-clock.py:28` pins `e7a27695…` (the digest of that seat's
  own draft receipt `build/K46ExecClocks/observe-r46.json`); the plan's named live observe wrote
  `.ufo/waves/round-46/final/observe-r46.json` at 19:01Z with sha256 `6091c529…`. The gate compares
  the pinned digest after reading the file (`corpus/release-clock.py:513-521`); a digest mismatch
  marks the whole bundle invalid and every row reads `RECEIPT-MISMATCH`.
- **Evidence (state before the repoint landed, 16:02Z):** `sha256sum` of both files (above);
  `final/observe-run.txt` records the 19:01Z run as the one that wrote the plan path; at that
  instant the working-tree `corpus/release-clock.py` was still the BASE `b18444f8…`, and the
  working-tree `corpus/release-clocks.tsv` was already synced to 2026-11-06 values that agree with
  all three live receipts on the sampled rows (S008 `3.13.3`/`not-fired`, S098 `quote-located`).
  At 16:04Z the repoint was applied (see Resolution).
- **Failure path:** an executor applies the K46ExecClocks draft verbatim (pin `e7a27695…`) while
  the final receipt remains `6091c529…` → DEFAULT fails with `RECEIPT-MISMATCH` for every row and
  C2 reads 0; conversely, copying the draft receipt over the final path makes the measured receipt
  differ from the run documented in `observe-run.txt`.
- **Resolution observed at 16:04Z:** the applied working-tree `corpus/release-clock.py:28` pins
  `6091c529…`, exactly the receipt at the plan path; the draft pin `e7a27695…` was superseded, and
  the working-tree `receipt_path` default points at the same file. The remaining check is at the
  commit: if the candidate is rebuilt or the receipt regenerated, the pin must move with it, and
  the closure should still confirm the non-author live observation
  (`build/K46ReviewerLive/obs.json`, `6127f07f…`, 18:53Z) agrees on every feed clock.
- **Smallest remediation if it recurs:** pin the digest of the receipt actually committed at
  `.ufo/waves/round-46/final/observe-r46.json` (the 19:01Z one, because `observe-run.txt` documents
  it) and keep the TSV synced to that same receipt.

## Refusal boundary — explicit statement

**No secret value, token, cookie, vault field, or `op://` reference path is present in the round-46
artifact set scanned at 2026-11-06T19:02:12Z** (85 regular files under
`.ufo/waves/round-46/**` plus 4 under `plans/round-46*`; receipt
`.ufo/waves/round-46/build/K46Sentinel/refusal-scan.txt`, sha256 `c617a41a…`). Detectors and results:

- private keys, GitHub/AWS/Slack/OpenAI token shapes, JWT triples, `vault://`/`secret://`/`sops://`
  schemes, `Authorization:`/`Cookie:`/`Set-Cookie:` headers, `op run|read|item|inject|signin`,
  `OP_SERVICE_ACCOUNT`: **no matches**.
- credential assignment shapes (`password|secret|token|cookie|api_key…: value`): one match, a
  **negative self-test fixture** — `build/K46ExecClocks/release-clock.py:1555`
  `https://feed.example.test/releases.atom?token=TEST-SENTINEL-ONLY`; the same file asserts the
  value is neither fetched nor persisted (`:1562-1566`). Not a secret.
- 1Password account/auth paths: two matches, both **negative redirect fixtures**
  (`build/K46ExecClocks/release-clock.py:1483-1485`, `…/account/login`, `…/app`) asserting the
  denylist refuses them. No account, session, vault or auth URL is a live target.
- receipt JSON URLs: four observation receipts carry records — `controls/c2-positive-observe.json`
  (`15ae4ead…`), `build/K46ExecClocks/observe-r46.json` (`e7a27695…`), `build/K46ReviewerLive/obs.json`
  (`6127f07f…`) and `final/observe-r46.json` (`6091c529…`) — each 29 records, all `http_status` 200,
  all observed 2026-11-06, no `error` fields, and **zero** URLs with query, fragment or userinfo.
- the literal `op://` occurs exactly four times, in `build-spec.json` and `build-dispatch.json`,
  only inside the quoted seat-prompt rule text ("never write an `op://` reference path into any
  artifact"). The reference-path shape `op://<vault>/<item>` matches **0**. This is rule text, not
  a reference; it must not be "sanitized" out of the prompt embeds.
- `1password.com` / `www.1password.dev` **public documentation** pages are clock targets
  (S005–S007, S017–S020, S030–S032; e.g. `www.1password.dev/brokered-access`). They are read as
  public pages under the boundary's "web reads of public pages only": the tool sends a bare
  User-Agent-only GET, has no cookie jar or auth handler, disables environment proxies
  (`ProxyHandler({})`), rejects userinfo/query/fragment/secret-shaped paths
  (`valid_public_https_url`), denies account/app/auth/login/session/vault hosts and paths, and
  strips query/fragment/userinfo and secret-shaped path segments from receipt URLs
  (`safe_receipt_url`, probe P6 → `https://example.com`). No form post and no remote write exists in
  the tool.
- caveat: other seats are still writing; re-run
  `bash .ufo/waves/round-46/build/K46Sentinel/refusal-scan.sh <out>` from the lane root at the
  candidate tip before freeze.

## Verified defensive controls (no finding)

- **Fetch/SSRF:** HTTPS only, port 443 or none, no userinfo/query/fragment, IP literals must be
  `is_global`, `localhost`/`.local` refused, 1Password account/app/auth/login/my/session/vault
  hosts and paths refused (`corpus/release-clock.py:172-206`, probe P4). DNS is resolved once and
  the connection is **pinned** to the validated addresses (`PinnedHTTPSConnection`/`Handler`,
  `:251-296`, `:305-327`), so a rebind between check and connect cannot redirect the request; any
  non-global answer refuses the whole host. Probe P5: `https://2130706433/` passes the syntactic
  check but `public_addresses` → `host resolves to a non-public address` (defense in depth).
- **Redirects:** automatic following disabled (`NoRedirectHandler`, `:735-737`); manual loop permits
  at most 5 hops, requires the same scheme/host/port, denies credential-path segments, and on
  1Password hosts requires the original path (`:230-249`, `:758-767`).
- **Body caps/DoS:** 8 MiB cap on both the success and `HTTPError` paths (`:768-776`), 20 s socket
  timeout, XML `DOCTYPE`/`ENTITY` refused before parsing (`:819-820`), element and entry caps
  (`:825-831`), version ordering without `int()` (`:388-417`); probes P2: internal entity bomb and
  external entity both refused with `XML DTD and entity declarations are not allowed`.
- **Receipt write:** atomic temp file in the destination directory + `os.link`, refuses an existing
  path or symlink, cleans the temp on failure, refuses missing/read-only parents
  (`:919-950`, probe P3). Receipt content is limited to id/clock/url/status/digest/version/
  verdict/date; the body itself is never persisted; URLs are sanitized (`:858-868`, `:210-228`).
- **Counters:** quoted expansions throughout; `${HYAKU_SCRATCH:-default}` cannot yield an empty
  root; `rm -rf` stays inside the two-component PID scratch; the trap is installed before any
  extraction or write; `git archive` extraction is followed by an explicit
  `missing-gate` SETUP check, so a truncated archive fails closed rather than scoring; C2's
  missing receipt fails closed (`PINNED=0`) and `load_receipt_bundle` treats duplicate ids, a wrong
  `format`, and a digest mismatch as invalid (`:508-543`). The plan's repoint (path + digest) is
  exactly the edit `plans/round-46-controls.py:105-116` (reference impl) applies; the working-tree
  candidate pins the receipt that the 19:01Z observe actually wrote (`6091c529…`).

## Not run (honesty)

- No live `--observe` and no network fetch by this seat; all four 29-record receipts cited
  (predeclaration control, K46ExecClocks draft, K46ReviewerLive observation, and the 19:01Z final
  observe documented in `final/observe-run.txt`) were produced by other seats, not by me.
- No counter execution and no `claim-ledger.sh verify` / self-counts (read-only seat, host-heavy
  excluded). BASE values come from the committed receipts `controls/c1-base.txt` (`value=0`),
  `controls/c2-base.txt` (`value=0`), `controls/gates-base.txt` (`RELEASE_CLOCK: FAILED`,
  rc 1), `controls/controls-prefreeze.txt` (11 MATCH), which I read, not re-ran.

SEAT-STATUS: complete
