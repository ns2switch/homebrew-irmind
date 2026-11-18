class Irmind < Formula
  desc "Terminal assistant for incident response and forensic analysis"
  homepage "https://github.com/ns2switch/irmind"
  license any_of: ["MIT", "Apache-2.0"]

  # IRMind release: v0.5.4

  on_macos do
    on_arm do
      url "https://github.com/ns2switch/irmind/releases/download/v0.5.4/irmind-macos-aarch64", using: :nounzip
      sha256 "3f5b77f131c10c4d39b941f31a21f8f639464199a5a3bdbdbb7179aef22352cc"

      resource "irmind-evtx" do
        url "https://github.com/ns2switch/irmind/releases/download/v0.5.4/irmind-evtx-macos-aarch64", using: :nounzip
        sha256 "f6e50561e7788da0e65c6d1efe900b515e99cb766cf1ec78c1cd8063c92a56c6"
      end
    end
    on_intel do
      url "https://github.com/ns2switch/irmind/releases/download/v0.5.4/irmind-macos-x86_64", using: :nounzip
      sha256 "9f101c5a3ce09eeee9faabb0fce2fa30aeaaa5235255fcbd05bbbd9d8e579c10"

      resource "irmind-evtx" do
        url "https://github.com/ns2switch/irmind/releases/download/v0.5.4/irmind-evtx-macos-x86_64", using: :nounzip
        sha256 "cf1920a8e2f8aa6ff63b343e331b42d8f1ae0d76bc6f6ec5f0847ad4df486548"
      end
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/ns2switch/irmind/releases/download/v0.5.4/irmind-linux-aarch64", using: :nounzip
      sha256 "12c0c98cacd4a8feb155a29ebff6e020e47d9fdcad1814a3764e5a8487decd8b"

      resource "irmind-evtx" do
        url "https://github.com/ns2switch/irmind/releases/download/v0.5.4/irmind-evtx-linux-aarch64", using: :nounzip
        sha256 "2bd3396e1161c59bd528fc1eb3b50141333f6418a03ba2ab70758fd675a62bf3"
      end
    end
    on_intel do
      url "https://github.com/ns2switch/irmind/releases/download/v0.5.4/irmind-linux-x86_64", using: :nounzip
      sha256 "7bbff032bc077a96c9e97e279a7d1fefcf8391c9e52f65e7da9dd960da9cffda"

      resource "irmind-evtx" do
        url "https://github.com/ns2switch/irmind/releases/download/v0.5.4/irmind-evtx-linux-x86_64", using: :nounzip
        sha256 "8154d8726cc913cb5344cb878b2be52afce8ea2be2c2d9e76f88f5dc11d670b2"
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
