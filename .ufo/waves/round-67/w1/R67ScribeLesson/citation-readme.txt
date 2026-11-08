# citation gate on corpus/README.md, current working tree (README rows added by this seat)
$ bash corpus/claim-ledger.sh citations --docs corpus/README.md
UNRESOLVED corpus/README.md:120 corpus/knowledge/source-capture-binding.md (local)
CITATION_GATE: BROKEN (cites=159 docs=1 unresolved=1 ephemeral=0 labeled=0)

# same command on a fixture whose corpus/knowledge/source-capture-binding.md EXISTS
$ (fixture with the entry present) bash corpus/claim-ledger.sh citations --docs corpus/README.md
CITATION_LAYOUT: lone-clone fleet_absent=6 (no fleet-root entry or sibling lane beside the root; fleet-only citations were not checked)
CITATION_GATE: INCOMPLETE (cites=159 docs=1 unresolved=0 ephemeral=0 labeled=0 fleet_absent=6)
# cite_target() — corpus/claim-ledger.sh:659-663 (the resolution rule for a corpus/* token)
  local t=$1 r
  case "$t" in
    corpus/*|SKILL.md|SCORECARD.md|PROVINCE.md|SHONEN.md|LOG.md|AGENTS.md)
      [[ -e $ROOT/$t ]] && printf '%s' "$ROOT/$t" ;;
    knowledge/*|lessons/*)
      [[ -e $ROOT/corpus/$t ]] && printf '%s' "$ROOT/corpus/$t" ;;
    .ufo/*)
      # lane-first (round 24, R11-08): lane rounds keep their wave evidence in
      # their own `.ufo/`; only a path absent there falls back to the fleet tree
      r=${t#.ufo/}
      if [[ -e $ROOT/.ufo/$r ]]; then printf '%s' "$ROOT/.ufo/$r"
      elif [[ -e $ROOT/../.ufo/$r ]]; then printf '%s' "$ROOT/../.ufo/$r"; fi ;;
    ufo/*)
      r=${t#ufo/}; [[ -e $ROOT/../.ufo/$r ]] && printf '%s' "$ROOT/../.ufo/$r" ;;

# cite_class() — corpus/claim-ledger.sh:643-653
  case "$1" in
    corpus/*) printf 'local' ;;
    knowledge/*|lessons/*) printf 'shorthand' ;;
    ufo/*|.ufo/*) printf 'ufo' ;;
    kagi-shokunin/*) printf 'self' ;;
    *-shokunin/*) printf 'sibling' ;;
    SKILL.md|SCORECARD.md|PROVINCE.md|SHONEN.md|LOG.md|AGENTS.md) printf 'rootdoc' ;;
    *) return 1 ;;
  esac
}

cite_target() { # prints the resolved absolute path, or nothing
# SD6 consequence of the forward reference
# corpus/self-description-sweep.sh:406-418 — every UNRESOLVED line from the citations gate
# becomes a 'MISMATCH SD6 <loc> <detail>' finding.

$ bash corpus/claim-ledger.sh citations --docs corpus/README.md   # today, entry absent
UNRESOLVED corpus/README.md:120 corpus/knowledge/source-capture-binding.md (local)
CITATION_GATE: BROKEN (cites=159 docs=1 unresolved=1 ephemeral=0 labeled=0)

$ same command with corpus/knowledge/source-capture-binding.md present (fixture)
CITATION_GATE: INCOMPLETE (cites=159 docs=1 unresolved=0 ephemeral=0 labeled=0 fleet_absent=6)
