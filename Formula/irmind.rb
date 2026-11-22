class Irmind < Formula
  desc "Terminal assistant for incident response and forensic analysis"
  homepage "https://github.com/ns2switch/irmind"
  license any_of: ["MIT", "Apache-2.0"]

  # IRMind release: v0.6.0

  on_macos do
    on_arm do
      url "https://github.com/ns2switch/irmind/releases/download/v0.6.0/irmind-macos-aarch64", using: :nounzip
      sha256 "910143e5f81d9b2be0ebd0fcfe46f6906c2e4bbf4c48ab36d1dcd3b30fce581e"

      resource "irmind-evtx" do
        url "https://github.com/ns2switch/irmind/releases/download/v0.6.0/irmind-evtx-macos-aarch64", using: :nounzip
        sha256 "25945c727a295be0db7070c3419bdc0e03dcba02e7cde575c3853da897b2f06b"
      end
    end
    on_intel do
      url "https://github.com/ns2switch/irmind/releases/download/v0.6.0/irmind-macos-x86_64", using: :nounzip
      sha256 "ad099d153d2407166ccb93a6ccec87c8c484cac9b2f17fa2f1b66535a8752d83"

      resource "irmind-evtx" do
        url "https://github.com/ns2switch/irmind/releases/download/v0.6.0/irmind-evtx-macos-x86_64", using: :nounzip
        sha256 "8859eaf4649c34954ffe29769cefbf841e128f309ba39be1650b1ab5a6b84f61"
      end
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/ns2switch/irmind/releases/download/v0.6.0/irmind-linux-aarch64", using: :nounzip
      sha256 "fc5f7a196e50df39cf49fa9e8b37c102791656946bceb2975eac9dd7a9ffaf7c"

      resource "irmind-evtx" do
        url "https://github.com/ns2switch/irmind/releases/download/v0.6.0/irmind-evtx-linux-aarch64", using: :nounzip
        sha256 "1b95a165dae3cdd8f06f941e4d9259a058c4e8f34175cf898a10b2d767b25e69"
      end
    end
    on_intel do
      url "https://github.com/ns2switch/irmind/releases/download/v0.6.0/irmind-linux-x86_64", using: :nounzip
      sha256 "0901576065a059e0233ec1af722d1af02799fb87dd0007236aec9b81b43f85fb"

      resource "irmind-evtx" do
        url "https://github.com/ns2switch/irmind/releases/download/v0.6.0/irmind-evtx-linux-x86_64", using: :nounzip
        sha256 "0385af7c5387640f9e13cdb2514f82838e1c19b8e6bfef1192a74a28cec6b177"
      end
    end
  end

  def install
    bin.install Dir["irmind-*"].fetch(0) => "irmind"
    resource("irmind-evtx").stage do
      bin.install Dir["irmind-evtx-*"].fetch(0) => "irmind-evtx"
    end
  end

  test do
    assert_equal "irmind #{version}\n", shell_output("#{bin}/irmind --version")
    assert_match "Usage:", shell_output("#{bin}/irmind --help")
    assert_path_exists bin/"irmind-evtx"
  end
end
