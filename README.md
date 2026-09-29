# git-debian-latest

Debian packages of the newest git in Debian unstable, rebuilt for Debian 13 (trixie) on GitHub Actions.

Debian trixie ships git 2.47.3. This repository builds two tracks on trixie, both with the packaging of the `git`
source package in Debian unstable (sid):

- **sid**: sid's source package as it is, rebuilt for trixie.
- **upstream**: the newest git release tarball from kernel.org, packaged with sid's `debian/` directory. It is built
  only while that release is newer than sid's, and a failure here does not stop the sid track.

The packages link against trixie's own libraries, so they install with no package from any other suite.

## How a build runs

`.github/workflows/build.yml` runs daily and on manual dispatch. Its jobs, in order:

1. `resolve` reads the version of the `git` source package in Debian unstable and the newest release on
   kernel.org, and emits one build per track.
1. Each build runs [`package.yml`](.github/workflows/package.yml), whose jobs follow.
1. `decide` lets the build run only when no release carries the tag for that version, and lets the image run
   only when that release does not yet record its container image.
1. `build` downloads the source package in a `debian:trixie-slim` container. On the upstream track it replaces the
   tarball with kernel.org's, verified against kernel.org's `sha256sums.asc`. It installs the build dependencies
   from trixie, adds a changelog entry for the rebuild version, then builds every binary package and runs git's
   test suite.
1. `release` publishes a GitHub release carrying every binary package and the full source package.
1. `image` builds the [`Dockerfile`](Dockerfile) from the released packages, pushes it to the GitHub container
   registry, and attaches `container-image.txt` to the release, naming the image by tag and digest.

## Versions

A rebuild of the sid version `1:2.55.0-1` gets the version `1:2.55.0-1~trixie1` and the release tag
`2.55.0-1-trixie1`. The `~` sorts the rebuild below the sid version it came from and above trixie's
`1:2.47.3-0+deb13u1`.

The upstream release 2.56.0 gets the version `1:2.56.0-0~trixie1` and the tag `2.56.0-0-trixie1`. The Debian
revision `0` sorts it below the `1:2.56.0-1` that sid will carry once it packages that release.

## Install

Packages are built for amd64 only. Download `git` and `git-man` from a release, then install both:

```sh
gh release download <tag> --repo k0pernikus/git-debian-latest --pattern 'git_*_amd64.deb' --pattern 'git-man_*_all.deb'
sudo apt install ./git_*_amd64.deb ./git-man_*_all.deb
```

`git` requires `git-man` at exactly its own version, and trixie's other dependencies come from trixie itself.
GitHub replaces the `~` of the version with `.` in every asset name, so the rebuild of `1:2.55.0-1` is published
as `git_2.55.0-1.trixie1_amd64.deb`.

## Container image

`ghcr.io/k0pernikus/git-debian-latest:<tag>` is `debian:trixie-slim` with the release's `git` and `git-man`
installed, and `:latest` points at the release whose tag sorts newest. The release's `container-image.txt` names the image by
digest.

## In your own Dockerfile

The [`Dockerfile`](Dockerfile) is the reference for installing these packages in another image:

- An intermediate `scratch` stage fetches the two packages with `ADD --checksum`, so an unchanged package is a
  cache hit and a changed one is verified against its digest. The version is part of each file name, so a new
  release is always fetched, never served from cache.
- The installing stage bind-mounts that stage, so the `.deb` files never enter an image layer.
- [`scripts/assert-git-version`](scripts/assert-git-version) fails the build when any installed package built
  from the `git` source carries another version. `git-doc` is the case it exists for: it does not depend on
  `git`, so trixie's `git-doc` installs beside a newer `git` without error.

The Dockerfile takes the tag, the file names and their digests as build arguments, because it builds every
release. Each asset's `sha256` digest is listed by
`gh release view <tag> --repo k0pernikus/git-debian-latest --json assets`. An image pinning one release writes
those values into its `ADD` lines directly.

## License

GPL-2.0-only, the license of git itself. Every release carries the full source package it was built from.
