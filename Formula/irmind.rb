class Irmind < Formula
  desc "Terminal assistant for incident response and forensic analysis"
  homepage "https://github.com/ns2switch/irmind"
  license any_of: ["MIT", "Apache-2.0"]

  # IRMind release: v0.7.3

  on_macos do
    on_arm do
      url "https://github.com/ns2switch/irmind/releases/download/v0.7.3/irmind-macos-aarch64", using: :nounzip
      sha256 "9ba41142c2bd510b3b29f3eaa162929aed798e1fece17452ead079abec37be64"

      resource "irmind-evtx" do
        url "https://github.com/ns2switch/irmind/releases/download/v0.7.3/irmind-evtx-macos-aarch64", using: :nounzip
        sha256 "0128a67851d2ee7a67f7267ab88677a3fc344da799598c4bf1241f41a06a3f55"
      end
    end
    on_intel do
      url "https://github.com/ns2switch/irmind/releases/download/v0.7.3/irmind-macos-x86_64", using: :nounzip
      sha256 "dd4da0f580c18777da8666cc6d8d7204d3ec0e0a4dd17038bde9c87d4db63793"

      resource "irmind-evtx" do
        url "https://github.com/ns2switch/irmind/releases/download/v0.7.3/irmind-evtx-macos-x86_64", using: :nounzip
        sha256 "4c32c1550e42eb9765cb76d036150eff468e04a704cdff02133c5dc53f6ce30f"
      end
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/ns2switch/irmind/releases/download/v0.7.3/irmind-linux-aarch64", using: :nounzip
      sha256 "e3f899b7daea0a5b7450985c41f7529920a51e011563b35d9d341d102d29651f"

      resource "irmind-evtx" do
        url "https://github.com/ns2switch/irmind/releases/download/v0.7.3/irmind-evtx-linux-aarch64", using: :nounzip
        sha256 "6d99eec1b538bb9068ea4cecae788dbb84ef489a476301c809f4ce4b1ee55e0d"
      end
    end
    on_intel do
      url "https://github.com/ns2switch/irmind/releases/download/v0.7.3/irmind-linux-x86_64", using: :nounzip
      sha256 "323a436fcc4e8fe2db4a3b19c9963c08267726f07652cabb2d02cd442b81a161"

      resource "irmind-evtx" do
        url "https://github.com/ns2switch/irmind/releases/download/v0.7.3/irmind-evtx-linux-x86_64", using: :nounzip
        sha256 "0e329cfe96e866099636c68d5789c8217a6faefb1f8d17064ab9f7db6091aacf"
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
