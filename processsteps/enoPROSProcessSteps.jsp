<%@page import="com.matrixone.apps.domain.util.FrameworkUtil"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%@page import="com.matrixone.apps.framework.ui.UIUtil"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkException"%>
<%@page import="java.text.*, java.io.*, java.util.*, java.util.List, org.w3c.dom.Document"%>
<%@page import="com.dassault_systemes.enovia.processsteps.services.impl.ProcessSteps"%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>
<%@include file = "../common/emxNavigatorInclude.inc"%>

<!-- Added below one for Drag and Drop functionality -->
<link rel="stylesheet" href="../common/styles/emxUIExtendedHeader.css"/>
<script src="../common/scripts/emxJSValidationUtil.js"></script>
<script src="../common/scripts/emxExtendedPageHeaderFreezePaneValidation.js"></script>
<script src="../processsteps/scripts/enoProcessStepsUtil.js"></script>


<%


boolean showNoticeMsg=false;
String errorMsg ="";
try{
context.updateClientTasks();
ClientTaskList listNotices 	= context.getClientTasks();	
ClientTaskItr itrNotices 	= new ClientTaskItr(listNotices);
StringBuilder sbMessages	= new StringBuilder();

while (itrNotices.next()) {
	System.out.println("itrNotices1"+itrNotices);
	ClientTask clientTaskMessage =  itrNotices.obj();
		sbMessages.append((String) clientTaskMessage.getTaskData());
	}
	

	errorMsg = sbMessages.toString();

context.clearClientTasks();
errorMsg = errorMsg.replace("\"", "\\\"");
showNoticeMsg= errorMsg != null && !errorMsg.equals("") && !errorMsg.equals("null");


		

}
catch (Exception e) {
	
}



String errorMessage         = null;
boolean initialPageLoad     = false;
String initialObjectId = "";
String initialSelectedAffectedItems = "";
try{

    String languageStr      = request.getHeader("Accept-Language");
    String inputStep        = request.getParameter("step");
    String inputSequence    = request.getParameter("sequence");
    String objectId         = request.getParameter("objectId");
    String rootObjectId     = request.getParameter("rootobjectId");
    String operationName    = request.getParameter("operationName");
    String queryStr         = request.getQueryString();
    String isActiveStep     = request.getParameter("isactive");
    String isElapsedStep    = request.getParameter("iselapsed");
    String inputStepState   = request.getParameter("state");
    String inputStepPolicy  = request.getParameter("policy");
    String inputStepType  = request.getParameter("type");
String pageName  = request.getParameter("page");


    Locale locale           = request.getLocale();
    String documentId    = "";
    initialObjectId = objectId;

    String selectedAffectedItems    = request.getParameter("selectedAffectedItems");
    String selectedProposedItem = request.getParameter("selectedProposedItem");
    if(UIUtil.isNotNullAndNotEmpty(selectedAffectedItems) && UIUtil.isNotNullAndNotEmpty(selectedProposedItem)&&!selectedAffectedItems.contains(selectedProposedItem)){
        selectedAffectedItems+='|'+selectedProposedItem;
    }
    else if (UIUtil.isNotNullAndNotEmpty(selectedProposedItem)&&!selectedAffectedItems.contains(selectedProposedItem)){
        selectedAffectedItems=selectedProposedItem;
    }
    initialSelectedAffectedItems = selectedAffectedItems;

    String activeStep       = "1";
    context         = Framework.getFrameContext(session);

    initialPageLoad = isNullOrEmpty(inputSequence) ? true : false;
    if(initialPageLoad) {
%>
        <!doctype html>
        <html lang="en">
        <head>
          <meta http-equiv="cache-control" content="no-cache" /> <!-- To be removed in production code-->
          <meta http-equiv="pragma" content="no-cache" />  <!-- To be removed in production code -->

          <meta charset="utf-8">
          
          <script src="../common/scripts/emxUIConstants.js"></script>
          <script src="../common/scripts/emxUICore.js"></script>
          <script src="../common/scripts/emxUIModal.js"></script>

		  <link rel="stylesheet" href="../webapps/UIKIT/UIKIT.css" />
		  <link rel="stylesheet" href="../webapps/ENOProcessStepsUX/ENOProcessStepsUX.css" />

		  <script src="../plugins/libs/jquery/2.0.3/jquery.js"></script>
		  <script type="text/javascript" src="../webapps/AmdLoader/AmdLoader.js"></script>
		  <script type="text/javascript" src="../webapps/WebappsUtils/WebappsUtils.js"></script>
		  <script language="Javascript" src="../common/scripts/emxUICore.js"></script>
		  <script language="Javascript" src="../common/scripts/emxUIModal.js"></script>
		  <script type="text/javascript" src="../webapps/PlatformAPI/PlatformAPI.js"></script>
		  <script type="text/javascript" src="../webapps/UIKIT/UIKIT.js"></script>
		  <script type="text/javascript" src="../webapps/ENOProcessStepsUX/scripts/ProcessSteps.js"></script>
		  <script type="text/javascript" src="../webapps/ENOProcessStepsDiscussionsUX/scripts/ProcessDiscussions.js"></script>
		  <script type="text/javascript" src="../webapps/ENOProcessStepsUX/scripts/ProcessSteps3DSpaceActions.js"></script>
		  <script type="text/javascript" src="../c/UWA/js/UWA_Standalone_Alone.js"></script>
          <script src="../webapps/c/UWA/js/UWA_W3C_Alone.js"></script>

		  <style type="text/css">
			.tile-title{
			font-size: 15px;
			font-family: '3dsregular' tahoma,serif;
			color: #368ec4;
			}
			.module{
			width:100%;
			height:100%;
			margin: 0;
			border: none;
			}
			.moduleWrapper {
				z-index: inherit;
				zoom: 1;
			}

            .module > .moduleHeader {
                display: none;
            }

            .moduleFooter {
                display: none;
            }
        </style>

          <script>
if("<%=showNoticeMsg%>" == "true") {
  	alert("<xss:encodeForJavaScript><%=errorMsg%></xss:encodeForJavaScript>");

  }
<%
 if (session.getAttribute("error.message") != null)
{

 String sErrorMessage = (String)session.getAttribute("error.message");
session.removeAttribute("error.message");
          sErrorMessage = sErrorMessage.trim();

%>
alert("<%=sErrorMessage%>");
<%
}
%>

          var objId='<%=objectId%>';
          refreshTree(objId, "", "", "", "", "", false,"");

          function refreshTree(objId, documentDropRelationship, documentCommand, showStatesInHeader, sMCSURL, imageDropRelationship, headerOnly,frmName){
        	    var url = "../common/emxExtendedPageHeaderAction.jsp?action=refreshHeader&objectId="+objId+"&documentDropRelationship="
        	    +documentDropRelationship+"&documentCommand="+documentCommand+"&showStatesInHeader="+showStatesInHeader
        	    +"&imageDropRelationship="+imageDropRelationship+"&MCSURL="+sMCSURL;

        	    $.ajax({
        	        url : url,
        	        cache: false
        	        }).success( function(result){
        	            if (!result.indexOf("EXCEPTION")!=-1){
        	                getTopWindow().document.getElementById("ExtpageHeadDiv").innerHTML=result;
        	                }
        	            });
        	    }

		function resizeIframe(obj) 
          {
            var doc   			= obj.contentDocument? obj.contentDocument: obj.contentWindow.document;               
            var height  		= getDocHeight(doc);
            obj.style.height 	= height + 'px';
          }
          
		function getDocHeight(doc) 
          {
            doc         = doc || document;
            var body    = doc.body, html = doc.documentElement;
            var height  = Math.max( body.scrollHeight, body.offsetHeight, html.clientHeight, html.scrollHeight, html.offsetHeight );

            return height;
          }
          
 
              		  require(['DS/PlatformAPI/PlatformAPI',
			          'DS/ENOProcessStepsUX/scripts/ProcessSteps'],
					 function(PlatformAPI, ProcessSteps) {
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
        		                       		                
						
                                                loading();
			                        var options={};
                                                options.page="<%=pageName%>";
							options.myAppsURL=myAppsURL;
			options.proxy="passport";
options.tenant=curTenant;
options.securitycontext="";
						ProcessSteps.loadReferenceView(objId, '<%=initialSelectedAffectedItems%>','',options);
		
						var content = ProcessSteps.loadProcessSteps(objId, '<%=initialSelectedAffectedItems%>','',options);

            });

            </script>
        </head>

	<div id=ReferenceView></div>
	<div id="carousel" class="carousel" style="overflow: hidden;"></div>
    <div id=accordianTasks></div>
      
            <iframe height="0%" width="0%" name="listHidden" class="hidden-frame" id="listHidden" style="display:none;"></iframe>
<%
        context.clearClientTasks();
    }

}catch(Exception e){
    errorMessage = "Failed to load process dashboard, error:" + e.getMessage();
    e.printStackTrace();
}

if(initialPageLoad) {
%>
<script>
function loading(){
      	   	var container = document.createElement('div');
      	   	container.classList.add('loading');
      	   	for(var i=0; i<4; i++){
      	   		var loading = document.createElement('div');
      	   		loading.classList.add('loading-bar');
      	   		container.appendChild(loading);
      	   	}
      	   	var loadinglablevalue ="Loading..."
      	   	var loadingtext = document.createElement('span');
      	   	var loadinglabletext = document.createTextNode(loadinglablevalue);
      	   	loadingtext.appendChild(loadinglabletext);
      	   	container.appendChild(loadingtext);
      	  document.getElementById("accordianTasks").appendChild(container);
      	}
</script>
<div>
<!-- 
<iframe id="recentDocumentsview" name="recentDocumentsview" src="" marginwidth="0" marginheight="0" frameBorder="0" height="300px" width="100%" scrolling="no" ></iframe>
</div>
<script>
    document.getElementById("recentDocumentsview").src =
              "../processsteps/ProcessStepsReferential.jsp?objectId="+objId;
</script>
-->
<!-- <iframe id="processdiscussions" name="processdiscussions" src="../processsteps/ProcessDiscussions.jsp" marginwidth="0" marginheight="0" frameBorder="0" height="100%" width="100%" scrolling="no" onload=""></iframe> -->
</body>
</html>
<iframe name="formViewHidden" style="width:0; height:0; border:0; border:none; visibility:0" id="formViewHidden">
<html><head></head><body></body></html>
</iframe>
<!-- <iframe id="processdiscussions" name="processdiscussions" src="../processsteps/ProcessDiscussions.jsp" marginwidth="0" marginheight="0" frameBorder="0" height="100%" width="100%" scrolling="no" onload=""></iframe>
<div id='testreact'></div> -->
<%} %>

<%!

	private boolean isNullOrEmpty(String input){
	    if(input == null || input.equals("") || input.equals("null")) return true;
	    return false;
	}
	
%>

