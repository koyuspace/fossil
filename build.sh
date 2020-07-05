#!/bin/bash
builddir=meson_build
output="src/com.gitlab.baschdel.dragonstone"
dest="dragonstone"

if [ ! -d "$builddir" ]
then
	meson "$builddir" --prefix=/usr
fi

cd "$builddir"
rm -f "$output"
ninja
cp -f "$output" "../$dest"
