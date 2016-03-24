//server.js

var express = require('express');
var bodyParser = require('body-parser');

var app = express();
var port = process.env.PORT || 6969;
var router = express.Router();

app.use('/api', router);

router.get('/', function(req, res) {
	res.send("root request");
});

router.get('/a', function(req, res) {
	res.send("a request");
})

app.listen(port);