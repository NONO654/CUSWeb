<%-- emxLifecycleTaskReassignComments.jsp -   Comments Dialog Page

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any actual or intended
   publication of such program.

   static const char RCSID[] = $Id: emxLifecycleTaskReassignComments.jsp.rca 1.4.3.2 Wed Oct 22 15:48:30 2008 przemek Experimental przemek $
--%>
<%@include file="../emxUICommonAppInclude.inc"%>
<%@include file="../emxUICommonHeaderBeginInclude.inc"%>
<%
    String strLanguage = request.getHeader("Accept-Language");
%>

<script language="JavaScript">
<!--
    function done_onclick() {
       var objPreProcessWnd = findFrame(window.getTopWindow().getWindowOpener().parent, "listHidden");       
       if (objPreProcessWnd) {
	       	if (objPreProcessWnd.submitComments) {	         	
	       		objPreProcessWnd.submitComments(window.getTopWindow(), document.formReassignComment.notificationComment.value);
	       	}
       }         
    }

    function cancel_onclick() {
        getTopWindow().closeWindow();
    }
//-->
</script>

<%@include file="../emxUICommonHeaderEndInclude.inc"%>

<form name="formReassignComment">
    <table border="0" width="100%" cellspacing="2" cellpadding="5">
        <tr>
            <td class="label"><%=i18nNow.getI18nString("emxFramework.Attribute.Comments", "emxFrameworkStringResource", strLanguage)%></td>
            <td class="inputField"><textarea name="notificationComment" rows="5" cols="50"></textarea></td>
        </tr>
    </table>
</form>


<%@include file="../emxUICommonEndOfPageInclude.inc"%>
