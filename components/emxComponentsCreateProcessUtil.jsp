<%--
  emxComponentsCreateProcessUtil.jsp

  Copyright (c) 1993-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program

--%>
<%@include file = "../components/emxComponentsTreeUtilInclude.inc" %>
<%@include file = "emxComponentsUtil.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%
	String jsTreeID 	= emxGetParameter(request, "jsTreeID");
	String objectId 	= emxGetParameter(request, "newObjectId");
    String targetLocation = emxGetParameter(request,"targetLocation");
    String DefaultCategory = emxGetParameter(request,"DefaultCategory");
    String strSuiteKey =    emxGetParameter(request,"strSuiteKey");
    StringBuffer treeUrl = null;
    if(!UIUtil.isNullOrEmpty(DefaultCategory)){ 
    treeUrl = new StringBuffer(com.matrixone.apps.framework.ui.UINavigatorUtil.getCommonDirectory(context));
	treeUrl.append("/emxTree.jsp?AppendParameters=true&objectId=").append(XSSUtil.encodeForURL(context, objectId)).append("&DefaultCategory=").append(XSSUtil.encodeForURL(context, DefaultCategory));
    treeUrl.append("&mode=insert&emxSuiteDirectory=").append(XSSUtil.encodeForURL(context, strSuiteKey));
    }
%>
<script src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<script language="javascript" type="text/javaScript">
//XSSOK
var treeURL = "<%=treeUrl%>";
if(treeURL == null || treeURL == "null"){
if (getTopWindow().getWindowOpener() && getTopWindow().getWindowOpener().name == "")
treeURL = getTreeURL("<%=XSSUtil.encodeForJavaScript(context, objectId)%>", "<%=XSSUtil.encodeForJavaScript(context, appDirectory)%>", null, "replace");
else
treeURL = getTreeURL("<%=XSSUtil.encodeForJavaScript(context, objectId)%>", "<%=XSSUtil.encodeForJavaScript(context, appDirectory)%>", null);
}

     loadTreeNode("<%=XSSUtil.encodeForJavaScript(context, objectId)%>", null,"<%=XSSUtil.encodeForJavaScript(context, jsTreeID)%>","<%=XSSUtil.encodeForJavaScript(context, appDirectory)%>",true, treeURL);
<%
	if("slidein".equalsIgnoreCase(targetLocation)) {
%>
		getTopWindow().closeSlideInDialog();
<%  } else {%>
		if (getTopWindow().getWindowOpener() && isIE) {
	    	closePopupWindow(getTopWindow());
		}
		else if (getTopWindow().getWindowOpener()) {
	    	getTopWindow().closeWindow();
		}
<%}%>
</script>
