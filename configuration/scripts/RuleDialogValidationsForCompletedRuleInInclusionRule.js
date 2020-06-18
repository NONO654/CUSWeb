
//RuleDialogValidationsForCompletedRule.js
//Includes all the operations to be performed on Rule Dilaog Page..which may vary depending upon the Type of rule.
/*Functions included:
 * createNamedElement
 * submitRule
 * fnValidate
 */


 var vDescriptionValue = "";
    var vVaultValue = "";
    var vRDO = "";
    
	function getRuleBasics(DVValuesAddedMap,vMode)
     {
		return true;
     }
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
 

var lstRightExpression =  new Array;

var isSubmitted =  false;
function submitRule(mode,submitURL)
  {
	
	if(fnValidate()){
		var ruleNameType = "";
		var url = "" ;
				 
		var vParentform = document.getElementById("RuleForm");
		var ProductId = vParentform.hContextId.value; 
		var ContextType = vParentform.hContextType.value;
		  		 
		document.getElementById('hrightExpObjIds').value = passRightHiddenExpId;
		document.getElementById('hrightExpObjTxt').value = passRightHiddenExpText;
	    
	    url="../configuration/RuleDialogValidationUtil.jsp?mode=ValidateExpression";
	    var queryString = "ProductId="+ProductId+"&lstRightExpression="+lstRightExpression; 
	    var vtest = emxUICore.getDataPost(url,queryString);
	    iIndex = vtest.indexOf("RightExpression=");		
	    iLastIndex = vtest.indexOf(";");		
	    var isRightExpValid = vtest.substring(iIndex+"RightExpression=".length , iLastIndex );
	    isRightExpValid  = trim(isRightExpValid );
	    
	    if(isRightExpValid == "true"){
	    	if(!isSubmitted){
		    	isSubmitted =  true;
				var type ='<%=strContextType%>';	   
			    if(type == '<%=ConfigurationConstants.TYPE_PRODUCT_VARIANT%>')
			    {
			    	document.getElementById('hMandatory').value ="";
			    }
			    
			   if(mode=="create"){
			    	if(submitURL!=null){
			    		submitURL = submitURL.replace("|","&");
			    		submitURL = submitURL.replace("|","&");
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
			   else if(mode=="copy"){}
	    	}else{	
	    		alert(ERROR_PROCESS_INPROGRESS);
	    	}
	    }
        else{
    		
				alert(ERROR_MESSAGE_FOR_INVALID_RIGHT_EXP);	
			
	    }
	}
  }
  
  
 function fnValidate(){
	lstRightExpression =  new Array;
	var vParentform = document.getElementById("RuleForm");
    
	if(!(checkForExpBadChar(vParentform,document.getElementById("RExp"),RIGHT_EXP))){
	 return false;
    }
	
    var selectedRightActual = "" ;
    var selectedRightText = "" ;
    var tmpi = 0 ;
       
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
 		//alert(ERROR_MESSAGE_FOR_RIGHT_EXP);
 		//return false;
 	}
     
     
 	passRightHiddenExpId = selectedRightActual;
 	passRightHiddenExpText = selectedRightText ; 
 	rightExpVal = passRightHiddenExpText;
 	
     return true;
  }

 var passComparisonParam		= "" ;
 var tempInclusion = "Inclusion";
 var tempExclusion = "Exclusion";
 
//Function to compute completed rule for create rule
function computedRule(tmpOperator,textarea,calledFrom)
{
    var rightExp = document.getElementById('RExp');
    var vParentform = document.getElementById("RuleForm");
    var ContextName = vParentform.hContextNameForIR.value;
    					
	
	passComparisonParam = document.getElementById('comparisonOperator').value;
	
	var rightExpText = "";
	for (var i = 0; i < rightExp.length; i++){
		rightExpText = rightExpText + document.getElementById("RExp").options[i].text + "\n";
    }
    //var url="../configuration/RuleDialogValidationUtil.jsp?mode=getExpressionIR&leftExp="+encodeURIComponent(ContextName)+"&rightExp="+encodeURIComponent(rightExpText)+"&compType="+passComparisonParam;
    //var vRes = emxUICore.getData(url);
	var url="../configuration/RuleDialogValidationUtil.jsp?mode=getExpressionIR";
	var queryString = "leftExp="+encodeURIComponent(ContextName)+"&rightExp="+encodeURIComponent(rightExpText)+"&compType="+passComparisonParam;
	var vRes = emxUICore.getDataPost(url,queryString);
    var iIndex = vRes.indexOf("irExp=");
    var iLastIndex = vRes.indexOf("#");
    var irExp = vRes.substring(iIndex+"irExp=".length , iLastIndex );
    computeRule = irExp ;
	var objDIV = document.getElementById("divRuleText"); 
	objDIV.innerHTML = computeRule.toString();
   	
}

function displayComputedRule(vMode){
	
	var rightExp = document.getElementById('RExp');
	if(rightExp!=null && rightExp!=""){
		var vParentform = document.getElementById("RuleForm");
		var ContextName = vParentform.hContextNameForIR.value;
		passComparisonParam = document.getElementById('comparisonOperator').value;
		var rightExpText = "";
		for (var i = 0; i < rightExp.length; i++){
			rightExpText = rightExpText + document.getElementById("RExp").options[i].text + "\n";
	    }
		
	    //var url="../configuration/RuleDialogValidationUtil.jsp?mode=getExpressionIR&leftExp="+encodeURIComponent(ContextName)+"&rightExp="+encodeURIComponent(rightExpText)+"&compType="+passComparisonParam;
	    //var vRes = emxUICore.getData(url);
		var url="../configuration/RuleDialogValidationUtil.jsp?mode=getExpressionIR";
		var queryString = "leftExp="+encodeURIComponent(ContextName)+"&rightExp="+encodeURIComponent(rightExpText)+"&compType="+passComparisonParam;
		var vRes = emxUICore.getDataPost(url,queryString);
	    var iIndex = vRes.indexOf("irExp=");
	    var iLastIndex = vRes.indexOf("#");
	    var irExp = vRes.substring(iIndex+"irExp=".length , iLastIndex );
	    computeRule = irExp ;
	    var objDIV = document.getElementById("divRuleText"); 
		objDIV.innerHTML = computeRule.toString();
	}
 }

function emptyRuleExpression() {
	
	return true;	
	}
