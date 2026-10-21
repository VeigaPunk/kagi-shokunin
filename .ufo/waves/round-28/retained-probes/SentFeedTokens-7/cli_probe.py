import importlib.util
import sys
from pathlib import Path

SANDBOX = Path('/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-28/sandboxes/SentFeedTokens-7')
case = sys.argv[1]
root = SANDBOX / ('cli-' + case)
corpus = root / 'corpus'
corpus.mkdir(parents=True)
spec = importlib.util.spec_from_file_location('release_clock', SANDBOX / 'base/corpus/release-clock.py')
rc = importlib.util.module_from_spec(spec)
spec.loader.exec_module(rc)

(corpus / 'SOURCES.md').write_text(
    '| id | source | kind | tier | scope | anchor | teaches | status | opened | recheck | used-by |\n'
    '|---|---|---|---|---|---|---|---|---|---|---|\n'
    '| S001 | https://example.test/doc | docs | A | test | Python 3.15.1 | test | mined | 2026-10-21 | on-release | — |\n'
    '| S002 | https://feed.example.test/releases.atom | docs | A | test | Latest release | test | mined | 2026-10-21 | 90d | — |\n', encoding='utf-8')
(corpus / 'release-clocks.tsv').write_text(
    '\t'.join(rc.HEADER) + '\n'
    'S001\tfeed\tS002\thttps://feed.example.test/releases.atom\t3.15.1\t3.15.1\t2026-10-21\tnot-fired\ttest\n',
    encoding='utf-8')

bodies = {
    'leading-zero': b'<feed><entry><title>Python 3.15.01</title></entry></feed>',
    'oversized-version': b'<feed><entry><title>Python 3.15.' + b'1' * 4301 + b'</title></entry></feed>',
    'unknown-encoding': b'<?xml version="1.0" encoding="x-no-such-encoding"?><feed><entry><title>v3.15.2</title></entry></feed>',
}
rc.request_body = lambda url, **kwargs: (200, bodies[case], None)
output = root / 'observations.json'
raise SystemExit(rc.main(['--root', str(root), '--observe', str(output)]))
