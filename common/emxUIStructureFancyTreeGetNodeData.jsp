<%--  emxIndentedTable.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
--%>
<%@include file="emxNavigatorInclude.inc"%>
<%@include file="emxNavigatorTopErrorInclude.inc"%>
<%@page import="javax.json.JsonArray"%>
<%@page import="javax.json.Json"%>
<%@page import="javax.json.JsonObject"%>
<%@page import="javax.json.JsonArrayBuilder"%>
<%@page import="javax.json.JsonObjectBuilder"%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>
<%@page import="com.matrixone.apps.framework.ui.UIExpression"%>
<%@page import="com.matrixone.apps.framework.ui.UINavigatorUtil"%>
<%@page import="com.matrixone.apps.framework.ui.UITreeUtil"%>
<%@page import="com.matrixone.apps.framework.ui.UIUtil"%>
<%@page import="java.util.HashMap"%>
<%@page import="com.matrixone.apps.domain.util.MapList"%>
<%

	String languageStr = request.getHeader("Accept-Language");

	String objectId = emxGetParameter(request, "objectId");
	String rootId = emxGetParameter(request, "rootId");
	DomainObject domObj = DomainObject.newInstance(context,objectId);
	
	String RELATIONSHIP_LINKED_FOLDERS = "to[Linked Folders].from.id";
	StringList strSel  = new StringList();
    strSel.add(DomainConstants.SELECT_TYPE);
    strSel.add(DomainConstants.SELECT_NAME);
    strSel.add(RELATIONSHIP_LINKED_FOLDERS);
    strSel.add("attribute[Count]");
    
    String emxSuiteDirectory=emxGetParameter(request,"SuiteDirectory");
	String stMenuName = UITreeUtil.getTreeMenuName(application, session, context, rootId, emxSuiteDirectory);
	HashMap treeStructureMenuMap = UIMenu.getMenu(context, stMenuName);
	String sStructureMenu = UIComponent.getSetting(treeStructureMenuMap, "Structure Menu");
	Vector userRoleList = PersonUtil.getAssignments(context);
	MapList structureTreeMenuMap = UIMenu.getOnlyCommands(context, sStructureMenu, userRoleList);
	HashMap command = (HashMap) structureTreeMenuMap.get(0);
	
	
	Map menuJSNodeStructMap = UITreeUtil.getJSNodeMap(application, session, request, context, treeStructureMenuMap, objectId, null);
    Map objMap     = domObj.getInfo(context, strSel);
    String objType = "";
    String linkedRelationship = "";
    String fldCount = (String)objMap.get("attribute[Count]");
  
    
    if(objMap!=null)
    {
        objType = (String)objMap.get(DomainConstants.SELECT_TYPE);
    }
    String objName = "";
    if(objMap!=null)
    {
		objName= (String) menuJSNodeStructMap.get("nodeLabel");
		linkedRelationship= (String)objMap.get(RELATIONSHIP_LINKED_FOLDERS);
	
		if(UIUtil.isNullOrEmpty(objName))	{
		    objName = (String)objMap.get(DomainConstants.SELECT_NAME);
		}
		if(UIUtil.isNotNullAndNotEmpty(linkedRelationship)){			
			String sLinkedText = EnoviaResourceBundle.getProperty(context,"emxTeamCentralStringResource",context.getLocale(),"emxTeamCentral.Common.Linked");			
			objName=objName+"("+fldCount+")"+"("+sLinkedText+")";
		}	
    }
    
	JsonArrayBuilder retJson = Json.createArrayBuilder();
	JsonObjectBuilder objNode = BPSJsonObjectBuilder.createJsonObjectBuilder(Json.createObjectBuilder());
	String sCmdItemName = UIComponent.getName(command);
	objNode.add("icon", UINavigatorUtil.getTypeIconProperty(context, objType));
	objNode.add("title", objName);
	objNode.add("lazy", "true");
	objNode.add("key",objectId);
	objNode.add("commandName",XSSUtil.encodeForHTMLAttribute(context, sCmdItemName));
	objNode.add("objectId",objectId);
	objNode.add("url","../common/emxTree.jsp?objectId="+objectId+"&refreshTree=false");
	
	retJson.add(objNode);
	
	out.clear();
	response.setContentType("application/json; charset=UTF-8");
	out.write(retJson.build().toString());
%>
