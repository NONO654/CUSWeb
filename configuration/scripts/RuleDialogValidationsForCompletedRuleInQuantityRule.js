
//RuleDialogValidationsForCompletedRuleInQuantityRule.js
//Includes all the operations to be performed on Rule Dilaog Page..which may vary depending upon the Type of rule.
/*Functions included:
 * submitRule
 * fnValidate
 */
 

function displayComputedRule(vMode){
	var ContextName = document.getElementById("RuleForm"). hContextName.value;	
			var usageQuantityField = document.getElementById("RuleForm").txtquantity;
		var usageQuantity  = usageQuantityField.value;
		
		var isAlphaNumeric = null;
		if(usageQuantity != ""){
		    isAlphaNumeric = usageQuantity.match((/[a-zA-Z]/));
		}
	    
		if(isAlphaNumeric){
	        alert(ERROR_MESSAGE_FOR_QUANTITY_USAGE);
	        usageQuantityField.value = "";
	        usageQuantityField.focus();
	    }else if(usageQuantity != ""){
	    	isAlphaNumeric = basicValidation('RuleForm',usageQuantityField,usageQuantityField.id,false,false,true,false,false,false,false);
	    	if(!isAlphaNumeric){
	    		alert(ERROR_MESSAGE_FOR_QUANTITY_USAGE);
	            usageQuantityField.value = "";
	            usageQuantityField.focus();        	
	    	}    	
	    	else{
	    		if(isNaN(usageQuantity))
	    			{
	    			alert(ERROR_MESSAGE_FOR_QUANTITY_USAGE);
		            usageQuantityField.value = "";
		            usageQuantityField.focus();
	    			}
	    		if(usageQuantity <0)
	    			{
	    			alert(ERROR_MESSAGE_FOR_QUANTITY_USAGE);
		            usageQuantityField.value = "";
		            usageQuantityField.focus();
	    			}
	    	}
	    }
	  
		var vUsageQuantity = document.getElementById("RuleForm").txtquantity.value; 
	  
		var rightExpText = "";
	   //if(vMode=="edit" ||vMode=="copy"){
	       var rightExp = document.getElementById('RExp');
	       for (var i = 0; i < rightExp.length; i++){
	    	   rightExpText = rightExpText + rightExp.options[i].text + "\n ";
	          if (i < rightExp.length - 1){
	              rightExpText = rightExpText;
	          }
	       }
	   // }
	   if(rightExpText!="")
		   rightExpText="("+rightExpText+")";
	   
	    //var url="../configuration/RuleDialogValidationUtil.jsp?mode=getExpressionQR&leftExp="+encodeURIComponent(ContextName)+"&rightExp="+encodeURIComponent(rightExpText)+"&quantity="+vUsageQuantity;
	    var url="../configuration/RuleDialogValidationUtil.jsp?mode=getExpressionQR";
	    var queryString = "leftExp="+encodeURIComponent(ContextName)+"&rightExp="+encodeURIComponent(rightExpText)+"&quantity="+vUsageQuantity;
	    var vRes = emxUICore.getDataPost(url,queryString);
	    var iIndex = vRes.indexOf("qrExp=");
	    var iLastIndex = vRes.indexOf("#");
	    var bcrExp = vRes.substring(iIndex+"qrExp=".length , iLastIndex );
	    computeRule = bcrExp ;
	    var objDIV = document.getElementById("divRuleText");
	    objDIV.innerHTML = computeRule
	 }
	    


//Function to compute completed rule for create rule
 function computedRule(tmpOperator,textarea,calledFrom)
 {
	 var rightExpText = "";
	 var rightExp = document.getElementById('RExp');

	 for (var i = 0; i < rightExp.length; i++)
     {
		rightExpText = rightExpText + rightExp.options[i].text + "\n ";
		if (i < rightExp.length - 1)
	    {
			 rightExpText = rightExpText;
		}
	 }
	 if(rightExpText!="")
		 rightExpText="("+rightExpText+")";
	 var ContextName = document.getElementById("RuleForm"). hContextName.value;	
	 var vUsageQuantity = document.getElementById("RuleForm").txtquantity.value;
	 //var url="../configuration/RuleDialogValidationUtil.jsp?mode=getExpressionQR&leftExp="+encodeURIComponent(ContextName)+"&rightExp="+encodeURIComponent(rightExpText)+"&quantity="+vUsageQuantity;
	 var url="../configuration/RuleDialogValidationUtil.jsp?mode=getExpressionQR";
	 var queryString = "leftExp="+encodeURIComponent(ContextName)+"&rightExp="+encodeURIComponent(rightExpText)+"&quantity="+vUsageQuantity;
	 var vRes = emxUICore.getDataPost(url,queryString);
	 var iIndex = vRes.indexOf("qrExp=");
	 var iLastIndex = vRes.indexOf("#");
	 var bcrExp = vRes.substring(iIndex+"qrExp=".length , iLastIndex );
	 computeRule = bcrExp ;
	 //For CompletedRule
	 var objDIV = document.getElementById("divRuleText"); 
	 var ruleTextArea = document.RuleForm.completedRule;
	 objDIV.innerHTML = computeRule.toString();
	 
 } 

 var lstLeftExpression =  new Array;
 var lstRightExpression =  new Array;
function submitRule(mode,submitURL)
  {
	if(fnValidate(mode)){
		var ruleNameType = "";
		var url = "" ;
				 
		var vParentform = document.getElementById("RuleForm");
		var ProductId = vParentform.hContextId.value; 
		var ContextType = vParentform.hContextType.value;
		
		document.getElementById('hrightExpObjIds').value = passRightHiddenExpId;
		document.getElementById('hrightExpObjTxt').value = passRightHiddenExpText;
	    
	    //url="../configuration/RuleDialogValidationUtil.jsp?mode=ValidateExpression&ProductId="+ProductId+"&lstLeftExpression="+lstLeftExpression+"&lstRightExpression="+lstRightExpression;
		url="../configuration/RuleDialogValidationUtil.jsp?mode=ValidateExpression";
		var queryString = "ProductId="+ProductId+"&lstLeftExpression="+lstLeftExpression+"&lstRightExpression="+lstRightExpression;
    
	    var vtest = emxUICore.getDataPost(url,queryString);
	    var iIndex = vtest.indexOf("LeftExpression=");
	    var iLastIndex = vtest.indexOf(",");
	    var isLeftExpValid = vtest.substring(iIndex+"LeftExpression=".length , iLastIndex );
	    isLeftExpValid  = trim(isLeftExpValid );

	    vtest = vtest.substring(iLastIndex+1 , vtest.length );
	    iIndex = vtest.indexOf("RightExpression=");		
	    iLastIndex = vtest.indexOf(";");		
	    var isRightExpValid = vtest.substring(iIndex+"RightExpression=".length , iLastIndex );
	    isRightExpValid  = trim(isRightExpValid );
	    
	    if(isRightExpValid == "true"){
				
				var type ='<%=strContextType%>';	   
			    if(type == '<%=ConfigurationConstants.TYPE_PRODUCT_VARIANT%>')
			    {
			    	document.getElementById('hMandatory').value ="";
			    }
			    
			   if(mode=="create"){
			    	if(submitURL!=null){
			    		document.RuleForm.action = submitURL+"&ProductId="+ProductId+"&ContextType"+ContextType;
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
				    		document.RuleForm.action = submitURL+"&ProductId="+ProductId+"&ContextType="+ContextType;
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
	    }
        else{
    					
				alert(ERROR_MESSAGE_FOR_INVALID_RIGHT_EXP);	
			
	    }
	}
  }
  
  
 function fnValidate(mode)
  {
	lstLeftExpression =  new Array;
	lstRightExpression =  new Array;
	var vParentform = document.getElementById("RuleForm");
	
    var description  = getTopWindow().document.getElementsByName('txtDescription')[0];
    var nameField = getTopWindow().document.getElementsByName('txtRuleName')[0]; 

    var fieldNameValue = getTopWindow().document.getElementsByName('txtRuleName')[0].value;
    if(mode!="edit")
    {
    	var autoName = getTopWindow().document.getElementsByName('autoName')[0].checked;
    }
    var fieldName1 = "Name";
    var empty =""; 
    // for name Field validation  
    if((fieldNameValue != empty && autoName == false) || mode=="edit"){  	
      if(!basicValidation(vParentform,nameField,fieldName1,true,true,true,false,false,false,false)){
     	 return false;
 	  }
    }
    var Name = fieldNameValue;
    
    if (Name == ""){
		if(autoName == false){
			alert(RULE_NAME_SELECT);
			return false ;
		}
    }
    if(getTopWindow().document.getElementById("txtquantity").value==""){
    	alert(ERROR_MESSAGE_FOR_QUANTITY);
    	return false;
    }	
    var selectedLeftActual = "" ;
    var selectedLeftText = "" ;
    var selectedRightActual = "" ;
    var selectedRightText = "" ;
    var tmpi = 0 ;
     
    if(document.getElementById("RExp").options.length != 0 ){
    	for(var i=0 ; i<document.getElementById("RExp").options.length ; i++){
    		selectedRightText = selectedRightText + document.getElementById("RExp").options[i].text + " ";
        	selectedRightActual = selectedRightActual + document.getElementById("RExp").options[i].value + " ";	
        	
        	var strRExpOption = document.getElementById("RExp").options[i];
        	if(strRExpOption.value != "AND" && strRExpOption.value != "OR" && strRExpOption.value != "NOT" && strRExpOption.value != "(" && strRExpOption.value != ")"){
        		lstRightExpression[i] = "TRUE"
            }else{
            	lstRightExpression[i] = strRExpOption.value;
                 }
    	}
    }
    
    passRightHiddenExpId = selectedRightActual;
 	passRightHiddenExpText = selectedRightText ; 
 	rightExpVal = passRightHiddenExpText;
 		  
 	Name = vParentform.txtRuleName.value;
 	if (Name == ""){
 	  if(vParentform.autoName.checked == false){
 		alert(ERROR_MESSAGE_FOR_NAME_ENTRY);
 		return false ;
       }
 	}
     return true;
  }
