var fs = require('fs');

exports.load = function(jsonObj, settings) {
	var htmlObj = fs.readFileSync(settings.WhiteLotusDir.toString() + '/templates/header1.html', 'utf8');
	htmlObj += fs.readFileSync(settings.WhiteLotusDir.toString() + '/templates/css/list.css', 'utf8');
	htmlObj += fs.readFileSync(settings.WhiteLotusDir.toString() + '/templates/header2.html', 'utf8');

	htmlObj += "<div class='title'>" + jsonObj.title.mainTitle + "</div>";
	if (jsonObj.title.subTitle) {
		htmlObj += "<div class='subtitle'>" + jsonObj.title.subTitle + "</div>";
	} else {
		htmlObj += "<div class='subtitle'>&nbsp;</div>";
	}
	
	htmlObj += "<table style='width:100%'>";
	
	for (var i in jsonObj.listItems) {
		htmlObj += "<tr><td style='text-align:left'><div class='listnumber'>" + jsonObj.listItems[i].leftTextField + "</div></td>";
		htmlObj += "<td style='text-align:left'><div class='listitem'>" + jsonObj.listItems[i].rightTextField + "</div></td></tr>";
	}
	
	htmlObj += "</table>"
	
	htmlObj += fs.readFileSync(settings.WhiteLotusDir.toString() + '/templates/footer.html', 'utf8');

	return htmlObj;
}
