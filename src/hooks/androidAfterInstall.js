module.exports = function(context) {
	"use strict";

	var fs = context.requireCordovaModule("fs");
	var path = context.requireCordovaModule("path");
	var deferral = context.requireCordovaModule("q").defer();

	var platformRoot = path.join(context.opts.projectRoot, "platforms/android");
	var googleSercicesPath = path.join(context.opts.projectRoot, "google-services.json");

	console.log(platformRoot, googleSercicesPath);

	fs.createReadStream(googleSercicesPath).pipe(fs.createWriteStream(path.join(platformRoot, "google-services.json")));

	return deferral.promise;
};