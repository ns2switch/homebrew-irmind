class Irmind < Formula
  desc "Terminal assistant for incident response and forensic analysis"
  homepage "https://github.com/ns2switch/irmind"
  license any_of: ["MIT", "Apache-2.0"]

  # IRMind release: v0.7.1

  on_macos do
    on_arm do
      url "https://github.com/ns2switch/irmind/releases/download/v0.7.1/irmind-macos-aarch64", using: :nounzip
      sha256 "28105028bdef0eb2d5e3c541819b9a5c6a87ad06b871e68b410ce458a418a8c6"

      resource "irmind-evtx" do
        url "https://github.com/ns2switch/irmind/releases/download/v0.7.1/irmind-evtx-macos-aarch64", using: :nounzip
        sha256 "650df7dae3d3085c83c814a26281959d4d58e27bf1c4a6c3fc3671e72a307524"
      end
    end
    on_intel do
      url "https://github.com/ns2switch/irmind/releases/download/v0.7.1/irmind-macos-x86_64", using: :nounzip
      sha256 "1f5f9ee71ad734400fc9d19c6b08425312ea091ba3457e89bc610225a85571be"

      resource "irmind-evtx" do
        url "https://github.com/ns2switch/irmind/releases/download/v0.7.1/irmind-evtx-macos-x86_64", using: :nounzip
        sha256 "22d6ad49e120d51a74814d112236b45c57ae8d32018d04859573b38a7898de67"
      end
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/ns2switch/irmind/releases/download/v0.7.1/irmind-linux-aarch64", using: :nounzip
      sha256 "221b6e96eff36e319c5b434a6d55507f2d73d7d11d90670683fdfad358b722c6"

      resource "irmind-evtx" do
        url "https://github.com/ns2switch/irmind/releases/download/v0.7.1/irmind-evtx-linux-aarch64", using: :nounzip
        sha256 "c7bf3e7599c8bf131368f4324bb2f27cc4742662c7d289bcf10013b47cb308fa"
      end
    end
    on_intel do
      url "https://github.com/ns2switch/irmind/releases/download/v0.7.1/irmind-linux-x86_64", using: :nounzip
      sha256 "17f5e9762bd70c6f7cb054e0f8643baa4339bf62eb5f0172c85386b27384bcfc"

      resource "irmind-evtx" do
        url "https://github.com/ns2switch/irmind/releases/download/v0.7.1/irmind-evtx-linux-x86_64", using: :nounzip
        sha256 "bda2b51410bdf35a147bb84aeb9a03269b833ad8f5c3da8baee031d8aad594ca"
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
