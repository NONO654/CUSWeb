<%-- ECMChangeLegacyFilterProcess.jsp --

    Copyright (c) 1992-2018 Enovia Dassault Systemes.All Rights Reserved.
    This program contains proprietary and trade secret information of MatrixOne,Inc.
    Copyright notice is precautionary only and does not evidence any actual
    or intended publication of such program

    static const char RCSID[] =$Id: emxEngineeringFilterProcess.jsp.rca 1.6.3.2 Wed Oct 22 15:52:31 2008 przemek Experimental przemek przemek $
--%>

<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@ include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxUIConstantsInclude.inc"%>
<%@page import="com.matrixone.apps.domain.util.i18nNow"%>
<%@page import="java.util.Enumeration"%>
<%@page import="com.matrixone.apps.framework.ui.UICache"%>
<%@page import="java.util.StringTokenizer"%>
<%@page import="java.util.Iterator"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkUtil"%>



<%
	String acceptLanguage = request.getHeader("Accept-Language");
	String sURL 					="";
	String strObjectId = emxGetParameter(request, "objectId");
	String cmdFilterOption 			= emxGetParameter(request, "ECMChangeLegacyFilter");
	String portalCmdName 			= emxGetParameter(request, "portalCmdName");
	String sToolbar 				= emxGetParameter(request, "toolbar");
	
	HashMap menuMap 				= UICache.getMenu(context, "ECMChangeLegacyMenu");
	MapList commandMap 				= (MapList)menuMap.get("children");
	
	String sRequiredCommand 		= "";
	String cmdLabel 				= "";
	String cmdName 					= "";
	String sDisplayValue 			= "";
	String sActualValue 			= "";
	String sRegisteredSuite 		= "";
	String strStringResourceFile 	= "";
	StringList cmdList 				= new StringList();
			
	Iterator cmdItr = commandMap.iterator();
	while(cmdItr.hasNext())	{
		Map tempMap = (Map)cmdItr.next();
		cmdName = (String)tempMap.get("name");
		HashMap cmdMap = UICache.getCommand(context, cmdName);
		HashMap settingMap = (HashMap)cmdMap.get("settings");
		cmdLabel = (String)cmdMap.get("label");
		sRegisteredSuite = (String)settingMap.get("Registered Suite");

		strStringResourceFile = UINavigatorUtil.getStringResourceFileId(context, sRegisteredSuite);
		sDisplayValue = i18nNow.getI18nString (cmdLabel, strStringResourceFile, context.getSession().getLanguage());
		if(sDisplayValue.equals(cmdFilterOption)){
			sRequiredCommand =  cmdName;
			break;
		}
	}
	boolean isMenu = false;
	String searchType ="";
	String cmdHref ="";
	if(sRequiredCommand!=null){
		HashMap cmdMap = UICache.getCommand(context, sRequiredCommand);
		cmdHref = (String)cmdMap.get("href");
		HashMap settingsMap = (HashMap)cmdMap.get("settings");
	    searchType = (String)settingsMap.get("searchType");
	}
%>

<script language="Javascript">

var sURL = "../common/emxIndentedTable.jsp?table=AEFGeneralSearchResults&searchType=<%=XSSUtil.encodeForJavaScript(context,searchType)%>&toolbar=ECMChangeLegacyToolbar&ECMChangeLegacyFilter=<%=XSSUtil.encodeForJavaScript(context,cmdFilterOption)%>&program=enoECMChangeOrder:getLegacyChangeForSearchType&portalMode=true&objectId=<%=XSSUtil.encodeForJavaScript(context,strObjectId)%>";
	
var contentFrame = findFrame(getTopWindow(), "ECMChangeLegacy");
contentFrame.location.href	= sURL;
</script>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
