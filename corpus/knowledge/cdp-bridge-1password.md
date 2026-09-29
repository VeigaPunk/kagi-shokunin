# 1Password ↔ Chrome CDP bridge

Source: `~/.local/bin/the-janitor` `cmd_cdp_ensure` (L251–271),
`cmd_cdp_status` (L273–291), profile/port vars (L22–26); observed host state
2026-09-28 (`ls`, `op --version`, `tmux ls`). No browser was launched and no
vault UI was touched while writing this entry.

Reverify: R11-01, R11-02

## Why the bridge exists

1Password's browser extension unlocks the CLI integration through a Chrome
**native messaging host** (NMH). The fleet's burner Chrome profile
(`the-musketeer`) is a separate profile directory, so the NMH manifest must be
written into *that* profile or the extension cannot reach
`/opt/1Password/1Password-BrowserSupport`.

| Knob | Default | Line |
|---|---|---|
| `MUSKETEER_CHROME_PROFILE` | `~/.local/share/the-musketeer/chrome-profile` | L23 |
| NMH dir | `$PROFILE/NativeMessagingHosts` | L24 |
| NMH manifest | `…/com.1password.1password.json` | L25 |
| `ONEPASSWORD_BROWSER_SUPPORT` | `/opt/1Password/1Password-BrowserSupport` | L26 |
| `MUSKETEER_CDP_PORT` | `9222` | L27 |

Observed on this host: `/opt/1Password/1Password-BrowserSupport` exists;
`~/.local/share/the-musketeer/chrome-profile/NativeMessagingHosts/com.1password.1password.json`
is present; `op` is `/usr/bin/op` version **2.35.0**.

## `cdp-bridge ensure` (idempotent writer)

Refuses with exit 2 (`the-janitor: BrowserSupport missing: <path>`) when the
support binary is not executable; otherwise writes the manifest `chmod 600`:

```json
{ "name": "com.1password.1password",
  "description": "1Password BrowserSupport for musketeer-chrome",
  "path": "<BROWSER_SUPPORT>", "type": "stdio",
  "allowed_origins": [
    "chrome-extension://aeblfdkhhhdcdjpifhhbdiojplfjncoa/",
    "chrome-extension://gejiddohjgogedgjnonbofjigllpkmbf/" ] }
```

The two allowed extension IDs are the only origins that may talk to the host —
a third ID silently gets nothing (Chrome refuses the connection), which presents
as "extension can't find 1Password", not as an error message.

## `cdp-bridge status` (names only)

Prints `profile`, `nmh_json <path> present|missing`, `browser_support <path>
executable|missing`, then `nmh_path` + `nmh_origins` parsed out of the manifest,
and finally `cdp 127.0.0.1:9222 up|down` from
`curl -fsS --max-time 1 http://127.0.0.1:9222/json/version`. Note what it never
prints: extension internals, vault contents, or any credential — the subcommand
is deliberately a *reachability* probe.

## `cdp-bridge open-popup` is refused by design

```
the-janitor: open-popup is human/CDP UI — use agent-browser; will not scrape vault DOM
```
exit 2 (L325–328). The 1Password unlock/approval popup is a human surface;
scraping vault DOM is out of bounds for the CLI and for agents. This is the
domain's clearest statement of where automation stops.

## Error patterns

| Symptom | Likely cause | Move |
|---|---|---|
| `cdp … down` | burner Chrome not running with `--remote-debugging-port=9222` | start/inspect via the browser lane; do not re-`ensure` blindly |
| `nmh_json missing` after a profile reset | profile dir recreated without the manifest | `cdp-bridge ensure` (idempotent, 600) |
| extension still cannot reach 1Password | extension ID not in `allowed_origins`, or 1Password Settings → Developer → "Integrate with 1Password CLI" off | compare IDs from `status`; the CLI-integration toggle is the same hint the handler startup prints (`the-janitor` L110) |
| handler dies during startup with `handler exited before becoming ready` | CLI integration disabled or app locked | same toggle + unlock, then retry (L109–111) |

## Cross-domain note (reported, not absorbed)

Port `9222` and the `the-musketeer` Chrome profile are **shared** with the
webzites kimi fleet, which serializes all browser work behind
`webzites lease acquire` (kake province: `kake-shokunin/SKILL.md` §"Lease
before browser"). A janitor CDP probe and a kimi publish-prep both want that one
browser. Ownership of the shared-browser lease for vault work is unresolved in
this province; filed to the integrator rather than claimed here.

## Falsification

`the-janitor cdp-bridge status` reproduces every field above from live state;
`the-janitor cdp-bridge open-popup` exits 2 with the quoted refusal. Neither
command touches vault data, so both are safe to run as a smoke check.
