<%--  emxComponentsSpecifyShareTypes.jsp   -
   Copyright (c) 1992-2018 Dassault Systemes.All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxComponentsSpecifyShareTypes.jsp.rca 1.10 Wed Oct 22 16:18:19 2008 przemek Experimental przemek $
--%>

<%@include file = "emxComponentsDesignTopInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%@include file = "emxComponentsVisiblePageInclude.inc"%>
<%@include file = "../emxTagLibInclude.inc"%>

<%

  String languageStr              = request.getHeader("Accept-Language");
  String objectId                 = emxGetParameter(request,"objectId");
  String selectedIds              = emxGetParameter(request,"selectedIds");
  String jsTreeID                 = emxGetParameter(request,"jsTreeID");
  String initSource               = emxGetParameter(request,"initSource");
  String suiteKey                 = emxGetParameter(request,"suiteKey");

  String strShareTypeSelect       = DomainConstants.ATTRIBUTE_SHARE_TYPES;

  String shareTypes = "";
  boolean isShareTypesAvailable = false;
    i18nNow i18nnow = new i18nNow();
String strShareType = EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource", context.getLocale(), "emxComponents.CollaborationPartners.ShareTypes");
  shareTypes = JSPUtil.getCentralProperty(application, session,"emxEngineeringCentral","ShareTypes");
  if (shareTypes == null)
  {
    shareTypes = "";
  }
  else if (!"".equals(shareTypes))
  {
    isShareTypesAvailable = true;
  }

  // creating the select list
  StringList selectStmts = new StringList(4);
  selectStmts.addElement(DomainObject.SELECT_ID);
  selectStmts.addElement(DomainObject.SELECT_NAME);
  selectStmts.addElement(Organization.SELECT_ORGANIZATION_PHONE_NUMBER);
  selectStmts.addElement(Organization.SELECT_WEB_SITE);

  // Tokenizing the object ids selected in the results page to get the object info
  StringTokenizer stringtokenizer = new StringTokenizer(selectedIds, ",");
  int tokenNumber=stringtokenizer.countTokens();
  String objectIds[]=new String[tokenNumber];
  for(int token=0;token<tokenNumber;token++)
  {
    objectIds[token]=stringtokenizer.nextToken();
  }
  // to get the details of the organization selected in the results page
  MapList attributeDetailsList = DomainObject.getInfo(context,objectIds,selectStmts);
%>

<script language="JavaScript" type="text/javascript" >
  function createCollaborationRequests()
  {
    document.formDataRows.action = "emxComponentsCreateCompanyCollaborationRequest.jsp";
    document.formDataRows.submit();
  }
</script>

<%@include file = "../emxUICommonHeaderEndInclude.inc" %>

<%
    //tokenizing the values to get an array for the attribute values of Share Types
    String tokenValue="";
    StringTokenizer stringtokenizerShareType = new StringTokenizer(shareTypes, ",");
    int tokenCount = stringtokenizerShareType.countTokens();
    String tokens[]=new String[tokenCount];
%>

<form name = "formDataRows" method="post" action="" target="_top">
<table class="list" width="100%" border="0" cellspacing="1" cellpadding="1">
  <tr>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td colspan="<%=tokenCount%>">
    <table class="list" border="0" cellspacing="0" cellpadding="0" width="100%">
      <tr>
        <!-- <th class="groupheader" colspan="<%=tokenCount%>"><%=i18nNow.getTypeI18NString(strShareTypeSelect,languageStr)%></th>-->
    <th class="groupheader" colspan="<%=tokenCount%>"><%=XSSUtil.encodeForHTML(context, strShareType)%></th>
      </tr>
    </table>
    </td>
  </tr>
  <tr>
    <th>
        <emxUtil:i18n localize="i18nId">emxComponents.Common.Name</emxUtil:i18n>
    </th>
    <th>
        <emxUtil:i18n localize="i18nId">emxComponents.Table.Phone</emxUtil:i18n>
    </th>
    <th>
        <emxUtil:i18n localize="i18nId">emxComponents.Table.WebSite</emxUtil:i18n>
    </th>
    <td class="separator" width="1" style="background-color:white">&nbsp;</td>
<%
    for(int token=0;token<tokenCount;token++)
    {
      tokenValue=stringtokenizerShareType.nextToken();
      tokens[token]=tokenValue;
%>
      <th>
        <%=XSSUtil.encodeForHTML(context, i18nNow.getTypeI18NString(PropertyUtil.getSchemaProperty(context, tokenValue),languageStr))%>
      </th>
<%
    }

    if(!isShareTypesAvailable)
    {
%>
      <th>&nbsp;</th>
<%
    }
%>
  </tr>

  <fw:mapListItr mapList="<%= attributeDetailsList %>" mapName="companyMap">
      <tr class='<fw:swap id="1"/>'>
<%
      String treeUrl         = "../common/emxTree.jsp?objectId="+XSSUtil.encodeForURL(context, (String)companyMap.get(DomainObject.SELECT_ID));
%>
      <td wrap="hard">
        <!-- //XSSOK -->
		<a href="javascript:emxShowModalDialog('<%=treeUrl%>')" ><img src="../common/images/iconCompany16.png" border="0" align="middle"/></a>
        <!-- //XSSOK -->
		<a href="javascript:emxShowModalDialog('<%=treeUrl%>')" ><%=XSSUtil.encodeForHTML(context, (String)companyMap.get(DomainObject.SELECT_NAME))%></a>
      </td>
      <td wrap="hard"><%=XSSUtil.encodeForHTML(context, (String)companyMap.get(Organization.SELECT_ORGANIZATION_PHONE_NUMBER))%>&nbsp;</td>
      <td wrap="hard"><a target="_blank" href="<%=XSSUtil.encodeForHTMLAttribute(context, (String)companyMap.get(Organization.SELECT_WEB_SITE)) %>"><%=XSSUtil.encodeForHTML(context, (String)companyMap.get(Organization.SELECT_WEB_SITE))%>&nbsp;</td>
      <td class="separator" width="1" style="background-color:white">&nbsp;</td>
<%
      // show the values of the Share Types as the value of the checkbox
      for(int yy=0;yy<tokens.length;yy++)
      {
%>
      <td><input type="checkbox" name="<%=XSSUtil.encodeForHTMLAttribute(context, (String)companyMap.get(DomainObject.SELECT_ID))%>" value="<%=tokens[yy]%>"/></td>
<%
      }
      if(!isShareTypesAvailable)
      {
%>
        <td><emxUtil:i18n localize="i18nId">emxComponents.EditShareTypes.NoShareTypes</emxUtil:i18n></td>
<%
      }
%>
      </tr>
    </fw:mapListItr>
    </table>

    <input type="hidden" name="selectedIds" value="<xss:encodeForHTMLAttribute><%=selectedIds%></xss:encodeForHTMLAttribute>"/>
    <input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=objectId%></xss:encodeForHTMLAttribute>"/>
    <input type="hidden" name="jsTreeID" value="<xss:encodeForHTMLAttribute><%=jsTreeID%></xss:encodeForHTMLAttribute>"/>
    <input type="hidden" name="initSource" value="<xss:encodeForHTMLAttribute><%=initSource%></xss:encodeForHTMLAttribute>"/>
    <input type="hidden" name="suiteKey" value="<xss:encodeForHTMLAttribute><%=suiteKey%></xss:encodeForHTMLAttribute>"/>

</form>

<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
