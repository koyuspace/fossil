#!/bin/bash
builddir=meson_build

if [ ! -d "$builddir" ]
then
	meson "$builddir" --prefix=/usr
fi

cd "$builddir"
ninja
ninja install
