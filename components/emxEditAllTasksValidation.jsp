<%--  emxEditAllTasksValidation.jsp   -   To open the Edit All dialog based on type
   Copyright (c) 1993-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxEditAllTasksValidation.jsp
--%>

<%@include file  = "../emxUICommonAppInclude.inc"%>
<%@include file  = "emxRouteInclude.inc"%>

<html>
<head>
<script src='../common/scripts/emxUICore.js'></script>
<script src='../common/scripts/emxUIModal.js'></script>
<script src='../emxUIPageUtility.js'></script>
<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
</head>
<body>
<script>
<%
	String routeId  = emxGetParameter(request,"objectId");
	String RTUrl = "emxEditAllTasksDialogFS.jsp?objectId=" + XSSUtil.encodeForURL(context, routeId);
	String routeUrl = "emxRouteEditAllTasksDialogFS.jsp?objectId=" + XSSUtil.encodeForURL(context, routeId);
	DomainObject domainObject = DomainObject.newInstance(context);
	domainObject.setId(routeId);
	String sTypeName = domainObject.getType(context);
	String templateState = domainObject.getInfo(context,DomainObject.SELECT_CURRENT);
	if(sTypeName.equals(com.matrixone.apps.domain.DomainConstants.TYPE_ROUTE_TEMPLATE))
        {
		if(templateState.equals(DomainObject.STATE_ROUTE_TEMPLATE_ACTIVE))
		{
%>
  		if (confirm("<emxUtil:i18nScript localize="i18nId">emxComponents.RouteTaskSummary.EditAllMessage</emxUtil:i18nScript>") != 0)  {
		    //XSSOK
  			document.location.href = "<%=RTUrl%>";
  		} else { getTopWindow().closeWindow(); }

<%
	} else {
%>
//XSSOK
    		document.location.href = "<%=RTUrl%>";
<%
		}
    } else {
            %>
            //XSSOK
            document.location.href = "<%=routeUrl%>";
<% }
%>
</script>
</body>
</html>
