#!/usr/bin/env python3

import os
import subprocess

### Compile gsettings scema

install_prefix = os.environ["MESON_INSTALL_PREFIX"]
schemadir = os.path.join(install_prefix,"share/glib-2.0/schemas")

if not os.environ.get("DESTDIR"):
	print("Compiling gsettings schemas ... (schemadir:"+schemadir+")")
	subprocess.call(["glib-compile-schemas",schemadir])
