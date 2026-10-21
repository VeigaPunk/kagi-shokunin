# FRecapS014-9 — round-24 falsify — C2/S014 recapture attack (freshness)

Lane frozen revision: `c5ef9e92201b6c36396301f12b23740565bf86a0` (BASE `4f94b52a…`). Sandbox
`/fast/scratch/kagi-r24-recovery/KagiR24-2.FRecapS014-9/lane` cloned `--no-hardlinks`, frozen rev
checked out there; all execution `env -i HOME=<empty sandbox home> PATH=/usr/bin:/bin`. Production
untouched; only this report written. No tool installs/upgrades needed; pacman untouched.

## Attacked claims (committed round-24)
- `corpus/source-fetches.tsv:67` S014: 2026-10-21 capture, raw `449ef132…d1785d9`/63046 B,
  normalized (rendered-text-v1) `ca496ad8…52a403`, quote "The jwt auth method … or by providing a JWT".
- `corpus/inrow-pins.tsv:20` S014: pin `e94723241fbc…cb0b1` classified **non-reproducing**.
- `corpus/SOURCES.md:20` in-row uppercase quote + stale `Fetch sha256:`; caveat/erratum
  `SOURCES.md:95-97,102-105` ("original Fetch hashes remain historical point observations with
  undocumented representation"; "S014's uppercased JWT quote is normalized text").
- `.ufo/waves/round-24/build/RecapS014.md` digest/locate/position claims.

## Re-open (declared profile, sandbox)
`env -i HOME=$S/home PATH=/usr/bin:/bin curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0
(documentation verification)' -D s014-headers.txt -w '%{url_effective} %{http_code}\n' -o
s014-body.html https://openbao.org/docs/auth/jwt/`
→ `https://openbao.org/docs/auth/jwt/ 200`, curl exit 0, no redirect; body 63046 B;
`sha256sum` → `449ef132ba380948398c03cd96b0a10f80572b734c381897e681b3609d1785d9` — **byte-identical
to the committed capture**; `last-modified: Tue, 20 Oct 2026 07:50:18 GMT` (same as recap);
etag `W/"6ad71d3a-f646"` — 0xf646 = 63046, size component consistent.

## Normalizer + locate (frozen-rev clone)
- `python3 corpus/rendered-text-v1.py --selftest` → `PASS (cases=20)`, rc=0.
- `… digest s014-body.html` → raw `449ef132…`, normalized `ca496ad8…`, normalized_bytes=15942,
  rc=0 — both match the committed row exactly (fresh as of 2026-10-21 09:12:56 GMT fetch).
- locate uppercase in-row quote → `count=0` rc=1: not a case-literal live excerpt, exactly as the
  recorded erratum states (page renders `jwt` in code style, lowercase).
- locate lowercase short variant → `count=1` rc=0; full S025 sentence → `count=1` rc=0.
- Normalized positions: `JWT/OIDC auth method` at [0, 619] (title copy 0, H1 619); sentence at 640;
  context before H1: `…iew Version: Version 2.7.x On this page ` — every RecapS014.md position
  claim reproduces exactly.

## Classification interpretation (raw vs normalized vs non-reproducing)
- Pin `e947…` matches neither documented representation of today's body → **non-reproducing is
  honest**. Page `last-modified` (2026-10-20 07:50:18 GMT) postdates the pin's 2026-10-19 opening,
  so the pinned body predates the current one: later page drift is NOT proof the original capture
  was false, and no documented representation can reproduce it today. Historical capture
  reproducibility: **unverifiable**; metadata consistency of the committed rows: **verified**.
- No undocumented representation is called current: the fetch row declares
  `decoded-http-body-volatile-v1` (raw) + `rendered-text-v1` (normalized); col 3 row-identity
  digest reproduces: `printf 'S014\tmined\thttps://openbao.org/docs/auth/jwt/\n' | sha256sum` →
  `885fbb66f18d963f1ba24bad0dc96b2e97013c7e1ef2ddad345bb7ab348b3295` — exact.
- Probe: same URL without `--compressed` (no Accept-Encoding) returned identical bytes `449ef132…`
  — no alternate representation emerges; nothing relabels the pin as reproducing.

## Verdict
- Operability: PASS. Freshness: PASS (today's capture reproduces committed raw, normalized,
  byte size, and row-identity digest; headers consistent).
- Calibration: PASS (pin honestly classified non-reproducing; uppercase-quote erratum recorded;
  S025 supersedes S014's quote/locator and reproduces count=1 today).
- Falsifier: none found. Severity: none. Residual unknown: the pre-2026-10-20 body the pin hashed
  is not recoverable from the registered URL alone (no archive fetch in scope); C2 does not require it.
