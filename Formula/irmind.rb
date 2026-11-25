class Irmind < Formula
  desc "Terminal assistant for incident response and forensic analysis"
  homepage "https://github.com/ns2switch/irmind"
  license any_of: ["MIT", "Apache-2.0"]

  # IRMind release: v0.7.2

  on_macos do
    on_arm do
      url "https://github.com/ns2switch/irmind/releases/download/v0.7.2/irmind-macos-aarch64", using: :nounzip
      sha256 "63fbffc82a46433a263070e1a97749a290afbe64e7ea8c27e5cbecf4427c6b5f"

      resource "irmind-evtx" do
        url "https://github.com/ns2switch/irmind/releases/download/v0.7.2/irmind-evtx-macos-aarch64", using: :nounzip
        sha256 "342a547155fe6176ee56f36b325db8eb5dc4c116ac8287adcd4648a77fcf8af5"
      end
    end
    on_intel do
      url "https://github.com/ns2switch/irmind/releases/download/v0.7.2/irmind-macos-x86_64", using: :nounzip
      sha256 "b20ee9d76e0e81e37f928b928959ebc710452943e933d89706f5999c249c639e"

      resource "irmind-evtx" do
        url "https://github.com/ns2switch/irmind/releases/download/v0.7.2/irmind-evtx-macos-x86_64", using: :nounzip
        sha256 "c5b0903dbc1996b8fb0f5a461c3f93b63a2f32645528a1e17d822f0f95ee3814"
      end
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/ns2switch/irmind/releases/download/v0.7.2/irmind-linux-aarch64", using: :nounzip
      sha256 "093e7de652c905f3a2b723c0a57b5fcfb6ecf1ba68b280278992002e2422c1ce"

      resource "irmind-evtx" do
        url "https://github.com/ns2switch/irmind/releases/download/v0.7.2/irmind-evtx-linux-aarch64", using: :nounzip
        sha256 "046bed067a151701dd6d8b2aa929daee6839a5786f68ba41d45470c6be02ae1d"
      end
    end
    on_intel do
      url "https://github.com/ns2switch/irmind/releases/download/v0.7.2/irmind-linux-x86_64", using: :nounzip
      sha256 "2bc432f4e59b9d2f5cdbc199c5143b9d536f13ddb72240691b286d4ed0e637cc"

      resource "irmind-evtx" do
        url "https://github.com/ns2switch/irmind/releases/download/v0.7.2/irmind-evtx-linux-x86_64", using: :nounzip
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
