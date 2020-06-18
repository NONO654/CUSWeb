<%--  emxPrefLanguage.jsp -
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxPrefLanguage.jsp.rca 1.7 Wed Oct 22 15:49:00 2008 przemek Experimental przemek $
--%>

<%@include file = "emxNavigatorInclude.inc"%>
<HTML>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>

  <HEAD>
    <TITLE></TITLE>
    <META http-equiv="imagetoolbar" content="no" />
    <META http-equiv="pragma" content="no-cache" />
    <SCRIPT language="JavaScript" src="scripts/emxUIConstants.js"
    type="text/javascript">
    </SCRIPT>
    <script language="JavaScript" src="scripts/emxUICore.js"></script>
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
  <BODY onload="doLoad(), turnOffProgress()">
    <FORM id="LangPref" method="post" action="emxPrefLanguageProcessing.jsp">
      <TABLE border="0" cellpadding="5" cellspacing="2"
             width="100%">
        <TR>
          <TD width="150" class="label">
            <emxUtil:i18n localize="i18nId">emxFramework.Preferences.Language</emxUtil:i18n>
          </TD>
          <TD class="inputField">
            <SELECT name="language" id="language">
<%
    try
    {
    ContextUtil.startTransaction(context, false);
    // Get Language choices
    ArrayList languageChoices = PersonUtil.getLanguageChoices(context);

    // Get Language preference set for logged in user
    String languageDefault = PersonUtil.getLanguage(context);

    // for each Language choice
    for (int i = 0; i < languageChoices.size(); i++)
    {
        // get choice
        String choice = (String)languageChoices.get(i);

        // translate the choice
        String choicePropKey = "emxFramework.Preferences.Language." + choice.replace(' ', '_');
        String choicePropValue = UINavigatorUtil.getI18nString(choicePropKey, "emxFrameworkStringResource", request.getHeader("Accept-Language"));

        // if translation not found then show choice.
        if (choicePropValue == null || choicePropValue.equals(choicePropKey))
        {
            choicePropValue = choice;
        }

        // if choice is equal to default then
        // mark it selected
        if (choice.equals(languageDefault))
        {
%>
              <OPTION value="<%=XSSUtil.encodeForHTMLAttribute(context,(String)choice)%>" selected>
                <!-- //XSSOK -->
                <%=choicePropValue%>
              </OPTION>
<%
        }
        else
        {
%>
              <OPTION value="<%=XSSUtil.encodeForHTMLAttribute(context,(String)choice)%>">
                <!-- //XSSOK -->
                <%=choicePropValue%>
              </OPTION>
<%
        }
    }
    }
    catch (Exception ex)
    {
        ContextUtil.abortTransaction(context);

        if(ex.toString()!=null && (ex.toString().trim()).length()>0)
        {
            emxNavErrorObject.addMessage("emxPrefConversions:" + ex.toString().trim());
        }
    }
    finally
    {
        ContextUtil.commitTransaction(context);
    }
%>
            </SELECT>
          </TD>
        </TR>
      </TABLE>
    </FORM>
  </BODY>

<%@include file = "emxNavigatorBottomErrorInclude.inc"%>

</HTML>

