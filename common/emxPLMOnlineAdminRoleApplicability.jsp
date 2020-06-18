<%@ page import="com.dassault_systemes.vplmposadministrationui.uiutil.EncodeUtil" %>
<%@ page import="com.dassault_systemes.vplmposadministrationui.uiutil.AdminUtilities"%>
<%@include file = "../common/emxPLMOnlineAdminAttributesCalculation.jsp"%>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxPLMOnlineIncludeStylesScript.inc"%>
<%@include file = "../common/emxPLMOnlineAdminAuthorize.jsp"%>
<%
    String OrgName  = emxGetParameter(request,"OrgName");
	String escOrgName = EncodeUtil.escape(OrgName);
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
        function formatResponseRole(){
           var xmlhttp1= xmlreqs[0];
            xmlhttp1.onreadystatechange=function()
            {
               if(xmlhttp1.readyState==4)
                {
                   var projectName = xmlhttp1.responseXML.getElementsByTagName("RoleApplicable");
                   var tableResultat = document.getElementById("tabRes");
                   if(projectName.length == 0){
                            //document.getElementById("ErrorMessage").innerHTML = "No Role in the DB";
                   }else{
                            for (var i = 0 ; i < projectName.length ; i++){
                                var row=tableResultat.insertRow(-1);
                                var projectID="";
                                //Adding the First Cell
                                var project = projectName[i].getElementsByTagName("PLM_ExternalID")[0].firstChild.data;

                                if(projectName[i].getElementsByTagName("Description").length > 0 && projectName[i].getElementsByTagName("Description")[0].firstChild != null){
                                    projectID = projectName[i].getElementsByTagName("Description")[0].firstChild.data;

                            }

                                var checkID = "<input type='checkbox'  id='"+project+"'  disabled >";
                                addCellInARow(row, "MatrixFeel", 0,checkID);
                                var newCell = addCellInARow(row, "MatrixFeel", 1);
								newCell.appendChild(document.createTextNode(project));
                                newCell = addCellInARow(row, "MatrixFeel", 2 );
								newCell.appendChild(document.createTextNode(projectID));
                                }
                            }
                         turnOffProgress();
                        initAjaxCall("RolApplicable","VPM","VPLMAdmin","Query","<%=OrgName%>",formatResponseRoleApp,3);
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
                        if((document.getElementById(newElements[i].firstChild.data) != null) ){
                                xmlhttpRoleAppBefore = xmlhttpRoleAppBefore +";;"+newElements[i].firstChild.data;
                            document.getElementById(newElements[i].firstChild.data).checked = true;
                        }
                    }
                }
                turnOffProgress();
            }
    }


    

    function LoadQueries(){
         initAjaxCall("RolApplicable","VPM","VPLMAdmin","Parent","<%=OrgName%>",formatResponseRole,0);
    }

    function doneClose(){
        var checkBoxesElements = document.getElementsByTagName("input");
        var Roles2Add="";
        var Name2Show="";
        var j = 0;
        for(var i = 0 ; i < checkBoxesElements.length ; i++){
            if (checkBoxesElements[i].checked){
                Roles2Add=Roles2Add+";;"+checkBoxesElements[i].id;
                Name2Show=Name2Show+checkBoxesElements[i].id+",";
                j++;
            }
        }
        sizeOfApplicable=j;
        appRole=Name2Show;
        // JIC 13:07:18 IR IR-243916V6R2013x: Changed source name
        var dest = "source=AddRolApplicability&RolesToRem="+encodeURIComponent(xmlhttpRoleAppBefore)+"&Roles2Add="+encodeURIComponent(Roles2Add)+"&Filter="+encodeURIComponent("<%=OrgName%>");
        //document.getElementById("imgProgressDiv").style.visibility="";
        turnOnProgress();
        xmlreq("emxPLMOnlineAdminAjaxResponse.jsp",dest,returnValue,4);

    }

    function returnValue(){
        var xmlhttp4= xmlreqs[4];
            xmlhttp4.onreadystatechange=function()
            {
               if(xmlhttp4.readyState==4)
                {   
                    turnOffProgress();
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
        for(var i = 0 ; i < checkBoxesElements.length ; i++){
            if (checkBoxesElements[i].disabled){
                checkBoxesElements[i].disabled=false;
            }
        }
    }
 </script>
</head>
<body class="slide-in-panel" onload="javascript:LoadQueries();turnOnProgress()">
    <div id="pageHeadDiv">
        <table>
            <tr>
                <td class="page-title">
                    <h2><%=getNLS("Organization")%> : <%=escOrgName%></h2>
                </td>
                <td class="functions">
                    <table>
                        <tr>
                            <td class="progress-indicator"><div id="imgProgressDiv"></div></td>
                        </tr>
                    </table>                </td>
            </tr>
        </table>
         <div class="toolbar-container" id="divToolbarContainer">
            <div id="divToolbar" class="toolbar-frame">
                <div class="toolbar">
                    <table cellspacing="0" cellpadding="0" border="0">
                        <tbody>
                            <tr>
                                <td class="icon-button" nowrap="" title='<%=getNLS("Edit")%>' onclick="Javascript:EditMode()">
                                    <img src="images/iconGenericBlue.gif"><%=getNLS("Edit")%>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
    <div id="divPageBody" style="top:87px;">
        <table border="1px" style=" border-color: white ; border-top: 10px" >
            <tbody>
                <tr></tr>
            <!-- Applicable Roles  -->
                <tr style=" height: 50% ; overflow: auto ; width: 100%"  >
                    <table border="1px" style=" border-color: white ;" width="100%"  >
                      
                        <tr>
                            <td>
                                <table border="1px" id="tabRes" style=" overflow:scroll; height: 20px ;  border-color: white" width="100%">
                                    <tr id="Header" style=" width: 100%" >
                                        <td class="MatrixLabel" width=""></td><td class="MatrixLabel"><%=getNLS("Name")%></td><td class="MatrixLabel"><%=getNLS("Description")%></td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                   </table>
                </tr>
                <tr>
                    <table id="rulestable"></table>
                </tr>
</tbody>
       </table>
    </div>
    <div id="divPageFoot">
        <script>addFooter("javascript:doneClose()", "images/buttonDialogDone.gif", '<%=getNLS("Done")%>','<%=getNLS("Done")%>',"javascript:top.closeSlideInDialog()", "images/buttonDialogCancel.gif", '<%=getNLS("Cancel")%>','<%=getNLS("Cancel")%>');</script>
    </div>
</body>
</html>
