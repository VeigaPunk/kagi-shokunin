# R61ExecFixRecords — rederive receipt (round 61, seat R61ExecFixRecords)

One command + output per number written into the three corrected record files
(`corpus/lessons/round-60.md`, `plans/round-60.md`, `LOG.md`). All commands run by this
seat on 2026-11-07 from the lane repo `/home/vgpnk/Projects/shokunin/kagi-shokunin`
(read-only git; no numbers copied without re-derivation).

## I1 — `results=16` and `output=3824` (lesson correction line "supersedes R37")

Command:

```
python3 -I -B -c "
import json
d=json.load(open('.ufo/waves/round-60/w1-results.json','rb'))
res=d['results']; mut=[r for r in res if r['name']=='R60MutCounters'][0]
print('results =',len(res)); print('R60MutCounters output bytes =',len(mut['output'].encode()))"
```

Output:

```
results = 16
R60MutCounters output bytes = 3824
```

Named artifact `mutants.md` exists at HEAD:

```
$ git ls-tree -r --name-only HEAD -- .ufo/waves/round-60/build/R60MutCounters/
.ufo/waves/round-60/build/R60MutCounters/mutants.md
.ufo/waves/round-60/build/R60MutCounters/raw/SHA256SUMS
.ufo/waves/round-60/build/R60MutCounters/raw/c1-matrix.txt
.ufo/waves/round-60/build/R60MutCounters/raw/c2-clean-final-bytes.txt
.ufo/waves/round-60/build/R60MutCounters/raw/c2-matrix.txt
.ufo/waves/round-60/build/R60MutCounters/raw/c2-on-gutted-selftest-trial.provenance.md
.ufo/waves/round-60/build/R60MutCounters/raw/c2-on-gutted-selftest-trial.txt
.ufo/waves/round-60/build/R60MutCounters/raw/c2-single-run.txt
.ufo/waves/round-60/build/R60MutCounters/raw/probed-c1-check.py
.ufo/waves/round-60/build/R60MutCounters/raw/probed-trial.sh
.ufo/waves/round-60/build/R60MutCounters/raw/trial3-T-M1-shim-flips-two.out
.ufo/waves/round-60/build/R60MutCounters/raw/trial3-T-M2-broken-maps-0.out
.ufo/waves/round-60/build/R60MutCounters/raw/trial3-T-M3-selftest-no-assertions.out
.ufo/waves/round-60/build/R60MutCounters/raw/trial3-clean.out
```

## I3/A7 — the cited receipt carries no form/content-type leg

Command (grounds both the lesson's "second instance" line and plan Amendment A7):

```
$ git show 818d2a82:.ufo/waves/round-60/final/l1-probe.txt | grep -nicE 'form|content-type'
0
$ echo $?
1        # grep rc 1 = no match
```

## I4 — `three` new record defects (D1, D2, D3)

Command (the routed-defect table of the spot-check names exactly D1–D3 as new record
defects; D4 is the sentence itself, D5–D7 are the other routed records):

```
$ grep -cE '^\| D[123] \|' corpus/lessons/round-60-verifier-spotcheck.md
3
```

Quoted sentence located in the round-60 fleet report
(`/home/vgpnk/Projects/shokunin/.ufo/reports/round-60/kagi.md`):

```
$ grep -c 'no new record defect' /home/vgpnk/Projects/shokunin/.ufo/reports/round-60/kagi.md
1
```

## I6 — the driver line and four `-03:00` committer timestamps

Driver line (fleet watchdog, mutable; copied verbatim):

```
$ grep -m1 'launch kagi round=60' /home/vgpnk/Projects/shokunin/.ufo/watchdog.log
2026-11-07T15:03:17-03:00 launch kagi round=60 pgid=134532 driver=hyaku-inline attempt=1
```

Committer stamps in the named range:

```
$ git log --format='%ci' a677c78e..818d2a82
2026-11-07 16:33:44 -0300
2026-11-07 16:33:16 -0300
2026-11-07 16:32:34 -0300
2026-11-07 16:26:52 -0300
2026-11-07 16:01:05 -0300
2026-11-07 15:47:01 -0300
2026-11-07 15:18:26 -0300
2026-11-07 15:14:19 -0300
2026-11-07 15:06:58 -0300
```

Each of the four stamps quoted in the correction line occurs in that output
(normalization: `T` → space, `-03:00` → ` -0300`, git's `%ci` offset form):

```
$ for t in '2026-11-07T15:06:58-03:00' '2026-11-07T15:14:19-03:00' '2026-11-07T15:18:26-03:00' '2026-11-07T15:47:01-03:00'; do n=$(printf '%s' "$t" | sed 's/T/ /; s/-03:00/ -0300/'); c=$(git log --format='%ci' a677c78e..818d2a82 | grep -cF "$n"); echo "$t -> '$n' occurrences=$c"; done
2026-11-07T15:06:58-03:00 -> '2026-11-07 15:06:58 -0300' occurrences=1
2026-11-07T15:14:19-03:00 -> '2026-11-07 15:14:19 -0300' occurrences=1
2026-11-07T15:18:26-03:00 -> '2026-11-07 15:18:26 -0300' occurrences=1
2026-11-07T15:47:01-03:00 -> '2026-11-07 15:47:01 -0300' occurrences=1
```

## I7 — 3, 4, 16 and 18.75, 25 (role mix of the round-60 wave results)

Command:

```
python3 -I -B -c "
import json
d=json.load(open('.ufo/waves/round-60/w1-results.json','rb'))
roles=[r['agent'] for r in d['results']]
print('roles =',sorted(set(roles)))
lit=[x for x in roles if x in ('reviewer','critic','mutation-tester','labrat')]
print('literal-list roles present =',sorted(set(lit)),'count =',len(set(lit)))
print('plus sentinel =',len(set(lit)|{'sentinel'}) if 'sentinel' in roles else 'no sentinel')
print('total results =',len(roles))"
```

Output:

```
roles = ['connector', 'critic', 'executor', 'mutation-tester', 'revenger', 'reviewer', 'scout', 'scribe', 'sentinel']
literal-list roles present = ['critic', 'mutation-tester', 'reviewer'] count = 3
plus sentinel = 4
total results = 16
```

Percentages:

```
$ python3 -I -B -c "print('3/16 =',3/16*100,'%'); print('4/16 =',4/16*100,'%')"
3/16 = 18.75 %
4/16 = 25.0 %
```

Quoted superseded sentence located in the round-60 fleet report (wrapped over two
lines, lines 10–11):

```
10:`ufo-swarm-wave.mjs run` rc 0, `counts spawn=16 resume=0 total=16`), attack share 4/16 =
11:25 % on the addendum's literal list (reviewer, critic, mutation-tester, labrat — no labrat
```

## I5 (LOG.md) — `insertions=1 deletions=1` and the superseded text

Command:

```
$ git diff --numstat 14a6c07d 818d2a82 -- LOG.md
1	1	LOG.md
```

Superseded wave-line text at `14a6c07d` (first 200 bytes; the `dead seats 1` sentence
the in-place rewrite replaced):

```
$ git show 14a6c07d:LOG.md | tail -1 | cut -c1-200
- Wave `kagi-r60-w1`, 16 seats v1 (`.ufo/waves/round-60/w1-dispatch.json`; reports `.ufo/waves/round-60/w1/`): 2 scout, 6 executor, 2 scribe, 1 reviewer, 1 critic, 1 mutation-tester, 1 sentinel, 1 con
```

## Append-only confirmation

```
$ git diff --numstat -- LOG.md corpus/lessons/round-60.md plans/round-60.md
1	0	LOG.md
15	0	corpus/lessons/round-60.md
14	0	plans/round-60.md
```

Additions only, 0 deletions in each of the three files.
