# Registry row drafts - kagi round 41, seat K41ScribeRegistry

Lane: /home/vgpnk/Projects/shokunin/kagi-shokunin, branch master.
Predeclaration commit (frozen plan + counters + BASE controls): 5142b52.
Claim BASE: 19025d97e5013bac2f45d6b9e61bfbafc84c3c8d.
Round-40 landed state (positive control P0 of C1): 6f1588cc0ebd5cbbd4e983fbd71c1e419d225ce0.
Round-40 claim BASE: 6cc8850dfc5757927699e5a53a876f47c8df21aa.

CORPUS.md rule 1 (a row is a claim): both sources below were opened LIVE by this seat on
2026-11-05 (see opens.txt); each row carries a located quote that exits 0 under
`python3 corpus/rendered-text-v1.py locate`. No row was copied from another seat's draft.

## Row drafts (append after the S096 row in corpus/SOURCES.md)

Each line below is ONE registry row, 11 columns, no literal or escaped pipe, no newline.
Column order: id | source | kind | tier | scope | anchor | teaches | status | opened | recheck | used-by.

```
| S097 | Built-in Types — Python 3.15.2 documentation — https://docs.python.org/3/library/stdtypes.html | docs | A | rendered-text-v1 whitespace class grounding (str.isspace) | str.isspace() entry, whitespace definition paragraph; title Python 3.15.2 documentation, fetched 2026-11-05 | grounds the step-5 whitespace class of corpus/rendered-text-v1.py for the round-41 C2 change. Quote (verbatim): "either its general category is Zs (“Separator, space”), or its bidirectional class is one of WS , B , or S ." (rendered-text-v1 byte offset 71263). Derivation (paraphrase, outside the quote): a character is whitespace for str.isspace() when the Unicode character database gives it general category Zs or bidirectional class WS, B or S; that class admits U+00A0 and U+3000 and also U+001C-U+001F, which the Unicode White_Space property omits, so it is wider than White_Space and the normalizer keeps the wider set. | mined | 2026-11-05 | 90d | corpus/lessons/round-41.md |
| S098 | UTS #18: Unicode Regular Expressions — https://www.unicode.org/reports/tr18/ | spec | A | Unicode White_Space as a candidate rendered-text-v1 whitespace class | Annex C: Compatibility Properties, space (\s) entry; UTS #18, fetched 2026-11-05 | REJECTED: as the rendered-text-v1 whitespace class, UTS #18 defines \s as the Unicode White_Space set, which excludes U+001C-U+001F that str.isspace() accepts, so it cannot ground the normalizer class; quote "space (\s) \p{Whitespace} See PropList for the definition of Whitespace."; flip: the normalizer class is redefined to White_Space. | rejected | 2026-11-05 | on-release | — |
```

## Row notes

- S097: kind `docs`, tier `A`, scope `rendered-text-v1 whitespace class grounding (str.isspace)`,
  status `mined`, opened `2026-11-05`, recheck `90d`.
- S098: kind `spec`, tier `A`, status `rejected`, opened `2026-11-05`, recheck `on-release`
  (the recheck form of the existing rejected row S030). The `teaches` cell opens `REJECTED:` and
  carries `flip:`, as the corpus contract requires for a rejected row.
- `used-by` for S097 is `corpus/lessons/round-41.md`; the seat brief proposed
  `corpus/rendered-text-v1.py (round 41 C2)`. That literal value is NOT used: measured in the sandbox,
  `bash corpus/sources-census.sh` reports it as `FINDING SC_USEDBY_MISSING path=corpus/rendered-text-v1.py (round 41 C2)`
  and `FINDING SC_USEDBY_MISSING S097: corpus/rendered-text-v1.py (round 41 C2) not a repo corpus path`
  (census exit 1), because the census accepts only `corpus/(knowledge|lessons)/<name>.md` used-by paths and
  requires the cited file to exist and to carry the row id on its `source:` line. The S095/S096 precedent
  (rows opened in round 40) uses the round lesson file for the same reason. Conflict reported verbatim in notes.md.
- `used-by` for S098 is the em dash, matching the existing rejected row S030.
- No cell contains a literal or escaped pipe and no cell contains a newline (asserted programmatically).
