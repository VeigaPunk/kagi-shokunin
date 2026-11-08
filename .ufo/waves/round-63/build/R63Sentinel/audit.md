# R63Sentinel — secret-discipline and write-scope audit (round 63, wave 1)

Seat: `R63Sentinel` (sentinel, round 63 attempt 1, wave `kagi-r63-w1`).
Lane: `/home/vgpnk/Projects/shokunin/kagi-shokunin`, HEAD `966c469` at snapshot.
Claim BASE `0c07aab8df64b673a54a5113aebd7f34b622adbc`; frozen plan `plans/round-63.md`
at `12c9e4284d6de52ba61fcc656165cd24e8b74480` with Amendments A1 and A2.
**Snapshot: 2026-11-07T23:03:49Z** (the wave was still running; see §Snapshot boundary).
Read-only seat: this file and `w1/R63Sentinel.md` are the only lane writes.

Criteria read: `corpus/QUALITY.md` QA5 (no credential material, ever) and QM72 (a
committed fetch receipt carries no cookie value, session id or server-issued
credential-shaped token; `Set-Cookie`/`Cookie` values removed before commit and the
removal stated in the file).

## 0. File population audited

```
cd /home/vgpnk/Projects/shokunin/kagi-shokunin
{ git diff --name-only 0c07aab8df64b673a54a5113aebd7f34b622adbc..HEAD
  git ls-files --others --exclude-standard
  find .ufo/waves/round-63 -type f; } | sort -u | sed 's|^\./||' > files.txt
wc -l < files.txt
```

Output: `19`. The 19 files at snapshot:

```
plans/round-63.md
.ufo/waves/round-63/base/census.md
.ufo/waves/round-63/build/R63ExecRouted/routed.md
.ufo/waves/round-63/build/R63ScribeRecords/records.md
.ufo/waves/round-63/build_w1_spec.py
.ufo/waves/round-63/census-start.txt
.ufo/waves/round-63/w1-dispatch.err
.ufo/waves/round-63/w1-dispatch.json
.ufo/waves/round-63/w1-spec.json
.ufo/waves/round-63/w1.ready
.ufo/waves/round-63/w1.ready.dispatched
.ufo/waves/round-63/w1/R63ExecControls.md
.ufo/waves/round-63/w1/R63ExecRouted.md
.ufo/waves/round-63/w1/swarm-registry.json
plans/round-63-benign.tsv
plans/round-63-c1.sh
plans/round-63-controls.sh
plans/round-63-residual.tsv
plans/round-63-routed.sh
```

## 1. Credential-shape scan (counts only)

Command (one `grep -E -o` per pattern; only counts are printed, never a matched value):

```
FILES=$(cat files.txt)
scan() { printf '%-28s %s\n' "$1" "$(grep -E -o -I -e "$2" $FILES 2>/dev/null | wc -l)"; }
scan vault_token_hvs        'hvs\.[A-Za-z0-9_-]{8,}'
scan legacy_root_token_s    '\bs\.[A-Za-z0-9]{16,}'
scan op_scheme_ref          'op://'
scan set_cookie_header      'Set-Cookie:'
scan cookie_header          'Cookie:'
scan authorization_header   'Authorization:'
scan session_id             'session[-_ ]?id'
scan session_assign         'session=[A-Za-z0-9]'
scan x_vault_token          'X-Vault-Token'
scan env_token              '(VAULT|BAO)_TOKEN'
scan cf_bm_cookie           '__cf_bm'
scan private_key_pem        '-----BEGIN [A-Z ]*PRIVATE KEY-----'
scan unseal_word            'unseal'
scan root_token_word        'root[ _-]token'
scan secret_id_word         'secret_id'
scan client_token_word      'client_token'
scan hex64_unseal_shape     '\b[0-9a-f]{64}\b'
```

Output:

```
vault_token_hvs              0
legacy_root_token_s          0
op_scheme_ref                3
set_cookie_header            0
cookie_header                0
authorization_header         3
session_id                   6
session_assign               0
x_vault_token                0
env_token                    0
cf_bm_cookie                 0
private_key_pem              0
unseal_word                  6
root_token_word              6
secret_id_word               0
client_token_word            0
hex64_unseal_shape           5
TOTAL_HITS 29
FILES_SCANNED 19
```

**Hit count: 29 occurrences over 19 files; value-shaped hits: 0.**

Value-shaped subset re-counted separately (a token prefix, a cookie header, a
bot-management cookie, a Vault header, a token env var, a PEM header):

```
for f in $FILES; do grep -E -o -I \
  -e 'hvs\.[A-Za-z0-9_-]{8,}' -e '\bs\.[A-Za-z0-9]{16,}' -e 'Set-Cookie:' -e 'Cookie:' \
  -e '__cf_bm' -e 'X-Vault-Token' -e '(VAULT|BAO)_TOKEN' \
  -e '-----BEGIN [A-Z ]*PRIVATE KEY-----' "$f"; done | wc -l
```

Output: `0`.

Classification of the 29 hits (per-file breakdown, `grep -E -o -I` over the same
pattern set):

```
.ufo/waves/round-63/base/census.md                           1
.ufo/waves/round-63/build/R63ScribeRecords/records.md        1
.ufo/waves/round-63/build_w1_spec.py                         9
.ufo/waves/round-63/w1-dispatch.json                         9
.ufo/waves/round-63/w1-spec.json                             9
```

- `build_w1_spec.py`, `w1-spec.json`, `w1-dispatch.json` (9 each): the wave template's
  own instruction text names the shapes it forbids — the strings `op://`,
  `Authorization:`, `session id`, `unseal`, `root token` and the bao binary sha256
  `9c5f3628…` appear as pattern names and a digest, not as values. No reference path
  follows `op://`; no value follows `Authorization:`.
- `base/census.md` and `build/R63ScribeRecords/records.md` (1 each): the sha256 pin
  `f2afd9b8f5382cdf8b8914546bb8fcb73d135854e6e546c5012fb7df63eca9c0` of
  `plans/round-61-c1-check.py`, a digest, not an unseal key.
- `hex64_unseal_shape` = 5: three occurrences of the bao binary digest `9c5f3628…`
  (template files) and two of the instrument pin `f2afd9b8…` (`census.md`,
  `records.md`). Both are sha256 digests; neither is a 64-hex unseal key.

**Verdict: no credential material.** No secret value, token, session id, vault/item/field
name, cookie value or `op://` reference path in any round-63 artifact. The `op://` and
`Authorization:` spellings are pattern names in the seat brief, and the lane's own
committed instruments already spell them (`corpus/transcript-scan.sh:84`,
`corpus/op-ref-probe.sh:198`, `corpus/scope-gate.sh:59`), so no new exposure class is
introduced.

**QM72 status at snapshot: not exercisable.** `.ufo/waves/round-63/capture/` is empty —
no fetch receipt (headers, meta or body) exists yet, so there is no `Set-Cookie`/`Cookie`
surface to audit. This is a snapshot boundary, not a pass; re-run this check at landing
(the capture seat `R63ScoutSources` is still running).

## 2. Receipt-path check

Command (every absolute and wave-relative path cited by the round's artifacts):

```
grep -rhoE '(/[A-Za-z0-9_.-]+){2,}' plans/round-63.md \
  .ufo/waves/round-63/base/census.md .ufo/waves/round-63/census-start.txt \
  .ufo/waves/round-63/w1-spec.json .ufo/waves/round-63/w1-dispatch.json \
  .ufo/waves/round-63/w1/swarm-registry.json .ufo/waves/round-63/build_w1_spec.py \
  .ufo/waves/round-63/w1.ready .ufo/waves/round-63/w1.ready.dispatched \
  | sort | uniq -c | sort -rn
```

And the report/receipt targets the wave spec names:

```
grep -oE '\.ufo/waves/round-63/[A-Za-z0-9_./-]+' .ufo/waves/round-63/w1-spec.json \
  | sort | uniq -c
```

Output (report targets):

```
2 .ufo/waves/round-63/capture/notes.md
1 .ufo/waves/round-63/w1
1 .ufo/waves/round-63/final/
1 .ufo/waves/round-63/capture/
1 .ufo/waves/round-63/build/R63Sentinel/audit.md
1 .ufo/waves/round-63/build/R63ScribeRecords/sources-block.md
1 .ufo/waves/round-63/build/R63ScribeRecords/records.md
1 .ufo/waves/round-63/build/R63ScribeEntry/entry.md
1 .ufo/waves/round-63/build/R63ScoutPreState/prestate.md
1 .ufo/waves/round-63/build/R63Reviewer/findings.md
1 .ufo/waves/round-63/build/R63MutC2/mutants.md
1 .ufo/waves/round-63/build/R63MutC1/mutants.md
1 .ufo/waves/round-63/build/R63ExecRouted/routed.md
1 .ufo/waves/round-63/build/R63ExecControls/controls.md
1 .ufo/waves/round-63/build/R63ExecC2Counter/counter.md
1 .ufo/waves/round-63/build/R63ExecC1Grammar/grammar.md
1 .ufo/waves/round-63/build/R63ExecC1Counter/counter.md
1 .ufo/waves/round-63/build/R63Critic/critique.md
1 .ufo/waves/round-63/build/R63Connector/sweep.md
```

Every report/receipt target is inside the lane tree under `.ufo/waves/round-63/`.
`reportDir` is `.ufo/waves/round-63/w1`; the 15 seat reports land there. No target is
`/tmp`, `/var/tmp` or a `$HYAKU_SCRATCH` path.

External-path mentions found by the first command, classified:

| path | where | classification |
|---|---|---|
| `/fast/scratch/hyaku/kagi-r63/L1-base/` | `plans/round-63.md:273` (§Bounds) | **allowed** — the plan pre-declares it "not citable evidence" and says the committed counters re-derive it |
| `/fast/scratch/hyaku/kagi-r63/L1-base/base` | `.ufo/waves/round-63/base/census.md:4` | **observation O1** — the census names the scratch tree it measured; not a receipt path and not cited as evidence, but the receipt is not self-contained |
| `/fast/scratch/hyaku` | `build_w1_spec.py`, `w1-spec.json`, `w1-dispatch.json` | **allowed** — scratch-root instruction text |
| `/tmp`, `/var/tmp` | `build_w1_spec.py:204`, `w1-spec.json`, `w1-dispatch.json` | **allowed** — the instruction that forbids them |

No receipt path outside the lane tree. Two `/tmp` fixture violations found by the
scratch sweep are named in §4 (V1, V2); neither is cited as evidence anywhere in the
lane (`grep -rn '/tmp/r63routed-task.txt\|/tmp/c1ck'` over the lane ⇒ no output).

## 3. Write-scope check

```
git -C /home/vgpnk/Projects/shokunin status --porcelain
git -C /home/vgpnk/Projects/shokunin/kagi-shokunin status --porcelain -uall
```

Fleet root output:

```
 M .scratch/goal-20261103-hyaku-run15.md
 M .scratch/run15-state.json
?? .scratch/run15-wrapup/misroot-cff0b4cb/
```

Lane output:

```
 M corpus/claims-declared.tsv
 M plans/round-62-c1.sh
?? .ufo/waves/round-63/build/R63ExecRouted/routed.md
?? .ufo/waves/round-63/build/R63ScribeRecords/records.md
?? .ufo/waves/round-63/w1-dispatch.err
?? .ufo/waves/round-63/w1.ready
?? .ufo/waves/round-63/w1.ready.dispatched
?? .ufo/waves/round-63/w1/R63ExecControls.md
?? .ufo/waves/round-63/w1/R63ExecRouted.md
?? .ufo/waves/round-63/w1/swarm-registry.json
?? plans/round-63-benign.tsv
?? plans/round-63-c1.sh
?? plans/round-63-controls.sh
?? plans/round-63-residual.tsv
?? plans/round-63-routed.sh
```

Attribution, against the write scope each seat's prompt declares:

| path | owner named in the spec | verdict |
|---|---|---|
| `plans/round-63-c1.sh` | `R63ExecC1Counter` ("You own those two files plus your receipts") | in scope |
| `plans/round-62-c1.sh` (M) | `R63ExecC1Counter` | in scope |
| `plans/round-63-benign.tsv`, `plans/round-63-residual.tsv` | `R63ExecC1Counter` (named in its prompt) | in scope |
| `plans/round-63-controls.sh` | `R63ExecControls` ("You own that one file") | in scope |
| `plans/round-63-routed.sh` | `R63ExecRouted` ("You own that one file") | in scope |
| `build/R63ExecRouted/routed.md` | `R63ExecRouted` receipt dir | in scope |
| `build/R63ScribeRecords/records.md` | `R63ScribeRecords` receipt dir | in scope |
| `w1/R63ExecControls.md`, `w1/R63ExecRouted.md` | `reportDir` | in scope |
| `w1-dispatch.err`, `w1.ready`, `w1.ready.dispatched`, `w1/swarm-registry.json` | orchestrator dispatch files | in scope (wave dir) |
| `corpus/claims-declared.tsv` (M) | no seat spec names it | **observation O2** — the L1's QM64 edit |

`corpus/claims-declared.tsv` diff:

```
+62	C1	calibration
+62	C2	operability
+63	C1	calibration
+63	C2	operability
```

The pre-edit backup at the wave scratch root is byte-identical to `HEAD`:

```
git show HEAD:corpus/claims-declared.tsv | diff - /fast/scratch/hyaku/kagi-r63/claims-declared.tsv.bak
```

Output: no diff (`BAK_EQUALS_HEAD`). No seat prompt names this file (the only
`claims-declared` occurrence in `w1-spec.json` is `R63ExecRouted`'s receipt filename
`.ufo/waves/round-63/final/claims-declared.txt`). The edit is the L1's QM64 landing work
and the L1 is the sole committer; **not a seat write-scope breach**.

Sibling-lane check (every lane repo at the fleet root):

```
for d in */; do [ -d "$d/.git" ] || continue
  git -C "$d" status --porcelain -uall 2>/dev/null | grep -i 'kagi-r63\|round-63' | sed "s|^|$d |"
done
```

Output: only `kagi-shokunin/` entries. `kasegi-shokunin` (its own round 100) and
`mado-shokunin` (its own round 63 closure) show working-tree activity, but no
kagi round-63 path and no kagi-named file. **No sibling-lane write.**

Files at the fleet root that name kagi round 63 (strict pattern
`kagi round 63|kagi.*round-63|kagi-r63`, excluding `.git`/`.jj`/the lane):

```
./.ufo/prompts/kagi-round-63.md          (orchestrator prompt, 19:44)
```

plus the orchestrator's own state surfaces that carry a `kagi` key:
`.ufo/state/*` (orchestrator), `.scratch/run15-state.json` (orchestrator run state,
20:01:13) and `.scratch/goal-20261103-hyaku-run15.md`. `.ufo/l0-questions.md`
(13:34, pre-round) mentions kagi rounds 3/10/19, not round 63. No file at the fleet
root was written by a kagi seat: the fleet-root modifications are the orchestrator's
`.scratch` run state.

Host-path check (read-only inputs: `/boot`, `/etc`, `/usr`, `/var`, `/efi`, other homes):

```
find /etc /usr/local /boot -maxdepth 2 -newermt '2026-11-07 19:55'
find /var -xdev \( -path /var/tmp -o -path /var/log -o -path /var/cache -o -path /var/lib/pacman \) -prune -o -newermt '2026-11-07 19:55' -print
find /efi -newermt '2026-11-07 19:55'
find /home -maxdepth 2 -newermt '2026-11-07 19:55' ! -path '/home/vgpnk/*'
find /home/vgpnk/.local/bin -maxdepth 1 -newermt '2026-11-07 19:55'
```

Output: `/etc`, `/usr/local`, `/boot`, `/efi`, other homes and `~/.local/bin` ⇒ empty.
`/var` ⇒ one line, `/var/lib/systemd/timesync/clock` (systemd-timesyncd, a host
service; not a seat write). **No host-path write by any seat.**

## 4. Scratch discipline

```
du -sh /fast/scratch/hyaku/kagi-r63/*
```

Output at snapshot:

```
12G	/fast/scratch/hyaku/kagi-r63/L1-base
616M	/fast/scratch/hyaku/kagi-r63/L1-check
13G	/fast/scratch/hyaku/kagi-r63/R63Critic
0	/fast/scratch/hyaku/kagi-r63/R63ExecC1Counter
206M	/fast/scratch/hyaku/kagi-r63/R63ExecC1Grammar
821M	/fast/scratch/hyaku/kagi-r63/R63ExecControls
208M	/fast/scratch/hyaku/kagi-r63/R63MutC1
821M	/fast/scratch/hyaku/kagi-r63/R63MutC2
317M	/fast/scratch/hyaku/kagi-r63/R63Reviewer
2.1G	/fast/scratch/hyaku/kagi-r63/R63ScoutPreState
3.1M	/fast/scratch/hyaku/kagi-r63/R63ScoutSources
2.3G	/fast/scratch/hyaku/kagi-r63/R63ScribeEntry
4.0K	/fast/scratch/hyaku/kagi-r63/R63ScribeRecords
20K	/fast/scratch/hyaku/kagi-r63/R63Sentinel
4.0K	/fast/scratch/hyaku/kagi-r63/claims-declared.tsv.bak
```

- `L1-base` (12G) and `L1-check` (616M) are the L1's, not seat trees.
- Every seat tree is under `kagi-r63/<seat-name>/` as the brief requires. At snapshot
  the wave was still running, so these trees are **live, not abandoned**.
- `R63ExecC2Counter` (idle) has no tree — it cleaned up before yielding. Good.
- `R63Sentinel` is this seat's tree and is deleted before yield.
- **V3:** `claims-declared.tsv.bak` (836 B) sits at the wave scratch root, not under a
  seat dir. It is the L1's pre-edit backup of `corpus/claims-declared.tsv` and is
  byte-identical to `HEAD`. Stray; remove with the scratch root.
- Empty seat trees at snapshot: `R63ExecC1Counter` (0 files) and `R63ScribeRecords`
  (4.0K, receipts only). `R63ExecC1Counter` is still running with an empty mandated
  scratch dir while a 206 MB BASE extraction exists at `/tmp/c1ck` (V1) — see below.

## Violations

| id | severity | violation | evidence | smallest remediation |
|---|---|---|---|---|
| V1 | **medium** | A 206 MB extracted BASE tree lives at `/tmp/c1ck`, outside the mandated `$HYAKU_SCRATCH/kagi-r63/<seat>/` root and over the 50 MB `/tmp` allowance. | `du -sh /tmp/c1ck` ⇒ `206M`; `stat -c %y /tmp/c1ck` ⇒ `2026-11-07 20:01:39` (created during the wave; file mtimes are the BASE commit time 19:43:06); no round-63 file inside; not cited as evidence (`grep` over the lane ⇒ 0). Probable owner `R63ExecC1Counter` — its mandated scratch is empty at 20:00:47 and it needs a BASE tree. **[INFERENCE]** | `rm -rf /tmp/c1ck` after the owning seat yields; the seat should extract under its own scratch dir. |
| V2 | low | `/tmp/r63routed-task.txt` (3,110 B) — task-text scratch under `/tmp`, outside the mandated scratch root. | `ls -la /tmp/r63routed-task.txt` ⇒ 3,110 B, 20:00:59; not cited as evidence (`grep` ⇒ 0); under the 50 MB allowance | delete with the scratch root; no evidence depends on it |
| V3 | low | `claims-declared.tsv.bak` (836 B) left at the wave scratch root, not under a seat dir. | `ls -la /fast/scratch/hyaku/kagi-r63/claims-declared.tsv.bak` ⇒ 836 B, 20:01:58; `diff` against `HEAD:corpus/claims-declared.tsv` ⇒ identical | remove with the scratch root |

No credential-material violation (QA5), no `/tmp`-cited evidence, no host-path write,
no sibling-lane write, no write outside a seat's declared paths.

## Observations (not violations)

- **O1.** `base/census.md:4` names the L1's scratch tree
  (`/fast/scratch/hyaku/kagi-r63/L1-base/base`) as the tree it measured. The plan
  §Bounds pre-declares that tree "not citable evidence" and says the committed counters
  re-derive it, so this is a method note, not a receipt path. The receipt is not
  self-contained; the counters are.
- **O2.** `M corpus/claims-declared.tsv` is the only modified tracked lane file. It
  adds rounds 62 and 63 rows (QM64). No seat spec names it; the L1 is the sole
  committer. In scope for the L1, not a seat write.
- **O3.** The wave's milestone string in `w1-spec.json` and `w1/swarm-registry.json`
  reads `C2 C2_REFUSAL killed 0->6 … six named surviving mutants`, while the frozen
  plan's Amendment A2 (`plans/round-63.md:300`) sets **population 5, target killed=5**
  (L5 vacuous at BASE). The dispatch text was not updated to A2. This is a record
  defect for the L1 to route (the frozen predicate is authoritative; the seat briefs
  and the registry carry the stale 6). Reported, not amended.
- **O4.** `R63ExecC1Counter` and `R63ScribeRecords` scratch trees were empty/partial at
  snapshot; both seats were still running.

## Snapshot boundary

The audit ran at 2026-11-07T23:03:49Z while the wave was in flight. Not yet existing
and therefore **not audited**: `.ufo/waves/round-63/capture/` (fetch receipts — QM72's
cookie-removal surface) and `.ufo/waves/round-63/final/` (the gate receipts `db`
requires). Re-run checks 1 and 2 at landing, after the capture and final receipts are
committed. Everything that existed at snapshot is covered above.

SEAT-STATUS: complete
