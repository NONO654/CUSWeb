<%-- (c) Dassault Systemes, 2007, 2008 --%>
<%--
  Process instantiate template commands
--%>

<%@page import="java.util.Arrays"%>
<%@page import="java.util.ArrayList"%>
<%@page import="matrix.util.StringList"%>
<%@page import="matrix.db.Context"%>
<%@page import="com.matrixone.apps.domain.util.MqlUtil"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkException"%>
<%@include file="../common/emxNavigatorInclude.inc"%>

<%@page import = "com.dassault_systemes.smaslm.matrix.common.SimulationUtil" %>
<%@page import="com.dassault_systemes.smaslm.matrix.server.SimulationContentUtil"%>
<%@page import = "com.dassault_systemes.smaslm.matrix.common.SimulationConstants"%>
<%@page import = "com.matrixone.apps.framework.ui.UINavigatorUtil"%>
<%@page import = "com.dassault_systemes.smaslm.matrix.web.ErrorUtil"%>
<%@page import = "java.util.Enumeration"%>
<%@page import = "java.util.List"%>
<%@page import = "matrix.db.JPO"%>

<%@page import="com.matrixone.apps.domain.DomainObject"%>

<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script type="text/javascript" src="../simulationcentral/smaStructureBrowser.js"></script>
<script type="text/javascript" src="../simulationcentral/smaStructureNavigator.js"></script>
<script type="text/javascript" src="../common/scripts/emxUIModal/emxUIModal.js"></script>
<script type="text/javascript" src="../common/scripts/jquery-latest.js"></script>

<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>
<%

    //remove session data if needed.@CLEANUP
    session.removeAttribute("TargetFolder");

    // Obtain the correct context from the request
         matrix.db.Context context2 =
         (matrix.db.Context)request.getAttribute("context");
     if (context2 != null)
         context = context2;

    String  timeStamp = emxGetParameter(request, "timeStamp");
    String fromWidget  = emxGetParameter(request, "fromWidget");
    String connected = emxGetParameter(request, "connected");
    String fromAct = emxGetParameter(request, "fromAct");
    String toAct = emxGetParameter(request, "toAct");
    HashMap requestMap = UINavigatorUtil.getRequestParameterMap(pageContext);
    HashMap tableData = tableBean.getTableData(timeStamp);
    String parentRowNo = null;
    String check = emxGetParameter(request,"check");
    Boolean fromdashboard = Boolean.parseBoolean(emxGetParameter(request, "fromdashboard"));
    //get the parent OID for the target Location
    MapList objectList = (MapList)tableData.get("ObjectList");
    int rowCount = (objectList != null) ? objectList.size() : 0;
    for (int index = 1; index < rowCount; index++)
    {
        Map optionMap = (Map)objectList.get(index);
        String level = (String)optionMap.get("level");
        String title = (String)optionMap.get("title");

        if("Select".equals(title) && "2".equals(level))
            parentRowNo = (String)optionMap.get("id");
    }
    String parentRowName = "Content"+parentRowNo;
    String parentId = (String)requestMap.get(parentRowName);
    if(null == parentId){
        parentId = (String)requestMap.get("parentOID");
    }
    HashMap programMap = new HashMap();
    HashMap paramMap = new HashMap();

    // Copy all of the parameters passed on the request
    Enumeration params = request.getParameterNames();
    while (params.hasMoreElements())
    {
        String name = (String) params.nextElement();
        String value = emxGetParameter(request, name);
        paramMap.put(name,value);
    }

    programMap.put("paramMap",paramMap);
    programMap.put("requestMap",requestMap);
    programMap.put("tableData",tableData);

    String[] args = JPO.packArgs(programMap);
    String newObjectId = null;

    // If the JPO throws an exception, clean up messgae and rethrow
    // it will be caught (and handled} by the tableEditProcess JSP
    try
    {
        Map results = (Map)JPO.invoke(context,
            "jpo.simulation.Template", null,
            "instantiate", args, Map.class);

        newObjectId = (String) results.get("objectId");

        //added for Template enhancements <Release R2012> - Start

        //show alert for required fields
        String strEditCompAlert = (String) results.get("Message");

        if( null != strEditCompAlert && !"null".equalsIgnoreCase(strEditCompAlert) && !strEditCompAlert.equals("") )
        {
            //stop the execution after alert
            //if there is an edit compulsory field
            //not filled

                throw new MatrixException(strEditCompAlert);
        }
        //added for Template enhancements <Release R2012> - End

        if (newObjectId != null)  //modified for Template enhancements <Release R2012>
		{

// THE FOLLOWING CODE WAS USED IN V2 ON THE MY DESK PAGES, THEREFORE
// I'M NOT GETTING RID OF IT IN CASE WE DECIDE TO PUT THE PAGES BACK IN.
//            String parentId = emxGetParameter(request, "parentOID");
//
//            // Get the original table where the user did the Create New
//            // command.  Then get it's object list and table data
//            String origTimestamp = (String) requestMap.get("origTimestamp");
//
//            // If we have a parent (and we're coming from a page with a list,
//            // then just update the table otherwise show new entity.
//            // This is/was called from the V2 My Desk Template page, it is
//            // being left here in case we go back to it.
//            if ( parentId != null && parentId.length() > 0 &&
//                 origTimestamp != null && origTimestamp.length() > 0 )
//            {
//                // We must add the new entity to the objectList so that when
//                // the table is refreshed, it has the data
//
//                MapList objectList    = tableBean.getObjectList(origTimestamp);
//                HashMap origTableData = tableBean.getTableData(origTimestamp);
//
//                // Update the object list with the new entity and reload
//                // it into the table data
//                Map M = new HashMap();
//                M.put("level","1");
//                M.put("relationship","Vaulted Objects");
//                M.put("id", newObjectId );
//                objectList.add(M);
//
//                origTableData.put("objectList",objectList);
//
//                // Update tablebean with new data
//                tableBean.setTableData(origTimestamp,origTableData);
//            }
//
//            // Open new entity in home page
//            else
//            {

                //String parentId = emxGetParameter(request, "parentOID");

			String action = "";
			String message = "";
			boolean isSimulation = false;
			boolean isFolder = false;
			boolean isTestCase = false;
			boolean isTestExecution = false;
			boolean isTask = false;
			boolean isTestMethod = false;
			boolean isActivity = false;
			// If the parent is a simulation, then we're adding an
			// activity to the simulation via the "create new"
			// command using a template.  If this is the case, then
			// we already have the parent so we don't need to get
			// it from the JPO.



			if (parentId != null && parentId.length() > 0) {

				final String SELECT_KINDOF_PROCESS = "type.kindof["
		+ SimulationUtil.getSchemaProperty(SimulationConstants.SYMBOLIC_type_Simulation) + "]";

				final String SELECT_KINDOF_ACTIVITY = "type.kindof["
		+ SimulationUtil.getSchemaProperty(SimulationConstants.SYMBOLIC_type_SimulationActivity)
		+ "]";

				final String SELECT_KINDOF_FOLDER = new StringBuilder().append("type.kindof[")
						.append(SimulationUtil
								.getSchemaProperty(DomainSymbolicConstants.SYMBOLIC_type_ProjectVault))
						.append("]").toString();

				final String SELECT_KINDOF_TESTCASE = new StringBuilder().append("type.kindof[")
						.append(SimulationUtil
								.getSchemaProperty(DomainSymbolicConstants.SYMBOLIC_type_TestCase))
						.append("]").toString();

				final String SELECT_KINDOF_TESTEXECUTION = new StringBuilder().append("type.kindof[")
						.append(SimulationUtil.getSchemaProperty("type_TestExecution")).append("]").toString();

				final String SELECT_KINDOF_TASK = new StringBuilder().append("type.kindof[")
						.append(SimulationUtil.getSchemaProperty("type_Task")).append("]").toString();

				final String SELECT_KINDOF_TESTMETHOD = new StringBuilder().append("type.kindof[")
						.append(SimulationUtil.getSchemaProperty("type_TestMethod")).append("]").toString();

				DomainObject objDO = new DomainObject(parentId);

				isSimulation = Boolean.parseBoolean((String) objDO.getInfo(context, SELECT_KINDOF_PROCESS));
				isFolder = Boolean.parseBoolean(objDO.getInfo(context, SELECT_KINDOF_FOLDER));
				isTestCase = Boolean.parseBoolean(objDO.getInfo(context, SELECT_KINDOF_TESTCASE));
				isTestExecution = Boolean.parseBoolean(objDO.getInfo(context, SELECT_KINDOF_TESTEXECUTION));
				isTask = Boolean.parseBoolean(objDO.getInfo(context, SELECT_KINDOF_TASK));
				isTestMethod = Boolean.parseBoolean(objDO.getInfo(context, SELECT_KINDOF_TESTMETHOD));
				isActivity = Boolean.parseBoolean((String) objDO.getInfo(context, SELECT_KINDOF_ACTIVITY));

				if (isSimulation || isFolder || isTestCase || isTestExecution || isTask || isTestMethod
						|| isActivity) {
					action = "CONTINUE";
					message = "";
				}
			}

                final String REL_VAULTED_OBJECTS =
                    SimulationUtil.getSchemaProperty(
                        SimulationConstants.
                        SYMBOLIC_relationship_VaultedObjects);

                StringList objSelects = new StringList();
                objSelects.add(DomainConstants.SELECT_ID);

                StringList relSelects = new StringList();
                relSelects.add(
                    DomainConstants.SELECT_RELATIONSHIP_ID);
                relSelects.add(
                    DomainConstants.SELECT_RELATIONSHIP_NAME );
                DomainObject newProcessObject =
                    new DomainObject(newObjectId);
                Map relationMap =
                    newProcessObject.getRelatedObject(
                        context,
                        REL_VAULTED_OBJECTS,
                        false,
                        objSelects,
                        relSelects);

                boolean isObjectConnectedToDefaultFolder = false;
                //if("DefaultFolder".equals(parentName))
                 //   isObjectConnectedToDefaultFolder = true;
                if("".equals(parentId))
                    isObjectConnectedToDefaultFolder = true;
                try{
                    if(relationMap != null){
                    String relationId = (String)relationMap.get(
                        DomainConstants.SELECT_RELATIONSHIP_ID);

                    if(!"".equalsIgnoreCase(relationId) &&
                        relationId != null)
                    {
                        String defaultId = SimulationUtil.
                                     getWorkingFolderOID(context, true);

                        String folderID = ((String)relationMap.get("id")!=null)?
                            (String)relationMap.get("id"):"";

                        if(folderID.equals(defaultId))
                            isObjectConnectedToDefaultFolder = true;
                    }

                    }
                }catch(Exception nullException){
                    /*
                     * Process is not connected to default folder
                     * ignore exception
                     */
                }


                // not instantiating from a simulation or folder so put new
                // thing into the default folder.

                if (!isSimulation && !isFolder && !isTestCase && !isTestExecution && !isTask && !isTestMethod &&
                    !isObjectConnectedToDefaultFolder && !isActivity)
                {
                    Map returnMap1 = (Map) JPO.invoke(context,
                        "jpo.simulation.SimulationUI", null,
                        "getNewParentFolder", null, Map.class);

                    if ( returnMap1 != null )
                        parentId = (String) returnMap1.get("parentId");

                    action = (String) returnMap1.get("Action");
                    message = (String) returnMap1.get("Message");
                }

                if ( "CONTINUE".equalsIgnoreCase(action) &&
                     parentId != null && parentId.length() > 0 &&
                     !isObjectConnectedToDefaultFolder )
                {
                    String[] args2 = { parentId, newObjectId };
					if("true".equals(fromWidget)){
                    	ArrayList<String> ar = new ArrayList<String>(Arrays.asList(args2));
                    	ar.add(connected);
                    	ar.add(fromAct);
                    	ar.add(toAct);
                    	ar.add(fromWidget);
                    	args2 = ar.toArray(new String[ar.size()]);
                    }

                    Map returnMap2 = (Map) JPO.invoke(context,
                        "jpo.simulation.SimulationUI", null,
                        "connect", args2, Map.class);

                    if ( returnMap2 != null )
                    {
                        action = (String) returnMap2.get("Action");
                        message = (String) returnMap2.get("Message");
                    }
                }

                if ( message != null && message.length() > 0 )
                {
%>
                <script>
                    alert("<%=message %>");
                </script>
<%
                }

                //added for Template enhancements <Release R2012> - Start
                String strMode = (String)requestMap.get("mode");
                String isApply = (String)requestMap.get("isApply");

                //added for Template enhancements <Release R2012> - End

               // for slm-lite we do not want to open the newly instantiated object
               // in the home page we want to go to the "My Simulations" tab and the
               // new object will be at the top since the table is sorted on
               // modified date in descending order
               if (strMode.equalsIgnoreCase(
                    SimulationConstants.TEMPLATE_MODE_INSTANTIATE_LITE) ||
                    strMode.equalsIgnoreCase(SimulationConstants.TEMPLATE_MODE_INSTANTIATE_RUN_LITE) ||
                    strMode.equalsIgnoreCase(SimulationConstants.TEMPLATE_MODE_INSTANTIATE_RUN))
                {
                   String physicalId = "";
                   if(newObjectId != null && !"".equals(newObjectId)){
                       DomainObject obj = new DomainObject(newObjectId);
                       physicalId = obj.getInfo(context,"physicalid");
                   }

                   String runSimulation = "False";
                   if( strMode.equalsIgnoreCase(SimulationConstants.TEMPLATE_MODE_INSTANTIATE_RUN_LITE) ||
                       strMode.equalsIgnoreCase(SimulationConstants.TEMPLATE_MODE_INSTANTIATE_RUN))
                   {
                       runSimulation = "True";
                   }
                   String argsDi[] = null;
                   boolean isLicenced =SimulationContentUtil.isDiscoverUser(context, argsDi);
                   if(!isLicenced){
                    return;
                   }
%>
                    <script>
                        var fromdashboard = "<%=fromdashboard%>" == "true";
                        if(! fromdashboard)
                        {
                            if (getTopWindow() && getTopWindow().getWindowOpener() && getTopWindow().getWindowOpener().getTopWindow() )
                            {
                                frame = findFrame(getTopWindow().getWindowOpener().getTopWindow(),"content");
                                if (frame != null)
                                    {
                                    getTopWindow().currentApp = "SIMDISB_AP";
                                    var appsMenuList = new Array();
                                    appsMenuList[0] = 'SMAScenario_Definition_New';
                                    try{
                                    getTopWindow().changeProduct('SIMULIA', 'Performance Study', 'SIMDISB_AP', appsMenuList, 'SIMDISB_AP', null);
                                    }
                                    catch(error)
                                    {
                                        console.log(error);
                                    }
                                    getTopWindow().getWindowOpener().emxUICategoryTab.destroy();
                                       if(getTopWindow().getWindowOpener().objStructureFancyTree){
                                           getTopWindow().getWindowOpener().objStructureFancyTree.destroy();
                                        }
                                    getTopWindow().getWindowOpener().showMyDesk();
                                    getTopWindow().getWindowOpener().bclist.insert('MyDesk', 'root', ':', 'Performance Study','','../webapps/SMAProcPSUI/ps-app/ps-app.html',null,null);
                                    var openURL = getTopWindow().openURL;
                                        if(typeof openURL != 'string'){
                                         openURL = openURL ? openURL.value : null;
                                        }
                                     getTopWindow().getWindowOpener().openURL = null;
                                     frame.location.href = openURL ? openURL : "../webapps/SMAProcPSUI/ps-app/ps-app.html?runSimulation="+"<%=runSimulation%>"+"&physicalId="+"<%=physicalId%>";

                                    }
                            }

                        }

                    </script>
<%
                }
               else if (strMode.equalsIgnoreCase(
                   SimulationConstants.TEMPLATE_MODE_INSTANTIATE)
                   && (isTestCase||isTestExecution||isTask)){
                   %>
                   <script>
                   var fromdashboard = "<%=fromdashboard%>" == "true";
                   if(! fromdashboard){
                	   var topWin = getTopWindow();
                       if(topWin.getWindowOpener != null)
                       {
                       topWin = topWin.getWindowOpener().getTopWindow();
                       }
                       var hiddenFrame =findFrame(topWin,"detailsDisplay");
                       hiddenFrame.location.href=hiddenFrame.location.href;
                   }
                   </script>
                   <%
               }
                else if(!(strMode.equalsIgnoreCase(
                    SimulationConstants.TEMPLATE_MODE_INSTANTIATE_RUN)
                    ) && (isApply == null || "false".equals(isApply)))
                {

                    DomainObject obj = new DomainObject(newObjectId) ;
                    String entryPoint = null;

                    if(obj.isKindOf(context, SimulationConstants.TYPE_SIMULATION_DOCUMENT)
                        || obj.isKindOf(context,SimulationConstants
                            .TYPE_SIMULATION_ACTIVITY))
                        entryPoint = "showInBrowseTab";
                    else
                        entryPoint = "EntryInPerformanceStudy";


                    StringBuffer contentURL1 = new StringBuffer(275);
                    contentURL1.append("../simulationcentral/smaHomeUtil.jsp");
                    contentURL1.append("?objectId=").append(newObjectId);
                    contentURL1.append("&objectAction=").append(entryPoint);
                    %>
                    <script>
                        try
                        {
                          var fromdashboard = "<%=fromdashboard%>" == "true";
                          if(fromdashboard)
                          {
                            var procObj ={
                                  id: "<%=newObjectId%>",
                                  check: "<%=check%>"
                                  }
                            getTopWindow().opener.top.postMessage(procObj, "*");
                            getTopWindow().closeWindow();
                          }
                          else {
                              if(getTopWindow() && getTopWindow().getWindowOpener()){
                                  var hFra = findFrame(getTopWindow().getWindowOpener().getTopWindow(),"hiddenFrame");
                                  hFra.location.href = "<%=contentURL1.toString()%>";
                                 }else{
                                   var psURL = "../common/emxNavigator.jsp?ContentPage=../webapps/SMAProcPSUI/ps-app/ps-app.html?physicalId="+"<%=newObjectId%>";
                                   getTopWindow().location.href = psURL;
                                 }
                           }

                         }
                        catch(error)
                        {
                            console.log(error);
                        }
                     </script>
                        <%
                }

          }
          if("true".equalsIgnoreCase(fromWidget)) {
              %>
              <script>
              try{
                  if(window.getTopWindow().formEditDisplay.document.editDataForm.isPopup.value === 'true'){
                    alert = console.log;
                  }
                  window.getTopWindow().formEditDisplay.document.editDataForm.isPopup.value = false;
              }catch(e){
                console.log(e);
              }
              var contentFrame = getTopWindow().opener.top,
                 model = {};
                 model.operation = 'Instantiate';
                 model = JSON.stringify(model);
                 contentFrame.postMessage(model, "*");
              </script>
<%
          }
    }

    catch (Exception ex)
    {
        String message = ErrorUtil.getMessage(ex);

        // put the error message on the request for ENOVIA to handle
        request.setAttribute("error.message", message);
    }

%>
