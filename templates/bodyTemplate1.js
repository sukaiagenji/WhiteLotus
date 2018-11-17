var fs = require('fs');

exports.load = function(jsonObj, settings) {
	var htmlObj = fs.readFileSync(settings.WhiteLotusDir.toString() + '/templates/header1.html', 'utf8');
	htmlObj += fs.readFileSync(settings.WhiteLotusDir.toString() + '/templates/css/bodytemplate1.css', 'utf8');
	htmlObj += fs.readFileSync(settings.WhiteLotusDir.toString() + '/templates/header2.html', 'utf8');
	
	htmlObj += "<table style='width:100%'><tr>";

	htmlObj += "<td style='text-align:left' width='50%'><div class='title'>" + jsonObj.title.mainTitle + "</div></td>";
	htmlObj += "<td style='text-align:right' width='50%' rowspan='2'>";
	if (jsonObj.skillIcon) {
		for (var i in jsonObj.skillIcon.sources) {
			if (jsonObj.currentWeatherIcon.sources[i].size == "SMALL") {
				htmlObj += "<img src=" + jsonObj.currentWeatherIcon.sources[i].url + "></td></tr>";
			}
		}
	}
	
	if (jsonObj.title.subTitle) {
		htmlObj += "<tr><td style='text-align:left' width='50%'><div class='subtitle'>" + jsonObj.title.subTitle + "</div>";
	} else {
		htmlObj += "<tr><td style='text-align:left' width='50%'><div class='subtitle'>&nbsp;</div>";
	}
	
	htmlObj += "</td></tr></table>";
	
	htmlObj += "<table style='width:100%'><tr><td><div class='textbox'>" + jsonObj.textField + "</div></td></tr></table>";
	
	htmlObj += fs.readFileSync(settings.WhiteLotusDir.toString() + '/templates/footer.html', 'utf8');

	return htmlObj;
}
