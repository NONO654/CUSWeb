<%--  emxShortcut.jsp

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   
--%>
<%@page import="javax.json.JsonArray,javax.json.Json"%>
<%@page import="javax.json.JsonObjectBuilder"%>
<%@include file = "emxNavigatorInclude.inc"%>
<jsp:include page="emxShortcut.html"></jsp:include>
<jsp:useBean id="shortcutInfo" class="com.matrixone.apps.framework.ui.UIShortcut" scope="session" />


<%
	
	String key = emxGetParameter(request, "key");
	JsonObjectBuilder shortcutJson = BPSJsonObjectBuilder.createJsonObjectBuilder(Json.createObjectBuilder());
	HashMap params = new HashMap();
	params.put("charSet",Framework.getCharacterEncoding(request));
	params.put("languageStr",request.getHeader("Accept-Language"));
	
	ArrayList recentlyViewed = shortcutInfo.getRecentlyViewedList(key);
	ArrayList[] shortcutList = shortcutInfo.getShortcutMap(key);
	
	JsonArray recentLyViewedArr=UIShortcutUtil.getRecentlyViewedJson(context, application, session, request, recentlyViewed);	
	JsonArray collectioArr=UIShortcutUtil.getCollectionsJson(context, application, session, request, params);
	
	shortcutJson.add("recentlyViewed",recentLyViewedArr);
	shortcutJson.add("collections",collectioArr);
%>

<script>
var shortcutArr = [];

<%
	//update facet state only
	for(int j=0;j<shortcutList[1].size();j++){
%>
	//XSSOK
	shortcutArr.push('<%=(String)shortcutList[1].get(j)%>');
<%
	}
%>
</script>

<script>
	jQuery(document).ready(function ($) {
		
		if(getTopWindow().shortcut.length ==0){	
			updateShortcutArray(shortcutArr);
		}
	    emxUIShortcut.init(<%=shortcutJson.build().toString()%>);
	});
</script>
	
