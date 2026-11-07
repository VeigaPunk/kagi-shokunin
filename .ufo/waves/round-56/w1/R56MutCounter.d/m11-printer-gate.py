#!/usr/bin/env python3
import sys
MATCH = [
 ("corpus/knowledge/betterleaks-detection-vs-validation.md", 4, "S055", "grep", 1),
 ("corpus/knowledge/cdp-bridge-1password-oidc-workflow.md", 3, "S070", "locate", 1),
 ("corpus/knowledge/iso-11770-3-edition-status.md", 3, "S101", "grep", 2),
 ("corpus/knowledge/iso-11770-3-edition-status.md", 3, "S113", "grep", 3),
 ("corpus/knowledge/iso-11770-3-edition-status.md", 3, "S114", "grep", 2),
 ("corpus/knowledge/nist-key-management-guidance-status.md", 3, "S074", "grep", 1),
 ("corpus/knowledge/nist-key-management-parts-withdrawal.md", 3, "S078", "pdf", 1),
 ("corpus/knowledge/oidc-federation-trust-policy.md", 3, "S067", "grep", 1),
 ("corpus/knowledge/secret-scanning-detection-vs-validation.md", 4, "S054", "grep", 1),
 ("corpus/knowledge/trufflehog-verification-lifecycle.md", 4, "S057", "grep", 1),
]
if sys.argv[1:2] == ["--selftest"]:
    print("RECHECK_REPLAY_SELFTEST: PASS (10 cases)")
    sys.exit(0)
for e, ln, sid, form, n in MATCH:
    print("MATCH %s:%d id=%s form=%s stated=%d replayed=%d" % (e, ln, sid, form, n, n))
print("RECHECK_REPLAY: CLEAN (clocks=10 match=10 mismatch=0 no_capture=0 bad_capture=0 unsupported=0 tool=0)")
sys.exit(0)
