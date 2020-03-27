# dragonstone

A simple gtk gopher/gemini client written in vala, that will eventually support other protocols

### Noteworthy feataures
- support for the gopher protocol
- support for the (gemini)[gopher://zaibatsu.circumlunar.space/1/~solderpunk/gemini] protocol 
- tabs (surprisingly uncommon feataure)
- in application image display (not inline, very simple)
- view page source option
- support for file:// uris (DON'T visit big directorys)
- per tab history
- save to disk everything
- cache
- unfinished feataures and bugs (I try to keep them to a minimum)

### Wishlist
- display a menu when right clicking on a link
- save bookmarks

##How to build/install?
Note: to build dragonstone you need the following dependedencys:
- gtk3+ - the graphics toolkit
- valac - the vala compiler
- meson - the buildsystem
- python 3.x

to build it either run the build.sh script, which will automatically setup the build folder run ninja and put the output in the projects root directory

the produced binary should run without any extra work (have not tested this on a fresh system)

to make development easy, the run script calls the build.sh script and then runs whatever is at the output

## TODO:
- Implement bookmarks
- Implement poroper gemini support (at the Tls layer)
- Implement proper handling of http and mailto links
- Implement a directory view
- Fix a memory leak, that probably has something to do with 
