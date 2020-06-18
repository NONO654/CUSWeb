<%--  emxCompMailAttachmentSummary.jsp   -   Displays the Attached Objects of the mail in a List
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program
   static const char RCSID[] = $Id: emxCompMailAttachmentSummary.jsp.rca 1.21 Wed Oct 22 15:48:03 2008 przemek Experimental przemek $
--%>
<%@ include file="emxNavigatorInclude.inc" %>
<%@include file = "../emxPaginationInclude.inc" %>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<%@ page import="com.matrixone.apps.domain.*,com.matrixone.apps.framework.ui.*"%>

<%
  String sMailId            = emxGetParameter(request, "objId");
  String jsTreeID           = emxGetParameter(request,"jsTreeID");
  String suiteKey           = emxGetParameter(request,"suiteKey");
  String sPrinterFriendly   =emxGetParameter(request, "PrinterFriendly");
%>
  <%@include file = "emxUIConstantsInclude.inc"%>
  <script language="javascript" type="text/javascript" src="scripts/emxUIModal.js"></script>
  <script language="javascript" type="text/javascript" src="scripts/emxUIActionbar.js"></script>
<%@include file = "../emxStyleDefaultInclude.inc"%>
<%@include file = "../emxStyleListInclude.inc"%>
<%@include file = "../emxStyleFormInclude.inc"%>
<%
  //Use only if Not a Dialog Page
  String isDialogPage = emxGetParameter(request,"contentPageIsDialog");
  if (!"true".equalsIgnoreCase(isDialogPage)){
%>
<%@include file = "../emxStylePropertiesInclude.inc"%>
<%
  }
%>

<link rel="stylesheet" href="../emxUITemp.css" type="text/css" />
<%
  if ("true".equals(sPrinterFriendly)){
%>
<link rel="stylesheet" href="../emxUIPF.css" type="text/css" />
<%
  }
%>

<script language="Javascript" >
  function doFilter() {
    document.maillAttach.submit();
  }

  //this function should be in an include file so it can be included in any page
  function openExternalWindow(url) {
    var strFeatures = "width=780,height=500,dependent=yes,resizable=yes";
    var win = window.open(url, "NewWindow", strFeatures);
    return;
  }
  function showFindDialogPopup() {
    emxShowModalDialog('emxCompMailAttachmentSearchDialogFS.jsp', 575, 575);
  }

  function doCheck() {
    var objForm = document.forms[0];
    var chkList = objForm.chkList;
    var reChkName = /chkItem/gi;
    for (var i=0; i < objForm.elements.length; i++)
    if (objForm.elements[i].name.indexOf('chkItem') > -1)
    objForm.elements[i].checked = chkList.checked;
  }
  function updateCheck() {
    var objForm = document.forms[0];
    var chkList = objForm.chkList;
    chkList.checked = false;
  }
function openAttachmentContent(strURL){
	findFrame(getTopWindow(),"content").location.href = strURL;
}

</script>

<%
  // display the attached objects, if any.
  String sColor       = "even";
  IconMail iconMailGeneric = null;


    //String sShowAttachements = propCentralProperties.getProperty("emxComp.ShowAttachments");
  //if (!(sMailId.equals(""))) {
if (!UIUtil.isNullOrEmpty(sMailId)) {
    IconMailItr iconMailItrGeneric = new IconMailItr(IconMail.getMail(context));
    while (iconMailItrGeneric.next()) {
      iconMailGeneric = iconMailItrGeneric.obj();
      long lMailId = iconMailGeneric.getNumber();
      if (sMailId.equals(String.valueOf(lMailId))) {
        break;
      } else {
        iconMailGeneric = null;
      }
    }
  }

  MapList mailList = new MapList();
  String sBusId = "";
  String sName = "";
  String sDescription = "";

  if (iconMailGeneric != null) {
    iconMailGeneric.open(context, new Visuals());
    BusinessObjectList boListMailObjects = iconMailGeneric.getObjects();
    iconMailGeneric.close(context);
    BusinessObjectItr boTempItrMailObjects   = new BusinessObjectItr(boListMailObjects);
    BusinessObject boProj = new BusinessObject();

    HashMap tempMap = new HashMap();
    //Check the no of objects attached


  // pagination change
  if (emxPage.isNewQuery()) {
    if (boListMailObjects.size()>0) {

      while (boTempItrMailObjects.next()) {

        try {
          boProj = boTempItrMailObjects.obj();
          boProj.open(context);
          tempMap = new HashMap();
          tempMap.put(DomainObject.SELECT_ID, boProj.getObjectId());
          tempMap.put(DomainObject.SELECT_NAME, boProj.getName());
          tempMap.put(DomainObject.SELECT_DESCRIPTION, boProj.getDescription(context));
          mailList.add(tempMap);
          boProj.close(context);
        } 
        catch (Exception exp)
        {
          emxNavErrorObject.addMessage(exp.toString().trim());
        }
      }
    }

    emxPage.getTable().setObjects(mailList);
    // this is for sorting the list.  Use it if your want the page to be initialy sorted.
    emxPage.getTable().setDefaultSortValues(DomainObject.SELECT_NAME, "ascending", "string");
  }
  mailList = emxPage.getTable().evaluate(context, emxPage.getCurrentPage());
 }
%>
<!-- //XSSOK -->
<framework:sortInit defaultSortKey="name" defaultSortType="string" mapList="<%= mailList %>" params='' resourceBundle="emxFrameworkStringResource" ascendText="emxFramework.Common.SortAscending" descendText="emxFramework.Common.SortDescending"/>

<form name="maillAttach" method="post"id="">
  <input type="hidden" name="suiteKey" value="<%=XSSUtil.encodeForHTMLAttribute(context, suiteKey)%>"/>
    <table class="list">
      <tr>
        <%if(sPrinterFriendly==null) {%>
        <th width="5%" style="text-align:center">
          <input type="checkbox" name="chkList" id="chkList" onclick="doCheck()" />
        </th>
        <%}%>

        <th>
                <framework:sortColumnHeader
                  title="emxFramework.Common.Name"
                  sortKey="<%=  DomainObject.SELECT_NAME %>"
                  sortType="string"
                  anchorClass="tab"/>
        </th>

        <th>
                <framework:sortColumnHeader
                  title="emxFramework.Common.Description"
                  sortKey="<%=  DomainObject.SELECT_DESCRIPTION %>"
                  sortType="string"
                  anchorClass="tab"/>
        </th>

        <th>&nbsp;</th>
      </tr>
<!-- //XSSOK -->
        <framework:mapListItr mapList="<%= mailList %>" mapName="mailMap">
<%
        sBusId = (String) mailMap.get(DomainObject.SELECT_ID);
        sName = (String) mailMap.get(DomainObject.SELECT_NAME);
        sDescription = (String) mailMap.get(DomainObject.SELECT_DESCRIPTION);
        if (sColor.equals("even")) {
          sColor    = "odd";
        } else {
          sColor    = "even";
        }
%>
        <!-- //XSSOK -->
        <tr class="<%=sColor%>">
               <%if(sPrinterFriendly==null) {%>
                        <td align="center" ><input type="checkbox" name="chkItem1" id="chkItem1" onclick="updateCheck()" /></td>
               <%}%>
          <td>
          <% if (UIUtil.isNullOrEmpty(jsTreeID)) {%>
          	<a href="javascript:openAttachmentContent('emxTree.jsp?objectId=<%=XSSUtil.encodeForURL(context, sBusId)%>')"><%=XSSUtil.encodeForHTML(context, sName)%></a>
          <% } else { %>
            <a href="javascript:getTopWindow().addContextTreeNode('<%=XSSUtil.encodeForJavaScript(context, sBusId)%>','<%=XSSUtil.encodeForJavaScript(context, jsTreeID)%>','common')"><%=XSSUtil.encodeForHTML(context, sName)%></a>
            <%} %>
          </td>
          <td><%=XSSUtil.encodeForHTML(context, sDescription)%></td>
             <%if(sPrinterFriendly==null) {%>
          <td align="center"><a href= "javascript:showModalDialog('emxTree.jsp?objectId=<%=XSSUtil.encodeForURL(context, sBusId)%>', 800, 600);" ><img  border="0" src="images/iconNewWindow.gif" /></a></td>
             <%}%>
        </tr>
        </framework:mapListItr>

<!-- //XSSOK -->
    <framework:ifExpr expr="<%=  mailList.isEmpty() %>">
    <tr class="odd" >
      <td class="noresult" colspan="6" height="50"><emxUtil:i18n localize="i18nId">emxFramework.IconMail.Common.NoObjectsFound</emxUtil:i18n></td>
    </tr>
    </framework:ifExpr>

  </table>
</form>
<%@include file = "emxNavigatorBottomErrorInclude.inc"%>
