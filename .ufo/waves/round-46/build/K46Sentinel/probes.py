import importlib.util, sys, os, tempfile, pathlib, socket, http.client, json, urllib.parse
sys.dont_write_bytecode = True
LANE = "/home/vgpnk/Projects/shokunin/kagi-shokunin"
spec = importlib.util.spec_from_file_location("rc_probe", LANE + "/corpus/release-clock.py")
m = importlib.util.module_from_spec(spec); spec.loader.exec_module(m)
SCR = "/fast/scratch/hyaku/kagi-r46/K46Sentinel"
resolver = lambda host, port, type=socket.SOCK_STREAM: [(socket.AF_INET, type, socket.IPPROTO_TCP, "", ("93.184.216.34", port))]
row = {"id": "S001", "clock": "feed", "feed_url": "https://example.test/releases.atom",
       "anchored_version": "1.2.3", "observed_version": "1.2.3", "observed_at": "2026-11-06",
       "verdict": "not-fired"}
src = {"id": "S001", "url": "https://example.test/doc"}

print("P0 default receipt/pin")
print("  receipt_path(root,None) =", m.receipt_path(pathlib.Path("/R"), None))
print("  DEFAULT_RECEIPT_SHA256  =", m.DEFAULT_RECEIPT_SHA256)

print("P1 fetch-layer exception handling in observe_one")
class Opener:
    def __init__(self, exc): self.exc = exc
    def open(self, req, timeout=None): raise self.exc
for label, exc in (("BadStatusLine", http.client.BadStatusLine("bogus")),
                   ("IncompleteRead", http.client.IncompleteRead(b"x"*10, 100)),
                   ("RemoteDisconnected", http.client.RemoteDisconnected("closed")),
                   ("ConnectionResetError", ConnectionResetError("reset"))):
    try:
        r = m.observe_one(src, row, None, opener=Opener(exc), resolver=resolver)
        print("  %-20s handled -> error=%r" % (label, r.get("error")))
    except BaseException as e:
        print("  %-20s UNCAUGHT -> %s.%s" % (label, type(e).__module__, type(e).__name__))

print("P2 XML DTD/entity")
bomb = b'<?xml version="1.0"?><!DOCTYPE feed [<!ENTITY e0 "lol"><!ENTITY e1 "&e0;&e0;&e0;&e0;&e0;&e0;&e0;&e0;&e0;&e0;">]><feed><entry><title>v1.2.3 &e1;</title></entry></feed>'
xxe = b'<?xml version="1.0"?><!DOCTYPE feed [<!ENTITY x SYSTEM "file:///etc/hostname">]><feed><entry><title>v1.2.3 &x;</title></entry></feed>'
for label, payload in (("internal-entity", bomb), ("external-entity", xxe)):
    try:
        print("  %-16s ACCEPTED -> %r" % (label, m.parse_latest_version(payload)))
    except ValueError as e:
        print("  %-16s refused -> %s" % (label, e))

print("P3 write_receipt")
d = pathlib.Path(tempfile.mkdtemp(prefix="probe-", dir=SCR))
target = d/"real.json"; target.write_text("{}")
link = d/"link.json"; os.symlink(str(target), str(link))
for label, p in (("existing", target), ("symlink", link), ("fresh", d/"new.json"),
                 ("missing-parent", d/"no-such-dir"/"observe-r46.json")):
    try:
        m.write_receipt(p, []); print("  %-15s WROTE" % label)
    except m.SetupError as e:
        print("  %-15s SetupError: %s" % (label, e))
ro = d/"ro"; ro.mkdir(); ro.chmod(0o555)
try:
    m.write_receipt(ro/"x.json", []); print("  %-15s WROTE" % "readonly-parent")
except m.SetupError as e:
    print("  %-15s SetupError: %s" % ("readonly-parent", e))
finally:
    ro.chmod(0o755)

print("P4 valid_public_https_url")
cases = ["https://example.com/", "https://example.com/?token=abc", "https://user:pass@example.com/",
         "https://127.0.0.1/", "https://169.254.169.254/latest/meta-data/", "https://2130706433/",
         "https://[::ffff:127.0.0.1]/", "https://[fd00::1]/", "https://localhost/",
         "https://example.com\\@evil.com/", "https://1password.com/account/", "https://account.1password.com/",
         "https://www.1password.dev/brokered-access", "https://example.com/path/ghp_aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
         "http://example.com/", "https://example.com:8443/"]
for u in cases:
    print("  %-58s %s" % (u, m.valid_public_https_url(u)))
print("P5 2130706433 resolution + is_global")
addrs, err = m.public_addresses("https://2130706433/")
print("  public_addresses ->", addrs, err)
print("P6 safe_receipt_url strip")
print("  ", m.safe_receipt_url("https://user:pass@example.com/x/deadbeefdeadbeefdeadbeefdeadbeef/ok?q=1#frag"))
