Author: R71Critic (critic)

# R71Critic — C1 wording falsification (Amendment 59: killing artifact must be found before the report, by me)

Lane: kagi-shokunin, round 71 C1 depth (T6–T9). Frozen predicate, kill rule, shims, named ceiling
per plans/round-71.md §C1 and plans/round-71-c1.sh. I ran the trial myself:
`bash corpus/openbao-pki-issuer-trial.sh --work /fast/scratch/hyaku/kagi-r71/R71Critic
--evidence .../ev` → `TRIAL T6..T9 HOLDS`, `OPENBAO_PKI_ISSUER_TRIAL: HOLDS holds=4 broken=0
error=0 bao=v2.7.2 openssl=3.6.5`, rc 0; no leaked `bao server` afterwards. Every sentence below
is checked against trial HOLDS conditions, counter DISCRIMINATE/ARTIFACT legs, and evidence files
I inspected by hand (openssl verify, CRL text, OCSP response). No secret named; all names
r71.test synthetic.

## Classification method

(a) **enforced**: counter value requires the trial HOLDS line under real binary + BROKEN under
the matching shim + HOLDS under the other three + entry line names OpenBao 2.7.2 + openssl
artifact check passes (artN).
(b) **stated-not-enforced**: in trial HOLDS condition or admission prose, no artifact leg.
(c) **unsupported**: no leg at all.

## Sentence-by-sentence (round-71 knowledge entry + §C1)

Entry title (line 1): "a `truncate` issuer clipped a 10h leaf to its own NotAfter, a revoked leaf
of a non-default issuer was on its own issuer's CRL and not the default's, token-less OCSP answered
`revoked`/`good`, and a `no_store` leaf refused by serial was revoked by proof of possession."
(a) enforced — each clause = one T verdict + artifact check; entry's own `## Measured` and
`Does not establish` caveats keep the title scoped.

Why/table (lines 19–38): S173/S170 quotes and [INFERENCE] consequences — (c) unsupported as
mechanics, honestly labelled (b)-style: text says column 4 "is documentation … or the lane's
own inference, marked as such" and uses [INFERENCE]. Neutral; no over-reach.

"observed while building T6: `bao write …` reset `issuer_name` to `""`" (table line 35) +
L1 probe receipt corroboration — (b) stated-not-enforced: prose only, counter never reads it;
entry's Measured disclaimer says "observed details are … not counter-enforced." Neutral.

- T6 Measured (entry line 49): "enforced — verdict flipped by SH6 … and artifact check: leaf
  verifies against 2h issuer, notAfter equals issuer's." (a) Wild thing enforced: art6 checks
  leaf verifies + `enddate leaf == enddate issuer` + issuer lifetime <36000 s. What the workload
  sentence "10h leaf" / "2h issuer" asserts (10h request length, 2h issuer request length) is
  (b) stated-not-enforced: the trial issues `ttl=2h` / `ttl=10h` but binds only dates, never
  requested TTL values; the <10h leg is a *bound* ("could not fit unclipped"), not a measurement
  of 10h. Narrowest honest wording: "a leaf requested longer than the issuer's life is issued
  with NotAfter equal to the issuer's; issuer lifetime in evidence <10h."
- T7 Measured (line 50): (a) fully enforced — art7 checks verify-both-issuers, CRL signatures,
  serial-listed / not-listed.
- T8 Measured (line 51): verdict + OCSP responses (a) enforced for *response content*;
  "The requests carried no token (trial's openssl ocsp runs with BAO_TOKEN unset; openssl does
  not read it in any case)" is (b) stated-not-enforced: trial unsets BAO_TOKEN in the shell but
  makes an HTTP OCSP POST to `$BAO_ADDR/v1/pki/ocsp` with no CLI auth header — token-lessness
  holds because no credential is supplied on the OCSP path, which the counter never inspects.
  Smallest fix: "requests were made without presenting a token; the trial unsets BAO_TOKEN."
- T9 Measured (line 52): (a) for CRL leg; "The refusal of revoke-by-serial is part of the
  trial's HOLDS condition, not of the artifact check" is (b) honestly flagged — counter
  correctly scoped. Neutral.
- Does-not-establish block (lines 54–67): (a) honest scope; the final bullet names the named
  ceiling. Neutral.

§C1 plan wording (round-71.md lines 18, 20–23, 54–61):
- Heading "executed and artifact-checked" over-claims *execution* if read as counted; body line
  81–85 names the ceiling explicitly ("that the trial executes the mechanics through `bao` is a
  reviewed property, not a counted one"), and Measured section reiterates it. The title is the
  only sentence that could be read unqualified. Neutral *given* the body; smallest safe edit =
  title reads "executed and artifact-checked" → historical narrow form already carried in the
  round-70 pattern ("count of shim-discriminating verdicts").
- T6 sentence (§C1 line 54–55): "(default `err` refuses it)" — (b) stated-not-enforced as a
  distinct leg: the trial BROKEN-peers refusal (`long-leaf-refused`) but no artifact leg proves
  the refusal used the *err* policy; technically the SH6 flip is the discriminator, not a probe
  of `err` vs a generic failure. Smallest honest form: "under the default the issuing call fails
  when the leaf would outlive the issuer" [not directly artifact-checked].
- Axis name "depth" (line 18) vs "coverage": the predicate counts verdict words flipped by shims
  — coverage of 4 behaviours — but each carries an openssl artifact that no earlier PKI round
  carried, and the round-70 spot-check routed exactly this "count does not prove the observable"
  class to be closed by an artifact leg. The depth claim lives in the artifact leg, not the
  count. `artifact-checked` is exactly right — the name is not overstated *because* the heading
  says executed-and-artifact-checked, and the body honestly limits "executed" to reviewed
  property. Attack considered: relabelling as coverage would be a worse fit than depth, since
  breadth (one more behaviour) without artifacts is the round-70 ceiling.

## Killing artifact sought (Amendment 59)

Find — before reporting — an admission that fails the frozen predicate while the entry claims
otherwise. I ran the control-suite logic against the landed bytes conceptually and re-ran the
live trial: no killing artifact found on the landed trial (verdicts HOLDS, artifacts verify by
independent openssl as expected). The plan/counter are frozen — I propose no edit to them; the
narrowest honesty fixes above are entry-prose only, suitable for a lesson, not for amending
consumed verdicts.

## Narrowed service-level wording of the whole C1 claim (for judge-facing use)

"Four OCSP/CRL/issuer mechanics are each enforced by a trial verdict that flips BROKEN under a
falsifier shim plus an openssl artifact; whether OpenBao produced them is *reviewed*, not counted."

FINDING CR-1 neutral T6 '10h'/'2h' are requested TTLs, only dates+<10h bound are artifact-checked; narrow to date equality.
FINDING CR-2 neutral T8 tokenlessness rests on shell `unset BAO_TOKEN` plus no CLI auth header, not an artifact leg.
FINDING CR-3 neutral §C1 heading 'executed' is honestly limited by the named ceiling in body; depth justified by the artifact leg, not the verdict count.
SEAT-STATUS: complete reviewed every factual sentence; ran the trial once; no killing artifact found on landed bytes
