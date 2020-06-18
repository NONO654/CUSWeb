<%--  MCADChangeOwnerSubmit.jsp

   Copyright (c) 1992-2012 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program
--%>


<%@ include file="MCADTopInclude.inc"%>
<%@ include file="MCADTopErrorInclude.inc"%>
<%@ page import="com.matrixone.apps.domain.util.*"%>
<%@page import="com.matrixone.apps.domain.util.ENOCsrfGuard"%>
<%
MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData)session.getAttribute("MCADIntegrationSessionDataObject");

String fieldNameActual 	= emxGetParameter(request, "fieldNameActual");
String fieldNameDisplay = emxGetParameter(request, "fieldNameDisplay");
String uiType 			= emxGetParameter(request, "uiType");
String typeAhead 		= emxGetParameter(request, "typeAhead");
String frameName 		= emxGetParameter(request, "frameName");
String methodName 		= emxGetParameter(request, "methodName");

String emxTableRowId[] 		= emxGetParameterValues(request, "emxTableRowId");
StringBuffer actualValue 	= new StringBuffer();
StringBuffer displayValue 	= new StringBuffer();
StringBuffer OIDValue 		= new StringBuffer();
Context context 			= integSessionData.getClonedContext(session);
ENOCsrfGuard.validateRequest(context, session, request, response);	
for(int i=0;i<emxTableRowId.length;i++) 
{
    StringTokenizer strTokenizer 	= new StringTokenizer(emxTableRowId[i] , "|");
    String strObjectId 				= strTokenizer.nextToken() ;                         
    DomainObject objContext 		= new DomainObject(strObjectId);
    StringList strList 				= new StringList();
    strList.addElement(DomainConstants.SELECT_NAME);
    strList.addElement(DomainConstants.SELECT_TYPE);
    Map resultList 				= objContext.getInfo(context, strList);
    String strContextObjectName = (String)resultList.get("name");
    String strContextObjectType = (String)resultList.get("type");
    String strTypeSymbolicName  = UICache.getSymbolicName(context, strContextObjectType, "type");
    OIDValue.append(strObjectId);
    actualValue.append(strContextObjectName);
    
    if(!UIUtil.isNullOrEmpty(strTypeSymbolicName) && "type_Person".equals(strTypeSymbolicName)) 
    {
		displayValue.append(PersonUtil.getFullName(context, strContextObjectName));
    } 
    else
		displayValue.append(strContextObjectName);
    
        
    if(i!=emxTableRowId.length-1)
    {
        actualValue.append("|");
        displayValue.append("|");
        OIDValue.append("|");
    }                           
}    
%>
<%@page
	import="matrix.util.StringList, java.util.HashMap, com.matrixone.apps.domain.DomainObject, java.util.StringTokenizer,
				com.matrixone.apps.domain.DomainConstants, java.util.Map, com.matrixone.apps.domain.util.PersonUtil,
				com.matrixone.apps.framework.ui.UICache,com.matrixone.apps.framework.ui.UIUtil"%>
<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<script language="javascript" type="text/javaScript">

var typeAhead 		= "<%=XSSUtil.encodeForJavaScript(context,typeAhead)%>";

var uiType 			= "<%=XSSUtil.encodeForJavaScript(context,uiType)%>";
var targetWindow 	= null;

if(typeAhead == "true") 
{
    var frameName 	= "<%=XSSUtil.encodeForJavaScript(context,frameName)%>";
    if(frameName == null || frameName == "null" || frameName == "") 
        targetWindow = window.parent;
    else 
        targetWindow = getTopWindow().findFrame(window.parent, frameName);
}
else
    targetWindow = getTopWindow().getWindowOpener();


var tmpFieldNameActual 	= "<%=XSSUtil.encodeForJavaScript(context,fieldNameActual)%>";

var tmpFieldNameDisplay = "<%=XSSUtil.encodeForJavaScript(context,fieldNameDisplay)%>";
var tmpFieldNameOID		= tmpFieldNameActual + "OID";

var vfieldNameActual 	= targetWindow.document.getElementById(tmpFieldNameActual);
var vfieldNameDisplay 	= targetWindow.document.getElementById(tmpFieldNameDisplay);
var vfieldNameOID 		= targetWindow.document.getElementById(tmpFieldNameOID);

if (vfieldNameActual == null && vfieldNameDisplay == null) 
{
	vfieldNameActual		= targetWindow.document.forms[0][tmpFieldNameActual];
	vfieldNameDisplay		= targetWindow.document.forms[0][tmpFieldNameDisplay];
	vfieldNameOID			= targetWindow.document.forms[0][tmpFieldNameOID];
}

if (vfieldNameActual == null && vfieldNameDisplay == null) 
{
	vfieldNameActual=targetWindow.document.getElementsByName(tmpFieldNameActual)[0];
	vfieldNameDisplay=targetWindow.document.getElementsByName(tmpFieldNameDisplay)[0];
	vfieldNameOID=targetWindow.document.getElementsByName(tmpFieldNameOID)[0];
}

if (vfieldNameActual == null && vfieldNameDisplay == null) 
{
     var elem = targetWindow.document.getElementsByTagName("input");
     var att;
     var iarr;
     for(i = 0,iarr = 0; i < elem.length; i++) {
        att = elem[i].getAttribute("name");
        if(tmpFieldNameDisplay == att) {
            vfieldNameDisplay = elem[i];
            iarr++;
        }
        if(tmpFieldNameActual == att) {
            vfieldNameActual = elem[i];
            iarr++;
        }
        if(iarr == 2) 
            break;
    }
}
//XSSOK
vfieldNameDisplay.value = "<%=displayValue%>" ;
//XSSOK
vfieldNameActual.value 	= "<%=actualValue%>" ;

if(vfieldNameOID != null) 
    //XSSOK
	vfieldNameOID.value = "<%=OIDValue%>" ;

else if(uiType === "createForm" || uiType === "form") 
    //XSSOK
	vfieldNameActual.value = "<%=OIDValue%>" ;

if(targetWindow.updateFilters) 
//XSSOK
	targetWindow.updateFilters("<%=fieldNameDisplay%>","<%=displayValue%>",true);

<%
if(!UIUtil.isNullOrEmpty(methodName))
{
%>
		getTopWindow().getWindowOpener().<%=XSSUtil.encodeForJavaScript(context,methodName)%>(vfieldNameActual.value);
<%
}
%>

if(typeAhead != "true") 
{
	//top.location.href = "../common/emxCloseWindow.jsp";
}

</script>
