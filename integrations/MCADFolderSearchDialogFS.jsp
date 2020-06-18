<%--  MCADFolderSearchDialogFS.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>


<%@ include file ="MCADTopInclude.inc" %>
<%@include file ="../iefdesigncenter/DSCAppletUtils.inc"%>
<%@page import="com.matrixone.apps.domain.util.*" %>
<%@page import="com.matrixone.apps.framework.ui.UIUtil" %>
<html>
<head>
<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="javascript" src="../common/scripts/emxUITreeUtil.js"></script>
<script>
	var DIR_IMAGES = "../common/images/";
	var DIR_STYLES = "../common/styles/";
	var DIR_APPLEVEL_STYLES = "../common/styles/";
	var DIR_APPLEVEL_IMAGES = "../common/images/";
	var DIR_TREE = DIR_IMAGES;
	var DIR_NAVBAR = DIR_IMAGES;
	var DIR_SEARCHPANE = DIR_IMAGES;
	var DIR_BUTTONS = DIR_APPLEVEL_IMAGES + "";
	var DIR_SMALL_ICONS = DIR_IMAGES+"";
	var DIR_BIG_ICONS = DIR_IMAGES + "";
	var DIR_UTIL = DIR_APPLEVEL_IMAGES;
	var IMG_BULLET = DIR_IMAGES + "yellowbullet.gif";
	var IMG_SPACER = DIR_IMAGES + "utilSpacer.gif";
	var IMG_LOADING = DIR_IMAGES + "iconStatusLoading.gif";
	var URL_MAIN = "../common/emxMainFrame.asp";
	var URL_SHRUNK = "../common/emxShrunkFrame.asp";
	var PROJECT_SMALL_ICONS = DIR_IMAGES + "iconSmallProject.png";
	var FOLDER_SMALL_ICONS = DIR_IMAGES + "iconSmallFolder.png";
	var WORKSPACE_SMALL_ICONS = DIR_IMAGES + "iconSmallWorkspace.png";
	var PROJECT_HEADING_SMALL_ICON = DIR_IMAGES + "iconSmallProject.gif";
	var UI_LEVEL = 3;
	var CALENDAR_START_DOW = 0;
	var isMinIE5 = false,isMinIE55 = false,isMinIE6 = false;

</script>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="javascript" src="../common/scripts/emxUISelectableTree.js"></script>
<script language="javascript" src="../emxUIPageUtility.js"></script>


<script language="javascript">

 var tree = new jsSelectableTree("emxUITree.css");
 var tempTree = tree; 

function showProgressImage(showIcon)
{
	 if(showIcon)
	 {
		  headerDisplay.document.imgProgress.src = "images/utilProgressDialog.gif";
	 }
	 else
	 {
         headerDisplay.document.imgProgress.src = "images/utilSpace.gif";
     }    	 
}
 
</script>



<%
	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");
	Context context                          = integSessionData.getClonedContext(session);
	
	String nodeId			= emxGetParameter(request,"nodeId");
	String encodedTNR		= emxGetParameter(request,"tnr");
	String integrationName	= emxGetParameter(request,"integrationName");
	String callPage         = emxGetParameter(request, "callPage");
	String workspaceFolderId = Request.getParameter(request,"workspaceFolderId");
	String operationTitle   = Request.getParameter(request,"operationTitle");
	
	if(UIUtil.isNullOrEmpty(integrationName))
	{
		String gcoName = emxGetParameter(request,"gcoName");
         
		 if(!UIUtil.isNullOrEmpty(gcoName))
		{
			 MCADMxUtil util	                = new MCADMxUtil(context, integSessionData.getLogger(), integSessionData.getResourceBundle(), integSessionData.getGlobalCache());
			 String globalConfigObjectID			= util.getGlobalConfigObjectID(context, "MCADInteg-GlobalConfig", gcoName);

			if(!UIUtil.isNullOrEmpty(globalConfigObjectID))
			{
				BusinessObject globalConfigObject	= new BusinessObject(globalConfigObjectID);
				globalConfigObject.open(context);

				String sourceDetailsAttrName		= util.getActualNameForAEFData(context,"attribute_IEF-SourceDetails");

                if(!UIUtil.isNullOrEmpty(sourceDetailsAttrName))
				{
					Attribute sDAttr					= globalConfigObject.getAttributeValues(context, sourceDetailsAttrName);
					integrationName                     = sDAttr.getValue();
				}
			}
		}
	}
	
	if (callPage == null) callPage = "";
	String frameRows		= "";

	boolean displayCurrentFolder = false;
	if (null == encodedTNR || encodedTNR.length() == 0)
	{
	   frameRows = "50,*,50";
	}
	else
	{
	   frameRows = "50,*,*,50";
	   displayCurrentFolder = true;
	}

	//String strShowCollection = emxGetParameter(request,"showCollection");  //L86
	String strShowProject = "true";
	if(integrationName  != null && integrationName.equalsIgnoreCase("solidworks"))
	     strShowProject = "false";

	String strShowCollection = "false";
	String strCheckAccess = "true";
	if (null == strShowCollection)
	{
	    strShowCollection = "";
	}
	if (strShowCollection.equals("false"))
	   strCheckAccess = "false";
	
%>
<!--XSSOK-->
<frameset rows="<%=frameRows%>" frameborder="yes" framespacing="2">
	<frame name="headerDisplay" src="MCADFolderSearchDialogHeader.jsp" scrolling=no>
	<!--XSSOK-->
	<frame name="folderDisplay" src="MCADFolderSearchDialog.jsp?workspaceFolderId= <%=XSSUtil.encodeForURL(context,XSSUtil.encodeForJavaScript(context,workspaceFolderId))%>&showCollection=<%=strShowCollection%>&callPage=<%=XSSUtil.encodeForJavaScript(context,callPage)%>&selectWorkspace=true&showProject=<%=strShowProject%>" marginheight="3">
<% if (displayCurrentFolder) { %>
	<frame name="folderAssignedDisplay" src="DSCFolderAssigned.jsp?nodeId=<%=XSSUtil.encodeForURL(context,XSSUtil.encodeForJavaScript(context,nodeId))%>&tnr=<%=XSSUtil.encodeForJavaScript(context,encodedTNR)%>" marginheight="3">
<% } %>
    <!--XSSOK-->
	<frame name="bottomDisplay" src="MCADFolderSearchDialogFooter.jsp?nodeId=<%=XSSUtil.encodeForURL(context,XSSUtil.encodeForJavaScript(context,nodeId))%>&checkAccess=<%=strCheckAccess%>&integrationName=<%=XSSUtil.encodeForJavaScript(context,integrationName)%>&operationTitle=<%=XSSUtil.encodeForURL(XSSUtil.encodeForJavaScript(context,operationTitle))%>" scrolling=no >
</frameset>
</html>
