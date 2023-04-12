#/bin/bash

echo Deleting dist
rm -rf dist/
echo Deleting .love
rm breakout.love
echo Zipping
zip -9 breakout.love -r fonts/ graphics/ lib/ sounds/ src/ main.lua
echo Building
love.js breakout.love dist/ --title Breakout --memory 67108864
