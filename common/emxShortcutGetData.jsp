<%--  emxShortcutGetData.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.

   This jsp is called from client side to get the server side information for Shortcut  
--%>
<%@page import="javax.json.JsonArray,javax.json.Json"%>
<%@page import="javax.json.JsonObjectBuilder"%>
<%@include file = "emxNavigatorInclude.inc"%>
<jsp:useBean id="shortcutInfo" class="com.matrixone.apps.framework.ui.UIShortcut" scope="session" />

<%
String action = emxGetParameter(request, "action");
String objectId = emxGetParameter(request, "objectId");
String update = emxGetParameter(request, "update");
String key = emxGetParameter(request, "key");

String recentlyViewLength = EnoviaResourceBundle.getProperty(context, "emxFramework.Shortcut.RecentlyViewedList.count");

String strSystemCollection = EnoviaResourceBundle.getProperty(context, "emxFramework.ClipBoardCollection.Name");
String strSystemGeneratedCollectionLabel =  UINavigatorUtil.getI18nString("emxFramework.ClipBoardCollection.NameLabel", "emxFrameworkStringResource", request.getHeader("Accept-Language"));

if("getCategory".equals(action)){
	JsonArray objectJsonArr=null;
	try {		
		String catagoryMenuName = "";
		String relId="";
		if(!FrameworkUtil.isObjectId(context,objectId)) {
			StringList list = FrameworkUtil.split(objectId, "|");
			catagoryMenuName = (String)list.get(1);
			relId=(String)list.get(0);
			objectId="";
		} else {
			catagoryMenuName =UITreeUtil.getTreeMenuName(application, session, context, objectId, (String)request.getParameter("suiteKey"));	
		}
	 	objectJsonArr =UIShortcutUtil.getObjectCategoryJson(context, objectId,catagoryMenuName,  application, session, request,  objectJsonArr,relId ) ;
	} catch(Exception e) {
		e.printStackTrace();
		objectJsonArr=Json.createArrayBuilder().build();
	}
	if( objectJsonArr==null){
		objectJsonArr=Json.createArrayBuilder().build();
	}
	out.clear();
    response.setContentType("application/json; charset=UTF-8");
	out.write(objectJsonArr.toString());
}
else if("removeObject".equals(action)){
	StringList memberIds = new StringList();
	memberIds = FrameworkUtil.split(objectId, "|");

	try {
		SetUtil.removeMembers(context, strSystemCollection, memberIds, false);
	} catch(Exception e)	{
		e.printStackTrace();
	}
} 
else if("doesObjectExist".equals(action)){
	JsonObjectBuilder objectStatusBuilder = BPSJsonObjectBuilder.createJsonObjectBuilder(Json.createObjectBuilder());
	DomainObject domObj = null;
	boolean exists = false;
	objectStatusBuilder.add("exists", "false");
	if(!FrameworkUtil.isObjectId(context,objectId)) {
		StringList list = FrameworkUtil.split(objectId, "|");
		String collectionName = SetUtil.getCollectionName(context, (String)list.get(0));
		exists = SetUtil.exists(context, collectionName);
	} else {
		domObj = new DomainObject(objectId);
		exists = domObj.exists(context);
	}
	
	if(exists) {
		objectStatusBuilder.add("exists", "true");
	} 
    out.clear();
    response.setContentType("application/json; charset=UTF-8");
	out.write(objectStatusBuilder.build().toString());
}
else if("updateShortcutInfo".equals(action))
{
	ArrayList[] shortcutMap = shortcutInfo.getShortcutMap(key);	
	if(null==shortcutMap) {
		shortcutMap = new ArrayList[2];
		for(int i = 0; i<2; i++){
			shortcutMap[i] = new ArrayList();
		}
		shortcutInfo.setShortcutMap(key,shortcutMap);
	}
	String id = emxGetParameter(request, "id");
	if("recentlyViewed".equals(update)){
		ArrayList recentlyViewedList =  shortcutInfo.getRecentlyViewedList(key);
			
		if(recentlyViewedList.contains(id)){
			recentlyViewedList.remove(id);		
		}
		if(recentlyViewedList.size() >= Integer.parseInt(recentlyViewLength)) {
			recentlyViewedList.remove(0);	
		}
		recentlyViewedList.add(id);
	}
	else if("facetState".equals(update)){
		ArrayList collectionStateList =  shortcutInfo.getCollectionStateList(key);
		StringList idList = FrameworkUtil.split(id, "|");
		// Remove all the elements from the arraylist and add only the elements present in getTopWindow().shortcut
		collectionStateList.removeAll(collectionStateList);
		for(int i =0; i<idList.size(); i++){
			String facetId = (String)idList.get(i);
			if(!collectionStateList.contains(facetId)){
				collectionStateList.add(facetId);	
			}
		}
	}
	
}
else if("initializeShortcutMap".equals(action)) {
	ArrayList[] shortcutMap = shortcutInfo.getShortcutMap(key);
	if(null==shortcutMap) {
		shortcutMap = new ArrayList[2];
		for(int i = 0; i<2; i++){
			shortcutMap[i] = new ArrayList();
		}
		shortcutInfo.setShortcutMap(key,shortcutMap);
	}
}

%>
