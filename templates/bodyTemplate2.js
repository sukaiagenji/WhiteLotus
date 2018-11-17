var fs = require('fs');

exports.load = function(jsonObj, settings) {
	var htmlObj = fs.readFileSync(settings.WhiteLotusDir.toString() + '/templates/header1.html', 'utf8');
	htmlObj += fs.readFileSync(settings.WhiteLotusDir.toString() + '/templates/css/bodytemplate2.css', 'utf8');
	htmlObj += fs.readFileSync(settings.WhiteLotusDir.toString() + '/templates/header2.html', 'utf8');
	
	htmlObj += "<table style='width:100%'><tr>";

	htmlObj += "<td style='text-align:left' width='50%'><div class='title'>" + jsonObj.title.mainTitle + "</div></td>";
	htmlObj += "<td style='text-align:right' rowspan='2' width='50%'>";
	if (jsonObj.skillIcon) {
		for (var i in jsonObj.skillIcon.sources) {
			if (jsonObj.skillIcon.sources[i].size == "SMALL") {
				htmlObj += "<img src=" + jsonObj.skillIcon.sources[i].url + "></td></tr>";
			}
		}
	}
	
	if (jsonObj.title.subTitle) {
		htmlObj += "<tr><td style='text-align:left'><div class='subtitle' width='50%'>" + jsonObj.title.subTitle + "</div>";
	} else {
		htmlObj += "<tr><td style='text-align:left'><div class='subtitle' width='50%'>&nbsp;</div>";
	}
	
	htmlObj += "</td></tr></table>";
	
	htmlObj += "<table style='width:100%'><tr><td style='vertical-align:top; text-align:left' width='50%'><div class='textbox'>" + jsonObj.textField + "</div></td>";
	htmlObj += "<td style='vertical-align:top; text-align:right' width='50%'>";
	for (var i in jsonObj.image.sources) {
		if (jsonObj.image.sources[i].size == "SMALL") {
			htmlObj += "<img src=" + jsonObj.image.sources[i].url + "></td></tr></table>";
		}
	}
	
	htmlObj += fs.readFileSync(settings.WhiteLotusDir.toString() + '/templates/footer.html', 'utf8');

	return htmlObj;
}
