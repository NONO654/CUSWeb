<%--  IEFObjectAttachments.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>

<%@ page import="java.util.*,java.io.*, java.net.*,com.matrixone.MCADIntegration.server.*,com.matrixone.MCADIntegration.server.beans.*, com.matrixone.MCADIntegration.utils.*,com.matrixone.MCADIntegration.utils.customTable.*"  %>
<%@ page import = "matrix.db.*, matrix.util.*,com.matrixone.servlet.*,com.matrixone.apps.framework.ui.*,com.matrixone.apps.domain.util.*, com.matrixone.apps.domain.*,com.matrixone.MCADIntegration.server.cache.*" %>

<%@ include file="../common/emxNavigatorTopErrorInclude.inc" %>
<%@ include file="../emxTagLibInclude.inc" %>

<%@page import="com.matrixone.apps.domain.util.ENOCsrfGuard"%>

<html>
<head>

<%
    Context context          = null;
	String objectID			 =Request.getParameter(request,"objectId");
	String typeName			 =Request.getParameter(request,"typeName");
	String headerKey		 =Request.getParameter(request,"header");
	String helpMarker		 =Request.getParameter(request,"HelpMarker");
	String table     		 =Request.getParameter(request,"table");
	String topActionbar		 =Request.getParameter(request,"topActionbar");
	String suiteKey			 =Request.getParameter(request,"suiteKey");
	String sortColumnName	 =Request.getParameter(request,"sortColumnName");
	String sortDirection	 =Request.getParameter(request,"sortDirection");
	String selection		 =Request.getParameter(request,"selection");
	String portalMode		 =Request.getParameter(request,"portalMode");
	String categoryTree =Request.getParameter(request,"categoryTreeName");
	String suiteDirectory	 = Request.getParameter(request,"emxSuiteDirectory");
	String printerFriendly	 =Request.getParameter(request,"PrinterFriendly") == null ? "true":Request.getParameter(request,"PrinterFriendly") ;

	table   	   = (table == null) ? "DSCAttachments" : table;
	topActionbar   = (topActionbar == null) ? "IEFObjectAttachmentsTopActionBar" : topActionbar;
	headerKey	   = (headerKey == null) ? "emxIEFDesignCenter.Header.Attachments" : headerKey;
	suiteKey	   = (suiteKey == null) ? "eServiceSuiteDesignerCentral" : suiteKey;
	helpMarker	   = (helpMarker == null) ? "emxhelpdscuploadfiles" : helpMarker;
	selection 	   = (selection == null) ? "multiple" : selection;

	sortColumnName = (sortColumnName == null) ? "Name" : sortColumnName;
	sortDirection  = (sortDirection == null) ? "ascending" : sortDirection;
	portalMode	   = (portalMode == null) ? "false" : portalMode;

	String integrationName						= "";
	String errorMessage							= "";
	String oldobjectID								= "";
	MCADGlobalConfigObject  globalConfigObject	= null;
	String sProjectMajorData = "false";

	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute(MCADServerSettings.MCAD_INTEGRATION_SESSION_DATA_OBJECT);

	String acceptLanguage						  = request.getHeader("Accept-Language");
	MCADServerResourceBundle serverResourceBundle = new MCADServerResourceBundle(acceptLanguage);

	if(integSessionData == null)
	{
		errorMessage = serverResourceBundle.getString("mcadIntegration.Server.Message.ServerFailedToRespondSessionTimedOut");
	}
	// [NDM] H68 start
	else
	{
		context				= integSessionData.getClonedContext(session);
		MCADMxUtil util		= new MCADMxUtil(context, integSessionData.getLogger(), integSessionData.getResourceBundle(), integSessionData.getGlobalCache());
		integrationName		= util.getIntegrationName(context, objectID);

		String IS_VERSION_OBJ = MCADMxUtil.getActualNameForAEFData(context,"attribute_IsVersionObject");
		String SELECT_ISVERSIONOBJ = "attribute["+IS_VERSION_OBJ+"]";	

		String relVersionOf = MCADMxUtil.getActualNameForAEFData(context, "relationship_VersionOf");		
		String SELECT_MAJOR = "from["+relVersionOf+"].to.id";
		
		StringList slSelectsForInputID = new StringList(2);
		slSelectsForInputID.addElement(SELECT_ISVERSIONOBJ);
		slSelectsForInputID.addElement(SELECT_MAJOR);

		StringList slOid = new StringList(1);				
		slOid.addElement(objectID);

		String [] oidsTopLevel		  = new String [slOid.size()];
		slOid.toArray(oidsTopLevel);	

		BusinessObjectWithSelectList buslWithSelectionList = BusinessObject.getSelectBusinessObjectData(context, oidsTopLevel, slSelectsForInputID);
		BusinessObjectWithSelect busObjectWithSelect 		= (BusinessObjectWithSelect)buslWithSelectionList.elementAt(0);
		String isThisVersionObj         = (String)busObjectWithSelect.getSelectData(SELECT_ISVERSIONOBJ);
		boolean isVersion = Boolean.valueOf(isThisVersionObj).booleanValue();

		if(isVersion){
			String sMajorId         = (String)busObjectWithSelect.getSelectData(SELECT_MAJOR);
			String sActiveMinorID = util.getActiveVersionObject(context, sMajorId);
			if(sActiveMinorID.equals(objectID)){
				sProjectMajorData = "true";
				objectID = sMajorId;
			}
		}

						
				}
	// [NDM] H68 end

	
%>

</head>
<body>
<SCRIPT LANGUAGE="JavaScript">
	top.bclist.changeID("<%=XSSUtil.encodeForJavaScript(integSessionData.getClonedContext(session),oldobjectID)%>","<%=XSSUtil.encodeForJavaScript(integSessionData.getClonedContext(session),objectID)%>", true);
</SCRIPT>
<form name="whereUsedForm" action="../common/emxIndentedTable.jsp" >

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

	<input type="hidden" name="program" value="IEFListAttachments:getTableData">
	<input type="hidden" name="typeName" value="<xss:encodeForHTMLAttribute><%= typeName %></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="expandLevelFilter" value="false">
	<input type="hidden" name="table" value="<xss:encodeForHTMLAttribute><%= table %></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="sortColumnName" value="<xss:encodeForHTMLAttribute><%=sortColumnName%></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="sortDirection" value="<xss:encodeForHTMLAttribute><%=sortDirection%></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="selection" value="<xss:encodeForHTMLAttribute><%=selection%></xss:encodeForHTMLAttribute>">
	<%
		IEFIntegAccessUtil accessUtil		= new IEFIntegAccessUtil(context, new MCADServerResourceBundle(acceptLanguage), new IEFGlobalCache());		
		if(sProjectMajorData.equals("false") && (integrationName == null || integrationName.equals("") ||  accessUtil.getAssignedIntegrations(context).contains(integrationName)) )
		{
	%>
	<input type="hidden" name="topActionbar" value="<xss:encodeForHTMLAttribute><%=topActionbar%></xss:encodeForHTMLAttribute>">
	<%
		}
	%>	
	<input type="hidden" name="header" value="<xss:encodeForHTMLAttribute><%= headerKey %></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="objectCompare" value="false">
	<input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%= objectID %></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="HelpMarker" value="<xss:encodeForHTMLAttribute><%= helpMarker %></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="categoryTreeName" value="<xss:encodeForHTMLAttribute><%=categoryTree%></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="suiteKey" value="<xss:encodeForHTMLAttribute><%= suiteKey %></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="portalMode" value="<xss:encodeForHTMLAttribute><%= portalMode %></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="expandLevelFilter" value="false">
	<input type="hidden" name="PrinterFriendly" value="<xss:encodeForHTMLAttribute><%=printerFriendly%></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="SuiteDirectory" value="<xss:encodeForHTMLAttribute><%=suiteDirectory%></xss:encodeForHTMLAttribute>">
</form>

<%@ include file="../common/emxNavigatorBottomErrorInclude.inc" %>

<%
	if ("".equals(errorMessage.trim()))
	{
%>
	<SCRIPT LANGUAGE="JavaScript">
		document.whereUsedForm.submit();
	</SCRIPT>
<%
	} else {
%>
	<link rel="stylesheet" href="../emxUITemp.css" type="text/css">
	&nbsp;
      <table width="90%" border=0  cellspacing=0 cellpadding=3  class="formBG" align="center" >
        <tr >
		  <!--XSSOK-->
          <td class="errorHeader"><%=serverResourceBundle.getString("mcadIntegration.Server.Heading.Error")%></td>
        </tr>
        <tr align="center">
		  <!--XSSOK-->
          <td class="errorMessage" align="center"><%=errorMessage%></td>
        </tr>
      </table>
<%
	}
%>
</body>
</html>
