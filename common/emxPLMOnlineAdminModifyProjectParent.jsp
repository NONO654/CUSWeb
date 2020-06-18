<%@ page import="com.dassault_systemes.vplmposadministrationui.uiutil.AdminUtilities"%>
<%@include file = "../common/emxPLMOnlineAdminAttributesCalculation.jsp"%>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxPLMOnlineIncludeStylesScript.inc"%>
<%@include file = "../common/emxPLMOnlineAdminAuthorize.jsp"%>
<%
    String OrgName  = emxGetParameter(request,"projectName");
	String prjFamily  = emxGetParameter(request,"prjFamily");
	String childs  = emxGetParameter(request,"childs");
	String prjParent  = emxGetParameter(request,"prjParent");
	String source  = emxGetParameter(request,"Source");
	String SearchForProjects = getNLS("SearchForProjects");
	// RBR2: FUN[080973]
	String prjTitle = emxGetParameter(request,"projectV_Name");
	String prjParentTitle = emxGetParameter(request,"prjParentV_Name");;
	
		
	
	if (source == null) source="";
    String ERR_SecCtxAlreadyCreated  = getNLS("ERR_SecCtxAlreadyCreated");
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
       
    
  function queryProject(){
	   // RBR2: Now this filter will be V_Name
	   var FilterValue = document.getElementById("Filter").value;	  
       xmlreq("emxPLMOnlineAdminAjaxResponse.jsp","source=Project&Solution=VPLM&Destination=VPLMAdmin&Method=Query&Filter="+FilterValue+"&FamilyFilter="+"<%=prjFamily%>",formatResponse,0);
  }

     // RBR2: FUN[080973]
     function doneClose(){
    	var Solution = document.getElementsByName("radioSelect");
         
        for (var i = 0 ; i < Solution.length ; i++){
         if (Solution[i].checked){
		if( top.content.portalDisplay.APPVPLMProject == undefined){
			var parent = top.content.portalDisplay.APPVPLMProjectSearch.Topos.document.getElementById("PrjParent");
			var parentTitle = top.content.portalDisplay.APPVPLMProjectSearch.Topos.document.getElementById("PrjParentV_Name");
		}else{
			var parent = top.content.portalDisplay.APPVPLMProject.Topos.document.getElementById("PrjParent");
			var parentTitle = top.content.portalDisplay.APPVPLMProject.Topos.document.getElementById("PrjParentV_Name");
		}
			while(parent.hasChildNodes()) parent.removeChild(parent.lastChild);
        	parent.appendChild(document.createTextNode(Solution[i].id)); // PRJ Name Hidden 
        	
			while(parentTitle.hasChildNodes()) parentTitle.removeChild(parentTitle.lastChild);
        	
			parentTitle.appendChild(document.createTextNode(Solution[i].getAttribute("v_name").toString())); // V_Name

         }
        }
    	
        turnOffProgress();
        
        top.document.getElementById("layerOverlay").style.display   ="none";
       top.closeSlideInDialog();
        

    }

	 // RBR2: FUN[080973]
     function formatResponse(){
         var xmlhttp= xmlreqs[0];
             xmlhttp.onreadystatechange=function()
             {
                if(xmlhttp.readyState==4)
                {
                	var projectName = xmlhttp.responseXML.getElementsByTagName("Project");
                	 var tableResultat = document.getElementById("tabResult");
              	    tableResultat.style.visibility = "";
              	    if(projectName.length == 0){
              		   turnOffProgress();
                         document.getElementById("ErrorMessage").innerHTML = "No Project in the DB";
              	   }else{
              		     var nbRow =  document.getElementById("tabResult").rows.length;
                         if(nbRow > 1){
                             for (var j = 0 ; j < nbRow-1 ; j++){
                              document.getElementById('tabResult').deleteRow(-1);
                             }
                         }
                        
                    	
              		   for (var i = 0 ; i < projectName.length ; i++){
                             var row=tableResultat.insertRow(-1);
                             var prj_Parent="";
                             var prj_Parent_Title  = "";
                             var prj_Family="";
                             var prj_Accreditation="";
                             //Adding the First Cell
                             var prj = projectName[i].getElementsByTagName("PLM_ExternalID")[0].firstChild.data;
                             var prjTitle = projectName[i].getElementsByTagName("V_Name")[0].firstChild.data;
                             if(projectName[i].getElementsByTagName("Family").length > 0 && projectName[i].getElementsByTagName("Family")[0].firstChild != null){
                            	 prj_Family = projectName[i].getElementsByTagName("Family")[0].firstChild.data;
                             }
                               if ( (prj_Family == "<%=prjFamily%>") && ("<%=OrgName%>" != prj) ) {
                            	   if("<%=childs%>".indexOf(prj) == -1){
	                            	   if(projectName[i].getElementsByTagName("project_Parent").length > 0 && projectName[i].getElementsByTagName("project_Parent")[0].firstChild != null){
    	                        	 		prj_Parent = projectName[i].getElementsByTagName("project_Parent")[0].firstChild.data;
        	                           }
	                            	   if(projectName[i].getElementsByTagName("Project_Parent_V_Name").length > 0 && projectName[i].getElementsByTagName("Project_Parent_V_Name")[0].firstChild != null){
	                            		   prj_Parent_Title = projectName[i].getElementsByTagName("Project_Parent_V_Name")[0].firstChild.data;
       	                          	   }
            	                	   if(projectName[i].getElementsByTagName("Accreditation").length > 0 && projectName[i].getElementsByTagName("Accreditation")[0].firstChild != null){
                	            			   prj_Accreditation = projectName[i].getElementsByTagName("Accreditation")[0].firstChild.data;
                    	              }
                        	    		
                            		   var checkID=document.createElement("input");
                            		    checkID.setAttribute("type","radio");     
                            		    checkID.setAttribute("name","radioSelect");     
                            		    checkID.setAttribute("id",prj);
                            		    checkID.setAttribute("v_name",prjTitle);
                            	   		var newCell = addCellInARow(row, "MatrixFeel", 0);
										newCell.appendChild(checkID);
   	                    	       		newCell = addCellInARow(row, "MatrixFeel", 1);
   	                        	   		newCell.appendChild(document.createTextNode(prjTitle));
   	                        	   		newCell = addCellInARow(row, "MatrixFeel", 2);
	                        	   		newCell.appendChild(document.createTextNode(prj));
										newCell = addCellInARow(row, "MatrixFeel", 3);
										newCell.appendChild(document.createTextNode(prj_Parent));
										newCell.setAttribute("hidden", true); // Hide Parent Name instead show title
   	                           	  		newCell = addCellInARow(row, "MatrixFeel", 4);
	                           	   		newCell.appendChild(document.createTextNode(prj_Parent_Title));
										newCell = addCellInARow(row, "MatrixFeel", 5);
   	                           			newCell.appendChild(document.createTextNode(prj_Accreditation));
										newCell = addCellInARow(row, "MatrixFeel", 6);
										newCell.appendChild(document.createTextNode(prj_Family));
								}
                              }
              	   	}
              	   }
                   turnOffProgress();
                    
    //                  top.document.getElementById("layerOverlay").style.display   ="none";
                     // top.content.portalDisplay.APPVPLMLocalAdministration.sommaire.document.getElementById("ClickButton").click();
  			  //top.closeSlideInDialog();
                  }

              }
     }
   
    
    
    //TODO : Refresh Number Of Sec Context

    function EditMode(){
          var checkBoxesElements = document.getElementsByTagName("input");
          var j=0;
            for(var i = 0 ; i < checkBoxesElements.length ; i++){
            if ((checkBoxesElements[i].disabled) && !(checkBoxesElements[i].checked)){
                j = j+1;
                checkBoxesElements[i].disabled=false;
                }
            }
            if (j == 0){alert("<%=ERR_SecCtxAlreadyCreated%>");}
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
                    	<h2><%=getNLS("SelectAProject")%></h2>
                        <%}else{%> 
                        <h2><%=getNLS("CurrentProject")%> : <%=OrgName%></h2>
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
                                        <td class="MatrixLabel"><%=SearchForProjects%> :</td><td class="MatrixLabel"><input type="text" id="Filter" size="10" value="*">&nbsp;&nbsp;<img src="images/iconSmallSearch.gif" onclick="javascript:queryProject();" id="FilterOrg" style="cursor : pointer"></td>
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
										<!-- RBR2: Title added to table -->
                                        <td class="MatrixLabel"></td>
                                        <td class="MatrixLabel"><%=getNLS("Title")%></td>
                                        <td class="MatrixLabel"><%=getNLS("Name")%></td>
                                        <td class="MatrixLabel" hidden><%=getNLS("Parent")%></td>
                                        <td class="MatrixLabel" id="parentV_Name"><%=getNLS("Parent")%></td>
                                        <td class="MatrixLabel"><%=getNLS("Accreditation")%></td>
                                        <td class="MatrixLabel"><%=getNLS("Family")%></td>
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
