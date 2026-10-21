#!/usr/bin/env bash
# Frozen round-26 evidence replay, not a replacement for the historical default.
set -euo pipefail
mode=${1:-}
[[ $mode == before || $mode == after ]] || { printf 'usage: replay-current.sh before|after [frozen-root]\n' >&2; exit 2; }
here=$(dirname -- "$(realpath -- "$0")")
frozen=${2:-"$here/../rearmed"}
frozen=$(realpath -- "$frozen")
if [[ -f $frozen/observe-2.json ]]; then
  manifest_sha=2e4767828f6a0a4083c300fb0399859a03a4b596d3a276fa7052a0ab232719f8
  receipt=observe-2.json
else
  manifest_sha=cbb420c571719bce61d6ddbf64779dda5417d9d201f8fee535e81d8008630361
  receipt=observe-1.json
fi
actual_manifest=$(sha256sum -- "$frozen/inputs.sha256")
if [[ ${actual_manifest%% *} != "$manifest_sha" ]]; then
  printf 'ROUND26_REPLAY: snapshot_tampered\n'
  exit 2
fi
if ! (cd -- "$frozen" && sha256sum --check --quiet inputs.sha256); then
  printf 'ROUND26_REPLAY: snapshot_tampered\n'
  exit 2
fi
receipt_sha=$(sha256sum -- "$frozen/$receipt")
receipt_sha=${receipt_sha%% *}
PYTHONDONTWRITEBYTECODE=1 python3 -B "$frozen/release-clock.py" --root "$frozen/$mode" \
  --receipt "$frozen/$receipt" --receipt-sha "$receipt_sha"
