# S005 live-page recapture

- Registry: `corpus/SOURCES.md:11`; registered URL: `https://1password.com/product/credential-broker`; historical in-row `Fetch sha256:` pin: `f7ba8254b1109111c42429eb896b9ba767a7320c20c5a9c5fc6f1d993bdffd2f`.
- Fetch command (profile as declared): `curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)' -o /fast/scratch/kagi-r24/seats/RecapS005-2/s005-body.html -w '%{url_effective} %{http_code}\n' 'https://1password.com/product/credential-broker'`.
- Fetch result: final URL `https://1password.com/product/credential-broker`; HTTP `200`; curl exit `0`. The curl-decoded body saved to `/fast/scratch/kagi-r24/seats/RecapS005-2/s005-body.html` is **196,082 bytes**.
- Digest command: `python3 /home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/rendered-text-v1.py digest /fast/scratch/kagi-r24/seats/RecapS005-2/s005-body.html` (exit `0`). Output: `raw_sha256=f1319513a95fd351ad89a493b98d9f7384d0d3e53583640fbb574a09bb3bace5`, `bytes=196082`, `normalized_sha256=f439a0eb0411a3d5191849b5b7f8d20d3fe4634656e7589d281378e0e8934c2a`, `normalized_bytes=5818`.
- Historical pin comparison: raw match **no**; normalized match **no**. The recorded pin matches neither current digest.
- Locate command: `python3 /home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/rendered-text-v1.py locate /fast/scratch/kagi-r24/seats/RecapS005-2/s005-body.html "Credential Broker checks the workload's identity against your policy, then delivers the exact credentials that specific job is approved for."` (exit `0`). Result: `count=1`.
- The first hit's nearest preceding heading in the normalized body is **“The platform identifies the job”** (H3). The exact located sentence is: **“Credential Broker checks the workload's identity against your policy, then delivers the exact credentials that specific job is approved for.”**
- Scope/teaches verdict: **yes** — that live sentence still supports the row's high-level claim that workload identity is checked against policy before job-approved credentials are delivered. It does not establish configuration mechanics, which the row explicitly excludes from scope.
- Tools installed/updated: none.
