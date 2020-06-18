
<%-- emxLaunch3DPlay.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
--%>

<%@include file="../common/emxNavigatorNoDocTypeInclude.inc"%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>
<%@ page import="com.matrixone.apps.plmprovider.*"%>
<%@ page import="com.matrixone.apps.common.Part" %>
<%@ page import="com.matrixone.apps.domain.util.PropertyUtil" %>
<%@ page import="com.matrixone.apps.domain.util.mxType"%>
<%@ page import="com.matrixone.apps.framework.ui.UIUtil"%>

<emxUtil:localize id="i18nId" bundle="emxComponentsStringResource"
	locale='<%= XSSUtil.encodeForHTML(context, request.getHeader("Accept-Language")) %>' />


<!DOCTYPE html>
<html style="height: 100%; overflow: hidden;">
<head>

<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="javascript" src="../common/scripts/emxUICoreMenu.js"></script>
 <script type="text/javascript" src="../webapps/AmdLoader/AmdLoader.js"></script>
 <script type="text/javascript" src="../common/scripts/jquery-latest.js"></script>
<script src="../webapps/c/UWA/js/UWA_W3C_Alone.js"></script>

<script language="JavaScript" src="emxUIImageManager.js"
	type="text/javascript"></script>



<%
String objectId     = (String)emxGetParameter(request, "objectId");
String compare3D    = (String)emxGetParameter(request, "3DCompare");
String objectId2     = (String)emxGetParameter(request, "objectId2");
String firstLoad = (String)emxGetParameter(request,"firstLoad");
final String TYPE_VPM_REFERENCE       = PropertyUtil.getSchemaProperty("type_VPMReference");
String physicalId = "";
String type="";
String serverUrl = Framework.getFullClientSideURL(request,null,"");	
DomainObject domainObject = new DomainObject(objectId);

StringList selects = new StringList();
selects.add("physicalid");
selects.add("type");
Part part = new Part(objectId);
Map objMap = domainObject.getInfo(context, selects);
if(domainObject.isKindOf(context, "Part")) {
	Map partSpecMap = part.getInfoMap(context);
	physicalId = (String)partSpecMap.get("physicalid");
	type=(String)partSpecMap.get("type");			
}else {
	physicalId = (String) objMap.get("physicalid");
	type = (String) objMap.get("type");
}
boolean isTypeVPMRef=false;
if(UIUtil.isNotNullAndNotEmpty(type)) {

isTypeVPMRef = mxType.isOfParentType(context, type, TYPE_VPM_REFERENCE);
}

%>


<script>
	var viewer, subscribe;
	var compare = <%=XSSUtil.encodeForJavaScript(context,compare3D)%>;
	var objectId2 = '<%=XSSUtil.encodeForJavaScript(context,objectId2)%>';
	var firstLoad = <%=XSSUtil.encodeForJavaScript(context,firstLoad)%>;
	window.parent.parent.compare3D = compare;
	// Listening to viewer creation at startup
	
	function cb3DPlayReady(e) {
		
		console.log("3DPLAYREADY");
		e.target.removeEventListener('3DPLAYREADY',  arguments.callee, false);	
		viewer = e.detail.helper;
		if (viewer && subscribe){
			
			if(compare===true&&firstLoad===true) {
			
				window.parent.parent.viewer1 = viewer;
		
			var iframe = window.parent.document.getElementById("secondframe");
			iframe.setAttribute("src", "emxLaunch3DPlay.jsp?3DCompare=true&firstLoad=false&crossHighlight=true&timeStamp=null&objectId="+objectId2); 
			}else if(compare===true) {		
				window.parent.parent.viewer2 = viewer;
			}else {
				window.parent.viewer = viewer;				
			}
			if("<%=true%>"=="<%=isTypeVPMRef%>"){
			
			subscribe(viewer, true);
			}
		}
	}
		
		
	function cbBomReady(e,obj) {
		console.log("BOMREADY");

		subscribe = obj.subscribe;
		if (viewer && subscribe){
			subscribe(viewer, true);
	
		}
		
		}
		
	
	
	window.top.document.addEventListener('3DPLAYREADY',cb3DPlayReady , false);
	window.top.$(window.top.document).on("BOMREADY", cbBomReady);
	
	if(compare===true){
	
		if(window.parent.parent.bomReady=="true"){

			subscribe = window.parent.parent.subscribe1;
			
			if (viewer && subscribe){
				if("<%=true%>"=="<%=isTypeVPMRef%>"){
				subscribe(viewer, true);
		}
		}
			
		}
	}
	
</script>
	

<SCRIPT LANGUAGE="Javascript">
	document.oncontextmenu = function() {
		return false;
	}
	var myViewer = document.getElementById("viewer");
</SCRIPT>

<%@include file="../common/emxNavigatorBottomErrorInclude.inc"%>

<SCRIPT LANGUAGE="Javascript">
var stype = '<%=type%>';
if(compare){
window.parent.parent.compare3D1 = compare;
}

if( stype=="null" || stype=="undefined") {
	$(document).ready(function() {

		var div = document.createElement("div");
		document.body.setAttribute("style","background-color:#c2d1e0");
		div.setAttribute("style","position:absolute;top:50%;left:50%;transform:translateX(-50%) translateY(-50%);");
		
		var h5 = document.createElement("h5");

		var textnode = document.createTextNode("<emxUtil:i18nScript localize="i18nId">emxComponents.3DPlay.No3DProductAttached</emxUtil:i18nScript>");
		h5.setAttribute("style","color: #ab2121;");
		h5.appendChild(textnode);
		div.appendChild(h5);
		document.body.appendChild(div);
				
	});
}
else{
	  			 require([
	  		             'DS/3DPlayHelper/3DPlayHelper'
	  		         ], function (Player3DPlayWeb) {
	  		           
	  		        	p= Player3DPlayWeb({container:'divPageBody',
	  		        		input:{		        			
	  		        			asset: {
	  		        					provider: 'EV6',
	  		        					physicalid: '<%=physicalId%>',
	  		        					dtype:'<%=type%>',
	  		        					serverurl:'<%=serverUrl%>'
	  		        					}
	  		        			},
	  		        			options : {loading: 'autoplay'
	  		        				}
	  		        			});
	  		         });
}
	  			</script>

</head>

<body class=" slide-in-panel" style="height: 100%; margin: 0px;">

		<div id="divPageBody" name="divPageBody" style="top: 0px;bottom: 200px;width:100%;height:100%;">

	    </div>

</body>


</html>
