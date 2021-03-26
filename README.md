# Fossil

A simple GTK Gopher/Gemini client written in Vala

### Supported download protocols
- Gopher
- Gemini
- Finger

### Supported upload protocols
- [gopher+write](https://alexschroeder.ch/wiki/2017-12-30_Gopher_Wiki)
- [gemini+write](https://alexschroeder.ch/wiki/2020-06-04_Gemini_Upload)
- [gemini+upload](https://alexschroeder.ch/wiki/Baschdels_spin_on_Gemini_uploading)

### Noteworthy features
- Tabs
- Bookmarks
- In-application image display
- View page source option
- Support for `file://` URIs
- Per tab history
- Ability to save everything to disk
- Cache
- Works on Linux-based smartphones
- Tries to be as themeable as possible using GTK themes and icon packs
- Favicons

## How to build/install?
Note: to build Fossil you need the following dependencies:
- gtk3+ - the graphics toolkit
- valac - the Vala compiler
- meson - the build system
- cmake - used by meson
- gdk-pixbuf-2.0 - to resize favicons
- python 3.x
- json-glib
- gnutls

To build it, run the `build.sh` script, which will automatically setup
the build folder, run ninja, and put the output in the projects root
directory. The produced binary should be executable, now.

![](https://cdn.discordapp.com/attachments/766326715244740618/824233938049695774/unknown.png)
