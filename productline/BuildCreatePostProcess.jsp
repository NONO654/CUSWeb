<%--  BuildCreatePostProcess.jsp - The post-process jsp for the Build create component used to do the post process operations after Build creation.
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@include file="emxDesignTopInclude.inc"%>
<%@include file="../emxContentTypeInclude.inc"%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc" %>

<%@ page
	import="com.matrixone.apps.productline.Build,
	com.matrixone.apps.framework.ui.UINavigatorUtil"%>

<%
	String languageStr = request.getHeader("Accept-Language");
	String createContext = emxGetParameter(request, "createContext");
	String initSource = emxGetParameter(request, "initSource");
	String suiteKey = emxGetParameter(request, "suiteKey");
	String jsTreeID = emxGetParameter(request, "jsTreeID");
	String ImageData = emxGetParameter(request, "ImageData");
	String timeStamp = emxGetParameter(request, "timeStamp");
	String fullTextSearch = emxGetParameter(request, "fullTextSearch");
	String fromContext=emxGetParameter(request, "fromContext");
	String url = "";
	StringList buildIds;

	context = (matrix.db.Context) request.getAttribute("context");

	try {
		HashMap requestMap = UINavigatorUtil
				.getRequestParameterMap(request);
		HashMap requestValuesMap = UINavigatorUtil
				.getRequestParameterValuesMap(request);
		requestMap.put("RequestValuesMap", requestValuesMap);
		buildIds = Build.createMultipleBuilds(context, requestMap);
	} catch (Exception e) {
		e.printStackTrace();
		throw e;
	}

	if (createContext.equalsIgnoreCase("Actions") && buildIds != null && buildIds.size() > 1)
	{
		url = "../common/emxIndentedTable.jsp?table=PLCMyDeskBuildList&mode=edit&program=emxBuild:getBuildsForMassEdit&header=emxProduct.Heading.EditBuild&HelpMarker=emxhelpbuildslist&toolbar=EmptyMenu&hideHeader=false&ImageData="
		+ ImageData
		+ "&initSource=" + XSSUtil.encodeForURL(context,initSource)
		+ "&jsTreeID=" + XSSUtil.encodeForURL(context,jsTreeID)
		+ "&languageStr=" + XSSUtil.encodeForURL(context,languageStr)
		+ "&timeStamp="	+ XSSUtil.encodeForURL(context,timeStamp)
		+ "&suiteKey=" + XSSUtil.encodeForURL(context,suiteKey)
		+ "&fullTextSearch="+XSSUtil.encodeForURL(context,fullTextSearch)
		+ "&selection=multiple"
		+ "&objectIds=" + buildIds
		+ "&showSavedQuery=false&searchCollectionEnabled=false&massPromoteDemote=false&multiColumnSort=false&triggerValidation=false&showClipboard=false&objectCompare=false&export=false&autoFilter=false&printerFriendly=false&displayView=details";
	
%>
<script language="Javascript" type="text/javascript">
//MODIFIED for 315774
//XSSOK
getTopWindow().location.href = "<%=url%>";
<%}%>
</script>
<script language="Javascript" type="text/javascript">
 if("UnitContext"=="<%=XSSUtil.encodeForJavaScript(context,fromContext)%>"){
	var detailsDisplay = findFrame(getTopWindow(), "PLCProductBuildTreeCategory");
	
	if (detailsDisplay == null) {
		detailsDisplay = findFrame(getTopWindow(),"detailsDisplay");                        
    }
	detailsDisplay.location.href = detailsDisplay.location.href;
	
} 
 		</script>

<%@include file="../common/emxNavigatorBottomErrorInclude.inc"%>
