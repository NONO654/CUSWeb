<%-- smaShowRelated.jsp

   Copyright (c) 1999-2007 MatrixOne, Inc.
   All Rights Reserved.

   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%@page import="com.dassault_systemes.smaslm.matrix.common.SimulationUtil" %>

<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../common/emxUIConstantsInclude.inc"%>

<%
    final String locale = context.getSession().getLanguage();
    String header = SimulationUtil.getI18NString(context,
        "Common.AddCategory.PageHeading" );

%>

<head>
<title>Select Categories</title>
<script type="text/javascript" language="javascript" >
    addStyleSheet("emxUIDefault");
    addStyleSheet("emxUIDialog");
</script>

<body>
    <table margin="0" border="0" width="100%" cellspacing="0" cellpadding="5">
    <tr>
        <td width="1%" nowrap><span class="pageHeader"><%=header %></span></td>
    </tr>
    </table>
</body>

</html>
