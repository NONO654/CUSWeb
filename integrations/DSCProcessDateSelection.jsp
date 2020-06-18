<%--  DSCProcessDateSelection.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%@ page import="com.matrixone.MCADIntegration.utils.*,com.matrixone.MCADIntegration.server.beans.*,matrix.db.*"  %>
<%@ page import="com.matrixone.apps.domain.util.* ,java.util.Map"%>

<%@page import="com.matrixone.apps.domain.util.ENOCsrfGuard"%>

<%
	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");
	Context context								= integSessionData.getClonedContext(session);

	MCADMxUtil util    							= new MCADMxUtil(context, integSessionData.getLogger(), integSessionData.getResourceBundle(), integSessionData.getGlobalCache());
	String dateSelected						    =Request.getParameter(request,"DSCRecentlyAccessedPartsFilter");	
        //String RECENTLY_ACCESSED_PARTS				=Request.getParameter(request,"ACCESSED_PARTS");
        String RECENTLY_ACCESSED_PARTS              =Request.getParameter(request,"RECENTLY_ACCESSED_PARTS");

	String sIntegName							=Request.getParameter(request,"integrationName");

%>

 <html>
	<head>
		<script language="JavaScript" src="../common/scripts/emxUIConstants.js"></script>
		<script language="javascript" src="../integrations/scripts/MCADUtilMethods.js" type="text/javascript"></script>
		<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>
	</head>
	<body>
		<form target="_parent" name="appletReturnHiddenForm" method="post" action="../common/emxIndentedTable.jsp">

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
			<!--XSSOK-->
			<input type="hidden" name="integrationName" value="<%=sIntegName%>">
			<input type="hidden" name="suiteKey" value="DesignerCentral">
			<input type="hidden" name="refreshFrame" value="appletReturnHiddenFrame">
			<input type="hidden" name="RECENTLY_ACCESSED_PARTS" value="">
		</form>
		<script language="javascript" type="text/javascript">
		        //XSSOK
			document.appletReturnHiddenForm.dateSelected.value = "<%= dateSelected %>";
			//XSSOK
			document.appletReturnHiddenForm.RECENTLY_ACCESSED_PARTS.value = "<%= RECENTLY_ACCESSED_PARTS %>";
			document.appletReturnHiddenForm.submit();
		</script>
	</body>
</html>

