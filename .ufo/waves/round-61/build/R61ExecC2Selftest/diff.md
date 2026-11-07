# diff.md — SKILL.md gate-registry row for `plans/round-60-c2.sh` (I2 / spot-check D2)

Exactly one line of `SKILL.md` changed: the round-60-additions gate-registry row whose
name cell contains `plans/round-60-c2.sh` (was line 855). No other byte of `SKILL.md`
was touched.

## OLD (selftest cell read `none of its own`)

```
| AppRole custody counter (`plans/round-60-c2.sh`) | gate | `bash plans/round-60-c2.sh [revision \| --tree DIR]` | 0 `C2_APPROLE_TRIAL: value=5 …`; 1 value<5; 2 SETUP | none of its own — it runs the trial's `--selftest` as a conjunct | two independent real runs, five shim vectors, the no-bao leg, the trial's `--selftest`, a secret scan and the ambient-env leg | materialises the revision into scratch and removes it; no lane write | kagi |
```

## NEW (selftest cell carries the runnable `--selftest`, the case count and the red witness)

```
| AppRole custody counter (`plans/round-60-c2.sh`) | gate | `bash plans/round-60-c2.sh [revision \| --tree DIR]` | 0 `C2_APPROLE_TRIAL: value=5 …`; 1 value<5; 2 SETUP | `bash plans/round-60-c2.sh --selftest` ⇒ `C2_SELFTEST: PASS (cases=36)`, fixture-driven (no `bao`, no network), and fails with named `FINDING` ids on a mutated copy — 36 assertions over 8 fixture cases that drive the counter's own verdict mapping end to end through a fixture trial (absent trial; all-legs HOLDS; broken shim vector; missing second real run; no-bao leg printing HOLDS; failing trial selftest; secret-shaped fixture token; unknown flag SETUP), with the red witness built in (a copy with the verdict mapping inverted, or the SH1 expectation dropped, exits non-zero printing `FINDING C2-ST-MUT*` ids); the trial's `--selftest` stays a conjunct of the value | two independent real runs, five shim vectors, the no-bao leg, the trial's `--selftest`, a secret scan and the ambient-env leg | materialises the revision into scratch and removes it; no lane write | kagi |
```

Checks against the frozen I2 condition: the selftest cell carries `--selftest`
(`bash plans/round-60-c2.sh --selftest`), states the case count (36), carries the
red-witness note (inverted verdict mapping / dropped SH1 expectation ⇒ non-zero exit
with named `FINDING C2-ST-MUT*` ids), and the string `none of its own` no longer
occurs in this row. (One other, out-of-scope occurrence remains at `SKILL.md:754` —
the round-24 `row identity reader`, `kind: helper`, not a gate and not named by I2;
"change nothing else in SKILL.md" leaves it untouched.)
