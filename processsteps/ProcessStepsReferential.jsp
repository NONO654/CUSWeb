<%@page import="com.matrixone.apps.domain.util.FrameworkUtil"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkException"%>
<%@page import="java.text.*,java.io.*, java.util.*, java.util.List, org.w3c.dom.Document"%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>
<%@include file = "../common/emxNavigatorInclude.inc"%>


<!doctype html>
<html lang="en">
	<head>
	  <meta http-equiv="cache-control" content="no-cache" /> <!-- TBD: Does this impact performance?-->
	  <meta http-equiv="pragma" content="no-cache" />  <!-- TBD: Does this impact performance?-->

	  <meta charset="utf-8">
<link rel="stylesheet" href="../webapps/UIKIT/UIKIT.css" />



	<script src="../plugins/libs/jquery/2.0.3/jquery.js"></script>	
	<script type="text/javascript" src="../webapps/AmdLoader/AmdLoader.js"></script>
	<script type="text/javascript" src="../webapps/WebappsUtils/WebappsUtils.js"></script>
	<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
	<script language="Javascript" src="../common/scripts/emxUIModal.js"></script>
	<script type="text/javascript" src="../webapps/PlatformAPI/PlatformAPI.js"></script>
	<script type="text/javascript" src="../webapps/UIKIT/UIKIT.js"></script>
	<script type="text/javascript" src="../webapps/ENOProcessStepsReferential/scripts/ProcessStepsReferential.js"></script>
	<script type="text/javascript" src="../webapps/Handlebars/Handlebars.js"></script>
	<script type="text/javascript" src="../c/UWA/js/UWA_Standalone_Alone.js"></script>
    <script src="../webapps/c/UWA/js/UWA_W3C_Alone.js"></script>
	<script src="../plugins/libs/jqueryui/1.10.3/js/jquery-ui.js"></script>

<%

	String objectId = request.getParameter("objectId");
	context         = Framework.getFrameContext(session);
%>


	  <script>
	  
	  function resizeIframe(){
		  var accHeight = $("#accordion2").height();
		  var frame = $('#recentDocumentsview', window.parent.document);
		  frame.height(accHeight + 150);
	  }
	  
	  function setAccordionHeight(){
		  var accHeight = $("#accordion2").height();
		  
		  var frame = $('#recentDocumentsview', window.parent.document);
		  frame.height(accHeight + 150);
	  }
	  	
	  jQuery(document).ready(function () {

	    });
	  
	  </script>
		
	</head>
	<body>
</br>
   
<div id='recentDocuments'></div>

	<script>
  var objId='<%=objectId%>';
	




var recentDoc 		= 	document.getElementById('recentDocuments');


 require(['DS/PlatformAPI/PlatformAPI',
			 'DS/ENOProcessStepsReferential/ProcessStepsReferential',
	         ],
	        function(PlatformAPI,ProcessStepsReferential){
			
debugger;
window.enoviaProcessStepsWidget = {

							mySecurityContext 	: "",
							myRole 				: "",
							collabspace 		: "",
							tenant				: "",
							proxy				: "passport",
							getSecurityContext	: function () {
								return this.mySecurityContext;
							},
							getTenant			: function () {
								return this.tenant;
							},
							getProxy			: function () {
								return this.proxy;
        		    },
        		                   
						};
var myAppsURL = "<%=FrameworkUtil.getMyAppsURL(context, request, response)%>";
                    	
						var curTenant = "";
						<%
							if(!FrameworkUtil.isOnPremise(context)) {
						%>
							curTenant = "<%=XSSUtil.encodeForJavaScript(context, context.getTenant())%>";
							enoviaProcessStepsWidget.tenant = curTenant;
						<%
									}
						%>
        		
			 ProcessStepsReferential.loadReferentialView(myAppsURL, 'passport', curTenant, '',objId,recentDoc);
			 ProcessStepsReferential.attachEventHdlrs(recentDoc);
			 

			});




	

function drag(ev) {

    ev.dataTransfer.setData("text", ev.target.id);
}
function allowDrop(ev,this1) {

    ev.preventDefault();
 //$(ev.target).css('borderColor','blue');
//var droptittle=document.getElementById("calloutCCD-0000016");
//droptittle.style.display="inline-block";
}

function drop(ev,this1,ondrop) {
debugger;
    ev.preventDefault();

this1.style.borderColor="red";

   alert("Drag Object: "+ev.dataTransfer.getData("text") +" Drop Object: " + this1.id +" Drop Event: " + ondrop);


}
function mouseover(ev)
{
ev.style.cursor='pointer';
ev.style.borderColor="red";
}
function mouseout(ev)
{
ev.style.cursor='';
ev.style.borderColor="#FFFFFF";
}

function leavedrop(ev,this1)
{


}



</script>

</body>
</html>
