<%--   emxRouteTemplateCancelNewTaskProcess.jsp -- This is the process page which 
       removes any new Tasks added to a Route Template if the Cancel button is hit.

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxRouteTemplateCancelNewTaskProcess.jsp.rca 1.6 Tue Oct 28 19:01:05 2008 przemek Experimental przemek $
--%>

<%@include file  = "../emxUICommonAppInclude.inc"%>
<%@ include file = "emxRouteInclude.inc" %>
<%@include file = "../common/emxTreeUtilInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>

<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>

<jsp:useBean id="formBean" scope="session" class="com.matrixone.apps.common.util.FormBean"/>

<%
String newTaskIds = emxGetParameter(request,"newTaskIds");
String routeTemplateRevisionId = emxGetParameter(request , "routTemplateRevisionId");

if ((newTaskIds != null) && 
    (!"".equals(newTaskIds)) &&
    (!"null".equals(newTaskIds)))
{
   StringTokenizer tokenizer = new StringTokenizer(newTaskIds,"|");

   while(tokenizer.hasMoreTokens())
   {
      String relId = tokenizer.nextToken();
      DomainRelationship rel = new DomainRelationship(relId);
      rel.remove(context);
   }
}
	if(newTaskIds != null)
	{
	    
	    try
	    {
		    formBean.removeElement("mapRouteDetails");
	    }
	    catch(NullPointerException e)
	    {
	        
	    }
	}
if(UIUtil.isNotNullAndNotEmpty(routeTemplateRevisionId))
{
	RouteTemplate rt = new RouteTemplate(routeTemplateRevisionId);
    rt.deleteObject(context);
}

%>

<script language="Javascript">
  window.closeWindow();
</script>
