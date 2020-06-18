 
 //=================================================================
// JavaScript Methods for Registration of Admin, State and Viewer property
// emxUIDynamicProductConfigurator.js
//
// Copyright 1993-2007 Dassault Systemes.
// All Rights Reserved.
// This program contains proprietary and trade secret information of Dassault Systemes.
// Copyright notice is precautionary only 
// and does not evidence any actual or intended publication of such program
//
// static const char RCSID[] = $Id: /web/configuration/scripts/emxUIDynamicProductRevision.js 1.2.1.1 Wed Jan 07 09:33:18 2009 GMT ds-shbehera Experimental$
//=================================================================

var featureSelectionList = new Array(); // contains ths list of featureList ids and orderedQuantity values of selected features due to the last selection
var plainFeatureSelectionList = new Array(); // contains ths list of featureList ids of selected features due to the last selection
var featureDeselectionList = new Array();
var keyInMemberList = "";
var userSelectedFtrLstId;
var isValidConfiguration;
var comboOwnerForOptionConflict;
var validationStatus = false;  // required to check whether PC is validated before done button is clicked
var lstTrueMPRId; 
var contextObjectType;
var contextMode;
var strExcludeListMPR;
var ruleEvaluationMembersList = new Array(); // it will carry all the rule evaluation member ids.
//var optionObj;   // to avoid the performance issues for combo


// this method remove the rows from featrueOptions table of Product Configuration -- Modified for  IR-022438V6R2011WIM
function removeAddedRows(parentFtrLstId, optionFtrLstId, featureRowDisplayLevel, parentFeatureRowDisplayLevel,isParentDeselect)
{
	var url="ProductRevisionResponse.jsp?mode=dbChooserFeatureDeletion&parentFtrLstId="+parentFtrLstId+"&optionFtrLstId="+optionFtrLstId+"&parentFeatureRowDisplayLevel="+parentFeatureRowDisplayLevel+"&randomCheckForIe=" +Math.random();
	emxUICore.getData(url);
		
	var tBody = document.getElementById("featureOptionsBody");
	var targetRowId = "MprRow"+featureRowDisplayLevel;
	var targetRow = document.getElementById(targetRowId);	
	var nxtSibling;
	var isMandatory=false;
	if(tBody && targetRow)
	{
		while(true)
		{
			nxtSibling = targetRow.nextSibling;
			for(var i=0; i<targetRow.childNodes.length && isParentDeselect != "true" ; i++){
				var chldNod = targetRow.childNodes[i];				
				var txt = "";
				
				if(chldNod.textContent){
					txt = chldNod.textContent;
				}else{
					txt = chldNod.innerText;
				}
				if("Mandatory" == txt){
					isMandatory = true;
				}
			}
			if(targetRow.nextSibling)
			{
				var nextSiblingRowId = (targetRow.nextSibling).getAttribute("id");
					
				if(nextSiblingRowId && !isMandatory)
				{
					if(targetRowId.match(/\./g))
					{
						if(nextSiblingRowId.match(/\./g))
						{	
							if((nextSiblingRowId.match(/\./g).length) > (targetRowId.match(/\./g).length))
							{
								tBody.removeChild(targetRow);
								featureDeselectionList.push(targetRow.getAttribute("ftrLstId"));
								targetRow = nxtSibling;
							}else
							{
								tBody.removeChild(targetRow);
								featureDeselectionList.push(targetRow.getAttribute("ftrLstId"));
								break;
							}
						}else
						{
							tBody.removeChild(targetRow);
							featureDeselectionList.push(targetRow.getAttribute("ftrLstId"));
							break;
						}
					}else
					{
						if(nextSiblingRowId.match(/\./g))
						{
							tBody.removeChild(targetRow);
							featureDeselectionList.push(targetRow.getAttribute("ftrLstId"));
							targetRow = nxtSibling;
						}else
						{
							tBody.removeChild(targetRow);
							featureDeselectionList.push(targetRow.getAttribute("ftrLstId"));
							break;
						}
					}
				}else if (!isMandatory)
				{
					// means it is a key-in row
					tBody.removeChild(targetRow);
					featureDeselectionList.push(targetRow.getAttribute("ftrLstId"));
					targetRow = nxtSibling;
				}else{
					break;
				}
				
			}else
			{
				tBody.removeChild(targetRow);
				featureDeselectionList.push(targetRow.getAttribute("ftrLstId"));
				break;
			}
		}

		if(isMandatory){
			alert("<emxUtil:i18nScript localize=\"i18nId\">emxProduct.Alert.NoDeselectMand</emxUtil:i18nScript>");
			return isMandatory;
		}else{
			validate();
		}
		
	}
}

// this method adds a row in the featrueOptions table of Product Configuration
function addNewRow(rowInnerHtml, featureRowDisplayLevel)
{
	var tBody = document.getElementById("featureOptionsBody");
	var targetRowId = "MprRow"+featureRowDisplayLevel;
	if(tBody)
	{
		var newDiv = document.createElement("div");
		newDiv.innerHTML = rowInnerHtml;
		var newRow = newDiv.firstChild.firstChild.firstChild;
		var targetRow = document.getElementById(targetRowId);
		while(true)
		{
			if(targetRow.nextSibling)
			{
				var nextSiblingRowId = (targetRow.nextSibling).getAttribute("id");
				if(nextSiblingRowId)
				{
					if(targetRowId.match(/\./g))
					{
						if(nextSiblingRowId.match(/\./g))
						{
							if((nextSiblingRowId.match(/\./g).length) > (targetRowId.match(/\./g).length))
							{
								targetRow = targetRow.nextSibling;
							}else
							{
								break;
							}
						}else
						{
							break;
						}
					}else
					{
						if(nextSiblingRowId.match(/\./g))
						{
							targetRow = targetRow.nextSibling;
						}else
						{
							break;
						}
					}
				}else
				{
					// means it is a key-in row
					targetRow = targetRow.nextSibling;
				}
			}else
			{
				break;
			}
		}
		insertAfter(newRow, targetRow);
		
		var ftrLstId = newRow.getAttribute("ftrLstId");
		featureSelectionList.push(ftrLstId);
		plainFeatureSelectionList.push(ftrLstId);
		
		// make the parent radio or checkBox checked.
    	var parentElmntDiv = document.getElementById(featureRowDisplayLevel);
    	var innerHTMLId = parentElmntDiv.getAttribute("innerHTMLId");
    	var selectedElement = document.getElementById(innerHTMLId);
    	selectedElement.checked = "checked";
	}
}  

// to insert an element after the targeted element 
function insertAfter(newElement,targetElement) {
    var parent = targetElement.parentNode;
    if (parent.lastChild == targetElement) {
        parent.appendChild(newElement);
    } else {
        parent.insertBefore(newElement,targetElement.nextSibling);
    }
}

function updateKeyInMemberList()
{
	var KeyInRowName = "Key-In";
	var keyInMemberRows = document.getElementsByName(KeyInRowName);
	var keyInRowElmnt;
	var keyInInputElmntId;
	var keyInInputElmnt;
	var keyInValue;
	for(var i=0; i<keyInMemberRows.length; i++)
	{
		keyInRowElmnt = keyInMemberRows[i];
		keyInInputElmntId  = keyInRowElmnt.getAttribute("inputElementForKeyIn");
		if(keyInInputElmntId != "" && keyInInputElmntId != null)
		{
		keyInInputElmnt = document.getElementById(keyInInputElmntId);
		if(!keyInInputElmnt)
			keyInInputElmnt = document.getElementById("forIe"+keyInInputElmntId);
		keyInValue = keyInInputElmnt.value;
		keyInMemberList += keyInInputElmntId;
		keyInMemberList += "-";
		if(keyInValue == null || keyInValue == "")
			keyInMemberList += "Empty";
		else
			keyInMemberList += keyInValue;
		if(i != keyInMemberRows.length - 1)
			keyInMemberList += "-";
	}
		
	}
	var isForKeyIn = true;
	var url="ProductRevisionResponse.jsp?isForKeyIn=" +isForKeyIn+ "&keyInMemberList=" +keyInMemberList + "&randomCheckForIe=" +Math.random();
	keyInMemberList = [];
	var xmlDoc = emxUICore.getXMLData(url);
	var xmlObj=xmlDoc.documentElement;
	var name;
	var isEmptyKeyInValue;
	isEmptyKeyInValue = xmlObj.getAttribute("isEmpty");
	if(isEmptyKeyInValue != "" && isEmptyKeyInValue != "null" && isEmptyKeyInValue)
		return isEmptyKeyInValue;
	else
		return false;
}

function updateInnerHTML(target, checked, selectionType)
{
	var groupName = target.getAttribute("groupName");
	var id = target.getAttribute("innerHTMLId");
	var isDisabled = document.getElementById(id).disabled;
	var featureRowLevel = target.getAttribute("id");
	//var orderedQuantity = target.getAttribute("orderedquantity");
	var arr = id.split("c");
	var selectedFtrLstId = arr[1];
	var iFeatureRowLevel = target.getAttribute("id");
	

	
	if(checked == true)
	{
		//updateOrderedQuantity(featureRowLevel, orderedQuantity, true);
		
		if(!((contextMode=="2" && contextObjectType=="Model")
                                ||(contextMode=="1" && contextObjectType!="Product Variant"))&&(selectionType == "MustSelectOnlyOne" || selectionType == "MaySelectOnlyOne")){
   			//Modifed for Bug 374673 : To maintain the mandatory features as checked and disabled 
   			if(isDisabled){
   				htmlText = "<input name="+groupName+" id="+id+" type=\"radio\" value=\"radiobutton\" onclick=\"validate('"+iFeatureRowLevel+"')\" featureRowLevel="+iFeatureRowLevel+" checked=\"checked\" disabled=\"disabled\"/>";
   			}else{
   				htmlText = "<input name="+groupName+" id="+id+" type=\"radio\" value=\"radiobutton\" onclick=\"validate('"+iFeatureRowLevel+"')\" featureRowLevel="+iFeatureRowLevel+" checked=\"checked\"/>";
   			}	 	
   			
   		}else{
   		   //Modifed for Bug 374673 : To maintain the mandatory features as checked and disabled
   			if(isDisabled){
   				htmlText = "<input name="+groupName+" id="+id+" type=\"checkbox\" value=\"checkbox\" onclick=\"validate('"+iFeatureRowLevel+"')\" featureRowLevel="+iFeatureRowLevel+" checked=\"checked\" disabled=\"disabled\"/>";	
   			}else{
   				htmlText = "<input name="+groupName+" id="+id+" type=\"checkbox\" value=\"checkbox\" onclick=\"validate('"+iFeatureRowLevel+"')\" featureRowLevel="+iFeatureRowLevel+" checked=\"checked\"/>";	
   			}	
   		}		
   			
   	}
   	else
   	{
		//updateOrderedQuantity(featureRowLevel, orderedQuantity, false);
   	
   		if(!((contextMode=="2" && contextObjectType=="Model")
                                ||(contextMode=="1" && contextObjectType!="Product Variant"))&&(selectionType == "MustSelectOnlyOne" || selectionType == "MaySelectOnlyOne"))
   		 htmlText = "<input name="+groupName+" id="+id+" type=\"radio\" value=\"radiobutton\" onclick=\"validate('"+iFeatureRowLevel+"')\" featureRowLevel="+iFeatureRowLevel+" />";
   		else
   			htmlText = "<input name="+groupName+" id="+id+" type=\"checkbox\" value=\"checkbox\" onclick=\"validate('"+iFeatureRowLevel+"')\" featureRowLevel="+iFeatureRowLevel+" />";
   	}
   		 
 	target.innerHTML = htmlText;
}

// This function is to make the combo or chooser or dbChooser childrens deselected if the parent is deselected
function makeDeselectionsOfComboChooserAndDBChooser(id)
{
	// this is to make combo or chooser option deselected
	var comboOrChooserRowId = parseFloat(id) + 1;
	var comboOrChooserRow = document.getElementById('MprRow'+comboOrChooserRowId);
	
		if(comboOrChooserRow)
		{
			var isComboOrChooser = comboOrChooserRow.getAttribute("isComboOrChooser");
			if(isComboOrChooser)
			{
				var isChooserElement = isComboOrChooser.slice(0, 14);
				if(isChooserElement == "chooserElement")
				{
					var inputElement = document.getElementById(isComboOrChooser);
					var currentselectionliid = inputElement.getAttribute("currentselectionliid");
					if(currentselectionliid != null && currentselectionliid != "")
					{
						var deselectedId = currentselectionliid.split("li")[1];
						inputElement.setAttribute("lastselectionftrlstid", deselectedId);
					inputElement.setAttribute("currentselectionliid", "");
					inputElement.value = "";
						featureDeselectionList.push(deselectedId);
					}
				}else{
					var comboElement = document.getElementById(isComboOrChooser);
					featureDeselectionList.push(comboElement.options[comboElement.selectedIndex].value);
					for(var j=0; j<comboElement.options.length; j++)
					{
						var text = comboElement.options[j].text;
						if(text == "" || text == null)
						{
							comboElement.options[j].selected = "selected";
						}
					}
				}
			}
		}
		//end
		
		// this is to make the dbChooserOptions deselected 
		var dbChooserRow = document.getElementById('MprRow'+id);
		if(dbChooserRow)
		{
			var nxtRow;
		while(true)
		{
				nxtRow = dbChooserRow.nextSibling;
				if(nxtRow && nxtRow.id.match(/\./g))
			{
					var dbChooserSubFtrDisplaylvl = nxtRow.id.split("MprRow")[1];
					var dbChooserChildStatusDivId = nxtRow.firstChild.firstChild.id;
					var arrTemp3 = dbChooserChildStatusDivId.split('E');
					var arrTemp4 = arrTemp3[1].split('c');
			// Added new arg for modified method  IR-022438V6R2011WIM
					removeAddedRows(arrTemp4[0], arrTemp4[1], dbChooserSubFtrDisplaylvl, id, "true");	
				}else{
				break;
			}
		}
		}
		
		//end	
}

var arrFtrLstIds = new Array(); // this array carries all the parents in the feature structure to be deselected
function makeDeselections(relatedDivId) // This function is to make the childrens deselected if the parent is deselected
{
	var deselectedDiv = document.getElementById(relatedDivId);
	var ftrLstId = deselectedDiv.getAttribute("ftrLstId");	
	var selectionType = deselectedDiv.getAttribute("selectionType");
	arrFtrLstIds.push(ftrLstId);
	//Modified for Bug 373505 - Deselecting only if not mandatory but updating the  featureDeselectionList.
	var innerHTMLId = deselectedDiv.getAttribute("innerHTMLId");
    var isChecked = document.getElementById(innerHTMLId).checked;
	var isDisabled = document.getElementById(innerHTMLId).disabled;
	
	
	if(isChecked && isDisabled)
		 		isMandatory=true;
	if(!isMandatory){
	updateInnerHTML(deselectedDiv, false, selectionType);
	}
	//Modified for Bug 373505 -  Deselecting only if not mandatory but updating the  featureDeselectionList.	
	featureDeselectionList.push(ftrLstId);
	makeDeselectionsOfComboChooserAndDBChooser(relatedDivId);
	var isMandatory=false;
	while(true)
	{
		var id = ++relatedDivId ;
		var divElement = "";
		var divElement = document.getElementById(id);
		/*if(divElement == null)
			var orderedQnttyDivId = document.getElementById(id+"OrderedQuantity");
		if((divElement == "" || divElement == null) && orderedQnttyDivId == null)
			break;
		else*/
		 if(divElement == null)
			id = ++relatedDivId ;
		divElement = document.getElementById(id);
		if(divElement)
		{
		 selectionType = divElement.getAttribute("selectionType");
		 innerHTMLId = divElement.getAttribute("innerHTMLId");				 
		 var arr = innerHTMLId.split("c");
		 var parentFtrLstId = arr[0];	
		 isChecked = document.getElementById(innerHTMLId).checked;
		 isDisabled = document.getElementById(innerHTMLId).disabled;
		 if(isChecked && isDisabled)
		 		isMandatory=true;	 
			 
			var toBeDeselected = false;
	   		 for(var i=0; i<arrFtrLstIds.length; i++)
	   		 {
	    		ftrLstId = arrFtrLstIds[i];
		      //Bug 371022 - Deselecting value only if it's not Mandatory
		 if(parentFtrLstId == ftrLstId)
		 {
					toBeDeselected = true;
					break;
		 		}
		 //End : Bug 371022 - Deselecting value only if it's not Mandatory	
			}
			if(toBeDeselected == true)
	    	{
	    	//Modified for Bug 373505 - Deselecting only if not mandatory but updating the  featureDeselectionList.
			if(!isMandatory){
			updateInnerHTML(divElement, false, selectionType);
			 } 	
		//Modified for Bug 373505 -  Deselecting only if not mandatory but updating the  featureDeselectionList.	
				makeDeselectionsOfComboChooserAndDBChooser(id);
				
				makeDeselections(id, true);
		 }
		 else
		 	break;
		}else
			break;
	}
	arrFtrLstIds = [];
}

function getSelectedId(divId)
{
	var selectedDiv = "";
	var orderedQuantity = "";
	var additionalCheckForIE = null;
	selectedDiv = document.getElementById(divId);	
	// For DropDown
	if(selectedDiv != null)
		additionalCheckForIE = selectedDiv.getAttribute("innerHTMLId");
	if((selectedDiv == null || selectedDiv == "") || additionalCheckForIE == null)
	{
		var selectedSelectElements = document.getElementsByName(divId);
		if(selectedSelectElements != null && selectedSelectElements.length != 0)
		{
			selectedSelectElement = selectedSelectElements[0];
			var isChooser = divId.slice(0, 7);
			if(isChooser == "chooser")
			{
				var deselectionListMember = selectedSelectElement.getAttribute("lastSelectionFtrlstId");
				var selectedLiId = selectedSelectElement.getAttribute("currentSelectionLiId");
				var selectedLi = document.getElementById(selectedLiId);
				if(selectedLi)
				{
					var selectedFtrLstId = selectedLi.getAttribute("ftrLstId");
					var orderedQuantity = selectedLi.getAttribute("orderedQuantity");
				}
				featureSelectionList.push(selectedFtrLstId);
				plainFeatureSelectionList.push(selectedFtrLstId);
				featureDeselectionList.push(deselectionListMember);
				
				var featureRowLevel = selectedSelectElement.getAttribute("featureRowLevel");
				--featureRowLevel;
				flag1 = true;
				makeParentSelection(featureRowLevel, true);
			}
			else{
			var featureRowLevel = selectedSelectElement.getAttribute("featureRowLevel");
			var selectedFtrLstId = selectedSelectElement.value;
			var option = "";
			var deSelectedFtrLstId = "";
			for(var i=0; i < selectedSelectElement.options.length; i++)
			{
				deSelectedFtrLstId = selectedSelectElement.options[i].value;
				option = selectedSelectElement.options[i];
				if(selectedSelectElement.options[i].selected)
				{
					featureSelectionList.push(selectedFtrLstId);
					plainFeatureSelectionList.push(selectedFtrLstId);
				}
				else
					featureDeselectionList.push(deSelectedFtrLstId);
			}
			--featureRowLevel;
			flag1 = true;
			makeParentSelection(featureRowLevel, true);
		}
		}
		
	}
	
	// For Radio and CheckBoxes
	
	else if(selectedDiv != null && additionalCheckForIE != null)
	{
	var innerHTMLId = selectedDiv.getAttribute("innerHTMLId");
	var groupName = selectedDiv.getAttribute("groupName");
	var selectionType = selectedDiv.getAttribute("selectionType");
	var ftrLstId = selectedDiv.getAttribute("ftrLstId");
	userSelectedFtrLstId = ftrLstId;
	//var orderedQuantity = selectedDiv.getAttribute("orderedQuantity");
	/*if(orderedQuantity == null)
	{
		orderedQuantity = "0.0";
	}*/
	var selectedElement = document.getElementById(innerHTMLId);
	if(selectedElement)
	{
	var isChecked = selectedElement.checked;
	if(isChecked == true)
	{
			//updateOrderedQuantity(divId, orderedQuantity, true);
				
	featureSelectionList.push(ftrLstId);
	plainFeatureSelectionList.push(ftrLstId);
	//Added for Bug 373505:To select mandatory features into featureSelectionList
	selectMandatoryFeature(divId);
	//End-Added for Bug 373505:To select mandatory features into featureSelectionList
			if(!((contextMode=="2" && contextObjectType=="Model")
                                ||(contextMode=="1" && contextObjectType!="Product Variant"))&& (selectionType == "MustSelectOnlyOne" || selectionType == "MaySelectOnlyOne"))
	{
		var groupElements = document.getElementsByName(groupName);
		for(var count=0; count<groupElements.length; count++)
		{
				var groupElement = groupElements[count];
				var relatedDivId = groupElement.getAttribute("featureRowLevel");
					var deselectedDiv = document.getElementById(relatedDivId);
					var ftrLstId = deselectedDiv.getAttribute("ftrLstId");	
				if(relatedDivId != divId)
				{
						//updateOrderedQuantity(relatedDivId, orderedQuantity, false);
						
						featureDeselectionList.push(ftrLstId);
						arrFtrLstIds = [];
					makeDeselections(relatedDivId);	
				}
		}
			}
			flag1 = true;
			makeParentSelection(divId, false);
		}else
		{
			//var orderedQuantity = selectedDiv.getAttribute("orderedQuantity");
			//updateOrderedQuantity(divId, orderedQuantity, false);
			makeDeselections(divId);
			featureDeselectionList.push(ftrLstId);
			var flag;
			var groupElements = document.getElementsByName(groupName);
			for(var count=0; count < groupElements.length; count++)
			{
				var groupElement = groupElements[count];
				flag = groupElement.checked;
				if(flag == true)
					break;
			}
			if(flag != true)
				{
				  var vnewDivId = --divId;
				  
				  if(vnewDivId>0)
				  {
					  var selectedNewDiv = document.getElementById(vnewDivId);
			//Modified for  IR-022438V6R2011WIM
					  if(selectedNewDiv){
						  var newgroupName = selectedNewDiv.getAttribute("groupName");
						  if(groupName==newgroupName)
						  {
						     makeParentDeselection(vnewDivId);
						  }  
					  }
				  }
				  else
				  {
				         makeParentDeselection(--divId);
				  }				  
				  
				}				
		}
	}
	
	}
}	
	
var flag1 = true;
function makeParentSelection(divId, isForCombo)
{
	var selectedDiv = document.getElementById(divId);
	//Added for Bug 373505:To select mandatory features into featureSelectionList
	//selectMandatoryFeature(divId);
	//End-Added for Bug 373505:To select mandatory features into featureSelectionList
	if(selectedDiv == null)
		return;
	var innerHTMLId = selectedDiv.getAttribute("innerHTMLId");
	var groupName = selectedDiv.getAttribute("groupName");
	var selectionType = selectedDiv.getAttribute("selectionType");
	var arr = innerHTMLId.split("c");
	var parentFtrLstId = arr[0];
	while(flag1)
	{
		var id;
		if(isForCombo == true)
			id = divId ;
		else
			id = --divId;
		var divElement = document.getElementById(id);
		/*if(divElement == null)
			var orderedQnttyDivId = document.getElementById(id+"OrderedQuantity");*/
		if((divElement == "" || divElement == null)) 
		//&& (orderedQnttyDivId == null))
		{
			flag1 = false;
				break;
		}
		else if(divElement == null)
			id = --divId;
		divElement = document.getElementById(id);
			selectionType = divElement.getAttribute("selectionType");
		groupName = divElement.getAttribute("groupName");
            var ftrLstId = divElement.getAttribute("ftrLstId");		
        //var orderedQuantity = divElement.getAttribute("orderedQuantity");
		/*if(orderedQuantity == null)
			{
			orderedQuantity = "0.0";
		}*/		
		if(ftrLstId == parentFtrLstId || isForCombo == true)
		{
			featureSelectionList.push(ftrLstId);
			plainFeatureSelectionList.push(ftrLstId);
				updateInnerHTML(divElement, true, selectionType);
		    
		    //Added for IR :375155		
			if(!((contextMode=="2" && contextObjectType=="Model")
                                ||(contextMode=="1" && contextObjectType!="Product Variant"))&&(selectionType == "MustSelectOnlyOne" || selectionType == "MaySelectOnlyOne"))
			/*if(!((contextMode=="2" && contextObjectType=="Model")
                                ||(contextMode=="1" && contextObjectType == "Product Variant"))&&(selectionType == "MustSelectOnlyOne" || selectionType == "MaySelectOnlyOne"))*/
			
			{
				var groupElements = document.getElementsByName(groupName);
				for(var count=0; count < groupElements.length; count++)
				{
					var groupElement = groupElements[count];
					var relatedDivId = groupElement.getAttribute("featureRowLevel");
					var divElement = document.getElementById(relatedDivId);
					var syblingFtrLstId = divElement.getAttribute("ftrLstId");
					if(syblingFtrLstId != ftrLstId)
						makeDeselections(relatedDivId);
					
				}
			}
			makeParentSelection(id, false);
	 	}
	}
}

function makeParentDeselection(divId)
{
	var deSelectedDiv = document.getElementById(divId);
	
	/*f(deSelectedDiv == null)
		var orderedQnttyDivId = document.getElementById(divId+"OrderedQuantity");*/
	if((deSelectedDiv == "" || deSelectedDiv == null) )
	//&& orderedQnttyDivId == null)
	{
		return;
	}
	else if(deSelectedDiv == null)
		divId = --divId;
	makeDeselections(divId);
	deSelectedDiv = document.getElementById(divId);
	var innerHTMLId = deSelectedDiv.getAttribute("innerHTMLId");
	var groupName = deSelectedDiv.getAttribute("groupName");
	var selectionType = deSelectedDiv.getAttribute("selectionType");
	var ftrLstId = deSelectedDiv.getAttribute("ftrLstId");
	featureDeselectionList.push(ftrLstId);
	updateInnerHTML(deSelectedDiv, false, selectionType);
	if(selectionType == "MaySelectOneOrMore" || selectionType == "MustSelectAtLeastOne")
	{
		var groupElements = document.getElementsByName(groupName);
		var flag;
		for(var count=0; count<groupElements.length; count++)
		{
			var groupElement = groupElements[count];
			flag = groupElement.checked;
			if(flag == true)
				break;
		}
		if(flag != true)
		{
			makeDeselections(divId);
			//makeParentDeselection(--divId);
			
				  var vnewDivId = --divId;
				  
				  if(vnewDivId > 0)
				  {
					  var selectedNewDiv = document.getElementById(vnewDivId);
					  var newgroupName = selectedNewDiv.getAttribute("groupName");
					  if(groupName==newgroupName)
					  {
					     makeParentDeselection(vnewDivId);
					  }		
				  }
				  else
				  {
				      makeParentDeselection(--divId);
				      
				  }		  
					
		
		}
	}
	else 
	{
		makeDeselections(divId);
		//makeParentDeselection(--divId);
		
		var vnewDivId = --divId;
		if(vnewDivId > 0)
		{
		  var selectedNewDiv = document.getElementById(vnewDivId);
		  var newgroupName = selectedNewDiv.getAttribute("groupName");
		  if(groupName==newgroupName)
		  {
			     makeParentDeselection(vnewDivId);
		  }		
		}
		else
		{
		      makeParentDeselection(--divId);
		}
		
		
		
	}
}

        	var errorIconMemberList = new Array();
var techFtrErrorIconMemberList = new Array();
		var changeIconMemberList = new Array();
		var makeDisappearMemberList = new Array();
		var makeAppearMemberList = new Array();
		var autoSelectionMemberList = new Array();
		var deSelectionMemberList = new Array();
		var toNameListForComboAppearMembers = new Array();
		var completeStatusIconMemberList = new Array();

function eraseLastResponse(isFromValidate2)
{
	var nodeName;
		var tempArr = new Array();
		var tempArr1 = new Array();
    var temp;
    var temp1;
    var temp2;
    var temp3;
    var refreshComboTarget;
    var refreshChooserTarget;
    var refreshTarget;
   	var refreshDivHtml = "<a></a>";
   	var mprRowId;
   	var rowElement;
			
   	var bIsDynamic = false;
	var dynamicEvaluation = false;
	var url;
	var xmlDoc;
	var responseStatus;
		   	
	if(isFromValidate2)
	{
		if(completeStatusIconMemberList.length == 0) // this means that it is the first call to eraseLastResponse() after the page load
		{
			
		url="ProductRevisionResponse.jsp?dynamicEvaluation=" +dynamicEvaluation+ "&featureSelectionList=" +featureSelectionList+ "&featureDeselectionList=" +featureDeselectionList+ "&bIsDynamic=" +bIsDynamic + "&randomCheckForIe=" +Math.random();
			xmlDoc = emxUICore.getXMLData(url);
			//responseStatus = xmlDoc.getElementsByTagName("EcResponseStatus")[0];
		
			//completeStatusIconMemberList = convertStringToArray(responseStatus.getAttribute("completeStatusIconMemberList"));
		}
	
		if(completeStatusIconMemberList.length >= 1)
		{
			for(var n=0; n<completeStatusIconMemberList.length; n++)
			{
				nodeName = completeStatusIconMemberList[n];
				if(nodeName != null && nodeName != "")
				{
					tempArr = nodeName.split("E");
				    temp = tempArr[1];
				    tempArr1 = temp.split("c");
				    temp1 = tempArr1[0];
				    temp2 = "comboDiv"+temp1;
				    temp3 = "chooserDiv"+temp1;
				    refreshComboTarget = document.getElementById(temp2);
				    refreshChooserTarget = document.getElementById(temp3);
				    refreshTarget = document.getElementById(nodeName);
				   	refreshDivHtml = "<a></a>";
				   	mprRowId;
				   	rowElement;
				   	if( refreshTarget != null && refreshComboTarget == null && refreshChooserTarget == null)
			   		 {
			    		refreshTarget.innerHTML = refreshDivHtml;
			   		 }
			   		 else if(refreshTarget == null && refreshComboTarget != null && refreshChooserTarget == null)
			   		 {	
			    		refreshComboTarget.innerHTML = refreshDivHtml;
			   		 }else if(refreshChooserTarget != null && refreshTarget == null && refreshComboTarget == null)
			   		 {
			    		refreshChooserTarget.innerHTML = refreshDivHtml;
			   		 }
		   		 }
			}
		}
	}else{
	
		var arr = new Array(errorIconMemberList.length, changeIconMemberList.length, completeStatusIconMemberList.length, techFtrErrorIconMemberList.length);
		var count = getMaximumLength(arr);
		var tBody = document.getElementById("featureOptionsBody");
		
		if(count == 0) // this means that it is the first call to eraseLastResponse() after the page load
		{
			
			url="ProductRevisionResponse.jsp?dynamicEvaluation=" +dynamicEvaluation+ "&featureSelectionList=" +featureSelectionList+ "&featureDeselectionList=" +featureDeselectionList+ "&bIsDynamic=" +bIsDynamic + "&randomCheckForIe=" +Math.random();
			xmlDoc = emxUICore.getXMLData(url);
			responseStatus = xmlDoc.getElementsByTagName("EcResponseStatus")[0];
		
			errorIconMemberList = convertStringToArray(responseStatus.getAttribute("errorIconMemberList"));
			changeIconMemberList = convertStringToArray(responseStatus.getAttribute("changeIconMemberList"));
			completeStatusIconMemberList = convertStringToArray(responseStatus.getAttribute("completeStatusIconMemberList"));
			
			arr = new Array(errorIconMemberList.length, changeIconMemberList.length, completeStatusIconMemberList.length, techFtrErrorIconMemberList.length);
			count = getMaximumLength(arr);
		}
}

}
// this method converts a string to array and it can be more generalized by passing the delimeter 
function convertStringToArray(stringVar)
{
	var arrVar;
	stringVar = stringVar.slice(1, stringVar.length-1);
	if(stringVar != "")
	{
		arrVar = stringVar.split(", ");
	}else{
		arrVar = new Array();
	}
	return arrVar;	
}

// this method returns the maximum length of the arrays in the passed in array
function getMaximumLength(lengthArray)
{
	var mxmLength = parseFloat(lengthArray[0]);
	for(var i=1; i<lengthArray.length; i++)
	{
		(mxmLength > parseFloat(lengthArray[i])) ? mxmLength = mxmLength : mxmLength = parseFloat(lengthArray[i]);
	}
	return mxmLength;
}

function updateErrorIcomResponse(divId)
{
	if(divId != null && divId != "")
		{
	    var tempArr = divId.split("E");
			var temp = tempArr[1];
		var tempArr1 = temp.split("c");
			var parentFtrLstId = tempArr1[0];
			var comboDivId = "comboDiv"+parentFtrLstId;
			var chooserDivId = "chooserDiv"+parentFtrLstId;
			
			var comboDivElement = document.getElementById(comboDivId);
			var chooserDivElement = document.getElementById(chooserDivId);
			var divElement = document.getElementById(divId);
		
			if(divElement == null && comboDivElement == null && chooserDivElement == null)
			{
			return;
			}
			else if(divElement != null && comboDivElement == null && chooserDivElement == null)
			{
				var mprRowId = divElement.getAttribute("mprRowId");
				var targetRow = document.getElementById(mprRowId);
				targetRow.setAttribute("class","mx_error");
				targetRow.className = "mx_error";
			        target = document.getElementById(divId);
		        	htmlText = "<img src=../common/images/iconStatusError.gif onmouseover=getY(event);displayOptionConflict('"+divId+"')>";
		        	target.innerHTML = htmlText;
			}else if(chooserDivElement != null && comboDivElement == null && divElement == null)
			{
				mprRowId = chooserDivElement.getAttribute("mprRowId");
				targetRow = document.getElementById(mprRowId);
				targetRow.setAttribute("class","mx_error");
				targetRow.className = "mx_error";
				target = chooserDivElement;
				htmlText = "<img src=../common/images/iconStatusError.gif onmouseover=getY(event);displayOptionConflict('"+chooserDivId+"')>";
				target.innerHTML = htmlText;
			}else
			{
				var comboElementId = "comboElement"+parentFtrLstId;
				var selectElement = document.getElementById(comboElementId);
				if(selectElement)
				{
					var selectedOption = selectElement.options[selectElement.selectedIndex];
					var selectedOptionValue = selectedOption.value;
				}
				if(!selectedOptionValue == "")
				{
				var mprRowId = comboDivElement.getAttribute("mprRowId");
				var targetRow = document.getElementById(mprRowId);
				targetRow.setAttribute("class","mx_error");
				targetRow.className = "mx_error";
				target = document.getElementById(comboDivId);
				htmlText = "<img src=../common/images/iconStatusError.gif onmouseover=getY(event);displayOptionConflict('"+comboDivId+"')>";
				target.innerHTML = htmlText;
			}
			}
	}
		}
		
		
function updateTechFtrErrorIconResponse(divId)
{
	if(divId)
	{
	var rowInnerHtml = "<table><tbody><tr name='rowForTechFtr' class='mx_error'>"
						+ "<td class='mx_status'>"
						+ "<div id='"+divId+"'><img src='../common/images/iconStatusError.gif' onmouseover=getY(event);displayOptionConflict('"+divId+"')></div>"
						+ "</td><td>&#160;</td><td>&#160;</td><td>&#160;</td><td>&#160;</td><td>&#160;</td></tr></tbody></table>";
	
	var newDiv = document.createElement("div");
	newDiv.innerHTML = rowInnerHtml;
	var newRow = newDiv.firstChild.firstChild.firstChild;
	
	var tBody = document.getElementById("featureOptionsBody");
	if(tBody && newRow)
	{
		insertAfter(newRow, tBody.lastChild);
	}
}
}

		
function updateChangeIconResponse(divId)
{
	if(divId != null && divId != "")
		{
	    var tempArr = divId.split("E");
			var temp = tempArr[1];
		var tempArr1 = temp.split("c");
			var parentFtrLstId = tempArr1[0];
			var comboDivId = "comboDiv"+parentFtrLstId;
			var chooserDivId = "chooserDiv"+parentFtrLstId;
			
			var comboDivElement = document.getElementById(comboDivId);
			var chooserDivElement = document.getElementById(chooserDivId);
			var divElement = document.getElementById(divId);
			
			var mprRowId;
			var targetRow;
			
			if(divElement == null && comboDivElement == null && chooserDivElement == null)
		{
			return;
		}
			else if(divElement != null && comboDivElement == null && chooserDivElement == null)
			{
				mprRowId = divElement.getAttribute("mprRowId");
				targetRow = document.getElementById(mprRowId);
				targetRow.setAttribute("class","mx_changed");
				targetRow.className = "mx_changed";
			target = document.getElementById(divId);
			htmlText = "<img src=../common/images/iconStatusChanged.gif onmouseover=getY(event);displayOptionConflict('"+divId+"')>";
			target.innerHTML = htmlText;
			}else if(chooserDivElement != null && comboDivElement == null && divElement == null)
			{
				mprRowId = chooserDivElement.getAttribute("mprRowId");
				targetRow = document.getElementById(mprRowId);
				targetRow.setAttribute("class","mx_changed");
				targetRow.className = "mx_changed";
				target = chooserDivElement;
				htmlText = "<img src=../common/images/iconStatusChanged.gif onmouseover=getY(event);displayOptionConflict('"+chooserDivId+"')>";
				target.innerHTML = htmlText;
			}else
			{
				var comboElementId = "comboElement"+parentFtrLstId;
				var selectElement = document.getElementById(comboElementId);
				if(selectElement)
				{
					var selectedOption = selectElement.options[selectElement.selectedIndex];
					var selectedOptionValue = selectedOption.value;
				}
				if(!selectedOptionValue == "")
				{
				var mprRowId = comboDivElement.getAttribute("mprRowId");
				var targetRow = document.getElementById(mprRowId);
				targetRow.setAttribute("class","mx_changed");
				targetRow.className = "mx_changed";
				target = document.getElementById(comboDivId);
				htmlText = "<img src=../common/images/iconStatusChanged.gif onmouseover=getY(event);displayOptionConflict('"+comboDivId+"')>";
				target.innerHTML = htmlText;
			}
		}
		}
}
		
function updateCompleteStatusIconResponse(divId)
{
	if(divId != null && divId != "")
		{
			var divElement = document.getElementById(divId);
			if(divElement == null)
		{
			return;
		}
			else if(divElement)
			{
				var mprRowId = divElement.getAttribute("mprRowId");
				var targetRow = document.getElementById(mprRowId);
				target = document.getElementById(divId);
				htmlText = "<img src=../common/images/iconStatusComplete.gif>";
				target.innerHTML = htmlText;
			}
	}
		}
		
function updateAutoSelectionResponse(elementId)
		{
	if(elementId != null && elementId != "")
			{
		var tempArr = elementId.split("c");
			var parentFtrLstId = tempArr[0];
			var optionFtrLstId = tempArr[1];
			var comboElementId = "comboElement"+parentFtrLstId;
			var comboElementName = "comboElName"+parentFtrLstId;
			var chooserElementId = "chooserElement"+parentFtrLstId;
			var selectElement = document.getElementById(comboElementId);
			var chooserElement = document.getElementById(chooserElementId);
			var inputElement = document.getElementById(elementId);
			if(inputElement != null && selectElement == null && chooserElement == null)
			{
			var divId1 = inputElement.getAttribute("featureRowLevel");
			target1 = document.getElementById(divId1);
				var selectionType = target1.getAttribute("selectionType");
				var groupName = target1.getAttribute("groupName");
				
				if(!((contextMode=="2" && contextObjectType=="Model")
                                ||(contextMode=="1" && contextObjectType!="Product Variant"))&&(selectionType == "MustSelectOnlyOne" || selectionType == "MaySelectOnlyOne"))
				{
					var groupElements = document.getElementsByName(groupName);
					for(var count=0; count<groupElements.length; count++)
					{
						var groupElement = groupElements[count];
						var relatedDivId = groupElement.getAttribute("featureRowLevel");
						if(relatedDivId != divId1)
						{
							var deselectedDiv = document.getElementById(relatedDivId);
							var ftrLstId = deselectedDiv.getAttribute("ftrLstId");	
							featureDeselectionList.push(ftrLstId);	
						}
					}
				}		
				updateInnerHTML(target1, true, selectionType);
			}else if(chooserElement != null && inputElement == null && selectElement == null )
			{	
				var featureRowLevel = chooserElement.getAttribute("featurerowlevel");
				var liId = featureRowLevel+"li"+optionFtrLstId;
				var li = document.getElementById(liId);
				if(li)
				{
					if(chooserElement.getAttribute("currentselectionliid"))
					{
				var currentSelectionLi = document.getElementById(chooserElement.getAttribute("currentselectionliid"));
					if(currentSelectionLi)
					{
							var lastSelectionFtrlstId = currentSelectionLi.getAttribute("ftrlstid");
						featureDeselectionList.push(lastSelectionFtrlstId);
					}
					}
							var currentSelectionFtrlstId = li.getAttribute("ftrlstid");
				updateTableColumnValuesForChooser(chooserElementId, li);
				checkOrderedQuantity(featureRowLevel+"OrderedQuantity", chooserElementId, featureRowLevel+"ExtPrice", featureRowLevel+"EachPrice", false, featureRowLevel+"li"+currentSelectionFtrlstId);
						
					}
			}else if(inputElement == null && selectElement != null && chooserElement == null)
			{
				
				for(var i=0; i < selectElement.options.length; i++)
				{
					deSelectedFtrLstId = selectElement.options[i].value;
					var featureRowLevel = selectElement.getAttribute("featurerowlevel");
					if(deSelectedFtrLstId == optionFtrLstId)
					{
						selectElement.options[i].selected = "selected";
						updateTableColumnValuesForCombo(comboElementName);
						checkOrderedQuantity(featureRowLevel+"OrderedQuantity", comboElementName, featureRowLevel+"ExtPrice", featureRowLevel+"EachPrice", false);
					}
					else
						featureDeselectionList.push(deSelectedFtrLstId);
						
				}
		}else{
			return;
		}
			}			
		}
		
function updateDeselectionResponse(elementId)
		{
	if(elementId != null && elementId != "")
	{
		var tempArr = elementId.split("c");
			var parentFtrLstId = tempArr[0];
			var optionFtrLstId = tempArr[1];
			var comboElementId = "comboElement"+parentFtrLstId;
			var chooserElementId = "chooserElement"+parentFtrLstId;
			var comboElementName = "comboElName"+parentFtrLstId;
			var selectElement = document.getElementById(comboElementId);
			var chooserElement = document.getElementById(chooserElementId);
			var inputElement = document.getElementById(elementId);
			var comboHasBlank = false;
			if(inputElement != null && selectElement == null && chooserElement == null)
			{
				var featureRowLevel = inputElement.getAttribute("featureRowLevel");
				makeParentDeselection(featureRowLevel);
			}else if(chooserElement != null && inputElement == null && selectElement == null )
			{
				var featureRowLevel = chooserElement.getAttribute("featurerowlevel");
				var liId = featureRowLevel+"li"+optionFtrLstId;
				var li = document.getElementById(liId);
				var currentSelectionLi = document.getElementById(chooserElement.getAttribute("currentselectionliid"));
					var lastSelectionFtrlstId = currentSelectionLi.getAttribute("ftrlstid");
					if(optionFtrLstId == lastSelectionFtrlstId && li)
					{
						li = document.getElementById(featureRowLevel+"li");
						//var currentSelectionFtrlstId = li.getAttribute("ftrlstid");
						featureDeselectionList.push(lastSelectionFtrlstId);
						updateTableColumnValuesForChooser(chooserElementId, li);
						checkOrderedQuantity(featureRowLevel+"OrderedQuantity", chooserElementId, featureRowLevel+"ExtPrice", featureRowLevel+"EachPrice", false, featureRowLevel+"li");
				
					}
			}else if(inputElement == null && selectElement != null  && chooserElement == null)
			{
				var selectedFtrLstId = selectElement.value;
				if(optionFtrLstId == selectedFtrLstId) // make the deselection only if the corresponding frt is owner of the combo
				{
					for(var i=0; i < selectElement.options.length; i++)
					{
						deSelectedFtrLstId = selectElement.options[i].value;
						if(deSelectedFtrLstId == optionFtrLstId)
						{
							var featureRowLevel = selectElement.getAttribute("featurerowlevel");
							// following var is required for the excluded feature from the Combo to show the option conflict details
							// for the change icon against the combo as the present owner ftr of combo will be blank.
							comboOwnerForOptionConflict = deSelectedFtrLstId;
							for(var i=0; i < selectElement.options.length; i++)
							{
								var optionToBeSelected = selectElement.options[i].value;
								if(optionToBeSelected == "")
								{
									comboHasBlank = true;
									selectElement.options[i].selected = "selected";
									updateTableColumnValuesForCombo(comboElementName);
									checkOrderedQuantity(featureRowLevel+"OrderedQuantity", comboElementName, featureRowLevel+"ExtPrice", featureRowLevel+"EachPrice", false);
								}
							}
							if(!comboHasBlank)  // if combo dont contain blank value then add it and then make it selected.
							{
								selectElement.options[selectElement.options.length] = new Option("", "", false, false);
								for(var i=0; i < selectElement.options.length; i++)
								{
									var optionToBeSelected = selectElement.options[i].value;
									if(optionToBeSelected == "")
									{
										selectElement.options[i].selected = "selected";
										updateTableColumnValuesForCombo(comboElementName);
										checkOrderedQuantity(featureRowLevel+"OrderedQuantity", comboElementName, featureRowLevel+"ExtPrice", featureRowLevel+"EachPrice", false);
									}
								}
							}
						}
					}
				}
			}
		}
}

function updateMakeAppearResponse(divId, toName, xmlDoc)
{
	var dlistprice = "0.0";
	var dmaximumquantity = "0.0";
	var orderedquantity = "0.0";
	var sequenceOrder = "1";
	var tempSeqenceOrder;
	var index = null;
	
	if(divId != null && divId != "")
	{
	   	var nodeName = xmlDoc.getElementsByTagName(divId)[0];
	   	dlistprice =  nodeName.getAttribute("listPrice");
		dmaximumquantity =  nodeName.getAttribute("maximumQntty");
		orderedquantity =  nodeName.getAttribute("orderedQntty");
		sequenceOrder =  nodeName.getAttribute("sequenceOrder");
		sequenceOrder = parseFloat(sequenceOrder);
		var keyInType = nodeName.getAttribute("keyInType");
		var selectionType = nodeName.getAttribute("selectionType");
				
		var tempArr = divId.split("E");
		var temp = tempArr[1];
		var tempArr1 = temp.split("c");
		var parentFtrLstId = tempArr1[0];
		var optionFtrLstId = tempArr1[1];
		var comboElementId = "comboElement"+parentFtrLstId;
		var chooserElementId = "chooserElement"+parentFtrLstId;
		var selectElement = document.getElementById(comboElementId);
		var chooserElement = document.getElementById(chooserElementId);
		var divElement = document.getElementById(divId);
		if(divElement == null && selectElement == null && chooserElement == null)
		{
			return;
		}
		else if(divElement != null && selectElement == null && chooserElement == null)
		{
			var mprRowId = divElement.getAttribute("mprRowId");
			var targetRow = document.getElementById(mprRowId);
			if(targetRow.style.visibility == "hidden")
				 targetRow.style.visibility = "visible";
		}else if(chooserElement != null && selectElement == null && divElement == null)
		{
			var featureRowLevel = chooserElement.getAttribute("featureRowLevel");
			if(!document.getElementById(featureRowLevel+"li"+optionFtrLstId))
			{
				var ulElement = document.getElementById("chooserLayerUL"+parentFtrLstId);
				var new_element = document.createElement('li');
				new_element.innerHTML = toName;
				new_element.setAttribute("id", featureRowLevel+"li"+optionFtrLstId);
				new_element.setAttribute("class", "");
				new_element.onclick = function(){makeOptionSelectionFromFilter(this)};
				new_element.setAttribute("dlistprice", dlistprice);
	  			new_element.setAttribute("dmaximumquantity", dmaximumquantity);
				new_element.setAttribute("orderedquantity", orderedquantity);
	 			new_element.setAttribute("sequenceorder", sequenceOrder);
	 			new_element.setAttribute("ftrlstid", optionFtrLstId);
	  			new_element.setAttribute("selectionType", selectionType);
	 			new_element.setAttribute("keyInType", keyInType);
					
				if(ulElement.firstChild){
					var obj = ulElement.lastChild;
					ulElement.insertBefore(new_element, obj.nextSibling);
				}else{
					ulElement.insertBefore(new_element, ulElement.firstChild);
				}
			}
		}else
		{
			var isAlreadyAvailable = false;
			var isIndexSet = false;
			for(var i=0; i < selectElement.options.length; i++)
			{
				var availableFtrLstId = selectElement.options[i].value;
				tempSeqenceOrder = selectElement.options[i].getAttribute("sequenceOrder");
				tempSeqenceOrder = parseFloat(tempSeqenceOrder);
				if(availableFtrLstId == optionFtrLstId)
				{
					isAlreadyAvailable = true;
					break;
				}else if(!isIndexSet){
					if(tempSeqenceOrder > sequenceOrder)
					{
						index = i;
						isIndexSet = true;
					}
				}
			}
			if(!isAlreadyAvailable)
			{
				var numbOfOptions = selectElement.options;
				var newOption=document.createElement('option');
	 			newOption.text = toName;
	  			newOption.setAttribute("dlistprice", dlistprice);
	  			newOption.setAttribute("dmaximumquantity", dmaximumquantity);
	 			newOption.setAttribute("orderedquantity", orderedquantity);
	  			newOption.setAttribute("sequenceOrder", sequenceOrder);
	  			newOption.setAttribute("selectionType", selectionType);
	  			newOption.setAttribute("keyInType", keyInType);
	  			newOption.value = optionFtrLstId;
	  			try
	    		{
	   				selectElement.add(newOption,((0 > index) || (numbOfOptions.length == index)) ? null : numbOfOptions[index]); // standards compliant
	   			}
	  			catch(ex)
	    		{
	    			selectElement.add(newOption, index); // IE only
	   			}
					
			}
		}
	}
}
			
function updateMakeDisAppearResponse(divId)
{
	if(divId != null && divId != "")
		{
		var comboHasBlank1 = false;
		var tempArr = divId.split("E");
			var temp = tempArr[1];
		var tempArr1 = temp.split("c");
			var parentFtrLstId = tempArr1[0];
			var optionFtrLstId = tempArr1[1];
			var comboElementId = "comboElement"+parentFtrLstId;
			var chooserElementId = "chooserElement"+parentFtrLstId;
			var comboElementName = "comboElName"+parentFtrLstId;
			var selectElement = document.getElementById(comboElementId);
			var chooserElement = document.getElementById(chooserElementId);
			
			var divElement = document.getElementById(divId);
			if(divElement == null && selectElement == null && chooserElement == null)
		{
			return;
		}
			else if(divElement != null && selectElement == null && chooserElement == null)
			{
				var mprRowId = divElement.getAttribute("mprRowId");
				var targetRow = document.getElementById(mprRowId);
				var vis = targetRow.style.visibility;
				if(targetRow.style.visibility == "visible" || targetRow.style.visibility == "")
					 targetRow.style.visibility = "hidden";
			}else if(chooserElement != null && divElement == null && selectElement == null)
			{
				var featureRowLevel = chooserElement.getAttribute("featureRowLevel");
				var liId = featureRowLevel+"li"+optionFtrLstId;
				var ulElement = document.getElementById("chooserLayerUL"+parentFtrLstId);
				var li = document.getElementById(liId);
				if(li && ulElement)
				{
					var currentselectionliid = chooserElement.getAttribute("currentselectionliid");
					var currentSelectionLi;
					if(currentselectionliid != null && currentselectionliid != "" )
					{
						currentSelectionLi = document.getElementById(currentselectionliid);
					}
		 		ulElement.removeChild(li);
			 		if(dummyLiArray && dummyLiArray.length >= 1)
			 		{
			 			var tempArr = new Array(dummyLiArray);
			 			dummyLiArray = [];
			 			for(var liObj in tempArr)
			 			{
			 				if(liObj != li)
			 				{
			 					dummyLiArray.push(liObj);
			 				}
			 			}
			 		}
				 		if(currentSelectionLi)
				 		{
				 			var lastSelectionFtrlstId = currentSelectionLi.getAttribute("ftrlstid");
				 		if(optionFtrLstId == lastSelectionFtrlstId)
				 		{
			 			li = document.getElementById(featureRowLevel+"li");
					 			featureDeselectionList.push(lastSelectionFtrlstId);
								updateTableColumnValuesForChooser(chooserElementId, li);
						checkOrderedQuantity(featureRowLevel+"OrderedQuantity", chooserElementId, featureRowLevel+"ExtPrice", featureRowLevel+"EachPrice", false, featureRowLevel+"li");
				 		}
					}
			 				}
			}else
			{	
				var featureRowLevel = selectElement.getAttribute("featurerowlevel");
				for(var i=0; i < selectElement.options.length; i++)
				{
					var makeDisAppearFtrLstId = selectElement.options[i].value;
					var currentOption = selectElement.options[i];
					var isSelected = currentOption.selected;
					var orderedquantity = currentOption.getAttribute("orderedquantity");
					if(makeDisAppearFtrLstId == optionFtrLstId)
					{
						selectElement.remove(i);	
						if(isSelected)
						{
							for(var i=0; i < selectElement.options.length; i++)
							{
								var optionToBeDisapeared = selectElement.options[i].value;
								if(optionToBeDisapeared == "")
								{
									comboHasBlank1 = true;
									selectElement.options[i].selected = "selected";
									updateTableColumnValuesForCombo(comboElementName);
									checkOrderedQuantity(featureRowLevel+"OrderedQuantity", comboElementName, featureRowLevel+"ExtPrice", featureRowLevel+"EachPrice", false);
								}
							}
							if(!comboHasBlank1)  // if combo dont contain blank value then add it and then make it selected.
							{
								selectElement.options[selectElement.options.length] = new Option("", "", false, false);
								for(var i=0; i < selectElement.options.length; i++)
								{
									var optionToBeSelected = selectElement.options[i].value;
									if(optionToBeSelected == "")
									{
										selectElement.options[i].selected = "selected";
										updateTableColumnValuesForCombo(comboElementName);
										checkOrderedQuantity(featureRowLevel+"OrderedQuantity", comboElementName, featureRowLevel+"ExtPrice", featureRowLevel+"EachPrice", false);
									}
								}
							}
						}
					}
				}
			}
		}
 }

// it updates the lstTrueMPRId element in the emxProductConfigurationFeaturesTableDialog.jsp
function updateLstTrueMPRId(xmlDoc)
{
	var xmlElement = xmlDoc.getElementsByTagName("EcTrueMPRIdList")[0];
	if(xmlElement)
	{
		lstTrueMPRId = xmlElement.getAttribute("strTrueMPRId");	
		var obj = document.getElementById("lstTrueMPRId");
		obj.setAttribute("lstTrueMPRId", lstTrueMPRId);
		strExcludeListMPR = xmlElement.getAttribute("strExcludeListMPR");	
		var objEx = document.getElementById("strExcludeListMPR");
		objEx.setAttribute("strExcludeListMPR", strExcludeListMPR);
	}
}

function getResponse(xmlDoc, isFromValidate2)
{
	var responseStatus = xmlDoc.getElementsByTagName("EcResponseStatus")[0];
        updateLstTrueMPRId(xmlDoc);
 }

// to make the keyin input element appear for combo keyin feature on its selection
function showKeyInInputElementForCombo(featureDisplayLevel, keyInType, strSubFeatureListId)
{
	var keyInDivId = featureDisplayLevel+"keyInDivForCombo";
	var keyInRowId = featureDisplayLevel+"keyInRowForCombo";
	var keyInHiddenElmntId = featureDisplayLevel+"keyInHidden";
	var keyInRowElement = document.getElementById(keyInRowId);
	var keyInRowDivId = document.getElementById(keyInDivId);
	var keyInInputElmnt = document.getElementById(keyInHiddenElmntId);
	var htmlForKeyInInputElement;
	
	keyInRowElement.style.visibility = "visible";
	keyInInputElmnt.setAttribute('inputElementForKeyIn', strSubFeatureListId);
	if(keyInType == "Date")
	{
		htmlForKeyInInputElement = "<table><tr><td class=\"mx_input-cell\"><input id=\"forIe"+strSubFeatureListId+"\" name="+strSubFeatureListId+""+
		"type=\"text\" size=\"20\" value=\"\"  readonly /></td><td><a href=\"javascript:showCalendar('featureOptions','forIe"+strSubFeatureListId+"', '')\"><img border=\"0\" valign=\"bottom\" src=\"../common/images/iconSmallCalendar.gif\" /><input type=\"hidden\" value=\"\" name=\"txtProductSEDate_msvalue\" /></a></td></tr> <tr>"+
		"<td class=\"mx_hint-text\">(mm/dd/yyyy)</td></tr></table>";
	}
	else if(keyInType == "Input")
	{
		htmlForKeyInInputElement = "<table><tr><td class=\"text-field\"><input id=\""+strSubFeatureListId+"\" name=\"txtKeyInText\" type=\"text\" value=\"\" />"+
		"</td></tr><tr><td class=\"mx_hint-text\">(Enter the input)</td></tr></table>";
	}
	else if(keyInType == "Integer")
	{
		htmlForKeyInInputElement = "<table><tr><td class=\"text-field\"><input id=\""+strSubFeatureListId+"\" name=\"txtKeyInText\" type=\"text\" value=\"0\" onchange=\"javascript: this.value = inputNumberCheck (this.value, 0, 1)\"; /></td>"+
		"</tr><tr><td class=\"mx_hint-text\">(Enter the Integer Value)</td></tr></table>";
	}
	else if(keyInType == "Real")
	{
		htmlForKeyInInputElement = "<table><tr><td class=\"text-field\"><input id=\""+strSubFeatureListId+"\" name=\"txtKeyInText\" type=\"text\" value=\"0.00\" onchange=\"javascript: this.value = inputNumberCheck (this.value, 2, 1)\"; /></td>"+
		"</tr><tr><td class=\"mx_hint-text\">(Enter the Real Value)</td></tr></table>";
	}
	else if(keyInType == "Text")
	{
		htmlForKeyInInputElement = "<table><tr><td class=\"text-field\"><textarea id=\""+strSubFeatureListId+"\" name=\"txtKeyInText\" rows=\"5\" cols=\"25\"></textarea></td>"+
		"</tr><tr><td class=\"mx_hint-text\">(Enter the text)</td></tr></table>";
	}
	keyInRowDivId.innerHTML = htmlForKeyInInputElement;
}

 function updateTableColumnValuesForCombo(divId)
 {
 	var selectElements = document.getElementsByName(divId);
	if(selectElements != null && selectElements.length != 0)
	{
		var selectElement = selectElements[0];
		var featureRowLevel = selectElement.getAttribute("featureRowLevel");
		var selectedFtrLstId = selectElement.value;
		var selectionType = "";
		var keyInType = "";
		var strUsage = "";
		var selectedOption = selectElement.options[selectElement.selectedIndex];
		selectionType = selectedOption.getAttribute("selectionType");
		strUsage = selectedOption.getAttribute("Usage");
		//var dMinimumQuantity;
		//var dMaximumQuantity;
		//var dListPrice;
		var parentFtrLstId = divId.slice(11,divId.length);
		
		//var eachPriceInputId = featureRowLevel+"EachPrice";
		var varUsage = featureRowLevel+"Usage";
        var infoDivId = "info"+parentFtrLstId;
        //var quantityDivId = "quantity"+parentFtrLstId;
		var htmlText;
		var target = document.getElementById(varUsage);
		var htmlText;
		if(target != null)
		{
			target.value = strUsage;
		}
	    target = document.getElementById(infoDivId);
		if(target != null)
		{
			htmlText = "<a class=\"mx_button-info\" href=\"javascript:fnloadHelp('"+selectedFtrLstId+"')\" border=\"0\"></a>";
			target.innerHTML = htmlText;
		}
		}
 }

 function validate1(divID, featureRowLevel, fromChkOrdrdQntty) 
    {	
    	if(divID)
    	{
    	var comboCheck = divID.slice(0,5);
    	if(fromChkOrdrdQntty != true )
    	{
    		fromChkOrdrdQntty = false;
    	}
    	if(comboCheck == "combo" && fromChkOrdrdQntty == false)
    	{
    		updateTableColumnValuesForCombo(divID);
    		//checkOrderedQuantity(featureRowLevel+"OrderedQuantity", divID, featureRowLevel+"ExtPrice", featureRowLevel+"EachPrice", false);
    	}
    	}
    	
    	isValidConfiguration = "true";
    	
    	//techFtrErrorIconMemberList = [];
    	if((document.getElementsByName("rowForTechFtr")).length >= 1)
    	{
    		var arr = document.getElementsByName("rowForTechFtr");
    		/*for(var i=0; i< arr.length; i++)
    		{
    			techFtrErrorIconMemberList.push(arr[i]);
    		}*/
    	}
    	eraseLastResponse(false);
    	
    	var dynamicEvaluation = true;
    	var bIsDynamic = true;
		var url="ProductRevisionResponse.jsp?randomCheckForIe=" +Math.random();
		var queryString = "dynamicEvaluation=" +dynamicEvaluation+ "&userSelectedFtrLstId=" +userSelectedFtrLstId+ "&featureSelectionList=" +featureSelectionList+ "&featureDeselectionList=" +featureDeselectionList+ "&bIsDynamic=" +bIsDynamic + "";
		/*var xmlDoc = emxUICore.getXMLDataPost(url, queryString);
		getResponse(xmlDoc, false);*/
		//calculateTotalPrice();
		//validationStatus = false;
		removeMask();
		
		featureSelectionList = [];
		featureDeselectionList = [];
		plainFeatureSelectionList = [];
 	}
 	
	 function validate2(divID, featureRowLevel, fromChkOrdrdQntty)
	 {
	 	if(divID)
	 	{
	 	var comboCheck = divID.slice(0,5);
    	if(fromChkOrdrdQntty != true )
    	{
			fromChkOrdrdQntty = false;    	
    	}
    	if(comboCheck == "combo" && fromChkOrdrdQntty == false)
    	{
    		updateTableColumnValuesForCombo(divID);
    		//checkOrderedQuantity(featureRowLevel+"OrderedQuantity", divID, featureRowLevel+"ExtPrice", featureRowLevel+"EachPrice", false);
    	}
	 	}
    	eraseLastResponse(true);
    	var dynamicEvaluation = false;
    	var bIsDynamic = true;
		var url="ProductRevisionResponse.jsp?randomCheckForIe=" +Math.random();
		var queryString = "dynamicEvaluation=" +dynamicEvaluation+ "&userSelectedFtrLstId=" +userSelectedFtrLstId+ "&featureSelectionList=" +featureSelectionList+ "&featureDeselectionList=" +featureDeselectionList+ "&bIsDynamic=" +bIsDynamic + "";
		/*var xmlDoc = emxUICore.getXMLDataPost(url, queryString);
		getResponse(xmlDoc, true);*/
		//calculateTotalPrice();
		
		featureSelectionList = [];
		featureDeselectionList = [];
		plainFeatureSelectionList = [];
 	}
 	
 	
 	function validate(divID, featureRowLevel, fromChkOrdrdQntty) 
    {	
    	    var check = contextMode;
    		fromChkOrdrdQntty = false;
    		isRuleValidationRequired = false;
    		var divId = divID;
    	if(divID)
    	{		//Added for Bug 371022 - To be checked when creating Product Variant
				if(!((contextMode=="2" && contextObjectType=="Model") || (contextMode=="1" && contextObjectType=="Hardware Product")|| (contextMode=="1" && contextObjectType=="Product Variant"))){
	 				isSiblingfeatureMandatory(divId);
	 				//Added for IR-022438V6R2011WIM - Include Standard sub feature in selected list
	 				isSubfeatureStandard(divId);
				}
				//End:Bug 371022
    	getSelectedId(divID);
    	}
    	var arr = new Array(plainFeatureSelectionList.length, featureDeselectionList.length);
    	var count = getMaximumLength(arr);
    	validate2(divID, featureRowLevel, fromChkOrdrdQntty);
    	
    }
	
    var dialogLayerOuterDiv, dialogLayerInnerDiv, objTable1, iframeEl;
    var isMaskAdded = false; 
    
    function addMask(strHdrMsg, strBodyMsg1, strBodyMsg2)
    {

    try{ 
    	if(!isMaskAdded) {
    	isMaskAdded = true ; 
        spanRowCounter = null;
        levelCounter = null;
        dialogLayerOuterDiv = document.createElement("div");
        dialogLayerOuterDiv.className = "mx_divLayerDialogMask";
        document.body.appendChild(dialogLayerOuterDiv);
       
        dialogLayerInnerDiv = document.createElement("div");
        dialogLayerInnerDiv.className = "mx_alert";
        dialogLayerInnerDiv.setAttribute("id", "mx_divLayerMaskDialog");
        
       dialogLayerInnerDiv.style.top = 140;
       dialogLayerInnerDiv.style.left = emxUICore.getWindowWidth()/3 + "px"; 
        
        document.body.appendChild(dialogLayerInnerDiv);
        
        var divLayerDialogHeader = document.createElement("div");
        divLayerDialogHeader.setAttribute("id", "mx_divLayerMaskDialogHeader");
        if(isIE) {
            divLayerDialogHeader.innerText = readFromStringResource(strHdrMsg);
        }else {
            divLayerDialogHeader.textContent = readFromStringResource(strHdrMsg);
        }
        
        var divLayerDialogBody = document.createElement("div");
        divLayerDialogBody.setAttribute("id", "mx_divLayerMaskDialogBody");
        
        var paraElement1 = document.createElement("p");
        if(isIE) {
            paraElement1.innerText = readFromStringResource(strBodyMsg1);
        }else {
            paraElement1.textContent = readFromStringResource(strBodyMsg1);
        }


        var paraElement2 = document.createElement("p");
        paraElement2.className = "mx_processing-message";

        if(isIE) {
            paraElement2.innerText = readFromStringResource(strBodyMsg2);
        }else {
            paraElement2.textContent = readFromStringResource(strBodyMsg2);
        }

        divLayerDialogBody.appendChild(paraElement1);
        divLayerDialogBody.appendChild(paraElement2);

        var divLayerDialogFooter = document.createElement("div");
        divLayerDialogFooter.setAttribute("id", "mx_divLayerMaskDialogFooter");

        objTable1 = document.createElement("table");
        objTable1.border = 0;
        objTable1.cellPadding = 0;
        objTable1.cellSpacing = 0;

        var objTBody = document.createElement("tbody");
        var objTR = document.createElement("tr");
        divLayerDialogFooter.appendChild(objTable1);
        objTable1.appendChild(objTBody);
        objTBody.appendChild(objTR);
		
        dialogLayerInnerDiv.appendChild(divLayerDialogHeader);
        dialogLayerInnerDiv.appendChild(divLayerDialogBody);
        dialogLayerInnerDiv.appendChild(divLayerDialogFooter);
        }
        }catch(exec ){
        	//alert(exec);
        }
    }
 function removeMask(){
		isMaskAdded = false; 
        document.body.removeChild(dialogLayerInnerDiv);
        document.body.removeChild(dialogLayerOuterDiv);   
 	}
	
	
 function retainVisualCue(divID, visualCueCheck)
 {
 	var target = document.getElementById(divID);
 	if(visualCueCheck == "errorIcon")
 		htmlText = "<img src=../common/images/iconStatusError.gif onmouseover=getY(event);displayOptionConflict('"+divID+"')>";
 	else
 		htmlText = "<img src=../common/images/iconStatusChanged.gif onmouseover=getY(event);displayOptionConflict('"+divID+"')>";
 	target.innerHTML = htmlText;
 }
	
function fnValidateConfiguration() 
 {
 	var dynamicEvaluation = true;
 	bIsDynamic = false;
	var url="ProductRevisionResponse.jsp?dynamicEvaluation=" +dynamicEvaluation+ "&featureSelectionList=" +featureSelectionList+ "&featureDeselectionList=" +featureDeselectionList+ "&bIsDynamic=" +bIsDynamic + "&randomCheckForIe=" +Math.random();
	var xmlDoc = emxUICore.getXMLData(url);
	var xmlObj=xmlDoc.documentElement;
	var name;
	var validationMsg = null;
	for(var j=0; j < xmlObj.childNodes.length; j++)
	{
		name = xmlObj.childNodes[j].nodeName;	
		if(name == "EcValidationMsg")
		{
			validationMsg = xmlObj.childNodes[j].getAttribute("validationMsg");
			if(validationMsg != "" && validationMsg != "null" )
			{
				var arr = new Array();
				arr = validationMsg.split("-con6ftr-");
				var stringToBei18ned = arr[0];
				var ftrName = arr[1];
				giveAlert(stringToBei18ned, ftrName);
			}
		}
	}	
	
	if(validationMsg == null || validationMsg == "" || validationMsg == "null")
	{
		 var AlertMsg;
		 getResponse(xmlDoc, false);
		 if(isValidConfiguration == "false")
		{
			AlertMsg = "PC_INVALID_MSG";
    
 		}
	     else
	    {
	        AlertMsg = "PC_VALID_MSG";
	    }
        giveAlert(AlertMsg);
	    isValidConfiguration = "true";
	    validationStatus = true;
	}
 
 }
	
 function checkPCValidationStatus()
 {
 	if(!validationStatus)
 	{
 		giveAlert("FIRST_VALIDATE_MSG");
 		return false;
 	}
 	else
 		return true;
 }
	

function geti18nedMessage(msg)
{
	var arr = new Array();
	arr = msg.split("-con6ftr-");
	var count = arr.length;
	var i18nedMessage = new Array();
	var stringToBei18ned;
	var temp;
	if(count > 1)
	{
		for(var k=0; k<count; k++)
		{
			if(k == 0 || k%2 == 0 )
			{
				temp = arr[k];
				i18nedMessage.push(temp);
				i18nedMessage.push(" ");
			}else{
				stringToBei18ned = arr[k];
				temp = readFromStringResource(stringToBei18ned);
				i18nedMessage.push(temp);
				i18nedMessage.push(" ");
			}
		}
	}else{
		stringToBei18ned = readFromStringResource(msg);
		i18nedMessage.push(stringToBei18ned);
	}

	return i18nedMessage.join("");
}
	
	
 function displayOptionConflict(divID)
	{
		var displayText = false;
		var dynamicEvaluation = false;
		var ruleExpression ;
		var visualCue ;
		var v ;
		var v1;
		var cnxtSnglLnMsg;
		var ruleType;
		var owner;
		var toName;
		var visualCueCheck;
		var bIsDynamic = false;
		var singleLineMsg = new Array();
		var visualCueForSLMsg = new Array();
		var url="ProductRevisionResponse.jsp?dynamicEvaluation=" +dynamicEvaluation+ "&featureSelectionList=" +featureSelectionList+ "&featureDeselectionList=" +featureDeselectionList+ "&bIsDynamic=" +bIsDynamic + "&randomCheckForIe=" +Math.random();
		var xmlDoc = emxUICore.getXMLData(url);
	    var xmlObj=xmlDoc.documentElement;
	    var tempRU;
	    var checkIfCombo;
	    var checkIfChooser;
	    var parentFtrLstId;
	    var selectElementId;
	    var selectElement;
	    var selectOptionFtrLstId;
	    var comboDivOwnerFromXML;
	    var tempMsg;
	    
		    checkIfCombo = divID.slice(0,8);
		    checkIfChooser = divID.slice(0, 7);
		    if(checkIfCombo == "comboDiv")
		    {
		 for(var j=0; j < xmlObj.childNodes.length; j++){
		    	
		    v1 = xmlObj.childNodes[j].nodeName;
		    arr = v1.split("-");
		    tempRU = arr[0];
		    	
		    		parentFtrLstId = divID.slice(8, divID.length+1);
		    		selectElementId = "comboElement"+parentFtrLstId;
		    		selectElement = document.getElementById(selectElementId);
		    		selectOptionFtrLstId = selectElement.value;
		    		if(selectOptionFtrLstId != "" && selectOptionFtrLstId != null)
		    		comboDivOwnerFromXML = "E"+parentFtrLstId+"c"+selectOptionFtrLstId;
		    		else if(comboOwnerForOptionConflict != "" && comboOwnerForOptionConflict != null)
		    			comboDivOwnerFromXML = "E"+parentFtrLstId+"c"+comboOwnerForOptionConflict;
		    		else{
		    		
		    			for(var i=0; i < selectElement.options.length; i++)
						{
							comboOwnerForOptionConflictAttribute = selectElement.options[i].getAttribute("comboOwnerForOptionConflict");
							if(comboOwnerForOptionConflictAttribute != null && comboOwnerForOptionConflictAttribute != "")
							{
								comboOwnerForOptionConflict = comboOwnerForOptionConflictAttribute
							}
						}
						comboDivOwnerFromXML = "E"+parentFtrLstId+"c"+comboOwnerForOptionConflict;
		    		}
		    		if(v1 != "EValidationMsg" && tempRU != "Ecproduct" && v1 != "script" && v1 != "#text")
		     		{
		     			visualCue = xmlObj.childNodes[j].getAttribute("visualCue");
						if( ( visualCue == "errorIcon" || visualCue == "changeIcon") && v1 != comboDivOwnerFromXML ) 
						{
							a = xmlObj.childNodes[j].getAttribute("singleLineMsg");
							tempMsg = geti18nedMessage(a);
		 					singleLineMsg.push(tempMsg);
		 					visualCueForSLMsg.push(visualCue);
						}
						if(v1 == comboDivOwnerFromXML)
					 	{
		    				displayText = true;
		    				ruleExpression = xmlObj.childNodes[j].getAttribute("ruleExpression");
		    				var ruleExpressionArray = new Array();
		    				ruleExpressionArray = ruleExpression.split("~");
		    				ruleExpression = ruleExpressionArray.join("~ ");
		    				
		        			cnxtSnglLnMsg = xmlObj.childNodes[j].getAttribute("singleLineMsg");
		        			cnxtSnglLnMsg = geti18nedMessage(cnxtSnglLnMsg);
		        			
		        			
		    				ruleType = xmlObj.childNodes[j].getAttribute("ruleType");
		    				owner = xmlObj.childNodes[j].getAttribute("owner");
		    				toName = xmlObj.childNodes[j].getAttribute("toName");
		    				if(visualCue == "errorIcon" || visualCue == "")
		    					visualCueCheck = "errorIcon";
		    				else
		    					visualCueCheck = "changeIcon";
				 		}
		     		}
		    	}
		    }else if(checkIfChooser == "chooser")
		    {
		    
		    	for(var j=0; j < xmlObj.childNodes.length; j++)
		    	{
		    		v1 = xmlObj.childNodes[j].nodeName;
		    		arr = v1.split("-");
		   			tempRU = arr[0];
		    	
		    		parentFtrLstId = divID.slice(10, divID.length+1);
		    		selectElementId = "chooserElement"+parentFtrLstId;
		    		selectElement = document.getElementById(selectElementId);
		    		var liElementId = selectElement.getAttribute("currentSelectionLiId")
		    		var liElement = document.getElementById(liElementId);
		    		if(liElement)
		    		{
		    			selectOptionFtrLstId = liElement.getAttribute("ftrlstid");
		    		}
		    		if(selectOptionFtrLstId != "" && selectOptionFtrLstId != null)
		    		{
		    			comboDivOwnerFromXML = "E"+parentFtrLstId+"c"+selectOptionFtrLstId;
		    		}else{
		    			selectOptionFtrLstId = selectElement.getAttribute("lastSelectionFtrlstId");
		    			comboDivOwnerFromXML = "E"+parentFtrLstId+"c"+selectOptionFtrLstId;
		    		}
		    		
		    		if(v1 != "EValidationMsg" && tempRU != "Ecproduct" && v1 != "script" && v1 != "#text")
		     		{
		     			visualCue = xmlObj.childNodes[j].getAttribute("visualCue");
						if( ( visualCue == "errorIcon" || visualCue == "changeIcon") && v1 != comboDivOwnerFromXML ) 
						{
							a = xmlObj.childNodes[j].getAttribute("singleLineMsg");
							tempMsg = geti18nedMessage(a);
		 					singleLineMsg.push(tempMsg);
		 					visualCueForSLMsg.push(visualCue);
		    }
						if(v1 == comboDivOwnerFromXML)
					 	{
		    				displayText = true;
		    				ruleExpression = xmlObj.childNodes[j].getAttribute("ruleExpression");
		    				var ruleExpressionArray = new Array();
		    				ruleExpressionArray = ruleExpression.split("~");
		    				ruleExpression = ruleExpressionArray.join("~ ");
		    				
		        			cnxtSnglLnMsg = xmlObj.childNodes[j].getAttribute("singleLineMsg");
		        			cnxtSnglLnMsg = geti18nedMessage(cnxtSnglLnMsg);
		        			
		        			
		    				ruleType = xmlObj.childNodes[j].getAttribute("ruleType");
		    				owner = xmlObj.childNodes[j].getAttribute("owner");
		    				toName = xmlObj.childNodes[j].getAttribute("toName");
		    				if(visualCue == "errorIcon" || visualCue == "")
		    					visualCueCheck = "errorIcon";
		    else
		    					visualCueCheck = "changeIcon";
				 		}
		     		}
		    	}
		    }else
		    {	
		    	for(var j=0; j < xmlObj.childNodes.length; j++){
		    	
		   	 		v1 = xmlObj.childNodes[j].nodeName;
		    		arr = v1.split("-");
		    		tempRU = arr[0];
		    		
		     if(v1 != "EValidationMsg" && tempRU != "Ecproduct" && v1 != "script" && v1 != "#text")
		     {
		     	visualCue = xmlObj.childNodes[j].getAttribute("visualCue");
				if( ( visualCue == "errorIcon" || visualCue == "changeIcon") && v1 != divID ) 
				{
				
					a = xmlObj.childNodes[j].getAttribute("singleLineMsg");
					tempMsg = geti18nedMessage(a);
 					singleLineMsg.push(tempMsg);
		 			visualCueForSLMsg.push(visualCue);
				}
				if(v1 == divID)
				 {
		    		displayText = true;
		    		ruleExpression = xmlObj.childNodes[j].getAttribute("ruleExpression");
		    		var ruleExpressionArray = new Array();
		    		ruleExpressionArray = ruleExpression.split("~");
		    		ruleExpression = ruleExpressionArray.join("~ ");
		    		
		        	//cnxtSnglLnMsg = xmlObj.childNodes[j].getAttribute("singleLineMsg");
		        	cnxtSnglLnMsg = xmlObj.childNodes[j].getAttribute("singleLineMsg");
		        	cnxtSnglLnMsg = geti18nedMessage(cnxtSnglLnMsg);
		        	
		        	
		    		ruleType = xmlObj.childNodes[j].getAttribute("ruleType");
		    		owner = xmlObj.childNodes[j].getAttribute("owner");
		    		toName = xmlObj.childNodes[j].getAttribute("toName");
		    				if(visualCue == "errorIcon" || visualCue == "")
		    			visualCueCheck = "errorIcon";
		    		else
		    			visualCueCheck = "changeIcon";
				 }
		     }
		     	}
		 }
		
		var target = document.getElementById(divID);
		var optionConflictResponseArr = new Array();
		var optionConflictResponse;
		if(displayText == true)
		{
			var img;
			var arr = new Array();
			if(visualCueCheck == "errorIcon")
				img = "\"../common/images/iconStatusError.gif\"";
			else
				img = "\"../common/images/iconStatusChanged.gif\"";
				
			arr = ruleType.split(" ");
			type = arr[0];
			if(type == "BooleanCompatibilityRule")
				ruleImg = "\"../common/images/iconSmallBooleanCompatibilityRule.gif\"";
			else
				ruleImg = "\"../common/images/iconSmallRule.gif\"";
			
			var locallayerDialogTop = "";
	/*		if(layerDialogBottom && layerDialogBottom >= 0 && layerDialogBottom <= LD_HEIGHT)
			{
				locallayerDialogTop = cursorY - LD_TOP_CORRECTION;
				if(locallayerDialogTop < 0)
			{
					locallayerDialogTop = 2;
				}
			}else{
				locallayerDialogTop = "";
			}*/
			
       	 	optionConflictResponseArr.push("<iframe id=\"forIE6z-indexingIssue\" style=\"z-index: 0; width: 302px; height: 240px; position: absolute; left: 12px; display: inline; top: "+locallayerDialogTop+"; visibility: hidden;\" frameborder=0 scrolling=no marginwidth=0 src=\"\" marginheight=0></iframe><html><head><title>Option Conflict Dialog Layer</title></head><body><div id=\"mx_divLayerDialog\" style=\" top:"+locallayerDialogTop+"; \" class=\"\">"+
       	 		"<div id=\"mx_divLayerDialogHeader\">" +
            	"<table cellspacing=\"0\" cellpadding=\"0\" border=\"0\"><tbody><tr><td class=\"title\">Option Conflict</td>"+
            	"<td class=\"buttons\"><a class=\"button cancel\" onclick=retainVisualCue('"+divID+"','"+visualCueCheck+"') /></td></tr></tbody></table></div>"+
            	"<div id=\"mx_divLayerDialogBody\">" +
            	"<table cellspacing=\"0\" cellpadding=\"0\" border=\"0\"><tbody><tr><td><p align=left>Your last option selection has affected other option selections. Please review the affected items below:</p></td></tr></tbody></table>"+
            	"<div class=\"mx_all_option_detail\" >"+
				"<div class=\"mx_option-detail context\"><table><tr>"+
				"<td><img src="+img+"></td><td>"+
				"<span class=\"mx_field-headName\">"+cnxtSnglLnMsg+"</span></td></tr><tr><td class=\"mx_spacer-cell level-1\"></td></tr>"+
				"<tr><td class=\"mx_spacer-cell level-2\"></td><td><table><tr><td><img src="+ruleImg+"></td>"+
				"<td><span class=\"mx_field-headName\">"+ruleType+"</span></td></tr><tr><td class=\"mx_spacer-cell level-1\"></td></tr>"+
				"<tr><td></td><td><span class=\"mx_field-headName\">Context :</span></td></tr>"+
				"<tr><td></td><td>"+toName+"</td></tr>"+
				"<tr><td></td><td><span class=\"mx_field-headName\">Rule :</span></td></tr>"+
				"<tr><td></td><td>"+ruleExpression+"</td></tr>"+
				"<tr><td></td><td><span class=\"mx_field-headName\">Owner :</span></td></tr>"+
				"<tr><td></td><td>"+owner+"</td></tr></table></td></tr></table></div>");
            	
            	for(var l=1; l <= singleLineMsg.length; l++)
            	{
            		s = singleLineMsg.pop();
            		v = visualCueForSLMsg.pop();
            	
            		if(v == "errorIcon")
						img = "\"../common/images/iconStatusError.gif\"";
					else
						img = "\"../common/images/iconStatusChanged.gif\"";
            	
            		optionConflictResponseArr.push("<div class=\"mx_option-detail\"><table><tr><td><img src="+img+"></td><td><span class=\"mx_field-name\">"+ s +"</span> " +
            		"</td></tr></table></div>");
            	}
            	
            	optionConflictResponseArr.push("</div></div><div id=\"mx_divLayerDialogFooter\">&#160;</div></div></body></html>");
            	
            	optionConflictResponse = optionConflictResponseArr.join("");
            	
			target.innerHTML = optionConflictResponse; 
		
		}
	
	}
	

var LD_TOP_CORRECTION = 300;
var LD_HEIGHT = 270;

var layerDialogBottom;
var cursorY;

function getY(e)
{
	cursorY = (window.Event) ? e.pageY : event.clientY;
	var windowY;
	if (parseInt(navigator.appVersion)>3) 
	{
		 if (navigator.appName=="Netscape") 
		 {
	windowY = window.innerHeight;
		 }
		 if (navigator.appName.indexOf("Microsoft")!=-1) 
		 {
			  windowY = document.body.offsetHeight + 40;
		 }
	}
	layerDialogBottom = (windowY - cursorY);
}
	
function inputNumberCheck (str, dec, bNeg)
		{ 
			// auto-correct input - force numeric data based on params.
			 var cDec = '.'; // decimal point symbol
			var bDec = false; var val = "";
			var strf = ""; var neg = ""; var i = 0;

			if (str == "") return;
			 parseFloat ("0").toFixed (dec);
			 if (bNeg && str.charAt (i) == '-') 
			 {
				neg = '-'; i++; 
			 }

			 for (i; i < str.length; i++)
			 {
				  val = str.charAt (i);
				  if (val == cDec)
				 {
					if (!bDec) 
					{ 
						strf += val; bDec = true; 
					}
				 }
				 else if (val >= '0' && val <= '9')
					 strf += val;
			}

			if(strf.length == 0 && dec == 0)
				giveAlert("ENT_INT_MSG");
			else if(strf.length == 0 && dec == 2)
				giveAlert("ENT_DEC_MSG");
		    strf = (strf == "" ? 0 : neg + strf);
		 return parseFloat (strf).toFixed (dec);
	  } 

// added for filter layer dialog

function toggleVisibilityOfFilterLayerDialog(ChooserLayerDialogDivId, visibilityFlag, iFrameId)
{	
	var temp = document.getElementById(ChooserLayerDialogDivId);
	var iFrame = document.getElementById(iFrameId);
	var div = temp.parentNode;
	
	var locallayerDialogTop = "";
/*	if(layerDialogBottom && layerDialogBottom >= 0 && layerDialogBottom <= LD_HEIGHT)
	{
		locallayerDialogTop = cursorY - LD_TOP_CORRECTION;
		if(locallayerDialogTop < 0)
		{
			locallayerDialogTop = 2;
		}
	}else{
		locallayerDialogTop = "";
	}*/
	
	if(div)
	{
		if(visibilityFlag)
		{
			div.style.top = locallayerDialogTop;
			iFrame.style.top= locallayerDialogTop;
			div.style.visibility = "visible";
			iFrame.style.visibility = "visible";
		}else{
			div.style.visibility = "hidden";
			iFrame.style.visibility = "hidden";
		}
	}		
}

var lastSelectedLi;
function makeOptionSelectionFromFilter(li)
{
	var  divID = li.parentNode.id;
	var mandatoryExists=false;
		var listElem =  document.getElementById("chooserLayerUL"+divID.split("chooserLayerUL")[1]);
		for (i=0;  i<listElem.childNodes.length; i++){
			if (listElem.childNodes[i].nodeName=="LI"){
				var chldNode = "";
				if(isIE){
					chldNode = listElem.childNodes[i].getAttribute("usage");
				}else{
					chldNode = listElem.childNodes[i].attributes["usage"].value;
				}
				
				
				if(chldNode == "Mandatory"){
					mandatoryExists = true;
					lastSelectedLi = listElem.childNodes[i];
					listElem.childNodes[i].setAttribute("class","selected");
					listElem.childNodes[i].className = "selected";
					listElem.childNodes[i].style.border = "0.04px solid #555555";
				}else{
					//listElem.childNodes[i].class = "";
					listElem.childNodes[i].setAttribute("class","");
					listElem.childNodes[i].className = "";
				}				
			}
		}		
		if(mandatoryExists){
			alert("<emxUtil:i18nScript localize=\"i18nId\">emxProduct.Alert.AlreadyMand</emxUtil:i18nScript>");
		}
		else{
			if(lastSelectedLi)
			{
				lastSelectedLi.setAttribute("class","");
				lastSelectedLi.className = "";
				lastSelectedLi.style.border = "";
			}else{
				var ul = li.parentNode;
				var defaultSelectedLiId = ul.getAttribute("defaultLiId");
				if(defaultSelectedLiId)
				{
					var defaultSelectedLi = document.getElementById(defaultSelectedLiId);
					if(defaultSelectedLi)
					{
						defaultSelectedLi.setAttribute("class","");
						defaultSelectedLi.className = "";
						defaultSelectedLi.style.border = "";
					}
				}
			}
			
			
			
			li.setAttribute("class","selected");
			li.className = "selected";
			li.style.border = "0.04px solid #555555";
			
			lastSelectedLi = li;
		}
	
	
}

function updateTableColumnValuesForChooser(chooserFtrElementId, lastSelectedLi2)
{
	var strUsage = "";
	var inputElement = document.getElementById(chooserFtrElementId);
	var ftrName = lastSelectedLi2.innerHTML;
	inputElement.value = ftrName;
	var featureRowLevel = inputElement.getAttribute("featureRowLevel");
	var selectedFtrLstId = lastSelectedLi2.getAttribute("ftrlstid");
	var selectedLiId = lastSelectedLi2.getAttribute("id");
	var varUsage = featureRowLevel+"Usage";
	strUsage = lastSelectedLi2.getAttribute("Usage");
	
	var lastSelectionLiId = inputElement.getAttribute("currentSelectionLiId");
	if(lastSelectionLiId)
	{
		var lastSelectionLi = document.getElementById(lastSelectionLiId);
		if(lastSelectionLi)
		{
			var lastSelectionFtrlstId = lastSelectionLi.getAttribute("ftrlstid");
			inputElement.setAttribute("lastSelectionFtrlstId", lastSelectionFtrlstId);
		}
	}
	inputElement.setAttribute("currentSelectionLiId", selectedLiId);
	var target = document.getElementById(strUsage);
	var htmlText;
	if(target != null)
	{
		target.value = strUsage;
	}
	var selectionType = "";
	selectionType = lastSelectedLi2.getAttribute("selectionType");
	var parentFtrLstId = chooserFtrElementId.slice(14,chooserFtrElementId.length);
        var infoDivId = "info"+parentFtrLstId;
    	target = document.getElementById(infoDivId);
	if(target != null)
	{
		htmlText = "<a class=\"mx_button-info\" href=\"javascript:fnloadHelp('"+selectedFtrLstId+"')\" border=\"0\"></a>";
		target.innerHTML = htmlText;
	}

}


function updateSelectedOptionFromFilter(chooserFtrElementId, chooserLayerDialogDivId, visibilityFlag, iFrameId)
{
	updateTableColumnValuesForChooser(chooserFtrElementId, lastSelectedLi);
	var parentFtrLstId = chooserFtrElementId.slice(14,chooserFtrElementId.length);
	var inputElement = document.getElementById(chooserFtrElementId);
	var featureRowLevel = inputElement.getAttribute("featureRowLevel");
	var selectedFtrLstId = lastSelectedLi.getAttribute("ftrlstid");
	
	toggleVisibilityOfFilterLayerDialog(chooserLayerDialogDivId, visibilityFlag, iFrameId);
	validate("chooserElName"+parentFtrLstId, featureRowLevel);
	// Commented for IR Mx375107
	//checkOrderedQuantity(featureRowLevel+"OrderedQuantity", chooserFtrElementId, featureRowLevel+"ExtPrice", featureRowLevel+"EachPrice", false, featureRowLevel+"li"+selectedFtrLstId);
}


var dummyLiArray = new Array();
var dummyfilterInputElement;
function performFilterAction(filterInputElementId, ulId)
{
	var ul = document.getElementById(ulId);
	var filterInputElement = document.getElementById(filterInputElementId);
	var filterCriteria = filterInputElement.value;
	var liList = ul.childNodes;
	var filteredList = new Array();
	var ftrName;
	var hasStarAtEnd = false;
	var hasStarAtStart = false;
	
	if(dummyfilterInputElement)
	{
		if(dummyfilterInputElement != filterInputElement)
		{
			dummyLiArray = [];
			for(var i=0; i<liList.length; i++)
			{
				var new_element = document.createElement('li');
				new_element = liList[i];
				dummyLiArray.push(new_element);
			}
		}else{
			if(liList.length > dummyLiArray.length){
				dummyLiArray = [];
				for(var i=0; i<liList.length; i++)
				{
					var new_element = document.createElement('li');
					new_element = liList[i];
					dummyLiArray.push(new_element);
				}
			}
		}
	}else{
		for(var i=0; i<liList.length; i++)
		{
			var new_element = document.createElement('li');
			new_element = liList[i];
			dummyLiArray.push(new_element);
		}
	}
	
	dummyfilterInputElement = filterInputElement;
	
	if((filterCriteria.slice(filterCriteria.length-1, filterCriteria.length)) == "*")
	{
		hasStarAtEnd = true;
		filterCriteria = filterCriteria.slice(0, filterCriteria.length-1)
	}
	if((filterCriteria.slice(0, 1)) == "*")
	{
		hasStarAtStart = true;
		filterCriteria = filterCriteria.slice(1, filterCriteria.length)
	}
	
	var isFirstIteration;
	var temp;
	if(hasStarAtEnd && !hasStarAtStart)
	{
		isFirstIteration = true;
			if(isFirstIteration)
			{
				for(var i=0; i<dummyLiArray.length; i++)
				{
					ftrName = dummyLiArray[i].innerHTML;
				temp = ftrName.slice(0, filterCriteria.length);
					if(temp == filterCriteria)
					{
						filteredList.push(dummyLiArray[i]);
					}
				}
				isFirstIteration = false;
			}else{
				for(var i=0; i<liList.length; i++)
				{
					ftrName = liList[i].innerHTML;
				temp = ftrName.slice(0, filterCriteria.length);
					if(temp == filterCriteria)
					{
						filteredList.push(liList[i]);
					}
				}
			}
	}else if(hasStarAtStart && !hasStarAtEnd){
		isFirstIteration = true;
		if(isFirstIteration)
		{
			for(var i=0; i<dummyLiArray.length; i++)
			{
				ftrName = dummyLiArray[i].innerHTML;
				temp = ftrName.slice((ftrName.length-filterCriteria.length), ftrName.length);
				if(temp == filterCriteria)
			{
					filteredList.push(dummyLiArray[i]);
				}
			}
			isFirstIteration = false;
			}else{
			for(var i=0; i<liList.length; i++)
			{
				ftrName = liList[i].innerHTML;
				temp = ftrName.slice(filterCriteria.length, ftrName.length);
				if(temp == filterCriteria)
				{
					filteredList.push(liList[i]);
				}
			}
			}
	}else if(hasStarAtStart && hasStarAtEnd){
		isFirstIteration = true;
		if(isFirstIteration)
		{
			for(var i=0; i<dummyLiArray.length; i++)
			{
				ftrName = dummyLiArray[i].innerHTML;
				temp = ftrName.indexOf(filterCriteria);
				if(temp != -1)
			{
					filteredList.push(dummyLiArray[i]);
				}
			}
			isFirstIteration = false;
			}else{
				for(var i=0; i<liList.length; i++)
				{
				ftrName = liList[i].innerHTML;
				temp = ftrName.indexOf(filterCriteria);
				if(temp != -1)
				{
					filteredList.push(liList[i]);
				}
			}
		}		
	}else{
		for(var i=0; i<dummyLiArray.length; i++)
		{
			ftrName = dummyLiArray[i].innerHTML;
			if(ftrName == filterCriteria)
			{
				filteredList.push(dummyLiArray[i]);
			}
		}
		
	}
	
		var tempLi;
		var liId;
		for(var k=0; k<dummyLiArray.length; k++)
		{
			tempLi = dummyLiArray[k];
			liId = tempLi.getAttribute("id");
			tempLi = document.getElementById(liId);
			if(tempLi)
			{
				ul.removeChild(tempLi);
			}
		}
	
	for(var j=0; j<filteredList.length; j++)
	{
		if(ul.firstChild){
			var obj = ul.lastChild;
			ul.insertBefore(filteredList[j], obj.nextSibling);
		}else{
			ul.insertBefore(filteredList[j], ul.firstChild);
		}
	}
	
}
function loadProductEffectivity(productEffectivityId)
 {
 	var url="ProductRevisionResponse.jsp?mode=editOptionsAfterMask&productEffectivityId="+productEffectivityId;
 	var vres = emxUICore.getData(url);
 	var target = document.getElementById("editResponse");
	target.innerHTML = vres;
	removeMask();
 }
 //For Bug 371022 - To check whether any other feature in the group is already set to mandatory.
 function isSiblingfeatureMandatory(divID){
 
 	var mandatoryExists=false;
 	var selectedDiv = document.getElementById(divID);
		// Added condition for IR Mx375107
 	if(selectedDiv){
 		var groupName = selectedDiv.getAttribute("groupName");
 	    var groupElements = document.getElementsByName(groupName);
 	    var flag;
 	    var flag1;
 	    var divID;
 	    for(var count=0; count<groupElements.length; count++)
 			{
 				var groupElement = groupElements[count];
 				flag = groupElement.defaultChecked;
 				flag1 = groupElement.disabled;
 	// Modified to 
 				var grType =groupElement.type; 
 				if(flag == true && flag1== true && grType != "checkbox"){
 					mandatoryExists = true;
 					alert("<emxUtil:i18nScript localize=\"i18nId\">emxProduct.Alert.AlreadyMand</emxUtil:i18nScript>");
 					groupElement.checked=true;
 					divID = count+1;
 					break;
 				}	
 			}
 	}
 	else{ 		
 		var listElem =  document.getElementById("chooserLayerUL"+divID.split("chooserElName")[1]);
 		for (i=0; listElem!= null && i<listElem.childNodes.length; i++){
	 			if (listElem.childNodes[i].nodeName=="LI"){
	 				if(listElem.childNodes[i].attributes["usage"].value == "Mandatory"){
						listElem.childNodes[i].setAttribute("class","selected");
						listElem.childNodes[i].className = "selected";
	 					if(listElem.childNodes[i].className != "selected" || listElem.childNodes[i].getAttribute("class") != "selected"){
	 						mandatoryExists = true;
	 	 					makeOptionSelectionFromFilter(listElem.childNodes[i]);
	 					} 	 					
	 				}else{
					listElem.childNodes[i].setAttribute("class","");
					listElem.childNodes[i].className = "";
	 				} 				
	 			}
	 		}
 		if(mandatoryExists){
				alert("<emxUtil:i18nScript localize=\"i18nId\">emxProduct.Alert.AlreadyMand</emxUtil:i18nScript>");
			}
 	}
   return divID.toString();
 }
//Added for Bug 373505:To select mandatory features into featureSelectionList --  Modified for  IR-022438V6R2011WIM
var selectedFtrLstIds = new Array();
var selectedSubFtrLstIds = new Array();
function selectMandatoryFeature(divID){
	var selectedDiv = document.getElementById(divID);
	var ftrLstId = selectedDiv.getAttribute("ftrLstId");
	selectedFtrLstIds.push(ftrLstId);
	var isMandatory =false;
	while(true)
	{
		var id = ++divID ;
		var divElement = "";
		var divElement = document.getElementById(id);
		if(divElement == null)
			id = ++divID ;
		divElement = document.getElementById(id);
	    if(divElement)
		{
		 var innerHTMLId = divElement.getAttribute("innerHTMLId");
		 var arr = innerHTMLId.split("c");
		 var parentFtrLstId = arr[0];
		 var FLId = arr[1];
		 var optElem = document.getElementById(innerHTMLId);
		 
		 var groupName = divElement.getAttribute("groupName");
		 var groupElements = document.getElementsByName(groupName);
		 var isSubFeature = false;
		 var selectDivGName= selectedDiv.getAttribute("groupName");
		 var divElemDivname= divElement.getAttribute("groupName");
		 var subFLId = "";
		 for(var j=0; j<groupElements.length && (selectDivGName != divElemDivname); j++)
	   	  {			 
			 optElem = groupElements[j];
			 id = optElem.parentNode.id;
			 var arrId = optElem.id.split("c");
			 var parentFtrLstId_1 = arrId[0];
			 var FLId_1 = arrId[1];
			 //if(optElem.checked )
			     //isMandatory=true;	
			 for(var i=0; i<selectedFtrLstIds.length; i++)
		   	  {
		    	ftrLstId = selectedFtrLstIds[i];
			 	if(optElem.checked && parentFtrLstId_1 == ftrLstId)
			 	{
					if(subFLId == ""){
						subFLId = FLId_1+"<<"+id;
					}else if(subFLId.indexOf(id)==-1){
						subFLId = subFLId+"??"+FLId_1+"<<"+id;
					}
			 	}
		   	  }
	   	  }
		 
		 //var isChecked = document.getElementById(innerHTMLId).checked;
		 //var isDisabled = document.getElementById(innerHTMLId).disabled;
		 //if(isChecked)
		  //   isMandatory=true;	 
		//var isSubFeature = false;	 
	   	 //for(var i=0; i<selectedFtrLstIds.length; i++)
	   	  //{
	    //		ftrLstId = selectedFtrLstIds[i];
		// 	if(parentFtrLstId == ftrLstId)
		// 	{
	     //    	isSubFeature = true;
		//		break;
		// 	}
		//}
		 if(subFLId != ""){
			 var FLidArr = subFLId.split("??");
			 for(var j=0; j<FLidArr.length ; j++)
		   	  {	
				 var idArr = FLidArr[j].split("<<");
				 if(featureSelectionList.find(idArr[0]) == -1){
					 featureSelectionList.push(idArr[0]);
					 plainFeatureSelectionList.push(idArr[0]);
					 selectMandatoryFeature(idArr[1]);
				 }
		   	  }
		 }else
			 break;
		//if(isSubFeature == true && isMandatory)
		//{
	    //	featureSelectionList.push(FLId);
	    //	plainFeatureSelectionList.push(FLId);
	    //	selectMandatoryFeature(id);
		//}
		//else 
		 //  break;
	  }else
	    break;
	}
	selectedFtrLstIds =[];
}
//Added for IR-022438V6R2011WIM - Include Standard sub feature in selected list
function isSubfeatureStandard(divID){
	 
 	var mandatoryExists=false;
 	var isParentSelected = false;
 	var selectedDiv = document.getElementById(divID);
		// Added condition for IR Mx375107
 	if(selectedDiv){
 		//Increment divid to get all subfeature of selected Feature for satandard check
 		var id = ++divID ;
 		var grouElemDiv = document.getElementById(id);
 		var groupName = selectedDiv.getAttribute("groupName");
 		if(grouElemDiv != null)
		{
 			groupName = grouElemDiv.getAttribute("groupName");
		}
 		//Begin:IR-059095V6R2011x:Checking if the features immediate parent is selected or not.
 		var  parentDivId;
 		while(divID >= 0){
 			parentDivId = -- divID;
 			var parentDiv = document.getElementById(parentDivId);
 			if(parentDiv!=null && parentDiv!='undefined'){
 			var pGroupName = parentDiv.getAttribute("groupName");
 			if(pGroupName != groupName)
 			{
 		    	var innerHTMLId = parentDiv.getAttribute("innerHTMLId");
 		    	var parentElement = document.getElementById(innerHTMLId);
 		    	var isChecked = document.getElementById(innerHTMLId).checked;
 		    	if(isChecked)
 		    	{
 		   		isParentSelected = true;
 		    		
 		    	}	
 		    	break;	
 		}
 			}
 		}
 		//End:IR-059095V6R2011x:Checking if the features immediate parent is selected/checked or not.		
 	    var groupElements = document.getElementsByName(groupName);
 	    var flag;
 	    var flag1;
 	    var divID;
 	    for(var count=0; count<groupElements.length; count++)
 			{
 				var groupElement = groupElements[count];
 				flag = groupElement.defaultChecked;
 				flag1 = groupElement.checked;
 				if(flag == true && flag1 == true)
 				{
 					var arrId = groupElement.id.split("c");
 					var parentFtrLstId_1 = arrId[0];
 					var FLId_1 = arrId[1];
 				//IR-059095V6R2011x:Adding the standard feature to featureSelectionList only when its parent is selected/checked.					
 					if(isParentSelected){                     
 			    	featureSelectionList.push(FLId_1);
 			    	plainFeatureSelectionList.push(FLId_1);
 					}

 			    	selectMandatoryFeature(groupElement.parentNode.id);
 				}
 			}
 	}
}
//End : Added for Bug 373505:To select mandatory features into featureSelectionList
