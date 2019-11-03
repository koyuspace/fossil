#!/bin/bash
builddir=build

if [ ! -d "$builddir" ]
then
	meson "$builddir" --prefix=/usr
fi

cd "$builddir"
ninja
ninja install
