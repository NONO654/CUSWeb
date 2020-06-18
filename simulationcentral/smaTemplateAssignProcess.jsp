<%-- (c) Dassault Systemes, 2007, 2008 --%>
<%--
  Assigns a simulation or activity to a template, replacing one if
  it already existed.
--%>
<%--  --%>

<%@include file="../common/emxNavigatorInclude.inc"%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>

<%@page
    import="com.dassault_systemes.smaslm.matrix.common.SimulationUtil"%>
<%@page
    import="com.dassault_systemes.smaslm.matrix.common.SimulationConstants"%>
<%@page
    import="com.dassault_systemes.smaslm.matrix.web.StructureBrowserUtil"%>
<%@page import="com.dassault_systemes.smaslm.matrix.web.ErrorUtil"%>
<%@page import="com.matrixone.apps.framework.ui.UINavigatorUtil"%>
<%@page import="matrix.util.StringList"%>

<script type="text/javascript" src="../common/scripts/emxUIConstants.js"></script>
<script type="text/javascript" src="../common/scripts/emxUICore.js"></script>
<script type="text/javascript"
    src="../simulationcentral/smaStructureNavigator.js"></script>
<script type="text/javascript"
    src="../simulationcentral/smaStructureBrowser.js"></script>
    

<jsp:useBean id="tableBean"
    class="com.matrixone.apps.framework.ui.UITable" scope="session" />
<jsp:useBean id="indentedTableBean"
    class="com.matrixone.apps.framework.ui.UITableIndented" scope="session" />

<% 
    String templateId = emxGetParameter(request, "parentOID");

    String errMessage     = "";

    String oldContentId = null;
    String oldRelId = null;

    StringList activities = new StringList();

    // Get list of activity IDs from sim (if appropriate)
    try
    {
        // Get the ID of the template content entity
        String[] args1 = {templateId};
        Map returnMap1 = (Map) 
                JPO.invoke( context, 
                    "jpo.simulation.Template", null, 
                    "getAssignedId", args1, Map.class);
       
        if ( returnMap1 != null )
        {
            oldContentId = (String) returnMap1.get(DomainConstants.SELECT_ID);
            oldRelId = (String) returnMap1.get(DomainConstants.SELECT_RELATIONSHIP_ID);

            // If we have a simulation, get its activity IDs.  This is
            // used later in case the user stuck the activities into 
            // the nav tree.  If so, we need to remove them.
            //

            final String TYPE_SIMULATION = 
                SimulationUtil.getSchemaProperty(
                    SimulationConstants.SYMBOLIC_type_Simulation);
            
            String contentType = (String) returnMap1.get(DomainConstants.SELECT_TYPE);

            if( TYPE_SIMULATION.equals(contentType) )
            {
                Map programMap2 = new HashMap();
                programMap2.put("objectId", oldContentId);
                String[] args2 = JPO.packArgs(programMap2);
                
                // Get map list of activity IDs
                MapList returnMap2 = (MapList)
                    JPO.invoke( context, 
                        "jpo.simulation.Simulation", null, 
                        "getActivities", args2, MapList.class);
                
                // Save IDs in stringlist for below
                for ( int ii=0; ii<returnMap2.size(); ii++ )
                {
                    String sID = (String)
                        ((Map)returnMap2.get(ii))
                            .get(DomainConstants.SELECT_ID);
                    activities.add(sID);
                }
            }
        }
       
    }
    catch (Exception ex)
    {
        errMessage = ErrorUtil.getMessage(ex);
        emxNavErrorObject.addMessage(errMessage);
    }

    String sourceId = emxGetParameter(request, "emxTableRowId");
          if(sourceId.contains("|"))
        {
            StringList at = FrameworkUtil.split(sourceId, "|");
            sourceId    = (String)at.get(0);
        }

    HashMap programMap = new HashMap();
    programMap.put("templateId", templateId);
    programMap.put("sourceId", sourceId);
	
 	// Get the initial request map of the Assign command
    // (which is really emxSearch.jsp).
    String timeStamp2 = emxGetParameter(request, "timeStamp");
    Map requestMap2 = (Map) indentedTableBean.getRequestMap(timeStamp2);
    programMap.put("requestMap", requestMap2);
    
    String[] args = JPO.packArgs(programMap);
    Map returnMap = null;
    try
    {
       returnMap = (Map) 
            JPO.invoke( context, 
                   "jpo.simulation.Template", null, 
                   "assignContent", args, Map.class);
    }
    catch (Exception ex)
    {
        errMessage = ErrorUtil.getMessage(ex);
        emxNavErrorObject.addMessage(errMessage);
    }

    String newContentId   = "";
    String newContentName = "";
    String newRelId = "";
    
    // Check returned data
    if ( returnMap != null )
    {
        // Check for error
        String action = (String) returnMap.get("Action");
        if ( "STOP".equalsIgnoreCase(action) )
        {
            errMessage = (String) returnMap.get("Message");
        }
        else
        {
            newContentId   = (String) returnMap.get("newContentId");
            
            // Get new title/name for new object
            HashMap paramMapTitle = new HashMap();
            HashMap programMapTitle = new HashMap();

            paramMapTitle.put("objectId", newContentId);

            programMapTitle.put("paramMap", paramMapTitle);

            String[] args1 = JPO.packArgs(programMapTitle);
            
            newContentName = (String)JPO.invoke(context, 
                "jpo.simulation.SimulationUI", null,
                "getTitle", args1, String.class);
            
            // For IR-013373 To update the Template after 
            // assigning the process - vn1
            
            DomainObject templateObj = new DomainObject();
            templateObj.setId(templateId);
            newRelId = templateObj.getInfo(context,"from[Simulation Template Content].id");
        }
    }
    
    if (errMessage.length() == 0 && returnMap != null)
    {
        // Find out what page we came from.
        String fromPage = (String)requestMap2.get("fromPage");
        if (fromPage != null  &&  fromPage.equals("slmHome"))
        {
            // Came from the SLM Home page.
            // Update the TOC tree.

            String refreshFrame = (String) requestMap2.get("refreshFrame");
            String templateTableRowId = (String)requestMap2.get("emxTableRowId");

            // Get the timeStamp of the Home page.
            String timeStamp1 = (String)requestMap2.get("timeStamp");
%>
            <script language="JavaScript">
            var topFrame = getTopWindow();
            if (getTopWindow().getWindowOpener())
            {
                topFrame = getTopWindow().getWindowOpener().getTopWindow();        
            }
            //javascript comments rearranged to resolve IR-090435V6R2012WIM
            </script>
<%
            if (oldContentId != null)
            {
%>
                <script language="JavaScript">
                var frame = sbFindFrame(topFrame, "<%=refreshFrame%>");
                if (frame != null)
                {
<%
                    // If the old content is visible in the TOC, it has to be
                    // removed.
                    // Get the Structure Browser entry for the template row
                    // and check if it has a child (which is the old content).
    
                    //-- In the indentedTableBean, the table data is stored in
                    //-- the IndexedObjectList TreeMap.
                    //-- And the map keys are the "d,d,..." row ids.
    
                    String[] templateTableRowIdParts = templateTableRowId.split("\\|");
                    String templateRowId = templateTableRowIdParts[3];
                    
                    Map tableData1 = indentedTableBean.getTableData(timeStamp1);
    
                    SortedMap<String,Map> indexedObjectList = null;
                    if(tableData1!=null)
                        indexedObjectList = (SortedMap)tableData1.get("IndexedObjectList");
    
                    // Get the entry for the template row.
                    Map templateRowMap = (Map)indexedObjectList.get(templateRowId);
                    // Check if the template row has a child.
                    MapList templateRowChildren = (MapList)templateRowMap.get("children");
                    if (templateRowChildren != null && templateRowChildren.size() != 0)
                    {
                        // The template row has been expanded.
                        // Its children are now obsolete and must be removed.
                        //
                        // Want to call the indented table's removeRows() function.
                        // This function takes an array of ids for the rows to remove.
                        // These ids are the long form "relid|objid|parentid|rowid"
                        // The needed data is obtained from the child map.
                        //
                        // Also need to set the template row back to not expanded.
                        // This allows the template row to be re-expanded (by the user)
                        // and the new content displayed.
    
                        Map<String,String> child1 = (Map)templateRowChildren.get(0);
                        String[] rowLabelIds = new String[4];
                        rowLabelIds[0] = child1.get("id[connection]");
                        rowLabelIds[1] = child1.get("id");
                        rowLabelIds[2] = templateId;
                        rowLabelIds[3] = child1.get("id[level]");
                        String rowSelectLabel = FrameworkUtil.join(rowLabelIds, "|");
	                    
	                    
                        String action = "add";
                        StringList content = new StringList();
                        content.add(newContentId + "|" + newRelId);
                        
                        // Convert parent ID and added content to an appropriate javascript
                        // code that either adds the entities or displays an error message.
    
                        String sXML = StructureBrowserUtil.convertToXMLString(
                        context, action, "", templateTableRowId, content);
                     
%>
                        
                        var rowsToRemove = new Array();
				        rowsToRemove[0] = "<%=rowSelectLabel%>";
                        frame.removeRows(rowsToRemove);
                        var nRow = emxUICore.selectSingleNode(frame.oXML.documentElement,
                                "/mxRoot/rows//r[@id = '<%=templateRowId%>']");
                        // For IR-013373 To update the Template after 
                        // assigning the process - vn1
                        sbAddToSelected("<%=templateTableRowId%>", "<%=sXML%>", false, "<%=refreshFrame%>");
                        // For IR-013373 Code commented so that the new row added in the 
                        // strucuture browser remain expanded - vn1
				        //nRow.setAttribute("display", "none");
<%
                    }
%>
			        frame.refreshRows();
<%
			        // Update the content pane if it was showing the
			        // old template content.
%>
                    var contentHeaderFrame = sbFindFrame(topFrame, "smaHomeHeader");
                    if (contentHeaderFrame != null)
			        {
                        contentHeaderFrame.respondToObjectDeleted("<%=templateId%>");
			        }
	        }
            if (getTopWindow().getWindowOpener())
            {
                getTopWindow().closeWindow();
            }
            </script>            
<%
            }
            else
            {
%> 
<script language="JavaScript">
                if(getTopWindow().getWindowOpener())
                {
                    getTopWindow().closeWindow();
                }
</script>                                
<%                
            }
        }
        else if (fromPage != null  &&  fromPage.equals("newUI"))
        {
           %>
               <script>
                    	deleteNode("<%=oldContentId%>");
                        refreshDetailsTable("<%=sourceId%>","<%=templateId%>");    
                        window.top.close();
               </script>
           <%
        }
        else
        {
            // Not from the Home page. Must be from the old emxTree page.
            // Update the tree.
%>
<script language="Javascript">
	        var doRefresh = true;
	
	        // If we're on a page where an entity in the table has also been
	        // inserted into the navigation tree (like the Activities page),
	        // Then we must update the revision of the object in the navtree
	        
	        // Verify that the current page has a tree before we try
	        // to update it.
	        var frame = null;
	        if ( getTopWindow().getWindowOpener() )
	            frame = findFrame(getTopWindow().getWindowOpener().getTopWindow(),"emxUITreeFrame");
	        else
	            frame = findFrame(getTopWindow(),"emxUITreeFrame");
	
	        if ( typeof frame != "undefined")
	        {
	            var navTree = null;
	            if ( getTopWindow().getWindowOpener() )
	                navTree = getTopWindow().getWindowOpener().getTopWindow().objDetailsTree;
	            else
	                navTree = getTopWindow().objDetailsTree;
	
	            // Nav tree found, let's update it
	            if( navTree != null )
	            {
	                var oldID = "<%=oldContentId %>";
	                var obj = null;
	                
<%
	                // Remove all the Activities.
	                for ( int ii=0; ii<activities.size(); ii++ )
	                {
	                    String actId = (String) activities.get(ii);
%>
	                    navTree.deleteObject("<%=actId %>", false);
<%
	                }
%>              
	
	                // Get the tree entity to change the revision of
	                obj = navTree.getObject(oldID);
	                if ( obj != null )
	                {
	                    var newID = "<%=newContentId %>";
	                    var newName = "<%=newContentName %>";
	                    
	                    // We must change the ID of the entity's children
	                    // ourselves.  The changeID function below only 
	                    // does the entity's node and not the child nodes 
	                    // of that entity.
	
	                    // For unknown reasons the childnodes hang off the
	                    // nodes array instead of directly off "obj"
	                    var parNode = obj.nodes[0];
	
	                    // ChangeID changes the definition of "obj" so we
	                    // must set the child IDs before calling changeID
	                    for (var ii=0; ii<parNode.childNodes.length; ii++)
	                    {
	                        childNode = parNode.childNodes[ii];
	
	                        // For safety reasons, make sure we're changing
	                        // the correct ID.
	                        if ( childNode.objectID == oldID )
	                            childNode.objectID = newID;
	                        
	                        // Replace ID in loadURL (if it is defined)
	                        if ( typeof(childNode.loadURL) != "undefined" && 
	                             childNode.loadURL != null )
	                        {
	                            childNode.loadURL = 
	                                childNode.loadURL.replace(oldID,newID);
	                        }
	                        
	                        // Some children have children so go one more
	                        // level deep (this covers the entities in the
	                        // 'more' commands
	                        for (var jj=0; 
	                                jj<childNode.childNodes.length; jj++)
	                        {
	                            var CN = childNode.childNodes[jj];
	                            if( CN.objectID == oldID )
	                                CN.objectID = newID;
	
	                            // Replace ID in loadURL (if it is defined)
	                            if ( typeof(CN.loadURL) != "undefined" && 
	                                 CN.loadURL != null )
	                            {
	                                CN.loadURL = 
	                                    CN.loadURL.replace(oldID,newID);
	                            }
	                        }
	                    }
	
	                    // Change display name & ID of parent
	                    obj.changeName(newName, false);
	                    obj.changeID(newID, true);
	                    doRefresh = false;
	                }
	            }
	        }

	        if ( getTopWindow().getWindowOpener() )
	        {
	           if ( doRefresh && getTopWindow().getWindowOpener().getTopWindow().refreshTablePage )
	               getTopWindow().getWindowOpener().getTopWindow().refreshTablePage();
	        
	           getTopWindow().closeWindow();
	        }
	        </script>
<%
        }
    }
    else
    {
        if (errMessage.length() != 0)
        {
            session.putValue("error.message", errMessage);
%>
<%@include file="../common/emxNavigatorBottomErrorInclude.inc"%>
<script language="javascript">
            if (getTopWindow().getWindowOpener())
            {
                //close the assign process window if this is still open
                getTopWindow().closeWindow();
            }
        </script>
<%
        }
    }
%>
