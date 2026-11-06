| P1-status-flip | 0 | why=status:S014) | valid |
| ↳ C1-M4-drop-intact-conjunct | P1-status-flip | 0→0 | NOT-KILLED |
| ↳ C1-M5-ignore-status-cell | P1-status-flip | 0→0 | NOT-KILLED |
| P2-dup-registry-row | 0 | why=row-count:S010) | valid |
| ↳ C1-M6-accept-dup-registry-rows | P2-dup-registry-row | 0→0 | NOT-KILLED |
| P3-capture-tamper | 0 | why=capture-sha) | valid |
| ↳ C1-M7-drop-capture-sha | P3-capture-tamper | 0→3 | KILLED |
| P4-row-sha-wrong | 0 | why=sha) | valid |
| ↳ C1-M8-drop-row-sha | P4-row-sha-wrong | 0→3 | KILLED |
| P5-two-s099-rows | 0 | why=s099-rows=2) | valid |
| ↳ C1-M10-drop-single-s099-row | P5-two-s099-rows | 0→0 | NOT-KILLED |
| P6-prefixed-finding | 3 | why=) | valid |
| ↳ C1-M12-loose-cleared-match | P6-prefixed-finding | 3→2 | KILLED |
| P7-quote-absent-from-blob | 0 | why=quote) | valid |
| ↳ C1-M14-drop-blob-quote-check | P7-quote-absent-from-blob | 0→3 | KILLED |
| P1b-status-flip-silent-census | 0 | why=status:S014) | valid |
| ↳ C1-M4-drop-intact-conjunct | P1b-status-flip-silent-census | 0→3 | KILLED |
| ↳ C1-M5-ignore-status-cell | P1b-status-flip-silent-census | 0→3 | KILLED |
| P2b-dup-registry-silent-census | 0 | why=row-count:S010) | valid |
| ↳ C1-M6-accept-dup-registry-rows | P2b-dup-registry-silent-census | 0→0 | NOT-KILLED |
| P5b-two-s099-rows-silent-census | 0 | why=s099-rows=2) | valid |
| ↳ C1-M10-drop-single-s099-row | P5b-two-s099-rows-silent-census | 0→3 | KILLED |
| Q1-swap-same-count | 10 | S012:quote-swapped; | valid |
| ↳ C2-M5-drop-quote-swap | Q1-swap-same-count | 10→11 | KILLED |
| Q2-wrong-quote-count | 10 | S012:quote-count; | valid |
| ↳ C2-M6-drop-quote-count | Q2-wrong-quote-count | 10→11 | KILLED |
| Q3-quote-absent-body | 10 | S012:not-located; | valid |
| ↳ C2-M7-accept-zero-count | Q3-quote-absent-body | 10→10 | NOT-KILLED |
| Q4-dotdot-same-file | 10 | S012:capture-dotdot; | valid |
| ↳ C2-M10-drop-dotdot | Q4-dotdot-same-file | 10→11 | KILLED |
| Q5-capture-outside | 10 | S012:capture-path; | valid |
| ↳ C2-M11-drop-capture-prefix | Q5-capture-outside | 10→11 | KILLED |
| Q6-dup-ledger-row | 10 | S012:rows=2; | valid |
| ↳ C2-M12-accept-dup-ledger-rows | Q6-dup-ledger-row | 10→11 | KILLED |
| Q7-wrong-url | 10 | S012:url; | valid |
| ↳ C2-M13-drop-url-check | Q7-wrong-url | 10→11 | KILLED |
| Q8-wrong-release | 10 | S012:release; | valid |
| ↳ C2-M14-drop-release-check | Q8-wrong-release | 10→11 | KILLED |
| Q9-capture-same-len | 10 | S012:capture-sha; | valid |
| ↳ C2-M16-drop-capture-sha | Q9-capture-same-len | 10→11 | KILLED |
| Q10-wrong-declared-bytes | 10 | S012:capture-bytes; | valid |
| ↳ C2-M9-drop-capture-bytes | Q10-wrong-declared-bytes | 10→11 | KILLED |
