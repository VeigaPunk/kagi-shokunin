"""Negative control: does a LATER feed-row supersession (round-37 pattern S089/S090)
fire the successor on BASE without any table anchor change?
Expected: no — S089/S090 are 90d feeds (not on-release), so evaluate() never
binds them; the fired derived clocks stay fired and the gate cannot see the
successor. Documents why S174/S175 (not S089/S090) had to be recheck=on-release
table re-pins, and that the re-arm is a table action, not an observation action."""
