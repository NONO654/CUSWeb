<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxPLMOnlineIncludeStylesScript.inc"%>
<%@include file = "../common/emxPLMOnlineAdminAttributesCalculation.jsp"%>
<%@include file = "../common/emxPLMOnlineAdminAuthorize.jsp"%>
<%--
    Document   : emxPLMOnlineAdminContext.jsp
    Author     : LXM
    Modified : 18/10/2010 -> Migrate to New Gen UI
--%>
<html>
    <head>
     <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
     <script>
     function appelFrameContext(){
        displaySecondColumnFrame("emxPLMOnlineAdminQueryContext.jsp","");
     }
    
    </script>
   </head>
   <body>
    <%  
        /*Prepare NLS Words*/
        String ByContextInfo = getNLS("ByContextInfo");
        String New = getNLS("New");
        String Name = getNLS("Name");
        // RBR2: FUN[080973]
        String title = getNLS("Title");
		String Search = getNLS("Search");
     	String dest = (String)emxGetParameter(request,"dest");
    %>
    <form action="" name="submitForm" method="POST">
	<%if(dest==null) {%>
        <a href="javascript:CreationFrame('Context')" class="link"><%=New%></a>
	<%}%>
        <table width="100%">
            <tr>
                <td>
                    <table width="100%">
                        <script>
                            addTable("iconSmallContext.gif","<%=ByContextInfo%>",1);
                            addTdRE("<%=title%>","V_Name","*","appelFrameContext");
                            addCloseTag();
			</script>                                 
                    </table>
               </td>
            </tr>
        </table>
    </form>
    <script>addFooter("javascript:appelFrameContext()","images/buttonDialogApply.gif","<%=Search%>","<%=Search%>");</script>
  </body>
</html>



