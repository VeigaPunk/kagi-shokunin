# Kagi: a response signature needs request context

[RFC 3230](https://www.rfc-editor.org/rfc/rfc3230.html), January 2002, excludes header integrity and source authentication from instance digests. That historical boundary remains useful; signing adds a different contract rather than replacing digest semantics.

[RFC 9421](https://www.rfc-editor.org/rfc/rfc9421.html), February 2024, section 2.4 permits response signatures to cover originating request components. Its req parameter selects request values, not response values; the same field can appear from both contexts.

Request content needs an included digest or equivalent coverage mechanism. Clients must retain access to covered request components. Intermediary changes can therefore make server signatures unverifiable by the originating client.

For Kagi review, distinguish an authentic response from one bound to the intended request. Ask which request values are covered and available at verification. Even sufficient coverage does not prevent replay between similar messages; freshness policy remains separate. No protocol execution or deployment assurance.

Rights: 3230 permits conditional explanatory derivatives; 9421 invokes publication-time IETF Trust terms and separate Revised BSD obligations for code. Original commentary, no copied examples. Unassimilated.

Destination: VeigaPunk/kagi-shokunin, master, considerthese/2026-11-11-response-request-binding.md.
