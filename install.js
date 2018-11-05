exports.startInstallation = function () {
	var readline = require('readline');

	console.log('***************************\n**     Welcome to the    **\n**      White\u2740Lotus      **\n**       Installer       **\n***************************\n');

	console.log('\nThis installer will add the Alexa AVS Sample App to your Raspberry Pi.\nA Raspberry Pi 3 is highly recommended, although a Raspberry Pi 2 Model B+ is supported.'
	console.log('\nDesktop is not recommended, since everything, including card rendering, is created in console.')
	console.log('\nBecause of the amount of processing necessary to run the Alexa AVS Sample App,\nIt is recommended that you have no other applications running on this Raspberry Pi.'

	var rl = readline.createInterface({
		input: process.stdin
	}

	rl.question('\nAre you ready to proceed with installing the Alexa AVS Sample App and all dependencies? (yes/No)\n' (answeryesno) => {
		if(answeryesno.toLowerCase == 'yes') {
			console.log('\n\nProceeding with installation...');
			doInstallation();
		} else {
			console.log('\n\nInstallation aborted!!!');
			break;
		}

		rl.close();
	});
}

function doInstallation() {
	console.log('\n\nUpdating system...');
}