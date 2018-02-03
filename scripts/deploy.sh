#!/bin/bash
set -e

rm -rf dest || exit 0;

mkdir -p dest/assets

# compile JS using Elm
elm make src/Main.elm --yes --output dest/elm-temp.js
uglifyjs dest/elm-temp.js -c warnings=false -m --screw-ie8 -o dest/elm.js
rm dest/elm-temp.js

# copy the images and html
cp -R index.html img dest

# publish to itch.io
butler push dest unsoundscapes/404-elm-street:html
