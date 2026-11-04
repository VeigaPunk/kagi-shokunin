# corpus/SOURCES.md S072 `scope` cell — R32-3 correction (old → new, as landed)

File: `corpus/SOURCES.md`, row `S072` (1Password CLI Release Notes), column 5 (`scope`). Every other cell of the row is byte-identical.

## OLD (at frozen BASE `76f4eea`, before this round's edit)

```
op CLI 2.41.1 release identity (the build the installed binary reports)
```

## NEW (landed in the round-33 working tree; the exact current text)

```
op CLI 2.41.1 release identity (the version token `op --version` prints; the article's build number `#2410101` is not printed by the binary)
```

## Basis and state

- R32-3 (`corpus/lessons/round-32-verifier-spotcheck.md` §6): "the build the installed binary reports" over-claims — the installed binary reports only the version token.
- Measured this round: `op --version` → `2.41.1` (binary `/usr/bin/op`, 2026-11-04). No `op signin`, `op account`, `op item`, `op read`, `op inject` or `op run` was issued.
- The build number stays where it belongs: the release-notes heading `2.41.1 (build #2410101 ) – released 2026-10-21` and its article id `v2410101` (anchor cell unchanged).
- The edit is already applied by the lane's landing at the time of this draft (10:36), so this file is the old→new record for `corpus/lessons/round-33.md` §Migrations, not a pending patch. The landed wording satisfies R32-3; this seat's independently drafted alternative ("build #2410101 is the release-notes article's build number, not a value the binary reports") is withdrawn in favour of the landed text.

## Checks

1. `awk -F'|' '$2 ~ /^ *S072 *$/ {print $6}' corpus/SOURCES.md` contains `op --version` and no longer contains `the build the installed binary reports`.
2. The `anchor`, `teaches`, `status`, `opened`, `recheck` and `used-by` cells are unchanged, so the capture row and the census handshake do not move.
3. The old→new is logged in `corpus/lessons/round-33.md` §Migrations (R32-3's routing requirement).
