<%--   emxRouteCancelNewTaskProcess.jsp -- This is the process page which 
       removes any new Tasks added to a Route if the Cancel button is hit.

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxRouteCancelNewTaskProcess.jsp.rca 1.6 Tue Oct 28 19:01:05 2008 przemek Experimental przemek $
--%>

<%@include file  = "../emxUICommonAppInclude.inc"%>
<%@ include file = "emxRouteInclude.inc" %>
<%@include file = "../common/emxTreeUtilInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>

<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<!--Added for the bug no 350789 -->
<jsp:useBean id="formBean" scope="session" class="com.matrixone.apps.common.util.FormBean"/>
<!--Added for the bug no 350789  -->
<%
String newTaskIds = emxGetParameter(request,"newTaskIds");
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
	    // Modified for the bug 359035
	    try
	    {
		    formBean.removeElement("mapRouteDetails");
	    }
	    catch(NullPointerException e)
	    {
	        
	    }
	}

%>

<script language="Javascript">
  window.closeWindow();
</script>
