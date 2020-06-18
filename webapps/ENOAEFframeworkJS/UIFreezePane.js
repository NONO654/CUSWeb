/*! Copyright 2014 Dassault Systèmes */
/* Configure AMD Loader to load non AMD lib
* See requirejs shim config for references :
*   http://requirejs.org/docs/api.html#config-shim
*/
/* global require, define, jQuery */
//require(['DS/GanttSample/Shim'], function (Shim){
//	Shim.defineShim({
//		testVariable : 'Gnt',  //name of the variable used to verify if the module is loaded and to export
//		ShimModuleName : 'DS/GanttSample/Bryntum',   //name of the shym module
//		VenModuleName : 'Bryntum',        //name of the vendor module
//		VenMWebName : 'DS/Bryntum/',                 //name of the vendor mweb
//		jsName : 'gnt-all',             //name of the js to load (to verify if the shim has already been configured.  Should not be the same as VenModuleName)
//		deps : ['DS/GanttSample/Ext']       //dependencies
//	});
//});
//parameters here to be configured on a case by case

var testVariable = 'editableTable';  //name of the variable used to verify if the module is loaded and to export
var ShimModuleName = 'DS/ENOAEFframeworkJS/UIFreezePane';   //name of the shym module
var VenModuleName = 'emxUIFreezePane';        //name of the vendor module
var VenMWebName = 'DS/ENOAEFStructureBrowser/';                 //name of the vendor mweb
var folderPath = 'webroot/common/scripts/'
//var jsName = 'gnt-all';             //name of the js to load (to verify if the shim has already been configured.  Should not be the same as VenModuleName)

//var VenMWebName = 'DS/VENBryntum/';                 //name of the vendor mweb
var jsName = 'scripts';             //name of the js to load (to verify if the shim has already been configured.  Should not be the same as VenModuleName)
var deps = [
          'UWA/Core',
          'UWA/Utils',
          'UWA/Utils/InterCom',
          'DS/ENOAEFframeworkJS/UICore',
          'DS/ENOFrameworkPlugins/JQueryStorage',
          'DS/ENOAEFframeworkJS/FindInCntrl',
          'DS/ENOAEFframeworkJS/UIToolbar',
          'DS/ENOAEFframeworkJS/UITableUtil',
          'DS/ENOAEFframeworkJS/UITagNavConnector',
          'DS/ENOAEFframeworkJS/UICalendar',
          'DS/ENOFrameworkPlugins/JQueryWaitForImages',
          'DS/ENODragAndDrop/ENODragAndDrop',
          'DS/ENOAEFframeworkJS/UIRTE',
          'DS/ENOFrameworkPlugins/JSHashTable',
          'DS/ENOFrameworkPlugins/JQueryFormatNumber',
		      'DS/ENOAEFframeworkJS/JSValidationUtil',
          'DS/ENOAEFframeworkJS/ExtendedPageHeaderFreezePaneValidation',
          'DS/ENOAEFframeworkJS/Query',
          'DS/ENOFrameworkPlugins/Html2Canvas',
          'DS/ENOFrameworkPlugins/Canvg',
          'DS/ENOAEFframeworkJS/NavigatorHelp',
          'DS/ENOAEFframeworkJS/UIPopups',
          'DS/ENOAEFframeworkJS/dsTouchEvents',
          'DS/ENOAEFframeworkJS/UIRTEToolbar',
          'DS/ENOAEFframeworkJS/GSBContextMenu', 
          'DS/ENOAEFframeworkJS/GSBhtml',   
		      'DS/ENOAEFframeworkJS/GSBCamera',
          'DS/ENOAEFframeworkJS/GSBVisualLayout',
          'DS/ENOAEFframeworkJS/GSBSampleTree',
          'DS/ENOAEFframeworkJS/GSBMiniMap',
          'DS/ENOAEFframeworkJS/GSBLoadTree',
          'DS/ENOAEFframeworkJS/GSBSlider',
          'DS/ENOAEFframeworkJS/GSBHistory',
          'DS/ENOAEFframeworkJS/GSBState',
          'DS/ENOAEFframeworkJS/GSBController',
          'DS/ENOAEFframeworkJS/GSBUIActionSearch',


          'css!DS/ENOAEFframeworkJS/styles/emxUIExtendedHeader',
          'css!DS/ENOAEFframeworkJS/styles/emxUIDefault',
          'css!DS/ENOAEFframeworkJS/styles/emxUIToolbar',
          'css!DS/ENOAEFframeworkJS/styles/emxUIMenu',
          'css!DS/ENOAEFframeworkJS/styles/emxUIStructureBrowser',
          'css!DS/ENOAEFframeworkJS/styles/emxUICalendar',
          'css!DS/ENOAEFframeworkJS/styles/MiniMap',
          'css!DS/UIKIT/UIKIT',
          'css!DS/ENOAEFframeworkJS/styles/emxUIImageManagerInPlace',
          //need to add jquery.css

          'css!DS/ENOAEFframeworkJS/styles/emxUIChannelDefault.css',
          //need to add emxUIDialog.css only in case of some condition
          'css!DS/ENOAEFframeworkJS/styles/emxUIThumbnailGallery'];

/*'css!DS/ENOAEFframeworkJS/emxUIExtendedHeader','css!DS/ENOAEFframeworkJS/emxUIDefault','css!DS/ENOAEFframeworkJS/emxUIToolbar','css!DS/ENOAEFframeworkJS/emxUIMenu','css!DS/ENOAEFframeworkJS/emxUIStructureBrowser', 'css!DS/ENOAEFframeworkJS/emxUICalendar','css!DS/ENOAEFframeworkJS/MiniMap','css!DS/UIKIT/UIKIT','css!DS/ENOAEFframeworkJS/emxUIImageManagerInPlace'];       //dependencies*/

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

