# rev 348aa3b8ea7298aeb2f4d69db321fe827a92ae4f
# leg: live (a) — corpus/knowledge/secret-scanning-detection-vs-validation.md:4, stated -> 1
# command: curl -fsSL --max-time 60 -w 'HTTP=%{http_code} bytes=%{size_download}\n' -o $S/live/trufflehog-readme.body 'https://raw.githubusercontent.com/trufflesecurity/trufflehog/main/README.md'; grep -c 'it can also log in to confirm if that secret is live or not' <body>
HTTP=200 bytes=38524
curl_exit=0
1
grep_exit=0
# last line: grep_exit=0
