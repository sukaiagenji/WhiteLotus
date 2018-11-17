var fs = require("fs");

exports.load = function(jsonObj, settings) {
	var htmlObj = fs.readFileSync(settings.WhiteLotusDir.toString() + '/templates/header1.html', 'utf8');
	htmlObj += fs.readFileSync(settings.WhiteLotusDir.toString() + '/templates/css/weather.css', 'utf8');
	htmlObj += fs.readFileSync(settings.WhiteLotusDir.toString() + '/templates/header2.html', 'utf8');
	
	htmlObj += "<div class='title'>" + jsonObj.title.mainTitle + "</div>";
	htmlObj += "<div class='subtitle'>" + jsonObj.title.subTitle + "</div>";
	
	htmlObj += "<table style='width:100%'><tr><td  width='20.6%'><div class='weathericon'>"
	for (var i in jsonObj.currentWeatherIcon.sources) {
		if (jsonObj.currentWeatherIcon.sources[i].size == "SMALL") {
			htmlObj += "<img src=" + jsonObj.currentWeatherIcon.sources[i].url + "></div></td>";
		}
	}
	
	htmlObj += "<td style:'align=center'><div class='currenttemp'>" + jsonObj.currentWeather + "</div></td>";
	
	htmlObj += "<td width='20.6%'><table><tr><td width='50%'>";
	for (var i in jsonObj.highTemperature.arrow.sources) {
		if (jsonObj.highTemperature.arrow.sources[i].size == "SMALL") {
			htmlObj += "<img src=" + jsonObj.highTemperature.arrow.sources[i].url + "></td>";
		}
	}
	htmlObj += "<td width='50%'><div class='largehigh'>" + jsonObj.highTemperature.value + "</div></td></tr>";
	
	htmlObj += "<tr><td width='50%'>";
	for (var i in jsonObj.lowTemperature.arrow.sources) {
		if (jsonObj.lowTemperature.arrow.sources[i].size == "SMALL") {
			htmlObj += "<img src=" + jsonObj.lowTemperature.arrow.sources[i].url + "></td>";
		}
	}
	htmlObj += "<td width='50%'><div class='largelow'>" + jsonObj.lowTemperature.value + "</div></td></tr></table></table>";
	
	htmlObj += "<table style='width:100%; padding-top: 7.5%'><tr>";
	
	for (var i in jsonObj.weatherForecast) {
		for (var j in jsonObj.weatherForecast[i].image.sources) {
			if (jsonObj.weatherForecast[i].image.sources[j].size == "SMALL") {
				htmlObj += "<td><table><tr><td><img src=" + jsonObj.weatherForecast[i].image.sources[j].url + ">";
			}
		}
		htmlObj += "</td></tr><tr><td><div class='date'>" + jsonObj.weatherForecast[i].day + "</div></td></tr>";
		htmlObj += "<tr><td><div class='smallhigh'>" + jsonObj.weatherForecast[i].highTemperature + "</div> | <div class='smalllow'>" + jsonObj.weatherForecast[i].lowTemperature + "</td></tr></table>";
	}

	htmlObj += "</tr></table>";
	
	htmlObj += fs.readFileSync(settings.WhiteLotusDir.toString() + '/templates/footer.html', 'utf8');
	
	return htmlObj;
}
