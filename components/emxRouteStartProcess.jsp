<%--  emxRouteStartProcess.jsp  --  Starting the Route process

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxRouteStartProcess.jsp.rca 1.19 Wed Oct 22 16:17:58 2008 przemek Experimental przemek $
 --%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxRouteInclude.inc"%>
<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>

<%
  String routeId = emxGetParameter(request, "routeId").trim();
  String sState = emxGetParameter(request, "Stage");
  String portalMode = emxGetParameter(request,"portalMode");
  BusinessObject busRoute = new BusinessObject(routeId);
  if(sState.equals("start")) {
    try{

      //set the RPE Variable
      String treeMenu = JSPUtil.getApplicationProperty(context,application,"eServiceComponents.treeMenu.InboxTask");
      if(treeMenu != null && !"".equals(treeMenu)){
        MQLCommand mql = new MQLCommand();
        mql.open(context);
        String mqlCommand = "set env global MX_TREE_MENU " + treeMenu;
        mql.executeCommand(context, mqlCommand);
        mql.close(context);
      }

      busRoute.open(context);
      busRoute.promote(context);
      busRoute.close(context);
      InboxTask.setTaskTitle(context, routeId);

   } catch (Exception ex ) {
     session.putValue("error.message",ex);
     // System.out.println(ex.getMessage());
   }
 }
 StringBuffer treeUrl = new StringBuffer(128);
 treeUrl.append(UINavigatorUtil.getCommonDirectory(context));
 treeUrl.append("/emxTree.jsp?emxSuiteDirectory=");
 treeUrl.append(XSSUtil.encodeForURL(context, appDirectory));
 treeUrl.append("&objectId=");
 treeUrl.append(XSSUtil.encodeForURL(context, routeId));



%>
<script language="javascript">
  
  var tree = parent.window.getWindowOpener().getTopWindow().tempTree;
  if(parent.window.getWindowOpener().parent.parent.frames[0].name == "emxUITreeFrame"){
    //XSSOK
    parent.window.getWindowOpener().parent.parent.location.href = "<%=treeUrl.toString()%>&mode=insert&jsTreeID="+tree.getSelectedNode().nodeID;
  }else if ('true' == '<%=XSSUtil.encodeForJavaScript(context, portalMode)%>'){
    var tabFrame = findFrame(getTopWindow().getWindowOpener().parent,"listDisplay");
    if(tabFrame != 'undefined' && tabFrame != null){
      tabFrame.parent.document.location.href = tabFrame.parent.document.location.href;
    }
  }else{
    parent.window.getWindowOpener().getTopWindow().refreshTablePage();
  }
  window.closeWindow();
</script>
