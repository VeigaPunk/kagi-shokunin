import re,sys
def norm(b):
    t=b.decode('utf-8','replace')
    return re.sub(r'\s+',' ',t)
pairs=[('S095','.ufo/waves/round-40/capture/S095.body','Matches Unicode whitespace characters (as defined by',75897),
       ('S096','.ufo/waves/round-40/capture/S096.body','This function uses the rules defined by the HTML 5 standard',13521)]
for sid,path,q,off in pairs:
    b=open(path,'rb').read()
    raw=b.decode('utf-8','replace')
    qn=re.sub(r'\s+',' ',q)
    # exact raw byte locate
    qb=q.encode()
    exact=[m.start() for m in re.finditer(re.escape(qb),b)]
    # whitespace-normalized: find in normalized text and map back to nearest raw offset
    nt=norm(b)
    idx=nt.find(qn)
    # raw occurrence search with whitespace regex
    pat=re.compile(r'\s+'.join(re.escape(w) for w in q.split()))
    m=pat.search(raw)
    print(f"{sid}: file={path} bytes={len(b)} quote={q!r}")
    print(f"  exact_byte_matches={exact}")
    print(f"  normalized_index={idx}  raw_ws_regex_match_start={m.start() if m else None} raw_match_end={m.end() if m else None}")
    print(f"  expected_offset={off} delta={(m.start()-off) if m else None}")
    if m:
        print(f"  matched_raw_text={raw[m.start():m.end()]!r}")
    print()
