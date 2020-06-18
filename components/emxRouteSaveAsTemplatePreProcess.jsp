<%-- emxRouteSaveAsTemplatePreProcess.jsp --

  Copyright (c) 1992-2018 Dassault Systemes.All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

    static const char RCSID[] = $Id: emxRouteSaveAsTemplatePreProcess.jsp
--%>
<%@include file  = "emxRouteInclude.inc"%>
<%@include file  = "../emxUICommonAppInclude.inc"%>
<script type="text/javascript" language="JavaScript">
<%
	 String routeId = emxGetParameter(request,"objectId");
     Route boRoute = (Route)DomainObject.newInstance(context,DomainConstants.TYPE_ROUTE);
     boRoute.setId(routeId);
     
     StringBuffer sb            = new StringBuffer();
     SelectList relSelects = new SelectList(2);
     relSelects.addElement(boRoute.SELECT_TITLE);
     relSelects.addElement(boRoute.SELECT_SCHEDULED_COMPLETION_DATE);
     SelectList selectStmts = new SelectList();
     selectStmts.addElement(boRoute.SELECT_ROUTE_TEMPLATE_NAME);
     selectStmts.addElement(boRoute.SELECT_ROUTE_TEMPLATE_ID);
     Map resultMap = boRoute.getInfo(context, selectStmts);
     String strTemplate    = (String) resultMap.get(boRoute.SELECT_ROUTE_TEMPLATE_NAME);
     String strTemplateId  = (String) resultMap.get(boRoute.SELECT_ROUTE_TEMPLATE_ID);
     
	 MapList ml = boRoute.getRouteMembers(context, selectStmts, relSelects, false);

      if ( ml.size() == 0) {
%>
        alert("<emxUtil:i18nScript localize="i18nId">emxComponents.Routes.TemplateMessage</emxUtil:i18nScript>");
<%
      } 
      else 
	  {
        String saveURL = JSPUtil.encodeHref(request, "emxSaveRouteTemplateDialogFS.jsp?routeId="  + XSSUtil.encodeForURL(context, routeId) + "&routeName=" + XSSUtil.encodeForURL(context, strTemplate) + "&routeTemplateId=" + XSSUtil.encodeForURL(context, strTemplateId));
%>
		//XSSOK
		getTopWindow().showModalDialog('<%=saveURL%>','570','520');
<%
      }
%>
</script>
