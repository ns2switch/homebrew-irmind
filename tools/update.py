#!/usr/bin/env python3
"""Generate a pinned formula only from an exact-tag authenticated checksum list."""
import argparse
import hashlib
import json
from pathlib import Path
import re
import subprocess
import tempfile

REPO = 'ns2switch/irmind'
WORKFLOW = 'https://github.com/ns2switch/irmind/.github/workflows/ci.yml@refs/tags/'
PLATFORMS = (('macos', 'arm', 'macos-aarch64'), ('macos', 'intel', 'macos-x86_64'),
             ('linux', 'arm', 'linux-aarch64'), ('linux', 'intel', 'linux-x86_64'))


def run(args):
    result = subprocess.run(args, text=True, capture_output=True, timeout=300)
    if result.returncode:
        raise ValueError('Release verification command failed; formula unchanged')
    return result.stdout


def version(tag):
    if not isinstance(tag, str) or len(tag) > 64:
        raise ValueError('Invalid release tag length')
    if not re.fullmatch(r'v(?:0|[1-9][0-9]*)\.(?:0|[1-9][0-9]*)\.(?:0|[1-9][0-9]*)', tag):
        raise ValueError('Expected an exact numeric release tag')
    return tuple(map(int, tag[1:].split('.')))


def latest():
    records = json.loads(run(['gh', 'api', f'repos/{REPO}/releases?per_page=100']))
    candidates = []
    for record in records:
        if record.get('draft'):
            continue
        try:
            candidates.append((version(record['tag_name']), record['tag_name']))
        except (ValueError, KeyError):
            continue
    if not candidates:
        raise ValueError('No published numeric release found')
    return max(candidates)[1]


def checksums(text):
    found = {}
    if len(text.encode()) > 1_000_000:
        raise ValueError('Checksum list exceeds its bound')
    for line in text.splitlines():
        match = re.fullmatch(r'([0-9a-f]{64})  ([A-Za-z0-9._-]+)', line)
        if not match or match[2] in found or match[2] in ('.', '..'):
            raise ValueError('Malformed or duplicate checksum entry')
        found[match[2]] = match[1]
    return found


def authenticate(tag, directory):
    version(tag)
    run(['gh', 'release', 'download', tag, '-R', REPO, '-D', str(directory),
         '-p', 'SHA256SUMS', '-p', 'SHA256SUMS.sigstore.json'])
    sums = directory / 'SHA256SUMS'
    if sums.stat().st_size > 1_000_000 or (directory / 'SHA256SUMS.sigstore.json').stat().st_size > 1_000_000:
        raise ValueError('Release verification material exceeds its bound')
    run(['cosign', 'verify-blob', str(sums), '--bundle', str(directory / 'SHA256SUMS.sigstore.json'),
         '--certificate-identity', WORKFLOW + tag,
         '--certificate-oidc-issuer', 'https://token.actions.githubusercontent.com'])
    return checksums(sums.read_text(encoding='ascii'))


def formula(tag, sums):
    version(tag)
    lines = ['class Irmind < Formula', '  desc "Terminal assistant for incident response and forensic analysis"',
             '  homepage "https://github.com/ns2switch/irmind"', f'  version "{tag[1:]}"',
             '  license any_of: ["MIT", "Apache-2.0"]', '']
    supported = []
    for system, cpu, asset in PLATFORMS:
        main, helper = 'irmind-' + asset, 'irmind-evtx-' + asset
        if main not in sums or helper not in sums:
            continue
        if not all(re.fullmatch('[0-9a-f]{64}', sums[name]) for name in (main, helper)):
            raise ValueError('Invalid artifact hash')
        supported.append(asset)
        origin = f'https://github.com/{REPO}/releases/download/{tag}/'
        lines += [f'  on_{system} do', f'    on_{cpu} do', f'      url "{origin}{main}", using: :nounzip',
                  f'      sha256 "{sums[main]}"', '', '      resource "irmind-evtx" do',
                  f'        url "{origin}{helper}", using: :nounzip', f'        sha256 "{sums[helper]}"',
                  '      end', '    end', '  end', '']
    if len(supported) != len(PLATFORMS):
        raise ValueError('An exact release with all macOS/Linux architectures is required')
    lines += ['  def install', '    bin.install Dir["irmind-*"].fetch(0) => "irmind"',
              '    resource("irmind-evtx").stage do',
              '      bin.install Dir["irmind-evtx-*"].fetch(0) => "irmind-evtx"',
              '    end', '  end', '', '  test do',
              '    assert_equal "irmind #{version}\\n", shell_output("#{bin}/irmind --version")',
              '    assert_match "Usage:", shell_output("#{bin}/irmind --help")',
              '    assert_path_exists bin/"irmind-evtx"', '  end', 'end', '']
    return '\n'.join(lines)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--tag')
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--check-source', type=Path,
                        help='Reject a submitted formula unless it matches authenticated release metadata')
    parser.add_argument('--minimum-formula', type=Path,
                        help='Reject requests older than the currently published formula')
    args = parser.parse_args()
    def formula_tag(path):
        if path.stat().st_size > 64_000:
            raise ValueError('Formula exceeds its bound')
        found = re.findall(r'^  version "([0-9]+\.[0-9]+\.[0-9]+)"$', path.read_text(encoding='utf-8'), re.M)
        if len(found) != 1:
            raise ValueError('Formula must declare one exact version')
        return 'v' + found[0]
    tag = args.tag or (formula_tag(args.check_source) if args.check_source else latest())
    if args.minimum_formula and version(tag) < version(formula_tag(args.minimum_formula)):
        raise ValueError('Refusing to downgrade the tap')
    with tempfile.TemporaryDirectory(prefix='irmind-tap-') as temporary:
        output = formula(tag, authenticate(tag, Path(temporary)))
    if args.check_source and args.check_source.read_text(encoding='utf-8') != output:
        raise ValueError('Submitted formula differs from the authenticated release recipe')
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(output)
    print('Verified formula generated for', tag, 'SHA-256', hashlib.sha256(output.encode()).hexdigest())


if __name__ == '__main__':
    try:
        main()
    except (OSError, ValueError, subprocess.SubprocessError):
        raise SystemExit('Formula generation failed closed; no package metadata was published') from None
