var strFeatureSingle = "Single";
var strFeatureMultiple = "Multiple";
var strUsageRequired = "Required";
var flag;



function validate(obj)
   {
//	var divID = obj.getAttribute("rowid");
//	//for top level lf Rowid is appended
//    if((divID).indexOf("Rowid")>=0)
//		divID = divID.substring(divID.indexOf("Rowid")+5, divID.length);
	var divID = obj.getAttribute("PFLid");
	
	var nameAttr = obj.name;
	var level=obj.getAttribute("level");
	var InputCollection = document.getElementsByTagName("INPUT");   
	getpreviousSelection(InputCollection,nameAttr,level);	
	var selectefeature = document.getElementById("DIV"+divID);	
	var seletparentid = selectefeature.getAttribute("parentid");	
	var seleclevel = selectefeature.getAttribute("level");	
	var selfid = selectefeature.getAttribute("selfid");	
	var selffeature = selectefeature.getElementsByTagName("input")[0];	
	flag = selffeature.checked;	
	if(flag)
	{		
	//Goto top feature or parent feature which selectiontype is multiple
	topfeature(seletparentid,seleclevel);	
	//Calling a function to make selection of all parents	
	selffeature.checked =true;
    makeSelectRequiredChilds(seleclevel,selfid);
	makeparentselect(seletparentid);	
	}
	else
		{	
		   var featurelevel = selectefeature.getAttribute("level");
			makeDeselection(featurelevel,selfid);
		}		
  }
function topfeature(seletparentid,seleclevel)
{
	var immparentfeature = document.getElementById(seletparentid);
	if(immparentfeature !=null){
		var selectiontype = immparentfeature.getAttribute("selectiontype");
		var immparentfeatureid = immparentfeature.getAttribute("parentid");
		var immparentfeaturelevel = immparentfeature.getAttribute("level");
		var immparentfeaturedvid = immparentfeature.getAttribute("rowid");
	
		if(((selectiontype == strFeatureMultiple) || !(immparentfeatureid))&& seleclevel<immparentfeaturelevel)
			{
			makeDeselection(immparentfeaturelevel,immparentfeaturedvid,flag);
			}
		else
			{
				if(immparentfeatureid=="")
					{
					return;
					}
				else
					{
					topfeature(immparentfeatureid,immparentfeaturelevel);
					}
			
			}
	}
}

/*make selection of all parents
 * input is parentid
 */	
function makeparentselect(parentid)
	{
		
	var nextparentfeature = document.getElementById(parentid);
	if(nextparentfeature!=null){
	nextparentfeature.checked =true;
	
	var selectionType = nextparentfeature.getAttribute("selectiontype");
	var level = nextparentfeature.getAttribute("level");
	if(selectionType == strFeatureMultiple)
		{
		    makeSelectRequiredChilds(level,parentid);
		}
	
	var nextparentid = nextparentfeature.getAttribute("parentid");
	if(nextparentid)
		{
		makeparentselect(nextparentid);
		}
	}	
	
	}
 
 function checkParentSelected(parentid)
	{
	 var nextparentfeature=null;
	 if(parentid!=""){
		 nextparentfeature = document.getElementById(parentid);
	 }
	if(nextparentfeature!=null){
	
	if(!nextparentfeature.checked){		
		return false;
	}	
	var nextparentid = nextparentfeature.getAttribute("parentid");
	if(nextparentfeature!=null){
	if(nextparentid)
		{
		checkParentSelected(nextparentid);
		}	
	}
	}
	return true;
	}
 
 function makeSelectRequiredChilds(level,parentid)
 {
	 var groupElementlevel;
	 var groupElemnts;
	 groupElemnts = document.getElementsByTagName("div");
	  for(var i=0; i<groupElemnts.length; i++) {
	         var groupElemnt = groupElemnts[i];
	         var parentId = groupElemnt.getAttribute("parentid");
	         if(parentId == parentid){
	        	var groupElementlevel = groupElemnt.getAttribute("level");
	        	var groupElementid = groupElemnt.getAttribute("selfid");
		  		if ((groupElementlevel>level))
				  {
		  			var groupElementUsage = groupElemnt.getAttribute("usage");
		  			if(groupElementUsage == strUsageRequired)
		  				{
		  				document.getElementById(groupElementid).checked = true;
		  				}
		  			
		  		  }
	         }
	  }
	 
 }
 
 function makeDeselection(level,dvid)
 {
	  var groupElementlevel;
	  var groupElemnts;
	  var groupElemnt;
	  
	  groupElemnts = document.getElementsByTagName("div");	
	  for(var i=0; i<groupElemnts.length; i++) {
	         var groupElemnt = groupElemnts[i];
	         var parentId = groupElemnt.getAttribute("parentid");
	         if(parentId == dvid){
	        	groupElementlevel = groupElemnt.getAttribute("level");
	        	groupElementlevel = groupElemnt.getAttribute("level");	        
		  		groupElementid = groupElemnt.getAttribute("selfid");
		  		if ((groupElementlevel>level))
				  {
		  			document.getElementById(groupElementid).checked = false;
		  			makeDeselection(groupElementlevel,groupElementid);
		  		  }
	         }	       
	  }
	  
	  var tBody = document.getElementById("featureOptionsBody");	 
	  if(tBody)
	  {	 
	 	 for(var i=0; i<tBody.rows.length; i++) {
	          var rows = tBody.rows[i];
	          var rowId = rows.getAttribute("id");
	          var rowParentId = rows.getAttribute("parentLFId");	          
	          if( rowParentId != null && rowParentId == dvid){
	         	 var selId = rowId.replace("Rowid", "");
	         	 var selffeature = document.getElementById(selId);
	         	 if (selffeature.getAttribute("type") == "hidden"){
	         		document.getElementById('hconnectedrels').value =document.getElementById('hconnectedrels').value+","+selffeature.getAttribute("relid") ;
		         	 document.getElementById('hPFLIds').value =document.getElementById('hPFLIds').value+","+selffeature.getAttribute("pflid");
		         	 tBody.deleteRow(i);
		         	 i--;
	         	 }
	          }
	 	 }
	  }
 }
 
 function removeAddedRows(parentFtrLstId, optionFtrLstId, parentId, subFeatureId,isParentDeselect)
 {
	 
	 var tBody = document.getElementById("featureOptionsBody");
	 var parentRowId = "Rowid"+parentId;
	 var subFeaRowId = "Rowid"+subFeatureId;
	 var parentInput = document.getElementById("DIV"+parentId);
	 if(tBody)
	 {	 var index = 0;
		 for(var i=0; i<tBody.rows.length; i++) {
	         var rows = tBody.rows[i];
	         var rowId = rows.getAttribute("id");
	         if(subFeaRowId == rowId){
	        	 index = i;
	         }
		 }
		 
    	 var selffeature = document.getElementById(subFeatureId);           
    	 document.getElementById('hconnectedrels').value =document.getElementById('hconnectedrels').value+","+selffeature.getAttribute("relid") ;
    	 document.getElementById('hPFLIds').value =document.getElementById('hPFLIds').value+","+selffeature.getAttribute("pflid");
		 var subFeaCnt = 0 ;
		 for(var i=0; i<tBody.rows.length; i++) {
	         var rows = tBody.rows[i];
	         var rowId = rows.getAttribute("parentLFId");
	         if(parentId == rowId){
	        	 subFeaCnt++;
	         }
		 }
		 tBody.deleteRow(index);		
		 if(subFeaCnt==0){
			 parentInput.childNodes[0].checked = false;
		 }
	 }
 }

	
	
		
	
	function getpreviousSelection(InputCollection,nameAttr,level){
		for (var i = 0; i < InputCollection.length; i++) {		 
	        if (InputCollection[i].type == "radio"  && InputCollection[i].name == nameAttr && InputCollection[i].getAttribute("level")<=level) { 
	        	if (!InputCollection[i].checked) {	        		
	        		for (var j = 0; j < InputCollection.length; j++) {	        				        			
	        				makeDeselection(level, InputCollection[j].getAttribute("rowid"));        			
	        		}        		
	        	}                 
	        } 
	    }
	}
	
