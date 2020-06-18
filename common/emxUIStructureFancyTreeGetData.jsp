<%--  
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
<%@page import="java.util.Vector"%>
<%@page import="com.matrixone.apps.framework.tree.Tree"%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>

<%
	MapList structureTreeMenuMap = new MapList();
	String sStructureMenu = "";

	String treeLabel = "";
	String reinit = "";
	HashMap menuJSNodeMap = new HashMap();
	    String structureMenuObj = "";
	
	MapList sMapList = new MapList();
	MapList subList = new MapList();
	HashMap firstCommand = null;
	String emxSuiteDirectory = emxGetParameter(request, "emxSuiteDirectory");

	Vector userRoleList = PersonUtil.getAssignments(context);
	String languageStr = request.getHeader("Accept-Language");

	String objectId = emxGetParameter(request, "objectId");
	String childId = emxGetParameter(request, "rootId");
	String relId = emxGetParameter(request, "relId");
	reinit = emxGetParameter(request, "reinit");
	    String commandName = emxGetParameter(request, "commandName");
	
	HashMap params = new HashMap();
	JsonArrayBuilder structureArray = Json.createArrayBuilder();
	
	StringList strSel  = new StringList();
    strSel.add(DomainConstants.SELECT_TYPE);
    strSel.add(DomainConstants.SELECT_NAME);
    
    if(!reinit.equals("reinit")){

	    firstCommand = (HashMap) UIMenu.getCommand(context, commandName);
                    		HashMap requestMap = UINavigatorUtil.getRequestParameterMap(request);
	    sMapList = UITreeUtil.getStructureChildren(context, firstCommand, objectId, requestMap);
                    	    sMapList.sort("name", "ascending", "string");
	    for (int childIdx = 0; childIdx < sMapList.size(); childIdx++) {
			JsonObjectBuilder jsonObj = BPSJsonObjectBuilder.createJsonObjectBuilder(Json.createObjectBuilder());
			Map childMap = (Map) sMapList.get(childIdx);
			String childObjectId = (String) childMap.get("id");
                    			String childRelID = "";
			try {
			    childRelID = (String) ((StringList) childMap.get("id[connection]")).get(0);
			} catch (Exception e) {
			    childRelID = (String) childMap.get("id[connection]");
                                }
			DomainObject childDomObj = DomainObject.newInstance(context, childObjectId);
			Map childObjMap = childDomObj.getInfo(context, strSel);
                    		    String childTypeName = "";
			if (childObjMap != null) {
			    childTypeName = (String) childObjMap.get(DomainConstants.SELECT_TYPE);
                    		    }
                    		    String childNodeName = "";
                    		    Map menuJSNodeStructMap = new HashMap();
			String stMenuName = (String) childMap.get("treeMenu");
			if (UIUtil.isNullOrEmpty(stMenuName)) {
			    stMenuName = UITreeUtil.getTreeMenuName(application, session, context, childObjectId, emxSuiteDirectory);
			}
			if (UIUtil.isNotNullAndNotEmpty(stMenuName)) {
			    HashMap treeStructureMenuMap = UIMenu.getMenu(context, stMenuName);
			    menuJSNodeStructMap = UITreeUtil.getJSNodeMap(application, session, request, context, treeStructureMenuMap, childObjectId, childRelID);
			} else {
			    menuJSNodeStructMap = UITreeUtil.getJSNodeMap(application, session, request, context, firstCommand, childObjectId, childRelID);
			}
			childNodeName = (String) menuJSNodeStructMap.get("nodeLabel");
			if (UIUtil.isNullOrEmpty(childNodeName) || (UIUtil.isNotNullAndNotEmpty((String) firstCommand.get("label")) && ((String) (firstCommand.get("label"))).equalsIgnoreCase(childNodeName))) {
			    childNodeName = (String) childObjMap.get(DomainConstants.SELECT_NAME);
			}
			jsonObj.add("title", childNodeName);
			jsonObj.add("icon", UINavigatorUtil.getTypeIconProperty(context, childTypeName));
			jsonObj.add("objectId", childObjectId);
			jsonObj.add("key", childObjectId);
			jsonObj.add("relId", childRelID);
			jsonObj.add("structureTreeName", sStructureMenu);
			jsonObj.add("lazy", "true");
			jsonObj.add("commandName", commandName);
			jsonObj.add("firstLoad", "false");
			jsonObj.add("SuiteDirectory", emxSuiteDirectory); 
			jsonObj.add("url", "../common/emxTree.jsp?objectId=" + childObjectId+"&refreshTree=false&emxSuiteDirectory="+emxSuiteDirectory);
			structureArray.add(jsonObj);
                    	    }
	out.clear();
	response.setContentType("application/json; charset=UTF-8");
	out.write(structureArray.build().toString());
    }else {
    	
    	JsonArray strucTree=null;
	    Tree treeObj = new Tree(context);
	     //treeObj.setStructureMenuName(sTreeMenuName);
	     treeObj.setApplication(application);
	     treeObj.setSession(session);
	     treeObj.setObjectId(objectId);
	     treeObj.setEmxSuiteDirectory(emxSuiteDirectory);
	     treeObj.setStructureTreeMenuName(sStructureMenu);
	     treeObj.setRequest(request);
	     treeObj.setRelId(relId);

	     strucTree=UITreeUtil.createFancyTree(treeObj);
	     JsonObjectBuilder j = BPSJsonObjectBuilder.createJsonObjectBuilder(Json.createObjectBuilder());
	     j.add("structureTree",strucTree.toString());
	     
	     out.clear();
	 	response.setContentType("application/json; charset=UTF-8");
	 	out.write(j.build().toString());
    }
	     
%>
