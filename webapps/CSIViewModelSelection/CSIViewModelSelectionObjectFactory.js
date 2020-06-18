

define('DS/CSIViewModelSelection/CSIViewModelSelectionObjectFactory', ['DS/WebVisuParameters/CSISelectionObject', 'DS/CSIViewModelWebInterfaces/CSIVMClientSelectionObject', 'DS/CSIViewModelWebInterfaces/CSIViewModelWebEnv'],
 
 function (CSIOldSelectionObject, CSINewSelectionObject, CSIUxEnv) {
 	'use strict';

 	var _Factory;
 	if (_Factory == undefined) {
 		_Factory = {};

 		_Factory.createCSISelectionObject = function (params) {
 			var toreturn;
 			if (CSIUxEnv.isNewCSIIdentificationActivated() == true) {
 				CSINewSelectionObject.prototype._declareType();
 				toreturn = new CSINewSelectionObject(params);
 			}
 			else {
 				toreturn = new CSIOldSelectionObject(params);
 			}
 			return toreturn;
 		}
 	}

 	return _Factory;

 });
