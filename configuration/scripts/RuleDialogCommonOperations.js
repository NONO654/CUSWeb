
//RuleDialogCommonOperations.js

//Includes all the operations to be performed on Rule Dilaog Page..  which will not vary depending upon the Type of rule.
/*Functions included: 
* checkName()
* showDRSelector()
* showVaultSelector
* addOption
* moveUp
* moveDown
* clearAll
* operatorInsert
* trim
* Ltrim
* Rtrim
* computedRule
* showRuleDialog
* displayOptionRuleExpression
* retainValue

*/
    var strUserAgent = navigator.userAgent.toLowerCase();
    var isIE = strUserAgent.indexOf("msie") > -1 && strUserAgent.indexOf("opera") == -1;

function checkName(){

	if(document.RuleForm.autoName.checked == true){
		document.RuleForm.txtRuleName.disabled = true;
	}else{
		document.RuleForm.txtRuleName.disabled = false;
	}
}

function modifyRuleClassification(){
	  var vSelectedTypeIndex = document.getElementById('ruleClassification').selectedIndex;
	  var vSelectedType = document.getElementById('ruleClassification').options[vSelectedTypeIndex].value;
	  //Need to update the Context Selector Page accordingly
	  document.getElementById("featureType").options.length=0; 
	  
	  //Do it more generic
	  if(vSelectedType=="Logical"){
		  
		  var vOption = document.createElement('option');
		  //vOption.text="Logical";
		  vOption.appendChild(document.createTextNode(LOGICAL));
		  
		  vOption.value="relationship_LOGICALSTRUCTURES";   
		  document.getElementById("featureType").appendChild(vOption);  
		  
		  var vOption = document.createElement('option');
		  vOption.appendChild(document.createTextNode(CONFIGURATION));
		  
		  vOption.value="relationship_CONFIGURATIONSTRUCTURES"; 
		  document.getElementById("featureType").appendChild(vOption);  
		  
	  }else{
		  var vOption = document.createElement('option');
		  //vOption.text="Configuration";
		  vOption.appendChild(document.createTextNode(CONFIGURATION));
		  vOption.value="relationship_CONFIGURATIONSTRUCTURES";   
		  document.getElementById("featureType").appendChild(vOption);  
		  
	  }
 }


function isDuplicateName(vMode,editValue){
		var ruleName= document.RuleForm.txtRuleName.value;
		var ruleNameHidden = document.RuleForm.hiddenRuleName.value;
		var ruleType= document.RuleForm.hRuleType.value;
		var invldChar = checkStringForChars(ruleName, ARR_NAME_BAD_CHARS, false);
			if(invldChar.length > 0)
		    {
				var strAlert = ALERT_INVALID_CHARS+invldChar;
		         alert(strAlert);
		         document.RuleForm.txtRuleName.value="";
		         return false;
		    }
		
	    var url="../configuration/RuleDialogValidationUtil.jsp?mode=isDuplicateName&type="+ruleType+"&name="+encodeURIComponent(ruleName)+"&revision=-";
	    var vRes = emxUICore.getData(url);
	    var iIndex = vRes.indexOf("isDup=");
	    var iLastIndex = vRes.indexOf("#");
	    var bcrExp = vRes.substring(iIndex+"isDup=".length , iLastIndex );
	    if(trim(bcrExp)== "true"){
	    	alert(DUP_NAME_ALERT);
	    	if((vMode=="edit"))
	    	document.RuleForm.txtRuleName.value=editValue;
	    	else
	    	document.RuleForm.txtRuleName.value="";	    		
	    }
	    document.RuleForm.hiddenRuleName.value = encodeURIComponent(ruleName);
}


function showDRSelector(txtDRDisplay,txtDRId)
{
	 var strTxtRDO = "document.forms['RuleForm'].txtDRDisplay";
	 var sURL='../common/emxFullSearch.jsp?field=TYPES=type_Organization&table=FTRFeatureSearchResultsTable&Registered Suite=Configuration&selection=single&showSavedQuery=true&hideHeader=true&HelpMarker=emxhelpfullsearch&submitURL=../configuration/SearchUtil.jsp?mode=Chooser&fieldNameActual=hDRId&fieldNameDisplay=txtDRDisplay&chooserType=FormChooser';
	 showChooser(sURL, 850, 630);
}
function showVaultSelector(strTxtVault)
{
	  //This function is for popping the Vault chooser.
	  txtVault = eval(strTxtVault);
	  showChooser('../common/emxVaultChooser.jsp?fieldNameActual=hVaultID&fieldNameDisplay=txtVaultDisplay&incCollPartners=false&multiSelect=false');
}

//Function to add options in Left & Right dropdown
function addOption(selectbox,text,value,relationshipType)
{	if(value!=undefined && value.trim()!="" ){
	 var optn = document.createElement("OPTION");
     optn.text = text;
     optn.value = value;
     
     if(relationshipType!=undefined && relationshipType.trim()!="" ){
    	 if(document.getElementById('ruleClassification')){
    		 var vRuleClassification = document.getElementById('ruleClassification').value;
         	 optn.setAttribute("RuleClassification", vRuleClassification);
         	 optn.setAttribute("FeatureType", relationshipType); 
         	 
    	 }else{
    		 //In case of "Inclusion Rule" , Rule Classification attribute is not present
    		 optn.setAttribute("RuleClassification", "NA");
         	 optn.setAttribute("FeatureType", relationshipType); 
    	 }
     }else if(optn.value=="AND" || optn.value=="OR"  || optn.value=="NOT"  || optn.value==")" || optn.value=="("){
    	 
    	 optn.setAttribute("RuleClassification", "NA");
     	 optn.setAttribute("FeatureType", "NA"); 
     }
 	 selectbox.options.add(optn);
   }
}    

//Function to move up the feature options 
function moveUp(textArea)
{
	var Exp;
	if(textArea == 'left')
	{
	  Exp = document.getElementById('LExp') ;
	}
	if(textArea == 'right')
	{
	 Exp = document.getElementById('RExp') ;
	}
    
    var ind = Exp.selectedIndex;
    if(ind==-1)
    {
    	alert(ERROR_MESSAGE_FOR_SELECTION);
    	return 0;
    }
	
	for(var i = 0; i < Exp.length; i++)
	{
	  if (Exp.options[i].selected && i!=0)
	  {  
		prevOpt = Exp.options[i-1].innerHTML;
		prevOptVal = Exp.options[i-1].value;
		prevFeatTypeVal = Exp.options[i-1].attributes.featuretype.value;

		temp = Exp.options[i].innerHTML;
		tempVal = Exp.options[i].value;
		tempFeatTypeVal = Exp.options[i].attributes.featuretype.value;

		Exp.options[i-1].innerHTML = temp;
		Exp.options[i-1].value= tempVal;
		Exp.options[i-1].attributes.featuretype.value= tempFeatTypeVal;

		Exp.options[i-1].selected = true;
			
		Exp.options[i].innerHTML = prevOpt;
		Exp.options[i].value = prevOptVal;
		Exp.options[i].attributes.featuretype.value = prevFeatTypeVal;
			

		Exp.options[i].selected = false;
			}
		} //end of for
} // end of method




//Function to move down the feature options 
function moveDown(textArea)
{
    var Exp;
    if(textArea == 'left')
	{
	 Exp = document.getElementById('LExp') ;
	}
	if(textArea == 'right')
	{
	 Exp = document.getElementById('RExp') ;
	}

	//Start: 368163
    var ind = Exp.selectedIndex;
    if(ind==-1){
    	alert(ERROR_MESSAGE_FOR_SELECTION);
    	return 0;
    }//End: 368163
    
	for (var i = Exp.length - 1; i >= 0; i--)
	    {
			if (Exp.options[i].selected && (i!=(Exp.length-1)))
			{  
				currOpt = Exp.options[i].innerHTML;
				currOptVal = Exp.options[i].value;
				currFeatTypeVal = Exp.options[i].attributes.featuretype.value;
			
				temp = Exp.options[i+1].innerHTML;
				tempVal = Exp.options[i+1].value;
				tempFeatTypeVal = Exp.options[i+1].attributes.featuretype.value;

			    Exp.options[i].innerHTML = temp;
				Exp.options[i].value= tempVal;
				Exp.options[i].attributes.featuretype.value= tempFeatTypeVal;

			    Exp.options[i].selected = false;
			    
			    Exp.options[i+1].innerHTML = currOpt;
				Exp.options[i+1].value = currOptVal;
				Exp.options[i+1].attributes.featuretype.value = currFeatTypeVal;
				

				Exp.options[i+1].selected = true;
			}
		} //end of for
} // end of method 

//Function to move down the feature options 
//Function to remove the feature options
function clearAll(textArea)
{
	if(textArea == 'left')
	{
	 Exp = document.getElementById('LExp') ;
	}
	if(textArea == 'right')
	{
	 Exp = document.getElementById('RExp');
	}

	for(i=Exp.length-1; i>=0; i--)
	{		  
		Exp.options[i] = null;	
	}
	if(isIE && isMaxIE7){
	    Exp.removeAttribute("style");
	    Exp.removeAttribute("RuleClassification");
	    Exp.removeAttribute("FeatureType");
		Exp.setAttribute("class",'select');
	}
 }// end of method

//Function to insert logical operators 'AND' , 'OR', 'NOT', etc
 function operatorInsert(operator,textArea)
 {
 	var Exp;
 	if(textArea == 'left')
	{
 		leftExp = document.getElementById('LExp') ;
	}
	if(textArea == 'right')
	{
		rightExp = document.getElementById('RExp') ;
	}
    
 	if(textArea=="left"){
 		Exp = leftExp;
 		addOption(Exp,operator,operator);
 		}
 	else{
 		Exp = rightExp;
 		addOption(Exp,operator,operator);
        }                                                                                                                  
 	var i = Exp.length;

 } //end of method
 

//Removes leading and ending whitespaces
 function trim( value )
 {
   return LTrim(RTrim(value));
 }
  
 function LTrim( value )
 {
   var re = /\s*((\S+\s*)*)/;
   return value.replace(re, "$1");
 }

 // Removes ending whitespaces
 function RTrim( value ) 
 {
 	var re = /((\s*\S+)*)\s*/;
 	return value.replace(re, "$1");
 }
 
 var passComparisonParam		= "" ;
 var tempIncom = " Incompatible ";
 var tempCodept = " Co-Dependent ";
 var tempReq = " Requires";
 
 
//Function to compute completed rule for create rule
 function computedRule(tmpOperator,textarea,calledFrom)
 {
	 var leftExpText = "";
	 var rightExpText = "";
	 
	 var logicalOperator = tmpOperator;
	  
	 passComparisonParam = document.getElementById('compatibilityType').value;
	 
	 if(passComparisonParam!=null && passComparisonParam=="Incompatible")
 	 {
 			passComparisonParam = tempIncom;
 	 }
 	 else if(passComparisonParam!=null && passComparisonParam=="Requires")
 	 {
 		passComparisonParam = tempReq;
 	 }
 	 else
 	 {
 		passComparisonParam = tempCodept;
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
					
		 var compOperaRequires = "Requires" ;	
		 if(passComparisonParam == compOperaRequires)
		 {				
			 computeRule = "<B>"+leftExpText + "</B> " +   passComparisonParam + " <B>" + rightExpText+"</B>" ;
		 }
		 else
		 {
			 computeRule = "<B>"+leftExpText + "</B> " +  " is " + passComparisonParam + " with " + " <B>" + rightExpText+"</B>" ;
		 }
		 
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
		 
		if(document.CompOperform.comparisonOperator)
		{
		  var compOperaRequires = "Requires" ;
		  if(passComparisonParam == compOperaRequires)
		  {				
			 computeRule = "<B>"+leftExpText + "</B> " +   passComparisonParam + " <B>" + rightExpText+"</B>" ;
		  }
		  else
		  {
		 	computeRule = "<B>"+leftExpText + "</B> " +  " is " + passComparisonParam + "with" + " <B>" + rightExpText+"</B>" ;
		  }
		}
		else
		{
			computeRule = "<B>"+leftExpText + "</B> " + " will have the choice of( " + "<B>"+rightExpText+"</B>"+ ") " ;	
		  }	
		
			var objDIV = document.getElementById("divRuleText"); 
	    }
	 
    	objDIV.innerHTML = computeRule.toString();
 } 
 
 
//for leftExpression textArea onmouse Dialog
 function showRuleDialog(ruleExpressionLength,expdivId,divId,textArea)
 {
 	var selectedDiv = "";	
 	var divId;
 	var exp;	
 	var expression = new Array;
 	var expressionValue = new Array;
 	var textArea;
 	if(document.getElementById(expdivId).options.length != 0 ){
 	  //document.RuleForm.LeftExpression.style.visibility="hidden";
     for(var i=0; i<document.getElementById(expdivId).options.length; i++){
 	  exp = document.getElementById(expdivId).options[i].text;	
 	  if(exp.length>ruleExpressionLength){
 	   var value;	
 	   while(true){	
 		   value = exp.substring(ruleExpressionLength);	
 		   expression.push(value);
 		   expression.push("\n");
 		   exp = exp.substring(ruleExpressionLength);
 		   if(exp.length<ruleExpressionLength){	
 			expression.push(exp);
 			expression.push("\n");
 			break;
 	  }else{
 	   continue;
 	  }
 	 }	
 	}else{	
 	 	expression.push(exp); 
 	 	expression.push("\n");  	 	
  	  }	 	
     }	
 	displayOptionRuleExpression(expression, divId,textArea,ruleExpressionLength);	
//     iFrame_ie6 = document.getElementById("forIE6z-indexingIssue");
//     iFrame_ie6.style.visibility = "visible";
 	}
 }

 function displayOptionRuleExpression(exp, divID,textArea,ruleExpressionLength)
 {
 	var target = document.getElementById(divID);	
 	var optionResponse;
 	var expression = new Array();
 	var expValue;
 	var  ruletxArea =textArea;
 	var ruleExpValue;
 	
 	if(ruletxArea=="leftEx")
 	{
 	  expValue = EXP_VALUE_LEFT;
 	}
 	if(ruletxArea=="rightEx")
 	{
 	 expValue = EXP_VALUE_RIGHT;
 	}
 	if(ruletxArea=="comRule")
 	{
 	 expValue = EXP_VALUE_COMPLETED;
 	}
 	
 	ruleExpValue = exp.join(""); 
 	
 	if(ruletxArea=="comRule")
 	{ 

   	expression.push("<span onclick=retainValue('"+divID+"','"+ruleExpressionLength+"')><html><head></head><body><div id=\"mx_divLayerDialog\" style=top:350px; class=\"mx_option-details \" ><div id=\"mx_divLayerDialogHeader\">"  +
 	        	"<h1> <NOBR>"+HEADER+"</NOBR> </h1></div><div id=\"mx_divLayerDialogBody\">" +
 				"<div class=\"mx_option-detail context\" ><table BGCOLOR=FFFFCC>"+
 				"<tr><td><h1> <NOBR>"+ expValue+"</NOBR></h1></td></tr>"+
 				"<tr><td>"+ruleExpValue+"</td></tr>"+			
 				"</table></div>");
 	
 	
 	}else
 	{
 	expression.push("<span onclick=retainValue('"+divID+"','"+ruleExpressionLength+"')><html><head></head><body><div id=\"mx_divLayerDialog\" class=\"mx_option-details \" ><div id=\"mx_divLayerDialogHeader\">" +
 	        	"<h1><NOBR>"+HEADER+"</NOBR> </h1></div><div id=\"mx_divLayerDialogBody\">" +
 				"<div class=\"mx_option-detail context\" ><table BGCOLOR=FFFFCC>"+
 				"<tr ><td><h1> <NOBR>"+ expValue+"</NOBR></h1></td></tr>"+
 				"<tr><td>"+ruleExpValue+"</td></tr>"+			
 				"</table></div>");
 	
 	}			
 				
 	optionResponse = expression;
 	target.innerHTML = optionResponse; 	
 }


 function retainValue(divID,ruleExpressionLength)
 {	
 	var target = document.getElementById(divID);	
 	var funName;
 	if(divID=="RuleLeft")
 	{
 	 document.RuleForm.LeftExpression.style.visibility="visible";
 	 funName ="showRuleDialog('"+ruleExpressionLength+"','LExp','RuleLeft','leftEx')";
 	
 	}
 	if(divID=="RuleRight"){
 	document.RuleForm.RightExpression.style.visibility="visible";
 	funName ="showRuleDialog('"+ruleExpressionLength+"','RExp','RuleRight','rightEx')";
 	}
 	if(divID=="RuleCompleteIcon"){
 	document.RuleForm.RightExpression.style.visibility="visible";
 	funName ="showRuleCompleteDialog('"+ruleExpressionLength+"')";  	
 	}
 	htmlText ="<img src=../common/images/iconSmallNewWindow.png  onClick="+funName+">"; 	 		
 	target.innerHTML = htmlText ; 	
    //iFrame_ie6.style.visibility = "hidden";
 }

//for completed Rule textArea onmouse Dialog	
 function showRuleCompleteDialog(ruleExpressionLength)
 {	
 	var textArea;
 	var expression = new Array;		
 	var expressionValue ;	
 	if(((document.getElementById("LExp")!= null)&& (document.getElementById("LExp").options.length != 0 ))
 			||((document.getElementById("RExp")!= null)&& (document.getElementById("RExp").options.length != 0 )))
 	{
 	//document.RuleForm.RightExpression.style.visibility="hidden";	
 	divId = "RuleCompleteIcon";
 	textArea="comRule";	
 	var objDIV = document.getElementById("divRuleText"); 
 	computeRule = objDIV.innerHTML;
 	expressionValue = computeRule.toString();	
 	if(expressionValue.length>ruleExpressionLength)
 	{	
 	var value;	
 	while(true)
 	{	
 	value = expressionValue.substr(0,ruleExpressionLength);			
 	expression.push(value);
 	expression.push("\n");
 	expressionValue = expressionValue.substr(ruleExpressionLength);
 	if(expressionValue.length<ruleExpressionLength)
 	{
 	expression.push(expressionValue);
 	expression.push("\n");
 	 break;
 	}
 	else
 	{
 	 continue;
 	}
 	
 	}	
 	
 	}
 	else{			
     expression.push(expressionValue);  	
     expression.push("\n");  	
     }
 	displayOptionRuleExpression(expression, divId,textArea,ruleExpressionLength);	
 	}
 }
 
   function mx_setHeight(){
	    
	    var contentDivHeight = document.getElementById('divContent').offsetHeight;
	    var pageBodyDivHeight = document.getElementById('divPageBody').offsetHeight;
	    var sourceListTop = document.getElementById('divSourceList').offsetTop;
	    var sourceList = document.getElementById('divSourceList');
	    var ruleTextTop = document.getElementById('divRuleText').offsetTop;
	    var ruleText = document.getElementById('divRuleText');
	    var sourceListWidth = document.getElementById('divFeatureSelectorBody').offsetWidth;
	    var sourceListParent = document.getElementById('divFeatureSelectorBody');
	    var sourceListParentParent = document.getElementById('divFeatureSelector');
	    var sourceListFilter = document.getElementById('divFilter');
	    var sourceListFilterHeight = document.getElementById('divFilter').offsetHeight;
	    sourceList.style.height = "0";
	    sourceList.style.height =(contentDivHeight - sourceListTop)-12+"px";
	    sourceListParent.style.height =(contentDivHeight - sourceListTop)-12 +sourceListFilterHeight+24+"px";
	    sourceListParentParent.style.height =(contentDivHeight - sourceListTop)-12 +sourceListFilterHeight+24+18+"px";
	    if(isIE){
		    sourceListParent.style.height =(contentDivHeight - sourceListTop)+sourceListFilterHeight+"px";
		    sourceListParentParent.style.height =(contentDivHeight - sourceListTop)+sourceListFilterHeight+30+"px";
		    sourceListWidth=sourceListWidth-10;
		}
	    sourceList.style.width = sourceListWidth;
	    ruleText.style.height = "0";
	    ruleText.style.width = '350';
	    if(isIE)
	    	ruleText.style.width = '330';
	    if((contentDivHeight - ruleTextTop)-20>0)
	    ruleText.style.height = (contentDivHeight - ruleTextTop)-20+"px";
	}
	 
	 function displayComputedRule(vMode){
	     if(vMode=="edit"){
	       var leftExpText = "";
	       var rightExpText = "";
	       var passComparisonParam = "" ;
	       var tempIncom = " Incompatible ";
	       var tempCodept = " Co-Dependent ";
	       var tempReq = " Requires";
	  
	       passComparisonParam = document.getElementById('compatibilityType').value;
	       if(passComparisonParam!=null && passComparisonParam=="Incompatible"){
	         passComparisonParam = tempIncom;
	       }else if(passComparisonParam!=null && passComparisonParam=="Requires"){
	         passComparisonParam = tempReq;
	       }else{
	        passComparisonParam = tempCodept;
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
	                    
	       var compOperaRequires = "Requires" ;   
	       if(passComparisonParam == compOperaRequires){              
	             computeRule = "<B>"+leftExpText + "</B> " +   passComparisonParam + " <B>" + rightExpText+"</B>" ;
	       }else{
	             computeRule = "<B>"+leftExpText + "</B> " +  " is " + passComparisonParam + " with " + " <B>" + rightExpText+"</B>" ;
	       }
	         
	         var objDIV = document.getElementById("divRuleText");
	         objDIV.innerHTML = computeRule.toString();
	      }
	    }
	    
	 function formExp(textArea,strRuleType){
	    if(textArea == 'left'){
	        var displayString = document.getElementById('hleftExpObjTxtForEdit').value;
	        var actualString = document.getElementById('hleftExpObjIdsForEdit').value;
	        var relationshipType = document.getElementById('hleftExpFeatTypeVal').value;
	        
	        displayString=displayString.trim();
	        actualString=actualString.trim();
	        relationshipType=relationshipType.trim();
	        
	        var splitDisplayArr= displayString.split('#');
	        var splitRelTypeArr= relationshipType.split('#');
	        var splitActualArr= actualString.split(' ');
	        if(splitDisplayArr.length>0){
	        	for(var i=0;i<splitDisplayArr.length;i++){
	        		addOption(document.getElementById('LExp'), splitDisplayArr[i], splitActualArr[i],splitRelTypeArr[i]);
	        	}
	        }
	        if(isIE && isMaxIE7)
    		document.getElementById('LExp').style.width = 'auto';
	        
	    }else if(textArea == 'right'){
	        displayString = document.getElementById('hrightExpObjTxtForEdit').value;
	        actualString = document.getElementById('hrightExpObjIdsForEdit').value;
	        var relationshipType = document.getElementById('hrightExpFeatTypeVal').value;
	        
	        displayString=displayString.trim();
	        actualString=actualString.trim();
	        relationshipType=relationshipType.trim();
	        
	        var splitDisplayArr= displayString.split('#');
	        var splitRelTypeArr= relationshipType.split('#');
	        var splitActualArr= actualString.split(' ');
	        if(splitDisplayArr.length>0){
	        	for(var i=0,j=0;i<splitDisplayArr.length;i++,j++){
	        		if(strRuleType=='MarketingPreferenceRule' && splitActualArr[j]=='AND' ){
	        		  addOption(document.getElementById('RExp'), splitDisplayArr[i], splitActualArr[++j],splitRelTypeArr[i]);
	        	    }
	        		else{
	        		  addOption(document.getElementById('RExp'), splitDisplayArr[i], splitActualArr[j],splitRelTypeArr[i]);
	        		}
	        	}
	        	if(isIE && isMaxIE7)
	    		document.getElementById('RExp').style.width = 'auto';	
	        }
	    }
	 } 
	 
	 function toggleBox(szDivID,szDivID1){
	    var strUserAgent = navigator.userAgent.toLowerCase();
	    var isIE = strUserAgent.indexOf("msie") > -1 && strUserAgent.indexOf("opera") == -1;
	    if(szDivID=='divBasics'){
	        var sourceList = document.getElementById('img1');
	        var src = sourceList.src;
	        var index = src.lastIndexOf("/");
	        var y = src.substring(0,index+1);
	        var x = src.substring(index+1);
	        if(x=="utilChannelClose.gif"){
	            var xp = y+"utilChannelOpen.gif";
	            var sourceList1 = document.getElementById('divFeatureSelector');
	            var mx_image2 = document.getElementById('img2');
	            if(isIE){
	                //mx_image2.style.margin = '-190pt 0pt 6px';
	            }else{
	                //mx_image2.style.margin = '-130pt 0pt 6px';
	            }
	            mx_setHeight(); 
	        }else{
	            var contentDivHeight = document.getElementById('divContent').offsetHeight;
	            var xp = y+"utilChannelClose.gif";
	            //document.RuleForm.img2.src = y+"utilChannelOpen.gif";
	            var mx_image2 = document.getElementById('img2');
	            var mx_divSL = document.getElementById('divSourceList');
	            mx_image2.style.margin = '0pt 0pt 6px';
	            var sourceListTop = document.getElementById('divSourceList').offsetTop;
	            var sourceList = document.getElementById('divSourceList');
	            sourceList.style.height = "0";
	            sourceList.style.height = (contentDivHeight - sourceListTop)-18 +"px";
	        }
	        document.RuleForm.img1.src = xp;
	        sourceList = document.getElementById('img1');
	    }else{
	        var sourceList = document.getElementById('img2');
	        var src = sourceList.src;
	        var index = src.lastIndexOf("/");
	        var y = src.substring(0,index+1);
	        var x = src.substring(index+1);
	        if(x=="utilChannelClose.gif"){
	            var xp = y+"utilChannelOpen.gif";
	        }else{
	            var xp = y+"utilChannelClose.gif";
	            var sourceList1 = document.getElementById('divFeatureSelector');
	            var mx_image2 = document.getElementById('img2');
	        }
	        document.RuleForm.img2.src = xp;
	        sourceList = document.getElementById('img2');
	    }
	    
	    if(document.layers){
	       if(document.layers[szDivID].visibility == 'show' || document.layers[szDivID].visibility == ''){
	            document.layers[szDivID].visibility = "hide";
	        }else{
	            document.layers[szDivID].visibility = "show";
	        }
	    }else if(document.getElementById){
	        var obj = document.getElementById(szDivID+"Body");
	        var objParent = document.getElementById(szDivID);
	        if(obj.style.visibility == 'visible' || obj.style.visibility == ''){
	            obj.style.visibility = "hidden";
	            objParent.style.height="28px";
	            mx_setHeight();
	        }else{
	            obj.style.visibility = "visible";
	            var bodyheight=obj.offsetHeight;
	            objParent.style.height=bodyheight+30 +"px";
	            mx_setHeight();
	        }
	    }else if(document.all){
	        if(document.all[szDivID].style.visibility == 'visible' || document.all[szDivID].style.visibility == ''){
	            document.all[szDivID].style.visibility = "hidden";
	        }else{
	            document.all[szDivID].style.visibility = "visible";
	        }
	    }
	}
	 
	 window.onresize=mx_setHeight;
	 
	 
