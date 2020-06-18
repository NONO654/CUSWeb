<%--  emxTeamCreateWorkspacePostProcess.jsp  --  Creating Workspace object

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxTeamCreateWorkspacePostProcess.jsp.rca 1.30 Tue Oct 28 18:58:29 2008 przemek Experimental przemek $
 --%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file ="emxTeamCommonUtilAppInclude.inc" %>
<%@include file = "eServiceUtil.inc"%>
<%@include file = "emxTeamGrantAccess.inc"%>
<%@include file = "emxTeamStartUpdateTransaction.inc"%>
<%@include file = "../components/emxComponentsSetCompanyKeyInRPE.inc"%>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<jsp:useBean id="createBean" class="com.matrixone.apps.framework.ui.UIForm" scope="session"/>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%
	String timeStamp = emxGetParameter(request, "timeStamp");
    HashMap formMap = createBean.getFormData(timeStamp);
    HashMap requestMap = UINavigatorUtil.getRequestParameterMap(request);
    String langStr = context.getSession().getLanguage();

  String suiteKey               = emxGetParameter(request,"suiteKey");
  String sourcePageName         = emxGetParameter(request,"sourcePageName");
  String sPortalMode            = emxGetParameter(request,"portalMode");
  String sParentFrameName       = emxGetParameter(request, "parentFrameName");
  String sTreeFrameName         = emxGetParameter(request, "treeFrameName");
  String objectId          		= (String)requestMap.get("newObjectId");
  String sTreeMode				= emxGetParameter(request, "refreshTree");
  
  if (sPortalMode == null || sParentFrameName == null) sPortalMode = "false";
 
  String strUser                = context.getUser();
  boolean bError                = false;
  String strProjectId           = "";
  String treeUrl                = null;

%>
    <%@ include file = "emxTeamCommitTransaction.inc" %>
    <%@  include file="emxTeamAbortTransaction.inc" %>
<%
String treeMode = "";
if("true".equalsIgnoreCase(sTreeMode)){
	  treeMode = "replace";
}else{
	  treeMode = "insert"; 
}

  treeUrl = UINavigatorUtil.getCommonDirectory(context)+
                  "/emxTree.jsp?AppendParameters=true"+
                  "&treeNodeKey=node.Workspace&suiteKey=eServiceSuiteTeamCentral&objectId="+
                  objectId +
                  "&mode="+treeMode+
                  "&emxSuiteDirectory="+appDirectory +
                  "&treeTypeKey=type.Project&suiteKey=" + XSSUtil.encodeForURL(context, suiteKey) ;

  if(bError) {
%>

  <script language="javascript">
 //handle double-click issue
 //XSSOK
   alert("<%=session.getValue("error.message")%>");
  parent.document.location.href=parent.document.location.href;


  </script>

<%
  } else {
%>
<script language="javascript">
//XSSOK
var isPortalMode         = "true" == <%=(XSSUtil.encodeForJavaScript(context,sPortalMode).equals("true") && XSSUtil.encodeForJavaScript(context, sParentFrameName) != null && XSSUtil.encodeForJavaScript(context, sParentFrameName).length() > 0)%>;
//XSSOK
var isSourcePageName     = "true" == <%=(XSSUtil.encodeForJavaScript(context, sourcePageName) == null || "null".equals(XSSUtil.encodeForJavaScript(context, sourcePageName))|| "".equals(XSSUtil.encodeForJavaScript(context,sourcePageName)))%>;
var frameContent = openerFindFrame(getTopWindow(), "content"); 
  if (isPortalMode) {
      var portalFrame  = openerFindFrame(getTopWindow(), '<%=XSSUtil.encodeForJavaScript(context,sParentFrameName)%>');
       if (portalFrame != null) {
        portalFrame.document.location.href = portalFrame.document.location.href;
    }
    var treeFrame = openerFindFrame(getTopWindow(), '<%=XSSUtil.encodeForJavaScript(context,sTreeFrameName)%>');
    if (treeFrame != null){
        treeFrame.document.location.href = treeFrame.document.location.href;
    }
  }
  else  {
	if (frameContent != null) { 
	     if(isSourcePageName) {
			//XSSOK
			frameContent.document.location = "<%= treeUrl %>";
   } else {
			//XSSOK
			frameContent.document.location.href = "<%= treeUrl %>";
         }
	}
	else if(getTopWindow().getWindowOpener() != null){
		//XSSOK
		getTopWindow().getWindowOpener().location = "<%= treeUrl %>";
		}
	parent.window.closeWindow();
	}
</script>

<%
  }
%>

