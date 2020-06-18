//======================================================================================
//	JavaScript File - emxstructureCompareutils.js
//
//	Copyright (c) 1993-2018 Dassault Systemes.
//	All Rights Reserved.
//	This program contains proprietary and trade secret information of Dassault Systemes.
//	Copyright notice is precautionary only and does not evidence any actual
//	or intended publication of such program
//
//	static const char RCSID[] = $Id: emxUIStructureCompareUtils.js.rca 1.4.3.2 Wed Oct 22 15:47:59 2008 przemek Experimental przemek $
//======================================================================================
	
var firstColumn;
var secondColumn;
var thirdColumn;
var count;

function loadData(){
	firstColumn=document.getElementById("firstColumn");
	secondColumn=document.getElementById("secondColumn");
	thirdColumn=document.getElementById("thirdColumn");
	
	optionElement(firstColumn,colNames);
	optionElement(secondColumn,colNames);
	optionElement(thirdColumn,colNames);
	
	secondColumn.disabled=false;
	thirdColumn.disabled=true;
	disableCheckBox();
	
	if(getTopWindow().window.info && getTopWindow().window.info["CompareCriteriaJSON"] && getTopWindow().window.info["CompareCriteriaJSON"].selTypeDisp) {
		reloadCompareCriteria(document.forms["compareForm"]);
	}

}


//To Populate the second Option 
function populateSecondOption(){
  
	var values = firstColumn.value;
	var secondvalues=secondColumn.value;
	
	secondColumn.length=0;
	
	for(var i=0; i<colNames.length; i++){
		    if(values != "None"){  
		   
				if(secondvalues == "None" || secondvalues == ""){
				  
		    	    if(colNames[i] != values){
						var newOption = document.createElement('option');
						newOption.text = colLabels[i];
						newOption.value= colNames[i];
						try{
							secondColumn.add(newOption,null);
						}
						catch(ex){ 
							secondColumn.add(newOption);
						} 
					}
				}else{
					if(colNames[i]!=values){
						var newOption = document.createElement('option');
						newOption.text = colLabels[i];
						newOption.value=colNames[i];
						if(colNames[i]==secondvalues){
												
						newOption.selected=true;
						}
						try{
						secondColumn.add(newOption,null);
						}
						catch(ex){
							secondColumn.add(newOption);
						}
					}
				}
		
			}else{
				var newOption = document.createElement('option');
				newOption.text= colLabels[i];
				newOption.value=colNames[i];
				try{
					secondColumn.add(newOption,null);
				}
				catch(ex){
					secondColumn.add(newOption);
				}
			}
	}
	populateThirdOption();
}
//To Populate the third Option
function populateThirdOption(){

  var firstValues=firstColumn.value;
  var secondValues=secondColumn.value;
  var thirdValues=thirdColumn.value;
  thirdColumn.length=0;
	for(var i=0;i<colNames.length;i++){
		    if(firstValues=="None"){
		    
				if(secondValues!="None" && colNames[i]!=secondValues){
      		    	var newOption = document.createElement('option');
					newOption.text= colLabels[i];
					newOption.value=colNames[i];
					
					try{
						thirdColumn.add(newOption,null);
						}
						
					catch(ex){
						thirdColumn.add(newOption);
					}
				}else{
					var newOption = document.createElement('option');
					newOption.text=colLabels[i];
					newOption.value=colNames[i];
					try{
						thirdColumn.add(newOption,null);
						}
						
					catch(ex){
						thirdColumn.add(newOption);
					}
				}
		}else{
				 if(secondValues=="None" ){
					 if(colNames[i]!=firstValues){
							var newOption = document.createElement('option');
							newOption.text= colLabels[i];
							newOption.value=colNames[i];
							try{
								thirdColumn.add(newOption,null);
								
							}
							catch(ex){
								thirdColumn.add(newOption);
							}
					}
				}else{
					if(colNames[i]!==firstValues&&colNames[i]!==secondValues) {
					 var newOption = document.createElement('option');
							newOption.text= colLabels[i];
							
							newOption.value=colNames[i];
							 if(colNames[i]==thirdValues){
							
							newOption.selected=true;
						        }
							try{
								thirdColumn.add(newOption,null);
								
							}
							catch(ex){
								thirdColumn.add(newOption);
							}
							
					}
					
				}
			}
	}
}
function populate(){
	if(firstColumn.value!="None"){
	 secondColumn.disabled=false;
	 thirdColumn.disabled=false;
	}
	if(secondColumn.value=="None"){
		thirdColumn.value="None";
		thirdColumn.disabled=true;
	}else{
		thirdColumn.disabled=false;
	}
}

function conflict(){
	if(firstColumn.value==secondColumn.value){
		secondColumn.value="None";
	}
	if(firstColumn.value==thirdColumn.value){
		thirdColumn.value="None";
	}
	if(secondColumn.value==thirdColumn.value){
		thirdColumn.value="None";
	} 
}
  
function optionElement(element){
if(element.name=="firstColumn"){
	for(var i=0;i<firstOptionArray.length;i++){
		var newOption = document.createElement('option');
		newOption.text= firstOptionLabelArray[i];
		newOption.value=firstOptionArray[i];
		try{
			element.add(newOption,null);
		}
		catch(ex){
			element.add(newOption);
		}
	}
}
else{
	for(var i=0;i<colNames.length;i++){ 
		if ( !(colNames[i] == firstColumn.value) ) 
		 {
			var newOption = document.createElement('option');
			newOption.text= colLabels[i];
			newOption.value=colNames[i];
			try{
				element.add(newOption,null);
			}
			catch(ex){
				element.add(newOption);
			}
	 	}
  	}
  }
}	 

function disableCheckBox(){
	var formObject = document.compareForm;
    var fValue=	firstColumn.value;
    var sValue= secondColumn.value;
    var tValue=	thirdColumn.value;
    
	for(var i=0;i<colNames.length-1;i++){
		 var temp=formObject.CompareBy[i].value;
		 if(temp==fValue || temp==sValue || temp == tValue){ 
		 	formObject.CompareBy[i].checked = false; 
		 	formObject.CompareBy[i].disabled = true;
		 }
		 else{
		 	formObject.CompareBy[i].disabled = false;
		 }
	}
}

function onDone(){
	checkValue();
}

function checkValue(){

	var refObject = findFrame(getTopWindow(),"formStructureCompare");
	var formObject = refObject.document.forms.compareForm;
	
	var scApplied = formObject.scApplied.value;
	
	var compareBy=new Array();
  	var c_value="";
	var count=formObject.CompareBy.length;
	
	var selTypeDisp = formObject.selTypeDisp.value;
	var selTypeDisp1 = formObject.selTypeDisp1.value;
	
	formObject.matchBasedOn.value = "";
	formObject.compareBy.value = "";
	
	if ( selTypeDisp == "*")
	{
	  alert(emxUIConstants.STR_FIRST_OBJ_SELECT_MSG);
	  return;
	}
	else if ( selTypeDisp1 == "*" )
	{
	   alert(emxUIConstants.STR_SECOND_OBJ_SELECT_MSG);
	   return;  
	}
	for(var i=0;i<count;i++){
   		if (formObject.CompareBy[i].checked){
      		 c_value += formObject.CompareBy[i].value + ",";
      	}
  	}
  	formObject.cbox_Value.value = c_value;

  	if(c_value.length==0){
  		alert(emxUIConstants.STR_COMPARE_CRITERIA_ERROR_MSG);
  		return;
  	}else{
	    for ( var i=0; i < count ; i++)
	    {    
		    if ( formObject.CompareBy[i].checked )
		    {  
		    	if ( formObject.compareBy.value == "" )
		    	formObject.compareBy.value = refObject.document.compareForm.CompareBy[i].value;
		    	else
		    	formObject.compareBy.value += ","+refObject.document.compareForm.CompareBy[i].value;
		    } 	    
	    }
	    if ( formObject.firstColumn != null && formObject.firstColumn.value != "None" )
	    {
	       if ( formObject.matchBasedOn.value == "" )
	       {
	          formObject.matchBasedOn.value = formObject.firstColumn.value;
	       }else
	       {
	          formObject.matchBasedOn.value += ","+formObject.firstColumn.value;
	       }
	    }
	    if ( formObject.secondColumn != null && formObject.secondColumn.value != "None" )
	    {
	       if ( formObject.matchBasedOn.value == "" )
	       {
	          formObject.matchBasedOn.value = formObject.secondColumn.value;
	       }else
	       {
	          formObject.matchBasedOn.value += ","+formObject.secondColumn.value;
	       }
	    } 
	    if ( formObject.thirdColumn != null && formObject.thirdColumn.value != "None" )
	    {
	       if ( formObject.matchBasedOn.value == "" )
	       {
	          formObject.matchBasedOn.value = formObject.thirdColumn.value;
	       }else
	       {
	          formObject.matchBasedOn.value += ","+formObject.thirdColumn.value;
	       } 
	    } 
	    if ( formObject.objectId != null )
	    {
	        formObject.objectId.value = formObject.strObjectId1.value;
	        formObject.objectId.value += ","+formObject.strObjectId2.value;
	    }
	    
	    //formObject.scApplied.value = "true";
	    
	    //findFrame(getTopWindow(), "AEFSCCompleteSummaryResults").parent.document.getElementById("divPvChannel-2-1").childNodes[0].style.display ="";
	    //formObject.criteriaModified.value = "false";
	    
	    formObject.target = "AEFSCCompleteSummaryResults";
	    
	    formObject.submit();
	}
}

function validateLevel(){
	var objThis = arguments[0];
	var objTo = getTopWindow().getWindowOpener().document.getElementById("to");
	var objFrom = getTopWindow().getWindowOpener().document.getElementById("from");
	if(objThis.value == "All"){
		if(objTo && objFrom){
			if(objTo.checked == true && objFrom.checked == true){			
				alert(emxUIConstants.STR_ALLLEVEL_ERROR);
				objThis.options[0].selected  = true;
			}
		}else{
			if(!isExpandProgOrMenuPassed){
				alert(emxUIConstants.STR_ALLLEVEL_ERROR);
				objThis.options[0].selected  = true;
			}
		}		
	}
}
