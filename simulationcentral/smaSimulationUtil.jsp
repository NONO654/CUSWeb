<%-- (c) Dassault Systemes, 2007, 2008 --%>
<%--
  Process various SLM commands on the "My *" pages.
--%>

<%-- Common Includes --%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>

<%@page import = "com.matrixone.apps.domain.DomainObject"%>
<%@page import = "com.matrixone.apps.domain.DomainConstants"%>
<%@page import = "com.matrixone.apps.domain.DomainSymbolicConstants"%>
<%@page import = "com.matrixone.apps.framework.ui.UINavigatorUtil"%>
<%@page import = "com.matrixone.apps.domain.util.FrameworkException"%>
<%@page import = "com.matrixone.apps.domain.util.MqlUtil"%>
<%@page import="com.dassault_systemes.smaslm.matrix.server.Simulation"%>
<%@page import = "com.dassault_systemes.smaslm.matrix.web.ErrorUtil"%>
<%@page import = "com.dassault_systemes.smaslm.matrix.web.Parameters"%>
<%@page import = "com.dassault_systemes.smaslm.matrix.web.SlmUIUtil"%>
<%@page import = "com.dassault_systemes.smaslm.matrix.common.AccessUtil" %>
<%@page import = "com.dassault_systemes.smaslm.matrix.common.SimulationUtil" %>
<%@page import = "com.dassault_systemes.smaslm.matrix.common.SimulationConstants" %>
<%@page import="com.dassault_systemes.smaslm.matrix.server.SimulationActivity"%>

<%@page import = "matrix.db.Context"%>
<%@page import = "matrix.db.JPO"%>
<%@page import = "matrix.db.User"%>
<%@page import = "matrix.util.MatrixException"%>
<%@page import = "matrix.util.StringList"%>
<%@page import = "matrix.util.ErrorMessage"%>

<%@page import = "java.util.HashMap"%>
<%@page import = "java.util.Map"%>
<%@page import = "java.util.List"%>
<%@page import = "java.util.StringTokenizer"%>
<%@page import = "java.util.Vector"%>

<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript" src="../common/scripts/emxUITableUtil.js"></script>
<script type="text/javascript" src="../simulationcentral/smaStructureNavigator.js"></script>
<script type="text/javascript" src="../simulationcentral/smaUITree.js"></script>

<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>

<!--  <html> and <head> were added by something above here.   -->
</head>
<body>

<%
    boolean closeTop = false;

    String objectAction = emxGetParameter(request, "objectAction");
    String fromPage = emxGetParameter(request, "fromPage");
    String strObjId = emxGetParameter(request, "objectId");
    String suiteKey = emxGetParameter(request, "suiteKey");
    String sRowIds[] = request.getParameterValues("emxTableRowId");
    String parentOid = null;

    if("changeOwner".equals(objectAction) && (strObjId==null || "".equals(strObjId)) )//WXB-170400
            strObjId = (String)session.getAttribute("CHANGEOWNERIDS");//WXB-170400
    
    if (sRowIds != null && sRowIds.length != 0)
    {
        parentOid = strObjId;
        strObjId = null;
    }
    else if (strObjId != null)
    {
        // allow for the possibilty that a "*" list was passed in
        sRowIds = strObjId.split("\\*");
    }
    else
    {
        // your screwed
        String errMsgInternal = SimulationUtil.getI18NString(context,
            "Error.Internal.NoObject");
        emxNavErrorObject.addMessage(errMsgInternal);
    }

    // get the table row IDs and keep them unchanged
    // (allows us to perform table operations)
    String[] tableRowIds = new String[sRowIds.length];
    System.arraycopy(sRowIds, 0, tableRowIds, 0, sRowIds.length);

    // If called from emxTable, the row ids might be
    //   <connection id>|<selected object id>
    // If called from an emxIndentedTable, the row ids are:
    //   <conection id>|<selected object id>|<parent object id>|<indented table ordering tag>
    // In either case, pull out the <selected object id>.
    if (sRowIds[0] != null && sRowIds[0].indexOf('|') > -1)
    {
        for (int ix = 0; ix < sRowIds.length; ix++)
        {
            String[] ids = sRowIds[ix].split("\\|");
            if (ids.length > 1)
                sRowIds[ix] = ids[1];
        }
    }

    if (objectAction.equalsIgnoreCase("changeOwner"))
    {
        closeTop = true;
    }

    StringBuilder contentURL = new StringBuilder(175);

    if (sRowIds != null
        && isNotLocked(context, sRowIds, parentOid,
            objectAction, emxNavErrorObject)
        && hasAccess(context, sRowIds, objectAction,
            emxNavErrorObject))
    {
        try
        {
            // Delete
            if (objectAction.equalsIgnoreCase("delete")
                || objectAction.equalsIgnoreCase("deleteJob"))
            {
                String confirmMsg = null;
                String confirmParamName = "confirmOwnedRevsDelete";

                if (emxGetParameter(request, "confirmOwnedRevsDelete") == null)
                {
                    try
                    {
                        if (emxGetParameter(request, "confirmOwnedRevsDelete") == null)
                        {
                            Boolean isOwnedWithRevs = (Boolean) JPO.invoke(
                                context,
                                "jpo.simulation.SimulationUtil",
                                null,
                                "isOwnedContentWithMultipleRevisions",
                                sRowIds,
                                Boolean.class);

                            if (isOwnedWithRevs.booleanValue())
                            {
                                confirmMsg = SimulationUtil.getI18NString(context,
                                        "smaSimulationCentral.OwnedContentWithRevisions.confirmDelete");
                            }
                        }
                    }
                    /* if something fails during the check proceed
                     * with the delete
                     */
                    catch (Exception ignore) {}
                }
                
                if (confirmMsg != null)
                {
%>
                <form name="preserveParamsForm" method="POST"
                    action="../simulationcentral/smaSimulationUtil.jsp?<%= confirmParamName %>=true">
<%
                    // add the rest of the parameters to the request
                    for (Iterator iter = Parameters.getParameterList(request).iterator();
                         iter.hasNext();)
                    {
                        Parameters.Parameter param = (Parameters.Parameter) iter.next();
                        String paramName = param.getName();

                        if (paramName == null ||
                            paramName.equals(confirmParamName))
                        {
                            continue;
                        }
%>
                    <input name="<%= paramName %>"
<%
                        String paramValue = param.getValue();
                        if (paramValue != null)
                        {
%>
                        value="<%= paramValue %>"
<%
                        }
%>
                        type="hidden"/>
<%
                    }
%>
                </form>
                <script language="JavaScript">
                    <!--
                    if (confirm('<%= confirmMsg %>'))
                    {
                        document.preserveParamsForm.submit();
                    }
                    //-->
                </script>
<%
                }
                else
                {
                    SlmUIUtil.deleteObjects(context, sRowIds);

                    // Now remove objects from search results display.
                    // This requires removing the data from the tablebean.
                    String timeStamp = emxGetParameter(request,"timeStamp");
                    if ( timeStamp != null && timeStamp.length() > 0 )
                    {
                        String openedBy = "";
                        HashMap tabData = tableBean.getTableData(timeStamp);
                        if ( tabData != null )
                        {
                            HashMap reqMap = tableBean.getRequestMap(tabData);
                            if ( reqMap != null )
                                openedBy = (String) reqMap.get("openedBy");
                        }

                        // Ignore if we're not coming from search pages
                        if ( "GlobalSearch".equalsIgnoreCase(openedBy) )
                        {
                            MapList objList =
                                tableBean.getObjectList(timeStamp);

                            Iterator itrMap = objList.iterator();
                            while ( itrMap.hasNext() )
                            {
                                Map objMap = (Map) itrMap.next();
                                String id = (String) objMap.get(
                                    DomainObject.SELECT_ID);
    
                                // Remove selected rows in table data
                                for ( int ii=0; ii<sRowIds.length; ii++ )
                                {
                                    if ( id.equals(sRowIds[ii]) )
                                    {
                                        itrMap.remove();
                                    }
                                }
                            }
                        
                            // Update tablebean with new data.
                           tabData.put("objectList", objList);
                           tableBean.setTableData(timeStamp, tabData);
                       }
                    }
%>
                <script>
                // unregister all selected rows
                if (unregister)
                {
<%
                    for ( int ii=0; ii<sRowIds.length; ii++ )
                    {
%>
                       unregister("<%=sRowIds[ii] %>");
<%
                    }
%>
                }

                // Delete items from tree but only if tree frame
                // is displayed.
                //SimDocsProperties
                var fromPage = "<%= fromPage%>";
                if (fromPage == "SimDocsProperties")
                {
                    getTopWindow().location.href = '../common/emxNavigator.jsp?appName=' + getTopWindow().currentApp;
                }
                </script>
<%
                }
            }

            else if
               (objectAction.equalsIgnoreCase("deleteHostApplications"))
            {
                String[] args = new String[2];
                
                // set up jpo args which include host oid and
                // "|" separated list of application row ids
                args[0] = parentOid;
                String rowsToDelete = "";
                for (int k=0; k<sRowIds.length; k++)
                {
                    rowsToDelete = rowsToDelete + sRowIds[k] + "|";
                }
                // removing trailing "|"
                args[1] = 
                    rowsToDelete.substring(0,rowsToDelete.length() - 1);
                JPO.invoke(context,
                    "jpo.simulation.SimulationHost", null,
                    "deleteApplications", args, Boolean.class);
            }
            
            else if (objectAction.equalsIgnoreCase("moveUp")
                || objectAction.equalsIgnoreCase("moveDown"))
            {
                  String[] args = new String[3];
                  args[0] = parentOid;
                  args[1] = sRowIds[0];
                  args[2] = 
                      (objectAction.equalsIgnoreCase("moveUp"))
                               ? "true" : "false";
                  JPO.invoke(context,
                      "jpo.simulation.Simulation", null,
                      "moveActivity", args, Boolean.class);
            }


            else if (objectAction.equalsIgnoreCase("changeOwner"))
            {
                // check if any revision has an owned relation.
                // this will be true only for documents.

                final String ACTIVITY_TYPE = 
                    SimulationUtil.getSchemaProperty(
                        SimulationConstants.SYMBOLIC_type_SimulationActivity);

                final String DOCUMENTS_TYPE = 
                    SimulationUtil.getSchemaProperty(
                        DomainSymbolicConstants.SYMBOLIC_type_DOCUMENTS);

                StringBuilder selectBuf = new StringBuilder();

                final String SELECT_KINDOF_ACTIVITY =
                    selectBuf.
                        append("type.kindof[").
                        append(ACTIVITY_TYPE).
                        append(']').
                        toString();

                final String SELECT_KINDOF_DOCUMENTS =
                    selectBuf.delete(0, selectBuf.length()).
                        append("type.kindof[").
                        append(DOCUMENTS_TYPE).
                        append(']').
                        toString();

                StringList objectSelects = new StringList();
                objectSelects.add(SELECT_KINDOF_ACTIVITY);
                objectSelects.add(SELECT_KINDOF_DOCUMENTS);

                // Get the list of business objects in tree
                BusinessObjectWithSelectList bowsl = BusinessObject
                    .getSelectBusinessObjectData(
                        context, sRowIds, objectSelects);

                boolean okToContinue = true;

                for (Iterator iter = bowsl.iterator();
                     okToContinue && iter.hasNext();)
                {
                    String errKey = null;

                    BusinessObjectWithSelect bows =
                        (BusinessObjectWithSelect) iter.next();
                    if (Boolean.parseBoolean(bows.getSelectData(
                            SELECT_KINDOF_ACTIVITY)))
                    {
                        if (SlmUIUtil.isOwnedActivity(context, bows))
                        {
                            errKey = "smaHome.cmdChecks.NoActAccess";
                        }
                    }
                    else if (Boolean.parseBoolean(bows.getSelectData(
                                 SELECT_KINDOF_DOCUMENTS)))
                    {
                        if (SlmUIUtil.isOwnedContent(context, bows))
                        {
                            errKey = "smaHome.cmdChecks.NoDocAccess";
                        }
                    }

                    if (errKey != null)
                    {
                        emxNavErrorObject.addMessage(
                        		SimulationUtil.getI18NString(context,
                                errKey));
                        okToContinue = false;
                    }
                }

                String ownedProp = SimulationUtil.getSchemaProperty(
                    SimulationConstants.SYMBOLIC_relationship_SimulationContent_Owned);

                StringBuilder objsToProcess = new StringBuilder();
                // check all the objects, if any fail the change owner
                // will not occur.
                for (int iii = 0; okToContinue && iii < sRowIds.length; iii++)
                {
                    String selObjectId = sRowIds[iii];
                    String tableRowId =
                        (iii < tableRowIds.length) ?
                        tableRowIds[iii] :
                        selObjectId;
                    
                    // build a "*" list of objects to process
                    if ( iii > 0)
                        objsToProcess.append("*");
                    objsToProcess.append(tableRowId);

                    StringBuilder mqlCmd = new StringBuilder(128);
                    String expr = "!revisions.to["+ownedProp+"]~~true";
                    mqlCmd.append("eval expr $1")
                        .append(" on bus $2");
                        //.append();
                    String cmd = mqlCmd.toString();

                    String res1 = "-1";
                    try
                    {
                        res1 = MqlUtil.mqlCommand(context, cmd,expr,selObjectId);
                    }
                    catch (Exception e)
                    {
                        // Ignored
                    }

                    // Check to see if any revision is owned
                    // Don't change owner if revision has an owned relation
                    if ("false".equalsIgnoreCase(res1))
                    {
                        String errMsg = SimulationUtil.getI18NString(context,
                                "Error.ChangeOwner.OwnedContent");
                        emxNavErrorObject.addMessage(errMsg);
                        okToContinue = false;
                    }
                }
                if (okToContinue)
                {
                    String timestamp = 
                        emxGetParameter(request,"timeStamp");
                    contentURL.append(
                            "../simulationcentral/smaSelectOwner.jsp?")
                        .append(
                            "searchUrl=../components/emxCommonSearch.jsp")
                        .append("&searchmode=PersonChooser")
                        .append("&suiteKey=Components")
                        .append(
                            "&searchmenu=APPMemberSearchInMemberList")
                        .append("&searchcommand=APPFindPeople")
                        .append(
                            "&SubmitURL=../simulationcentral/smaSelectOwnerProcess.jsp")
                        .append("&updateAction=refreshCaller")
                       // .append("&objectId=").append(objsToProcess.toString())//WXB-170400 Already stored this in session
                        .append("&timeStamp=").append(timestamp);
                }
            }
            
            else if (objectAction.equalsIgnoreCase("refreshJobList"))
            {
                // Nothing needs done - just want to refresh the 
                // the table, which is done below.
            }

            else
            {
                // Loop through all selected
                for (int iii = 0; iii < sRowIds.length; iii++)
                {
                    String selObjectId = sRowIds[iii];

                    DomainObject obj = new DomainObject();
                    obj.setId(selObjectId);

                    if (objectAction.equalsIgnoreCase("lock"))
                    {
                        obj.lock(context);
                    }
                    else if (objectAction
                        .equalsIgnoreCase("unlock"))
                    {
                        obj.unlock(context);
                    }
                    else if (objectAction
                        .equalsIgnoreCase("activateHosts"))
                    {
                        obj.setState(context, "Active");
                    }
                    else if (objectAction
                        .equalsIgnoreCase("deactivateHosts"))
                    {
                        obj.setState(context, "Inactive");
                    }
                }
            }
        }
        catch (Exception ex)
        {
            emxNavErrorObject.addMessage(ErrorUtil.getMessage(ex));

            // The following is intentionally done AFTER the above
            // call of emxNavErrorObject.addMessage().
            // If 'ex' originated from a MatrixException, its message
            // may contain the kernel error code. That error code is
            // parsed out by addMessage().

            if (objectAction.equalsIgnoreCase("delete"))
            {
                // Check if this is the "Check trigger blocked event"
                // error. If so, display a better message.
                // -- the int code for the subject error is 1500167.

                int errCode = 0;
                Vector meMessages = emxNavErrorObject.getMessages();
                if (meMessages != null)
                {
                    ErrorMessage mxErrMsg = (ErrorMessage) 
                            meMessages.get(0);
                    if (mxErrMsg != null)
                        errCode = mxErrMsg.getErrorCode();
                }

                if (errCode == 1500167)
                {
                    String lang = request.getHeader("Accept-Language");
                    String sErrorMsg = 
                    		SimulationUtil.getI18NString(context,
                            "Error.DeleteBlocked");

                    meMessages.remove(0);
                    emxNavErrorObject.addMessage(sErrorMsg);
                }
            }
        }
    }

    // If action above caused a URL to need to be opened, open it.
    if (contentURL.length() > 0)
    {
%>
        <script language="javascript">
            getTopWindow().location.href = "<%=contentURL.toString()%>";
        </script>
<%
    }
    else
    {
        // the following include will cause the display of an alert 
        // message if there is an outstanding error.
%>

<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>

<%
        if (closeTop)
        {
%>
          <script language="javascript">
              getTopWindow().closeWindow();
          </script>
<%
        }
        else
        {
%>
          <script language="Javascript">
<%
            if (objectAction.equalsIgnoreCase("refreshJobList") ||
                objectAction.equalsIgnoreCase("deleteJob"))
            {
%>
          if (this.name == "listHidden")
          {
              var target = null;
              if (parent.name == "SMASimulation_NavTreeJobs")
              {
                 target = parent;
              }
              else if (parent.name == "detailsDisplay"
                      && parent.parent.name == "smaHomeContent")
              {
                 target = parent;
              }
              else if(parent.name == "SMADiscover_JobMonitor")
                  {
                  target = parent;
                  }
              if (target != null)
              {
                 // Expecting came from the Simulation/Activity Jobs table.
                 target.location.href = target.location.href;
              }
          }
<%
            }
            else if (objectAction.equalsIgnoreCase("moveUp") ||
                objectAction.equalsIgnoreCase("moveDown"))
            {
%>
            getTopWindow().refreshTablePage();
            refreshNode("<%=parentOid%>","null"); 
<%
            }
            else
            {
%>
              
          if ( getTopWindow().refreshTablePage )
          {
              getTopWindow().refreshTablePage();
          }
          
          // Here to update display on search results page
          else if ( getTopWindow() && getTopWindow().searchView
                    && getTopWindow().searchView.listDisplay &&
                    getTopWindow().searchView.listDisplay.location &&
                     getTopWindow().searchView.listDisplay.location.reload )
          {
              getTopWindow().searchView.listDisplay.location.reload();
          }
          else if (getTopWindow() && getTopWindow().location &&  getTopWindow().location.href)
          {
              getTopWindow().location.href = getTopWindow().location.href;
          }
<%
            }
%>
          </script>
<%
        }
    }
%>

</body>
</html>

<%!// Make sure the selected object is not locked.
    //
    private boolean isNotLocked(Context context, String[] sRowIds,
        String parentId, String objectAction,
        FrameworkException emxNavErrorObject)
    {
        boolean isnotlocked = true;
        String lang = context.getSession().getLanguage();
        final String RUNNING = SimulationConstants.JOB_STATUS_RUNNING;

        // moveUp/moveDown - parent
        // delete - parent and object.
        // changeOwner = object.
        //
        if ((objectAction.equalsIgnoreCase("lock") || objectAction
            .equalsIgnoreCase("unlock")) == false)
        {
            try
            {
                // Check that parent is not locked.
                //
                boolean parentLocked = false;
                if (parentId != null
                    && objectAction.equalsIgnoreCase("changeOwner") == false)
                {
                    DomainObject parentDO = new DomainObject();
                    parentDO.setId(parentId);

                    if (AccessUtil.isLocked(context, parentDO, true))
                    {
                        String objName = 
                            parentDO.getInfo(context,
                                DomainConstants.SELECT_LOCKER);
                        
                        final String msg1 = SimulationUtil
                            .getI18NString(context,
                                "smaSimulationCentral.Content.ErrMsg.cannotdooperation");
                        final String msg2 = SimulationUtil
                            .getI18NString(context,
                                "smaSimulationCentral.Content.ErrMsg.parentislocked");

                        String msg3 = msg1 + " " + 
                            StringResource.format(msg2, "P1", objName);

                        emxNavErrorObject.addMessage(msg3);
     
                        isnotlocked = false;
                        parentLocked = true;
                    }
                }

                // Check that object is not locked.
                //
                if ((objectAction.equalsIgnoreCase("delete")
                    || objectAction.equalsIgnoreCase("activateHosts")
                    || objectAction.equalsIgnoreCase("deactivateHosts")
                    || objectAction.equalsIgnoreCase("changeOwner") || objectAction
                    .equalsIgnoreCase("deleteJob"))
                    && parentLocked == false)
                {
                    boolean checkLocker = true;
                    if (objectAction.equalsIgnoreCase("changeOwner"))
                        checkLocker = false;

                    for (int ix = 0; ix < sRowIds.length; ++ix)
                    {
                        String selId = sRowIds[ix];
                        // get the actual object id since sRowId
                        // might be "|" separated list containing 
                        // relation and parent id's as well
                        String[] ids = sRowIds[ix].split("\\|");
                        if (ids.length > 1)
                            selId = ids[1];
                        DomainObject objectDO = new DomainObject();
                        objectDO.setId(selId);
                        String objName = SimulationUtil.getObjectName(
                            context, objectDO);
                        final String msg1 = SimulationUtil
                            .getI18NString(context,
                                "smaSimulationCentral.Content.ErrMsg.cannotdooperation");
                        final String msg2;

                        if (AccessUtil.isLocked(context, objectDO,
                            checkLocker))
                        {

                            if (checkLocker)
                            {
                                msg2 = SimulationUtil
                                    .getI18NString(context,
                                        "smaSimulationCentral.Content.ErrMsg.selectedislocked");
                            }
                            else
                            {
                                msg2 = SimulationUtil
                                    .getI18NString(context,
                                        "smaSimulationCentral.Content.ErrMsg.selectedislocked2");
                            }

                            String user = 
                                objectDO.getInfo(context,
                                    DomainConstants.SELECT_LOCKER);
                            
                            String msg3 = msg1 + " " + 
                                StringResource.format(msg2, "P1", user);

                            emxNavErrorObject.addMessage(msg3);

                            isnotlocked = false;
                            sRowIds[ix] = null;
                        }
                        else if (objectAction
                            .equalsIgnoreCase("deleteJob"))
                        {
                            String[] methodargs = { sRowIds[ix] };
                            String status = (String) JPO.invoke(
                                context, "jpo.simulation.Job", null,
                                "getStatus", methodargs, String.class);
                            if (status.equalsIgnoreCase(SimulationConstants.JOB_STATUS_RUNNING)
                                ||status.equalsIgnoreCase(SimulationConstants.JOB_STATUS_PAUSED)
                                ||status.equalsIgnoreCase(SimulationConstants.JOB_STATUS_WAITING))
                            {
                                msg2 = SimulationUtil
                                    .getI18NString(context,
                                        "smaSimulationCentral.Content.ErrMsg.jobisrunning");

                                String msg3 = msg1 + " " + 
                                    StringResource.format(msg2, "P1", objName);

                                emxNavErrorObject.addMessage(msg3);

                                isnotlocked = false;
                                sRowIds[ix] = null;
                            }
                        }
                        else if(objectAction.
                            equalsIgnoreCase("delete")){
                            DomainObject domainObject = 
                                new DomainObject(sRowIds[ix]);
                            if(domainObject.isKindOf(context, 
                                SimulationUtil.getSchemaProperty(
                                    SimulationConstants.SYMBOLIC_type_Simulation)))
                            {
                                if(!isJobRunningForSimulation(context,
                                    sRowIds[ix],emxNavErrorObject )){
                                    isnotlocked = false;
                                    sRowIds[ix] = null;
                                }
                                
                            }
                            if(domainObject.isKindOf(context, 
                                SimulationUtil.getSchemaProperty(
                                    SimulationConstants.SYMBOLIC_type_SimulationActivity)))
                            {
                                SimulationActivity simActivity = 
                                    new SimulationActivity(sRowIds[ix]);
                                String simulationId = 
                                    simActivity.
                                    getParentSimulationOid(context);

                                if(!isJobRunningForSimulation(context,
                                    simulationId,emxNavErrorObject )){
                                    isnotlocked = false;
                                    sRowIds[ix] = null;
                                }
                                
                            }
                        }
                            
                    }
                }
            }
            catch (Exception ex)
            {
                isnotlocked = false;
                emxNavErrorObject.addMessage(ErrorUtil.getMessage(ex));
            }
        }

        return isnotlocked;
    }

private boolean isJobRunningForSimulation(Context context, String objId,
    FrameworkException emxNavErrorObject){
    try{
    Simulation sim = new Simulation(objId);
    String status = sim.getRunStatus(context);
    if(status.equalsIgnoreCase(SimulationConstants.JOB_STATUS_RUNNING)
        ||status.equalsIgnoreCase(SimulationConstants.JOB_STATUS_PAUSED)
        ||status.equalsIgnoreCase(SimulationConstants.JOB_STATUS_NOTSTARTED)
        ||status.equalsIgnoreCase(SimulationConstants.JOB_STATUS_WAITING))
    {
        String attrName=sim.getInfo(context, "attribute[Title]");
        String errMsg = SimulationUtil.getI18NString(context,
                "Error.JobDelete.JobRunning");

        String errorMessage = StringResource.format(
                errMsg, "P1", attrName);

    emxNavErrorObject.addMessage(errorMessage);
    return false;        
    }
    else return true;
    }catch(Exception e){
        emxNavErrorObject.addMessage(e.getMessage());
        return false;
    }
}


    // Method to check access for command
    // Returns true if has access, otherwise returns false
    //  0 = Read         10 = Create        20 = ChangePolicy 
    //  1 = Modify       11 = Promote       21 = ChangeType 
    //  2 = Delete       12 = Demote        22 = FromConnect 
    //  3 = Checkout     13 = Enable        23 = ToConnect 
    //  4 = Checkin      14 = Disable       24 = FromDisconnect 
    //  5 = Lock         15 = Override      25 = ToDisconnect 
    //  6 = Unlock       16 = Schedule      26 = Freeze 
    //  7 = Grant        17 = Revise        27 = Thaw 
    //  8 = Revoke       18 = Changelattice 28 = Execute 
    //  9 = ChangeOwner  19 = ChangeName    29 = ModifyForm 
    //
    //       30 = ViewForm 31 = Show 32 = All 33 = None 
    //
    private boolean hasAccess(Context context, String[] sRowIds,
        String objectAction, FrameworkException emxNavErrorObject)
    {
        boolean hasaccess = true;
        String reqAccess = "";
        //    String reqParentAccess = "";

        // Specify access params for each command
        if (objectAction.equals("changeOwner"))
        {
            reqAccess = "changeowner";
        }
        else if (objectAction.equals("lock"))
        {
            reqAccess = "lock";
        }
        else if (objectAction.equals("delete"))
        {
            reqAccess = "delete";
        }
        else if (objectAction.equals("deleteJob"))
        {
            reqAccess = "modify,fromdisconnect";
        }
        else
        {
            return hasaccess;
        }

        try
        {
            // Loop thru each selected item - determine if user has access
            for (int ii = 0; ii < sRowIds.length; ii++)
            {
                //            StringList sIds = convertRowId( sRowIds[ii] );
                //            String objectId = (String)sIds.get(1);
                //            String parentId = (String)sIds.get(2);

                String objectId = sRowIds[ii];
                // get the actual object id since sRowId
                // might be "|" separated list containing 
                // relation and parent id's as well
                String[] ids = sRowIds[ii].split("\\|");
                if (ids.length > 1)
                    objectId = ids[1];

                // Check access to object
                if (reqAccess.length() > 0)
                {
                    DomainObject DO = new DomainObject();
                    DO.setId(objectId);

                    if ( ! AccessUtil.hasAccess(context, DO, reqAccess))
                    {
                        hasaccess = false;

                        String[] tnr = SimulationUtil.getTNR(context, objectId);

                        String lang =context.getSession().getLanguage();

                        String errMsg1;
                        if (objectAction.equals("deleteJob"))
                        {
                            errMsg1 = 
                                SimulationUtil.getI18NString(context,
                                "ErrMsg.Content.noaccessJobDelete",
                                 "TYPE", tnr[0], "NAME", tnr[1]);
                        }
                        else if (objectAction.equals("changeOwner"))
                        {
                            errMsg1 = 
                                SimulationUtil.getI18NString(context,
                                "ErrMsg.Content.noaccessChangeOwner",
                                 "TYPE", tnr[0], "NAME", tnr[1]);
                        }
                        else
                        {
                            String state = 
                                DO.getInfo(
                                    context, DomainObject.SELECT_CURRENT);

                            errMsg1 = 
                                SimulationUtil.getI18NString(context,
                                "ErrMsg.Content.noaccess",
                                 "TYPE", tnr[0], "NAME", tnr[1],
                                "NAME2", tnr[1], "STATE", state);
                        }
                        emxNavErrorObject.addMessage(errMsg1);
                        break;
                    }
                }

                // NOT USED YET 11/14/2007
                //            // Check access to parent
                //            if ( reqParentAccess.length() > 0 )
                //            {
                //                DomainObject DO = new DomainObject();
                //                DO.setId(parentId);
                //    
                //                if ( !AccessUtil.hasAccess(context, DO, reqParentAccess) )
                //                {
                //                    hasaccess = false;
                //
                //                    String objName = 
                //                        SimulationUtil.getObjectName(context, DO);
                //
                //                    String state = 
                //                        DO.getInfo(
                //                            context, DomainObject.SELECT_CURRENT);
                //
                //                    String locale = context.getSession().getLanguage();
                //                    String errMsg1 = 
                //                        UINavigatorUtil.getI18nString(
                //                        "ErrMsg.Content.noaccess",
                //                        "smaSimulationCentralStringResource", locale );
                //                    errMsg1 = StringResource.format(errMsg1, "P1", objName, "P2", state);
                //                    emxNavErrorObject.addMessage(errMsg1);
                //                    break;
                //                }
                //            }
            }
        }
        catch (Exception ex)
        {
            hasaccess = false;
            emxNavErrorObject.addMessage(ErrorUtil.getMessage(ex));
        }

        return hasaccess;
    }
%>

