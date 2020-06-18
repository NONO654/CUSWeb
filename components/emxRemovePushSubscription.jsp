<%--  emxRemovePushSubscription.jsp
   Copyright (c) 2000-2018 - 2008 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxRemovePushSubscription.jsp.rca 1.1.7.5 Wed Oct 22 16:18:48 2008 przemek Experimental przemek $
--%>

<html>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../common/emxUIConstantsInclude.inc"%>
<%@page import="com.matrixone.apps.common.util.*"%>


<%
	//Read the objectId list passed in
	String saObjectKey[]    = emxGetParameterValues(request, "emxTableRowId");
	String sObjectId        = emxGetParameter(request, "objectId");
	String timeStamp        = emxGetParameter(request, "timeStamp");


	boolean errorHappen = false;
	//Process subscribed events, create objects and connect relationships
	try
	{
		if(saObjectKey != null)
		{
			for(int i =0; i < saObjectKey.length; i++)
			{
				DomainRelationship.disconnect(context, (String)FrameworkUtil.split(saObjectKey[i], "|").get(0));
			}
		}
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
		  if(parent.getWindowOpener()){
		  parent.getWindowOpener().refreshPage = true;
		  parent.document.location.href = parent.document.location.href;
		  }
		  else if(getTopWindow().opener){
		  getTopWindow().opener.refreshPage = true;
		  parent.document.location.href = parent.document.location.href;
		  }
		  else
		  {
			getTopWindow().location.href=getTopWindow().location.href;
		  }
		</script>
<%
	}
%>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
</html>
