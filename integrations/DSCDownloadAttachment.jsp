<%--  DSCDownloadAttachment.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%--
  Description : This file sets the framset for custom table page.  
--%>
<!-- IEF imports Start -->
<%@ page import = "com.matrixone.MCADIntegration.server.beans.*, com.matrixone.MCADIntegration.utils.*, com.matrixone.MCADIntegration.server.*" %>
<jsp:useBean id="indentedTableBean" class="com.matrixone.apps.framework.ui.UITableIndented" scope="session"/>

<!-- IEF imports End -->

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Frameset//EN"
"http://www.w3.org/TR/xhtml1/DTD/xhtml1-frameset.dtd">

<html>

<%@include file = "MCADTopInclude.inc"%>

<html>
<head>
</head>
<body>
<script language="JavaScript" src="./scripts/MCADUtilMethods.js" type="text/javascript"></script>
<script language="JavaScript" src="./scripts/IEFUIConstants.js" type="text/javascript"></script>
<script language="JavaScript" src="./scripts/IEFUIModal.js" type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>

<%
    Context context= Framework.getMainContext(session);
	String[] objectIds	 = emxGetParameterValues(request, "emxTableRowId");
	String currIntegName = emxGetParameter(request,"integrationName");

	ArrayList selectedObjectInfo  = new ArrayList(objectIds.length);
	ArrayList selectedObjectRowId = new ArrayList(objectIds.length);

	String timeStamp   = emxGetParameter(request, "timeStamp");
	HashMap tableData  = indentedTableBean.getTableData(timeStamp);
	MapList ObjectList = (MapList) tableData.get("ObjectList");

	for(int i=0; i < objectIds.length; i++)
	{
		String objectRowInfo = 	 objectIds[i];
		selectedObjectRowId.add(objectRowInfo.substring(objectRowInfo.lastIndexOf("|") + 1 ));
	}
	
	for(int i=0; i < ObjectList.size(); i++)
	{
		HashMap objList = (HashMap)ObjectList.get(i);
		String rowInfo  = (String)objList.get("id[level]");

		if(selectedObjectRowId.contains(rowInfo))
			selectedObjectInfo.add(objList.get("rowid"));
	}

%>
<script language="JavaScript">

	var objectIDArray = new Array();
<%
		String objectId = "";
		for(int i=0; i<selectedObjectInfo.size(); i++)
		{
			objectId = (String) selectedObjectInfo.get(i);
%>
			objectIDArray.push('<%=XSSUtil.encodeForJavaScript(context,objectId)%>');
<%
		}
%>
	var urlParameters = "?objectIds=" + objectIDArray +"&integName=" + '<%=XSSUtil.encodeForJavaScript(context,currIntegName)%>';
	var url           = "./DSCDownloadFilesFS.jsp" + urlParameters;

	showIEFModalDialog(url,'500', '500');
</script>

</html>
