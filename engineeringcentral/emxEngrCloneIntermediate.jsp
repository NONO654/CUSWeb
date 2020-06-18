 <%--  emxEngrCloneIntermediate.jsp  -  Search dialog frameset
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>
<%@include file="../common/emxNavigatorInclude.inc"%>

<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>

<script language="JavaScript" src="../common/scripts/emxUICore.js"></script>
<%
String strAction="";
String objectId = emxGetParameter(request, "objectId");
String typeStr = emxGetParameter(request,"type");
strAction =emxGetParameter(request,"action");
String parentOID = emxGetParameter(request, "parentOID");
String copyObjectId = emxGetParameter(request, "objectId");
String createMode    = emxGetParameter(request, "createMode");
String pfId = null;
String pfAutoNameGenerator = "FALSE";

if (copyObjectId != null && !"null".equals(copyObjectId) && !"".equals(copyObjectId)) {
	DomainObject domObj = DomainObject.newInstance(context, copyObjectId);
	String SELECT_PARTFAMILY_ID = "to[" + DomainConstants.RELATIONSHIP_CLASSIFIED_ITEM + "].from.id";
    String SELECT_PARTFAMILY_NAME_GENERATOR_ON = "to[" + DomainConstants.RELATIONSHIP_CLASSIFIED_ITEM + "].from.attribute[" + DomainConstants.ATTRIBUTE_PART_FAMILY_NAME_GENERATOR_ON + "]";
    
    StringList objectselect = new StringList(2);
    objectselect.add(SELECT_PARTFAMILY_ID);
    objectselect.add(SELECT_PARTFAMILY_NAME_GENERATOR_ON);
    
    Map infoMap = domObj.getInfo(context, objectselect);
    pfId = (String) infoMap.get(SELECT_PARTFAMILY_ID);           
    pfAutoNameGenerator = (String) infoMap.get(SELECT_PARTFAMILY_NAME_GENERATOR_ON);
    
    if (pfAutoNameGenerator == null) {
    	pfAutoNameGenerator = "false";
    }
}

if(strAction==null){
    strAction="";
}
DomainObject domPartObj = new DomainObject(objectId);
String srcObjType = domPartObj.getInfo(context, com.matrixone.apps.domain.DomainConstants.SELECT_TYPE);
String symbolicName = com.matrixone.apps.domain.util.FrameworkUtil.getAliasForAdmin(context,"type",srcObjType,true);
if(strAction.equals("PartClone")){
    response.setHeader("Cache-Control", "no-cache");
    response.getWriter().write("@"+symbolicName+"@");   
}

String selectedObjectType= "_selectedType:"+srcObjType+",type_Part";

%>
<script language="Javascript">
var isFromPartFamilyNav = "false";
try {
	//XSSOK
	var bCallSubmit       = '<%=XSSUtil.encodeForJavaScript(context,strAction)%>';
	var isFromPartFamily  = false;
	//var vbreadCrumArray   = getTopWindow().getWindowOpener().getTopWindow()?getTopWindow().getWindowOpener().getTopWindow().bclist.getCurrentBreadCrumbTrail().getBreadCrumbArray():"";
	var vbreadCrumArray = ""; 
	if (vbreadCrumArray.length >= 2) {
		isFromPartFamilyNav = "true"; 
	   //var parentOID       = vbreadCrumArray[vbreadCrumArray.length - 2 ].id;
	  
	}
    //var finalSubmitAction = (isFromPartFamily && isFromPartFamily.indexOf("true") > -1)?"refreshCaller":"treeContent";
    //var isFromPartFamilyNav = (isFromPartFamily.indexOf("true") > -1) ? "true" : "false";
    
}
catch (e) {
   alert(e.message);
}
if ((bCallSubmit=="") || (bReload==null)){
    
    
    //Modified for To Create Multiple part from Part Clone
    
    
	//XSSOK
    sURL = "../common/emxCreate.jsp?fromPartProperties=true&submitAction=doNothing&nameField=both&header=emxEngineeringCentral.Part.ClonePart&form=ENCClonePart&suiteKey=EngineeringCentral&targetLocation=slidein&multiPartCreation=true&HelpMarker=emxhelppartclone&copyObjectId=<%=XSSUtil.encodeForJavaScript(context,objectId)%>&type=<xss:encodeForURL><%=selectedObjectType%></xss:encodeForURL>&postProcessJPO=emxPart:postProcessForClonePart&preProcessJavaScript=preProcessInCreatePartClone&TypeActual=Part&createJPO=emxPart:checkLicenseAndCloneObject&partFamilyID=<xss:encodeForURL><%=pfId%></xss:encodeForURL>&PartFamilyAutoName=<xss:encodeForURL><%=pfAutoNameGenerator%></xss:encodeForURL>&postProcessURL=../engineeringcentral/PartCreatePostProcess.jsp?mode=clonedPartOpenInEditMode&emxTableRowId=<%=XSSUtil.encodeForJavaScript(context,objectId)%>&fromPartFamilyNav=" + isFromPartFamilyNav + "&slideinType=wider";
   //XSSOK 
   if("MFG"=="<%=XSSUtil.encodeForJavaScript(context,createMode)%>"){
	   sURL = sURL+"&createMode=MFG";
	   sURL = sURL+"&HelpMarker=emxmfgpartclonedetails";
    }
   else
	   {
	   sURL = sURL+"&createMode=ENG";
	   sURL = sURL+"&HelpMarker=emxhelppartclone";
	   }
    window.location.href = sURL;
}
</script>
