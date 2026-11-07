#!/usr/bin/env bash
# Build C2 attack fixture trees from the shape-keyed stub.
set -eu
S=/fast/scratch/hyaku/kagi-r59/R59ReviewerCounters
STUB=$S/stub-trial.sh
mk() { # NAME
  rm -rf "$S/trees/$1"
  mkdir -p "$S/trees/$1/corpus"
  cp "$STUB" "$S/trees/$1/corpus/openbao-transit-trial.sh"
}
# A2: SH3 flips T3 AND T4 (a shim that flips two tests)
mk a2_twoflips
sed -i 's/  SH3) vec=HHBHH ;;/  SH3) vec=HHBBH ;;/' "$S/trees/a2_twoflips/corpus/openbao-transit-trial.sh"
# A3: duplicate T1 line
mk a3_dup
sed -i 's|^i=1$|echo "TRIAL T1 HOLDS duplicate"; i=1|' "$S/trees/a3_dup/corpus/openbao-transit-trial.sh"
# A4: no CLEANROOM line
mk a4_noclean
sed -i 's|^echo "TRIAL CLEANROOM HOLDS stub: no second server started"$|: cleanroom omitted|' "$S/trees/a4_noclean/corpus/openbao-transit-trial.sh"
# A5: absolute path with NO command -v gate (PATH bypass not even attempted)
mk a5_absnogate
sed -i '/^if ! command -v bao >\/dev\/null 2>&1; then$/,/^fi$/c\:' "$S/trees/a5_absnogate/corpus/openbao-transit-trial.sh"
# A6: a token-shaped string in output (secret scan must bite). The prefix is
# assembled at runtime so this receipt carries no contiguous token shape.
mk a6_token
TOKPREFIX="h""v""s""."
sed -i "s|^echo \"TRIAL CLEANROOM HOLDS stub: no second server started\"\$|echo \"TRIAL CLEANROOM HOLDS token ${TOKPREFIX}CIYyMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAw\"|" "$S/trees/a6_token/corpus/openbao-transit-trial.sh"
# A7: an r59- + 24-hex nonce in output (secret scan must bite). The body is
# assembled from two halves so this receipt carries no contiguous nonce shape.
mk a7_nonce
NONCE="r59-""0123456789abcdef""01234567"
sed -i "s|^echo \"TRIAL CLEANROOM HOLDS stub: no second server started\"\$|echo \"TRIAL CLEANROOM HOLDS nonce ${NONCE}\"|" "$S/trees/a7_nonce/corpus/openbao-transit-trial.sh"
# A8: T3 ERROR in the real run
mk a8_error
sed -i 's|^  if \[ "$ch" = H \]; then$|  if [ "$ch" = H ] \&\& [ "$i" != 3 ]; then|' "$S/trees/a8_error/corpus/openbao-transit-trial.sh"
echo built
# C2 baseline and line-parsing variants (B01/B04/B09/B10)
mk c2_stub
mk c2_sumjunk
sed -i 's|echo "OPENBAO_TRANSIT_TRIAL: HOLDS holds=5 broken=0 error=0 bao=v2.7.2"|echo "OPENBAO_TRANSIT_TRIAL: HOLDS holds=5 broken=0 error=0 error=1 bao=v2.7.2"|' "$S/trees/c2_sumjunk/corpus/openbao-transit-trial.sh"
mk c2_sumdup
sed -i 's|echo "OPENBAO_TRANSIT_TRIAL: HOLDS holds=5 broken=0 error=0 bao=v2.7.2"|echo "OPENBAO_TRANSIT_TRIAL: HOLDS holds=5 broken=0 error=0 bao=v2.7.2"; echo "OPENBAO_TRANSIT_TRIAL: BROKEN holds=0 broken=5 error=0 bao=v2.7.2"|' "$S/trees/c2_sumdup/corpus/openbao-transit-trial.sh"
mk c2_dupcr
sed -i 's|echo "TRIAL CLEANROOM HOLDS stub: no second server started"|echo "TRIAL CLEANROOM HOLDS a"; echo "TRIAL CLEANROOM HOLDS b"|' "$S/trees/c2_dupcr/corpus/openbao-transit-trial.sh"
echo c2variants-built
