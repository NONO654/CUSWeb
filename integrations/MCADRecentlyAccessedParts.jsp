<%--  MCADRecentlyAccessedParts.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>

<%@ include file ="MCADTopInclude.inc" %>
<%@ include file="MCADTopErrorInclude.inc" %>
<%@ include file="../iefdesigncenter/emxInfoTableInclude.inc" %>
<%@ include file = "MCADBottomErrorInclude.inc"%>
<%@ page import= "com.matrixone.apps.domain.util.*" %>

<%@page import="com.matrixone.apps.domain.util.ENOCsrfGuard"%>

<% 	
	String sIntegName							= Request.getParameter(request,"integrationName");
	String dateSelected						    = "Today";
    
	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute(MCADServerSettings.MCAD_INTEGRATION_SESSION_DATA_OBJECT);
	Context	context							    = integSessionData.getClonedContext(session);
	MCADGlobalConfigObject globalConfigObject   = integSessionData.getGlobalConfigObject(sIntegName, context);	  	    		
				
	MCADRecentlyAccessedPartsHelper helper      = new  MCADRecentlyAccessedPartsHelper(integSessionData);
	MapList mResultList							= helper.getRecentlyAccessedBusObjectList(context, MCADRecentlyAccessedPartsHelper.ALL,globalConfigObject);
	String jpoPackedArgs						= MCADUtil.covertToString(mResultList,true,true);
    jpoPackedArgs								= MCADUrlUtil.encode(jpoPackedArgs); 

	session.setAttribute("GCO",globalConfigObject);
	session.setAttribute("LCO",integSessionData.getLocalConfigObject());
	session.setAttribute("GCOTable",integSessionData.getIntegrationNameGCOTable(context));
%>

<html>
	<head>
		<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
		<script language="javascript" src="../integrations/scripts/MCADUtilMethods.js" type="text/javascript"></script>
		<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>
	</head>
	<body>
		<form name="appletReturnHiddenForm" method="post" action="../common/emxIndentedTable.jsp">

<%
boolean csrfEnabled = ENOCsrfGuard.isCSRFEnabled(context);
if(csrfEnabled)
{
  Map csrfTokenMap = ENOCsrfGuard.getCSRFTokenMap(context, session);
  String csrfTokenName = (String)csrfTokenMap .get(ENOCsrfGuard.CSRF_TOKEN_NAME);
  String csrfTokenValue = (String)csrfTokenMap.get(csrfTokenName);
%>
  <!--XSSOK-->
  <input type="hidden" name= "<%=ENOCsrfGuard.CSRF_TOKEN_NAME%>" value="<%=csrfTokenName%>" />
  <!--XSSOK-->
  <input type="hidden" name= "<%=csrfTokenName%>" value="<%=csrfTokenValue%>" />
<%
}
//System.out.println("CSRFINJECTION");
%>


			<input type="hidden" name="program" value="DSCRecentlyAccessedParts:getRecentlyAccessedBusObjectsList">
			<input type="hidden" name="toolbar" value="DSCRecentlyAccessedPartsToolBar">
			<input type="hidden" name="jpoAppServerParamList" value="session:GCOTable,session:LCO,session:GCO">
			<input type="hidden" name="table" value="DSCRecentlyAccessedParts">
			<input type="hidden" name="sortColumnName" value="AccessDate">
			<input type="hidden" name="sortDirection" value="descending">
			<input type="hidden" name="selection" value="multiple">
			<input type="hidden" name="header" value="emxIEFDesignCenter.Common.RecentlyAccessedDesigns">
			<!--XSSOK-->
			<input type="hidden" name="dateSelected" value="<%= dateSelected %>">
			<input type="hidden" name="integrationName" value="<xss:encodeForHTMLAttribute><%=sIntegName%></xss:encodeForHTMLAttribute>">
			<input type="hidden" name="suiteKey" value="DesignerCentral">
			<input type="hidden" name="refreshFrame" value="appletReturnHiddenFrame">
			<input type="hidden" name="RECENTLY_ACCESSED_PARTS" value="">
		</form>
		<script language="javascript" type="text/javascript">
		    //XSSOK
			document.appletReturnHiddenForm.RECENTLY_ACCESSED_PARTS.value = "<%= jpoPackedArgs %>";
			document.appletReturnHiddenForm.submit();
		</script>
	</body>
</html>
