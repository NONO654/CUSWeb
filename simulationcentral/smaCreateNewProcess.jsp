<%-- (c) Dassault Systemes, 2007, 2008 --%>
<%--
  Utility to return xml string to structure browser.  This is called
  after adding referenced content
--%>

<%@page import="com.dassault_systemes.smaslm.matrix.common.SimulationConstants"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkUtil"%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@page import = "java.util.HashMap,java.util.Map"%>
<%@page import = "com.dassault_systemes.smaslm.matrix.common.SimulationUtil"%>
<%@page import = "com.dassault_systemes.smaslm.matrix.web.StructureBrowserUtil"%>
<%@page import = "com.dassault_systemes.smaslm.matrix.web.ErrorUtil"%>
<%@page import = "com.matrixone.apps.common.Search"%>
<%@page import = "com.matrixone.apps.domain.util.FrameworkUtil"%>
<%@page import = "java.util.HashMap"%>
<%@page import = "java.util.Iterator"%>
<%@page import = "com.matrixone.apps.common.SubscriptionManager, com.matrixone.apps.common.WorkspaceVault"%>
<%@page import = "com.dassault_systemes.smaslm.matrix.common.SimulationUtil"%>
<%@page import = "com.dassault_systemes.smaslm.matrix.common.SimulationConstants"%>
<%@page import="com.dassault_systemes.smaslm.matrix.web.SlmUIUtil"%>

<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>
<jsp:useBean id="createBean" class="com.matrixone.apps.framework.ui.UIForm" scope="session"/>

<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script type="text/javascript" src="../simulationcentral/smaStructureBrowser.js"></script>
<script type="text/javascript" src="../simulationcentral/smaStructureNavigator.js"></script>
<script language="javascript" src="../common/scripts/emxUITreeUtil.js"></script>

<%!
          private static String getDescriptor(String type)
          {
                  String file = "SimulationProcess.xml";
                  if("SimulationActivitywithPredefinedSteps".equalsIgnoreCase(type))
                      file = "SimulationActivity_PreBuild.xml";
                  else if(SimulationConstants.TYPE_SIMULATION_ACTIVITY.equalsIgnoreCase(type))
                      file = "SimulationActivity.xml";
                  return file;

          }

%>
<%
    Map requestMapForm = UINavigatorUtil.getRequestParameterMap(pageContext);
    String form =(String) requestMapForm.get("predefinedSteps");
    
    String action = "add";
    String message = "";
    String msg = "";
    matrix.db.Context context2 = 
        (matrix.db.Context)request.getAttribute("context");
    if (context2 != null)
        context = context2;

    String refreshFrame = emxGetParameter(request, "refreshFrame");

    String objectId = emxGetParameter(request, "newObjectId");
    String objectAction = emxGetParameter(request, "objectAction");
    String parentId = emxGetParameter(request, "parentOID");

    String parentRowId = emxGetParameter(request, "emxTableRowId");
    
    String program = emxGetParameter(request, "postProcessProgram");

    HashMap paramMap   = new HashMap(1);
    paramMap.put("objectId",  objectId);
    
    // add the form data to the param map
    String timeStamp = emxGetParameter(request, "timeStamp");
    HashMap formMap = createBean.getFormData(timeStamp);
    if (formMap != null)
    {
        MapList fieldList = (MapList) formMap.get("fields");
        Iterator fieldsIter = fieldList.iterator();
        while (fieldsIter.hasNext())
        {
            Map field = (Map)fieldsIter.next();
            String fieldName = (String) field.get("name");
            paramMap.put(
                fieldName,emxGetParameter(request,fieldName));
        }
    }
        


    HashMap requestMap = new HashMap(1);
    requestMap.put("parentOID", parentId);

    HashMap programMap = new HashMap(1);
    programMap.put("requestMap", requestMap);
    programMap.put("paramMap",   paramMap);
    programMap.put("requestMapForm",requestMapForm);
    // put the descriptor as a stream
    DomainObject dob = new DomainObject();
    String type = "";
    if(null!=objectId && !"".equals(objectId))
    {
        dob.setId(objectId);
        type = (String)dob.getInfo(context, DomainConstants.SELECT_TYPE);
    }
    if("true".equals(form)){
        type = "SimulationActivitywithPredefinedSteps";  
    }
    programMap.put("stream",
        "/com/dassault_systemes/smaslm/matrix/server/workflowdescriptors/"+ 
               getDescriptor(type));
    
    StringList contentData = new StringList(1);

    try
    {
        StringList prog = FrameworkUtil.split(program,":");

        // Let's do post create processing
		FrameworkUtil.validateMethodBeforeInvoke(context, prog.get(0), prog.get(1), "POSTPROCESS");
        HashMap results = (HashMap) JPO.invoke(context, 
            (String) prog.get(0), null,
            (String) prog.get(1), JPO.packArgs(programMap),
            HashMap.class);
        
        String childId = (String) results.get("objectId");
        String relId   = (String) results.get("relId");
        
        contentData.add(childId+"|"+relId);
    }
    catch (Exception ex)
    {
        action = "error";
        objectAction =    action;
        message = ErrorUtil.getMessage(ex);
        msg =   ErrorUtil.getMessage(ex);
        contentData.setSize(0);
    }
    
    
    if (parentId!=null)
    {
    	String appDirectory = "teamcentral";
    	String sLanguage = "en-US,en;q=0.9";
    	MapList folderMapList =  new  MapList();
    	WorkspaceVault WorkspaceVault      = (WorkspaceVault) DomainObject.newInstance(context,DomainConstants.TYPE_WORKSPACE_VAULT,DomainConstants.TEAM);
    	WorkspaceVault.setId(parentId);
    	folderMapList = WorkspaceVault.getAllParentWorkspaceVaults(context,parentId);
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
    
    if ( msg.length() > 0 )
        emxNavErrorObject.addMessage(msg);
    
    if ( !"error".equals(action) && msg.length() > 0 )
    {}
    if ("refreshGroupTable".equalsIgnoreCase(objectAction))
    {
    	String form2 = emxGetParameter(request, "form");
    	String href = SlmUIUtil.getCommandHref(context,
	        "SMAStation_ListRefresh", null, null, requestMap);
    	String channelCmd = "SMAStationList";
    	if ("SMAHostGroup_Create".equalsIgnoreCase(form2))
       	{
	    	href = SlmUIUtil.getCommandHref(context,
			    "SMAStationAdmin_ShowHostGroups", 
			    null, null, requestMap);
	    	channelCmd = "SMAStationAdmin_ShowHostGroups";
       	}
        %>
	    <script language="javascript">
      	var frame = null;  
      	frame = findFrame(getTopWindow(),"<%=channelCmd%>"); 
      	if (frame) 
      	{
        	frame.location.href = "<%=href%>";
      	}
	    </script>
		<%
    }
%>




