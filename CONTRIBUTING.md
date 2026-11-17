# Contributing

Change the generator and its offline tests rather than editing a published hash
by hand. Use only exact release tags, verify the checksum-list signature and
include both matching executables for every supported architecture. Run
`python3 -B tools/test_update.py` and native Homebrew installation tests.

Do not add alternate mirrors, skip hashes/signatures, execute a downloaded
binary before verification, or add a production token to this repository.
Release metadata is updated only after native checks and an optimistic main
commit check. A failing or incomplete release leaves the formula unchanged.

Product changes belong in [IRMind](https://github.com/ns2switch/irmind). Skill
methodologies belong in [irmind-skills](https://github.com/ns2switch/irmind-skills).
