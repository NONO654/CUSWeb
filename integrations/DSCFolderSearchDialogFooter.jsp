<%--  DSCFolderSearchDialogFooter.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%@ include file ="MCADTopInclude.inc" %>

<%
	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");

	String nodeId	= emxGetParameter(request,"nodeId");
    String formName = emxGetParameter(request, "formName");
%>


<html>
  <head>
  <script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
  <script>

	function doSearch()
	{
	  var framefolderDisplay = findFrame(parent,"folderDisplay");
	  var projectId = framefolderDisplay.document.FolderSearch.projectId.value;
	  //XSSOK
	  parent.window.opener.doSearch(projectId,'<%=nodeId%>');
	  parent.window.close();
	}

	function doSelect ()
	{
		var selectedNode = parent.tree.getSelectedNode();

		if(selectedNode != null)
		{
			var objectId = selectedNode.getObjectID();
			var objectName = selectedNode.name;
			var parentNode = selectedNode.parent;
			var fullPath = objectName;

			while(parentNode != null)
			{
				fullPath = parentNode.name + "/" + fullPath;
				parentNode = parentNode.parent;
			}

			var index = fullPath.indexOf('/');
			fullPath = fullPath.substring(index+1);

			//XSSOK
			var nodeId = "<%=nodeId%>";

			// TC-Folder
			//alert('nodeId = ' +  nodeId);
			//alert('formName = ' + '<%=formName%>');
			//XSSOK
			parent.window.opener.window.document.forms['<%=formName%>'].WorkspaceFolder.value = fullPath;
			//XSSOK
			parent.window.opener.window.document.forms['<%=formName%>'].workspaceFolderId.value = objectId;
			/*if(nodeId != null && nodeId != "null" && nodeId != "")
			{
				parent.window.opener.doSelect(objectId,fullPath, nodeId, document.FolderSelect.ApplyToChild.checked);
			}
			else
			{
				parent.window.opener.doGlobalSelect(objectId,fullPath,document.FolderSelect.ApplyToChild.checked);
			}*/
			parent.window.close();
		}
		else
		{   //XSSOK
			alert("<%=integSessionData.getStringResource("mcadIntegration.Server.Message.PleaseSelectAFolder")%>");
		}
	}


  </script>
    <style type=text/css >
	  body { background-color: #DDDECB; } body, th, td, p { font-family: verdana, helvetica, arial, sans-serif; font-size: 8pt; }a { color: #003366; } a:hover { } a.object { font-weight: bold; } a.object:hover { } span.object {  font-weight: bold; } a.button { } a.button:hover { } td.pageHeader {  font-family: Arial, Helvetica, Sans-Serif; font-size: 13pt; font-weight: bold; color: #990000; } td.pageBorder {  background-color: #003366; } th { text-align: left; color: white; background-color: #336699; } th.sub { text-align: left; color: white; background-color: #999999; } tr.odd { background-color: #ffffff; } tr.even { background-color: #eeeeee; }
    </style>
  </head>
  <body>
<form name="FolderSelect">
	<table border="0" align=right width="10%">
		<tr>

			<td><img src="./images/utilSpace.gif" width=24 height=16 >&nbsp;</td>
			<td nowrap><a href="javascript:doSelect()"><img src="../integrations/images/emxUIButtonNext.gif" border="0" alt="<%=integSessionData.getStringResource("mcadIntegration.Server.ButtonName.Done")%>"></a></td>
			<td nowrap><a href="javascript:doSelect()"><%=integSessionData.getStringResource("mcadIntegration.Server.ButtonName.Done")%></a></td>
			<td nowrap><a href="javascript:parent.window.close()"><img src="../integrations/images/emxUIButtonCancel.gif" border="0" alt="<%=integSessionData.getStringResource("mcadIntegration.Server.ButtonName.Cancel")%>"></a></td>
			<td nowrap><a href="javascript:parent.window.close()"><%=integSessionData.getStringResource("mcadIntegration.Server.ButtonName.Cancel")%></a></td>
	</tr>
	</table>
	</td>
	</tr>
	</table>
</form>
  </body>
</html>
