<%-- CharacteristicUtil.jsp

  Copyright (c) 1999-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information
  of MatrixOne, Inc.  Copyright notice is precautionary only and
  does not evidence any actual or intended publication of such program
static const char RCSID[] = "$Id: enoTemplateUtil.jsp.rca 1.60 Wed Apr  2 16:23:14 2008 przemek Experimental przemek $";
--%>

<%@ include file = "../emxUICommonAppInclude.inc"%>
<%@ include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@ include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@ page import="com.matrixone.apps.domain.util.XSSUtil"%>

<%

	//String action 		= (String)emxGetParameter(request,"action");
	String objectId  	= emxGetParameter(request, "objectId");
	String mode  	= emxGetParameter(request, "mode");
    System.out.println("Object ID is "+objectId);
%>

<script type="text/javascript" src="../common/scripts/emxUIUtility.js"></script>
<script type="text/javaScript">
	<%-- var action = "<%=XSSUtil.encodeForJavaScript(context, action)%>";

	if ("EvaluateCriteria" == action){
  		var detailsFrame = findFrame(getTopWindow(), 'detailsDisplay');
	 	detailsFrame.location.href = detailsFrame.location.href;
  	} --%>
 <%--  	//var objID= "<%=XSSUtil.encodeForJavaScript(context, objectId)%>"; --%>
	var objID= "<%=XSSUtil.encodeForJavaScript(context, objectId)%>";
	var action= "<%=XSSUtil.encodeForJavaScript(context, mode)%>";
  	var detailsFrame = findFrame(getTopWindow(), 'detailsDisplay');
	if("Characteristics" == action) {
		detailsFrame.location.href="../webapps/ENOCharacteristicsWebApp/ENOCharacteristicsWebApp.html?objectId="+objID;
	} else if("testMethods" == action){
	  	detailsFrame.location.href="../webapps/ENOCharacteristicsWebApp/ENOCharTestMethodsManagement.html?objectId="+objID;
	}
  	console.log(objID);
</script>

<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
