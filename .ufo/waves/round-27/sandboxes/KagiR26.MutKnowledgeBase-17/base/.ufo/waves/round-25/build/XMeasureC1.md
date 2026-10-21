# XMeasureC1 — C1 measurement instrument

## Changed
- Added executable `.ufo/waves/round-25/tools/c1-measure.sh`.
- It resolves tool/docs commits from the script's repository, refuses missing `corpus/self-counts.py` or `.tsv` at tool revision with exit 2, creates a non-reused label directory under `/fast/scratch/kagi-r25/XMeasureC1/`, clones and checks out docs revision, overlays both files via `git show`, then runs the counter under `env -i PATH=/usr/bin:/bin HOME=<scratch>`.
- Prints one `C1_MEASURE` summary with parsed `stale`/`claims`, followed by captured tool output. `--mutate ID` runs once silently, increments the unique numeric capture for that table row in the scratch document, reruns, and requires tool exit 1; its process exit is 1 on the expected red result.

## Evidence / verification
- Frozen revision: `4587c61a348e4528717404a68912c373f3ef4d03` (plan base). `corpus/self-counts.py` and `.tsv` were absent in the lane tree when checked; no tool/docs revision pair was exercised.
- ShellCheck availability command: `if command -v shellcheck >/dev/null 2>&1; then shellcheck --version; else printf 'shellcheck unavailable\n'; fi` → exit 0; stdout: `ShellCheck - shell script analysis tool`, `version: 0.11.0`.
- `shellcheck .ufo/waves/round-25/tools/c1-measure.sh` → **UNRUN**; `c1-measure.sh` stub-tool sandbox run (baseline and `--mutate`) → **UNRUN**. The fleet editing-wave rule prohibits lint/tests during this wave; parent owns post-integration verification. No stub repo was created and no test output is claimed.
- No installs or updates.

## Pointers / risk
- `.ufo/waves/round-25/tools/c1-measure.sh:4-7` CLI; `:42-61` revision resolution and required-file refusal; `:64-79` fresh scratch clone setup; `:84-116` hermetic invocation and output; `:118-202` row mutation and exit-1 assertion.
- Mutation recognizes TSV headers `id`/`claim_id`, document `doc`/`document`/`path`/`doc_path`/`file`, and regex `regex`/`pattern`/`locator`/`line_regex`/`match_regex`. Since the producer table was absent and the required stub run is UNRUN, confirm its actual headers against these aliases during parent verification.
