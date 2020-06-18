<%--  emxPackagesConfigurationSearchUtil.jsp

   Copyright (c) 1992-2010 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxPackagesConfigurationSearchUtil.jsp.rca 1.1 Wed Jan 14 05:57:06 2009 ds-smourougayan Experimental przemek $
--%>

<%@page import="com.dassault_systemes.DictionaryAuthor_itfs.DAuData,
                com.dassault_systemes.DictionaryAuthor_itfs.DAuManagerAccess,
				com.dassault_systemes.DictionaryAuthor_itfs.IDAuExtension,
				com.dassault_systemes.DictionaryAuthor_itfs.IDAuManager,
				com.dassault_systemes.DictionaryAuthor_itfs.IDAuPackage,
				com.dassault_systemes.DictionaryAuthor_itfs.IDAuType"%>
<%@page import = "com.matrixone.apps.framework.ui.UINavigatorUtil"%>
<%@page import = "com.dassault_systemes.DictionaryAuthor_itfs.DAuUtilities"%>

<%!
String computeName(Context iContext, String iObjectId)
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
					System.out.println("YI3 - pack name : "+name);
				}else
				{
					DAuData typeExtData = manager.getTypeOrExtensionFromId(iContext, iObjectId);
					if (null != typeExtData)
					{
						IDAuType type = typeExtData.IDAUTYPE;
						if(type == null){
							type = typeExtData.IDAUINSTANCE;
						}
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
					System.out.println("YI3 - pack : "+name);
					
				}
			}
		}
	}
	catch (Exception e)
	{
		System.out.println("GMX - emxPackagesConfigurationSearchUtil - Exception : " + e.getMessage());
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
String packId = emxGetParameter(request, "parentOID"); 

/*System.out.println("GMX - SearchUtil - hashMap");
Enumeration eNumParameters = emxGetParameterNames(request);
String parmValue = "";

String tableRowIds[] = null;
while( eNumParameters.hasMoreElements())
{
	String parmName  = (String)eNumParameters.nextElement();
	System.out.println("param  : " + parmName + " - value : " + emxGetParameter(request, parmName));
}
System.out.println("GMX - SearchUtil - hashMap");*/
String errString =  DAuUtilities.getSpecializationStringResource(context,"emxDataSpecialization.ErrMsg.scopes");
String packSelected = "";
StringBuffer actualValue = new StringBuffer();
StringBuffer displayValue = new StringBuffer();
StringBuffer OIDValue = new StringBuffer();
String typeId ="";
for(int i=0;i<emxTableRowId.length;i++){
	StringTokenizer strTokenizer = new StringTokenizer(emxTableRowId[i] , "|");
	String strObjectId = strTokenizer.nextToken();
	DomainObject objContext = new DomainObject(strObjectId);
	StringList strList = new StringList();
	strList.addElement(DomainConstants.SELECT_NAME);
	strList.addElement(DomainConstants.SELECT_TYPE);
	Map resultList = objContext.getInfo(context, strList);
	String strContextObjectName = computeName(context, strObjectId);
	System.out.println("YI3 - computeName: "+strContextObjectName);
	String[] strTemp = strContextObjectName.split(";");
	strContextObjectName=strTemp[0];
	System.out.println("YI3 - computeName1: "+strContextObjectName);
	if(strTemp.length>1)
		packSelected=strTemp[1];
	System.out.println("YI3 - packSelected: "+packSelected);
	if ((null == strContextObjectName) || strContextObjectName.isEmpty())
		strContextObjectName = (String)resultList.get("name");
	String strContextObjectType = (String)resultList.get("type");
	String strTypeSymbolicName  = UICache.getSymbolicName(context, strContextObjectType, "type");
	OIDValue.append(strObjectId);
	typeId=strObjectId;
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

out.write("\r\n");
out.write("<script language\"javascript\">\r\n");
out.write("var exts = new Object()\r\n");

IDAuManager manager = DAuManagerAccess.getDAuManager();
ArrayList<String> extensionsList= new ArrayList<String>();
if (null != manager && !packSelected.equals("selected"))
{
		DAuData data = manager.getTypeOrExtensionFromId(context, typeId);
		IDAuPackage pack = manager.getPackageFromId(context, packId);
		//System.out.println("YI3 - SearchUtil - packName : "+pack.getName(context));
		if (null != data)
		{
			IDAuType type = data.IDAUTYPE;
			if(type == null){
				type = data.IDAUINSTANCE;
			}
			if (null != type)
			{
				//System.out.println("YI3 - SearchUtil - typeName : "+type.getName(context));
				ArrayList<IDAuExtension> extensions = pack.getExtensions(context);
				//System.out.println("YI3 - SearchUtil - nbr of exts: "+extensions.size());
				for (IDAuExtension extension : extensions) {
				    /* MFL_121122
					ArrayList<IDAuType> scopes =extension.getScopes(context);
					scopes.addAll(extension.getInheritedScopes(context));
					*/
					ArrayList<IDAuType> scopes =extension.getScopes(context,true);
					for (IDAuType type_i : scopes) {
						String typeName = type_i.getName(context);
						//if extension extend the same Type
						if (typeName.equals(type.getName(context))) {
							extensionsList.add(extension.getName(context));
						}
					}
				}
			}
		}
		
		

String strOut = null;
int nSz = extensionsList.size();
if (nSz > 0) {
	strOut = "exts[\"" + "exts" + "\"] = [" ;
	out.write(strOut);
	String str = "";
	for (int ii = 0; ii < nSz; ii++) {
	    str = extensionsList.get(ii);
	    strOut = "{value:\"" + str + "\"" + ", text:\"" + str + "\"}";
		if (ii != nSz-1) {
			strOut += ",\r\n";
		}
		out.write(strOut);

	}
	strOut = "];\r\n";
	out.write(strOut);
}
	//}
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

function setExtension(chooser,magnit)
{
    var newElem;
    //var where = null; //(navigator.appName == "Microsoft Internet Explorer") ? -1 : null;
    //var unitChooser = chooser.document.getElementById("attrUnit");
	var unitChooser = chooser.document.getElementsByName("ukExtension")[0];
    while (unitChooser.options.length) {
        unitChooser.remove(0);
    }
    var db = exts["exts"];
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

var typeAhead = "<%=typeAhead%>";
var targetWindow = null;
var uiType = "<%=uiType%>";
var iSelected = "<%=packSelected%>";
var errMsg = "<%=errString%>";
if(iSelected=="selected"){
	alert(errMsg);
}else{
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
var typeExt = vfieldNameDisplay.value;
setExtension(targetWindow,"exts");
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
