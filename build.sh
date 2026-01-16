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
cp ./pathfinder ./tests/test_pathfinder.sh LICENSE ./"$DIR_NAME"
tar -cz -f $TAR_NAME $DIR_NAME

# Make package outline
cd "$DIR_NAME"
dh_make -i -a -c custom --copyrightfile ../LICENSE -y
rm -rf debian/*.ex # Remove example files

# Add other files as required
cp ../deb/install debian/install
cp ../deb/links debian/links
cp ../deb/control debian/control

# We'll set up a proper pipeline with gbp-dch later, this is just a placeholder
cat << EOF > debian/changelog
pathfinder ($VERSION-1) unstable; urgency=medium

  * Initial release of the pathfinder CLI utility.

 -- ForsakenIdol <forsaken.idol929@gmail.com>  $(date -R)
EOF

# Build unsigned, ignores change file
debuild -us -uc

# Move build artifacts other than `.deb` into their own directory
cd ..
mkdir -p artifacts
mv pathfinder_* artifacts/
mv artifacts/*.deb ./

# Cleanup temp artifacts
rm -rf "$TAR_NAME"
rm -rf "$DIR_NAME"
