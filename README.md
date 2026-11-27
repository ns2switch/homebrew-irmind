# IRMind Homebrew tap

Prebuilt [IRMind](https://github.com/ns2switch/irmind) terminal incident-response
binaries and the matching isolated EVTX helper. License: MIT OR Apache-2.0.
[Español](README.es.md).

## Install, update and uninstall

With Homebrew already installed:

```sh
brew install ns2switch/irmind/irmind
irmind --version
irmind demo
brew upgrade ns2switch/irmind/irmind
brew uninstall ns2switch/irmind/irmind
```

The formula selects separate macOS arm64, macOS Intel, Linux x86_64 or Linux
arm64 assets. It downloads both executables only from the specified IRMind GitHub
Release and checks their SHA-256 values. Installation does not compile IRMind or
download models or evidence. Upgrading is an explicit Homebrew action; IRMind
does not update itself. Keep the verified creating-version executables outside
Homebrew before upgrading if you need to retain pre-1.0 cases: Homebrew may remove
old kegs, and minor IRMind versions may change formats without migration.

## Trust and native checks

The updater authenticates SHA256SUMS with cosign against the exact IRMind
repository, release workflow, tag and GitHub OIDC issuer before rendering the
formula. Missing architectures, malformed or duplicate checksums, a modified
recipe or a requested downgrade fail closed. Homebrew verifies every payload's
checksum; CI additionally compares the installed bytes with the authenticated
recipe. [Independent signature/provenance verification](https://github.com/ns2switch/irmind/blob/main/docs/platforms.md#verify-a-release-before-installing)
and the [code signing policy](https://github.com/ns2switch/irmind/blob/main/CODE_SIGNING.md)
remain available.

Native CI covers macOS arm64, macOS Intel and Linux x86_64: `brew audit --strict`,
installation, `brew test`, exact version, an 80x24 demo smoke test and uninstall.
The demo smoke uses a real PTY with accelerated presentation, exits after the
first narrated scene and checks temporary cleanup and preservation of an existing
data directory. IRMind's release checks exercise the complete presentation.

macOS checks assert that neither installed executable has `com.apple.quarantine`;
they never remove that attribute. Version and PTY execution must succeed without
startup warnings. These are headless native-runner observations, not a claim of
Developer ID signing, notarization or interactive browser-download validation.

## Release automation

`update.yml` accepts an exact tag for a published stable release through `workflow_dispatch`.
IRMind dispatches it after publishing a tag, using `HOMEBREW_TAP_TOKEN` from its
protected `release` environment. That cross-repository token needs Actions write
access to this tap; it does not publish formula contents.

Read-only jobs authenticate the release and test the generated candidate. A
separate job, using only this repository's ephemeral GITHUB_TOKEN, commits the
formula with a non-forced atomic reference update after all checks pass. Fresh
native runners then install the actual published tap and compare its recipe with
the authenticated candidate. No scheduled update or source-build fallback runs.
Pull-request recipes must match the authenticated renderer byte for byte before
Homebrew evaluates them. Pull requests cannot publish updates.

Set STABLE_TAG to an exact published stable version before dispatching:

```sh
gh workflow run update.yml -R ns2switch/homebrew-irmind --ref main -f tag="$STABLE_TAG"
```

For development, install Python 3.11+, `gh` and cosign 3.1.4 or newer:

```sh
python3 -B tools/test_update.py
python3 tools/update.py --tag "$STABLE_TAG" --output Formula/irmind.rb
```

See [CONTRIBUTING](CONTRIBUTING.md). Do not replace missing hashes with another
architecture or bypass identity verification.

Recent Homebrew versions may ask you to trust a third-party formula before installation. Inspect `Formula/irmind.rb`, then explicitly run `brew trust --formula ns2switch/irmind/irmind` if requested. The native checks grant trust only to this formula after authenticating the recipe; they do not disable Homebrew trust checks globally.
