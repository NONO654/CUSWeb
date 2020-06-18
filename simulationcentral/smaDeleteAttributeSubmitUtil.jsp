<%-- (c) Dassault Systemes, 2007, 2008 --%>
<%-- Wrapper JSP to invoke SubmitJPO with selected rows. --%>

<%-- Common Includes --%>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>

<%@page import="com.dassault_systemes.smaslm.matrix.web.ErrorUtil"%>
<%@page import="com.dassault_systemes.smaslm.matrix.web.StructureBrowserUtil"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkException"%>
<%@page import="com.matrixone.apps.domain.util.ContextUtil"%>
<%@page import="com.matrixone.apps.framework.ui.UINavigatorUtil"%>
<%@page import="matrix.db.JPO"%>
<%@page import="matrix.util.MatrixException"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.HashMap"%>

<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>

<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script type="text/javascript" src="../simulationcentral/smaStructureBrowser.js"></script>
<script src="../plugins/tagnavigator/js/vendor/jquery-1.8.2.min.js" >
</script>
<script src="../simulationcentral/smaStructureNavigator.js" >
</script>

<%
    matrix.db.Context context2 =
        (matrix.db.Context)request.getAttribute("context");
    if (context2 != null)
        context = context2;

    String timeStamp = emxGetParameter(request, "timeStamp");
    String tableRowId[] = request
        .getParameterValues("emxTableRowId");
    

    String[] tableRowIdDelete = new String[tableRowId.length]   ;
    
    for( int i = 0; i < tableRowId.length; i++)
    {
        String[] r = tableRowId[i].split("\\|");
        tableRowIdDelete[i] = r[1] ;

    }


    Map tableData = null;
    Map tableRequestMap = null;
    if (timeStamp != null && timeStamp.length() > 0)
    {
        tableData = (Map) tableBean.getTableData(timeStamp);
        if (tableData != null)
        {
            tableRequestMap = (Map) tableData.get("RequestMap");
        }
    }

    // This JSP can be invoked from a command href or a table parameter.
    String strJPO = emxGetParameter(request, "SubmitJPO");
    String refreshAction = emxGetParameter(request, "refreshAction");
    
    String oid = (String)session.getAttribute("stepId");
    session.removeAttribute("stepId");

    // when submitting from slm lite "refresh" we want to reload the slm-lite view
    // and stay on the same tab.  The refresh command will open a new window
    // which needs to be closed and we will reload the tab
    if ("parentLite".equalsIgnoreCase(refreshAction))
    {
%>
            <script>
            getTopWindow().getWindowOpener().document.location.href = getTopWindow().getWindowOpener().document.location.href;

            // Close the popup
            getTopWindow().closeWindow();
            </script>
<%
            return;
    }
    if (strJPO == null)
    {
        if (tableRequestMap != null)
        {
            strJPO = (String) tableRequestMap.get("SubmitJPO");
        }
        refreshAction = "submit";
    }

    String strJPOName = null;
    String strMethodName = null;
    if (strJPO != null)
    {
        strJPOName = strJPO.substring(0, strJPO.indexOf(":"));
        strMethodName = strJPO.substring(
            strJPO.indexOf(":") + 1, strJPO.length());
    }

    try
    {
        if ((strJPOName != null) && !(strJPOName.equals(""))
            && (strMethodName != null)
            && !(strMethodName.equals("")))
        {
            Map inputMap = new HashMap();
            final String OBJECT_IDS = "objectIDs";
            inputMap.put(OBJECT_IDS, tableRowIdDelete);

            inputMap.put("requestMap",
                    UINavigatorUtil.getRequestParameterMap(pageContext));
            inputMap.put("tableData", tableData);
            inputMap.put("stepId", oid);


            ContextUtil.startTransaction(context, true);
            try
            {
                JPO.invoke(context, strJPOName, new String[0],
                    strMethodName, JPO.packArgs(inputMap));

                ContextUtil.commitTransaction(context);
            }
            catch (Exception ex)
            {
                ContextUtil.abortTransaction(context);
                throw ex;
            }
        }
    }
    catch (Exception exJPO)
    {
        //  if had problem adding attribute throw exception so message
        //  is posted and dialog stays up to be fixed
        if (refreshAction.equalsIgnoreCase("parentClose"))
        {
            request.setAttribute("error.message",
                ErrorUtil.getMessage(exJPO));
            throw exJPO;
        }
        else
            emxNavErrorObject.addMessage(ErrorUtil.getMessage(exJPO));
    }
%>
<%--
// the following include will cause the display of an alert
// message if there is an outstanding error.
--%>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
<%
    // Handle the various refresh options:
    //     (null) - refresh current table page
    //     submit - refresh getWindowOpener() table page and close page
    //     parent - refresh table page and getWindowOpener() table page

    String selectedRowId  = null;
    if(tableRequestMap != null)
    {
        selectedRowId = (String) tableRequestMap.get("emxTableRowId");
    
        if ( selectedRowId != null && selectedRowId.length() > 0 )
        {
            if("AssignConnector".equals(strMethodName))
            {
                String objectId = emxGetParameter(request, "objectId");
                String parentId = emxGetParameter(request, "parentOID");
                %>
                    <script>
                          getTopWindow().closeWindow();
                          getTopWindow().refreshTablePage();
                    </script>
                <%
            }
           else
            {
                String refreshFrame = (String) tableRequestMap.get("refreshFrame");
                     // Convert parent ID and added content to an appropriate javascript
                     // code that either adds the entities or displays an error message.
                String sXML = StructureBrowserUtil.convertToXMLString(
                               context, "refresh", "", selectedRowId, null,
                               refreshFrame, false );
                     %>
                          <%= sXML %>
                     <%
            }
        }
    }

    if ((refreshAction == null))
    {
%>
    <script>
        getTopWindow().refreshTablePage();
    </script>
    
<%
    //return;
    }
    
    else if ((refreshAction.equalsIgnoreCase("submit")) && (selectedRowId == null))
    {
        // If we don't have any errors, update the nav tree, content frame
        // and close the window
        if (emxNavErrorObject.getMessages().size() == 0)
        {
%>
    <script>
        // Update the content frame
        getTopWindow().getWindowOpener().getTopWindow().refreshTablePage();

        // Close the popup
        getTopWindow().closeWindow();
    </script>
<%
        }
    }
    else if ((refreshAction.equalsIgnoreCase("parent"))&& (selectedRowId == null))
    {
%>
    <script>
        getTopWindow().document.location.href = getTopWindow().document.location.href;
        getTopWindow().getWindowOpener().getTopWindow().refreshTablePage();
    </script>
<%
    }
    else if ((refreshAction.equalsIgnoreCase("parentClose"))&& (selectedRowId == null))
    {
%>
            <script>
            getTopWindow().document.location.href = getTopWindow().document.location.href;
            getTopWindow().getWindowOpener().getTopWindow().refreshTablePage();

            // Close the popup
            getTopWindow().closeWindow();
            </script>
<%
    }
%>

