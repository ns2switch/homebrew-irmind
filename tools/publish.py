"""Publish the tested formula with an atomic, non-forced branch update."""
import base64
import json
import os
from pathlib import Path
import re
import subprocess
import sys


def api(path, method='GET', payload=None):
    args = ['gh', 'api', path, '--method', method]
    if payload is not None: args += ['--input', '-']
    result = subprocess.run(args, input=json.dumps(payload) if payload is not None else None,
                            text=True, capture_output=True, check=True, timeout=120)
    return json.loads(result.stdout)


def main():
    repo = os.environ['GITHUB_REPOSITORY']
    if repo != 'ns2switch/homebrew-irmind': raise ValueError('Unexpected repository')
    expected = os.environ['EXPECTED_COMMIT']
    if not re.fullmatch('[0-9a-f]{40}', expected): raise ValueError('Invalid source commit')
    if api(f'repos/{repo}/git/ref/heads/main')['object']['sha'] != expected:
        raise ValueError('Main changed; rerun verification before publishing')
    path = Path(sys.argv[1])
    if path.stat().st_size > 64_000: raise ValueError('Formula exceeds its bound')
    content = path.read_bytes()
    match = re.search(rb'^  # IRMind release: v([0-9]+\.[0-9]+\.[0-9]+)$', content, re.M)
    if not match: raise ValueError('No exact version in tested formula')
    parent = api(f'repos/{repo}/git/commits/{expected}')
    blob = api(f'repos/{repo}/git/blobs', 'POST',
               {'content': base64.b64encode(content).decode(), 'encoding': 'base64'})
    tree = api(f'repos/{repo}/git/trees', 'POST', {'base_tree': parent['tree']['sha'],
               'tree': [{'path': 'Formula/irmind.rb', 'mode': '100644', 'type': 'blob', 'sha': blob['sha']}]})
    message = ('Update verified IRMind formula to ' + match[1].decode() +
               '\n\nSigned-off-by: github-actions[bot] <41898282+github-actions[bot]@users.noreply.github.com>')
    commit = api(f'repos/{repo}/git/commits', 'POST',
                 {'message': message, 'tree': tree['sha'], 'parents': [expected]})
    api(f'repos/{repo}/git/refs/heads/main', 'PATCH', {'sha': commit['sha'], 'force': False})
    print('Verified native formula published at', commit['sha'])


if __name__ == '__main__': main()
