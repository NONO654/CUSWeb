<%--  emxInfoCustomTableCleanupSession.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%--
  Description : This jsp page removes table information stored in session objects
--%>

<%@include file = "../emxRequestWrapperMethods.inc"%>

<%
    String timeStamp = emxGetParameter(request, "timeStamp");

    if (timeStamp != null && session.getAttribute("TableData" + timeStamp) != null)
        session.removeAttribute("TableData" + timeStamp);

    if (session.getAttribute("CurrentIndex" + timeStamp) != null)
        session.removeAttribute("CurrentIndex" + timeStamp);
       
    if (session.getAttribute("ColumnDefinitions" + timeStamp) != null)
        session.removeAttribute("ColumnDefinitions" + timeStamp);
%>
<script language="JavaScript">
window.close();
</script>

