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
				com.dassault_systemes.DictionaryAuthor_itfs.IDAuExtension,
				com.dassault_systemes.DictionaryAuthor_itfs.IDAuManager,
				com.dassault_systemes.DictionaryAuthor_itfs.IDAuPackage,
				com.dassault_systemes.DictionaryAuthor_itfs.IDAuType,
				com.matrixone.apps.domain.util.EnoviaResourceBundle"%>

<%!
String computeName(Context iContext, String iObjectId)
{
	String name = "";
	try
	{
		if ((null != iObjectId) && !iObjectId.isEmpty())
		{
			IDAuManager manager = DAuManagerAccess.getDAuManager();
			if (null != manager)
			{
				DAuData typeExtData = manager.getTypeOrExtensionFromId(iContext, iObjectId);
				if (null != typeExtData)
				{
					IDAuType type = typeExtData.IDAUTYPE;
					if (null != type)
					{
						String typeName = type.getName(iContext);
						if ((null != typeName) && !typeName.isEmpty())
							name = typeName;
					}
					else
					{
						IDAuExtension extension = typeExtData.IDAUEXTENSION;
						if (null != extension)
						{
							String extensionName = extension.getName(iContext);
							if ((null != extensionName) && !extensionName.isEmpty())
								name = extensionName;
						}
					}
				}
			}
		}
	}
	catch (Exception e)
	{
		System.out.println("GMX - emxPackagesConfigurationSubmitMagnitude - Exception : " + e.getMessage());
	}
	
	return name;
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

out.write("\r\n");
out.write("<script language\"javascript\">\r\n");
out.write("var units = new Object()\r\n");
IDAuManager manager = DAuManagerAccess.getDAuManager();
String displayVal="";
if (null != manager) {
    String magnitudeName = displayValue.toString();
    ArrayList<String> listUnits = manager.getMagnitudeUnits(null,magnitudeName);
	System.out.println("GMX - SubmitMagnitude - Magnitude name1: "+magnitudeName);
	String dimensionPrefix="DSDim_";
	if (!magnitudeName.startsWith(dimensionPrefix))
	{
	  magnitudeName=dimensionPrefix+magnitudeName;
	}
	displayVal = EnoviaResourceBundle.getAdminI18NString(context, "Dimension", magnitudeName, context.getLocale().getLanguage());
	System.out.println("GMX - SubmitMagnitude - Magnitude name2: "+displayVal);
	//magnitudeName=deiplayVal;
	String strOut = null;
	int nSz = listUnits.size();
	if (nSz > 0) {
		strOut = "units[\"" + magnitudeName.substring(dimensionPrefix.length()) + "\"] = [" ;
		out.write(strOut);
		String unit = "";
		String unitNls = "";
		for (int ii = 0; ii < nSz; ii++) {
		    unit = listUnits.get(ii);
			unitNls = EnoviaResourceBundle.getAdminI18NString(context, "Range.Dimension", unit, context.getLocale().getLanguage());
		    strOut = "{value:\"" + unit + "\"" + ", text:\"" + unitNls + "\"}";
			if (ii != nSz-1) {
				strOut += ",\r\n";
			}
			out.write(strOut);
		}
		strOut = "];\r\n";
		out.write(strOut);
	}
}
out.write("</script>\r\n");
%>

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
// MFL_Units
function setUnits(chooser,magnit)
{
    var newElem;
    //var where = null; //(navigator.appName == "Microsoft Internet Explorer") ? -1 : null;
    //var unitChooser = chooser.document.getElementById("attrUnit");
	var unitChooser = chooser.document.getElementsByName("attrUnit")[0];
    while (unitChooser.options.length) {
        unitChooser.remove(0);
    }
    var db = units[magnit];
    newElem = chooser.document.createElement("option");
    newElem.text = "";
    newElem.value = "";
    //does not work on IE==> unitChooser.add(newElem, where);
    unitChooser.options.add(newElem);
    if (magnit != "" && db != null) {
        for (var i = 0; i < db.length; i++) {
            //does not work on IE==> newElem = new Option(db[i].text,db[i].value);
            //does not work on IE==> unitChooser.add(newElem,where);
            newElem = chooser.document.createElement("option");
            newElem.text = db[i].text;
            newElem.value = db[i].value;
			unitChooser.options.add(newElem);
        }
    }
}				 
// MFL_Units_End
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
// GMX - check du bon radio button
var isFinished = false, i = 0, radioButton = null;
while (!isFinished)
{
	var radio = targetWindow.document.getElementById("attrType" + i);
	if (null != radio)
	{
		radioButton = radio;
		radio.checked = false;
		i++;
	}
	else
	{
		isFinished = true;
		if (null != radioButton)
			radioButton.checked = true;
	}
}
// GMX - fin du check du radio button
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
vfieldNameDisplay.value ="<%=displayVal%>" ;
vfieldNameActual.value ="<%=actualValue%>" ;
var magnitude = vfieldNameActual.value;
setUnits(targetWindow,magnitude);
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
</script>
