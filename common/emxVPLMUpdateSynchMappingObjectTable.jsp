<%--  emxVPLMUpdateSynchMappingObjectTable.jsp

   Copyright (c) 1992-2012 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxReloadCache.jsp.rca 1.23 Wed Oct 22 15:49:03 2008 przemek Experimental przemek $
--%>

<html>
<%@ page import = "com.matrixone.vplmintegration.util.VPLMIntegParamObject"%>
<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<emxUtil:localize id="i18nId" bundle="emxVPLMSynchroStringResource" locale='<%= request.getHeader("Accept-Language") %>' />

<head> 
</head>
<%
try
{                                                              
	ContextUtil.startTransaction(context, false);
	boolean isSynchMappingObjectTableUpdated = VPLMIntegParamObject.updateParamObjectTable(context);
	if(isSynchMappingObjectTableUpdated ==  true)
	{
		ContextUtil.commitTransaction(context);
%>
		<SCRIPT LANGUAGE="JavaScript" TYPE="text/javascript">
			alert("<emxUtil:i18nScript localize="i18nId">emxVPLMSynchro.Synch.Success.UpdateSyncMappingObjectTable</emxUtil:i18nScript>");
		</SCRIPT>
<%
	}
	else
		throw new MatrixException();

} catch (Exception ex) 
{
	ex.printStackTrace();
    ContextUtil.abortTransaction(context);
	 %>
	<SCRIPT LANGUAGE="JavaScript" TYPE="text/javascript">
		alert("<emxUtil:i18nScript localize="i18nId">emxVPLMSynchro.Synch.Failed.UpdateSyncMappingObjectTable</emxUtil:i18nScript>");
	</SCRIPT>
	<%
} 
%>
<body>
<%@include file = "emxNavigatorBottomErrorInclude.inc"%>
</body>
</html>

