<%-- (c) Dassault Systemes, 2007, 2008 --%>
<%--
  Displays the Impact Graph.
--%>


<html>

<%@include file="../common/emxNavigatorInclude.inc"%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>

<%@page import="com.dassault_systemes.smaslm.matrix.web.ImpactGraphUI"%>
<%@page import = "com.dassault_systemes.smaslm.matrix.web.ErrorUtil"%>
<%@page import="com.dassault_systemes.smaslm.matrix.web.SlmUIUtil"%>
<%@page import="com.dassault_systemes.smaslm.matrix.server.SimulationContentUtil"%>
<%@page import="com.matrixone.apps.domain.util.ContextUtil"%>
<%@page import="com.matrixone.apps.framework.ui.UINavigatorUtil"%>
<%@page import="com.matrixone.apps.domain.util.i18nNow"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.HashMap"%>
<%@page import="java.util.Iterator"%>
<%@page import="java.util.ListIterator"%>
<%@ page import ="com.matrixone.apps.domain.util.EnoviaResourceBundle" %>

<head>
<title>Impact Graph</title>
<%@include file="../common/emxUIConstantsInclude.inc"%>
<%@include file="../emxStyleDefaultInclude.inc"%>

<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script src="../common/scripts/emxUIModal.js"></script>
<script>
  addStyleSheet("emxUIMenu");
</script>

<link rel="stylesheet" type="text/css"
      href="styles/smaImpactGraph.css" />

</head>

<body class="content" onload="turnOffProgress();">
<%
final String i18nLang = request.getHeader("Accept-Language");
final String ResourceFile = "smaSimulationCentralStringResource";
Locale loc = context.getLocale();
  String timeStamp = emxGetParameter(request, "timeStamp");
  ImpactGraphUI impactGraph = ImpactGraphUI.getImpactGraph(context,timeStamp);

  String physicalId = emxGetParameter(request, "physicalId");
  String objectId = null;
  if(physicalId != null && (!physicalId.equals(""))){
  	DomainObject obj = DomainObject.newInstance(context,physicalId);
  	obj.openObject(context);
  	objectId = obj.getInfo(context,"id");
  }

  if(objectId == null || objectId.equals(""))
      objectId = emxGetParameter(request, "objectId");

  String excludeFolders = emxGetParameter(request, "excludeFolders");
  if(excludeFolders == null || excludeFolders.equals(""))
  {
	  excludeFolders = "false";
  }


  //Array of arrayLists each arrayList represents row for HTMl table.
  ArrayList igTable = null;

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

  int startingGraphWidth = impactGraph.getGraphWidth();
  String side = emxGetParameter(request, "side");
  if (side == null)
      side = "";

  String action = emxGetParameter(request, "action");
  if (action == null  ||  action.length() == 0)
  {
      impactGraph.reset();
      action = "ExpandObject";
  }

  String dirStr = emxGetParameter(request, "direction");

  boolean expandOperation = false;
  boolean collapseOperation = false;

  if ("ExpandObject".equals(action))
  {
      expandOperation = true;

      int direction = 0;
      if (dirStr == null  ||  dirStr.length() == 0)
      {
          direction = ImpactGraphUI.EXPAND_INPUT
              + ImpactGraphUI.EXPAND_OUTPUT;
      }
      else
      {
          if ("Input".equals(dirStr))
          {
              direction = ImpactGraphUI.EXPAND_INPUT;
          }
          else if ("Output".equals(dirStr))
              direction = ImpactGraphUI.EXPAND_OUTPUT;
      }

      try
      {

          igTable = impactGraph.expandObject(context,
              objectId, direction , excludeFolders);

      }
      catch (Exception ex)
      {
          String msg = ErrorUtil.getMessage(ex).trim();
          if (msg.length() > 0)
          {
              emxNavErrorObject.addMessage(msg);
          }
      }
  }
  else if ("collapseObject".equals(action))
  {
      collapseOperation = true;

      try
      {

           igTable = impactGraph.collapseObject(context,
               objectId );

      }
      catch (Exception ex)
      {
          String msg = ErrorUtil.getMessage(ex).trim();
          if (msg.length() > 0)
          {
              emxNavErrorObject.addMessage(msg);
          }
      }
  }
  else if ("collapseInputs".equals(action))
  {
      collapseOperation = true;

      try
      {
          igTable = impactGraph.collapseInputs(context,
              objectId);
      }
      catch (Exception ex)
      {
          String msg = ErrorUtil.getMessage(ex).trim();
          if (msg.length() > 0)
          {
              emxNavErrorObject.addMessage(msg);
          }
      }
  }
  else if ("collapseOutputs".equals(action))
  {
      collapseOperation = true;

      try
      {
          igTable = impactGraph.collapseOutputs(context,
              objectId);
      }
      catch (Exception ex)
      {
          String msg = ErrorUtil.getMessage(ex).trim();
          if (msg.length() > 0)
          {
              emxNavErrorObject.addMessage(msg);
          }
      }
  }
  else if ("refreshObject".equals(action))
  {
      try
      {
          igTable = impactGraph.refreshGraph(context , excludeFolders);
      }
      catch (Exception ex)
      {
          String msg = ErrorUtil.getMessage(ex).trim();
          if (msg.length() > 0)
          {
              emxNavErrorObject.addMessage(msg);
          }
      }
  }

  if (side.equals("left"))
  {
      int newGraphWidth = impactGraph.getGraphWidth();

      if (newGraphWidth != startingGraphWidth)
      {
          if (expandOperation)
          {
              scrOfX += 50 * (newGraphWidth - startingGraphWidth);
          }
          else if (collapseOperation)
          {
              scrOfX -= 50 * (startingGraphWidth - newGraphWidth);
          }
      }
  }
%>


<script>
function getScrollXY()
{
  var scrOfX = 0, scrOfY = 0;
  if ( typeof( window.pageYOffset ) == 'number' )
  {
    //Netscape compliant
    scrOfY = window.pageYOffset;
    scrOfX = window.pageXOffset;
  }
  else if ( document.body
           && ( document.body.scrollLeft || document.body.scrollTop ) )
  {
    //DOM compliant
    scrOfY = document.body.scrollTop;
    scrOfX = document.body.scrollLeft;
  }
  else if ( document.documentElement
           && ( document.documentElement.scrollLeft || document.documentElement.scrollTop ) )
  {
    //IE6 standards compliant mode
    scrOfY = document.documentElement.scrollTop;
    scrOfX = document.documentElement.scrollLeft;
  }
  return [ scrOfX, scrOfY ];
}

<%-- Handles the click of the expand icon.
  --%>
function expandObject(href)
{
	var impactgraphExcludeFolders = sessionStorage.getItem('impactgraphExcludeFolders');

    var pageRef = '../simulationcentral/smaImpactGraphDisplay.jsp'
            + '?emxSuiteDirectory=simulationcentral'
            + '&suiteKey=SimulationCentral'
            + '&timeStamp=<%=timeStamp%>' + '&excludeFolders='+ impactgraphExcludeFolders;


    var scrollXY = getScrollXY();
    pageRef += '&scrOfX=' + scrollXY[0];
    pageRef += '&scrOfY=' + scrollXY[1];
    pageRef += '&';

    turnOnProgress();
    <%-- the progress symbol is automatically turned off when the
    --   update page loads.
    --%>
    var targetFrame = findFrame(getTopWindow(), 'impactGraphContent');
    targetFrame.location.href = pageRef + href;
    // set the focus to new window
    targetFrame.getTopWindow().focus();
}

<%-- Handles the click of the "set up to date" icon.
  --%>
function setObjectUpToDate(nodeId, objectId)
{
    var url = '../simulationcentral/smaSetObjectUpToDateStatus.jsp'
            + '?nodeId=' + nodeId
            + '&objectId=' + objectId
            + '&emxSuiteDirectory=simulationcentral'
            + '&suiteKey=SimulationCentral'
            + '&timeStamp=<%=timeStamp%>';
    var scrollXY = getScrollXY();
    url += '&scrOfX=' + scrollXY[0];
    url += '&scrOfY=' + scrollXY[1];

    turnOnProgress();
    var targetFrame = findFrame(getTopWindow(), 'hiddenImpactGraph');
    targetFrame.location.href = url;
}

<%-- Handles the links on the object names.
  --%>
function showObject(objectId)
{
  var url = '../common/emxNavigator.jsp?isPopup=true&mode=tree&mode=insert&objectId='+objectId;

  <%-- The width and height arguments are taken from --%>
  <%-- emxUIModal.js:showDetailsPopup() --%>
  var windowName = "ImpactGraph_" + objectId.replace(/\./g, "_");
  var windObj = showAndGetNonModalDialogWithName(url, windowName, 875, 550, false);
}
</script>


<table class="impactgraph">
  <tr><td><img src="../common/images/utilSpacer.gif"></td></tr>
<%
  if (igTable != null)
  {
    // Each element of igTable represents a row of a table.
    // Each row is an arraylist that contains the cells of that row.

    String expandStr =
        EnoviaResourceBundle.getProperty(context,ResourceFile,loc,"smaSimulationCentral.ImpactGraph.expand");
    String collapseStr =
        EnoviaResourceBundle.getProperty(context,ResourceFile,loc,"smaSimulationCentral.ImpactGraph.collapse");


    final int ROOT_COLUMN_INITIALIZER = 9999;
    int rootColumn = ROOT_COLUMN_INITIALIZER;
    Iterator tableIter = igTable.iterator();
    boolean onFirstRow = true;
    while (tableIter.hasNext())
    {
      ArrayList igRow = (ArrayList)tableIter.next();
%>
  <tr>
<%
      ListIterator rowIter = igRow.listIterator();
      int idx = -1;
      while (rowIter.hasNext())
      {
        idx += 1;
        Map objectMap = (Map)rowIter.next();

        if (rootColumn == ROOT_COLUMN_INITIALIZER
            && objectMap != null
            && objectMap.get(ImpactGraphUI.OBJECT_ROOT_KEY) != null)
        {
            rootColumn = idx;
        }

        // Get the relationship Map for this node.
        // However, the root node does not have a relationship Map.
        //
        Map relMap = null;
        if (idx != rootColumn  &&  rowIter.hasNext())
        {
            relMap = (Map)rowIter.next();
            idx += 1;
        }
        if (idx > rootColumn)
        {
            // On the output side, need to swap the order of objectMap
            // and relMap.
            Map temp = relMap;
            relMap = objectMap;
            objectMap = temp;
        }

        // Generate the table column output for the current object
        // and its relationship.
        // - When on the left side of the graph, the object is processed
        // - first. When on the right side of the graph, the
        // - relationship is processed first.
        // - So, the following for-loop eliminates having to duplicate
        // - the object and relationship processing.
        //
        for (int kx=0; kx<2; kx++)
        {
          // If on the left side of the graph, do the object first.
          // Otherwise, do the object second.
          if ((kx==0 && idx<=rootColumn)
              || (kx==1 && idx>rootColumn))
          {
            if (objectMap == null)
            {
                // No object here. Fill in a empty cell.
%>
<%-- IE v6 has a weakness whereby whitespace after the image      --%>
<%-- causes whitespace in the page display. This causes breaks in --%>
<%-- the branches of the graph.                                   --%>
<%-- Therefore, the html AND jsp code that occurs after an img    --%>
<%-- must be such that there is NO whitespace between the img and --%>
<%-- the trailing </td>                                           --%>

    <td class='ExpandBtnLeft'>
      <img src="../common/images/utilSpacer.gif" border="0"></td>
    <td class='IGObjectTypeEmpty'>
      <img src="../common/images/utilSpacer.gif" border="0"></td>
    <td class='IGObjectEmpty'>
      <img src="../common/images/utilSpacer.gif" border="0"></td>
    <td class='IGObjectStatusEmpty'>
      <img src="../common/images/utilSpacer.gif" border="0"></td>
    <td class='ExpandBtnRight'>
      <img src="../common/images/utilSpacer.gif" border="0"></td>
<%
                continue;
            }

            String nodeId = (String)
                objectMap.get(ImpactGraphUI.NODE_ID_KEY);
            String objectIdKey = (String)
                objectMap.get(ImpactGraphUI.OBJECT_ID_KEY);

            String typeName = (String)
                objectMap.get(ImpactGraphUI.OBJECT_TYPE_KEY);
            String title = (String)
                objectMap.get(impactGraph.OBJECT_TITLE_KEY);
            String name = (String)
                objectMap.get(ImpactGraphUI.OBJECT_NAME_KEY);
            String rev = (String)
                objectMap.get(ImpactGraphUI.OBJECT_REV_KEY);
            String kindofSimFoldersString = (String) objectMap.
                get(ImpactGraphUI.KINDOF_SIMULATION_FOLDERS_KEY);
            boolean kindofSimulationFolders = Boolean.valueOf(
                kindofSimFoldersString).booleanValue();

            if (title == null  ||  title.length() == 0)
            {
                title = name;
            }

            String inSyncStr = (String)
                objectMap.get(impactGraph.OBJECT_INSYNC_KEY);
            boolean inSync =
                "false".equalsIgnoreCase(inSyncStr) == false;

            String lockedStr = (String)
                objectMap.get(impactGraph.OBJECT_LOCKED_KEY);
            boolean objLocked = "true".equalsIgnoreCase(lockedStr);

            // The leftmost node is expandable on its left/input side.
            // The first node on this row is the leftmost node.
            String inputState = (String)
                objectMap.get(ImpactGraphUI.OBJECT_INPUTS_KEY);
            boolean leftIsExpand =
                ImpactGraphUI.IO_STATE_NOTEXPANDED.equals(inputState);

            // The rightmost node is expandable on its right/output side.
            // To determine if this is the rightmost node, must look at
            // the next column - if there is a non-empty next column,
            // then this is not the rightmost node.
            String outputState = (String)
                objectMap.get(ImpactGraphUI.OBJECT_OUTPUTS_KEY);
            boolean rightIsExpand =
                ImpactGraphUI.IO_STATE_NOTEXPANDED.equals(outputState);

            // Check if this object has an empty input or output branch
            // (input when on the left side of the graph and output when
            //  on the right side of the graph).
            // An empty branch is indicated by a marker property in
            // objectMap (a null value).
            //
            // The root gets treated as both an input side node and
            // and output side node.
            //
            boolean noInputToExpand = false;
            boolean noOutputToExpand = false;
            if (idx <= rootColumn)
            {
              // Processing the left (input) side of the graph
              // (or the root).

              String flag = (String)
                  objectMap.get(ImpactGraphUI.OBJECT_NOINPUTS_KEY);
              noInputToExpand = "true".equalsIgnoreCase(flag);
            }
            if (idx >= rootColumn)
            {
              // Processing the right (output) side of the graph
              // (or the root).

              String flag = (String)
                  objectMap.get(ImpactGraphUI.OBJECT_NOOUTPUTS_KEY);
              noOutputToExpand = "true".equalsIgnoreCase(flag);
            }

            String leftIcon = null;
            String leftTitle = null;
            String leftHref = null;
            // at this point, the left side includes root.
            if (idx <= rootColumn)
            {
              // processing the left side of the graph.
              if (noInputToExpand == false)
              {
                if (leftIsExpand)
                {
                    leftIcon = "iconPlus.gif";
                    leftTitle = expandStr;
                    leftHref =
                        "javascript:expandObject("
                        +"'action=ExpandObject&direction=Input"
                        +"&side=left"
                        +"&objectId=" + nodeId + "'"
                        + ")";
                }
                else
                {
                    leftIcon = "iconMinus.gif";
                    leftTitle = collapseStr;
                    leftHref =
                        "javascript:expandObject("
                        +"'action=collapseInputs"
                        +"&side=left"
                        +"&objectId=" + nodeId + "'"
                        + ")";
                }
              }
            }
            else
            {
              // processing the right side of the graph.
              leftIcon = "iconMinus.gif";
              leftTitle = collapseStr;
              leftHref =
                  "javascript:expandObject("
                  +"'action=collapseObject"
                  +"&side=right"
                  +"&objectId=" + nodeId + "'"
                  + ")";
            }

            String rightIcon = null;
            String rightTitle = null;
            String rightHref = null;
            // at this point, the left sides does NOT include root.
            if (idx < rootColumn)
            {
              // processing the left side of the graph.
              rightIcon = "iconMinus.gif";
              rightTitle = collapseStr;
              rightHref =
                  "javascript:expandObject("
                  +"'action=collapseObject"
                  +"&side=left"
                  +"&objectId=" + nodeId + "'"
                  + ")";
            }
            else
            {
              // processing the right side of the graph.
              if (noOutputToExpand == false)
              {
                if (rightIsExpand)
                {
                    rightIcon = "iconPlus.gif";
                    rightTitle = expandStr;
                    rightHref =
                        "javascript:expandObject("
                        +"'action=ExpandObject&direction=Output"
                        +"&side=right"
                        +"&objectId=" + nodeId + "'"
                        + ")";
                }
                else
                {
                    rightIcon = "iconMinus.gif";
                    rightTitle = collapseStr;
                    rightHref =
                        "javascript:expandObject("
                        +"'action=collapseOutputs"
                        +"&side=right"
                        +"&objectId=" + nodeId + "'"
                        + ")";
                }
              }
            }
%>
    <%-- Insert the left side expand image --%>
    <td class='ExpandBtnLeft'>
<%
    if (leftIcon == null)
    {
%>
      <img src="../common/images/utilSpacer.gif" border="0"></td>
<%
    }
    else
    {
%>
      <a href="<%=leftHref%>"><img src='images/<%=leftIcon%>'
         title='<%=leftTitle%>' alt='<%=leftTitle%>' border='0'></a></td>
<%
    }
%>
    <%-- End left side expand image --%>
    <%-- Insert type image for object --%>
<%
    // UINavigatorUtil.getTypeIconProperty() returns only a name,
    // no path.
    String typeImg = "../common/images/" +
        UINavigatorUtil.getTypeIconProperty(context, typeName);
    String typeTitle =
        UINavigatorUtil.getAdminI18NString(
            "Type", typeName, i18nLang);
	
	boolean isHigherRev = false;
    if(objectIdKey != null && objectIdKey.length() >0)
    {
        SimulationContentUtil simulationContentUtil = SimulationContentUtil.getInstance();
        if(!simulationContentUtil.isLastRevision(context,objectIdKey))
            isHigherRev = true;
    }		
    String objectClass;
    String typeClass;
    if (inSync)
    {
    	if (isHigherRev)
		{
			objectClass =
				(idx == rootColumn) ? "IGObjectRootHR" : "IGObjectHR";
			typeClass =
				(idx == rootColumn) ? "IGObjectTypeRootHR" : "IGObjectTypeHR";
		}	
		else
		{
			objectClass =
				(idx == rootColumn) ? "IGObjectRoot" : "IGObject";
			typeClass =
				(idx == rootColumn) ? "IGObjectTypeRoot" : "IGObjectType";
		}
    }
    else
    {
        objectClass =
            (idx == rootColumn) ? "IGObjectRootOos" : "IGObjectOos";
        typeClass =
            (idx == rootColumn) ? "IGObjectTypeRootOos" : "IGObjectTypeOos";
    }
%>
    <%-- Insert the type image for the object --%>
      <td style="padding:1px 0px 1px 1px;"
       ><div class="<%=objectClass%>" style="position:relative;border-radius: 5px 0px 0px 5px;-moz-border-radius: 5px 0px 0px 5px;-webkit-border-radius: 5px 0px 0px 5px;"
         ><div style="padding:2px 14px 2px 0px;"
           >&nbsp;<br>&nbsp;</div
            ><div class='<%=typeClass%>' style="padding: 2px 0px 2px 2px;position:absolute;top:5px;left:0px;z-index:2;"
              ><img src='<%=typeImg%>' title='<%=typeTitle%>'
                alt='<%=typeTitle%>' border='0' style="vertical-align:middle"></div></div></td>

    <%-- Insert title cell for object --%>
<%
    if (idx == rootColumn)
    {
    	String titleClass =
    			isHigherRev ? "IGObjectNameRootHR" : "IGObjectNameRoot";
    	      titleClass =
    	    		  inSync ? titleClass : "IGObjectNameRootOos";
%>
      <td style="padding:1px 0px 1px 0px;"
       ><div class="<%=objectClass%>" style=""
         ><div class='<%=titleClass%>' style="padding: 2px 3px 2px 3px;text-align:center;white-space:nowrap;"
           ><%=title%><br>rev: <%=rev%></div></div></td>
<%
    }
    else
    {
    	String titleClass =
    	          isHigherRev ? "IGObjectNameHR" : "IGObjectName";
    	      titleClass =
    	          inSync ? titleClass : "IGObjectNameOos";

      if (!kindofSimulationFolders)
      {
%>
      <td style="padding:1px 0px 1px 0px;"
       ><div id="<%= nodeId %>" class="<%=objectClass%>"
         ><div class='<%=titleClass%>' style="padding: 2px 3px 2px 3px;text-align:center;white-space:nowrap;"
           ><a href="javascript:showObject('<%= objectIdKey %>')"
             ><%=title%><br>rev: <%=rev%></a></div></div></td>
<%
      }
      else
      {
%>
      <td style="padding:1px 0px 1px 0px;"
       ><div id="<%= nodeId %>" class="<%=objectClass%>"
         ><div class='<%=titleClass%>' style="padding: 2px 3px 2px 3px;"
           ><table border="0" cellpadding="0" cellspacing="0">
              <tr>
                <td>&nbsp;</td>
                <td rowspan="2" style="width:100%;text-align:center;white-space:nowrap;"
                  ><%=title%></td>
              </tr>
              <tr><td>&nbsp;</td></tr>
            </table>
          </div></div></td>
<%
      }
    }
%>
    <%-- End insert title cell for object --%>
    <%-- Insert out-of-date image for object --%>
<%
    String alertImg;
    String alertTitle;
    String alertClass;
    boolean includeSetHref = false;
    if (inSync)
    {
        alertImg = "../common/images/utilSpacer.gif";
        alertTitle = "";
        alertClass =
            (idx == rootColumn) ? "IGObjectStatusRoot" : "IGObjectStatus";
    }
    else
    {
        if (objLocked == false)
        {
            alertImg = "../simulationcentral/images/smaIconOutOfDate.gif";
            alertTitle =
                EnoviaResourceBundle.getProperty(context,ResourceFile,loc,"smaSimulationCentral.ImpactGraph.ObjectAlert.Title");

            includeSetHref = true;
        }
        else
        {
            alertImg = "../common/images/utilSpacer.gif";
            alertTitle = "";
        }
        alertClass =
            (idx == rootColumn) ? "IGObjectStatusRootOos" : "IGObjectStatusOos";
    }
    String higherRevImg = "../common/images/utilSpacer.gif";
    String higherRevTitle = "";
    if (isHigherRev)
    {
        higherRevImg = "../common/images/iconSmallHigherRevision.gif";
        higherRevTitle =
          EnoviaResourceBundle.getProperty(context,ResourceFile,loc,"smaSimulationCentral.ImpactGraph.HigherRevision.Title");
    }
    if (includeSetHref)
    {
%>
      <%-- Insert the out-of-date image for the object --%>
      <td style="padding:1px 1px 1px 0px;"
       ><div class="<%=objectClass%>" style="position:relative;border-radius: 0px 5px 5px 0px;-moz-border-radius: 0px 5px 5px 0px;-webkit-border-radius: 0px 5px 5px 0px;"
         ><div style="padding:2px 14px 2px 0px;"
           >&nbsp;<br>&nbsp;</div
             ><div class='<%=alertClass%>' style="padding: 2px 2px 2px 0px;position:absolute;top:5px;left:0px;z-index:2;"
               ><a href="javascript:setObjectUpToDate('<%=nodeId%>', '<%=objectIdKey%>')"
                 ><img src='<%=alertImg%>' title='<%=alertTitle%>'
                    alt='<%=alertTitle%>' border='0'></a><img src='<%=higherRevImg%>' title='<%=higherRevTitle%>'
                    alt='<%=higherRevTitle%>' border='0'></div></div></td>
<%
    }
    else
    {
%>
      <%-- Insert the out-of-date image for the object --%>
      <td style="padding:1px 1px 1px 0px;"
       ><div class="<%=objectClass%>" style="position:relative;border-radius: 0px 5px 5px 0px;-moz-border-radius: 0px 5px 5px 0px;-webkit-border-radius: 0px 5px 5px 0px;"
         ><div style="padding:2px 14px 2px 0px;"
           >&nbsp;<br>&nbsp;</div
             ><div class='<%=alertClass%>' style="padding: 2px 2px 2px 0px;position:absolute;top:5px;left:0px;z-index:2;"
               ><img src='<%=alertImg%>' title='<%=alertTitle%>'
                  alt='<%=alertTitle%>' border='0'><img src='<%=higherRevImg%>' title='<%=higherRevTitle%>'
                  alt='<%=higherRevTitle%>' border='0'></div></div></td>
<%
    }
%>
    <%-- Insert the right side expand image --%>
    <td class='ExpandBtnRight'>
<%
    if (rightIcon == null)
    {
%>
      <img src="../common/images/utilSpacer.gif" border="0"></td>
<%
    }
    else
    {
%>
      <a href="<%=rightHref%>"><img src="images/<%=rightIcon%>"
         title='<%=rightTitle%>' alt='<%=rightTitle%>' border="0"></a></td>
<%
    }
%>
    <%-- End right side expand image --%>
<%
          }

          else
          {
            // Do the branch processing.

            if (idx == rootColumn)
                // There is no branch to process for the root column.
                continue;

            if (relMap == null)
            {
%>
    <td class='Branch'>
      <img src="../common/images/utilSpacer.gif" border="0"></td>
<%
                continue;
            }

            String relName = (String)
                relMap.get(ImpactGraphUI.REL_NAME_KEY);
            Integer branchInt = (Integer)
                relMap.get(ImpactGraphUI.BRANCH_TYPE_KEY);

            String inSyncStr = (String)
                relMap.get(impactGraph.REL_INSYNC_KEY);
            boolean inSync =
                "false".equalsIgnoreCase(inSyncStr) == false;

            /*
             * branch types:
             *   1) ----->  igRHorizontalArrowW38.gif
             *   2) --|-->  igRHorArrowMDnBranchW38.gif
             *   3) --|     igLHorRBranchW38.gif
             *   4) --'     igLHorRUpBranchW38.gif
             *   5)   |     igVerticalLineW38.gif
             *   6)   |-->  igRHorLBranchW38.gif
             *   7)   '-->  igRHorLUpBranchW38.gif
             *   8) --,     igLHorRDNBranchW38.gif
             *   9)   ,-->  igRHorLDNBranchW38.gif
             */

            String[] imageTable =
                          {
                             "",
                             "igRHorizontalArrowW38.gif",
                             "igRHorArrowMDnBranchW38.gif",
                             "igLHorRBranchW38.gif",
                             "igLHorRUpBranchW38.gif",
                             "igVerticalLineW38.gif",
                             "igRHorLBranchW38.gif",
                             "igRHorLUpBranchW38.gif",
                             "igLHorRDnBranchW38.gif",
                             "igRHorLDnBranchW38.gif"
                          };

            int branchType = branchInt.intValue();
            String branchImage = imageTable[branchType];

            String relTitle = "";
            if (relName != null)
            {
                relTitle =
                    UINavigatorUtil.getAdminI18NString("Relationship",
                        relName, i18nLang);
            }
%>
    <td class='Branch'><div style="position:relative">
      <img src="images/<%=branchImage%>" title='<%=relTitle%>'
           alt='<%=relTitle%>' border="0"><%
//<%
    if (inSync == false)
    {
      String imgName = "../simulationcentral/images/smaIconOutOfDate.gif";
      if (idx < rootColumn)
      {
          String markerTitle =
              EnoviaResourceBundle.getProperty(context,ResourceFile,loc,"smaSimulationCentral.ImpactGraph.InSyncMarkerInput.Title");
%><div class="InSyncMarkerInput"><img src='<%=imgName%>'
           alt='<%=markerTitle%>' title='<%=markerTitle%>'
           border='0'/></div></div><%
//<%
      }
      else
      {
          String markerTitle =
              EnoviaResourceBundle.getProperty(context,ResourceFile,loc,"smaSimulationCentral.ImpactGraph.InSyncMarkerOutput.Title");
%><div class="InSyncMarkerOutput"><img src='<%=imgName%>'
           alt='<%=markerTitle%>' title='<%=markerTitle%>'
           border='0'/></div></div><%
//<%
      }
    }
%></td>
<%

          } // if-else
        } // for (kx)
      } // while (rowIter)
%>
  </tr>
<%
      onFirstRow = false;
    } // while (tableIter)
  } // if (igTable)
%>
</table>

<script>
    function getOffsetLeft(element)
    {
        var offsetLeft = 0;

        for (node = element; node != null; node = node.parentNode)
        {
            if (node.offsetLeft != null)
            {
                offsetLeft += node.offsetLeft;
            }
        }

        return offsetLeft
    }

    function getOffsetTop(element)
    {
        var offsetTop = 0;

        for (node = element; node != null; node = node.parentNode)
        {
            if (node.offsetTop != null)
            {
                offsetTop += node.offsetTop;
            }
        }

        return offsetTop;
    }

    var scrollX = <%=scrOfX%>;
    var scrollY = <%=scrOfY%>;

<%if ("ExpandObject".equals(action)) { %>
    var element = document.getElementById('<%= objectId %>');

    var offsetLeft = 0;
    var offsetTop = 0;

    if (element != null)
    {
      offsetLeft = getOffsetLeft(element);
      offsetTop = getOffsetTop(element);
    }

<%    if ("Input".equals(dirStr)) { %>
    scrollX = -offsetLeft;
<%    } else if ("Output".equals(dirStr)) { %>
    scrollX += offsetLeft;
<%    } // "Output" %>
    scrollY += offsetTop;
<%} // "ExpandObject" %>

    window.scrollTo(scrollX, scrollY);
</script>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
