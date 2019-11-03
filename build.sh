#!/bin/bash
builddir=build
output="src/com.gitlab.baschdel.dragonstone"
dest="gtkGopher"

if [ ! -d "$builddir" ]
then
	meson "$builddir" --prefix=/usr
fi

cd "$builddir"
ninja
cp -f "$output" "../$dest"
