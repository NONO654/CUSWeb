<%--  emxPackagesConfigurationSubmitDeploymentObjects.jsp

   Copyright (c) 1992-2010 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxPackagesConfigurationSubmitDeploymentObjects.jsp.rca 1.1 Wed Jan 14 05:57:06 2009 ds-smourougayan Experimental przemek $
--%>

<%@page import="com.dassault_systemes.DictionaryAuthor_itfs.DAuData,
                com.dassault_systemes.DictionaryAuthor_itfs.DAuManagerAccess,
				com.dassault_systemes.DictionaryAuthor_itfs.IDAuManager,
				com.dassault_systemes.DictionaryAuthor_itfs.IDAuPackage,
				com.dassault_systemes.DictionaryAuthor_itfs.IDAuType"%>
<%@page import = "com.matrixone.apps.framework.ui.UINavigatorUtil"%>
<%@page import = "com.dassault_systemes.DictionaryAuthor_itfs.DAuUtilities"%>

<%!
private static String computeName(Context iContext, String iObjectId)
{
	String name = "";
	String packSelected="";
	try
	{
		if ((null != iObjectId) && !iObjectId.isEmpty())
		{
			IDAuManager manager = DAuManagerAccess.getDAuManager();
			if (null != manager)
			{
				IDAuPackage currentPackage = manager.getPackageFromId(iContext, iObjectId);
				if (null != currentPackage){
					name = currentPackage.getName(iContext);
					packSelected = ";selected";
				}else
				{
					DAuData typeExtData = manager.getTypeOrExtensionFromId(iContext, iObjectId);
					if (null != typeExtData)
					{
						IDAuType type = typeExtData.IDAUTYPE;
						if (type == null) {
						    type = typeExtData.IDAUINSTANCE;
						}
						if (null != type)
						{
							String typeName = type.getName(iContext);
							if ((null != typeName) && !typeName.isEmpty())
								name = typeName;
						}
					}
				}
			}
		}
	}
	catch (Exception e)
	{
		System.out.println("GMX - emxPackagesConfigurationSubmitDeploymentObjects - Exception : " + e.getMessage());
	}
	
	return name+packSelected;
}
%>

<%@include file = "../common/emxNavigatorInclude.inc"%>

<%
response.setHeader("Cache-Control", "no-cache"); //HTTP 1.1
response.setHeader("Pragma", "no-cache"); //HTTP 1.0
String fieldNameActual = emxGetParameter(request, "fieldNameActual");
String uiType = emxGetParameter(request, "uiType");
String typeAhead = emxGetParameter(request, "typeAhead");
String frameName = emxGetParameter(request, "frameName");
String fieldNameDisplay = emxGetParameter(request, "fieldNameDisplay");
String emxTableRowId[] = emxGetParameterValues(request, "emxTableRowId");

/*System.out.println("GMX - SubmitDeploymentObjects - hashMap");
Enumeration eNumParameters = emxGetParameterNames(request);

String parmValue = "";
String tableRowIds[] = null;
while( eNumParameters.hasMoreElements())
{
	String parmName  = (String)eNumParameters.nextElement();
	System.out.println("param  : " + parmName + " - value : " + emxGetParameter(request, parmName));
}
System.out.println("GMX - SubmitDeploymentObjects - hashMap");
*/

String errString = DAuUtilities.getSpecializationStringResource(context,"emxDataSpecialization.ErrMsg.scopes");
String packSelected="";
StringBuffer actualValue = new StringBuffer();
StringBuffer displayValue = new StringBuffer();
StringBuffer OIDValue = new StringBuffer();
for(int i=0;i<emxTableRowId.length;i++){
	StringTokenizer strTokenizer = new StringTokenizer(emxTableRowId[i] , "|");
	String strObjectId = strTokenizer.nextToken();
	DomainObject objContext = new DomainObject(strObjectId);
	StringList strList = new StringList();
	strList.addElement(DomainConstants.SELECT_NAME);
	strList.addElement(DomainConstants.SELECT_TYPE);
	Map resultList = objContext.getInfo(context, strList);
	String strContextObjectName = computeName(context, strObjectId);
	String[] strTemp = strContextObjectName.split(";");
	strContextObjectName=strTemp[0];
	if(strTemp.length>1)
		packSelected=strTemp[1];
	if ((null == strContextObjectName) || strContextObjectName.isEmpty())
		strContextObjectName = (String)resultList.get("name");
	String strContextObjectType = (String)resultList.get("type");
	String strTypeSymbolicName  = UICache.getSymbolicName(context, strContextObjectType, "type");
	OIDValue.append(strObjectId);
	actualValue.append(strContextObjectName);
	if(!UIUtil.isNullOrEmpty(strTypeSymbolicName) && "type_Person".equals(strTypeSymbolicName)) {
		displayValue.append(PersonUtil.getFullName(context, strContextObjectName));
	} else {
		displayValue.append(strContextObjectName);
	}
		
	if(i!=emxTableRowId.length-1){
		actualValue.append("|");
		displayValue.append("|");
		OIDValue.append("|");
	}
}
// Update the Admin Index
%>
<%--  BMN2 19/09/2018 IR-633070 : After analysis with JPI, we found that this line is no more useful.
include file = "emxPackagesConfigurationUpdateAdminIndexes.inc" --%>
<%@page import="matrix.util.StringList,
                java.util.HashMap,
                com.matrixone.apps.domain.DomainObject,
                java.util.StringTokenizer,
                com.matrixone.apps.domain.DomainConstants,
                java.util.Map,
                com.matrixone.apps.domain.util.PersonUtil,
                com.matrixone.apps.framework.ui.UICache,
                com.matrixone.apps.framework.ui.UIUtil"
                %>

<script language="javascript" type="text/javaScript">

var typeAhead = "<%=typeAhead%>";
var iSelected = "<%=packSelected%>";
var errMsg = "<%=errString%>";
if(iSelected=="selected"){
	alert(errMsg);
	var contentFrame =top.findFrame(top,"content");
	contentFrame.setSubmitURLRequestCompleted();
}else{
	var targetWindow = null;
	var uiType = "<%=uiType%>";
	if(typeAhead == "true")
	{
		var frameName = "<%=frameName%>";
		if(frameName == null || frameName == "null" || frameName == "") {
			targetWindow = window.parent;
		} else {
			targetWindow = top.findFrame(window.parent, frameName);
		}
	}else
	{
		targetWindow = top.opener;
	}
	var tmpFieldNameActual = "<%=fieldNameActual%>";
	var tmpFieldNameDisplay = "<%=fieldNameDisplay%>";
	var tmpFieldNameOID = tmpFieldNameActual + "OID";
	var vfieldNameActual = targetWindow.document.getElementById(tmpFieldNameActual);
	//vfieldNameActual = vfieldNameActual == null ? targetWindow.document.getElementsByName(tmpFieldNameActual)[0] : vfieldNameActual;
	var vfieldNameDisplay = targetWindow.document.getElementById(tmpFieldNameDisplay);
	var vfieldNameOID = targetWindow.document.getElementById(tmpFieldNameOID);
	if (vfieldNameActual==null && vfieldNameDisplay==null){
	vfieldNameActual=targetWindow.document.forms[0][tmpFieldNameActual];
	vfieldNameDisplay=targetWindow.document.forms[0][tmpFieldNameDisplay];
	vfieldNameOID=targetWindow.document.forms[0][tmpFieldNameOID];
	}
	if (vfieldNameActual==null && vfieldNameDisplay==null){
	vfieldNameActual=targetWindow.document.getElementsByName(tmpFieldNameActual)[0];
	vfieldNameDisplay=targetWindow.document.getElementsByName(tmpFieldNameDisplay)[0];
	vfieldNameOID=targetWindow.document.getElementsByName(tmpFieldNameOID)[0];
	}
	// gestion de cette salete de slidein
	if (vfieldNameActual==null && vfieldNameDisplay==null){
		try
		{
			targetWindow = targetWindow.frames[0];
			vfieldNameActual=targetWindow.document.getElementsByName(tmpFieldNameActual)[0];
			vfieldNameDisplay=targetWindow.document.getElementsByName(tmpFieldNameDisplay)[0];
			vfieldNameOID=targetWindow.document.getElementsByName(tmpFieldNameOID)[0];
		}
		catch(e)
		{
		}
	}
	vfieldNameDisplay.value ="<%=displayValue%>" ;
	vfieldNameActual.value ="<%=actualValue%>" ;

	if(vfieldNameOID != null) {
	vfieldNameOID.value ="<%=OIDValue%>" ;
	}
	else if(uiType === "createForm" || uiType === "form"){
	vfieldNameActual.value ="<%=OIDValue%>" ;
	}
	/*Below function should be invoked to update the filter values */
	if(targetWindow.updateFilters){
	targetWindow.updateFilters("<%=fieldNameDisplay%>","<%=displayValue%>",true);
	}

	if(typeAhead != "true")
	top.location.href = "../common/emxCloseWindow.jsp";
}
</script>
