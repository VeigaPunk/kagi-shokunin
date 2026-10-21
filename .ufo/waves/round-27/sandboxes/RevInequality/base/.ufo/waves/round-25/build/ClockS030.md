# ClockS030 — C3 per-row clock for SOURCES row S030 (WHATWG Infra Standard)

Seat KagiR25.ClockS030-2 · 2026-10-21 · BASE `4587c61a348e4528717404a68912c373f3ef4d03`
(sandbox lone clone at /fast/scratch/kagi-r25/ClockS030, HEAD verified at clone, lane untouched).

Row under test: `corpus/SOURCES.md:36` — S030, "Infra Standard — https://infra.spec.whatwg.org/",
spec, tier A, REJECTED, anchor "§4.6 Code points, #ascii-whitespace; Living Standard, Last Updated
19 October 2026, opened 2026-10-21", recheck=`on-release`, clock=`—`. Capture row
`corpus/source-fetches.tsv` S030: representation `decoded-http-body-volatile-v1`, sha256
`8d43350a0a36ebf7682cfe4146dcd7afb8d9f94da0d80677dcc0da16e43590d7`, 383472 bytes, normalized
`6acd7b558b4990c1e00e7fa4e512c5eefdb31ba5b1013105538b42716d4e8f39` under `rendered-text-v1`.

## 1. Which release identity governs this page

**Case (b) — unversioned live docs.** No official versioned release feed exists:

- `env -i PATH=/usr/bin:/bin HOME=$S/home curl -fsSL --compressed -A 'kagi-shokunin-round25/1.0 (documentation verification)' https://github.com/whatwg/infra/releases -o gh-releases.html` → exit 0, `HTTP=200`; the page contains exactly one match of "There aren’t any releases here". The spec's source repo publishes no versioned releases.
- `https://api.github.com/repos/whatwg/infra/releases/latest` → `HTTP=403` unauthenticated rate-limit body (BLOCKED, not absence evidence; the HTML page above is the evidence).
- The page declares its own identity, no version numbers anywhere (fresh body, verbatim):
  `Living Standard — Last Updated <time class="dt-updated" datetime="2026-10-19">19 October 2026</time>`

So the C3 clock for S030 is `rendered-quote`: the row's quote must still locate in a fresh fetch
under rendered-text-v1 (usage read from the script header; normalize = steps 5–6 for the quote).

## 2. Fresh observation, 2026-10-21 (all commands `env -i PATH=/usr/bin:/bin HOME=$S/home`)

1. `curl -fsSL --compressed -A 'kagi-shokunin-round25/1.0 (documentation verification)' -w 'HTTP=%{http_code} bytes=%{size_download} url=%{url_effective}\n' https://infra.spec.whatwg.org/ -o infra-fresh.html` → exit 0, `HTTP=200 bytes=64354 url=https://infra.spec.whatwg.org/` (64354 = compressed wire; file on disk = decoded body, `stat` 383472 bytes).
2. `sha256sum infra-fresh.html` → `8d43350a0a36ebf7682cfe4146dcd7afb8d9f94da0d80677dcc0da16e43590d7` — byte-identical to the S030 capture's representation sha AND byte count (same-day re-fetch, page unchanged).
3. `python3 corpus/rendered-text-v1.py digest infra-fresh.html` (from sandbox lane) → exit 0: `RENDERED_TEXT_V1: raw_sha256=8d43350a0a36ebf7682cfe4146dcd7afb8d9f94da0d80677dcc0da16e43590d7 bytes=383472 normalized_sha256=6acd7b558b4990c1e00e7fa4e512c5eefdb31ba5b1013105538b42716d4e8f39 normalized_bytes=84606` — normalized digest identical to the recorded `6acd7b55…`.
4. `python3 corpus/rendered-text-v1.py locate infra-fresh.html 'ASCII whitespace is U+0009 TAB, U+000A LF, U+000C FF, U+000D CR, or U+0020 SPACE.'` → exit 0, `RENDERED_TEXT_V1_LOCATE: count=1`.
5. `grep -o -m1 'id="ascii-whitespace"' infra-fresh.html` → present (`grep -c 'ascii-whitespace'` = 32); Last Updated marker as quoted in §1, `datetime="2026-10-19"` = anchored date.

## 3. Proposed corpus/release-clocks.tsv line

Columns: id, clock, feed_url, anchored_version, observed_version, observed_at, verdict.

```
S030	rendered-quote	—	Living Standard — Last Updated 19 October 2026 (datetime=2026-10-19)	Living Standard — Last Updated 19 October 2026 (datetime=2026-10-19)	2026-10-21	not-fired
```

Design note for L1: feed_url=`—` because a `rendered-quote` row has no feed; the re-fetch target is
the row's own registered URL. If `release-clock.py --observe` instead expects a non-empty URL in
that column, use `https://infra.spec.whatwg.org/` — the choice is flagged, not silently made.

## 4. Feed SOURCES candidate

None. whatwg/infra offers no release feed to cite (absence evidence in §1), so S030 binds to
`rendered-quote`, not `feed`; no SOURCES row proposed. The row's own page already carries a
datable identity marker (§1 quote) suitable as the anchor's version/date component.

## 5. Verdict on S030's teaches

**not-fired.** The quote locates in the fresh page (count=1, exit 0), the `#ascii-whitespace` dfn
id is present, the Last Updated identity (`datetime=2026-10-19`) equals the row's anchored
identity, and the decoded body is byte-identical (sha256 + size) to this morning's capture.
Teaches holds: S030 records that the Infra Standard's ASCII-whitespace definition was tested as
the rendered-text-v1 whitespace class and REJECTED (fails 3 of 10 recorded digests). That
definition text is unchanged verbatim on the live page, so both the candidate the row names and
the rejection's premise still stand; nothing in the source moved since capture.

## Tooling

No installs (pacman paused; none needed): system `curl`, `python3`, `git` only. Lane read-only;
no git/jj mutation; all fetches used the contracted UA string.
