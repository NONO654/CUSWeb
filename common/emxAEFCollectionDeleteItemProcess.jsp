<%--  emxAEFCollectionDeleteItemProcess.jsp   - The Collection Memeber delete object processing page
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
--%>

<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<jsp:useBean id="indentedTableBean" class="com.matrixone.apps.framework.ui.UITableIndented" scope="session"/>
<jsp:useBean id="menuBean" class="com.matrixone.apps.framework.ui.UIMenu" scope="request"/>
<!-- Import the java packages -->
<script language="JavaScript" src="scripts/emxUICore.js" type="text/javascript"></script>
<script>
var parentFrame = false;
</script>
<%@include file = "enoviaCSRFTokenValidation.inc"%>
<%
    String timeStamp = Request.getParameter(request, "timeStamp");  
    HashMap tableData = indentedTableBean.getTableData(timeStamp);
    MapList relBusObjList = indentedTableBean.getFilteredObjectList(tableData);
    HashMap tableControlMap = indentedTableBean.getControlMap(tableData);
    HashMap requestMap = indentedTableBean.getRequestMap(tableData);  
    String sSetName  = SetUtil.getCollectionName(context,(String)requestMap.get("relId"));
    // Properties to be read for Clipboard Collections
    // Modified for Bug 342586
 	String strSystemCollection = EnoviaResourceBundle.getProperty(context, "emxFramework.ClipBoardCollection.Name");
    
    String url = "";
    String SelectedCollections[] = FrameworkUtil.getSplitTableRowIds(emxGetParameterValues(request, "emxTableRowId"));
    StringList memberIds = new StringList();
    if(SelectedCollections!=null) {
        for (int iIndex = 0; iIndex < SelectedCollections.length ; iIndex++) {
            memberIds.addElement(SelectedCollections[iIndex]);
        }
    }
    SetUtil.removeMembers(context, sSetName, memberIds, false);
%>

<%@include file = "emxNavigatorBottomErrorInclude.inc"%>

<script language="Javascript">
	//To close the collection items window on deletion
	if(parentFrame) {
		getTopWindow().closeWindow();
	} else {
		var tree = getTopWindow().objDetailsTree;
		var isRootId = false;
		
		if (tree && tree.root != null) {
			var parentId = tree.root.id;
			var parentName = tree.root.name;
	<%
			for (int i=0;i<memberIds.size();i++) {
				String RelId = (String)memberIds.get(i);
	%>
				var objId = '<xss:encodeForJavaScript><%=RelId%></xss:encodeForJavaScript>';
				tree.getSelectedNode().removeChild(objId);
				if(parentId == objId ){
					isRootId = true;
				}
	<%
			}
	%>
		}
		
		if(isRootId) {
			var url =  "../common/emxTree.jsp?AppendParameters=true&objectId=" + parentId;
			var contentFrame = getTopWindow().findFrame(getTopWindow(), "content");
			if (contentFrame) {
				contentFrame.location.replace(url);
			} else {
				getTopWindow().refreshShortcut();
				getTopWindow().refreshTablePage();
			}
		} else {
			getTopWindow().refreshShortcut();
			getTopWindow().refreshTablePage();
		}
	}
</script>
