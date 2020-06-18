<%--  emxRefreshSubscriptionsList.jsp
   Copyright (c) 2000-2018 - 2008 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxRefreshSubscriptionsList.jsp.rca 1.1.7.5 Wed Oct 22 16:18:03 2008 przemek Experimental przemek $
--%>

<html>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="javascript">
  if(parent.getWindowOpener())
  {
  if(parent.getWindowOpener().refreshPage)
  	parent.getWindowOpener().document.location.href = parent.getWindowOpener().document.location.href;
  }
  else
  {
  	getTopWindow().getWindowOpener().location.href=getTopWindow().getWindowOpener().location.href;
  	getTopWindow().closeWindow();
  }
  
  window.closeWindow();
</script>

</html>
