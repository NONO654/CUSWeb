<%--  emxRouteContentSearchTypes.jsp   - Component Frame for "Build ECO"

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxRouteContentSearchTypes.jsp.rca 1.7 Wed Oct 22 15:48:43 2008 przemek Experimental przemek $
--%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>

<%@include file = "emxNavigatorBaseInclude.inc"%>
<html>
<body>
<%
String relName = emxGetParameter(request,"relName");
String routeId = emxGetParameter(request,"objectId");
StringBuffer searchURL = new StringBuffer();
searchURL.append("../common/emxFullSearch.jsp?");
Enumeration eNumParameters = emxGetParameterNames(request);
while( eNumParameters.hasMoreElements() ) {
    String parmName = (String)eNumParameters.nextElement();
    String parmValue = (String)emxGetParameter(request,parmName);
    if(UIUtil.isNullOrEmpty(parmValue))
        continue;
    searchURL.append(parmName);
    searchURL.append("=");
    searchURL.append(XSSUtil.encodeForURL(context,parmValue));

    if(eNumParameters.hasMoreElements()){
    	searchURL.append("&");
    }
}
String RELATIONSHIP_ROUTE_SCOPE = PropertyUtil.getSchemaProperty("relationship_RouteScope");
String TYPE_WORKSPACE = PropertyUtil.getSchemaProperty("type_Project");
String TYPE_WORKSPACE_VAULT = PropertyUtil.getSchemaProperty("type_ProjectVault");

String scopeDetails = (MqlUtil.mqlCommand(context,"print bus $1 select $2 $3 dump $4",routeId,"relationship["+RELATIONSHIP_ROUTE_SCOPE+"].from.id","relationship["+RELATIONSHIP_ROUTE_SCOPE+"].from.type","|"));

String scopeId = "";
String scopeType = "";
if(UIUtil.isNotNullAndNotEmpty(scopeDetails)){
	scopeId = scopeDetails.split("[|]")[0];
	scopeType = scopeDetails.split("[|]")[1];
}
String searchTypes = MqlUtil.mqlCommand(context, "print relationship $1 select $2 dump", true, relName, "fromtype");
if(UIUtil.isNotNullAndNotEmpty(scopeId) && (TYPE_WORKSPACE.equals(scopeType) || TYPE_WORKSPACE_VAULT.equals(scopeType))){
	searchURL.append("&field=TYPES="+XSSUtil.encodeForURL(context, searchTypes)+":ROUTE_CONTENT_SCOPE="+XSSUtil.encodeForURL(context,scopeId));
}else{
	searchURL.append("&field=TYPES="+XSSUtil.encodeForURL(context, searchTypes));
}
searchURL.append("&frameName=APPContent");
%>
<script type="text/javascript" src="../common/scripts/jquery-latest.js"></script>
<script src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
	<script src="../common/scripts/emxUICore.js" type="text/javascript"></script>
	<script src="../common/scripts/emxUIModal.js" type="text/javascript"></script>
<script>
var search = "<%=searchURL.toString()%>";
showModalDialog(search);
</script>
</body>

</html>
