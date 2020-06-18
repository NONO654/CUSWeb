<%-- (c) Dassault Systemes, 2007, 2008 --%>
<%--
  Utility to return xml string to structure browser.  This is called
  when changing the revision of an entity.  This changes the nav tree
  as well as the content table
--%>

<%-- Common Includes --%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@include file="../common/emxNavigatorInclude.inc"%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>

<%@page import = "com.dassault_systemes.smaslm.matrix.common.SimulationConstants"%>
<%@page import = "com.dassault_systemes.smaslm.matrix.common.SimulationUtil"%>
<%@page import = "com.dassault_systemes.smaslm.matrix.web.ErrorUtil"%>
<%@page import = "com.dassault_systemes.smaslm.matrix.web.StructureBrowserUtil"%>
<%@page import = "com.matrixone.apps.domain.util.FrameworkException"%>
<%@page import = "com.matrixone.apps.domain.util.FrameworkUtil"%>
<%@page import = "com.matrixone.apps.framework.ui.UINavigatorUtil"%>
<%@page import = "matrix.db.JPO"%>
<%@page import = "matrix.util.MatrixException"%>
<%@page import = "java.util.Map"%>
<%@page import = "java.util.HashMap"%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="matrix.util.StringList"%>
<%@page import="com.matrixone.apps.domain.util.MapList"%>
<%@page import="com.dassault_systemes.smaslm.matrix.server.Simulation"%>

<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>

<!-- Used to load "findFrame" --> 
<script type="text/javascript" src="../common/scripts/emxUIConstants.js"></script>
<script type="text/javascript" src="../common/scripts/emxUICore.js"></script>
<!-- Included to access sbAddToSelected -->
<script type="text/javascript" src="../simulationcentral/smaStructureBrowser.js"></script>


<%
    String errMessage  = "";

    ////////////////////////////////////////////////////////////////////
    // Change the relationship to point to newly selected revision
    String timeStamp = emxGetParameter(request, "timeStamp");
    Map revisionTableData = (Map)tableBean.getTableData(timeStamp);

    try 
    { 
        // Call JPO to actually perform the revision swap
        Map inputMap = new HashMap();
        inputMap.put("tableData", revisionTableData);
        inputMap.put("requestMap", 
            UINavigatorUtil.getRequestParameterMap(pageContext));
    
        JPO.invoke(context, 
            "jpo.simulation.SimulationContent", new String[0],
                "selectRevision", JPO.packArgs(inputMap));
    } 
    catch (Exception exJPO)
    {
        errMessage = ErrorUtil.getMessage(exJPO);
    }


    ////////////////////////////////////////////////////////////////////
    // Get some basic information from the request object

    String action  = "refresh";

    String newRowIDs[]  = emxGetParameterValues(request, "emxTableRowId");
    String newObjectID  = newRowIDs[0];
    String parentRowId ="";
    String oldObjectID = "";

    String parentRowID  = ""; 
    String parentRow    = "";
    String parentID     = "";
    String relID        = "";
    String callerTable    = "";
    String contentRowID = "";
    
    // Get new title/name for new object
    HashMap paramMap = new HashMap();
    HashMap programMap = new HashMap();

    paramMap.put("objectId",newObjectID);

    programMap.put("paramMap",paramMap);

    String[] args1 = JPO.packArgs(programMap);
    
    /* String newName = (String)JPO.invoke(context, 
        "jpo.simulation.SimulationUI", null,
        "getTitleRev", args1, String.class); */

    // Get the request map from the table where the "select revision"
    // command got executed
    Map origTableRequestMap = (Map)revisionTableData.get("RequestMap");
    if (origTableRequestMap != null)
    {
        oldObjectID = (String)origTableRequestMap.get("objectId");
        callerTable   = (String)origTableRequestMap.get("tableType");
        contentRowID= (String)origTableRequestMap.get("ContentRowIds");
    }
        
    // Grab the data from selected row
    StringList IDList = FrameworkUtil.split(contentRowID, "|");
    if ( IDList.size() > 0 ) relID     = (String) IDList.get(0);
    if ( IDList.size() > 2 ) parentID  = (String) IDList.get(2);
    if ( IDList.size() > 2 ) parentRow = (String) IDList.get(2);
    if ( IDList.size() > 3 ) parentRowId = (String)IDList.get(3);
    
 
    // Find the type of the object represented by parentId. If it is a process / activity, then call the 
    // updateAttributeDefinition function of SIMULATIONSBase JPO. 
    DomainObject dom = new DomainObject(parentID);
    String[] param1 = {parentID};

    StringList selects = new StringList(DomainConstants.SELECT_TYPE);

    // Query the domain object represented by parentID to get the type
    MapList info = dom.getInfo(context, param1, selects);
    
    if(info.size() > 0)
    {       
        String domainObjectType = (String)((Map)info.get(0)).get(DomainConstants.SELECT_TYPE);
        String symbolicName = FrameworkUtil.getAliasForAdmin(context,"Type", domainObjectType, true);
        
       
        if(symbolicName.equalsIgnoreCase(SimulationConstants.SYMBOLIC_type_SimulationActivity) ||
           symbolicName.equalsIgnoreCase(SimulationConstants.SYMBOLIC_type_Simulation))
        {
            // Call JPO to update the attribute definition
             Map argsMap = new HashMap();
                argsMap.put("oldObjectID", oldObjectID);
                argsMap.put("newObjectID", newObjectID);
                argsMap.put("parentID", parentID);

                 String message = (String) JPO.invoke(
                    context,
                    "jpo.simulation.SIMULATIONSBase",
                    null,
                    "updateAttributeDefinition",
                    JPO.packArgs(argsMap),
                    String.class);
                 
                 // Popup the error message in case the attribute definition is not updated properly.
                 if(!message.equalsIgnoreCase("Updated"))
                 {%>
                     <script>
                     alert("<%=message%>");
                     </script>
                 <%}
        }
    }
   
    if ( errMessage.length() == 0 &&
         ! "emxIndentedTable".equalsIgnoreCase(callerTable) )
    {
%>
        <script language="Javascript">
            getTopWindow().getWindowOpener().getTopWindow().refreshTablePage();
            getTopWindow().closeWindow();
        </script>

<%
    }

    ////////////////////////////////////////////////////////////////////
    // If ON a page with a structure browser
    // then we need to update the entity in the page by removing it
    // and then adding it (unfortunately there is no replace function)
    else if ( errMessage.length() == 0 &&
              "emxIndentedTable".equalsIgnoreCase(callerTable) )
    {
        try
        {
            final String RELATIONSHIP_SIMULATION_SUBFOLDER =
                SimulationUtil.getSchemaProperty(
                    SimulationConstants.
                        SYMBOLIC_relationship_SimulationSubFolder);

            final String RELATIONSHIP_SIMULATION_CATEGORY =
                SimulationUtil.getSchemaProperty(
                    SimulationConstants.
                        SYMBOLIC_relationship_SimulationCategory);
            
            final String RELATIONS = RELATIONSHIP_SIMULATION_SUBFOLDER +
                "," + RELATIONSHIP_SIMULATION_CATEGORY;


            String[] args = new String[2];
            args[0] = parentID;
            args[1] = RELATIONS;
        
            // Let's find the partial parent row id
            parentRowID = (String)JPO.invoke(context, 
                "jpo.simulation.SimulationUI", null,
                    "getStructureBrowserRowID", args, String.class);
    
            // We must append the SB row id to the end
            int lastComma = parentRow.lastIndexOf(",");
            if ( lastComma > -1 )
                parentRow = parentRow.substring(0,lastComma);
            
            parentRowID += parentRow;
        }
        catch (Exception ex)
        {
            errMessage = ErrorUtil.getMessage(ex);
        }
    
        if ( errMessage.length() == 0 )
        {
            
            // On the content page, we must remove the old revision
            // and add the new revision, there is no replace command
            // that I am aware of.
            
            // Remove the old object from the structure browser
            action = "remove";
            String contentRowIDs = contentRowID.substring(0,contentRowID
                .lastIndexOf("|"));

%>
            <script type="text/javascript">
          //Added for IR-IR-260574V6R2014x to get proper parentRowId Start
            var topFrame1 = getTopWindow();
            if (getTopWindow().getWindowOpener())
            {
                topFrame1 =  getTopWindow().getWindowOpener().getTopWindow();        
            }
            var frame1 = sbFindFrame(topFrame1, "detailsDisplay");
            
            var childRow = emxUICore.selectSingleNode(frame1.oXML.documentElement,
            "/mxRoot/rows//r[@id = '<%=parentRowId%>']");
            
            var parentRowId = null;
            if(childRow){
                parentRowId = childRow.parentNode.getAttribute("r")
                + "|" + childRow.parentNode.getAttribute("o")
                + "|" + childRow.parentNode.parentNode.getAttribute("o")
                + "|" + childRow.parentNode.getAttribute("id");                     
            }
          //Added for IR-IR-260574V6R2014x to get proper parentRowId End
            var topFrame = parent;
            if ( getTopWindow().getWindowOpener() )
                topFrame = getTopWindow().getWindowOpener().parent;
            
            var rowsToRemove = [];
            var contentRowID = "<%=contentRowIDs %>";
            frame1.removeRows([contentRowID]);
            </script>

<%
        }
        if ( errMessage.length() == 0 )
         {
            // Add new object to structure browser

            action = "add";

            // Create the XML response string
            StringBuffer data = new StringBuffer(1);
            data.append(StructureBrowserUtil.setXMLdataRow(
                context, parentID, relID, newObjectID, "nada"));
        
            String sXML = 
                StructureBrowserUtil.setXMLStructureBrowserResponse(
                    context, action, errMessage, data.toString() );
             
            // Add the new object to structure browser
%>
            <script type="text/javascript">
            setTimeout("sbAddToSelected(parentRowId, \"<%=sXML %>\", true, \"detailsDisplay\")", 500);
            </script>
<%
        }
    }

    ////////////////////////////////////////////////////////////////////
    // Handle errors
    if ( errMessage.length() > 0 )
    {
        if ( "emxIndentedTable".equalsIgnoreCase(callerTable) )
        {
            action = "error";
            // The following will close the popup
%>
            <jsp:include page="../simulationcentral/smaStructureBrowserUtil.jsp" >
                <jsp:param name ="action"  value = "<%= action %>" />
                <jsp:param name ="message" value = "<%= errMessage %>" />
            </jsp:include>
<%
        }
        else
        {
%>
            <%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
            <script language="Javascript">
                getTopWindow().closeWindow();
            </script>
<%
        }
    }
%> 

