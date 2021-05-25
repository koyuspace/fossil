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

## How to build/install?

Note: to build Fossil you need the following dependencies:

- gtk3+ - the graphics toolkit
- valac - the Vala compiler
- meson - the build system
- cmake - used by meson
- python 3.x
- json-glib
- gnutls
- gettext

One-liner for Debian-based systems:

```
sudo apt install libgtk-3-dev valac meson cmake libgdk-pixbuf2.0-dev python3 libjson-glib-dev libgnutls28-dev gettext
```

To build and install Fossil, run the `install.sh` script, which will automatically setup the build folder, run ninja, put the output in the projects root directory, copy the files for Fossil to your system and registers the protocol handler. You should then find a new entry in your application launcher.

![](https://cdn.discordapp.com/attachments/766326715244740618/824233938049695774/unknown.png)
