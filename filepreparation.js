const fs = require('fs');
const sep = require('path').sep;

const resoucesExts = ['png','ttf', 'wav'];
const basedir = '.' + sep;
const ext = '.lua';
const inputFile =  basedir + 'main.lua';
const outputFile = basedir + 'pathsToShip';
const gPaths = [];

function onModuleFound(path) {
    gPaths.push(path);
    const text = fs.readFileSync(path, { encoding: 'utf8' });

    matchResource(text);
    searchModules(text);
}

function searchModules(text) {
    const results = matchModule(text);

    if (results) {
        for (const match of results) {
            const path = basedir + match[1] + ext;

            onModuleFound(path);
        }
    }
}

function matchModule(text) {
    const re = /require\s\(?['"](.+)['"]\)?/gm;

    return text.matchAll(re);
}

function matchResource(text) {
    const genRE = ext => `['"]([^'"]+\.${ext})['"]`

    resoucesExts.forEach(ext => {
        const re = new RegExp(genRE(ext), 'gm');

        const results = text.matchAll(re);

        if (results) {
            for (const match of results) {
                gPaths.push(basedir + match[1]);
            }
        }
    })
}

function filterReps(items) {
    return Array.from(new Set(items));
}

function printPaths(paths) {
    const content = paths.join('\n');
    fs.writeFileSync(outputFile, content);
}

function main(path) {
    onModuleFound(path);
    printPaths(filterReps(gPaths));
}

main(inputFile);
