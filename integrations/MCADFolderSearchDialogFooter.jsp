<%--  MCADFolderSearchDialogFooter.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%@ include file ="MCADTopInclude.inc" %>
<%@page import="com.matrixone.apps.domain.util.*" %>

<%@page import="com.matrixone.apps.domain.util.ENOCsrfGuard"%>

<%
	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");
    
	String nodeId			= emxGetParameter(request,"nodeId");
    String checkAccess		= emxGetParameter(request,"checkAccess");
	String integrationName	= Request.getParameter(request,"integrationName");
    String doSelect			= emxGetParameter(request, "doSelect");
	
	// Designer Central Changes Starts
	String operationTitle=Request.getParameter(request,"operationTitle");

    if (null == doSelect) 
		doSelect = "";
        
	if(integrationName == null || integrationName.length() == 0 || integrationName.equals("null"))
	{
		MCADLocalConfigObject localConfigObject = integSessionData.getLocalConfigObject();
		String[] init	= new String[] {};
		String jpoName	= "DSC_CommonUtil";

		// get the Integration Assignment from user's Local Config Object
		// if Integration Assignment is not default. The first one in the
		// list will be selected
		String jpoMethod = "getDefaultIntegrationAssignment";
		HashMap paramMap = new HashMap();

		paramMap.put("LCO", (Object)localConfigObject);
        Context context = Framework.getFrameContext(session);
		Map result		= (Map)JPO.invoke(context, jpoName, init, jpoMethod, JPO.packArgs(paramMap), Map.class);
								
	    integrationName = (String)result.get("integrationName");
	}
    // Designer Central Changes Ends

if (checkAccess == null) checkAccess = "";
    
    Context context = null;
    try
    {
       context = integSessionData.getClonedContext(session);
    }
    catch (Exception e)
    {
    }
    boolean bEnableAppletFreeUI = MCADMxUtil.IsAppletFreeUI(context);   
%>


<html>
  <head>
<script language="JavaScript" src="./scripts/IEFUIConstants.js" type="text/javascript"></script>
<script language="JavaScript" src="./scripts/IEFUIModal.js" type="text/javascript"></script>
<script language="JavaScript" src="./scripts/MCADUtilMethods.js" type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<script language="JavaScript">

function createRequestObject() {
    var tmpXmlHttpObject;
    
    //depending on what the browser supports, use the right way to create the XMLHttpRequest object
    if (window.XMLHttpRequest) { 
        // Mozilla, Safari would use this method ...
        tmpXmlHttpObject = new XMLHttpRequest();
	
    } else if (window.ActiveXObject) { 
        // IE would use this method ...
        tmpXmlHttpObject = new ActiveXObject("Microsoft.XMLHTTP");
    }
    return tmpXmlHttpObject;
}

function makeGetRequest(http,inputId,selectedNode, isProjectSpace) {
    //make a connection to the server ... specifying that you intend to make a GET request 
    //to the server. Specifiy the page name and the URL parameters to send
	http.open('get', '../iefdesigncenter/DSCCommonUtil.jsp?mode=CheckAccessOnFolder&selectedOid=' + inputId+'&projectSpaceType='+isProjectSpace);
    //assign a handler for the response
    http.onreadystatechange = function processResponse() {
    //check if the response has been received from the server
    if(http.readyState == 4){
        //read and assign the response from the server


					var response = http.responseText.replace(/^\s*/g, "");
					//strAllDivisions = strAllDivisions.replace(/\s+$/g, "");

		var bExists = response.indexOf("true") != -1;

		if(bExists){
var objectName = selectedNode.name;
			var parentNode = selectedNode.parent;
			var fullPath = objectName;
			while(parentNode != null)
			{
				fullPath = parentNode.name + "/" + fullPath;
				parentNode = parentNode.parent;
			}
			var index = fullPath.indexOf('/');
			fullPath = fullPath.substring(index+1);

			//changes made for IR-305062-3DEXPERIENCER2015x. "nodeId" will be generated randonmly.
			//var nodeId = "<%=XSSUtil.encodeForJavaScript(context,nodeId)%>";
			var nodeId = "<%=nodeId%>";
			var integrationName = "<%=XSSUtil.encodeForJavaScript(integSessionData.getClonedContext(session),integrationName)%>";
			
			if('<%=bEnableAppletFreeUI%>' == "true")
				{
				 	var s = unescape(encodeURIComponent(fullPath))
				    var h = ''
				    for (var i = 0; i < s.length; i++) {
				        h += s.charCodeAt(i).toString(16)
				    }
				 	fullPath = h;
				}else
			fullPath = hexEncode(integrationName ,fullPath);	
if ("<%=XSSUtil.encodeForJavaScript(integSessionData.getClonedContext(session),checkAccess)%>" == 'true')
			{
			   document.hiddenForm.objectId.value = inputId;
			   document.hiddenForm.fullPath.value = fullPath;
			   document.hiddenForm.nodeId.value = nodeId;
			   document.hiddenForm.applyToChild.value = document.FolderSelect.ApplyToChild.checked;
			
			   document.hiddenForm.submit();
			}
		        else
		        {
			   document.hiddenForm.applyToChild.value = document.FolderSelect.ApplyToChild.checked;
	                   
			   if(nodeId != null && nodeId != "null" && nodeId != "")
			   {
				parent.window.opener.doSelect(inputId,fullPath, nodeId, document.FolderSelect.ApplyToChild.checked);
			   }
			   else
			   {
				parent.window.opener.doGlobalSelect(inputId,fullPath,document.FolderSelect.ApplyToChild.checked);
			   }
			   parent.window.close();
			}
			}
			else{
                        //XSSOK
			alert("<%=integSessionData.getStringResource("mcadIntegration.Server.Message.NoWriteAccessAndSelectOtherFolder")%>");
	
			parent.linkClick(parent.tree.selectedID);
		    parent.showProgressImage(false);
			}
			}
};
    //actually send the request to the server
    http.send(null);
}
  function doSearch()
  {
  	  var frameObj = findFrame[parent,"bottomDisplay"]; 	
  	  var projectId = frameObj.document.FolderSearch.projectId.value;

	  parent.window.opener.doSearch(projectId,'<%=XSSUtil.encodeForJavaScript(context,nodeId)%>');
	  parent.window.close();
  }

	function doSelect () 
	{
		parent.showProgressImage(true);
	    
	           if ('<%=XSSUtil.encodeForJavaScript(integSessionData.getClonedContext(session),doSelect)%>' == 'false')
	           parent.window.close();
	        
		var selectedNode = parent.tree.getSelectedNode();
		
		if(selectedNode== null)
		{
			//XSSOK
			alert("<%=integSessionData.getStringResource("mcadIntegration.Server.Message.PleaseSelectAFolder")%>");	
			parent.showProgressImage(false);
		}
		else
		{
		var parentNode = selectedNode.parent;
		var grandParent=parentNode.parent;

		if(grandParent.name=="")
		   { 
		                //XSSOK
				alert("<%=integSessionData.getStringResource("mcadIntegration.Server.Message.WorkspaceCanNotBeSelectedAsDefaultFolder")%>");
				parent.showProgressImage(false);
				parentNode=selectedNode;
			   
		   }
			
			else
		{
		
		if(selectedNode != null)
		{
	var http = createRequestObject();
			var objectId = selectedNode.getObjectID();
var isProjectSpace = false;
			var pNotExists = objectId.indexOf("p_") != -1;
			if(pNotExists == 'true' || pNotExists)
			{
			isProjectSpace = true;
			//var res=	objectId.slice(2);
			var res=objectId.substring(2);
			makeGetRequest(http,res,selectedNode, isProjectSpace);
			}
	else {
			makeGetRequest(http,objectId,selectedNode, isProjectSpace);
			}
 //do additional parsing of the response, if needed
                       
        //in this case simply assign the response to the contents of the <div> on the page. 
       // document.getElementById('description').innerHTML = response;
			
        //If the server returned an error message like a 404 error, that message would be shown within the div tag!!. 
        //So it may be worth doing some basic error before setting the contents of the <div>
				
		}
		}
	}
	}

  </script>
   <link rel="stylesheet" href="../integrations/styles/emxIEFCommonUI.css" type="text/css">
  </head>
  <body>

<form name="FolderSelect" method="post">

<%
boolean csrfEnabled = ENOCsrfGuard.isCSRFEnabled(context);
if(csrfEnabled)
{
  Map csrfTokenMap = ENOCsrfGuard.getCSRFTokenMap(context, session);
  String csrfTokenName = (String)csrfTokenMap .get(ENOCsrfGuard.CSRF_TOKEN_NAME);
  String csrfTokenValue = (String)csrfTokenMap.get(csrfTokenName);
%>
  <!--XSSOK-->
  <input type="hidden" name= "<%=ENOCsrfGuard.CSRF_TOKEN_NAME%>" value="<%=csrfTokenName%>" />
  <!--XSSOK-->
  <input type="hidden" name= "<%=csrfTokenName%>" value="<%=csrfTokenValue%>" />
<%
}
//System.out.println("CSRFINJECTION");
%>

	<table border="0" align=left width="10%">
		<tr>
                        <!--XSSOK-->
			<td nowrap ><input type="hidden" name="ApplyToChild" ></td>
			<!--XSSOK-->
                        <td nowrap><a href="javascript:doSelect()"><img src="../integrations/images/emxUIButtonNext.gif" border="0" alt="<%=integSessionData.getStringResource("mcadIntegration.Server.ButtonName.Done")%>"></a>&nbsp;</td>
			<!--XSSOK-->
			<td nowrap><a href="javascript:doSelect()"><%=integSessionData.getStringResource("mcadIntegration.Server.ButtonName.Done")%></a></td>
			<!--XSSOK-->
			<td nowrap><a href="javascript:parent.window.close()"><img src="../integrations/images/emxUIButtonCancel.gif" border="0" alt="<%=integSessionData.getStringResource("mcadIntegration.Server.ButtonName.Cancel")%>"></a>&nbsp;</td>
			<!--XSSOK-->
			<td nowrap><a href="javascript:parent.window.close()"><%=integSessionData.getStringResource("mcadIntegration.Server.ButtonName.Cancel")%></a></td>
	</tr>
	</table>
</form>
<form name="hiddenForm" action="DSCFolderCheck.jsp" method="post">

<%
boolean csrfEnabled1 = ENOCsrfGuard.isCSRFEnabled(context);
if(csrfEnabled1)
{
  Map csrfTokenMap1 = ENOCsrfGuard.getCSRFTokenMap(context, session);
  String csrfTokenName1 = (String)csrfTokenMap1.get(ENOCsrfGuard.CSRF_TOKEN_NAME);
  String csrfTokenValue1 = (String)csrfTokenMap1.get(csrfTokenName1);
%>
  <!--XSSOK-->
  <input type="hidden" name= "<%=ENOCsrfGuard.CSRF_TOKEN_NAME%>" value="<%=csrfTokenName1%>" />
  <!--XSSOK-->
  <input type="hidden" name= "<%=csrfTokenName1%>" value="<%=csrfTokenValue1%>" />
<%
}
//System.out.println("CSRFINJECTION");
%>

   <input type="hidden" name="objectId" value="">
   <input type="hidden" name="fullPath" value="">
   <input type="hidden" name="nodeId" value="">
   <input type="hidden" name="applyToChild" value="">
</form>
<form name="parentTypeCheckForm" action="MCADCreateFolderParentTypeCheck.jsp" target="hiddenFrame" method="post">

<%
boolean csrfEnabled2 = ENOCsrfGuard.isCSRFEnabled(context);
if(csrfEnabled2)
{
  Map csrfTokenMap2 = ENOCsrfGuard.getCSRFTokenMap(context, session);
  String csrfTokenName2 = (String)csrfTokenMap2 .get(ENOCsrfGuard.CSRF_TOKEN_NAME);
  String csrfTokenValue2 = (String)csrfTokenMap2.get(csrfTokenName2);
%>
  <!--XSSOK-->
  <input type="hidden" name= "<%=ENOCsrfGuard.CSRF_TOKEN_NAME%>" value="<%=csrfTokenName2%>" />
  <!--XSSOK-->
  <input type="hidden" name= "<%=csrfTokenName2%>" value="<%=csrfTokenValue2%>" />
<%
}
//System.out.println("CSRFINJECTION");
%>

   <input type="hidden" name="objectId" value="">
</form>
  <iframe name="hiddenFrame" src="../common/emxBlank.jsp" height="1" width="1" noresize="noresize" marginheight="0" marginwidth="0" frameborder="0" scrolling="no">
	</iframe>
  </body>
</html>
