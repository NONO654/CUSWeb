<%--  StructureDisplay.jsp
   Copyright (c) 2008-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program
--%>
<%--
/*
 * @quickreview LX6 JX5 12:07:30 (IR-157193V6R2013x  "ST: Structure View invoke from RMB menu on Requirement Specification under Requirement Group display Requirement Group structure view. ")
 * @quickreview OEP DJH IR-218082V6R2014 - Removing code related to tableMenu
 * @quickreview QYG     IR-327334-3DEXPERIENCER2015x - issue with redirect on 3DExp 
 */
 --%>
<%@page import = "java.util.*,com.matrixone.apps.domain.util.*"%>
<%@page import="com.matrixone.apps.requirements.*"%>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<html>
<head>
<%

HashMap requestMap = UINavigatorUtil.getRequestParameterMap(pageContext);
String strLanguage = request.getHeader("Accept-Language");
String objectId = emxGetParameter(request, "objectId");
String parentOID = emxGetParameter(request, "parentOID");
String emxTableRowId = emxGetParameter(request, "emxTableRowId");
String categoryTreeName = emxGetParameter(request, "categoryTreeName");
//Start:IR-157193V6R2013x:LX6
if(emxTableRowId != null)
{
	String[] tokens = emxTableRowId.split("[|]");
	if(tokens.length == 1)
	{
		objectId = tokens[0];
	}
	else
	{
		objectId = tokens[1];
	}
}
//End:IR-157193V6R2013x:LX6
DomainObject bo=new DomainObject(objectId);
StringList lstSelectableList = new StringList();
lstSelectableList.add(DomainConstants.SELECT_NAME);
lstSelectableList.add(DomainConstants.SELECT_REVISION);
lstSelectableList.add(DomainConstants.SELECT_POLICY);
lstSelectableList.add(DomainConstants.SELECT_TYPE);
 
Map map = bo.getInfo(context,(StringList)lstSelectableList);
String strPolicy = (String) map.get(DomainConstants.SELECT_POLICY);
String strType = (String) map.get(DomainConstants.SELECT_TYPE);

if(strPolicy.equals("Version") && mxType.isOfParentType(context, strType, "Requirement Specification")) //Requirement Specification Version document
{
	Map menuMap = UIToolbar.getToolbar(context, "type_DOCUMENTS", PersonUtil.getAssignments(context), objectId, requestMap, strLanguage);
	String href = (String)menuMap.get("href");
	href = UINavigatorUtil.parseHREF(context,href, "Components");
	href += (href.indexOf("?") == -1 ? "?" : "&" ) + "objectId=" + objectId + "&categoryTreeName=" + categoryTreeName;
	href += "&suiteKey=Components&SuiteDirectory=components&StringResourceFileId=emxComponentsStringResource";	
	href += parentOID == null ? "" : "&parentOID=" + parentOID;
%>
	<script language="javascript" type="text/javaScript">
	window.location.href = "<%=XSSUtil.encodeForJavaScript(context, href) %>";
	</script>
<%		
//	response.sendRedirect(href);
	return;
}
else
{
	int selectedCommand = 0;
	String ExpandMenu = "";
	String StructureBrowserOption = "";
	String ContentEditorOption = "";	
	String tableView = "";
	String structuredisplay = PropertyUtil.getAdminProperty(context, PersonUtil.personAdminType, context.getUser(), "preference_StructureDisplay");

	if(true == bo.isKindOf(context,"Requirement Specification")||true == bo.isKindOf(context,"Requirement")||true == bo.isKindOf(context,"Chapter"))
	{
		StructureBrowserOption = "&expandProgram=emxSpecificationStructure:expandTreeWithAllRequirements";
		ContentEditorOption =    "&selectedProgram=emxSpecificationStructure:expandTreeWithAllRequirements";
	}
	if( (structuredisplay == null) || (structuredisplay.equals("null")) || (structuredisplay.equals("")) || (structuredisplay.equals("sb")) || !RequirementsUtil.isSCEUsed(context, new String[]{}))
	{  
		selectedCommand = 0;
	}
	else{
		selectedCommand = 1;
	}

	String menu = emxGetParameter(request, "menu");
	Map menuMap = UIToolbar.getToolbar(context, menu, PersonUtil.getAssignments(context), objectId, requestMap, strLanguage);
	MapList children = (MapList)menuMap.get("Children");
	int size = children.size() ;
	if(size > 0)
	{
		Map commandMap = size == 1 ? (Map)children.get(0) : (Map)children.get(selectedCommand);
		String href = (String)commandMap.get("href");
		href += "&objectId=" + objectId + "&categoryTreeName=" + categoryTreeName+"&menu="+menu;
		href += "&suiteKey=Requirements&SuiteDirectory=requirements&StringResourceFileId=emxRequirementsStringResource";
		href += StructureBrowserOption + ContentEditorOption;
		href += tableView;
		
		//START:IR-154624V6R2013x 
		if(objectId != null)
        {
            DomainObject domObj = DomainObject.newInstance(context, objectId);
            State curState = domObj.getCurrentState(context);
            String strState = curState.getName();
            
            if(strState.equals("Release") || strState.equals("Obsolete"))
            {
            	href += "&editRootNode=false";
            }
        }
		//END:IR-154624V6R2013x
%>
<script language="javascript" type="text/javaScript">
window.location.href = "<%=XSSUtil.encodeForJavaScript(context, href) %>";
</script>
<%		
//		response.sendRedirect(href);
		return;
	}
}

%>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
</head>
<body>
</body>
</html>
