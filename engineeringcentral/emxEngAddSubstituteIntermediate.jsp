 <%--  emxEngrFullSearchPreProcess.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>
<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="emxEngrFramesetUtil.inc"%>
<%
  String objectId = XSSUtil.encodeForJavaScript(context,emxGetParameter(request,"objectId"));
  String parentOID = XSSUtil.encodeForJavaScript(context,emxGetParameter(request,"parentOID"));
  String strRegSuite = XSSUtil.encodeForJavaScript(context,emxGetParameter(request, "suiteKey"));

  String contentURL = "../common/emxIndentedTable.jsp?program=emxPart:getBOMStructure&table=ENCEBOMIndentedSummary&selection=single&selectionWizardMultiple=multiple&massPromoteDemote=false&triggerValidation=false&autoFilter=false&customize=false&header=emxEngineeringCentral.Select.SubstitutePart&cancelLabel=emxFramework.Command.Cancel&submitURL=../engineeringcentral/emxEngEBOMAddExistingProcess.jsp&submitWizardURL=../engineeringcentral/emxEngPartCreateSubstitutePartProcess.jsp&hideHeader=false&submitLabel=emxFramework.Command.Done&submitAction=refreshCaller&HelpMarker=emxhelppartsubstitute&objectId="+objectId+"&parentOID="+parentOID+"&suiteKey="+strRegSuite;
%>
<script>
//XSSOK
document.location.href="<%=contentURL%>";
</script>
