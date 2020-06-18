<%--  emxBlank.jsp   - Page for poping up a window from an actin link page

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxAEFSubmitPopupAction.jsp.rca 1.8 Tue Oct 28 22:59:40 2008 przemek Experimental przemek $
--%>
<%@include file = "emxNavigatorInclude.inc"%>

<html>
<%
  String strURL = emxGetParameter(request,"url");
  String portalMode = emxGetParameter(request, "portalMode");
  String portalFrame = emxGetParameter(request, "portalFrame");
  String parentFrame = emxGetParameter(request, "parentFrame");
  String curFrameName = "";
  if("true".equalsIgnoreCase(portalMode)){
	  curFrameName = portalFrame;
  } else {
	 curFrameName = emxGetParameter(request, "frameName");
  }
 
%>
<head><title><head><title><xss:encodeForHTML> <%=sAppName%> </xss:encodeForHTML></title>
<script language="JavaScript" src="scripts/emxUICore.js" type="text/javascript"></script>
<script language="JavaScript" src="scripts/emxUIModal.js" type="text/javascript"></script>
<script language="JavaScript" src="scripts/emxUIConstants.js" type="text/javascript"></script>
<script language="javascript">
var strURL="<%=XSSUtil.encodeForJavaScript(context, strURL)%>";
var curFrameName="<%=XSSUtil.encodeForJavaScript(context, curFrameName)%>";
var portalFrame="<%=XSSUtil.encodeForJavaScript(context, portalFrame)%>";
var parentFrame="<%=XSSUtil.encodeForJavaScript(context, parentFrame)%>";
function submitSpecialForm()
{
    var objListWindow = null;
    var detailsDisppalyFrame = findFrame(parent, "detailsDisplay");
    
    if(portalFrame != null && portalFrame != "null" && portalFrame != ""){
    	objListWindow = emxUICore.findFrame(parent, portalFrame);
    	if(detailsDisppalyFrame){
    		objListWindow = findFrame(detailsDisppalyFrame, portalFrame);
    	}
    	
    }
    if(curFrameName != null && curFrameName != "null" && curFrameName != ""){
    	objListWindow = findFrame(parent, curFrameName);   
    	if(detailsDisppalyFrame){
    		objListWindow = findFrame(detailsDisppalyFrame, curFrameName);
    	}
    	var objListSlideWindow = null;
    	objListSlideWindow = findFrame(objListWindow, "listDisplay");
		if(!objListSlideWindow){
			  objListSlideWindow = findFrame(objListWindow, "formViewDisplay");
		 }	
		 if(!objListSlideWindow){
			  objListSlideWindow = findFrame(objListWindow, "formEditDisplay");
		 }  
		objListWindow = objListSlideWindow ? objListSlideWindow : objListWindow;
    }
    if(parentFrame != null && parentFrame != "null" && parentFrame != ""){
   		var objParentFrame = findFrame(parent, parentFrame);
   		objListWindow = openerFindFrame(objParentFrame, portalFrame);
    }
    
	if (!objListWindow) 
	{
		objListWindow = findFrame(parent, curFrameName);
		if (!objListWindow) {
		objListWindow = findFrame(parent, "formViewDisplay");
	    }
	    if (!objListWindow) {
	        objListWindow = parent.frames['formEditDisplay'];
	    }
	    
	    if (!objListWindow) {
	        objListWindow = findFrame(parent, "listDisplay");
	    }
	    if (!objListWindow) {
	        objListWindow = findFrame(parent, "detailsDisplay");
	    }
	    
	    if (!objListWindow) {
	        objListWindow = findFrame(parent, "content");
	    }
	}

	var objForm = objListWindow.document.forms['emxSubmitForm'] ? objListWindow.document.forms['emxSubmitForm'] : objListWindow.document.forms[0];
	if (!objForm) {
		objForm = document.forms["emxTableForm"];
	}

	if (objForm.timeStamp) {
		strURL += "&timeStamp=" + objForm.timeStamp.value;
	}

	//Added for Bug : 353307
	var rmbFormParent = objListWindow.document.body;
	if (strURL.indexOf("isFromRMB=true") > 0) {
		objForm = emxUICore.clonedForm(objForm, rmbFormParent);
	}

	objForm.target = window.name;
	objForm.action = strURL+"&openerFrame="+curFrameName;
	objForm.method = "post";
	
	addSecureToken(objForm);
	objForm.submit();
	removeSecureToken(objForm);

	if (strURL.indexOf("isFromRMB=true") > 0) {
		rmbFormParent.removeChild(objForm);
	}
}
</script>
</head>

<body topmargin="0" marginheight="0" leftmargin="0" marginwidth="0" onload="submitSpecialForm()">
</body>
</html>
