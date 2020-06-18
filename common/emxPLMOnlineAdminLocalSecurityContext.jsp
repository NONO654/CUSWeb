<%@ page import="com.dassault_systemes.vplmposadministrationui.uiutil.EncodeUtil" %>
<%@ page import="com.dassault_systemes.vplmposadministrationui.uiutil.AdminUtilities"%>
<%@include file = "../common/emxPLMOnlineAdminAttributesCalculation.jsp"%>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxPLMOnlineIncludeStylesScript.inc"%>
<%@include file = "../common/emxPLMOnlineAdminAuthorize.jsp"%>
<%
    String OrgName  = emxGetParameter(request,"OrgName");
	String escOrgName = EncodeUtil.escape(OrgName);
    String ERR_SecCtxAlreadyCreated  = getNLS("ERR_SecCtxAlreadyCreated");
%>
<html>
<head>
<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="javascript" src="../common/scripts/emxUICoreMenu.js"></script>
<title><%=escOrgName%></title>
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
       
  function formatResponseProject(){
           var xmlhttp2= xmlreqs[1];
            xmlhttp2.onreadystatechange=function()
            {
                if(xmlhttp2.readyState==4){
                   var projectName = xmlhttp2.responseXML.getElementsByTagName("Project");
                   var tableResultat = document.getElementById("tabRes");
                   if(projectName.length == 0){
                            //document.getElementById("ErrorMessage").innerHTML = "No Project in the DB";
                   }else{
                            for (var i = 0 ; i < projectName.length ; i++){
                                var row=tableResultat.insertRow(-1);
                                var projectID="";
                                //Adding the First Cell
                                var project = projectName[i].getElementsByTagName("PLM_ExternalID")[0].firstChild.data;

                                if(projectName[i].getElementsByTagName("project_Parent").length > 0 && projectName[i].getElementsByTagName("project_Parent")[0].firstChild != null){
                                    projectID = projectName[i].getElementsByTagName("project_Parent")[0].firstChild.data;

                            }

                                var checkID = "<input type='checkbox'  id='"+project+"'  disabled >";
                                addCellInARow(row, "MatrixFeel", 0,checkID);
                                var newCell = addCellInARow(row, "MatrixFeel", 1);
								newCell.appendChild(document.createTextNode(project));
                                newCell = addCellInARow(row, "MatrixFeel", 2);
								newCell.appendChild(document.createTextNode(projectID));
                                }
                            }
                         turnOffProgress();
                         initAjaxCall("Context","VPM","VPLMAdmin","Create","Local Administrator."+"<%=OrgName%>"+"*",formatResponseCtx,2);
                     }
            }
  }
    

      function formatResponseRoleApp(){
            var xmlhttp2= xmlreqs[3];
            xmlhttp2.onreadystatechange=function()
            {
               if(xmlhttp2.readyState==4)
                {
                    var newElements = xmlhttp2.responseXML.getElementsByTagName("PLM_ExternalID");
                    for (var i = 0 ; i < newElements.length ; i ++){
                        if(document.getElementById(newElements[i].firstChild.data) != null){
                            xmlhttpRoleAppBefore = xmlhttpRoleAppBefore +";;"+newElements[i].firstChild.data;
                            document.getElementById(newElements[i].firstChild.data).checked = true;
                        }
                    }
                }
            }
    }

function formatResponseCtx(){
           var xmlhttp3= xmlreqs[2];
            xmlhttp3.onreadystatechange=function()
            {
               if(xmlhttp3.readyState==4)
                {
                    var ctxName = xmlhttp3.responseXML.getElementsByTagName("PLM_ExternalID");
                    for (var i = 0 ; i < ctxName.length ; i++){
                          var prjName=ctxName[i].firstChild.data;
                          var prNameOnly = prjName.split(".");
                          document.getElementById(prNameOnly[2]).checked=true;
                }
            }
            turnOffProgress();
    }
}



     function LoadQueries(){
         initAjaxCall("Project","VPM","VPLMAdmin","Query","*",formatResponseProject,1);

    }

  
       function doneClose(){
        var checkBoxesElements = document.getElementsByTagName("input");
        var Roles2Add="";
        var Name2Show="";
         var j = 0;
        for(var i = 0 ; i < checkBoxesElements.length ; i++){
            if (checkBoxesElements[i].checked ){
                if(!checkBoxesElements[i].disabled){
                    Roles2Add=Roles2Add+";;"+checkBoxesElements[i].id;
                }
                Name2Show=Name2Show+checkBoxesElements[i].id+",";
                j++;
            }
        }
        sizeOfApplicable=j;
        appRole=Name2Show;
        turnOnProgress();
        var dest = "source=CreateCtx&Prj2Add="+encodeURIComponent(Roles2Add)+"&OrgName="+encodeURIComponent("<%=OrgName%>");
        xmlreq("emxPLMOnlineAdminAjaxResponse.jsp",dest,returnValue,4);

    }

    function returnValue(){
        var xmlhttp4= xmlreqs[4];
            xmlhttp4.onreadystatechange=function()
            {
               if(xmlhttp4.readyState==4)
                {
                   turnOffProgress();
                  
                    top.document.getElementById("layerOverlay").style.display   ="none";
		if( top.content.portalDisplay.APPVPLMLocalAdministration == undefined){
                    top.content.portalDisplay.APPXPLocalAdministration.sommaire.document.getElementById("ClickButton").click();
		}else{
                    top.content.portalDisplay.APPVPLMLocalAdministration.sommaire.document.getElementById("ClickButton").click();
		}
			  top.closeSlideInDialog();
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
<body class="slide-in-panel" onload="javascript:LoadQueries();turnOnProgress()">
    <div id="pageHeadDiv">
        <table>
            <tbody>
                <tr>
                    <td class="page-title">
                        <h2><%=getNLS("Organization")%> : <%=OrgName%></h2>
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
                <div class="toolbar">
                    <table cellspacing="0" cellpadding="0" border="0">
                        <tbody>
                            <tr>
                                <td nowrap=""  title='<%=getNLS("AddContext")%>' class="icon-button" onclick="Javascript:EditMode()"><img src="../common/images/iconGenericBlue.gif"><%=getNLS("AddContext")%>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
    <div id="divPageBody" style="top :87px;">
        <table  border="1px" style=" border-color: white;">
            <!-- Applicable Roles  -->
           <tr>
                            <td>
                                <table border="1px" id="tabRes" style=" overflow:scroll; height: 20px ;  border-color: white" width="100%">
                                    <tr id="Header" style=" width: 100%" >
                                        <td class="MatrixLabel" width=""></td><td class="MatrixLabel"><%=getNLS("Project")%></td><td class="MatrixLabel"><%=getNLS("ProjectParent")%></td>
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
