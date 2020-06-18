<%--  emxPushSubscriptionProcess.jsp
   Copyright (c) 2000-2018 - 2008 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxPushSubscriptionProcess.jsp.rca 1.2.7.5 Wed Oct 22 16:18:10 2008 przemek Experimental przemek $
--%>

<html>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../common/emxUIConstantsInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%@page import="com.matrixone.apps.common.util.*"%>
<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>
<jsp:useBean id="indentedTableBean" class="com.matrixone.apps.framework.ui.UITableIndented" scope="session"/>

<%
	//Read the objectId list passed in
	String saObjectKey[]    = ComponentsUIUtil.getSplitTableRowIds(emxGetParameterValues(request, "emxTableRowId"));
	String sObjectId        = emxGetParameter(request, "objectId");
	String timeStamp        = emxGetParameter(request, "timeStamp");
	HashMap requestMap = null;
	if(UINavigatorUtil.isMobile(context)){
		requestMap = indentedTableBean.getRequestMap(timeStamp);
	}else{
		requestMap = tableBean.getRequestMap(timeStamp);
	}
	String eventName     = (String) requestMap.get("eventName");
    String strLanguage = request.getHeader("Accept-Language");

	boolean errorHappen = false;
	//Process subscribed events, create objects and connect relationships
	try
	{
		SubscriptionUtil.createPushSubscription(context, sObjectId, eventName, saObjectKey, strLanguage);
	}
	catch(Exception ex)
	{
		errorHappen = true;
		emxNavErrorObject.addMessage(ex.toString().trim());
	}

	if(!errorHappen)
	{
%>
		<script language="javascript">
  		  var searchViewFrm = getTopWindow().findFrame(getTopWindow(), "searchView"); 
		  searchViewFrm.parent.window.getWindowOpener().parent.getWindowOpener().refreshPage = true;
		  searchViewFrm.parent.window.getWindowOpener().location.href=searchViewFrm.parent.window.getWindowOpener().location.href;		  
		  searchViewFrm.parent.window.closeWindow();
		</script>
<%
	}
	else
	{
%>
		<script language="javascript">
		  var tblFooterFrm = getTopWindow().findFrame(parent, "listFoot");
		  tblFooterFrm.setTableSubmitAction(true);
		</script>
<%
	}
%>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
</html>
