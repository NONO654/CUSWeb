<%-- (c) Dassault Systemes, 2007, 2008 --%>
<%--
  Handles creating the new revision of the selected object,
  and updating the Home page if appropriate.
--%>

<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>

<%@page import = "com.dassault_systemes.smaslm.matrix.common.SimulationConstants" %>
<%@page import = "com.dassault_systemes.smaslm.matrix.common.SimulationUtil" %>
<%@page import = "com.dassault_systemes.smaslm.matrix.web.StructureBrowserUtil"%>
<%@page import = "com.dassault_systemes.smaslm.matrix.web.ErrorUtil"%>
<%@page import = "com.matrixone.apps.domain.util.FrameworkUtil"%>
<%@page import = "com.matrixone.apps.framework.ui.*" %>
<%@page import = "java.util.HashMap"%>
<%@page import = "java.util.Map"%>
<%@page import = "matrix.util.StringList"%>

<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<jsp:useBean id="formEditBean" class="com.matrixone.apps.framework.ui.UIForm" scope="session"/>
<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>
<jsp:useBean id="indentedTableBean" class="com.matrixone.apps.framework.ui.UITableIndented" scope="session"/>

<html>
<head>
<title></title>
</head>
<body>
<% 
    String objectAction = emxGetParameter(request,"objectAction");
    String objectId     = emxGetParameter(request,"objectId");
    
    String submitLocation = emxGetParameter(request,"submitLocation");
    matrix.db.Context context2 = 
        (matrix.db.Context)request.getAttribute("context");
    if (context2 != null)
        context = context2;
  //..I24 added the code to get the last revision
    DomainObject objId = DomainObject.newInstance(context,objectId);
    BusinessObject busLastRev = objId.getLastRevision(context);
    String lastRevDocId = busLastRev.getObjectId();
    objectId = lastRevDocId;

    
    String strCopyFiles = emxGetParameter(request, "copyFiles");
    boolean copyFiles = false;
    if (strCopyFiles != null && strCopyFiles.length() > 0 && (strCopyFiles.equalsIgnoreCase("true") || strCopyFiles.equalsIgnoreCase("false"))) {
        copyFiles = Boolean.parseBoolean(strCopyFiles);
    }
   //...I24 end
   
    
    if ( "reviseAnalyticsCase".equalsIgnoreCase(objectAction) || 
    	 "reviseSimulation".equalsIgnoreCase(objectAction) ||
         "reviseActivity".equalsIgnoreCase(objectAction)   ||
         "reviseTemplate".equalsIgnoreCase(objectAction)   ||
         "reviseAttributeGroup".equalsIgnoreCase(objectAction)   ||
         "reviseConnector".equalsIgnoreCase(objectAction) ||
         "reviseDocument".equalsIgnoreCase(objectAction) )
    {
        String newId   = "";
        String message = "";
        String action  = "";

        try
        {
            String newName   = emxGetParameter(request,"Name");
            String newRevId  = emxGetParameter(request,"Revision");
            String newVault  = emxGetParameter(request,"Vault");
            String newDesc   = emxGetParameter(request,"Description");
            String newTitle  = emxGetParameter(request,"Title");
            String newPolicy = emxGetParameter(request,"Policy");
            // m6d 2013HL Revision Comments textarea field added
            String newRevisionComments = emxGetParameter(request,"Revision Comments");

            //vn1 2012xHL Revision Enhancement : Retrieve 
            //ReviseContent values from Revise form
            String reviseContent = emxGetParameter(request,"ReviseContent");
            
            HashMap paramMap = new HashMap();
            paramMap.put("objectId", objectId);
            paramMap.put("Name",     newName);
            paramMap.put("Revision", newRevId);
            paramMap.put("Vault",    newVault);
            paramMap.put("Description", newDesc);
            paramMap.put("Title",    newTitle);
            paramMap.put("Policy",   newPolicy);
         // m6d 2013HL Revision Comments textarea field added to map
            paramMap.put("Revision Comments" , newRevisionComments);

            //vn1 2012xHL Revision Enhancement : Add CopyAccess and 
            //ReviseContent values in paramMap
            paramMap.put("copyFiles", copyFiles);  // I24: to handle copyFile option for document.
                                     
            if("on".equalsIgnoreCase(reviseContent))
                paramMap.put("reviseContent", "Yes");
            else
                paramMap.put("reviseContent", "No");
            
            String timeStamp = emxGetParameter(request, "timeStamp");
            HashMap formMap = formEditBean.getFormData(timeStamp);

            HashMap programMap = new HashMap();
            programMap.put("paramMap",paramMap);
            programMap.put("formMap", formMap);

            String[] args = JPO.packArgs(programMap);

            // Do the deed - call the post copy function
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

            // If this is an activity in a simulation, we don't want
            // to connect this revision to a folder.
            String inSim = "false";
            if ( "CONTINUE".equalsIgnoreCase(action))
            {
                final String REL_SIM_SA = 
                    SimulationUtil.getSchemaProperty(
                        SimulationConstants.SYMBOLIC_relationship_SimulationActivity);
                
                DomainObject DO = new DomainObject(objectId);
                inSim = DO.getInfo(context, "to["+REL_SIM_SA+"]");
            }

            // Connect things that need to be connected (i.e. something
            // revised in a workspace folder or sim activities)
            if ( "CONTINUE".equalsIgnoreCase(action) 
                 && (newId != null && newId.length() > 0) )
            {
            	
            
                if("false".equalsIgnoreCase(inSim) )
                {     

%>
<script type="text/javascript" src="../simulationcentral/smaStructureNavigator.js"></script>
                  
<%               
                	            
                }
                // Just return it ..in case of Activity revisioning (on activity revisioning it should not goes out of revisions tab)
                else
                {
                	return;
                }
                
                // Insert code for calling smaHomeUtil (showinBrowse tab)
            	StringBuffer contentURL1 = new StringBuffer(275);
                    
                if ("refreshInDiscover".equals(submitLocation))
                {
                    
                    DomainObject DO = new DomainObject(newId);
                    String physId = DO.getInfo( context, 
                        SimulationConstants.PHYSICAL_ID); 

                    
                    contentURL1.append(
                      "../common/emxPortal.jsp?portal=SMAHome_Discover")
                      .append("&HelpMarker=SMAHome_Discover")
                      .append("&mode=advanced")
                      .append("&suiteKey=simulationcentral")
                      .append("&objectId=").append(newId)
                      .append("&physicalId=").append(physId);
                } 
                else
                {
                    contentURL1.append("../simulationcentral/smaHomeUtil.jsp");
                    contentURL1.append("?objectId=").append(newId);
                    contentURL1.append("&objectAction=showInBrowseTab");
                }
%>			                       
                    
                <script>
                var subAction = "<%=submitLocation%>";
                if (subAction == "refreshInDiscover")
                {
                    if ( getTopWindow().getWindowOpener() )
                        hFra=findFrame(
                          getTopWindow().getWindowOpener().getTopWindow(),"smaDiscoverHomeContent");
                     else
                        hFra = 
                          findFrame(getTopWindow(),"smaDiscoverHomeContent");
                    hFra.location.href = "<%=contentURL1.toString()%>";
                }
                else  if (subAction == "refreshInAdvise")
                {
                    if ( getTopWindow().getWindowOpener() )
                        hFra=findFrame(
                          getTopWindow().getWindowOpener().getTopWindow(),"SMAHome_SMAHome_Advise_TabCases");
                     else
                        hFra = 
                          findFrame(getTopWindow(),"SMAHome_SMAHome_Advise_TabCases");
                    hFra.location.reload(true);
                }
                else if (subAction == "PerformanceStudy") {
                		<%
                		DomainObject DO = DomainObject.newInstance(context,newId);
                        String physicalId = DO.getInfo(context,"physicalid");
                		%>
                		var contentFrame = getTopWindow().opener.top,
                            physicalId = "<%=physicalId%>",
                            model = {};
                        model.physicalId = physicalId;
                        model.operation = 'revise';
                        model = JSON.stringify(model);
                                contentFrame.postMessage(model, "*");
                        }
                else
                {
                    if ( getTopWindow().getWindowOpener() )
                       hFra=findFrame(getTopWindow().getWindowOpener().getTopWindow(),"hiddenFrame");
                    else
                       hFra = findFrame(getTopWindow(),"hiddenFrame");                                     
                    hFra.location.href = "<%=contentURL1.toString()%>";
                }   
                   
                </script>
            <%          
            } %>                          
<%           
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
     
 
<script language="Javascript">
//fix for IR-099502V6R2012x window not closing on click of 'Done' button by m6d start 
if(getTopWindow().getWindowOpener())
{
    getTopWindow().closeWindow();
}
//fix for IR-099502V6R2012x window not closing on click of 'Done' button by m6d end
</script>


</body>
</html>

