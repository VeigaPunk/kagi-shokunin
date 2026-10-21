#!/usr/bin/env python3
"""Check and observe release clocks bound to SOURCES.md recheck rows."""
import argparse
import contextlib
import datetime as dt
import hashlib
import http.client
import importlib.util
import ipaddress
import io
import json
import os
import re
import socket
import stat
import sys
import tempfile
import urllib.error
import urllib.parse
import urllib.request
import xml.etree.ElementTree as ET
from pathlib import Path

HEADER = (
    "id", "clock", "feed_source_id", "feed_url", "anchored_version",
    "observed_version", "observed_at", "verdict", "note",
)
DEFAULT_RECEIPT_SHA256 = "13b8540c78b9de07bc184894583a368472fd1f2f04a898220bf7c29d2648a169"
SOURCE_ID_RE = re.compile(r"S[0-9]{3}")
VERSION_RE = re.compile(
    r"(?<![A-Za-z0-9.])v?([0-9]+\.[0-9]+(?:\.[0-9]+)*(?:[-+][0-9A-Za-z.-]+)?)(?![A-Za-z0-9.])",
    re.IGNORECASE,
)
QUOTE_RE = re.compile(r"“([^”]+)”|(?<!\\)\"([^\"\n]+)\"")
USER_AGENT = "kagi-shokunin-round25/1.0 (documentation verification)"
MAX_BODY_BYTES = 8 * 1024 * 1024
MAX_REDIRECTS = 5
MAX_XML_ELEMENTS = 100_000
MAX_FEED_ENTRIES = 5_000


class SetupError(Exception):
    """An unavailable or malformed input/configuration, not a failed claim."""


def setup(message):
    raise SetupError(message)


def source_url(source_cell):
    match = re.search(r"https?://[^\s<>|]+", source_cell, re.IGNORECASE)
    if not match:
        return None
    value = match.group(0).rstrip(".,;)")
    return safe_receipt_url(value) if valid_public_https_url(value) else None


def parse_sources(root):
    path = root / "corpus" / "SOURCES.md"
    try:
        text = path.read_text(encoding="utf-8")
    except OSError as exc:
        setup("cannot read corpus/SOURCES.md: %s" % exc.__class__.__name__)
    except UnicodeError:
        setup("corpus/SOURCES.md is not UTF-8")

    result = {}
    for line_number, line in enumerate(text.splitlines(), 1):
        stripped = line.strip()
        if not stripped.startswith("|"):
            continue
        cells = stripped[1:].split("|")
        if cells and not cells[-1].strip():
            cells.pop()
        cells = [cell.strip() for cell in cells]
        if not cells or not SOURCE_ID_RE.fullmatch(cells[0]):
            continue
        if len(cells) != 11:
            setup("corpus/SOURCES.md:%d has %d fields, expected 11" %
                  (line_number, len(cells)))
        source_id = cells[0]
        if source_id in result:
            setup("corpus/SOURCES.md:%d duplicates %s" % (line_number, source_id))
        result[source_id] = {
            "id": source_id,
            "url": source_url(cells[1]),
            "kind": cells[2],
            "anchor": cells[5],
            "teaches": cells[6],
            "opened": cells[8],
            "recheck": cells[9],
            "line": line_number,
        }
    if not result:
        setup("no SOURCES.md registry rows found")
    return result


def parse_bindings(root):
    path = root / "corpus" / "release-clocks.tsv"
    if not path.exists():
        return []
    try:
        lines = path.read_text(encoding="utf-8").splitlines()
    except OSError as exc:
        setup("cannot read corpus/release-clocks.tsv: %s" % exc.__class__.__name__)
    except UnicodeError:
        setup("corpus/release-clocks.tsv is not UTF-8")
    if not lines:
        setup("corpus/release-clocks.tsv is empty; expected header")
    if tuple(lines[0].split("\t")) != HEADER:
        setup("corpus/release-clocks.tsv has an unexpected header")

    rows = []
    for line_number, line in enumerate(lines[1:], 2):
        if not line.strip() or line.lstrip().startswith("#"):
            continue
        fields = [field.strip() for field in line.split("\t")]
        row_id = fields[0] if fields and fields[0] else "row-%d" % line_number
        rows.append({
            "id": row_id,
            "fields": fields,
            "line": line_number,
            "malformed": len(fields) != len(HEADER),
        })
    return rows


def parse_captures(root):
    """Declared capture quote + locate profile per id (corpus/source-fetches.tsv).

    The capture row is the single declared quote for a source; the registry's
    teaches cell may carry markdown (backticks) that never locates in a page.
    """
    path = root / "corpus" / "source-fetches.tsv"
    if not path.exists():
        return {}
    try:
        lines = path.read_text(encoding="utf-8").splitlines()
    except OSError as exc:
        setup("cannot read corpus/source-fetches.tsv: %s" % exc.__class__.__name__)
    except UnicodeError:
        setup("corpus/source-fetches.tsv is not UTF-8")
    captures = {}
    for line in lines:
        if not line.strip() or line.startswith("#"):
            continue
        fields = line.split("\t")
        if len(fields) != 16:
            setup("corpus/source-fetches.tsv row has %d fields, expected 16" % len(fields))
        captures[fields[0]] = (fields[12], fields[13])
    return captures


def path_carries_secret(path):
    parts = [urllib.parse.unquote(part).lower() for part in path.split("/") if part]
    secret_routes = {
        "access_token", "api_key", "apikey", "id_token", "oauth_token",
        "session", "session_id", "sessionid", "token",
    }
    for index, part in enumerate(parts):
        if part in secret_routes and index + 1 < len(parts) and len(parts[index + 1]) >= 8:
            return True
        if re.fullmatch(r"[0-9a-f]{32,}", part):
            return True
        # a long token-shaped segment; a hyphenated word slug such as
        # `1password-credential-broker-public-preview` (S006/S020) is not one
        if (re.fullmatch(r"[a-z0-9_-]{40,}", part)
                and max(len(piece) for piece in part.split("-")) >= 20):
            return True
        if len(part.split(".")) == 3 and all(len(piece) >= 8 for piece in part.split(".")):
            return True
    return False


def valid_public_https_url(value):
    if not isinstance(value, str):
        return False
    try:
        parsed = urllib.parse.urlsplit(value)
        if (parsed.scheme.lower() != "https" or not parsed.hostname
                or parsed.username is not None or parsed.password is not None
                or parsed.query or path_carries_secret(parsed.path)):
            return False
        port = parsed.port
        if port not in (None, 443):
            return False
        host = parsed.hostname.lower().rstrip(".")
        if host == "localhost" or host.endswith((".localhost", ".local")):
            return False
        try:
            if not ipaddress.ip_address(host).is_global:
                return False
        except ValueError:
            pass
        if host.endswith(("1password.com", "1password.dev")):
            labels = host.split(".")
            if any(label in ("account", "app", "auth", "login", "my", "signin", "sign-in", "vault")
                   for label in labels[:-2]):
                return False
            path_parts = {
                urllib.parse.unquote(part).lower()
                for part in parsed.path.split("/") if part
            }
            if path_parts.intersection({
                    "account", "accounts", "app", "auth", "login", "my",
                    "session", "sessions", "signin", "sign-in", "vault"}):
                return False
        return True
    except (TypeError, ValueError):
        return False


def safe_receipt_url(value):
    if not isinstance(value, str):
        return None
    try:
        parsed = urllib.parse.urlsplit(value)
        if not parsed.hostname:
            return None
        host = parsed.hostname.lower().rstrip(".")
        if ":" in host:
            host = "[%s]" % host
        port = parsed.port
        authority = host + ((":%d" % port) if port is not None else "")
        path = "" if path_carries_secret(parsed.path) else parsed.path
        return urllib.parse.urlunsplit(
            (parsed.scheme.lower(), authority, path, "", "")
        )
    except (TypeError, ValueError):
        return None


def redirect_allowed(value, allowed_origin, initial_url):
    if not valid_public_https_url(value) or url_origin(value) != allowed_origin:
        return False
    parsed = urllib.parse.urlsplit(value)
    path = urllib.parse.unquote(parsed.path).lower()
    blocked = {
        "account", "accounts", "auth", "authorize", "authorization",
        "login", "oauth", "session", "sessions", "sign-in", "signin", "sso",
    }
    parts = [part.split(".", 1)[0] for part in re.split(r"[/;]+", path) if part]
    if any(part in blocked for part in parts):
        return False
    if parsed.hostname.lower().endswith(("1password.com", "1password.dev")):
        original = urllib.parse.urlsplit(initial_url)
        if path.rstrip("/") != urllib.parse.unquote(original.path).lower().rstrip("/"):
            return False
    return True

class PinnedHTTPSConnection(http.client.HTTPSConnection):
    """Connect to validated addresses while retaining the URL host for TLS SNI."""

    def __init__(self, host, addresses, **kwargs):
        self.validated_addresses = tuple(addresses)
        super().__init__(host, **kwargs)

    def _connect_pinned(self, address, timeout, source_address):
        last_error = None
        for ip_address_value in self.validated_addresses:
            try:
                return socket.create_connection(
                    (ip_address_value, self.port), timeout, source_address
                )
            except OSError as exc:
                last_error = exc
        if last_error is not None:
            raise last_error
        raise OSError("no validated addresses")

    def connect(self):
        create_connection = self._create_connection
        self._create_connection = self._connect_pinned
        try:
            super().connect()
        finally:
            self._create_connection = create_connection


class PinnedHTTPSHandler(urllib.request.HTTPSHandler):
    def __init__(self, addresses):
        super().__init__()
        self.validated_addresses = tuple(addresses)

    def https_open(self, request):
        addresses = self.validated_addresses
        connection_factory = lambda host, **kwargs: PinnedHTTPSConnection(
            host, addresses, **kwargs
        )
        return self.do_open(
            connection_factory, request, context=self._context
        )


def make_public_opener(addresses):
    return urllib.request.build_opener(
        urllib.request.ProxyHandler({}),
        NoRedirectHandler(),
        PinnedHTTPSHandler(addresses),
    )


def url_origin(value):
    parsed = urllib.parse.urlsplit(value)
    return parsed.scheme.lower(), parsed.hostname.lower(), parsed.port or 443


def public_addresses(value, resolver=None):
    parsed = urllib.parse.urlsplit(value)
    resolver = resolver or socket.getaddrinfo
    try:
        records = resolver(
            parsed.hostname, parsed.port or 443, type=socket.SOCK_STREAM
        )
    except (OSError, ValueError):
        return None, "host lookup failed"
    if not records:
        return None, "host lookup returned no addresses"
    addresses = []
    for record in records:
        try:
            address = ipaddress.ip_address(record[4][0])
        except (IndexError, TypeError, ValueError):
            return None, "host lookup returned an invalid address"
        if not address.is_global:
            return None, "host resolves to a non-public address"
        normalized = str(address)
        if normalized not in addresses:
            addresses.append(normalized)
    return tuple(addresses), None


def valid_iso_date(value):
    try:
        return dt.date.fromisoformat(value).isoformat() == value
    except (TypeError, ValueError):
        return False


def version_is_named(anchor, version):
    if not version or version == "-":
        return False
    version = version[1:] if version[:1].lower() == "v" else version
    pattern = r"(?<![A-Za-z0-9.])v?%s(?![A-Za-z0-9.])" % re.escape(version)
    return re.search(pattern, anchor, re.IGNORECASE) is not None


def extract_quotes(teaches):
    quotes = []
    for match in QUOTE_RE.finditer(teaches):
        quote = match.group(1) or match.group(2)
        if quote.strip():
            quotes.append(quote)
    return quotes


FEED_KINDS = ("docs", "code", "dataset")
LOCATE_PROFILES = ("rendered-text-v1", "raw-literal-v1")


def norm_version(value):
    return value[1:] if value[:1].lower() == "v" else value


NUMERIC_VERSION_RE = re.compile(r"[0-9]+\.[0-9]+\.[0-9]+")


def numeric_version(value):
    """Strict X.Y.Z (optional leading v) as an int tuple, else None.

    SemVer 2.0.0 §11.2 (S042) / PyPA release segments (S043): cores compare
    numerically. Non-numeric anchors (e.g. `v1.21.x`), two-component or series
    anchors and prerelease/build suffixes are not ordered here; alone they keep
    the inequality rule, a declared limit (corpus/lessons/round-27.md §C2).
    """
    value = norm_version(value or "")
    if not NUMERIC_VERSION_RE.fullmatch(value):
        return None
    return tuple(int(part) for part in value.split("."))


def is_regression(floor, observed):
    """True when both are strict X.Y.Z and the observation is numerically older."""
    anchor = numeric_version(floor)
    seen = numeric_version(observed)
    return anchor is not None and seen is not None and seen < anchor


def feed_floors(rows):
    """Highest strict X.Y.Z anchor per feed URL over well-formed feed rows.

    Rows sharing one feed (S027/S028/S040/S041 on python.org) observe the same
    stream, so an observation below ANY numeric anchor on that feed is older
    than a release already recorded: this catches an un-fire back to an older
    anchor (the fired 3.15.0 rows re-reading 3.15.0 while 3.15.1 is anchored)
    and gives non-numeric anchors (S012 `v1.21.x`) the feed's numeric floor.
    """
    floors = {}
    for row in rows:
        if row["malformed"]:
            continue
        values = dict(zip(HEADER, row["fields"]))
        anchor = numeric_version(values["anchored_version"])
        if values["clock"] != "feed" or anchor is None:
            continue
        url = values["feed_url"]
        if url not in floors or anchor > numeric_version(floors[url]):
            floors[url] = values["anchored_version"]
    return floors


def receipt_date(value):
    if not isinstance(value, str) or not value.endswith("Z"):
        return None
    try:
        timestamp = dt.datetime.fromisoformat(value[:-1] + "+00:00")
    except ValueError:
        return None
    if timestamp.utcoffset() != dt.timedelta(0):
        return None
    return timestamp.date().isoformat()


def receipt_matches(source_id, source, values, receipt):
    if not isinstance(receipt, dict):
        return False
    expected_url = values["feed_url"] if values["clock"] == "feed" else source["url"]
    status = receipt.get("http_status")
    if ("error" in receipt
            or receipt.get("id") != source_id
            or receipt.get("clock") != values["clock"]
            or receipt.get("url") != expected_url
            or receipt.get("verdict") != values["verdict"]
            or receipt_date(receipt.get("observed_at")) != values["observed_at"]
            or type(status) is not int or not 200 <= status < 300
            or not isinstance(receipt.get("sha256"), str)
            or not re.fullmatch(r"[0-9a-f]{64}", receipt["sha256"])):
        return False
    if values["clock"] == "feed":
        parsed_version = receipt.get("parsed_version")
        return (
            isinstance(parsed_version, str)
            and norm_version(parsed_version) == norm_version(values["observed_version"])
            and receipt.get("located") is None
        )
    if values["clock"] == "rendered-quote":
        located = receipt.get("located")
        expected_located = values["verdict"] == "quote-located"
        return (
            receipt.get("parsed_version") is None
            and type(located) is bool
            and located is expected_located
        )
    return False


def load_receipt_bundle(path, expected_sha256=None):
    bundle = {"records": {}, "invalid_ids": set(), "invalid": False}
    if not os.path.lexists(path):
        return bundle
    try:
        raw = Path(path).read_bytes()
    except OSError:
        bundle["invalid"] = True
        return bundle
    if expected_sha256 is not None:
        if (not re.fullmatch(r"[0-9a-f]{64}", expected_sha256)
                or hashlib.sha256(raw).hexdigest() != expected_sha256):
            bundle["invalid"] = True
            return bundle
    try:
        document = json.loads(raw.decode("utf-8"))
    except (UnicodeError, json.JSONDecodeError):
        bundle["invalid"] = True
        return bundle
    if (not isinstance(document, dict)
            or document.get("format") != "release-clock-observations-v1"
            or not isinstance(document.get("observations"), list)):
        bundle["invalid"] = True
        return bundle
    for record in document["observations"]:
        if not isinstance(record, dict) or not isinstance(record.get("id"), str):
            bundle["invalid"] = True
            continue
        record_id = record["id"]
        if record_id in bundle["records"] or record_id in bundle["invalid_ids"]:
            bundle["invalid_ids"].add(record_id)
            bundle["records"].pop(record_id, None)
        else:
            bundle["records"][record_id] = record
    return bundle


def receipt_path(root, selected):
    if selected is None:
        return root / ".ufo" / "waves" / "round-26" / "observe-2.json"
    path = Path(selected)
    return path if path.is_absolute() else root / path


def evaluate(sources, rows, captures=None, receipt_bundle=None):
    captures = captures or {}
    receipt_bundle = receipt_bundle or {
        "records": {}, "invalid_ids": set(), "invalid": False,
    }
    receipt_records = receipt_bundle["records"]
    invalid_receipt_ids = receipt_bundle["invalid_ids"]
    on_release = sorted(
        source_id for source_id, source in sources.items()
        if source["recheck"] == "on-release"
    )
    by_id = {}
    errors = set()
    for row in rows:
        row_id = row["id"]
        source = sources.get(row_id)
        if source is None or source["recheck"] != "on-release":
            errors.add(("ORPHAN", row_id))
            continue
        by_id.setdefault(row_id, []).append(row)

    floors = feed_floors(rows)
    bound = 0
    unbound = 0
    observed = 0
    fired = 0
    derived = 0
    for source_id in on_release:
        matches = by_id.get(source_id, [])
        if not matches:
            errors.add(("UNBOUND", source_id))
            unbound += 1
            continue
        if len(matches) != 1:
            errors.add(("INCONSISTENT", source_id))
            continue
        row = matches[0]
        bound += 1
        if row["malformed"]:
            errors.add(("INCONSISTENT", source_id))
            continue
        values = dict(zip(HEADER, row["fields"]))
        clock = values["clock"]
        feed_source_id = values["feed_source_id"]
        feed_url = values["feed_url"]
        anchored = values["anchored_version"]
        observed_version = values["observed_version"]
        observed_at = values["observed_at"]
        verdict = values["verdict"]
        row_valid = True
        row_fired = False
        row_derived = False

        if clock == "feed":
            feed_source = sources.get(feed_source_id)
            if (not SOURCE_ID_RE.fullmatch(feed_source_id)
                    or feed_source is None
                    or feed_source["kind"].lower() not in FEED_KINDS
                    or feed_source["recheck"] == "on-release"
                    or not valid_public_https_url(feed_url)
                    or feed_source["url"] != feed_url):
                errors.add(("BADFEED", source_id))
                row_valid = False
            is_derived = values["note"].startswith("derived:")
            anchor_ok = is_derived or version_is_named(sources[source_id]["anchor"], anchored)
            if (is_regression(anchored, observed_version)
                    or is_regression(floors.get(feed_url, ""), observed_version)):
                # S042 §11.2 numeric order: the feed's newest stable release is
                # older than this row's anchor or than another numeric anchor
                # on the same feed -- a stale, cropped or withdrawn stream to
                # re-verify, never a newer-stable clock event. An observation
                # EQUAL to the feed floor cannot be told from a legitimate state.
                errors.add(("REGRESSED", source_id))
                row_valid = False
            elif (not anchor_ok or not observed_version or observed_version == "-"
                    or numeric_version(observed_version) is None
                    or not valid_iso_date(observed_at)
                    or verdict not in ("not-fired", "fired")):
                errors.add(("INCONSISTENT", source_id))
                row_valid = False
            elif verdict == "fired" and norm_version(observed_version) != norm_version(anchored):
                row_fired = True
                row_derived = is_derived
            elif verdict == "not-fired" and norm_version(observed_version) == norm_version(anchored):
                row_derived = is_derived
            else:
                errors.add(("INCONSISTENT", source_id))
                row_valid = False
        elif clock == "rendered-quote":
            quote, profile = captures.get(source_id, ("", ""))
            if (feed_source_id != "-" or feed_url != "-" or anchored != "-"
                    or observed_version != "-" or not valid_iso_date(observed_at)
                    or verdict not in ("quote-located", "quote-missing")
                    or not quote.strip() or quote == "-"
                    or profile not in LOCATE_PROFILES
                    or not sources[source_id]["url"]):
                errors.add(("INCONSISTENT", source_id))
                row_valid = False
            else:
                row_fired = verdict == "quote-missing"
        else:
            errors.add(("INCONSISTENT", source_id))
            row_valid = False

        receipt = receipt_records.get(source_id)
        if receipt_bundle["invalid"] or source_id in invalid_receipt_ids:
            errors.add(("RECEIPT-MISMATCH", source_id))
            row_valid = False
        elif receipt is None:
            errors.add(("NOT OBSERVED", source_id))
            row_valid = False
        elif not receipt_matches(source_id, sources[source_id], values, receipt):
            errors.add(("RECEIPT-MISMATCH", source_id))
            row_valid = False
        if isinstance(receipt, dict) and receipt.get("verdict") == "regressed":
            errors.add(("REGRESSED", source_id))
            row_valid = False
        if row_valid:
            observed += 1
            fired += row_fired
            derived += row_derived

    bound_ids = {
        source_id for source_id, matches in by_id.items()
        if len(matches) == 1 and not matches[0]["malformed"]
    }
    for record_id in set(receipt_records) | invalid_receipt_ids:
        if record_id not in bound_ids:
            errors.add(("RECEIPT-MISMATCH", record_id))

    return {
        "on_release": len(on_release),
        "bound": bound,
        "unbound": unbound,
        "observed": observed,
        "fired": fired,
        "derived": derived,
        "errors": sorted(errors),
        "passed": not errors and bound == len(on_release),
    }


def print_result(result):
    for category, row_id in result["errors"]:
        print("%s %s" % (category, row_id))
    state = "CLEAN" if result["passed"] else "FAILED"
    print("RELEASE_CLOCK: %s (on_release=%d bound=%d unbound=%d observed=%d fired=%d derived=%d)" % (
        state, result["on_release"], result["bound"], result["unbound"],
        result["observed"], result["fired"], result["derived"],
    ))


def load_normalizer(root):
    path = root / "corpus" / "rendered-text-v1.py"
    spec = importlib.util.spec_from_file_location("rendered_text_v1", path)
    if spec is None or spec.loader is None:
        raise ValueError("cannot import corpus/rendered-text-v1.py")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


class NoRedirectHandler(urllib.request.HTTPRedirectHandler):
    def redirect_request(self, request, response, code, message, headers, new_url):
        return None


def request_body(url, opener=None, resolver=None):
    if not valid_public_https_url(url):
        return None, None, "URL must be public HTTPS without credentials or query"
    allowed_origin = url_origin(url)
    current_url = url
    redirects = 0
    while True:
        addresses, address_error = public_addresses(current_url, resolver)
        if address_error:
            return None, None, address_error
        current_opener = opener or make_public_opener(addresses)
        request = urllib.request.Request(current_url, headers={"User-Agent": USER_AGENT})
        try:
            response = current_opener.open(request, timeout=20)
        except urllib.error.HTTPError as exc:
            status = exc.code
            location = exc.headers.get("Location") if exc.headers else None
            if status in (301, 302, 303, 307, 308):
                exc.close()
                if not location:
                    return status, None, "redirect missing location"
                next_url = urllib.parse.urljoin(current_url, location)
                if redirects >= MAX_REDIRECTS or not redirect_allowed(
                        next_url, allowed_origin, url):
                    return status, None, "redirect denied"
                current_url = next_url
                redirects += 1
                continue
            body = exc.read(MAX_BODY_BYTES + 1)
            if len(body) > MAX_BODY_BYTES:
                return status, None, "response too large"
            return status, body, "HTTP %d" % status
        with response:
            status = response.getcode()
            body = response.read(MAX_BODY_BYTES + 1)
        if len(body) > MAX_BODY_BYTES:
            return status, None, "response too large"
        if status is None or status < 200 or status >= 300:
            return status, body, "HTTP %s" % status
        return status, body, None

STABLE_TITLE_RE = re.compile(r"^(?:[A-Za-z]+ )?v?([0-9]+\.[0-9]+\.[0-9]+)$")
STABLE_TAG_HREF_RE = re.compile(r"/releases/tag/v?([0-9]+\.[0-9]+\.[0-9]+)$")
TEXT_VERSION_RE = re.compile(r"^Version:[ \t]*v?([0-9]+\.[0-9]+\.[0-9]+)[ \t]*$", re.MULTILINE)


def parse_latest_version(body):
    """Newest STABLE release in a feed: the max X.Y.Z over every entry.

    Entry order is not trusted (GitHub Atom orders by update time and mixes
    module tags such as `sdk/v0.26.0` and prereleases such as `v2.2.0-rc1`);
    only a title that is exactly `[Word ]vX.Y.Z` or a `/releases/tag/vX.Y.Z`
    link counts. A plain-text release file (curl.se/info) is read from its
    `Version: X.Y.Z` line.
    """
    if not isinstance(body, bytes) or len(body) > MAX_BODY_BYTES:
        raise ValueError("feed body is invalid or too large")
    if not body.lstrip().startswith(b"<"):
        match = TEXT_VERSION_RE.search(body.decode("utf-8"))
        if match:
            return match.group(1)
        raise ValueError("text release file has no Version: X.Y.Z line")
    if re.search(br"<!\s*(?:DOCTYPE|ENTITY)\b", body, re.IGNORECASE):
        raise ValueError("XML DTD and entity declarations are not allowed")
    try:
        root = ET.fromstring(body)
    except (ET.ParseError, ValueError) as exc:
        raise ValueError("feed is not valid XML: %s" % exc.__class__.__name__)
    if sum(1 for _ in root.iter()) > MAX_XML_ELEMENTS:
        raise ValueError("feed XML has too many elements")
    entries = root.findall(".//{*}entry")
    if not entries:
        entries = root.findall(".//{*}item")
    if len(entries) > MAX_FEED_ENTRIES:
        raise ValueError("feed has too many entries")
    if not entries:
        raise ValueError("feed has no entry/item")
    stable = []
    for entry in entries:
        for child in list(entry):
            tag = child.tag.rsplit("}", 1)[-1].lower()
            match = None
            if tag == "title" and child.text:
                match = STABLE_TITLE_RE.match(child.text.strip())
            elif tag == "link":
                href = child.attrib.get("href") or (child.text or "")
                match = STABLE_TAG_HREF_RE.search(href.strip())
            if match:
                stable.append(match.group(1))
    if not stable:
        raise ValueError("feed has no stable X.Y.Z release entry")
    return max(stable, key=lambda v: tuple(int(part) for part in v.split(".")))


def utc_timestamp():
    return dt.datetime.now(dt.timezone.utc).isoformat(timespec="seconds").replace("+00:00", "Z")


def observe_one(source, values, normalizer, opener=None, resolver=None, capture=None, floor=None):
    clock = values["clock"]
    url = values["feed_url"] if clock == "feed" else source["url"]
    receipt = {
        "id": values["id"],
        "clock": clock,
        "url": safe_receipt_url(url),
        "http_status": None,
        "sha256": None,
        "parsed_version": None,
        "located": None,
        "verdict": None,
        "observed_at": None,
    }
    try:
        status, body, error = request_body(url, opener=opener, resolver=resolver)
        receipt["http_status"] = status
        if body is not None:
            receipt["sha256"] = hashlib.sha256(body).hexdigest()
        if error:
            raise ValueError(error)
        if clock == "feed":
            parsed_version = parse_latest_version(body)
            receipt["parsed_version"] = parsed_version
            # the row's anchor and its previously recorded observation are both
            # floors: a fired 3.15.0 row that recorded 3.15.1 must not silently
            # read not-fired again when the feed shows 3.15.0 (round 27 C2)
            if (is_regression(values["anchored_version"], parsed_version)
                    or is_regression(values.get("observed_version", ""), parsed_version)
                    or is_regression(floor or "", parsed_version)):
                receipt["verdict"] = "regressed"
            elif norm_version(parsed_version) == norm_version(values["anchored_version"]):
                receipt["verdict"] = "not-fired"
            else:
                receipt["verdict"] = "fired"
        else:
            # the declared capture quote and its locate profile (source-fetches.tsv)
            quote, profile = capture or ("", "")
            if not quote.strip() or quote == "-" or profile not in LOCATE_PROFILES:
                raise ValueError("source row has no declared capture quote")
            if profile == "raw-literal-v1":
                receipt["located"] = quote in body.decode("utf-8")
            else:
                normalized_page = normalizer.normalize_bytes(body).decode("utf-8")
                # exactly rendered-text-v1's own `locate`: collapse the quote, never
                # tag-strip it (S031's quote legitimately contains `<!--`)
                wanted = normalizer.collapse_quote(quote)
                receipt["located"] = bool(wanted) and wanted in normalized_page
            receipt["verdict"] = (
                "quote-located" if receipt["located"] else "quote-missing"
            )
    except urllib.error.URLError:
        receipt["error"] = "network error"
    except UnicodeError:
        receipt["error"] = "body is not strict UTF-8"
    except (OSError, ValueError) as exc:
        receipt["error"] = str(exc)
    receipt["observed_at"] = utc_timestamp()
    return receipt


def write_receipt(path_value, receipts):
    output_path = Path(os.path.abspath(os.fspath(path_value)))
    document = {
        "format": "release-clock-observations-v1",
        "observations": receipts,
    }
    temp_path = None
    try:
        if os.path.lexists(output_path):
            setup("observation output already exists or is a symlink")
        with tempfile.NamedTemporaryFile(
                "w", encoding="utf-8", newline="\n", dir=str(output_path.parent),
                prefix="." + output_path.name + ".", suffix=".tmp", delete=False) as handle:
            temp_path = Path(handle.name)
            json.dump(document, handle, ensure_ascii=False, indent=2, sort_keys=True)
            handle.write("\n")
        os.link(str(temp_path), str(output_path), follow_symlinks=False)
        temp_path.unlink()
    except SetupError:
        if temp_path is not None:
            try:
                temp_path.unlink(missing_ok=True)
            except OSError:
                pass
        raise
    except OSError as exc:
        if temp_path is not None:
            try:
                temp_path.unlink(missing_ok=True)
            except OSError:
                pass
        setup("cannot write observation receipt: %s" % exc.__class__.__name__)


def run_observe(root, sources, rows, output_path, captures=None):
    captures = captures or {}
    by_id = {}
    for row in rows:
        by_id.setdefault(row["id"], []).append(row)
    eligible = []
    for source_id in sorted(sources):
        source = sources[source_id]
        matches = by_id.get(source_id, [])
        if source["recheck"] != "on-release" or len(matches) != 1:
            continue
        row = matches[0]
        if row["malformed"]:
            continue
        values = dict(zip(HEADER, row["fields"]))
        if values["clock"] in ("feed", "rendered-quote"):
            eligible.append((source, values))
    normalizer = None
    if any(values["clock"] == "rendered-quote" for _, values in eligible):
        try:
            normalizer = load_normalizer(root)
        except (OSError, ImportError, ValueError) as exc:
            setup("cannot load rendered-text-v1: %s" % exc.__class__.__name__)
    floors = feed_floors(rows)
    receipts = [observe_one(source, values, normalizer, capture=captures.get(source["id"]),
                            floor=floors.get(values["feed_url"]))
                for source, values in eligible]
    write_receipt(output_path, receipts)
    failures = sum("error" in receipt for receipt in receipts)
    fired = sum(receipt.get("verdict") in ("fired", "quote-missing")
                for receipt in receipts)
    regressed = sum(receipt.get("verdict") == "regressed" for receipt in receipts)
    print("RELEASE_CLOCK_OBSERVE: wrote %d observations (failed=%d fired=%d regressed=%d) to %s" % (
        len(receipts), failures, fired, regressed, output_path,
    ))
    return failures




def fixture_source(source_id, name, kind, anchor, teaches, recheck, url):
    fields = [
        source_id, "%s — %s" % (name, url), kind, "A", "test scope", anchor,
        teaches, "mined", "2026-10-21", recheck, "—",
    ]
    return "| " + " | ".join(fields) + " |"


def fixture_row(source_id="S001", clock="feed", feed_source_id="S002",
                feed_url="https://example.test/releases.atom", anchored="1.2.3",
                observed="1.2.3", observed_at="2026-10-21", verdict="not-fired",
                note="test"):
    return "\t".join((source_id, clock, feed_source_id, feed_url, anchored,
                      observed, observed_at, verdict, note))


def selftest():
    global MAX_BODY_BYTES, MAX_XML_ELEMENTS, request_body, utc_timestamp
    cases = 0
    failures = []

    def fake_public_resolver(host, port, type=socket.SOCK_STREAM):
        return [(socket.AF_INET, type, socket.IPPROTO_TCP, "", ("93.184.216.34", port))]

    def private_resolver(host, port, type=socket.SOCK_STREAM):
        return [(socket.AF_INET, type, socket.IPPROTO_TCP, "", ("127.0.0.1", port))]

    default_capture = "\t".join(
        ["S001", "mined", "0" * 64, "https://example.test/doc", "https://example.test/doc",
         "200", "curl-fsSL-compressed-v1", "2026-10-21", "decoded-http-body-v1", "0" * 64,
         "1", "-", "the exact example.", "rendered-text-v1", "0" * 64, "1"]) + "\n"

    def synthetic_receipt_bundle(sources, rows):
        records = {}
        by_id = {}
        for row in rows:
            if row["id"] in sources and sources[row["id"]]["recheck"] == "on-release":
                by_id.setdefault(row["id"], []).append(row)
        for source_id, matches in by_id.items():
            if len(matches) != 1 or matches[0]["malformed"]:
                continue
            values = dict(zip(HEADER, matches[0]["fields"]))
            clock = values["clock"]
            source = sources[source_id]
            records[source_id] = {
                "id": source_id,
                "clock": clock,
                "url": values["feed_url"] if clock == "feed" else source["url"],
                "http_status": 200,
                "sha256": "0" * 64,
                "parsed_version": values["observed_version"] if clock == "feed" else None,
                "located": (values["verdict"] == "quote-located")
                           if clock == "rendered-quote" else None,
                "verdict": values["verdict"],
                "observed_at": values["observed_at"] + "T00:00:00Z",
            }
        return {"records": records, "invalid_ids": set(), "invalid": False}

    def mutate_receipt(field, value):
        def mutation(bundle):
            bundle["records"]["S001"][field] = value
        return mutation

    def mutate_receipt_values(**values):
        def mutation(bundle):
            bundle["records"]["S001"].update(values)
        return mutation

    def remove_receipt(bundle):
        bundle["records"].pop("S001", None)

    def run_case(name, rows_text, expected_errors, expected_counts=None,
                 captures_text=default_capture, receipt_action=None, extra_sources=(),
                 feed_anchor="Latest release 1.2.0; series 1.2.x"):
        nonlocal cases
        cases += 1
        with tempfile.TemporaryDirectory(prefix="release-clock-") as temp:
            root = Path(temp)
            corpus = root / "corpus"
            corpus.mkdir()
            source_lines = [
                "| id | source | kind | tier | scope | anchor | teaches | status | opened | recheck | used-by |",
                "|---|---|---|---|---|---|---|---|---|---|---|",
                fixture_source("S001", "Document", "docs", "Version 1.2.3",
                               "Quote: “the exact example.”", "on-release",
                               "https://example.test/doc"),
                fixture_source("S002", "Release feed", "code", feed_anchor,
                               "Release Atom feed.", "90d",
                               "https://example.test/releases.atom"),
                fixture_source("S003", "Stable doc", "spec", "Page title",
                               "Stable.", "manual", "https://example.test/stable"),
            ] + list(extra_sources)
            (corpus / "SOURCES.md").write_text("\n".join(source_lines) + "\n", encoding="utf-8")
            (corpus / "release-clocks.tsv").write_text(
                "\t".join(HEADER) + "\n" + rows_text, encoding="utf-8")
            if captures_text:
                (corpus / "source-fetches.tsv").write_text(
                    "# capture fixture\n" + captures_text, encoding="utf-8")
            sources = parse_sources(root)
            rows = parse_bindings(root)
            captures = parse_captures(root)
            receipts = synthetic_receipt_bundle(sources, rows)
            if receipt_action:
                receipt_action(receipts)
            result = evaluate(sources, rows, captures, receipts)
            actual_errors = set(result["errors"])
            expected = set(expected_errors)
            if actual_errors != expected:
                failures.append("%s: errors %r != %r" % (name, actual_errors, expected))
            if expected_counts:
                for key, value in expected_counts.items():
                    if result[key] != value:
                        failures.append("%s: %s=%r != %r" %
                                        (name, key, result[key], value))
            if result["passed"] != (not expected):
                failures.append("%s: passed=%r" % (name, result["passed"]))

    run_case("missing binding", "", [("UNBOUND", "S001")],
             {"on_release": 1, "bound": 0, "unbound": 1, "observed": 0, "fired": 0})
    run_case("unchanged feed", fixture_row() + "\n", [],
             {"bound": 1, "unbound": 0, "observed": 1, "fired": 0})
    run_case("fired feed", fixture_row(observed="1.2.4", verdict="fired") + "\n", [],
             {"observed": 1, "fired": 1})
    run_case("unknown id", fixture_row("S999") + "\n",
             [("ORPHAN", "S999"), ("UNBOUND", "S001")])
    run_case("non-release id", fixture_row("S003") + "\n",
             [("ORPHAN", "S003"), ("UNBOUND", "S001")])
    run_case("unknown feed", fixture_row(feed_source_id="S999") + "\n",
             [("BADFEED", "S001")])

    run_case("non-feed source", fixture_row(
        feed_source_id="S003", feed_url="https://example.test/stable") + "\n",
        [("BADFEED", "S001")])
    run_case("invalid date", fixture_row(observed_at="2026-02-30") + "\n",
             [("INCONSISTENT", "S001"), ("RECEIPT-MISMATCH", "S001")])
    run_case("wrong verdict", fixture_row(observed="1.2.4", verdict="not-fired") + "\n",
             [("INCONSISTENT", "S001")])
    run_case("duplicate binding", fixture_row() + "\n" + fixture_row() + "\n",
             [("INCONSISTENT", "S001")], {"bound": 0, "unbound": 0})
    run_case("located quote", fixture_row(clock="rendered-quote", feed_source_id="-",
             feed_url="-", anchored="-", observed="-", verdict="quote-located") + "\n", [],
             {"bound": 1, "observed": 1, "fired": 0})
    run_case("quote without feed fields", fixture_row(clock="rendered-quote",
             verdict="quote-missing", anchored="1.2.3") + "\n",
             [("INCONSISTENT", "S001")])
    run_case("missing quote fires", fixture_row(clock="rendered-quote", feed_source_id="-",
             feed_url="-", anchored="-", observed="-", verdict="quote-missing") + "\n", [],
             {"observed": 1, "fired": 1})
    run_case("quote without capture", fixture_row(clock="rendered-quote", feed_source_id="-",
             feed_url="-", anchored="-", observed="-", verdict="quote-located") + "\n",
             [("INCONSISTENT", "S001")], captures_text="")
    run_case("derived anchor counted", fixture_row(
             anchored="1.2.0", observed="1.2.0",
             note="derived: newest stable release on the feed when the row was opened") + "\n",
             [], {"observed": 1, "derived": 1})
    run_case("unnamed anchor refused", fixture_row(anchored="1.2.0", observed="1.2.0") + "\n",
             [("INCONSISTENT", "S001")])
    run_case("v-prefix equality", fixture_row(anchored="v1.2.3", observed="1.2.3") + "\n", [],
             {"observed": 1, "fired": 0})
    run_case("feed row on-release", fixture_row(
        feed_source_id="S001", feed_url="https://example.test/doc") + "\n",
        [("BADFEED", "S001")])
    # round 27 C2: S042 §11.2 numeric precedence. Red-before: only the fired
    # lie (and the feed-floor un-fire below) were accepted CLEAN at round-26
    # BASE; a below-anchor not-fired row was already INCONSISTENT there.
    run_case("downgrade fired lie refused", fixture_row(observed="1.2.2", verdict="fired") + "\n",
             [("REGRESSED", "S001")], {"observed": 0, "fired": 0})
    run_case("below-anchor not-fired typed regressed", fixture_row(
             anchored="1.2.3", observed="1.1.9", verdict="not-fired") + "\n",
             [("REGRESSED", "S001")], {"observed": 0})
    run_case("numeric not lexical", fixture_row(observed="1.10.0", verdict="fired") + "\n", [],
             {"observed": 1, "fired": 1})
    run_case("non-numeric anchor keeps inequality", fixture_row(
             anchored="1.2.x", observed="1.3.0", verdict="fired",
             note="derived: series anchor, not orderable") + "\n", [],
             {"observed": 1, "fired": 1, "derived": 1})
    # round 28 C2: a derived anchor is bound to the version its feed row's
    # anchor names. Red-before: every case below is accepted CLEAN at BASE,
    # where `is_derived` skipped the anchor check entirely.
    run_case("derived anchor must name feed anchor", fixture_row(
             anchored="1.2.0", observed="1.2.0",
             note="derived: newest stable release on the feed when the row was opened") + "\n",
             [("DERIVATION", "S001")], {"observed": 0, "derived": 0},
             feed_anchor="Latest release v1.2.9")
    run_case("derived anchor rejects suffix sibling", fixture_row(
             anchored="1.2.3", observed="1.2.3",
             note="derived: newest stable release on the feed when the row was opened") + "\n",
             [("DERIVATION", "S001")], {"observed": 0, "derived": 0},
             feed_anchor="Latest release 1.2.30")
    run_case("derived anchor needs a named version", fixture_row(
             anchored="1.2.0", observed="1.2.0",
             note="derived: newest stable release on the feed when the row was opened") + "\n",
             [("DERIVATION", "S001")], {"observed": 0, "derived": 0},
             feed_anchor="Latest release")
    run_case("derived fired anchor bound to feed", fixture_row(
             anchored="1.2.0", observed="1.3.0", verdict="fired",
             note="derived: series anchor, not orderable") + "\n",
             [("DERIVATION", "S001")], {"observed": 0, "fired": 0, "derived": 0},
             feed_anchor="Latest release v1.2.9")
    run_case("derived group named exactly", fixture_row(
             anchored="1.2.0", observed="1.2.0",
             note="derived: newest stable release on the feed when the row was opened") + "\n" + fixture_row(
             "S004", anchored="1.2.0", observed="1.2.0",
             note="derived: newest stable release on the feed when the row was opened") + "\n",
             [("DERIVATION", "S001"), ("DERIVATION", "S004")], {"observed": 0, "derived": 0},
             extra_sources=[fixture_source("S004", "Successor", "docs", "Version 1.2.0",
                                           "Successor.", "on-release",
                                           "https://example.test/successor")],
             feed_anchor="Latest release v1.2.9")
    run_case("feed floor catches un-fire", fixture_row(
             anchored="1.2.3", observed="1.2.3", verdict="not-fired") + "\n" + fixture_row(
             "S004", anchored="1.2.4", observed="1.2.4", verdict="not-fired") + "\n",
             [("REGRESSED", "S001")], {"observed": 1},
             extra_sources=[fixture_source("S004", "Successor", "docs", "Version 1.2.4",
                                           "Successor.", "on-release",
                                           "https://example.test/successor")])
    run_case("feed floor lifts non-numeric anchor", fixture_row(
             anchored="1.2.x", observed="1.1.0", verdict="fired",
             note="derived: series anchor, not orderable") + "\n" + fixture_row(
             "S004", anchored="1.2.4", observed="1.2.4", verdict="not-fired") + "\n",
             [("REGRESSED", "S001")], {"observed": 1},
             extra_sources=[fixture_source("S004", "Successor", "docs", "Version 1.2.4",
                                           "Successor.", "on-release",
                                           "https://example.test/successor")])
    run_case("regressed receipt refused", fixture_row() + "\n",
             [("REGRESSED", "S001"), ("RECEIPT-MISMATCH", "S001")], {"observed": 0},
             receipt_action=mutate_receipt_values(parsed_version="1.2.2", verdict="regressed"))
    run_case("major component compared", fixture_row(
             anchored="1.2.3", observed="0.9.9", verdict="fired") + "\n",
             [("REGRESSED", "S001")], {"observed": 0})
    run_case("non-strict observation refused", fixture_row(observed="1.3", verdict="fired") + "\n",
             [("INCONSISTENT", "S001")], {"observed": 0})

    run_case("missing receipt", fixture_row() + "\n",
             [("NOT OBSERVED", "S001")], {"observed": 0},
             receipt_action=remove_receipt)
    run_case("receipt id mutation", fixture_row() + "\n",
             [("RECEIPT-MISMATCH", "S001")],
             receipt_action=mutate_receipt("id", "S999"))
    run_case("receipt clock mutation", fixture_row() + "\n",
             [("RECEIPT-MISMATCH", "S001")],
             receipt_action=mutate_receipt("clock", "rendered-quote"))
    run_case("receipt URL mutation", fixture_row() + "\n",
             [("RECEIPT-MISMATCH", "S001")],
             receipt_action=mutate_receipt("url", "https://example.test/other"))
    run_case("receipt date mutation", fixture_row() + "\n",
             [("RECEIPT-MISMATCH", "S001")],
             receipt_action=mutate_receipt("observed_at", "2026-10-20T23:59:59Z"))
    run_case("receipt verdict mutation", fixture_row() + "\n",
             [("RECEIPT-MISMATCH", "S001")],
             receipt_action=mutate_receipt("verdict", "fired"))
    run_case("receipt parsed-version mutation", fixture_row() + "\n",
             [("RECEIPT-MISMATCH", "S001")],
             receipt_action=mutate_receipt("parsed_version", "9.9.9"))

    run_case("TSV fired mutation against retained receipt",
             fixture_row(observed="1.2.4", verdict="fired") + "\n",
             [("RECEIPT-MISMATCH", "S001")],
             receipt_action=mutate_receipt_values(
                 parsed_version="1.2.3", verdict="not-fired"))
    run_case("receipt version normalization control",
             fixture_row(anchored="v1.2.3") + "\n", [],
             {"observed": 1},
             receipt_action=mutate_receipt("parsed_version", "v1.2.3"))
    run_case("extra receipt mismatch", fixture_row() + "\n",
             [("RECEIPT-MISMATCH", "S999")],
             receipt_action=lambda bundle: bundle["records"].__setitem__(
                 "S999", {"id": "S999"}))
    run_case("duplicate receipt mismatch", fixture_row() + "\n",
             [("RECEIPT-MISMATCH", "S001")],
             receipt_action=lambda bundle: bundle["invalid_ids"].add("S001"))
    run_case("quote located receipt control", fixture_row(
        clock="rendered-quote", feed_source_id="-", feed_url="-",
        anchored="-", observed="-", verdict="quote-located") + "\n", [],
        {"observed": 1, "fired": 0})
    run_case("quote located receipt mutation", fixture_row(
        clock="rendered-quote", feed_source_id="-", feed_url="-",
        anchored="-", observed="-", verdict="quote-located") + "\n",
        [("RECEIPT-MISMATCH", "S001")],
        receipt_action=mutate_receipt("located", False))

    atom = b'<feed xmlns="http://www.w3.org/2005/Atom">%s</feed>'
    def entry(title, tag):
        return (b'<entry><title>%s</title><link rel="alternate" type="text/html" '
                b'href="https://github.com/o/r/releases/tag/%s"/></entry>' % (title, tag))
    parser_cases = (
        ("first-entry stable", atom % entry(b"v2.4.1", b"v2.4.1"), "2.4.1"),
        ("module tag and rc skipped", atom % b"".join((
            entry(b"sdk/v9.9.9", b"sdk%2Fv9.9.9"), entry(b"v2.2.0-rc1", b"v2.2.0-rc1"),
            entry(b"v2.1.2", b"v2.1.2"), entry(b"v2.2.0", b"v2.2.0"))), "2.2.0"),
        ("commit-message module title skipped", atom % b"".join((
            entry(b"api/v2.7.9: Add changelog entry", b"api%2Fv2.7.9"),
            entry(b"v2.7.1", b"v2.7.1"))), "2.7.1"),
        ("rss product titles", b"<rss><channel>"
            b"<item><title>Python 3.16.0a1</title></item>"
            b"<item><title>Python install manager 26.4.1</title></item>"
            b"<item><title>Python 3.15.0</title></item>"
            b"<item><title>Python 3.14.8</title></item></channel></rss>", "3.15.0"),
        ("plain-text release file", b"Version: 8.23.0\nDate: 2026-10-14\n", "8.23.0"),
    )
    for label, feed_body, wanted in parser_cases:
        cases += 1
        try:
            got = parse_latest_version(feed_body)
        except ValueError as exc:
            got = "ValueError: %s" % exc
        if got != wanted:
            failures.append("version parser %s: %r != %r" % (label, got, wanted))
    for label, feed_body in (
            ("no stable entry", atom % entry(b"v3.0.0-beta1", b"v3.0.0-beta1")),
            ("text without Version line", b"Date: 2026-10-14\n")):
        cases += 1
        try:
            parse_latest_version(feed_body)
            failures.append("version parser %s: accepted" % label)
        except ValueError:
            pass

    cases += 1
    try:
        if parse_latest_version(
                b'<feed xmlns="http://www.w3.org/2005/Atom"><entry><title>v2.4.1</title></entry></feed>') != "2.4.1":
            failures.append("Atom version parser")
    except ValueError as exc:
        failures.append("Atom version parser: %s" % exc)

    for label, url, wanted in (
            ("word slug accepted",
             "https://1password.com/blog/1password-credential-broker-public-preview", True),
            ("token segment refused",
             "https://feed.example.test/x/" + "Ab9" * 16, False)):
        cases += 1
        if valid_public_https_url(url) is not wanted:
            failures.append("url check %s" % label)

    class RedirectOpener:
        def __init__(self, location):
            self.location = location
            self.requests = []

        def open(self, request, timeout):
            self.requests.append(request)
            raise urllib.error.HTTPError(
                request.full_url, 302, "Found", {"Location": self.location}, None
            )

    for name, initial_url, location in (
            ("cross-origin redirect", "https://feed.example.test/releases.atom",
             "https://other.example.test/releases.atom"),
            ("loopback redirect", "https://feed.example.test/releases.atom",
             "https://127.0.0.1/private"),
            ("login-path redirect", "https://feed.example.test/releases.atom",
             "https://feed.example.test/login"),
            ("1Password account-path redirect", "https://www.1password.dev/brokered-access",
             "https://www.1password.dev/account/login"),
            ("1Password app-path redirect", "https://www.1password.dev/brokered-access",
             "https://www.1password.dev/app"),
            ("1Password path-change redirect", "https://www.1password.dev/brokered-access",
             "https://www.1password.dev/unrelated")):
        opener = RedirectOpener(location)
        status, body, error = request_body(
            initial_url, opener=opener, resolver=fake_public_resolver,
        )
        cases += 1
        if (status != 302 or body is not None or error != "redirect denied"
                or len(opener.requests) != 1):
            failures.append("%s: redirect was not rejected before a second request" % name)
        elif (opener.requests[0].get_header("User-agent") != USER_AGENT
              or opener.requests[0].get_header("Authorization") is not None):
            failures.append("%s: unexpected request headers" % name)

    cases += 1
    if not redirect_allowed(
            "https://www.1password.dev/brokered-access",
            ("https", "www.1password.dev", 443),
            "https://www.1password.dev/brokered-access/"):
        failures.append("1Password trailing-slash canonical redirect was rejected")

    class StaticResponse:
        code = 200
        msg = "OK"
        headers = {}

        def __init__(self, body):
            self.body = body
            self.read_limit = None

        def getcode(self):
            return self.code

        def info(self):
            return self.headers

        def read(self, limit):
            self.read_limit = limit
            return self.body[:limit]

        def __enter__(self):
            return self

        def __exit__(self, exc_type, exc_value, traceback):
            return False

    class StaticHTTPSHandler(urllib.request.HTTPSHandler):
        handler_order = 200

        def __init__(self, response):
            self.response = response
            self.requests = []

        def https_open(self, request):
            self.requests.append(request)
            return self.response

    class StaticOpener:
        def __init__(self, body):
            self.response = StaticResponse(body)
            self.requests = []

        def open(self, request, timeout):
            self.requests.append(request)
            return self.response

    query_opener = RedirectOpener("https://other.example.test/")
    query_values = {
        "id": "S001", "clock": "feed",
        "feed_url": "https://feed.example.test/releases.atom?token=TEST-SENTINEL-ONLY",
        "anchored_version": "1.2.3",
    }
    query_receipt = observe_one(
        {"url": "https://example.test/doc", "teaches": "test"},
        query_values, None, opener=query_opener, resolver=fake_public_resolver,
    )
    cases += 1
    if ("TEST-SENTINEL-ONLY" in json.dumps(query_receipt)
            or query_opener.requests or query_receipt["url"] !=
            "https://feed.example.test/releases.atom"):
        failures.append("query value was fetched or persisted in receipt")

    path_opener = RedirectOpener("https://other.example.test/")
    path_values = {
        "id": "S001", "clock": "feed",
        "feed_url": "https://feed.example.test/session/PATH-TEST-SENTINEL",
        "anchored_version": "1.2.3",
    }
    path_receipt = observe_one(
        {"url": "https://example.test/doc", "teaches": "test"},
        path_values, None, opener=path_opener, resolver=fake_public_resolver,
    )
    cases += 1
    if ("PATH-TEST-SENTINEL" in json.dumps(path_receipt)
            or path_opener.requests or path_receipt["url"] != "https://feed.example.test"):
        failures.append("path-carried secret was fetched or persisted")

    old_body_limit = MAX_BODY_BYTES
    MAX_BODY_BYTES = 8
    try:
        oversized_opener = StaticOpener(b"x" * 32)
        status, body, error = request_body(
            "https://feed.example.test/releases.atom", opener=oversized_opener,
            resolver=fake_public_resolver,
        )
        cases += 1
        if (status != 200 or body is not None or error != "response too large"
                or oversized_opener.response.read_limit != 9):
            failures.append("response body limit was not enforced")
    finally:
        MAX_BODY_BYTES = old_body_limit

    port_opener = StaticOpener(b"unused")
    status, body, error = request_body(
        "https://feed.example.test:8443/releases.atom",
        opener=port_opener, resolver=fake_public_resolver,
    )
    cases += 1
    if (status is not None or body is not None or not error
            or port_opener.requests or valid_public_https_url(
                "https://feed.example.test:8443/releases.atom")):
        failures.append("nonstandard HTTPS port was accepted")

    private_opener = StaticOpener(b"unused")
    status, body, error = request_body(
        "https://feed.example.test/releases.atom",
        opener=private_opener, resolver=private_resolver,
    )
    cases += 1
    if (status is not None or body is not None
            or error != "host resolves to a non-public address"
            or private_opener.requests):
        failures.append("private DNS result was fetched")

    proxy_lookup = []
    original_getproxies = urllib.request.getproxies
    urllib.request.getproxies = lambda: proxy_lookup.append(True) or {}
    try:
        direct_opener = make_public_opener(("93.184.216.34",))
    finally:
        urllib.request.getproxies = original_getproxies
    proxy_handlers = [
        handler for handler in direct_opener.handlers
        if isinstance(handler, urllib.request.ProxyHandler)
    ]
    fake_body = b'<feed><entry><title>v1.2.3</title></entry></feed>'
    fake_response = StaticResponse(fake_body)
    fake_https_handler = StaticHTTPSHandler(fake_response)
    direct_opener.add_handler(fake_https_handler)
    status, body, error = request_body(
        "https://feed.example.test/releases.atom", opener=direct_opener,
        resolver=fake_public_resolver,
    )
    cases += 1
    sent_request = fake_https_handler.requests[0] if fake_https_handler.requests else None
    opener_ok = (
        not proxy_lookup and not proxy_handlers
        and status == 200 and body == fake_body and error is None
        and sent_request is not None
        and sent_request.get_header("User-agent") == USER_AGENT
        and sent_request.get_header("Authorization") is None
    )
    if not opener_ok:
        failures.append(
            "direct opener: env_lookup=%s handlers=%d status=%r body_match=%s "
            "error=%s requests=%d ua_present=%s auth_present=%s" % (
                bool(proxy_lookup), len(proxy_handlers), status, body == fake_body,
                error, len(fake_https_handler.requests),
                bool(sent_request and sent_request.get_header("User-agent")),
                bool(sent_request and sent_request.get_header("Authorization")),
            )
        )

    cases += 1
    try:
        parse_latest_version(
            b'<!DOCTYPE feed [<!ENTITY version "1.2.3">]>'
            b'<feed><entry><title>&version;</title></entry></feed>'
        )
        failures.append("DTD/entity feed was accepted")
    except ValueError:
        pass

    old_element_limit = MAX_XML_ELEMENTS
    MAX_XML_ELEMENTS = 2
    try:
        parse_latest_version(
            b'<feed><entry><title>v1.2.3</title></entry></feed>'
        )
        failures.append("oversized feed structure was accepted")
    except ValueError:
        pass
    finally:
        MAX_XML_ELEMENTS = old_element_limit
    cases += 1

    feed_observation = observe_one(
        {"url": "https://example.test/doc", "teaches": "test"},
        {"id": "S001", "clock": "feed",
         "feed_url": "https://feed.example.test/releases.atom",
         "anchored_version": "1.2.3"},
        None,
        opener=StaticOpener(
            b'<feed><entry><title>v1.2.4</title></entry></feed>'
        ),
        resolver=fake_public_resolver,
    )
    cases += 1
    if (feed_observation["parsed_version"] != "1.2.4"
            or feed_observation["verdict"] != "fired"):
        failures.append("live feed observation did not record a fired version")

    downgrade_observation = observe_one(
        {"url": "https://example.test/doc", "teaches": "test"},
        {"id": "S001", "clock": "feed",
         "feed_url": "https://feed.example.test/releases.atom",
         "anchored_version": "1.2.3"},
        None,
        opener=StaticOpener(
            b'<feed><entry><title>v1.2.2</title></entry><entry><title>v1.2.3-rc1</title></entry></feed>'
        ),
        resolver=fake_public_resolver,
    )
    cases += 1
    if (downgrade_observation["parsed_version"] != "1.2.2"
            or downgrade_observation["verdict"] != "regressed"
            or "error" in downgrade_observation):
        failures.append("older live feed observation was not typed regressed")

    floor_observation = observe_one(
        {"url": "https://example.test/doc", "teaches": "test"},
        {"id": "S001", "clock": "feed",
         "feed_url": "https://feed.example.test/releases.atom",
         "anchored_version": "1.2.3", "observed_version": "1.2.4"},
        None,
        opener=StaticOpener(b'<feed><entry><title>v1.2.3</title></entry></feed>'),
        resolver=fake_public_resolver,
    )
    cases += 1
    if floor_observation["verdict"] != "regressed" or "error" in floor_observation:
        failures.append("return to the anchor after a recorded newer observation was not regressed")

    sibling_floor_observation = observe_one(
        {"url": "https://example.test/doc", "teaches": "test"},
        {"id": "S001", "clock": "feed",
         "feed_url": "https://feed.example.test/releases.atom",
         "anchored_version": "1.2.3", "observed_version": "1.2.3"},
        None,
        opener=StaticOpener(b'<feed><entry><title>v1.2.3</title></entry></feed>'),
        resolver=fake_public_resolver, floor="1.2.4",
    )
    cases += 1
    if sibling_floor_observation["verdict"] != "regressed" or "error" in sibling_floor_observation:
        failures.append("observation below a sibling anchor on the same feed was not regressed")

    normalizer = load_normalizer(Path(__file__).resolve().parent.parent)
    quote_source = {
        "url": "https://docs.example.test/page",
        "teaches": "Quote: “the exact example.”",
    }
    quote_values = {
        "id": "S001", "clock": "rendered-quote",
        "feed_url": "-", "anchored_version": "-",
    }
    quote_observation = observe_one(
        quote_source, quote_values, normalizer, capture=("the exact example.", "rendered-text-v1"),
        opener=StaticOpener(b"<p>the exact <em>example.</em></p>"),
        resolver=fake_public_resolver,
    )
    missing_quote_observation = observe_one(
        quote_source, quote_values, normalizer, capture=("the exact example.", "rendered-text-v1"),
        opener=StaticOpener(b"<p>changed text</p>"),
        resolver=fake_public_resolver,
    )
    cases += 1
    if (quote_observation["located"] is not True
            or quote_observation["verdict"] != "quote-located"
            or missing_quote_observation["located"] is not False
            or missing_quote_observation["verdict"] != "quote-missing"):
        failures.append("rendered-text quote observation")


    with tempfile.TemporaryDirectory(prefix="release-clock-receipt-") as temp:
        root = Path(temp)
        destination = root / "receipt.json"
        sample = [{
            "id": "S001", "clock": "feed", "url": "https://example.test/feed",
            "http_status": 200, "sha256": "0" * 64, "parsed_version": "1.2.3",
            "located": None, "verdict": "not-fired",
            "observed_at": "2026-10-21T00:00:00Z",
        }]
        write_receipt(destination, sample)
        cases += 1
        decoded = json.loads(destination.read_text(encoding="utf-8"))
        allowed_receipt_keys = {
            "id", "clock", "url", "http_status", "sha256", "parsed_version",
            "located", "verdict", "observed_at",
        }
        if (stat.S_IMODE(destination.stat().st_mode) != 0o600
                or set(decoded) != {"format", "observations"}
                or set(decoded["observations"][0]) != allowed_receipt_keys):
            failures.append("receipt mode or fields")
        before = destination.read_bytes()
        cases += 1
        try:
            write_receipt(destination, [])
            failures.append("receipt overwrite was accepted")
        except SetupError:
            if destination.read_bytes() != before:
                failures.append("receipt changed after overwrite refusal")
        digest = hashlib.sha256(before).hexdigest()
        valid_bundle = load_receipt_bundle(destination, digest)
        mismatch_bundle = load_receipt_bundle(destination, "0" * 64)
        cases += 1
        if (valid_bundle["invalid"] or "S001" not in valid_bundle["records"]
                or not mismatch_bundle["invalid"]):
            failures.append("receipt digest binding")
        target = root / "target.json"
        target.write_text("preserve", encoding="utf-8")
        link = root / "receipt-link.json"
        link.symlink_to(target)
        try:
            write_receipt(link, [])
            failures.append("receipt symlink was accepted")
        except SetupError:
            if target.read_text(encoding="utf-8") != "preserve":
                failures.append("receipt symlink target changed")
        cases += 1

    with tempfile.TemporaryDirectory(prefix="release-clock-recapture-") as temp:
        root = Path(temp)
        corpus = root / "corpus"
        corpus.mkdir()
        source_lines = [
            "| id | source | kind | tier | scope | anchor | teaches | status | opened | recheck | used-by |",
            "|---|---|---|---|---|---|---|---|---|---|---|",
            fixture_source("S001", "Document", "docs", "Version 1.2.3",
                           "Quote: “the exact example.”", "on-release",
                           "https://example.test/doc"),
            fixture_source("S002", "Release feed", "code", "Latest release",
                           "Release Atom feed.", "90d",
                           "https://example.test/releases.atom"),
        ]
        (corpus / "SOURCES.md").write_text(
            "\n".join(source_lines) + "\n", encoding="utf-8"
        )
        tsv_path = corpus / "release-clocks.tsv"
        tsv_path.write_text(
            "\t".join(HEADER) + "\n" + fixture_row() + "\n", encoding="utf-8"
        )
        tsv_before = tsv_path.read_bytes()
        output_path = root / "receipt.json"
        stale_receipt = [dict(
            synthetic_receipt_bundle(
                parse_sources(root),
                [{"id": "S001", "fields": fixture_row(
                    observed="9.9.9", verdict="fired").split("\t"),
                 "malformed": False}],
            )["records"]["S001"]
        )]
        write_receipt(output_path, stale_receipt)
        # Recapture writes a NEW receipt, never overwrites filed evidence.
        output_path = root / "new-receipt.json"
        original_request_body = request_body
        original_utc_timestamp = utc_timestamp
        request_body = lambda url, **kwargs: (
            200, b'<feed><entry><title>v1.2.3</title></entry></feed>', None
        )
        utc_timestamp = lambda: "2026-10-21T00:00:00Z"
        recapture_stdout = io.StringIO()
        try:
            with contextlib.redirect_stdout(recapture_stdout):
                recapture_exit = main([
                    "--root", str(root), "--observe", str(output_path),
                ])
        finally:
            request_body = original_request_body
            utc_timestamp = original_utc_timestamp
        recaptured = load_receipt_bundle(output_path)["records"].get("S001", {})
        cases += 1
        if (recapture_exit != 0
                or "RECEIPT-MISMATCH" in recapture_stdout.getvalue()
                or recaptured.get("parsed_version") != "1.2.3"
                or recaptured.get("verdict") != "not-fired"
                or tsv_path.read_bytes() != tsv_before):
            failures.append("stale receipt recapture or TSV immutability")

        receipt_digest = hashlib.sha256(output_path.read_bytes()).hexdigest()
        explicit_stdout = io.StringIO()
        with contextlib.redirect_stdout(explicit_stdout):
            explicit_exit = main([
                "--root", str(root), "--receipt", str(output_path),
                "--receipt-sha", receipt_digest,
            ])
        cases += 1
        if explicit_exit != 0 or "RELEASE_CLOCK: CLEAN" not in explicit_stdout.getvalue():
            failures.append("explicit receipt override with digest")

        no_digest_stdout = io.StringIO()
        with contextlib.redirect_stdout(no_digest_stdout):
            no_digest_exit = main(["--root", str(root), "--receipt", str(output_path)])
        cases += 1
        if (no_digest_exit != 2
                or "--receipt requires --receipt-sha" not in no_digest_stdout.getvalue()):
            failures.append("explicit receipt without digest was accepted")

        changed_document = json.loads(output_path.read_text(encoding="utf-8"))
        changed_document["observations"][0]["parsed_version"] = "9.9.9"
        output_path.write_text(
            json.dumps(changed_document, sort_keys=True) + "\n", encoding="utf-8"
        )
        mismatch_stdout = io.StringIO()
        with contextlib.redirect_stdout(mismatch_stdout):
            mismatch_exit = main([
                "--root", str(root), "--receipt", str(output_path),
                "--receipt-sha", receipt_digest,
            ])
        cases += 1
        if (mismatch_exit != 1
                or "RECEIPT-MISMATCH S001" not in mismatch_stdout.getvalue()):
            failures.append("explicit receipt digest mismatch was accepted")

    with tempfile.TemporaryDirectory(prefix="release-clock-quote-missing-") as temp:
        root = Path(temp)
        corpus = root / "corpus"
        corpus.mkdir()
        source_lines = [
            "| id | source | kind | tier | scope | anchor | teaches | status | opened | recheck | used-by |",
            "|---|---|---|---|---|---|---|---|---|---|---|",
            fixture_source("S001", "Document", "docs", "Page title",
                           "Quote: “the exact example.”", "on-release",
                           "https://example.test/doc"),
        ]
        (corpus / "SOURCES.md").write_text("\n".join(source_lines) + "\n", encoding="utf-8")
        tsv_path = corpus / "release-clocks.tsv"
        quote_row = fixture_row(
            clock="rendered-quote", feed_source_id="-", feed_url="-",
            anchored="-", observed="-", verdict="quote-located",
        )
        tsv_path.write_text("\t".join(HEADER) + "\n" + quote_row + "\n", encoding="utf-8")
        (corpus / "source-fetches.tsv").write_text(
            "# synthetic capture\n" + default_capture, encoding="utf-8"
        )
        normalizer_source = Path(__file__).resolve().parent / "rendered-text-v1.py"
        (corpus / "rendered-text-v1.py").write_bytes(normalizer_source.read_bytes())
        tsv_before = tsv_path.read_bytes()
        root_sources = parse_sources(root)
        root_rows = parse_bindings(root)
        root_captures = parse_captures(root)
        output_path = root / "quote-receipt.json"
        original_request_body = request_body
        original_utc_timestamp = utc_timestamp
        request_body = lambda url, **kwargs: (200, b"<p>changed text</p>", None)
        utc_timestamp = lambda: "2026-10-21T00:00:00Z"
        summary = io.StringIO()
        try:
            with contextlib.redirect_stdout(summary):
                observe_failures = run_observe(
                    root, root_sources, root_rows, output_path, root_captures
                )
        finally:
            request_body = original_request_body
            utc_timestamp = original_utc_timestamp
        bundle = load_receipt_bundle(output_path)
        result = evaluate(root_sources, root_rows, root_captures, bundle)
        quote_receipt = bundle["records"].get("S001", {})
        cases += 1
        if (observe_failures != 0
                or "failed=0 fired=1" not in summary.getvalue()
                or quote_receipt.get("located") is not False
                or quote_receipt.get("verdict") != "quote-missing"
                or ("RECEIPT-MISMATCH", "S001") not in result["errors"]
                or tsv_path.read_bytes() != tsv_before):
            failures.append("quote-missing fired receipt or TSV immutability")

    # round 28 C2: the --observe CLI path shares evaluate with verify and
    # --receipt, so a derived anchor unbound from its feed row's anchor fails
    # the observation run too (exit 1, typed finding, offline static body).
    with tempfile.TemporaryDirectory(prefix="release-clock-observe-derived-") as temp:
        root = Path(temp)
        corpus = root / "corpus"
        corpus.mkdir()
        source_lines = [
            "| id | source | kind | tier | scope | anchor | teaches | status | opened | recheck | used-by |",
            "|---|---|---|---|---|---|---|---|---|---|---|",
            fixture_source("S001", "Document", "docs", "Version 1.2.0",
                           "Doc.", "on-release", "https://example.test/doc"),
            fixture_source("S002", "Release feed", "code", "Latest release v1.2.9",
                           "Release Atom feed.", "90d",
                           "https://example.test/releases.atom"),
        ]
        (corpus / "SOURCES.md").write_text("\n".join(source_lines) + "\n", encoding="utf-8")
        (corpus / "release-clocks.tsv").write_text("\t".join(HEADER) + "\n" + fixture_row(
            anchored="1.2.0", observed="1.3.0", verdict="fired",
            note="derived: newest stable release on the feed when the row was opened") + "\n",
            encoding="utf-8")
        original_request_body = request_body
        original_utc_timestamp = utc_timestamp
        request_body = lambda url, **kwargs: (
            200, b'<feed xmlns="http://www.w3.org/2005/Atom">'
                 b"<entry><title>v1.3.0</title></entry></feed>", None)
        utc_timestamp = lambda: "2026-10-21T00:00:00Z"
        observe_stdout = io.StringIO()
        try:
            with contextlib.redirect_stdout(observe_stdout):
                observe_exit = main(["--root", str(root), "--observe",
                                     str(root / "derived-observe.json")])
        finally:
            request_body = original_request_body
            utc_timestamp = original_utc_timestamp
        cases += 1
        if (observe_exit != 1
                or "DERIVATION S001" not in observe_stdout.getvalue()
                or "RELEASE_CLOCK: FAILED" not in observe_stdout.getvalue()):
            failures.append("observe path accepted an unbound derived anchor")

    if failures:
        for failure in failures:
            print("RELEASE_CLOCK_SELFTEST: FAIL %s" % failure)
        return 1
    print("RELEASE_CLOCK_SELFTEST: PASS (%d cases)" % cases)
    return 0


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__, allow_abbrev=False)
    parser.add_argument("--root", metavar="DIR", help="repository root (defaults to this script's checkout)")
    parser.add_argument("--selftest", action="store_true", help="run synthetic, offline cases")
    parser.add_argument("--observe", metavar="OUT.json", help="fetch currently bound clocks and write a receipt")
    parser.add_argument("--receipt", metavar="FILE", help="retained observation receipt (default is the round-26 rearmed receipt)")
    parser.add_argument("--receipt-sha", metavar="SHA256", help="required digest for an explicit --receipt")
    args = parser.parse_args(argv)
    if args.selftest:
        if args.observe or args.receipt or args.receipt_sha:
            print("RELEASE_CLOCK: SETUP (--selftest is isolated from receipts and observation)")
            return 2
        return selftest()
    if args.observe and (args.receipt or args.receipt_sha):
        print("RELEASE_CLOCK: SETUP (--observe uses its output receipt, not --receipt)")
        return 2
    if args.receipt and not args.receipt_sha:
        print("RELEASE_CLOCK: SETUP (--receipt requires --receipt-sha)")
        return 2
    if args.receipt_sha and not args.receipt:
        print("RELEASE_CLOCK: SETUP (--receipt-sha requires --receipt)")
        return 2
    if args.receipt_sha and not re.fullmatch(r"[0-9a-f]{64}", args.receipt_sha):
        print("RELEASE_CLOCK: SETUP (--receipt-sha must be 64 lowercase hex digits)")
        return 2

    root = Path(args.root).resolve() if args.root else Path(__file__).resolve().parent.parent
    try:
        sources = parse_sources(root)
        rows = parse_bindings(root)
        captures = parse_captures(root)
        if args.observe:
            observation_failures = run_observe(root, sources, rows, args.observe, captures)
            receipts = load_receipt_bundle(Path(args.observe))
        else:
            observation_failures = 0
            receipt_file = receipt_path(root, args.receipt)
            expected_sha256 = args.receipt_sha or (
                DEFAULT_RECEIPT_SHA256 if args.receipt is None else None
            )
            receipts = load_receipt_bundle(receipt_file, expected_sha256)
        result = evaluate(sources, rows, captures, receipts)
    except SetupError as exc:
        print("RELEASE_CLOCK: SETUP (%s)" % exc)
        return 2

    print_result(result)
    return 0 if result["passed"] and observation_failures == 0 else 1


if __name__ == "__main__":
    sys.exit(main())
