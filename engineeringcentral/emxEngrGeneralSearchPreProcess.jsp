<%-- emxEngrGeneralSearchPreProcess.jsp --
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
String strBOMMode ="Resolved";
String searchTypesforUnresolved ="";
String searchTypesforresolved ="";
String policySelectableName="";
String searchTypes = (String)FrameworkProperties.getProperty(context, "eServiceEngineeringCentral.Types");
String strDefaultName=XSSUtil.encodeForJavaScript(context,emxGetParameter(request,"default"));
String strTxtTextSearch=XSSUtil.encodeForJavaScript(context,emxGetParameter(request,"txtTextSearch"));
//added for bug 361504
boolean isMBOMInstalled = FrameworkUtil.isSuiteRegistered(context,"appVersionX-BOMManufacturing",false,null,null);
if(isMBOMInstalled){
    searchTypes = searchTypes + ",type_MCO,type_MECO";
}
/*if(isPUEInstalled)-Commented for the property entry removal for IR-076329V6R2012       
 
{
      strBOMMode = FrameworkProperties.getProperty(context, "emxUnresolvedEBOM.PUE.BOMMode");
      if(strBOMMode.equalsIgnoreCase("Resolved")){
          searchTypesforresolved = (String)FrameworkProperties.getProperty(context, "eServiceEngineeringCentral.Types");
          searchTypes=searchTypesforresolved;
          policySelectableName = ":Policy!="+PropertyUtil.getSchemaProperty(context,"policy_ConfiguredPart");
      }
      //371857, 371858, 371849, begin, no need to support PUE ECO in ENG general search, use the Unresolved EBOM's PUE ECO's search
      //else if(strBOMMode.equalsIgnoreCase("Mixed")){
      //    searchTypesforUnresolved = (String)FrameworkProperties.getProperty(context, "eServiceEngineeringCentral.TypesForUnresolved");
      //    searchTypes += ","+searchTypesforUnresolved;
      //}
      //371857, 371858, 371849, end
}
else{
    policySelectableName = ":Policy!="+PropertyUtil.getSchemaProperty(context,"policy_ConfiguredPart");
}*/
if(!isPUEInstalled){
	policySelectableName = ":Policy!="+PropertyUtil.getSchemaProperty(context,"policy_ConfiguredPart");
}
%>

<script language="Javascript">
//XSSOK
   sURL = "../common/emxFullSearch.jsp?field=TYPES=<%=searchTypes + policySelectableName%>&showInitialResults=true&table=ENCGeneralSearchResult&selection=multiple&hideHeader=true&freezePane=ActiveECRECO,Name&toolbar=ENCFullSearchToolbar&HelpMarker=emxhelpfullsearch&suiteKey=EngineeringCentral&SuiteDirectory=engineeringcentral&default=<%=strDefaultName%>&txtTextSearch=<%=strTxtTextSearch%>&targetLocation=windowshade";
   window.location.href = sURL;
</script>
