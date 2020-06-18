<%-- emxRouteWizardSearchTemplateDialog.jsp --

  Copyright (c) 1992-2018 Dassault Systemes.All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxRouteWizardSearchTemplateDialog.jsp.rca 1.15 Wed Oct 22 16:17:54 2008 przemek Experimental przemek $
--%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxRouteInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>

<script language="javascript">
  function doSearch() {
   //added for the   form  not to submitted more than once
    if (!jsDblClick()) {
    return;
  }
    if ( document.searchtemplate.txtName.value == "" || document.searchtemplate.txtName.value == null ) {
      alert("<emxUtil:i18nScript  localize="i18nId">emxComponents.SearchTemplate.EnterName</emxUtil:i18nScript>");
      document.searchtemplate.txtName.focus();
      return;
    } else {
        startSearchProgressBar();
        document.searchtemplate.submit();
        return;
    }
  }

  function closeWindow() {
    window.closeWindow();
    return;
  }

</script>

<%@include file = "../emxUICommonHeaderEndInclude.inc" %>

<%
  // get the route object
  String typeRouteTemplate = PropertyUtil.getSchemaProperty(context, "type_RouteTemplate");
  String languageStr       = request.getHeader("Accept-Language");

  String sUser       = i18nNow.getI18nString("emxComponents.Common.User", "emxComponentsStringResource",languageStr);
  String sEnterprise = i18nNow.getI18nString("emxComponents.Common.Enterprise", "emxComponentsStringResource", languageStr);
  String sWorkspace = i18nNow.getI18nString("emxComponents.Common.Workspace","emxComponentsStringResource", languageStr);
  String sProjectspace = i18nNow.getI18nString("emxComponents.Common.Projectspace","emxComponentsStringResource", languageStr);
 
  String sAll        = "*";
  String sName           = emxGetParameter(request,"txtName");
  String sScope          = emxGetParameter(request,"selscope");
  String scopeId   = emxGetParameter(request,"scopeId");
  //only used when searching for template for items in a workspace
  String workspaceId   = emxGetParameter(request,"workspaceId");
  String relatedObjectId   = emxGetParameter(request,"objectId");
  //added for 320802
  String parentForm       = emxGetParameter(request,"form");
  String parentField      = emxGetParameter(request,"field");
  String parentFieldDisp  = emxGetParameter(request,"fieldDisp");
  String parentFieldObjId  = emxGetParameter(request,"fieldDispObjId");
  //320802

  String supplierOrgId = emxGetParameter(request,"supplierOrgId");
  //Prepare the proper contentUrl with all the required parameters

  if (sName==null) {
    sName = "*";
  }

%>

<form name="searchtemplate" id="searchtemplate" method="post" onSubmit="javascript:doSearch(); return false" target="_parent" action="../common/emxTable.jsp">
<input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=relatedObjectId%></xss:encodeForHTMLAttribute>" />
  <table border="0" cellpadding="5" cellspacing="2" width="530">
    <tr>
      <td class="label">
        <emxUtil:i18n localize="i18nId">emxComponents.SearchTemplate.Type</emxUtil:i18n>
      </td>
      <td class="inputField"><img src="../common/images/iconSmallRouteTemplate.gif" alt="" name="route" id="route" border="0"/>&nbsp;<%=i18nNow.getTypeI18NString(typeRouteTemplate,languageStr)%></td>
    </tr>
    <tr>
      <td class="label">
        <emxUtil:i18n localize="i18nId">emxComponents.Common.Name</emxUtil:i18n>
      </td>
      <td class="inputField">
        <input type="text" name="txtName" id="txtName" value="<%=XSSUtil.encodeForHTMLAttribute(context,sName)%>"/>
        <input type="hidden" name="supplierOrgId" value="<%=XSSUtil.encodeForHTMLAttribute(context,emxGetParameter(request,"supplierOrgId"))%>" />
      </td>
    </tr>
    <tr>
      <td class="label">
        <emxUtil:i18n localize="i18nId">emxComponents.SearchTemplate.Availability</emxUtil:i18n>
      </td>
      <td class="inputField">
        <select name="selScope">
        <!-- //XSSOK -->
          <option value="<%=sAll%>"><%=sAll%></option>
          <option value="Enterprise"><%=sEnterprise%></option>
          <option value="User"><%=sUser%></option>

<%    //to fix bug# 280873 - start
      boolean bTeam = FrameworkUtil.isSuiteRegistered(context,"featureVersionTeamCentral",false,null,null);
      if(bTeam)
      {
%>
          <option value="Workspace"><%=sWorkspace%></option>
 <%
        }   //to fix bug# 280873 - end
%>

<%    //to fix bug# 282270 - start
      boolean bProgram = FrameworkUtil.isSuiteRegistered(context,"appVersionProgramCentral",false,null,null);
      if(bProgram)
      {
%>
        <option value="Project Space"><%=sProjectspace%></option>
 <%
        }   //to fix bug# 282270 - end
%>
        </select>
      </td>
    </tr>
  </table>
  &nbsp;

   <input type="hidden" name="table" value="RouteTemplateSummary" />
   <input type="hidden" name="selection" value="single" />
   <input type="hidden" name="header" value="emxComponents.SearchTemplate.SelectTemplate" />
   <input type="hidden" name="sortColumnName" value="Name" />
   <input type="hidden" name="sortDirection" value="ascending" />
   <input type="hidden" name="program" value="emxRouteTemplate:getAllSearchRouteTemplates" />
   <input type="hidden" name="suiteKey" value="Components" />
   <input type="hidden" name="languageStr" value="<%=XSSUtil.encodeForHTMLAttribute(context,languageStr)%>" />
   <input type="hidden" name="vault" value="<%=XSSUtil.encodeForHTMLAttribute(context,JSPUtil.getVault(context,session))%>" />
   <input type="hidden" name="CancelButton" value="true" />
   <input type=hidden name="SubmitURL" value="../components/emxSearchSetRouteTemplate.jsp?form=<%=XSSUtil.encodeForURL(context, parentForm)%> &field=<%=XSSUtil.encodeForURL(context,parentField)%>&fieldDisp=<%=XSSUtil.encodeForURL(context,parentFieldDisp)%>&fieldDispObjId=<%=XSSUtil.encodeForURL(context,parentFieldObjId)%>" />
    <input type="hidden" name="HelpMarker" value="emxhelpselectroutetemplate" />
   <input type="hidden" name="Style" value="Dialog" />
   <input type="hidden" name="CancelLabel" value="emxComponents.Button.Cancel" />
   <input type="hidden" name="TransactionType" value="update" />
   <input type="hidden" name="saveQuery" value="false" />
   <input type="hidden" name="changeQueryLimit" value="true" />
   <input type="hidden" name="Export" value="false" />
   <input type="hidden" name="workspaceId" value="<xss:encodeForHTMLAttribute><%=workspaceId%></xss:encodeForHTMLAttribute>" />
   

</form>
<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
