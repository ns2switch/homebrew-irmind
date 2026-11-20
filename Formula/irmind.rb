class Irmind < Formula
  desc "Terminal assistant for incident response and forensic analysis"
  homepage "https://github.com/ns2switch/irmind"
  license any_of: ["MIT", "Apache-2.0"]

  # IRMind release: v0.5.5

  on_macos do
    on_arm do
      url "https://github.com/ns2switch/irmind/releases/download/v0.5.5/irmind-macos-aarch64", using: :nounzip
      sha256 "0972c9e6d2154db95ceeb7575148c8d2b7fcc53af5ba0a3db6c138bfd52f0232"

      resource "irmind-evtx" do
        url "https://github.com/ns2switch/irmind/releases/download/v0.5.5/irmind-evtx-macos-aarch64", using: :nounzip
        sha256 "3a760c8c5e5469eacd7998b14f16702fbfbc8060fb52f6595aed3dc109e99552"
      end
    end
    on_intel do
      url "https://github.com/ns2switch/irmind/releases/download/v0.5.5/irmind-macos-x86_64", using: :nounzip
      sha256 "9b328c7a5ade4d06bb63b3061b2d968db0a11742bcd9e215bddabd170c318a03"

      resource "irmind-evtx" do
        url "https://github.com/ns2switch/irmind/releases/download/v0.5.5/irmind-evtx-macos-x86_64", using: :nounzip
        sha256 "23cd1699b5081526103c4230ca7c671435ba69994b2a234c1976fe0ce305b25e"
      end
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/ns2switch/irmind/releases/download/v0.5.5/irmind-linux-aarch64", using: :nounzip
      sha256 "ec1dbe9b12c928c6ee7bd5c48a1bb924a4d2770a7340cc623ff9b80cb0ef0c18"

      resource "irmind-evtx" do
        url "https://github.com/ns2switch/irmind/releases/download/v0.5.5/irmind-evtx-linux-aarch64", using: :nounzip
        sha256 "977632d402ddc82161fbb27388bf07a679e887a36da26668f4c67e0fa6061e2d"
      end
    end
    on_intel do
      url "https://github.com/ns2switch/irmind/releases/download/v0.5.5/irmind-linux-x86_64", using: :nounzip
      sha256 "145ad7d5ccd3b9c6d7562937d17d5072692ed2be6fb77b4a9ec63ac3becd1e5e"

      resource "irmind-evtx" do
        url "https://github.com/ns2switch/irmind/releases/download/v0.5.5/irmind-evtx-linux-x86_64", using: :nounzip
        sha256 "3182b224e77f50d218674995c22f30731ee76d5171ce84504aa30ded3c1a79fb"
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
