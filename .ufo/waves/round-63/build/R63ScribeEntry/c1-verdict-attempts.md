# C1 counter verdict attempts on the candidate tree (this seat)

Both attempts were made with `HYAKU_SCRATCH` pointed at this seat's scratch and
`bash plans/round-63-c1.sh --tree /home/vgpnk/Projects/shokunin/kagi-shokunin`.

## attempt 1 — 20:12 counter bytes (sha of the file then not recorded)

Observed stdout before the crash (copied from the seat transcript; the redirect file was
overwritten by attempt 2, so this is the transcript copy, not a live file):

```
c1-residual: prior leg=1 (B3..B7 must each read value>=1)
c1-residual: paraphrase leg=1 (P3..P5 must each read value=0)
c1-residual: stub e1_rc=2 e1_ok=1 e2_rc=2 e2_ok=1 (runs: <scratch>/stub/run.out <scratch>/stub2/run.out)
plans/round-63-c1.sh: line 472: STUB: unbound variable
```

No `C1_RESIDUAL:` line was printed. The 20:18 bytes no longer carry a `$STUB` reference
at that site (the stub echo now names `$stub3_rc`/`$stub3_e3`).

## attempt 2 — 20:17 tree copy

Cancelled by this seat after the reviewer recorded the same wave-load starvation class
(`.ufo/waves/round-63/build/R63Reviewer/findings.md` §6: two counter runs starved behind
four concurrent runs). No output was produced; the redirect file is empty.

The counter-level verdict (`C1_RESIDUAL: accepted=0 rejected=0 … guard=1`) is the L1's to
land; this seat's entry does not substitute for it.
