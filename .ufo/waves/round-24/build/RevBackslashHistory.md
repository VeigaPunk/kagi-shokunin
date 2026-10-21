# Backslash guard history

## Findings

- The policy guard first entered `corpus/claim-ledger.sh` with the file itself in **R11 commit `301b9ec6f5fa6aa78518e5c177eb9f63d01c76dc`** (2026-09-28 20:08:39 -0300). The `policy_check` history from `git log -L` shows its initial line as `[[ $c == *'\\'* ]]` (`corpus/claim-ledger.sh@301b9ec:121`). At the frozen Round-23 HEAD, this old test was still present; it matched two adjacent backslashes, not one.
- The Round-11 lesson associates the `g\it` evasion with **selftest case 36**, whose actual name is `policy-split-verb` (`corpus/lessons/round-11.md:160`; source case `corpus/claim-ledger.sh:1466`). Its fixture is `claims-split.tsv`: `bash -c "o""p --version"` (`claim-ledger.sh:1278`). It contains no backslash and is rejected by the earlier `bash -c` check, not the backslash guard. Thus case 36 did **not** test or prove refusal of `g\it`.
- The Round-11 lesson's separate claim that `g''it` / `g\it` / `o"p"` reached a stand-in is recorded as a real executor observation (A03/A04, sentinel F2; line 160). That vulnerability observation was true as reported; the implied claim that selftest case 36 covered the backslash refusal was never true. The old guard could not refuse a command containing only one backslash.
- In the observed Round-24 working tree, new fixture `claims-bs1.tsv` uses `printf '...corpus/a\\b...'` (`corpus/claim-ledger.sh:1324`) and case **`policy-single-backslash`** (`:1563`). Bash `printf` turns the format's `\\` spelling into one literal `\` in the generated command field. This is the first selftest case found that actually feeds a single backslash; it tests `a\b`, not the exact token `g\it`. The current R24 draft changes the guard to `[[ $c == *\\* ]]` (`:261`), which matches a single literal backslash. These are working-tree/R24-draft lines, not the frozen HEAD; HEAD remains `4f94b52a3cdfaa289d779bd8a2afcd0b1fcd9105`. A separate non-HEAD commit object `800792299b0245327121d589519848c68defe682` (parent is that HEAD, blank subject) contains the same R24 change.
- **R18-02 came later:** commit `fecee8743e52eb8fb5fbb40782934cb619a1a96e`, dated 2026-10-14 10:05:10 -0300, added `R18-02` to `corpus/claim-ledger.tsv` (`:49`) with command `grep -cE '\[substrate\]'`. It postdates the R11 guard by over two weeks; the R11 guard predates the R18-02 row.

## Evidence chain / commands

All history commands below were read-only and exited 0:

```sh
git -C /home/vgpnk/Projects/shokunin/kagi-shokunin log --format='%H %ad %s' --date=iso-strict -L '/^policy_check() {/,/^}/:corpus/claim-ledger.sh'
git -C /home/vgpnk/Projects/shokunin/kagi-shokunin log --format='%H %ad %s' --date=iso-strict -S"[[ \$c == *'\\\\'* ]]" -- corpus/claim-ledger.sh
git -C /home/vgpnk/Projects/shokunin/kagi-shokunin log --format='%H %ad %s' --date=iso-strict -S'policy-split-verb' -- corpus/claim-ledger.sh
git -C /home/vgpnk/Projects/shokunin/kagi-shokunin log --format='%H %ad %s' --date=iso-strict -S"grep -cE '\\[substrate\\]'" --all -- corpus/claim-ledger.tsv
git -C /home/vgpnk/Projects/shokunin/kagi-shokunin show --format= --unified=2 fecee8743e52eb8fb5fbb40782934cb619a1a96e -- corpus/claim-ledger.tsv
```

`-L` and `-S` identify R11 as the guard/case introduction and R18 as the later count-row addition. No selftest or other runtime was run for this history investigation; the R24 fixture conclusion is static source/`printf`-format analysis, not an executed result. No tools were installed or updated.
