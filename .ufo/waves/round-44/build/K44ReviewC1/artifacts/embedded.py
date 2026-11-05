import sys
src, scr = sys.argv[1], sys.argv[2]
s = open(src).read()
OLD = '[ "$P1" = "0" ] && [ "$N1" = "1" ] && [ "$N2" = "1" ]'
assert s.count(OLD) == 1, "final-condition marker"
assert s.count("# N1: stale fixture") == 1, "N1 marker"
assert s.count("# N2: silent fixture") == 1, "N2 marker"

def cut(text, start, end):
    i = text.index(start)
    j = text.index(end, i) + len(end)
    return text[:i] + text[j:]

y1 = cut(s, "# N1: stale fixture", "N1=$?\n").replace(OLD, '[ "$P1" = "0" ] && [ "$N2" = "1" ]')
assert '"$N1"' not in y1, "y1 post-condition"
y2 = cut(s, "# N2: silent fixture", "N2=$?\n").replace(OLD, '[ "$P1" = "0" ] && [ "$N1" = "1" ]')
assert '"$N2"' not in y2, "y2 post-condition"
open(scr + "/mut-y1", "w").write(y1)
open(scr + "/mut-y2", "w").write(y2)
