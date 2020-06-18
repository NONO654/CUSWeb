<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxPLMOnlineIncludeStylesScript.inc"%>
<%@include file = "../common/emxPLMOnlineAdminAttributesCalculation.jsp"%>
<%@include file = "../common/emxPLMOnlineAdminAuthorize.jsp"%>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    </head>
    <body>
    <%
         /*Prepare NLS Words*/
        String ByRoleName = getNLS("ByRoleName");
        String Name = getNLS("Name");
        String Search = getNLS("Search");
     String xp = (String)emxGetParameter(request,"dest");
       
        String dest = "emxPLMOnlineAdminQueryRole.jsp";
    %>
        <form action="javascript:displaySecondColumnFrame('<%=dest%>','')" name="submitForm" id="submitForm" method="POST">
	<%if(xp==null) {%>
            <a href="javascript:CreationFrame('Role')" class="link"> <%=getNLS("New")%></a>
	<%}%>
            <table width="100%">
                <tr>
                    <td>
                        <table width="100%">
                            <script>
                                addTable("iconSmallRole.gif","<%=ByRoleName%>",1);
                                addTdRE("<%=Name%>","PLM_ExternalID","*");
                                addCloseTag();
                          </script>
                        </table>
                    </td>
                </tr>
            </table>
        </form>
        <script>addFooter("javascript:displaySecondColumnFrame('<%=dest%>','')","images/buttonDialogApply.gif","<%=Search%>","<%=Search%>");</script>
    </body>
</html>
