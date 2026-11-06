#!/usr/bin/env python3
"""K46MutCounters: mutate the frozen round-46 counters in a scratch clone and score
them with the frozen pre-freeze controls runner (plans/round-46-controls.py).
A mutant is KILLED when any control reports DIFF (observed != frozen expected)."""
import hashlib, json, os, subprocess, sys

S = "/fast/scratch/hyaku/kagi-r46/K46MutCounters"
CL = S + "/clone"
REV = "44808ced56359c98f35995178fb24a6482899263"
C1 = "plans/round-46-c1.sh"
C2 = "plans/round-46-c2.sh"
OUT = S + "/out"
os.makedirs(OUT, exist_ok=True)

MUTANTS = [
    # ---- C1 counter (plans/round-46-c1.sh) ----
    ("C1-1-equiv-drop", C1,
     '  [ "$epass" = 1 ] || EQUIV=0\n',
     '  :\n',
     "EQUIV leg dropped: every equivalent mutant counts as surviving"),
    ("C1-2-real-drop", C1,
     'REAL=0\nif [ "$rrc" -eq 0 ]; then\n  case $rlast in "CLAIMS_DECLARED: CLEAN"*) REAL=1 ;; esac\nfi\n',
     'REAL=1\n',
     "REAL leg dropped: the real tree is never run"),
    ("C1-3-kill-unconditional", C1,
     '  [ "$mrc" -ne 0 ] && KILLED=$((KILLED + 1))\n',
     '  KILLED=$((KILLED + 1))\n',
     "every mutant counted killed without running its exit status"),
    ("C1-4-positive-drop", C1,
     'EQUIV=1\nrcs=""\n',
     'POSITIVE=1\nEQUIV=1\nrcs=""\n',
     "POSITIVE leg dropped: an unproven gate counts as positive"),
    ("C1-5-kill-on-setup", C1,
     '  [ "$mrc" -ne 0 ] && KILLED=$((KILLED + 1))\n',
     '  [ "$mrc" -ge 2 ] && KILLED=$((KILLED + 1))\n',
     "kill keyed on rc>=2 (SETUP/crash) instead of any non-zero exit"),
    ("C1-6-noop-allowed", C1,
     '  if cmp -s "$G" "$m"; then setup "mutant-noop-$1"; fi\n',
     '',
     "no-op mutant refusal removed"),
    ("C1-7-empty-pass", C1,
     '  if [ "$rc" -eq 0 ]; then\n    case $last in "CLAIMS_DECLARED_SELFTEST: PASS"*) pass=1 ;; esac\n  fi\n',
     '  if [ "$rc" -eq 0 ]; then\n    pass=1\n  fi\n',
     "PASS prefix check dropped: rc 0 with any last line counts as pass"),
    # ---- C2 counter (plans/round-46-c2.sh) ----
    ("C2-1-http-drop", C2,
     '        ok = (r.get("http_status") == 200\n              and isinstance',
     '        ok = (isinstance',
     "receipt records counted without http_status 200"),
    ("C2-2-date-floor-drop", C2,
     '              and at[:10] >= "2026-11-06" and at[:10] == t[0][6])',
     '              and at[:10] == t[0][6])',
     "date floor 2026-11-06 removed"),
    ("C2-3-kept-drop", C2,
     'kept = int(all(i in cur for i in base))',
     'kept = 1',
     "KEPT leg dropped: deleted registry rows never fail the counter"),
    ("C2-4-pinned-drop", C2,
     'read -r KEPT FRESH detail <<EOF\n',
     'PINNED=1\nread -r KEPT FRESH detail <<EOF\n',
     "PINNED leg dropped: an unpinned/absent receipt counts as clean"),
    ("C2-5-pinned-no-sha", C2,
     '$(gate --receipt "$RECEIPT" --receipt-sha "$RSHA")',
     '$(gate --receipt "$RECEIPT")',
     "PINNED accepted without --receipt-sha (sha gate dropped)"),
    ("C2-6-on29-drop-s098", C2,
     'S031 S032 S098"',
     'S031 S032"',
     "ON29 list loses S098"),
    ("C2-7-dup-accept", C2,
     'ok = ok and len(r) == 1',
     'ok = ok and len(r) >= 1',
     "duplicate receipt records accepted (exactly-one dropped)"),
    ("C2-8-value-gate-drop-default", C2,
     'if [ "$DEFAULT" = 1 ] && [ "$PINNED" = 1 ] && [ "$KEPT" = 1 ]; then',
     'if [ "$PINNED" = 1 ] && [ "$KEPT" = 1 ]; then',
     "VALUE no longer requires DEFAULT clean"),
    ("C2-9-pinned-always0", C2,
     '  read -r prc PINNED plast <<EOF\n',
     '  read -r prc _ plast <<EOF\n',
     "PINNED can never be 1 (pinned leg hard-fails)"),
    ("C2-10-parser-empty", C2,
     '[ -n "${KEPT:-}" ] && [ -n "${FRESH:-}" ] || setup parser-empty\n',
     ':\n',
     "parser-empty refusal removed (empty parse accepted)"),
]

def sha(p):
    return hashlib.sha256(open(p, "rb").read()).hexdigest()

def restore(rel):
    b = subprocess.run(["git", "-C", CL, "show", "%s:%s" % (REV, rel)],
                       capture_output=True, check=True).stdout
    open(os.path.join(CL, rel), "wb").write(b)
    return hashlib.sha256(b).hexdigest()

base_sha = {rel: sha(os.path.join(CL, rel)) for rel in (C1, C2)}
json.dump({"rev": REV, "pristine_sha": base_sha}, open(S + "/pristine.json", "w"), indent=2)
print("PRISTINE", json.dumps(base_sha))

rows = []
for name, rel, old, new, what in MUTANTS:
    p = os.path.join(CL, rel)
    pre = sha(p)
    s = open(p, encoding="utf-8").read()
    if s.count(old) != 1:
        rows.append({"mutant": name, "file": rel, "what": what, "verdict": "SETUP",
                     "diff": "anchor count=%d" % s.count(old)})
        continue
    open(p, "w", encoding="utf-8").write(s.replace(old, new, 1))
    mut = sha(p)
    env = dict(os.environ, HYAKU_SCRATCH=S + "/hs-" + name)
    pr = subprocess.run(["python3", "-B", "plans/round-46-controls.py"], cwd=CL,
                        env=env, capture_output=True, text=True)
    open(os.path.join(OUT, name + ".txt"), "w").write(
        "$ python3 -B plans/round-46-controls.py  (cwd=%s, HYAKU_SCRATCH=%s)\n%s%s\nrc=%d\n"
        % (CL, env["HYAKU_SCRATCH"], pr.stdout, pr.stderr, pr.returncode))
    lines = pr.stdout.strip().splitlines()
    diffs = [l for l in lines if "\tDIFF\t" in l]
    killed_by = [l.split("\t")[0] for l in diffs]
    verdict = "KILLED" if diffs else "SURVIVED"
    post = restore(rel)
    rows.append({"mutant": name, "file": rel, "what": what,
                 "pre_sha": pre, "mutant_sha": mut, "restored_sha": post,
                 "restored_ok": post == pre, "verdict": verdict,
                 "killed_by": killed_by, "rc": pr.returncode,
                 "last": lines[-1] if lines else "<no output>",
                 "diff_lines": diffs})
    print("%-28s %-9s rc=%d killed_by=%s restored=%s"
          % (name, verdict, pr.returncode, ",".join(killed_by) or "-",
             "OK" if post == pre else "MISMATCH"))

post_all = {rel: sha(os.path.join(CL, rel)) for rel in (C1, C2)}
json.dump({"rev": REV, "rows": rows, "final_sha": post_all,
           "restored_all": post_all == base_sha}, open(S + "/results.json", "w"), indent=2)
print("FINAL", json.dumps(post_all), "restored_all=%s" % (post_all == base_sha))
