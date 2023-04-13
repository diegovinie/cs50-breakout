#/bin/bash

echo Deleting dist
rm -rf dist/
echo Deleting .love
rm breakout.love
echo Preparing files
node filepreparation.js
echo Zipping
zip -9 breakout.love -r $(cat pathsToShip)
echo Building
love.js breakout.love dist/ --title Breakout --memory 67108864
echo "done"
