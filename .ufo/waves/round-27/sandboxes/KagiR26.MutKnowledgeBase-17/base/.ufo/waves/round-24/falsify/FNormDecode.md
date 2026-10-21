# FNormDecode — C2 strict UTF-8 falsification

**Revision:** `c5ef9e92201b6c36396301f12b23740565bf86a0` (frozen lane; checkout in `/fast/scratch/kagi-r24-recovery/FNormDecode-9`). **Observed bounds:** assigned normalizer and replay receipt; 2 synthetic byte fixtures; 20 selftest assertions; replay lists 10 rows. No production files changed; no tools installed.

## Outcomes

- **Strict UTF-8 decode / UTF-8 output — PASS, no finding.** In `corpus/rendered-text-v1.py`, `normalize_bytes` decodes with `errors="strict"`, then encodes UTF-8; `cmd_digest` converts `UnicodeDecodeError` to setup refusal. The bounded pair below observed both behaviors. **Falsifier:** valid UTF-8 normalizing to bytes other than the independently specified expected bytes/hash, or the invalid-byte input producing a digest / exit other than setup / 2.
- **Selftest — PASS.** `--selftest` reported all 20 assertions `ok`, ending `RENDERED_TEXT_V1_SELFTEST: PASS (cases=20)`; exit 0. This includes `strict-utf8` and `quote-collapse-only`.
- **Replay receipt — PASS as recorded; independent recapture not attempted.** `.ufo/waves/round-24/normalizer-replay.json` reports `matches: 10`; all 10 listed rows have `match: true`. Receipt records normalized-digest matches, not the original body bytes, so I did not independently recompute those ten digests.
- **Browser-equivalence promise — PASS within named files only.** No browser-equivalence promise appears in the normalizer, replay receipt, or `plans/round-24.md`. Literal search (`browser|equiv|DOM|WHATWG`) only found the normalizer's explicit rejected WHATWG ASCII-whitespace alternative; this is not semantic proof about other callers/docs. No LSP device was available in the mounted tools, so LSP status/references/definition/diagnostics were not run.

## Bounded command and observations

Created the sandbox with `git clone --no-hardlinks /home/vgpnk/Projects/shokunin/kagi-shokunin /fast/scratch/kagi-r24-recovery/FNormDecode-9 && git -C /fast/scratch/kagi-r24-recovery/FNormDecode-9 checkout --detach c5ef9e92201b6c36396301f12b23740565bf86a0`; checkout reported `HEAD is now at c5ef9e9`.

All commands ran in the sandbox with `HOME=/fast/scratch/kagi-r24-recovery/FNormDecode-9/home` and `PATH=/usr/bin:/bin` set by `env -i`. Fixture commands: `printf '<p>caf\303\251&nbsp;tea</p>' > /fast/scratch/kagi-r24-recovery/FNormDecode-9/valid.bin` and `printf 'a\377b' > /fast/scratch/kagi-r24-recovery/FNormDecode-9/invalid.bin`. Normalizer commands: `python3 corpus/rendered-text-v1.py digest /fast/scratch/kagi-r24-recovery/FNormDecode-9/valid.bin`, the same command with `invalid.bin`, and `python3 corpus/rendered-text-v1.py --selftest`.

Independent expectation for the valid normalized payload was literal UTF-8 bytes `636166c3a920746561` (`café tea`), 9 bytes; `printf 'caf\303\251 tea' | sha256sum` gave `11090cdb223e7c60e9e5b8dc79b790374747ab86e276e688ab82414ef94e8171`.

- Valid fixture stdout: `RENDERED_TEXT_V1: raw_sha256=d2849078d1aa5c0ab9be9e4583a130527c1b2e7102b030d444800ce638fa8bb1 bytes=21 normalized_sha256=11090cdb223e7c60e9e5b8dc79b790374747ab86e276e688ab82414ef94e8171 normalized_bytes=9`; exit 0. Independent expected digest matched.
- Invalid fixture stdout: `RENDERED_TEXT_V1: SETUP (not strict UTF-8)`; exit 2. No normalized digest was emitted.
- Selftest stdout: 20 `case ...: ok` lines; final `RENDERED_TEXT_V1_SELFTEST: PASS (cases=20)`; exit 0.

**Residual risk / gap:** this demonstrates one multibyte valid input (including HTML entity normalization) and one invalid byte (`0xff`), not every malformed UTF-8 sequence; the ten historical body captures were not independently available/re-hashed in this bounded run. No browser parser equivalence was tested or claimed by the scoped files.