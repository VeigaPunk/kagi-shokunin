# Counter 2 as frozen cannot reach 0 — measured counterexample

Plan round-30 C2, counting command 2:

    grep -rIl $'\r' --exclude-dir=.git --exclude-dir=.jj . | wc -l     (run at lane root)
    prints `0` — before: 3 files.

Measured at BASE `f67232c`:

| tree | literal command | + `--exclude-dir=.ufo` |
|---|---|---|
| working tree, HEAD `b7482b4` | **167** | 3 |
| `git archive BASE` extract (no .git/.jj) | **135** | 3 |
| tracked at BASE (`git grep -Il $'\r'`) | **135** | 3 |
| after stripping the 3 drifted files | **132** | **0** |

So "before: 3 files" is the count only for the `.ufo`-excluded form. The literal
frozen command reads 132 after the repair, not 0, because 132 tracked `.ufo`
files legitimately contain CR bytes:

- 127 are HTTP wire captures (`*.headers`, `*.hdr`, `*.txt`, `*.body`, `*.html`).
  The CR is the captured byte: e.g. `.ufo/waves/round-26/build/ClockS005.headers.txt`
  starts `HTTP/2 200 \r\n date: …` — an HTTP/1.1-style CRLF header block recorded
  as evidence. Normalizing these to LF would destroy the evidence property the
  files exist to carry.
- 5 are round-29 receipt JSONs under `.ufo/waves/round-29/final/`
  (c1-after, c1-before, c2-after, c2-base-gate, c2-base-plain), CRLF on every
  line (433/433, 101/101). These are Windows-host artifacts too, but they are
  committed evidence from a prior round, not lane production files; changing
  them would rewrite another round's receipt outside this claim's scope.

Also: the working tree (167) exceeds the tracked set (135) by 32 untracked CR
files — 31 under `.ufo/waves/round-28/retained-probes/SrcNodeSemver/node_modules/`
(gitignored by `.ufo/waves/round-28/.gitignore`) plus wave-dir receipts. A gate
counted over the raw working tree is therefore also unstable across checkouts.

## Consequence for C2

- C2's own after-state still holds: census exit 0, checklist exit 0 — both
  measured above, and both depend only on the 3 drifted files.
- The standing row R30-01 must scope to the authored surface
  (`--exclude-dir=.ufo`), where the value is exactly 3 before and 0 after.
  That is the form drafted in `c2-18-eol-gate-draft.sh`.
- If C2 insists on the literal `0`, the only way to reach it is normalizing
  evidence captures — which harms the evidence axis. Recommend the scoped row
  and stating the 132 explicitly, rather than silently broadening the repair.
