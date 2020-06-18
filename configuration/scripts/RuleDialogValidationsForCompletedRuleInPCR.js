
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
 
var passComparisonParam		= "";

//Function to compute completed rule for create rule
function computedRule(tmpOperator,textarea,calledFrom)
{
	 var leftExpText = "";
	 var rightExpText = "";
	 var logicalOperator = tmpOperator;
	  
	 passComparisonParam = document.getElementById('comparisonOperator').value;
	 
	 if (passComparisonParam == "Requires" || passComparisonParam == "Co-Dependent")
     {          
		 document.RuleForm.compType[0].disabled = true ;                          
     }else
     {          	                  
    	 document.RuleForm.compType[0].disabled = false ; 					
     }
	 
	 if(calledFrom=="same")
	 {
		 var leftExp = document.getElementById('LExp');
		 for (var i = 0; i < leftExp.length; i++)
		 {
		   	leftExpText = leftExpText + leftExp.options[i].text + "\n";
		 }
		 
		 var rightExp = document.getElementById('RExp');
		 for (var i = 0; i < rightExp.length; i++)
        {
			rightExpText = rightExpText + rightExp.options[i].text + "\n ";
			if (i < rightExp.length - 1)
		    {
				 rightExpText = rightExpText;
			}
		 }
       //var url="../configuration/RuleDialogValidationUtil.jsp?mode=getExpressionPCR&leftExp="+encodeURIComponent(leftExpText)+"&rightExp="+encodeURIComponent(rightExpText)+"&compType="+passComparisonParam;
       //var vRes = emxUICore.getData(url);
		 
	   var url="../configuration/RuleDialogValidationUtil.jsp?mode=getExpressionPCR";
	   var queryString = "leftExp="+encodeURIComponent(leftExpText)+"&rightExp="+encodeURIComponent(rightExpText)+"&compType="+passComparisonParam;
	   var vRes = emxUICore.getDataPost(url,queryString);
       var iIndex = vRes.indexOf("pcrExp=");
       var iLastIndex = vRes.indexOf("#");
       var pcrExp = vRes.substring(iIndex+"pcrExp=".length , iLastIndex );
       computeRule = pcrExp ;
		 var objDIV = document.getElementById("divRuleText"); 
	 }
	 else
	 {
		 var leftExp = document.getElementById('LExp');
		 for (var i = 0; i < leftExp.length; i++)
		 {
		   leftExpText = leftExpText + leftExp.options[i].text + "\n";
		 }
		
		//if(document.REform.RightExpression)
		//{
          var rightExp = document.getElementById('RExp');
		//}
		if(rightExp)
		{
		    for (var i = 0; i < rightExp.length; i++)
		    {
		    	rightExpText = rightExpText + rightExp.options[i].text + "\n ";
				if (i < rightExp.length - 1)
				{
					rightExpText = rightExpText;
				}
			}
		}
		
		
		var logicalOperator = tmpOperator;
		passComparisonParam = document.getElementById('comparisonOperator').value;
		 
	       //var url="../configuration/RuleDialogValidationUtil.jsp?mode=getExpressionPCR&leftExp="+encodeURIComponent(leftExpText)+"&rightExp="+encodeURIComponent(rightExpText)+"&compType="+passComparisonParam;
	       //var vRes = emxUICore.getData(url);
		   var url="../configuration/RuleDialogValidationUtil.jsp?mode=getExpressionPCR";
		   var queryString = "leftExp="+encodeURIComponent(leftExpText)+"&rightExp="+encodeURIComponent(rightExpText)+"&compType="+passComparisonParam;
		   var vRes = emxUICore.getDataPost(url,queryString);
	       var iIndex = vRes.indexOf("pcrExp=");
	       var iLastIndex = vRes.indexOf("#");
	       var pcrExp = vRes.substring(iIndex+"pcrExp=".length , iLastIndex );
	       computeRule = pcrExp ;
			var objDIV = document.getElementById("divRuleText");
	    }
   	objDIV.innerHTML = computeRule.toString();
} 
 var lstLeftExpression =  new Array;
 var lstRightExpression =  new Array;
 var isSubmitted =  false;
function submitRule(mode,submitURL)
  {
	if(fnValidate(mode)){
		var ruleNameType = "";
		var url = "" ;
				 
		passComparisonParam = document.getElementById('comparisonOperator').value;
		document.getElementById('comparisonOperator').value = passComparisonParam;
		passComparisonParam = document.getElementById('compType').value;
		document.getElementById('compType').value = passComparisonParam;
			
		var vParentform = document.getElementById("RuleForm");
		var ProductId = vParentform.hContextId.value; 
		var ContextType = vParentform.hContextType.value;
		
		document.getElementById('hleftExpObjIds').value = passLeftHiddenExpId;
		document.getElementById('hleftExpObjTxt').value = passLeftHiddenExpText;
	     
	    
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
			   else if(mode=="copy"){}
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
	lstLeftExpression =  new Array;
	lstRightExpression =  new Array;
	var vParentform = document.getElementById("RuleForm");
	
    var description  = getTopWindow().document.getElementsByName('txtDescription')[0];
    var nameField = getTopWindow().document.getElementsByName('txtRuleName')[0]; 
    
    var fieldNameValue = getTopWindow().document.getElementsByName('txtRuleName')[0].value;
    var autoName  =  false;    
    if(mode!="edit"){
    	 autoName = getTopWindow().document.getElementsByName('autoName')[0].checked;
    }
    //var fieldNameValue = formName.txtRuleName.value; 
    var fieldName1 = "Name";
    var empty =""; 
    
    if(fieldNameValue != empty && autoName == false){  	
  	 if(!basicValidation(vParentform,nameField,fieldName1,true,true,true,false,false,false,false)){
  		 
  		 return false;
  	  }
  	}
  	 
    //For Description Filed Validation
  	 if(!basicValidation(vParentform,description,DESCRIPTION,true,false,true,false,false,false,checkBadChars)){
  		 
  		 return false;
    }
    
    var selectedLeftActual = "" ;
    var selectedLeftText = "" ;
    var selectedRightActual = "" ;
    var selectedRightText = "" ;
    var tmpi = 0 ;
    
    if (document.getElementById("LExp").options.length != 0 )
    {
    	for(var i=0 ; i<document.getElementById("LExp").options.length ; i++)
    	{
    		selectedLeftText = selectedLeftText + document.getElementById("LExp").options[i].text + " ";
        	selectedLeftActual = selectedLeftActual + document.getElementById("LExp").options[i].value + " ";
        	var strLExpOption = document.getElementById("LExp").options[i];
        	if(strLExpOption.value != "AND" && strLExpOption.value != "OR" && strLExpOption.value != "NOT" && strLExpOption.value != "(" && strLExpOption.value != ")")
        	{
        		lstLeftExpression[i] = "TRUE"
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
        	if(strRExpOption.value != "AND" && strRExpOption.value != "OR" && strRExpOption.value != "NOT" && strRExpOption.value != "(" && strRExpOption.value != ")")
        	{
        		lstRightExpression[i] = "TRUE"
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
     
 	passRightHiddenExpId = selectedRightActual;
 	passRightHiddenExpText = selectedRightText ; 
 	rightExpVal = passRightHiddenExpText;

    
    //var url="../configuration/RuleDialogValidationUtil.jsp?mode=ValidatePCRExpression&strLeftExpression="+selectedLeftActual+"&strRightExpression="+selectedRightActual;
 	var url="../configuration/RuleDialogValidationUtil.jsp?mode=ValidatePCRExpression";
 	var queryString  = "strLeftExpression="+selectedLeftActual+"&strRightExpression="+selectedRightActual;
    var vtest = emxUICore.getDataPost(url,queryString);
    var iIndex = vtest.indexOf("bExpSame=");		
    var iLastIndex = vtest.indexOf(";");		
    var bExpSame = vtest.substring(iIndex+"bExpSame=".length , iLastIndex );
    bExpSame  = trim(bExpSame );
    
 	if(bExpSame=="true" )
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
 
 
 function displayComputedRule(vMode){
     if(vMode=="edit"){
       var leftExpText = "";
       var rightExpText = "";
       var passComparisonParam = "" ;
       var tempIncom = COMPARISON_TYPE_INCOMPATIBLE;
       var tempCodept = COMPARISON_TYPE_CO_DEP;
       var tempReq = COMPARISON_TYPE_REQUIRES;
       var tempComp = COMPARISON_TYPE_COMPATIBLE;

       passComparisonParam = document.getElementById('comparisonOperator').value;
       passComparisonParam=passComparisonParam.trim();
       if (passComparisonParam == "Requires" || passComparisonParam == "Co-Dependent"){          
    		 document.RuleForm.compType[0].disabled = true ;                          
       }else{          	                  
        	 document.RuleForm.compType[0].disabled = false ; 					
       }
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
       //var url="../configuration/RuleDialogValidationUtil.jsp?mode=getExpressionPCR&leftExp="+encodeURIComponent(leftExpText)+"&rightExp="+encodeURIComponent(rightExpText)+"&compType="+passComparisonParam;
       var url="../configuration/RuleDialogValidationUtil.jsp?mode=getExpressionPCR";
       var queryString = "leftExp="+encodeURIComponent(leftExpText)+"&rightExp="+encodeURIComponent(rightExpText)+"&compType="+passComparisonParam; 
       var vRes = emxUICore.getDataPost(url,queryString);
       var iIndex = vRes.indexOf("pcrExp=");
       var iLastIndex = vRes.indexOf("#");
       var pcrExp = vRes.substring(iIndex+"pcrExp=".length , iLastIndex );
       computeRule = pcrExp ;                    
         var objDIV = document.getElementById("divRuleText");
         objDIV.innerHTML = computeRule.toString();
      }
    }
    
