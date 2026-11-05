#!/usr/bin/env bash
# plans/round-37-controls.sh MODE — pre-freeze control runner (round 37).
#
# Builds one fixture per MODE in its own scratch copy of the BASE extraction
# (never in the extraction itself: controls share one extraction), then runs
# the frozen C2 counter there and prints its integer. Used only by the
# pre-freeze gate (corpus/prefreeze-control.sh) and by the wave's forgery seats.
#   nowork   the unmodified BASE tree                          expect 3
#   g1       superseded vault anchor v2.2.0 under vault URL     expect 3
#   g2       current openbao version under the vault URL        expect 3
#   g3       current vault version stated in knowledge/ only    expect 3
#   partial  vault row only (candidate row S089)                expect 2
#   full     all three current rows S089/S090/S091 (fixture)    expect 0
set -eu
mode=${1:?mode}
base=${BASE:?BASE extraction}
scratch=${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r37
mkdir -p "$scratch"
t=$(mktemp -d "$scratch/ctl-$mode.XXXXXX")
trap 'rm -rf -- "$t"' EXIT
cp -r "$base/." "$t/"
cd "$t"
vault='| S089 | Vault releases feed — https://github.com/hashicorp/vault/releases.atom | code | A | Vault release identity | Entry titled v2.2.1, tag link /releases/tag/v2.2.1 | teaches | mined | 2026-11-05 | 90d | corpus/lessons/round-37.md |'
openbao='| S090 | OpenBao releases feed — https://github.com/openbao/openbao/releases.atom | code | A | OpenBao release identity | Entry titled v2.7.2, tag link /releases/tag/v2.7.2 | teaches | mined | 2026-11-05 | 90d | corpus/lessons/round-37.md |'
python_row='| S091 | Python releases feed — https://www.python.org/downloads/feed.rss | docs | A | CPython release identity | Item titled Python 3.15.2, pubDate Sun, 25 Oct 2026 04:15:38 +0000 | teaches | mined | 2026-11-05 | 90d | corpus/lessons/round-37.md |'
case $mode in
  nowork) : ;;
  g1) printf '%s\n' '| S089 | Vault releases feed — https://github.com/hashicorp/vault/releases.atom | code | A | Vault release identity | Entry titled v2.2.0, tag link /releases/tag/v2.2.0 | teaches | mined | 2026-11-05 | 90d | corpus/lessons/round-37.md |' >> corpus/SOURCES.md ;;
  g2) printf '%s\n' '| S089 | Vault releases feed — https://github.com/hashicorp/vault/releases.atom | code | A | Vault release identity | Entry titled v2.7.2, tag link /releases/tag/v2.7.2 | teaches | mined | 2026-11-05 | 90d | corpus/lessons/round-37.md |' >> corpus/SOURCES.md ;;
  g3) mkdir -p corpus/knowledge && printf 'source: https://github.com/hashicorp/vault/releases.atom\n\nVault v2.2.1 is current.\n' > corpus/knowledge/g3.md ;;
  partial) printf '%s\n' "$vault" >> corpus/SOURCES.md ;;
  full) printf '%s\n%s\n%s\n' "$vault" "$openbao" "$python_row" >> corpus/SOURCES.md ;;
  *) echo "unknown mode $mode" >&2; exit 2 ;;
esac
bash plans/round-37-c2.sh
