<%--  EngineeringChangeSearchPreProcess.jsp

	Copyright (c) 1992-2018 Dassault Systemes.
	All Rights Reserved.
	This program contains proprietary and trade secret information of MatrixOne, Inc.
	Copyright notice is precautionary only and does not evidence any actual or intended publication of such program
	
	Intermediate Jsp which gets the search types from the DB, and forms the search url.
--%>

<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file = "../emxTagLibInclude.inc"%>
<%@ page import="matrix.util.StringList,
				com.matrixone.apps.common.EngineeringChange,
				java.util.Iterator,
				com.matrixone.apps.domain.util.FrameworkUtil,
				com.matrixone.apps.domain.DomainConstants,
				com.matrixone.apps.domain.DomainRelationship"%>

<%
	String functionality = emxGetParameter(request,"functionality");
	String objectId  = emxGetParameter(request, "objectId");
	String suiteKey  = emxGetParameter(request, "suiteKey");
	 //String strInclusionType = (String)DomainRelationship.getAllowedTypes(context, DomainConstants.RELATIONSHIP_REPORTED_AGAINST_EC,true,false).get(DomainRelationship.KEY_INCLUDE);
	String searchTypes = "";
	//Modified to fix IR-090294V6R2012
	String searchURL = "../common/emxFullSearch.jsp?showInitialResults=false&suiteKey="+XSSUtil.encodeForURL(context, suiteKey)+"&objectId="+XSSUtil.encodeForURL(context, objectId)+"&";
	if("affectedItems".equalsIgnoreCase(functionality)) {
	    //Start of excluding CF,LF,MF & Product
		searchTypes = (String)DomainRelationship.getAllowedTypes(context, DomainConstants.RELATIONSHIP_EC_AFFECTED_ITEM, true, false).get(DomainRelationship.KEY_INCLUDE);
	    if(searchTypes != null && !searchTypes.equals(""))
		{
			 StringList basicList = FrameworkUtil.split(searchTypes, ",");	
			 String strIncludeTypes = "";
			 StringList slIncludeTypes = new StringList();
			 
			 for(int l=0; l < basicList.size(); l++) {
		        String strTypes = (String) basicList.get(l);
		        if(!strTypes.equalsIgnoreCase("type_CONFIGURATIONFEATURES") && !strTypes.equalsIgnoreCase("type_LOGICALSTRUCTURES") && !strTypes.equalsIgnoreCase("type_Products"))
		 		{
		        	slIncludeTypes.add(strTypes);
		 		}
			 }
			 searchTypes = slIncludeTypes.join(",").toString();
		}
	  //End of excluding CF,LF,MF & Product
	  //XSSOK
	    searchURL+="field=TYPES="+searchTypes+"&table=AEFGeneralSearchResults&selection=multiple&showSavedQuery=True&searchCollectionEnabled=True&srcDestRelName=relationship_ECAffectedItem&isTo=true&submitURL=../components/emxEngineeringChangeUtil.jsp?mode=AddExistingECAffectedItems";		
	} else if("implementedItems".equalsIgnoreCase(functionality)) {
	    searchTypes = (String)DomainRelationship.getAllowedTypes(context, DomainConstants.RELATIONSHIP_EC_IMPLEMENTED_ITEM, true).get(DomainRelationship.KEY_INCLUDE);
	  //XSSOK
	    searchURL+="field=TYPES="+searchTypes+"&table=AEFGeneralSearchResults&selection=multiple&showSavedQuery=True&searchCollectionEnabled=True&srcDestRelName=relationship_ECImplementedItem&isTo=true&submitURL=../components/emxEngineeringChangeUtil.jsp?mode=AddExistingECImplementedItems";
	} else if("resolvedItems".equalsIgnoreCase(functionality)) {
	    searchTypes = (String)DomainRelationship.getAllowedTypes(context, DomainConstants.RELATIONSHIP_RESOLVED_TO, false).get(DomainRelationship.KEY_INCLUDE);
	  //XSSOK
	    searchURL+="field=TYPES="+searchTypes+"&table=AEFGeneralSearchResults&selection=multiple&showSavedQuery=True&searchCollectionEnabled=True&excludeOIDprogram=emxCommonIssue:excludeIssueRelatedObjects&srcDestRelName=relationship_ResolvedTo&isTo=false&submitURL=../components/emxEngineeringChangeUtil.jsp?mode=AddExistingECSatisfiedItems";
	} else if("reportedAgainst".equalsIgnoreCase(functionality)) {
	    searchTypes = (String)DomainRelationship.getAllowedTypes(context, DomainConstants.RELATIONSHIP_REPORTED_AGAINST_EC, true).get(DomainRelationship.KEY_INCLUDE);
	    //XSSOK
	    searchURL+="field=TYPES="+searchTypes+"&table=APPECReportedAgainstSearchList&selection=single&showSavedQuery=True&searchCollectionEnabled=True&srcDestRelName=relationship_ResolvedTo&isTo=false&submitURL=../productline/SearchUtil.jsp?submitAction=refreshCaller&formName=editDataForm&frameName=formEditDisplay&mode=chooser&suiteKey=Components&fieldNameOID=ReportedAgainstOID&fieldNameActual=ReportedAgainst&fieldNameDisplay=ReportedAgainstDisplay&chooserType=FormChooser&objectId="+XSSUtil.encodeForURL(context, objectId);
	}
	
%>

<html>
<head>
</head>
<body>	
<form name="engrfullsearch" method="post">
<input type="hidden" name="field" value="<%= "TYPES="+searchTypes %>" />
<input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%= objectId %></xss:encodeForHTMLAttribute>" />
<script type="text/javascript" src="../common/scripts/jquery-latest.js"></script>
<script src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<script src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<script src="../common/scripts/emxUIModal.js" type="text/javascript"></script>
<script language="Javascript">
showModalDialog("<%=searchURL%>");
</script>
</form>
</body>
</html>
