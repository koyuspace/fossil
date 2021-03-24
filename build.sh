#!/bin/bash
builddir=meson_build
output="src/com.github.koyuspace.fossil"
dest="fossil"

if [ ! -d "$builddir" ]
then
	meson "$builddir" --prefix=/usr
fi

cd "$builddir"
rm -f "$output"
ninja
cp -f "$output" "../$dest"
