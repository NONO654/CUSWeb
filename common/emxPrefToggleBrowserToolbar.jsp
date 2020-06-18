<%--  emxPrefToggleBrowserToolbar.jsp -
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxPrefToggleBrowserToolbar.jsp.rca 1.1.1.5 Wed Oct 22 15:48:19 2008 przemek Experimental przemek $
--%>

<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>

<%
    String showToolbar="";
    String toolbarYesSelected="";
    String toolbarNoSelected="";      

    showToolbar = PersonUtil.getToolbarPreference(context);
    if( (showToolbar == null) || (showToolbar.equals("null")) || (showToolbar.equals("")) || (showToolbar.equals("true") ))
    {
        toolbarYesSelected="checked";
    }        
    else
    {
        toolbarNoSelected="checked";
    }                
%>
<html>
  <head>
    <title></title>
    <script language="JavaScript" src="scripts/emxUIConstants.js" type="text/javascript"></script>
      <script language="JavaScript" src="scripts/emxUICore.js" type="text/javascript"></script>
    <script language="JavaScript" src="scripts/emxUIModal.js" type="text/javascript"></script>
    <script language="JavaScript" src="scripts/emxUIPopups.js" type="text/javascript"></script>
    <script type="text/javascript">
      addStyleSheet("emxUIDefault");
      addStyleSheet("emxUIForm");
    </script>
  </head>
  <body onload="turnOffProgress()">
   <form method="post" action="emxPrefToggleBrowserToolbarProcess.jsp" onsubmit="findFrame(getTopWindow(),'preferencesFoot').submitAndClose()">
      <table border="0" cellpadding="5" cellspacing="2" width="100%">
        <tr>
          <td width="150" class="label">
            <emxUtil:i18n localize="i18nId">emxFramework.ToggleBrowserPreference.ShowBrowserToolbar</emxUtil:i18n>
          </td>
          <td class="inputField">
            <table>
             <tr>
              <td><input type="radio" name="showToolbar" id="showToolbar" value="true" <%=toolbarYesSelected%> /><emxUtil:i18n localize="i18nId">emxFramework.label.Yes</emxUtil:i18n></td>
             </tr>
             <tr>
              <td><input type="radio" name="showToolbar" id="showToolbar" value="false" <%=toolbarNoSelected%> /><emxUtil:i18n localize="i18nId">emxFramework.label.No</emxUtil:i18n></td>
             </tr>
             <tr> 
              <td><emxUtil:i18n localize="i18nId">emxFramework.Preferences.ToggleToolbarMessage</emxUtil:i18n>&nbsp;</td>
             </tr>
             </table>
          </td>
        </tr>
      </table>
    </form>
  </body>
<%@include file = "emxNavigatorBottomErrorInclude.inc"%>
</html>
