//=================================================================
// JavaScript expandall.js
// Copyright (c) 1992-2018 Dassault Systemes.
// All Rights Reserved.
//=================================================================
// NOTE: Legacy code stay as global to avoid regression.
//       New code should be put inside of "define"
//							MM:DD:YY
//quickreview LX6       	04:03:15    IR-362439-3DEXPERIENCER2016x : Expand functionality does not work correctly on structure explore of Requirement Specification or Requirement.
//quickreview KIE1  ZUD		14:10:15	Expand all command was not working
//quickreview QYG           05:03:16    javascript refactoring, split from RichTextEditorStructure.js
//quickreview KIE1  ZUD		30:03:17	IR-499554-3DEXPERIENCER2018x: R419-STP: Expand not working When Specification is opened from Overview of requirement as Checkbox inside Expand all button are not in Checked State by default.


if(localStorage['debug.AMD']) {
	var _RMTExpandAll_js = _RMTExpandAll_js || 0;
	_RMTExpandAll_js++;
	console.info("AMD: ENORMTCustoSB/expandall.js loading " + _RMTExpandAll_js + " times.");
}

define('DS/ENORMTCustoSB/expandall', ['DS/RichEditorCusto/Util'], function(){
	if(localStorage['debug.AMD']) {
		console.info("AMD: ENORMTCustoSB/expandall.js dependency loaded.");
	}	
	
	emxUICore.instrument(emxUIToolbarButton, 'init', RMTCustomExpandAll, RMTHideExpandAll);
	//emxUICore.instrument(emxUIToolbar, 'createDOM', RMTCheckToolbar, null);
	emxUICore.instrument(emxUICorePopupMenu, 'show', setDefaultValues, updateValuesAfterPreferences);
	emxUICore.instrument(window, '_delay_expandAll', RMTBeforeExpandAll, RMTAfterExpandAll);
	
	if(localStorage['debug.AMD']) {
		console.info("AMD: ENORMTCustoSB/expandall.js finish.");
	}	
	return {};
});


//START : LX6 : IR-362439-3DEXPERIENCER2016x : Expand functionality does not work correctly on structure explore of Requirement Specification or Requirement.
function updateValuesAfterPreferences(){
	var expandValues = getTopWindow().expandFilterTypes;
	var expandFilter = getTopWindow().RMTExpandFilter;
	$('#emxExpandFilter').val(expandFilter);
	if(expandValues!=null){
		if(expandValues.indexOf("SubRequirements")>-1){
			$('#SubRequirements')[0].checked=true;
		}else{
			$('#SubRequirements')[0].checked=false;
		}
		if(expandValues.indexOf("Parameters")>-1){
			$('#Parameters')[0].checked=true;
		}else{
			$('#Parameters')[0].checked=false;
		}
		if(expandValues.indexOf("TestCases")>-1){
			$('#TestCases')[0].checked=true;
		}else{
			$('#TestCases')[0].checked=false;
		}
	}
	submitToolbarForm('javascript:selectMoreLevel()','popup','emxExpandFilter','812','500','structureBrowser','','','false','false','combobox','emxExpandFiltermxcommandcode');
}
//END : LX6 : IR-362439-3DEXPERIENCER2016x : Expand functionality does not work correctly on structure explore of Requirement Specification or Requirement.

function setDefaultValues(objRef, strDir, x, y) {
	//START : LX6 : IR-362439-3DEXPERIENCER2016x : Expand functionality does not work correctly on structure explore of Requirement Specification or Requirement.
	isPreferencesModified=getTopWindow().preferencesModified;
	if( objRef.id == "expandAll"){
		if(isPreferencesModified == true){
			updateValuesAfterPreferences();
			getTopWindow().preferencesModified = false;
		}else if (displayExpandAllFirstTime == true) {
				var expandFilter = getTopWindow().RMTExpandFilter;
				displayExpandAllFirstTime = false;
				$('#emxExpandFilter').val(expandFilter);
		}
	}
	return true;
	//END : LX6 : IR-362439-3DEXPERIENCER2016x : Expand functionality does not work correctly on structure explore of Requirement Specification or Requirement	
}

function checkExpandTypes(value) {
    var returnedValue = getTopWindow().expandFilterTypes.indexOf(value) > -1 ? "checked" : "";
    return returnedValue;
}

function RMTBeforeExpandAll(){
	var expandTypes = "";
    for (var i = 0; i < RMTexpandTypes.length; i++) {
        var isChecked = $('#' + RMTexpandTypes[i])[0].checked;
        if (isChecked) {
            if (expandTypes.length > 0) {
                expandTypes += ",";
            }
            expandTypes += RMTexpandTypes[i];
        }
    }
	var href = '../requirements/SpecificationStructureUtil.jsp?mode=customExpand' + '&RMTCustomTypes=' +
    expandTypes + "&fpTimeStamp=" + timeStamp+ '&expandLevel=All';
$.post(href, {
        RMTCustomTypes: expandTypes,
    },
    function(data, status) {
        var QuickChartSlideIn = $('#dashBoardSlideInFrame');
    	if(QuickChartSlideIn.length>0){
    		//the dashboard is displayed
    		refreshQuickCharts();
    	}
        
    });
}

function RMTAfterExpandAll(){
//	expandAllDynaTreeRMT();
	var QuickChartSlideIn = $('#dashBoardSlideInFrame');
	if(QuickChartSlideIn.length>0){
		setTimeout(function() {
			//the dashboard is displayed
			refreshQuickCharts();
	    }, TIMEOUT_VALUE);
		
	}
}

function RMTCustomExpandAll() {
    var returnedValue = false;
    currentTable == "RMTRequirementSpecificationsList" ? true : false;
    //if(this.url == "javascript:expandAll()"){
    if (this.icon.contains("iconActionSetNodeExpansionLevel")) {
        this.id = "expandAll";
        this.url = "";
        this.addMenu(new emxUIToolbarMenu());
        this.setMode("");
        objMenu = this.menu;
        var popup = "";
        popup += "<label title=\"\">" + expandHint + "</label>";
        popup += "<table>";
        popup += "<tr>";
        popup += "<td class=\"input\">";
        popup +=
            "<select name=emxExpandFilter title='' style='width:80px;' id='emxExpandFilter'  onChange=updateDefaultValue();submitToolbarForm('javascript:selectMoreLevel()','popup','emxExpandFilter','812','500','structureBrowser','','','false','false','combobox','emxExpandFiltermxcommandcode')>";
        popup += "<option value=\"1\" >1</option>";
        popup += "<option value=\"2\" >2</option>";
        popup += "<option value=\"3\" >3</option>";
        popup += "<option value=\"4\" >4</option>";
        popup += "<option value=\"5\" >5</option>";
        popup += "<option value=\"All\" >"+allLabel+"</option>";
        popup += "</select>";
        popup += "<br>";
        if (currentTable != "RMTMyDeskGroupList") {
            for (var i = 0; i < RMTexpandTypes.length; i++) {
                popup += "<input type=\"checkbox\" id=" + RMTexpandTypes[i] +
                    " value=\""+RMTexpandTypes[i]+"\" " + checkExpandTypes(RMTexpandTypes[i]) + ">" + RMTLabels[i] +
                    "<br>";
            }
        } else {
            RMTexpandTypes = "";
        }
        popup += "<input type=\"button\" value=\""+applyLabel+"\" onclick=\"RMTExpandAll()\"/>";
        popup += "</td>";
        objMenu.addItem(new emxUIToolbarFormField(emxUIToolbar.INPUT_TYPE_COMBOBOX, "emxExpandFilter",
            "Expand", "javascript:selectMoreLevel()", "popup", "", "", "812", "500", popup, "",
            "", "",
            "false", "false", "", "", "15", "", "", "", "", "", "", "", "", "", ""));
        
    	if(localStorage['debug.AMD']) {
    		console.info("AMD: #####checkboxes for expand all added.###########");
    	}	
    	
        returnedValue = true;
    }else if(this.icon.contains("iconActionExpandAll")){ 
    	this.id="expandAllDefaultValue";
    	returnedValue = true
    }else {
        returnedValue = true;
    }
	afterOnResizeTimeout();
    return returnedValue;
}

function updateDefaultValue() {
    var selectedValue = document.getElementById("emxExpandFilter").value;
    getTopWindow().RMTExpandFilter = selectedValue; 
}

function RMTExpandAll() {
    var expandTypes = "";
    for (var i = 0; i < RMTexpandTypes.length; i++) {
        var isChecked = $('#' + RMTexpandTypes[i])[0].checked;
        if (isChecked) {
            if (expandTypes.length > 0) {
                expandTypes += ",";
            }
            expandTypes += RMTexpandTypes[i];
        }
    }
    setRequestSetting("RMTCustomTypes", expandTypes);
    var expandFilterValue = getTopWindow().RMTExpandFilter!=null?getTopWindow().RMTExpandFilter:'All';
    var href = '../requirements/SpecificationStructureUtil.jsp?mode=customExpand' + '&RMTCustomTypes=' +
        expandTypes + "&fpTimeStamp=" + timeStamp+ '&expandLevel='+expandFilterValue;
    $.post(href, {
            RMTCustomTypes: expandTypes,
        },
        function(data, status) {
        	expandLevel=emxExpandFilter.value;
            expandNLevels();
            var QuickChartSlideIn = $('#dashBoardSlideInFrame');
        	if(QuickChartSlideIn.length>0){
        		//the dashboard is displayed
        		refreshQuickCharts();
        	}
            
        });

}

/*function RMTCheckToolbar() {

    for (var i = 0; i < this.items.length; i++) {
        var button = this.items[i];
        //JX5 : button.icon might be null in catia client context
        if (button.icon != null) {
            if (button.icon.contains("iconActionSetNodeExpansionLevel")) {
                this.items.splice(i, 1);
                i--;
            }
        }

    }
    return true;
}*/

function RMTHideExpandAll() {
	$('#emxExpandFilter').val(getTopWindow().RMTExpandFilter);
    var hideExpand = currentTable == "RMTRequirementSpecificationsList" ? true : false;
    if(hideExpand==true){
    	if (this.icon.contains("iconActionExpandAll")) {
        	$("#expandAllDefaultValue").hide();
        }
        if (this.icon.contains("iconActionSetNodeExpansionLevel")) {
        	$("#expandAll").hide();
        }
    }else{
    	if((this.icon.contains("iconActionSetNodeExpansionLevel"))){
        	$("#expandAll").find("img[src$='iconActionSetNodeExpansionLevel.png']").hide();
        	$("#expandAll").css({"padding-left":"0px"});
        	$("#expandAll").css({"padding-right":"9px"});
        	
        }
        if((this.icon.contains("iconActionExpandAll"))){
        	$("#expandAllDefaultValue").css({"margin-right":"0px"});
        }
    }
    return true;
}

if(localStorage['debug.AMD']) {
	console.info("AMD: ENORMTCustoSB/expandall.js global finish.");
}
