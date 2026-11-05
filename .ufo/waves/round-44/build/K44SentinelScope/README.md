# K44SentinelScope evidence

Report: ../K44SentinelScope.md (findings F1–F4, per-item verdicts, method notes).

## Receipts (clean battery rerun, sandbox clone at ae9e9eb319826a7ded0a47ba2d043c44aa1c3bae, exit 0)

sha256:
```
53c234e5e8472b6ac51c1ae1cab3fe06fad053beb8ebfd8977b010655bfdd3c3  receipts-base-at-ae9e9eb/c1-base        (bytes: "2\n")
9a271f2a916b0b6ee6cecb2426f0b3206ef074578be55d9bc94f6f3fe3ab86aa  receipts-base-at-ae9e9eb/c1-skipfix     ("0\n")
9a271f2a916b0b6ee6cecb2426f0b3206ef074578be55d9bc94f6f3fe3ab86aa  receipts-base-at-ae9e9eb/c2-base        ("0\n")
9a271f2a916b0b6ee6cecb2426f0b3206ef074578be55d9bc94f6f3fe3ab86aa  receipts-base-at-ae9e9eb/c2-forged-sha  ("0\n")
9a271f2a916b0b6ee6cecb2426f0b3206ef074578be55d9bc94f6f3fe3ab86aa  receipts-base-at-ae9e9eb/c2-forged-rev  ("0\n")
9a271f2a916b0b6ee6cecb2426f0b3206ef074578be55d9bc94f6f3fe3ab86aa  receipts-base-at-ae9e9eb/c3-base        ("0\n")
1121cfccd5913f0a63fec40a6ffd44ea64f9dc135c66634ba001d10bcf4302a2  receipts-base-at-ae9e9eb/c3-pos        ("3\n")
4355a46b19d348dc2f57c046f8ef63d4538ebb936000f3c9ee954a27460dd865  receipts-base-at-ae9e9eb/c3-wrongvals   ("1\n")
1172db1481fa954d763d0868682ce4d8aaee288bc95a32748342c5319ae77407  receipts-base-at-ae9e9eb/measured-at.txt
```

Instrument pins at ae9e9eb:
```
050801ae95c87d49ea57125234a6ce76e1b6ddf774839f687caf1e4ae546f293  plans/round-44-c1.sh
e3aff85dd13c2b1df899a93d97e4cae2c79ffe920e22bc2bac8ab699a1b07be5  plans/round-44-c2.sh
53ac204198c37de9ba2483c50b49d948e0fe4ebc08ec865bb7e89e92e34f7c4e  plans/round-44-c3.sh
b0c680116db8caeeabfd868ff429c68408e01fc4405fc95ee7bb32f8f189036f  plans/round-44-controls.sh
```

containment/ holds porcelain and /tmp,/var/tmp snapshots plus the footprint sampler summary
(peak 895 MB, max 4 live shared clones, ~56 samples at 2 s cadence during the first full battery run).
injection-probes.txt holds the verbatim observed argument-injection results (incl. the F1 finding hit).

Sandbox scratch (clones, sampler logs) deleted before seat yield; these copies are the durable evidence.
