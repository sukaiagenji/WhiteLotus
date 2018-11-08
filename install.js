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

	rl.question('\nAre you ready to proceed with installing the\nAlexa AVS Sample App and all dependencies? (yes/No)\n?', (answer) => {
		if(answer.toLowerCase() == 'yes') {
			console.log('\n\nProceeding with installation...\n\n');
			doInstallation();
		} else {
			console.log('\n\nInstallation aborted!!!');
		}

		rl.close();
	});
}

function doInstallation() {
	console.log("Updating system...\n\n")
	const { spawnSync } = require('child_process')
	const update = spawnSync('sudo', ['apt-get', 'udpate']);
}

/* Ignore this file. Because of issues with the installation script, I will be moving everything to pure shell script. */