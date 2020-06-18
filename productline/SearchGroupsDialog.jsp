<%--  SearchGroupsDialog.jsp - The basics page for Person Search

      Copyright (c) 1999-2018 Dassault Systemes. All Rights Reserved.
      This program contains proprietary and trade secret information of MatrixOne, Inc.
      Copyright notice is precautionary only and does not evidence any actual or intended
      publication of such program

   static const char RCSID[] = $Id: /ENOProductLine/CNext/webroot/productline/SearchGroupsDialog.jsp 1.3.2.1.1.1 Wed Oct 29 22:17:06 2008 GMT przemek Experimental$
--%>

<%@include file = "emxDesignTopInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%
  String strFieldNameDisplay = emxGetParameter(request,"fieldNameDisplay");
  String strFieldNameActual = emxGetParameter(request,"fieldNameActual");
  String languageStr    = request.getHeader("Accept-Language");
  String strParentForm = emxGetParameter(request,"formName");
  String strParentFrame = emxGetParameter(request,"frameName");
  String parentGroup = emxGetParameter(request,"parentGroup");
  if (parentGroup == null || parentGroup.equals("null") || parentGroup.equals("")){
      parentGroup = "";
  }
  parentGroup = parentGroup.trim();
  String sTopChecked      = emxGetParameter(request,"chkTopLevel");
  String sSubChecked      = emxGetParameter(request,"chkSubLevel");
  String actionString     = "SearchGroupsResultsFS.jsp";

%>

<script language="javascript">
     addStyleSheet("emxUIMenu");
</script>

<script language="Javascript">

  function doSearch() {

    if(document.grpSearch.txtName.value == "" )
    {
       alert("<emxUtil:i18nScript localize="i18nId">emxProduct.Alert.PleaseEnterDetails</emxUtil:i18nScript>");
    }
    else
	{
		if (jsDblClick()) {
					document.grpSearch.submit();
				} 
	 } 
	 return;
  }

  function ClearSearch() {
    document.grpSearch.txtName.value = "*";
  }

</script>

<%@include file = "../emxUICommonHeaderEndInclude.inc" %>

<form name="grpSearch" method="post" action=<xss:encodeForHTMLAttribute><%=actionString%></xss:encodeForHTMLAttribute> target="_parent" onSubmit="doSearch(); return false">

  <table border="0" cellpadding="5" cellspacing="2" width="530">
    <tr>
      <td class="label">
        <emxUtil:i18n localize="i18nId">emxProduct.Form.Label.Type</emxUtil:i18n>
      </td>
      <td class="inputField"><img src="../common/images/iconSmallGroup.gif" alt="" name="group" border="0"/>
        &nbsp;<emxUtil:i18n localize="i18nId">emxProduct.Common.Group</emxUtil:i18n>
      </td>
    </tr>

<%
      if (!(parentGroup.equals("")))
      {
%>
    <tr>
      <td class="label">
      <emxUtil:i18n localize="i18nId">emxProduct.Form.Label.ParentName</emxUtil:i18n>
      </td>
      <td class="inputField"><%=XSSUtil.encodeForHTML(context,i18nNow.getAdminI18NString("Group",parentGroup,languageStr))%></td>
    </tr>
<%
      }
%>
    <tr>
      <td class="label">
        <emxUtil:i18n localize="i18nId">emxProduct.Form.Label.Name</emxUtil:i18n>
      </td>
      <td class="inputField">
        <input type="text" name="txtName" id="txtName" value="*"/>
      </td>
    </tr>
<%
   if (parentGroup.equals(""))
   {
%>
    <tr>
      <td class="label">
        <emxUtil:i18n localize="i18nId">emxProduct.Form.Label.Level</emxUtil:i18n>
      </td>
      <td class="inputField">
        <table>
          <tr><td>
            <input type="checkbox" name="chkTopLevel" id="chkTopLevel" value="" <xss:encodeForHTMLAttribute><%=sTopChecked%></xss:encodeForHTMLAttribute> /><emxUtil:i18n localize="i18nId">emxProduct.Form.Label.TopLevel</emxUtil:i18n>
          </td></tr>
          <tr><td>
            <input type="checkbox" name="chkSubLevel" id="chkSubLevel" value=""  <xss:encodeForHTMLAttribute><%=sSubChecked%></xss:encodeForHTMLAttribute> /><emxUtil:i18n localize="i18nId">emxProduct.Form.Label.SubLevel</emxUtil:i18n>
          </td></tr>
        </table>
      </td>
    </tr>
<%
      }
%>

</table>
<input type="hidden" name="parentGroup" value="<xss:encodeForHTMLAttribute><%=parentGroup%></xss:encodeForHTMLAttribute>">
<input type="hidden" name="formName" value="<xss:encodeForHTMLAttribute><%=strParentForm%></xss:encodeForHTMLAttribute>">
<input type="hidden" name="frameName" value="<xss:encodeForHTMLAttribute><%=strParentFrame%></xss:encodeForHTMLAttribute>">
<input type="hidden" name="fieldNameDisplay" value="<xss:encodeForHTMLAttribute><%=strFieldNameDisplay%></xss:encodeForHTMLAttribute>">
<input type="hidden" name="fieldNameActual" value="<xss:encodeForHTMLAttribute><%=strFieldNameActual%></xss:encodeForHTMLAttribute>">
<input type="image" name="inputImage" height="1" width="1" src="../common/images/utilSpacer.gif" hidefocus="hidefocus" style="-moz-user-focus: none" />
</form>

<%@include file = "emxDesignBottomInclude.inc" %>
<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
