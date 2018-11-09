var weatherTemplate = require('./weatherTemplate.js');
var bodyTemplate1 = require('./bodyTemplate1.js');
var bodyTemplate2 = require('./bodyTemplate2.js');
var listTemplate1 = require('./listTemplate1.js');
var emptyTemplate = require('./emptyTemplate.js');

exports.returnHtml = function(jsonObj) {
	var templateType = jsonObj.type
	switch(templateType) {
		case "WeatherTemplate":
			return weatherTemplate.load(jsonObj);
			break;
		case "BodyTemplate1":
			return bodyTemplate1.load(jsonObj);
			break;
		case "BodyTemplate2":
			return bodyTemplate2.load(jsonObj);
			break;
		case "ListTemplate1":
			return listTemplate1.load(jsonObj);
			break;
		default:
			return emptyTemplate.load();
	}
}
