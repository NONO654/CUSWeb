//=================================================================
// JavaScript File - emxUIMultiColumnSortUtils.js
//
// Copyright (c) 1993-2018 Dassault Systemes.
// All Rights Reserved.
// This program contains proprietary and trade secret information of Dassault Systemes.
// Copyright notice is precautionary only
// and does not evidence any actual or intended publication of such program
//
//=================================================================
var firstColumn;
var secondColumn;
var thirdColumn;
var sortColNames = new Array();
var sortColLabel = new Array();
var colNames = new Array();
var colLabel = new Array();
colNames=getSortColumnValuesArray();
colLabel=getSortColumnLabelArray();

//To populate option at the first time of body load
  function loadData(parameterArray,directionArray,obj1,obj2,obj3){
	colNames = getSortColumnValuesArray();
	colLabel = getSortColumnLabelArray();	
	firstColumn = document.getElementById("firstColumn");
	secondColumn = document.getElementById("secondColumn");
	thirdColumn = document.getElementById("thirdColumn");
	var sParamLen = parameterArray.length;
	
//if User has Given URL paramters(sortColumnName,sortDirection) in the HREF of the Command
	if(sParamLen > 0){
	     setTimeout( function() { 
		  for(var i = 0; i < sParamLen; i++){
		  	if(i == 0){
			  for(var j=0; j<colNames.length,j<colLabel.length; j++){
				var newOption = document.createElement('option');
				newOption.text = colLabel[j];
				newOption.value = colNames[j];
				newOption.title = colLabel[j];				
				var colName = colNames[j];
				if(colName.indexOf("@")>0)
				{
					var firstIndex = colName.indexOf("@");
					var lastIndex = colName.indexOf("|");
					colName = colName.substring(firstIndex+1,lastIndex);
				}
				if(colName == parameterArray[i] ||colNames[j]==parameterArray[i] ){
					newOption.selected=true;
					 if(directionArray.length>0){
						if(directionArray[0]=='ascending'){
							obj1[0].checked=true;
						}
						if(directionArray[0]=='descending'){
							obj1[1].checked=true;
						}
					 }else{
					 obj1[0].checked=true;
					 obj2[0].checked=true;
					 obj3[0].checked=true;
					}
				  }
				try{
				 firstColumn.add(newOption,null);// standards compliant; doesn't work in IE
				}
				catch(ex){
					firstColumn.add(newOption);// IE only
				}
			}
			populateSecondOption();

		    populateThirdOption();
			}
			 
			if(i==1){
			 secondColumn.length=0;
		     var values1 = firstColumn.value;
		    	for(var k=0;k<colNames.length,k<colLabel.length;k++){
		  		   var newOption = document.createElement('option');
				   newOption.text =colLabel[k];
				   newOption.value = colNames[k];
				   newOption.title = colLabel[k];				   
				   var colName = colNames[k];
				   if(colName.indexOf("@")>0)
				   {
				   		var firstIndex = colName.indexOf("@");
					   	var lastIndex = colName.indexOf("|");
					   	colName = colName.substring(firstIndex+1,lastIndex);
				   }
					if(colNames[k]!=values1){
				       if(colName == parameterArray[i] ||colNames[k]==parameterArray[i] ){
					     newOption.selected=true;
					   if(directionArray.length>1){
						 if(directionArray[1]=='ascending'){

							obj2[0].checked=true;
						 }
						 if(directionArray[1]=='descending'){	

							obj2[1].checked=true;
						 }
					   }
					   else{
				        	 if(obj1[0].checked==true){
						      obj2[0].checked=true;
					         }
						     if(obj1[1].checked==true){	
							 obj2[1].checked=true;
       						 }
					
					   } 
				       }
				
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
		    if(i==2){
		      thirdColumn.length=0;
		      var values1 = firstColumn.value;
		      var values2 = secondColumn.value;
			    for(var l=0;l<colNames.length,l<colLabel.length;l++){
				   var newOption = document.createElement('option');
				   newOption.text = colLabel[l];
				   newOption.value = colNames[l];
				   newOption.title = colLabel[l];				   
				   var colName = colNames[l];
				   if(colName.indexOf("@")>0)
				   {
						var firstIndex = colName.indexOf("@");
						var lastIndex = colName.indexOf("|");
						colName = colName.substring(firstIndex+1,lastIndex);
				   }
				    if((colNames[l]!=values1)&&(colNames[l]!=values2)){
				      if(colName == parameterArray[i] ||colNames[l] == parameterArray[i]){
					    newOption.selected=true;
						 if(directionArray.length>2){
						   if(directionArray[2]=='ascending'){
							obj3[0].checked=true;
						   }
						   if(directionArray[2]=='descending'){
							obj3[1].checked=true;
						   }
					     }
					     else{
					        if(obj2[0].checked==true){
							 obj3[0].checked=true;
						    }
						    if(obj2[1].checked==true){	
							 obj3[1].checked=true;
						    }
					
					     }
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
		  }},emxUICoreMenu.WATCH_DELAY);
       }
//if NO URL(sortColumnName,sortDirection)paramters in the HREF of the Command	  
	   else{
	 	  colNames=getSortColumnValuesArray();
		  colLabel=getSortColumnLabelArray();
		  optionElement(firstColumn);
		  optionElement(secondColumn);
		  optionElement(thirdColumn);
	   }
  }
//To Populate the second Option
  function populateSecondOption(){
	colLabel = getSortColumnLabelArray();
	colNames = getSortColumnValuesArray();
    firstColumn=document.getElementById("firstColumn");
	secondColumn=document.getElementById("secondColumn");
	thirdColumn=document.getElementById("thirdColumn");
	var firstvalues = firstColumn.value;
	var secondvalues=secondColumn.value;
	secondColumn.length=0;
	for(var i=0; i<colNames.length,i<colLabel.length; i++){
	  if(firstvalues != "None"){
			 if(secondvalues == "None" || secondvalues == ""){
			 	if(colNames[i] != firstvalues){
			 		var newOption = document.createElement('option');
					newOption.text = colLabel[i];
					newOption.value= colNames[i];
					newOption.title= colLabel[i];					
					try{
					   secondColumn.add(newOption,null);
					}
					catch(ex){
					   secondColumn.add(newOption);
					}
					
			    }
			 }
			 else{
			 	 if(colNames[i]!=firstvalues){
				 var newOption = document.createElement('option');
				  newOption.text = colLabel[i];
			      newOption.value=colNames[i];
			      newOption.title=colLabel[i];			      
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
		
		  }
		  else{
		  		var newOption = document.createElement('option');
				newOption.text= colLabel[i];
				newOption.value=colNames[i];
				newOption.title=colLabel[i];				
				try{
					secondColumn.add(newOption,null);
				}
				catch(ex){
					secondColumn.add(newOption);
				}
		  }
	  }
	  
  }
//To Populate the third Option
  function populateThirdOption(){
  	colLabel = getSortColumnLabelArray();
    colNames = getSortColumnValuesArray();    
    firstColumn=document.getElementById("firstColumn");
    secondColumn=document.getElementById("secondColumn");
    thirdColumn=document.getElementById("thirdColumn");
    var firstValues=firstColumn.value;
    var secondValues=secondColumn.value;
    var thirdValues=thirdColumn.value;
    thirdColumn.length=0;
	  for(var i=0;i<colNames.length,i<colLabel.length;i++){
		  if(firstValues=="None"){
			 if(secondValues!="None" && colNames[i]!=secondValues){
      		    var newOption = document.createElement('option');
				newOption.text= colLabel[i];
				newOption.value=colNames[i];
				newOption.title=colLabel[i];				
				 try{
				   thirdColumn.add(newOption,null);
				 }
				 catch(ex){
				   thirdColumn.add(newOption);
				 }
			 }
			 else{
				var newOption = document.createElement('option');
				newOption.text=colLabel[i];
				newOption.value=colNames[i];
				newOption.title=colLabel[i];				
				try{
				   thirdColumn.add(newOption,null);
				}
				catch(ex){
				   thirdColumn.add(newOption);
				}
			 }
		  }
		  else{
			   if(secondValues=="None"){
				  if(colNames[i]!=firstValues){
					 var newOption = document.createElement('option');
					 newOption.text= colLabel[i];
					 newOption.value=colNames[i];
					 newOption.title=colLabel[i];					 
					 try{
						thirdColumn.add(newOption,null);
					 }
					 catch(ex){
						thirdColumn.add(newOption);
					 }
				  }
			   }
			   else{
					if(colNames[i]!==firstValues&&colNames[i]!==secondValues){
					  var newOption = document.createElement('option');
					  newOption.text= colLabel[i];
					  newOption.value=colNames[i];
					  newOption.title=colLabel[i];					  
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
//Validations for "None" values
  function populate(){
	if(firstColumn.value=="None"){
		secondColumn.value="None";
		thirdColumn.value="None";
	}
	if(secondColumn.value=="None"){
		thirdColumn.value="None";
	} 
  }

//Validation regarding coflicts
  function conflict(){
	if(firstColumn.value==secondColumn.value){
		secondColumn.value="None";
		populateSecondOption();
	}
	if(firstColumn.value==thirdColumn.value){
		thirdColumn.value="None";
		populateThirdOption();
	}
	if(secondColumn.value==thirdColumn.value){
		thirdColumn.value="None";
		populateThirdOption();
	} 
  }
//To populate the value when No URL parameter is specified
   function optionElement(element){
	colNames=getSortColumnValuesArray();
	colLabel=getSortColumnLabelArray();	
	var selectedElement = "";
	if(element)
	{
		for(var i=0;i<element.options.length;i++)
		{
			if(element.options[i].selected)
			selectedElement = element.options[i].value;
		}
	}
	element.length=0;
	 for(var i=0;i<colNames.length,i<colLabel.length;i++){
	 	   var newOption = document.createElement('option');
		   newOption.text= colLabel[i];
		   newOption.value= colNames[i];
		   newOption.title=colLabel[i];		   
		   try{
				element.add(newOption,null);
		   }
		   catch(ex){
				element.add(newOption);
		   }
		   if(selectedElement == colNames[i])
		   		element.options[i].selected = true;
	 }
	 
	}
     
//To set the global array of sortable columns to construct option element	
  function setSortColumnsArray(selectedColNames,selectedColLabel){
   
   sortColNames.length=0;
   sortColLabel.length=0;   
    for(var i=0;i<selectedColNames.length;i++){
      sortColNames.push(selectedColNames[i]);
    }

    for(var j=0;j<selectedColLabel.length;j++){
      sortColLabel.push(selectedColLabel[j]);
    }	
	
  }
//To get the global array of sortable column values to construct option element	
  function getSortColumnValuesArray(){

    return sortColNames;
  }
//To get the global array of sortable column label to construct option element
  function getSortColumnLabelArray(){

    return sortColLabel;
  }		
