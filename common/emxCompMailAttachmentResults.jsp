<%-- emxCompMailAttachmentResults.jsp --

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxCompMailAttachmentResults.jsp.rca 1.7 Wed Oct 22 15:48:24 2008 przemek Experimental przemek $
--%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxCompCommonUtilAppInclude.inc"%>

<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<script language="javascript">
  function submitform() {
    var checkedFlag = "false";
    var isCheckboxPresent = "false";
    // force to select atleast one member to add
    for (var varj = 0; varj < document.templateresults.elements.length; varj++) {
      if (document.templateresults.elements[varj].type == "checkbox") {
        isCheckboxPresent = "true";
        if (document.templateresults.elements[varj].checked){
          checkedFlag = "true";
          break;
        }
      }
    }

    if ((checkedFlag == "false") && (isCheckboxPresent == "true")) {
      alert("<emxUtil:i18nScript localize='i18nId'>emxFramework.IconMail.FindResults.AlertMsg1</emxUtil:i18nScript>");
      return;
    } else {
      document.templateresults.action="emxCompMailAttach.jsp";
      document.templateresults.submit();
      parent.window.closeWindow();
    }
  }

  function closeWindow() {
    parent.window.closeWindow();
    return;
  }
</script>
<%@include file = "../emxUICommonHeaderEndInclude.inc" %>

<%
  String sType = emxGetParameter(request,"txtType");
  String sName = emxGetParameter(request,"txtName");
  String sRevision = emxGetParameter(request,"txtRevision");

  String sAll = "*";

  boolean isFound = false;

  sType = sType.trim();
  sName = sName.trim();
  sRevision = sRevision.trim();

  matrix.db.Query qryGeneric    = new matrix.db.Query();

  qryGeneric.create(context);

  //set the Type where clause

  qryGeneric.setBusinessObjectType(sType);
  qryGeneric.setBusinessObjectName(sName);
  qryGeneric.setBusinessObjectRevision(sRevision);
//  qryGeneric.setOwnerPattern(sOwner);
  //set the vault where clause
  qryGeneric.setVaultPattern("*");

  BusinessObjectList boListGeneric = qryGeneric.evaluate(context);
  qryGeneric.close(context);

  String classname = "odd";
%>

<form name="templateresults" id="templateresults" method="post" onSubmit="return false">
  <table border="0" cellpadding="3" cellspacing="2" width="100%">
    <tr>
      <th width="5%" style="text-align:center">&nbsp;</th>
      <th><emxUtil:i18n localize="i18nId">emxFramework.IconMail.Common.Name</emxUtil:i18n></th>
      <th><emxUtil:i18n localize="i18nId">emxFramework.IconMail.Common.Rev</emxUtil:i18n></th>
    </tr>
<%
    if(boListGeneric.size()==0){
%>
      <tr class="odd">
        <td class="noresult" colspan="4"><emxUtil:i18n localize="i18nId">emxFramework.IconMail.Common.NoObjectsFound</emxUtil:i18n></td>
      </tr>

<%
      return;
    }

    String sObjId = "";
    String sObjType = "";
    String sObjName = "";
    String sObjRevision = "";
    BusinessObject boGeneric = null;
    BusinessObjectItr boItrGeneric = new BusinessObjectItr(boListGeneric);
    while (boItrGeneric.next()) {
      boGeneric = boItrGeneric.obj();
      boGeneric.open(context);
      sObjId = boGeneric.getObjectId();
      sObjName = boGeneric.getName();
      sObjType = boGeneric.getObjectId();
      sObjRevision = boGeneric.getRevision();
//      byte bIcon[] = boGeneric.getIcon();
      boGeneric.close(context);
%>
      <!-- //XSSOK -->
      <tr class="<%=classname%>">
        <td><input type="checkbox" name ="chkList" id="chkList" value = "<%=XSSUtil.encodeForHTMLAttribute(context, sObjId)%>" /></td>
        <td><%=XSSUtil.encodeForHTML(context, sObjName)%>&nbsp;</td>
        <td><%=XSSUtil.encodeForHTML(context, sObjRevision)%>&nbsp;</td>
      </tr>
<%
      if(classname == "odd")
        classname = "even";
      else
        classname = "odd";
    }
%>
  </table>
</form>
<%
  // ----- Common Page End Include  -------
%>
<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
