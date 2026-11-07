# R58MutCounter — survivors: confirmed, then closed by the lane's own revision

Three conjuncts were shape-reads on pins `d37829c0` and `59f6eba4`, outside the
assigned one-per-item battery (whose eight predicates all killed). On the primary
pin `6b9c0c9d` the lane's own hardening binds all three; the probes now read
`value=1` with the right token. **No survivor remains on the final bytes and no
patch routing is open.** The record below gives the exploit and binding, so the
L1 can confirm the landed instrument really carries it.

Verification (pin `6b9c0c9d`, base `cand04`):

```
c7-x1: value=1 population=8 i1=1 i2=1 i3=0 … guard=1     (date probe now caught)
c7-x2: value=1 population=8 … i5=0 … guard=1             (command probe now caught)
c7-x3: value=1 population=8 i1=0 … guard=1               (missing-receipt probe now caught)
base:  value=0 population=8 i1..i8=1 guard=1
```

On the earlier pins the same probes read `value=0 … iN=1 … guard=1`
(`c3-x*.out`, `c4-x*.out`). The historical patch bundles
`checker-patched.8a2fa2e1.py` (for `59f6eba4`) and `checker-patched.58e530b2.py`
(for `d37829c0`) were verified too (`c4p-*.out`, `c3p-*.out`); they are kept as
the independent derivation of the same bindings, not as a pending change.

## S1 — I3 must bind the date to the S117 registry row (now line 314)

Mutation (probe `x1`): lesson S117 Gate row `audit-hash/, opened 2026-11-07` ->
`audit-hash/, opened 2026-11-06` (the registry row still says 2026-11-07).

Old exploit: `if DATE_RE.search(blk): date_ok = True` accepted any date shape.
Landed binding (`6b9c0c9d` line 314):

```python
        if set(DATE_RE.findall(s117)) & set(DATE_RE.findall(blk)):
            date_ok = True
```

## S2 — I5 must read the entry-command cell (now lines 401-405)

Mutation (probe `x2`): entry command
`python3 -I -B corpus/current-claims.py …` -> `python3 -I -B corpus/other-claims.py …`;
the name cell still says `corpus/current-claims.py`.

Old exploit: `"python3" in ln` plus the name cell matched; the command's script was
never read. Landed binding (`6b9c0c9d` lines 401-405):

```python
        cells = [c.strip() for c in ln.strip().strip("|").split("|")]
        cmd_cell = cells[2] if len(cells) > 2 else ""
        if ("corpus/current-claims.py" in cmd_cell and "python3" in ln
                and "--selftest" in ln and "SETUP" in ln
                and {"0", "1", "2"} <= codes):
```

## S3 — I1 must bind the named receipt path to a file (now lines 253-254)

Mutation (probe `x3`): LOG Round-57 record every epoch-C receipt path
`…/controls-prefreeze-epochC*.txt` -> `…/controls-prefreeze-epochC-gone.txt`
(no such file; the name still matches the epoch-C shape and the `epoch C` token
stays on the same line).

Old exploit: `ok_log_path = ok_log_epoch` (shape only). Landed binding
(`6b9c0c9d` lines 253-254):

```python
    ok_log_path = ok_log_epoch and any(
        os.path.isfile(os.path.join(root, p)) for p in EPOCH_C_RECEIPT_RE.findall(surf))
```

## What remains (not survivors; routed as remarks)

- R1 `item8` hard-codes `FLEET_ROOT = "/home/vgpnk/Projects/shokunin"` (L1's
  conformance ruling; host-specific). Make it env-overridable
  (`C1_FLEET_ROOT`) and name the bound.
- R2 `--no-challenge` exits 1 on a clean tree (declared diagnostic semantics, A4).
  The wrapper ignores that rc; a bare consumer could misread it.
- R4 I4's tip-count/end-rows class reads the *live* registry count; freeze
  `corpus/SOURCES.md` before the final candidate reading.
- R3 (I6 over-read of every string constant) is **withdrawn**: `d37829c0` already
  excludes the module docstring and the `--selftest` fixture bodies/plumbing
  (M58-4), and `6b9c0c9d` keeps that.
