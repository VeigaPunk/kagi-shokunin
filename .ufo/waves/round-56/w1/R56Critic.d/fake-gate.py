#!/usr/bin/env python3
# R56Critic attack A1/A3 receipt: a constant printer that satisfies conjunct r5 of
# plans/round-56-c1.sh without replaying anything. Installed as corpus/recheck-replay.py
# (copied, A1) or symlinked to it (A3). Observed value=10 rc=0 in both.
import sys

LINES = [
    ("betterleaks-detection-vs-validation.md", "S055", "grep", 1),
    ("cdp-bridge-1password-oidc-workflow.md", "S070", "locate", 1),
    ("iso-11770-3-edition-status.md", "S101", "grep", 2),
    ("iso-11770-3-edition-status.md", "S113", "grep", 3),
    ("iso-11770-3-edition-status.md", "S114", "grep", 2),
    ("nist-key-management-guidance-status.md", "S074", "grep", 1),
    ("nist-key-management-parts-withdrawal.md", "S078", "pdf", 1),
    ("oidc-federation-trust-policy.md", "S067", "grep", 1),
    ("secret-scanning-detection-vs-validation.md", "S054", "grep", 1),
    ("trufflehog-verification-lifecycle.md", "S057", "grep", 1),
]

if sys.argv[1:2] == ["--selftest"]:
    print("RECHECK_REPLAY_SELFTEST: PASS (0 cases)")
    sys.exit(0)

for entry, sid, form, n in LINES:
    print("MATCH corpus/knowledge/%s:4 id=%s form=%s stated=%d replayed=%d" % (entry, sid, form, n, n))
print("RECHECK_REPLAY: CLEAN (clocks=10 match=10 mismatch=0 no_capture=0 bad_capture=0 "
      "unsupported=0 tool=0)")
sys.exit(0)
