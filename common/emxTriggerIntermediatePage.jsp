 <%-- emxTriggerIntermediatePage.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxTriggerIntermediatePage.jsp.rca 1.13.3.2 Wed Oct 22 15:47:56 2008 przemek Experimental przemek $
--%>

<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>

<html>

<%

  String objectId = emxGetParameter(request,"objectId");
  String[] sCheckBoxArray = (String[])emxGetParameterValues(request, "emxTableRowId");
  StringBuffer sbSelectedObjectId = new StringBuffer();
  String strMultipleObejct = emxGetParameter(request,"multipleObjects");
  String strSubHeader = "emxFramework.TriggerValidationReport.Header.Multiple_Objects";
  if(strMultipleObejct==null || "false".equalsIgnoreCase(strMultipleObejct))
  {
      String strObjectId = emxGetParameter(request,"objectId");
      if(strObjectId!=null && strObjectId.length()>0)
      {
          com.matrixone.apps.domain.DomainObject domainObj = com.matrixone.apps.domain.DomainObject.newInstance(context,strObjectId);
          String stateName=domainObj.getInfo(context,com.matrixone.apps.domain.DomainConstants.SELECT_CURRENT);
          String policyName=domainObj.getInfo(context,com.matrixone.apps.domain.DomainConstants.SELECT_POLICY);
          com.matrixone.apps.domain.util.i18nNow loc = new com.matrixone.apps.domain.util.i18nNow();
          String i18State=loc.getStateI18NString(policyName, stateName, context.getLocale().getLanguage());
          strSubHeader = domainObj.getType(context) + " " + domainObj.getName(context) + " (" + i18State + ")";
          domainObj.close(context);
      }
  }
  for(int i=0;i<sCheckBoxArray.length;i++)
  {
      if(i!=0)
      {
          sbSelectedObjectId.append(",");
      }
      sbSelectedObjectId.append(sCheckBoxArray[i]);

  }
  
  
  String postvalue = "&table=AEFTriggerValidationReport&program=emxTriggerValidationResults:getTriggerResults&results=&emxTableRowId=" + XSSUtil.encodeForURL(context, sbSelectedObjectId.toString());
  
  //clear the output buffer
%>
<head>
<script language="JavaScript" src="scripts/emxUIConstants.js"></script>
<script language="JavaScript" src="scripts/emxUICore.js"></script>
<script language="JavaScript" src="scripts/emxUICoreMenu.js"></script>
<script language="JavaScript" src="scripts/emxUIToolbar.js"></script>
<script language="JavaScript" src="scripts/emxUITableUtil.js"></script>
<script language="JavaScript">
   
	var selectedId = '<xss:encodeForJavaScript><%=sbSelectedObjectId.toString()%></xss:encodeForJavaScript>';
	var subHeader = '<%=XSSUtil.encodeForJavaScript(context,strSubHeader)%>';
	var multipleObject = '<xss:encodeForJavaScript><%=strMultipleObejct%></xss:encodeForJavaScript>';
	var holdIds = "";
	 parent.frames[0].location.href = "emxTriggerValidationStatus.jsp";
	 //parent.frames[2].location.href = "emxBlank.jsp";
	 
	function getAsyncXMLData (fnCallback,url, postdata) 
	{
		var oRequest = emxUICore.createHttpRequest();
	    oRequest.open("post", url, true);
	    oRequest.setRequestHeader("Content-Type", "application/x-www-form-urlencoded"); 
	    oRequest.setRequestHeader("charset", "UTF-8"); 
	    oRequest.onreadystatechange = function() {
	    	if (oRequest.readyState == 4) {
	            fnCallback(oRequest.responseText);
	        }
	    }
    	oRequest.send(postdata);
	}
	 
	 function init()
	 {	 
	 
	 	//objHTTP = emxUICore.createHttpRequest();
        
       // emxUICore.getAsyncXMLData(objHTTP, callback, levelId, strURL, sPostData);
        //XSSOK
        getAsyncXMLData(callback,"emxTriggerValidationProcess.jsp", "<%=postvalue%>");
	 	// var response = emxUICore.getXMLDataPost("emxTriggerValidationProcess.jsp", "<%=postvalue%>");
	 	// var data = emxUICore.selectSingleNode(response.documentElement, "/mxRoot/data");
 		// var text = emxUICore.getText(data);	 
	 	// callback(text);		
	 }
	 
	 function callback(response)
	 {	 	
	 	var respDOM = emxUICore.createXMLDOM();
        respDOM.loadXML(response);
        emxUICore.checkDOMError(respDOM);       
        
	    var data = emxUICore.selectSingleNode(respDOM.documentElement, "/mxRoot/data");
 		var results = emxUICore.getText(data);
 		 
	 	document.processingForm.results.value= results;
	 	document.processingForm.action= "emxIndentedTable.jsp?&header=emxFramework.TriggerValidationReport.Header.Promote_Trigger_Vlidation_Report&subHeader="+subHeader+"&customize=false&CancelLabel=emxFramework.IconMail.Button.Close&CancelButton=true&Style=dialog&triggerValidation=false&showClipboard=false&massPromoteDemote=false&HelpMarker=emxhelptriggervalidationreport";
	 	document.processingForm.method ="post";
		document.processingForm.target = '_top';
		document.processingForm.submit();
	 	
	 } 

	 
</script>
</head>
<body onload ='init()'> 
<form name ="errorForm">
	</form>
	<form name = "processingForm">
		<input type="hidden" value ='<xss:encodeForHTMLAttribute><%=sbSelectedObjectId.toString()%></xss:encodeForHTMLAttribute>' name ="emxTableRowId" id = "emxTableRowId" />
		<input type="hidden" value ='AEFTriggerValidationReport' name ="table" id = "table" />
		<input type="hidden" value ='emxTriggerValidationResults:getTriggerResults' name ="program" id = "program" />
		<input type="hidden" value ='' name ="results" id = "results" />
	</form>	
</body>
</html>
