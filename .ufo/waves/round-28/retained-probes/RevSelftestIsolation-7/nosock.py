import runpy, socket, sys
class NetworkBlocked(RuntimeError):
    pass
def boom(*a, **k):
    raise NetworkBlocked("network access attempted during the selftest")
socket.socket.connect = boom
socket.socket.connect_ex = boom
socket.create_connection = boom
socket.getaddrinfo = boom
socket.gethostbyname = boom
sys.argv = ["release-clock.py", "--selftest"]
try:
    runpy.run_path("base/corpus/release-clock.py", run_name="__main__")
except SystemExit as exc:
    print("EXIT", exc.code)
