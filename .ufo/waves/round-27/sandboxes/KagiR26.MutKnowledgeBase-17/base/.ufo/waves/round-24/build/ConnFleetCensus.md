# Round 24 fleet-census overlap

## Finding

The current command exits **0**, with seven W04 warnings and a `kagi ok` line. The planned `source-fetches.tsv` captures and `inrow-pins.tsv` do not enter the fleet validator's input surface. The new S027+ rows in `corpus/SOURCES.md` do. **They preserve exit 0 only if each is a well-formed Registry row and every mined row's used-by path exists when validation runs.** The frozen plan/proposals specify candidate sources, not final S027+ cells or used-by paths, so an unconditional after-state pass cannot be certified yet.

## Evidence and affected checks

- Fleet roster construction points each lane at `corpus/SOURCES.md` (`/home/vgpnk/Projects/shokunin/scripts/sources-census.sh:466-468`); validation passes that selected file to `row_pass` and `usedby_findings` (`:717-722`). It does not read `corpus/source-fetches.tsv` or `corpus/inrow-pins.tsv`. Thus adding the 16 capture records or the new classification file alone cannot create fleet W04, E01, or E11 findings.
- Round-24 C2 plans one S001–S016 capture per legacy pin and the in-row classifications, then new Python `re`/`html` rows and an explicit rejected ASCII-whitespace alternative (`plans/round-24.md:37-50`). Candidate URLs are Python `re.html` (`.ufo/waves/round-24/build-dispatch.json:924-926`), Python `html.html` (`.ufo/waves/round-24/build/SrcPyHtml.md:5-7`), and WHATWG Infra ASCII whitespace (`build-dispatch.json:934-936`). The current `SOURCES.md` ends at S026 (rows `:22-32`); no final S027+ rows are present to inspect.
- **W04:** source URLs are extracted and normalized by `url_of` (`scripts/sources-census.sh:600-604`); repeated URL across scopes prints W04 (`:644-645`), regardless of row status because each URL is recorded (`:651-653`). The candidate Python and WHATWG URLs are distinct from each other and the current registered URLs, so they imply no *new* W04 if those are the URLs used. Existing S019–S023, S025, and S026 already yield seven W04s (including S021/S026 at `corpus/SOURCES.md:27,32`). A rejected status does not suppress W04. W04 alone does not set failure: only E findings set `findings=1` (`:739-745`), and final exit is 0 absent errors (`:803-806`).
- **Row shape:** every new row must be inside `## Registry` and have exactly 11 cells (`NF=13` including the outer pipes); otherwise E01 is emitted (`scripts/sources-census.sh:635-637`) and E findings cause exit 1 (`:739-740,805`). The proposed rows are not yet materialized, so their actual field count cannot be confirmed. Avoid literal `|` inside cells and retain the standard 11-cell table shape.
- **Used-by existence:** fleet only checks `mined` rows (`scripts/sources-census.sh:558-560`) and emits E11 when the referenced path does not exist (`:565-570`); this check is run in validate mode (`:721-722`). The rejected row with `used-by` `—` is exempt. The round-24 lesson file is absent from the current `corpus/lessons/` listing; if the mined Python rows name `corpus/lessons/round-24.md`, they will trigger E11 until that file is created. The plan does not specify the final used-by cells, so this is a concrete integration-order risk, not a confirmed future finding.
- **Separate lane-gate obligation:** Kagi's gate reads and validates `source-fetches.tsv` (`corpus/sources-census.sh:236-287`) and reads `inrow-pins.tsv` (`:289-315`). It requires a capture for every registry row; only S001–S016 get the historical in-row exemption, and even those require captures (`:316-328`). Therefore new S027+ rows also need lane-gate provenance rows; fleet validation does not check this. A fleet-clean result does not prove SC_FETCH clean.

## Bounded proposal and verification

Integrate each mined S027+ row together with its existing/created used-by file, and keep the rejected row's reason and `flip:` text intact; then run fleet validation after the whole registry/lesson change is present. Ensure each new table row remains 11 cells. This ordering avoids a transient E11 without changing the provenance model or weakening either gate. It improves **operability** (no avoidable validation failure) and preserves **freshness** (captures/classifications remain owned by SC_FETCH); it does not change the **calibration** population.

Observed verification (read-only):

```text
scripts/sources-census.sh validate --root /home/vgpnk/Projects/shokunin kagi
EXIT=0
```

Output contained the seven W04 warnings for S019–S023, S025, S026 and `kagi ok`. No post-addition validation was run because the S027+ rows and their final used-by paths are not present in the current registry.