
<%-- CPVLaunch3DPlay.jsp
   Copyright (c) 1992-2015 Dassault Systemes.
   All Rights Reserved.
--%>
<%-- 
 ** history:
 *  @quickreview spl7 gh4 2017/07/26: IR-533599 : Fixed issue of XSS encoding feature
--%>
<%@ include file="../common/emxNavigatorNoDocTypeInclude.inc"%>
<%@ include file="../common/emxNavigatorTopErrorInclude.inc"%>
<%@ page import="java.util.List"%>

<emxUtil:localize id="i18nId" bundle="emxComponentsStringResource"
	locale='<%= XSSUtil.encodeForHTML(context, request.getHeader("Accept-Language")) %>' />


<%
	String objectId   = (String)emxGetParameter(request, "objectId");
	String sProg 	  = (String)emxGetParameter(request, "program");
	String sMethod    = (String)emxGetParameter(request, "method");

	String physicalId = "";
	String sType = "";
	String serverUrl  = Framework.getFullClientSideURL(request,null,"");

	context.start(false);
	HashMap args = new HashMap();
	args.put("objectId",objectId);
	MapList mapResult = (MapList)JPO.invoke(context, sProg, null, sMethod, JPO.packArgs(args), MapList.class);	
	context.abort();

	HashMap mapObj = (HashMap) mapResult.get(0);
	physicalId = (String) mapObj.get("id");
	sType = (String) mapObj.get("type");
	if(null==sType || "".equals(sType))
		sType = "VPMReference";	
	
%>

<!DOCTYPE html>
<html style="height: 100%; overflow: hidden;">
<head>
	
	<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
	<script language="javascript" src="../common/scripts/emxUICore.js"></script>
	<script language="javascript" src="../common/scripts/emxUICoreMenu.js"></script>
	<script type="text/javascript" src="../webapps/AmdLoader/AmdLoader.js"></script>
	<script src="../webapps/c/UWA/js/UWA_W3C_Alone.js"></script>
	<script language="JavaScript" src="emxUIImageManager.js" type="text/javascript"></script>
	
	<script>
		var viewer;
		var PATH_SEPARATOR ="/";
		var CPVExpandPSFrame = top.findFrame(top,"CPVExpandPSCmd");
		var CPVExpandMBOMFrame = top.findFrame(top,"CPVExpandMBOMCmd");
		
		window.top.document.addEventListener('3DPLAYLOADINGFINISHED', function(e) {
			viewer = e.detail.helper;
			if (viewer){
				viewer.addSelectionCB(selectCB);
				viewer.addHideShowCB(hideShowCB);
				//viewer.hideAll();
			}
		}, false);
			
		function selectCB(CSOaction, idPathList) {
			idPathList.forEach(function(idPath) {
				var sPathPID = getPathPID(idPath);
				if(CSOaction == 'ADD') {
					CPVExpandPSFrame.do3DPSCrossHighlight(sPathPID, true);
					CPVExpandMBOMFrame.do3DMfgItemCrossHighlight(sPathPID, true);
				}
				else if(CSOaction == 'REMOVE') {
					CPVExpandPSFrame.do3DPSCrossHighlight(sPathPID, false);
					CPVExpandMBOMFrame.do3DMfgItemCrossHighlight(sPathPID, false);
				}
			});		
		}
		
		function hideShowCB(CSOaction, idPathList) {
			//alert("CSOaction = "+CSOaction+" idPathList ="+idPathList);
			idPathList.forEach(function(idPath) {
				var sPathPID = getPathPID(idPath);
				if(CSOaction == 'ADD') {
					//CPVExpandPSFrame.do3DPSCrossHighlight(sPathPID, true);
					//CPVExpandMBOMFrame.do3DMfgItemCrossHighlight(sPathPID, true);
				}
				else if(CSOaction == 'REMOVE') {
					//CPVExpandPSFrame.do3DPSCrossHighlight(sPathPID, false);
					//CPVExpandMBOMFrame.do3DMfgItemCrossHighlight(sPathPID, false);
				}
			});		
		}
		
		function getPathPID(idPath) {
			
			var sPathPID = "";
			if (idPath) {
				var tempList = idPath.split(PATH_SEPARATOR);
				if(tempList.length > 1) {
					for (var i=1; i<tempList.length-3; i++) {
						if(i==1)
							sPathPID = tempList[i];
						else
							sPathPID += PATH_SEPARATOR + tempList[i];
					}
				}
			}
			return  sPathPID;
		}
	</script>
	
	<script language="Javascript">
		document.oncontextmenu = function() {
			return false;
		}
		var myViewer = document.getElementById("viewer");
	</script>
	
	<%@include file="../common/emxNavigatorBottomErrorInclude.inc"%>

</head>

<body class=" slide-in-panel" style="height: 100%; margin: 0px;">

	<div id="divPageBody" name="divPageBody" style="top: 0px;bottom: 200px;width:100%;height:100%;">
	<script language="javascript">

	 require([
	     'DS/3DPlayHelper/3DPlayHelper'
	 ], function (Player3DPlayWeb) {
	   
		p= Player3DPlayWeb({container:'divPageBody',
			input:{		        			
				asset: {
					provider: 'EV6',
					physicalid: '<%=XSSUtil.encodeForJavaScript(context,physicalId)%>',
					dtype:'<%=XSSUtil.encodeForJavaScript(context,sType)%>',
					serverurl:'<%=XSSUtil.encodeForJavaScript(context,serverUrl)%>'
				}
			},
				options : {
					loading: 'preload'
				}
			}
		);
	 });

	</script>
	</div>

</body>

</html>
