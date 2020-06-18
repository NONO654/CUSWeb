//=================================================================
// JavaScript derivation.js
// Copyright (c) 1992-2018 Dassault Systemes.
// All Rights Reserved.
//=================================================================
// NOTE: Legacy code stay as global to avoid regression.
//       New code should be put inside of "define"
//							MM:DD:YY
//quickreview JX5 	QYG 	01:31:14 	HL RMT Create Derivation links between Requirements
//quickreview JX5     		07:17:14 	HL RMT Create Derivation links between Requirements : instrument doFreezePaneCheckBoxes to gray out commands when not reqspec
//quickreview JX5     		08:01:14 	Remove instrumentation of doFreezePaneCheckBoxes, handle selection for derivation commands differently
//quickreview JX5 	  		11:28:14 	IR-341738 Adding target in "Covers" or "Refined Into" pop up dialogue box is KO after invoking "Requirement Tracability Report" from icon. 
//quickreview HAT1 	ZUD 	12:22:14 	HL Requirement Specification Dependency
//quickreview HAT1 	ZUD 	02:12:15 	HL - Requirement Specification dependency. Tabs and buttons support in checkConsistency dialog.
//quickreview ZUD 	HAT1 	04:23:15    IR-364087-3DEXPERIENCER2016x : All target Req spec for existing dependency is not available in the traceability authoring...
//quickreview JX5	T94		05:20:15	IR-370825-3DEXPERIENCER2016x : Create links to cover requirements, it's need to take a long time.
//quickreview LX6			06:11:15	IR-374998-3DEXPERIENCER2016x : When refining requirements, Change of relationship status of requirement in drop down menu is not getting saved properly. 
//quickreview QYG           05:03:16    javascript refactoring, split from RichTextEditorStructure.js
//quickreview HAT1 	ZUD 	11:07:16 	IR-438515-3DEXPERIENCER2018x: Japanese character are garbled on the Sub requirement page.
//quickreview KIE1 	ZUD 	01:11:17	IR-528236-3DEXPERIENCER2018x:R420-STP: Adding Target object to create links form Create link to cover requirement/Create link to refined requirement is KO.

define('DS/ENORMTCustoSB/derivation', [], function(){
	return {};
});


/**
 * RMT Window Identifier class which hold useful properties that can be used by
 * the functionality to implement the refresh process
 */
function RMTWindow(isRichTextEditor, tableWindowReference, sourceObjId) {
    this.isRichTextEditor = isRichTextEditor;
    this.tableWindowReference = tableWindowReference;
    this.sourceObjId = sourceObjId;
}

function getNavigatorWindow(win) {
    win = win.getTopWindow();

    while (!win.RMTNavigatorWindow) {
        try {
	 //KIE1 ZUD TSK447636 
            if (win.getWindowOpener() && win.location.protocol == win.getWindowOpener().location.protocol && win.location.host ==
                win.getWindowOpener().location.host) {
                win = win.getWindowOpener().getTopWindow();
            } else
                return win;
        } catch (e) {
            return win;
        }
    }
    return win.RMTNavigatorWindow;
}

/**
 * Function is called from RMTMarkAsSource command
 */
function RMTMarkAsSource_onClick() {
    var mode = "Mark";
    var rowId = null;
    try {
        rowId = getSelectedRowId(mode);
    } catch (exp) {}

    if (rowId) {
        // AJAX to call jsp to save object id in session
        var srcUrl = "../requirements/StartLinkProcess.jsp?suiteKey=Requirements&emxTableRowId=" + rowId;
        var rcode1 = emxUICore.getDataPost(srcUrl, '');

        rcode1 = trim(rcode1);

        getTopWindow().RMTNavigatorWindow.RMTWindowIdentity = new RMTWindow(
            typeof window.emxEditableTable != 'undefined' && window.emxEditableTable.isRichTextEditor,
            window,
            rowId);

        if (rcode1 != '') {
            alert(rcode1);
        }
    }
}

/**
 * Function is called from RMTLinkAsDerived command
 */
function RMTLinkAsDerived_onClick() {
    RMTLinkAsSubDerived("Derived");
}

/**
 * Function is called from RMTLinkAsSub command
 */

function RMTLinkAsSub_onClick() {
    RMTLinkAsSubDerived("Sub");
}

function RMTLinkAsSubDerived(mode) {

    var rowIds = getSelectedRowId(mode);
    var aSourceWindowIdentidy = null;
    try {
        aSourceWindowIdentidy = findRMTSourceWindow();
    } catch (exp) {}

    if (!aSourceWindowIdentidy) {
        alert(SBCouldNotFindSourceSelectionText);
        return;
    }

    var sbWindow = aSourceWindowIdentidy.tableWindowReference;

    // AJAX to call jsp to save object id in session
    var srcUrl = "../requirements/LinkAsSubOrDerivedProcess.jsp?mode=" + mode +
        "Requirement&suiteKey=Requirements&sourceID=" + aSourceWindowIdentidy.sourceObjId;
    for (var i = 0; i < rowIds.length; i++) {
        srcUrl += "&emxTableRowId=" + rowIds[i];
    }
    srcUrl = trim(srcUrl);

    var success = false;
    var strErrMsg = null;
    try {
        var code = emxUICore.getDataPost(srcUrl, '');
        if (code.indexOf("|") >= 0) {
            code = code.split("|");
            var xmlMessage = code[1];
            code = code[0];
            if (aSourceWindowIdentidy.isRichTextEditor) {
                sbWindow.emxEditableTable.refreshObject();
            } else {
                if (sbWindow.emxEditableTable.refreshSelectedRows) {
                    sbWindow.emxEditableTable.refreshSelectedRows();
                }
            }

            if (typeof sbWindow.emxEditableTable != 'undefined' && sbWindow.emxEditableTable.addToSelected) {
                sbWindow.emxEditableTable.addToSelected(xmlMessage);

                if (!aSourceWindowIdentidy.isRichTextEditor) {
                    var objDOM = emxUICore.createXMLDOM();
                    objDOM.loadXML(xmlMessage);
                    var newObj = sbWindow.emxUICore.selectNodes(
                        objDOM.documentElement, "/mxRoot//item");
                    var newRelId = newObj[0].getAttribute("relId");
                    var rowId = aSourceWindowIdentidy.sourceObjId[0].split("|")[3];
                    var aRowsSelected = sbWindow.emxUICore.selectNodes(
                        sbWindow.oXML, "/mxRoot/rows//r[@id='" + rowId + "']");
                    var newChild = sbWindow.emxUICore.selectNodes(
                        aRowsSelected[0], "/mxRoot/rows//r[@r='" + newRelId + "']");
                    if (newChild.length == 0) {
                        sbWindow.emxEditableTable.addToSelected(xmlMessage);
                    }
                }
            }

        }
        alert(code);
        success = true;
    } catch (exp) {
        if (exp.description) {
            strErrMsg = exp.description;
        } else {
            strErrMsg = exp;
        }
    }

    if (success) {} else {
        alert(strErrMsg);
    }
}

/**
 * Finds the source window from which an object is selected as source object
 * This is done by checking the RMTSourceWindow flag on all the open windows
 */
function findRMTSourceWindow() {
    if (getTopWindow().RMTNavigatorWindow && getTopWindow().RMTNavigatorWindow.RMTWindowIdentity &&
        getTopWindow().RMTNavigatorWindow.RMTWindowIdentity.tableWindowReference && !getTopWindow().RMTNavigatorWindow
        .RMTWindowIdentity.tableWindowReference.closed)
        return getTopWindow().RMTNavigatorWindow.RMTWindowIdentity;

    throw "No RMT source window found.";
}

/**
 * Function is used to find the emxTableRowId of source and target window.
 */
function getSelectedRowId(mode) {
    var aSelectedTableRowIds;
    if (window.emxEditableTable.isRichTextEditor) {
        aSelectedTableRowIds = getSelectedTableRowIds();

    } else {
        var aRowsSelected = emxUICore.selectNodes(oXML.documentElement,
            "/mxRoot/rows//r[@checked='checked']");
        aSelectedTableRowIds = getCheckboxArray(aRowsSelected, mode);
    }
    if (aSelectedTableRowIds.length > 1 && mode == "Mark") {
        alert(SBPleaseSelectOneItemOnlyText);
        return;
    }
    return aSelectedTableRowIds;
}

/**
 * Called from getSelectedRow(mode) method
 */

function getCheckboxArray(aRowsSelected, mode) {
    var checkboxArray = new Array();
    var chkLen = aRowsSelected.length;

    for (var j = 0; j < chkLen; j++) {
        var id = aRowsSelected[j].getAttribute("id");
        var oid = aRowsSelected[j].getAttribute("o");
        var relid = aRowsSelected[j].getAttribute("r");
        if (relid == null || relid == "null") {
            relid = "";
        }
        var parentId = aRowsSelected[j].getAttribute("p");
        if (parentId == null || parentId == "null") {
            parentId = "";
        }
        var totalRowInfo = relid + "|" + oid + "|" + parentId + "|" + id;
        checkboxArray[checkboxArray.length] = totalRowInfo;
    }
    return checkboxArray;
}

function unregisterRMTSourceWindow() {
    if (getTopWindow().RMTNavigatorWindow && getTopWindow().RMTNavigatorWindow.RMTWindowIdentity &&
        getTopWindow().RMTNavigatorWindow.RMTWindowIdentity.tableWindowReference == window) {
        getTopWindow().RMTNavigatorWindow.RMTWindowIdentity = null;
    }

}

/**
 * Keep a reference to main navigator window.
 */
getTopWindow().RMTNavigatorWindow = getNavigatorWindow(getTopWindow());
/*
 * if(isIE) { window.attachEvent("onunload", unregisterRMTSourceWindow); } else {
 * window.addEventListener("unload", unregisterRMTSourceWindow, false);
 *  }
 */


/*****************************************************************
 *  HAT1 ZUD HL Requirement Specification Dependency 
 *  Check Consistency Command : Start
 ****************************************************************/
function launchCheckConsistencyCmd(mode, rowId)
{
	var derivationMode = mode;
    var cssId = 'ui-dynatree-csss';
    if (!document.getElementById(cssId)) {
        var head = document.getElementsByTagName('head')[0];
        var csslink = document.createElement('link');
        csslink.id = cssId;
        csslink.rel = 'stylesheet';
        csslink.type = 'text/css';
        csslink.href = '../common/styles/emxUIDynaTree.css';
        csslink.media = 'all';
        head.appendChild(csslink);
    }
    
    var cssIdMenu = 'ui-dynatreeMenu-csss';
    if (!document.getElementById(cssIdMenu)) {
        var headMenu = document.getElementsByTagName('head')[0];
        var csslinkMenu = document.createElement('link');
        csslinkMenu.id = cssIdMenu;
        csslinkMenu.rel = 'stylesheet';
        csslinkMenu.type = 'text/css';
        csslinkMenu.href = '../requirements/styles/jquery-contextMenu.css';
        csslinkMenu.media = 'all';
        headMenu.appendChild(csslinkMenu);

    }
    
    $.cachedScript("../requirements/scripts/plugins/jquery.ui-RMT.js").done(function() {
        $.cachedScript("../requirements/scripts/plugins/jquery.dialogextend-RMT.js").done( function() {
                $.cachedScript("../plugins/dynatree/1.2.6/jquery.dynatree.min.js").done( function() {
                        require(["dummy/../../requirements/scripts/plugins/jquery.contextMenu-RMT.js", 
                                 'DS/ENORMTCustoSB/explorer', 
                                 'DS/ENORMTCustoSB/CheckConsistencyCmd'], function( ) {
                                	var objectId = null;
                                	var rootObject = null;
                                	var isSelectionAvailable = false;
                                	rootObject = emxUICore.selectNodes(oXML,"/mxRoot/rows//r[@id='0']")[0];
                                	if(rootObject == null)
                                	{
                                		//We use the checked rows
                                		var checkedBoxes = getCheckedRows();
                                		if(checkedBoxes.length > 0){
                                			objectId = checkedBoxes[0].getAttribute("o");
                                			isSelectionAvailable = true;
                                		}
                                	}
                                	else{
                                		objectId   = rootObject.getAttribute("o");
                                		isSelectionAvailable = true;
                                	}
                                	// ++ HAT1 ZUD: HL - Requirement Specification dependency calling all commented functions from ChechConsistencyCmd.js file.

                                	if(isSelectionAvailable){
                                		// create derivation dialog
                                       createCheckConsistencyDialog(objectId);

                                       /* goDynatreeCheckConsistency(
                                                "#treeSource", objectId);
                                       // for Covering
                                       construcFirstCheckConsistencyTree(
                                                "#treeSource",
                                                objectId, 'yes');
                                       
                                       goDynatreeRefined(
                                       		"#treeTarget", objectId);
                                       // for Refined
                                       construcFirstCheckConsistencyTree(
                                               "#treeTarget",
                                               objectId, 'no');

                                       finishCheckConsistencyDlgConstruction
                                                ();
                                        */
                                   	// -- HAT1 ZUD: HL - Requirement Specification dependency
                                       }else {
                                        //Object selection is mandatory in reqspec list
                                        alert("Please select an object !");
                                    }

                            });
                    });
            });
    });

}

/*****************************************************************
 *  Check Consistency Command : End
 ****************************************************************/


/*****************************************************************
 *  Derivation Command : Start
 ****************************************************************/
var derivTreeNumber = 1;
var derivationMode = "satisfy";

function launchDerivationCmd(mode, rowId) {
	
    derivationMode = mode;
    var cssId = 'ui-dynatree-csss';
    if (!document.getElementById(cssId)) {
        var head = document.getElementsByTagName('head')[0];
        var csslink = document.createElement('link');
        csslink.id = cssId;
        csslink.rel = 'stylesheet';
        csslink.type = 'text/css';
        csslink.href = '../common/styles/emxUIDynaTree.css';
        csslink.media = 'all';
        head.appendChild(csslink);
    }

    var cssIdMenu = 'ui-dynatreeMenu-csss';
    if (!document.getElementById(cssIdMenu)) {
        var headMenu = document.getElementsByTagName('head')[0];
        var csslinkMenu = document.createElement('link');
        csslinkMenu.id = cssIdMenu;
        csslinkMenu.rel = 'stylesheet';
        csslinkMenu.type = 'text/css';
        csslinkMenu.href = '../requirements/styles/jquery-contextMenu.css';
        csslinkMenu.media = 'all';
        headMenu.appendChild(csslinkMenu);
    }

    $.cachedScript("../requirements/scripts/plugins/jquery.ui-RMT.js").done(function() {
        $.cachedScript("../requirements/scripts/plugins/jquery.dialogextend-RMT.js").done( function() {
                $.cachedScript("../plugins/dynatree/1.2.6/jquery.dynatree.min.js").done( function() {
                	 $.cachedScript("../webapps/ENORMTCustoSB/DerivationCmd.js").done( function() {
                        require(["dummy/../../requirements/scripts/plugins/jquery.contextMenu-RMT.js", 
                                 'DS/ENORMTCustoSB/explorer', 
                                 'DS/ENORMTCustoSB/DerivationCmd'], function( ) {
	                            	var objectId = null;
	                            	var rootObject = null;
	                            	var isSelectionAvailable = false;
	                            	rootObject = emxUICore.selectNodes(oXML,"/mxRoot/rows//r[@id='0']")[0];
	                            	if(rootObject == null)
	                            	{
	                            		//We use the checked rows
	                            		var checkedBoxes = getCheckedRows();
	                            		if(checkedBoxes.length > 0){
	                            			objectId = checkedBoxes[0].getAttribute("o");
	                            			isSelectionAvailable = true;
	                            		}
	                            		
	                            	}
	                            	else{
	                            		objectId   = rootObject.getAttribute("o");
	                            		isSelectionAvailable = true;
	                            	}
	                            	if(isSelectionAvailable){
	                            		// create derivation dialog
	                                    createDerivationDialog();
	                                    
	                                        goDynatreeDerivation(
	                                            "#treeSource");
	                                        
	                                        setTimeout(function(){
	                                        	 construcFirstDerivTree(
	                                                     "#treeSource",
	                                                     objectId, 'no');
	                                        	 
	
	                                             finishDerivDialogConstruction
	                                                 ();
	                                             
	                                             //existing dependency Target Reqspecs
	                                             existingDependTargetReqSpecs(objectId);
	                                        },TIMEOUT_VALUE);
	
	                                        
	                            	}else {
	                                    //Object selection is mandatory in reqspec list
	                                    alert("Please select an object !");
	                                }
	
                            });
                    });
            });
    });
    });
}

/*****************************************************************
 *  Derivation Command : End
 ****************************************************************/
function displayDerivedInforamtions(rootObj, objectId, direction,divTitle) {
	
	//We need to load the jqueryui scripts in case it's not done already
	$.cachedScript("../requirements/scripts/plugins/jquery.ui-RMT.js").done(function() {
        $.cachedScript("../requirements/scripts/plugins/jquery.dialogextend-RMT.js").done(
            function() {
            	 var program;
            	    var diection;
            	    if (direction == 'up') {
            	        dir = 'To';
            	    } else {
            	        dir = 'From';
            	    }
            	    //START : IR-374998-3DEXPERIENCER2016x Requirement: When refining requirements, Change of relationship status of requirement 
            	    //in drop down menu is not getting saved properly.
            	    var url = "../common/emxIndentedTable.jsp?toolbar=RMTSpecCoveredRefinedRemoveDelete&expandLevel=1&selection=multiple&editLink=true&freezePane=TargetReq&objectId=" + objectId +
            	        "&customize=false&program=emxRequirement:getDerivedRequirements&reportRelationships=relationship_DerivedRequirement&reportDirection=" +
            	        dir +
            	        "&reportTypes=type_Requirement&table=RMTCoveredRefineReqTable&header=emxRequirements.TraceabilityReport.Specification.Requirement.SubDerivedReqs.Header&HelpMarker=emxhelptraceabilityreqreqreport&suiteKey=Requirements&selectedType=Specification&baselineObject=";
            	  ////END : IR-374998-3DEXPERIENCER2016x Requirement: When refining requirements, Change of relationship status of requirement 
            	    //in drop down menu is not getting saved properly.
            	    var floatingOptions = {
            	        resizable: [true, {
            	            animate: true
            	        }],
            	        height: 600,
            	        width: 1000,
            	        title: divTitle,
            	        close: function () {
            	            refreshMainPage();
            	        }
            	    };
            	   //maximize,minize buttons are options of dialogextend component
            	    var floatingExtentedOptions = {
            	    		"closable": true,
            	            "maximizable": true,
            	            "minimizable": true,
            	            "dblclick": 'maximize'		
            	    };
            	    var floatingDivId = "float" + direction + objectId.split(".").join("_");
            	    var frameId = "frame" + direction + objectId.split(".").join("_");
            	    var div = $('#' + floatingDivId);
            	    var frame = $('#' + frameId);
            	    $('#' + floatingDivId).dialog(floatingOptions).dialogExtend(floatingExtentedOptions);
            	    frame.css({
            	        'width': '100%',
            	        'height': '100%'
            	    });
            	    frame.attr('src', url);
            })});
   
}
//END : IR-341768-3DEXPERIENCER2016  No label is displayed on pop up dialogue box when user click on icons of the columns Covered Requirements and Refining Requirements.

//++ HAT1 ZUD: IR-438515-3DEXPERIENCER2018x: fix
function decode_utf8( s ) 
{
	  return decodeURIComponent( escape( s ) );
}

// -- HAT1 ZUD: IR-438515-3DEXPERIENCER2018x: fix 

function displaySubInformations(objectId, divTitle, fromToValue) 
{

// ++ HAT1 ZUD: IR-604654-3DEXPERIENCER2019x ++
	var selection = "multiple";
	if(fromToValue == "From")
		traceabilityReportMethod = "getDownDirectionSubRequirements";
	else if(fromToValue == "To")
		traceabilityReportMethod = "getUpDirectionSubRequirements";
	else
		traceabilityReportMethod = "getBothDirectionSubRequirements";
	// -- HAT1 ZUD: IR-604654-3DEXPERIENCER2019x --
	
	//HAT1 ZUD: IR-438515-3DEXPERIENCER2019x: fix
	if(isIE)
	divTitle = decode_utf8(divTitle);
	
	var dialogId = "";

	//We need to load the jqueryui scripts in case it's not done already
	$.cachedScript("../requirements/scripts/plugins/jquery.ui-RMT.js").done(function() {
        $.cachedScript("../requirements/scripts/plugins/jquery.dialogextend-RMT.js").done(
            function() {
            	 var program;
            	    //START : IR-374998-3DEXPERIENCER2016x Requirement: When refining requirements, Change of relationship status of requirement 
            	    //in drop down menu is not getting saved properly.
            	    var url = '../common/emxIndentedTable.jsp?toolbar=RMTSpecCoveredRefinedRemoveDelete&selection=multiple&hideRootSelection=true&expandLevel=1&sortColumnName=none&suiteKey=Requirements&editLink=true&freezePane=TargetReq&'+
            	    	'program=emxTraceabilityReport:' + traceabilityReportMethod +
            	    '&table=RMTCoveredRefineReqTable&customize=false&objectId='+objectId;   //hasChildren=false&editRootNode=false&
            	    /*var url = "../common/emxIndentedTable.jsp?expandLevel=1&editLink=true&freezePane=TargetReq&objectId=" + objectId +
            	        "&customize=false&program=emxRequirement:getDerivedRequirements&reportRelationships=relationship_DerivedRequirement&reportDirection=" +
            	        dir +
            	        "&reportTypes=type_Requirement&table=RMTSpecCoveredRefinedRemoveDelete&header=emxRequirements.TraceabilityReport.Specification.Requirement.SubDerivedReqs.Header&HelpMarker=emxhelptraceabilityreqreqreport&suiteKey=Requirements&selectedType=Specification&baselineObject=";*/
            	  ////END : IR-374998-3DEXPERIENCER2016x Requirement: When refining requirements, Change of relationship status of requirement 
            	    //in drop down menu is not getting saved properly.
            	    var floatingDivId = "float" + objectId.split(".").join("_");
            	    dialogId = floatingDivId;
            	    var floatingOptions = {
            	        resizable: [true, {
            	            animate: true
            	        }],
            	        height: 400,
            	        width: 1000,
            	        title: divTitle,
            	        close: function () {
            	            refreshMainPage();
            	        }
            	    };
            	   //maximize,minize buttons are options of dialogextend component
            	    var floatingExtentedOptions = {
            	    		"closable": true,
            	            "maximizable": true,
            	            "minimizable": true,
            	            "dblclick": 'maximize'		
            	    };
            	   
            	    var frameId = "frame" + objectId.split(".").join("_");
            	    var div = $('#' + floatingDivId);
            	    var frame = $('#' + frameId);
            	    $('#' + floatingDivId).dialog(floatingOptions).dialogExtend(floatingExtentedOptions);
            	    frame.css({
            	        'width': '100%',
            	        'height': '100%'
            	    });
            	    frame.attr('src', url);

            })});
}

function refreshMainPage(){
	var pageUrl = window.location.href;
	//comes from traceability report so the main page as to be refreshed
	 setTimeout(function() {
	        emxEditableTable.refreshStructureWithOutSort();
	        refreshStructureTree();
	        turnOffProgress();
	    }, TIMEOUT_VALUE);
}


function getFloatingDiv(objectId, direction) {

    var floatingDivId = "float" + direction + objectId.split(".").join("_");
    var frameName = "frame" + direction + objectId.split(".").join("_");
    var floatingDiv = jQuery('<div id="' + floatingDivId + '" style ="display: none;">' +
        '</div>');
    var frame = jQuery('<iframe frameborder="0" name="floatingFrame" id=' + frameName + '></iframe>');
    floatingDiv.append(frame);
    frame.css({
        'width': '100%',
        'height': '100%'
    });
    $("#mx_divBody").append(floatingDiv);
}

