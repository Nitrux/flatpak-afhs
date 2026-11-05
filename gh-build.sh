#!/usr/bin/env bash

# SPDX-License-Identifier: BSD-3-Clause
# Copyright 2026 <Nitrux Latinoamericana S.C. <hello@nxos.org>>

set -e

upstream_url="https://github.com/flatpak/flatpak.git"
debian_url="https://salsa.debian.org/debian/flatpak.git"
debian_ref="${DEBIAN_REF:-debian/unstable}"
version="${1:-1.18.4}"
patch_name="0001-aesthetic-fhs-root-enumeration.patch"

if [[ "$version" == "latest" ]]; then
    release_url="$(curl --fail --location --silent --show-error \
        --output /dev/null --write-out '%{url_effective}' \
        "https://github.com/flatpak/flatpak/releases/latest")"
    version="${release_url##*/}"
fi

if [[ ! "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "Invalid Flatpak version: $version" >&2
    exit 1
fi

echo "Building Flatpak $version with the Aesthetic FHS patch"

repo_dir="$(pwd)"
build_dir="$(mktemp -d)"
trap 'rm -rf "$build_dir"' EXIT

git clone --branch "$version" --depth=1 "$upstream_url" "$build_dir/src"
git clone --branch "$debian_ref" --depth=1 "$debian_url" "$build_dir/debian-packaging"

cp -a "$build_dir/debian-packaging/debian" "$build_dir/src/debian"
cp "$repo_dir/debian/patches/$patch_name" "$build_dir/src/debian/patches/$patch_name"

awk -v packages=" flatpak libflatpak0 gir1.2-flatpak-1.0 " '
    BEGIN { RS = ""; ORS = "\n\n" }
    {
        package = ""
        count = split($0, lines, "\n")
        for (i = 1; i <= count; i++) {
            if (lines[i] ~ /^Package: /) {
                split(lines[i], fields, /[[:space:]]+/)
                package = fields[2]
                break
            }
        }
        if (package == "" || index(packages, " " package " ")) print
    }
' "$build_dir/src/debian/control" > "$build_dir/src/debian/control.tmp"
mv "$build_dir/src/debian/control.tmp" "$build_dir/src/debian/control"

if ! grep -Fxq "$patch_name" "$build_dir/src/debian/patches/series"; then
    printf '%s\n' "$patch_name" >> "$build_dir/src/debian/patches/series"
fi

cd "$build_dir/src"

apt -qq update
apt -qq -yy install equivs git devscripts lintian --no-install-recommends

current_version="$(dpkg-parsechangelog --show-field Version)"
nitrux_version="${version}+nitrux1-1"
if [[ "$current_version" != "$nitrux_version" ]]; then
    dch --newversion "$nitrux_version" --distribution nitrux \
        --force-distribution --maintmaint \
        "Handle hidden root entries when building the D-Bus proxy."
fi

mk-build-deps -i -t "apt-get --yes" -r

export DEB_BUILD_OPTIONS="${DEB_BUILD_OPTIONS:+$DEB_BUILD_OPTIONS }nodoc noautodbgsym nocheck"

debuild -b -uc -us

for package in flatpak libflatpak0 gir1.2-flatpak-1.0; do
    cp "$build_dir"/"$package"_*.deb "$repo_dir"/
done
