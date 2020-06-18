<%-- (c) Dassault Systemes, 2008 --%>
<%--
 - The purpose of this jsp is simply to pass the timestamp of the
 - Revisions table to the New Revision form as callerTimeStamp.
 - Why this is necessary:
 -   emxForm passes along all URL parameters. In addition, it creates
 -   its own timeStamp parameter. This results in 2 timeStamp parameters
 -   getting passed to emxFormEditProcess, with the incorrect one
 -   being passed first. Thus, emxFormEditProcess is working with the
 -   wrong timeStamp.
 --%>

<%@include file = "../common/emxNavigatorInclude.inc"%>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>

<html>
<head>
<title></title>
</head>
<body>
<%
StringBuilder appendParams = new StringBuilder();
String tableRowIdList[] = Request.getParameterValues(request, "emxTableRowId");

String queryPart = request.getQueryString();
if (queryPart != null)
{
    appendParams.append(FrameworkUtil.encodeURLParamValues(queryPart));

    // Change the name of the timeStamp.

    int pos1 = appendParams.indexOf("timeStamp");
    if (pos1 > -1)
    {
        appendParams.replace(pos1, pos1+9, "callerTimeStamp");
    }
}
session.setAttribute("massEmxTableRowId", tableRowIdList);

String fwdUrl = "../common/emxForm.jsp?" + appendParams.toString(); 
%>
<script>
getTopWindow().showSlideInDialog("<%=fwdUrl.toString()%>");
</script>
</body>
</html>

