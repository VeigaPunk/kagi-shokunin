# R50ScoutSources — frontier sources for C1 (the Linux parent-death signal)

Seat: `R50ScoutSources` · Round 50 (kagi, attempt 1) · lane `kagi-shokunin` (`/home/vgpnk/Projects/shokunin/kagi-shokunin`)
BASE `565c43a874b59cd216f4a55c8742db48fa854f16` · predeclaration `7d3b2c01b375d5459abd7da79bb4063b7d728fc7`
Opened 2026-11-06 · domain: secrets & vault ops

Scope of this seat: open the two frontier sources C1 rests on — the Linux parent-death signal
(`prctl(2) PR_SET_PDEATHSIG`) and `setpriv(1) --pdeathsig` — locate teachable quotes, record their
provenance, and draft the two `corpus/SOURCES.md` registry rows the plan calls for
(`plans/round-50.md:109`, "SOURCES rows for prctl(2) PR_SET_PDEATHSIG and setpriv(1)").

**Nothing outside my seat's write scope was touched.** `corpus/SOURCES.md` was read only; the two
rows below are *drafts for the executor to append*, not an applied edit. The frozen instruments
(`plans/round-50-c1.sh`, `plans/round-50-c2.sh`, `plans/round-50-controls.sh`,
`corpus/openbao-token-trial.sh`, `corpus/claim-ledger.tsv`, the controls receipts) were not edited
and were not run as gates.

---

## 1. Fetches (public read-only pages; no form posts, no remote writes)

All three pages were fetched with `curl -sSL`; each saved raw under this seat's capture dir.
`curl -sSL -o <file> -w '%{http_code}'` for the status; `stat -c %s` for bytes; `sha256sum` for the body hash.

| # | URL | HTTP | bytes | body sha256 |
|---|---|---|---|---|
| 1 | `https://man7.org/linux/man-pages/man2/PR_SET_PDEATHSIG.2const.html` | **200** | 10684 | `5e72367effe41fab8ca6a0969ed39c201c98a7495c9cbc94b574b4949144fc82` |
| 2 | `https://man7.org/linux/man-pages/man2/prctl.2.html` (fallback, also fetched) | **200** | 26266 | `ef698f6c5aab0224e9bf238ea1820160797c15d0adcee8b37fcaac7297866810` |
| 3 | `https://man7.org/linux/man-pages/man1/setpriv.1.html` | **200** | 20601 | `3bc0de9949a754b35811837d59d76ee1b4934f1747ab835702a7d017437770fd` |

URL 1 did **not** 404, so URL 2 is a supplementary capture, not a substitute. URL 2 was still worth
fetching and hashing: it is the page a reader lands on first for `prctl(2)`, and it establishes that
the *semantics* live on `PR_SET_PDEATHSIG(2const)` — `prctl(2)` itself only lists the constant and
cross-references it (`grep -c -F "PR_SET_PDEATHSIG(2const)" prctl.2.flat.txt` → 4, all list/see-also
occurrences; the descriptive prose is not there). The registry row therefore anchors on URL 1.

Captures in `R50ScoutSources/`:

```
PR_SET_PDEATHSIG.2const.html   PR_SET_PDEATHSIG.2const.txt   PR_SET_PDEATHSIG.2const.flat.txt
prctl.2.html                   prctl.2.txt                   prctl.2.flat.txt
setpriv.1.html                 setpriv.1.txt                 setpriv.1.flat.txt
fetch-receipt.txt
```

`.txt` = HTML tags stripped (text preserved in reading order, line-wrapped like the rendered page).
`.flat.txt` = whitespace-collapsed to one line, used for the `grep -c` locators (the line-wrapped
file breaks multi-line sentences, so a single-line form is the honest thing to grep against).
Full command/exit/stdout transcript: `R50ScoutSources/fetch-receipt.txt`.

### Page version/date footers

| Page | Footer line | Colophon provenance |
|---|---|---|
| `PR_SET_PDEATHSIG (2const)` | `Linux man-pages 6.19 2026-02-08 PR_SET_PDEATHSIG (2const)` | "This page was obtained from the tarball man-pages-6.19.tar.gz … on 2026-09-09"; "HTML rendering created 2026-09-09" |
| `prctl (2)` | `Linux man-pages 6.19 2026-02-08 prctl (2)` | same tarball `man-pages-6.19.tar.gz`, fetched 2026-09-09; rendering 2026-09-09 |
| `SETPRIV (1)` | `util-linux 2.43.devel-1062-f... 2026-08-03 SETPRIV (1)` | "obtained from the project's upstream Git repository … on 2026-08-04 (… the most recent commit that was found in the repository was 2026-08-03)"; rendering 2026-09-09 |

**Freshness caveat (honest, worth an executor's attention):** the `setpriv(1)` page is a *devel*
snapshot (`2.43.devel-1062-f…`), not a tagged release, and the host binary is
`setpriv from util-linux 2.42.4` (`/usr/bin/setpriv`). The `--pdeathsig keep|clear|<signame>`
option exists in both, so the citation is valid for the host, but a reader on 2.42.4 is being
served documentation from a newer tree. This is why the drafted row's `recheck` is `on-release`.

---

## 2. Located quotes (each ≤ 25 words, each `grep -c` = 1 in the tag-stripped text)

Word counts are literal `printf '%s' "<quote>" | wc -w`. Locators are `grep -c -F "<quote>"` against
the whitespace-collapsed tag-stripped capture; every count below is **1** (the only exception is
noted explicitly).

### (a) The signal is delivered when the parent (thread) terminates

Source: `PR_SET_PDEATHSIG (2const)`, §DESCRIPTION.

> The parent-death signal is sent upon subsequent termination of the parent thread and also upon termination of each subreaper process

`wc -w` = **20** · `grep -c -F` in `PR_SET_PDEATHSIG.2const.flat.txt` = **1**
(locator substring `sent upon subsequent termination of the parent thread`).

This is the exact sentence that answers C1's question "does the server actually die when its
parent shell is killed?". It names the *thread*, not the process — which is the sharper fact, and
is what §CAVEATS repeats ("The 'parent' in this case is considered to be the thread that created
this process"). Note the corollary C1 should not over-claim: the signal fires when the **parent
thread** exits, and `prctl` is one-shot per thread.

### (b) The setting is cleared on fork; preserved over execve except for set-user-ID/set-group-ID

Source: `PR_SET_PDEATHSIG (2const)`, §DESCRIPTION. Three sub-facts, three quotes, each ≤ 25 words,
each counting 1:

> The parent-death signal setting is cleared for the child of a fork(2).

`wc -w` = **12** · `grep -c -F` = **1**

> It is also (since Linux 2.4.36 / 2.6.23) cleared when executing a set-user-ID or set-group-ID binary

`wc -w` = **16** · `grep -c -F` = **1**

> otherwise, this value is preserved across execve(2).

`wc -w` = **7** · `grep -c -F` = **1**

Together these teach the full inheritance rule: fork clears it, **execve preserves it**, and the
preservation is voided when the exec'd binary is set-user-ID/set-group-ID or carries capabilities.
That last clause is the reason the C1 fix must not wrap `bao` in a credential-changing wrapper —
it is exactly what `setpriv --pdeathsig` exists to undo (see (c)). The page also notes the setting
is cleared on changes to effective/fsuid/fsgid credentials, and that if the parent thread and all
ancestor subreapers have already died before the `prctl` call, **no** signal is sent.

### (c) `setpriv`'s `--pdeathsig` option

Source: `setpriv (1)`, §OPTIONS, `--pdeathsig keep | clear | <signal>`.

> Keep, clear or set the parent death signal. Some LSMs, most notably SELinux and AppArmor, clear the signal when the process' credentials change.

`wc -w` = **23** · `grep -c -F` in `setpriv.1.flat.txt` = **1**

and the follow-on sentence that explains *why the option exists*:

> Using --pdeathsig keep will restore the parent death signal after changing credentials to remedy that situation.

`wc -w` = **16** · `grep -c -F` = **1**

This is the operative citation for C1: `setpriv --pdeathsig KILL` applies the parent-death signal to
the program it `execve`s, so the throwaway `bao server -dev` inherits a `KILL` that fires when the
wrapping shell's thread dies. The option synopsis line itself carries a `|` (`keep | clear |
<signal>`), which is why it is quoted here only as prose — see §4 for why that matters in a table cell.

**Host cross-check (read-only):** `/usr/bin/setpriv --help` lists `--pdeathsig keep|clear|<signame>`;
`setpriv --version` → `setpriv from util-linux 2.42.4`. The option C1 depends on is present on this
host, one util-linux release behind the documented tree.

---

## 3. Registry facts about `corpus/SOURCES.md` (read-only)

```
grep -cE '^\|[[:space:]]*S[0-9]{3,}[[:space:]]*\|' corpus/SOURCES.md   -> 105
max id in the table                                                  -> S105
grep -c 'man7.org'   corpus/SOURCES.md -> 0
grep -c 'setpriv'   corpus/SOURCES.md -> 0
grep -c 'pdeathsig'  corpus/SOURCES.md -> 0
grep -c 'prctl'      corpus/SOURCES.md -> 0
```

**Neither URL is already registered**, and no `prctl`/`setpriv`/`pdeathsig` row exists. `S106` and
`S107` are therefore the next unused ids (`S` + ≥3 digits, next unused, never reused).

Schema read from `CORPUS.md` §"SOURCES.md — where a shokunin learns" (contract v1, frozen) and from
the census in `corpus/sources-census.sh:169-199`: 11 columns ⇒ `awk -F'|'` must print `NF=13`;
`kind ∈ {spec,docs,paper,code,tool,dataset,talk,book,community,own-work}`; `tier ∈ {A,B,C}`;
`status ∈ {queued,mined,rejected}`; `community` is never tier A; no `|` inside any cell; `used-by`
paths of `mined` rows must exist; `recheck` is an ISO date or a cadence (`90d`, `180d`,
`on-release`).

`kind` for both rows: **`docs`** — these are the authoritative upstream manual pages for the
kernel / util-linux interfaces, i.e. primary documentation, not code, not a community lead.
`tier` **A** for both: they are the authoritative source *for the scope claimed* (the exact kernel
and util-linux semantics of the flag C1 uses), which is what tier A means in this contract.

### The two drafted rows (append-only; to be applied by the executor, NOT applied here)

Both rows: `status` = `mined`, `opened` = `2026-11-06`, `recheck` = `on-release`,
`used-by` = `corpus/openbao-token-trial.sh, corpus/lessons/round-50.md`. No literal or escaped `|`
appears in any cell. `awk -F'|'` prints `NF=13` for each (11 columns).

```
| S106 | PR_SET_PDEATHSIG(2const) — Linux manual page — https://man7.org/linux/man-pages/man2/PR_SET_PDEATHSIG.2const.html | docs | A | Linux parent-death signal semantics for prctl(2): delivery when the parent thread terminates, and inheritance across fork and execve, as cited by C1 | §DESCRIPTION and §CAVEATS, PR_SET_PDEATHSIG(2const); man-pages 6.19 dated 2026-02-08, page obtained from tarball man-pages-6.19.tar.gz on 2026-09-09; fetched 2026-11-06 (decoded body, raw sha256 5e72367effe41fab8ca6a0969ed39c201c98a7495c9cbc94b574b4949144fc82, 10684 bytes) | The parent-death signal is delivered to the child when the parent thread terminates, and the setting is cleared for a forked child but otherwise survives execve, so a wrapper whose shell dies takes its child down with it. Quotes: "The parent-death signal is sent upon subsequent termination of the parent thread and also upon termination of each subreaper process" (§DESCRIPTION); "The parent-death signal setting is cleared for the child of a fork(2)." (§DESCRIPTION) | mined | 2026-11-06 | on-release | corpus/openbao-token-trial.sh, corpus/lessons/round-50.md |
```

```
| S107 | setpriv(1) — Linux manual page — https://man7.org/linux/man-pages/man1/setpriv.1.html | docs | A | The setpriv(1) --pdeathsig option that applies a parent-death signal to the execve'd program, as used by C1 | §OPTIONS, --pdeathsig entry; util-linux 2.43.devel-1062 dated 2026-08-03, page obtained from the upstream util-linux Git repository on 2026-08-04; fetched 2026-11-06 (decoded body, raw sha256 3bc0de9949a754b35811837d59d76ee1b4934f1747ab835702a7d017437770fd, 20601 bytes) | setpriv --pdeathsig sets the parent-death signal of the program it execs, so a throwaway dev server started under it dies with its parent shell instead of outliving it. Quote: "Keep, clear or set the parent death signal. Some LSMs, most notably SELinux and AppArmor, clear the signal when the process' credentials change." (§OPTIONS, --pdeathsig) | mined | 2026-11-06 | on-release | corpus/openbao-token-trial.sh, corpus/lessons/round-50.md |
```

Shape checks actually run against these two drafted rows (not on the live file — the live file was
not modified):

```
awk -F'|' 'NF==13' -> line 1 NF=13, line 2 NF=13
literal '|' inside any cell: 0
'\\|' (escaped pipe) inside any cell: 0
ids S106 / S107 absent from the live table (105 rows, max S105)
```

**One caveat the executor must resolve, and it is a real one:** `used-by` names
`corpus/lessons/round-50.md`, and that file **does not exist yet**
(`ls corpus/lessons/round-50.md` → "No such file or directory"; `corpus/lessons/` currently ends at
`round-9.md`). The census checks mined rows' `used-by` paths exist
(`corpus/sources-census.sh:199`). So the two rows must be appended **after** the round-50 lesson
draft lands, or the census will fail on `missing: corpus/lessons/round-50.md`. The other used-by path,
`corpus/openbao-token-trial.sh`, does exist (8614 bytes) and already carries the C1 change:
`setpriv --pdeathsig KILL bao server -dev …` at line 64, with a `command -v setpriv` setup guard at
line 34.

---

## 4. OpenBao release freshness (note only)

```
gh api repos/openbao/openbao/releases --jq '.[0:3][]|.tag_name+" "+.published_at'
  v2.7.2 2026-10-26T20:24:37Z
  v2.6.5 2026-10-26T20:23:12Z
  v2.7.1 2026-10-01T14:03:19Z
gh api repos/openbao/openbao/releases --jq '.[0] | .tag_name+" | "+.published_at+" | "+.name'
  v2.7.2 | 2026-10-26T20:24:37Z | v2.7.2
gh api 'repos/openbao/openbao/tags?per_page=10' --jq '.[].name'
  v2.7.2 v2.7.1 v2.7.0 v2.7.0-beta20260909 v2.6.5 v2.6.4 v2.6.3 v2.6.2 v2.6.1 v2.6.0
```

**No release newer than v2.7.2 exists.** The newest OpenBao release is **v2.7.2, published
2026-10-26T20:24:37Z**, and it is also the newest tag (`v2.7.1` is older; `v2.7.0-beta20260909` is a
beta and is not a release). The registry already anchors this version: `corpus/SOURCES.md` S090
(Atom feed, fetched 2026-11-05) and S093 (tag page) both name v2.7.2 with the same
`2026-10-26T20:24:37Z` timestamp, so no new row is warranted for release identity and none is
drafted. Freshness note only; nothing here is a claim about OpenBao behaviour.

---

## 5. What this seat did **not** do (scope honesty)

- Did **not** edit `corpus/SOURCES.md` — the rows are drafts for the executor to append, and §3
  flags the `used-by` ordering constraint that would otherwise fail the census.
- Did **not** run `plans/round-50-c1.sh`, `plans/round-50-c2.sh`, `plans/round-50-controls.sh`,
  `corpus/claim-ledger.sh verify` (341 s, host-heavy, and not named by my item), or any gate
  instrument. The frozen instruments were read only, where reading helped; findings against them are
  routed, not applied.
- Did **not** start any `bao server -dev`; no OpenBao process was launched, so no throwaway server
  exists to kill. No token, password, key material, vault field or cookie was read, printed, copied
  or written.
- Did **not** touch `~/.config/sops`, `~/.ssh`, or any key file; did not contact 1Password, `op`,
  the-janitor, any vault or any account; wrote no `op://` reference anywhere.
- Did **not** write to any remote: the three fetches are GETs of public pages. No form post.
- Did **not** mutate host sysctls, services, users, packages or kernel settings; `pacman` was not
  invoked. No tool was installed or upgraded for this item (none was needed), so the tooling-authorization
  record is empty by design.
- Did **not** run any mutating git or jj command. `git rev-parse` / `git show` / `git status` were
  read-only. No fixture repo was created.
- **Observed (not mine, not killed):** `pgrep -a -f 'bao server'` shows one live OpenBao dev server,
  PID 931730, with `-dev-root-token-id=r49-f32e…` — a round-49 nonce, i.e. an orphan from a prior
  round, not started by this seat. I started no `bao` process, so I killed none; it is reported here
  for whoever owns the round-49 leftovers. (The root token value is not reproduced in this report.)
- Wrote only inside `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-50/build/R50ScoutSources*`
  (this report and its capture dir). The scratch dir `$HYAKU_SCRATCH/kagi-r50/R50ScoutSources/`
  (`/fast/scratch/hyaku/kagi-r50/R50ScoutSources/`) holds only the row-shape scratch check
  (`rows.tsv`) — the drafts above are reproduced inline here, so nothing needed to be copied out of it.

## 6. Remaining unknowns

- The `setpriv(1)` page is a devel-tree snapshot (`2.43.devel-1062-f…`) rather than a tagged release,
  and the host carries util-linux 2.42.4. If the lane wants the row pinned to a *release*, the
  util-linux v2.42.x tagged `setpriv.1` page is the closer match; I fetched the man7 devel page
  because it is the canonical current URL for `setpriv(1)`. Flagged, not resolved unilaterally.
- `corpus/lessons/round-50.md` is absent, so the `used-by` half of both rows is not yet satisfiable.
  The row append must be sequenced after that lesson draft.
