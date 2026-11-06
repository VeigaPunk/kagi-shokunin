#!/bin/bash
REF=/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-48/controls/fixtures/ref-sops-age-trial.sh
bash "$REF" "$@" | grep -v '^SOPS_AGE_TRIAL: '
exit "${PIPESTATUS[0]}"
