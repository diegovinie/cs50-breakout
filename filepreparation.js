const fs = require('fs');
const sep = require('path').sep;

const resoucesExts = ['png','ttf', 'wav'];
const basedir = '.' + sep;
const depsdir = basedir;
const ext = '.lua';
const inputFile =  basedir + 'main.lua';
const outputFile = basedir + 'pathsToShip';
const gPaths = [];

let gLuaPaths = [];

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
            const module = match[1];
            const path = basedir + module + ext;

            if (fs.existsSync(path)) {
                onModuleFound(path);
            } else {
                const externalPath = searchDeepModules(module);

                if (externalPath) {
                    const depsModulePath = depsdir + parseModuleToPath(module) + ext;

                    prepareDirectories(depsModulePath);

                    fs.copyFileSync(externalPath, depsModulePath);

                    onModuleFound(depsModulePath);
                }
                else
                    throw new Error(`Module ${module} not found.`);
            }
        }
    }
}

function searchDeepModules(module) {
    const filePath = parseModuleToPath(module);

    for (const path of gLuaPaths) {
        const fullPath = path + filePath + ext;

        if (fs.existsSync(fullPath)) {
            return fullPath;
        }
    }
}

function loadLuaPaths() {
    const vars = ['LUA_PATH'];

    for (const v of vars) {
        const str = process.env[v];

        if (str) gLuaPaths.push(...parseLuaPaths(str));
    }
}

function parseLuaPaths(str) {
    return str.replaceAll("'", '').split(';').map(line => {
        const matches = line.match(/^(.+)\?/);

        return matches[1];
    })
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

function parsePathToModule(path) {
    return path.replaceAll('/', '.');
}

function parseModuleToPath(module) {
    return module.replaceAll('.', '/');
}

function prepareDirectories(path) {
    let str = '.' + sep;

    for (const dir of path.split(sep).slice(0, -1)) {
        if (!fs.existsSync(str + dir))
            fs.mkdirSync(str + dir)

        str += dir + sep;
    }
}

function filterReps(items) {
    return Array.from(new Set(items));
}

function savePathsToFile(paths) {
    const content = paths.join('\n');
    fs.writeFileSync(outputFile, content);
}


/////////////////////////////////////////////////////////////

function main(path) {
    loadLuaPaths();

    // if (fs.existsSync(depsdir))
    //     fs.rmSync(depsdir, { recursive: true });

    onModuleFound(path);
    savePathsToFile(filterReps(gPaths));
}

main(inputFile);
