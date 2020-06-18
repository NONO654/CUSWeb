<%--  emxTeamSearchWorkSpaceMembersDialog.jsp   -  Search for members in the company
Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxTeamSearchWorkspaceMembersDialog.jsp.rca 1.16 Wed Oct 22 16:06:32 2008 przemek Experimental przemek $
--%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxTeamCommonUtilAppInclude.inc"%>
<%@include file = "emxTeamProfileUtil.inc"%>
<%@include file = "emxTeamUtil.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%
  String sProjectId        = emxGetParameter(request,"projectId");
  String sRouteId          = emxGetParameter(request, "routeId");
  String chkSubscribeEvent = emxGetParameter(request, "chkSubscribeEvent");
  String objectId          = emxGetParameter(request, "objectId");
  String flag              = emxGetParameter(request, "flag");
  String languageStr       = request.getHeader("Accept-Language");
  String sfromPage         = emxGetParameter(request,"fromPage");
  //DomainObject workspaceObject=DomainObject.newInstance(context,sProjectId);
 %>

<script language="javascript">

  function doSearch() {

    if(document.createDialog.lastName.value=="") {
      alert("<emxUtil:i18nScript localize="i18nId">emxTeamCentral.WorkSpaceAddMembersDialog.LastNameRequired</emxUtil:i18nScript>");
      document.createDialog.projectName.focus();
      return;
    } else if(document.createDialog.firstName.value=="") {
      alert("<emxUtil:i18nScript localize="i18nId">emxTeamCentral.WorkSpaceAddMembersDialog.FirstNameRequired</emxUtil:i18nScript>");
      document.createDialog.firstName.focus();
      return;
    }else if(document.createDialog.company.value=="") {
      alert("<emxUtil:i18nScript localize="i18nId">emxTeamCentral.WorkSpaceAddMembersDialog.CompanyNameRequired</emxUtil:i18nScript>");
      document.createDialog.company.focus();
      return;
    }else if(document.createDialog.userName.value=="") {
      alert("<emxUtil:i18nScript localize="i18nId">emxTeamCentral.WorkSpaceAddMembersDialog.UserNameRequired</emxUtil:i18nScript>");
      document.createDialog.userName.focus();
      return;
    }else {
      document.createDialog.submit();
      return;
    }
  }
  function closeWindow() {
      parent.window.closeWindow();
      return;
  }
</script>

<%@include file = "../emxUICommonHeaderEndInclude.inc" %>


<form name="createDialog" method="post" onSubmit="return false" target="_parent" action="emxTeamSelectWorkspaceMembersDialogFS.jsp">
  <input type="hidden" name="projectId" value="<%=XSSUtil.encodeForHTMLAttribute(context,sProjectId)%>" />
  <input type="hidden" name="routeId" value="<%=XSSUtil.encodeForHTMLAttribute(context,sRouteId)%>" />
  <input type="hidden" name="flag" value="<%=XSSUtil.encodeForHTMLAttribute(context,flag)%>" />
  <input type="hidden" name="chkSubscribeEvent" value="<%=XSSUtil.encodeForHTMLAttribute(context,chkSubscribeEvent)%>" />
  <input type="hidden" name="objectId" value="<%=XSSUtil.encodeForHTMLAttribute(context,objectId)%>" />
  <input type="hidden" name="fromPage" value="<%=XSSUtil.encodeForHTMLAttribute(context,sfromPage)%>"/>
  <input type="hidden" name="searchFlag" value="searchDialog"/>

  <table border="0" cellpadding="5" cellspacing="2" width="100%">
    <tr>
      <td width="150" class="label"><label for="Type"><emxUtil:i18n localize="i18nId">emxTeamCentral.WorkSpaceAddMembersDialog.Type</emxUtil:i18n></label></td>
      <td class="inputField"><img src="images/iconSmallPerson.gif" border="0"name="imgPerson" id="imgPerson" alt="<emxUtil:i18n localize='i18nId'>emxTeamCentral.WorkSpaceAddMembersDialog.Person</emxUtil:i18n>" /><emxUtil:i18n localize="i18nId">emxTeamCentral.WorkSpaceAddMembersDialog.Person</emxUtil:i18n></td>
    </tr>
    <tr>
      <td class="label"><label for="UserName"><emxUtil:i18n localize="i18nId">emxTeamCentral.WorkSpaceAddMembersDialog.UserName</emxUtil:i18n></label></td>
      <td class="inputField"><input type="Text" name="userName" value="*" size="20" /></td>
    </tr>
    <tr>
      <td class="label"><label for="LastName"><emxUtil:i18n localize="i18nId">emxTeamCentral.WorkSpaceAddMembersDialog.LastName</emxUtil:i18n></label></td>
      <td class="inputField"><input type="Text" name="lastName" value="*" size="20" /></td>
    </tr>
    <tr>
      <td class="label"><label for="FirstName"><emxUtil:i18n localize="i18nId">emxTeamCentral.WorkSpaceAddMembersDialog.FirstName</emxUtil:i18n></label></td>
      <td class="inputField"><input type="Text" name="firstName" value="*" size="20" /></td>
    </tr>
    <tr>
      <td class="label"><label for="Company"><emxUtil:i18n localize="i18nId">emxTeamCentral.WorkSpaceAddMembersDialog.Company</emxUtil:i18n></label></td>
      <td class="inputField"><input type="Text" name="company" value="*" size="20" /></td>
    </tr>
  </table>
</form>

<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
