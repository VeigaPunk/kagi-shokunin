import probe, shutil
def patch_p4(path):
    probe.patch_p3(path)
    s = path.read_text()
    old = '    return max(stable, key=lambda v: tuple(int(part) for part in v.split(".")))\n'
    new = ('    newest = max(stable, key=lambda v: tuple(int(part) for part in v.split(".")))\n'
           '    if numeric_version(newest) is None:\n        raise ValueError("non-canonical version token")\n    return newest\n')
    assert old in s; path.write_text(s.replace(old, new, 1))
probe.WORK.mkdir(exist_ok=True)
for pname, patch in (("BASE", None), ("P4", patch_p4)):
    for label, kind, spec in probe.CASES:
        if pname == "BASE" and label not in ("F4replace", "F3replace"): continue
        name = "%s-%s" % (pname, label)
        if kind == "table": r = probe.table_case(name, patch, **spec)
        elif kind == "table-env": r = probe.table_case(name, patch, env={"PYTHONINTMAXSTRDIGITS": "0"}, isolated=False, **spec)
        else: r = probe.observe_case(name, patch, *spec)
        code, tb, lines = r
        keep = [l for l in lines if not l.startswith("WRITTEN")]
        print("%-28s exit=%d tb=%s | %s" % (name, code, tb, " ; ".join(keep)[:420]))
        shutil.rmtree(probe.WORK / name)
