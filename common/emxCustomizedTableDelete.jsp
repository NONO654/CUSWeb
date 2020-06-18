<%-- emxCustomizedTableDelete.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program
	static const char RCSID[] = $Id: emxCustomizedTableDelete.jsp.rca 1.10.3.2 Wed Oct 22 15:47:58 2008 przemek Experimental przemek $
--%>

<%@include file="emxNavigatorInclude.inc"%>
<%@include file="emxNavigatorTopErrorInclude.inc"%>
<%@include file="emxNavigatorTimerTop.inc"%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>

<emxUtil:localize id="i18nId" bundle="emxFrameworkStringResource" locale='<xss:encodeForHTMLAttribute><%= request.getHeader("Accept-Language") %></xss:encodeForHTMLAttribute>' />


<jsp:useBean id="tableBean"	class="com.matrixone.apps.framework.ui.UITable" scope="session" />
<jsp:useBean id="indentedTableBean"	class="com.matrixone.apps.framework.ui.UITableIndented" scope="session" />
<html>
<head>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUITableUtil.js" type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUICoreMenu.js" type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUIFreezePane.js" type="text/javascript"></script>


</head>
<body>

<% 
	
	String strUIType = emxGetParameter(request,"uiType");
	String timeStamp = emxGetParameter(request,"timeStamp");
	
	if(strUIType!=null && "table".equals(strUIType))
	{
	    HashMap requestMap = tableBean.getRequestMap(timeStamp);
	   	String strTableName = 	 (String)requestMap.get("table");
	    String strNextTableName = tableBean.deleteCurrentTable(context,strTableName);
	    if(strNextTableName!=null)
	    {
%>

			<script language="JavaScript">
			    // In refreshTable() these params are used as an URL parameter. So encodeForURL() is used here.
				parent.window.refreshTable('<xss:encodeForJavaScript><%=strNextTableName%></xss:encodeForJavaScript>','','','<xss:encodeForJavaScript><%=timeStamp%></xss:encodeForJavaScript>','<xss:encodeForJavaScript><%=strUIType%></xss:encodeForJavaScript>');
			</script>
<% 
	    }
	    else
	    {
%>			
			<script language="JavaScript">
				alert("<emxUtil:i18nScript localize="i18nId">emxFramework.Table.Delete.Error.Message</emxUtil:i18nScript>");
			</script>
<% 
	    }
	}
	if(strUIType!=null && "structureBrowser".equals(strUIType))
	{
	    HashMap requestMap = indentedTableBean.getRequestMap(timeStamp);
	   	String strTableName = 	 (String)requestMap.get("selectedTable");
	   	String strNextTableName = indentedTableBean.deleteCurrentTable(context,strTableName);
	    if(strNextTableName!=null)
	    {
%>
			<script language="JavaScript">
			     // In refreshSBTable() these params are used as an URL parameter. So encodeForURL() is used here.
			     parent.window.refreshSBTable('<xss:encodeForJavaScript><%=strNextTableName%></xss:encodeForJavaScript>','','','true','<xss:encodeForJavaScript><%=timeStamp%></xss:encodeForJavaScript>','<xss:encodeForJavaScript><%=strUIType%></xss:encodeForJavaScript>');
			</script>
<%
	    }
		else
		{
%>    
			<script language="JavaScript">
			alert("<emxUtil:i18nScript localize="i18nId">emxFramework.Table.Delete.Error.Message</emxUtil:i18nScript>");
			</script>

<%
		}
    
	}

%>
	
</body>
</html>
