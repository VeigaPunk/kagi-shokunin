#!/bin/bash
REF=/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-48/controls/fixtures/ref-sops-age-trial.sh
bash "$REF" "$@" | awk '{print} /^TRIAL T1 HOLDS/{print}'
exit "${PIPESTATUS[0]}"
