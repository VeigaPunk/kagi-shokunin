import subprocess, sys
rows = [
    ('M1.1', '.ufo/waves/round-61/capture/S125.body', 'A certain threshold of shares is required to reconstruct the unseal key, which is then used to decrypt the root key.', 'A certain threshold of shares is required to\nreconstruct the unseal key, which is then used to decrypt the root key.'),
    ('M1.2', '.ufo/waves/round-61/capture/S125.body', "OpenBao uses an algorithm known as Shamir's Secret Sharing to split the key into shares.", 'to split the key into shares.'),
    ('M1.3', '.ufo/waves/round-61/capture/S125.body', 'This allows each share of the root key to be on a distinct client machine for better security.', 'key to be on a distinct client machine for better security.'),
    ('M1.4', '.ufo/waves/round-61/capture/S125.body', 'When an OpenBao server is started, it starts in a sealed state.', 'When an OpenBao server is started, it starts in a'),
    ('M1.5', '.ufo/waves/round-61/capture/S125.body', 'The only possible operations are to unseal the OpenBao and check the status of the seal.', 'The only possible operations are to unseal the OpenBao and check the status'),
    ('M1.6', '.ufo/waves/round-61/capture/S125.body', 'Once an OpenBao node is unsealed, it remains unsealed until one of these things happens:', 'Once an OpenBao node is unsealed, it remains unsealed until one of these things happens:'),
    ('M1.7', '.ufo/waves/round-61/capture/S125.body', 'It is resealed via the API (see below).', 'It is resealed via the API (see below).'),
    ('M1.8', '.ufo/waves/round-61/capture/S125.body', 'The server is restarted.', 'The server is restarted.'),
    ('M1.9', '.ufo/waves/round-61/capture/S125.body', 'This will throw away the root key in memory and require another unseal process to restore it.', 'key in memory and require another unseal process to restore it.'),
    ('M1.10', '.ufo/waves/round-61/capture/S125.body', 'Sealing only requires a single operator with root privileges.', 'only requires a single operator with root privileges.'),
    ('M1.11', '.ufo/waves/round-61/capture/S125.body', "It can't be accessed again without access to the root key shares.", 'access to the root key shares.'),
    ('M2.1', '.ufo/waves/round-61/capture/S125.body', 'the shares are added one at a time (in any order) until enough shares are present to reconstruct the key and decrypt the root key.', 'the shares are added one at a time (in any\norder) until enough shares are present to reconstruct the key and\ndecrypt the root key.'),
    ('M2.2', '.ufo/waves/round-61/capture/S125.body', 'each node must be unsealed with the required threshold of shares. Partial unsealing of each node is not distributed across the cluster.', 'unsealed with the required threshold of shares. Partial unsealing of each node\nis not distributed across the cluster.'),
    ('M2.3', '.ufo/waves/round-61/capture/S125.body', 'This process is stateful: each key can be entered via multiple mechanisms from multiple client machines and it will work.', 'This process is stateful: each key can be entered via multiple mechanisms from\nmultiple client machines and it will work.'),
    ('M3.1', '.ufo/waves/round-61/capture/S126.body', 'operator rekey command is deprecated, please use rotate-keys instead.', 'command is deprecated, please use'),
    ('M3.2', '.ufo/waves/round-61/capture/S126.body', 'The operator rekey command generates a new set of unseal keys.', 'The <code>operator rekey</code> command generates a new set of unseal keys.'),
    ('M3.3', '.ufo/waves/round-61/capture/S126.body', 'This operation is zero downtime, but it requires the OpenBao is unsealed and a quorum of existing unseal keys are provided.', 'This operation is zero downtime,\nbut it requires the OpenBao is unsealed and a quorum of existing unseal keys are\nprovided.'),
    ('M3.4', '.ufo/waves/round-61/capture/S126.body', "-init (bool: false) - Initialize the rekeying operation. This can only be done if there's not one in progress.", "Initialize the rekeying operation. This can only be\ndone if there's not one in progress."),
    ('M3.5', '.ufo/waves/round-61/capture/S126.body', '-nonce (string: "") - Nonce value provided at initialization. The same nonce value must be provided with each unseal key.', 'Nonce value provided at initialization. The same\nnonce value must be provided with each unseal key.'),
    ('M3.6', '.ufo/waves/round-61/capture/S126.body', '-verify (bool: false) - Indicate during the phase -init that the verification process is activated for the rekey.', 'verification process is activated for the rekey.'),
    ('M3.7', '.ufo/waves/round-61/capture/S126.body', '-key-shares (int: 5) - Number of key shares to split the generated master key into. This is the number of "unseal keys" to generate.', 'Number of key shares to split the generated master\nkey into. This is the number of "unseal keys" to generate.'),
    ('M3.8', '.ufo/waves/round-61/capture/S126.body', '-key-threshold (int: 3) - Number of key shares required to reconstruct the root key. This must be less than or equal to -key-shares.', 'Number of key shares required to reconstruct the\nroot key. This must be less than or equal to -key-shares.'),
    ('M3.9', '.ufo/waves/round-61/capture/S126.body', '-target (string: "barrier") - Target for rekeying. "recovery" only applies when HSM support is enabled or using Auto Unseal', 'Target for rekeying. "recovery" only applies\nwhen HSM support is enabled or using'),
    ('M3.10', '.ufo/waves/round-61/capture/S126.body', 'This option is only available if the PGP keys were provided and the backup has not been deleted.', 'option is only available if the PGP keys were provided and the backup has not\nbeen deleted.'),
    ('M3.11', '.ufo/waves/round-61/capture/S126.body', 'Initialize a rekey: $ bao operator rekey \\ -init \\ -key-shares=15 \\ -key-threshold=9', 'Initialize a rekey:</p>'),
    ('M3.12', '.ufo/waves/round-61/capture/S126.body', 'Perform the verification of the rekey using the verification nonce: $ bao operator rekey -verify -nonce="..."', '$ bao operator rekey -verify -nonce="..."'),
    ('M4.1', '.ufo/waves/round-61/capture/S127.body', 'The operator generate-root command generates a new root token by combining a quorum of share holders.', 'The <code>operator generate-root</code> command generates a new root token by combining a\nquorum of share holders.'),
    ('M4.2', '.ufo/waves/round-61/capture/S127.body', 'A base64-encoded one-time-password (OTP) provided via the -otp flag. Use the -generate-otp flag to generate a usable value.', 'A base64-encoded one-time-password (OTP) provided via the'),
    ('M4.3', '.ufo/waves/round-61/capture/S127.body', 'The resulting token is XORed with this value when it is returned.', 'The resulting token is XORed\nwith this value when it is returned.'),
    ('M4.4', '.ufo/waves/round-61/capture/S127.body', 'Use the -decode flag to output the final value.', 'Use the <code>-decode</code> flag to output the\nfinal value.'),
    ('M4.5', '.ufo/waves/round-61/capture/S127.body', '-decode (string: "") - Decode and output the generated root token. This option requires the -otp flag be set to the OTP used during initialization.', 'Decode and output the generated root token.'),
    ('M4.6', '.ufo/waves/round-61/capture/S127.body', '-nonce (string: "") - Nonce value provided at initialization. The same nonce value must be provided with each unseal key.', 'Nonce value provided at initialization. The same\nnonce value must be provided with each unseal key.'),
    ('M4.7', '.ufo/waves/round-61/capture/S127.body', '-generate-otp (bool: false) - Generate and print a high-entropy one-time-password (OTP) suitable for use with the "-init" flag.', 'one-time-password (OTP) suitable for use with the "-init" flag.'),
    ('M4.8', '.ufo/waves/round-61/capture/S127.body', 'Generate an OTP code for the final token: $ bao operator generate-root -generate-otp', '$ bao operator generate-root -generate-otp'),
]
bad = 0
for qid, path, quote, anchor in rows:
    body = open(path,'rb').read()
    n_raw = body.count(anchor.encode())
    r = subprocess.run(['python3','corpus/rendered-text-v1.py','locate',path,quote], capture_output=True,text=True)
    n_loc = r.stdout.strip()
    ok = (n_raw == 1 and n_loc == 'RENDERED_TEXT_V1_LOCATE: count=1')
    if not ok:
        bad += 1; print('MISMATCH', qid, n_raw, n_loc)
print('QUOTE_RESOLUTION: rows=%d mismatches=%d' % (len(rows), bad))
