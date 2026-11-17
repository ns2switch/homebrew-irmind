import unittest
from unittest.mock import patch
from pathlib import Path
import tempfile
import update

class FormulaTests(unittest.TestCase):
    def hashes(self):
        return {prefix + asset: 'a' * 64 for _, _, asset in update.PLATFORMS
                for prefix in ('irmind-', 'irmind-evtx-')}

    def test_all_four_platforms_install_both_verified_binaries(self):
        output = update.formula('v0.5.3', self.hashes())
        self.assertEqual(output.count('sha256 "' + 'a' * 64 + '"'), 8)
        self.assertEqual(output.count('resource "irmind-evtx"'), 4)
        self.assertIn('bin.install Dir["irmind-evtx-*"].fetch(0) => "irmind-evtx"', output)

    def test_no_missing_intel_asset_or_helper_is_silently_accepted(self):
        for name in self.hashes():
            values = self.hashes(); del values[name]
            with self.assertRaises(ValueError): update.formula('v0.5.3', values)

    def test_tag_and_checksum_injection_are_rejected(self):
        for tag in ['latest', '../main', 'v0.5.3;id', 'v0.5.3\n', 'v00.5.3']:
            with self.assertRaises(ValueError): update.formula(tag, self.hashes())
        for text in ['a'*64+'  ../bad', 'a'*64+'  file\n'+'a'*64+'  file', 'x'*64+'  file']:
            with self.assertRaises(ValueError): update.checksums(text)

    def test_verification_uses_exact_tag_identity_and_oidc_issuer(self):
        with tempfile.TemporaryDirectory() as temporary:
            root=Path(temporary)
            (root/'SHA256SUMS').write_text('a'*64+'  irmind-linux-x86_64\n')
            (root/'SHA256SUMS.sigstore.json').write_text('{}')
            with patch.object(update,'run',return_value='') as call:
                update.authenticate('v0.5.3',root)
            command=call.call_args.args[0]
            self.assertIn(update.WORKFLOW+'v0.5.3',command)
            self.assertIn('https://token.actions.githubusercontent.com',command)

    def test_latest_includes_published_prereleases_and_excludes_drafts(self):
        with patch.object(update,'run',return_value='[{"tag_name":"v0.5.3","draft":false,"prerelease":true},{"tag_name":"v0.6.0","draft":true}]'):
            self.assertEqual(update.latest(),'v0.5.3')

    def test_source_formula_must_equal_authenticated_recipe(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            source = root / 'irmind.rb'
            output = root / 'generated.rb'
            expected = update.formula('v0.5.3', self.hashes())
            source.write_text(expected + "\n# unreviewed recipe modification\n")
            args = ['update.py', '--check-source', str(source), '--output', str(output)]
            with patch('sys.argv', args), patch.object(update, 'authenticate', return_value=self.hashes()):
                with self.assertRaises(ValueError): update.main()
            self.assertFalse(output.exists())

    def test_older_dispatch_cannot_downgrade_published_formula(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            source = root / 'irmind.rb'
            source.write_text(update.formula('v0.5.4', self.hashes()))
            args = ['update.py', '--tag', 'v0.5.3', '--minimum-formula', str(source),
                    '--output', str(root / 'out.rb')]
            with patch('sys.argv', args):
                with self.assertRaises(ValueError): update.main()
            self.assertFalse((root / 'out.rb').exists())

if __name__=='__main__':unittest.main()

