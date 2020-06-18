<html>
<head>
<title>ENOVIA</title>
<script type="text/javascript" src="scripts/emxUICore.js"></script>
<script src="scripts/emxUISlideIn.js" type="text/javascript"></script>
<%@ page import="com.dassault_systemes.vplmposadministrationui.uiutil.AdminUtilities"%>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxPLMOnlineIncludeStylesScript.inc"%>
<%@include file = "../common/emxPLMOnlineAdminAttributesCalculation.jsp"%>
<%@include file = "../common/emxPLMOnlineAdminAuthorize.jsp"%>
<%
    String ModifyApplicableRole = getNLS("ModifyApplicableRoles");
    String Roles = getNLS("Roles");
    String NLSSecContext = getNLS("SecurityContexts");
    String AddContexts = getNLS("AddContext");

    boolean isLocal = false;
    if(AdminUtilities.isLocalAdmin(mainContext))isLocal=true;
%>
<script language="JavaScript">

    var DisplayErrorMsg = "";
     var xmlreqs = new Array();
            var xmlhttpOrganization = "";
            var companies = "";
            var bus = "";
            var dep="";

            function formatResponse()
            {
                xmlhttpOrganization = xmlreqs[0];

                xmlhttpOrganization.onreadystatechange=function()
                {
                    var ResultTable = document.getElementById("ResultTable");
                    var nbRow =  document.getElementById("ResultTable").rows.length;
                    if(nbRow > 1){
                        for (var j = 0 ; j < nbRow-1 ; j++){
                         document.getElementById('ResultTable').deleteRow(-1);
                        }
                    }
                     
                    if(xmlhttpOrganization.readyState==4)
                    {
                        //addOptionsToSelect("Org_Parent",xmlhttpOrganization,"PLM_ExternalID","","no");
                        document.getElementById("loadingMessage").style.display="none";

                        var orgList = xmlhttpOrganization.responseXML.getElementsByTagName("Organization");
                        var orgPLMID = xmlhttpOrganization.responseXML.getElementsByTagName("PLM_ExternalID");
                     
                        var Type = xmlhttpOrganization.responseXML.getElementsByTagName("org_Type");
                        var Parent = xmlhttpOrganization.responseXML.getElementsByTagName("org_Parent");

                        var RoleApplicable = xmlhttpOrganization.responseXML.getElementsByTagName("RoleApplicable");
                        // JIC 13:07:15 IR IR-243916V6R2013x: Added role family
                        var FamilyRoleApplicable = xmlhttpOrganization.responseXML.getElementsByTagName("FamilyRoleApplicable");
                        var RoleApplicableNum = xmlhttpOrganization.responseXML.getElementsByTagName("RoleApplicableNum");
                        var SecCtxNum = xmlhttpOrganization.responseXML.getElementsByTagName("SecurityContextNum");
                        var SecCtx = xmlhttpOrganization.responseXML.getElementsByTagName("SecurityContext");

                        for (var i = 0 ; i < orgList.length; i++){
                            var roleApplicable="";
                            var familyRoleApplicable="";
                            var secCtx="";
                            var row=ResultTable.insertRow(-1);

                            var cell=row.insertCell(-1);
                            cell.innerHTML=orgList[i].getElementsByTagName("PLM_ExternalID")[0].firstChild.data.htmlEncode();
                            cell.className= "MatrixFeel";
                            
                            var cell1=row.insertCell(-1);
                            cell1.innerHTML=orgList[i].getElementsByTagName("org_Type")[0].firstChild.data;
                            cell1.className= "MatrixFeel";

                            var cell3=row.insertCell(-1);
                            if(orgList[i].getElementsByTagName("org_Parent")[0]!=null && orgList[i].getElementsByTagName("org_Parent")[0].firstChild!=null)
                            {
                                cell3.innerHTML = orgList[i].getElementsByTagName("org_Parent")[0].firstChild.data.htmlEncode();
                            }
                            else
                            {
                                cell3.innerHTML="";
                            }

                            cell3.className= "MatrixFeel";

                            var cell2=row.insertCell(-1);
                            var roleNum=0;

                            if(RoleApplicable[i] !=null && RoleApplicable[i].firstChild!=null)
                            {
                                roleApplicable = RoleApplicable[i].firstChild.data;
                            }

                            if(FamilyRoleApplicable[i] !=null && FamilyRoleApplicable[i].firstChild!=null)
                            {
                                familyRoleApplicable = FamilyRoleApplicable[i].firstChild.data;
                            }

                            if(RoleApplicableNum[i] !=null && RoleApplicableNum[i].firstChild!=null)
                            {
                                roleNum = RoleApplicableNum[i].firstChild.data;
                            }

                            if(SecCtx[i] !=null && SecCtx[i].firstChild!=null)
                            {
                                secCtx = SecCtx[i].firstChild.data;
                            }

                            cell2.className= "MatrixFeel";
                            cell2.innerHTML= roleNum+ " <%=Roles%>" + " <img src='images/utilActionScrollArrowDown.gif' style='cursor:pointer' title='"+roleApplicable+"'/><img src='images/utilProcessStepArrow.gif' title='<%=ModifyApplicableRole%>' style='cursor:pointer' onclick=javascript:editOrganization(\""+encodeURIComponent(orgPLMID[i].firstChild.data)+"\")>";
                            cell2.id="RoleApp"+orgPLMID[i].firstChild.data;
                            //cell2.innerHTML="RoleApp"+orgPLMID[i].firstChild.data;
                            var secCtxNum = 0;
                            var cell2=row.insertCell(-1);
                            var id ="SecContexts_"+orgPLMID[i].firstChild.data;
                            cell2.className= "MatrixFeel";
                            if(SecCtxNum[i] !=null && SecCtxNum[i].firstChild!=null)
                            {secCtxNum = SecCtxNum[i].firstChild.data;
                            }
                            <%if (isLocal){%>
                                // JIC 13:07:15 IR IR-243916V6R2013x: Changed test for local adminsitration role
                                if(roleApplicable != "Local Administrator" && !familyRoleApplicable != "LocalAdmin"){
                                    cell2.innerHTML = "0 "+"<%=NLSSecContext%>";
                                }else{
                                    cell2.innerHTML = secCtxNum+ " <%=NLSSecContext%>" +" <img src='images/utilActionScrollArrowDown.gif' style='cursor:pointer' title='"+secCtx+"' onclick=javascript:editSecurityContexts(\""+encodeURIComponent(orgPLMID[i].firstChild.data)+"\")>   <img src='images/utilProcessStepArrow.gif' title='<%=AddContexts%>' style='cursor:pointer' id='"+id+"' onclick=javascript:editSecurityContexts(\""+encodeURIComponent(orgPLMID[i].firstChild.data)+"\")>";
                                }
                            <%}else{%>
                                    cell2.innerHTML = secCtxNum+" <%=NLSSecContext%>" +" <img src='images/utilActionScrollArrowDown.gif' style='cursor:pointer' title='"+secCtx+"' onclick=javascript:editSecurityContexts(\""+encodeURIComponent(orgPLMID[i].firstChild.data)+"\")>   <img src='images/utilProcessStepArrow.gif' title='<%=AddContexts%>' style='cursor:pointer' id='"+id+"' onclick=javascript:editSecurityContexts(\""+encodeURIComponent(orgPLMID[i].firstChild.data)+"\")>";
                            <%}%>
                            cell2.id="SecCtx"+orgPLMID[i].firstChild.data;
                            //cell2.innerHTML = "<select id='"+id+"'>";
                           // var response = orgList[i].getElementsByTagName("SecurityContext");

                           /* for(var j = 0 ; j < response.length ; j++ ){
                            if( (response[j].firstChild != null)  ) {
                                var nouvel_element = new Option(response[j].firstChild.data,response[j].firstChild.data,false,true);
                                nouvel_element.id=response[j].firstChild.data;
                                nouvel_element.selected=false;

                                document.getElementById(id).options[document.getElementById(id).length] = nouvel_element;
                            }
                            }*/
                        }
                    }
                }
            }


            function editOrganization(orgName){
                top.showSlideInDialog("emxPLMOnlineAdminRoleApplicability.jsp?OrgName="+orgName, true);
            }


            function editSecurityContexts(orgName){
                top.showSlideInDialog("emxPLMOnlineAdminLocalSecurityContext.jsp?OrgName="+orgName, true);
            }
</script>
 <script type="text/javascript">
 function initializeSlideInssss(){
    	 var pcdtop = "26px";
            document.getElementById("loadingMessage").style.display="block";
            
	 	document.getElementById("pageContentDiv").style.top = pcdtop;
	 	   var FilterValue = document.getElementById("Filter").value;
                xmlreq("emxPLMOnlineAdminAjaxResponse.jsp","source=OrgAndRolApp&Filter="+FilterValue,formatResponse,0);

 }
 </script>
</head>
<body class="dialog" onload="initializeSlideInssss()" >
    <%
        String HostCompanyName =getHostCompanyName(mainContext);
    %>
    <div class="breadcrumbs">
        <div id="breadcrumbs_leftbutton" class="buttons previous disabled">
            <a href="javascript:;" class="btn left"></a>
        </div>
        <div id="breadcrumbs_rightbutton" class="buttons next disabled">
            <a href="javascript:;" class="btn right"></a>
        </div>
    </div><!-- /.breadcrumbs -->
    <script type="text/javascript" src="./scripts/emxBreadcrumbs.js"></script>
    <div id="pageContentDiv" class="divPageBodyVPLM"  style=" overflow: auto">
        <div id="pageHeadDiv" >
            <table style=" vertical-align: middle">
                <thead style=" height: 40px; background-image: url(images/bgnd-dialog-head.png);">
                    <th>
                        <h2 style=" color: white"><%=getNLS("ManageMyLocalAdministration")%></h2>
                    </th>
                </thead>
            </table>
        </div>
        <table  width="100%" border="1px" style="  top: 43px; border-color: white">
            <tr style=" width: 100%"  >
                <td bgcolor="#659ac2" style=" color: white; font-family: verdana, helvetica, arial, sans-serif; font-size: 10pt; font-weight: bold; padding: 1px;"  >
                    <%=getNLS("OrganizationFilter")%> : 
                    <%if (isLocal){%><input onkeypress="return enterEvent(event,initializeSlideInssss)"  type="text" id="Filter"  size="20" value="*" readonly><img src="images/iconSmallSearch.gif" onclick="javascript:initializeSlideInssss();" id="FilterOrg" style="cursor : pointer">
              	 <%}else{%>
                 <input onkeypress="return enterEvent(event,initializeSlideInssss)"  type="text" id="Filter"  size="20" value="<%=HostCompanyName%>"><img src="images/iconSmallSearch.gif" onclick="javascript:initializeSlideInssss();" id="FilterOrg" style="cursor : pointer">

                 <%}%><button id="ClickButton" onclick="javascript:initializeSlideInssss();"  style="visibility:hidden">
			 </td>
            </tr>
            <tr>
                <table border="1px" width="100%" id="ResultTable" style=" border-color: white">
                    <tr bgcolor="#b0b2c3" style="width : 100%">
                        <td class="MatrixLabel" ><%=getNLS("OrganizationName")%></td>
                        <td class="MatrixLabel"><%=getNLS("OrganizationType")%></td>
                        <td class="MatrixLabel"><%=getNLS("Parent")%></td>
                        <td class="MatrixLabel"><%=getNLS("ApplicableRoles")%></td>
                        <td class="MatrixLabel"><%=getNLS("ExistingContexts")%></td>
                    </tr>
                </table>
            </tr>
        </table>
                     <div   style=" height: 50%; " id="loading">
                <table width="100%" style="height : 100%">
                    <tr valign="middle" align="middle" style=" height: 100%">
                        <td   id="loadingMessage">
                            <img src="images/iconParamProgress.gif">
                        </td>
                        <td style=" color: #990000 ; font-size: 12pt ; font-style: italic ; font-weight: bold " id="ErrorMessage">
                        </td>
                    </tr>
                 </table>
            </div>
    </div>
  
    </body>
</html>
