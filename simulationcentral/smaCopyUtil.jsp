<%-- (c) Dassault Systemes, 2007, 2008 --%>
<%--
  Utility to return xml string to structure browser.  This is called
  after creating new documents
--%>

<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>

<%@page import = "com.dassault_systemes.smaslm.matrix.common.AccessUtil" %>
<%@page import = "com.dassault_systemes.smaslm.matrix.common.SimulationConstants" %>
<%@page import = "com.dassault_systemes.smaslm.matrix.common.SimulationUtil" %>
<%@page import = "com.dassault_systemes.smaslm.matrix.web.StructureBrowserUtil"%>
<%@page import = "com.dassault_systemes.smaslm.matrix.web.ErrorUtil"%>
<%@page import = "com.matrixone.apps.domain.util.FrameworkUtil"%>
<%@page import = "java.util.HashMap"%>
<%@page import = "java.util.Map"%>
<%@page import = "matrix.util.StringList"%>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script type="text/javascript" src="../simulationcentral/smaStructureNavigator.js"></script>


<jsp:useBean id="formEditBean" class="com.matrixone.apps.framework.ui.UIForm" scope="session"/>
<jsp:useBean id="indentedTableBean" class="com.matrixone.apps.framework.ui.UITableIndented" scope="session"/>

<html>
<head>
<title></title>
</head>
<body>
<%
    String objectAction = emxGetParameter(request,"objectAction");
    String objectId     = emxGetParameter(request,"objectId");
        
    // This utility is called by copy commands in many places:
    // global search
    // The old My Desk pages
    // Create New (from existing)
    // Home page
    
    if ( "copySimulation".equalsIgnoreCase(objectAction) ||
         "copyActivity".equalsIgnoreCase(objectAction)   ||
         "copyCommon".equalsIgnoreCase(objectAction)     ||
         "copyTemplate".equalsIgnoreCase(objectAction)   ||
         "copyAttributeGroup".equalsIgnoreCase(objectAction) ||
         "copyConnector".equalsIgnoreCase(objectAction)    )
    {
        String newId   = "";
        String message = "";
        String action  = "";

        try
        {
            matrix.db.Context context2 = 
                (matrix.db.Context)request.getAttribute("context");
            if (context2 != null)
                context = context2;

			// get object's attribute map
            DomainObject objDo = new DomainObject(objectId);
            Map attrMap = objDo.getAttributeMap(context);
            
            // Create a map that contains the request value for each of
            // the form fields (there is a request value for each input
            // field on the form).

            String timeStamp = emxGetParameter(request, "timeStamp");
            Map formMap = formEditBean.getFormData(timeStamp);
            MapList fieldList = (MapList) formMap.get("fields");
            HashMap paramMap = new HashMap();
            Iterator fieldsIter = fieldList.iterator();
            boolean nameTitleChange = false;
            boolean nullRev = false;
            while (fieldsIter.hasNext())
            {
                Map field = (Map)fieldsIter.next();
                String fieldName = (String) field.get("name");
                String fieldVal = emxGetParameter(request, fieldName);
                
                // check for name/title issue
                // needed for host copy
                // also put in revision since we are not revising hosts
                if (fieldName.equals("Title") && 
                    !attrMap.containsKey("Title"))
                {
                    fieldName = "Name";
                    nameTitleChange = true;
                }
                if (fieldName.equals("Revision") && 
                    fieldVal == null)
                {
                    nullRev = true;
                }

                paramMap.put(fieldName, fieldVal);
            }
            
            paramMap.put("objectId", objectId);
            if (nullRev && nameTitleChange)
            {
                paramMap.put("Revision", "-");
            }

            HashMap programMap = new HashMap();
            programMap.put("paramMap",paramMap);
            programMap.put("formMap", formMap);

            String[] args = JPO.packArgs(programMap);

            // Call the post copy function and create the entity
            String program = emxGetParameter(request, "postProcessProgram");
            StringList prog = FrameworkUtil.split(program,":");

			FrameworkUtil.validateMethodBeforeInvoke(context, prog.get(0), prog.get(1), "POSTPROCESS");
            Map returnMap = (Map) JPO.invoke(context, 
                (String) prog.get(0), null,
                (String) prog.get(1), args, Map.class);
                
            // Check returnMap
            if ( returnMap != null )
            {
                action  = (String) returnMap.get("Action");
                message = (String) returnMap.get("Message");
                newId   = (String) returnMap.get("objectId");
            }

            if ((newId == null || newId.length() == 0)  
                 &&  "CONTINUE".equalsIgnoreCase(action))
            {
                action = "STOP";
            }

            // Connect things that need to be connected (i.e. something
            // copied in a workspace folder or sim activities)

            String parentId = null;
            String parentRowId = null;
            String selectedEntityRowId = null;
            String parentToggleId = null;
            
            if ( "CONTINUE".equalsIgnoreCase(action))
            {
                String fromPage = emxGetParameter(request, "fromPage");

                ///////////////////////////////////////////////////////
                // We're coming from the create new page
                if ( "createNew".equalsIgnoreCase(fromPage) )
                {
                    action = "CONTINUE";
                    parentRowId = emxGetParameter(request, "parentRowId");
                    parentId    = emxGetParameter(request, "parentOID");
                }
                
                ///////////////////////////////////////////////////////
                // We're coming directly from the home page (vs. 
                // coming from create new that came from home page)
                else if ( "slmHome".equalsIgnoreCase(fromPage)
                          || "list".equalsIgnoreCase(fromPage) )
                {
                    // Get the selected row 
                    // - this is the entity being copied.
                    selectedEntityRowId = 
                        emxGetParameter(request,"emxTableRowId");
                    
                    // Get selected entity toggle Id.
                    String[] ids = selectedEntityRowId.split("\\|");

                    // disregard the selected row if it does not have
                    // a rel id (meaning it represents a phatom container).
                    if (ids[0] == null || ids[0].length() == 0)
                    {
                        selectedEntityRowId = null;
                    }
                    int len = ids.length;
                    if (selectedEntityRowId != null && len>2)
                    {
                        parentId = ids[2];
                    }
                }
                
                ///////////////////////////////////////////////////////
                // We're coming from the search results page
                else if ( "searchResults".equalsIgnoreCase(fromPage) )
                {
                    // Nothing special done here
                }
                
                ///////////////////////////////////////////////////////
                // We're coming from the V2 properties pages 
                else if ( "properties".equalsIgnoreCase(fromPage) )
                {
                    // Not used in V3
                }
                
                // If NOT copying an activity into a simulation
                // then find the folder to put this thing in.

                final String TYPE_SIMULATION = 
                    SimulationUtil.getSchemaProperty(
                        SimulationConstants.SYMBOLIC_type_Simulation);
             
                String parentType = "";
                if (parentId != null)
                {

                    DomainObject DO = new DomainObject(parentId);
                    parentType = DO.getInfo(
                        context, DomainObject.SELECT_TYPE );
                }

                if ( ! TYPE_SIMULATION.equalsIgnoreCase(parentType) )
                {
                    String origParentId = parentId;
                    String[] args1 = new String[]
                        { origParentId, null, objectId };
    
                    Map returnMap1 = (Map) JPO.invoke(context, 
                        "jpo.simulation.SimulationUI", null,
                        "getNewParentFolder", args1, Map.class);
                    
                    if ( returnMap1 != null )
                    {
                        parentId = (String) returnMap1.get("parentId");
                        action   = (String) returnMap1.get("Action");
                        message  = (String) returnMap1.get("Message");

                        if ( message != null && message.length() > 0 )
                        {
%>
                            <script>
                            alert("<%=message %>");
                            </script>
<%
                            message = null;
                        }
                    }
                }

            } // if ("CONTINUE"

            ///////////////////////////////////////////////////////
            // If parent is found and we can continue, do so.
            StringList contentData = new StringList(1);
            if ( "CONTINUE".equalsIgnoreCase(action)
                 && parentId != null && parentId.length() > 0 )
            {
                String[] args2 = { parentId, newId };
            
                // Connect parent with child
                Map returnMap2 = (Map) JPO.invoke(context, 
                    "jpo.simulation.SimulationUI", null,
                    "connect", args2, Map.class);

                if ( returnMap2 != null )
                {
                    action = (String) returnMap2.get("Action");
                    message = (String) returnMap2.get("Message");
                    String childId = (String) returnMap2.get("childId");
                    String relId = (String) returnMap2.get("relId");

                    contentData.add(newId + "|" + relId);

                    if ( message != null && message.length() > 9 )
                    {
%>
                        <script>
                            alert("<%=message %>");
                        </script>
<%
                        message = null;
                    }
                }
            }
            else
            {
                contentData.add(newId + "|nada");
            }
            
            // Try to update the folder to which the new 
            // entity was added.

            if ("CONTINUE".equalsIgnoreCase(action))
            {
%>
<script type="text/javascript" src="../simulationcentral/smaStructureBrowser.js"></script>
<%
                    String fromPage = emxGetParameter(request, "fromPage");
                    if("PerformanceStudy".equalsIgnoreCase(fromPage)) {                        
                        DomainObject DO = DomainObject.newInstance(context,newId);
                        String physicalId = DO.getInfo(context,"physicalid");
                        
%>
                    <script>    
                    var contentFrame = getTopWindow().opener.top,
                            physicalId = "<%=physicalId%>",
                       model = {};
                       model.physicalId = physicalId;
                       model.operation = 'copy';
                       model = JSON.stringify(model);
                       contentFrame.postMessage(model, "*");
                    </script>
<%
                    }else if("properties".equalsIgnoreCase(fromPage) 
                        || "slmHome".equalsIgnoreCase(fromPage) 
                        || "list".equalsIgnoreCase(fromPage)) {
                        StringBuffer contentURL1 = new StringBuffer(275);
                        contentURL1.append("../simulationcentral/smaHomeUtil.jsp");
                        contentURL1.append("?objectId=").append(newId);
                        contentURL1.append("&objectAction=showInBrowseTab");
                    
%>
                    <script>
                        <%--//openInHomePage("<%=newId%>") --%>
                        if ( getTopWindow().getWindowOpener() )
                            hFra=findFrame(getTopWindow().getWindowOpener().getTopWindow(),"hiddenFrame");
                         else
                            hFra = findFrame(getTopWindow(),"appletFrame");                                     
                         hFra.location.href = "<%=contentURL1.toString()%>";
                    </script>
<%                  }
            } // if ( "CONTINUE"
        } 
        catch (Exception ex)
        {
            message = ErrorUtil.getMessage(ex);
        }
        
        if ( (message != null && message.length() > 0) &&
             ! "NOCONNECT".equalsIgnoreCase(message) )
        {
%>
            <script>
                alert("<%=message %>");
            </script>
<%
        }
    }
%>
    <script>
        if ( getTopWindow().getWindowOpener() )
            getTopWindow().closeWindow();
    </script>

</body>
</html>

