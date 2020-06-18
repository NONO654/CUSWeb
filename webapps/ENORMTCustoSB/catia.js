//=================================================================
// JavaScript catia.js
// Copyright (c) 1992-2018 Dassault Systemes.
// All Rights Reserved.
//=================================================================
// NOTE: Legacy code stay as global to avoid regression.
//       New code should be put inside of "define"
//							MM:DD:YY
//quickreview JX5     		07:17:14 	Embedded SB in CATIA : hide dashboard command, instrument links
//quickreview JX5	  		19:09:14 	IR-309968-3DEXPERIENCER2015x : Effectivity in Table is KO.
//quickreview QYG           05:03:16    javascript refactoring, split from RichTextEditorStructure.js
if(localStorage['debug.AMD']) {
	var _RMTCATIA_js = _RMTCATIA_js || 0;
	_RMTCATIA_js++;
	console.info("AMD: ENORMTCustoSB/catia.js loading " + _RMTCATIA_js + " times.");
}

define('DS/ENORMTCustoSB/catia', ['DS/RichEditorCusto/Util'], function(){
	if(localStorage['debug.AMD']) {
		console.info("AMD: ENORMTCustoSB/catia.js dependency loaded.");
	}
	emxUICore.instrument(window, 'link', linkRTES, null);
	//JX5 IR-309968-3DEXPERIENCER2015x : Effectivity in Table is KO.
	emxUICore.instrument(window, 'getCell', null, afterGetCellRTES);
	
	if(localStorage['debug.AMD']) {
		console.info("AMD: ENORMTCustoSB/catia.js finish.");
	}
	return {};
});


// Fix the "Effectivity Definition Dialog" toolbar the display of the SCE in
// CATIA.
if (typeof objMainToolbar != "undefined" && ((window.location.href.indexOf("RichTextEditorLayout.jsp") >=
    0)) || (window.location.href.indexOf("emxIndentedTable.jsp") >= 0)) {
    var obj = null;
    for (var i = 0; i < objMainToolbar.items.length; i++) {
        // search for the CFF action button that opens the effectivity
        // definition dialog
        if (objMainToolbar.items[i].formFieldName == "CFFExpressionFilterInput") {
            obj = objMainToolbar.items[i];
            break; // got it
        }
    }
    if (obj) { // if we found the item, replace the faulty submitToolbar
        // method by showModalDialog (and set the valid parameters)
        var html = obj.html;
        html = html
            .replace(
                "submitToolbarForm('../effectivity/EffectivityDefinitionDialog.jsp",
                "showModalDialog('../effectivity/EffectivityDefinitionDialog.jsp");
        var pos = html.indexOf(" 'popup'");
        html = html.substring(0, pos) + " '600' , '600' , 'true')\">";
        obj.html = html; // replace the button URL
    }
}
// End Fix of the SCE for CATIA.

/* JX5 Start Embedded SB in CATIA */

function linkRTES(colNum, oid, relId, parentId, linkName) {
        //In CATIA do nothing
        if (isSBEmbedded) {
            return false; // don't call original one
        } else {
            return true; // call original one
        }
    }
/* JX5 End Embedded SB in CATIA*/




function afterGetCellRTES(){
	//Look for Effectivity Column position in table
	var EffectivityColumn = colMap['columns']['StructureEffectivityExpression'];
	if(EffectivityColumn){
		var EffectivityColumnIndex = colMap['columns']['StructureEffectivityExpression'].index;
	
		//Check selected column is an effectivity column
		if(currentColumnPosition == EffectivityColumnIndex){
			//We are in a structure effectivity cell
	
			if(isSBEmbedded){
				//We are in the embedded SB in CATIA
				getCellForCatia();
			}
		}
	}
	return true;
}
function getCellForCatia()
{
    // remove any popup input fields if they exists
    if(currentFormfield || currentHiddenFormfield || currentFloatingDiv){
        removeCurrentFloatingDiv();
    }

    // Get target name
    var targetName = currentCell.target.tagName.toLowerCase();
    var targetNode = currentCell.target;

    var objColumn = colMap.getColumnByIndex(currentColumnPosition-1); 
        
    var editable = objColumn.getSetting("Editable");
    if(editable != 'true'){
        return;
     }
        
     var inputType = objColumn.getSetting("Input Type");
        
        //test for valid InputType
        if(!inputType|| inputType.length < 1){
            return;
        }

        //create floating div
        var name = "formfield" + new Date().getTime();

        var uomAssociated = objColumn.getSetting("UOMAssociated");
        if (uomAssociated != null && uomAssociated != undefined && uomAssociated.toLowerCase() == "true")
        {
            inputType = "dimension";
        }
        var value;
        var rowid = targetNode.parentNode.getAttribute("id");
        var formfield  = getField(targetNode, inputType, objColumn, value, rowid);
        formfield.name = name;
        currentFormfield = formfield; 
        var floatingDiv = document.createElement("div");
        floatingDiv.name = "floatingDiv";
        floatingDiv.className = "formLayer";
        
        
        if(strUserAgent.indexOf("msie 7") >= 0 )
        {
        	getCanvas().appendChild(floatingDiv); //compatible view
        }
        else
        {
            
            document.forms[0].appendChild(floatingDiv);
        }
        
        document.forms[0].elements[name] = formfield; 
        var offset = jQuery(targetNode).offset();
        var posY = offset.top;
        posY -= 6;
        var posX = offset.left;
        posX -= 6;
        floatingDiv.style.top =  posY +"px"; //relative to header element
        floatingDiv.style.left = posX +"px"; 

        floatingDiv.style.visibility = "visible";
        floatingDiv.appendChild(formfield);  
		
        if (inputType == "dimension"||inputType=="radiobutton")
        {
            currentFormfield = formfield;           
            currentFloatingDiv = floatingDiv;
        }

        //create the hidden field for <name>_msvalue
        var hiddenField = document.createElement("input");
        hiddenField.setAttribute("type","hidden");
        //add date picker if column is a date
        if(objColumn.getSetting("format").toLowerCase() == "date"){
            //set to readonly
            if(objColumn.getAttribute("AllowManualEdit") == null ||
                objColumn.getAttribute("AllowManualEdit").toLowerCase() != "true"){
                formfield.setAttribute("readonly","readonly");
            }
            //name and register the hidden field
            hiddenField.name = name + "_msvalue";
            document.forms[0].appendChild(hiddenField);
            if(strUserAgent.indexOf("msie 7") >= 0){
            	document.forms[0].elements[name + "_msvalue"] = hiddenField;
            }
            var anchor = document.createElement("a");
            anchor.setAttribute("href","javascript:showCalendar('emxTableForm', '"+name+"', '','',updateTextWithHelper)");
            var img = document.createElement("img");
            img.setAttribute("src","../common/images/iconSmallCalendar.gif");
            img.setAttribute("alt","Date Picker");
            img.setAttribute("border","0");
            anchor.appendChild(img);
            floatingDiv.appendChild(anchor);
            currentFormfield = formfield;
            currentHiddenFormfield = hiddenField;
            currentFloatingDiv = floatingDiv;
        }
        //rangeHelper url
        if(objColumn.getAttribute("rangeHref") != undefined){
            //oid relid
            var oid = targetNode.parentNode.getAttribute("o");
            var relId = targetNode.parentNode.getAttribute("r");
            //name and register the hidden field
            hiddenField.name = name + "_Actual";
            document.forms[0].appendChild(hiddenField);
            if(strUserAgent.indexOf("msie 7") >= 0){
	        	document.forms[0].elements[name + "_Actual"] = hiddenField;
	        	document.forms[0][name + "_Actual"] = hiddenField;
            }
            var rangeHref = objColumn.getAttribute("rangeHref");
            var suiteKey  = objColumn.getSetting("Registered Suite");
            var button = document.createElement("input");
            button.setAttribute("type","button");
            button.setAttribute("name","btnType");
            button.setAttribute("value","...");
            button.onclick = function(){
                var appendParams = "formName=emxTableForm&fieldNameActual="+name+
                                        "_Actual&fieldNameDisplay="+name+
                                        "&objectId="+oid+"&relId="+relId+
                                        "&suiteKey="+suiteKey;
                rangeHref += (rangeHref.indexOf('?') > -1 ? '&' : '?') + appendParams;
                showChooser(rangeHref,'600','600');
                watchForChange(name,formfield.value);
            };
            floatingDiv.appendChild(button);
            formfield.setAttribute("readOnly","readOnly");
            currentFormfield = formfield;
            currentHiddenFormfield = hiddenField;
            currentFloatingDiv = floatingDiv;
        }

        //must focus window first because of tabbing bug in Moz
        window.focus();
        
        if (inputType == "dimension")
        {
            var oId = currentM1Node.getAttribute("o") + objColumn.getAttribute("name");
            document.getElementById(oId).focus();
        }
        else
        {
            formfield.focus(); 
        }  
         
}
//End JX5 IR-309968-3DEXPERIENCER2015x : Effectivity in Table is KO.

if(localStorage['debug.AMD']) {
	console.info("AMD: ENORMTCustoSB/catia.js global finish.");
}
