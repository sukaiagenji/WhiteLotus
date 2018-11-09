var express = require('express');
var app = express();
var template = require('./templates/loader.js');
const { spawn } = require('child_process');

var jsonObj = {};
var htmlObj = template(jsonObj);

const avsSpawn = spawn('sudo bash startsample.sh', {
	shell: true
});

avsSpawn.stdout.on('data', function (data) {
	if (data.indexOf('{"type":') !== -1) {
		jsonResponse = data.toString('utf8');
		if (jsonResponse.indexOf('\{\"type\"\:') !== -1) {
			jsonResponse = jsonResponse.substr(jsonResponse.indexOf('\{\"type\"\:'));
			jsonResponse = jsonResponse.split(/\r?\n/);
			jsonObj = JSON.parse(jsonResponse[0]);
			htmlObj = template(jsonObj);
			// send Chromium refresh
		}
	} else if (data.indexOf('RenderTemplateCard - Cleared') {
		jsonObj = {};
		htmlObj = template(jsonObj);
		// send Chromium refresh
	}
});

app.get('/',function(req,res) {
	res.set('Content-Type', 'text/html');
	res.send(new Buffer(htmlObj));
});

app.listen(2287);
