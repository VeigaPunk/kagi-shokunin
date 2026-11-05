SEAT K37CriticClaim — kagi round 37, wave build — critic attack on claim C2 (freshness)
Date: 2026-11-05. Lane: /home/vgpnk/Projects/shokunin/kagi-shokunin. Candidate: 9efcea7.
Claim under test (frozen): `bash plans/round-37-c2.sh` counts release-feed surfaces with no
SOURCES.md row naming the feed URL and the receipt's parsed_version; BASE 3, target 0.
Receipt sha256 verified before any run: cb96cfb23bda8d1366a184c280aebe767ed09b0bba0934876edeef6fe42c9203
(exact match to the pinned value in plans/round-37-c2.sh and the assignment).
Installs: none. Network fetches: none. All git operations read-only (archive/rev-parse/show/ls-tree).
Scratch: /fast/scratch/hyaku/kagi-r37/K37CriticClaim (git archive extractions), removed before yield.

METHOD
  S=/fast/scratch/hyaku/kagi-r37/K37CriticClaim
  git -C <lane> archive 9efcea7 | tar -x -C $S/cand     # candidate tree (receipt+counter tracked in it)
  git -C <lane> archive 911ab51 | tar -x -C $S/base     # BASE tree (counter+receipt absent at BASE;
                                                        # copied in from cand as fixtures, receipt sha re-verified)

BASELINES (all executed)
  bash plans/round-37-c2.sh            in $S/base  -> stdout "3",  exit 0   (no-work control reproduces)
  bash plans/round-37-c2.sh            in $S/cand  -> stdout "0",  exit 0   (landing state reproduces)
  bash corpus/sources-census.sh        in $S/cand  -> exit 0, "SOURCES_CENSUS: CLEAN (rows=91 ... captures=91 ...)"
  fleet: scripts/sources-census.sh validate --root $S/fleet0 kagi   -> exit 0, "kagi ok", W04 dup-URL warnings only
  Real-row integrity (context for §3): quotes located in the committed capture bodies at exactly the
  Gate's byte offsets — grep -abo gives 726 (v2.2.1), 729 (v2.7.2), 1583 (Python 3.15.2); body sha256
  3cbfdd86d1b45309… / a54d1a5314ca7016… / 9ba8856e586659ab… match the Gate prefixes and the
  corpus/source-fetches.tsv digest column. The shipped candidate work is genuine.

§1 CHEAPEST COUNTERFEIT — the predicate met without the claimed work
Construction (in $S/cand, via file edits on the extraction only):
  - Removed the real SOURCES.md rows S089/S090/S091; appended rows with the same ids, source cells
    carrying the same three feed URLs, anchor cells naming v2.2.1 / v2.7.2 / Python 3.15.2, and
    INVENTED quotes (e.g. "Release v2.2.1 is the newest Vault version published this cycle") that
    occur in no fetched bytes — proven: grep -rF of each invented sentence over the extraction tree
    and the stored bodies returns nothing.
  - V1: capture rows deleted (no provenance at all).
      bash plans/round-37-c2.sh  -> stdout "0", exit 0        COUNTER PASSES ON PURE INVENTION
      bash corpus/sources-census.sh -> exit 1, FINDING SC_FETCH id=S089/S090/S091 missing-provenance,
          SOURCES_CENSUS: FAILED (findings=3)  — it detects MISSING CAPTURE ROWS, not unlocated quotes.
  - V2: appended format-valid capture rows with invented 64-hex body digests (aaaa…/bbbb…/cccc…),
      invented locations ("invented-quote-not-located").
      bash plans/round-37-c2.sh  -> "0", exit 0
      lane census -> exit 1, FINDING SC_FETCH id=S08x row-identity-digest-mismatch (x3)
      fleet census -> exit 0, "kagi ok"   (fleet gate accepts the forgery outright)
  - V2': replaced the fake row digests with the correctly computed ones. The lane census's row-identity
      digest is sha256("id\tstatus\turl\n") (corpus/sources-census.sh:262-263) — derived from the
      forger's own text; computed values ec82f849… / f911b24d… / 44554690… (the same values the real
      rows carry).
      bash plans/round-37-c2.sh  -> "0", exit 0
      bash corpus/sources-census.sh -> exit 0, "SOURCES_CENSUS: CLEAN (rows=91 …)"   ALL GATES GREEN
      fleet census -> exit 0, "kagi ok"
  - V3: deleted .ufo/waves/round-37/capture/ (the committed fetch bodies) entirely.
      counter -> "0" exit 0; lane census -> CLEAN exit 0; fleet census -> exit 0 "kagi ok".
      NO gate reads the stored bodies; deleting 2,779 lines of committed evidence changes no verdict.
Result: counterfeit_passes=YES. The frozen predicate (counter = 0) is fully met by a tree in which no
feed was ever fetched, every quote is invented, and the capture bodies do not exist. The only checks
that ever fired were provenance-existence (V1) and a digest computable from the forger's own text (V2).

§2 DOES ANY CENSUS VERIFY A QUOTE OCCURS IN THE CAPTURED BODY? — NO
Lane census corpus/sources-census.sh:
  :277-278  words=$(printf '%s' "$fquote" | wc -w); …
            [[ -n $fquote && $words -le 25 ]] || finding SC_FETCH "id=$fid quote"
            -> quote checked for PRESENCE and ≤25 words only.
  :262-263  line=$(printf '%s\t%s\t%s\n' "$fid" "${ST[$fid]:-}" "${FURL[$fid]}" | sha256sum)
            [[ $frow == "${line%% *}" ]] || finding SC_FETCH "id=$fid row-identity-digest-mismatch"
            -> binds capture row to (id, status, url) REGISTRY TEXT — no bytes, no body.
  :305-306  SC_INROW compares an in-row/entry-declared "Fetch sha256:" marker against the capture
            row's declared digest — declaration vs declaration; S089-S091 carry no marker, so this
            check never engages for the claim's rows.
  :240-243  FURL/FINROW are parsed FROM THE SOURCES ROW ITSELF (source cell + optional marker).
Fleet census scripts/sources-census.sh: same gate shape — quote word-count (:277-278), digest
format (:269 `[[ $fsha =~ ^[0-9a-f]{64}$ ]]`), no body read anywhere; empirically exit 0 on the
forgery with bodies deleted.
Neither census opens .ufo/waves/round-37/capture/* at any line (V3 empirically confirms). No gate in
the repo recomputes any recorded digest from stored bytes. Answer: none does.

§3 CEILING — is the named ceiling the real one?
The plan's ceiling says: the counter checks only feed-URL + version naming; it does not check that
`teaches` is right nor that the source was opened; "a row that fakes the quote would pass the
counter; the wave's reviewer re-fetch is the control for that class." My attack confirms the named
ceiling and sharpens it in three ways:
  1. The named compensating control "the Gate's located quotes" is NOT a check — the Gate is
     lane-authored prose; no tool verifies it. That plan sentence overstates; the only live control
     it names is the reviewer re-fetch.
  2. The censuses the kill rules gate on contribute ZERO quote-authenticity signal: their strongest
     fetch checks are provenance-existence, format, and a self-derived identity digest; stored bodies
     can be deleted with every gate green (V3). So the real ceiling is larger than "the counter does
     not check quotes": NO AUTOMATED GATE IN THE REPO CHECKS QUOTES, including both censuses.
  3. The gap that would close the forged-quote class is one mechanical step away and unexercised:
     the committed bodies bind to the Gate claims exactly (offsets 726/729/1583, sha256 match), so
     `grep -abo <quote> <body>` + sha256 comparison is a decisive located-quote check — nobody runs
     it at freeze or landing. Meanwhile the lesson's own discernment rule concedes dispatched seats
     are "lane evidence, not outside agreement," and its Non-author spot-check reads "Pending
     outside closure." At this wave, quote authenticity rests on prose plus lane seats.

§4 VERDICT ON THE FROZEN CLAIM
admissible on its predicate as frozen — not a bookkeeping move — with one discipline condition.
Reason: the predicate is exactly "the counter prints 0 at the landing revision, BASE 3," and every
element measured honestly in my runs: BASE reproduces at 911ab51 ("3", exit 0), landing reproduces
at 9efcea7 ("0", exit 0), the receipt is sha-pinned and verifies, and the no-work control excludes
the round-36 failure mode (a do-nothing tree reads 3, not 0 — the delta requires the rows). The
plan's ceiling paragraph names, in advance and almost verbatim, the exact forgery class I built, so
my counterfeit exposes no hidden gap in the predicate; it confirms the declared one. The claim is
not the round-36 bookkeeping shape: the substance it rides on — that the three feeds moved to
2.2.1 / 2.7.2 / 3.15.2 — is anchored in a genuine instrument observation (receipt sha cb96cfb2…,
records carry located+sha256 fields), and the shipped rows bind to committed bodies by sha and byte
offset (verified in METHOD). What the claim certifies is registry-text currency against that frozen
receipt and nothing more; it does NOT certify that the sources were opened or that quotes are
located — no automated instrument in the repo certifies that (§2). Condition: closure must not cite
the counter's 0 (or either census CLEAN) as evidence of quote authenticity; the binding control is
the mechanical quote-location check against the committed bodies (one grep + sha compare; I executed
it on the real rows and it passes) and/or the reviewer's live re-fetch. Smallest safe correction:
none to the frozen counter, receipt, or controls; record the executed mechanical quote-location
check at closure so the forged-quote class rests on evidence rather than prose.

EVIDENCE FILES (saved under this seat dir)
  scratch-census-cand-pristine.txt  lane census, pristine candidate (CLEAN, exit 0)
  scratch-census-v1-nocaptures.txt  V1: 3x SC_FETCH missing-provenance, FAILED (findings=3)
  scratch-census-v2-fakecaptures.txt V2: 3x SC_FETCH row-identity-digest-mismatch, FAILED (findings=3)
  scratch-census-v3-nobodies.txt    V3: bodies deleted (lane census, CLEAN)
  scratch-census-final.txt          V2': full forgery, lane census CLEAN (exit 0)
  scratch-fleet-cand0.txt           fleet census, pristine candidate (exit 0, "kagi ok")
  scratch-fleet-v2.txt / scratch-fleet-v3.txt / scratch-fleet-final.txt
                                    fleet census on forgery states (exit 0, "kagi ok" in all)
  scratch-fleet-census-cand0-pristine.txt  first fleet run with wrong --root (conf error) — kept
                                    for honesty; superseded by the conf-based runs above.

CLAIM CRITIC: DONE counterfeit_passes=yes verdict=admissible
