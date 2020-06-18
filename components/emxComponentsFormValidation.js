/*!================================================================
 *  JavaScript Form Validaion
 *  emxComponentsFormValidation.js
 *  Version 1.1
 *
 *  Copyright (c) 1992-2018 Dassault Systemes. All Rights Reserved.
 *  This program contains proprietary and trade secret information
 *  of MatrixOne,Inc. Copyright notice is precautionary only
 *  and does not evidence any actual or intended publication of such program
 *
 *  static const char RCSID[] = $Id: emxComponentsFormValidation.js.rca 1.6 Wed Oct 22 16:18:58 2008 przemek Experimental przemek $
 *=================================================================
 */
 
getTopWindow().isStartRouteClicked=false;
function startRoute(){
	if(!getTopWindow().isStartRouteClicked){
		getTopWindow().isStartRouteClicked = true;
		var objId = "";	
		var objForm = this.frmFormView;
		for (var i=0; i < objForm.elements.length; i++) {
		      if(objForm.elements[i].name == "objectId"){
		      	objId = objForm.elements[i].value;
		      	break;
		      }
		}
		findFrame(getTopWindow(),"formViewHidden").location.href ="../components/emxRouteStartPreProcess.jsp?objectId=" + objId;
		
	}
	return;
}



function disableOrganization()
{
  
  for(i=0;i<document.forms[0].elements.length;i++)
  {
    if(document.forms[0].elements[i].name == 'Organization')
    {
    document.forms[0].elements[i+2].disabled=true;
     document.forms[0].OrganizationDisplay.value="";
    break;
    }
  }
}

function enableOrganization(name,id)
{
  
  
  for(i=0;i<document.forms[0].elements.length;i++)
  {
    if(document.forms[0].elements[i].name == 'Organization')
    {
    document.forms[0].elements[i+2].disabled=false;
    document.forms[0].OrganizationDisplay.value=name;
    document.forms[0].OrganizationOID.value=id;
    break;
    }
  }
}


function disablePersonalRadio(){
  if(document.forms[0].rb[1].checked){
        document.forms[0].rb[1].checked = false;
        document.forms[0].rb[0].checked = true;
        return;
      }else{
        document.forms[0].rb[0].checked = false;
        document.forms[0].rb[1].checked = true;
        return;
      }

  }

//Validating for Date Value
function IssueDateValidate(){

	var strESD = document.forms[0].EstimatedStartDate.value;
	var strEFD = document.forms[0].EstimatedFinishDate.value;
    	var msg = "";
		
    	var fieldESD = new Date(strESD);
    	var fieldEFD = new Date(strEFD);
   
	if ((trimWhitespace(strESD) != '') && (trimWhitespace(strEFD) != '') )
	{
		if (fieldESD > fieldEFD)
		{
            //Condition check when Estimated Start Date is after Estimated Finish Date. It should be before the Estimated Finish Date
			msg = "Invalid Date: Estimated Start Date should not be after Estimated Finish Date. Please enter the valid Dates.";
			alert(msg);
			return false;
		}
		
	}
	return true;
}  
