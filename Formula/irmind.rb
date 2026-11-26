class Irmind < Formula
  desc "Terminal assistant for incident response and forensic analysis"
  homepage "https://github.com/ns2switch/irmind"
  license any_of: ["MIT", "Apache-2.0"]

  # IRMind release: v0.7.4

  on_macos do
    on_arm do
      url "https://github.com/ns2switch/irmind/releases/download/v0.7.4/irmind-macos-aarch64", using: :nounzip
      sha256 "22f2def936ae0e88aa5c49bfdb190027fa16c9c83f89610df8384c0ab4a015fa"

      resource "irmind-evtx" do
        url "https://github.com/ns2switch/irmind/releases/download/v0.7.4/irmind-evtx-macos-aarch64", using: :nounzip
        sha256 "8879ec120aea51f4136c69c23f3e64427b06cf7fd01a13216ae4284d4253f332"
      end
    end
    on_intel do
      url "https://github.com/ns2switch/irmind/releases/download/v0.7.4/irmind-macos-x86_64", using: :nounzip
      sha256 "946a23be338acd63941f19c5492ce1e467643e953cfe36d7fceaddb678c983f6"

      resource "irmind-evtx" do
        url "https://github.com/ns2switch/irmind/releases/download/v0.7.4/irmind-evtx-macos-x86_64", using: :nounzip
        sha256 "ed65d931a155ff3f35e66f9fcc897c49eba83ca85a869387e179a855abc4ad71"
      end
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/ns2switch/irmind/releases/download/v0.7.4/irmind-linux-aarch64", using: :nounzip
      sha256 "bf4feb18aa4425c59062bd0d62cfe262ac49e9f5ebe09351551651ee07a207d0"

      resource "irmind-evtx" do
        url "https://github.com/ns2switch/irmind/releases/download/v0.7.4/irmind-evtx-linux-aarch64", using: :nounzip
        sha256 "046bed067a151701dd6d8b2aa929daee6839a5786f68ba41d45470c6be02ae1d"
      end
    end
    on_intel do
      url "https://github.com/ns2switch/irmind/releases/download/v0.7.4/irmind-linux-x86_64", using: :nounzip
      sha256 "b218b8c4ce3e28cfdeb48f1e48354feddc0d7c282ac5207b909d4654a855dd80"

      resource "irmind-evtx" do
        url "https://github.com/ns2switch/irmind/releases/download/v0.7.4/irmind-evtx-linux-x86_64", using: :nounzip
        sha256 "1afe179d83dbbbcf5d6bcbf3c3399e5cc5e63bc0f75c144656f025b6b8c99c60"
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
