<%-- emxEngrChangeSearchPreProcess.jsp -- adds central specific types to the engineerint types.used in ENCFindChange command as the preprocess jsp.
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@ include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxUIConstantsInclude.inc"%>
<%@ page import = "com.matrixone.apps.domain.util.*,java.text.*" %>
<%
boolean isPUEInstalled = FrameworkUtil.isSuiteRegistered(context,"appVersionEngineeringConfigurationCentral",false,null,null);
String searchTypes = (String)FrameworkProperties.getProperty(context, "eServiceEngineeringCentral.ChangeTypes");
boolean isMBOMInstalled = FrameworkUtil.isSuiteRegistered(context,"appVersionX-BOMManufacturing",false,null,null);
String strMFGSearchTypes = (String)FrameworkProperties.getProperty(context, "eServiceEngineeringCentral.MFGChangeTypes");
String strURLParam = emxGetParameter(request,"searchMode");
String strDefaultName=XSSUtil.encodeForJavaScript(context,emxGetParameter(request,"default"));
String strTxtTextSearch=XSSUtil.encodeForJavaScript(context,emxGetParameter(request,"txtTextSearch"));
//MFG
/* if(("MFG").equals(strURLParam))
{
	searchTypes = strMFGSearchTypes+":Policy!=policy_MCO,policy_SourcingECR";
} */
//IR-009058: check if VPLM type exists
String VPLMtyp = PropertyUtil.getSchemaProperty(context, "type_PLMActionBase");
if(isMBOMInstalled && (("MFG").equals(strURLParam))){
    searchTypes = searchTypes + ",type_MCO,type_MECO";
}
if(isPUEInstalled && !(("MFG").equals(strURLParam)))
{
      
    searchTypes = searchTypes + ",type_PUEECO";
}
//IR-009058: add type VPLMtyp/PLMActionBase in find Change if VPLM is installed
if(VPLMtyp!=null && !VPLMtyp.equals("") && !(("MFG").equals(strURLParam)))
{
      
    searchTypes = searchTypes + ",type_PLMActionBase";
}
searchTypes = XSSUtil.encodeForURL(context,searchTypes);
if(isMBOMInstalled && ("MFG").equals(strURLParam))
{
	searchTypes = searchTypes+"&excludeOIDprogram=emxMBOMFullSearch:excludeOIDECR";
}
%>

<script language="Javascript">
	//XSSOK
   sURL = "../common/emxFullSearch.jsp?field=TYPES=<%=searchTypes %>&showInitialResults=true&table=ENCGeneralSearchResult&selection=multiple&hideHeader=true&freezePane=ActiveECRECO,Name&toolbar=ENCFullSearchToolbar&HelpMarker=emxhelpfullsearch&default=<%=strDefaultName%>&txtTextSearch=<%=strTxtTextSearch%>&suiteKey=EngineeringCentral&SuiteDirectory=engineeringcentral&targetLocation=windowshade";  
   window.location.href = sURL;
</script>
