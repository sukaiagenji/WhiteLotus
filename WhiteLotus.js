//var http = require('http');
//var fs = require('fs');
//var express = require('express');
//var app = express();
//var template = require('./scripts/template.js');
const { spawn } = require('child_process');

var jsonObj = {};
// load standard card into variable

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
			// load the proper template into variable
			// send Chromium refresh
		}
	} else if (data.indexOf('RenderTemplateCard - Cleared') {
		jsonObj = {};
		// load standard card into variable
		// send Chromium refresh
	}
});

//app.post('/',function(req,res) {
	// serve template through variable
//})

//app.listen(2287);
