<%--  emxEngrMarkupInterfaceRouteRequest.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@ page import="java.util.*,java.io.*,com.matrixone.jdom.*,com.matrixone.jdom.output.*"%>
<%@ page import="com.matrixone.jdom.*,
    com.matrixone.jdom.Document,
    com.matrixone.jdom.input.*,
    com.matrixone.jdom.output.*,
    com.matrixone.apps.common.util.*" %>
<%@page import="com.matrixone.apps.engineering.*"%>

<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>


<%
//Starts-for next Gen slidein
String targetLocation = emxGetParameter(request, "targetLocation");
targetLocation = (null == targetLocation || "null".equals(targetLocation))?"":targetLocation;
//Ends for next Gen slidein

String sObjId = emxGetParameter(request,"objectId");
String commandType=emxGetParameter(request,"commandType");
String relId = emxGetParameter(request, "relId");

String strObjectIds = null;

Map reqMap = (Map)request.getParameterMap();
String[] oXML = (String[])reqMap.get("markupXML");
String strMarkupXML = oXML[0];		//emxGetParameter(request,"markupXML");

String strMultipleObjects = "";
String strInvalidStateError = "";
String strPolicy = null;
String strReleasePhase = null;
String strReleasePhaseVal = null;

String strIsReleased = "";


//Multitenant
//String strSaveAsError = i18nNow.getI18nString("emxEngineeringCentral.Markup.SaveAsError", "emxEngineeringCentralStringResource", context.getSession().getLanguage());
String strSaveAsError = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.Markup.SaveAsError");

java.io.CharArrayReader reader = new java.io.CharArrayReader(strMarkupXML.toCharArray());
com.matrixone.jdom.input.SAXBuilder builder = new com.matrixone.jdom.input.SAXBuilder(false);
builder.setFeature("http://apache.org/xml/features/disallow-doctype-decl", true);
builder.setFeature("http://xml.org/sax/features/external-general-entities", false);
builder.setFeature("http://xml.org/sax/features/external-parameter-entities", false);
builder.setValidation(false);
com.matrixone.jdom.Document doc = builder.build(reader);
/* Get The Top Level Element i.e. <mxRoot> */
com.matrixone.jdom.Element rootElement = doc.getRootElement();

java.util.List objList = rootElement.getChildren("object");
Iterator objItr = objList.iterator();
while(objItr.hasNext())
{
	Element eleChild = (Element) objItr.next();

	com.matrixone.jdom.Attribute attrAction = eleChild.getAttribute("markup");

	com.matrixone.jdom.Attribute attrObjectId = null;

	String strObjectId = null;

	if (attrAction != null && "changed".equals(attrAction.getValue()))
	{
		attrObjectId = eleChild.getAttribute("parentId");
		strObjectId = attrObjectId.getValue();
	}
	else
	{
		attrObjectId = eleChild.getAttribute("objectId");
		strObjectId = attrObjectId.getValue();
	}

	if (strObjectId != null)
	{
		DomainObject doTemp = new DomainObject(strObjectId);
		String strTempPolicy = doTemp.getInfo(context, DomainConstants.SELECT_POLICY);
		String strTempType = doTemp.getInfo(context, DomainConstants.SELECT_TYPE);
		String strTempName = doTemp.getInfo(context, DomainConstants.SELECT_NAME);
		String strTempRevision = doTemp.getInfo(context, DomainConstants.SELECT_REVISION);

		String strTempState = doTemp.getInfo(context, DomainConstants.SELECT_CURRENT);
		
		strReleasePhaseVal = doTemp.getInfo(context, EngineeringConstants.ATTRIBUTE_RELEASE_PHASE_VALUE);
		
		if(strReleasePhase == null)
		{
			strReleasePhase = strReleasePhaseVal;
		}
		else
		{
			if (!strReleasePhase.equals(strReleasePhaseVal))
			{
				strMultipleObjects = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.Markup.DifferentTypesError"); 
				break;
			}
		}
		
		if (strPolicy == null)
		{
			strPolicy = strTempPolicy;
		}
		else
		{
			if (!strPolicy.equals(strTempPolicy))
			{
				
				//Multitenant
				//strMultipleObjects = i18nNow.getI18nString("emxEngineeringCentral.Markup.DifferentTypesError", "emxEngineeringCentralStringResource", context.getSession().getLanguage());
				strMultipleObjects = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.Markup.DifferentTypesError"); 
				break;
			}
		}

		HashMap programMap = new HashMap();
		programMap.put("objectId", strObjectId);

		Boolean  blnIsCreateAllowed = (Boolean)JPO.invoke(context,"emxENCActionLinkAccess",null,"isSaveMarkupAllowed",JPO.packArgs(programMap),Boolean.class);

		boolean blnCreate = blnIsCreateAllowed.booleanValue();

		if (!blnCreate || strTempState.equals(EngineeringConstants.STATE_EC_PART_REVIEW) || strTempState.equals(DomainObject.STATE_PART_APPROVED))
		{
                       //Modified for IR-092362V6R2012
			//Multitenant
			//strInvalidStateError=i18nNow.getI18nString("EngineeringCentral.Markup.InvalidStateError", "emxEngineeringCentralStringResource", context.getSession().getLanguage());
			strInvalidStateError=EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.Markup.InvalidStateError");	
	                strInvalidStateError = strInvalidStateError+ strTempType + " " + strTempName + " " + strTempRevision ;

			break;
		}

		if (strObjectIds == null)
		{
			strObjectIds = strObjectId;
		}
		else
		{
			strObjectIds = strObjectIds + "|" + strObjectId;
		}
	}

}

session.removeAttribute("markupXML");
session.setAttribute("markupXML", strMarkupXML);

String contentURL = "../common/emxForm.jsp?form=MarkupSave&targetLocation=slidein&formHeader=emxEngineeringCentral.Markup.Create&HelpMarker=emxhelpebommarkupcreate&submitAction=doNothing&mode=edit&postProcessJPO=emxPartMarkup:saveMarkup&suiteKey=EngineeringCentral&StringResourceFileId=emxEngineeringCentralStringResource&commandType="
		+ commandType + "&objectId=" + sObjId+"&jpoAppServerParamList=session:markupXML";
%>


<html>
<head>
</head>
<body>
<form name="form" method="post">
<input type="hidden" name="markupXML" value = "" />
<input type="hidden" name="objectIds" value = "" />
<input type="hidden" name="relId" value = "" />
<input type="hidden" name="targetLocation" value="<xss:encodeForHTMLAttribute><%=targetLocation%></xss:encodeForHTMLAttribute>" />
<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="JavaScript" type="text/javascript">
document.form.objectIds.value = "<xss:encodeForJavaScript><%=strObjectIds%></xss:encodeForJavaScript>";
document.form.relId.value = "<xss:encodeForJavaScript><%=relId%></xss:encodeForJavaScript>";

var isSubmitAllowed = true;
//XSSOK
var multipleError = "<%=strMultipleObjects%>";
//XSSOK
var invlalidStateError = "<%=strInvalidStateError%>";
var cmdType = "<xss:encodeForJavaScript><%=commandType%></xss:encodeForJavaScript>";

var objTempIds = "<xss:encodeForJavaScript><%=strObjectIds%></xss:encodeForJavaScript>";
var arrTempObjIds = objTempIds.split("|");


if (cmdType == "SaveAs" && arrTempObjIds.length > 1)
{
	isSubmitAllowed = false;
	//XSSOK
	alert("<%=strSaveAsError%>");
    parent.getTopWindow().closeSlideInDialog();

}
else if (invlalidStateError != "")
{
	isSubmitAllowed = false;
	alert(invlalidStateError);
	if(parent && parent.getTopWindow()){
		parent.getTopWindow().closeSlideInDialog();
	}
	else{
    		getTopWindow().closeSlideInDialog();
	}
}
else if (multipleError != "")
{
	isSubmitAllowed = false;
	alert(multipleError);
    parent.getTopWindow().closeSlideInDialog();
}
else
{
	var msg = "";
	var markupIds = "";
	var objIds = "<xss:encodeForJavaScript><%=strObjectIds%></xss:encodeForJavaScript>";



	if (objIds == "")
	{
		if (msg.length == 0)
		{
			//XSSOK
			document.form.action='<%=contentURL%>';
		}
		else
		{
			isSubmitAllowed = false;
			alert(msg);
			getTopWindow().closeSlideInDialog();
		}
	}
	else
	{
		//XSSOK
		document.form.action='<%=contentURL%>';
	}
}

if (isSubmitAllowed){
    document.form.submit();
} 

</script>
 </form>
 </body>
</html>



