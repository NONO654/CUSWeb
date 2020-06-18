<%-- (c) Dassault Systemes, 2008 --%>
<%--
  Post process jsp for creating a Template.
  Handle the updating of the V3 SLM Home page when a Template is
  created.
--%>

<%@include file="../common/emxNavigatorInclude.inc"%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>

<%@page import="com.dassault_systemes.smaslm.matrix.common.SimulationUtil" %>
<%@page import="com.dassault_systemes.smaslm.matrix.common.SimulationConstants"%>
<%@page import="com.dassault_systemes.smaslm.matrix.server.SlmUtil"%>
<%@page import="com.dassault_systemes.smaslm.matrix.web.StructureBrowserUtil"%>
<%@page import="com.dassault_systemes.smaslm.matrix.web.ErrorUtil"%>
<%@page import = "com.matrixone.apps.common.SubscriptionManager, com.matrixone.apps.common.WorkspaceVault"%>
<%@page import="java.util.List"%>
<%@page import="com.matrixone.apps.framework.ui.UINavigatorUtil"%>
<%@page import="java.util.Map"%>
<%@page import="com.dassault_systemes.smaslm.matrix.server.SimulationContentUtil"%>

<jsp:useBean id="createBean" class="com.matrixone.apps.framework.ui.UIForm" scope="session"/>
<jsp:useBean id="indentedTableBean" class="com.matrixone.apps.framework.ui.UITableIndented" scope="session"/>

<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script type="text/javascript" src="../simulationcentral/smaStructureBrowser.js"></script>
<script type="text/javascript" src="../simulationcentral/smaStructureNavigator.js"></script>

<%
try
{
    Map requestMap = UINavigatorUtil
        .getRequestParameterMap(pageContext);

    String ppJpoParam = emxGetParameter(request, "postProcessProgram");
    boolean defaultJpo = false;
    if (ppJpoParam == null)
    {
        ppJpoParam = "jpo.simulation.Template:assignContent";
        defaultJpo = true;
    }

    String[] ppJpoParts = ppJpoParam.split(":");

    if (ppJpoParts.length != 2)
    {
        // Badly formed postProcessJPO URL parameter.
        throw new FrameworkException(
            "Error: no colon found in the postProcessProgram parameter '"
            + ppJpoParam + "'");
    }

    String templateOid = emxGetParameter(request, "newObjectId");
    String templateViewId = null, templateViewName = null, newContentId = null;
    String parentId = emxGetParameter(request, "parentOID");
    String tableRowId = emxGetParameter(request, "emxTableRowId");
    matrix.db.Context context2 = 
        (matrix.db.Context)request.getAttribute("context");
    if (context2 != null)
        context = context2;

    // The table row will either be a folder (when creating a new
    // template) or the entity that the template was created from
    // (i.e. save as template).

    String selectedObjId = tableRowId;
    String[] rowIdParts =null;
    if(tableRowId!=null)
        rowIdParts = tableRowId.split("\\|");
    else
    {
        rowIdParts = new String[2];
        rowIdParts[1]=parentId;
    }
    if (rowIdParts.length > 1 )
        selectedObjId = rowIdParts[1];


    final String SELECT_KINDOF_WSFOLDER =
        "type.kindof["
        + SimulationUtil.getSchemaProperty(
              DomainSymbolicConstants.SYMBOLIC_type_ProjectVault)
        + "]";

    boolean isWSFolder = false;
	if(selectedObjId !=null && selectedObjId.length()>0)
	{
    DomainObject objDO = new DomainObject(selectedObjId);
		 isWSFolder = 
        Boolean.parseBoolean((String) objDO.getInfo(context, SELECT_KINDOF_WSFOLDER));
	}

    HashMap programMap = null;

    if (defaultJpo)
    {
        // Call the default JPO only if the selected object is a
        // simulation or activity.

        if (isWSFolder == false)
        {
            programMap = new HashMap();
            programMap.put("templateId", templateOid);
            programMap.put("sourceId", selectedObjId);
            programMap.put("requestMap", requestMap);
        }
    }
    else
    {
        programMap = new HashMap();
        programMap.put("templateId", templateOid);
        programMap.put("sourceId", tableRowId);
        programMap.put("requestMap", requestMap);
    }

    if (programMap != null)
    {
        String jpoProgram = ppJpoParts[0];
        String jpoFunction = ppJpoParts[1];
    
        String[] methodargs = JPO.packArgs(programMap);
    
        // Do the deed.
        Map returnMap = (Map)
            JPO.invoke(context, jpoProgram, null,
            jpoFunction, methodargs, Map.class);
    
        if (returnMap != null  &&  returnMap.size() > 0)
        {
            String message = (String)returnMap.get("Message");
            String action  = (String)returnMap.get("Action");
            templateViewId = (String) returnMap.get("templateViewId");
            newContentId = (String) returnMap.get("newContentId");    
            if (message != null  &&  message.length() > 0)
            {
                String alertMessage = 
                    SimulationUtil.getI18NString(context,message);
    
                // If action == continue, display the message here
                // (and continue).
                // Otherwise, throw an exception to indicate an error.
    
                if ("continue".equalsIgnoreCase(action))
                {
                    alertMessage = FrameworkUtil.findAndReplace(alertMessage, "\n", "\\n");
                    alertMessage = FrameworkUtil.findAndReplace(alertMessage, "\r", "\\r");
%>
                    <script language="javascript">
                        alert("<%=alertMessage%>");
                    </script>
<%
                }
                else
                {
                    // Unfortunately the new object has already been
                    // created and we need to delete it.
                    // Because we are using autoname, the template 
                    // object is already committed in the database.
                    // So we need to do some fancy foot work to delete it.
                    //  - abort all the current open transactions,
                    //  - delete the template (in a transaction).
                    //  - restore the previously open transactions.

                    int transCount = 0;
                    while (ContextUtil.isTransactionActive(context))
                    {
                        transCount += 1;
                        ContextUtil.abortTransaction(context);
                    }

                    ContextUtil.startTransaction(context, true);
                    try
                    {
                        SlmUtil.deleteObjects(context, new String[] {templateOid});
                        ContextUtil.commitTransaction(context);
                    }
                    catch (Exception ex)
                    {
                        // Expect to never get here.
                        ContextUtil.abortTransaction(context);
                    }
                    
                    for (int ix=0; ix<transCount; ++ix)
                    {
                        ContextUtil.startTransaction(context, true);
                    }


                    // Now return an error like everything is normal.
                    throw new FrameworkException(alertMessage);
                }
            }
        }
    }

    
    String parentRowId = null;
    String origFolderId = null;

    if (isWSFolder)
    {
        parentRowId = tableRowId;
        origFolderId = selectedObjId;
    }
    else
    {
        if (rowIdParts.length > 2 )
            origFolderId = rowIdParts[2];
        else
        {
            if(!isWSFolder)
                origFolderId = parentId;
            else
                origFolderId = selectedObjId;  
        }
            
            // could be null in the case of the unmanaged folder.

    }


    // Get folder in which to create template (will either be
    // selected folder, default folder or no folder - in the wild)
    String[] args1 = new String[]
        { origFolderId, tableRowId, null };

    Map returnMap1 = (Map) JPO.invoke(context, 
        "jpo.simulation.SimulationUI", null,
        "getNewParentFolder", args1, Map.class);
    
    String parentFolder = null;
    if ( returnMap1 != null )
        parentFolder = (String) returnMap1.get("parentId");
    
    String action = (String) returnMap1.get("Action");
    String message = (String) returnMap1.get("Message");
    
    if ( message != null && message.length() > 0 )
    {
%>
        <script>
            alert("<%=message %>");
        </script>
<%
        message = null;
    }
    
    StringList contentData = new StringList(1);
    if ( "CONTINUE".equalsIgnoreCase(action) &&
         parentFolder != null && parentFolder.length() > 0 )
    {
        String[] args2 = { parentFolder, templateOid };
    
        Map returnMap2 = (Map) JPO.invoke(context, 
            "jpo.simulation.SimulationUI", null,
            "connect", args2, Map.class);

        if ( returnMap2 != null )
        {
            action = (String) returnMap2.get("Action");
            message = (String) returnMap2.get("Message");
            String relId = (String) returnMap2.get("relId");

            contentData.add(templateOid + "|" + relId);
        }
    }

    if ( message != null && message.length() > 0 )
    {
%>
        <script>
            alert("<%=message %>");
        </script>
<%
        message = null;
    }
    
    if (parentFolder!=null)
    {
    	String appDirectory = "teamcentral";
    	String sLanguage = "en-US,en;q=0.9";
    	MapList folderMapList =  new  MapList();
    	WorkspaceVault WorkspaceVault      = (WorkspaceVault) DomainObject.newInstance(context,DomainConstants.TYPE_WORKSPACE_VAULT,DomainConstants.TEAM);
    	WorkspaceVault.setId(parentFolder);
    	folderMapList = WorkspaceVault.getAllParentWorkspaceVaults(context,parentFolder);
    	if(folderMapList != null && folderMapList.size() > 0 ){
            Iterator folderMapListItr = folderMapList.iterator();
            while(folderMapListItr.hasNext()) {
              	Map folderMap = (Map)folderMapListItr.next();
              	String foldn  = (String)folderMap.get(WorkspaceVault.SELECT_NAME);
              	String foldId = (String)folderMap.get(WorkspaceVault.SELECT_ID);
              	String treeLabel = UITreeUtil.getUpdatedTreeLabel(application,session,request,context,foldId,(String)null,appDirectory,sLanguage);
    %>
    <script language="javascript">
          getTopWindow().changeObjectLabelInTree("<%=XSSUtil.encodeForJavaScript(context, foldId)%>","<%=treeLabel%>");
          </script>
    <%
           }
         }
    	
    }
    
    String contentURL = null, appName = null, appTrigram = null;
    boolean isXSUser = SimulationContentUtil.isXSUser(context, null);
    if (templateViewId != null && !"".equals(templateViewId) && isXSUser) {
        contentURL = "../common/emxNavigator.jsp?appName=ENOPRCB_AP&ContentPage=../simulationcentral/smaExperienceStudio.jsp?objectId="+templateOid;
        //appName=SIMEXPS_AP not working
    %>
   	<script>
       getTopWindow().location.href = "<%=contentURL%>";
    </script> 
   	<%
    }
}
catch (Exception ex)
{
    String errMsg = ErrorUtil.getMessage(ex);
    emxNavErrorObject.addMessage(errMsg);
}
    
%>







