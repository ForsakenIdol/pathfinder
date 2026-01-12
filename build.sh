#!/bin/sh

set -e -u

export DEBFULLNAME="ForsakenIdol"
export DEBEMAIL="forsaken.idol929@gmail.com"
TOOL_NAME="pathfinder"
VERSION=0.1.0

DIR_NAME="$TOOL_NAME-$VERSION"
TAR_NAME="$TOOL_NAME"_$VERSION.orig.tar.gz

# Tarball
mkdir -p "$DIR_NAME/debian"
cp ./pathfinder ./tests/test_pathfinder.sh ./"$DIR_NAME"
cp LICENSE ./"$DIR_NAME"/debian
tar -cz -f $TAR_NAME $DIR_NAME

# Make package outline
cd "$DIR_NAME"
dh_make -i -a -c custom --copyrightfile LICENSE -y
rm -rf debian/*.ex # Remove example files

# Add other files as required
cat << "EOF" > debian/install
pathfinder /usr/bin
test_pathfinder.sh /usr/share/doc/pathfinder/tests/
EOF
cat << "EOF" > debian/control
Source: pathfinder
Section: unknown
Priority: optional
Maintainer: ForsakenIdol <forsaken.idol929@gmail.com>
Rules-Requires-Root: no
Build-Depends:
 debhelper-compat (= 13),
Standards-Version: 4.7.2
Homepage: https://github.com/ForsakenIdol/pathfinder

Package: pathfinder
Architecture: all
Depends:
 ${misc:Depends},
Description: PATH environment consolidation and enumeration
 A Linux consolidation and enumeration tool for the PATH environment variable.
 Includes tests installed into /usr/share/doc/pathfinder.
EOF
# We'll set up a proper pipeline with gbp-dch later, this is just a placeholder
cat << "EOF" > debian/changelog
pathfinder (0.1.0-1) UNRELEASED; urgency=medium

  * Initial release.

 -- ForsakenIdol <forsaken.idol929@gmail.com>  Mon, 12 Jan 2026 17:36:50 +0800
EOF

# Build unsigned, ignores change file
debuild -us -uc

# Move build artifacts other than `.deb` into their own directory
cd ..
mkdir -p artifacts
mv pathfinder_* artifacts/
mv artifacts/*.deb .

# Cleanup temp artifacts
rm -rf "$TAR_NAME"
rm -rf "$DIR_NAME"
