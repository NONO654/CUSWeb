/*
*=================================================================
** emxMEPFormValidation.js
** Copyright Dassault Systemes, 2007. All rights reserved
** This program is proprietary property of Dassault Systemes and its subsidiaries.
** This documentation shall be treated as confidential information and may only be used by employees or contractors
** with the Customer in accordance with the applicable Software License Agreement
** static const char RCSID[] = $Id: /ENOManufacturerEquivalentPart/CNext/webroot/manufactuerequivalentpart/scripts/emxMEPFormValidation.js 1.6.2.1.1.1 Wed Oct 29 22:14:50 2008 GMT przemek Experimental$
*=================================================================
*/



function clearField(formName,fieldName,idName) 
{
    var operand = "document." + formName + "." + fieldName+".value = \"*\";";
    eval (operand);
    if(idName != null){
        var operand1 = "document." + formName + "." + idName+".value = \"*\";";
        eval (operand1);
    }   
    return;
}
function vaultSelection()
{
  var vaultSelected = document.editDataForm.vaultOption[3].checked;
  var selectedVault = document.editDataForm.vaultsDisplay.value;
  if(vaultSelected==true && selectedVault==""){
    alert("<emxUtil:i18nScript localize='i18nId'>emxManufacturerEquivalentPart.Common.selectvault</emxUtil:i18nScript>");
      return false;
  }else{
    return true;
  }
}

function ResetField(formName,fieldName,idName,manufacturer,manufacturerid) 
{
    var operand = "document." + formName + "." + fieldName+".value = \""+manufacturerid+"\";";
    eval (operand);
    if(idName != null){
        var operand1 = "document." + formName + "." + idName+".value = \""+manufacturer+"\";";
        eval (operand1);
    }   
    return;
}
function resetManuLoc(){
document.forms[0].ManufacturerLocationDisplay.value="";
document.forms[0].ManufacturerLocationOID.value="";
}
function loadRevision()
        {
        
        var orgId=document.forms[0].Manufacturer.value;
         var mxValidateURL = "../manufacturerequivalentpart/emxMEPRevValidation.jsp?orgId="+orgId ;
        var sResponse = emxUICore.getData(mxValidateURL);
        
        var values=sResponse.split("|");
        
       
        var CompId=values[0];
        var CageCode=values[1];
        var customRevision=values[2];
        var uniqueIdentifier=values[3];
        var revSeq=values[5];
        var idx = document.forms[0].Policy.selectedIndex;
    
        var policyName = document.forms[0].Policy.options[idx].value;
        var revision = customRevision;
        var id = uniqueIdentifier;
        var ccode = CageCode;
        var cid = CompId;
            if( id == "attribute_OrganizationID")
            {
              if(revision=="true"){
                document.forms[0].CustomRevision.value = cid;
                //Added - 010681
                document.forms[0].revision.value = cid;
                //Ends - 010681
                document.forms[0].customrev.value = cid;
                }else{
                document.forms[0].Revision.value = cid;
                document.forms[0].rev.value = cid;
                }
               // document.emxCreateForm.Revision.disabled=true;
            }
            else if (id == "attribute_CageCode")
            {
              if(revision=="true"){
                //IR-010681 : Modified CustomRevision to Revision
                //Added - 010681
                document.forms[0].revision.value = ccode;
                //Ends - 010681
                document.forms[0].CustomRevision.value = ccode;
                document.forms[0].customrev.value = ccode;
                }else{
                document.forms[0].Revision.value = ccode;
                document.forms[0].rev.value=ccode;
                    }
            }
            else
            {
              var policyIdx=revSeq;
              var Idxvalues=policyIdx.split(",");
               if(revision=="true"){
                //IR-010681 : Modified CustomRevision to Revision
                //Added - 010681
                document.forms[0].revision.value = Idxvalues[idx];
                //Ends - 010681
                document.forms[0].CustomRevision.value = Idxvalues[idx];
                document.forms[0].customrev.value = Idxvalues[idx];
                }else{
                  document.forms[0].Revision.value = Idxvalues[idx];
                 document.forms[0].rev.value=Idxvalues[idx];
                 }
              
                
            }
           
            
          }
          
 function setRevision()
    {

     var locId=document.forms[0].ManufacturerLocationOID.value;

   if(locId!=null &&  locId!=""){
  
    var mxValidateURL = "../manufacturerequivalentpart/emxMEPRevValidation.jsp?locId="+locId ;
    var sResponse = emxUICore.getData(mxValidateURL);
        
    var values=sResponse.split("|");
    var plantId=values[4];

    var tempRev = document.forms[0].Revision.value;
    var hiddenRev = document.forms[0].rev.value;
    if(tempRev.indexOf("-") != -1) {
        tempRev = tempRev.substring(0,tempRev.indexOf("-"));
    }
    if(hiddenRev.indexOf("-") != -1) {
        hiddenRev = hiddenRev.substring(0,hiddenRev.indexOf("-"));
    }
    document.forms[0].Revision.value = tempRev+"-"+plantId; 
    document.forms[0].rev.value = hiddenRev+"-"+plantId; 
        }
    }

    //Added - 010681
    function setMEPRevision()
    {
        document.forms[0].revision.value = document.forms[0].CustomRevision.value;
	}
    //Ends - 010681




// Added  for enabling type ahead ///
function loadRevision(targetWindow)
{
        var orgId=targetWindow.document.getElementsByName("Manufacturer")[0].value;
        if(orgId==null || typeof(orgId)==undefined){
        	orgId=targetWindow.document.getElementsByName("Manufacturer")[0];
        }
 
              
         var mxValidateURL = "../manufacturerequivalentpart/emxMEPRevValidation.jsp?orgId="+orgId ;
        var sResponse = emxUICore.getData(mxValidateURL);
        
        var values=sResponse.split("|");
        
       
        var CompId=values[0];
        var CageCode=values[1];
        var customRevision=values[2];
        var uniqueIdentifier=values[3];
        var revSeq=values[5];
        var idx = document.forms[0].Policy.selectedIndex;
        
        var policyName =targetWindow.document.getElementsByName("Policy")[0].options[idx].value;
        
        var revision = customRevision;
        var id = uniqueIdentifier;
        var ccode = CageCode;
        var cid = CompId;
            if( id == "attribute_OrganizationID")
            {
              if(revision=="true"){
                targetWindow.document.getElementsByName("CustomRevision")[0].value = cid;
                targetWindow.document.getElementsByName("revision")[0].value = cid;
                targetWindow.document.getElementsByName("customrev")[0].value = cid;
                }else{
                targetWindow.document.getElementsByName("Revision")[0].value = cid;
                targetWindow.document.getElementsByName("rev")[0].value = cid;
                	
                }
           
            }
            else if (id == "attribute_CageCode")
            {
              if(revision=="true"){
                 targetWindow.document.getElementsByName("revision")[0].value = ccode;
              	targetWindow.document.getElementsByName("CustomRevision")[0].value = ccode;
              	targetWindow.document.getElementsByName("customrev")[0].value = ccode;
                }else{
                targetWindow.document.getElementsByName("Revision")[0].value = ccode;
                targetWindow.document.getElementsByName("rev")[0].value = ccode;
                    }
            }
            else
            {
              var policyIdx=revSeq;
              var Idxvalues ="";
              if(policyIdx != null && !("".equals(policyIdx)) && policyIdx != undefined)
              {
               Idxvalues=policyIdx.split(",");
              }
               if(revision=="true"){
                targetWindow.document.getElementsByName("revision")[0].value = Idxvalues[idx];
               
                	  targetWindow.document.getElementsByName("CustomRevision")[0].value = Idxvalues[idx];
            	  targetWindow.document.getElementsByName("customrev")[0].value = Idxvalues[idx];
                
                }else{
                	
                  targetWindow.document.getElementsByName("Revision")[0].value = Idxvalues[idx];
                  targetWindow.document.getElementsByName("rev")[0].value = Idxvalues[idx];
                 }
              
                
            }
           
            
          }
    
//Added  for enabling type ahead ///

 function setRevision (targetWindow)
{
   var locId=targetWindow.document.getElementsByName("ManufacturerLocation")[0].value;
     
        
   if(locId!=null &&  locId!=""){
	    
    var mxValidateURL = "../manufacturerequivalentpart/emxMEPRevValidation.jsp?locId="+locId ;
     
    var sResponse = emxUICore.getData(mxValidateURL);
        
    var values=sResponse.split("|");
    var plantId=values[4];

    var tempRev = targetWindow.document.getElementsByName("Revision")[0].value;
    var hiddenRev = targetWindow.document.getElementsByName("rev")[0].value;
    
    if(tempRev.indexOf("-") != -1) {
        tempRev = tempRev.substring(0,tempRev.indexOf("-"));
    }
    if(hiddenRev.indexOf("-") != -1) {
        hiddenRev = hiddenRev.substring(0,hiddenRev.indexOf("-"));
    }
    targetWindow.document.getElementsByName("Revision")[0].value = tempRev+"-"+plantId; 
    targetWindow.document.getElementsByName("rev")[0].value = hiddenRev+"-"+plantId; 
    }
}
