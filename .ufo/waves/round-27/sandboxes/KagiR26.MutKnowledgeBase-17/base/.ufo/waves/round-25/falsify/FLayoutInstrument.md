# FLayoutInstrument — C2 measurement review

Revision reviewed: `82745e2c60e726b49499b8f309529935dc4eff2b` (frozen candidate).
Axes: C2 operability only. C1 calibration and C3 freshness are outside this instrument's coverage.

## Findings by severity

### MAJOR — candidate measurement is blocked by sandbox prerequisites and fixed scratch root

Static review: `.ufo/waves/round-25/tools/c2-measure.sh:185-192` requires `MANIFEST.json` and `.ufo/{reports,waves,prompts}` beside its lane. Those were absent beside this seat's candidate clone. At `:194-200` it writes to the fixed `/fast/scratch/kagi-r25/XMeasureC2/<label>`, outside the allowed unique sandbox `/fast/scratch/kagi-r25/FLayoutInstrument-4`; that shared path already contains prior `XMeasureC2` runs. I refused to provision a mirror and then let the unmodified script write there. A parent mirror alone would not remove the scratch-path conflict.

Exact attempted argv: `env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/FLayoutInstrument-4/home bash /fast/scratch/kagi-r25/FLayoutInstrument-4/lane/.ufo/waves/round-25/tools/c2-measure.sh 82745e2c60e726b49499b8f309529935dc4eff2b FLayoutInstrument-preflight`

- Exit: **2** (safe preflight stopped before scratch creation or measurement).
- Stdout: `{"error":"required fleet source directory is missing: /fast/scratch/kagi-r25/FLayoutInstrument-4/.ufo/reports","phase":"argument validation"}`
- Full C2 measurement: **UNRUN**. Do not read the preflight exit as a candidate C2 result.

### MAJOR — prior synthetic-fleet baseline is an invalid control

The tool copies only `.ufo/reports`, `.ufo/waves`, `.ufo/prompts` into its synthetic fleet (`c2-measure.sh:227-233`); this omits referenced root evidence directories. Prior BASE evidence (`.ufo/waves/round-25/build/XMeasureC2.md:13-20,25`) records exit **1**, fleet `CITATION_GATE: BROKEN (... unresolved=6 ...)`, all six classed `ufo`, and `fleet_baseline_citations_clean=false`. This is a known incomplete-fixture result, not evidence against the candidate. Per assignment, classify the control as invalid unless repaired in a sandbox mirror; no such repair/run was made here.

### README mutation boundary

Static review (`c2-measure.sh:131-139,264-269`): the append/restore helper writes `lane_root/corpus/README.md`, and its callers pass the two newly cloned scratch roots; it does not target the source checkout README. **PASS (static only)** for the script's write target. The prior build record at `.ufo/waves/round-25/build/XMeasureC2.md:28` separately reports a scratch-debugging line transiently inserted into the live `corpus/README.md` and removed. That was a build deviation, not behavior of this helper; current `git status --porcelain -- corpus/README.md` was empty. It does not erase the historical transient write.

## Evidence, limits

- Sandbox checkout command: `S=/fast/scratch/kagi-r25/FLayoutInstrument-4 && mkdir -p "$S" && git clone -q --no-hardlinks /home/vgpnk/Projects/shokunin/kagi-shokunin "$S/lane" && git -C "$S/lane" checkout -q 82745e2c60e726b49499b8f309529935dc4eff2b && git -C "$S/lane" rev-parse HEAD && ls "$S/lane"`; exit **0**; stdout began `82745e2c60e726b49499b8f309529935dc4eff2b`.
- Prior BASE command (recorded, not rerun): `env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/XMeasureC2/driver-home bash /home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-25/tools/c2-measure.sh 4587c61a348e4528717404a68912c373f3ef4d03 base-4587c61a348e-XMeasureC2-2d`; exit **1**; stdout excerpt: `CITATION_GATE: BROKEN (cites=1371 docs=67 unresolved=6 ephemeral=0 labeled=13)` (source: prior build report above).
- LSP device unavailable: `read xd://lsp` returned “No such tool”; no LSP references/definition/diagnostics were available. Literal search was not treated as semantic proof.
- No packages installed. No candidate full measurement, `verify`, or `cells` run; no C1/C3 conclusion.
