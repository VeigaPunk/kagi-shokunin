K47MutCounters receipts (round 47, BASE 252ef1ca).

Reproduce:
  S=$HYAKU_SCRATCH/kagi-r47/K47MutCounters; mkdir -p "$S"
  cp -a . $S/ctl 2>/dev/null; mkdir -p $S/mut && cp mut/*-pristine.sh $S/mut/
  cp -a cap $S/cap
  python3 $S/ctl/gen_mutants.py        # writes $S/mut/<id>-c{1,2}.sh + .diff
  python3 $S/ctl/mutdrive.py baseline  # 17 frozen controls, must equal controls-prefreeze.txt
  python3 $S/ctl/mutdrive.py <mutant-id>
  python3 $S/ctl/probes.py
Missing from this dir on purpose: the six live HTML captures (~1.4 MB). Refetch the registry URLs
and compare sha256 with cap/captures.sha256; cap/S099.body is included (fleet blob 75dd2612).
The harness copies differ from plans/*.sh only by the documented REPO= relocation.
