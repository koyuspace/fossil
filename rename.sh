#!/bin/bash
find -name "*.vala" | lua tools/bulksed.lua "s/$1/$2/g"
