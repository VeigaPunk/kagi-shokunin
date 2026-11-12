# Kagi: different ports do not isolate cookies

[RFC 2965](https://www.rfc-editor.org/rfc/rfc2965.html), October 2000, section 3.3.4 distinguishes three Port states: absent allows any port; present without a value restricts return to the receiving port; a list restricts return to listed ports. This historical rule concerns Set-Cookie2, not a general browser isolation guarantee.

[RFC 6265](https://www.rfc-editor.org/rfc/rfc6265.html), April 2011, obsoletes that specification and deprecates Cookie2 and Set-Cookie2. Section 8.5 explicitly denies cookie isolation by port for both reading and writing. It discourages using security-sensitive cookies across mutually distrusting services on different ports of one host.

Distinguish a service's listening port from its session boundary. An old Port attribute does not establish that a later mechanism preserves its restriction. Stateful HTTP continues; the isolation contract does not.

Selected sections; no browser testing or deployment claim. Original commentary, no copied examples. Earlier copyright permits conditional explanatory derivatives; later publication-time IETF terms include older-material restrictions and separate code provisions. Unassimilated.

Reviewed 2026-11-11. Destination: VeigaPunk/kagi-shokunin, master, considerthese/2026-11-11-cookie-port-boundary.md.
