
//RuleDialogValidationsForCompletedRule.js
//Includes all the operations to be performed on Rule Dilaog Page..which may vary depending upon the Type of rule.
/*Functions included:
 * createNamedElement
 * submitRule
 * fnValidate
 */

//The NAME attribute cannot be set at run time on elements dynamically created with the createElement method. 
//To create an element with a name attribute, include the attribute and value when using the createElement method.
//eg: document.createElement("<input name='brian'>")
//The browser creates an element with the invalid type = "<input name='brian'>". This is what Netscape 7.1 and Opera 8.5 do
//The code simply tries to create the element using the Internet Explorer method first; if this fails it uses the standard method.
function createNamedElement(type, name) {
	   var element = null;
	   // Try the IE way; this fails on standards-compliant browsers
	   try {
	      element = document.createElement('<'+type+' name="'+name+'">');
	   } catch (e) {
	   }
	   if (!element || element.nodeName != type.toUpperCase()) {
	      // Non-IE browser; use canonical method to create named element
	      element = document.createElement(type);
	      element.name = name;
	   }
	   return element;
	}
 
 
 var lstLeftExpression =  new Array;
 var lstRightExpression =  new Array;
 var isSubmitted =  false;
function submitRule(mode,submitURL)
  {
	if(fnValidate(mode)){
		var ruleNameType = "";
		var url = "" ;
				 
		passComparisonParam = document.getElementById('compatibilityType').value;
		document.getElementById('compatibilityType').value = passComparisonParam;
			
		var vParentform = document.getElementById("RuleForm");
		var ProductId = vParentform.hContextId.value; 
		var ContextType = vParentform.hContextType.value;
		  		 
		document.getElementById('hleftExpObjIds').value = passLeftHiddenExpId;
		document.getElementById('hleftExpObjTxt').value = passLeftHiddenExpText;
	     
	    
		document.getElementById('hrightExpObjIds').value = passRightHiddenExpId;
		document.getElementById('hrightExpObjTxt').value = passRightHiddenExpText;
		
		
		document.getElementById('hleftExpRCVal').value = passLERuleClassValue;
		document.getElementById('hleftExpFeatTypeVal').value = passLEFeatTypeValue;
	  	
		document.getElementById('hrightExpRCVal').value = passRERuleClassValue;
		document.getElementById('hrightExpFeatTypeVal').value = passREFeatTypeValue;
		
		
	    
	    	var vUrlParam = "mode=ValidateExpression&ProductId="+ProductId+"&lstLeftExpression="+lstLeftExpression+"&lstRightExpression="+lstRightExpression;
	    	var vtest = emxUICore.getDataPost("../configuration/RuleDialogValidationUtil.jsp", vUrlParam);
	    var iIndex = vtest.indexOf("LeftExpression=");
	    var iLastIndex = vtest.indexOf(",");
	    var isLeftExpValid = vtest.substring(iIndex+"LeftExpression=".length , iLastIndex );
	    isLeftExpValid  = trim(isLeftExpValid );

	    vtest = vtest.substring(iLastIndex+1 , vtest.length );
	    iIndex = vtest.indexOf("RightExpression=");		
	    iLastIndex = vtest.indexOf(";");		
	    var isRightExpValid = vtest.substring(iIndex+"RightExpression=".length , iLastIndex );
	    isRightExpValid  = trim(isRightExpValid );
	    
	    if(isLeftExpValid == "true" && isRightExpValid == "true"){
	    	if(!isSubmitted){
	    	isSubmitted =  true;
				
				var type ='<%=strContextType%>';	   
			    if(type == '<%=ConfigurationConstants.TYPE_PRODUCT_VARIANT%>')
			    {
			    	document.getElementById('hMandatory').value ="";
			    }
			    
			   if(mode=="create"){
			    	if(submitURL!=null){
			    		document.RuleForm.action = submitURL+"&ProductId="+ProductId;
			    		document.RuleForm.submit();
			    	}
			    	else{
			    	  document.RuleForm.action ="../configuration/RuleDialogSubmitUtil.jsp?mode=create&ProductId="+ProductId;
		 			  document.RuleForm.submit();
		 			  getTopWindow().getWindowOpener().location.href = getTopWindow().getWindowOpener().location.href;
					  window.getTopWindow().closeWindow();	
			    	}
			    }
			   else if(mode=="edit"){
				    	if(submitURL!=null){
				    		submitURL = submitURL.replace("|","&");
				    		document.RuleForm.action = submitURL+"&ProductId="+ProductId+"&ContextType"+ContextType;
				    		document.RuleForm.submit();
				    	}
				    	else{
				    	  document.RuleForm.action ="../configuration/RuleDialogSubmitUtil.jsp?mode=edit&ProductId="+ProductId;
			 			  document.RuleForm.submit();
			 			 getTopWindow().getWindowOpener().location.href = getTopWindow().getWindowOpener().location.href;
						  window.getTopWindow().closeWindow();	
				    	}
			   }
			   else if(mode=="copy"){
			    	if(submitURL!=null){
			    		submitURL = submitURL.replace("|","&");
			    		document.RuleForm.action = submitURL+"&ProductId="+ProductId+"&ContextType"+ContextType;
			    		document.RuleForm.submit();			    		
			    	}
			    	else{
			    	  document.RuleForm.action ="../configuration/RuleDialogSubmitUtil.jsp?mode=copy&ProductId="+ProductId;
		 			  document.RuleForm.submit();
		 			  getTopWindow().getWindowOpener().location.href = getTopWindow().getWindowOpener().location.href;
					  window.getTopWindow().closeWindow();	
			    	}
		       }
	    	}else{	
	    		alert(ERROR_PROCESS_INPROGRESS);
	    	}

	    }
        else{
    		if(isLeftExpValid =="false"  && isRightExpValid=="false" ){
				alert(ERROR_MESSAGE_FOR_INVALID_LEFT_RIGHT_EXP);
			}else if( isLeftExpValid=="false" ){
				alert(ERROR_MESSAGE_FOR_INVALID_LEFT_EXP);
			}else{			
				alert(ERROR_MESSAGE_FOR_INVALID_RIGHT_EXP);	
			}
	    }
	}
  }
  
  
 function fnValidate(mode)
  {
	//Check the Configuration/Design Rule validation
	
	 var vRuleClassificationIndex = document.getElementById('ruleClassification').selectedIndex;
	 var vFeatureTypeIndex = document.getElementById('featureType').selectedIndex;
 	 //var vRuleClassificationSet = document.getElementById('ruleClassification').options[vRuleClassificationIndex].value;
	 var vRuleClassificationSet = document.getElementById('ruleClassification').value;
	 //alert("fnValidate11111111......."+vRuleClassificationSet);
	
	lstLeftExpression =  new Array;
	lstRightExpression =  new Array;
	var vParentform = document.getElementById("RuleForm");
	
    var description  = getTopWindow().document.getElementsByName('txtDescription')[0];
    var nameField = getTopWindow().document.getElementsByName('txtRuleName')[0];
    var autoName = false;
    var mandatory = getTopWindow().document.getElementsByName('mandatory')[0].value; 
    if(mandatory!=""){
    	
    	document.getElementById('hMandatory').value = mandatory;
    }
    
    var fieldNameValue = getTopWindow().document.getElementsByName('txtRuleName')[0].value;
    if(mode!="edit"){
    	autoName = getTopWindow().document.getElementsByName('autoName')[0].checked;
    }
    
    //var fieldNameValue = formName.txtRuleName.value; 
    var fieldName1 = "Name";
    var empty =""; 
    
    // for name Field validation  
    // IR-172238V6R2013x oeo We always want to send the field name through validation in edit mode
    // (where autoname does not exist)
    
    if((fieldNameValue != empty && autoName == false) || mode=="edit")
    {  	
    	if(!basicValidation(vParentform,nameField,fieldName1,true,true,true,false,false,false,false))
        {
     	    return false;
 	    }
    }
 	
    //For Description Filed Validation
    /*
    if(!basicValidation(vParentform,description,DESCRIPTION,true,false,true,false,false,false,checkBadChars))
    {
       return false;
    }
   */
    
    var selectedLeftActual = "" ;
    var selectedLeftText = "" ;
    var selectedRightActual = "" ;
    var selectedRightText = "" ;
    
    var selectedLeftTextRC = "" ;
    var selectedRightTextRC = "" ;
    var selectedLeftTextFeatType = "" ;
    var selectedRightTextFeatType = "" ;
    
    var tmpi = 0 ;
    
    if (document.getElementById("LExp").options.length != 0 )
    {
    	for(var i=0 ; i<document.getElementById("LExp").options.length ; i++)
    	{
    		selectedLeftText = selectedLeftText + document.getElementById("LExp").options[i].text + " ";
        	selectedLeftActual = selectedLeftActual + document.getElementById("LExp").options[i].value + " ";
        	
        	var strLExpOption = document.getElementById("LExp").options[i];
        	
        	var vFeatureType = document.getElementById("LExp").options[i].getAttribute('FeatureType');
        	
        	selectedLeftTextRC = selectedLeftTextRC + document.getElementById("ruleClassification").value + " ";
        	selectedLeftTextFeatType = selectedLeftTextFeatType + document.getElementById("featureType").value + " ";        	
        	
        	if(strLExpOption.value != "AND" && strLExpOption.value != "OR" && strLExpOption.value != "NOT" && strLExpOption.value != "(" && strLExpOption.value != ")")
        	{
        		if( (vRuleClassificationSet == 'Configuration' && vFeatureType == 'relationship_CONFIGURATIONSTRUCTURES')
        			  || vRuleClassificationSet == 'Logical')
        		{
        			lstLeftExpression[i] = "TRUE";	
        			
        		}else{
        		   alert(ERROR_MESSAGE_FOR_MARKETING_RULE_LEFT_EXP);
        		   return false;
        		}
            }
            else
            {
            	lstLeftExpression[i] = strLExpOption.value;
            }
    	}
    }
    else
    {
 	  alert(ERROR_MESSAGE_FOR_LEFT_EXP);
 	  return false;
    }
    
    if(document.getElementById("RExp").options.length != 0 )
    {
    	for(var i=0 ; i<document.getElementById("RExp").options.length ; i++)
    	{
    		selectedRightText = selectedRightText + document.getElementById("RExp").options[i].text + " ";
        	selectedRightActual = selectedRightActual + document.getElementById("RExp").options[i].value + " ";	
        	
        	var strRExpOption = document.getElementById("RExp").options[i];
        	
        	var vFeatureType = document.getElementById("RExp").options[i].getAttribute('FeatureType');
        	selectedRightTextRC = selectedRightTextRC + document.getElementById("ruleClassification").value + " ";
        	selectedRightTextFeatType = selectedRightTextFeatType + document.getElementById("featureType").value + " ";    
        	
        	if(strRExpOption.value != "AND" && strRExpOption.value != "OR" && strRExpOption.value != "NOT" && strRExpOption.value != "(" && strRExpOption.value != ")")
        	{
        		if( (vRuleClassificationSet == 'Configuration' && vFeatureType == 'relationship_CONFIGURATIONSTRUCTURES')
          			  || (vRuleClassificationSet == 'Logical'&& (vFeatureType == 'relationship_LOGICALSTRUCTURES'||vFeatureType == 'nonCFCOType')))
          		{
        			lstRightExpression[i] = "TRUE";
          			
          		}else{
          		   if(vRuleClassificationSet == 'Configuration'){
          			 alert(ERROR_MESSAGE_FOR_MARKETING_RULE_RIGHT_EXP);
            		   return false;
          		   }else{
          			 alert(ERROR_MESSAGE_FOR_DESIGN_RULE_RIGHT_EXP);
            		   return false;
          		   }
          		   
          		}
            }
            else
            {
            	lstRightExpression[i] = strRExpOption.value;
            }
    	}
    }
 	else
 	{
 		alert(ERROR_MESSAGE_FOR_RIGHT_EXP);
 		return false;
 	}
     
     
     passLeftHiddenExpId = selectedLeftActual ;
     passLeftHiddenExpText = selectedLeftText ;
     leftExpVal = passLeftHiddenExpText;
     
     passLERuleClassValue= selectedLeftTextRC ;
  	 passLEFeatTypeValue=selectedLeftTextFeatType;
  	
 	passRightHiddenExpId = selectedRightActual;
 	passRightHiddenExpText = selectedRightText ; 
 	rightExpVal = passRightHiddenExpText;
 	
 	passRERuleClassValue=selectedRightTextRC;
 	passREFeatTypeValue=selectedRightTextFeatType;
 	
    
 	if((leftExpVal.trim()==rightExpVal.trim())&&(passRightHiddenExpId.trim()==passLeftHiddenExpId.trim()))
 	{		 
 		alert(ERROR_MESSAGE_FOR_SIMILAR_EXP);
 		return false;
 	}
 		  
 	Name = vParentform.txtRuleName.value;
 	if (Name == "")
 	{
 	  if(vParentform.autoName.checked == false)
 	  {
 		alert(ERROR_MESSAGE_FOR_NAME_ENTRY);
 		return false ;
       }
 	}
 	
     return true;
  }

 //Function to compute completed rule for create rule
function computedRule(tmpOperator,textarea,calledFrom)
{
    
    var vParentform = document.getElementById("RuleForm");
    var ContextName = vParentform.hContextName.value;

    var passComparisonParam = "" ;
    passComparisonParam = document.getElementById('comparisonOperator').value;
   
    
    var rightExp = document.getElementById('RExp');
    var leftExp = document.getElementById('LExp');
    var leftExpText = "";
    var rightExpText = "";
	

	for (var i = 0; i < leftExp.length; i++){
		leftExpText = leftExpText + document.getElementById("LExp").options[i].text + "\n";
    }
    
	for (var i = 0; i < rightExp.length; i++){
		rightExpText = rightExpText + document.getElementById("RExp").options[i].text + "\n";
    }
      
                
    var vUrlParam = "mode=getExpressionBCR&leftExp="+encodeURIComponent(leftExpText)+"&rightExp="+encodeURIComponent(rightExpText)+"&compType="+passComparisonParam;
	var vRes = emxUICore.getDataPost("../configuration/RuleDialogValidationUtil.jsp", vUrlParam);
    var iIndex = vRes.indexOf("bcrExp=");
    var iLastIndex = vRes.indexOf("#");
    var bcrExp = vRes.substring(iIndex+"bcrExp=".length , iLastIndex );
    computeRule = bcrExp ;
	var objDIV = document.getElementById("divRuleText"); 
	objDIV.innerHTML = computeRule.toString();
   	
}

function displayComputedRule(vMode){
 
      var leftExpText = "";
      var rightExpText = "";
      var passComparisonParam = "" ;
      
      passComparisonParam = document.getElementById('comparisonOperator').value;

      
      var leftExp = document.getElementById('LExp');
      for (var i = 0; i < leftExp.length; i++){
        leftExpText = leftExpText + leftExp.options[i].text + "\n";
      }
        
      var rightExp = document.getElementById('RExp');
      for (var i = 0; i < rightExp.length; i++){
         rightExpText = rightExpText + rightExp.options[i].text + "\n ";
         if (i < rightExp.length - 1){
             rightExpText = rightExpText;
         }
      }
      var vUrlParam = "mode=getExpressionBCR&leftExp="+encodeURIComponent(leftExpText)+"&rightExp="+encodeURIComponent(rightExpText)+"&compType="+passComparisonParam;
      var vRes = emxUICore.getDataPost("../configuration/RuleDialogValidationUtil.jsp", vUrlParam);
      var iIndex = vRes.indexOf("bcrExp=");
      var iLastIndex = vRes.indexOf("#");
      var bcrExp = vRes.substring(iIndex+"bcrExp=".length , iLastIndex );
      computeRule = bcrExp ;
        
        var objDIV = document.getElementById("divRuleText");
        objDIV.innerHTML = computeRule.toString();
    
   }
   
