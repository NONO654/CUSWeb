<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1"%>
<!DOCTYPE html>
<html style="height: 100%">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">

</head>


<body onload="loadPropertyPage();" style="height: 100%">

	<script src="../webapps/AmdLoader/AmdLoader.js"></script>
	<script src="scripts/emxUICore.js"></script>
	<script type="text/javascript">
		<%@page import="com.matrixone.apps.domain.util.FrameworkUtil,
                com.matrixone.apps.framework.ui.UIUtil,
                matrix.db.Context,
                com.matrixone.servlet.Framework,
                com.matrixone.apps.domain.util.XSSUtil"
                %>
		
			<%
					
				String objectId = request.getParameter("objectId");
				String physicalId = request.getParameter("physicalId");
				Context context = Framework.getFrameContext(session);
				if(UIUtil.isNullOrEmpty(physicalId)){
					if(UIUtil.isNotNullAndNotEmpty(objectId)){
						physicalId = FrameworkUtil.getPIDfromOID(context, objectId);
					}
				}
				
			%>
					
		var physicalId = "<%=physicalId %>";
		var myAppsURL = "<%=FrameworkUtil.getMyAppsURL(context, request, response)%>"+'/resources/AppsMngt';
		var clntlang = "<%=XSSUtil.encodeForJavaScript(context, (String)request.getHeader("Accept-Language"))%>";
		var curUserId = "<%=XSSUtil.encodeForJavaScript(context,context.getUser())%>";
		
		if(clntlang){
			clntlang = clntlang.substr(0,2);
		}
		
		
	    require.config({
	        config: {
	            i18n: {
	                locale: clntlang
	            }
	        }
	    }); 
		
		function loadPropertyPage() {
	
			require([ 'DS/EditPropWidget/EditPropWidget',
					'DS/EditPropWidget/constants/EditPropConstants',
					'DS/EditPropWidget/models/EditPropModel',
					'UWA/Widget',
					'UWA/Drivers/Alone' 
					], 
					function(
						EditPropWidget, 
						EditPropConstants, 
						EditPropModel,
						WidgetElement,
						Alone) {

	            		var tenantId = getTopWindow().location.search.match(/[?&]tenant=([^&]*)?/);
	            		tenantId = (tenantId == null ? undefined : tenantId[1] || undefined);
	            		
	            		getTopWindow()["COMPASS_CONFIG"] ={};
						getTopWindow()["COMPASS_CONFIG"].userId  = curUserId;
						getTopWindow()["COMPASS_CONFIG"].lang = clntlang;
						getTopWindow()["COMPASS_CONFIG"].myAppsBaseUrl= myAppsURL;
				
						window.widget = new WidgetElement();	
						widget.lang = clntlang;
						
						
	                	var editPropertiesView  = new EditPropWidget({   
	                        'typeOfDisplay': EditPropConstants.ALL,
	                        'selectionType': EditPropConstants.NO_SELECTION,
	                        'readOnly': true,
	                        'extraNotif': true,
	                        'editMode': true

	                    });
	                    var resultElementSelected = [];
	                    var selection = new EditPropModel({
	                        'tenant': tenantId,
	                        'objectId': physicalId
	                    });
	                    resultElementSelected.push(selection);
	                    setTimeout(function () {
	                        editPropertiesView.initDatas(resultElementSelected);
	                        editPropertiesView.centerIt();
	                        widget.addEvent('onResize', function () {
	                            setTimeout(function () {
	                                editPropertiesView.onResize();
	                            }, 10);
	                        });
	                    }, 50);
	                    
	                    var container = document.getElementById('container');
	                    editPropertiesView.inject(container);    
						
			});
		}
	</script>
	<div id="container" style="height: 100%">
	</div>
</body>
</html>
