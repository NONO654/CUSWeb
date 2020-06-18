<%@include file = "../common/emxPLMOnlineAdminAttributesCalculation.jsp"%>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxPLMOnlineAdminAuthorize.jsp"%>
<%@include file = "../common/emxPLMOnlineIncludeStylesScript.inc"%>
<%
        String OrgName  = emxGetParameter(request,"OrgName");
	String source  = emxGetParameter(request,"Source");
	String OrgType  = emxGetParameter(request,"OrgType");
	String Search = getNLS("Search");
        String orgParentName= emxGetParameter(request,"orgParentName");

	if (source == null) source="";
	if (OrgType == null) OrgType="";
%>
<html>
<head>
<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="javascript" src="../common/scripts/emxUICoreMenu.js"></script>
<script type="text/javascript">
	addStyleSheet("emxUIToolbar");
</script>
<script language="JavaScript" src="scripts/emxUIActionbar.js"></script>
<script language="JavaScript" src="scripts/emxUIToolbar.js"></script>
<script>
    var xmlreqs = new Array();
    var xmlhttpRoleAppBefore="";
    var sizeOfApplicable =  0;
    var appRole = "";
       
    
  function queryOrganization(){
	   var FilterValue = document.getElementById("Filter").value;	  
       xmlreq("emxPLMOnlineAdminAjaxResponse.jsp","source=Organization&Destination=VPLMAdmin&responseOrg=org_Type,org_Parent&filterOrg="+FilterValue,formatResponse,0);
  }

   
     function doneClose(){
    	var Solution = document.getElementsByName("radioSelect");
         
        for (var i = 0 ; i < Solution.length ; i++){
         if (Solution[i].checked){
		if( top.content.portalDisplay.APPVPLMOrganization == undefined){
        	 var parent = top.content.portalDisplay.APPXPOrganization.Topos.document.getElementById("OrgParent");
		}else{
        	 var parent = top.content.portalDisplay.APPVPLMOrganization.Topos.document.getElementById("OrgParent");
		}
			while(parent.hasChildNodes()) parent.removeChild(parent.lastChild);
			 parent.appendChild(document.createTextNode(Solution[i].id));
         }
        }
    	
        turnOffProgress();
        
        top.document.getElementById("layerOverlay").style.display   ="none";
       top.closeSlideInDialog();
        

    }


    
    function formatResponse(){
        var xmlhttp= xmlreqs[0];
            xmlhttp.onreadystatechange=function()
            {
               if(xmlhttp.readyState==4)
               {
            	
            	   var organizationName = xmlhttp.responseXML.getElementsByTagName("Organization");
            	   var tableResultat = document.getElementById("tabResult");
            	   tableResultat.style.visibility = "";
            	   if(organizationName.length == 0){
            		   turnOffProgress();
                       document.getElementById("ErrorMessage").innerHTML = "No Organization in the DB";
            	   }else{
            		   var nbRow =  document.getElementById("tabResult").rows.length;
                       if(nbRow > 1){
                           for (var j = 0 ; j < nbRow-1 ; j++){
                            document.getElementById('tabResult').deleteRow(-1);
                           }
                       }
                       
            		   for (var i = 0 ; i < organizationName.length ; i++){
                           var row=tableResultat.insertRow(-1);
                           var org_Parent="";
                           var org_Type="";
                           //Adding the First Cell
                           var org = organizationName[i].getElementsByTagName("PLM_ExternalID")[0].firstChild.data;

                           if(organizationName[i].getElementsByTagName("org_Parent").length > 0 && organizationName[i].getElementsByTagName("org_Parent")[0].firstChild != null){
                        	   org_Parent = organizationName[i].getElementsByTagName("org_Parent")[0].firstChild.data;
                           }
                           if(organizationName[i].getElementsByTagName("org_Type").length > 0 && organizationName[i].getElementsByTagName("org_Type")[0].firstChild != null){
                        	   org_Type = organizationName[i].getElementsByTagName("org_Type")[0].firstChild.data;
                           }
                           var checkID="";
                          
                           if (("<%=OrgType%>" == "Company") ){
                        	  if (org_Type == ("Company") ){
                        		  
                         	      if ( (org != "<%=OrgName%>") && ("<%=OrgName%>" != org_Parent) && (org != "<%=orgParentName%>") ){
                            		   checkID=document.createElement("input");
                            		   checkID.setAttribute("type","radio");     
                            		   checkID.setAttribute("name","radioSelect");     
                            		   checkID.setAttribute("id",org);     
                 		          
 	                	           var newCell = addCellInARow(row, "MatrixFeel", 0);
								   newCell.appendChild(checkID);
 	                    	       newCell = addCellInARow(row, "MatrixFeel", 1);
								   newCell.appendChild(document.createTextNode(org));
 	                        	   newCell = addCellInARow(row, "MatrixFeel", 2);
								   newCell.appendChild(document.createTextNode(org_Type));
 	                           	   newCell = addCellInARow(row, "MatrixFeel", 3);
								   newCell.appendChild(document.createTextNode(org_Parent));
                            	}
                           }
                           }
                           if (("<%=OrgType%>" == "Business Unit")){
                        	 
                          	 
                        	   if ( (org_Type == ("Company")) || (org_Type == ("Business Unit")) ){
                        		   if ( (org != "<%=OrgName%>") && ("<%=OrgName%>" != org_Parent) && (org != "<%=orgParentName%>") ){
                            		   checkID=document.createElement("input");
                            		   checkID.setAttribute("type","radio");     
                            		   checkID.setAttribute("name","radioSelect");     
                            		   checkID.setAttribute("id",org);     
                 		          
 	                	           var newCell = addCellInARow(row, "MatrixFeel", 0);
								   newCell.appendChild(checkID);
 	                    	       newCell = addCellInARow(row, "MatrixFeel", 1);
								   newCell.appendChild(document.createTextNode(org));
 	                        	   newCell = addCellInARow(row, "MatrixFeel", 2);
								   newCell.appendChild(document.createTextNode(org_Type));
 	                           	   newCell = addCellInARow(row, "MatrixFeel", 3);
								   newCell.appendChild(document.createTextNode(org_Parent));
                             	}
                        	   }
                           
                           }
                           
                           if (("<%=OrgType%>" == "Department")){
                        	      if ( (org != "<%=OrgName%>") && ("<%=OrgName%>" != org_Parent)&& (org != "<%=orgParentName%>")  ){
                            		   checkID=document.createElement("input");
                            		   checkID.setAttribute("type","radio");     
                            		   checkID.setAttribute("name","radioSelect");     
                            		   checkID.setAttribute("id",org);     
                 		          
 	                	           var newCell = addCellInARow(row, "MatrixFeel", 0);
								   newCell.appendChild(checkID);
 	                    	       newCell = addCellInARow(row, "MatrixFeel", 1);
								   newCell.appendChild(document.createTextNode(org));
 	                        	   newCell = addCellInARow(row, "MatrixFeel", 2);
								   newCell.appendChild(document.createTextNode(org_Type));
 	                           	   newCell = addCellInARow(row, "MatrixFeel", 3);
								   newCell.appendChild(document.createTextNode(org_Parent));
                             	}
                           }
                           
            	   	}
            	   }
                   turnOffProgress();
                  
                }

            }
    }
    

 </script>
</head>
<body class="slide-in-panel">
    <div id="pageHeadDiv">
        <table>
            <tbody>
                <tr>
                    <td class="page-title">
                    	<% if(source.equals("VPLMAdmin")){
                    	%>
                    	<h2><%=getNLS("SelectAnOrganization")%></h2>
                        <%}else{%> 
                        <h2><%=getNLS("CurrentOrganization")%> : <%=OrgName%></h2>
                        <%}%> 
                     </td>
                     <td class="functions">
                         <table>
                             <tbody>
                                 <tr>
                                    <td class="progress-indicator">
                                        <div id="imgProgressDiv" style="visibility: hidden;"></div>
                                    </td>
                                </tr>
                             </tbody>
                         </table>
                    </td>
                </tr>
            </tbody>
        </table>

<div id="divToolbarContainer" class="toolbar-container">
            <div class="toolbar-frame" id="divToolbar">
            </div>
        </div>
    </div>
    <div id="divPageBody" style="top :87px;">
        <table  border="1px" style=" border-color: white;margin-top: 10px ; padding-top: 10px; top: 10px ">
            
           <tr >
                            <td>
                                <table border="1px" id="tabRes" style=" overflow:scroll; height: 20px ;  border-color: white" width="100%">
                                    <tr id="Header" style=" width: 100%" >
                                        <td class="MatrixLabel"><%=getNLS("SearchForOrganizations")%> :</td><td class="MatrixLabel"><input type="text" id="Filter" size="10" value="*">&nbsp;&nbsp;<img src="images/iconSmallSearch.gif" title="<%=Search%>" onclick="javascript:queryOrganization();" id="FilterOrg" style="cursor : pointer"></td>
                                    </tr>
                                </table>
                            </td>
           </tr>
           
           
       </table>
               <table  border="1px" style=" border-color: white;margin-top: 10px ; padding-top: 10px; top: 10px ">
            
           <tr >
                            <td>
                                <table border="1px" id="tabResult" style=" visibility: hidden;overflow:scroll; height: 20px ;  border-color: white" width="100%">
									<tr id="Header" style=" width: 100% ; "  >
                                        <td class="MatrixLabel"></td><td class="MatrixLabel"><%=getNLS("Name")%></td><td class="MatrixLabel"><%=getNLS("Type")%></td><td class="MatrixLabel"><%=getNLS("Parent")%></td>
                                    </tr>
                                </table>
                            </td>
           </tr>
           
           
       </table>
    </div>
      
    <div id="divPageFoot">
        <script>addFooter("javascript:doneClose()", "images/buttonDialogDone.gif", '<%=getNLS("Done")%>','<%=getNLS("Done")%>',"javascript:top.closeSlideInDialog()", "images/buttonDialogCancel.gif", '<%=getNLS("Cancel")%>','<%=getNLS("Cancel")%>');</script>
    </div>
</body>
</html>
