# Consider these: secret-handling methodology and explicit exposure

Curated 2026-11-03. This is a reading queue for possible consideration after hyaku, not assimilation, training, a capability claim, or permission to access credentials. The existing lane hold remains unchanged. No software was installed or run, and no vault, account, host configuration, or secret material was accessed.

Selection favors primary guidance and small, inspectable mechanisms over broad vault integrations. These two candidates are complementary: a lifecycle checklist and an implementation-level API for limiting accidental disclosure.

## 1. OWASP Secrets Management Cheat Sheet

- **Primary source:** https://cheatsheetseries.owasp.org/cheatsheets/Secrets_Management_Cheat_Sheet.html
- **Why consider it:** Its lifecycle and auditing sections separate creation, rotation, revocation and expiry, while making audit events distinct from secret values. That is useful for designing a vocabulary for synthetic hygiene receipts without needing to retrieve credentials.
- **Possible later use:** Draft a paper-only matrix mapping fake lifecycle events to expected metadata, prohibited value fields and uncertainty labels. Treat operational rotation and access changes as separately authorized actions, not implications of reading the guide.
- **Limit:** General community guidance, not proof that a particular vault or host implements the properties. No account integration is proposed here.
- **Rights:** OWASP Cheat Sheet Series identifies its content as CC BY-SA 4.0 in the [site footer](https://cheatsheetseries.owasp.org/). This note contains original commentary and a link, not a copy of the guide. Reuse of guide text requires its applicable attribution/share-alike terms.

## 2. secrecy: explicit secret access in Rust

- **Repository:** https://github.com/iqlusioninc/crates/tree/main/secrecy
- **Versioned API:** https://docs.rs/secrecy/0.10.3/secrecy/
- **Why consider it:** The SecretBox and ExposeSecret design makes access explicit, redacts ordinary debugging, and uses zeroize on drop. Optional serialization is gated. The small API is useful reference material for reviewing how a fake-value wrapper exposes data.
- **Possible later use:** Review a synthetic-only interface on paper: enumerate intentional exposure points and accidental logging/serialization channels. No installed credential CLI, real value, scan or dependency execution is needed to read the design.
- **Limits:** This is not encryption, a vault, or universal memory protection. The API documentation excludes advanced memory locking and warns about intermediate copies around deserialization. Its 0.10.3 release is dated 2024-10-09; a repository commit touching secrecy was observed on 2026-09-02, so release age and maintenance activity must not be conflated.
- **Rights:** MIT OR Apache-2.0, verified in the [repository README](https://github.com/iqlusioninc/crates/tree/main/secrecy) and [version metadata](https://docs.rs/crate/secrecy/0.10.3). Source code is not vendored here.

## Selection and verification notes

- Checked the eight existing public considerthese files through 2026-10-26. None contains an external URL, so these are not duplicate links in that directory.
- Full corpus/source-registry duplicate checking was intentionally not performed under the lane's existing hold. These remain candidates, not asserted gaps or novel capabilities.
- Primary pages, license declarations and the secrecy path's latest commit were opened on 2026-11-03. Repository observation: [d4994d154abc40b90df5d1bde29ad58280e886f3](https://github.com/iqlusioninc/crates/commit/d4994d154abc40b90df5d1bde29ad58280e886f3).
- Keep attribution, software licensing, permission to execute, and permission to handle real credentials separate. No permission is broadened by this reading list.
