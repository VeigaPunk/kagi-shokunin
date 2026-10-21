# RevClosureExit — round-23 falsification: closure disposition exit semantics

- Seat: falsification reviewer (leaf), round 23, base `d218603b74099ddca0bd8f869516fc41db0979bf` + uncommitted round-23 tree.
- Attack target: `corpus/closure-dispositions.py` (C1) exit semantics against its own documented contract.
- Lane was read-only: every mutation ran on a copy under `/tmp/r23-rev-closureexit`; no file under the lane was written or edited. The one authorized write is this report.
- I did not run `corpus/claim-ledger.sh verify` or any host-bound row. I ran the C1 gate directly (the command named by `claim-ledger.tsv:60` R23-02) and its `--selftest`.

## Artifacts under test (byte identity checked)

```
$ sha256sum corpus/closure-dispositions.py corpus/closure-dispositions.json corpus/lessons/round-22-verifier-spotcheck.md
6cc822785d2b93c6061b9cc738398bef533391cbe7d4cf36aa2567bb358bddd4  corpus/closure-dispositions.py
f20f00d1be8d50984953eb21c377a333912e9c1ca346e4637850586f04cc0d59  corpus/closure-dispositions.json
65a5b3dee667146c47c158d344dad7c2a9307d6997a0a9800d92b7dbb55869f7  corpus/lessons/round-22-verifier-spotcheck.md
```

The JSON pin `source_sha256` equals the independently computed source digest (`65a5…69f7`), and the JSON `source` field equals the default source path.

## Setup and baseline

```
$ rm -rf /tmp/r23-rev-closureexit && mkdir -p /tmp/r23-rev-closureexit
$ cp -a /home/vgpnk/Projects/shokunin/kagi-shokunin/corpus /tmp/r23-rev-closureexit/corpus
$ cd /tmp/r23-rev-closureexit && cp corpus/closure-dispositions.json baseline.json
$ cmp corpus/closure-dispositions.py /home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/closure-dispositions.py && echo SCRIPT_IDENTICAL
SCRIPT_IDENTICAL
$ cmp baseline.json /home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/closure-dispositions.json && echo JSON_IDENTICAL
JSON_IDENTICAL

$ cd /tmp/r23-rev-closureexit && python3 corpus/closure-dispositions.py --root .
CLOSURE_DISPOSITIONS: CLEAN (obligations=15 fixed=7 reported=2 operator_owned=1 no_action=5 rejected=0 pointers=15)
EXIT=0

$ cd /tmp/r23-rev-closureexit && python3 corpus/closure-dispositions.py --selftest
… all 13 case lines report ok …
CLOSURE_DISPOSITIONS_SELFTEST: PASS (13 cases)
EXIT=0
```

The lane itself, read-only, produced the same line with exit 0:

```
$ cd /home/vgpnk/Projects/shokunin/kagi-shokunin && python3 corpus/closure-dispositions.py --root .
CLOSURE_DISPOSITIONS: CLEAN (obligations=15 fixed=7 reported=2 operator_owned=1 no_action=5 rejected=0 pointers=15)
LANE_EXIT=0
```

`R23-02`'s expected regex matches that line (`grep -E "$expected" cases/actual.txt` → `REGEX_ROW_MATCH`, grep exit 0). Obligation count cross-checked independently against the source: 9 `^- D<n> ` bullets, 5 `admit|reject` table rows, 1 `**ADMITTED.**` line = 15; live JSON ids are unique (`jq -r '.dispositions[].id' | sort | uniq -d` → 0).

## Assigned exit-semantics attacks — all six conform

Each case mutated only `cases/<case>.json` in the copy and was invoked as
`python3 corpus/closure-dispositions.py --root . --dispositions "$PWD/cases/<case>.json"`.
Exit codes were captured directly (no pipeline).

| case | mutation command | observed output (stdout tail) | exit | documented | result |
|---|---|---|---|---|---|
| missing obligation (row removed) | `jq 'del(.dispositions[] \| select(.id=="D9"))' baseline.json > cases/missing.json` | `DISPOSITION MISSING D9` / `CLOSURE_DISPOSITIONS: FAILED (obligations=15 dispositions=14 missing=1 unknown=0 unresolved=0)` | 1 | FAILED exit 1 | conforms |
| missing obligation (source adds D10, pin updated) | source copy `+ "- D10 tenth obligation added adversarially"`; JSON `source_sha256` recomputed | `DISPOSITION MISSING D10` / `CLOSURE_DISPOSITIONS: FAILED (obligations=16 dispositions=15 missing=1 unknown=0 unresolved=0)` | 1 | FAILED exit 1 | conforms |
| duplicate id | `jq '.dispositions += [.dispositions[0]]' baseline.json > cases/duplicate.json` | `CLOSURE_DISPOSITIONS: SETUP (duplicate disposition id SPOT-01)` | 2 | SETUP exit 2 | conforms |
| duplicate id D1 | `jq '.dispositions += [.dispositions[] \| select(.id=="D1")]' baseline.json > cases/dupD1.json` | `CLOSURE_DISPOSITIONS: SETUP (duplicate disposition id D1)` | 2 | SETUP exit 2 | conforms |
| unknown id | append `{"id":"X9","class":"routed-defect","disposition":"no-action","note":"unknown obligation recorded anyway for adversarial test"}` | `DISPOSITION UNKNOWN X9` / `CLOSURE_DISPOSITIONS: FAILED (obligations=15 dispositions=16 missing=0 unknown=1 unresolved=0)` | 1 | FAILED exit 1 | conforms |
| invalid kind | `jq '(.dispositions[] \| select(.id=="D2").disposition) = "ignored"' baseline.json` | `CLOSURE_DISPOSITIONS: SETUP (invalid disposition 'ignored' for D2)` | 2 | SETUP exit 2 (line 27: malformed record) | conforms |
| source-digest mismatch | `jq '.source_sha256 = ("0" * 64)' baseline.json` | `CLOSURE_DISPOSITIONS: SETUP (source digest mismatch: 0000…0000 -> 65a5b3dee667146c47c158d344dad7c2a9307d6997a0a9800d92b7dbb55869f7)` | 2 | SETUP exit 2 | conforms |
| pointer escape (`..`) | D1 pointer `../corpus/lessons/round-23.md#Routed defect dispositions` | `DISPOSITION POINTER-ESCAPE D1 ../corpus/lessons/round-23.md#Routed defect dispositions` / `CLOSURE_DISPOSITIONS: FAILED (obligations=15 dispositions=15 missing=0 unknown=0 unresolved=1)` | 1 | FAILED exit 1 | conforms |
| pointer escape (absolute) | SPOT-01 pointer `/etc/hostname` | `DISPOSITION POINTER-ESCAPE SPOT-01 /etc/hostname` / `…FAILED (… unresolved=1)` | 1 | FAILED exit 1 | conforms |
| pointer escape (embedded `..`) | SPOT-01 pointer `corpus/../corpus/SOURCES.md` | `DISPOSITION POINTER-ESCAPE SPOT-01 corpus/../corpus/SOURCES.md` / `…FAILED (… unresolved=1)` | 1 | FAILED exit 1 | conforms |
| pointer escape (anchor-only) | SPOT-01 pointer `#Routed` | `DISPOSITION POINTER-ESCAPE SPOT-01 #Routed` / `…FAILED (… unresolved=1)` | 1 | FAILED exit 1 | conforms |

Every one of the six assigned branches uses the documented exit code and prints the documented prefix (`DISPOSITION MISSING|UNKNOWN|POINTER-ESCAPE` + final `CLOSURE_DISPOSITIONS: FAILED` for exit 1; `CLOSURE_DISPOSITIONS: SETUP (` for exit 2). The `FAILED`/`CLEAN` summary field names and the `PASS (13 cases)` count also match the docstring. No defect against the assigned six paths.

Adjacent exit paths also conformed: short note → `DISPOSITION NOTE-SHORT D1 note < 24 chars`, exit 1; fixed without pointer → `DISPOSITION POINTER-MISSING D1 fixed without pointer`, exit 1; non-string pointer → `DISPOSITION POINTER-MALFORMED SPOT-01 pointer is not a string`, exit 1; anchor miss → `DISPOSITION POINTER-ANCHOR SPOT-03 corpus/SOURCES.md#S004`, exit 1; non-object row → `SETUP (disposition row is not an object)`, exit 2; wrong schema → `SETUP (schema mismatch: 'wrong-schema')`, exit 2; empty list → `SETUP (dispositions list is empty)`, exit 2; broken JSON → `SETUP (dispositions unreadable: Expecting property name …)`, exit 2; absent file → `SETUP (dispositions unreadable: [Errno 2] …)`, exit 2; unreadable dispositions (mode 000) → `SETUP (dispositions unreadable: [Errno 13] …)`, exit 2; missing source → `SETUP (source not found: …)`, exit 2; source-field mismatch → `SETUP (source field '…' != requested '…')`, exit 2; unknown argument / missing option value → `SETUP`, exit 2; `--help` exit 0.

## Findings

### F1 (medium, exit-contract violation) — invalid UTF-8 in the dispositions file escapes SETUP and exits 1 with a traceback

`load_dispositions` catches only `(OSError, json.JSONDecodeError)` at `corpus/closure-dispositions.py:127`. `Path.read_text(encoding="utf-8")` at `:126` raises `UnicodeDecodeError`, which is a `ValueError`/`UnicodeError`, not `OSError`, and is not caught. The docstring promises `<line 27>`: "a malformed record exits 2" and documents only `SETUP` for exit 2.

```
$ cd /tmp/r23-rev-closureexit && printf '\xff\xfe{"schema":' > cases/nonutf8.json
$ python3 corpus/closure-dispositions.py --root . --dispositions "$PWD/cases/nonutf8.json" >cases/nonutf8.out 2>cases/nonutf8.err; echo "EXIT=$?"
EXIT=1
$ wc -c < cases/nonutf8.out
0
$ tail -2 cases/nonutf8.err
  File "<frozen codecs>", line 325, in decode
UnicodeDecodeError: 'utf-8' codec can't decode byte 0xff in position 0: invalid start byte
```

Observed: exit 1, empty stdout, no `CLOSURE_DISPOSITIONS:` prefix at all. Documented: a malformed record → `CLOSURE_DISPOSITIONS: SETUP (…)`, exit 2. A CI wrapper keyed on the documented exit codes would classify a corrupt registry as a coverage `FAILED` (1) rather than a setup fault (2), and keying on the verdict line would match nothing. Unlike a missing file or syntactically broken JSON, this branch is unhandled.

### F2 (low, exit-contract violation) — unreadable source or pointer target exits 1 with a traceback

Three read sites are unguarded: source digest (`:73` `path.read_bytes()`), pointer target (`:112` `target.read_text(…, errors="replace")`), source parse (`:151`, after the digest already ran). Contrast: the dispositions read is guarded (`:127` → SETUP 2).

```
$ cd /tmp/r23-rev-closureexit
$ cp corpus/SOURCES.md corpus/SOURCES.locked.md && chmod 000 corpus/SOURCES.locked.md
$ jq '(.dispositions[] | select(.id=="SPOT-01").pointer) = "corpus/SOURCES.locked.md"' baseline.json > cases/unreadableptr.json
$ python3 corpus/closure-dispositions.py --root . --dispositions "$PWD/cases/unreadableptr.json" 2>&1 | tail -2; echo "EXIT=${PIPESTATUS[0]}"
PermissionError: [Errno 13] Permission denied: 'corpus/SOURCES.locked.md'
EXIT=1

$ cp corpus/lessons/round-22-verifier-spotcheck.md corpus/lessons/locked.md
$ jq '.source = "corpus/lessons/locked.md" | .source_sha256 = "65a5b3dee667146c47c158d344dad7c2a9307d6997a0a9800d92b7dbb55869f7"' baseline.json > cases/unreadablesrc.json
$ chmod 000 corpus/lessons/locked.md
$ python3 corpus/closure-dispositions.py --root . --source corpus/lessons/locked.md --dispositions "$PWD/cases/unreadablesrc.json" 2>&1 | tail -2; echo "EXIT=${PIPESTATUS[0]}"
PermissionError: [Errno 13] Permission denied: 'corpus/lessons/locked.md'
EXIT=1
```

Re-run with separate streams confirmed stdout is empty (`STDOUT_BYTES=0`) and exit is 1 for the pointer case.

Both cases emit a Python traceback, empty stdout, exit 1 — indistinguishable by exit code from the documented `FAILED` (1), and not the documented `SETUP` (2). Practical likelihood is low (committed files are readable), but the gate's own contract classifies setup faults as exit 2; this is the same fail-shape as F1 on a different trigger.

### F3 (low, containment) — POINTER-ESCAPE is lexical only; a symlink inside the root resolves a pointer outside the root and the gate returns CLEAN

`resolve_pointer` rejects only empty paths, absolute paths, and a `..` component (`:107`), then joins and reads (`:109-112`) without resolving symlinks. Demonstrated with a `fixed` disposition, i.e. the branch whose pointer is supposed to prove an in-tree record:

```
$ ln -sfn /tmp/r23-outside-d1.md corpus/outside-evidence.md   # in /tmp copy only
$ printf '# outside\n\nD1 is handled outside the root.\n' > /tmp/r23-outside-d1.md
$ jq '(.dispositions[] | select(.id=="D1").pointer) = "corpus/outside-evidence.md"' baseline.json > cases/symlinkfixed.json
$ python3 corpus/closure-dispositions.py --root . --dispositions "$PWD/cases/symlinkfixed.json"; echo "EXIT=$?"
CLOSURE_DISPOSITIONS: CLEAN (obligations=15 fixed=7 reported=2 operator_owned=1 no_action=5 rejected=0 pointers=15)
EXIT=0
$ readlink -f corpus/outside-evidence.md
/tmp/r23-outside-d1.md
```

This contradicts `claim-ledger.tsv:60`'s note that the gate "resolves every fixed pointer in-tree" if read as a containment guarantee. Live exposure is nil today: `find corpus -type l` = 0 and `git ls-files -s corpus | awk '$1==120000'` = 0 — the corpus contains no symlinks. It is a hardening gap, not a false pass on committed artifacts.

### F4 (low, doc/impl mismatch) — the documented `**REJECTED…**` adjudication line produces no `ADJ` obligation

The docstring says the adjudication section is identified by "a line starting `**ADMITTED.**`/`**REJECTED...**`" (`:16`) and that obligations include `ADJ`; `parse_obligations` only sets `ADJ` for `**ADMITTED.**` (`:99`). Tested on a source copy whose adjudication line was changed to `**REJECTED by outside review.**` with the pin recomputed (`cp corpus/lessons/round-22-verifier-spotcheck.md corpus/lessons/rejected.md`; one-line `**ADMITTED.**` → `**REJECTED by outside review.**` replacement; `sha256` recomputed into `cases/rejected_keepadj.json` and `cases/rejected_no_adj.json`, the latter with the `ADJ` row removed):

```
CASE_KEEP_ADJ  (baseline ADJ row retained)
DISPOSITION UNKNOWN ADJ
CLOSURE_DISPOSITIONS: FAILED (obligations=14 dispositions=15 missing=0 unknown=1 unresolved=0)
EXIT=1
CASE_NO_ADJ    (ADJ row removed)
CLOSURE_DISPOSITIONS: CLEAN (obligations=14 fixed=7 reported=1 operator_owned=1 no_action=5 rejected=0 pointers=14)
EXIT=0
```

So a rejected adjudication is either an `UNKNOWN` failure (if the author follows the disposition set for the admitted case) or silently dropped (`obligations=14`, CLEAN). The live source uses `**ADMITTED.**`, so C1's current claim is unaffected; the gap is in the stated general capability and in the selftest (no REJECTED case).

### F5 (low, calibration limit) — duplicate obligation bullets in the source collapse silently to one obligation

`parse_obligations` stores obligations in a dict keyed by id (`:90`), so a duplicated `- D9 …` bullet overwrites rather than adds. With the duplicated bullet in a source copy (`cp … dupsrc.md`; the existing `- D9 ` line appended immediately after itself; `source_sha256` recomputed) and the pin recomputed:

```
duplicated bullet count: 2
CLOSURE_DISPOSITIONS: CLEAN (obligations=15 fixed=7 reported=2 operator_owned=1 no_action=5 rejected=0 pointers=15)
EXIT=0
```

The docstring's format claim is "one `- D<N> ...` bullet per defect" (`:13`), and the gate's purpose is "exactly one typed disposition per obligation" (`:8`); a malformed source with two bullets for one id still passes CLEAN with one disposition. The live source has exactly one bullet per id (`grep -cE "^- D<n> "` = 1 for D1–D9), so no live false pass; source edits are also behind the digest pin.

### F6 (informational, test strength) — selftest does not assert the documented SETUP prefix or FAILED summary shape; empty anchor is accepted

`selftest` accepts a case when `rc == want_rc and needle in full` (`:326`), where the exit-2 needles are bare substrings (`invalid disposition`, `duplicate disposition id D1`, `source digest mismatch`). A regression that dropped `CLOSURE_DISPOSITIONS: SETUP (` or the `CLOSURE_DISPOSITIONS: FAILED (…)` summary would still print PASS. Separately, `pointer.partition("#")` with an empty anchor makes `corpus/SOURCES.md#` behave exactly like `corpus/SOURCES.md` (CLEAN, exit 0); the documented anchor requirement is vacuous for an empty anchor. Neither affects the six assigned branches' current outputs.

## What did not falsify

- The six assigned exit semantics (missing, duplicate, unknown, invalid kind, digest mismatch, lexical pointer escape) all produce the documented exit code and documented prefix.
- The live pin, obligation count, id uniqueness, `fixed` pointer resolution (D1/D3–D6/D8 in `corpus/lessons/round-23.md`, D7 in `corpus/source-fetches.tsv`, D9 in `corpus/claim-ledger.tsv`), the exact CLEAN line vs the R23-02 regex, and the 13-case selftest all hold at the observed bytes.
- The gate is host-free in the baseline runs (stdlib only, no network, reads confined to the tree for lexical paths; see F3 for the symlink caveat).

## Residual risk and verification gaps

1. F1/F2 mean the documented `SETUP`/exit-2 contract is not total: corrupt encodings and unreadable source/pointer files surface as exit 1 with empty stdout. If exit code is the machine contract, these are the only contract violations found; if the verdict line is the contract, these paths produce none.
2. F3 requires a symlink to be committed; none exists today. A `Path.resolve()` + commonpath containment check (or `O_NOFOLLOW`-style handling) would close it.
3. F4/F5 are capability limits, not live misstatements: the current source is `ADMITTED` and has no duplicate bullets, and the digest pin forces any such source edit through review.
4. Not run, by contract: `corpus/claim-ledger.sh verify` and any host-bound/host-private row, network re-fetch, and any mutation of the lane. R23-02's wrapper invocation was not executed end-to-end; the underlying command and its output line were verified directly.
5. Verification is against Python 3.14.8 on this host; the traceback frames (`pathlib`, `codecs`, `io`) are interpreter-specific, the exit codes are not.
