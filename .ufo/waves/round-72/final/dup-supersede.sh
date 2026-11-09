#!/usr/bin/env bash
# lists ids superseded by more than one registry row (two rows claiming the same predecessor)
f=${1:-corpus/SOURCES.md}
grep -E '^ {0,3}\| *S[0-9]{3} ' "$f" | awk -F'|' '{id=$2; gsub(/ /,"",id); t=$8; if (match(t,/supersedes S[0-9]{3}/)) {p=substr(t,RSTART+11,4); n[p]++; w[p]=w[p] " " id}} END {c=0; for (p in n) if (n[p]>1) {print "DUP-SUPERSEDE " p ":" w[p]; c++} print "DUP_SUPERSEDE: " c}'
