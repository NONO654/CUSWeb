<%-- emxComponentDeleteRouteTableProcess.jsp
  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxComponentDeleteRouteTableProcess.jsp.rca 1.9 Wed Oct 22 16:17:54 2008 przemek Experimental przemek $
--%>
<%@ include file = "../emxUICommonAppInclude.inc"%>
<%@ include file = "emxMemberListUtilAppInclude.inc"%>

<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="javascript" src="../common/scripts/emxUIModal.js"></script>
<script language="javascript" src="../emxUIPageUtility.js"></script>
<body>

<%
  String portalMode = emxGetParameter(request,"portalMode");
  String[] sRouteIds   = emxGetParameterValues(request, "emxTableRowId");
  String objectId = emxGetParameter(request,"objectId");

  String strRouteIds="";
  if(sRouteIds!=null){
    for (int i=0;i<sRouteIds.length;i++){
      strRouteIds+=sRouteIds[i]+"~";
    }
  }
%>
<script language="Javascript" >
  emxShowModalDialog('emxRouteDeleteDialogFS.jsp?routeId=<%=XSSUtil.encodeForURL(context, strRouteIds)%>&objectId=<%=XSSUtil.encodeForURL(context, objectId)%>&portalMode=<%=XSSUtil.encodeForURL(context, portalMode)%>',460, 360);
</script>

</body>
