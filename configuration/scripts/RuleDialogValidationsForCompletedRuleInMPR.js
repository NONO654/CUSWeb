
//RuleDialogValidationsForCompletedRuleInMPR.js
//Includes all the operations to be performed on Rule Dilaog Page..which may vary depending upon the Type of rule.
/*Functions included:
 * submitRule
 * fnValidate
 */
 
 function displayComputedRule(vMode){
		 if(vMode=="edit" ||vMode=="copy"){
	       var leftExpText = "";
	       var rightExpText = "";
	       
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
		   // var url="../configuration/RuleDialogValidationUtil.jsp?mode=getExpressionMPR&leftExp="+encodeURIComponent(leftExpText)+"&rightExp="+encodeURIComponent(rightExpText)+"&compType="+passComparisonParam;
	       var url="../configuration/RuleDialogValidationUtil.jsp?mode=getExpressionMPR";
		    //var vRes = emxUICore.getData(url);
	       var queryString = "leftExp=" +encodeURIComponent(leftExpText)+ "&rightExp=" +encodeURIComponent(rightExpText)+ "&compType="+passComparisonParam+"";
		    
		    //var vRes = emxUICore.getData(url);
		     var vRes = emxUICore.getDataPost(url, queryString);
		    
	       
		    var iIndex = vRes.indexOf("mprExp=");
		    var iLastIndex = vRes.indexOf("#");
		    var mprExp = vRes.substring(iIndex+"mprExp=".length , iLastIndex );
		    computeRule = mprExp ;
		    var objDIV = document.getElementById("divRuleText"); 
	        objDIV.innerHTML = computeRule.toString();
	      }
	    }
	    

 
 var lstLeftExpression =  new Array;
 var lstRightExpression =  new Array;
 var isSubmitted =  false;
//Function to compute completed rule for create rule
 function computedRule(tmpOperator,textarea,calledFrom)
 {
	 var leftExpText = "";
	 var rightExpText = "";
	 
		 var leftExp = document.getElementById('LExp');
		 for (var i = 0; i < leftExp.length; i++){
		   	leftExpText = leftExpText + leftExp.options[i].text + "\n";
		 }
		 
		 var rightExp = document.getElementById('RExp');
		 for (var i = 0; i < rightExp.length; i++){
			if(i==0){
			   rightExpText = rightExpText + rightExp.options[i].text + "\n ";
			}else if(i>0){
                 rightExpText = rightExpText+ " AND "+ rightExp.options[i].text + "\n ";
            }else if (i < rightExp.length - 1){
				rightExpText = rightExpText;
			}
		 }
			
		    //var url="../configuration/RuleDialogValidationUtil.jsp?mode=getExpressionMPR&leftExp="+encodeURIComponent(leftExpText)+"&rightExp="+encodeURIComponent(rightExpText)+"&compType="+passComparisonParam;
            var url="../configuration/RuleDialogValidationUtil.jsp?mode=getExpressionMPR";		    
		    
		    var queryString = "leftExp=" +encodeURIComponent(leftExpText)+ "&rightExp=" +encodeURIComponent(rightExpText)+ "&compType="+passComparisonParam+"";
		    
		    //var vRes = emxUICore.getData(url);
		     var vRes = emxUICore.getDataPost(url, queryString);
		    
		    var iIndex = vRes.indexOf("mprExp=");
		    var iLastIndex = vRes.indexOf("#");
		    var mprExp = vRes.substring(iIndex+"mprExp=".length , iLastIndex );
		    computeRule = mprExp ;
		    //computeRule = "<B>"+leftExpText + "</B> "+FEATURE_CHOICES+" <B>"+rightExpText+"</B>"+ ") " ;
		 var objDIV = document.getElementById("divRuleText"); 
    	objDIV.innerHTML = computeRule.toString();
 } 


 function submitRule(mode,submitURL){
	 
 	if(fnValidate(mode)){
 		
 		var ruleNameType = "";
 		var url = "" ;
 		
 		var vParentform = document.getElementById("RuleForm");
 		var ProductId = vParentform.hContextId.value; 
 		var ContextType = vParentform.hContextType.value;
 		
 		var mandatory = getTopWindow().document.getElementsByName('mandatory')[0].value; 
 	    if(mandatory!=""){
 	    	document.getElementById('hMandatory').value = mandatory;
 	    }
 		
 		document.getElementById('hleftExpObjIds').value = passLeftHiddenExpId;
 		document.getElementById('hleftExpObjTxt').value = passLeftHiddenExpText;
 	    
 		document.getElementById('hrightExpObjIds').value = passRightHiddenExpId;
 		document.getElementById('hrightExpObjTxt').value = passRightHiddenExpText;
 	    
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
 				alert(MARKETING_PREFERENCE_CHOICES_INVALID);
 			}else if( isLeftExpValid=="false" ){
 				alert(MARKETING_PREFERENCE_INVALID);
 			}else if( isRightExpValid=="false" ){			
 				alert(MARKETING_CHOICES_INVALID);	
 			}
 	    }
 	}
   }
 function endsWith(str, suffix) {
	    return str.indexOf(suffix, str.length - suffix.length) !== -1;
	}

   
  function fnValidate(mode){
	lstLeftExpression =  new Array;
	lstRightExpression =  new Array;
 	var vParentform = document.getElementById("RuleForm");     
    var nameField = getTopWindow().document.getElementsByName('txtRuleName')[0];     
    var autoName = false;
     if(mode!="edit"){
    	 autoName = getTopWindow().document.getElementsByName('autoName')[0].checked;
     }
     var fieldName1 = "Name";
     var empty =""; 
     
     // for name Field validation  
    //Modified for IR-204644V6R2014
     
     // if(fieldNameValue != empty && autoName == false){
     if(autoName == false){
     if(!basicValidation(vParentform,nameField,fieldName1,true,true,true,false,false,false,false)){
      	 return false;
  	  }
     }
  	//End of IR-204644V6R2014
     
     //For Description Filed Validation
  /*   if(!basicValidation(vParentform,description,DESCRIPTION,true,false,true,false,false,false,checkBadChars)){
        return false;
     } */
     
     var selectedLeftActual = "" ;
     var selectedLeftText = "" ;
     var selectedRightActual = "" ;
     var selectedRightText = "" ;
     var tmpi = 0 ;
     
     
     if (document.getElementById("LExp").options.length != 0 ){
     	for(var i=0 ; i<document.getElementById("LExp").options.length ; i++){
     		selectedLeftText = selectedLeftText + document.getElementById("LExp").options[i].text + " ";
         	selectedLeftActual = selectedLeftActual + document.getElementById("LExp").options[i].value + " ";
         	var strLExpOption = document.getElementById("LExp").options[i];
         	if(strLExpOption.value != "AND" && strLExpOption.value != "OR" && strLExpOption.value != "NOT" && strLExpOption.value != "(" && strLExpOption.value != ")"){
         		lstLeftExpression[i] = "TRUE"
             }else{
             	lstLeftExpression[i] = strLExpOption.value;
             }
         	
         	if(strLExpOption.value != "AND" && strLExpOption.value != "OR" && strLExpOption.value != "NOT" && strLExpOption.value != "(" && strLExpOption.value != ")"){
         		lstLeftExpression[i] = "TRUE"
             }else{
             	lstLeftExpression[i] = strLExpOption.value;
             }
     	}
      }
     //In MPR "blank" LE is allowed hence no "else" loop
    
     
     if(document.getElementById("RExp").options.length != 0 ){
    	 var j=0;
     	for(var i=0 ; i<document.getElementById("RExp").options.length ; i++){
     		
     		//To insert "AND" in between 2 selected Feature Options
     		var optionText= document.getElementById("RExp").options[i].text;
     		if(i==0){
     			//When it comes 1st time add the item
     			selectedRightText = selectedRightText + document.getElementById("RExp").options[i].text;
             	selectedRightActual = selectedRightActual +document.getElementById("RExp").options[i].value;
             	lstRightExpression[j] = "TRUE";
             	j++;
     			
     		}else if(i==(document.getElementById("RExp").options.length-1)){
     			//When it is last item
     			if(endsWith(selectedRightText,"AND")){

     	            selectedRightText = selectedRightText + " " + (document.getElementById("RExp").options[i].text);
     	           selectedRightActual = selectedRightActual + " " +  "AND" +  " " +(document.getElementById("RExp").options[i].value);

     		}else{
 	            selectedRightText = selectedRightText + " " + "AND"+  " " + (document.getElementById("RExp").options[i].text);
 	            selectedRightActual = selectedRightActual + " " +  "AND" +  " " +(document.getElementById("RExp").options[i].value);
     		}
 	            lstRightExpression[j] = "AND";
 	            j++;
 	            lstRightExpression[j] = "TRUE";
 	            j++;
     		}else{
     			if(endsWith(optionText,"AND")){
                    selectedRightText = selectedRightText + " " + (document.getElementById("RExp").options[i].text);
                    selectedRightActual = selectedRightActual + " " +  "AND" +  " " +(document.getElementById("RExp").options[i].value);
     			}else{
                    selectedRightText = selectedRightText + " " + "AND"+  " " + (document.getElementById("RExp").options[i].text);
                    selectedRightActual = selectedRightActual + " " +  "AND" +  " " +(document.getElementById("RExp").options[i].value);
     			}
                 lstRightExpression[j] = "AND";
                 j++;
 	            lstRightExpression[j] = "TRUE";
                 j++;
     		}
     	}
     }else{
  		alert(ENTER_MARKETING_CHOICES);
  		return false;
  	}
      
      
      passLeftHiddenExpId = selectedLeftActual ;
      passLeftHiddenExpText = selectedLeftText ;
      leftExpVal = passLeftHiddenExpText;
      
  	passRightHiddenExpId = selectedRightActual;
  	passRightHiddenExpText = selectedRightText ; 
  	rightExpVal = passRightHiddenExpText;
     
  	if((leftExpVal.trim()==rightExpVal.trim())&&(passRightHiddenExpId.trim()==passLeftHiddenExpId.trim())){		 
  		alert(ERROR_MESSAGE_FOR_SIMILAR_EXP);
  		return false;
  	}
  		  
  	Name = vParentform.txtRuleName.value;
  	if (Name == ""){
  	  if(vParentform.autoName.checked == false){
  		alert(ERROR_MESSAGE_FOR_NAME_ENTRY);
  		return false ;
        }
  	}
      return true;
   }

   
