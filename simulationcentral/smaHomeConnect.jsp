<%-- (c) Dassault Systemes, 2007, 2008 --%>
<%--
  Utility to return xml string to structure browser.  This is called
  after adding referenced content
--%>

<%@page import="matrix.util.StringList"%>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>

<%@page import = "com.dassault_systemes.smaslm.matrix.common.SimulationUtil"%>
<%@page import = "com.dassault_systemes.smaslm.matrix.web.StructureBrowserUtil"%>
<%@page import = "com.dassault_systemes.smaslm.matrix.web.ErrorUtil"%>
<%@page import = "com.matrixone.apps.common.Search"%>
<%@page import = "com.matrixone.apps.domain.util.FrameworkUtil"%>
<%@page import = "java.util.HashMap"%>
<%@page import = "java.util.Iterator"%>
<%@page import =  "com.matrixone.apps.common.SubscriptionManager,com.matrixone.apps.common.WorkspaceVault"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.domain.DomainSymbolicConstants" %>

<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>

<script language="javascript" src="../common/scripts/emxUISearch.js"></script>
<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script type="text/javascript" src="../simulationcentral/smaStructureBrowser.js"></script>
<script type="text/javascript" src="../simulationcentral/smaStructureNavigator.js"></script>

<%

    String action = "add";
    String message = "";
    String parentRowId = "";
    StringBuffer data = new StringBuffer(1);

    String timeStamp = emxGetParameter(request, "timeStamp");
    HashMap requestMap = (HashMap)tableBean.getRequestMap(timeStamp);

    String refreshFrame = (String)requestMap.get("refreshFrame");

    // Get row ID of parent (so we can add to it)
    parentRowId = (String)requestMap.get("emxTableRowId");
    StringList SL  = new StringList();
    String simSAId = "";
    if(parentRowId==null)
    {
        simSAId = emxGetParameter(request, "emxTableRowId");
    }
    else
    {
        SL      = FrameworkUtil.split(parentRowId,"|");
        simSAId = (String)SL.get(2);
    }
    

    // Get parent ID
    String parentId = (String)requestMap.get("objectId");

    // Get parent Sim/SA ID
     

    // Get relationship name
    String relNameSymb = 
        (String)requestMap.get(Search.REQ_PARAM_SRC_DEST_REL_NAME);

    // Get the list of child entities to add
    String[] childRowIds = request.getParameterValues("emxTableRowId");

    // Add the parent and all select categories to the args list
    String[] args = new String[3+childRowIds.length];
    args[0] = simSAId;
    args[1] = parentId;
    args[2] = relNameSymb;

    for ( int ii=0; ii<childRowIds.length; ii++ )
        args[ii+3] = childRowIds[ii];

    StringList contentData;
    try
    {
        // Let's create the categories
        contentData = (StringList)JPO.invoke(context, 
            "jpo.simulation.SimulationUI", null,
                "addContent", args, StringList.class);
    }
    catch (Exception ex)
    {
        action = "error";
        message = ErrorUtil.getMessage(ex);
        contentData = new StringList();
    }
    
    // The user may have tried to add duplicates which is bad.
    // So look for them and get the data to show a message below.
    String msg = "";
    Iterator itr = contentData.iterator();
    while (itr.hasNext())
    {
        String row = (String) itr.next();
        if ( row.startsWith("duplicate") )
        {
            if ( msg.length() == 0 )
            {
                msg = SimulationUtil.getI18NString(context, 
                    "smaSimulationCentral.Content.ErrMsg.cannotaddduplicate1");
            }

            itr.remove();
            StringList slRow = FrameworkUtil.split(row,"|");
            msg += (String) slRow.get(1);
        }
    }
    if ( msg.length() > 0 )
        emxNavErrorObject.addMessage(msg);
    
    if ( !"error".equals(action) && msg.length() > 0 )
    {
%>
        <script>
            var DisplayErrorMsg = "";
<%
            // Parse the string for "\n" so that the string can be displayed properly in Javascript
            StringTokenizer token = new StringTokenizer(msg, "\n");
            while (token.hasMoreTokens())
            {
                String strMsg = token.nextToken().trim();
%>
                DisplayErrorMsg += '<%=strMsg%>' + '\n';
<%
            }
            
            // If there is any data content to add, don't close the
            // top here or else the add function won't have a place
            // to work
            String closeTop = (contentData.size() > 0) ? "false" : "true";
%>
            alert(DisplayErrorMsg);

            if ( getTopWindow().getWindowOpener() && <%=closeTop %>)
                getTopWindow().closeWindow();
        </script>
<%
    }
    
    // Update content side of home page if it is available and the
    // command was to add content to the home table of contents and
    // not to add to a sim/sa content.
    String fromPage = (String)requestMap.get("fromPage");
    String objectId = "";
    if ( contentData.size() > 0 && 
         "slmHome".equalsIgnoreCase(fromPage) )
    {
        StringList firstElem = 
            FrameworkUtil.split((String)contentData.get(0),"|");
        objectId = (String) firstElem.get(0);
%>
    <script type="text/javascript">
        var frame = null;
        if ( getTopWindow().getWindowOpener() )
            frame = findFrame(getTopWindow().getWindowOpener().getTopWindow(),"smaHomeHeader");
        else
            frame = findFrame(getTopWindow(),"smaHomeHeader");
    
        if ( frame != null )
        {
            frame.location.href =
                "../simulationcentral/smaHomeContentHeader.jsp" + 
                "?objectId=<%=objectId %>";
        }
    </script>
<%
    }
    else
    {
        if(fromPage==null)
        {
            %>
            <script>
            updateFolderCount("<%=simSAId%>","<%=parentId%>");
            refreshDetailsTable("<%=simSAId%>","<%=parentId%>");
            getTopWindow().closeWindow();
            </script>
            <%
        }
        return;
    }

    // Convert parent ID and added content to an appropriate javascript
    // code that either adds the entities or displays an error message.
    String sXML = StructureBrowserUtil.convertToXMLString(
        context, action, message, parentRowId, contentData, 
            refreshFrame, true );
    
    //HF-111927 : To publish this event for Folder subscriptions as 
    //Team Central does not handle this.
     final String TYPE_DOCUMENTS =
        SimulationUtil.getSchemaProperty(
            DomainSymbolicConstants.SYMBOLIC_type_DOCUMENTS);
     if((objectId!=null)&&(objectId.length()>0))
     {
         DomainObject doObj = new DomainObject(objectId);
         if(doObj.isKindOf(context,TYPE_DOCUMENTS))
                    SimulationUtil.publishWorkspaceVaultEvent(context, objectId, parentId,
                            WorkspaceVault.EVENT_CONTENT_ADDED);
     }
%>
    <%= sXML %>
    
    

