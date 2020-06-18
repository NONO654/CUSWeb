
//RuleDialogValidationsForLeftExpressionInMPR.js
//Includes all the operations to be performed on Rule Dilaog Page..which may vary depending upon the Type of rule.
/*Functions included:
 * insertFeatureOptions
 * remove
 * removeFeature
 * removeFeatureOption
 */


function insertFeatureOptions(textArea,parentOID)
{
	//Checks whether the feature option checkbox is selected or not
	if(textArea == 'left')
	{
		var featureOptionDetails = getTopWindow().document.getElementById('leftExpCheckBox').checked;
		var passComparisonParam = getTopWindow().document.getElementById('compatibilityType').value;
	}
		
	if(textArea == 'right')
	{
		var featureOptionDetails = getTopWindow().document.getElementById('rightExpCheckBox').checked;
	}
    
    var sourceFrame = getTopWindow().document.getElementById('InclusionRuleSourceList');
    
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
    
    //------------------------------IE8 Fix
    var checkedItems = new Array;
    var vchkItems=new Array;
    var emxTableForm = sourceFrame.contentWindow.document.getElementsByName('emxTableForm')[0];
    if (emxTableForm) {
        var emxTableFormElements = emxTableForm.elements;
        for (var i = 0; i < emxTableFormElements.length; i++) {
            var emxTableFormElement = emxTableFormElements[i];
            if (emxTableFormElement.type == "hidden" && emxTableFormElement.name == "emxTableRowId") {
            	vchkItems.push(emxTableFormElement.value);
            }
        }
    }
    //If only one element is selected
    if(vchkItems==undefined){
    	alert(ERROR_MESSAGE_FOR_FEATURE_SELECTION);
    }else if ((vchkItems=="")){
    	alert(ERROR_MESSAGE_FOR_FEATURE_SELECTION);
    }else{
    if(vchkItems.length)
    {
    	checkedItems=vchkItems;	
    } 
    else
    {
    	checkedItems.push(vchkItems);
    }
    //------------------------------
    
    for(var ri = 0 ; ri < checkedItems.length ; ri++)
    {
       	var rowId = checkedItems[ri];
        var rowLevelArr = rowId.split("|");

        var checkedRelIds = rowLevelArr[0];
    	var checkedObjectIds = rowLevelArr[1];
    	var checkedParentIds = rowLevelArr[2];
    	var checkedObjLevel = rowLevelArr[3];
    	
    	if(checkedObjLevel == "0" && isRootNodePRD=="No")
    	{
    		//It is root node
    		alert(INVALID_RE_QR);
    	}
    	if(checkedObjLevel == "0" && isOfInvalidState=="Yes")
    	{
    		//It is root node invalid state
    		alert(INVALID_STATE_ALERT);
    	}
    	else
    	{
    		var vURL = "../configuration/RuleDialogPreProcessUtil.jsp?mode=formatQuantityRule&checkedRelIds="+checkedRelIds+"&checkedParentIds="+checkedParentIds+"&checkedObjectIds="+checkedObjectIds+"&featureOptionDetails="+featureOptionDetails;
            var vRes = emxUICore.getData(vURL);
            
            var iIndex = vRes.indexOf("ActualDisplay=");
            var iLastIndex = vRes.indexOf(",");
            var actualString = vRes.substring(iIndex+"ActualDisplay=".length , iLastIndex );
            vRes = vRes.substring(iLastIndex+1 , vRes.length );
            iIndex = vRes.indexOf("DisplayString=");
            iLastIndex = vRes.indexOf("#");
            var displayString = vRes.substring(iIndex+"DisplayString=".length , iLastIndex );
            
            if(textArea == 'left')
        	{
            	addOption(document.getElementById('LExp'), displayString, actualString);
            	if(isIE && isMaxIE7){
            		document.getElementById('LExp').style.width = 'auto';
            		if((document.getElementById('LExp').clientWidth<278)){
            			document.getElementById('LExp').style.width = '278px';
            		}
            	}
        	}
        	if(textArea == 'right')
        	{
        		if(parentOID!=null && parentOID!=checkedParentIds)
        		{
        			addOption(document.getElementById('RExp'), displayString, actualString);
                	if(isIE && isMaxIE7){
                		document.getElementById('RExp').style.width = 'auto';
                		if((document.getElementById('RExp').clientWidth<278)){
                			document.getElementById('RExp').style.width = '278px';
                		}
                	}
        		}
        		else
        		{
        			alert(ERROR_MESSAGE_FOR_INVALID_INSERT_FEATURE);
        		}
        	}
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
		Exp = document.getElementById('RExp') ;
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
	if(textArea == 'left'){
	 Exp = document.getElementById('LExp') ;
	}
	if(textArea == 'right'){
	 Exp = document.getElementById('RExp') ;
	}
	
	ind = Exp.selectedIndex;
	if (ind == -1){
	  alert(ERROR_MESSAGE_FOR_FEATURE_SELECTION);
	}else{	
	 var expValue= Exp.options[ind].value;
	 var expText= Exp.options[ind].text;
	 
	 var vRuleClassification = Exp.options[ind].attributes[1].value;
	 var vFeatureType = Exp.options[ind].attributes[2].value;
	 
	 var url="../configuration/RuleDialogValidationUtil.jsp?mode=getChildObjectID&relPhyID="+expValue;
	 var vRes = emxUICore.getData(url);
	 var iIndex = vRes.indexOf("childPhyID=");
	 var iLastIndex = vRes.indexOf(";");
	 var childPhyID = vRes.substring(iIndex+"childPhyID=".length , iLastIndex );
	 
	 var indexColon		= expText.indexOf('~');
	 var featureString	= expText.substring(0,indexColon);
	 var OptionString	= expText.substring(indexColon+1);
	 
	 var indexColon1		= expValue.indexOf('~');
	 var OptionStringID	=childPhyID.trim();
	 if(indexColon != -1){
  	  var exp1 =featureString ;
	  var exp2 =OptionString ;
	  for(var i=0; i<Exp.length; i++){
		if(Exp.options[i].selected){
		  Exp.options[i] = new Option(OptionString,OptionStringID);
		  Exp.options[i].setAttribute("ruleclassification",vRuleClassification);
		  Exp.options[i].setAttribute("featuretype",vFeatureType);
		}				
      } //end of for
	 } 
	 if(indexColon == -1){
    	for(var i=0; i<Exp.length; i++){
		  if(Exp.options[i].selected){
			 Exp.options[i] = null;
          } 
		}
     }
	 if(isIE && isMaxIE7){
		 Exp.removeAttribute("style");
		 Exp.setAttribute("class",'select');
	 }
	}
 } // end of method



  // Function to remove selected option 
function removeFeatureOption(textArea)
{
  if(textArea == 'left'){
	Exp = document.getElementById('LExp') ;
  }
  if(textArea == 'right'){
	Exp = document.getElementById('RExp') ;
  }

  ind =Exp.selectedIndex;
  if (ind == -1){
 	 alert(ERROR_MESSAGE_FOR_SELECT_OPTION);
  }
  else{
	var expValue		= Exp.options[ind].value;
	var expText			= Exp.options[ind].text;
	
	var vRuleClassification = Exp.options[ind].attributes[1].value;
	var vFeatureType = Exp.options[ind].attributes[2].value;
	
    var url="../configuration/RuleDialogValidationUtil.jsp?mode=getParentObjectID&relPhyID="+expValue;
    var vRes = emxUICore.getData(url);
    var iIndex = vRes.indexOf("parentPhyID=");
    var iLastIndex = vRes.indexOf(";");
    var parentPhyID = vRes.substring(iIndex+"parentPhyID=".length , iLastIndex );
	
	var indexColon		= expText.indexOf('~');
	var featureString	= expText.substring(0,indexColon);

	var OptionString	= expText.substring(indexColon+1);
	var indexColon1		= expValue.indexOf('~');
	var OptionStringID	= expValue.substring(indexColon1+1);
	var featureStringID = parentPhyID.trim();
	
	if(indexColon != -1){
		var exp1 =featureString ;
		var exp2 =OptionString ;
		for(var i=0; i<Exp.length; i++){
		  if(Exp.options[i].selected){
			 Exp.options[i] = new Option(exp1,featureStringID);
			 Exp.options[i].setAttribute("ruleclassification",vRuleClassification);
			 Exp.options[i].setAttribute("featuretype",vFeatureType);
		  }				
		} 
	}
	if(isIE && isMaxIE7){
		Exp.removeAttribute("style");
		Exp.setAttribute("class",'select');
	}
	if(indexColon == -1){
		alert(ERROR_MESSAGE_FOR_OPTION_SELECTION);
	}
  }
} // end of method

