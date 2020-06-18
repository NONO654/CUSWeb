
//RuleDialogValidationsForRE.js
//Includes all the operations to be performed on Rule Dilaog Page..which may vary depending upon the Type of rule.
/*Functions included:
 
 */

	
function insertFeatureOptions(textArea)
{
	//Checks whether the feature option checkbox is selected or not
	//alert("insertFeatureOptions...");
	var vRuleClassificationIndex = document.getElementById('ruleClassification').selectedIndex;
	var vRuleClassification = document.getElementById('ruleClassification').options[vRuleClassificationIndex].value;
    //var vFeatureTypeIndex = document.getElementById('featureType').selectedIndex;
    //var vFeatureType = document.getElementById('featureType').options[vFeatureTypeIndex].value;
    
    var checkedItems = new Array;
    //var vchkItems = sourceFrame.forms[0].emxTableRowId;
    
    var vchkItems=new Array;
    var sourceFrame = getTopWindow().document.getElementById('InclusionRuleSourceList');
    var emxTableForm = sourceFrame.contentWindow.document.getElementsByName('emxTableForm')[0];
    
    
    var vchkItems = getTopWindow().document.getElementById('InclusionRuleSourceList').contentWindow.getCheckedCheckboxes();
    
    
    //if (emxTableForm) {
      //  var emxTableFormElements = emxTableForm.elements;
       // for (var i = 0; i < emxTableFormElements.length; i++) {
         //   var emxTableFormElement = emxTableFormElements[i];
         //   if (emxTableFormElement.type == "hidden" && emxTableFormElement.name == "emxTableRowId") {
         //   	vchkItems.push(emxTableFormElement.value);
         //   }
        //}
    // }     
    
    //If only one element is selected
    if(vchkItems==undefined){
    	alert(ERROR_MESSAGE_FOR_FEATURE_SELECTION);
    }else if ((vchkItems=="")){
    	alert(ERROR_MESSAGE_FOR_FEATURE_SELECTION);
    }else{
    	
    	if(textArea == 'left')
    	{
    		var featureOptionDetails = getTopWindow().document.getElementById('leftExpCheckBox').checked;
    		var passComparisonParam = getTopWindow().document.getElementById('compatibilityType').value;
    	}
    	if(textArea == 'right')
    	{
    		var featureOptionDetails = getTopWindow().document.getElementById('rightExpCheckBox').checked;
    	}
    	
    	   var vProdupctId = "";
    	    if (isIE) {
    	    	vProductId = sourceFrame.contentWindow.document.getElementsByName('emxTableForm')[0].objectId.value;
    	    }else{
    	    	vProductId=sourceFrame.contentDocument.getElementsByName('emxTableForm')[0].objectId.value;
    	    }
    	    var vURL = "../configuration/RuleDialogPreProcessUtil.jsp?mode=SBRootNodeInfo&rootNodeID="+vProductId;
    	    var vRes = emxUICore.getData(vURL);
    	   
    	    var iIndex = vRes.indexOf("type=");
    	    var iLastIndex = vRes.indexOf(",");
    	    var type = vRes.substring(iIndex+"type=".length , iLastIndex );

    	    vRes = vRes.substring(iLastIndex+1 , vRes.length );
    	    iIndex = vRes.indexOf("isOfTypeFeatures=");
    	    iLastIndex = vRes.indexOf(",");
    	    var isOfTypeFeatures = vRes.substring(iIndex+"isOfTypeFeatures=".length , iLastIndex ).trim();

    	    vRes = vRes.substring(iLastIndex+1 , vRes.length );
    	    iIndex = vRes.indexOf("isOfTypePV=");
    	    iLastIndex = vRes.indexOf(",");
    	    var isOfTypePV = vRes.substring(iIndex+"isOfTypePV=".length , iLastIndex ).trim();

    	    vRes = vRes.substring(iLastIndex+1 , vRes.length );
    	    iIndex = vRes.indexOf("isOfInvalidState=");
    	    iLastIndex = vRes.indexOf(",");
    	    var isOfInvalidState = vRes.substring(iIndex+"isOfInvalidState=".length , iLastIndex ).trim();
    	   
    	    vRes = vRes.substring(iLastIndex+1 , vRes.length );
    	    iIndex = vRes.indexOf("isRootNodeProduct=");
    	    iLastIndex = vRes.indexOf(";");
    	    var isRootNodePRD = vRes.substring(iIndex+"isRootNodeProduct=".length , iLastIndex );
    	    
    	    	//if(vchkItems.length)
    	    	//{
    	    	//	checkedItems=vchkItems;	
    	    	//} 
    	    	//else
    	    	//{
    	    		//checkedItems.push(vchkItems);
    	    	//}
    	    var bflagForDesign = false;
    	    var bflagForMarketing = false;
    	    
    	    for(var key in vchkItems)
    	    //for(var ri = 0 ; ri < checkedItems.length ; ri++)
    	    {
    	    	var rowId = vchkItems[key];
    	        var rowLevelArr = rowId.split("|");
    	        var checkedRelIds = rowLevelArr[0];
    	    	var checkedObjectIds = rowLevelArr[1];
    	    	var checkedParentIds = rowLevelArr[2];
    	    	var checkedObjLevel = rowLevelArr[3];
    	    	
    	    	if(checkedObjLevel == "0" && isRootNodePRD=="No")
    	    	{
    	    		//It is root node
    	    		alert(INVALID_LE_RE_BCR);
    	    	}
    	    	else
    	    	{
    	    		var vUrlParam = "mode=format&checkedRelIds="+checkedRelIds+"&checkedParentIds="+checkedParentIds+"&checkedObjectIds="+checkedObjectIds+"&featureOptionDetails="+featureOptionDetails;
    	    		var vRes = emxUICore.getDataPost("../configuration/RuleDialogPreProcessUtil.jsp", vUrlParam);
    	            
    	            var iIndex = vRes.indexOf("ActualDisplay=");
    	            var iLastIndex = vRes.indexOf(",");
    	            var actualString = vRes.substring(iIndex+"ActualDisplay=".length , iLastIndex );
    	            vRes = vRes.substring(iLastIndex+1 , vRes.length );
    	            
    	            iIndex = vRes.indexOf("DisplayString=");
    	            var iLastIndex = vRes.indexOf(",");
    	            var displayString = vRes.substring(iIndex+"DisplayString=".length , iLastIndex );
    	            vRes = vRes.substring(iLastIndex+1 , vRes.length );
    	            
    	            iIndex = vRes.indexOf("RelationshipType=");
    	            iLastIndex = vRes.indexOf("#");
    	            var relationshipType = vRes.substring(iIndex+"RelationshipType=".length , iLastIndex );
    	            
    	        	if(
    	            		((textArea == 'left' || textArea == 'right') && vRuleClassification=='Configuration' && relationshipType=='relationship_CONFIGURATIONSTRUCTURES')
    	            		||(textArea == 'left' && vRuleClassification =='Logical')
    	            		||(textArea == 'right' && vRuleClassification =='Logical' && relationshipType=='relationship_LOGICALSTRUCTURES')
    	            		
    	            	   )
    	            		{
		    	                if(textArea == 'left')
		        	        	{
		        	            	addOption(document.getElementById('LExp'), displayString, actualString,relationshipType);
		        	            	if(isIE && isMaxIE7){
		        	            		document.getElementById('LExp').style.width = 'auto';
		        	            		if((document.getElementById('LExp').clientWidth<278)){
		        	            			document.getElementById('LExp').style.width = '278px';
		        	            		}
		        	            	}
		        	        	}
		        	        	if(textArea == 'right')
		        	        	{
		        	        		addOption(document.getElementById('RExp'), displayString, actualString,relationshipType);
		        	            	if(isIE && isMaxIE7){
		        	            		document.getElementById('RExp').style.width = 'auto';
		        	            		if((document.getElementById('RExp').clientWidth<278)){
		        	            			document.getElementById('RExp').style.width = '278px';
		        	            		}
		        	            	}
		        	        	}
    	            		}else{
    	            	    	 if(vRuleClassification=='Configuration'){
    	            	    		 bflagForMarketing = true;
    	            	    	 }
    	            	    	 else{
    	            	    		 bflagForDesign = true;
    	            	    	 }
    	            	    }
    	    	   }
    	    }
    	    //For multiple selection and insert use case alert executed at the end.
    	    if(bflagForDesign == true){
    	    	alert(ERROR_MESSAGE_FOR_DESIGN_RULE_RIGHT_EXP);
    	    }else if(bflagForMarketing==true){
    	    	if(textArea == 'left'){
    	    		alert(ERROR_MESSAGE_FOR_MARKETING_RULE_LEFT_EXP);
    	    	}else{
    	    		alert(ERROR_MESSAGE_FOR_MARKETING_RULE_RIGHT_EXP);
    	    	}
    	    }
       }
   }


//Function to remove the feature options
function remove(textArea)
{
	if(textArea == 'left')
	{
	 Exp = document.getElementById('LExp') ;
	}
	if(textArea == 'right')
	{
	 Exp = document.getElementById('RExp');
	}
	
	ind = Exp.selectedIndex;
   	if (ind == -1)
   	{
   	  alert(ERROR_MESSAGE_FOR_FEATURE_SELECTION);
	  return 0;
	}
   	
	if(ind!=-1)
	{
		var expValue = Exp.options[ind].value;
		var expText = Exp.options[ind].text;
	
		if (ind != -1)
		{
		  for(i=Exp.length-1; i>=0; i--)
		  {
		    if(Exp.options[i].selected)
			{
				Exp.options[i] = null;
			} 
		  }
	    }
	}
	
	if (Exp.length > 0)
	{
     Exp.selectedIndex = ind == 0 ? 0 : ind - 1;
    }
}// end of method

function removeFeature(textArea)
  {
	if (textArea == 'left') {
		Exp = document.getElementById('LExp');
	}
	if (textArea == 'right') {
		Exp = document.getElementById('RExp');
	}

	ind = Exp.selectedIndex;
	if (ind == -1) {
		alert(ERROR_MESSAGE_FOR_FEATURE_SELECTION);
	} else {
		var isContainOperator = false;
		for (var i = 0; i < Exp.length; i++) {
			if ((Exp.options[i].selected)
					&& (Exp.options[i].value == "AND"
							|| Exp.options[i].value == "OR"
							|| Exp.options[i].value == "NOT"
							|| Exp.options[i].value == "(" || Exp.options[i].value == ")")) {
				isContainOperator = true;
				break;
			}
		}

		if (isContainOperator) {
			alert(ERROR_MESSAGE_FOR_OPERATOR_SELECTION);
		} else {
			for (var i = Exp.length - 1; i >= 0; i--) {

				var expValue = Exp.options[i].value;
				var expText = Exp.options[i].text;
				var indexColon = expText.indexOf('~');

				if (indexColon == -1) {
					if (Exp.options[i].selected) {
						Exp.options[i] = null;
					}
				} else {
					var vRuleClassification = Exp.options[i].attributes[1].value;
					var vFeatureType = Exp.options[i].attributes[2].value;
					var url = "../configuration/RuleDialogValidationUtil.jsp?mode=getChildObjectIDBCR&relPhyID="
							+ expValue;
					var vRes = emxUICore.getData(url);
					var iIndex = vRes.indexOf("childPhyID=");
					var iLastIndex = vRes.indexOf(",");
					var childPhyID = vRes.substring(iIndex
							+ "childPhyID=".length, iLastIndex);

					var iIndex2 = vRes.indexOf("isCFCOType=");
					var iLastIndex2 = vRes.indexOf(";");
					var isCFCOType = vRes.substring(iIndex2
							+ "isCFCOType=".length, iLastIndex2);
					isCFCOType = isCFCOType.trim();

					if(vRuleClassification=='Configuration' &&  textArea == 'left' && isCFCOType == 'false'){
						alert(ERROR_MESSAGE_FOR_MARKETING_RULE_LEFT_EXP);
						return;
					}else if (vRuleClassification=='Configuration' &&  textArea == 'right'  && isCFCOType == 'false'){
						alert(ERROR_MESSAGE_FOR_MARKETING_RULE_RIGHT_EXP);
						return;
					}
					var featureString = expText.substring(0, indexColon);
					var OptionString = expText.substring(indexColon + 1);
					var indexColon1 = expValue.indexOf('~');
					var OptionStringID = childPhyID.trim();
					if (indexColon != -1) {
						var exp1 = featureString;
						var exp2 = OptionString;
						if (Exp.options[i].selected) {
							Exp.options[i] = new Option(OptionString,
									OptionStringID);
							Exp.options[i].setAttribute("ruleclassification",
									vRuleClassification);
							Exp.options[i].setAttribute("featuretype",
									vFeatureType);
						}
					}
				}
				if (isIE && isMaxIE7) {
					Exp.removeAttribute("style");
					Exp.setAttribute("class", 'select');
				}
			}
		}
	}
} // end of method



  // Function to remove selected option 
function removeFeatureOption(textArea) {
	if (textArea == 'left') {
		Exp = document.getElementById('LExp');
	}
	if (textArea == 'right') {
		Exp = document.getElementById('RExp');
	}

	ind = Exp.selectedIndex;
	if (ind == -1) {
		alert(ERROR_MESSAGE_FOR_SELECT_OPTION);
	} else {

		var hasNotOption = false;
		for (var i = 0; i < Exp.length; i++) {
			var expValue = Exp.options[i].value;
			var expText = Exp.options[i].text;
			var indexColon = expText.indexOf('~');
			if ((Exp.options[i].selected) && (indexColon == -1)) {
				hasNotOption = true;
				break;
			}
		}

		var isContainOperator = false;
		for (var i = 0; i < Exp.length; i++) {
			if ((Exp.options[i].selected)
					&& (Exp.options[i].value == "AND"
							|| Exp.options[i].value == "OR"
							|| Exp.options[i].value == "NOT"
							|| Exp.options[i].value == "(" || Exp.options[i].value == ")")) {
				isContainOperator = true;
				break;
			}
		}

		if (isContainOperator) {
			alert(ERROR_MESSAGE_FOR_OPERATOR_SELECTION);
		} else if (hasNotOption) {
			alert(ERROR_MESSAGE_FOR_OPTION_SELECTION);
		} else {
			for (var i = Exp.length - 1; i >= 0; i--) {
				var expValue = Exp.options[i].value;
				var expText = Exp.options[i].text;
				var indexColon = expText.indexOf('~');

				var vRuleClassification = Exp.options[i].attributes[1].value;
				var vFeatureType = Exp.options[i].attributes[2].value;

				var url = "../configuration/RuleDialogValidationUtil.jsp?mode=getParentObjectIDBCR&relPhyID="
						+ expValue;
				var vRes = emxUICore.getData(url);
				var iIndex = vRes.indexOf("parentPhyID=");
				var iLastIndex = vRes.indexOf(",");
				var parentPhyID = vRes.substring(
						iIndex + "parentPhyID=".length, iLastIndex);
				var iIndex2 = vRes.indexOf("isCFCOType=");
				var iLastIndex2 = vRes.indexOf(";");
				var isCFCOType = vRes.substring(iIndex2
						+ "isCFCOType=".length, iLastIndex2);
				isCFCOType = isCFCOType.trim();
				var vCurRuleClassification = document.getElementById('ruleClassification').value;
				if(vCurRuleClassification=='Configuration' &&  textArea == 'left' && isCFCOType == 'false'){
					alert(ERROR_MESSAGE_FOR_MARKETING_RULE_LEFT_EXP);
					return;
				}else if (vCurRuleClassification=='Configuration' &&  textArea == 'right'  && isCFCOType == 'false'){
					alert(ERROR_MESSAGE_FOR_MARKETING_RULE_RIGHT_EXP);
					return;
				}
				if(isCFCOType == 'false'){
					vFeatureType="nonCFCOType";
				}
				var featureString = expText.substring(0, indexColon);

				var OptionString = expText.substring(indexColon + 1);
				var indexColon1 = expValue.indexOf('~');
				var OptionStringID = expValue.substring(indexColon1 + 1);
				var featureStringID = parentPhyID.trim();

				if (indexColon != -1) {
					var exp1 = featureString;
					var exp2 = OptionString;

					if (Exp.options[i].selected) {
						Exp.options[i] = new Option(exp1, featureStringID);
						Exp.options[i].setAttribute("ruleclassification",
								vRuleClassification);
						Exp.options[i]
								.setAttribute("featuretype", vFeatureType);
					}
				}
			}
		}
		if (isIE && isMaxIE7) {
			Exp.removeAttribute("style");
			Exp.setAttribute("class", 'select');
		}
	}
} // end of method

