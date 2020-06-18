/*! Copyright 2014 Dassault Systèmes */
/* Configure AMD Loader to load non AMD lib
* See requirejs shim config for references :
*   http://requirejs.org/docs/api.html#config-shim
*/
/* global require, define, jQuery */
//require(['DS/GanttSample/Shim'], function (Shim){
//  Shim.defineShim({
//      testVariable : 'Gnt',  //name of the variable used to verify if the module is loaded and to export
//      ShimModuleName : 'DS/GanttSample/Bryntum',   //name of the shym module
//      VenModuleName : 'Bryntum',        //name of the vendor module
//      VenMWebName : 'DS/Bryntum/',                 //name of the vendor mweb
//      jsName : 'gnt-all',             //name of the js to load (to verify if the shim has already been configured.  Should not be the same as VenModuleName)
//      deps : ['DS/GanttSample/Ext']       //dependencies
//  });
//});
//parameters here to be configured on a case by case

var testVariable = 'emxUIConstants';  //name of the variable used to verify if the module is loaded and to export
var ShimModuleName = 'DS/ENOAEFframeworkJS/UIConstants';   //name of the shym module
var VenModuleName = 'emxUIConstants';        //name of the vendor module
var VenMWebName = 'DS/ENOAEFCore/';                 //name of the vendor mweb
var folderPath = 'webroot/common/scripts/'
//var jsName = 'gnt-all';             //name of the js to load (to verify if the shim has already been configured.  Should not be the same as VenModuleName)

//var VenMWebName = 'DS/VENBryntum/';                 //name of the vendor mweb
var jsName = 'scripts';             //name of the js to load (to verify if the shim has already been configured.  Should not be the same as VenModuleName)
var deps = [];       //dependencies

//code bellow should be the same for all shims
if (typeof window[testVariable] !== 'undefined' ) {
   define(ShimModuleName, function () {
       'use strict';
       return window[testVariable];
   });
} else {
   // In case the module gets executed multiple times
   if (require.toUrl(VenMWebName+VenModuleName).indexOf(jsName) === -1) { //if we don't the js name in the path for the module
       var lMwebPath = require.toUrl(VenMWebName+folderPath);
       // Remove any query strings
       var lIndexOfQuestionMark = lMwebPath.indexOf('?');
       if (lIndexOfQuestionMark > -1) { //remove ? and what follows from the url
        lMwebPath = lMwebPath.substring(0, lIndexOfQuestionMark);
       }
       var pathConfig = {};
       pathConfig[VenMWebName+VenModuleName] = lMwebPath + VenModuleName;

       var shimConfig = {};
       shimConfig[VenMWebName+VenModuleName] = {
                   deps: deps,
                   exports: testVariable
               }
       require.config({
           paths: pathConfig,
           shim: shimConfig
       });
   }
}
define(ShimModuleName, [VenMWebName + VenModuleName], function (module) {
   'use strict';
   return module;
});

