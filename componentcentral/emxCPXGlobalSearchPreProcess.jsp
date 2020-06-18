 <%--  emxCPXGlobalSearchPreProcess.jsp

(c) Dassault Systemes, 1993-2016.  All rights reserved.
--%>
<%@include file="../emxUIFramesetUtil.inc"%>

<%@ page import = "com.matrixone.apps.domain.util.FrameworkProperties"%>

<%

	String enableStdSearch = FrameworkProperties.getProperty(context, "CPC.enableStandardPartSearch");
	String language         = request.getHeader("Accept-Language");

	String contentURL = "../common/emxFullSearch.jsp?showInitialResults=false&table=CPXSearchResults&formInclusionList=SEPName,Vendor,SEPreference,MEPName,Manufacturer,MEPreference&fieldLabels=Vendor:emxFramework.FullTextSearch.Supplier,Manufacturer:emxFramework.FullTextSearch.Manufacturer,SEPreference:emxFramework.FullTextSearch.SEPPreference,MEPreference:emxFramework.FullTextSearch.MEPPreference,SEPName:emxFramework.FullTextSearch.SEPName,MEPName:emxFramework.FullTextSearch.MEPName";

	if(enableStdSearch != null && enableStdSearch.equals("true"))
		contentURL += "&field=TYPES=type_Part:POLICY=policy_StandardPart";
	else
		contentURL += "&field=TYPES=type_Part";

	// As part of fix for IR-100972V6R2012x, [suiteKey, SuiteDirectory] are added for URL; new help marker value
	// "emxhelpsearchpart" is updated and cancelLabel parameter is removed to make consistent with other standard search.
	contentURL += "&toolbar=CPCStandardPartsGlobalSearchToolbar&selection=multiple&hideHeader=true&HelpMarker=emxhelpsearchpart&selection=multiple&includeOIDprogram=jpo.componentcentral.sep.PartBase:checkAVXLicense&suiteKey=ComponentCentral&SuiteDirectory=componentcentral";

%>

<html>
<head>
</head>
<body>
<form name="cpxfullsearch" method="post">

<script language="Javascript">
        document.cpxfullsearch.target="_top";
        document.cpxfullsearch.action="<%=contentURL%>";
        document.cpxfullsearch.submit();

</script>
</form>
</body>
</html>

