# dragonstone

A simple GTK Gopher/Gemini client written in Vala, that will eventually support other protocols

### Noteworthy feataures
- support for the gopher protocol
- support for the [gemini](gopher://zaibatsu.circumlunar.space/1/~solderpunk/gemini) protocol 
- tabs (surprisingly uncommon feature)
- in application image display (not inline, very simple)
- view page source option
- support for `file://` URIs
- per tab history
- save to disk everything
- cache
- unfinished features and bugs (I try to keep them to a minimum)

### Wishlist
- settings
- plugins for supporting more protocols
- save bookmarks
- a non-codename for the project

##How to build/install?
Note: to build dragonstone you need the following dependencies:
- gtk3+ - the graphics toolkit
- valac - the Vala compiler
- meson - the build system
- cmake - used by meson
- python 3.x

To build it, run the `build.sh` script, which will automatically setup
the build folder, run ninja, and put the output in the projects root
directory. The produced binary should be executable, now.

To make development easy, the `run` script calls the `build.sh` script
and then runs whatever is at the output.

NOTE: if a build fails, but an earlier one succeeded, it will run the
binary produced by the earlier build.

## TODO:
- Implement bookmarks
- Implement proper Gemini support (at the TLS layer)
- Implement proper handling of http and mailto links
