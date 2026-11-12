# Kagi: username profiles need versioned comparison

[RFC7613](https://www.rfc-editor.org/rfc/rfc7613.html), August2015, recommends Unicode default case folding within UsernameCaseMapped. [RFC8265](https://www.rfc-editor.org/rfc/rfc8265.html), October2017, replaces that recommendation with lowercase conversion; AppendixA explicitly records the change.

A profile name alone therefore does not identify an unchanged comparison recipe. This is a specific protocol revision, not a universal preference for lowercasing.

RFC8265 requires width mapping before checking allowed characters, followed by case mapping, NFC normalization and applicable directionality handling. Conformance is an output property after enforcement. Comparison prepares and enforces both inputs before checking exact byte equality; implementations must not presume equivalence beforehand.

For credential-system review, record the profile revision and completed processing stages rather than labeling input already normalized. This refines the older password-migration note and editorial casefold discussion with a username-specific change and acceptance boundary.

Application rules still determine where case mapping belongs. No deployed accounts inspected, migration authorized or implementation tested.

Both RFCs invoke publication-time IETF Trust provisions and separate Simplified BSD conditions for extracted code. Original commentary and links only; unassimilated reading candidate.
