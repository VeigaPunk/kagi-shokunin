#!/usr/bin/env python3
"""Adjudicate the checked-in, typed C1 qualifier controls.

This is a closed-record reviewer, not prose NLP and not a source-truth oracle.
The source URLs are inert metadata; normal operation performs no network access.
"""

from __future__ import annotations

import copy
import hashlib
import json
import os
import re
import stat
import subprocess
import sys
import tempfile
from pathlib import Path
from typing import Any

SCHEMA = "kagi-feature-claims-v1"
MAX_INPUT_BYTES = 1_000_000
DEFAULT_CLAIMS = "corpus/feature-claims.json"
CLAIM_FIELDS = {
    "product",
    "feature",
    "path",
    "release_status",
    "eligibility",
    "runtime_constraints",
    "fact",
    "evidence",
}
EVIDENCE_FIELDS = {
    "product",
    "feature",
    "path",
    "release_status",
    "eligibility.plans",
    "eligibility.requirements",
    "eligibility.documented_exclusions",
    "runtime_constraints",
    "fact",
}
ELIGIBILITY_FIELDS = {
    "scope",
    "plans",
    "requirements",
    "documented_exclusions",
}
AUTHORITY_CLASSES = {
    "outside-verifier",
    "construction-rule",
    "verbatim-pin",
    "author",
}

# These are review-artifact pins, not vendor truth claims. Update them only with
# an intentionally reviewed source/control change and a corresponding report.
PINNED_REVIEW_SHA256 = "d1824e332779b134602d14c225d72f1d29fa1036778a2b728a1ec812636ce111"
PINNED_SOURCES_SHA256 = "4bae6cb65a1607705d488bd1748cd0fba50c9eca0cd8119cc2081364dbbfeae0"
PINNED_FEATURES_SHA256 = "154997ffac6e834bc841716dd4d835d9abc9f5f2787c69054e9f57111b7b5555"
PINNED_RECORDS_SHA256 = "efe5039dec14fe403bcbd4d8ace15fb38d538777d7ded0cfc1788a92cc84acb8"
PINNED_TRANSITIONS_SHA256 = "cba061a51b926b088ecb61b98c52308a2548e82e2a7aee7129c390724ca9f953"
PINNED_BOUNDARY_SHA256 = "c4ef738a184077d19cdb50fe71b7cfec972af6631dc887b3b0970964347e4616"

# Expected outcomes are separate literals from the record data. The two
# outside-verifier labels cite the already-landed non-author E1/E3 adjudication;
# other labels are rule or verbatim-pin controls, not independent agreement.
EXPECTED_RECORDS = {
    "BEFORE-E1-STATUS": ("before", "outside-verifier", "status-conflation", "reject:false-claim"),
    "BEFORE-E1-ELIGIBILITY": ("before", "construction-rule", "eligibility-omission", "reject:bar-fail"),
    "BEFORE-E3-VAULT-ONLY": ("before", "outside-verifier", "cross-product-source", "reject:bar-fail"),
    "BEFORE-CUSTOM-UNDERCITED": ("before", "construction-rule", "true-but-under-cited", "reject:bar-fail"),
    "BEFORE-SAME-PAGE-PREVIEW": ("before", "construction-rule", "same-page-status-anchor", "reject:false-claim"),
    "BEFORE-GITHUB-EXCLUSIONS": ("before", "construction-rule", "deployment-eligibility-omission", "reject:bar-fail"),
    "BEFORE-CUSTOM-NO-BETA-APP": ("before", "construction-rule", "beta-app-condition", "reject:bar-fail"),
    "BEFORE-CUSTOM-NO-JS-SDK": ("before", "construction-rule", "sdk-scope-omission", "reject:bar-fail"),
    "BEFORE-VAULT-GA-UNPINNED": ("before", "construction-rule", "unstated-release-status", "reject:bar-fail"),
    "BEFORE-VAULT-OPENBAO-SOURCE": ("before", "construction-rule", "reverse-cross-product-source", "reject:bar-fail"),
    "AFTER-GITHUB-BOUNDED": ("after", "verbatim-pin", "bounded-control", "admit"),
    "AFTER-CUSTOM-BETA-BOUNDED": ("after", "verbatim-pin", "bounded-control", "admit"),
    "AFTER-VAULT-LEASE": ("after", "verbatim-pin", "bounded-control", "admit"),
    "AFTER-OPENBAO-TTL": ("after", "verbatim-pin", "bounded-control", "admit"),
}

EXPECTED_TRANSITIONS = {
    "E1-STATUS-CONFLATION": (
        "BEFORE-E1-STATUS",
        "AFTER-CUSTOM-BETA-BOUNDED",
        "reject:false-claim",
        "admit",
        (
            "eligibility",
            "evidence.eligibility.plans",
            "evidence.eligibility.requirements",
            "evidence.release_status",
            "evidence.runtime_constraints",
            "release_status",
            "runtime_constraints",
        ),
    ),
    "E1-ELIGIBILITY-OMISSION": (
        "BEFORE-E1-ELIGIBILITY",
        "AFTER-GITHUB-BOUNDED",
        "reject:bar-fail",
        "admit",
        (
            "eligibility",
            "evidence.eligibility.documented_exclusions",
            "evidence.eligibility.plans",
            "evidence.eligibility.requirements",
        ),
    ),
    "E3-VAULT-ONLY-OPENBAO": (
        "BEFORE-E3-VAULT-ONLY",
        "AFTER-OPENBAO-TTL",
        "reject:bar-fail",
        "admit",
        ("evidence.fact",),
    ),
    "CUSTOM-BETA-UNDERCITED": (
        "BEFORE-CUSTOM-UNDERCITED",
        "AFTER-CUSTOM-BETA-BOUNDED",
        "reject:bar-fail",
        "admit",
        ("evidence.release_status",),
    ),
    "CUSTOM-SAME-PAGE-STATUS-SWAP": (
        "BEFORE-SAME-PAGE-PREVIEW",
        "AFTER-CUSTOM-BETA-BOUNDED",
        "reject:false-claim",
        "admit",
        ("release_status",),
    ),
    "GITHUB-DEPLOYMENT-ELIGIBILITY": (
        "BEFORE-GITHUB-EXCLUSIONS",
        "AFTER-GITHUB-BOUNDED",
        "reject:bar-fail",
        "admit",
        ("eligibility.documented_exclusions", "evidence.eligibility.documented_exclusions"),
    ),
    "CUSTOM-BETA-APP-CONDITION": (
        "BEFORE-CUSTOM-NO-BETA-APP",
        "AFTER-CUSTOM-BETA-BOUNDED",
        "reject:bar-fail",
        "admit",
        ("evidence.runtime_constraints", "runtime_constraints"),
    ),
    "CUSTOM-JAVASCRIPT-SDK-SCOPE": (
        "BEFORE-CUSTOM-NO-JS-SDK",
        "AFTER-CUSTOM-BETA-BOUNDED",
        "reject:bar-fail",
        "admit",
        ("evidence.runtime_constraints", "runtime_constraints"),
    ),
    "VAULT-UNSUPPORTED-STATUS": (
        "BEFORE-VAULT-GA-UNPINNED",
        "AFTER-VAULT-LEASE",
        "reject:bar-fail",
        "admit",
        ("release_status",),
    ),
    "OPENBAO-DOES-NOT-SUPPORT-VAULT-LEASE": (
        "BEFORE-VAULT-OPENBAO-SOURCE",
        "AFTER-VAULT-LEASE",
        "reject:bar-fail",
        "admit",
        ("evidence.fact",),
    ),
}

EXPECTED_BOUNDARY_IDS = {
    "OUT-OF-SCOPE-VAULT-JWT": "FC-UNKNOWN-FEATURE",
    "UNKNOWN-FIELD": "FC-UNKNOWN-FIELD",
    "UNKNOWN-SOURCE": "FC-UNKNOWN-SOURCE",
}


class GateError(Exception):
    def __init__(self, finding: str):
        super().__init__(finding)
        self.finding = finding


class DuplicateKeyError(ValueError):
    pass


def _no_duplicate_keys(pairs: list[tuple[str, Any]]) -> dict[str, Any]:
    result: dict[str, Any] = {}
    for key, value in pairs:
        if key in result:
            raise DuplicateKeyError
        result[key] = value
    return result


def _reject_constant(_value: str) -> None:
    raise ValueError


def _canonical_digest(value: Any) -> str:
    encoded = json.dumps(
        value,
        ensure_ascii=False,
        sort_keys=True,
        separators=(",", ":"),
    ).encode("utf-8")
    return hashlib.sha256(encoded).hexdigest()


def _root_path(raw_root: str | None) -> Path:
    if raw_root is None:
        candidate = Path(__file__).resolve(strict=True).parent.parent
    else:
        candidate = Path(raw_root)
    try:
        root = candidate.resolve(strict=True)
    except (OSError, RuntimeError):
        raise GateError("FC-ROOT-PATH") from None
    if not root.is_dir():
        raise GateError("FC-ROOT-PATH")
    return root


def _relative_claims_path(root: Path, raw_claims: str | None) -> tuple[str, ...]:
    raw = DEFAULT_CLAIMS if raw_claims is None else raw_claims
    if not raw or "\\" in raw or any(ord(char) < 32 or ord(char) == 127 for char in raw):
        raise GateError("FC-CLAIMS-PATH")
    path = Path(raw)
    if path.is_absolute():
        if raw != str(path):
            raise GateError("FC-CLAIMS-PATH")
        parts = path.parts
        root_parts = root.parts
        if len(parts) < len(root_parts) or tuple(parts[: len(root_parts)]) != root_parts:
            raise GateError("FC-CLAIMS-PATH")
        relative = parts[len(root_parts) :]
    else:
        relative = tuple(raw.split("/"))
    if not relative or any(part in ("", ".", "..") for part in relative):
        raise GateError("FC-CLAIMS-PATH")
    if not re.fullmatch(r"[A-Za-z0-9._/-]+", "/".join(relative)):
        raise GateError("FC-CLAIMS-PATH")
    return tuple(relative)


def _read_beneath(root: Path, relative: tuple[str, ...]) -> bytes:
    if not all(hasattr(os, flag) for flag in ("O_NOFOLLOW", "O_DIRECTORY", "O_NONBLOCK")):
        raise GateError("FC-SAFE-OPEN")
    base_flags = os.O_RDONLY | getattr(os, "O_CLOEXEC", 0)
    directory_flags = base_flags | os.O_DIRECTORY | os.O_NOFOLLOW
    current_fd = -1
    file_fd = -1
    try:
        current_fd = os.open(str(root), directory_flags)
        for component in relative[:-1]:
            next_fd = os.open(component, directory_flags, dir_fd=current_fd)
            os.close(current_fd)
            current_fd = next_fd
        file_fd = os.open(relative[-1], base_flags | os.O_NOFOLLOW | os.O_NONBLOCK, dir_fd=current_fd)
        before = os.fstat(file_fd)
        if not stat.S_ISREG(before.st_mode) or before.st_size > MAX_INPUT_BYTES:
            raise GateError("FC-CLAIMS-FILE")
        with os.fdopen(file_fd, "rb", closefd=True) as stream:
            file_fd = -1
            data = stream.read(MAX_INPUT_BYTES + 1)
            after = os.fstat(stream.fileno())
        if len(data) > MAX_INPUT_BYTES or len(data) != before.st_size:
            raise GateError("FC-CLAIMS-FILE")
        if (before.st_dev, before.st_ino, before.st_size, before.st_mtime_ns, before.st_ctime_ns) != (
            after.st_dev,
            after.st_ino,
            after.st_size,
            after.st_mtime_ns,
            after.st_ctime_ns,
        ):
            raise GateError("FC-CLAIMS-FILE")
        return data
    except GateError:
        raise
    except (OSError, ValueError):
        raise GateError("FC-CLAIMS-PATH") from None
    finally:
        if file_fd >= 0:
            os.close(file_fd)
        if current_fd >= 0:
            os.close(current_fd)


def _load_json(data: bytes) -> dict[str, Any]:
    try:
        text = data.decode("utf-8", errors="strict")
    except UnicodeDecodeError:
        raise GateError("FC-JSON-UTF8") from None
    try:
        value = json.loads(
            text,
            object_pairs_hook=_no_duplicate_keys,
            parse_constant=_reject_constant,
        )
    except DuplicateKeyError:
        raise GateError("FC-JSON-DUPLICATE-KEY") from None
    except (json.JSONDecodeError, ValueError, TypeError):
        raise GateError("FC-JSON-INVALID") from None
    if type(value) is not dict:
        raise GateError("FC-INPUT-SCHEMA")
    return value


def _exact_keys(value: Any, expected: set[str]) -> bool:
    return type(value) is dict and set(value) == expected


def _is_string(value: Any) -> bool:
    return type(value) is str and bool(value)


def _unique_string_list(value: Any) -> bool:
    return type(value) is list and all(_is_string(item) for item in value) and len(value) == len(set(value))


def _validate_source_catalog(sources: Any) -> dict[str, dict[str, Any]]:
    if type(sources) is not list or _canonical_digest(sources) != PINNED_SOURCES_SHA256:
        raise GateError("FC-SOURCE-MANIFEST")
    source_index: dict[str, dict[str, Any]] = {}
    for source in sources:
        if not _exact_keys(
            source,
            {"id", "product", "url", "sha256", "digest_observed_at", "title", "quotes", "bindings"}
            | ({"prior_registry_sha256"} if "prior_registry_sha256" in source else set()),
        ):
            raise GateError("FC-SOURCE-SCHEMA")
        source_id = source["id"]
        if not _is_string(source_id) or not re.fullmatch(r"S[0-9]{3}", source_id) or source_id in source_index:
            raise GateError("FC-SOURCE-SCHEMA")
        if not _is_string(source["product"]) or not _is_string(source["title"]):
            raise GateError("FC-SOURCE-SCHEMA")
        if not _is_string(source["sha256"]) or not re.fullmatch(r"[0-9a-f]{64}", source["sha256"]):
            raise GateError("FC-SOURCE-SCHEMA")
        if "prior_registry_sha256" in source and not re.fullmatch(r"[0-9a-f]{64}", source["prior_registry_sha256"]):
            raise GateError("FC-SOURCE-SCHEMA")
        if not _is_string(source["digest_observed_at"]):
            raise GateError("FC-SOURCE-SCHEMA")
        if not _is_string(source["url"]) or not source["url"].startswith("https://"):
            raise GateError("FC-SOURCE-SCHEMA")
        quotes = source["quotes"]
        if type(quotes) is not list:
            raise GateError("FC-SOURCE-SCHEMA")
        quote_index: dict[str, dict[str, Any]] = {}
        for quote in quotes:
            if not _exact_keys(quote, {"id", "anchor", "text"}):
                raise GateError("FC-SOURCE-SCHEMA")
            quote_id = quote["id"]
            if not _is_string(quote_id) or quote_id in quote_index:
                raise GateError("FC-SOURCE-SCHEMA")
            if not _is_string(quote["anchor"]) or not _is_string(quote["text"]):
                raise GateError("FC-SOURCE-SCHEMA")
            if len(quote["text"].split()) > 25:
                raise GateError("FC-SOURCE-QUOTE-LIMIT")
            quote_index[quote_id] = quote
        bindings = source["bindings"]
        if type(bindings) is not list:
            raise GateError("FC-SOURCE-SCHEMA")
        for binding in bindings:
            if not _exact_keys(binding, {"feature", "field", "value", "quote_id"}):
                raise GateError("FC-SOURCE-SCHEMA")
            if not all(_is_string(binding[key]) for key in ("feature", "field", "value", "quote_id")):
                raise GateError("FC-SOURCE-SCHEMA")
            if binding["quote_id"] not in quote_index:
                raise GateError("FC-SOURCE-SCHEMA")
        source_index[source_id] = source
    return source_index


def _feature_value(feature: dict[str, Any], field: str) -> Any:
    if field == "product":
        return feature["product"]
    if field == "feature":
        return feature["id"]
    if field == "path":
        return feature["path"]
    if field == "release_status":
        return [] if feature["release_status"] == "not_asserted" else feature["release_status"]
    if field == "eligibility.plans":
        return feature["eligibility"]["plans"]
    if field == "eligibility.requirements":
        return feature["eligibility"]["requirements"]
    if field == "eligibility.documented_exclusions":
        return feature["eligibility"]["documented_exclusions"]
    if field == "runtime_constraints":
        return feature["runtime_constraints"]
    if field == "fact":
        return feature["facts"]
    raise GateError("FC-FEATURE-SCHEMA")


def _validate_feature_catalog(features: Any, source_index: dict[str, dict[str, Any]]) -> dict[str, dict[str, Any]]:
    if type(features) is not list or _canonical_digest(features) != PINNED_FEATURES_SHA256:
        raise GateError("FC-FEATURE-MANIFEST")
    feature_index: dict[str, dict[str, Any]] = {}
    required_feature_keys = {
        "id",
        "group",
        "product",
        "path",
        "release_status",
        "release_status_anchor",
        "eligibility",
        "runtime_constraints",
        "facts",
        "evidence_requirements",
    }
    for feature in features:
        if not _exact_keys(feature, required_feature_keys):
            raise GateError("FC-FEATURE-SCHEMA")
        feature_id = feature["id"]
        if not _is_string(feature_id) or feature_id in feature_index:
            raise GateError("FC-FEATURE-SCHEMA")
        if not all(_is_string(feature[key]) for key in ("group", "product", "path", "release_status", "release_status_anchor")):
            raise GateError("FC-FEATURE-SCHEMA")
        if not _exact_keys(feature["eligibility"], ELIGIBILITY_FIELDS):
            raise GateError("FC-FEATURE-SCHEMA")
        eligibility = feature["eligibility"]
        if eligibility["scope"] not in ("source_bounded", "not_assessed"):
            raise GateError("FC-FEATURE-SCHEMA")
        if any(type(eligibility[key]) is not list or any(not _is_string(item) for item in eligibility[key]) for key in ("plans", "requirements", "documented_exclusions")):
            raise GateError("FC-FEATURE-SCHEMA")
        if type(feature["runtime_constraints"]) is not list or any(not _is_string(item) for item in feature["runtime_constraints"]):
            raise GateError("FC-FEATURE-SCHEMA")
        if type(feature["facts"]) is not list or not feature["facts"] or any(not _is_string(item) for item in feature["facts"]):
            raise GateError("FC-FEATURE-SCHEMA")
        evidence = feature["evidence_requirements"]
        if not _exact_keys(evidence, EVIDENCE_FIELDS):
            raise GateError("FC-FEATURE-SCHEMA")
        for field, refs in evidence.items():
            if type(refs) is not list:
                raise GateError("FC-FEATURE-SCHEMA")
            for ref in refs:
                if type(ref) is not list or len(ref) != 2 or not all(_is_string(item) for item in ref):
                    raise GateError("FC-FEATURE-SCHEMA")
                if ref[0] not in source_index:
                    raise GateError("FC-FEATURE-SCHEMA")
        feature_index[feature_id] = feature

    for feature in feature_index.values():
        for field, refs in feature["evidence_requirements"].items():
            values = _feature_value(feature, field)
            expected_values = values if type(values) is list else [values]
            observed_values: set[str] = set()
            for source_id, quote_id in refs:
                source = source_index[source_id]
                quote_index = {quote["id"]: quote for quote in source["quotes"]}
                if quote_id not in quote_index:
                    raise GateError("FC-FEATURE-SCHEMA")
                source_values = {
                    binding["value"]
                    for binding in source["bindings"]
                    if binding["feature"] == feature["id"]
                    and binding["field"] == field
                    and binding["quote_id"] == quote_id
                }
                if not source_values:
                    raise GateError("FC-FEATURE-SCHEMA")
                observed_values.update(source_values)
            if not set(expected_values).issubset(observed_values):
                raise GateError("FC-FEATURE-SCHEMA")
            if not expected_values and refs:
                raise GateError("FC-FEATURE-SCHEMA")
        status = feature["release_status"]
        if status in ("public_preview", "public_beta"):
            anchors = {
                quote["anchor"]
                for source_id, quote_id in feature["evidence_requirements"]["release_status"]
                for quote in source_index[source_id]["quotes"]
                if quote["id"] == quote_id
            }
            if feature["release_status_anchor"] != "page-title-H1" or "page-title-H1" not in anchors:
                raise GateError("FC-STATUS-ANCHOR-PIN")
    return feature_index


def _diff_paths(before: Any, after: Any, prefix: str = "") -> list[str]:
    if type(before) is dict and type(after) is dict:
        paths: list[str] = []
        for key in sorted(set(before) | set(after)):
            current = f"{prefix}.{key}" if prefix else key
            if key not in before or key not in after:
                paths.append(current)
            else:
                paths.extend(_diff_paths(before[key], after[key], current))
        return paths
    if before != after:
        return [prefix]
    return []


def _record_reference_ok(record: dict[str, Any]) -> bool:
    authority = record["label_authority"]
    reference = record["reference"]
    if authority == "outside-verifier":
        return _exact_keys(reference, {"path", "sha256", "anchor", "quote"}) and re.fullmatch(r"[0-9a-f]{64}", reference["sha256"]) is not None
    if authority == "construction-rule":
        return _exact_keys(reference, {"rule"})
    if authority == "verbatim-pin":
        return _exact_keys(reference, {"path", "anchor"})
    return False


def _validate_controls(artifact: dict[str, Any]) -> tuple[dict[str, dict[str, Any]], dict[str, dict[str, Any]]]:
    records = artifact["records"]
    if type(records) is not list or _canonical_digest(records) != PINNED_RECORDS_SHA256:
        raise GateError("FC-RECORD-MANIFEST")
    record_index: dict[str, dict[str, Any]] = {}
    for record in records:
        if not _exact_keys(record, {"id", "phase", "label_authority", "defect_class", "expected_decision", "reference", "claim"}):
            raise GateError("FC-RECORD-SCHEMA")
        record_id = record["id"]
        if not _is_string(record_id) or not re.fullmatch(r"[A-Z0-9][A-Z0-9-]*", record_id) or record_id in record_index:
            raise GateError("FC-RECORD-SCHEMA")
        expectation = EXPECTED_RECORDS.get(record_id)
        actual_meta = (record["phase"], record["label_authority"], record["defect_class"], record["expected_decision"])
        if expectation is None or actual_meta != expectation:
            raise GateError("FC-RECORD-EXPECTATION")
        if record["label_authority"] not in AUTHORITY_CLASSES or not _record_reference_ok(record):
            raise GateError("FC-RECORD-REFERENCE")
        record_index[record_id] = record
    if set(record_index) != set(EXPECTED_RECORDS):
        raise GateError("FC-RECORD-SET")

    transitions = artifact["transitions"]
    if type(transitions) is not list or _canonical_digest(transitions) != PINNED_TRANSITIONS_SHA256:
        raise GateError("FC-TRANSITION-MANIFEST")
    transition_index: dict[str, dict[str, Any]] = {}
    for transition in transitions:
        if not _exact_keys(transition, {"id", "before_record", "after_record", "expected_before", "expected_after", "allowed_delta_paths"}):
            raise GateError("FC-TRANSITION-SCHEMA")
        transition_id = transition["id"]
        if not _is_string(transition_id) or transition_id in transition_index:
            raise GateError("FC-TRANSITION-SCHEMA")
        expected = EXPECTED_TRANSITIONS.get(transition_id)
        if expected is None:
            raise GateError("FC-TRANSITION-EXPECTATION")
        before_id, after_id, expected_before, expected_after, delta_paths = expected
        actual = (
            transition["before_record"],
            transition["after_record"],
            transition["expected_before"],
            transition["expected_after"],
            tuple(transition["allowed_delta_paths"]) if type(transition["allowed_delta_paths"]) is list else (),
        )
        if actual != expected:
            raise GateError("FC-TRANSITION-EXPECTATION")
        if before_id not in record_index or after_id not in record_index:
            raise GateError("FC-TRANSITION-REFERENCE")
        before_record = record_index[before_id]
        after_record = record_index[after_id]
        if before_record["expected_decision"] != expected_before or after_record["expected_decision"] != expected_after:
            raise GateError("FC-TRANSITION-EXPECTATION")
        actual_deltas = tuple(_diff_paths(before_record["claim"], after_record["claim"]))
        if actual_deltas != delta_paths:
            raise GateError("FC-TRANSITION-DELTA")
        transition_index[transition_id] = transition
    if set(transition_index) != set(EXPECTED_TRANSITIONS):
        raise GateError("FC-TRANSITION-SET")
    used_records = {
        record_id
        for transition in transitions
        for record_id in (transition["before_record"], transition["after_record"])
    }
    if used_records != set(record_index):
        raise GateError("FC-RECORD-ORPHAN")

    boundaries = artifact["boundary_records"]
    if type(boundaries) is not list or _canonical_digest(boundaries) != PINNED_BOUNDARY_SHA256:
        raise GateError("FC-BOUNDARY-MANIFEST")
    boundary_index: dict[str, dict[str, Any]] = {}
    for record in boundaries:
        if not _exact_keys(record, {"id", "label_authority", "defect_class", "claim"}):
            raise GateError("FC-BOUNDARY-SCHEMA")
        record_id = record["id"]
        if not _is_string(record_id) or record_id not in EXPECTED_BOUNDARY_IDS or record_id in boundary_index:
            raise GateError("FC-BOUNDARY-SET")
        if record["label_authority"] != "author" or record["defect_class"] != "unjudgeable-scope-boundary":
            raise GateError("FC-BOUNDARY-EXPECTATION")
        boundary_index[record_id] = record
    if set(boundary_index) != set(EXPECTED_BOUNDARY_IDS):
        raise GateError("FC-BOUNDARY-SET")
    return record_index, boundary_index


def _claim_field_value(claim: dict[str, Any], field: str) -> Any:
    if field == "product":
        return claim.get("product")
    if field == "feature":
        return claim.get("feature")
    if field == "path":
        return claim.get("path")
    if field == "release_status":
        return [] if claim.get("release_status") == "not_asserted" else claim.get("release_status")
    if field == "eligibility.plans":
        return claim["eligibility"]["plans"]
    if field == "eligibility.requirements":
        return claim["eligibility"]["requirements"]
    if field == "eligibility.documented_exclusions":
        return claim["eligibility"]["documented_exclusions"]
    if field == "runtime_constraints":
        return claim["runtime_constraints"]
    if field == "fact":
        return claim.get("fact")
    raise GateError("FC-EVIDENCE-FIELD")


def _source_quote_index(source: dict[str, Any]) -> dict[str, dict[str, Any]]:
    return {quote["id"]: quote for quote in source["quotes"]}


def _decision(kind: str, finding: str) -> tuple[str, str]:
    return kind, finding


def _evaluate_claim(
    claim: Any,
    feature_index: dict[str, dict[str, Any]],
    source_index: dict[str, dict[str, Any]],
) -> tuple[str, str]:
    if type(claim) is not dict:
        return _decision("cannot-evaluate", "FC-CLAIM-SHAPE")
    unknown_claim_fields = set(claim) - CLAIM_FIELDS
    if unknown_claim_fields:
        return _decision("cannot-evaluate", "FC-UNKNOWN-FIELD")
    feature_id = claim.get("feature")
    if not _is_string(feature_id):
        return _decision("cannot-evaluate", "FC-MISSING-FEATURE")
    feature = feature_index.get(feature_id)
    if feature is None:
        return _decision("cannot-evaluate", "FC-UNKNOWN-FEATURE")
    if not _is_string(claim.get("product")):
        return _decision("cannot-evaluate", "FC-MISSING-PRODUCT")
    if claim["product"] != feature["product"]:
        return _decision("reject:false-claim", "FC-PRODUCT-MISMATCH")
    if not _is_string(claim.get("path")):
        return _decision("reject:bar-fail", "FC-PATH-QUALIFIER")
    if claim["path"] != feature["path"]:
        return _decision("reject:false-claim", "FC-PATH-MISMATCH")
    if not _is_string(claim.get("release_status")):
        return _decision("reject:bar-fail", "FC-STATUS-QUALIFIER")
    if claim["release_status"] != feature["release_status"]:
        if feature["release_status"] == "not_asserted":
            return _decision("reject:bar-fail", "FC-STATUS-UNSUPPORTED")
        return _decision("reject:false-claim", "FC-STATUS-MISMATCH")
    eligibility = claim.get("eligibility")
    if eligibility is None:
        return _decision("reject:bar-fail", "FC-ELIGIBILITY-QUALIFIER")
    if type(eligibility) is not dict:
        return _decision("cannot-evaluate", "FC-ELIGIBILITY-SHAPE")
    if set(eligibility) - ELIGIBILITY_FIELDS:
        return _decision("cannot-evaluate", "FC-UNKNOWN-FIELD")
    if set(eligibility) != ELIGIBILITY_FIELDS:
        return _decision("reject:bar-fail", "FC-ELIGIBILITY-QUALIFIER")
    if not _is_string(eligibility["scope"]) or any(
        not _unique_string_list(eligibility[field])
        for field in ("plans", "requirements", "documented_exclusions")
    ):
        return _decision("cannot-evaluate", "FC-ELIGIBILITY-SHAPE")
    expected_eligibility = feature["eligibility"]
    if eligibility["scope"] != expected_eligibility["scope"] or any(
        set(eligibility[field]) != set(expected_eligibility[field])
        for field in ("plans", "requirements", "documented_exclusions")
    ):
        return _decision("reject:bar-fail", "FC-ELIGIBILITY-QUALIFIER")
    if "runtime_constraints" not in claim:
        return _decision("reject:bar-fail", "FC-RUNTIME-CONSTRAINT")
    if not _unique_string_list(claim["runtime_constraints"]):
        return _decision("cannot-evaluate", "FC-RUNTIME-CONSTRAINT-SHAPE")
    if set(claim["runtime_constraints"]) != set(feature["runtime_constraints"]):
        return _decision("reject:bar-fail", "FC-RUNTIME-CONSTRAINT")
    fact = claim.get("fact")
    if not _is_string(fact):
        return _decision("reject:bar-fail", "FC-FACT-QUALIFIER")
    if fact not in feature["facts"]:
        return _decision("reject:bar-fail", "FC-FACT-UNSUPPORTED")
    evidence = claim.get("evidence")
    if evidence is None:
        return _decision("reject:bar-fail", "FC-EVIDENCE-MISSING")
    if type(evidence) is not dict:
        return _decision("cannot-evaluate", "FC-EVIDENCE-SHAPE")
    if set(evidence) - EVIDENCE_FIELDS:
        return _decision("cannot-evaluate", "FC-UNKNOWN-FIELD")
    if set(evidence) != EVIDENCE_FIELDS:
        return _decision("reject:bar-fail", "FC-EVIDENCE-MISSING")

    for field, references in evidence.items():
        if type(references) is not list:
            return _decision("cannot-evaluate", "FC-EVIDENCE-SHAPE")
        value = _claim_field_value(claim, field)
        values = set(value) if type(value) is list else {value}
        observed_values: set[str] = set()
        reference_set: set[tuple[str, str]] = set()
        for reference in references:
            if type(reference) is not list or len(reference) != 2 or not all(_is_string(part) for part in reference):
                return _decision("cannot-evaluate", "FC-EVIDENCE-SHAPE")
            reference_key = (reference[0], reference[1])
            if reference_key in reference_set:
                return _decision("cannot-evaluate", "FC-EVIDENCE-SHAPE")
            reference_set.add(reference_key)
            source_id, quote_id = reference_key
            source = source_index.get(source_id)
            if source is None:
                return _decision("cannot-evaluate", "FC-UNKNOWN-SOURCE")
            quote_index = _source_quote_index(source)
            if quote_id not in quote_index:
                return _decision("cannot-evaluate", "FC-UNKNOWN-QUOTE")
            if source["product"] != feature["product"]:
                return _decision("reject:bar-fail", "FC-CROSS-PRODUCT")
            bindings = [
                binding
                for binding in source["bindings"]
                if binding["feature"] == feature_id
                and binding["field"] == field
                and binding["quote_id"] == quote_id
            ]
            bound_values = {binding["value"] for binding in bindings}
            if not bound_values.intersection(values):
                reason = "FC-EVIDENCE-ANCHOR" if field == "release_status" else "FC-EVIDENCE-BINDING"
                return _decision("reject:bar-fail", reason)
            observed_values.update(bound_values)
        if not values.issubset(observed_values):
            return _decision("reject:bar-fail", "FC-EVIDENCE-BINDING")
        required_references = {
            (source_id, quote_id)
            for source_id, quote_id in feature["evidence_requirements"][field]
        }
        if reference_set != required_references:
            reason = "FC-EVIDENCE-ANCHOR" if field == "release_status" else "FC-EVIDENCE-MISSING"
            return _decision("reject:bar-fail", reason)
    return _decision("admit", "FC-ADMITTED")


def _artifact(data: bytes) -> tuple[dict[str, Any], dict[str, dict[str, Any]], dict[str, dict[str, Any]], dict[str, dict[str, Any]]]:
    value = _load_json(data)
    if set(value) != {"schema", "review", "sources", "features", "records", "transitions", "boundary_records"}:
        raise GateError("FC-INPUT-SCHEMA")
    if value["schema"] != SCHEMA:
        raise GateError("FC-INPUT-SCHEMA")
    if _canonical_digest(value["review"]) != PINNED_REVIEW_SHA256:
        raise GateError("FC-REVIEW-PIN")
    source_index = _validate_source_catalog(value["sources"])
    feature_index = _validate_feature_catalog(value["features"], source_index)
    record_index, boundary_index = _validate_controls(value)
    return value, source_index, feature_index, {**record_index, **boundary_index}


def _safe_identifier(value: str) -> str:
    if re.fullmatch(r"[A-Z0-9][A-Z0-9-]*", value):
        return value
    return "INVALID"


def _metric_cells(
    rows: list[tuple[str, str, str, str, str]],
) -> tuple[int, int, int, int, int]:
    matches = false_admissions = misses = misclassified = unjudgeable = 0
    for expected, actual, _authority, _defect, _finding in rows:
        if actual == "cannot-evaluate":
            unjudgeable += 1
        elif actual == expected:
            matches += 1
        elif expected.startswith("reject:") and actual == "admit":
            false_admissions += 1
        elif expected == "admit" and actual.startswith("reject:"):
            misses += 1
        else:
            misclassified += 1
    return matches, false_admissions, misses, misclassified, unjudgeable


def _run_phase(
    phase: str,
    records: dict[str, dict[str, Any]],
    boundary_records: dict[str, dict[str, Any]],
    feature_index: dict[str, dict[str, Any]],
    source_index: dict[str, dict[str, Any]],
) -> int:
    if phase == "boundary":
        outcomes: list[tuple[str, str]] = []
        for record_id in sorted(boundary_records):
            decision, finding = _evaluate_claim(boundary_records[record_id]["claim"], feature_index, source_index)
            print(f"BOUNDARY id={record_id} actual={decision} finding={finding} scored=no")
            expected_finding = EXPECTED_BOUNDARY_IDS[record_id]
            if decision != "cannot-evaluate" or finding != expected_finding:
                print("FEATURE_CLAIMS: FAILED phase=boundary finding=FC-BOUNDARY-DECISION")
                return 1
            outcomes.append((decision, finding))
        first_finding = outcomes[0][1] if outcomes else "FC-BOUNDARY-EMPTY"
        print(f"FEATURE_CLAIMS: CANNOT_EVALUATE phase=boundary unjudgeable={len(outcomes)} finding={first_finding}")
        return 2

    selected = [record for record in records.values() if record["phase"] == phase]
    if not selected:
        raise GateError("FC-PHASE-EMPTY")
    rows: list[tuple[str, str, str, str, str]] = []
    actual_counts = {"admit": 0, "reject:false-claim": 0, "reject:bar-fail": 0, "cannot-evaluate": 0}
    failed = False
    for record in sorted(selected, key=lambda item: item["id"]):
        actual, finding = _evaluate_claim(record["claim"], feature_index, source_index)
        expected = record["expected_decision"]
        actual_counts[actual] += 1
        rows.append((expected, actual, record["label_authority"], record["defect_class"], finding))
        print(
            f"DECISION id={_safe_identifier(record['id'])} authority={record['label_authority']} "
            f"class={record['defect_class']} expected={expected} actual={actual} finding={finding}"
        )
        if actual != expected:
            failed = True
    cell_keys = sorted({(row[2], row[3], row[0]) for row in rows})
    for authority, defect, expected in cell_keys:
        cell_rows = [row for row in rows if (row[2], row[3], row[0]) == (authority, defect, expected)]
        matches, false_admissions, misses, misclassified, unjudgeable = _metric_cells(cell_rows)
        print(
            f"CELL authority={authority} defect={defect} target={expected} matches={matches} "
            f"false_admissions={false_admissions} misses={misses} misclassified={misclassified} "
            f"unjudgeable={unjudgeable}"
        )
    unknown_count = actual_counts["cannot-evaluate"]
    first_finding = next((row[4] for row in rows if row[1] != "admit"), "FC-ADMITTED")
    if unknown_count:
        print(
            f"FEATURE_CLAIMS: CANNOT_EVALUATE phase={phase} false_claims={actual_counts['reject:false-claim']} "
            f"bar_failures={actual_counts['reject:bar-fail']} unjudgeable={unknown_count} finding={first_finding}"
        )
        return 2
    if phase == "before" or failed or actual_counts["reject:false-claim"] or actual_counts["reject:bar-fail"]:
        print(
            f"FEATURE_CLAIMS: FAILED phase={phase} false_claims={actual_counts['reject:false-claim']} "
            f"bar_failures={actual_counts['reject:bar-fail']} false_admissions={sum(1 for row in rows if row[0].startswith('reject:') and row[1] == 'admit')} "
            f"misses={sum(1 for row in rows if row[0] == 'admit' and row[1].startswith('reject:'))} finding={first_finding}"
        )
        return 1
    print(
        f"FEATURE_CLAIMS: CLEAN phase={phase} admitted={actual_counts['admit']} "
        f"false_claims={actual_counts['reject:false-claim']} bar_failures={actual_counts['reject:bar-fail']} "
        "false_admissions=0 misses=0 unjudgeable=0"
    )
    return 0
def _run_input(data: bytes, feature_index: dict[str, dict[str, Any]], source_index: dict[str, dict[str, Any]]) -> int:
    claim = _load_json(data)
    decision, finding = _evaluate_claim(claim, feature_index, source_index)
    if decision == "admit":
        print(f"FEATURE_CLAIMS: ADMIT finding={finding}")
        return 0
    if decision.startswith("reject:"):
        print(f"FEATURE_CLAIMS: REJECT decision={decision} finding={finding}")
        return 1
    print(f"FEATURE_CLAIMS: CANNOT_EVALUATE finding={finding}")
    return 2




def _invoke(
    script: Path,
    root: Path,
    *args: str,
    timeout_seconds: float = 20.0,
) -> subprocess.CompletedProcess[str]:
    try:
        return subprocess.run(
            [sys.executable, str(script), "--root", str(root), *args],
            cwd=str(root),
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
            timeout=timeout_seconds,
            check=False,
            close_fds=True,
        )
    except (OSError, subprocess.SubprocessError):
        raise GateError("FC-SELFTEST-INVOKE") from None


def _selftest(root: Path, claims_arg: str | None) -> int:
    if claims_arg is not None:
        raise GateError("FC-SELFTEST-ARGS")
    raw = _read_beneath(root, _relative_claims_path(root, None))
    artifact, _, _, _ = _artifact(raw)
    records = {record["id"]: record["claim"] for record in artifact["records"]}
    script = Path(__file__).resolve(strict=True)
    cases = 0
    failures = 0
    with tempfile.TemporaryDirectory(prefix="feature-claims-selftest-") as temporary:
        fixture_root = Path(temporary)
        fixture_claims = fixture_root / "corpus" / "feature-claims.json"
        fixture_claims.parent.mkdir(parents=True)
        fixture_claims.write_bytes(raw)

        valid_claim = copy.deepcopy(records["AFTER-CUSTOM-BETA-BOUNDED"])
        eligibility_omission = copy.deepcopy(records["BEFORE-E1-ELIGIBILITY"])
        status_swap = copy.deepcopy(records["BEFORE-SAME-PAGE-PREVIEW"])
        cross_product = copy.deepcopy(records["BEFORE-E3-VAULT-ONLY"])
        under_cited = copy.deepcopy(records["BEFORE-CUSTOM-UNDERCITED"])
        permuted = copy.deepcopy(valid_claim)
        permuted["eligibility"]["requirements"].reverse()
        permuted["runtime_constraints"].reverse()
        permuted["evidence"]["release_status"].reverse()
        permuted["evidence"]["runtime_constraints"].reverse()

        input_dir = fixture_root / "corpus" / "inputs"
        input_dir.mkdir(parents=True)
        fifo_claims = input_dir / "claims-fifo"
        fifo_input = input_dir / "input-fifo"
        os.mkfifo(fifo_claims)
        os.mkfifo(fifo_input)
        input_cases = [
            ("input-valid", valid_claim, 0, ("FEATURE_CLAIMS: ADMIT",)),
            ("input-eligibility-omission", eligibility_omission, 1, ("FC-ELIGIBILITY-QUALIFIER",)),
            ("input-same-page-status", status_swap, 1, ("FC-STATUS-MISMATCH",)),
            ("input-cross-product", cross_product, 1, ("FC-CROSS-PRODUCT",)),
            ("input-guide-only-undercited", under_cited, 1, ("FC-EVIDENCE-ANCHOR",)),
            ("input-permuted-sets", permuted, 0, ("FEATURE_CLAIMS: ADMIT",)),
        ]
        invocations = [
            ("after", ("--claims", "corpus/feature-claims.json", "--phase", "after"), 0, ("FEATURE_CLAIMS: CLEAN phase=after",)),
            ("before", ("--claims", "corpus/feature-claims.json", "--phase", "before"), 1, ("FC-STATUS-MISMATCH", "FC-ELIGIBILITY-QUALIFIER", "FC-CROSS-PRODUCT", "FC-EVIDENCE-ANCHOR")),
            ("boundary", ("--claims", "corpus/feature-claims.json", "--phase", "boundary"), 2, ("FC-UNKNOWN-FEATURE", "FC-UNKNOWN-FIELD", "FC-UNKNOWN-SOURCE")),
            ("input-path-escape", ("--input", "../outside.json"), 2, ("FC-CLAIMS-PATH",)),
            ("claims-fifo", ("--claims", "corpus/inputs/claims-fifo"), 2, ("FC-CLAIMS-FILE",)),
            ("input-fifo", ("--input", "corpus/inputs/input-fifo"), 2, ("FC-CLAIMS-FILE",)),
        ]
        for case_id, claim, expected_exit, markers in input_cases:
            input_path = input_dir / f"{case_id}.json"
            input_path.write_text(json.dumps(claim, ensure_ascii=False) + "\n", encoding="utf-8")
            relative_input = f"corpus/inputs/{case_id}.json"
            invocations.append(
                (
                    case_id,
                    ("--claims", "corpus/feature-claims.json", "--input", relative_input),
                    expected_exit,
                    markers,
                )
            )
        for case_id, arguments, expected_exit, markers in invocations:
            timeout_seconds = 1.0 if case_id in ("claims-fifo", "input-fifo") else 20.0
            result = _invoke(script, fixture_root, *arguments, timeout_seconds=timeout_seconds)
            cases += 1
            if result.returncode != expected_exit or any(marker not in result.stdout for marker in markers):
                failures += 1
                print(f"SELFTEST_CASE id={case_id} finding=FC-SELFTEST-ASSERTION")
    if failures:
        print(f"FEATURE_CLAIMS_SELFTEST: FAIL cases={cases} failed={failures} finding=FC-SELFTEST-ASSERTION")
        return 1
    print(f"FEATURE_CLAIMS_SELFTEST: PASS cases={cases}")
    return 0




def _parse_args(arguments: list[str]) -> tuple[str | None, str | None, str | None, str, bool, bool]:
    root: str | None = None
    claims: str | None = None
    input_claim: str | None = None
    phase = "after"
    selftest = False
    help_requested = False
    index = 0
    seen: set[str] = set()
    while index < len(arguments):
        token = arguments[index]
        if token in ("-h", "--help"):
            help_requested = True
            index += 1
            continue
        if token == "--selftest":
            if "selftest" in seen:
                raise GateError("FC-CLI")
            seen.add("selftest")
            selftest = True
            index += 1
            continue
        name, separator, inline_value = token.partition("=")
        if name in ("--root", "--claims", "--input", "--phase"):
            if name in seen:
                raise GateError("FC-CLI")
            seen.add(name)
            if separator:
                value = inline_value
            else:
                index += 1
                if index >= len(arguments):
                    raise GateError("FC-CLI")
                value = arguments[index]
            if not value or value.startswith("--"):
                raise GateError("FC-CLI")
            if name == "--root":
                root = value
            elif name == "--claims":
                claims = value
            elif name == "--input":
                input_claim = value
            else:
                phase = value
            index += 1
            continue
        raise GateError("FC-CLI")
    if help_requested and (seen or selftest):
        raise GateError("FC-CLI")
    if phase not in ("before", "after", "boundary"):
        raise GateError("FC-CLI")
    if input_claim is not None and "--phase" in seen:
        raise GateError("FC-CLI")
    if selftest and (claims is not None or input_claim is not None or phase != "after"):
        raise GateError("FC-SELFTEST-ARGS")
    return root, claims, input_claim, phase, selftest, help_requested


def _print_help() -> None:
    print("Usage: python3 corpus/feature-claims.py [--root DIR] [--claims PATH] [--input CLAIM.json | --phase before|after|boundary] [--selftest]")
    print("--claims selects the pinned review artifact; --input selects one typed claim beneath --root.")
    print("Without --input, default phase is after; before replays bad records; boundary returns cannot-evaluate separately.")


def main(arguments: list[str] | None = None) -> int:
    try:
        root_arg, claims_arg, input_arg, phase, selftest, help_requested = _parse_args(
            sys.argv[1:] if arguments is None else arguments
        )
        if help_requested:
            _print_help()
            return 0
        root = _root_path(root_arg)
        if selftest:
            return _selftest(root, claims_arg)
        relative = _relative_claims_path(root, claims_arg)
        raw = _read_beneath(root, relative)
        _, sources, features, record_sets = _artifact(raw)
        if input_arg is not None:
            input_data = _read_beneath(root, _relative_claims_path(root, input_arg))
            return _run_input(input_data, features, sources)
        records = {key: value for key, value in record_sets.items() if key in EXPECTED_RECORDS}
        boundaries = {key: value for key, value in record_sets.items() if key in EXPECTED_BOUNDARY_IDS}
        return _run_phase(phase, records, boundaries, features, sources)
    except GateError as error:
        print(f"FEATURE_CLAIMS: CANNOT_EVALUATE finding={error.finding}")
        return 2




if __name__ == "__main__":
    raise SystemExit(main())
