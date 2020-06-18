<%-- C3DHeaderPage.jsp

   Copyright Dassault Systemes, 1992-2011. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program
--%>

<%-- <%@include file = "../../common/emxNavigatorInclude.inc"%>
 file above provides getI18NString() --%>
<%@include file   ="../../common/emxLifecycleUtils.inc"%>  
<%@include file = "../../common/emxNavigatorTopErrorInclude.inc"%>
<%
String toolbar = emxGetParameter(request, "toolbar");
String objectId = null;
String relId = null;

if (toolbar == null || toolbar.trim().length() == 0)
{
    toolbar = PropertyUtil.getSchemaProperty(context,"menu_AEFSearchToolbar");
}

//Internationalize
String m_Lang = request.getHeader("Accept-Language");

String I18NResourceBundle = "c3dIntegrationStringResource";
String titleTag = emxGetParameter(request, "titleTag");
String pageTitle = i18nStringNowUtil(titleTag,I18NResourceBundle,m_Lang);

%>
<html>
    <head>
        <title>Search</title>

        <script language="JavaScript" src="../../common/scripts/emxUIConstants.js"></script>
        <script language="JavaScript" src="../../common/scripts/emxUICore.js"></script>
        <script language="JavaScript" src="../../common/scripts/emxUICoreMenu.js"></script>
        <script language="JavaScript" src="../../common/scripts/emxUIToolbar.js"></script>
        <script language="JavaScript" src="../../common/scripts/emxUIActionbar.js"></script>
        <script language="JavaScript" src="../../common/scripts/emxUIModal.js"></script>
        <script language="JavaScript" src="../../common/scripts/emxUIPopups.js"></script>
         
        <script type="text/javascript">		
            addStyleSheet("emxUIDefault");
            addStyleSheet("emxUIToolbar");
            addStyleSheet("emxUIMenu");
            addStyleSheet("emxUISearch");
            
            //overide openHelp
            function openHelp(){
                <%--lgt commented out 
                    top.pageControl.openHelp(arguments); --%>
            }
        </script>
        <link rel="stylesheet" href="../../common/styles/emxUIDefault.css" type="text/css">
        <link rel="stylesheet" href="../../common/styles/emxUIList.css" type="text/css">
        <link rel="stylesheet" href="../../common/styles/emxUIForm.css" type="text/css">
        <style>
  	body { background-color: #DDDECB; }
  	body, th, td, p, select, option { font-family: Verdana, Arial, Helvetica, Sans-Serif; font-size: 8pt; }
  	td.pageBorder {  background-color: #003366; }
  	a { color: #003366; }
  	a:hover { }
	</style>
    </head>
<body>
<form method="post">
  <table border="0" cellspacing="2" cellpadding="0" width="100%">
    <tr>
      <td width="99%">
        <table border="0" cellspacing="0" cellpadding="0" width="100%">
          <tr>
            <td class="pageBorder"><img src="../../common/images/utilSpacer.gif" width="1" height="1" alt=""></td>
          </tr>
        </table>
        <table border="0" width="100%" cellspacing="0" cellpadding="0">
          <tr>
            <td width="1%" nowrap><span class="pageHeader" id="pageHeader">&nbsp;<%=pageTitle%></span></td>
            <td width="1%"><img src="../../common/images/utilSpacer.gif" width="1" height="32" border="0" alt="" vspace="6"></td>
            <td align="right" class="filter">&nbsp;</td>
          </tr>
        </table>
<%-- <jsp:include page = "../../common/emxToolbar.jsp" flush="true">
    <jsp:param name="toolbar" value="<%=toolbar%>"/>
    <jsp:param name="objectId" value="<%=objectId%>"/>
    <jsp:param name="relId" value="<%=relId%>"/>
    <jsp:param name="export" value="false"/>
    <jsp:param name="PrinterFriendly" value="false"/>
</jsp:include> --%>
      </td>
      <td><img src="../../common/images/utilSpacer.gif" alt="" width="4"></td>
    </tr>
  </table>
</form>

        <script language="JavaScript">
        <%-- lgt commented out to avoid javascript errors
            //set window Title
            top.pageControl.setWindowTitle();
            
            //set window Title
            top.pageControl.setPageHeaderText();
        --%>    
            //enable action menu
            window.onload = function(){
                <%-- lgt commented out to avoid javascript errors
                initiate(); 
                top.setSaveFunctionality(true);
                --%>
            }
        </script>

<%@include file = "../../common/emxNavigatorBottomErrorInclude.inc"%>
</body>
</html>
