<%--  emxRouteTemplatePromote.jsp   -

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program
   static const char RCSID[] = $Id: emxRouteTemplatePromote.jsp.rca 1.7 Wed Oct 22 16:18:37 2008 przemek Experimental przemek $
--%>

<%@include file  = "../emxUICommonAppInclude.inc"%>
<%@include file  = "emxRouteInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>

<%
  String routeTemplateId = emxGetParameter(request,"objectId");
  RouteTemplate routeTemplate = (RouteTemplate)DomainObject.newInstance(context,DomainObject.TYPE_ROUTE_TEMPLATE);
  routeTemplate.setId(routeTemplateId);
  String templateState  = routeTemplate.getInfo(context,DomainObject.SELECT_CURRENT);

  if(templateState.equals(DomainObject.STATE_ROUTE_TEMPLATE_ACTIVE))
  {
      routeTemplate.demote(context);
  }
  else
  {
      routeTemplate.promote(context);
  }

%>
<html>
<body>
<form name="detailsForm" target="_parent">
  <input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=routeTemplateId%></xss:encodeForHTMLAttribute>" />
</form>
<script src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<script language="javascript">
parent.location.href = parent.location.href;
if(getTopWindow().RefreshHeader){
	getTopWindow().RefreshHeader();
}

</script>
</body>
</html>
