<%--
  emxRouteSummaryTaskEscalationProcess.jsp --

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $ Exp $
--%>
<%@ include file = "../emxUICommonAppInclude.inc"%>
<%@ include file = "emxMemberListUtilAppInclude.inc"%>

<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="javascript" src="../common/scripts/emxUIModal.js"></script>
<script language="javascript" src="../emxUIPageUtility.js"></script>

<%
  String initSource = emxGetParameter(request,"initSource");
  if (initSource == null){
    initSource = "";
  }
  String jsTreeID  = emxGetParameter(request,"jsTreeID");
  String suiteKey  = emxGetParameter(request,"suiteKey");

String[] sRouteIds   = ComponentsUIUtil.getSplitTableRowIds(request.getParameterValues("emxTableRowId"));
String strRouteIds="";
if(sRouteIds!=null){
        for (int i=0;i<sRouteIds.length;i++){
                strRouteIds+=sRouteIds[i]+"~";
        }
}
%>
<script language="javascript" >
        emxShowModalDialog('emxTaskEscalationDialogFS.jsp?routeIds=<%=XSSUtil.encodeForURL(context, strRouteIds)%>&fromPage=Process&jsTreeID=<%=XSSUtil.encodeForURL(context, jsTreeID)%>&suiteKey=<%=XSSUtil.encodeForURL(context, suiteKey)%>&initSource=<%=XSSUtil.encodeForURL(context, initSource)%>',460, 360);
</script>
