#!/bin/sh
#
# Update proguard-maven-modules from new proguard release.
#
# Do run from proguard-maven-modules directory.
#
# (c) 2011 by W. van Engen <dev-java@willem.engen.nl>
#

mvndir=`pwd`
if [ ! -f "$1" ]; then
	echo "Usage: $0 <proguardX.Y.tar.gz>" 1>&2
	exit 1
fi
newversion=`echo "$1" | sed 's|^.*proguard\([0-9.]\+[-_+a-zA-Z0-9.]*\)\.tar\.gz$|\1|p;d'`
if [ ! "$newversion" ]; then
	echo "Unrecognised proguard filename: $1" 1>&2
	exit 2
fi

# copy files from source directory to maven project
movetomvn() {
	srcbase="$1"
	srcdir="$2"
	dstbase="$3"
	dstproj="$4"

	# copy files to either java or resources in maven project
	for f in `cd "$srcbase" && find "$srcdir" -type f`; do
		# skip manifest, which maven project does
		[ `basename "$f"` = "MANIFEST.MF" ] && continue
		# copy
		dir=`dirname "$f"`
		if echo "$f" | grep -q '\(\.java\|package\.html\)$'; then
			dstdir="$dstproj/src/main/java/$dir"
		else
			dstdir="$dstproj/src/main/resources/$dir"
		fi
		mkdir -p "$dstbase/$dstdir"
		mv "$srcbase/$f" "$dstbase/$dstdir/"
	done
}

# unpack new proguard release
pgdir=`mktemp -t -d mgmupdate.XXXXXXXXXX`
tar -x -z -C "$pgdir" -f "$1"
mv "$pgdir/proguard$newversion/"* "$pgdir"
if [ $? -ne 0 ]; then
	rm -Rf "$pgdir"
	echo "Expected single directory in tarfile: proguard$newversion" 1>&2
	exit 3
fi
rmdir "$pgdir/proguard$newversion"

# remove old sources
for d in proguard-anttask proguard-base proguard-gui proguard-retrace proguard-wtk-plugin; do
	rm -Rf "$mvndir/$d/src/main/java/proguard" "$mvndir/$d/src/main/resources/proguard"
done

# spread proguard's files over maven projects
movetomvn "$pgdir/src" proguard/ant "$mvndir" proguard-anttask
movetomvn "$pgdir/src" proguard/gui "$mvndir" proguard-gui
movetomvn "$pgdir/src" proguard/retrace "$mvndir" proguard-retrace
movetomvn "$pgdir/src" proguard/wtk "$mvndir" proguard-wtk-plugin
# all remaining files in base package
movetomvn "$pgdir/src" proguard "$mvndir" proguard-base

# cleanup
rm -Rf "$pgdir"

# update version in pom files
sed -i 's|\(ProGuard\s\+\)[0-9.]\+|\1'"$newversion"'|i' "$mvndir/README.md"
for d in "" proguard-anttask proguard-base proguard-gui proguard-retrace proguard-wtk-plugin; do
	# only do one substitution (first one is pom's version)
	sed -i 's|\(<version>\)[0-9.]\+\(</version>\)|\1'"$newversion"'\2|;ta;b;:a;n;ba' "$mvndir/$d/pom.xml"
done

echo "Done! Don't forget to create a new tag."

