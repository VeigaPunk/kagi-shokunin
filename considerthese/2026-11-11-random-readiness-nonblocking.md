# Kagi: nonblocking randomness depends on the revision

[Linux 5.6](https://github.com/torvalds/linux/blob/v5.6/drivers/char/random.c) sends /dev/random reads through a readiness wait without checking O_NONBLOCK.

[Linux 6.1](https://github.com/torvalds/linux/blob/v6.1/drivers/char/random.c) returns EAGAIN when O_NONBLOCK is set and the generator is unready. The September 2022 [restoration](https://github.com/torvalds/linux/commit/cd4f24ae9404fd31fc461066e57889be3b68641b) does not restore the old post-initialization entropy-depletion blocking model.

For credential-generation reviews, distinguish waiting for readiness from a failed request and from delivered secret material. An unchanged device name or open flag does not establish unchanged startup behavior.

These are tagged source snapshots, not a tested host, an entropy-quality measurement or a universal release-number rule. Distribution backports require their own evidence.

Both files offer conditional BSD/GPL licensing alternatives. Original commentary only; no code copied, generator invoked, credentials accessed, training or assimilation.

Destination: VeigaPunk/kagi-shokunin, master, considerthese/2026-11-11-random-readiness-nonblocking.md.
