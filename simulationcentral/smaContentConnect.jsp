<%-- (c) Dassault Systemes, 2007, 2008 --%>
<%--
  Utility to return xml string to structure browser.  This is called
  after adding referenced content
--%>

<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>

<%@page import = "com.dassault_systemes.smaslm.matrix.common.SimulationConstants"%>
<%@page import = "com.dassault_systemes.smaslm.matrix.common.SimulationUtil"%>
<%@page import = "com.dassault_systemes.smaslm.matrix.web.StructureBrowserUtil"%>
<%@page import = "com.dassault_systemes.smaslm.matrix.web.ErrorUtil"%>
<%@page import = "com.matrixone.apps.common.Search"%>
<%@page import = "com.matrixone.apps.domain.util.FrameworkUtil"%>
<%@page import = "java.util.HashMap"%>
<%@page import = "java.util.Iterator"%>
<%@page import = "com.matrixone.apps.common.util.ComponentsUIUtil, java.util.Enumeration, matrix.util.StringList"%>
<%@page import="com.matrixone.apps.framework.ui.UINavigatorUtil"%>
<%@page import =  "com.matrixone.apps.common.SubscriptionManager,com.matrixone.apps.common.WorkspaceVault"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.domain.DomainSymbolicConstants" %>

<jsp:useBean id="indentedTableBean"
    class="com.matrixone.apps.framework.ui.UITableIndented" scope="session" />
<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>

<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script type="text/javascript" src="../simulationcentral/smaStructureBrowser.js"></script>
<script type="text/javascript" src="../simulationcentral/smaStructureNavigator.js"></script>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>

<%

Enumeration eNumParameters = emxGetParameterNames(request);

String action = "add",  message = "";
String[] memberIDs = null;
String rootObjectId = null, objectId = null, refObjId = null;
String srcDestRelName = emxGetParameter(request, "srcDestRelName");
memberIDs = ComponentsUIUtil.getSplitTableRowIds(emxGetParameterValues(request, "emxTableRowId"));
StringList sl = new StringList(memberIDs);

rootObjectId = emxGetParameter(request, "rootObjectId");
if (rootObjectId == null)
{
    rootObjectId = emxGetParameter(request, "parentOID");
}
String timeStamp = emxGetParameter(request, "timeStamp");

Map requestMap = null;

String openedBy = emxGetParameter(request, "openedBy");

if ("fromCollections".equals(openedBy)) { //Paste from Collection
	objectId = emxGetParameter(request, "objectId");
    refObjId = memberIDs[0];
    requestMap = (HashMap)tableBean.getRequestMap(timeStamp);
    srcDestRelName = requestMap.get("srcDestRelName").toString();
}
else { 
	objectId = emxGetParameter(request, "objectId");
	    refObjId = memberIDs[0];
	    requestMap = (HashMap)indentedTableBean.getRequestMap(timeStamp);
}
MapList tskDelivrblObj = new MapList();
int objectsFromTask = 0;
for(int i = 0; i<memberIDs.length;i++){
    DomainObject DO = new DomainObject();
    DO.setId(memberIDs[i]);
    boolean isTask = DO.isKindOf(context,SimulationUtil.getSchemaProperty(DomainSymbolicConstants.SYMBOLIC_type_Task));
    if(isTask){
        String relPattern =  SimulationUtil.getSchemaProperty(DomainSymbolicConstants
            .SYMBOLIC_relationship_TaskDeliverable);
        String typePattern = SimulationUtil.getSchemaProperty(SimulationConstants.TYPE_DOCUMENTS);
        StringList objSelects = new StringList();
        objSelects.add(DomainConstants.SELECT_ID);
        tskDelivrblObj = DO.getRelatedObjects(
            context, relPattern, typePattern, objSelects,
            null, false, true,  (short)0, null, null,
            0, null, null, null);
        objectsFromTask = tskDelivrblObj.size();
    }
}



String[] args = new String[3+memberIDs.length+objectsFromTask];
args[0]=rootObjectId;
args[1]=objectId;
args[2]=srcDestRelName;
for(int ii=0;ii<memberIDs.length;ii++)
    args[ii+3]=memberIDs[ii];

for(int jj=0;jj<objectsFromTask;jj++){
    Map mp = (Map)tskDelivrblObj.get(jj);
    args[3+memberIDs.length+jj]= (String) mp.get(DomainConstants.SELECT_ID);
}


//String[] args = new String[]{rootObjectId, objectId, srcDestRelName, refObjId};
sl = new StringList(args);

String parentId = emxGetParameter(request, "objectId");
String parentRowId = (String)requestMap.get("emxParentIds");
if(parentRowId == null && "addexisting".equals(openedBy))
{
  parentRowId = emxGetParameter(request, "emxTableRowIdActual");
  if(emxGetParameter(request, "smaTableRowId") != null){
	  parentRowId = emxGetParameter(request, "smaTableRowId");
 } 
} 
String refreshFrame = (String)requestMap.get("refreshFrame");

    StringList contentData;
    try
    {
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

        if ( row.startsWith("notActive") )
        {
            if ( msg.length() == 0 )
            {
                msg = SimulationUtil.getI18NString(context,
                    "smaSimulationCentral.Content.ErrMsg.notActive");
            }
            itr.remove();
            StringList slRow = FrameworkUtil.split(row,"|");
            msg += (String) slRow.get(1)+ "\n";
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
    objectId = "";
    if ( contentData.size() > 0 &&
         "slmHome".equalsIgnoreCase(fromPage) )
    {
        StringList firstElem =
            FrameworkUtil.split((String)contentData.get(0),"|");
        objectId = (String) firstElem.get(0);
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
                "?objectId=<%=objectId %>";
        }
    </script>
<%
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


















