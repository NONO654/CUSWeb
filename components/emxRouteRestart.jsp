<%--  emxRouteRestart.jsp   -   The page will restart the route in "Resume Process" functionality

   Copyright (c) 1992-2018 Dassault Systemes.All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxRouteRestart.jsp.rca 1.2.3.2 Wed Oct 22 16:17:51 2008 przemek Experimental przemek $
--%>
<%@include file="../common/emxNavigatorInclude.inc"%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file="../emxUICommonHeaderBeginInclude.inc"%>
<%@include file="../emxUICommonHeaderEndInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>

<%
    try {
        String strRouteId = emxGetParameter(request, "objectId");
        com.matrixone.apps.common.Route rtObj   = new com.matrixone.apps.common.Route();
        rtObj.setId(strRouteId);
        rtObj.reStartRoute(context,rtObj);
    } catch (Exception ex) {
         ex.printStackTrace();

         if (ex.toString() != null && ex.toString().length() > 0) {
            emxNavErrorObject.addMessage(ex.toString());
         }
    }
%>

<%@include file="../common/emxNavigatorBottomErrorInclude.inc"%>
<%@include file="../emxUICommonEndOfPageInclude.inc"%>

<html>
<body>
<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<script language="javascript">
 
  //Refresh grahical task tab in portal
  var frameContent = emxUICore.findFrame(getTopWindow(), "APPTasksGraphical");
  frameContent = frameContent ?(frameContent.location.href == "about:blank" ? emxUICore.findFrame(getTopWindow(), "APPTask"):frameContent):null;
  if(frameContent != null ){
    frameContent.location.href = frameContent.location.href;        	
  }  
  window.parent.location.href = window.parent.location.href;
  
</script>
</body>
</html>
