#!/bin/bash
sudo wget -O /usr/bin/com.github.koyuspace.fossil https://github.com/koyuspace/fossil/releases/download/v1.2/com.github.koyuspace.fossil
sudo chmod +x /usr/bin/com.github.koyuspace.fossil
sudo wget -O /usr/share/applications/com.github.koyuspace.fossil.desktop https://raw.githubusercontent.com/koyuspace/fossil/main/com.github.koyuspace.fossil.desktop.in
xdg-mime default com.github.koyuspace.fossil.desktop x-scheme-handler/gemini
xdg-mime default com.github.koyuspace.fossil.desktop x-scheme-handler/gopher
