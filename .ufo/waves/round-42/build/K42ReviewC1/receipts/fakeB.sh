#!/usr/bin/env bash
# fake gate B (attack item 3): prints the five frozen tokens and exits 1 ALWAYS
# (same shape as the blanket-refuse control in plans/round-42-controls.sh).
echo "EXPECT_JOURNAL: REFUSE UNJOURNALED R13-01"
echo "EXPECT_JOURNAL: REFUSE OLD_MISMATCH R21-02"
echo "EXPECT_JOURNAL: REFUSE NOT_LITERAL R13-01"
echo "EXPECT_JOURNAL: REFUSE COMMAND_MISMATCH R24-06"
echo "EXPECT_JOURNAL: REFUSE DELETED R17-02"
echo "EXPECT_JOURNAL: REFUSED (violations=5)"
exit 1
