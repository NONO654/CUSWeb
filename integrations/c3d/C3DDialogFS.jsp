<%-- C3DDialogFS.jsp

   Copyright Dassault Systemes, 1992-2011. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program
--%>

<%@ page import = "matrix.db.*, matrix.util.*,com.matrixone.servlet.*,com.matrixone.apps.framework.ui.*,com.matrixone.apps.domain.util.*, com.matrixone.apps.domain.*, java.util.*, java.io.*, java.net.URLEncoder, java.util.*" errorPage="../../common/emxNavigatorErrorPage.jsp"%>
<%@include file = "../../common/emxNavigatorBaseInclude.inc"%>
<%@include file = "../../common/emxUIConstantsInclude.inc"%>

<%
  String Result = "";
  String error = "";
  String sErrorCode = "";
//String prMQLString;
  MQLCommand prMQL  = new MQLCommand();
  prMQL.open(context);
 // prMQLString = "execute program eServiceHelpAbout.tcl ";
String[] arg = {
				"eServiceHelpAbout.tcl"
				};
  prMQL.executeCommand(context,"execute program $1",arg);
  Result = prMQL.getResult().trim();
  error = prMQL.getError();

  if( Result.equals(""))//tcl program does not exist
  {
    session.setAttribute("Error",error);

%>
  <emxUtil:i18n localize="i18nId">emxFramework.Common.Error</emxUtil:i18n>: <%=error%>
<%
  }

  StringTokenizer token = new StringTokenizer(Result, "|", false);
  sErrorCode = token.nextToken().trim();//first token

  if( sErrorCode.equals("1"))//internal failure of tcl program
  {
    session.setAttribute("Error",token.nextToken().trim());//second token
%>
    <emxUtil:i18n localize="i18nId">emxFramework.Common.Error</emxUtil:i18n>: <%=error%> 
<%
  }
%>
   
<%!
/*
     * Queries Matrix database to check if person have
     * assigned admin role
     */
static boolean isAdmin(Context context) throws MatrixException 
{
	boolean isAdmin = false;
	String userName = context.getUser();

	//String cmd = "print person \"" + userName + "\" select admin dump;";
	String[] args = {
					userName,
					"dump"
					}; 
    MQLCommand mql = new MQLCommand();
    mql.executeCommand(context, "print person $1 select admin $2",args);
    String mResult = mql.getResult().trim();
    String mError = mql.getError();
    if ((mError.compareTo("")==0) && (null != mResult)) 
	{         
		 if(mResult.equalsIgnoreCase("all"))
		 {
			 isAdmin =  true;
		 }
		 else
		 {
			 int index = mResult.indexOf("property");			 
	         if (index >= 0) 
			 {
				  isAdmin =  true;
	         }
		 }
	}
	return isAdmin;
}
%>
  
<head>
<script language="javascript" src="../../common/scripts/emxUIConstants.js"></script>
<script>
	var DIR_IMAGES = "../../common/images/";
	var DIR_STYLES = "../../common/styles/";
	var DIR_APPLEVEL_STYLES = "../../common/styles/";
	var DIR_APPLEVEL_IMAGES = "../../common/images/";
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
	var URL_MAIN = "../../common/emxMainFrame.asp";
	var URL_SHRUNK = "../../common/emxShrunkFrame.asp";
	var UI_LEVEL = 3;
	var CALENDAR_START_DOW = 0;
	var strUserAgent = navigator.userAgent.toLowerCase();
	var isIE = strUserAgent.indexOf("msie") > -1 && strUserAgent.indexOf("opera") == -1;
	var isMinIE5 = false,isMinIE55 = false,isMinIE6 = false;

</script>

<script language="javascript" src="../../common/scripts/emxUISelectableTree.js"></script>
<script language="javascript" src="../../emxUIPageUtility.js"></script>


<script language="javascript">

 var tree = new jsSelectableTree("emxUITree.css");

</script>
<%
	String nodeId = emxGetParameter(request,"nodeId");
%>

<% 
   boolean isAdmin	 = isAdmin(context);   
   String strIsAdmin = String.valueOf(isAdmin);
	
    //Page parameters to populate
    String contentPage         = null;
    String titleTag            = null;                                     
    String footerDoneCaption   = null;
    String footerNextCaption   = null;
	String footerCancelCaption = null;

    String sPageID = emxGetParameter(request,"c3dPageID");
    if ((sPageID == null) || (sPageID.compareToIgnoreCase("null") == 0)) {
      
        sPageID = "C3DRegisterFormats";
    }     	
    if (sPageID.compareToIgnoreCase("C3DRegisterFormats") == 0) {
        contentPage = "C3DRegisterFormats.jsp?isAdmin="+strIsAdmin;
        titleTag = "c3dIntegration.ViewerReg.PageHeader";
        footerDoneCaption = null;
		if(isAdmin)
		{
        footerNextCaption = "c3dIntegration.Footer.Next";
		}
       	footerCancelCaption = "c3dIntegration.Footer.Cancel";      
    }
%>
<title>AutoVue Formats Registration</title>
<frameset rows="60,*,40" framespacing="0" frameborder="no" border="1">
	<frame name="headerDisplay" src="C3DHeaderPage.jsp?titleTag=<%=titleTag%>" scrolling=no>
	<frame name="middleDisplay" src="<%=contentPage%>" marginheight="3">
	<frame name="bottomDisplay" src="C3DFooterPage.jsp?footerCancelCaption=<%=footerCancelCaption%>&footerNextCaption=<%=footerNextCaption%>" scrolling=no >
</frameset>
</html>
