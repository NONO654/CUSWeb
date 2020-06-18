<%--  emxMEPChooserSearchPreProcess.jsp   -  This page deletes MEP objects.
    (c) Dassault Systemes, 1993-2018.All rights reserved.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program
   static const char RCSID[] = $Id: /ENOManufacturerEquivalentPart/CNext/webroot/manufactuerequivalentpart/emxMEPChooserSearchPreProcess.jsp 1.1.2.1.1.1 Wed Oct 29 22:14:50 2008 GMT przemek Experimental$
--%>

<%@page import="com.matrixone.apps.domain.util.PropertyUtil"%>
<%@page import="com.matrixone.apps.domain.DomainSymbolicConstants"%>

<%@include file = "../emxUICommonAppInclude.inc"%>

<html>
<body>
 <script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript">
     var strCompanyId = getTopWindow().getWindowOpener().document.forms[0].Manufacturer.value;
</script>

<%
   String sMode = emxGetParameter(request,  "mode");
   
   String url1 = "" ;
   String url2 = "" ;
   if(sMode!=null)
   {
	   if(sMode.equalsIgnoreCase("MfgLocn")) {
       
       String defaultType = PropertyUtil.getSchemaProperty(context,DomainSymbolicConstants.SYMBOLIC_type_Location);
       
       url1 = "../common/emxFullSearch.jsp?field=TYPES=type_Location:CURRENT=policy_Location.state_Active:MANUFACTURER_ID=" ;
       
       url2 =      
       "&HelpMarker=emxhelpfullsearch&showInitialResults=false&table=OrganizationList&selection=single"+
       "&submitAction=refreshCaller&hideHeader=true&isManufacturingLocation=Yes"+
       "&formname=type_CreateMEP&fieldNameActual=ManufacturerLocationOID&fieldNameDisplay=ManufacturerLocationDisplay"
       +"&submitURL=../manufacturerequivalentpart/emxMEPChooserProcess.jsp?searchMode=fullTextSearch&mode=adllMfgLocn&vaultOption=DEFAULT_VAULT&Name=*&type="+defaultType;
      
      }
	   if(sMode.equalsIgnoreCase("reportingOrgUrl"))
	   {
		   url1= "../common/emxFullSearch.jsp?field=TYPES=type_Company&table=ECSearchCompanyTable"
				   +"&HelpMarker=emxhelpselectorganization&showInitialResults=false&fieldNameActual=hidden_REPORTING_ORGANIZATION&fieldNameDisplay=REPORTING_ORGANIZATION&selection=single&hideHeader=false"+
				   "&submitURL=../manufacturerequivalentpart/emxMEPChooserProcess.jsp?searchMode=fullTextSearch&mode=reportingOrg&";
	   }
   }
%>

 <script language="Javascript">
 //XSSOK
 var strURL =  "<%=XSSUtil.encodeForJavaScript(context,url1)%>";
 
if(strCompanyId!=null)
{
//XSSOK
        strURL +=  strCompanyId+"<%=XSSUtil.encodeForJavaScript(context,url2)%>";        
}

	
        window.location.href = strURL;
</script>

</body>
</html>

