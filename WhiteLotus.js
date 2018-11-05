var express = require('express');
var app = express();
var fs = require('fs');
var install = require('./install');

if (!fs.existsSync('./config.json')) {
	console.log('Beginning White Lotus installation...')
	install.startInstall();
}

app.get('/', function (req, res) {
  res.send('Hello World!');
});
app.listen(3000, function () {
  console.log('Example app listening on port 3000!');
});
