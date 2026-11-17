class Irmind < Formula
  desc "Terminal assistant for incident response and forensic analysis"
  homepage "https://github.com/ns2switch/irmind"
  version "0.5.3"
  license any_of: ["MIT", "Apache-2.0"]

  on_macos do
    on_arm do
      url "https://github.com/ns2switch/irmind/releases/download/v0.5.3/irmind-macos-aarch64", using: :nounzip
      sha256 "ddbfe57c9029f30c9fc68f537cef70165dbb28a60e0f5648cbd08ed200f88ec1"

      resource "irmind-evtx" do
        url "https://github.com/ns2switch/irmind/releases/download/v0.5.3/irmind-evtx-macos-aarch64", using: :nounzip
        sha256 "679b72d1512a1e94e8d2ddac3945b92c09c34d64b671cd5118bf7e540fc97805"
      end
    end
  end

  on_macos do
    on_intel do
      url "https://github.com/ns2switch/irmind/releases/download/v0.5.3/irmind-macos-x86_64", using: :nounzip
      sha256 "b8522c4baeb232eb7c09f1da48ea56dabf9ba25d811864eff80290eaef8791c5"

      resource "irmind-evtx" do
        url "https://github.com/ns2switch/irmind/releases/download/v0.5.3/irmind-evtx-macos-x86_64", using: :nounzip
        sha256 "0d1ebfcc899155a02e94793f4ba2c79b8109b8e62116bf30cf76b150e639ada0"
      end
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/ns2switch/irmind/releases/download/v0.5.3/irmind-linux-aarch64", using: :nounzip
      sha256 "1e7bf523523fb47106a1b7b3e6482163a6200941ac0069a85adeddb7cb9008b2"

      resource "irmind-evtx" do
        url "https://github.com/ns2switch/irmind/releases/download/v0.5.3/irmind-evtx-linux-aarch64", using: :nounzip
        sha256 "8ace91cd44ec52a8cd4b2f8e40a89f90a9d255124f677dc948edec036f6ae4ad"
      end
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/ns2switch/irmind/releases/download/v0.5.3/irmind-linux-x86_64", using: :nounzip
      sha256 "312cefb522f23a2382f8085d93c4fa830565eac0b45a4a410211feb21bc943ce"

      resource "irmind-evtx" do
        url "https://github.com/ns2switch/irmind/releases/download/v0.5.3/irmind-evtx-linux-x86_64", using: :nounzip
        sha256 "de1581359c18d7eef256f05daaeb2317ed5397e0d307f26d667d9be3a10387c2"
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
