exports.returnHtml = function(jsonObj, settings) {
	var weatherTemplate = require(settings.WhiteLotusDir.toString() + '/templates/weatherTemplate.js');
	var bodyTemplate1 = require(settings.WhiteLotusDir.toString() + '/templates/bodyTemplate1.js');
	var bodyTemplate2 = require(settings.WhiteLotusDir.toString() + '/templates/bodyTemplate2.js');
	var listTemplate1 = require(settings.WhiteLotusDir.toString() + '/templates/listTemplate1.js');
	var emptyTemplate = require(settings.WhiteLotusDir.toString() + '/templates/emptyTemplate.js');
	var authorize = require(settings.WhiteLotusDir.toString() + '/templates/authorize.js');

	if (!jsonObj) {
		jsonObj = { type: 'empty' };
	}
	var templateType = jsonObj.type;
	switch(templateType) {
		case "WeatherTemplate":
			return weatherTemplate.load(jsonObj, settings);
			break;
		case "BodyTemplate1":
			return bodyTemplate1.load(jsonObj, settings);
			break;
		case "BodyTemplate2":
			return bodyTemplate2.load(jsonObj, settings);
			break;
		case "ListTemplate1":
			return listTemplate1.load(jsonObj, settings);
			break;
		case "authorize":
			return authorize.load(jsonObj, settings);
			break;
		default:
			return emptyTemplate.load(settings);
	}
}
