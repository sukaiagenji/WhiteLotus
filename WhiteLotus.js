var express = require('express');
var app = express();
const { spawn } = require('child_process');

var jsonObj = {};
var htmlObj = "";

try {
	settings = require("./settings.json");
} catch(e) {
	//No settings file found. Terminating.
	console.log("Settings failed to load. " + e);
}

var template = require(settings.WhiteLotusDir.toString() + '/templates/loader.js');

console.log('Starting Alexa AVS in the background...')
const avsSpawn = spawn('sudo bash ' + settings.AlexaAVSDir.toString() + '/startsample.sh', {
	shell: true
});

avsSpawn.stdout.on('data', function (data) {
	if (data.indexOf('Connecting') !== -1) {
		console.log('Connecting...');
	}
	if (data.indexOf('Authorized') !== -1) {
		console.log('Connected and Authorized!');
	}
	if (data.indexOf('Alexa is currently idle') !== -1) {
		console.log('Listening for wake word...');
	}
	if (data.indexOf('Listening') !== -1) {
		console.log('Listening...');
	}
	if (data.indexOf('Thinking') !== -1) {
		console.log('Thinking...');
	}
	if (data.indexOf('Speaking') !== -1) {
		console.log('Speaking...');
	}
	if (data.indexOf('Expecting') !== -1) {
		console.log('Expecting...');
	}
	if (data.indexOf('{"type":') !== -1) {
		jsonResponse = data.toString('utf8');
		if (jsonResponse.indexOf('{"type":') !== -1) {
			jsonResponse = jsonResponse.substr(jsonResponse.indexOf('{"type":'));
			jsonResponse = jsonResponse.split(/\r?\n/);
			try {
				jsonObj = JSON.parse(jsonResponse[0]);
			} catch (error) {
				console.log('JSON Parse error: ' + error);
			}
			
			htmlObj = template.returnHtml(jsonObj, settings);
			const refresh = spawn('sudo bash ' + settings.WhiteLotusDir.toString() + '/refresh.sh', {
				shell: true
			});
		}
	}
	if (data.indexOf('RenderTemplateCard - Cleared') !== -1) {
		jsonObj = {};
		htmlObj = template.returnHtml(jsonObj, settings);
		const refresh = spawn('sudo bash ' + settings.WhiteLotusDir.toString() + '/refresh.sh', {
			shell: true
		});
		console.log("Card Cleared!!!");
	}
	if (data.indexOf('To authorize, browse to:') !==-1) {
		console.log('Finding auth code...');
		var authCodeIndex = data.indexOf('code: ') + 6;
		var authCode = data.toString('utf8').substring(authCodeIndex, authCodeIndex + 6);
		jsonObj = { "type": "authorize", "code": authCode };
		htmlObj = template.returnHtml(jsonObj, settings);
		const refresh = spawn('sudo bash ' + settings.WhiteLotusDir.toString() + '/refresh.sh', {
			shell: true
		});
	}
	if (data.indexOf('Authorized!') !== -1) {
		jsonObj = {};
		htmlObj = template.returnHtml(jsonObj, settings);
		const refresh = spawn('sudo bash ' + settings.WhiteLotusDir.toString() + '/refresh.sh', {
			shell: true
		});
		console.log("Card Cleared!!!");
	}
});

avsSpawn.on('exit', console.log.bind(console, 'Alexa exited!!!'));

console.log('Loading Standard Screen...');
htmlObj = template.returnHtml(jsonObj, settings);
console.log('Done!!!');

console.log('Starting Control Port...');
app.get('/alexa-ctrlprt',function(req,res) {
	res.set('Content-Type', 'text/html');
	res.send(new Buffer(htmlObj));
});
console.log('Done!!!');

app.use('/backgrounds/', express.static(__dirname + '/templates/backgrounds'));

app.listen(8080);
console.log('Now listening on port 8080!!!');
