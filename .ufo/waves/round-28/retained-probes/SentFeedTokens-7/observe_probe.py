import importlib.util
import json
from pathlib import Path

SANDBOX = Path('/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-28/sandboxes/SentFeedTokens-7')
BASE = SANDBOX / 'base'
spec = importlib.util.spec_from_file_location('release_clock', BASE / 'corpus/release-clock.py')
rc = importlib.util.module_from_spec(spec)
spec.loader.exec_module(rc)

sources = {'S001': {'id': 'S001', 'url': 'https://example.test/doc', 'kind': 'docs',
                    'anchor': 'Python 3.15.1', 'recheck': 'on-release'}}
fields = ['S001', 'feed', 'S002', 'https://feed.example.test/releases.atom', '3.15.1',
          '3.15.1', '2026-10-21', 'not-fired', 'test']
rows = [{'id': 'S001', 'fields': fields, 'line': 2, 'malformed': False}]

cases = {
    'leading-zero': b'<feed><entry><title>Python 3.15.01</title></entry></feed>',
    'oversized-version': b'<feed><entry><title>Python 3.15.' + b'1' * 4301 + b'</title></entry></feed>',
    'unknown-encoding': b'<?xml version="1.0" encoding="x-no-such-encoding"?><feed><entry><title>v3.15.2</title></entry></feed>',
}
for name, body in cases.items():
    output = SANDBOX / ('observe-' + name + '.json')
    rc.request_body = lambda url, **kwargs: (200, body, None)
    try:
        failures = rc.run_observe(SANDBOX, sources, rows, output)
        document = json.loads(output.read_text(encoding='utf-8'))
        print(json.dumps({'case': name, 'run_observe_failures': failures,
                          'receipt': document['observations'][0]}, ensure_ascii=False))
    except Exception as exc:
        print(json.dumps({'case': name, 'raised': type(exc).__name__, 'message': str(exc),
                          'receipt_written': output.exists()}, ensure_ascii=False))
