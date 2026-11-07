#!/usr/bin/env python3
"""Round-60 seat R60ScoutApprole: verify every quote recorded in capture/notes.md
against the captured bodies, and print the locating commands.

Two locator families, both resolved against the captured .body bytes:
  * raw-literal  : the quote (or anchor) is a literal byte substring of the body;
                   resolved with `grep -c -F` and located by byte offset + line.
  * rendered-v1  : the quote is prose; resolved with the lane's committed
                   normalizer `corpus/rendered-text-v1.py locate <body> '<quote>'`
                   (count >= 1) and anchored by a raw-literal span in the same body.

Read-only. No network. Writes nothing.
"""
import importlib.util
import os
import sys

LANE = "/home/vgpnk/Projects/shokunin/kagi-shokunin"
CAP = os.path.join(LANE, ".ufo/waves/round-60/capture")

spec = importlib.util.spec_from_file_location(
    "rt", os.path.join(LANE, "corpus/rendered-text-v1.py"))
rt = importlib.util.module_from_spec(spec)
spec.loader.exec_module(rt)

BODIES = {}
for sid in ("S123", "S124"):
    p = os.path.join(CAP, sid + ".body")
    with open(p, "rb") as fh:
        BODIES[sid] = fh.read().decode("utf-8", errors="strict")

# (sid, kind, mechanic, section_heading, quote, raw_anchor)
ENTRIES = [
    ("S124", "rendered-v1", "M1 bind_secret_id (default + meaning)",
     "Create/Update AppRole > Parameters",
     "bind_secret_id (bool: true) - Require secret_id to be presented when logging in using this AppRole.",
     '<code>bind_secret_id</code> <code>(bool: true)</code> - Require'),
    ("S123", "rendered-v1", "M1 bind_secret_id (default + meaning)",
     "Further constraints",
     "The bind_secret_id constraint requires secret_id to be presented at the login endpoint.",
     '<code>bind_secret_id</code> constraint requires'),
    ("S124", "rendered-v1", "M1 bind_secret_id (default + meaning)",
     "Login with AppRole",
     "role_id is always required; if bind_secret_id is enabled (the default) on the AppRole, secret_id is required too.",
     'if <code>bind_secret_id</code> is enabled (the default) on the AppRole,'),
    ("S124", "rendered-v1", "M2 secret_id_num_uses",
     "Create/Update AppRole > Parameters",
     "secret_id_num_uses (integer: 0) - Number of times any particular SecretID can be used to fetch a token",
     '<code>secret_id_num_uses</code> <code>(integer: 0)</code> - Number of times any particular SecretID'),
    ("S124", "rendered-v1", "M3 secret_id_ttl",
     "Create/Update AppRole > Parameters",
     'secret_id_ttl (string: "") - Duration in either an integer number of seconds ( 3600 ) or an integer time unit ( 60m )',
     '<code>secret_id_ttl</code> <code>(string: "")</code> - Duration in either an integer number of'),
    ("S124", "rendered-v1", "M4 secret-id-accessor lookup + destroy",
     "Generate new secret ID",
     "the response will also contain a secret_id_accessor value which can be used to read the properties of the SecretID without divulging the SecretID itself",
     'the response will also contain a'),
    ("S124", "raw-literal", "M4 secret-id-accessor lookup + destroy",
     "Read AppRole secret ID accessor / Destroy AppRole Secret ID Accessor",
     "Destroy an AppRole secret ID by its accessor.",
     "Destroy an AppRole secret ID by its accessor."),
    ("S124", "raw-literal", "M4 secret-id-accessor lookup + destroy",
     "Read AppRole secret ID accessor (path)",
     "/auth/approle/role/:role_name/secret-id-accessor/lookup",
     "/auth/approle/role/:role_name/secret-id-accessor/lookup"),
    ("S124", "raw-literal", "M4 secret-id-accessor lookup + destroy",
     "Destroy AppRole Secret ID Accessor (path)",
     "/auth/approle/role/:role_name/secret-id-accessor/destroy",
     "/auth/approle/role/:role_name/secret-id-accessor/destroy"),
    ("S124", "rendered-v1", "M5 secret_id_bound_cidrs",
     "Create/Update AppRole > Parameters",
     "secret_id_bound_cidrs (array: []) - Comma-separated string or list of CIDR blocks; if set, specifies blocks of IP addresses which can perform the login operation.",
     '<code>secret_id_bound_cidrs</code> <code>(array: [])</code> - Comma-separated string or list of CIDR'),
    ("S123", "rendered-v1", "M5 secret_id_bound_cidrs",
     "Further constraints",
     "secret_id_bound_cidrs will only allow logins coming from IP addresses belonging to configured CIDR blocks on the AppRole.",
     '<code>secret_id_bound_cidrs</code> will only allow logins coming from IP addresses'),
    ("S124", "rendered-v1", "login request body fields",
     "Login with AppRole > Parameters",
     "role_id (string: <required>) - RoleID of the AppRole.",
     '<code>role_id</code> <code>(string: &lt;required>)</code> - RoleID of the AppRole.'),
    ("S124", "rendered-v1", "login request body fields",
     "Login with AppRole > Parameters",
     "secret_id (string: <required>) - SecretID belonging to AppRole.",
     '<code>secret_id</code> <code>(string: &lt;required>)</code> - SecretID belonging to AppRole.'),
    ("S123", "raw-literal", "login request body fields",
     "Via the API (login example body)",
     '--data \'{"role_id":"988a9df-...","secret_id":"37b74931..."}\'',
     '--data \'{"role_id":"988a9df-...","secret_id":"37b74931..."}\''),
    ("S123", "raw-literal", "refused login text / HTTP shape",
     "User lockout (only refusal-shaped sentence on either page)",
     "instead returning immediately\nwith a permission denied error.",
     "instead returning immediately\nwith a permission denied error."),
    ("S124", "raw-literal", "per-field role endpoints (trial write paths)",
     "Read, update, or delete AppRole properties",
     "/auth/approle/role/:role_name/bind-secret-id",
     "/auth/approle/role/:role_name/bind-secret-id"),
    ("S124", "raw-literal", "per-field role endpoints (trial write paths)",
     "Read, update, or delete AppRole properties",
     "/auth/approle/role/:role_name/secret-id-bound-cidrs",
     "/auth/approle/role/:role_name/secret-id-bound-cidrs"),
    ("S124", "raw-literal", "per-field role endpoints (trial write paths)",
     "Read, update, or delete AppRole properties",
     "/auth/approle/role/:role_name/secret-id-num-uses",
     "/auth/approle/role/:role_name/secret-id-num-uses"),
    ("S124", "raw-literal", "per-field role endpoints (trial write paths)",
     "Read, update, or delete AppRole properties",
     "/auth/approle/role/:role_name/secret-id-ttl",
     "/auth/approle/role/:role_name/secret-id-ttl"),
]


def main():
    failures = 0
    print("QUOTE_VERIFY: rows=%d" % len(ENTRIES))
    for sid, kind, mech, section, quote, anchor in ENTRIES:
        body = BODIES[sid]
        rel = ".ufo/waves/round-60/capture/%s.body" % sid
        if kind == "raw-literal":
            qcount = body.count(quote)
            acount = body.count(anchor)
            if qcount != 1:
                failures += 1
            off = body.find(quote)
            line = body.count("\n", 0, off) + 1 if off >= 0 else -1
            cmd = ("grep -c -F '%s' %s   # raw-literal, count=%d, byte=%d, line=%d"
                   % (quote.replace("\n", "\\n"), rel, qcount, off, line))
            print("OK  %s | %s | %s | %s" % (sid, mech, section, cmd))
            print("    quote=%r" % quote)
            print("    anchor_count=%d anchor_off=%d"
                  % (acount, body.find(anchor)))
        else:
            n = rt.normalize_text(body)
            qcount = n.count(rt.collapse_quote(quote))
            acount = body.count(anchor)
            aoff = body.find(anchor)
            aline = body.count("\n", 0, aoff) + 1 if aoff >= 0 else -1
            if qcount < 1 or acount < 1:
                failures += 1
            cmd = ("python3 corpus/rendered-text-v1.py locate %s '%s'   # count=%d"
                   % (rel, quote.replace("'", "'\\''"), qcount))
            cmd2 = ("grep -c -F '%s' %s   # anchor, count=%d, byte=%d, line=%d"
                    % (anchor.replace("\n", "\\n"), rel, acount, aoff, aline))
            print("OK  %s | %s | %s" % (sid, mech, section))
            print("    quote=%r words=%d" % (quote, len(quote.split())))
            print("    %s" % cmd)
            print("    %s" % cmd2)
        print("")
    print("QUOTE_VERIFY: failures=%d" % failures)
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())
