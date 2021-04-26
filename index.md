# Fossil

A simple GTK Gopher/Gemini client written in Vala

<a class="btn btn-success btn-lg" href="https://github.com/koyuspace/fossil/releases/download/v1.0/com.github.koyuspace.fossil" style="margin: 10px 0;"><svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-download" viewBox="0 0 16 16"><path d="M.5 9.9a.5.5 0 0 1 .5.5v2.5a1 1 0 0 0 1 1h12a1 1 0 0 0 1-1v-2.5a.5.5 0 0 1 1 0v2.5a2 2 0 0 1-2 2H2a2 2 0 0 1-2-2v-2.5a.5.5 0 0 1 .5-.5z"></path><path d="M7.646 11.854a.5.5 0 0 0 .708 0l3-3a.5.5 0 0 0-.708-.708L8.5 10.293V1.5a.5.5 0 0 0-1 0v8.793L5.354 8.146a.5.5 0 1 0-.708.708l3 3z"></path></svg> Download</a>

<img src="https://cdn.discordapp.com/attachments/766326715244740618/824233938049695774/unknown.png" style="padding:10px;float:right;height: 600px;">

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
- gettext

One-liner for Debian-based systems:

```
sudo apt install libgtk-3-dev valac meson cmake libgdk-pixbuf2.0-dev python3 libjson-glib-dev libgnutls28-dev gettext
```

To build it, run the `build.sh` script, which will automatically setup
the build folder, run ninja, and put the output in the projects root
directory. The produced binary should be executable, now.
