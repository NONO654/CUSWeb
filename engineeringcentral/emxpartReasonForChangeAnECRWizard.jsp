<%--  emxpartReasonForChangeAnECRWizard.jsp  -
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>



<%@include file = "emxDesignTopInclude.inc"%>
<%@ include file = "../emxJSValidation.inc" %>
<%@ include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@ include file = "emxengchgJavaScript.js"%>
<%@include file = "emxEngrVisiblePageInclude.inc"%>

<%
   String relatedObjectId = emxGetParameter(request,"objectId");
   String jsTreeID     = emxGetParameter(request,"jsTreeID");
   String objectId     = emxGetParameter(request,"objectId");
   String suiteKey     = emxGetParameter(request,"suiteKey");
   String selectedParts      = (String)session.getAttribute("selectedParts");
  
   String selectedType =emxGetParameter(request,"selectedType");
   String checkedButtonValue=emxGetParameter(request,"checkedButtonValue");
   String checkboxValue=emxGetParameter(request,"checkboxValue");
   String Relationship = emxGetParameter(request,"Relationship");
   String rdoId = emxGetParameter(request,"rdoId");
   String rdoName = emxGetParameter(request,"rdo");
   String policy = emxGetParameter(request,"policy");
   String mode=emxGetParameter(request,"mode");//    IR-068172V6R2012
   String backActionUrl    ="";
   String prevmode  = emxGetParameter(request,"prevmode");//IR-069928V6R2012
   String strReasonForChangeVal=null;
   //Modified for 	IR-069928V6R2012
   if(null!=prevmode && prevmode.equalsIgnoreCase("true"))
   {
   strReasonForChangeVal = (String)session.getAttribute("ReasonForChange_KEY");
     }  
   session.removeAttribute("ReasonForChange_KEY");
   if(strReasonForChangeVal == null){
       strReasonForChangeVal= "";
   }

   String sName = emxGetParameter(request,"Name");
   sName = (((sName == null) || (sName.equalsIgnoreCase("null"))) ? "*" : sName.trim().equals("") ? "*" : sName.trim());
   String sRev = emxGetParameter(request,"Rev");
  String sVault = "eService Production";

  try
  {
  	sVault = JSPUtil.getVault(context, session);
}
catch (Exception ex)
{
	sVault = "eService Production";
}
   String Create = emxGetParameter(request,"Create");

   if(Create==null || "null".equals(Create)) {
      Create="";
   }

   backActionUrl="emxpartRaiseAnECRAssignDetailsFS.jsp?checkedButtonValue="+checkedButtonValue+"&prevmode=true&checkboxValue="+checkboxValue+"suiteKey="+suiteKey;
%>

<script language="javascript">
  function goBack()
  {
	  //XSSOK
    document.createDialog.action="<%=XSSUtil.encodeForJavaScript(context,backActionUrl)%>";
    document.createDialog.submit();
    return;
  }
  function submitForm() {
    if (jsTrim(document.createDialog.reasonForChange.value)=="") {
       alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.RaiseECR.PleaseSelectReasonForChange</emxUtil:i18nScript>");
       document.createDialog.reasonForChange.value=jsTrim(document.createDialog.reasonForChange.value);
       return ;
    } else {

      document.createDialog.submit();
    }
  }

  function cleanUp() {
    document.createDialog.action="emxpartRaiseECRCleanup.jsp";
    document.createDialog.submit();
    return;
  }
</script>

<%@include file = "../emxUICommonHeaderEndInclude.inc" %>

<form name="createDialog" method="post" onSubmit="submitForm()" action="emxpartCreateRaiseECR.jsp" target="_parent">
  <table border="0" cellpadding="3" cellspacing="2" width="100%">
  <tr>
  	<!-- XSSOK -->
    <td class="labelRequired"><%=i18nNow.getAttributeI18NString(DomainObject.ATTRIBUTE_DESCRIPTION_OF_CHANGE,request.getHeader("Accept-Language"))%></td>
    <td class="inputField" align="left"><textarea name="reasonForChange" rows="6" cols="30"><xss:encodeForHTML><%=strReasonForChangeVal%></xss:encodeForHTML></textarea></td>
  </tr>
  </table>
  <input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=objectId%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="Name" value="<xss:encodeForHTMLAttribute><%=sName%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="Rev" value="<xss:encodeForHTMLAttribute><%=sRev%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="Create" value="<xss:encodeForHTMLAttribute><%=Create%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="checkboxValue" value="<xss:encodeForHTMLAttribute><%=checkboxValue%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="prevmode" value="<xss:encodeForHTMLAttribute><%=prevmode%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="selectedType" value="<xss:encodeForHTMLAttribute><%=selectedType%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="jsTreeID" value="<xss:encodeForHTMLAttribute><%=jsTreeID%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="suiteKey" value="<xss:encodeForHTMLAttribute><%=suiteKey%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="Relationship" value="<xss:encodeForHTMLAttribute><%=Relationship%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="RDOId" value="<xss:encodeForHTMLAttribute><%=rdoId%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="RDO" value="<xss:encodeForHTMLAttribute><%=rdoName%></xss:encodeForHTMLAttribute>" />

  <input type="hidden" name="policy" value="<xss:encodeForHTMLAttribute><%=policy%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="checkedButtonValue" value="<xss:encodeForHTMLAttribute><%=checkedButtonValue%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="mode" value="<xss:encodeForHTMLAttribute><%=mode%></xss:encodeForHTMLAttribute>" />
</form>
<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
