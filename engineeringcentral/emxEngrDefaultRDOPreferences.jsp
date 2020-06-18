<%--  emxEngrDefaultRDOPreferences.jsp -
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@include file = "emxDesignTopInclude.inc"%>
<%@include file = "emxEngrVisiblePageInclude.inc"%>
<%@include file = "emxengchgJavaScript.js"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>

</head>
<BODY onload="getTopWindow().turnOffProgress()">

<%
  String languageStr = request.getHeader("Accept-Language");
%>

  <form name="PrefForm" method="post"  action="emxEngrDefaultRDOPreferencesProcess.jsp" onsubmit="javascript:submitAndUpdate(); return false">
    <table border="0" cellpadding="5" cellspacing="2" width="100%">
      <tr>
        <td width="150" class="label">
          <emxUtil:i18n localize="i18nId">emxEngineeringCentral.Preferences.DesignResponsibility</emxUtil:i18n>
        </td>
        <td class="inputField">
            <input type="hidden" value="false" name="rdoflag" />
			<input type="text" name="RDO" size="20" readonly="readonly" value="<xss:encodeForHTMLAttribute><%=defaultRDOName%></xss:encodeForHTMLAttribute>" />
            <input type="hidden" name="RDOId" value="<xss:encodeForHTMLAttribute><%=defaultRDOId%></xss:encodeForHTMLAttribute>" />
            <input type="button" value="..." name="btnRDO" onclick="javascript:showModalDialog('emxpartRDOSearchDialogFS.jsp?form=PrefForm&field=RDO&fieldId=RDOId&searchLinkProp=SearchRDOLinks', 550,400);" />
            <a href="JavaScript:clearField('PrefForm','RDO','RDOId')" ><emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.Clear</emxUtil:i18n></a>
        </td>
      </tr>
      <tr>
        <td width="150" class="label"><emxUtil:i18n localize="i18nId">emxEngineeringCentral.Preferences.ForSession</emxUtil:i18n>
      </td>
        <td class="inputField">
        <table border="0">
          <tr>
            <td><input type="radio" value="CURRENT" name="RDOOption" />
              <emxUtil:i18n localize="i18nId">emxEngineeringCentral.Preferences.Current</emxUtil:i18n>
            </td>
          </tr>
          <tr>
            <td><input type="radio" checked value="ALL" name="RDOOption" />
              <emxUtil:i18n localize="i18nId">emxEngineeringCentral.Preferences.All</emxUtil:i18n>
            </td>
          </tr>
          </table>
        </td>
      </tr>
    </table>
    <input type="image" height="1" width="1" border="0" />
  </form>

<%@include file = "emxDesignBottomInclude.inc"%>
<%@include file = "emxEngrVisiblePageButtomInclude.inc"%>
<%@include file = "../emxUICommonEndOfPageInclude.inc" %>

