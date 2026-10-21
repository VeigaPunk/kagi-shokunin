# ClockS011 — round26 C1 freshness re-verification (leaf seat KagiR26.ClockS011)

Observed BASE: `1bf3eec48d3761580ffd375c88143232485ae814` (`git rev-parse HEAD`; worktree clean except untracked `.ufo/waves/round-26/` and `plans/round-26.md`).
Access: 2026-10-21T13:36:34Z (UTC). Lane-authored advice, not non-author closure. No production, registry, or historical receipt file written.

## Result: S011 clock not fired, teaching unchanged — no drift finding

| Check | Registry (BASE) | Observed this round | Disposition |
|---|---|---|---|
| Page digest (decoded HTTP body) | `d0ab8b201f1a6d5f5751e1f261f904822492c530bdcdc5a4db9a8e178c2e180c` (SOURCES.md row S011; inrow-pins.tsv S011; source-fetches.tsv S011) | `d0ab8b201f1a6d5f5751e1f261f904822492c530bdcdc5a4db9a8e178c2e180c`, 33153 bytes | byte-identical |
| Docs footer | last modified 2026-05-15, commit `9b7b84e…` | "Last modified May 15, 2026: Add page descriptions. (9b7b84e)" | unchanged |
| Declared clock (release-clocks.tsv S011: `feed`, S033, anchored 3.13.3) | observed 3.13.3, `not-fired` | first feed entry `v3.13.3`, updated 2026-07-23T05:29:11Z, link `/releases/tag/v3.13.3`; no entry newer than it (prerelease or stable) | not fired |

S027/S028 Python 3.15.1 instructions do not apply to this row. S011 is SOPS documentation, and its clock is the SOPS release feed (S033), not a Python feed.

## Source teaching, located (each quote ≤25 words, from the rendered text of the fetched body)

- §`rotate` command (registry quote): "Use updatekeys if you want to add a key without rotating the data key." It is located. The registry's backticks are rendered as code in HTML, so the text matches only after tags are stripped, consistent with round24 `reproduces-raw | rendered`.
- §`rotate` command: "The rotate command generates a new data encryption key and reencrypt all values with the new key."
- §Rotating secrets after a key in a key group has been compromised: "Only after this is done, should you start rotating the actual passwords, API keys and other secrets…" and "the compromised key could still have access to those."
- Footnote on that section: "doing it the other way is only a problem in two specific situations: the secret.sops.yaml file is checked in between the two sops calls".
- §Direct Editing: "owners of the removed key may have add access to the data key in the past." The "(sic)" in the knowledge file still holds.
- The page's table of contents still lists all four cited sections: Adding and removing keys, updatekeys command, rotate command, Rotating secrets after a key in a key group has been compromised.

Bound: these located quotes re-verify only the teachings cited in SOURCES.md S011 and `knowledge/sops-age-key-rotation.md` (the recipient/data-key/values separation and the compromise order). They do not certify the rest of the page, such as the per-provider flags or the Key Rotation subsection examples. They also say nothing about SOPS binary behaviour.

## HTTP metadata

- Page: `curl -fsSL --compressed https://getsops.io/docs/usage/key-management/` returned 200 with no redirect. Headers: `content-type: text/html; charset=UTF-8`, `etag: "ac822f490132c93fcee7b7efd1b2a8ef-ssl-df"`, `age: 133451`, `date: Wed, 21 Oct 2026 13:36:34 GMT`.
- Feed: `curl -fsSL --compressed https://github.com/getsops/sops/releases.atom` returned 200, 253037 bytes, sha256 `47a224ad71435b7f5cae863bc96c01468bfed482636045fc307430983b072ff6`. Headers: `etag: W/"47a224ad71435b7f5cae863bc96c0146"`, `date: Wed, 21 Oct 2026 13:36:32 GMT`.
- First six feed entries: v3.13.3 (2026-07-23), v3.13.2 (2026-06-30), v3.13.1 (2026-05-16), v3.13.0 (2026-05-08), v3.12.2 (2026-03-18), v3.12.1 (2026-02-22).
- Supporting captures: `.ufo/waves/round-26/build/ClockS011-evidence/{page.html,page.headers,feed.atom,feed.headers}`.

## Limitations (docs/feed limits, not drift)

1. **CDN cache age.** `age: 133451` (about 37 h) means the page came from an edge cache. A docs change published within that window would not appear in this response. The clock is the release feed, though, and the footer commit matches the pin, so this does not change the verdict.
2. **Feed-only clock.** The S011 clock watches SOPS releases, but the page is docs-site content that can change without a release. The knowledge file's recheck also names a change to the footer commit as a trigger. That trigger was checked directly here: it is still `9b7b84e`, so it has not fired either.
3. **Feed window.** GitHub's Atom feed lists only recent releases. That is enough here, because the newest entry equals the anchor.
4. **Anchor derivation note.** The release-clocks.tsv S011 note is still accurate. The docs commit date (2026-05-15) falls between v3.13.0 (2026-05-08) and v3.13.1 (2026-05-16). Anchoring to the docs date would mislabel the clock as fired, while anchoring to the newest stable tag (v3.13.3) does not.

## Counterexamples sought, none found

- A newer SOPS tag (stable or prerelease) above v3.13.3: none in the feed.
- A changed body digest or footer commit: none, both are byte-identical.
- The compromise order reversed or softened: no, "Only after this is done" still precedes the credential rotation step.
- `updatekeys` now rotating the data key: no, the §rotate text still separates the two.

## Advice to L1 (integrator)

For the new round26 receipt: S011 `feed` / S033 / anchored 3.13.3 / observed 3.13.3 / 2026-10-21 / `not-fired`. The in-row pin reproduces raw. No superseding registry row is needed. Leave the round25 receipt and the lone-clone INCOMPLETE/48 untouched.

## Commands run (exact)

- `git rev-parse HEAD`
- `curl -fsSL --compressed -D page.headers -o page.html … https://getsops.io/docs/usage/key-management/`
- `curl -fsSL --compressed -D feed.headers -o feed.atom … https://github.com/getsops/sops/releases.atom`
- `sha256sum page.html feed.atom`
- Python stdlib tag-strip and `html.unescape` to locate the quotes, and a regex over feed `<entry>` elements for title, updated, and link.

No tools installed or updated. No build, lint, test, or formatter run.
