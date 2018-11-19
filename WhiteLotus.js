///////////////////////////////////////////////////
//
//					White Lotus
//			A front end for the Alexa AVS
//
//			 See README for installation
//			  See License for licensing
///////////////////////////////////////////////////

//Setting up node modules
var express = require('express');
var app = express();
const { spawn } = require('child_process');

//Adding empty variables
//empty JSON object
var jsonObj = {};
//empty regular string
var htmlObj = "";

//We need the settings.json to load. If it doesn't, we're missing a major directory variable.
try {
	settings = require("./settings.json");
} catch(e) {
	//No settings file found. Terminating.
	console.log("Settings failed to load. " + e);
	//This terminates the program because it's not inside a function.
}

//Load the loader. Necessary for later, since we use an exported function.
var template = require(settings.WhiteLotusDir.toString() + '/templates/loader.js');

console.log('Starting Alexa AVS in the background...')
//Obvious from the log right here. Load AVS in a shell.
const avsSpawn = spawn('sudo bash ' + settings.AlexaAVSDir.toString() + '/startsample.sh', {
	//If shell isn't true here, AVS will run in the foreground. We need to avoid that.
	shell: true
});

//Start reading any stdout that AVS writes.
avsSpawn.stdout.on('data', function (data) {
	//Because of how long the strings of data are, we can't use a simple 'switch' here,
	//so we use if statements, and only look for key words.
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
		//Here's where things get fun. We've found a JSON string from AVS.
		jsonResponse = data.toString('utf8'); //String conversion from buffer to utf-8. Human readable.
		if (jsonResponse.indexOf('{"type":') !== -1) {
			jsonResponse = jsonResponse.substr(jsonResponse.indexOf('{"type":')); //Remove everything before '("type":'.
			jsonResponse = jsonResponse.split(/\r?\n/); //and split it at newline into an array.
			try { //Check the JSON object for errors.
				jsonObj = JSON.parse(jsonResponse[0]); //The JSON object is always at array[0], because there's nothing before it.
			} catch (error) {
				console.log('JSON Parse error: ' + error);
				//This doesn't terminate the program because it only terminates the function it's inside.
				//Call the function again, and it tries again.
			}
			
			//Call the function returnHTML from template (AKA loader.js) using the JSON object and settings.
			htmlObj = template.returnHtml(jsonObj, settings);
			const refresh = spawn('sudo bash ' + settings.WhiteLotusDir.toString() + '/refresh.sh', {
				//Spawn another program in the background to refresh Chromium.
				shell: true
			});
		}
	}
	if (data.indexOf('RenderTemplateCard - Cleared') !== -1) {
		//Clear the JSON object, since we no longer have a card to render.
		jsonObj = {};
		//Call the function returnHTML from template (AKA loader.js) using the JSON object and settings.
		htmlObj = template.returnHtml(jsonObj, settings);
		const refresh = spawn('sudo bash ' + settings.WhiteLotusDir.toString() + '/refresh.sh', {
			//Spawn another program in the background to refresh Chromium.
			shell: true
		});
		console.log("Card Cleared!!!");
	}
	if (data.indexOf('To authorize, browse to:') !==-1) {
		//Our AVS isn't authorized, so we need the authorization code.
		console.log('Finding auth code...');
		//Found it!!!
		var authCodeIndex = data.indexOf('code: ') + 6;
		//Convert the code to a utf-8 string.
		var authCode = data.toString('utf8').substring(authCodeIndex, authCodeIndex + 6);
		//Let's fill the JSON object with minimal information, since we're only using this once.
		jsonObj = { "type": "authorize", "code": authCode };
		//Call the function returnHTML from template (AKA loader.js) using the JSON object and settings.
		htmlObj = template.returnHtml(jsonObj, settings);
		const refresh = spawn('sudo bash ' + settings.WhiteLotusDir.toString() + '/refresh.sh', {
			//Spawn another program in the background to refresh Chromium.
			shell: true
		});
	}
	if (data.indexOf('Authorized!') !== -1) {
		//Clear the JSON object, since we're going to the Card Cleared screen.
		jsonObj = {};
		//Call the function returnHTML from template (AKA loader.js) using the JSON object and settings.
		htmlObj = template.returnHtml(jsonObj, settings);
		const refresh = spawn('sudo bash ' + settings.WhiteLotusDir.toString() + '/refresh.sh', {
			//Spawn another program in the background to refresh Chromium.
			shell: true
		});
		console.log("Card Cleared!!!");
	}
});

//Alexa exited for some reason!!!
avsSpawn.on('exit', console.log.bind(console, 'Alexa exited!!!'));

console.log('Loading Standard Screen...');
//We need to load the standard Card Cleared screen, since there's nothing going on.
htmlObj = template.returnHtml(jsonObj, settings);
console.log('Done!!!');

console.log('Starting Control Port...');
//Let's set up the main control port.
app.get('/alexa-ctrlprt',function(req,res) {
	//Setting the type going out as plain HTML, since we're not doing anything but HTML.
	res.set('Content-Type', 'text/html');
	//sending the HTML object being returned from our template (AKA loader.js)
	res.send(new Buffer(htmlObj));
});
console.log('Done!!!');

//Because of how the backgrounds and HTML work together, we have to set a new http directory for them,
//otherwise they won't display or work at all.
app.use('/backgrounds/', express.static(__dirname + '/templates/backgrounds'));

//Start the program listening to port 8080 for all incoming calls.
app.listen(8080);
console.log('Now listening on port 8080!!!');
