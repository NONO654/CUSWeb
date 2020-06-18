<%--  emxImageManagerUploadProcess.jsp -- To refresh the page once the upload process is sucsses.
  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program
   
--%>
<html>
<body>
<%
	String message = (String)session.getValue("error.message");
	boolean showAlert = message != null && !message.equals("") && !message.equals("null");
	session.removeValue("error.message");
%>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script> 
<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script> 
<script language="Javascript">  
  if("<%=showAlert%>" == "true") {
  	alert("<xss:encodeForJavaScript><%=message%></xss:encodeForJavaScript>");
  } else {
	  var frameContent = findFrame(getTopWindow().getWindowOpener().getTopWindow(), "detailsDisplay");
	  if (frameContent != null ) {
  		frameContent.document.location.href = frameContent.document.location.href;
	  } else {
	  	getTopWindow().getWindowOpener().parent.document.location.href = getTopWindow().getWindowOpener().parent.document.location.href;
  	  }
  }
  getTopWindow().closeWindow();
</script>
</body>
</html>

