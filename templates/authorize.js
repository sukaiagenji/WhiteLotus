var fs = require('fs');

exports.load = function(jsonObj, settings) {
	var htmlObj = fs.readFileSync(settings.WhiteLotusDir.toString() + '/templates/header1.html', 'utf8');
	htmlObj += fs.readFileSync(settings.WhiteLotusDir.toString() + '/templates/css/authorize.css', 'utf8');
	htmlObj += fs.readFileSync(settings.WhiteLotusDir.toString() + '/templates/header2.html', 'utf8');

	htmlObj += '<center><div class="title">Your device is not authorized!!!</div>';
	htmlObj += '<p><div class="textbox">To authorize your device, please visit <a href=https://amazon.com/us/code><br>https://amazon.com/us/code</a><br>and enter the following code:';
	htmlObj += '<p><div class="authcode">' + jsonObj.code + '</div>';
	
	htmlObj += fs.readFileSync(settings.WhiteLotusDir.toString() + '/templates/footer.html', 'utf8');

	return htmlObj;
}
