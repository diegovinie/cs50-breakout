var express = require('express');
var app = express();

const PORT = process.env.PORT || 5000

var options = {
    setHeaders: (res, path, stat) => {
        res.set('Cross-Origin-Embedder-Policy', 'require-corp')
        res.set('Cross-Origin-Opener-Policy', 'same-origin')
    }
};

//setting middleware
app.use(express.static('./dist', options));


var server = app.listen(PORT);

