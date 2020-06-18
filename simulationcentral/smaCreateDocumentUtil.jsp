<%-- (c) Dassault Systemes, 2007, 2008 --%>
<%--
  Utility to return xml string to structure browser.  This is called
  after creating new documents
--%>

<%@include file = "../common/emxNavigatorInclude.inc"%>

<%@page import = "com.dassault_systemes.smaslm.matrix.web.StructureBrowserUtil"%>
<%@page import = "com.dassault_systemes.smaslm.matrix.web.ErrorUtil"%>
<%@page import = "matrix.util.StringList"%>
<%@page import =  "com.matrixone.apps.common.SubscriptionManager,com.matrixone.apps.common.WorkspaceVault"%>
<%@page import = "com.dassault_systemes.smaslm.matrix.common.SimulationUtil"%>

<!-- Used to load "findFrame" --> 
<script type="text/javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script type="text/javascript" src="../simulationcentral/smaStructureBrowser.js"></script>
<script type="text/javascript" src="../simulationcentral/smaStructureNavigator.js"></script>

<% 
    String action = "add";
    String message = "";
    String parentId = emxGetParameter(request,"parentId"); 
    String newObjectId = "";
    
    // If not coming from a place that has a parent, then we're coming
    // from the global actions menu so open the document
    if ( parentId == null || parentId.length() == 0 )
    {
        try
        {
            // Set to find documents created within the last 10% of
            // an hour (i.e. 3 minutes) - We should be able to use much
            // less than this but if the system is running really slow..
            String[] args = new String[]{"0.05"};

            // Get the IDs
            newObjectId = (String)JPO.invoke(context, 
                "jpo.simulation.SimulationUI", null,
                    "getLastCreatedDocumentID", args, String.class);
%>
            <script type="text/javascript">
                    var contentFrame = findFrame(getTopWindow().getWindowOpener().getTopWindow(), "content");
                    if(contentFrame)
                    {
                        contentFrame.document.location.href = "../common/emxTree.jsp?objectId=<%=newObjectId%>";
                    }
                if ( getTopWindow().getWindowOpener() )
                    getTopWindow().closeWindow();
            </script>
<%
        } 
        catch (Exception ex)
        {
            action = "error";
            message = ErrorUtil.getMessage(ex);
        }

        return;
    }

    // Coming from a place that has a parent (such as a sim, sa, folder)
    // Get the row id that contains the checkbox so that we can check it
    Map requestMap = UINavigatorUtil.getRequestParameterMap(pageContext);
    String parentRowId = (String)requestMap.get("emxTableRowId");
    String refreshFrame = (String)requestMap.get("refreshFrame");

    StringList docIDs = new StringList();
    String objectId = "";
    try
    {
        String[] args = new String[]{parentId};
        // Get the IDs
        docIDs = (StringList)JPO.invoke(context, 
            "jpo.simulation.SimulationUI", null,
                "getCreatedDocumentIDs", args, StringList.class);
        
        if ( docIDs.size() > 0 )
        {
            StringList ids = 
                FrameworkUtil.split( (String)docIDs.get(0), "|" );
            objectId = (String) ids.get(0);
        }
    } 
    catch (Exception ex)
    {
        action = "error";
        message = ErrorUtil.getMessage(ex);
        docIDs.setSize(0);
    }

    // Update content side of home page if it is available and the
    // command was to create docs in the home table of contents and
    // not to add to a sim/sa content.
    String fromPage = (String)requestMap.get("fromPage");
    if ( docIDs.size() > 0 && 
         "slmHome".equalsIgnoreCase(fromPage) )
    {
        // Form a lineage set for the TOC from the parentRowId.
        // This may be a partial lineage, since we don't have the
        // complete lineage available.
        String[] parts = parentRowId.split("\\|");
        parts[0] = parts[2];
        parts[2] = objectId;
        parts[3] = "";
        String lineage = FrameworkUtil.join(parts, "|");
%>
    <script type="text/javascript">
        refreshDetailsTable("<%=objectId%>","<%=parentId%>");
        var frame = null;
        if ( getTopWindow().getWindowOpener() )
            frame = findFrame(getTopWindow().getWindowOpener().getTopWindow(),"smaHomeHeader");
        else
            frame = findFrame(getTopWindow(),"smaHomeHeader");
    
        if ( frame != null )
        {
            frame.location.href =
                "../simulationcentral/smaHomeContentHeader.jsp" + 
                "?objectId=<%=objectId%>&lineageOIDs=<%=lineage%>";
        }
    </script>
<%
    }
    //parentRowId = (parentRowId==null)?parentId:parentRowId;
    if ( docIDs.size() > 0 && 
        "multi".equalsIgnoreCase(fromPage) && parentRowId==null)
   {
        %>
        <script type="text/javascript">
        updateFolderCount("<%=objectId%>","<%=parentId%>");
        refreshDetailsTable("<%=objectId%>","<%=parentId%>");
        getTopWindow().closeWindow();
        </script>
        <%
   }
    // Convert parent ID and added content to an appropriate javascript
    // code that either adds the entities or displays an error message.
    String sXML = StructureBrowserUtil.convertToXMLString(
        context, action, message, parentRowId, docIDs, 
            refreshFrame, true );
    
        //HF-111927 : To publish this event for Folder subscriptions as 
        //Team Central does not handle this.
        
        SimulationUtil.publishWorkspaceVaultEvent(context, objectId, parentId,
                WorkspaceVault.EVENT_CONTENT_ADDED);

%>
    <%= sXML %>
    
