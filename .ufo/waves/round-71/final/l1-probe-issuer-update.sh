set -u; umask 077; export HOME=$(mktemp -d "${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r71/h.XXXX")
tok=r71dbg$RANDOM$RANDOM; port=18271
BAO_DEV_ROOT_TOKEN_ID=$tok setpriv --pdeathsig KILL bao server -dev -dev-listen-address=127.0.0.1:$port -dev-no-store-token >/dev/null 2>&1 & SP=$!
trap 'kill $SP; rm -rf $HOME' EXIT
export BAO_ADDR=http://127.0.0.1:$port BAO_TOKEN=$tok; sleep 2
bao secrets enable pki >/dev/null; bao secrets tune -max-lease-ttl=87600h pki >/dev/null
bao write pki/root/generate/internal common_name=root.r71.test ttl=87600h issuer_name=r71root >/dev/null
bao write pki/config/issuers default=r71root >/dev/null
bao write pki/root/generate/internal common_name=short.r71.test ttl=2h issuer_name=r71short >/dev/null
bao read -format=json pki/issuer/r71short | python3 -c 'import json,sys;d=json.load(sys.stdin)["data"];print({k:d[k] for k in ("issuer_name","leaf_not_after_behavior","usage")})'
ID=$(bao read -field=issuer_id pki/issuer/r71short)
bao write -format=json pki/issuer/r71short leaf_not_after_behavior=truncate | python3 -c 'import json,sys;d=json.load(sys.stdin)["data"];print("after-write",{k:d[k] for k in ("issuer_name","leaf_not_after_behavior","usage")})'
bao read -format=json pki/issuer/$ID | python3 -c 'import json,sys;d=json.load(sys.stdin)["data"];print("by-id",{k:d[k] for k in ("issuer_name","leaf_not_after_behavior","usage")})'
echo "read-by-name-after-write: $(bao read pki/issuer/r71short 2>&1 | grep -o "unable to find PKI issuer for reference: r71short" || echo found)"
bao patch -format=json pki/issuer/$ID issuer_name=r71short >/dev/null && echo patched
bao read -format=json pki/issuer/r71short | python3 -c 'import json,sys;d=json.load(sys.stdin)["data"];print({k:d[k] for k in ("issuer_name","leaf_not_after_behavior","usage")})'
bao write pki/roles/t6 allowed_domains=r71.test allow_subdomains=true max_ttl=24h >/dev/null
bao write -format=json pki/issuer/r71short/issue/t6 common_name=t.r71.test ttl=10h 2>&1 | grep -v '"certificate\|private_key\|issuing_ca\|ca_chain' | head -20
