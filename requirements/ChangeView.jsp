<%--  ChangeView.jsp
   Copyright (c) 2008-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program
--%>
 <%--  
        @quickreview T25 OEP 12:08:30 (IR-183690V6R2013x ZAPSECURITY+XSS:ChangeView.jsp.") 
        @quickreview QYG     13:02:22 (IR-206692V6R2014: broken in popups") 
 --%>
<%@page import = "java.util.*,com.matrixone.apps.domain.util.*"%>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<html>
<head>
<script src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<%
String TargetView = emxGetParameter(request,"TargetView");
String objectId = emxGetParameter(request, "objectId");
String SelectedProgram = emxGetParameter(request, "selectedProgram");
String SelectedTable = emxGetParameter(request, "selectedTable");
String ExpandOption = "";
String TypeView = "";
String DropDownMenus = "";

HashMap requestMap = UINavigatorUtil.getRequestParameterMap(pageContext);
String strLanguage = request.getHeader("Accept-Language");
String categoryTreeName = emxGetParameter(request, "categoryTreeName");

if(SelectedProgram != null)
{
	ExpandOption = "&selectedProgram=" + SelectedProgram;	
}
if(SelectedTable != null)
{
	TypeView = "&selectedTable=" + SelectedTable;
}
 
int selectedCommand = 0;
if( (TargetView == null) || (TargetView.equals("null")) || (TargetView.equals("")) || (TargetView.equals("sb")))
{  
	selectedCommand = 0;
}
else{
	selectedCommand = 1;
}

DropDownMenus = ExpandOption + TypeView;

String menu = emxGetParameter(request, "menu");
Map menuMap = UIToolbar.getToolbar(context, menu, PersonUtil.getAssignments(context), objectId, requestMap, strLanguage);
MapList children = (MapList)menuMap.get("Children");
int size = children.size() ;
if(size > 0)
{
	Map commandMap = size == 1 ? (Map)children.get(0) : (Map)children.get(selectedCommand);
	String href = (String)commandMap.get("href");
	href += "&objectId=" + objectId + DropDownMenus;
	href += "&suiteKey=Requirements&SuiteDirectory=requirements&StringResourceFileId=emxRequirementsStringResource";
	%>
	 <script language="javascript" type="text/javaScript">
<%-- IR-206692V6R2014: remove categoryTreeName param from popups --%>	 
	 var categoryTreeName = "<%=XSSUtil.encodeForJavaScript(context, categoryTreeName)%>";
	 if(parent.parent == getTopWindow()){
		 categoryTreeName = null;
	 }
	  // Start:IR:183690V6R2013x:T25
	  // Review:OEP
	 parent.location.href = "<%=XSSUtil.encodeForJavaScript(context, href) %>" + "&categoryTreeName=" + categoryTreeName;
	  //END:IR:183690V6R2013x:T25
	</script>
<%		
	return;

}
%>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
</head>
<body>
</body>
</html>

