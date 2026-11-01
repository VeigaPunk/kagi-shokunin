#!/usr/bin/env python3
"""Differential feed-token agreement gate (round 29 C2).

The round-28 closure found the D1 class: one scanner trusting a token shape
another scanner never extracts. The three feed extractors in
``corpus/release-clock.py`` (STABLE_TITLE_RE, STABLE_TAG_HREF_RE,
TEXT_VERSION_RE) are $-anchored independently; the closure's fail-open was
ALL THREE silently dropping a period-suffixed token the shared token grammar
(STABLE_TOKEN_RE + the canonicality judge) is willing to adjudicate. A
one-off fix can drift apart again silently. This gate makes the agreement a
standing check:

- it IMPORTS the live instrument's extractors and its shared token grammar
  (never copies them -- reference-drift class);
- it runs one fixed corpus of token shapes through every feed extractor in
  its natural wrapper (Atom title, /releases/tag/ href, text Version line);
- a shape the shared token grammar adjudicates (it extracts exactly one
  X.Y.Z core) must be EXTRACTED, unchanged, by every extractor; a shape
  outside that grammar (prerelease, build metadata, extra/missing
  components) must be REFUSED by every extractor;
- any extractor that deviates -- different extracted-vs-refused decision, or
  a different token -- is a named DISAGREE finding and fails the run.

Hermetic: no network, no host-private reads; the only file it opens is the
instrument named by --instrument (default: release-clock.py beside this
script). Exit 0 AGREE / 1 DISAGREE / 2 SETUP. Every disagreement is counted
in the verdict line (QM3); --selftest proves the checker itself on synthetic
extractors, including a seeded divergence it must catch (the gate is shown
able to fail). This gate adjudicates EXTRACTION agreement only: it never
orders versions, resolves references, reads feeds or contacts any host.

Shapes corpus (fixed; id -> token):
  trailing-period  3.15.1.            close-paren    3.15.1)
  comma-prose      3.15.1, out now    leading-zeros  3.15.01
  digits-19        3.15.1000000000000000000 (19-digit component)
  plain            3.15.1             v-prefix       v3.15.1
  prerelease       3.15.1rc1          build-metadata 3.15.1+build.2
  four-component   3.15.1.2           two-component  3.15
  series-x         1.21.x
"""
import argparse
import importlib.util
import re
import sys
from pathlib import Path

SHAPES = (
    ("trailing-period", "3.15.1."),
    ("comma-prose", "3.15.1, out now"),
    ("close-paren", "3.15.1)"),
    ("leading-zeros", "3.15.01"),
    ("digits-19", "3.15." + "1" * 19),
    ("prerelease", "3.15.1rc1"),
    ("build-metadata", "3.15.1+build.2"),
    ("four-component", "3.15.1.2"),
    ("v-prefix", "v3.15.1"),
    ("two-component", "3.15"),
    ("series-x", "1.21.x"),
    ("plain", "3.15.1"),
)
EXTRACTORS = ("STABLE_TITLE_RE", "STABLE_TAG_HREF_RE", "TEXT_VERSION_RE")


def load_instrument(path):
    """Import the live instrument module from an explicit path."""
    path = Path(path)
    if not path.is_file():
        raise SetupError("instrument not found: %s" % path)
    spec = importlib.util.spec_from_file_location("kagi_release_clock_under_test", path)
    if spec is None or spec.loader is None:
        raise SetupError("cannot import instrument: %s" % path)
    try:
        module = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(module)
    except Exception as exc:  # noqa: BLE001 - typed as SETUP below
        raise SetupError("instrument import failed: %s" % exc.__class__.__name__)
    missing = [name for name in EXTRACTORS + ("STABLE_TOKEN_RE",)
               if not hasattr(module, name)
               or not isinstance(getattr(module, name), re.Pattern)]
    if missing:
        raise SetupError("instrument lacks token grammar: %s" % ",".join(missing))
    return module


class SetupError(Exception):
    pass


def wrapped(token, wrapper):
    """Natural wrapper text per feed surface."""
    if wrapper == "title":
        return "Python " + token
    if wrapper == "href":
        return "/releases/tag/" + token
    return "Version: " + token  # text line


def run_extractor(regex, wrapper, text):
    """Mimic the instrument's own application of one extractor."""
    if wrapper == "title":
        match = regex.match(text.strip())
    elif wrapper == "href":
        match = regex.search(text.strip())
    else:
        match = regex.search(text)
    return match.group(1) if match else None


def judge_decision(token_re, token):
    """The shared token grammar's decision: (extract, core) or (refuse, None)."""
    match = token_re.search(token)
    return ("extract", match.group(1)) if match else ("refuse", None)


def check_shapes(instrument, shapes=SHAPES):
    """Return (findings, disagreements) over the shape corpus."""
    findings = []
    for shape_id, token in shapes:
        expected_kind, expected_core = judge_decision(instrument.STABLE_TOKEN_RE, token)
        decisions = {}
        for name in EXTRACTORS:
            got = run_extractor(getattr(instrument, name), name_to_wrapper(name), wrapped(token, name_to_wrapper(name)))
            decisions[name] = got
            kind = "extract" if got is not None else "refuse"
            if kind != expected_kind or (got is not None and got != expected_core):
                findings.append(
                    "FEED_TOKEN_DISAGREE shape=%s expected=%s%s %s=%s%s"
                    % (shape_id, expected_kind,
                       (":" + expected_core) if expected_core else "",
                       name, kind, (":" + got) if got else ""))
    return findings, len(findings)


def name_to_wrapper(name):
    return {"STABLE_TITLE_RE": "title",
            "STABLE_TAG_HREF_RE": "href",
            "TEXT_VERSION_RE": "text"}[name]


def run(instrument):
    findings, count = check_shapes(instrument)
    if findings:
        for line in findings:
            print(line)
        print("FEED_TOKEN_AGREE: DISAGREE (shapes=%d disagreements=%d)"
              % (len(SHAPES), count))
        return 1
    print("FEED_TOKEN_AGREE: AGREE (shapes=%d disagreements=0)" % len(SHAPES))
    return 0


def selftest():
    """Prove the checker on synthetic extractors only (never the live file).

    Cases: a uniform correct set agrees; a seeded divergent extractor (the
    $-anchored right boundary is the round-28 D1 mutation) is caught naming
    its shape; a refusal-side leak is caught; a wrong-token extraction is
    caught. The synthetic patterns below are selftest fixtures, not the live
    contract -- the live contract is only ever imported in run().
    """
    cases = 0
    failures = []
    good = {
        "STABLE_TITLE_RE": re.compile(r"^(?:[A-Za-z]+ )?v?([0-9]+\.[0-9]+\.[0-9]+)(?![A-Za-z0-9+-]|\.[0-9])"),
        "STABLE_TAG_HREF_RE": re.compile(r"/releases/tag/v?([0-9]+\.[0-9]+\.[0-9]+)(?![A-Za-z0-9+-]|\.[0-9])"),
        "TEXT_VERSION_RE": re.compile(r"^Version:[ \t]*v?([0-9]+\.[0-9]+\.[0-9]+)(?![A-Za-z0-9+-]|\.[0-9])", re.MULTILINE),
        "STABLE_TOKEN_RE": re.compile(r"(?<![A-Za-z0-9.])v?([0-9]+\.[0-9]+\.[0-9]+)(?![A-Za-z0-9+-]|\.[0-9])", re.IGNORECASE),
    }

    class Synthetic:
        pass

    def run_set(patterns):
        node = Synthetic()
        for name, pattern in patterns.items():
            setattr(node, name, pattern)
        return check_shapes(node)

    cases += 1
    findings, count = run_set(good)
    if findings or count != 0:
        failures.append("uniform synthetic set disagreed (%d)" % count)

    divergent = dict(good)
    divergent["STABLE_TITLE_RE"] = re.compile(r"^(?:[A-Za-z]+ )?v?([0-9]+\.[0-9]+\.[0-9]+)$")
    cases += 1
    findings, count = run_set(divergent)
    if count < 1 or not any("shape=trailing-period" in line
                            and "STABLE_TITLE_RE=refuse" in line
                            for line in findings):
        failures.append("seeded divergent title extractor not caught")

    leaky = dict(good)
    leaky["STABLE_TAG_HREF_RE"] = re.compile(r"/releases/tag/v?([0-9]+\.[0-9]+\.[0-9]+)")
    cases += 1
    findings, count = run_set(leaky)
    if count < 1 or not any("shape=prerelease" in line
                            and "STABLE_TAG_HREF_RE=extract" in line
                            for line in findings):
        failures.append("refusal-side prerelease leak not caught")

    wrong = dict(good)
    wrong["TEXT_VERSION_RE"] = re.compile(r"^Version:[ \t]*v?([0-9]+\.[0-9]+)", re.MULTILINE)
    cases += 1
    findings, count = run_set(wrong)
    if count < 1 or not any("shape=plain" in line
                            and "TEXT_VERSION_RE=extract:3.15" in line
                            for line in findings):
        failures.append("wrong-token extraction not caught")

    if failures:
        for failure in failures:
            print("FEED_TOKEN_AGREE_SELFTEST: FAIL %s" % failure)
        return 1
    print("FEED_TOKEN_AGREE_SELFTEST: PASS (%d cases)" % cases)
    return 0


def main(argv=None):
    parser = argparse.ArgumentParser(
        description="differential feed-token agreement gate (round 29 C2)",
        allow_abbrev=False)
    parser.add_argument("--instrument", metavar="FILE",
                        help="release-clock module to check (default: release-clock.py beside this script)")
    parser.add_argument("--selftest", action="store_true",
                        help="run synthetic offline cases only")
    args = parser.parse_args(argv)
    if args.selftest:
        if args.instrument:
            print("FEED_TOKEN_AGREE: SETUP (--selftest is isolated from --instrument)")
            return 2
        return selftest()
    try:
        instrument = load_instrument(
            args.instrument or Path(__file__).resolve().parent / "release-clock.py")
    except SetupError as exc:
        print("FEED_TOKEN_AGREE: SETUP (%s)" % exc)
        return 2
    return run(instrument)


if __name__ == "__main__":
    sys.exit(main())
