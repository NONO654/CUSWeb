<%--  emxPrefImagesInTablesForms.jsp  --

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxPrefImages.jsp.rca 1.1.1.1.5.4 Wed Oct 22 15:48:47 2008 przemek Experimental przemek $
 --%>

<%@include file = "emxNavigatorInclude.inc"%>

<HTML>

<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxUIConstantsInclude.inc"%>

  <HEAD>
    <TITLE></TITLE>
    <META http-equiv="imagetoolbar" content="no" />
    <META http-equiv="pragma" content="no-cache" />
    <SCRIPT language="JavaScript" src="scripts/emxUIConstants.js"
    type="text/javascript">
    </SCRIPT>
    <SCRIPT language="JavaScript" src="scripts/emxUIModal.js"
          type="text/javascript">
    </SCRIPT>
    <SCRIPT language="JavaScript" src="scripts/emxUIPopups.js"
          type="text/javascript">
    </SCRIPT>
    <SCRIPT type="text/javascript">
      addStyleSheet("emxUIDefault");
      addStyleSheet("emxUIForm");

      function doLoad() {
        if (document.forms[0].elements.length > 0) {
          var objElement = document.forms[0].elements[0];

          if (objElement.focus) objElement.focus();
          if (objElement.select) objElement.select();
        }
      }
    </SCRIPT>
  </HEAD>

 <%
        String strImagesTables="";
        String strImagesForms="";
        String strShowImagesInTables="";
        String strShowImagesInForms="";
        String strShowImagesTablesYesSelected="";
        String strShowImagesTablesNoSelected="";
        String strShowImagesFormsYesSelected="";
        String strShowImagesFormsNoSelected="";

        strImagesTables=PersonUtil.getImagesTables(context);
        strImagesForms=PersonUtil.getImagesForms(context);

        if( (strImagesTables == null) || (strImagesTables.equals("null")) || (strImagesTables.equals("")) || (strImagesTables.equals("Yes")))
        {
            strShowImagesTablesYesSelected="checked";
        }
        else
        {
            strShowImagesTablesNoSelected="checked";
        }
        if( (strImagesForms == null) || (strImagesForms.equals("null")) || (strImagesForms.equals("")) || (strImagesForms.equals("Yes")))
        {
            strShowImagesFormsYesSelected="checked";
        }
        else
        {
            strShowImagesFormsNoSelected="checked";
        }
  %>
  <BODY onload="doLoad(), turnOffProgress()">
    <FORM method="post" action="emxPrefImagesProcessing.jsp">
      <TABLE border="0" cellpadding="5" cellspacing="2"
             width="100%">
        <TR>
          <TD width="150" class="label">
            <emxUtil:i18n localize="i18nId">emxFramework.ImagePreference.ShowImagesInTables</emxUtil:i18n>
          </TD>
          <td class="inputField">
                <table>
                        <tr>
                                <!-- //XSSOK -->
                                <td><input type="radio" name="prefShowImagesTables" id="prefShowImagesTables" value="Yes" <%=strShowImagesTablesYesSelected%> /><emxUtil:i18n localize="i18nId">emxFramework.ImagePreference.Yes</emxUtil:i18n></td>
                        </tr>
                        <tr>
                        <!-- //XSSOK -->
                        <td><input type="radio" name="prefShowImagesTables" id="prefShowImagesTables" value="No" <%=strShowImagesTablesNoSelected%> /><emxUtil:i18n localize="i18nId">emxFramework.ImagePreference.No</emxUtil:i18n></td>
                        </tr>
                </table>
          </td>
       </TR>
       <TR>
          <TD width="150" class="label">
            <emxUtil:i18n localize="i18nId">emxFramework.ImagePreference.ShowImagesInForms</emxUtil:i18n>
          </TD>
          <td class="inputField">
                <table>
                        <tr>
                                <!-- //XSSOK -->
                                <td><input type="radio" name="prefShowImagesForms" id="prefShowImagesForms" value="Yes" <%=strShowImagesFormsYesSelected%> /><emxUtil:i18n localize="i18nId">emxFramework.ImagePreference.Yes</emxUtil:i18n></td>
                        </tr>
                        <tr>
                        <!-- //XSSOK -->
                        <td><input type="radio" name="prefShowImagesForms" id="prefShowImagesForms" value="No" <%=strShowImagesFormsNoSelected%> /><emxUtil:i18n localize="i18nId">emxFramework.ImagePreference.No</emxUtil:i18n></td>
                        </tr>
                </table>
          </td>
        </TR>
        <TR>
            <TD>&nbsp;</TD>
            <TD>&nbsp;</TD>
        </TR>
       <TR>
           <TD width="150" class="label">
                 <emxUtil:i18n localize="i18nId">emxFramework.ImagePreference.Note</emxUtil:i18n>
           </TD>
           <td class="inputField">
           <table>
                  <tr>
                     <td><emxUtil:i18n localize="i18nId">emxFramework.ImagePreference.NoteContent</emxUtil:i18n></td>
                  </tr>
            </table>
            </td>
       </TR>

      </TABLE>
    </FORM>
  </BODY>

<%@include file = "emxNavigatorBottomErrorInclude.inc"%>

</HTML>

