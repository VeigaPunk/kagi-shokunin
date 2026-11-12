# Kagi: separate backup state from clone signals

[WebAuthn Level 2](https://www.w3.org/TR/2021/REC-webauthn-2-20210408/), 8 April 2021 Recommendation, §6.1.1, treats a nonincreasing signature counter, when either value is nonzero, as possible cloning or malfunction, not conclusive attribution.

[Level 3](https://www.w3.org/TR/2026/REC-webauthn-3-20260825/), 25 August 2026 Recommendation, §§6.1.1–6.1.3 and 7.2, adds response-order races to that explanation and distinguishes backup eligibility (BE) from current backup state (BS). BE remains fixed; BS can change. BE=1/BS=0 means eligible but not presently backed up; BE=0/BS=1 is invalid. Authenticators without counters report zero.

Review backup transitions separately from counter anomalies. Eligibility alone cannot establish recovery readiness; a counter mismatch cannot identify the offending device. Protocol semantics are not deployment evidence.

Original commentary only. W3C copyright applies; Level 2 links document-use terms, Level 3 permissive terms, both conditional. No execution or assimilation.

Reviewed 2026-11-09. Space hold.

Destination: https://github.com/VeigaPunk/kagi-shokunin, considerthese/2026-11-09-webauthn-backup-counter.md.
