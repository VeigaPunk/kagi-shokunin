import sys
p, src = sys.argv[1], sys.argv[2]
payload = open(src, encoding='utf-8').read()
t = open(p, encoding='utf-8').read().splitlines(keepends=True)
s = t.index("## Capabilities\n")
e = next(i for i in range(s + 1, len(t)) if t[i].startswith("## "))
t.insert(e, payload + "\n")
open(p, 'w', encoding='utf-8').write(''.join(t))
