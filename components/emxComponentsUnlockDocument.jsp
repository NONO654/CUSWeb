<%--  emxComponentUnlockDocument.jsp   -

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxComponentsUnlockDocument.jsp.rca 1.9 Wed Oct 22 16:17:58 2008 przemek Experimental przemek $
--%>

<%@include file = "../emxUICommonAppInclude.inc"%>

<%
  //get document Id
  String objectId = emxGetParameter(request, "objectId");

  //get forward to page
  String returnTo = emxGetParameter(request, "returnTo");

  if (objectId != null) {

  //build business object/open/unlock/close
  BusinessObject document = new BusinessObject(objectId);
  document.open(context);
  if (document.isLocked(context)){
    //unlock it if locked
    document.unlock(context);
  }
  document.close(context);
%>
<html>
<body>

<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>       
<script language="Javascript" >
//if(getTopWindow().getWindowOpener())
//{
//  refreshTreeDetailsPage();
//}  
  var frameContent;
  if(getTopWindow().getWindowOpener()) {
    frameContent = findFrame(getTopWindow().getWindowOpener().getTopWindow(),"detailsDisplay");
  } else {
    frameContent = findFrame(getTopWindow(),"detailsDisplay");
  }
  
  frameContent.document.location.href = frameContent.document.location.href;
  
  if(getTopWindow().getWindowOpener()) {
    getTopWindow().closeWindow();
  }
  //var frameContent = findFrame(parent,"listDisplay");
  //frameContent.document.location.href = frameContent.document.location.href;
  //getTopWindow().close();
  //refreshTreeDetailsPage();

</script>

</body>
</html>


<%
  } //check if doc Id is null
%>
