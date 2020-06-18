<%-- emxLifecycleTaskReassignCommentsFS.jsp -   Comments FS Page

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any actual or intended
   publication of such program.

   static const char RCSID[] = $Id: emxLifecycleTaskReassignCommentsFS.jsp.rca 1.5.3.2 Wed Oct 22 15:48:21 2008 przemek Experimental przemek $
--%>

<%@include file="../common/emxNavigatorInclude.inc"%>
<%@include file="emxNavigatorTopErrorInclude.inc"%>

<%
    String strLanguage = request.getHeader("Accept-Language");
    String strDoneText = UINavigatorUtil.getI18nString(
            "emxFramework.Lifecycle.Done",
            "emxFrameworkStringResource", strLanguage);
    String strCancelText = UINavigatorUtil.getI18nString(
            "emxFramework.Lifecycle.Cancel",
            "emxFrameworkStringResource", strLanguage);
    String strPageHeading = UINavigatorUtil.getI18nString(
            "emxFramework.ReassignTask.Heading.AddComments",
            "emxFrameworkStringResource", strLanguage);
    String HelpMarker = "emxhelpreassigntaskcomments";

    // Specify URL to come in middle of frameset
    StringBuffer strContentURL = new StringBuffer("emxLifecycleTaskReassignComments.jsp");
%>
<html>
<head>
    <%@include file = "emxUIConstantsInclude.inc"%>
    <script language="JavaScript" type="text/javascript" src="../common/scripts/emxUITableUtil.js"></script>
    <script language="JavaScript" type="text/javascript" src="../common/scripts/emxNavigatorHelp.js"></script>    
    <script language="JavaScript" type="text/javascript" src="../common/scripts/emxUIToolbar.js"></script>

    <script type="text/javascript">
        addStyleSheet("emxUIDefault");
        addStyleSheet("emxUIDialog");
        addStyleSheet("emxUIToolbar");
        addStyleSheet("emxUIMenu");

        function done_onclick(){
            var dialogFrame = findFrame(this, "dialogFrame");
            if (dialogFrame) {
            	dialogFrame.done_onclick();
            }
        }
        
        function cancel_onclick(){
            var dialogFrame = findFrame(this, "dialogFrame");
            if (dialogFrame) {
            	dialogFrame.cancel_onclick();
            }
        }
    </script>
    
    <title><%=strPageHeading%></title>
</head>
	<body leftmargin="1" rightmargin="1" scroll="no">
		<table border="0" cellspacing="0" cellpadding="0" width="100%">
		    <tr>
		        <td class="pageBorder"><img src="images/utilSpacer.gif" width="1" height="1" alt="" /></td>
		    </tr>
		</table>
	
		<table width="100%" cellspacing="0" cellpadding="0" border="0">
		    <tbody>
		        <tr>
		            <td width="1%" nowrap="">
		                <span class="pageHeader"><%=strPageHeading%></span>
		            </td>
		            <td nowrap="">
		                <div id="imgProgressDiv" style="visibility: hidden;">
		                <img width="34" height="28" align="absmiddle" name="progress" src="images/utilProgressBlue.gif"/>
		            </td>
		            <td width="1%">
		                <img width="1" vspace="6" height="28" border="0" alt="" src="images/utilSpacer.gif"/>
		            </td>
		        </tr>
		    </tbody>
		</table>
	
		<jsp:include page="../common/emxToolbar.jsp" flush="true">
	        <jsp:param name="helpMarker" value="<%=HelpMarker%>" />
	        <jsp:param name="PrinterFriendly" value="false" />
	        <jsp:param name="export" value="false" />
	        <jsp:param name="multiColumnSort" value="false" />
	        <jsp:param name="expandLevelFilter" value="false" />
		</jsp:include>
	
		<iframe style="position: relative" name="dialogFrame" src="<%=strContentURL.toString()%>"
		    width="100%" height="75%" frameborder="0" border="0" scrolling="no"></iframe>
	
	    <br/><br/>
	    <table border="0" cellspacing="2" cellpadding="0" align="right">
	        <tr>
	            <td>&nbsp;&nbsp;</td>
	            <td><a href="javascript:done_onclick()"><img border="0" alt="<%=strDoneText%>" src="images/buttonDialogDone.gif" /></a></td>
	            <td nowrap>&nbsp;<a href="javascript:done_onclick()" class="button"><%=strDoneText%></a></td>
	            <td>&nbsp;&nbsp;</td>
	            <td><a href="javascript:cancel_onclick()"><img border="0" alt="<%=strCancelText%>" src="images/buttonDialogCancel.gif" /></a></td>
	            <td nowrap>&nbsp;<a class="button" href="javascript:cancel_onclick()"><%=strCancelText%></a></td>
	        </tr>
	    </table>
	</body>
</html>
