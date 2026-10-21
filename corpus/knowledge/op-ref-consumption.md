# `op.env` consumption — two parsers, one file (round 12, depth axis-move)

Source basis: read-only inspection 2026-09-28 of `~/.local/bin/the-janitor`
(`ENV_FILE` L7, `cmd_refs` L228–236, `cmd_run` L237–249, `need_op` L58),
`op --help` / `op run --help` / `op inject --help` / `op read --help` /
`op service-account --help` from `op` **2.35.0** (`/usr/bin/op`), and live
probes in a `mktemp -d` scratch tree over **fabricated, plain-valued** env
files. No vault read, no reference resolved, no approval prompt, no sign-in
dependency: every `op` invocation in this round went through the POLICY guard
in `corpus/op-ref-probe.sh`, which refuses **before exec** any op-side path that
carries the ref scheme token, is not a plain regular file (symlink, FIFO,
socket, device), or breaks a probe's premise (`absent.env` must not exist;
`adir` must be a real directory). That third clause is the round-12 sentinel's
finding F1/F2 — an earlier revision guarded a fixed name list, and
`--fixture DIR` could supply `absent.env` or a *file* named `adir` and reach the
binary; the guard is now per-path. No secret value, ref path, or account identifier is
recorded here.

Re-run everything in §Reproduction. The machine-checkable half of this entry is
`bash corpus/op-ref-probe.sh` (live) and `--selftest` (comparator); the one-offs
that cannot be mechanised are named in §Bounds with the reason.

Reverify: R11-01, R12-01, R12-02, R21-01

## 1. The two consumers are not the same parser

| Consumer | What it is | What it answers |
|---|---|---|
| `the-janitor refs` → `cmd_refs` L234 | an `awk -F= '/^[A-Z][A-Z0-9_]*=/'` over the raw lines | "which *lines* of this file look like uppercase assignments, and does the value start with the ref scheme?" |
| `the-janitor run -- <cmd>` → `cmd_run` L248 | `exec op run --env-file="$ENV_FILE" -- "$@"` | "what does the *dotenv resolver* inject into `<cmd>`?" |

`cmd_run` passes **no** `--no-masking`, so `op`'s default masking applies (see
§3). `refs` resolves nothing — it is a text inventory, and every claim below
about it is a claim about that `awk`, not about 1Password.

## 2. Measured divergence, per line shape

Same file read by both sides (`corpus/op-ref-probe.sh` fixtures; `--` marks the
one-off, non-mechanised rows):

| Line in `op.env` | `op run` injects | `refs` inventory | Divergence class |
|---|---|---|---|
| `K=plain` | `plain` | `K=<redacted-non-op-value>` | agree |
| `K = plain` (spaces around `=`) | `plain` | **key absent** | inventory false negative |
| `export K=plain` | `plain` | **key absent** | inventory false negative |
| `k=plain` (lowercase key) | `plain` | **key absent** | inventory false negative |
| `K="quoted value"` | `quoted value` (quotes stripped) | key present, redacted | value form invisible to `refs` |
| `K=` | empty string, still injected | key present, redacted | agree |
| `K=$OTHER` / `K=${OTHER}-x` | **expanded** (file-local first, then process env; unset → empty) | key present, redacted | expansion invisible to `refs` |
| `K=a\ b` | `a\ b` (backslash **not** an escape) | key present, redacted | agree |
| `K=ab#cd` | **`ab`** — `#` starts a comment anywhere in an unquoted value | key present, redacted | silent truncation (see §4) |
| `K="ab#cd"` | `ab#cd` (quotes protect `#`) | key present, redacted | agree |
| `K=a` ×3 (duplicate keys) | last wins | **listed 3×** | inventory count inflated |
| `1K=v` (digit-leading key) | `v` | **key absent** | inventory false negative |
| `  K=v` (indented line) | `v` | **key absent** | inventory false negative |
| `K=op://V/I/F` | resolved as a reference | echoed verbatim, **with any trailing text** | agree when unexpanded; leak class of round 10 |
| `K="op://V/I/F"` | **resolved as a reference** (one-off: `[ERROR] "…" isn't a vault in this account`, exit 1, ~2 s) | `K=<redacted-non-op-value>` — reported as a **non-ref** | **inventory false negative on a live reference** |
| `K=pre-op://V/I/F` | not a reference (value does not begin with the scheme) | redacted | agree |

The five symmetric-difference keys over the probe fixture are `KAGI12_B`
(`B = v`), `KAGI12_D` (`export D=v`), `kagi12_lower` (`lower=v`), `1KAGI12X`
(digit-leading key) and `KAGI12_L` (indented line): `op run` injects 12 keys,
`refs` lists 7, `divergent=5`.

**The operational reading.** An inventory taken through `refs` is a statement
about *some* assignment lines. It is not a statement about what the file loads.
The two false-negative directions that matter for hygiene:

1. **Keys that load but are invisible** (`export`, spaces, lowercase) — an
   audit that counts `refs` output undercounts what `cmd_run` will inject.
2. **A quoted reference that loads but is reported as a plain value** — the
   worst case, because the audit concludes "this key is not a credential" while
   `op run` resolves it. The `awk` tests `v ~ /^op:\/\//`, and a leading `"`
   defeats it; the dotenv parser strips the quotes first and resolves.

## 2b. Hard failures — files the resolver refuses and the inventory clears

The most severe divergence is not a missing key, it is a **whole-file abort
that `refs` cannot see**. `op`'s dotenv parser is strict; `cmd_refs`'s `awk`
matches `^[A-Z][A-Z0-9_]*=` and ignores everything else, so a file the resolver
rejects still yields a clean inventory:

| Line in the file | `op run --env-file=… -- true` | `refs` | Consequence |
|---|---|---|---|
| `K-NAME=v` (`-` in key) | `[ERROR] <ts> parsing Dotenv file: error at line 2 column 7: expected '=' but found '-'`, exit 1, **zero keys injected** | exit 0, lists the *valid* keys | audit says healthy, load delivers nothing |
| `KEY` (no `=`) | `[ERROR] <ts> parsing Dotenv file: error at line 1 column 5: missing '='`, exit 1 | as above | same |
| `=v` (empty key) | `[ERROR] <ts> parsing Dotenv file: error at line 1 column 1: key must be at least 1 character long`, exit 1 | as above | same |
| UTF-8 BOM before the first key | `[ERROR] <ts> parsing Dotenv file: error at line 1 column 1: expected '=' but found '<BOM>'`, exit 1 | as above | same |
| `--env-file=<a directory>` | `[ERROR] <ts> read <path>: is a directory`, exit 1 | n/a | note the verb changes (`read`, not `open`) |

Practical reading: "the parser is strict" cuts both ways. A stray byte in
`op.env` — an editor's BOM, a bare key from a botched edit, a `-` that should
have been `_` — makes **every** `the-janitor run -- <cmd>` fail with a
`parsing Dotenv file` error while `refs` (and any audit built on it) reports a
healthy inventory. Loadability is a separate question from inventory, and only
the resolver answers it.

## 3. The masking contract (measured, and narrower than it reads)

`op run --help` (2.35.0): *"Secrets printed to stdout or stderr are concealed by
default. Include the '--no-masking' flag to turn off masking."* The measured
scope of "secrets" is **reference-resolved values only**:

| Probe | Observed |
|---|---|
| `op run --env-file=plain.env -- printenv KAGI12_A` (`KAGI12_A=alpha-value`) | `alpha-value` — **not masked** |
| `op run --env-file=plain.env -- sh -c 'echo "[$KAGI12_A]"'` | `[alpha-value]` — not masked |
| the same value inside a longer line | not masked |
| `KAGI12_A=alpha-value op run -- printenv KAGI12_A` (shell env, no env file) | not masked |
| the same with `--no-masking` | identical output — the flag has **no effect on plain values** |
| `op://`-resolved value | masked by default (help text; **not measured** — see §Bounds) |

**Evidence grading for that table** (the distiller lane's split): the gate
mechanises exactly two of these rows — `printenv` on a plain key, and the
default-vs-`--no-masking` equality check. The subshell-`echo`, substring and
shell-env-only shapes are **one-off** measurements: made once by the author, and
independently re-measured by lane `R12ExecMask` on its own fixtures (identical
results, plus a stderr shape and a full-`printenv` multiset comparison). They are
not re-run by the gate, so §Bounds.10 applies to them — and the raw full-`env`
dump is **line-order nondeterministic** between runs (sorted output is stable),
which matters if anyone mechanises that shape later.

Consequence for this domain: `cmd_run` is `exec op run …` with no
`--no-masking`, so **plain-valued keys flow out of `the-janitor run` verbatim**.
The observed `op.env` holds 10 keys, 8 of which are `op://` refs and 2 raw
identifier values (`knowledge/janitor-env-contract.md` §Leak-surface notes) —
i.e. the raw keys are unmasked by design, and any *future* plain secret added to
that file is unmasked too. "The handler masks what it prints" is false; "1Password
masks what it resolves" is the true statement, and it covers only refs.

The mask token itself is not recorded here: producing one requires resolving a
reference, which this repo does not do. See §Bounds.

## 4. dotenv semantics `refs` cannot see (each one a silent-change class)

- **`#` truncates unquoted values.** `K=ab#cd` → `ab`. A generated plain secret
  containing `#` is silently truncated *without any error*, and `refs` cannot
  show the difference (both sides print a redaction).
- **Quotes are stripped** by the resolver (`"quoted value"` → `quoted value`) and
  preserved in the `awk`'s view of the same line — no error, different value.
- **Variable expansion** happens in values: `$K`, `${K}`; resolution order is
  the file (in line order) then the process environment; an unset variable
  expands to the empty string with exit 0. `refs` echoes the unexpanded text for
  ref-shaped values — `op://$ENV/I/F` is inventoried as a literal that the
  resolver will not treat as a literal.
- **Duplicate keys**: last wins for `op run`, every line listed by `refs`.
- **CRLF and surrounding whitespace are tolerated**: `K=v\r\n` → `v`,
  `K=  v  ` → `v` (unquoted). `K= v` → `v`.
- **Multiple `--env-file` flags MERGE (union); per key, the last file wins.**
  Measured: with `two1.env` (`P8=first`, `P9=onlyfirst`) then `two2.env`
  (`P8=second`), the child saw `P8=second` **and** `P9=onlyfirst` — so the help
  text's "the last environment file takes precedence" is a per-key rule, not a
  "only the last file is read" rule. Precedence over the ambient shell
  environment is also documented and measured: **env files beat shell
  variables** — the opposite of the usual dotenv default, and worth knowing
  before "fixing" a value in the shell when the file still carries the old one.
- **`op run` rewrites the inherited environment too.** A key passed only by the
  parent is injected with its value **trimmed**: `K='  spaced  ' op run --
  printenv K` → `spaced`. Interior `#`, `$`, `\`, `=` survive, so this is a
  trim, not a re-parse — but it means the child does not see the parent's value
  verbatim, and `op` also forces `GOTRACEBACK=none` into the child.
- **Quoting decides expansion, not just comment handling.** `"…"` expands
  (`$K`, `${K}`, and `${K:-default}` when the variable is unset); `'…'` strips
  the quotes but **suppresses expansion** (`S='$K'` → the literal `$K`). The
  inventory redacts all three identically.

## 5. Named error signatures (what a script sees)

| Command | Output (last line matters) | Exit |
|---|---|---|
| `op run --env-file=<missing> -- cmd` | `[ERROR] <ts> open <path>: no such file or directory` | 1 |
| `op run --env-file=<file>` (no command) | `[ERROR] <ts> expected at least 1 arguments but got 0 instead` + usage | 1 |
| `op run` over a ref whose vault does not exist (one-off) | `[ERROR] <ts> "<vault>" isn't a vault in this account. Specify the vault with its ID or name.` | 1, ~2 s |
| `op run --env-file=<file with a malformed line>` | `[ERROR] <ts> parsing Dotenv file: error at line N column M: …` (`expected '=' but found '-'`, `missing '='`, `key must be at least 1 character long`) | 1, zero keys injected |
| `THE_JANITOR_ENV=<missing> the-janitor refs` | `the-janitor: missing <path>` | 2 |
| `THE_JANITOR_ENV=<file> the-janitor run` (no command) | `the-janitor run: missing command` | 2 |

The wrapper's guards fire **before** `op` is reached, so a scripted path sees
exit 2 for both argument errors and never the `op` texts. The 1-vs-2 split is
the useful signal: 2 = wrapper refused, 1 = `op` refused.

## 6. The other ref-consuming verbs, and why the handler uses none of them

`op` 2.35.0 exposes three ways to consume a reference: `run` (env vars to a
child), `inject` (`-i`/`-o`, template → resolved file; `--file-mode` default
0600, confirmation prompt unless `-f`), and `read` (`-o` file or stdout, `-n`
no-newline, `--file-mode` 0600). `the-janitor` uses **only** `op run`; `inject`
and `read` are the paths an operator reaches for by hand, and each writes a
resolved artifact to disk (`inject`'s help says to delete it afterwards).
`op service-account` in this version has `create` and `ratelimit` (no `token`
subcommand); the handler's `OP_SERVICE_ACCOUNT_TOKEN` contract
(`knowledge/janitor-env-contract.md`) is unaffected by that.

## 7. Decision table — auditing an env file

| Question | Do this | Why not the obvious thing |
|---|---|---|
| What will `the-janitor run` actually inject? | `op run --env-file=<file> -- printenv <KEY>` per key (or `env` in a subshell), on a file **you know is plain** | `refs` misses `export`/spaced/lowercase keys and misreports quoted refs |
| Which keys are credentials? | `refs` for a first pass, then re-check every key whose value is quoted or `$`-bearing by inspection | `refs`' test is a prefix match on the raw line (round 10) |
| Is it safe to paste the output? | No, unless every key is a ref: plain values are **not** masked | "op masks secrets" is true only for resolved refs |
| Did a plain value silently change shape? | Compare before/after through `op run … printenv`, not through the file text | `#`, quotes and whitespace are rewritten by the parser |
| Will the file load at all? | `op run --env-file=<plain file> -- true` and read the exit code | `refs` exits 0 on a file the parser rejects (BOM, bare key, `-` in a key); for the real `op.env` this is **not testable without the vault** — see §8.4 |
| Which value wins? | File beats shell; last `--env-file` beats earlier | matches neither `bash` nor many dotenv libraries |

## 8. Bounds (named, not implied)

1. **Masking of ref-resolved values is not measured** — measuring it needs a
   resolved reference, and a resolved reference needs the vault. The claim "refs
   are masked by default" is the help text's, not a probe result.
2. **The mask token's shape is unknown** (identical problem). A gate that
   asserted it would have to resolve a reference.
3. **Masking applies to stdout/stderr.** Whether a value written by the child to
   a *file* is masked is not measured (and `op`'s help scopes the feature to the
   two streams).
4. **`op inject` / `op read` semantics are from `--help`, not executed** — both
   would resolve a reference; `op read --out-file`/`--file-mode` defaults are
   help-text claims.
5. **`--no-masking` interaction with a ref is untested** (needs a ref).
6. **This entry pins one `op` version's behaviour** (`2.35.0`). The probe turns
   that into a verdict: if `op` stops injecting `export`/spaced/lowercase keys,
   stops truncating `#`, or starts masking plain values, `op-ref-probe.sh` fails
   (exit 1) and the contract must be re-measured rather than assumed.
7. **Loadability of the real `op.env` is not testable here.** The resolver
   refuses or resolves; both need the file's actual contents in the op binary,
   and `op.env` carries refs. The probe measures *plain* fixtures, and the
   hard-failure class (§2b) is therefore proven on fixtures, not on the live
   file. The compensating check is structural: `refs` cannot detect it, so a
   live-file load is only proven by a real `run` under operator auth.
8. **Host-state dependence**: the probe needs `op` on `PATH` (override
   `OP_REF_OP_BIN`) and the handler at `$HOME/.local/bin/the-janitor` (override
   `OP_REF_JANITOR_BIN`); otherwise it fails `SETUP` exit 2 rather than reporting
   a clean result.
9. **A `$`-escape in a double-quoted value can decode a newline.** Lane
   `R12Sentinel` observed that `K="a\nb"` yields a real newline in the child;
   single quotes and octal/hex/unicode `\`-forms stay literal. Not folded into
   the edge contract (it is a shell-adjacent corner, and the gate's fixtures
   would need a binary-safe comparison).
10. **One-off rows are not re-run by the gate**: the quoted-reference
   resolution and the nonexistent-vault error text were measured once, by hand,
   with a bounded `timeout 6`, and independently by no lane (lane `R12Planner`
   flagged exactly this and is right: the resolver half of §2 is an
   author-measured one-off, not a non-author verification). They are marked `--`
   above so a reader can tell them from the mechanised rows — they are simply
   weaker evidence, and the entry says so rather than implying parity.
11. **The gate's self-checks have three measured blind spots** (round-12
   mutation lane, which deleted or rewrote each check on a scratch copy and
   re-ran `--selftest`): (a) deleting the *refs-inventory*, *masking flag-effect*
   or *signature text-fragment* check does not fail the selftest, because other
   checks catch the seeded cases for them — they are redundancy, not dead code,
   but a future editor should not read a green selftest as proof they work;
   (b) the masking pair is a **self-comparison**: an edit that reuses the default
   row as the `--no-masking` row yields equal values and is invisible to both the
   selftest and `verify` (no resolvable reference can make the flag observable on
   plain values, which is the point of the contract); (c) `--evaluate` compares
   whatever observation file it is handed, so a hand-forged file passes — it is a
   comparator, not a measurement. The compensating control for all three is the
   committed revision stamp plus review of the diff: `verify` recomputes the
   probe's hash, so a mutated gate in the repo is `STALE`, not silently green.
12. **The masking rows pin "plain values are unmasked", not "the flag was
   passed".** Stated again here because it is the one row a reader is most
   likely to over-read (mutation lane m10).

13. **`op` surfaces this entry names but does not bound individually** (all
   help-text-only, each needing a resolved reference or an account): `op read`'s
   query parameters (`?attribute=otp`, `?ssh-format=openssh`), global `--cache`
   semantics (what is cached, TTL, whether a cached read avoids vault contact —
   2.35.0 documents `--force` only as "Do not prompt for confirmation"), `op
   plugin run`/credential provisioning, and `--encoding SHIFT_JIS|gbk` output
   effects. Lane `R12ScoutHelp` enumerated 14 such items; the ones not listed
   here are already covered by §Bounds.1-5 or by `knowledge/op-cli-surface.md`.

## 9. Reproduction

```
bash corpus/op-ref-probe.sh              # OP_REF_PROBE: CLEAN (checks=44 oprun=12 refs=7 divergent=5 edge=10 sig=6), exit 0
bash corpus/op-ref-probe.sh --selftest   # OP_REF_SELFTEST: PASS (29 cases), exit 0
bash corpus/op-ref-probe.sh --fixture DIR    # re-measure against your own env files (op-side files must be plain)
bash corpus/op-ref-probe.sh --evaluate OBS   # pure comparison of a collected observation file
```

Fixture tree (generated by `write_fixtures`, plain values only):
`oprun.env` (the 12-key divergence fixture: `=`-spacing, `export`, lowercase,
digit-leading, indented), `edge.env` (10 classes: `#`/quote/CRLF/duplicate/
`${:-}`/single-quote), `two1.env` + `two2.env` (per-key precedence **and**
union), `malformed.env` + `adir/` (the hard-failure class), `refsclass.env`
(ref-shaped values: verbatim vs redacted vs duplicate rows). `absent.env` is
deliberately never created — it is the missing-file signature probe.

## 10. Falsification

- `bash corpus/op-ref-probe.sh` → `CLEAN (checks=44 …)`, exit 0 (live).
- Append `KAGI12-BAD=v` to a fixture copy → `sig op-dotenv-badchar` must be exit
  1 with `parsing Dotenv file`, and the `malformedrefs` inventory must still
  list `KAGI12_GOOD` — the blindness is asserted, not inferred.
- Change any contract value (e.g. add `export ` to a fixture key) → the
  corresponding `FAIL` line and exit 1; `--selftest` proves the comparator on 21
  cases, including fifteen seeded mutations (value, masking, edge, quoting,
  precedence, union, inherited trim, signatures, refs classification, the
  malformed-blindness pair).
- `KAGI12_POISON=op://…` appended to `oprun.env` with `OP_REF_OP_BIN` pointed at
  a logger stub → `POLICY` exit 2 **and an empty stub log** (the refusal happens
  before exec; selftest case `policy-ref-token`).
- `grep -n 'op://' corpus/op-ref-probe.sh` → only the policy guard, the refs-side
  fixture, and prose — no fixture handed to `op run` can contain a token.
- `grep -n 'exec op run' ~/.local/bin/the-janitor` → L248, without
  `--no-masking` (the masking finding's premise).
- `THE_JANITOR_ENV=<missing> the-janitor refs` → `the-janitor: missing …`, exit 2
  (signature row `janitor-refs-missing`).

## 11. Byte fidelity of `op run --env-file` (round 21, op 2.41.0)

§4 compares *key sets*; it is line-oriented and cannot see a value's trailing
LFs. This section pins what `op run --env-file` hands the child process **byte
for byte**, because `the-janitor run -- <cmd>` (`cmd_run` L248) is exactly
that exec. Measured 2026-10-19 on op `2.41.0` (`op --version`), repeating the
round-20 op `2.40.0` result unchanged (`corpus/lessons/round-20.md` §Byte
frontier). Command: `bash corpus/op-ref-probe.sh --dotenv-bytes` → six
`DOTENV_BYTES_CASE id=<id> status=PASS` lines, then
`OP_DOTENV_BYTES: CLEAN (checks=6 failed=0)`, exit 0 (ledger `R21-01`).
Each fixture is one generated plain-value line for key `KAGI16_VALUE`
(`dotenv_bytes()` in `corpus/op-ref-probe.sh`); the child prints the value with
`printf %s`, and only its `od -tx1` hex leaves the scratch tree.

- `DOTENV_OBS-escaped-lf` — double-quoted value with a backslash-n escape
  between `alpha` and `beta` → `616c7068610a62657461` = `alpha` LF `beta`. The
  parser expands `\n` inside double quotes: a consumer receives a real newline,
  not the two characters.
- `DOTENV_OBS-trailing-lf` — double-quoted value ending in two backslash-n
  escapes → `616c7068610a0a` = `alpha` LF LF. Trailing newlines survive the
  parser and the exec; any loss happens later, in the consumer (see below).
- `DOTENV_OBS-newline-only` — double-quoted value that is a single backslash-n
  escape → `0a`. A newline-only value is delivered as one byte, not as empty
  and not as unset.
- `DOTENV_OBS-single-literal` — single-quoted value with a backslash-n between
  `alpha` and `beta` → `616c7068615c6e62657461` = `alpha` `\` `n` `beta`. Single
  quotes are literal: no escape processing, so the same text means different
  bytes depending on the quote character.
- `DOTENV_OBS-double-multiline` — double-quoted value spanning two physical
  lines → `616c7068610a62657461` = `alpha` LF `beta`. A literal LF inside
  double quotes is kept.
- `DOTENV_OBS-single-multiline` — single-quoted value spanning two physical
  lines → `616c7068610a62657461` = `alpha` LF `beta`. Same bytes as the
  double-quoted form: a physical LF is kept under either quote.

**The loss is downstream, measured.** `v=$(printf 'alpha\n\n'); printf %s "$v" | od -An -tx1`
→ ` 61 6c 70 68 61` on this host: shell command substitution strips every
trailing LF. A wrapper that captures a delivered value with `$(...)` (or a
`read` loop) therefore loses the bytes `op` delivered faithfully; a script
that needs them reads the variable directly or the file, never a substitution.

**Decision row.** Multi-line or trailing-newline values in an env file → write
them double-quoted with explicit escapes (the `escaped-lf`/`trailing-lf` bytes
above are what arrives), and never rely on single quotes to expand an escape.

**Does not establish.** No handler behaviour (the handler is absent from this
host; nothing ran through `the-janitor`), no masking of resolved values
(§3 stays the masking contract), no vault or account fact — every value is a
generated plain string under `env -i` with scratch HOME/XDG, so no reference
was resolved. Scoped to op 2.40.0 and 2.41.0. Round-21 reviewer limits on the
instrument itself: the seven `--selftest` byte cases prove the comparator
only (their "faithful" fixture is a hand copy of the contract array, not an
independent observation); an op-side failure — sign-in prompt or timeout inside `op run`, or
a missing binary (`SETUP` exit 2 (preflight `command -v`, probe
code at `op-ref-probe.sh:525-526`), while a sign-in or timeout failure inside
`op run` surfaces as `DRIFT` exit 1 through `evaluate_bytes`; either way a red
`R21-01` is not by itself evidence of a byte change; and failing rows print no observed
hex. Those are named debt for the probe, not facts about `op`.

**Falsifier.** Any `DOTENV_BYTES_CASE … status=FAIL` with op exiting 0 on a
new op release falsifies the corresponding bullet for that release.
`recheck: on-release of op` — rerun `R21-01` after every op upgrade.

**Correction note.** §9's comment `OP_REF_SELFTEST: PASS (29 cases)` is
superseded: the selftest now proves 36 cases (ledger `R12-02`, re-pinned this
round after the byte arm added seven); §9 is left as written.

## Erratum (round 22 — comparator history)

The §10 “21 cases” comparator sentence is an intermediate historical count,
not the current selftest contract. The existing §11 correction to “36”
also supersedes that §10 count, not just §9. Run the current selftest and
compare its executed output to R12-02; reading the expected regex is not a
measurement. The surface-census pointer in this entry is not evidence for
dotenv semantics. Handler-derived observations retain their original
version/date and unavailable-substrate limits; the account-free byte arm
does not reverify the missing handler or reference-resolved masking.
Audit: `kagi-shokunin/.ufo/waves/round-22/build/Entry18.md`.