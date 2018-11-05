exports.startInstallation = function () {
	var readline = require('readline');

	console.log('***************************\n**     Welcome to the    **\n**      White\u2740Lotus      **\n**       Installer       **\n***************************\n');

	console.log('\nThis installer will add the Alexa AVS Sample App to your Raspberry Pi.\nA Raspberry Pi 3 is highly recommended, although a\nRaspberry Pi 2 Model B+ is supported.');
	console.log('\nDesktop is not recommended, since everything, including card rendering,\nis created in console.');
	console.log('\nBecause of the amount of processing necessary to run the Alexa AVS Sample App,\nit is recommended that you have no other applications running on this\nRaspberry Pi.');

	var rl = readline.createInterface({
		input: process.stdin,
		output: process.stdout
	});

	rl.question('\nAre you ready to proceed with installing the\nAlexa AVS Sample App and all dependencies? (yes/No)\n', (answeryesno) => {
		if(answeryesno.toLowerCase() == 'yes') {
			console.log('\n\nProceeding with installation...');
			doInstallation();
		} else {
			console.log('\n\nInstallation aborted!!!');
		}

		rl.close();
	});
}

function doInstallation() {
	console.log('\n\nUpdating system...');
}
