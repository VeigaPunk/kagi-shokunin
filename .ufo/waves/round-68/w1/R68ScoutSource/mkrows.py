#!/usr/bin/env python3
"""Emit the exact drafted S167 rows and check their contract shape.

Checks (contract v1, CORPUS.md "SOURCES.md — where a shokunin learns"):
  SOURCES.md row  -- 11 columns, no literal '|' inside any cell,
                     id is S###, kind/tier/status in the frozen enums,
                     opened is an ISO date, recheck is a valid cadence.
  source-fetches.tsv row -- 16 tab-separated columns, col 3 is the
                     row-identity digest the gate recomputes, col 13 is a
                     <=25-word quote, col 14 names a declared normalization,
                     col 15 is a 64-hex digest (or '-'), col 16 is the pure
                     capture path.
"""
import hashlib
import re
import subprocess
import sys

LANE = "/home/vgpnk/Projects/shokunin/kagi-shokunin"
NORM = LANE + "/corpus/rendered-text-v1.py"
BODY = LANE + "/.ufo/waves/round-68/capture/S167.body"

URL = "https://www.rfc-editor.org/rfc/rfc4648.txt"
FINAL_URL = URL
FETCHED = "2026-11-08"
HTTP = "200"
PROFILE = "curl-fsSL-compressed-v1"
REPRESENTATION = "decoded-http-body-v1"
REVISION = "-"
NORM_NAME = "rendered-text-v1"
LOC_PATH = ".ufo/waves/round-68/capture/S167.body"

QUOTE = ("Implementations MUST reject the encoded data if it contains "
         "characters outside the base alphabet when interpreting base-encoded data")

raw = open(BODY, "rb").read()
raw_sha = hashlib.sha256(raw).hexdigest()
nbytes = len(raw)
d = subprocess.run([sys.executable, NORM, "digest", BODY],
                   capture_output=True, text=True).stdout
norm_sha = re.search(r"normalized_sha256=([0-9a-f]{64})", d).group(1)
norm_bytes = int(re.search(r"normalized_bytes=(\d+)", d).group(1))
loc = subprocess.run([sys.executable, NORM, "locate", BODY, QUOTE],
                     capture_output=True, text=True).stdout
count = int(re.search(r"count=(\d+)", loc).group(1))
row_id_digest = hashlib.sha256(
    ("S167\tmined\t%s\n" % URL).encode()).hexdigest()

# ---------------------------------------------------------------- SOURCES.md
anchor = ("§3.3 Interpretation of Non-Alphabet Characters in Encoded Data "
          "(RFC 4648, October 2006; heading at body line 190, the MUST "
          "sentence at body lines 200-204); capture `%s` (%d B, sha256 `%s`); "
          "opened live %s with a browser user agent (HTTP %s, %d B, same "
          "sha256, refetch byte-identical; receipt "
          "`.ufo/waves/round-68/capture/S167.fetch.txt`; quote locate "
          "count=%d under rendered-text-v1; normalized sha256 `%s`, %d "
          "normalized bytes)" % (LOC_PATH, nbytes, raw_sha, FETCHED, HTTP,
                                  nbytes, count, norm_sha, norm_bytes))
teaches = ("a field with a declared alphabet is accepted in that exact form "
           "or refused, never read past: RFC 4648 §3.3 makes rejecting "
           "characters outside the base alphabet a MUST for an implementation "
           "interpreting base-encoded data, names stray CRLF as non-alphabet "
           "characters, and records that tolerating them has been used to "
           "exploit implementation errors (buffer overflow), so the lane's "
           "census refuses a location cell carrying a stray byte instead of "
           "normalising it away. Quote (verbatim): \"%s\"" % QUOTE)
sources_row = (
    "| S167 | RFC 4648 — The Base16, Base32, and Base64 Data Encodings — "
    "https://www.rfc-editor.org/rfc/rfc4648.txt | spec | A | "
    "record-level strictness: a field carrying structured data is accepted in "
    "its exact declared form or the record is refused; characters outside the "
    "declared alphabet are never silently normalised away, and the "
    "non-alphabet tolerance is a named implementation-error vector | " +
    anchor + " | " + teaches +
    " | mined | 2026-11-08 | 180d | corpus/knowledge/source-capture-binding.md |")

# ---------------------------------------------------------- source-fetches.tsv
fetch_row = "\t".join([
    "S167", "mined", row_id_digest, URL, FINAL_URL, HTTP, PROFILE, FETCHED,
    REPRESENTATION, raw_sha, str(nbytes), REVISION, QUOTE, NORM_NAME,
    norm_sha, LOC_PATH,
])

# ------------------------------------------------------------------- checks
fail = []


def check(cond, msg):
    print("%-4s %s" % ("OK" if cond else "FAIL", msg))
    if not cond:
        fail.append(msg)


cells = sources_row.split("|")
# A leading '|' makes cells[0] the empty prefix and cells[12] the empty suffix.
# The gate's own awk (NF==13) reads $2=id $4=kind $5=tier $8=teaches $9=status
# $10=opened $11=recheck $12=used-by, i.e. cells[k+1]; the checks below use the
# same offset so they measure what the gate measures.
check(len(cells) == 13, "SOURCES.md row splits into 11 cells (NF=13): got %d" % len(cells))
check(sources_row.count("|") == 12, "SOURCES.md row has exactly 12 '|'")
check(cells[1].strip() == "S167", "id cell ($2) is S167")
check(cells[3].strip() == "spec", "kind enum ($4): spec")
check(cells[4].strip() == "A", "tier enum ($5): A")
check(cells[8].strip() == "mined", "status enum ($9): mined")
check(re.fullmatch(r"\d{4}-\d{2}-\d{2}", cells[9].strip()) is not None,
      "opened ($10) is an ISO date: %s" % cells[9].strip())
check(re.fullmatch(r"(\d+d|on-release|\d{4}-\d{2}-\d{2})", cells[10].strip()) is not None,
      "recheck ($11) is a valid cadence: %s" % cells[10].strip())
check(cells[11].strip() == "corpus/knowledge/source-capture-binding.md",
      "used-by ($12) names the lane knowledge entry")
for i, c in enumerate(cells[1:12], start=1):
    check("|" not in c, "no literal '|' inside cell %d" % i)

f = fetch_row.split("\t")
check(len(f) == 16, "fetch row has 16 tab columns: got %d" % len(f))
check(f[0] == "S167" and f[1] == "mined", "fetch row id/status")
check(f[2] == row_id_digest, "fetch col 3 is the row-identity digest")
check(f[3] == URL and f[4] == FINAL_URL, "fetch url + final url")
check(f[5] == HTTP and f[6] == PROFILE, "fetch http status + request profile")
check(re.fullmatch(r"\d{4}-\d{2}-\d{2}", f[7]) is not None, "fetch fetched date")
check(f[8] == REPRESENTATION, "fetch representation")
check(f[9] == raw_sha, "fetch col 10 is the capture's raw sha256")
check(f[10] == str(nbytes), "fetch col 11 is the capture's byte count")
check(f[12] == QUOTE and len(QUOTE.split()) <= 25,
      "fetch col 13 is the quote and <=25 words (%d)" % len(QUOTE.split()))
check(f[13] == NORM_NAME, "fetch col 14 declares the normalization")
check(re.fullmatch(r"[0-9a-f]{64}", f[14]) is not None, "fetch col 15 is a 64-hex digest")
check(f[15] == LOC_PATH and len(f[15].split()) == 1,
      "fetch col 16 is the pure capture path (one whitespace-delimited token)")
check(count >= 1, "quote locates count>=1 under %s: count=%d" % (NORM_NAME, count))

print()
print("=== DRAFTED corpus/SOURCES.md row ===")
print(sources_row)
print()
print("=== DRAFTED corpus/source-fetches.tsv row (tabs shown as <TAB>) ===")
print(fetch_row.replace("\t", "<TAB>"))
print()
print("FAILURES: %d" % len(fail))
sys.exit(1 if fail else 0)
