# C3 index drafts — `corpus/README.md` and `PROVINCE.md`

Every line below is exact paste-ready text. Nothing here was applied to production
by this seat; the L1 is the sole integration writer.

## 1. `corpus/README.md` — coverage-map row (one row, three entry paths)

Placement: in the `## Coverage map` table, in the same block as the other
S-row-backed knowledge areas (after the `| Knowledge-entry declarations (data) |`
row). One row, three paths, matching the multi-path rows already in that table
(the `| Credential-hygiene checklist, executed (gate + data) |` row and the
`Knowledge-entry declarations (data)` row both cite more than one path).

```markdown
| Secret-scanning detection versus verification (entries, round 30) | `corpus/knowledge/secret-scanning-detection-vs-validation.md`, `corpus/knowledge/betterleaks-detection-vs-validation.md`, `corpus/knowledge/trufflehog-verification-lifecycle.md` | admitted from the staged campaign package with per-entry gates; registry rows S053–S060, every source re-opened 2026-11-03 (`.ufo/waves/round-30/final/c3/src-open/`); the Betterleaks entry's CEL clause was refused as staged and removed |
```

### Index rows for the three new knowledge entries (three separate rows)

`corpus/README.md` is the corpus index and already carries one row per knowledge
entry (`| Machine credential custody boundaries |`, `| SOPS age recipient and
data-key rotation |`, `| Vault/OpenBao auth, token, and lease lifecycle |`).
The three new entries are indexable the same way, one row each, placed next to
the round-21 area rows they extend:

```markdown
| Secret-scanning detection versus verification | `knowledge/secret-scanning-detection-vs-validation.md` | Gitleaks/TruffleHog detection is a pattern match while validation is a live check; `unknown` is not a clean scan (SOURCES.md S053–S054; re-opened 2026-11-03) |
| Betterleaks stage-tagged findings | `knowledge/betterleaks-detection-vs-validation.md` | detection by default, validation and analysis opt-in; a finding is a tuple (rule, stage, score), not a verdict (SOURCES.md S055–S056; re-opened 2026-11-03) |
| TruffleHog verification lifecycle | `knowledge/trufflehog-verification-lifecycle.md` | verification caching, read-only safety, integration-scoped re-verification, and notification as a separate decision (SOURCES.md S057–S060; re-opened 2026-11-03) |
```

## 2. `corpus/README.md` — `## Frontier` bullet

Current bullet (under "Areas being explored, not held as lane knowledge"):

```markdown
- **Secret scanning: detection versus verification** — adjacent to the hygiene tripwires in chousa, kasegi, and kumitate; see `SOURCES.md` §Leads (unopened), Gitleaks/Betterleaks and TruffleHog.
```

Replacement (the lead is now admitted knowledge; the OIDC and NIST bullets stay
untouched, and the Gitleaks/Betterleaks/TruffleHog leads are opened, so the
"§Leads (unopened)" pointer is no longer true for them):

```markdown
- **Secret scanning: detection versus verification** — moved to core in round 30 (S053–S060; `knowledge/secret-scanning-detection-vs-validation.md`, `knowledge/betterleaks-detection-vs-validation.md`, `knowledge/trufflehog-verification-lifecycle.md`); adjacent to the hygiene tripwires in chousa, kasegi, and kumitate.
```

## 3. `PROVINCE.md` — Core bullet addition

Placement: in the `## Core / Frontier / Adjacent (round 21)` section, as a new
bullet directly after the existing round-21 `**Core — documented knowledge…**`
bullet and before the `**Frontier — explored, not held:**` bullet.

```markdown
- **Core, round 30 — secret scanning, detection versus verification:** the Gitleaks, TruffleHog and Betterleaks tool documentation and the TruffleHog verification-lifecycle vendor pages (`knowledge/secret-scanning-detection-vs-validation.md`, `knowledge/betterleaks-detection-vs-validation.md`, `knowledge/trufflehog-verification-lifecycle.md`; rows S053–S060 in `corpus/SOURCES.md`, every source re-opened 2026-11-03). Moved from the frontier list in round 30 by the §10 assimilation; no sibling claims this ground (round-30 connector sweep). The frontier bullet below keeps its history.
```

## 4. `corpus/SOURCES.md` — lead disposition (recommended, not required by the plan text)

`## Leads (unopened)` still lists the now-opened Gitleaks/Betterleaks and
TruffleHog leads as "leads only, not evidence". Round 28 and round 23 each closed
their opened lead with a dated disposition paragraph in the same section. The
equivalent paragraph for round 30 (place after the round-28 disposition paragraph):

```markdown
Round-30 lead disposition (2026-11-03): the secret-scanning lead is opened as
S053–S060 — Gitleaks and TruffleHog READMEs, the Betterleaks README, the
Betterleaks repository record and the TruffleHog verification-lifecycle vendor
pages (S053–S060; the GitHub validity-check page S048 stays as held ground).
The OIDC and NIST frontier bullets are untouched. No existing status/recheck/
used-by field changed.
```
