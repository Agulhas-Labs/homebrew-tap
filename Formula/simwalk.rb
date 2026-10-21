# The tap formula for SimWalk. Generated from a template by the release scripts, which fill in the url, the
# version and the checksum of the release being cut - never edit those by hand.
#
# The URL is built from the artifact being released, not from a filename pattern: the tarball's name
# carries the public commit, so a pattern here would point at a file never uploaded under that name.
#
# The formula installs the binary and the runner's sources beside it, and stops there. Registering the MCP
# server and the hook writes to ~/.claude, which is the user's own configuration, so it stays an explicit
# command in the caveats rather than something a package manager does to you.
class Simwalk < Formula
  desc "Deterministic UI walks of a running iOS app, as resolved observations"
  homepage "https://github.com/Agulhas-Labs/simwalk"
  url "https://github.com/Agulhas-Labs/simwalk/releases/download/v0.1.4/simwalk-0.1.4-7181a043-arm64.tar.gz"
  sha256 "638e8bf2ca19434f386ba306e48afc6ca59e873451f5cd4ad3e830689978bfd0"
  license "Apache-2.0"

  depends_on xcode: ["27.0", :build]
  depends_on arch: :arm64
  depends_on macos: :ventura

  def install
    bin.install "bin/simwalk"
    # RUNNER_COMMIT, BINARY_SHA256 and RUNNER_FILES go with the sources: the binary reads them from share/simwalk.
    # Every entry, dot-paths included: a `share/simwalk/*` glob skips .agents/, which RUNNER_FILES lists, and the
    # binary refuses a runner tree missing a listed file.
    pkgshare.install (buildpath/"share/simwalk").children
    doc.install "INSTALL.md", "THIRD-PARTY-NOTICES.txt"
  end

  def caveats
    <<~EOS
      Installing this package does not write to ~/.claude, which is your own configuration. To register
      SimWalk's MCP server, hook and agent guide with Claude Code:

        simwalk install-hook

      The first walk builds SimWalk's XCUITest runner with xcodebuild, so Xcode must be installed.
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/simwalk --version")
    # The runner is paired with the binary by this hash, so brew must not have altered the binary's bytes.
    assert_equal (pkgshare/"BINARY_SHA256").read.strip, Digest::SHA256.file(bin/"simwalk").hexdigest
    # The binary refuses a runner tree missing a file RUNNER_FILES lists, or holding one with other bytes.
    cd pkgshare do
      system "shasum", "-a", "256", "--check", "--quiet", "RUNNER_FILES"
    end
  end
end
