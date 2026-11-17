"""Record native execution and macOS quarantine attributes without removing them."""
import argparse
import hashlib
import platform
import re
import json
import os
from pathlib import Path
import subprocess
import sys

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('bin', type=Path)
parser.add_argument('--formula', type=Path, required=True)
args = parser.parse_args()
result = {'platform': sys.platform, 'native_apple_signing_claimed': False}
formula = args.formula.read_text(encoding='utf-8')
system = 'macos' if sys.platform == 'darwin' else 'linux'
architecture = 'aarch64' if platform.machine().lower() in ('arm64', 'aarch64') else 'x86_64'
for name in ('irmind', 'irmind-evtx'):
    binary = (args.bin / name).resolve(strict=True)
    asset = f'{name}-{system}-{architecture}'
    pattern = r'url "https://github\.com/ns2switch/irmind/releases/download/v[0-9.]+/' + re.escape(asset) + r'", using: :nounzip\s*\n\s*sha256 "([0-9a-f]{64})"'
    expected = re.findall(pattern, formula)
    if len(expected) != 1 or hashlib.file_digest(binary.open('rb'), 'sha256').hexdigest() != expected[0]:
        raise SystemExit('Installed bytes do not match the authenticated release checksum')
    result[name + '_sha256_matches'] = True
    if sys.platform == 'darwin':
        attributes = subprocess.run(['/usr/bin/xattr', str(binary)], capture_output=True, text=True, check=True, timeout=10).stdout.splitlines()
        if 'com.apple.quarantine' in attributes:
            raise SystemExit('Homebrew payload unexpectedly has com.apple.quarantine; not removed')
        result[name + '_quarantine_absent'] = True
version = subprocess.run([str(args.bin / 'irmind'), '--version'], text=True,
                         capture_output=True, check=True, timeout=15)
if version.stderr:
    raise SystemExit('Installed binary emitted an unexpected startup warning')
result['version'] = version.stdout.strip()
print(json.dumps(result, sort_keys=True))
