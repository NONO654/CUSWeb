<%-- emxSearchHeader.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxSearchHeader.jsp.rca 1.18 Wed Oct 22 15:48:26 2008 przemek Experimental przemek $
--%>

<%@include file = "emxNavigatorInclude.inc"%>

<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<%
//Define request Parameters for toolbar
// String toolbar = "searchToolbar";
String toolbar = emxGetParameter(request, "toolbar");
String showToolbar = emxGetParameter(request, "showToolbar");
String objectId = null;
String relId = null;

if( (toolbar == null || toolbar.trim().length() == 0) && (!"false".equalsIgnoreCase(showToolbar)))
{
    toolbar = PropertyUtil.getSchemaProperty(context,"menu_AEFSearchToolbar");
}

//get title
String title = emxGetParameter(request, "title");
String languageStr = request.getHeader("Accept-Language");
if(title != null && title.length() > 0) {
    String containedInStr = "";
    containedInStr = UINavigatorUtil.getI18nString(title,"emxFrameworkStringResource",languageStr); 
    if(containedInStr != null && containedInStr.length() > 0) {
        title = containedInStr;
    }
}


%>
<html>
    <head>
        <title>Search</title>

        <script language="JavaScript" src="scripts/emxUIConstants.js"></script>
        <script language="JavaScript" src="scripts/emxUICore.js"></script>
        <script language="JavaScript" src="scripts/emxUICoreMenu.js"></script>
        <script language="JavaScript" src="scripts/emxUIToolbar.js"></script>
        <script language="JavaScript" src="scripts/emxUIActionbar.js"></script>
        <script language="JavaScript" src="scripts/emxUIModal.js"></script>
        <script language="JavaScript" src="scripts/emxUIPopups.js"></script>

        <script type="text/javascript">
            addStyleSheet("emxUIDefault");
            addStyleSheet("emxUIToolbar");
            addStyleSheet("emxUIMenu");
            addStyleSheet("emxUISearch");
            addStyleSheet("emxUIDialog");
            //overide openHelp
            function openHelp(){
                getTopWindow().pageControl.openHelp(arguments);
            }
        </script>

    </head>
<body class="head dialog">
<form method="post">
<div id="pageHeadDiv">
   <table>
     <tr>
    <td class="page-title">
      <h2><emxUtil:i18n localize="i18nId">emxFramework.GlobalSearch.Search</emxUtil:i18n></h2>
    </td>
<%
       String processingText = UINavigatorUtil.getProcessingText(context, languageStr);
%>
        <td class="functions">
	        <table><tr>
	                <!-- //XSSOK -->
	                <td class="progress-indicator"><div id="imgProgressDiv"><%=processingText%></div></td>
	        </tr></table>
        </td>
        </tr>
        </table>
<jsp:include page = "emxToolbar.jsp" flush="true">
    <jsp:param name="toolbar" value="<%=XSSUtil.encodeForURL(context, toolbar)%>"/>
    <jsp:param name="objectId" value="<%=XSSUtil.encodeForURL(context, objectId)%>"/>
    <jsp:param name="relId" value="<%=XSSUtil.encodeForURL(context, relId)%>"/>
    <jsp:param name="export" value="false"/>
    <jsp:param name="PrinterFriendly" value="false"/>
</jsp:include>
</div>
</form>

        <script language="JavaScript">
<%
            if(title == null || "null".equals(title) || "".equals(title)) {
%>
            //set window Title
            getTopWindow().pageControl.setWindowTitle();
<%
            }else {
%>
                getTopWindow().pageControl.setWindowTitle("<xss:encodeForHTML><%=title%></xss:encodeForHTML>");
<%
            }

            //set window Title
            if(title == null || "null".equals(title) || "".equals(title)) {
%>
                getTopWindow().pageControl.setPageHeaderText();
<%
            }else {
%>
                getTopWindow().pageControl.setPageHeaderText("<%=XSSUtil.encodeForURL(context,title)%>");
<%
            }
%>
            function enablesave () {
				setTimeout(function(){
					getTopWindow().setSaveFunctionality(true);
				}, 1000);
			}

            emxUICore.addEventHandler(window, "load", enablesave);
        </script>

<%@include file = "emxNavigatorBottomErrorInclude.inc"%>
</body>
</html>
