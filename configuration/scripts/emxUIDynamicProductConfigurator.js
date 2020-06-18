 
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
// static const char RCSID[] = $Id: /ENOVariantConfigurationBase/CNext/webroot/configuration/scripts/emxUIDynamicProductConfigurator.js 1.37.2.5.1.1 Wed Oct 29 22:27:16 2008 GMT przemek Experimental$
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
var strExcludeListMPR;
var ruleEvaluationMembersList = new Array(); // it will carry all the rule evaluation member ids.
var scrOfX = 0;
var scrOfY = 0;
//var optionObj;   // to avoid the performance issues for combo


// this method remove the rows from featrueOptions table of Product Configuration
function removeAddedRows(optionId)
{
	var url="ProductConfigurationDBChooser.jsp?mode=remove&FeatureId="+optionId;
	var html = emxUICore.getData(url);
	var mainDiv = document.getElementById("mx_divBody");
	mainDiv.innerHTML = html;
}

function removeDBChooserRows(optionId,parentId)
{
	var url="ProductConfigurationDBChooser.jsp?mode=remove&FeatureId="+optionId+"&parentFeatureId="+parentId;
	//var html = emxUICore.getData(url);
	
	var urlXML = "ProductConfigurationResponse.jsp?mode=editOptions&randomCheckForIe=" +Math.random();
	var urlXSL = "ProductConfigurationDisplay.xsl";
	//var xmlDOM = emxUICore.getXMLDataPost(urlXML); 
	var xmlDOM = emxUICore.getXMLDataPost(url);
	var xslDOM = emxUICore.getXMLDataPost(urlXSL);
	// code for IE
	if (window.ActiveXObject)
	{
		ex=xml.transformNode(xslDOM);
		document.getElementById("mx_divBody").innerHTML=ex;
	}
	// code for Mozilla, Firefox, Opera, etc.
	else if (document.implementation && document.implementation.createDocument)
	{
	  xsltProcessor = new XSLTProcessor();
	  xsltProcessor.importStylesheet(xslDOM);

	  resultDocument = xsltProcessor.transformToDocument(xmlDOM);
	  
	  document.getElementById("mx_divBody").innerHTML = resultDocument.xml;
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
		
		var ordrdQntty = newRow.getAttribute("ordrdQntty");
		var ftrLstId = newRow.getAttribute("ftrLstId");
		//featureSelectionList.push(ordrdQntty);
		featureSelectionList.push(ftrLstId);
		plainFeatureSelectionList.push(ftrLstId);
		
		// make the parent radio or checkBox checked.
		//Modified for IE7 issue 360072
		if(parentElmntDiv!=null && parentElmntDiv!='undefined'){
    			var parentElmntDiv = document.getElementById(featureRowDisplayLevel);
    			var innerHTMLId = parentElmntDiv.getAttribute("innerHTMLId");
    	   		var selectedElement = document.getElementById(innerHTMLId);
    			selectedElement.checked = "checked";
    		}
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



// this method updates the ordered quantity for each selected or deselected option accordingly. This is not for combo features.
function updateOrderedQuantity(featureRowLevel, orderedQuantity, isSelected)
{
	var orderedQnttyElement = document.getElementById(featureRowLevel+"OrderedQuantity");
	var eachPriceElement = document.getElementById(featureRowLevel+"EachPrice");
	var extPriceElement = document.getElementById(featureRowLevel+"ExtPrice");
	
	if(isSelected)
	{
		if(orderedQnttyElement)
		{
			var elementType = orderedQnttyElement.type;
			if(elementType != "text") // means it is an anchor
				orderedQnttyElement.innerHTML = orderedQuantity; // update the ordered quantity 
			else  // means it is a text element
				orderedQnttyElement.value = orderedQuantity;
				
			nOQntty = orderedQnttyElement.value;
			if(nOQntty == null || nOQntty == "")
				nOQntty = orderedQnttyElement.innerHTML;
			nOQntty = parseFloat(nOQntty);
			nEach = parseFloat(eachPriceElement.value);
			extPriceElement.value = nOQntty * nEach; 				
			calculateTotalPrice();				
		}
	}
	else
	{
		if(orderedQnttyElement)
		{
			var elementType = orderedQnttyElement.type;
			if(elementType != "text") // means it is an anchor
				orderedQnttyElement.innerHTML = "0.0"; // update the ordered quantity 
			else  // means it is a text element
				orderedQnttyElement.value = "0.0";
				
			nOQntty = orderedQnttyElement.value;
			if(nOQntty == null || nOQntty == "")
				nOQntty = orderedQnttyElement.innerHTML;
			nOQntty = parseFloat(nOQntty);
			nEach = parseFloat(eachPriceElement.value);
			extPriceElement.value = nOQntty * nEach; 		
			calculateTotalPrice();		
		}
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
		//keyInMemberList += "-";
		//Modified for  IR: Mx376489   
		keyInMemberList += "|";	
		
		if(keyInValue == null || keyInValue == " " || keyInValue == "")
			{
			  keyInMemberList += "Empty";
			}
		else
			{
			  keyInMemberList += keyInValue;
			}

		if(i != keyInMemberRows.length - 1)
			{
			    // keyInMemberList += "-";
				//Modified for  IR: Mx376489   
				keyInMemberList += "|";
			}
    	}
		
		
	}
	var isForKeyIn = true;
	var url="ProductConfigurationResponse.jsp?isForKeyIn=" +isForKeyIn+ "&keyInMemberList=" +keyInMemberList + "&randomCheckForIe=" +Math.random();
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

function updateOrderedQuantityAttribute(ftrLstId, ordrdQntty)
{
	var isForOrderedQntty = true;
	var url="ProductConfigurationResponse.jsp?isForOrderedQntty=" +isForOrderedQntty+ "&ftrLstId=" +ftrLstId + "&ordrdQntty=" +ordrdQntty + "&randomCheckForIe=" +Math.random();
	var html = emxUICore.getData(url);
	var bodyDiv = document.getElementById("mx_divBody");
	if(bodyDiv)
		bodyDiv.innerHTML = html;
	calculateTotalPrice();			
	return;
}

function checkOrderedQuantity(inputQtyElementId, divId, inputExtPriceElementId, inputEachPriceElementId, isFromUI,liId)
{	
	var maximumQuantity = "";
	var minimumQuantity = "";
	var extPriceElement;
	if(liId)
	{
		var inputElement = document.getElementById(divId);
		var li = document.getElementById(liId);
		
		if(inputElement)
		{
			var featureRowLevel = inputElement.getAttribute("featureRowLevel");
			var selectedFtrLstId = li.getAttribute("ftrlstid");
			var dMinimumQuantity;
			var dMaximumQuantity;
			var dOrderedQuantity;
			var parentFtrLstId = divId.slice(14,divId.length);
			
			var eachPriceInputId = featureRowLevel+"EachPrice";
			var extPriceInputId = featureRowLevel+"ExtPrice";
			var quantityInputId = featureRowLevel+"OrderedQuantity";
			
			var inputQtyElement = document.getElementById(quantityInputId);
			var elementType = inputQtyElement.type;
			var inputExtPElement = document.getElementById(extPriceInputId);
			var inputEachPElement = document.getElementById(eachPriceInputId);
			
			//var optionObj = selectElement.options[selectElement.selectedIndex];
			if(elementType != "text")
				dOrderedQuantity = inputQtyElement.innerHTML;
			else   
				dOrderedQuantity = inputQtyElement.value;
			dMaximumQuantity = li.getAttribute("dMaximumQuantity");
			dMinimumQuantity = li.getAttribute("minimumquantity");

			
			numMxQty = parseFloat(dMaximumQuantity);
			numOrdQty = parseFloat(dOrderedQuantity);
			numMinQty = parseFloat(dMinimumQuantity);
	
			if(isNaN(numOrdQty))
			{
				giveAlert("ENT_INVALIDCHAR_MSG");
				inputQtyElement.value = dMinimumQuantity;
				dOrderedQuantity = inputQtyElement.value;
			}
			else if(numMxQty < numOrdQty)
			{
				giveAlert("MAX_QTY_MSG");
				inputQtyElement.value = dMinimumQuantity;
				dOrderedQuantity = inputQtyElement.value;
				inputExtPElement.value = (inputQtyElement.value)*(inputEachPElement.value);
			}
			else if(numOrdQty < numMinQty)
			{
				giveAlert("MIN_QTY_MSG");
				inputQtyElement.value = dMinimumQuantity;
				dOrderedQuantity = inputQtyElement.value;
				inputExtPElement.value = (inputQtyElement.value)*(inputEachPElement.value);
			}
			else
				inputExtPElement.value = (numOrdQty)*(inputEachPElement.value);				
			li.setAttribute("orderedQuantity", dOrderedQuantity);			
			calculateTotalPrice();
			updateOrderedQuantityAttribute(selectedFtrLstId, dOrderedQuantity);
			var rowLevelArr = inputExtPriceElementId.split("E");
			var rowLevel = rowLevelArr[0];
			//if(isFromUI == true)
				//validate(divId, rowLevel, true);
		}
	}else{
	
	var divElement = document.getElementById(divId);
	if(divElement)
		var additionalCheckForIE = divElement.getAttribute("innerhtmlid");
	if(divElement != null && additionalCheckForIE != null)
	{
	maximumQuantity = divElement.getAttribute("maximumQuantity");
	minimumQuantity = divElement.getAttribute("minimumQuantity");
	}
	if(maximumQuantity != null && minimumQuantity != null && maximumQuantity != "" && minimumQuantity != "")
	{
		
	var inputQtyElement = document.getElementById(inputQtyElementId);
	var orderedQuantity = inputQtyElement.value;	
		extPriceElement = document.getElementById(inputExtPriceElementId);
	var eachPriceElement = document.getElementById(inputEachPriceElementId);
	
		numMxQty = parseFloat(maximumQuantity);
		numOrdQty = parseFloat(orderedQuantity);
			numMinQty = parseFloat(minimumQuantity);
			if(isNaN(numOrdQty))
			{
				giveAlert("ENT_INVALIDCHAR_MSG");
				inputQtyElement.value = minimumQuantity;
				orderedQuantity = inputQtyElement.value;
			}
			else if(numMxQty < numOrdQty)
			{
			giveAlert("MAX_QTY_MSG");
			inputQtyElement.value = minimumQuantity;
			}
			else if(numOrdQty < numMinQty)
			{
			giveAlert("MIN_QTY_MSG");
			inputQtyElement.value = minimumQuantity;
			}
		orderedQuantity = inputQtyElement.value;
	divElement.setAttribute('orderedQuantity', orderedQuantity);
		
		var relatedFtrElementId = extPriceElement.getAttribute("relatedftrelementid");
  		var relatedFtrElement = document.getElementById(relatedFtrElementId);
  		var relatedRowElement = document.getElementById("MprRow"+divId);
  		var tempArr = relatedFtrElementId.split("c");
  		var parentId = tempArr[0];
  		var childId = tempArr[1];
  		if(relatedFtrElement)
  		{
  		var elementType = relatedFtrElement.type;
  		if(elementType == "radio" || elementType == "checkbox") 
  		{
			isChecked = relatedFtrElement.checked;
			if(isChecked)
  			{	
	extPriceElement.value = (inputQtyElement.value)*(eachPriceElement.value);
				calculateTotalPrice();
			}
		}
	}
		else if(parentId == childId)
		{
			extPriceElement.value = (inputQtyElement.value)*(eachPriceElement.value);
			calculateTotalPrice();
		}else if(relatedRowElement)
		{
			extPriceElement.value = (inputQtyElement.value)*(eachPriceElement.value);
			calculateTotalPrice();
		}
		
		updateOrderedQuantityAttribute(childId, orderedQuantity);
	//	if(isFromUI == true)
	//	{
	//	validate(divId);
	//}
	}
	else
	{
		//var selectElements = document.getElementsByName(divId);
		var selectElements = document.getElementsByTagName("select");
		var selectElement;
        for(k = 0; k < selectElements.length; k++){
		   		if(selectElements[k].name == divId){
		   			selectElement=selectElements[k];
		   			break;
		   		}
		}
        
		if(selectElements != null && selectElements.length != 0)
		{
			
			//var selectElement = selectElements[0];
			var featureRowLevel = selectElement.getAttribute("featureRowLevel");
			var selectedFtrLstId = selectElement.value;
			var dMinimumQuantity;
			var dMaximumQuantity;
			var dOrderedQuantity;
			var parentFtrLstId = divId.slice(11,divId.length);
			
			var eachPriceInputId = featureRowLevel+"EachPrice";
			var extPriceInputId = featureRowLevel+"ExtPrice";
	        var quantityInputId = featureRowLevel+"OrderedQuantity";
	        
	        var inputQtyElement = document.getElementById(quantityInputId);
	        var elementType = inputQtyElement.type;
	        var inputExtPElement = document.getElementById(extPriceInputId);
	        var inputEachPElement = document.getElementById(eachPriceInputId);
	        
				var optionObj = selectElement.options[selectElement.selectedIndex];
				if(elementType != "text")
					dOrderedQuantity = inputQtyElement.innerHTML;
				else   
					dOrderedQuantity = inputQtyElement.value;
				dMaximumQuantity = optionObj.getAttribute("dMaximumQuantity");
				dMinimumQuantity = optionObj.getAttribute("minimumquantity");
	
			
			numMxQty = parseFloat(dMaximumQuantity);
			numOrdQty = parseFloat(dOrderedQuantity);
			numMinQty = parseFloat(dMinimumQuantity);
	
			if(isNaN(numOrdQty))
			{
				giveAlert("ENT_INVALIDCHAR_MSG");
				inputQtyElement.value = dMinimumQuantity;
				dOrderedQuantity = inputQtyElement.value;
			}
			if(numMxQty < numOrdQty)
			{
				giveAlert("MAX_QTY_MSG");
				inputQtyElement.value = dMinimumQuantity;
				dOrderedQuantity = inputQtyElement.value;
				inputExtPElement.value = (inputQtyElement.value)*(inputEachPElement.value);
			}
			else if(numOrdQty < numMinQty)
			{
				giveAlert("MIN_QTY_MSG");
				inputQtyElement.value = dMinimumQuantity;
				dOrderedQuantity = inputQtyElement.value;
				inputExtPElement.value = (inputQtyElement.value)*(inputEachPElement.value);
			}
			else
				inputExtPElement.value = (numOrdQty)*(inputEachPElement.value);				
			optionObj.setAttribute("orderedQuantity", dOrderedQuantity);			
			calculateTotalPrice();
			updateOrderedQuantityAttribute(selectedFtrLstId, dOrderedQuantity);
			var rowLevelArr = inputExtPriceElementId.split("E");
			var rowLevel = rowLevelArr[0];
		//	if(isFromUI == true)
			//validate(divId, rowLevel, true);
		}
	}
}
}

function updateInnerHTML(target, checked, selectionType)
{
	var groupName = target.getAttribute("groupName");
	var id = target.getAttribute("innerHTMLId");
	var featureRowLevel = target.getAttribute("id");
	var orderedQuantity = target.getAttribute("orderedquantity");
	var arr = id.split("c");
	var selectedFtrLstId = arr[1];
	var iFeatureRowLevel = target.getAttribute("id");
	
	if(checked == true)
	{
		updateOrderedQuantity(featureRowLevel, orderedQuantity, true);
		
		if(selectionType == "Single")
   			 htmlText = "<input name="+groupName+" id="+id+" type=\"radio\" value=\"radiobutton\" onclick=\"validate('"+iFeatureRowLevel+"')\" featureRowLevel="+iFeatureRowLevel+" checked=\"checked\"/>";
   		else
   			htmlText = "<input name="+groupName+" id="+id+" type=\"checkbox\" value=\"checkbox\" onclick=\"validate('"+iFeatureRowLevel+"')\" featureRowLevel="+iFeatureRowLevel+" checked=\"checked\"/>";
   	}
   	else
   	{
		updateOrderedQuantity(featureRowLevel, orderedQuantity, false);
   	
   		if(selectionType == "Single")
   		 htmlText = "<input name="+groupName+" id="+id+" type=\"radio\" value=\"radiobutton\" onclick=\"validate('"+iFeatureRowLevel+"')\" featureRowLevel="+iFeatureRowLevel+" />";
   		else
   			htmlText = "<input name="+groupName+" id="+id+" type=\"checkbox\" value=\"checkbox\" onclick=\"validate('"+iFeatureRowLevel+"')\" featureRowLevel="+iFeatureRowLevel+" />";
   	}
   		 
 	target.innerHTML = htmlText;
}

// This function is to make the combo or chooser or dbChooser childrens deselected if the parent is deselected
function makeDeselectionsOfComboChooser(id)
{
	var dropDownElement = document.getElementById(id);
	if(dropDownElement)
					{
		
						{
			var id = dropDownElement.value;
			featureDeselectionList.push(id);
						}
					}
				}
	
var arrFtrLstIds = new Array(); // this array carries all the parents in the feature structure to be deselected
function makeDeselections(relatedDivId) // This function is to make the childrens deselected if the parent is deselected
{
	var deselectedDiv = document.getElementById(relatedDivId);
	if(deselectedDiv==null){
		return;
	}
	else 
	{
		tagName = deselectedDiv.tagName;
		if(tagName != 'DIV')
			return;
	}
	var ftrLstId = deselectedDiv.getAttribute("ftrLstId");	
	var selectionType = deselectedDiv.getAttribute("selectionType");
	arrFtrLstIds.push(ftrLstId);
	updateInnerHTML(deselectedDiv, false, selectionType);
	featureDeselectionList.push(ftrLstId);
	makeDeselectionsOfComboChooser(relatedDivId);
	var childCount = 1;
	while(true)
	{
		var id = relatedDivId +"."+childCount;
		childCount++;
		var divElement = "";
		var divElement = document.getElementById(id);
		if(divElement == null)
			var orderedQnttyDivId = document.getElementById(id+"OrderedQuantity");
		if((divElement == "" || divElement == null) && orderedQnttyDivId == null)
			break;
		else if(divElement == null)
			continue ;
		divElement = document.getElementById(id);
		if(divElement)
		{
		 selectionType = divElement.getAttribute("selectionType");
		 var innerHTMLId = divElement.getAttribute("innerHTMLId");				 
		 if(innerHTMLId)
			 {
		 var arr = innerHTMLId.split("c");
		 var parentFtrLstId = arr[0];	
			 
				updateInnerHTML(divElement, false, selectionType);
				
		makeDeselectionsOfComboChooser(id);
				
				makeDeselections(id, true);
		 }
	}
	}
			
}


function getSelectedId(divId, forChooser)
{
	var selectedDiv = "";
	var orderedQuantity = "";
	var additionalCheckForIE = null;
	selectedDiv = document.getElementById(divId);	
	// For DropDown
	if(selectedDiv != null)
		additionalCheckForIE = selectedDiv.getAttribute("innerHTMLId");
	if((selectedDiv == null || selectedDiv == "") || additionalCheckForIE == null || forChooser == true)
	{
		var selectedSelectElements = document.getElementsByName(divId);
		var selectedSelectElement = document.getElementById("chooserLayerUL"+divId);
		if(selectedSelectElements != null && selectedSelectElements.length != 0 || selectedSelectElement!=null)
		{
			
			var isChooser = "";
			if(selectedDiv && selectedDiv.getAttribute("name"))
				isChooser = selectedDiv.getAttribute("name").slice(0, 7);
			if(isChooser == "chooser")
			{
				var deselectionListMember = selectedSelectElement.getAttribute("lastselectionftrlstid");
				var selectedFtrLstId = selectedSelectElement.defaultliid;
			//	var selectedLi = document.getElementById(selectedLiId);
			//	if(selectedLi)
			//	{
			//		var selectedFtrLstId = selectedLi.getAttribute("ftrLstId");
			//		var orderedQuantity = selectedLi.getAttribute("orderedQuantity");
			//	}
				//featureSelectionList.push(orderedQuantity);
				featureSelectionList.push(selectedFtrLstId);
				plainFeatureSelectionList.push(selectedFtrLstId);
				featureDeselectionList.push(deselectionListMember);
				
				var featureRowLevel = selectedSelectElement.getAttribute("featureRowLevel");
				featureRowLevel = getParentDivId(featureRowLevel);
				flag1 = true;
				
				
				makeParentSelection(featureRowLevel, true);
			}
			else{
				if(isIE)
					{
					selectedSelectElement = (selectedSelectElements.tags("select"))[0];
					}
				else
					{
					selectedSelectElement = selectedSelectElements[0];
					}
				
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
					orderedQuantity = option.getAttribute("orderedQuantity");
					if(orderedQuantity == null)
						orderedQuantity = "0.0";
				//	featureSelectionList.push(orderedQuantity);
					userSelectedFtrLstId = selectedFtrLstId;
					featureSelectionList.push(selectedFtrLstId);
						plainFeatureSelectionList.push(selectedFtrLstId);
				}
				else
					featureDeselectionList.push(deSelectedFtrLstId);
			}
			//--featureRowLevel;
			flag1 = true;
			makeParentSelection(featureRowLevel, true);
		}
			var id = selectedSelectElement.id;
			var parentFeatureId = id.substring(12);
			var siblings = document.getElementsByName(parentFeatureId);
			for(var sibCount = 0; sibCount < siblings.length; sibCount++)
			{
				var sibling = siblings[sibCount];
				var featureLevel = sibling.getAttribute("featureRowLevel");
				makeDeselections(featureLevel);
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
	var orderedQuantity = selectedDiv.getAttribute("orderedQuantity");
	if(orderedQuantity == null)
	{
		orderedQuantity = "0.0";
	}
	var selectedElement = document.getElementById(innerHTMLId);
	if(selectedElement)
	{
	var isChecked = selectedElement.checked;
	if(isChecked == true)
	{
			updateOrderedQuantity(divId, orderedQuantity, true);
				
	//featureSelectionList.push(orderedQuantity);
	featureSelectionList.push(ftrLstId);
	plainFeatureSelectionList.push(ftrLstId);
			if(selectionType == "Single")
	{
		var groupElements = document.getElementsByName(groupName);
		for(var count=0; count<groupElements.length; count++)
		{
				var groupElement = groupElements[count];
				var relatedDivId = groupElement.getAttribute("featureRowLevel");
					var deselectedDiv = document.getElementById(relatedDivId);
					if(deselectedDiv==null)
						continue;
					var ftrLstId = deselectedDiv.getAttribute("ftrLstId");	
				if(relatedDivId != divId)
				{
						updateOrderedQuantity(relatedDivId, orderedQuantity, false);
						
						featureDeselectionList.push(ftrLstId);
						arrFtrLstIds = [];
					makeDeselections(relatedDivId);	
				}
		}
		makeDeselectionsOfComboChooser("comboElement"+groupName);
			}
			flag1 = true;
			makeParentSelection(divId, false);
		}else
		{
			var orderedQuantity = selectedDiv.getAttribute("orderedQuantity");
			updateOrderedQuantity(divId, orderedQuantity, false);
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
				makeParentDeselection(getParentDivId(divId));
		}
	}
	
	}
}	
	
var flag1 = true;

function getParentDivId(childDivId)
{
	var index = childDivId.lastIndexOf('.');
	var parentDivId = childDivId.slice(0, index);
	return parentDivId;
}

function makeParentSelection(divId, isForCombo)
{
	var selectedDiv = document.getElementById(divId);
	if(selectedDiv == null)
		return;
	var innerHTMLId = selectedDiv.getAttribute("innerHTMLId");
	if(innerHTMLId==null)
		return;
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
			id = getParentDivId(divId);
		var divElement = document.getElementById(id);
		if(divElement == null)
			var orderedQnttyDivId = document.getElementById(id+"OrderedQuantity");
		if((divElement == "" || divElement == null))
		{
			flag1 = false;
				break;
		}
		else if(divElement == null)
			id = getParentDivId(divId);
		divElement = document.getElementById(id);
			selectionType = divElement.getAttribute("selectionType");
		groupName = divElement.getAttribute("groupName");
            var ftrLstId = divElement.getAttribute("ftrLstId");		
        var orderedQuantity = divElement.getAttribute("orderedQuantity");
		if(orderedQuantity == null)
			{
			orderedQuantity = "0.0";
		}		
		if(ftrLstId == parentFtrLstId || isForCombo == true)
		{
		//	featureSelectionList.push(orderedQuantity);
			featureSelectionList.push(ftrLstId);
			plainFeatureSelectionList.push(ftrLstId);
				updateInnerHTML(divElement, true, selectionType);
			if(selectionType == "Single")
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
				makeDeselectionsOfComboChooser("comboElement"+groupName);
			}
			makeParentSelection(id, false);
	 	}
	}
}

function makeParentDeselection(divId)
{
	var deSelectedDiv = document.getElementById(divId);
	
	if(deSelectedDiv == null)
		var orderedQnttyDivId = document.getElementById(divId+"OrderedQuantity");
	if((deSelectedDiv == "" || deSelectedDiv == null) && orderedQnttyDivId == null)
	{
		return;
	}
	else if(deSelectedDiv == null)
		divId = getParentDivId(divId);
	var parentDiv = document.getElementById(divId);
	if(parentDiv)
		{
			var parentId = parentDiv.getAttribute('ftrLstId');
			if(hasKeyInValue(parentId))
				return;
		}
	makeDeselections(divId);
	deSelectedDiv = document.getElementById(divId);
	var innerHTMLId = deSelectedDiv.getAttribute("innerHTMLId");
	var groupName = deSelectedDiv.getAttribute("groupName");
	var selectionType = deSelectedDiv.getAttribute("selectionType");
	var ftrLstId = deSelectedDiv.getAttribute("ftrLstId");
	featureDeselectionList.push(ftrLstId);
	updateInnerHTML(deSelectedDiv, false, selectionType);
	if(selectionType == "Multiple")
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
			makeParentDeselection(getParentDivId(divId));
		}
	}
	else 
	{
		makeDeselections(divId);
		makeParentDeselection(getParentDivId(divId));
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
			
			url="ProductConfigurationResponse.jsp?dynamicEvaluation=" +dynamicEvaluation+ "&featureSelectionList=" +featureSelectionList+ "&featureDeselectionList=" +featureDeselectionList+ "&bIsDynamic=" +bIsDynamic + "&randomCheckForIe=" +Math.random();
			xmlDoc = emxUICore.getXMLData(url);
			responseStatus = xmlDoc.getElementsByTagName("EcResponseStatus")[0];
		
			completeStatusIconMemberList = convertStringToArray(responseStatus.getAttribute("completeStatusIconMemberList"));
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
			
			url="ProductConfigurationResponse.jsp?dynamicEvaluation=" +dynamicEvaluation+ "&featureSelectionList=" +featureSelectionList+ "&featureDeselectionList=" +featureDeselectionList+ "&bIsDynamic=" +bIsDynamic + "&randomCheckForIe=" +Math.random();
			xmlDoc = emxUICore.getXMLData(url);
			responseStatus = xmlDoc.getElementsByTagName("EcResponseStatus")[0];
		
			errorIconMemberList = convertStringToArray(responseStatus.getAttribute("errorIconMemberList"));
			changeIconMemberList = convertStringToArray(responseStatus.getAttribute("changeIconMemberList"));
			completeStatusIconMemberList = convertStringToArray(responseStatus.getAttribute("completeStatusIconMemberList"));
			
			arr = new Array(errorIconMemberList.length, changeIconMemberList.length, completeStatusIconMemberList.length, techFtrErrorIconMemberList.length);
			count = getMaximumLength(arr);
		}
		
	for(var i=0; i<count; i++)
	{
		if(errorIconMemberList.length >= i)
		 {
			nodeName = errorIconMemberList[i];
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
		    		mprRowId = refreshTarget.getAttribute("mprRowId");
		    		rowElement = document.getElementById(mprRowId);
		    		rowElement.className = "";
		    		refreshTarget.innerHTML = refreshDivHtml;
		   		 }
		   		 else if(refreshTarget == null && refreshComboTarget != null && refreshChooserTarget == null)
		   		 {	
		   		 	mprRowId = refreshComboTarget.getAttribute("mprRowId");
		    		rowElement = document.getElementById(mprRowId);
		    		rowElement.className = "";
		    		refreshComboTarget.innerHTML = refreshDivHtml;
		   		 }else if(refreshChooserTarget != null && refreshTarget == null && refreshComboTarget == null)
		   		 {
		   		 	mprRowId = refreshChooserTarget.getAttribute("mprRowId");
		    		rowElement = document.getElementById(mprRowId);
		    		rowElement.className = "";
		    		refreshChooserTarget.innerHTML = refreshDivHtml;
		   		 }
	   		 }
		}
		if(techFtrErrorIconMemberList.length >= i)
		{
			if(tBody && techFtrErrorIconMemberList[i])
			{
				tBody.removeChild(techFtrErrorIconMemberList[i]);
			}
		}
		
		if(changeIconMemberList.length >= i)
		{
			nodeName = changeIconMemberList[i];
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
		    		mprRowId = refreshTarget.getAttribute("mprRowId");
		    		rowElement = document.getElementById(mprRowId);
		    		rowElement.className = "";
		    		refreshTarget.innerHTML = refreshDivHtml;
		   		 }
		   		 else if(refreshTarget == null && refreshComboTarget != null && refreshChooserTarget == null)
			 	{
		   		 	mprRowId = refreshComboTarget.getAttribute("mprRowId");
		    		rowElement = document.getElementById(mprRowId);
		    		rowElement.className = "";
		    		refreshComboTarget.innerHTML = refreshDivHtml;
		   		 }else if(refreshChooserTarget != null && refreshTarget == null && refreshComboTarget == null)
			 		{
		   		 	mprRowId = refreshChooserTarget.getAttribute("mprRowId");
		    		rowElement = document.getElementById(mprRowId);
		    		rowElement.className = "";
		    		refreshChooserTarget.innerHTML = refreshDivHtml;
			 		}
				 	}
			 	}
		if(completeStatusIconMemberList.length >= i)
		{
			nodeName = completeStatusIconMemberList[i];
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
				
				if(selectionType == "Single")
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
			//if(targetRow.style.visibility == "hidden")
				 //targetRow.style.visibility = "visible";
				 
			if(targetRow.style.display == 'none')
				 targetRow.style.display = '';
				 
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
				//var vis = targetRow.style.visibility;
				//if(targetRow.style.visibility == "visible" || targetRow.style.visibility == "")
					 //targetRow.style.visibility = "hidden";
				 if(targetRow.style.display == '')
				 	targetRow.style.display = 'none';
					 
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
        
	if(isFromValidate2)
	{
		completeStatusIconMemberList = [];
		completeStatusIconMemberList = convertStringToArray(responseStatus.getAttribute("completeStatusIconMemberList"));
		
		for(var i=0; i<completeStatusIconMemberList.length; i++)
		{
			if(completeStatusIconMemberList && completeStatusIconMemberList.length >= i)
			{
				updateCompleteStatusIconResponse(completeStatusIconMemberList[i]);
			}
		}
		
	}else{

	errorIconMemberList = [];
	techFtrErrorIconMemberList = [];
	changeIconMemberList = [];
	makeDisappearMemberList = [];
	makeAppearMemberList = [];
	autoSelectionMemberList = [];
	deSelectionMemberList = [];
	toNameListForComboAppearMembers = [];
	completeStatusIconMemberList = [];
	
	errorIconMemberList = convertStringToArray(responseStatus.getAttribute("errorIconMemberList"));
	techFtrErrorIconMemberList = convertStringToArray(responseStatus.getAttribute("techFtrErrorIconMemberList"));
	changeIconMemberList = convertStringToArray(responseStatus.getAttribute("changeIconMemberList"));
	makeDisappearMemberList = convertStringToArray(responseStatus.getAttribute("makeDisappearMemberList"));
	makeAppearMemberList = convertStringToArray(responseStatus.getAttribute("makeAppearMemberList"));
	autoSelectionMemberList = convertStringToArray(responseStatus.getAttribute("autoSelectionMemberList"));
	deSelectionMemberList = convertStringToArray(responseStatus.getAttribute("deSelectionMemberList"));
	toNameListForComboAppearMembers = convertStringToArray(responseStatus.getAttribute("toNameListForComboAppearMembers"));
	completeStatusIconMemberList = convertStringToArray(responseStatus.getAttribute("completeStatusIconMemberList"));
	
	if(errorIconMemberList.length >= 1 || techFtrErrorIconMemberList.length >= 1)
	{
		isValidConfiguration = "false";
	}
	
	var arr = new Array(errorIconMemberList.length, changeIconMemberList.length, makeDisappearMemberList.length, makeAppearMemberList.length, autoSelectionMemberList.length, deSelectionMemberList.length, toNameListForComboAppearMembers.length, completeStatusIconMemberList.length, techFtrErrorIconMemberList.length);
	var count = getMaximumLength(arr);
	for(var i=0; i<count; i++)
	{
		if(errorIconMemberList && errorIconMemberList.length >= i)
		{
			updateErrorIcomResponse(errorIconMemberList[i]);
		}
		if(techFtrErrorIconMemberList && techFtrErrorIconMemberList.length >=1)
		{
			updateTechFtrErrorIconResponse(techFtrErrorIconMemberList[i]);
		}
		if(changeIconMemberList && changeIconMemberList.length >= i)
		{
			updateChangeIconResponse(changeIconMemberList[i]);
		}
		if(completeStatusIconMemberList && completeStatusIconMemberList.length >= i)
		{
			updateCompleteStatusIconResponse(completeStatusIconMemberList[i]);
		}
		if(autoSelectionMemberList && autoSelectionMemberList.length >= i)
		{
			updateAutoSelectionResponse(autoSelectionMemberList[i]);
		}
		if(deSelectionMemberList && deSelectionMemberList.length >= i)
		{
			updateDeselectionResponse(deSelectionMemberList[i]);
		}
		if(makeAppearMemberList && makeAppearMemberList.length >= i)
		{
			updateMakeAppearResponse(makeAppearMemberList[i], toNameListForComboAppearMembers[i], xmlDoc);
		}
		if(makeDisappearMemberList && makeDisappearMemberList.length >= i)
		{
			updateMakeDisAppearResponse(makeDisappearMemberList[i]);
		}
	}
 }

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
		var selectedOption = selectElement.options[selectElement.selectedIndex];
		selectionType = selectedOption.getAttribute("selectionType");
		keyInType = selectedOption.getAttribute("keyInType");
		var dMinimumQuantity;
		var dMaximumQuantity;
		var dListPrice;
		var parentFtrLstId = divId.slice(11,divId.length);
		
		var eachPriceInputId = featureRowLevel+"EachPrice";
        var infoDivId = "info"+parentFtrLstId;
        var quantityDivId = "quantity"+parentFtrLstId;
        
        if(selectionType == "Key-In")
        {
        	showKeyInInputElementForCombo(featureRowLevel, keyInType, selectedFtrLstId);
        }
        else
        {
			var keyInRowId = featureRowLevel+"keyInRowForCombo";
			var keyInRowElement = document.getElementById(keyInRowId);
			keyInRowElement.style.visibility = "hidden";
        }
		
				dMinimumQuantity = selectedOption.getAttribute("orderedQuantity");
				dMaximumQuantity = selectedOption.getAttribute("dMaximumQuantity");
				dListPrice = selectedOption.getAttribute("dListPrice");
			
		if(dListPrice == null)
			dListPrice = "0.0";
		if(dMinimumQuantity == null)
			dMinimumQuantity = "0.0";
		if(dMaximumQuantity == null)
			dMaximumQuantity = "0.0";
		var target = document.getElementById(eachPriceInputId);
		var htmlText;
		if(target != null)
		{
			target.value = dListPrice;
		}
		target = document.getElementById(infoDivId);
		if(target != null)
		{
			htmlText = "<a class=\"mx_button-info\" href=\"javascript:fnloadHelp('"+selectedFtrLstId+"')\" border=\"0\"></a>";
			target.innerHTML = htmlText;
		}
		target = document.getElementById(quantityDivId);
		if(target != null)
		{
			if(dMaximumQuantity != dMinimumQuantity)
				htmlText = "<input name=\"OrderedQuantity\" id=\""+ featureRowLevel +"OrderedQuantity\" type=\"text\" value=\""+ dMinimumQuantity+ "\" onchange=\"checkOrderedQuantity('"+ featureRowLevel +"OrderedQuantity','"+ divId + "', '"+featureRowLevel+"ExtPrice', '"+featureRowLevel+"EachPrice', true)\">";
			else
				htmlText = "<a id=\""+featureRowLevel+"OrderedQuantity\" >"+ dMinimumQuantity +"</a>";
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
    		checkOrderedQuantity(featureRowLevel+"OrderedQuantity", divID, featureRowLevel+"ExtPrice", featureRowLevel+"EachPrice", false);
    	}
    	}
    	
    	isValidConfiguration = "true";
    	
    	techFtrErrorIconMemberList = [];
    	//IR-061710V6R2011x - Commented the code since getElementsByName doesn't work in IE, now retrieving all the rows from featureOptionBody
    	//and checking for mx_error adn updating techFtrErrorIconMemberList
    	/*if((document.getElementsByName("rowForTechFtr")).length >= 1)
    	{
    		var arr = document.getElementsByName("rowForTechFtr");
    		for(var i=0; i< arr.length; i++)
    		{
    			techFtrErrorIconMemberList.push(arr[i]);
    		}
    	}*/
		var tBody = document.getElementById("featureOptionsBody");
		var tBodyArray = tBody.rows;
		for(var i=0; i < tBodyArray.length; i++)
		{
			var rowElement = tBodyArray[i];
			if(rowElement.className == "mx_error" && rowElement.id == "")
			{
    			techFtrErrorIconMemberList.push(rowElement);
    	}
		}
		
    //	eraseLastResponse(false);
    	
    	var dynamicEvaluation = true;
    	var bIsDynamic = true;
		var url="ProductConfigurationResponse.jsp?mode=editOptions&randomCheckForIe=" +Math.random();
		var queryString = "dynamicEvaluation=" +dynamicEvaluation+ "&userSelectedFtrLstId=" +userSelectedFtrLstId+ "&featureSelectionList=" +featureSelectionList+ "&featureDeselectionList=" +featureDeselectionList+ "&bIsDynamic=" +bIsDynamic + "";
		var html = emxUICore.getDataPost(url, queryString);
		var bodyDiv = document.getElementById("mx_divBody");
		if(bodyDiv)
			bodyDiv.innerHTML = html;
		//getResponse(xmlDoc, false);
		calculateTotalPrice();
		validationStatus = false;
		removeMask();
		var divConfiguratorBody  = document.getElementById("mx_divConfiguratorBody");
		divConfiguratorBody.scrollTop = scrOfY;
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
    		checkOrderedQuantity(featureRowLevel+"OrderedQuantity", divID, featureRowLevel+"ExtPrice", featureRowLevel+"EachPrice", false);
    	}
	 	}
    	eraseLastResponse(true);
    	var dynamicEvaluation = false;
    	var bIsDynamic = true;
		var url="ProductConfigurationResponse.jsp?randomCheckForIe=" +Math.random();
		var queryString = "dynamicEvaluation=" +dynamicEvaluation+ "&userSelectedFtrLstId=" +userSelectedFtrLstId+ "&featureSelectionList=" +featureSelectionList+ "&featureDeselectionList=" +featureDeselectionList+ "&bIsDynamic=" +bIsDynamic + "";
		var xmlDoc = emxUICore.getXMLDataPost(url, queryString);
		getResponse(xmlDoc, true);
		calculateTotalPrice();
		
		featureSelectionList = [];
		featureDeselectionList = [];
		plainFeatureSelectionList = [];
 	}
 	
 	
 	function validate(divID, featureRowLevel, fromChkOrdrdQntty, isFromDbChooser, isFromDropDown) 
    {	
 		featureSelectionList = [];
		featureDeselectionList = [];
		plainFeatureSelectionList = [];
		var divConfiguratorBody  = document.getElementById("mx_divConfiguratorBody");
		scrOfY = divConfiguratorBody.scrollTop;
		scrOfX = divConfiguratorBody.scrollLeft;
			
    	if(fromChkOrdrdQntty != true ) // if it is not true means it is undefined hence make it false
    	{
    		fromChkOrdrdQntty = false;
    	}
    	if(isFromDropDown != true)
    		isFromDropDown = false;
    	var isRuleValidationRequired = false;
    	if(ruleEvaluationMembersList.length < 1)
    	{
    		var temp = document.getElementById("ruleEvalMembrsElmntId");
    		ruleEvaluationMembersList = convertStringToArray(temp.value);
    	}
    	if(divID)
    	{
    	getSelectedId(divID, isFromDropDown);
    	}
    	
    	var arr = new Array(plainFeatureSelectionList.length, featureDeselectionList.length);
    	var count = getMaximumLength(arr);
    	
    	if(!isFromDbChooser && !fromChkOrdrdQntty && ruleEvaluationMembersList.length > 0 && count > 0)
    	{
    		for(var n=0; n<count; n++)
    		{
    			if(!isRuleValidationRequired)
    			{
    				for(var m=0; m<ruleEvaluationMembersList.length; m++)
	    			{
	    				if(plainFeatureSelectionList[n] == ruleEvaluationMembersList[m] || featureDeselectionList[n] == ruleEvaluationMembersList[m])
	    				{
	    					isRuleValidationRequired = true;
	    					break;
	    				}
	    			}
    			}else{
    				break;
    			}
    		}
    	}
    	else
    	{
    		isRuleValidationRequired = true;
    	}
    	
    	if( fromChkOrdrdQntty || isRuleValidationRequired)
    	{
    	addMask("STR_PCVALIDATION_HEADERMSG1","STR_PCFTR_SELECTIONMSG1","STR_PCFTRSELECTIONVALIDATION_WAIT");
    	eval("setTimeout(\"validate1('"+divID+"', '"+featureRowLevel+"', '"+fromChkOrdrdQntty+"')\", 5);");
    	}else{
    	
	    	validate2(divID, featureRowLevel, fromChkOrdrdQntty);
    	}
    	
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
	
function fnValidateConfiguration(solverType) 
 {
 	var dynamicEvaluation = true;
 	bIsDynamic = false;
	var url="ProductConfigurationValidation.jsp?mode=checkValidity";
	var jsonString = emxUICore.getDataPost(url);
	var json = jsonString.parseJSON();
	var html = json.html;
	var bodyDiv = document.getElementById("mx_divBody");
	if(bodyDiv)
		bodyDiv.innerHTML = html;
	var msg = json.message;
	alert(msg);
	    validationStatus = true;
 	
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
	
function displayConflictDetails(divID,ID)
{
	var url="ProductConfigurationOptionsConflict.jsp?id="+ID+"&divId="+divID;
	var html = emxUICore.getDataPost(url);
	var div = document.getElementById(divID);
	div.oldInnerHTML=div.innerHTML;
	div.innerHTML=html;
}

function closeConflictDetailsDialog(divID)
{
	var div = document.getElementById(divID);
	div.innerHTML = div.oldInnerHTML;
	div.oldInnerHTML="";
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
		var url="ProductConfigurationResponse.jsp?dynamicEvaluation=" +dynamicEvaluation+ "&featureSelectionList=" +featureSelectionList+ "&featureDeselectionList=" +featureDeselectionList+ "&bIsDynamic=" +bIsDynamic + "&randomCheckForIe=" +Math.random();
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
							//Fix for Special Character Bug		    				
		    				toName = checkForSpecialCharacter(toName);
							//Fix for Special Character Bug		    				
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
		    				//Fix for Special Character Bug Start
		    				toName = checkForSpecialCharacter(toName);
		    				//Fix for Special Character Bug End
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
		        	cnxtSnglLnMsg = checkForSpecialCharacter(cnxtSnglLnMsg);
		        	cnxtSnglLnMsg = geti18nedMessage(cnxtSnglLnMsg);
		        	
		        	
		    		ruleType = xmlObj.childNodes[j].getAttribute("ruleType");
		    		owner = xmlObj.childNodes[j].getAttribute("owner");
		    		toName = xmlObj.childNodes[j].getAttribute("toName");
					//Fix for Special Character Bug
		    		toName = checkForSpecialCharacter(toName);
					//Fix for Special Character Bug
		    				if(visualCue == "errorIcon" || visualCue == "")
		    			visualCueCheck = "errorIcon";
		    		else
		    			visualCueCheck = "changeIcon";
				 }
		     }
		     	}
		 }
		var tempRuleExp = checkForSpecialCharacter(ruleExpression);
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
				"<tr><td></td><td>"+tempRuleExp+"</td></tr>"+
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

			if (str == "") 
			return " ";
			
			 parseFloat ("0").toFixed (dec);
			 if (bNeg && str.charAt (i) == '-') 
			 {
				neg = '-'; i++; 
			 }
			//Added for IR:Mx376489  To check InValid chars
			 if(isNaN(str))
			 {
				//it's not a number, so take action
				giveAlert("ENT_INVALIDCHAR_MSG");
				return " ";
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
					 {
					    strf += val;
					 }
				
			 }

			if(strf.length == 0 && dec == 0)
				giveAlert("ENT_INT_MSG");
			else if(strf.length == 0 && dec == 2)
				giveAlert("ENT_DEC_MSG");
		    strf = (strf == "" ? 0 : neg + strf);
		 return parseFloat (strf).toFixed (dec);
	  } 

// added for filter layer dialog

function toggleVisibilityOfFilterLayerDialog(ChooserLayerDialogDivId, visibilityFlag)
{	
	var div = document.getElementsByName(ChooserLayerDialogDivId)[0];
	
	var divList = document.getElementsByTagName("div");
	if(div == "undefined" || div == null)
	{
	for(var l=0;l < divList.length;l++)
	{
		var divName = divList[l].attributes.getNamedItem("name");
		var divValue = "";
		if(divName != null)
		{
			divValue = divName.nodeValue;
		}
		if(divValue == ChooserLayerDialogDivId)
		{
			div = divList[l];
			break;
		}
		}
	}
	var locallayerDialogTop = "";
	if(div)
	{
		if(visibilityFlag)
		{
			div.style.top = locallayerDialogTop;
			div.style.visibility = "visible";
		}else{
			div.style.visibility = "hidden";
		}
	}		
}

var lastSelectedLi;
function makeOptionSelectionFromFilter(li)
{
/*	if(lastSelectedLi)
	{
		lastSelectedLi.setAttribute("class","");
		lastSelectedLi.className = "";
		lastSelectedLi.style.border = "";
	}else{*/
		var ul = li.parentNode;
		var defaultSelectedLiId = ul.defaultliid;
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
	li.setAttribute("class","selected");
	li.className = "selected";
	li.style.border = "0.04px solid #555555";
	var ul = li.parentNode;
	ul.defaultliid = li.id;
}

function updateTableColumnValuesForChooser(chooserFtrElementId, lastSelectedLi2)
{
	var inputElement = document.getElementById(chooserFtrElementId);
	var ftrName = lastSelectedLi2.innerHTML;
	inputElement.value = ftrName;
	var featureRowLevel = inputElement.getAttribute("featureRowLevel");
	var selectedFtrLstId = lastSelectedLi2.getAttribute("ftrlstid");
	var selectedLiId = lastSelectedLi2.getAttribute("id");
	
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
	
	var selectionType = "";
	var keyInType = "";
	selectionType = lastSelectedLi2.getAttribute("selectionType");
	keyInType = lastSelectedLi2.getAttribute("keyInType");
	var dMinimumQuantity;
	var dMaximumQuantity;
	var dListPrice;
	var parentFtrLstId = chooserFtrElementId.slice(14,chooserFtrElementId.length);
	
	var eachPriceInputId = featureRowLevel+"EachPrice";
    var infoDivId = "info"+parentFtrLstId;
    var quantityDivId = "quantity"+parentFtrLstId;
    
    if(selectionType == "Key-In")
    {
    	showKeyInInputElementForCombo(featureRowLevel, keyInType, selectedFtrLstId);
    }
    else
    {
		var keyInRowId = featureRowLevel+"keyInRowForCombo";
		var keyInRowElement = document.getElementById(keyInRowId);
		keyInRowElement.style.visibility = "hidden";
    }
	
	dMinimumQuantity = lastSelectedLi2.getAttribute("orderedQuantity");
	dMaximumQuantity = lastSelectedLi2.getAttribute("dMaximumQuantity");
	dListPrice = lastSelectedLi2.getAttribute("dListPrice");
	
	if(dListPrice == null)
		dListPrice = "0.0";
	if(dMinimumQuantity == null)
		dMinimumQuantity = "0.0";
	if(dMaximumQuantity == null)
		dMaximumQuantity = "0.0";
	var target = document.getElementById(eachPriceInputId);
	var htmlText;
	if(target != null)
	{
		target.value = dListPrice;
	}
	target = document.getElementById(infoDivId);
	if(target != null)
	{
		htmlText = "<a class=\"mx_button-info\" href=\"javascript:fnloadHelp('"+selectedFtrLstId+"')\" border=\"0\"></a>";
		target.innerHTML = htmlText;
	}
	target = document.getElementById(quantityDivId);
	if(target != null)
	{
		if(dMaximumQuantity != dMinimumQuantity)
		{
			var liId = featureRowLevel+"li"+selectedFtrLstId;
			htmlText = "<input name=\"OrderedQuantity\" id=\""+ featureRowLevel +"OrderedQuantity\" type=\"text\" value=\""+ dMinimumQuantity+ "\" onchange=\"checkOrderedQuantity('"+ featureRowLevel +"OrderedQuantity', '"+ chooserFtrElementId + "', '"+featureRowLevel+"ExtPrice', '"+featureRowLevel+"EachPrice', true, '"+liId+"')\" />";
		}
		else
			htmlText = "<a id=\""+featureRowLevel+"OrderedQuantity\" >"+ dMinimumQuantity +"</a>";
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
	checkOrderedQuantity(featureRowLevel+"OrderedQuantity", chooserFtrElementId, featureRowLevel+"ExtPrice", featureRowLevel+"EachPrice", false, featureRowLevel+"li"+selectedFtrLstId);
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
function loadProductConfiguration(productConfigurationId,productConfigurationMode)
 {
 	var url="ProductConfigurationResponse.jsp?mode=editOptionsAfterMask&productConfigurationId="+productConfigurationId+"&productConfigurationMode="+productConfigurationMode;
 	var vres = emxUICore.getData(url);
 	var extraInfo = vres.split("-@ExtraInfo@-");
 	var priceInfo = extraInfo[1].split("-@PriceDelim@-");
 	var basePriceElmnt = document.getElementById("BasePrice");
 	basePriceElmnt.value = priceInfo[0];
 	var totalPriceInfo = priceInfo[1].split("-@RuleEval@-");
 	var totalPriceElmnt = document.getElementById("TotalPrice");
    totalPriceElmnt.value = totalPriceInfo[0];
 	var ruleEval = totalPriceInfo[1].split("-@MPRIds@-");
 	var ruleEvaluationIds = document.getElementById("ruleEvalMembrsElmntId");
 	ruleEvaluationIds.value = ruleEval[0];
 	var mprRelated = ruleEval[1].split("-@ExcludeList@-");
 	var trueMPRIds = document.getElementById("lstTrueMPRId");
 	var trueMPRIdsAtt = trueMPRIds.getAttribute("lstTrueMPRId");
 	//need to use setAttribute() for setting the value in element attribute
 	trueMPRIds.setAttribute("lstTrueMPRId", mprRelated[0]);
 	var excludeOIds = document.getElementById("strExcludeListMPR");
 	var excludeOIdsAtt = excludeOIds.getAttribute("strExcludeListMPR");
 	//need to use setAttribute() for setting the value in element attribute
 	excludeOIds.setAttribute("strExcludeListMPR", mprRelated[1]);
 	var target = document.getElementById("editResponse");
	target.innerHTML = extraInfo[0];
	calculateTotalPrice();
	removeMask();
 }
//Fix for Special Character Bug - Bug No. 361962
function checkForSpecialCharacter(toName)
{
	if(toName.indexOf("00100110")>= 0)
	{
		//toName.replace("00100110","&");
		toName = toName.replace(/00100110/g,"&");
	}
	if(toName.indexOf("00111111")>= 0)
	{
		//toName.replace("00111111","?");
		toName = toName.replace(/00111111/g,"?");
	}
	if(toName.indexOf("00111100")>= 0 )
	{
		//toName.replace("00111100","<");
		toName = toName.replace(/00111100/g,"<");
	}
	if(toName.indexOf("00100010")>= 0)
	{
		//toName.replace("00100010","\"");
		toName = toName.replace(/00100010/g,"\"");
	}
	return toName;
}

function hasKeyInValue(id)
{
	var keyInInput = document.getElementById(id);
	if(keyInInput)
		{
			var value = keyInInput.value;
			if(value.trim()=='')
				return false;
			return true;
		}
	return false;

}

function clearKeyInValue(id)
{
	updateKeyInValue('', id);
}

function onKeyInSelected(id, rowlevel)
{
	var keyInSelection = document.getElementById(id+"keyIn");
	if(keyInSelection && !keyInSelection.checked)
		clearKeyInValue(id);
	validate(rowlevel);
}

//Fix for Special Character Bug 
 
