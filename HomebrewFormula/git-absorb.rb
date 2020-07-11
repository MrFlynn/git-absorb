class GitAbsorb < Formula
  version "0.2.0"
  desc "An extension for Git that combines multiple repositories into a single repository"
  homepage "https://github.com/MrFlynn/git-absorb"
  url "https://github.com/MrFlynn/git-absorb/archive/v0.2.0.tar.gz"
  sha256 "9e87daac2b6cb182e02657fdb8ff085ad018cf6164919ac21493a355fe4291c6"

  depends_on "bash"

  def install
    bin.install "bin/git-absorb"
    man1.install "man/git-absorb.1"
  end
end