<%--  IEFSearchPartReSubmit.jsp

   Copyright Dassault Systemes, 1992-2012. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program
--%>

<%@ include file="MCADTopInclude.inc"%>
<%@ include file="MCADTopErrorInclude.inc"%>
<%@ page import="com.matrixone.apps.domain.util.*"%>

<%
MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData)session.getAttribute("MCADIntegrationSessionDataObject");

String uiType 			= emxGetParameter(request, "uiType");
String typeAhead 		= emxGetParameter(request, "typeAhead");
String frameName 		= emxGetParameter(request, "frameName");
String methodName 		= emxGetParameter(request, "methodName");
%>

<script language="javascript" type="text/javaScript">
//XSSOK
var typeAhead 	 = "<%=typeAhead%>";
//XSSOK
var uiType 		 = "<%=uiType%>";
var targetWindow = null;

if(typeAhead == "true") 
{
    //XSSOK
    var frameName = "<%=frameName%>";
    if(frameName == null || frameName == "null" || frameName == "") 
        targetWindow = window.parent;
    else 
        targetWindow = top.findFrame(window.parent, frameName);
}
else
    targetWindow = top.opener;
<%
if(!UIUtil.isNullOrEmpty(methodName))
{
	String strContextObjectId[]  = emxGetParameterValues(request, "emxTableRowId");
	StringTokenizer strTokenizer = new StringTokenizer(strContextObjectId[0] , "|");
	String strObjectId			 = strTokenizer.nextToken();
	DomainObject objContext		 = new DomainObject(strObjectId);
    String strContextObjectName  = objContext.getInfo(integSessionData.getClonedContext(session),DomainConstants.SELECT_NAME);
%>
    //XSSOK
	var objId='<%=strObjectId%>';
	//XSSOK
	var objName='<%=strContextObjectName%>';
	//XSSOK
	top.opener.<%=methodName%>(objName,objId);
<%
}
%>
if(typeAhead != "true")
{
	top.location.href = "../common/emxCloseWindow.jsp";
}
</script>
