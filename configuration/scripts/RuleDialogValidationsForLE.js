
//RuleDialogValidationsForLE.js
//Includes all the operations to be performed on Rule Dilaog Page..which may vary depending upon the Type of rule.
/*Functions included:
 * insertFeatureOptions
 * remove
 * removeFeature
 * removeFeatureOption
 */
var iFrame_ie6;

function insertFeatureOptions(textArea)
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
    
    
    var checkedItems = new Array;
    //var vchkItems = sourceFrame.forms[0].emxTableRowId;
    //var vchkItems = sourceFrame.contentDocument.getElementsByName('emxTableForm')[0].emxTableRowId;
    //-------------------------For IE7 Fix
    var vchkItems = getTopWindow().document.getElementById('InclusionRuleSourceList').contentWindow.getCheckedCheckboxes();
    
    //If only one element is selected
    //if(vchkItems.length)
   // {
   // 	checkedItems= sourceFrame.contentDocument.getElementsByName('emxTableForm')[0].emxTableRowId;	
   // } 
    //else
    //{
   // 	checkedItems.push(sourceFrame.contentDocument.getElementsByName('emxTableForm')[0].emxTableRowId);
   // }
    
    //for(var ri = 0 ; ri < checkedItems.length ; ri++)
    for(var key in vchkItems)
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
            iLastIndex = vRes.indexOf("#");
            var displayString = vRes.substring(iIndex+"DisplayString=".length , iLastIndex );
            vRes = vRes.substring(iLastIndex+1 , vRes.length );
            
            iIndex = vRes.indexOf("RelationshipType=");
            iLastIndex = vRes.indexOf("#");
            var relationshipType = vRes.substring(iIndex+"RelationshipType=".length , iLastIndex );
            
            // var expression = vRes.split("-@ActualDisplay@-");
            //var actualString = expression[0];
            //var displayString = expression[1];
            
            if(textArea == 'left')
        	{
            	addOption(document.getElementById('LExp'), displayString, actualString,relationshipType);
        	}
        	if(textArea == 'right')
        	{
        		addOption(document.getElementById('RExp'), displayString, actualString,relationshipType);
        	}
    	}
    }
}

//Function to remove the feature options
function removeExp(textArea)
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
	}
	else
	{	
	 var expValue		= Exp.options[ind].value;
	 var expText			= Exp.options[ind].text;
	 
	 var vRuleClassification = Exp.options[ind].attributes[1].value;
	 var vFeatureType = Exp.options[ind].attributes[2].value;

	 var indexColon		= expText.indexOf('~');

	 var featureString	= expText.substring(0,indexColon);
	 var OptionString	= expText.substring(indexColon+1);

	 var indexColon1		= expValue.indexOf('~');
	 var OptionStringID	= expValue.substring(indexColon1+1);
	 var featureStringID = expValue.substring(0,indexColon1);

	 if(indexColon != -1)
	 {
  	  var exp1 =featureString ;
	  var exp2 =OptionString ;

	  for(var i=0; i<Exp.length; i++)
	  {
		if(Exp.options[i].selected)
		{
		  Exp.options[i] = new Option(OptionString,OptionStringID);
		  Exp.options[i].setAttribute("ruleclassification",vRuleClassification);
		  Exp.options[i].setAttribute("featuretype",vFeatureType);
		}				
      } //end of for
	 } 
		
	 if(indexColon == -1)
	 {
    	for(var i=0; i<Exp.length; i++)
    	{
		  if(Exp.options[i].selected)
		  {
			 Exp.options[i] = null;
          } 
		}
     }
	}
 } // end of method



  // Function to remove selected option 
function removeFeatureOption(textArea)
{
  if(textArea == 'left')
  {
	Exp = document.getElementById('LExp') ;
  }
  if(textArea == 'right')
  {
	Exp = document.getElementById('RExp') ;
  }

  ind =Exp.selectedIndex;

  if (ind == -1)
  {
 	 alert();
  }
  else
  {
	var expValue		= Exp.options[ind].value;
	var expText			= Exp.options[ind].text;
	
	var vRuleClassification = Exp.options[ind].attributes[1].value;
	var vFeatureType = Exp.options[ind].attributes[2].value;
	
	var indexColon		= expText.indexOf('~');
	var featureString	= expText.substring(0,indexColon);

	var OptionString	= expText.substring(indexColon+1);
	var indexColon1		= expValue.indexOf('~');
	var OptionStringID	= expValue.substring(indexColon1+1);
	var featureStringID = expValue.substring(0,indexColon1);
	
	if(indexColon != -1)
	{
		var exp1 =featureString ;
		var exp2 =OptionString ;

		for(var i=0; i<Exp.length; i++)
		{
		  if(Exp.options[i].selected)
          {
			 Exp.options[i] = new Option(exp1,featureStringID);
			 Exp.options[i].setAttribute("ruleclassification",vRuleClassification);
			 Exp.options[i].setAttribute("featuretype",vFeatureType);
		  }				
		} 
	}
	if(indexColon == -1)
	{
		//alert('"<%=i18nStringNowUtil("emxProduct.Alert.OptionSelection", bundle,acceptLanguage)%>"');
		alert(ERROR_MESSAGE_FOR_OPTION_SELECTION);
	}
  }
} // end of method

