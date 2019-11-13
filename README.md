# dragonstone

A simple gtk gopher/gemini client, that will eventually support other protocols

## What this currenty is
Short answer: not finished!
Long answer:
A simple gtk based gopher and gemini client written in vala,
that will eventually support other protocols
Note: This is not only my first gtk but also my first vala project

### What can it do?
- fetch files from gopher servers (mostly successful)
- fetch files from gemini servers
- display content in multiple tabs
- display gopher directorys
- display gemini maps/directorys
- display text files
- display unscaled images
- some basic error handling
- remember a temporary per tab history (no I will not make it persistant)
- save files to disk

### What can it NOT do?
- display a menu when right clicking on a link
- save bookmarks

##How to build/install?
Note: to build dragonstone you need the following dependedencys:
- valac - the vala compiler
- meson - the buildsystem
- python 3.x

This program uses gsettings and beacause of that requires a gschema to be installed which can be found in the data folder.
if you trust me simply run the install.sh script with sudo
if not you have to install them manually

Plese contact me if you know how to install them local to the home diectory if that's possible.

to build it either run the build.sh script, which will automatically setup the build folder run ninja and put the output in the projects root directory

to make development easy, the run script calls the build.sh script and then runs whatever is at the output

## TODO:
- Implement dynamic tabs (basically what you know from your web browser)
- Implement bookmarks
- Find another way of making the font in the labels monospaced
- Implement poroper gemini support (at the Tls layer)
- Implement proper handling of http and mailto links
