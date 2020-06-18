
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
    var checkedItems = new Array;
    //var vchkItems = sourceFrame.forms[0].emxTableRowId;
    var vchkItems = sourceFrame.contentDocument.getElementsByName('emxTableForm')[0].emxTableRowId;
    
    //If only one element is selected
    if(vchkItems.length)
    {
    	checkedItems= sourceFrame.contentDocument.getElementsByName('emxTableForm')[0].emxTableRowId;	
    } 
    else
    {
    	checkedItems.push(sourceFrame.contentDocument.getElementsByName('emxTableForm')[0].emxTableRowId);
    }
    
    for(var ri = 0 ; ri < checkedItems.length ; ri++)
    {
    	var rowId = checkedItems[ri].value;
        var rowLevelArr = rowId.split("|");

        var checkedRelIds = rowLevelArr[0];
    	var checkedObjectIds = rowLevelArr[1];
    	var checkedParentIds = rowLevelArr[2];
    	var checkedObjLevel = rowLevelArr[3];
    	
    	if(checkedObjLevel == "0")
    	{
    		//It is root node
    		alert(ERROR_MESSAGE_FOR_ROOT_NODE_SELECTION);
    	}
    	else
    	{
    		var vURL = "../configuration/RuleDialogPreProcessUtil.jsp?mode=format&checkedRelIds="+checkedRelIds+"&checkedParentIds="+checkedParentIds+"&checkedObjectIds="+checkedObjectIds+"&featureOptionDetails="+featureOptionDetails;
            var vRes = emxUICore.getData(vURL);
            
            var iIndex = vRes.indexOf("ActualDisplay=");
            var iLastIndex = vRes.indexOf(",");
            var actualString = vRes.substring(iIndex+"ActualDisplay=".length , iLastIndex );
            vRes = vRes.substring(iLastIndex+1 , vRes.length );
            iIndex = vRes.indexOf("DisplayString=");
            iLastIndex = vRes.indexOf(";");
            var displayString = vRes.substring(iIndex+"DisplayString=".length , iLastIndex );
            
            // var expression = vRes.split("-@ActualDisplay@-");
            //var actualString = expression[0];
            //var displayString = expression[1];
            
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
        		addOption(document.getElementById('RExp'), displayString, actualString);
            	if(isIE && isMaxIE7){
            		document.getElementById('RExp').style.width = 'auto';
            		if((document.getElementById('RExp').clientWidth<278)){
            			document.getElementById('RExp').style.width = '278px';
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

