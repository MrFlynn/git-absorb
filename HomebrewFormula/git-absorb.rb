class GitAbsorb < Formula
  version "0.2.1"
  desc "An extension for Git that combines multiple repositories into a single repository"
  homepage "https://github.com/MrFlynn/git-absorb"
  url "https://github.com/MrFlynn/git-absorb/archive/v0.2.1.tar.gz"
  sha256 "02f2b8370858f347975ff2525f9fca478b2ae3a92e8a1d7be4393bb8d854c545"

  depends_on "bash"

  def install
    bin.install "bin/git-absorb"
    man1.install "man/git-absorb.1"
  end
end