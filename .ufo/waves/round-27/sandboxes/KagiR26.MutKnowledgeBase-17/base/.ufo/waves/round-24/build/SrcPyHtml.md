# Python `html.unescape` source finding

## Source observation

- URL opened: <https://docs.python.org/3/library/html.html> (official Python docs; declared fetch profile).
- Fetch command: `curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)' https://docs.python.org/3/library/html.html`; exit code **0**.
- Located at the page heading **“html — HyperText Markup Language support”**, function definition anchor **`#html.unescape`** (page section `#module-html`). The page identifies itself as **Python 3.15.0 documentation**, links source on CPython branch `3.15`, and displays **“Last updated on Oct 21, 2026 (05:52 UTC).”** No exact source commit is displayed.
- Verbatim definition (20 whitespace-separated words):

  > “Convert all named and numeric character references (e.g. `&gt;`, `&#62;`, `&#x3e;`) in the string *s* to the corresponding Unicode characters.”

  The immediately following sentence specifies the HTML 5 rules for valid and invalid references and the HTML 5 named-reference list. Together, the adjacent sentences support the narrow claim that `html.unescape` converts HTML5 named and numeric references to Unicode.

## Code check

- `corpus/rendered-text-v1.py:23-26` declares `html.unescape` as Python stdlib handling HTML5 named and numeric references, **after** tag removal; it also states that escaped markup produced by decoding entities is not removed.
- `corpus/rendered-text-v1.py:52` imports `html`; `:61-66` implements `normalize_text`, with tag substitution at `:63` and `html.unescape(s)` at `:64`, followed by whitespace collapse and trim. The call order matches the declaration.
- The docs substantiate the `html.unescape` semantics, not the normalizer’s regexes, operation order, or other pipeline behavior; those remain code claims.

## SOURCES-contract recommendation

- **Recommendation: ADMIT**, limited to grounding the declaration of Python `html.unescape` semantics in `rendered-text-v1.py`.
- **Kind:** `docs`. **Tier:** `A`, scoped to this claim: official Python documentation is authoritative for the documented API (`CORPUS.md:91-97`). **Scope:** Python 3.15 `html.unescape` converts named and numeric character references to corresponding Unicode characters under the documented HTML 5 rules.
- **Anchor/revision:** `html.unescape` (`#html.unescape`), *html — HyperText Markup Language support*, Python 3.15.0 docs; page last updated 2026-10-21 05:52 UTC. This meets the contract’s anchored, version/date-scoped source requirement (`CORPUS.md:99-100`). Suggested `recheck`: `on-release` (`corpus/QUALITY.md:23`).
- **Reason:** the quote directly covers named + numeric references and the Unicode conversion; the adjacent sentence supplies HTML5 rule coverage, and the exact function call and order are present in the declaration’s implementation.
- **Flip condition:** reject this page as grounding for the code’s actual-runtime behavior if a runtime pin/recheck establishes that the script runs a Python version whose official `html.unescape` contract differs materially from the 3.15 documentation; use the matching version’s official docs instead. Also reconsider if the page stops asserting named + numeric conversion under HTML 5 rules.

## Trace tooling

- LSP was unavailable: `read` of `xd://lsp` returned `No such tool` (the mounted-tool response listed no LSP device). Source locations above come from direct file reading, not semantic grep evidence.
