class Irmind < Formula
  desc "Terminal assistant for incident response and forensic analysis"
  homepage "https://github.com/ns2switch/irmind"
  license any_of: ["MIT", "Apache-2.0"]

  # IRMind release: v0.6.1

  on_macos do
    on_arm do
      url "https://github.com/ns2switch/irmind/releases/download/v0.6.1/irmind-macos-aarch64", using: :nounzip
      sha256 "61808c160000dc0b62aaa4ec94ba4f697e49089ae0349f9d67a7754f262860ee"

      resource "irmind-evtx" do
        url "https://github.com/ns2switch/irmind/releases/download/v0.6.1/irmind-evtx-macos-aarch64", using: :nounzip
        sha256 "3a3f535b816d714295322e8dcc5fab3669922a008a9dc47610abae12b6510089"
      end
    end
    on_intel do
      url "https://github.com/ns2switch/irmind/releases/download/v0.6.1/irmind-macos-x86_64", using: :nounzip
      sha256 "6f8a901e548a44d0e2e63b314c377aac9eb7b7a1d3e0a6ccb854896c58ef7dd1"

      resource "irmind-evtx" do
        url "https://github.com/ns2switch/irmind/releases/download/v0.6.1/irmind-evtx-macos-x86_64", using: :nounzip
        sha256 "4e7b2dcbd52ae0ebd8013ec0dabda1373972283684ab78e06ea7368ecc03e25d"
      end
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/ns2switch/irmind/releases/download/v0.6.1/irmind-linux-aarch64", using: :nounzip
      sha256 "c145d7bd06539e0fc64aa464f8ecaf3cb565aa2e1a7b3a6cac91e93ac9f35656"

      resource "irmind-evtx" do
        url "https://github.com/ns2switch/irmind/releases/download/v0.6.1/irmind-evtx-linux-aarch64", using: :nounzip
        sha256 "0fe136ffe772896455b2885f44b5da226640d68211572b26ab3cce4458661e18"
      end
    end
    on_intel do
      url "https://github.com/ns2switch/irmind/releases/download/v0.6.1/irmind-linux-x86_64", using: :nounzip
      sha256 "066c1fbdd2626278ef3591b3575ab7d6662f44ecb70a7e4dd2943d9dd02bafa0"

      resource "irmind-evtx" do
        url "https://github.com/ns2switch/irmind/releases/download/v0.6.1/irmind-evtx-linux-x86_64", using: :nounzip
        sha256 "0b29600c85621fffc6d4a19e1513224e8e33d5fe9eebb766418749db5f6281ad"
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
