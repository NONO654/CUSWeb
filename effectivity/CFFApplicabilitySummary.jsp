<%--
  CFFApplicabilitySummary.jsp
  
  Copyright (c) 1993-2016 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of 
  Dassault Systemes.
  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program
--%>

<%-- Common Includes --%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../common/emxUIConstantsInclude.inc"%>

<%@page import="com.matrixone.apps.domain.util.ContextUtil"%>
<%@page import="com.matrixone.apps.domain.util.MqlUtil"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import = "com.matrixone.apps.domain.DomainConstants"%>


<%
  out.clear();
  String urlStr = "";
String  strContextID = "";
String  curTenant="";
  boolean bIsError = false;
  try
  {
	   String objectId = emxGetParameter(request,"objectId");
	   DomainObject rootDom = new DomainObject(objectId);
	   strContextID = rootDom.getInfo(context, "physicalid");
           curTenant="";
     		if(!FrameworkUtil.isOnPremise(context)){
     			curTenant=XSSUtil.encodeForJavaScript(context, context.getTenant());
     }
else
{
	curTenant="OnPremise";
}
	   //urlStr = "../webapps/CfgApplicabilityUX/CfgApplicabilitySummary.html?contextID="+ strContextID+"&curTenant="+curTenant;

  }
  catch(Exception e)
  {
    bIsError=true;
    session.putValue("error.message", e.getMessage());
  }// End of main Try-catck block
%>
<html>
<head>

<script type="text/javascript" src="../webapps/AmdLoader/AmdLoader.js"></script>
<link rel="stylesheet" type="text/css" href="../webapps/c/UWA/assets/css/standalone.css" />
<script type="text/javascript" src="../webapps/c/UWA/js/UWA_Standalone_Alone.js"></script>
<script type="text/javascript" src="../webapps/WebappsUtils/WebappsUtils.js"></script>
<script type="text/javascript" src="../webapps/UIKIT/UIKIT.js"></script>
<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript" src="../common/scripts/emxUIModal.js"></script>
<script type="text/javascript" src="../webapps/PlatformAPI/PlatformAPI.js"></script>

<script type="text/javascript" src="../webapps/CfgEvolutionUX/CfgEvolutionUX.js"></script>
<script type="text/javascript" src="../webapps/ENOFrameworkPlugins/jQuery.js"></script>

    <style type="text/css">
        .module {
            width: 100%;
            height: 100% margin: 0;
        }

        .moduleHeader {
            display: none;
        }

        .moduleFooter {
            display: none;
        }
    </style>


<script>
var rootNode;
        function loadApplicability(contentAppdiv, contextID, curTenant) {
            require([
                        'DS/CfgEvolutionUX/CfgEvolutionLayoutFactory',
                        'DS/ENOFrameworkPlugins/jQuery', 'UWA/Environment', 'UWA/Environments/Standalone'

            ], function (CfgEvolutionLayoutFactory, jQuery, Environment, Standalone) {
                widget.addEvents(
                         {
                             onLoad: function () {


                                 //var sURL = '../../common/emxFullSearch.jsp?field=TYPES=' + 'Model' + ':CURRENT!=policy_Model.state_Inactive&table=AEFGeneralSearchResults&selection=multiple&formName=BCform&submitAction=refreshCaller&hideHeader=true&HelpMarker=emxhelpfullsearch&submitURL=../effectivity/EffectivityDefinitionSearch.jsp?fromOperation=search';
                                 //showChooser(sURL, 850, 630);

                                 jQuery(".moduleHeader").css("display", "none");
                                 jQuery(".moduleFooter").css("display", "none");
                                 jQuery(".moduleUwa").css("height", "100%");
                                 jQuery(".moduleUwa").css("border", "none");
                                 document.body.parentElement.setStyle("background", "none");
                                 document.body.parentElement.setStyle("overflow", "auto");
                                 jQuery(".moduleWrapper").css("height", "100%");
                                 jQuery(".moduleContent").css("height", "100%");
                                 var parent = document.querySelector("#contentAppdiv");
                                 var options = { 'mode': "Applicability", 'objectid': contextID, 'parent': parent, environment: "3DSpace",tenant:curTenant }

                                 var layout = CfgEvolutionLayoutFactory.create(options);
								 enoviaServerFilterWidget.fixForSearchInOpener =true;
                                 // CfgApplicabilityController.init(contentAppdiv,contextID,"3DSpace");
                             }
                         });
            });

        }

        document.addEventListener("DOMContentLoaded", function (e) // for some reasons, this needs to be outside of the require..
        {

if(rootNode)
		 {
			 getTopWindow().window.close();
		 }
		 else
		 {   
			  //var url = '<%=urlStr%>';
			  var parentdiv = document.getElementById("contentAppdiv");
			 // frame.setAttribute("src",url);			 

            /*var contextID=window.location.search.replace("?contextID=", "");*/
            var query = location.search.substr(1);
            var result = {};
            query.split("&").forEach(function (part) {
                var item = part.split("=");
                result[item[0]] = decodeURIComponent(item[1]);
            });
            var contextID = "<%=strContextID%>";
            var curTenant = "<%=curTenant%>";
            loadApplicability("contentAppdiv", contextID, curTenant);
}
        });




</script>
</head>
<body style="overflow:hidden;height: 100%; width:100%;">
<div id="contentAppdiv"  style="height: 94%; width:100%;"></div>
</body>
</html>  


