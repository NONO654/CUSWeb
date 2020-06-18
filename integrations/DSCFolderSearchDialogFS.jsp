<%--  DSCFolderSearchDialogFS.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>

<%@ include file ="MCADTopInclude.inc" %>


<head>
<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
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
	var UI_LEVEL = 3;
	var CALENDAR_START_DOW = 0;
	var isMinIE5 = false,isMinIE55 = false,isMinIE6 = false;

</script>

<script language="javascript" src="../common/scripts/emxUISelectableTree.js"></script>
<script language="javascript" src="../emxUIPageUtility.js"></script>


<script language="javascript">

 var tree = new jsSelectableTree("emxUITree.css");

</script>



<%
	String nodeId = emxGetParameter(request,"nodeId");
	String formName = emxGetParameter(request,"formName");
	String encodedTNR = emxGetParameter(request, "tnr");
	String frameRows = "";
	boolean displayCurrentFolder = false;
	if (null == encodedTNR || encodedTNR.length() == 0)
	{
	   frameRows = "50,50";
	} 
	else
	{
	   frameRows = "50,*,50";
	   displayCurrentFolder = true;
	}
	System.out.println("+++ encodedTNR = " + encodedTNR);
%>
<!--XSSOK-->
<frameset rows="<%=frameRows%>" frameborder="yes" framespacing="2">
    <!--XSSOK-->
	<frame name="headerDisplay" src="MCADFolderSearchDialogHeader.jsp?formName=<%=formName%>" scrolling=no>
<% if (displayCurrentFolder) { %>
    <!--XSSOK-->
	<frame name="folderDisplay" src="DSCFolderSearchDialog.jsp?formName=<%=formName%>" marginheight="3">
<% } %>
    <!--XSSOK-->
	<frame name="bottomDisplay" src="DSCFolderSearchDialogFooter.jsp?nodeId=<%=nodeId%>&formName=<%=formName%>" scrolling=no >
</frameset>
</html>
