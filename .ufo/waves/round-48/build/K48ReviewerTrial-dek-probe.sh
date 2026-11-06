#!/usr/bin/env bash
# K48ReviewerTrial-dek-probe.sh — soundness receipt for trial tests T1/T2.
# Question: is "data key not rotated" (T1) / "a new data key" (T2) correctly inferred from
# value-ciphertext/MAC identity/change? This probe unwraps the per-file data key itself
# (age-decrypts the sops.age[].enc block) and hashes it across updatekeys and rotate.
# Never prints a private key or the data key — only sha256 prefixes and public recipients.
# Usage: bash K48ReviewerTrial-dek-probe.sh   (self-contained; scratch removed on exit)
set -u
S=$(mktemp -d "${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r48/K48ReviewerTrial/dekprobe.XXXXXX") || exit 9
trap 'rm -rf -- "$S"' EXIT
export HOME="$S/home" XDG_CONFIG_HOME="$S/home/.config" SOPS_DISABLE_VERSION_CHECK=1
export PATH="/home/vgpnk/.local/bin:/usr/bin:/bin"
mkdir -p "$HOME" "$S/d" || exit 9
cd "$S/d" || exit 9
BIN=/home/vgpnk/.local/bin
"$BIN/age-keygen" -o a.key >/dev/null 2>&1 || exit 9
"$BIN/age-keygen" -o b.key >/dev/null 2>&1 || exit 9
A=$("$BIN/age-keygen" -y a.key) || exit 9
B=$("$BIN/age-keygen" -y b.key) || exit 9
printf 'k1: synthetic-trial-value-one\nk2: synthetic-trial-value-two\n' > plain.yaml
sops encrypt --age "$A" --filename-override f.yaml plain.yaml > f.yaml 2>/dev/null || exit 9

cat > snap.py <<'PY'
import re, sys, json, base64, hashlib, subprocess
path, keyfile = sys.argv[1], sys.argv[2]
lines = open(path).read().splitlines()
out = {"recipients": [], "meta": {}}
i = 0
while i < len(lines):
    m2 = re.match(r'(\s*)(?:- )?enc: \|', lines[i])
    if m2:
        ind = len(m2.group(1))
        keycol = ind + (2 if lines[i].lstrip().startswith('- ') else 0)
        content_ind = None; blk = []; k = i + 1
        while k < len(lines):
            s = lines[k]
            if s.strip() == '':
                k += 1; continue
            cur = len(s) - len(s.lstrip(' '))
            if cur <= keycol: break
            if content_ind is None: content_ind = cur
            blk.append(s[content_ind:]); k += 1
        recip = None
        for s in lines[k:]:
            mr = re.match(r'\s*recipient: (\S+)', s)
            if mr:
                recip = mr.group(1); break
        armor = '\n'.join(blk) + '\n'
        dek = subprocess.run(['/home/vgpnk/.local/bin/age', '-d', '-i', keyfile],
                             input=armor.encode(), capture_output=True)
        out["recipients"].append({
            "recipient": recip,
            "enc_sha256_16": hashlib.sha256(armor.encode()).hexdigest()[:16],
            "enc_len": len(armor),
            "dek_unwraps": dek.returncode == 0,
            "dek_sha256_16": hashlib.sha256(dek.stdout).hexdigest()[:16] if dek.returncode == 0 else None})
        i = k; continue
    mm = re.match(r'\s*(lastmodified|nonce|mac): (.*)$', lines[i])
    if mm:
        name, val = mm.group(1), mm.group(2)
        out["meta"][name] = val.strip() if name == "lastmodified" else hashlib.sha256(lines[i].encode()).hexdigest()[:16] + " (line-hash)"
    i += 1
print(json.dumps(out, indent=1))
PY

snap() { python3 snap.py f.yaml "$S/d/$1"; }

echo "== snapshot 1: after encrypt to A =="
snap a.key
printf 'creation_rules:\n  - path_regex: f\\.yaml$\n    age: "%s,%s"\n' "$A" "$B" > .sops.yaml
SOPS_AGE_KEY_FILE="$S/d/a.key" sops updatekeys -y f.yaml >/dev/null 2>&1
echo "updatekeys rc=$?"
echo "== snapshot 2: after updatekeys adding B =="
snap a.key
SOPS_AGE_KEY_FILE="$S/d/a.key" sops rotate -i f.yaml >/dev/null 2>&1
echo "rotate rc=$?"
echo "== snapshot 3: after rotate -i =="
snap a.key
echo "== sops decrypt --extract 'k1' after rotate (synthetic value) =="
SOPS_AGE_KEY_FILE="$S/d/a.key" sops decrypt --extract '["k1"]' f.yaml 2>/dev/null
echo "extract rc=$?"
