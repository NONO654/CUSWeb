<%--  emxIssueCreateProcess.jsp

  To handle refresh pages on creation of Issue

  Copyright (c) 1999-2018 Dassault Systemes.

  All Rights Reserved.
  This program contains proprietary and trade secret information
  of MatrixOne, Inc.  Copyright notice is precautionary only and
  does not evidence any actual or intended publication of such program

--%>

<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@ page import = "com.matrixone.apps.domain.util.i18nNow"%>
<%@ page import = "com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%@include file = "../components/emxComponentsTreeUtilInclude.inc" %>

<%
 try{
  //Get paramters from url
  String isApply = emxGetParameter(request, "isApply");
  HashMap requestMap = UINavigatorUtil.getRequestParameterMap(request);
  String addToCallerFrame = emxGetParameter(request,"addToCallerFrame");
  String jsTreeID = emxGetParameter(request, "jsTreeID");
  String issueId = (String) requestMap.get("newObjectId");
  String parentObjId = (String) requestMap.get("objectId");
  String strResolvedTo = (String) requestMap.get("resolvedTo");
  String relId = (String) requestMap.get("relId");
  String appDirectory = (String)EnoviaResourceBundle.getProperty(context,"eServiceSuiteComponents.Directory");
  String fromGlobalActionToolbar = emxGetParameter(request, "fromGlobalActionToolbar");

%>
<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="javascript" src="../common/scripts/emxUIModal.js"></script>
<script language="javascript">

      var treeURL = "";
      var refreshFrameHandle;
      var fromGlobalActionToolbar = "<%=XSSUtil.encodeForJavaScript(context,fromGlobalActionToolbar)%>";
      var issueId = "<%=XSSUtil.encodeForJavaScript(context,issueId)%>";
      var parentObjId = "<%=XSSUtil.encodeForJavaScript(context,parentObjId)%>";
      var isApply = "<%=XSSUtil.encodeForJavaScript(context,isApply)%>";
      var relId = "<%=XSSUtil.encodeForJavaScript(context,relId)%>";
      var strResolvedTo = "<%=XSSUtil.encodeForJavaScript(context,strResolvedTo)%>";
		if(fromGlobalActionToolbar == "true"){
			//XSSOK
			treeURL = getTreeURL(issueId, "<%=appDirectory%>", relId, "replace");
		}else{
			//XSSOK
			treeURL = getTreeURL(issueId, "<%=appDirectory%>", relId);
		}
		if(isApply != "true" && fromGlobalActionToolbar != "true"){		
			if(issueId != null && issueId != "null"){		
				//XSSOK
				loadTreeNode(issueId, parentObjId,"<%=XSSUtil.encodeForJavaScript(context, jsTreeID)%>","<%=appDirectory%>",true, treeURL);
			}
		}else if(isApply == "true" && fromGlobalActionToolbar != "true"){
			if(strResolvedTo == "true" && parentObjId != null && parentObjId != "null"){				
				var frameHandle = emxUICore.findFrame(getTopWindow(),'<%=addToCallerFrame%>');
				if(!frameHandle){
					frameHandle = findFrame(top, 'content');
					frameHandle = frameHandle.findFrame(top, 'detailsDisplay');
				}
				frameHandle.location.href =frameHandle.location.href;

			}else if(strResolvedTo != "true" && (parentObjId == "" || parentObjId == null || parentObjId == "null")){
				if(!refreshFrameHandle){
		     		refreshFrameHandle = emxUICore.findFrame(getTopWindow(),'frameTable');
		      	}
		      	if(refreshFrameHandle){
		      		var oXM = refreshFrameHandle.sbPage.oXML;
					var rowID = emxUICore.selectSingleNode(oXM, "/mxRoot/rows//r[@o]");
					if(rowID){
			        	var  xmlOut = "<mxRoot><action>add</action><data status='committed'><item oid='<%=issueId%>' relId='<%=relId%>' pid='<%=parentObjId%>'/></data></mxRoot>";
			        	refreshFrameHandle.emxEditableTable.addToSelectedMultiRoot(xmlOut);
					}else{
						refreshFrameHandle.location.href =frameHandle.location.href;				
					}
		      	}
			}else{
				var frameHandle = emxUICore.findFrame(getTopWindow(),'<%=XSSUtil.encodeForJavaScript(context,addToCallerFrame)%>');
				if(!frameHandle){
					frameHandle = findFrame(top, 'content');
					frameHandle = frameHandle.findFrame(top, 'detailsDisplay');
				}
				var oXM = frameHandle.sbPage.oXML;
				var rowID = emxUICore.selectSingleNode(oXM, "/mxRoot/rows//r[@o]");
				if(rowID){
		        	var  xmlOut = "<mxRoot><action>add</action><data status='committed'><item oid='<%=issueId%>' relId='<%=relId%>' pid='<%=parentObjId%>'/></data></mxRoot>";
					frameHandle.emxEditableTable.addToSelectedMultiRoot(xmlOut);
				}else{
					frameHandle.location.href =frameHandle.location.href;				
				}
			}
		}
	            
</script>

<%
} // End of try
catch(Exception ex) {
 ex.printStackTrace(System.out);
 session.putValue("error.message", ex.getMessage());
 } // End of catch
%>

<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
