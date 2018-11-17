var fs = require('fs');

exports.load = function(settings) {
	var htmlObj = fs.readFileSync(settings.WhiteLotusDir.toString() + '/templates/header1.html', 'utf8');
	htmlObj += fs.readFileSync(settings.WhiteLotusDir.toString() + '/templates/css/emptytemplate.css', 'utf8');
	htmlObj += fs.readFileSync(settings.WhiteLotusDir.toString() + '/templates/header2.html', 'utf8');
	
	htmlObj += "<div id='time' class='time'></div>";
	htmlObj += fs.readFileSync(settings.WhiteLotusDir.toString() + '/templates/currentTime.js', 'utf8');

	htmlObj += fs.readFileSync(settings.WhiteLotusDir.toString() + '/templates/footer.html', 'utf8');

	return htmlObj;
}
