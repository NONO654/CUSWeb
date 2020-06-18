<%@include file = "../common/emxPLMOnlineAdminAttributesCalculation.jsp"%>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxPLMOnlineAdminAuthorize.jsp"%>
<%@include file = "../common/emxPLMOnlineIncludeStylesScript.inc"%>
<script type="text/javascript" src="scripts/emxUICore.js"></script>
<%
    String orgName  = emxGetParameter(request,"OrgName");
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
    function searchKeyPress(e)
    {
        if (typeof e == 'undefined' && window.event) { e = window.event; }
        if (e.keyCode == 13)
        {
			var butt = "btn";
			if(e.target) butt = butt+e.target.id;
			else if(e.srcElement) butt = butt+e.srcElement.id;
            document.getElementById(butt).click();
        }
    }

    var xmlreqs = new Array();
   
    function formatResult()
    {
        var xmlhttp1 = xmlreqs[0];

        xmlhttp1.onreadystatechange=function()
        {
            if(xmlhttp1.readyState==4)
            {   
            	var orgsTable = xmlhttp1.responseXML.getElementsByTagName("Organization");
                  
                var table=document.getElementById('TableResult');
                document.getElementById("TableResult").style.display = "";
                var nbRow = document.getElementById("TableResult").rows.length;
                if(nbRow > 1){
                    for (var j = 0 ; j < nbRow-1 ; j++){
                     document.getElementById('TableResult').deleteRow(-1);
                    }
                }
                
                for (var i = 0 ; i <orgsTable.length ; i++){
                    var row=table.insertRow(-1);
					 
					var name = orgsTable[i].getElementsByTagName("PLM_ExternalID")[0].firstChild.data;
					var type = "";
                    if (orgsTable[i].getElementsByTagName("org_Type").length>0 && orgsTable[i].getElementsByTagName("org_Type")[0].firstChild != null)
                        type =orgsTable[i].getElementsByTagName("org_Type")[0].firstChild.data;
					if(type!="Company") continue;
                    var parent = "";
                    if (orgsTable[i].getElementsByTagName("org_Parent").length>0 && orgsTable[i].getElementsByTagName("org_Parent")[0].firstChild != null)
                         parent =orgsTable[i].getElementsByTagName("org_Parent")[0].firstChild.data;
						 
					var checkID=document.createElement("input");
					checkID.setAttribute("type","radio");     
					checkID.setAttribute("name","radioSelect");     
					checkID.setAttribute("id",name);
					var newCell = addCellInARow(row, "MatrixFeel", 0);
					newCell.appendChild(checkID);
					newCell = addCellInARow(row, "MatrixFeel", 1);
					newCell.appendChild(document.createTextNode(name));
					newCell = addCellInARow(row, "MatrixFeel", 2);
					newCell.appendChild(document.createTextNode(type));
					newCell = addCellInARow(row, "MatrixFeel", 3);
					newCell.appendChild(document.createTextNode(parent));
				}
            }
        }
    }
    
    function afficheOrgs(){
	   var FilterValue = document.getElementById("FilterOrg").value;	  
       xmlreq("emxPLMOnlineAdminAjaxResponse.jsp","source=Organization&Destination=VPLMAdmin&responseOrg=org_Type,org_Parent&filterOrg="+encodeURIComponent(FilterValue),formatResult,0);
    }

     function doneClose(){
    	var name = document.getElementsByName("radioSelect");
         
        for (var i = 0 ; i < name.length ; i++){
         if (name[i].checked){
		if( top.content.portalDisplay.APPVPLMContext == undefined){
			var parent = top.content.portalDisplay.APPXPCreateSecurityContext.sommaire.document.getElementById("compName");
		}else{
			var parent = top.content.portalDisplay.APPVPLMContext.sommaire.document.getElementById("compName");
		}
        	parent.value = name[i].id;
			parent.onchange();
         }
        }
    top.document.getElementById("layerOverlay").style.display   ="none";
       top.closeSlideInDialog();
    }
 function FocusOnInput()
 {
	document.getElementById("FilterOrg").focus();
 }    
 </script>
</head>
<body onload="FocusOnInput()" class="slide-in-panel">
    <div id="pageHeadDiv">
        <table>
            <tbody>
                <tr>
                    <td class="page-title">
                    	<h2><%=getNLS("SearchForOrganizations")%></h2>
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
           <tr>
                            <td>
                                <table border="1px" id="tabRes" style=" overflow:scroll; height: 20px ;  border-color: white" width="100%">
                                    <tr id="Header" style=" width: 100%" >
                                        <td class="MatrixLabel"><%=getNLS("SearchForOrganizations")%> :</td><td class="MatrixLabel"><input onkeypress="searchKeyPress(event);" type="text" id="FilterOrg" size="10" value="<%=orgName%>"><img src="images/iconSmallSearch.gif" onclick="javascript:afficheOrgs();" id="btnFilterOrg" style="cursor : pointer"></td>
                                    </tr>
                                </table>
                            </td>
      </tr>
       </table>
      <table  border="1px" style=" border-color: white;margin-top: 10px ; padding-top: 10px; top: 10px ">
           <tr><td>
			<table border="1px" style="margin-top : 20px;  border-color: white ; display:none" id="TableResult" >
       		<tr id="Header" style=" width: 100% ; ">
				<td class="MatrixLabel"></td>
				<td class="MatrixLabel"><%=getNLS("Name")%></td>
       			<td class="MatrixLabel"><%=getNLS("OrganizationType")%></td>
       			<td class="MatrixLabel"><%=getNLS("Parent")%></td>
       		</tr></table>
			</td></tr>
       </table>
    </div>
      
    <div id="divPageFoot">
        <script>addFooter("javascript:doneClose();", "images/buttonDialogDone.gif", '<%=getNLS("Done")%>','<%=getNLS("Done")%>',"javascript:top.closeSlideInDialog()", "images/buttonDialogCancel.gif", '<%=getNLS("Cancel")%>','<%=getNLS("Cancel")%>');</script>
    </div>
</body>
</html>
