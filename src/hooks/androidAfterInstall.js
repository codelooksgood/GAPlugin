module.exports = function(context) {
	"use strict";

	// check if android is added on platform add
	if (context.opts.platforms !== undefined && context.opts.platforms.indexOf('android') < 0) {
        return;
    }

	var fs = context.requireCordovaModule("fs");
	var path = context.requireCordovaModule("path");
	var deferral = context.requireCordovaModule("q").defer();

	var platformRoot = path.join(context.opts.projectRoot, "platforms/android");
	var googleSercicesPath = path.join(context.opts.projectRoot, "google-services.json");

	fs.createReadStream(googleSercicesPath).pipe(fs.createWriteStream(path.join(platformRoot, "google-services.json")));

	return deferral.promise;
};