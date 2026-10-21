import importlib.util, pathlib
def load(p):
    spec=importlib.util.spec_from_file_location("rc7", p)
    m=importlib.util.module_from_spec(spec); spec.loader.exec_module(m); return m
m=load("cand/corpus/release-clock.py")
CASES = {
 "feed 3.15.0 only": b"<feed><entry><title>Python 3.15.0</title></entry></feed>",
 "feed 3.15.0 + 3.15.00": b"<feed><entry><title>Python 3.15.0</title></entry><entry><title>Python 3.15.00</title></entry></feed>",
 "feed 3.15.00 only": b"<feed><entry><title>Python 3.15.00</title></entry></feed>",
 "feed 3.15.1 + 3.15.00": b"<feed><entry><title>Python 3.15.1</title></entry><entry><title>Python 3.15.00</title></entry></feed>",
 "feed 3.15.1 + 3.015.1": b"<feed><entry><title>Python 3.15.1</title></entry><entry><title>Python 3.015.1</title></entry></feed>",
}
for label, body in CASES.items():
    try:
        print(f"{label:30s} -> {m.parse_latest_version(body)!r}")
    except Exception as e:
        print(f"{label:30s} -> {type(e).__name__}: {e}")
print()
print("non_canonical_version probes:")
for t in ("3.015.1","3.15.01","3.15.00","3.15.0","03.15.1","3.15.1","1.2.3.4","3.015"):
    print(f"  {t:10s} non_canonical={m.non_canonical_version(t)} numeric={m.numeric_version(t)}")
