#!/usr/bin/env bash
echo "CONTROL C2-F6 expect=killed=0 mismatch observed=killed=5 population=5 verdict=mismatch"
echo "CONTROL C1-F8 expect=accepted=10 rejected=6 observed=accepted=0 rejected=0 verdict=mismatch"
echo "CONTROLS: match=0 mismatch=2"
exit 1
