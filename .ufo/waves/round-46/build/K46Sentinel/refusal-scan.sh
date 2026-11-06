#!/usr/bin/env bash
# Read-only refusal-boundary scan over the round-46 artifact set.
set -u
LANE=/home/vgpnk/Projects/shokunin/kagi-shokunin
OUT=$1
cd "$LANE" || exit 2
{
  echo "# refusal-boundary scan of round-46 artifacts"
  echo "# utc: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "# scope: .ufo/waves/round-46/** + plans/round-46* (regular files)"
  echo "# files: $(find .ufo/waves/round-46 -type f | wc -l) under .ufo/waves/round-46; $(find plans -maxdepth 1 -type f -name 'round-46*' | wc -l) under plans/"
  echo
  echo "## A. literal 'op://' occurrences (context 30 chars each side)"
  grep -rIoE --exclude-dir=K46Sentinel '.{0,30}op://.{0,30}' .ufo/waves/round-46 plans/round-46* 2>/dev/null || echo "(none)"
  echo
  echo "## B. op:// reference-path shape (op://<vault>/<item>)"
  n=$(grep -rIoE --exclude-dir=K46Sentinel 'op://[A-Za-z0-9][A-Za-z0-9_-]*/[A-Za-z0-9]' .ufo/waves/round-46 plans/round-46* 2>/dev/null | wc -l); echo "matches=$n"
  echo
  echo "## C. private keys"
  grep -rInE --exclude-dir=K46Sentinel -- '-----BEGIN [A-Z ]*PRIVATE KEY-----' .ufo/waves/round-46 plans/round-46* 2>/dev/null || echo "(none)"
  echo
  echo "## D. GitHub/AWS/Slack/OpenAI token shapes"
  grep -rInE --exclude-dir=K46Sentinel 'ghp_[A-Za-z0-9]{20,}|gho_[A-Za-z0-9]{20,}|ghu_[A-Za-z0-9]{20,}|ghs_[A-Za-z0-9]{20,}|github_pat_[A-Za-z0-9_]{20,}|AKIA[0-9A-Z]{16}|ASIA[0-9A-Z]{16}|xox[baprs]-[A-Za-z0-9-]{10,}|sk-ant-[A-Za-z0-9_-]{20,}|sk-[A-Za-z0-9]{32,}' .ufo/waves/round-46 plans/round-46* 2>/dev/null || echo "(none)"
  echo
  echo "## E. JWT triple shape"
  grep -rInE --exclude-dir=K46Sentinel 'eyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{5,}' .ufo/waves/round-46 plans/round-46* 2>/dev/null || echo "(none)"
  echo
  echo "## F. credential assignment shapes (field: value / field=value)"
  grep -rInE --exclude-dir=K46Sentinel '(password|passwd|secret|token|cookie|api[_-]?key|apikey|client[_-]?secret|session[_-]?id)[[:space:]]*[:=][[:space:]]*[^[:space:]"]{6,}' .ufo/waves/round-46 plans/round-46* 2>/dev/null || echo "(none)"
  echo
  echo "## G. HTTP auth/cookie headers"
  grep -rInE --exclude-dir=K46Sentinel '(^|[^A-Za-z])(Authorization|Cookie|Set-Cookie|Proxy-Authorization)[[:space:]]*:' .ufo/waves/round-46 plans/round-46* 2>/dev/null || echo "(none)"
  echo
  echo "## H. op/1Password CLI invocations or service-account env"
  grep -rInE --exclude-dir=K46Sentinel '\bop (run|read|item|inject|signin|account|vault)\b|OP_SERVICE_ACCOUNT|op://' .ufo/waves/round-46 plans/round-46* 2>/dev/null | grep -v 'never write an op:// reference path\|vault field or op:// reference path' || echo "(none beyond the quoted rule text)"
  echo
  echo "## I. secret-scheme URLs"
  grep -rInE --exclude-dir=K46Sentinel 'vault://|secret://|sops://|onepassword://' .ufo/waves/round-46 plans/round-46* 2>/dev/null || echo "(none)"
  echo
  echo "## J. receipt JSON urls carrying query or fragment"
  python3 -B - <<'PY'
import json, glob
bad = []
for p in sorted(glob.glob('.ufo/waves/round-46/**/*.json', recursive=True)):
    try:
        doc = json.load(open(p, encoding='utf-8'))
    except (OSError, ValueError):
        continue
    obs = doc.get('observations') if isinstance(doc, dict) else None
    if not isinstance(obs, list):
        continue
    for r in obs:
        u = r.get('url') if isinstance(r, dict) else None
        if isinstance(u, str) and ('?' in u or '#' in u or '@' in u):
            bad.append((p, r.get('id'), u))
print('receipts with observations scanned:', len([x for x in glob.glob('.ufo/waves/round-46/**/*.json', recursive=True) if '/K46Sentinel/' not in x]))
print('urls with query/fragment/userinfo:', bad if bad else '(none)')
PY
  echo
  echo "## K. 1Password account/auth-shaped hosts or paths in any URL"
  grep -rIoE --exclude-dir=K46Sentinel 'https?://[^ ")]*1password[^ ")]*' .ufo/waves/round-46 plans/round-46* 2>/dev/null \
    | grep -E '//(account|app|auth|login|my|signin|sign-in|vault)\.|/(account|accounts|app|auth|login|my|session|sessions|signin|sign-in|vault)(/|$)' \
    || echo "(none)"
  echo
  echo "## L. file modes under the artifact set"
  find .ufo/waves/round-46 -type f -printf '%m %p\n' | sort | uniq -c | sort -rn | head -8
} > "$OUT" 2>&1
