# R54 SentinelScope — security & scope sentinel, round 54 C1

Lane: /home/vgpnk/Projects/shokunin/kagi-shokunin (branch master)
BASE 1a0f43a9220bb0e995462c2aef745ac0124c3317 → CANDIDATE ede4373afa07a33e24cbd35e9fd33fc2fddf2f14 (HEAD of lane worktree)
Diff: 42 files, +35457/−64. 24 files under `.ufo/waves/round-54/` at candidate.
Scratch: `/fast/scratch/hyaku/kagi-r54/R54SentinelScope/` (HYAKU_SCRATCH=/fast/scratch/hyaku).
No `op` subcommand was run by this seat, and no real secret, key file, 1Password account, vault or vault field was read. No `git` mutation was run (read-only git only). All findings below are from local bytes and read-only git.

## (1) Secret/token/private-key/cookie/`op://`-shaped strings — **PASS**

Method: candidate blobs for all 42 changed files plus all 24 `.ufo/waves/round-54/**` blobs extracted with `git cat-file blob <rev>:<path>` into scratch; scanned with `grep -rE` over the extraction, and separately over the diff's added lines. The live (untracked) round-54 dir was scanned too.

| pattern | occurrences | verdict |
|---|---|---|
| `AKIA[0-9A-Z]{16}` (AWS key id) | 0 | clean |
| `-----BEGIN … PRIVATE KEY-----` / `BEGIN OPENSSH PRIVATE KEY` | 0 | clean |
| `AGE-SECRET-KEY-1…` | 0 | clean |
| `(hvs|hvb|hvr).<20+>` (Vault/OpenBao token) | 0 | clean |
| `gh[pousr]_…` / `github_pat_…` | 0 | clean |
| `xox[abposr]-…` (Slack) | 0 | clean |
| `sk-…` / `sk-ant-…` (OpenAI/Anthropic) | 0 | clean |
| JWT `eyJ….eyJ….` | 0 | clean |
| `Cookie:` / `Set-Cookie` / `Authorization:` (captures + added lines) | 0 | clean |
| `1PASSWORD_*TOKEN` | 0 | clean |
| password/token/secret/key assignment with ≥16-char value | 4 | all the same line, a fake sentinel fixture |

- The only `password…=<16+ chars>` hit is `corpus/release-clock.py:1607`
  `"feed_url": "https://feed.example.test/releases.atom?token=TEST-SENTINEL-ONLY"` — a selftest-only dummy on `feed.example.test`, not a credential. The 4 count is that one line in the changed blob, the fixture overlay copy, and their live copies.
- `Bearer` hits 2, both pre-existing prose in LOG.md:95 / SKILL.md:59 ("Basic-only — Bearer rejected", "Bearer/wrong-user/wrong-pw 401"); neither is on an added line and neither carries a value.
- `op://` occurrences: 52 across all scanned roots (40 in candidate-committed bytes; the other 12 are the orchestrator's untracked dispatch/spec files that quote this assignment). All are placeholder prose, never a resolvable reference. Distinct token forms: `op://V/I/F` (9), `op://…` (10), `op://$ENV/I/F` (3), bare `op://` (15), `op://'` (3, quoted prose). Zero occurrences carry a real account/vault/item name. Distribution: `corpus/knowledge/op-ref-consumption.md` 8 (plus the controls fixture copy, 8), `SKILL.md` 14 (all pre-existing; the 4 added SKILL.md lines contain no `op://`). Added diff lines containing `op://`: 8, all documentation table/example text from the entry (§Boundary/round-10 leak-class text).
- Live untracked `.ufo/waves/round-54/build-dispatch.json` / `build-spec.json` contain the literal string `op://` only because the orchestrator's seat assignment text quotes "`op://`-shaped strings"; not a reference path.
- High-entropy pass over added lines (`[A-Za-z0-9+/]{40,}` minus lowercase-hex): 9 distinct strings, all public path/URL fragments or commit ids (e.g. `3FEF9748469ADBE15DA7CA80AC2D62742012EA22` = 1Password's public op signing-key fingerprint; `.../shokunin/75dd2612…` = commit ids). 331 distinct 64-hex strings = sha256 digests (public), no key material.

## (2) op receipt and capture bodies carry public release metadata only — **PASS**

`/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-54/final/op-dotenv-bytes-2.42.0.txt` (987 B, 18 lines) contains only: `measured_at`, the public archive URL `https://cache.agilebits.com/dist/1P/op2/pkg/v2.42.0/op_linux_amd64_v2.42.0.zip`, `zip_sha256`, `op_sha256`, `op_version=2.42.0`, `gpg_validsig=3FEF9748469ADBE15DA7CA80AC2D62742012EA22` (public signing-key id), `installed_op=/usr/bin/op 2.41.1`, `probe_sha256=0f1945…` (matches `corpus/op-ref-probe.sh`, verified by `sha256sum`), the command template with `<verified 2.42.0 binary>` redacted, six `DOTENV_BYTES_CASE … status=PASS`, `OP_DOTENV_BYTES: CLEAN (checks=6 failed=0)`, `exit=0`. No path to a local credential store, no token, no reference path, no account identifier.

Captures:
- `.ufo/waves/round-54/capture/S112.body` — 45,175 B RSS 2.0 XML of the public page; `sha256sum` = `2dce505aedfb66f207701c4d96cb1c337f025cb6305817885c6c7f74665405e2`, exactly the prescribed digest and the digest in the S072 receipt record.
- `.ufo/waves/round-54/capture/rejections/*.body` — public product-history HTML and public releases HTML; each sha256 equals its `.meta` sha256 (`bb1791…`, `0cfbd2…`), so the receipt links the committed bytes.
- Sensitive-marker counts in the three bodies: `Set-Cookie` 0, `Cookie:` 0, `csrf` 0, JWT 0, `op://` 0, `AKIA` 0. Word hits are public prose: "password" 204/509/362 are the product name "1Password"; "private key(s)" are release-note text about SSH key formats ("The output of SSH private keys now use platform-appropriate line break…"); `--api-key` / `LOCALSTACK_API_KEY` are documented CLI flags/parameter names, not values.
- `.meta` files carry `url= http= type= bytes= final= sha256= fetched_at=` plus `parse(...) refused: XML DTD and entity declarations are not allowed` — no request headers, cookies or credentials.
- LOW (calibration, not exposure): in both rejection `.meta` files the recorded `bytes=` (74,323 and 20,250) is not the stored body length (528,203 and 96,166), while `sha256` does match the stored body. Likely the received Content-Length before transfer decoding; the field is unlabelled, so a reader cannot tell. No integrity impact.

Receipt `observe-r54.json`: 32 unique observations, key set exactly `clock, http_status, id, located, observed_at, parsed_version, sha256, url, verdict`; no value longer than 300 chars; S072 = feed / 200 / parsed 2.42.0 / verdict fired / sha256 2dce505… / url the OPFEED — public metadata only.

## (3) No committed op binary, no file > 1 MiB entered — **PASS**

- `git ls-tree -r -l ede4373… -- .ufo/waves/round-54`: 24 files, largest 528,203 B (`capture/rejections/app-updates…body`); none > 1,048,576 B.
- All 42 changed files sized at candidate via `git cat-file -s`: max 528,203 B; next 244,183 (SCORECARD.md), 178,067 (LOG.md).
- No ELF (`\x7fELF`) or ZIP (`PK\x03\x04`) magic in any extracted changed/round-54 blob; `git ls-tree -r` name filter for `op`, `op_linux*`, `.zip|.tar.gz|.deb|.pkg` tracked files → none; `find` in the worktree for `op`/`op_linux*`/`*.zip` → none.
- No secret-shaped filenames (`.pem/.key/.p12/.env/id_rsa/…`) anywhere in the lane tree at candidate.
- Informational: the lane does contain pre-existing > 1 MiB blobs in `.ufo/waves/round-26/**` and `round-27/**` (up to 7,373,074 B). They are untouched by this diff and predate BASE; nothing > 1 MiB entered in round 54.

## (4) Probe still refuses a reference token before exec on the 2.42.0 path — **PASS**

`corpus/op-ref-probe.sh` is byte-identical to BASE (`git diff --quiet BASE CANDIDATE -- corpus/op-ref-probe.sh` → rc 0; sha256 `0f1945e8…4f4c`, the receipt's `probe_sha256`). Guard read at lines 227–266:

- `guard_op_file()` refuses, with `POLICY`/exit 2 **before exec**, any op-side path that is a symlink or not a plain regular file (line 232), and any existing file whose bytes match `op://` (line 235–238): `OP_REF_PROBE: POLICY (env-file carries a reference token, refused before exec: …)`.
- `op_exec()` (line 248) is the single chokepoint: it walks its argv, and for every `--env-file=…` argument calls `guard_op_file` before the process starts (line 252–255). The only exec sites are line 262 (`env -i … "$OP_BIN" "$@"`) and 264 (`"$OP_BIN" "$@"`); no `--env-file <space>` call form exists in the file, so there is no unguarded argv shape.
- `--dotenv-bytes` (the 2.42.0 leg) constructs its own fixtures under `mktemp -d`, refuses `--fixture` outright (`OP_DOTENV_BYTES: POLICY (byte mode accepts generated fixtures or --evaluate only)`, main loop line ~767), and runs op only under `env -i PATH=… HOME=$WORK/home XDG_*=… OP_BIOMETRIC_UNLOCK_ENABLED=false OP_CACHE=false timeout 10`, so even a drift cannot reach a real account (no config, no cache, no TTY prompt).
- `--fixture DIR` in non-byte modes is guarded wholesale by `guard_op_side()` before any mode runs; refusal is in the main shell so `exit 2` is real.
- Residual (informational, not exploitable): the token guard matches the literal lowercase scheme `op://`; `OP://` or a percent-encoded spelling would pass the grep, but op's documented scheme is lowercase and the probe never consumes `--fixture` in byte mode. `guard_op_file` returns 0 for a non-existent path by design (the `absent.env` premise), which is separately asserted by the caller.

## (5) Counter/controls honour HYAKU_SCRATCH/TMPDIR, remove scratch, no hardcoded /tmp — **PASS**

- `plans/round-54-c1.sh`:62 `SCR=${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r54/c1.$$`; :64 `trap 'rm -rf -- "$SCR"' EXIT`; :85/:90 gate and selftest run with `TMPDIR="$SCR"`. `grep -n '/tmp' plans/round-54-c1.sh plans/round-54-controls.sh` → rc 1, no output (no hardcoded `/tmp`).
- `plans/round-54-controls.sh`:14 `SCR="${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r54"`, :16 `W=$(mktemp -d "$SCR/controls.XXXXXX")`, :17 `trap 'rm -rf -- "$W"' EXIT`, :18 `export TMPDIR="$W"`.
- Live verification with `HYAKU_SCRATCH=/fast/scratch/hyaku/kagi-r54/R54SentinelScope/scr` (own scratch):
  - `bash plans/round-54-c1.sh 1a0f43a9…` → `C1_OP_CLOCK: value=0 watched=0 measured=0 guard=1 (bad=watched:s072-recheck=180d measured:oprcpt-missing-or-symlink; …)`, rc 0, 0.89 s; leftover scratch: none.
  - `bash plans/round-54-c1.sh ede4373a…` → `C1_OP_CLOCK: value=2 watched=1 measured=1 guard=1 (bad=watched:OK measured:OK; gate-line=RELEASE_CLOCK: CLEAN (on_release=32 bound=32 unbound=0 observed=32 fired=14 derived=17))`, rc 0; leftover scratch: none.
  - `HYAKU_SCRATCH=/fast/scratch/hyaku/kagi-r54/R54SentinelScope/scr2 bash plans/round-54-controls.sh` → `CONTROLS: match=16 mismatch=0`, rc 0, 101.39 s, every line `CONTROL K1-… expect=… got=… MATCH` (K1-0 0, K1-P 2, K1-F1..F14 as predeclared); leftover scratch: none. This independently reproduces the pre-freeze control summary.
- LOW: in the counter, `mkdir -p -- "$SCR/t" "$SCR/b" || setup scratch` runs before the EXIT trap is installed, so a partial mkdir failure can leave a half-created `$SCR` behind. No guard against a hostile `HYAKU_SCRATCH` value (e.g. `/`), but that is an operator-controlled variable and the counter never reads it from the repo. Both scripts also avoid a persistent `HOME` override (the probe sets `HOME` per `env -i` invocation only).

## (6) Nothing in the round writes outside the lane — **PASS**

- Fleet root `git -C /home/vgpnk/Projects/shokunin status --porcelain` → 4 entries (`.scratch/goal-20261103-hyaku-run15.md`, `.scratch/run15-state.json`, `?? .scratch/run15-wrapup/misroot-cff0b4cb/`, `?? trail-ids.txt`); `grep -iE 'round-54|kagi'` → NONE. The lane is excluded from that repo by `.gitignore:1:*-shokunin/`.
- Lane `git status --porcelain` → 8 entries, all inside `.ufo/waves/round-54/` (orchestrator dispatch/ready files, `build/`, `final/c1-candidate-rev.txt`, `final/kill-rules.txt`); no tracked file modified, no write outside the lane.
- External read, no write: the round's LOG line 35103 documents a read-only `grep … /home/vgpnk/Projects/shokuknow/merge/kagi`. `find /home/vgpnk/Projects/shokuknow/merge/kagi -newermt '2026-11-07 00:00' -type f` → empty (no file touched today), so the read did not mutate that tree.
- Write targets in the round's own code: counter and controls write only under `HYAKU_SCRATCH`; the probe writes only under `mktemp -d`; `corpus/release-clock.py` writes only when `--observe FILE` is passed (default/`--receipt` are read-only) and its selftest uses `tempfile.TemporaryDirectory`; the measurement receipt itself lives at the in-lane pinned path `.ufo/waves/round-54/final/op-dotenv-bytes-2.42.0.txt`.

## Severity summary

No finding above LOW. The two LOW notes are calibration, not exposure: (a) rejection-capture `.meta` `bytes=` disagrees with the stored decoded body length while `sha256` agrees; (b) the counter can leak a partially created scratch dir if `mkdir -p` fails between creation and trap installation.

NONE of the checks (1)–(6) failed. No secret, token, cookie, private key, vault field, or resolvable `op://` reference appears in the round's bytes; the op binary is absent from the lane; the probe's pre-exec refusal is intact and byte-identical to BASE; both drivers honour `HYAKU_SCRATCH`/`TMPDIR` and leave no scratch; and no write escaped the lane.

Independent checks run by this seat (all read-only toward the lane): candidate/base blob extraction + pattern scan, `ls-tree` size/name audit, probe guard read, and two counter runs plus one full controls run under this seat's own `HYAKU_SCRATCH`.
