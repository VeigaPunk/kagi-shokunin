# R59ExecCounterC2 notes

counter: plans/round-59-c2.sh
counter sha256: 9bc3da958b665cd7359cd1697890d1126936ba30185234ef6f9fa6199e331f8d
reference fixture trial sha256: 46ddd9ef6a1f5fa95eadf0e33f55021139b70a1d043a05f3320bd3844530a321

The wave's real trial corpus/openbao-transit-trial.sh is not on disk at BASE
or in the working tree at counter-freeze time; corpus/openbao-transit-trial.sh
was measured against the plans/round-59.md sec C2 + A2 printed contract (locked
with seat R59ExecTrial), using reference-trial.sh.txt as the candidate-tree
payload. value=5 in receipt-candidate.txt is a contract reading, not a reading
of the wave's trial bytes.

reproduce (from lane root):
  bash plans/round-59-c2.sh                       # BASE -> absent line, guard=0, rc 0
  bash plans/round-59-c2.sh --tree <tree-with-trial>   # -> value=5 line, rc 0
bao pin is read live from plans/round-57-c2.sh; bao binary sha256 must equal
9c5f36287c673f386e1533e9c044169a248e4ee50dd54810fa766e95bd41b788 (OpenBao 2.7.2).
