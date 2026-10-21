# FQuoteIntegrity — quote drift, one mutation probe
Revision: `82745e2c60e726b49499b8f309529935dc4eff2b` (isolated clone HEAD observed).
Axes: calibration (what exit/summary proves), operability (offline/observe), freshness (negative receipt vs stale TSV).
Mutant: fixture/body.html:1 replaces `the exact` with `the changed`; source/capture quote and `quote-located` TSV stay unchanged.
Expected detector: a missing quote is a fired clock (`release-clock.py:437-448`); receipt must say missing. No invented requirement that fired clocks exit nonzero.
Verdict: **SURVIVED** the candidate exit+fired-summary detector; **KILLED** by inspecting the saved receipt. Baseline/restoration both PASS, not inconclusive.
Concrete falsifier: fresh missing quote produces observe `failed=0 fired=0`, exit 0, while its saved receipt is errorless `quote-missing`; live fired summary omits this clock.
## Exact commands and fixture
`B=/fast/scratch/kagi-r25/FQuoteIntegrity-4`; commands used the expanded absolute paths below.
`mkdir -p /fast/scratch/kagi-r25/FQuoteIntegrity-4/home && env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/FQuoteIntegrity-4/home git clone -q --no-hardlinks /home/vgpnk/Projects/shokunin/kagi-shokunin /fast/scratch/kagi-r25/FQuoteIntegrity-4/lane && env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/FQuoteIntegrity-4/home git -C /fast/scratch/kagi-r25/FQuoteIntegrity-4/lane checkout -q 82745e2c60e726b49499b8f309529935dc4eff2b` → exit 0, stdout empty.
`env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/FQuoteIntegrity-4/home git -C /fast/scratch/kagi-r25/FQuoteIntegrity-4/lane rev-parse HEAD` → exit 0, stdout revision above.
Fixture is the candidate's synthetic S001 example (`corpus/release-clock.py:739-742,753-757,805-807`): sole on-release doc, quote `the exact example.`, profile `rendered-text-v1`, clock `rendered-quote`, all four feed/version fields `-`, date `2026-10-21`, verdict `quote-located`.
Pristine/restored body bytes: `<p>the exact <em>example.</em></p>\n`; mutant: `<p>the changed <em>example.</em></p>\n`. Only that one body word changed (edit tool); then exact original bytes restored.
Same subprocess argv for each STAGE in order `pristine`, `mutated`, `restored` (cwd `$B/lane`, timeout 25s):
`/usr/bin/env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/FQuoteIntegrity-4/home PYTHONDONTWRITEBYTECODE=1 python3 -B -c "$CODE" STAGE`
Complete CODE, including exact imported-module argv and no-network transport replacement:
```python
import hashlib, importlib.util, json, sys
from pathlib import Path
B = Path('/fast/scratch/kagi-r25/FQuoteIntegrity-4'); L = B/'lane'; F = B/'fixture'
p = L/'corpus/release-clock.py'; s = importlib.util.spec_from_file_location('clock', p)
m = importlib.util.module_from_spec(s); s.loader.exec_module(m)
n = m.load_normalizer(L); m.load_normalizer = lambda root: n
m.request_body = lambda url, **kw: (200, (F/'body.html').read_bytes(), None)
paths = [p, L/'corpus/rendered-text-v1.py', F/'body.html', F/'corpus/SOURCES.md', F/'corpus/release-clocks.tsv', F/'corpus/source-fetches.tsv']
sha = lambda path: hashlib.sha256(path.read_bytes()).hexdigest()
before = {str(path.relative_to(B)): sha(path) for path in paths}
print('STAGE', sys.argv[1], 'SHA256', json.dumps(before, sort_keys=True))
argvs = [['--root', str(F)], ['--root', str(F), '--observe', str(B/(sys.argv[1]+'.json'))], ['--root', str(F)]]
exits = []
for argv in argvs:
    print('main argv=' + json.dumps(argv)); rc = m.main(argv); exits.append(rc); print('main exit=' + str(rc))
r = json.loads((B/(sys.argv[1]+'.json')).read_text())['observations'][0]
print('RECEIPT', json.dumps(r, sort_keys=True))
print('receipt_oracle=' + ('PASS' if r['located'] is True and r['verdict'] == 'quote-located' and 'error' not in r else 'FAIL'))
print('input_bytes_unchanged=' + str(before == {str(path.relative_to(B)): sha(path) for path in paths}))
print('candidate_detector_exit=' + str(max(exits)))
sys.exit(max(exits))
```
## Actual output / exits
All three runs: process exit 0; every printed `main exit=0`; `candidate_detector_exit=0`; stderr empty; `input_bytes_unchanged=True`.
All nine offline-result lines (including inside observe), exact:
`RELEASE_CLOCK: CLEAN (on_release=1 bound=1 unbound=0 observed=1 fired=0 derived=0)`
Mutated observe summary, exact:
`RELEASE_CLOCK_OBSERVE: wrote 1 observations (failed=0 fired=0) to /fast/scratch/kagi-r25/FQuoteIntegrity-4/mutated.json`
Pristine/restored observe summaries had the same counts and their respective `pristine.json` / `restored.json` paths.
| Stage | Receipt located / verdict / error | observed_at | Receipt oracle |
|---|---|---|---|
| pristine | true / quote-located / absent | 2026-10-21T12:02:30Z | PASS |
| mutated | false / quote-missing / absent | 2026-10-21T12:02:36Z | FAIL |
| restored | true / quote-located / absent | 2026-10-21T12:02:42Z | PASS |
Each receipt: id S001, clock rendered-quote, url https://example.test/doc, http_status 200, parsed_version null; sha256 equals that stage's body hash below.
## Restoration and bounds
Body SHA-256 pristine = restored: `a75576e85464d94587a2f623af9eeb90c70b312abf94e09a259bef24eeedd620`; mutated: `48a48024cbee62a56d7dfa60f5458af72a51c664aefeeefe221586ee81c57087`.
All stages, TSV SHA-256: `c9b423cc7d4a70ac877fb42e1d82b7512329282447022e5c940d9f3bb7f7793e`; capture TSV: `8bc0032224bae258017ea2bc6f92db498a590e078c422173956611a7aad55cb0`; SOURCES: `9bc34c27340f44fcbeb6b5a36e99b32d7401ab094a83ed33c62d24163915f8d7`.
All stages, imported release-clock.py SHA-256: `a3c5c5b92152ed87bb4713e4c66821e0d3f82193f8da19b809b7eeb569f76671`; normalizer: `7d6bfe8154898f8584e213bcf98936a0819ace75fd80f3dcc87bce1edd1dc7bf`.
PASS: per-receipt drift detection (`corpus/release-clock.py:617-630`); FAIL: live fired summary excludes quote-missing (`:702-707`), although offline evaluation counts it (`:448`).
Observed: in this probe the fresh negative receipt did not update/bind the stale TSV: the immediate post-observe offline run still reports observed=1 fired=0; main parses only sources/bindings/captures (`:1204-1222`). This is not proof that automatic TSV updating was promised.
Calibration limit: failed=0 means no retrieval/parser error, not every quote located; exit 0 alone is not a contract violation because fired feed clocks also succeed. The concrete inconsistency is fired=0 plus a missing-quote receipt.
UNRUN: public network, actual vendor quotes, capture-quote/metadata mutation, receipt replay across rows, C1/C2 gates, full verify/cells, host/account/vault/handler/CDP/op. No production repair or non-report lane writes; no tools installed/updated.
