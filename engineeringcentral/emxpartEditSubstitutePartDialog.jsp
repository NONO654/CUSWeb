<%--  emxpartEditSubstitutePartDialog.jsp   - Dialog page to take input for editing a Part.
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@include file = "emxDesignTopInclude.inc"%>
<%@include file = "emxEngrVisiblePageInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%@include file = "../emxJSValidation.inc" %>
<%@include file = "emxengchgJavaScript.js" %>
<head>
  <%@include file = "../common/emxUIConstantsInclude.inc"%>
  <script language="javascript" type="text/javascript" src="../common/scripts/emxUICalendar.js"></script>
</head>
<%
  String languageStr = request.getHeader("Accept-Language");
  String jsTreeID = emxGetParameter(request,"jsTreeID");
  String objectId = emxGetParameter(request,"objectId");
  //Getting EBOM Substitute relationship id from the request
  String relId = emxGetParameter(request,"relId");
%>

<script language="Javascript" >

  function isEmpty(s)
  {
    return ((s == null)||(s.length == 0))
  }

  function cancelMethod()
  {
     parent.closeWindow();
  }

  function doneMethod()
  {
     //validate that all required fields are entered
     var qtyvalue =  jsTrim(document.tempForm.Quantity.value);

     if(isEmpty(qtyvalue))
     {
       alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.BuildEBOM.Quantityfieldisemptypleaseenteranumber</emxUtil:i18nScript>");
       document.tempForm.Quantity.focus();
       return;
     }
     if(!isNumeric(qtyvalue))
     {
       alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Common.QuantityHasToBeANumber</emxUtil:i18nScript>");
       document.tempForm.Quantity.focus();
       return;
     }
     if((qtyvalue).substr(0,1) == '-')
     {
       alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Common.QuantityHasToBeAPositiveNumber</emxUtil:i18nScript>");
       document.tempForm.Quantity.focus();
       return;
     }
     if(qtyvalue== 0)
     {
       alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Common.QuantityHasToBeGreaterThanZero</emxUtil:i18nScript>");
       document.tempForm.Quantity.focus();
       return;
     }
     document.tempForm.submit();
  }
</script>

<%@include file = "../emxUICommonHeaderEndInclude.inc" %>
<%
  String sRefDes = PropertyUtil.getSchemaProperty(context,"attribute_ReferenceDesignator");
  String sFindNumber = PropertyUtil.getSchemaProperty(context,"attribute_FindNumber");
  String sQuantity = PropertyUtil.getSchemaProperty(context,"attribute_Quantity");
  SelectList sPartSelStmts = new SelectList(7);
  sPartSelStmts.addName();
  sPartSelStmts.addRevision();
  DomainObject dmObj = DomainObject.newInstance(context,objectId);
  Map objMap = dmObj.getInfo(context, (StringList)sPartSelStmts);
  DomainRelationship domrel = new DomainRelationship(relId);
  java.util.Map attMap = domrel.getAttributeMap(context);
  String sRefDesValue = (String)attMap.get(sRefDes);
  String sFindNumberValue = (String)attMap.get(sFindNumber);
  String sQuantityValue = (String)attMap.get(sQuantity);
  String detailPage = "emxpartEditPartDialogFS.jsp";
  String editURL = "emxpartEditSubstitutePartProcess.jsp?objectId=" + objectId;
  editURL += "&relId=" + relId;
  String sAttrRefDes = "attribute["+sRefDes+"]";
  String sAttrFindNumber = "attribute["+sFindNumber+"]";
  String sAttrQuantity = "attribute["+sQuantity+"]";
  String name = (String)objMap.get(DomainConstants.SELECT_NAME);
%>
<!-- XSSOK -->
<form name="tempForm" method="post" action="<xss:encodeForURL><%=editURL%></xss:encodeForURL>" onSubmit="javascript:doneMethod(); return false">
<table border="0" width="100%" cellpadding="5" cellspacing="2">
  <tr>
    <td class="label"><emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.Part</emxUtil:i18n></td>
    <!-- XSSOK -->
    <td class="field"><%=objMap.get(DomainConstants.SELECT_NAME)%>&nbsp;<emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.Rev</emxUtil:i18n>&nbsp;<%=objMap.get(DomainConstants.SELECT_REVISION)%></td>
  </tr>
  <tr>
    <td class="label"><emxUtil:i18n localize="i18nId">emxEngineeringCentral.BuildEBOM.FindNumber</emxUtil:i18n></td>
    <td class="field"><xss:encodeForHTML><%=sFindNumberValue%></xss:encodeForHTML></td>
  </tr>
  <tr>
    <td class="label"><emxUtil:i18n localize="i18nId">emxEngineeringCentral.BuildEBOM.ReferenceDesignator</emxUtil:i18n></td>
  
   <td class="field"><xss:encodeForHTML><%=sRefDesValue%></xss:encodeForHTML></td>
  </tr>
  <tr>
    <td class="labelRequired"><emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.Quantity</emxUtil:i18n></td>
    <td class="inputField"><input name="Quantity" value="<xss:encodeForHTMLAttribute><%=sQuantityValue%></xss:encodeForHTMLAttribute>" ></input></td>
  </tr>
</table>
  <input type="image" name="inputImage" height="1" width="1" src="../common/images/utilSpacer.gif" hidefocus="hidefocus" 
style="-moz-user-focus: none" />

</form>

<%
   objMap = null;
%>

<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
