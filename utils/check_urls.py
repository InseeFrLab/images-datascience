"""Check that every URL in the install scripts works."""

import re
import sys
import urllib.request
from pathlib import Path

URL_PATTERN = re.compile(r'^([A-Z0-9_]+_URL)="([^"]*)"$', re.MULTILINE)
VERSION_PATTERN = re.compile(r'^([A-Z0-9_]+_VERSION)(?:_\d+)?="([^"]*)"$', re.MULTILINE)
VARIABLE_PATTERN = re.compile(r"\$\{([A-Z0-9_]+)(%\.\*)?\}")


def read_versions(scripts):
    """Read the versions of versions.env and of the install scripts: {name: [values]}."""
    versions = {}
    for file in [Path("versions.env"), *scripts]:
        for name, value in VERSION_PATTERN.findall(file.read_text()):
            versions.setdefault(name, []).append(value)
    return versions


def inject_version_in_url(url, values, index):
    """Inject versions in URLs at once."""

    def value_of(match):
        name_values = values[match[1]]
        value = name_values[min(index, len(name_values) - 1)]
        return value.rsplit(".", 1)[0] if match[2] else value

    return VARIABLE_PATTERN.sub(value_of, url)


def find_and_expand_urls(script, versions):
    """Retrieve the URLs in bash install scripts and inject versions."""
    values = versions.copy()
    # One substitution per value of the variables that have several (PYTHON_VERSION, R_VERSION)
    nb_values = max(len(name_values) for name_values in versions.values())
    urls = []
    for name, url in URL_PATTERN.findall(script.read_text()):
        # Stored with the versions, as a URL may use the URLs above it (HELM_CHECKSUM_URL="${HELM_URL}.sha256sum")
        values[name] = list(dict.fromkeys(inject_version_in_url(url, values, index) for index in range(nb_values)))
        urls += values[name]
    return urls


def check_url(url):
    """Return the HTTP status of the URL, following redirects, without reading the body."""
    # Unauthenticated, like the downloads of the builds
    request = urllib.request.Request(url, headers={"User-Agent": "onyxia-images-url-check"})
    try:
        with urllib.request.urlopen(request, timeout=30) as response:
            return response.status
    except urllib.error.HTTPError as error:
        return error.code
    except urllib.error.URLError as error:
        return error.reason


if __name__ == "__main__":
    scripts = sorted(Path().glob("*/scripts/*.sh"))
    versions = read_versions(scripts)
    nb_fail = 0
    for script in scripts:
        for url in find_and_expand_urls(script, versions):
            status = check_url(url)
            if status == 200:
                print(f"OK : {url}")
            else:
                nb_fail += 1
                print(f"ERROR : {url} ({status}), in {script}")
    if nb_fail > 0:
        sys.exit("Invalid of non-responding URLs found, cancelling the build process.")
