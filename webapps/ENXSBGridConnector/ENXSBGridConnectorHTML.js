	var totalTimeStart = new Date().getTime();
	var performanceLogs = {};
	var editMap = {}, isDataModified = false;

    /**
    	TODO:
    	All global declared variables should be moved to publish properties in the ENXSBGridConnection.js if the
    	variable needs to be accessed across different modules (ENXDataGrid, ENXSBGridConnector, ENXSBToolbarClient)
    **/
    var gridType = "NONE";
    var dataGridModel, dgView, dgToolbar,alertMessageNotification, graph, toolbarInputControlsIds=[], displayModesColumnsArray = [], addEventListenersTo = [], tableViewEventListener = [], expandProgramViewEventListener = [], tagService;
	var emxExpandFilter, expandLevel = 0, fromExpandCommand = false, dataGridEnabled = true, activeCellColumn, activeCellRow;


require.config({
    	paths: {

    		emxUIConstants: "ENOAEFCore/webroot/common/scripts/emxUIConstants",
    		emxUIModal: "ENOAEFCore/webroot/common/scripts/emxUIModal",
    		emxUICoreMenu: "ENOAEFCore/webroot/common/scripts/emxUICoreMenu",
    		emxUICore: "ENOAEFCore/webroot/common/scripts/emxUICore",
    		emxUITableUtil: "ENOAEFCore/webroot/common/scripts/emxUITableUtil"
    	},

    	shim: {

    		"emxUIConstants": {
    			"exports" : "emxUIConstants"
    		},

    		"emxUIModal": {
    			"exports" : "emxUIModal"
    		},

    		"emxUICoreMenu": {
    			"exports" : "emxUICoreMenu"
    		},
    		"emxUICore" : {
    			"exports" : "emxUICore"
    		},
    		"emxUITableUtil" : {
    			"exports" : "emxUITableUtil"
    		}
    	}
    });

require({

},[
	'DS/ENXSBGridConnector/ENXSBGridConnector',
	'DS/ENXSBGridConnector/SBFunctionsSupport',
	'DS/ENOFrameworkPlugins/jQuery',
	'DS/ENXDataGrid/URLUtils'

],
	function(
			connector,
			SBFunctionsSupport,
			$,
			URLUtils){

	$.getScript( '../../common/GetValidations.jsp?suiteKey='+URLUtils.getParameter("suiteKey"), function( data, textStatus, jqxhr ) {
		 console.log( "validation script load: "+textStatus );
	});
	if(typeof URLUtils.getParameter("emxExpandFilter") != 'undefined' && URLUtils.getParameter("emxExpandFilter") != null && URLUtils.getParameter("emxExpandFilter") != "") {
		emxExpandFilter = Number(URLUtils.getParameter("emxExpandFilter"));
	}

	if (typeof widget != 'undefined') {
		widget.addEvents({
			onLoad : function(event) {
				var connector = new connector();
			}
		});
	} else {
		var connector = new connector();
	}

	var emxEditableTable = SBFunctionsSupport.emxEditableTable;
	emxEditableTable.expand = emxEditableTable.expand.bind(connector);

	window.emxEditableTable = emxEditableTable;
	window.toggleProgress = SBFunctionsSupport.toggleProgress;
	window.editableTable = SBFunctionsSupport.editableTable;
	window.rebuildView = SBFunctionsSupport.rebuildView;
	window.undo = SBFunctionsSupport.editableTable.undo;
	window.copy = SBFunctionsSupport.editableTable.copy;
	window.updateoXML = SBFunctionsSupport.updateoXML;
	window.postDataXML = SBFunctionsSupport.postDataXML;
	window.RefreshTableHeaders = SBFunctionsSupport.RefreshTableHeaders;
	window.showLifeCycleIcons = SBFunctionsSupport.showLifeCycleIcons;
	
	/*
	 * remove save alerts - start
	 */
	window.onunload = function() {
		var saveAlerts = getTopWindow().document.getElementsByClassName(" alert alert-root");
		if(typeof saveAlerts != 'undefined' && saveAlerts.length > 0) {
			while(saveAlerts.length > 0) {
				saveAlerts[0].parentNode.removeChild(saveAlerts[0]);
			}
		}
	}
	/*
	 * remove save alerts - end
	 */
});

