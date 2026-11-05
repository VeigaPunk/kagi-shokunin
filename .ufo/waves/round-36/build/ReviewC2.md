# ReviewC2 — C2 freshness, kagi round 36 (trailer-path copy)

Full raw outputs: `.ufo/waves/round-36/build/ReviewC2/review.md`. Same content as
`.ufo/waves/round-36/build/ReviewC2/report.md`.

**Verdict: ADMIT-WITH-CONDITIONS** (lane working-tree bytes). **REJECT** the literal F3
(only the 15 drifting rows re-dated): counter 0, but `release-clock.py` FAILED on 15
RECEIPT-MISMATCH rows (S005–S011, S017–S020, S029–S032, unchanged rows whose `observed_at`
the literal F3 leaves at 2026-10-21).

- Round-26 receipt: unchanged, blob `e02f4de…`, sha256 `13b8540c…`, commit `d30c989`;
  superseded, not rewritten; still CLEAN against its own table at BASE.
- Round-36 receipt: gate output. A live `--observe` re-run reproduces all 30 records
  field-for-field, including all 30 body sha256 values.
- Lane WT: counter `0` rc=0; verify `CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=15 derived=15)` rc=0.
  It re-dates 15 extra unchanged rows: a scope widening the lesson must disclose.
- Forgery: above/below/empty/removed/hand-edit controls behave as specified. Co-editing
  receipt and table reads counter 0 (forgeF); only the sha-pinned verify catches it.
- Conditions: disclose the 15 extra re-dated rows with old/new values in the lesson;
  claim C2 by verify CLEAN plus the sha pin, not by the counter alone; keep the round-26
  receipt committed.
