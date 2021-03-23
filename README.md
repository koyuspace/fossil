# Fossil

A simple GTK Gopher/Gemini client written in Vala

### Supported download protocols
- gopher
- (gemini)[gopher://zaibatsu.circumlunar.space/1/~solderpunk/gemini]
- finger

### Supported upload protocols
- [gopher+write](https://alexschroeder.ch/wiki/2017-12-30_Gopher_Wiki) (used by the [oddmuse](https://oddmuse.org/) wiki engine)
- [gemini+write](https://alexschroeder.ch/wiki/2020-06-04_Gemini_Upload) (used by the [oddmuse](https://oddmuse.org/) wiki engine)
- [gemini+upload](https://alexschroeder.ch/wiki/Baschdels_spin_on_Gemini_uploading) (a protocol I made myself for uplaoding to gemini (no known server implementations))

### Noteworthy features
- tabs (surprisingly uncommon feature)
- bookmarks
- in application image display (not inline, very simple)
- view page source option
- support for `file://` URIs
- per tab history
- save to disk everything
- cache
- runs smoothly on an old Thikpad X31 with a slow HDD, a pentium M @ 1.4GHz and 256MB RAM
- works on linux based smartphones
- trys to be as themeable as possible using GTK themes and icon packs (no guarantees except for obsidian2 and Numix because that's what I use on my development machines)
- unfinished features and bugs (I try to keep them to a minimum)

### Wishlist
- more settings
- plugins for supporting more protocols

## How to build/install?
Note: to build Fossil you need the following dependencies:
- gtk3+ - the graphics toolkit
- valac - the Vala compiler
- meson - the build system
- cmake - used by meson
- python 3.x

To build it, run the `build.sh` script, which will automatically setup
the build folder, run ninja, and put the output in the projects root
directory. The produced binary should be executable, now.

To make development easy, the `run` script calls the `build.sh` script
and then runs whatever is at the output (it will try and fail if there is none).
