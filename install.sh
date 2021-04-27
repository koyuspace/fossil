#!/bin/bash
builddir=meson_build

if [ ! -d "$builddir" ]
then
	meson "$builddir" --prefix=/usr
fi

cd "$builddir"
ninja
sudo ninja install
xdg-mime default com.github.koyuspace.fossil.desktop x-scheme-handler/gemini
xdg-mime default com.github.koyuspace.fossil.desktop x-scheme-handler/gopher
