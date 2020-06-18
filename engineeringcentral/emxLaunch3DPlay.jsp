
<%-- emxLaunch3DPlay.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
--%>

<%@include file="../common/emxNavigatorNoDocTypeInclude.inc"%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>
<%@ page import="com.matrixone.apps.engineering.Part" %>
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

<script language="JavaScript" src="../components/emxUIImageManager.js"
	type="text/javascript"></script>



<%
String targetLocation = (String)emxGetParameter(request, "targetLocation");
String objectId     = (String)emxGetParameter(request, "objectId");
String compare3D    = (String)emxGetParameter(request, "3DCompare");
String currentCompareTableName     = (String)emxGetParameter(request, "currentCompareTableName");
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
String sTenant = context.getTenant();
%>


<script>
	var viewer, subscribe;
	var compare = <xss:encodeForJavaScript><%=compare3D%></xss:encodeForJavaScript>;
	var objectId2 = '<xss:encodeForJavaScript><%=objectId2%></xss:encodeForJavaScript>';
	var firstLoad = <xss:encodeForJavaScript><%=firstLoad%></xss:encodeForJavaScript>;
	var currentCompareTableName = '<%=currentCompareTableName%>';
	var targetLocation = <%=targetLocation%>;
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
			iframe.setAttribute("src", "emxLaunch3DPlay.jsp?3DCompare=true&firstLoad=false&crossHighlight=true&timeStamp=null&objectId="+objectId2+"&currentCompareTableName="+currentCompareTableName); 
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
	
	window.parent.parent.$(window.parent.parent.document).on('BOMREADY', cbBomReady);

	
	if(compare===true){

			if(getTopWindow().findFrame(getTopWindow(),"portalDisplay").bomReady=="true"){
				subscribe = getTopWindow().findFrame(getTopWindow(),currentCompareTableName).subscribe;
			
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
//Added as temporary fix for IR-577462-3DEXPERIENCER2018x--start
 //localStorage.setItem('3DPlay.pad3DViewer', 'false');
//Added as temporary fix for IR-577462-3DEXPERIENCER2018x--end
//XSSOK
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
	var isChildWindow2 = isChildWindow();
	var popuplevel = 1;
	var parentWin = window;
	var openerWin = getTopWindow().getWindowOpener();
	var topWindow;

	if(isChildWindow2){
		topWindow = getMainParentWindow();
	}

	function isChildWindow(){
		if(getTopWindow().getWindowOpener() != null && getTopWindow().getWindowOpener() != undefined)
			return true;
		else
			return false;
	}
	
	function getMainParentWindow(){
		if(openerWin !=null || openerWin != undefined){
			popuplevel++;
			openerWin = getPopupLevel(popuplevel);
			return openerWin;
		}else{
			return openerWin.top;
		}
	}
	
	function getPopupLevel(count){
		var popupWindow = count;
		var level1= "getTopWindow().getWindowOpener()", level2=level1;
		for(var i=1;i<popupWindow;i++){
			level2 = level2+"."+level1; 
		}
		if(eval(level2) !=null){
			popupWindow++;
			return getPopupLevel(popupWindow);
		}else{
			return eval(level2.substring(0,level2.lastIndexOf(".")));
		}
	}
//When the window opens in compare mode/pop up mode
	//if(compare && (targetLocation == 'popup' || (getTopWindow().getWindowOpener() != null && getTopWindow().getWindowOpener() != undefined ))){
		if(isChildWindow2){
			topWindow.require(['DS/i3DXCompassPlatformServices/i3DXCompassPlatformServices'],function (i3DXCompassPlatformServices) {
			i3DXCompassPlatformServices.getPlatformServices({
	  		    onComplete: function(data){
				require(['DS/3DPlayHelper/3DPlayHelper'] ,function (Player3DPlayWeb) {
					var tenantId = '<%=sTenant%>';
					if(tenantId == null || tenantId == undefined || ''== tenantId){
					tenantId = data[0].platformId;
					}
					p= Player3DPlayWeb({container:'divPageBody',
	  		    					input:{ 
	  		    						asset: {
	  		    							provider: 'EV6',
	  		    							//XSSOK
	  		    							physicalid: '<%=physicalId%>',
	  		    							//XSSOK
	  		    							dtype:'<%=type%>',
	  		    							//XSSOK
	  		    							serverurl:'<%=serverUrl%>',
											tenant: tenantId
	  		    						}
	  		    					},
	  		    					options : {
	  		    						loading: 'autoplay',
	  		    						platformServices : data 
	  		    					}
	  		    				});
							});
						}
					});
				});
	  }else{
			//When the window opens in content mode
			require(['DS/i3DXCompassPlatformServices/i3DXCompassPlatformServices','DS/3DPlayHelper/3DPlayHelper'] ,
	  				  function (i3DXCompassPlatformServices,Player3DPlayWeb) {
						i3DXCompassPlatformServices.getPlatformServices({
	  		    			onComplete: function(data){
								var tenantId = '<%=sTenant%>';
					if(tenantId == null || tenantId == undefined || ''== tenantId){
					tenantId = data[0].platformId;
					}
	  		    				p= Player3DPlayWeb({container:'divPageBody',
	  		    					input:{ 
	  		    						asset: {
	  		    							provider: 'EV6',
	  		    							physicalid: '<%=physicalId%>',
	  		    							dtype:'<%=type%>',
	  		    							serverurl:'<%=serverUrl%>',
											tenant: tenantId
	  		    						}
	  		    					},
	  		    					options : {
	  		    						loading: 'autoplay',
	  		    						platformServices :data
	  		    					}
	  		    				}) 
	  		    			}
	  		    		})
	  		    	});
			}	  			
	}
	  			</script>

</head>

<body class=" slide-in-panel" style="height: 100%; margin: 0px;">

		<div id="divPageBody" name="divPageBody" style="top: 0px;bottom: 200px;width:100%;height:100%;">

	    </div>

</body>


</html>
