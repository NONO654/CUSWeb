<%-- (c) Dassault Systemes, 2007, 2008 --%>
<%--
  Displays the Impact Graph.
--%>


<%@page import="com.matrixone.apps.domain.util.ContextUtil"%>
<%@page import="com.dassault_systemes.smaslm.matrix.web.ImpactUtil"%>
<%@page import="com.dassault_systemes.smaslm.matrix.common.SimulationUtil" %>
<%@page import = "com.dassault_systemes.smaslm.matrix.web.ErrorUtil"%>

<html>

<%@include file="../common/emxNavigatorInclude.inc"%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>

<head>
<%@include file="../common/emxUIConstantsInclude.inc"%>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
</head>

<body>
Setting Object up-to-date

<%
  String locale = context.getSession().getLanguage();
  String noFrame = SimulationUtil.getI18NString(context,
    "Error.ImpactGraph.noFrame" );
  String nodeId = emxGetParameter(request, "nodeId");
  String objectId = emxGetParameter(request, "objectId");
  DomainObject obj = new DomainObject();
  obj.setId(objectId);
  boolean isObjLocked = obj.isLocked(context);
  User locker = obj.getLocker(context);
  String lockerName = "";
  if (locker != null)
  {
      lockerName = locker.getName();
  }

  try
  {
      if(isObjLocked && !(lockerName.equalsIgnoreCase(context.getUser())))
      {
          String[] tnr = SimulationUtil.getTNR(context, objectId);
          String retVal =
              SimulationUtil.getI18NString(context,
                  "Error.SetUpToDate.Locked",
                  "Type", tnr[0], "Name", tnr[1],
                  "User", lockerName);
          throw new Exception(retVal);
      }

      else
          ImpactUtil.setObjectUpToDate(context, objectId);
  }
  catch (Exception ex)
  {
      String msg = ErrorUtil.getMessage(ex).trim();
      if (msg.length() > 0)
      {
          emxNavErrorObject.addMessage(msg);
      }
  }

  String timeStamp = emxGetParameter(request, "timeStamp");
  int scrOfX = 0;
  int scrOfY = 0;
  String scrOff = emxGetParameter(request, "scrOfX");
  if (scrOff != null)
  {
      scrOfX = Integer.parseInt(scrOff);
  }
  scrOff = emxGetParameter(request, "scrOfY");
  if (scrOff != null)
  {
      scrOfY = Integer.parseInt(scrOff);
  }

%>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>

<script>
    var fromOpener = false;
    var targetFrame = findFrame(getTopWindow(), 'impactGraphContent');
    if (targetFrame == null)
    {
        targetFrame = findFrame(getTopWindow().getWindowOpener().getTopWindow(), 'impactGraphContent');
        if (targetFrame != null)
            fromOpener = true;
    }
    if (targetFrame == null)
    {
        alert("<%=noFrame %>");
    }
    else
    {

      var impactgraphExcludeFld = sessionStorage.getItem('impactgraphExcludeFolders');
      var pageRef = '../simulationcentral/smaImpactGraphDisplay.jsp'
              + '?emxSuiteDirectory=simulationcentral'
              + '&suiteKey=SimulationCentral'
              + '&action=refreshObject'
              + '&objectId=<%=nodeId%>'
              + '&timeStamp=<%=timeStamp%>'
              + '&excludeFolders='+ impactgraphExcludeFld;
      pageRef += '&scrOfX=<%=scrOfX%>';
      pageRef += '&scrOfY=<%=scrOfY%>';


      targetFrame.location.href = pageRef;
      // set the focus to new window
      targetFrame.getTopWindow().focus();
    }

    if (fromOpener)
    {
        getTopWindow().closeWindow();
    }
</script>

<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
