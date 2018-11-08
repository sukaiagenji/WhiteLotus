try {
	var express = require('express');
	var app = express();
	var fs = require('fs');
	var install = require('./install');
}
catch(error) {
	console.log(error);
}

if (!fs.existsSync('./config.json')) {
	console.log('Beginning White Lotus installation...');
	install.startInstallation();
}

if (fs.existsSync('./config.json')) {
	app.get('/', function (req, res) {
		res.send('Hello World!');
	});
	app.listen(3000, function () {
		console.log('Example app listening on port 3000!');
	});
}

/* Ignore this file. Because of issues with the installation script, I will be moving everything to pure shell script. */