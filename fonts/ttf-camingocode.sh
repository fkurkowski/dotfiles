#!/bin/sh

git clone git@github.com:aur-archive/ttf-camingocode.git
(cd ttf-camingocode && makepkg -i)
rm -rf ttf-camingocode
