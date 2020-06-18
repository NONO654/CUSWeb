<%--  emxMEPIntermediateSearch.jsp   -  This page deletes MEP objects.
    (c) Dassault Systemes, 1993-2018.All rights reserved.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program
   static const char RCSID[] = $Id: /ENOManufacturerEquivalentPart/CNext/webroot/manufactuerequivalentpart/emxMEPIntermediateSearch.jsp 1.1.2.1.1.1 Thur Dec 23 12:14:50 2010 GMT przemek Experimental$
--%>

<%@page import="com.matrixone.apps.domain.util.FrameworkProperties"%>
<%@page import="matrix.db.Context"%>

<%@include file = "../emxUICommonAppInclude.inc"%>

<script type="text/javascript" language="JavaScript" src="../common/scripts/emxUIModal.js"></script>

<%
String searchParam          = emxGetParameter(request,  "fieldNameDisplay");
String formName             = emxGetParameter(request,  "formName");
String actualFieldName      = emxGetParameter(request,  "fieldNameActual");
String strUserName          = context.getUser();
String strSubmitURL         = "../manufacturerequivalentpart/emxMEPUtil.jsp?fieldNameActual="+actualFieldName+"&fieldNameDisplay="+searchParam+"&formName="+formName+"&fromWhere=GlobalSearch";
String strURL               = "";
String strFormInclusionList = "";
String strInclusionList     = emxGetParameter(request,  "InclusionList");

StringBuffer sbURL = new StringBuffer();

if((searchParam.equalsIgnoreCase("MEPManufacturer") || searchParam.equalsIgnoreCase("CEPEquivalent")) && (strInclusionList.indexOf("Part")!= -1)){
	strFormInclusionList = FrameworkProperties.getProperty(context, "emxManufacturerEquivalentPart.MEP.FormInclusionListManufacturer");
	
	sbURL.append("../common/emxFullSearch.jsp");    
	sbURL.append("?table=MEPCompaniesSummary");
	sbURL.append("&HelpMarker=emxhelpmanufacturersearchresults");
	sbURL.append("&field=TYPES=type_Organization:");    
    sbURL.append("RELATIONSHIP=relationship_ManufacturingResponsibility");
	sbURL.append("&hideHeader=false");
	sbURL.append("&suiteKey=ManufacturerEquivalentPart");
	sbURL.append("&header=emxManufacturerEquivalentPart.GlobalSearch.ManufacturerSearchResults");
	sbURL.append("&showInitialResults=false");
	sbURL.append("&formInclusionList=");    
	sbURL.append(strFormInclusionList);    
	sbURL.append("&selection=multiple");    
	sbURL.append("&submitURL=");    
	sbURL.append(strSubmitURL);    
	strURL=sbURL.toString();
}
%>

<script language="javascript">
//XSSOK
	var url = "<%=XSSUtil.encodeForJavaScript(context,strURL)%>";
	window.location.href=url;
</script>
