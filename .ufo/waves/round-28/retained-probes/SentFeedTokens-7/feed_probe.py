import importlib.util
import json
import resource
import socket
import sys
import time
from pathlib import Path

BASE = Path('/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-28/sandboxes/SentFeedTokens-7/base')
spec = importlib.util.spec_from_file_location('release_clock', BASE / 'corpus/release-clock.py')
rc = importlib.util.module_from_spec(spec)
spec.loader.exec_module(rc)

class Response:
    def __init__(self, body):
        self.body = body
        self.read_limit = None
    def getcode(self):
        return 200
    def read(self, limit):
        self.read_limit = limit
        return self.body[:limit]
    def __enter__(self):
        return self
    def __exit__(self, *args):
        return False

class Opener:
    def __init__(self, response):
        self.response = response
        self.timeout = None
    def open(self, request, timeout):
        self.timeout = timeout
        return self.response

class BlockingResponse(Response):
    def read(self, limit):
        self.read_limit = limit
        while True:
            time.sleep(60)

class BlockingOpener(Opener):
    def __init__(self):
        self.response = BlockingResponse(b'')
        self.timeout = None


def resolver(host, port, type):
    return [(socket.AF_INET, socket.SOCK_STREAM, 6, '', ('93.184.216.34', port))]


def xml(body):
    return b'<feed><entry><title>' + body + b'</title></entry></feed>'


def observation(body, anchor='3.15.1'):
    opener = Opener(Response(body))
    receipt = rc.observe_one(
        {'url': 'https://example.test/doc', 'teaches': 'test'},
        {'id': 'S001', 'clock': 'feed', 'feed_url': 'https://feed.example.test/releases.atom',
         'anchored_version': anchor, 'observed_version': anchor},
        None, opener=opener, resolver=resolver,
    )
    return receipt, opener

if '--hang' in sys.argv:
    rc.request_body('https://feed.example.test/releases.atom', opener=BlockingOpener(), resolver=resolver)
    raise SystemExit('unexpectedly returned')

results = []
def record(name, fn):
    start = time.monotonic()
    try:
        value = fn()
        results.append({'case': name, 'result': value, 'elapsed_seconds': round(time.monotonic() - start, 3)})
    except BaseException as exc:
        results.append({'case': name, 'raised': type(exc).__name__, 'message': str(exc)[:180],
                        'elapsed_seconds': round(time.monotonic() - start, 3)})

record('noncanonical-leading-zero-observation', lambda: observation(xml(b'Python 3.15.01'))[0])
huge_version = xml(b'Python 3.15.' + b'1' * 4301)
record('oversized-component-direct-parser', lambda: rc.parse_latest_version(huge_version))
record('oversized-component-observation', lambda: observation(huge_version)[0])
record('unknown-xml-encoding-direct-parser', lambda: rc.parse_latest_version(
    b'<?xml version="1.0" encoding="x-no-such-encoding"?><feed><entry><title>v3.15.2</title></entry></feed>'))
record('unknown-xml-encoding-observation', lambda: observation(
    b'<?xml version="1.0" encoding="x-no-such-encoding"?><feed><entry><title>v3.15.2</title></entry></feed>')[0])
record('invalid-plain-utf8-observation', lambda: observation(b'\xff')[0])
record('entity-declaration', lambda: rc.parse_latest_version(
    b'<!DOCTYPE feed [<!ENTITY x "v3.15.2">]><feed><entry><title>&x;</title></entry></feed>'))
record('numeric-character-reference-control', lambda: rc.parse_latest_version(
    b'<feed><entry><title>&#118;3.15.2</title></entry></feed>'))
record('too-many-feed-entries', lambda: rc.parse_latest_version(
    b'<rss><channel>' + b'<item><title>v3.15.2</title></item>' * 5001 + b'</channel></rss>'))
record('too-many-xml-elements', lambda: rc.parse_latest_version(
    b'<feed><entry><title>v3.15.2</title></entry>' + b'<x/>' * 100000 + b'</feed>'))
record('deep-xml-50000', lambda: rc.parse_latest_version(
    b'<feed>' + b'<x>' * 50000 + b'<entry><title>v3.15.2</title></entry>' + b'</x>' * 50000 + b'</feed>'))
large_title = b'A' * (rc.MAX_BODY_BYTES - len(b'<feed><entry><title></title></entry></feed>'))
giant = b'<feed><entry><title>' + large_title + b'</title></entry></feed>'
record('giant-title-at-body-limit', lambda: {'size': len(giant), 'result': rc.parse_latest_version(giant)})

exact_response = Response(b'Version: 1.2.3\n' + b' ' * (rc.MAX_BODY_BYTES - len(b'Version: 1.2.3\n')))
record('response-exact-limit', lambda: (lambda out: {'status': out[0], 'len': len(out[1] or b''), 'error': out[2],
                                                       'read_arg': exact_response.read_limit})(
    rc.request_body('https://feed.example.test/releases.atom', opener=Opener(exact_response), resolver=resolver)))
over_response = Response(b'x' * (rc.MAX_BODY_BYTES + 1))
record('response-one-byte-over-limit', lambda: (lambda out: {'status': out[0], 'body_is_none': out[1] is None,
                                                              'error': out[2], 'read_arg': over_response.read_limit})(
    rc.request_body('https://feed.example.test/releases.atom', opener=Opener(over_response), resolver=resolver)))

print(json.dumps({'python': sys.version, 'int_max_str_digits': sys.get_int_max_str_digits(),
                  'limits': {'body': rc.MAX_BODY_BYTES, 'xml_elements': rc.MAX_XML_ELEMENTS,
                             'feed_entries': rc.MAX_FEED_ENTRIES},
                  'maxrss_kib': resource.getrusage(resource.RUSAGE_SELF).ru_maxrss,
                  'results': results}, ensure_ascii=False, indent=2))
