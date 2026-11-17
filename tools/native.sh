#!/usr/bin/env bash
set -euo pipefail
# All reads in this smoke test are from public repositories and release assets.
# Avoid consulting workstation-specific credential helpers; no stored credential
# or global Git setting is changed.
export GIT_CONFIG_COUNT=1 GIT_CONFIG_KEY_0=credential.helper GIT_CONFIG_VALUE_0='' 
candidate=${1:?candidate formula required}
mode=${2:?candidate or published mode required}
for prefix in /opt/homebrew /usr/local /home/linuxbrew/.linuxbrew; do
  if test -x "$prefix/bin/brew"; then export PATH="$prefix/bin:$PATH"; break; fi
done
command -v brew
brew tap ns2switch/irmind
tap=$(brew --repository ns2switch/irmind)
case "$mode" in
  candidate)
    mkdir -p "$tap/Formula"
    cp "$candidate" "$tap/Formula/irmind.rb"
    ;;
  published)
    cmp "$candidate" "$tap/Formula/irmind.rb"
    ;;
  *) echo 'unsupported smoke-test mode' >&2; exit 1 ;;
esac
# Trust only the exact authenticated formula under test on Homebrew versions
# which require explicit tap trust. Older supported Homebrew needs no grant.
if brew commands --quiet | awk '$0 == "trust" {found=1} END {exit !found}'; then
  brew trust --formula ns2switch/irmind/irmind
fi
brew audit --strict ns2switch/irmind/irmind
trap 'brew uninstall ns2switch/irmind/irmind || true' EXIT
brew install --verbose --debug ns2switch/irmind/irmind
brew test ns2switch/irmind/irmind
irmind --version
python3 tools/check_install.py "$(brew --prefix irmind)/bin" --formula "$candidate"
python3 tools/demo_pty.py "$(brew --prefix irmind)/bin/irmind"
brew uninstall ns2switch/irmind/irmind
trap - EXIT
