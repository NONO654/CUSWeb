<%--  emxTeamFoldersWorksapceDetails.jsp --

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program

   static const char RCSID[] = "$Id: emxTeamFoldersWorkspaceDetails.jsp.rca 1.12 Wed Oct 22 16:05:54 2008 przemek Experimental przemek $";
--%>

<%@include file = "../emxUICommonAppInclude.inc" %>
<%@include file = "emxTeamCommonUtilAppInclude.inc" %>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>

<%
  String objectId           = emxGetParameter(request, "objectId");
  String timeZone           = (String)session.getValue("timeZone");
  String sOwner             = "";
  String sProjectDesc       = "";
  String sProjectOriginated = "";

%>


<%@include file = "../emxUICommonHeaderEndInclude.inc" %>


<%
  BusinessObject boProject  = new BusinessObject(objectId);
  boProject.open(context);
  sOwner              = com.matrixone.apps.common.Person.getDisplayName(context, boProject.getOwner().getName());
  sProjectDesc        = boProject.getDescription();
  sProjectOriginated  = boProject.getCreated();
  boProject.close(context);
%>

<form name="details" method="post">
  <table border="0" cellpadding="5" cellspacing="2" width="100%">
    <tr>
      <td class="label"><emxUtil:i18n localize="i18nId">emxTeamCentral.Common.Name</emxUtil:i18n></td>
      <td class="field"><%=boProject.getName()%>&nbsp;</td>
    </tr>
    <tr>
        <td class="label"><emxUtil:i18n localize="i18nId">emxTeamCentral.TeamMyViewHome.Owner</emxUtil:i18n></td>
        <td class="field"><%=XSSUtil.encodeForHTML(context, (String)sOwner)%>&nbsp;</td>
    </tr>
    <tr>
      <td class="label"><emxUtil:i18n localize="i18nId">emxTeamCentral.ObjectDetails.Originated</emxUtil:i18n></td>
      <!--//XSSOK-->
      <td class="field"><emxUtil:lzDate displaydate="true" displaytime="true" localize="i18nId" tz='<%=XSSUtil.encodeForHTML(context, timeZone)%>' format='<%=DateFrm %>' ><%=sProjectOriginated%></emxUtil:lzDate>&nbsp;</td>
    </tr>
    <tr>
        <td class="label"><emxUtil:i18n localize="i18nId">emxTeamCentral.Common.Description</emxUtil:i18n></td>
        <td class="field"><%=XSSUtil.encodeForHTML(context, (String)sProjectDesc)%>&nbsp;</td>
    </tr>
  </table>
</form>

<%@include file = "../emxUICommonEndOfPageInclude.inc" %>


