<%--  emxPackagesConfigurationSubmitMagnitude.jsp

   Copyright (c) 1992-2010 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxPackagesConfigurationSubmitMagnitude.jsp.rca 1.1 Wed Jan 14 05:57:06 2009 ds-smourougayan Experimental przemek $
--%>

<%@page import="com.dassault_systemes.DictionaryAuthor_itfs.DAuData,
                com.dassault_systemes.DictionaryAuthor_itfs.DAuManagerAccess,
				com.matrixone.apps.domain.util.i18nNow,
				com.dassault_systemes.DictionaryAuthor_itfs.DAuUtilities,
				com.dassault_systemes.vocabulary_itfs.VocabularyManager,
				com.dassault_systemes.vocabulary_itfs.IVocabularyAccess,
				com.dassault_systemes.DictionaryAuthor_itfs.IDAuExtension,
				com.dassault_systemes.DictionaryAuthor_itfs.IDAuManager,
				com.dassault_systemes.DictionaryAuthor_itfs.IDAuPackage,
				com.dassault_systemes.DictionaryAuthor_itfs.IDAuType,
				com.matrixone.apps.domain.util.EnoviaResourceBundle"%>


<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
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
String errSelectPredicate =  DAuUtilities.getSpecializationStringResource(context,"emxDataSpecialization.ErrMsg.SelectPredicate");
String trigger="";
String nlsPredicateDisplay="";
/*System.out.println("GMX - SubmitMagnitude - hashMap");
Enumeration eNumParameters = emxGetParameterNames(request);
String parmValue = "";
String tableRowIds[] = null;
while( eNumParameters.hasMoreElements())
{
	String parmName  = (String)eNumParameters.nextElement();
	System.out.println("param  : " + parmName + " - value : " + emxGetParameter(request, parmName));
}
System.out.println("GMX - SubmitMagnitude - hashMap");*/

StringBuffer actualValue = new StringBuffer();
StringBuffer displayValue = new StringBuffer();
StringBuffer OIDValue = new StringBuffer();
for(int i=0;i<emxTableRowId.length;i++){
	StringTokenizer strTokenizer = new StringTokenizer(emxTableRowId[i] , "|");
	String strObjectId = strTokenizer.nextToken();

	displayValue.append(strObjectId);
	actualValue.append(strObjectId);
	OIDValue.append(strObjectId);
	
	if(i!=emxTableRowId.length-1){
		actualValue.append("|");
		displayValue.append("|");
		OIDValue.append("|");
	}
}
String displayVal=displayValue.toString();

if(!displayVal.contains(":")){
  trigger="error";
  emxNavErrorObject.addMessage(errSelectPredicate);
}
ArrayList<String> uri = new ArrayList<String>();
ArrayList<String> result = new ArrayList<String>();
uri.add(displayVal);
IVocabularyAccess vocab = VocabularyManager.getVocabularyAccess();
	if (null != vocab){
	result = vocab.getNLSNamesOfElementsFromURIs(context, uri, context.getLocale());
	if(!result.isEmpty()){
	  nlsPredicateDisplay = result.get(0);
	}
}
%>
<%@include file="../common/emxNavigatorBottomErrorInclude.inc"%>
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
var error = "<%=trigger%>";
if(error=="error"){
	top.location.href = "../common/emxCloseWindow.jsp";	
	
}
else{
var typeAhead = "<%=typeAhead%>";
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
vfieldNameDisplay.value ="<%=nlsPredicateDisplay%>" ;
vfieldNameActual.value ="<%=actualValue%>" ;
var magnitude = vfieldNameActual.value;
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

if(typeAhead != "true"){
top.location.href = "../common/emxCloseWindow.jsp";
}
}
</script>
