# dragonstone

A simple gtk gopher/gemini/... client written in vala

For the official release of a first stable version the project will drop its current codename in the favour of the permanent name "NightCat".

Screenshots may be out of date (use the git timestamps and a bit of common sense)

### Supported download protocols
- gopher
- (gemini)[gopher://zaibatsu.circumlunar.space/1/~solderpunk/gemini]
- finger

### Supported upload protocols
- (gopher+write)[https://alexschroeder.ch/wiki/2017-12-30_Gopher_Wiki] (used by the oddmuse wiki engine)
- (gemini+write)[https://alexschroeder.ch/wiki/2020-06-04_Gemini_Upload] (used by the oddmuse wiki engine)
- (gemini+upload)[https://alexschroeder.ch/wiki/Baschdels_spin_on_Gemini_uploading] (a protocol I made myself for uplaoding to gemini (no known server implementations))

### Noteworthy feataures
- tabs (surprisingly uncommon feataure)
- bookmarks
- in application image display (not inline, very simple)
- view page source option
- support for file:// uris
- per tab history
- save to disk everything
- cache
- runs smoothly on an old Thikpad X31 with a slow HDD a pentium M @ 1.4GHz and 256MB RAM
- works on linux based smartphones
- trys to be as themeable as possible using GTK themes and icon packs (no guarantees except for obsidian2 and Numix because that's what I use on my development machines)
- unfinished feataures and bugs (I try to keep them to a minimum)

### Wishlist
- more settings
- plugins for supporting more protocls
- a non codename for the project

##How to build/install?
Note: to build dragonstone you need the following dependedencys:
- gtk3+ - the graphics toolkit
- gnutls - Used for generating TLS certificates
- valac - the vala compiler
- meson - the buildsystem
- cmake - used by meson
- python 3.x - used by meson

to build it run the build.sh script, which will automatically setup the build folder run ninja and put the output in the projects root directory

the produced binary should run without any extra work

to make development easy, the run script calls the build.sh script and then runs whatever is at the output
(NOTE: if a build fails, but an earlyr one suceeded, it will run the binary produced by the earlyer build)

## TODO:
- Implement dynamic sessions
- Persistant view scroll position, user supplyed content etc.
- Implement a better error view, that trys to give explanations for the errors
- Improve the TLS sessions UI and functionality
- Improve image display performance
