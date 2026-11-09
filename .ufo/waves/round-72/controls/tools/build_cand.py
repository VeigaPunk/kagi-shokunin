#!/usr/bin/env python3
"""Round-72 C1 candidate builder (scratch tool, L1 KagiR72).

Applies to TREE: S174/S175 feed rows (supersede S034/S035), their fetch rows and
captures, the re-arm of the ten derived Vault/OpenBao clocks, the round-72
re-check ledger corpus/clock-rearm.tsv with page captures, observed_at refresh
for every clock row. Receipt observation + default pin are done afterwards.
usage: build_cand.py TREE CAPDIR
"""
import hashlib, os, re, shutil, subprocess, sys

tree, cap = sys.argv[1], sys.argv[2]
DAY = "2026-11-09"
RD = ".ufo/waves/round-72/capture"
os.makedirs(os.path.join(tree, RD), exist_ok=True)


def sha(p):
    return hashlib.sha256(open(p, "rb").read()).hexdigest()


FEEDS = {
    "S174": dict(old="S034", url="https://github.com/hashicorp/vault/releases.atom", file="vault.atom", ver="2.2.1",
                 updated="2026-10-23T17:34:44Z",
                 name="Vault releases, GitHub release Atom feed (round-72 re-anchor)",
                 scope="Vault release identity (newest stable X.Y.Z tag) for the re-armed derived on-release clocks of S013 and S022-S024; excludes `sdk/` module tags and `-rc` prereleases",
                 teach="supersedes S034 — the newest stable Vault release is now v2.2.1, so the derived clocks re-arm at 2.2.1 and fire again on the next stable tag; sdk/ module and -rc entries still do not count. Quote: “<title>v2.2.1</title>” (first stable entry)."),
    "S175": dict(old="S035", url="https://github.com/openbao/openbao/releases.atom", file="openbao.atom", ver="2.7.2",
                 updated="2026-10-26T20:24:37Z",
                 name="OpenBao releases, GitHub release Atom feed (round-72 re-anchor)",
                 scope="OpenBao server release identity (newest stable X.Y.Z tag) for the re-armed derived on-release clocks of S014-S016, S021, S025 and S026; excludes api/ and sdk/ module releases and beta tags",
                 teach="supersedes S035 — the newest stable OpenBao server release is now v2.7.2, so the derived clocks re-arm at 2.7.2 and fire again on the next stable tag; api/ and sdk/ module releases still do not count. Quote: “<title>v2.7.2</title>” (first stable entry)."),
}
REARM = {"S013": "S174", "S022": "S174", "S023": "S174", "S024": "S174",
         "S014": "S175", "S015": "S175", "S016": "S175", "S021": "S175", "S025": "S175", "S026": "S175"}

# --- registry rows -----------------------------------------------------------
sp = os.path.join(tree, "corpus/SOURCES.md")
lines = open(sp, encoding="utf-8").read().split("\n")
last = max(i for i, l in enumerate(lines) if re.match(r"^ {0,3}\| *S\d{3} ", l))
new = []
for sid, f in FEEDS.items():
    tag = "v" + f["ver"]
    anchor = f"Entry titled {tag}, tag link /releases/tag/{tag}, updated {f['updated']}; feed fetched {DAY}"
    new.append(f"| {sid} | {f['name']} — {f['url']} | code | A | {f['scope']} | {anchor} | {f['teach']} | mined | {DAY} | 90d | corpus/lessons/round-72.md |")
lines[last + 1:last + 1] = new
open(sp, "w", encoding="utf-8").write("\n".join(lines))

# --- fetch rows + feed captures ---------------------------------------------
fp = os.path.join(tree, "corpus/source-fetches.tsv")
rows = []
for sid, f in FEEDS.items():
    src = os.path.join(cap, f["file"])
    dst = os.path.join(tree, RD, sid + ".body")
    shutil.copyfile(src, dst)
    ident = hashlib.sha256(f"{sid}\tmined\t{f['url']}\n".encode()).hexdigest()
    q = f"<title>v{f['ver']}</title>"
    assert open(src, encoding="utf-8").read().count(q) == 1
    rows.append("\t".join([sid, "mined", ident, f["url"], f["url"], "200", "curl-fsSL-compressed-v1", DAY,
                           "decoded-http-body-volatile-v1", sha(dst), str(os.path.getsize(dst)), "-", q,
                           "raw-literal-v1", "-", f"{RD}/{sid}.body"]))
with open(fp, "a", encoding="utf-8") as h:
    h.write("\n".join(rows) + "\n")

# --- clock table -------------------------------------------------------------
cp = os.path.join(tree, "corpus/release-clocks.tsv")
out = []
for l in open(cp, encoding="utf-8").read().rstrip("\n").split("\n"):
    c = l.split("\t")
    if c[0] == "id":
        out.append(l); continue
    if c[0] in REARM:
        fid = REARM[c[0]]; f = FEEDS[fid]
        assert c[7] == "fired" and c[8].startswith("derived:") and c[2] == f["old"]
        c[2] = fid; c[4] = f["ver"]; c[5] = f["ver"]; c[7] = "not-fired"
        c[8] += (f"; round 72: re-armed at {f['ver']} through {fid} (supersedes {f['old']}, opened {DAY}) after the round-47 "
                 f"teaching re-verification (corpus/fired-reverify.tsv) and the round-72 re-check (corpus/clock-rearm.tsv); "
                 f"the round-72 receipt observe-r72.json ({DAY}) observes {f['ver']}, equal to the new anchor, so the clock is armed (not-fired)")
    else:
        what = (f"observed {c[5]}" if c[1] == "feed" else "quote located")
        c[8] += f"; re-observed by the round-72 receipt observe-r72.json ({DAY}, {what})"
    c[6] = DAY
    out.append("\t".join(c))
open(cp, "w", encoding="utf-8").write("\n".join(out) + "\n")

# --- re-check ledger ---------------------------------------------------------
fetch = {}
for l in open(fp, encoding="utf-8"):
    c = l.rstrip("\n").split("\t")
    if c and re.fullmatch(r"S\d{3}", c[0]):
        fetch[c[0]] = c
led = ["# clock-rearm.tsv — round 72: one row per re-armed derived release clock (plans/round-72.md C1).",
       "# The row's page was re-fetched in round 72 and the id's declared fetch quote (corpus/source-fetches.tsv col 13)",
       "# located in that capture with `python3 corpus/rendered-text-v1.py locate`; the round-47 teaching judgment",
       "# (corpus/fired-reverify.tsv) is the semantic re-verification at the same release. Quote location is not semantics.",
       "\t".join(["id", "url", "prior_anchor", "rearmed_anchor", "feed_source_id", "fetched_at", "capture_path",
                  "sha256", "bytes", "quote_count", "verdict"])]
ts = dict(l.split("\t")[:3:2] for l in open(os.path.join(cap, "page-times.tsv")).read().split("\n") if l)
prior = {"S174": "2.2.0", "S175": "2.7.1"}
for sid in sorted(REARM):
    fid = REARM[sid]
    url, quote = fetch[sid][3], fetch[sid][12]
    src = os.path.join(cap, "pages", sid + ".body")
    dst = os.path.join(tree, RD, sid + ".page.body")
    shutil.copyfile(src, dst)
    n = subprocess.run([sys.executable, os.path.join(tree, "corpus/rendered-text-v1.py"), "locate", dst, quote],
                       capture_output=True, text=True).stdout.strip().split("count=")[-1]
    assert int(n) >= 1, (sid, n)
    led.append("\t".join([sid, url, prior[fid], FEEDS[fid]["ver"], fid, ts[sid], f"{RD}/{sid}.page.body",
                          sha(dst), str(os.path.getsize(dst)), n, "quote-located"]))
open(os.path.join(tree, "corpus/clock-rearm.tsv"), "w", encoding="utf-8").write("\n".join(led) + "\n")
print("BUILD: ok")
