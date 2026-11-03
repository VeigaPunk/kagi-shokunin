# Recheck prose stripped from the 8 adopted rows (verbatim; for the lesson Gate)
# S066/S067 (-> S053/S054) carried a bare `180d`; nothing was stripped from them.

## S068 -> S055 (Betterleaks README, betterleaks/betterleaks)
cadence kept: 180d
prose removed (verbatim, logical line restored at the stripped pipe):
`curl -fsSL 'https://raw.githubusercontent.com/betterleaks/betterleaks/main/README.md' | grep -c 'Scans detect secrets without credential provider requests by default'` -> 1 (ran 2026-10-23)

## S069 -> S056 (GitHub repository search API response for "betterleaks")
cadence kept: 90d
prose removed (verbatim, logical line restored at the stripped pipe):
`curl -fsSL 'https://api.github.com/search/repositories?q=betterleaks&per_page=10' | python3 -c "import json,sys;d=json.load(sys.stdin);r=[i for i in d['items'] if i['full_name']=='betterleaks/betterleaks'][0];print(r['fork'],r['stargazers_count'],r['pushed_at'])"` -> `False 2322 2026-10-22T21:28:27Z` (ran 2026-10-23; the unauthenticated GitHub API is per-IP rate limited, so the stored response sha256 `0c8bdbd04508489c` is the fallback evidence)

## S070 -> S057 (TruffleHog Docs, Verification caching)
cadence kept: 180d
prose removed (verbatim, logical line restored at the stripped pipe):
`curl -fsSL 'https://trufflesecurity.com/docs/verification-caching' | grep -c 'Each cache entry expires after three hours'` -> 1 (ran 2026-10-23)

## S071 -> S058 (TruffleHog Docs, How we handle your data)
cadence kept: 180d
prose removed (verbatim, logical line restored at the stripped pipe):
`curl -fsSL 'https://trufflesecurity.com/docs/how-we-handle-your-data' | grep -c 'Credentials are verified using safe, read-only API calls'` -> 2 matching lines (ran 2026-10-23; the phrase appears in the feature list and in the Verification Safety panel)

## S072 -> S059 (TruffleHog Docs, Reverify secrets)
cadence kept: 180d
prose removed (verbatim, logical line restored at the stripped pipe):
`curl -fsSL 'https://trufflesecurity.com/docs/reverify-secrets' | grep -c 'Secret reverification is currently only supported'` -> 1 (ran 2026-10-23)

## S073 -> S060 (TruffleHog Docs, Notify results)
cadence kept: 180d
prose removed (verbatim, logical line restored at the stripped pipe):
`curl -fsSL 'https://trufflesecurity.com/docs/notify-results' | grep -c 'sendUnverified'` -> 2 matching lines (ran 2026-10-23)

