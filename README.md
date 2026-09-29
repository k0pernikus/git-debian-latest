# git-debian-latest

Debian packages of the newest git in Debian unstable, rebuilt for Debian 13 (trixie) on GitHub Actions.

Debian trixie ships git 2.47.3. This repository takes the `git` source package from Debian unstable (sid) and
builds it on trixie. The packages link against trixie's own libraries, so they install with no package from any
other suite.

The source package is Debian's: the upstream git release tarball plus Debian's packaging and patches.

## How a build runs

`.github/workflows/build.yml` runs daily and on manual dispatch. Its jobs, in order:

1. `resolve` reads the version of the `git` source package in Debian unstable.
1. `decide` lets the build run only when no release carries the tag for that version.
1. `build` downloads the source package in a `debian:trixie-slim` container and installs its build dependencies
   from trixie. It adds a changelog entry for the rebuild version, then builds every binary package and runs
   git's test suite.
1. `release` publishes a GitHub release carrying every binary package and the full source package.

## Versions

A rebuild of the sid version `1:2.55.0-1` gets the version `1:2.55.0-1~trixie1` and the release tag
`2.55.0-1-trixie1`. The `~` sorts the rebuild below the sid version it came from and above trixie's
`1:2.47.3-0+deb13u1`.

## Install

Packages are built for amd64 only. Download `git` and `git-man` from a release, then install both:

```sh
gh release download <tag> --repo k0pernikus/git-debian-latest --pattern 'git_*_amd64.deb' --pattern 'git-man_*_all.deb'
sudo apt install ./git_*_amd64.deb ./git-man_*_all.deb
```

## License

GPL-2.0-only, the license of git itself. Every release carries the full source package it was built from.
