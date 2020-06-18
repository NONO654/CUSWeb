<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxPLMOnlineIncludeStylesScript.inc"%>
<%@include file = "../common/emxPLMOnlineAdminAttributesCalculation.jsp"%>
<%@include file = "../common/emxPLMOnlineAdminAuthorize.jsp"%>
<%
             String Solution = prefUtil.getUserPreferredUISolution(mainContext);
     String dest = (String)emxGetParameter(request,"dest");
        String TabInteger[] = new String[2];
        TabInteger[0]=getNLS("RoleName");
        TabInteger[1]=getNLS("Special");
        String ERRCannotContain = myNLS.getMessage("ERR_ProjectCannotContain",TabInteger);
        String TabInteger2[] = new String[1];
        TabInteger2[0]=getNLS("RoleParent");
        String ERRCannotBeEmpty = myNLS.getMessage("ERR_CannotBeEmpty",TabInteger2);

        %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <script>
            xmlreqs = new Array();
            function formatResponse()
            {
                var xmlhttp = xmlreqs[0];

                xmlhttp.onreadystatechange=function()
                {
                    if(xmlhttp.readyState==4)
                    {
            <%if (Solution.equals("TEAM")){%>
                        addOptionsToSelect("role_parent",xmlhttp,"PLM_ExternalID","imageWaitingRole","no");
			<%} else {%>
                        addOptionsToSelect("role_parent",xmlhttp,"PLM_ExternalID","imageWaitingRole");
			<%}%>
                    }
                }
            }

            function checkBeforeSubmit(){
                if (hasSpecialChar(document.getElementById("PLM_ExternalID").value,true)){
                	alert("<%=ERRCannotContain%>" + ": " + emxUIAdminConsoleUtil.FORBIDDEN_CHARACTERS_WITH_DOT);
                }
            <%if (Solution.equals("TEAM")){%>
                else if (document.getElementById("role_parent").value=="")
                alert("<%=ERRCannotBeEmpty%>");
			<%}%>
				else
                document.submitForm.submit();
            }
        </script>
    </head>
    <body onload="javascript:initAjaxCall('Role','VPM','XP','Create','*',formatResponse,0)">
        <%
        String message = (String)emxGetParameter(request,"message");
        %>
        <%if (message != null) {%> <script>setTime("<%=message%>");</script><%}%>
        <form action="emxPLMOnlineAdminCreateRoleDB.jsp" method="POST" name="submitForm">
	<%if(dest==null) {%>
            <a href="emxPLMOnlineAdminRole.jsp" class="link"><%=getNLS("Search")%>...</a>
	<%}%>
            <table  width="100%" style="height:95% ; border-color: white" border="1px"   >
                <tr  height="90%" style=" border:1px ">
                    <td>
                        <img src="images/iconSmallRole.gif" title="<%=getNLS("Role")%>">
                        <table class="big">
                            <td class="title" width="50%"><%=getNLS("RoleName")%>:</td>
                            <td><input type="text" size="20" id="PLM_ExternalID" name="PLM_ExternalID" value=""></td>
                            <tr><td class="title" width="50%"><%=getNLS("RoleDescription")%>:</td>
                                <td>  <textarea id="v_id" name="v_id" cols="15" rows="5"></textarea>
                                </td>
                            </tr>
                        </table>
                    </td>
                    <td>
                        <table class="big">
                            <tr>
                                <td class="title" width="40%"><%=getNLS("RoleParent")%>:</td>
                                <td>
                                    <img  id="imageWaitingRole"  src="images/iconParamProgress.gif">
                                    <select name="role_parent" id="role_parent" size="18" style="display:none">
             <%
             if (!Solution.equals("TEAM")){%>
                                             <option style="color:gray ; font-style : italic" selected value=""><%=getNLS("None")%></option>
			<%}%>
                                    </select>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
            </table>
        </form>
        <%String Create =getNLS("Create");%>
        <script>addFooter("javascript:checkBeforeSubmit();","images/buttonDialogAdd.gif","<%=Create%>","<%=Create%>");</script>
    </body>
</html>
