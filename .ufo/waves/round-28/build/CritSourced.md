# CritSourced — C1 authority split, not a new canonicality authority

## Findings first

1. **Python documentation grounds the oversize failure, not a leading-zero prohibition.**
   BASE `corpus/release-clock.py:366,369-380` accepts decimal digit components and calls `int(part)` without a base argument.
   The primary [`int()` documentation](https://docs.python.org/3/builtins/functions.html#int), string-input paragraph, explicitly allows leading zeros; its base paragraph says `int('010')` is legal while `int('010', 0)` is not.
   Concrete documentary counterexample: `01` is a valid default-base integer string, so `3.15.01` cannot be declared invalid *because Python int rejects leading zeros*.
   The [stdtypes conversion-limit section](https://docs.python.org/3/builtins/stdtypes.html#integer-string-conversion-length-limitation) instead grounds configurable decimal conversion limits and `ValueError` on excess.
   **Impacted axes:** freshness (wrong supporting authority for F1/F3), calibration (runtime acceptance misrepresented as version validity).
   **Smallest safe correction:** split the lesson's evidence chain explicitly: Python docs → bounded conversion/typed handling; SemVer §2 → the lane's chosen lexical core grammar. An `int()` row can explain numeric aliasing, but cannot supply the prohibition.

2. **S042 exists at BASE, but its registered scope and located anchor are §11.2 ordering, not §2 canonical spelling.**
   BASE `corpus/SOURCES.md:49` scopes S042 to numeric precedence and locates §11.2; `:76` records its round-27 opening. BASE `corpus/SOURCES.md:50` separately limits S043 to supporting distribution-version ordering, not CPython interpreter policy.
   [SemVer §2](https://semver.org/spec/v2.0.0.html#spec-item-2) genuinely says normal X.Y.Z numbers “MUST NOT contain leading zeroes.” Thus the source page contains the rule, but the existing row's **registered teaching/locator** is not that rule.
   Concrete provenance counterexample: copying S042's BASE quote, “Major, minor, and patch versions are always compared numerically,” into a round-28 Gate does not ground rejection of `3.15.01`; numerical comparison collapses its patch value to 1.
   CORPUS.md:93-100 makes tier scope-specific and requires exact anchors; :112-118 requires this-round opening for a newly written row and permits only status/recheck/used-by in-place changes.
   **Smallest safe correction:** if a registry row is to assert the new §2 teaching, reopen SemVer this round and append a scoped row with a located §2 quote; do not silently broaden S042's scope/anchor/teaches. Use `supersedes S042 —` if presented as a correction; preserve the valid ordering teaching. A repeated canonical URL is not a new website, and must not be counted as one.

3. **The frozen wording does not require every half of C1 to have a newly created row.**
   Current `plans/round-28.md:21-25` separately names S042 §2 and requires “at least one registry row opened this round (Python integer-string conversion limit documentation)” cited by the lesson.
   Reusing an old S042 citation alone does **not demonstrate a this-round opening**, even though BASE `corpus/SOURCES.md:49` has the same calendar date as this round: date equality is not round provenance.
   However, a genuinely opened, properly scoped new Python-limit row can satisfy that literal at-least-one requirement while grounding F2/F4 only. Rejecting the entire sourced claim solely because that row does not also ground F1/F3 would strengthen the frozen contract without authority.
   **Advisory contract assessment, not admission/judgment:** split-source grounding is defensible; Python-only grounding for canonicality is not. The remaining fixable defect is inaccurate attribution/registry scope, not an intrinsic need to abandon C1. CORPUS.md:123-125 explicitly says expansion is knowledge, not rows, and imposes no row quota.

4. **Neither authority makes the complete lane policy a universal vendor rule.**
   SemVer §2 has no 4300-digit maximum; its grammar permits arbitrarily long nonzero-leading digit strings. Python's docs describe a configurable runtime limit, not a release-version maximum.
   Concrete documentary counterexample: `3.15.` followed by 4301 `1` characters satisfies SemVer's core spelling grammar but exceeds CPython's documented default decimal conversion limit. Conversely `3.15.01` fits the runtime limit but violates SemVer §2.
   BASE `corpus/SOURCES.md:49` already disclaims vendor SemVer API semantics; keep that boundary. Rejecting noncanonical feed tokens with a typed finding is a **lane input policy informed by those sources**, not evidence that CPython or every vendor adopts SemVer.
   **Smallest safe correction:** label the selected grammar and component bound as local fail-closed clock policy; cite each source for exactly its teaching. Say “default 4300, configurable,” not “Python versions cannot exceed 4300 digits.” No fixture or frozen counting-command change is needed.

## Axes and evidence basis

- **Freshness:** avoid false fired releases and tracebacks without borrowing a version-validity rule from runtime conversion documentation.
- **Calibration:** preserve distinctions among numeric equality, lexical canonicality, registry provenance, source scope, and local policy.
- The plan is absent from frozen BASE (as already reported in the supplied command result); plan line citations above are the current frozen claims-file text, **not BASE citations**. BASE citations above refer only to files obtained with `git show 3553d499577084a6c98d7078906017840bbf7b28:<path>`.
- Fleet `../CORPUS.md:93-118,123-125` is the current shared contract, not a file claimed to exist inside the lane's BASE tree.

## Commands and observations

Executed read-only commands (both completed successfully, exit 0):

```sh
git -C /home/vgpnk/Projects/shokunin/kagi-shokunin show 3553d499577084a6c98d7078906017840bbf7b28:corpus/SOURCES.md
git -C /home/vgpnk/Projects/shokunin/kagi-shokunin show 3553d499577084a6c98d7078906017840bbf7b28:corpus/release-clock.py
```

Specialized `read`/`grep` operations (no process exit codes exposed): read the frozen plan first; read godspeed skill and shared CORPUS.md; located BASE numeric parser lines in the retained `git show` output; opened official SemVer, Python stdtypes and functions documentation; located the integer constructor's leading-zero permission and conversion-limit/default/configurability passages. Read the sibling `SrcIntMaxStrDigits.md` proposal as data; its own §1 already limits support to the oversize half. Its proposed pairing with an `int()` row does not change that row into a canonicality authority.

## Not checked

No lane code, gates, selftests, fixtures, host rows, or another runtime were executed. Documentary counterexamples above are reasoned from primary text, not claimed probe results. No implementation draft, final round-28 lesson/Gate, final registry additions, fetch provenance, census, or Rust judgment was verified. No vendor tagging policies, private data, vaults, accounts, handlers, or CDP were contacted. No tools installed or updated. Production files unchanged; only this report written.
