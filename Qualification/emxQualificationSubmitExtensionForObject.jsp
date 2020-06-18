<%--  emxQualificationSubmitExtensionForObject.jsp submit Extension

   Copyright (c) 1992-2010 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxPackagesConfigurationSubmitDeploymentObjects.jsp.rca 1.1 Wed Jan 14 05:57:06 2009 ds-smourougayan Experimental przemek $
--%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@page import = "com.matrixone.apps.framework.ui.UINavigatorUtil"%>
<%@page import="com.matrixone.apps.domain.util.MqlUtil"%>
<%@ page import = "matrix.db.*, matrix.util.*,com.matrixone.servlet.*,java.util.*" %>
<%@page import = "com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%@ page import = "com.matrixone.apps.domain.DomainConstants"%>
<%@ page import = "com.matrixone.apps.domain.DomainObject"%>

<%

/*Enumeration eNumParameters = emxGetParameterNames(request);
while( eNumParameters.hasMoreElements() ) {
	String parmName  = (String)eNumParameters.nextElement();
	System.out.println("*YI3 - param : " + parmName + " - value : " + emxGetParameter(request, parmName));
}*/
response.setHeader("Cache-Control", "no-cache"); //HTTP 1.1
response.setHeader("Pragma", "no-cache"); //HTTP 1.0
//HttpSession session = request.getSession();
String fieldNameActual ="extension";// emxGetParameter(request, "fieldNameActual");
String uiType = emxGetParameter(request, "uiType");
String objectId = emxGetParameter(request, "objectId");
DomainObject BaseObject   = DomainObject.newInstance(context,objectId);
BaseObject.setId(objectId);
String strType = (String)BaseObject.getInfo(context,BaseObject.SELECT_TYPE);
String typeNls = strType;
String resNlsType = EnoviaResourceBundle.getTypeI18NString(context,strType,context.getLocale().getLanguage());
if(!resNlsType.isEmpty() && !resNlsType.contains("emxFramework")){
	typeNls = resNlsType;
}
String typeAhead = emxGetParameter(request, "typeAhead");
if(typeAhead==null)
	typeAhead="";
String frameName = emxGetParameter(request, "frameName");
String fieldNameDisplay ="extension_display";// emxGetParameter(request, "fieldNameDisplay");
String emxTableRowId[] = emxGetParameterValues(request, "emxTableRowId");

StringBuffer actualValue = new StringBuffer();
StringBuffer displayValue = new StringBuffer();
StringBuffer OIDValue = new StringBuffer();
String extName = emxTableRowId[0];

if (extName.startsWith("|") == true ) {
	extName = extName.substring(1);
}
int idxPipes = extName.indexOf("|");
if (idxPipes > 0 ) {								
	extName = extName.substring(0,idxPipes);
}

//check if extension can be added to the object
Map argsHash = new HashMap();
argsHash.put("objectId", objectId);
argsHash.put("extension", extName);
String addExtension="";
String errMsg="";
String extNameNls ="";
extNameNls=extName;
String resNlsExt = EnoviaResourceBundle.getMXI18NString(context, extName, "", context.getLocale().getLanguage(), "Interface");
if(!resNlsExt.isEmpty() && !resNlsExt.contains("emxFramework")){
	extNameNls = resNlsExt;
}
// Pack arguments into string array.
String[] args = JPO.packArgs(argsHash);
Boolean retVal =(Boolean) JPO.invoke(context, "emxQualificationProgram", null, "extensionCanBeAdded", args, Boolean.class);
if(retVal){
	displayValue.append(extNameNls);
	actualValue.append(extName);
	OIDValue.append(extName);
	addExtension="true";
}else{ 
	addExtension="false";
	String strLang = context.getSession().getLanguage();
	//errMsg = "Cannot add Extension: ";
	//errMsg += extName+" "+EnoviaResourceBundle.getProperty(context, "emxQualificationStringResource", context.getLocale(), "emxQualification.ErrMessage.ExtensionAdd");
	ArrayList<String> valMsg = new ArrayList<String>();
	valMsg.add(extNameNls);
	valMsg.add(typeNls);
	errMsg = EnoviaResourceBundle.getProperty(context, "emxQualificationStringResource", context.getLocale(), "emxQualification.ErrMessage.ExtensionAdd");
	if (errMsg != null && !errMsg.isEmpty()) {
		  for (String replacingVal : valMsg) {
			  errMsg = errMsg.replaceFirst("%val%",replacingVal);
		  }
		}
}


%>

<script language="javascript" type="text/javaScript">

//top.opener.location.href = top.opener.location.href;
//setTimeout('updateField()', 1000);
//function updateField(){
	var typeAhead = "<%=typeAhead%>";
	var targetWindow = null;
	var uiType = "<%=uiType%>";
	var addExt = "<%=addExtension%>";
	var msg = "<%=errMsg%>";
	if(addExt == "false"){
		alert(msg);
	}
	else{
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
			if(targetWindow==null)
				targetWindow = window.parent;
			
			
		}
		var tmpFieldNameActual = "<%=fieldNameActual%>";
		var tmpFieldNameDisplay = "<%=fieldNameDisplay%>";
		//alert(tmpFieldNameActual+"fieldValue");
		//alert(tmpFieldNameDisplay);
		//var vfieldNameActual = targetWindow.document.getElementById(tmpFieldNameActual+"fieldValue");
		//vfieldNameActual = vfieldNameActual == null ? targetWindow.document.getElementsByName(tmpFieldNameActual)[0] : vfieldNameActual;
		//var vfieldNameDisplay = targetWindow.document.getElementById(tmpFieldNameDisplay);
		//if (vfieldNameActual==null && vfieldNameDisplay==null){
		//	vfieldNameActual=targetWindow.document.forms[0][tmpFieldNameActual];
		//	vfieldNameDisplay=targetWindow.document.forms[0][tmpFieldNameDisplay];
		//}
		//if (vfieldNameActual==null && vfieldNameDisplay==null){
		var	vfieldNameActual=targetWindow.document.getElementsByName(tmpFieldNameActual)[0];
		var	vfieldNameValue=targetWindow.document.getElementsByName(tmpFieldNameActual+"fieldValue")[0];
		var	vfieldNameDisplay=targetWindow.document.getElementsByName(tmpFieldNameDisplay)[0];
		var	vfieldNameOID=targetWindow.document.getElementsByName(tmpFieldNameActual+"OID")[0];
		//}
		// gestion de cette salete de slidein
		if (vfieldNameActual==null && vfieldNameDisplay==null){
			try
			{
				targetWindow = targetWindow.frames[0];
				vfieldNameActual=targetWindow.document.getElementsByName(tmpFieldNameActual)[0];
				vfieldNameDisplay=targetWindow.document.getElementsByName(tmpFieldNameDisplay)[0];
			}
			catch(e)
			{
			}
		}
		//alert(vfieldNameDisplay+" : "+vfieldNameDisplay.value);
		//alert(vfieldNameActual+" : "+vfieldNameActual.value);
		if (vfieldNameDisplay!=null){
			//vfieldNameDisplay.readonly=false;
			vfieldNameDisplay.value ="<%=displayValue%>" ;
			//vfieldNameDisplay.readonly=true;
		}
		if (vfieldNameActual!=null)
			vfieldNameActual.value ="<%=actualValue%>" ;
		if (vfieldNameOID!=null)
			vfieldNameOID.value="<%=actualValue%>" ;
		if (vfieldNameValue!=null)
			vfieldNameValue.value="<%=actualValue%>" ;
		

		/*Below function should be invoked to update the filter values */
		if(targetWindow.updateFilters){
			targetWindow.updateFilters("<%=fieldNameDisplay%>","<%=displayValue%>",true);
		}

		if(typeAhead != "true")
			top.location.href = "../common/emxCloseWindow.jsp";
	}
</script>
