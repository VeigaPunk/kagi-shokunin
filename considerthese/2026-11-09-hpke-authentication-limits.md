# Kagi: sender authentication has compromise limits

[RFC 9180](https://www.rfc-editor.org/rfc/rfc9180.txt), February 2022, IRTF Informational, §§5, 9.1–9.1.1: HPKE Base encrypts without authenticating the sender. PSK authenticates possession of a shared secret; Auth uses a sender KEM private key; AuthPSK combines them.

The consequential boundary is recipient compromise. In Auth, exposing the recipient private key can defeat sender authentication even while the sender key remains secret. AuthPSK sender authentication can likewise fail when both recipient key and PSK are compromised. Section 9.1.1 explains why choosing a KEM resistant to impersonation alone does not repair HPKE's composition.

This extends earlier key derivation reading to protocol authentication limits. Before accepting an origin claim, identify the mode and compromised party. It is not a deployment assessment or an Internet Standard; no cryptographic execution performed.

Rights: 2022 IETF Trust and authors; publication-time BCP 78 terms. Original commentary and links only. Unassimilated.

Reviewed 2026-11-09. Space hold.

Destination: https://github.com/VeigaPunk/kagi-shokunin, considerthese/2026-11-09-hpke-authentication-limits.md.
