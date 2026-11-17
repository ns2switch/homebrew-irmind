"""Smoke-test the installed binary in a real 80x24 POSIX terminal."""
import argparse
import errno
import fcntl
import json
import os
from pathlib import Path
import re
import select
import signal
import struct
import subprocess
import tempfile
import termios
import time

CSI = re.compile(r'\x1b\[[0-?]*[ -/]*[@-~]')


def smoke(binary):
    binary = str(Path(binary).resolve(strict=True))
    with tempfile.TemporaryDirectory(prefix='irmind-brew-demo-') as directory:
        root = Path(directory)
        real = root / 'real'; real.mkdir(mode=0o700)
        marker = real / 'unrelated.txt'; marker.write_text('preserve me', encoding='utf-8')
        ephemeral = root / 'temporary'; ephemeral.mkdir(mode=0o700)
        env = os.environ.copy()
        env.update(TERM='xterm-256color', NO_COLOR='1', TMPDIR=str(ephemeral),
                   TMP=str(ephemeral), TEMP=str(ephemeral), HTTP_PROXY='', HTTPS_PROXY='')
        import pty
        master, slave = pty.openpty()
        fcntl.ioctl(slave, termios.TIOCSWINSZ, struct.pack('HHHH', 24, 80, 0, 0))
        def session():
            os.setsid()
            fcntl.ioctl(0, termios.TIOCSCTTY, 0)
        process = subprocess.Popen([binary, '--home', str(real), 'demo', '--scripted',
                                    '--presentation-speed', '50'], stdin=slave, stdout=slave,
                                   stderr=slave, env=env, preexec_fn=session, close_fds=True)
        os.close(slave)
        data = bytearray(); started = False; closed = False
        deadline = time.monotonic() + 30
        try:
            while time.monotonic() < deadline:
                if select.select([master], [], [], 0.05)[0]:
                    try:
                        block = os.read(master, 8192)
                    except OSError as error:
                        if error.errno == errno.EIO: break
                        raise
                    if not block: break
                    data.extend(block)
                    if len(data) > 262144: raise RuntimeError('demo terminal output exceeded bound')
                    text = CSI.sub('', data.decode('utf-8', errors='replace'))
                    if not started and re.search(r'Step\s*1\s*of\s*10', text):
                        started = True
                        os.write(master, b'\x1b')
                    if 'Demo data deleted' in text:
                        closed = True
                        break
                elif process.poll() is not None:
                    break
            status = process.wait(timeout=5) if closed else None
            if not started or not closed or status != 0:
                raise RuntimeError('80x24 demo did not open and exit cleanly: ' + ''.join(c for c in text[-1500:] if ord(c) >= 32 or c == '\n'))
            if marker.read_text() != 'preserve me' or list(ephemeral.iterdir()):
                raise RuntimeError('demo cleanup or isolation check failed')
            if sorted(p.name for p in real.iterdir()) != ['unrelated.txt']:
                raise RuntimeError('demo modified the real data directory')
        finally:
            if process.poll() is None:
                os.killpg(process.pid, signal.SIGTERM)
                try: process.wait(timeout=5)
                except subprocess.TimeoutExpired:
                    os.killpg(process.pid, signal.SIGKILL); process.wait(timeout=5)
            os.close(master)
    return {'columns': 80, 'rows': 24, 'demo_started': True, 'clean_exit': True,
            'temporary_data_removed': True, 'real_data_preserved': True}


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('binary')
    args = parser.parse_args()
    print(json.dumps(smoke(args.binary), sort_keys=True))
