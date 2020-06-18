<%-- (c) Dassault Systemes, 2008 --%>
<%--
  Process various SLM commands on the SLM Home page.
--%>
<%@page import="com.dassault_systemes.smaslm.matrix.server.SimulationContentUtil"%>
<%@page import="com.dassault_systemes.smaslm.matrix.common.json.JSONObject"%>
<%@page import="com.dassault_systemes.smaslm.matrix.common.json.JSONArray"%>


<jsp:useBean id="shortcutInfo" class="com.matrixone.apps.framework.ui.UIShortcut" scope="session" />


<%@page import="com.dassault_systemes.smaslm.common.util.StringValidator"%>
<%@page import="java.util.Iterator"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkUtil"%>
<%@page import="com.matrixone.apps.domain.util.MqlUtil"%>
<%@page import="com.matrixone.apps.domain.util.MapList"%>
<%@page import="com.matrixone.apps.domain.util.ContextUtil"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkException"%>
<%@page import="com.matrixone.apps.framework.ui.UIUtil"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.domain.DomainRelationship" %>
<%@page import="com.matrixone.apps.common.CommonDocument"%>
<%@page import="com.matrixone.apps.domain.DomainConstants" %>
<%@page import="com.matrixone.apps.domain.DomainSymbolicConstants" %>
<%@page import="com.matrixone.apps.framework.ui.UINavigatorUtil"%>
<%@page import="com.matrixone.apps.framework.ui.UICache"%>
<%@page import="com.dassault_systemes.smaslm.common.util.MessageServices"%>
<%@page import="com.dassault_systemes.smaslm.matrix.common.AccessUtil"%>
<%@page import="com.dassault_systemes.smaslm.matrix.common.SimulationUtil" %>
<%@page import="com.dassault_systemes.smaslm.matrix.common.SimulationConstants" %>
<%@page import="com.dassault_systemes.smaslm.matrix.server.SimulationCategory"%>
<%@page import="com.dassault_systemes.smaslm.matrix.server.SIMULATIONS"%>
<%@page import="com.dassault_systemes.smaslm.matrix.server.SimulationJob"%>
<%@page import="com.dassault_systemes.smaslm.matrix.web.ErrorUtil"%>
<%@page import="com.dassault_systemes.smaslm.matrix.web.Parameters" %>
<%@page import="com.dassault_systemes.smaslm.matrix.web.SlmUIUtil"%>
<%@page import="com.dassault_systemes.smaslm.matrix.server.SlmUtil"%>
<%@page import="com.dassault_systemes.smaslm.matrix.web.StructureBrowserUtil"%>
<%@page import =  "com.matrixone.apps.common.SubscriptionManager,com.matrixone.apps.common.WorkspaceVault"%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>

<%@page import="matrix.db.Context" %>
<%@page import="matrix.db.Access" %>
<%@page import="matrix.db.Context" %>
<%@page import="matrix.db.Command" %>
<%@page import="matrix.db.BusinessObject" %>
<%@page import="matrix.db.JPO"%>
<%@page import="matrix.db.User"%>
<%@page import="matrix.dbutil.SelectSetting"%>
<%@page import="matrix.util.StringList"%>
<%@page import="matrix.util.Pattern"%>
<%@page import="matrix.util.MatrixException"%>

<%@page import="java.net.InetAddress"%>
<%@page import="java.net.URL"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.Enumeration"%>
<%@page import="java.util.HashMap"%>
<%@page import="java.io.UnsupportedEncodingException"%>
<%@page import="com.dassault_systemes.smaslm.matrix.server.Template"%>

<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>

<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../simulationcentral/smaWebUtil.inc"%>

<script type="text/javascript" src="../simulationcentral/smaUITree.js"></script>
<script type="text/javascript" src="../simulationcentral/smaStructureBrowser.js"></script>
<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script language="javascript" src="../common/scripts/emxUIModal.js"></script>
<script language="javascript" src="../common/scripts/emxUITreeUtil.js"></script>
<script type="text/javascript" src="../simulationcentral/smaStructureNavigator.js"></script>
<script type="text/javascript" src="../common/scripts/emxUIShortcut.js"></script>
<script type="text/javascript" src="../common/scripts/jquery-latest.js"></script>
<script	type="text/javascript" src="../webapps/AmdLoader/AmdLoader.js" ></script>
<script type="text/javascript" src="../simulationcentral/smaAdviseOpenWidget.js"></script>

<%
    // What is it that we want to do?
    // Possible objectAction values:
    //    abort
    //    access (multi-select)
    //    addExisting
    //    addWorkspaceContent
    //    assignActivity
    //    assignConnector
    //    assignSimulation
    //    changeOwner (multi-select)
    //    continue
    //    copy
    //    createActivity
    //    createActivityInSim
    //    createAttributeGroup
    //    createConnector
    //    createDocOther
    //    createDocSimNV
    //    createDocSimVer
    //    createSimulation
    //    createTemplate
    //    delete (multi-select)
    //    getJobStatus (multi)
    //    goToDefaultFolder
    //    goToHomeFolder
    //    goToLastViewed
    //    goToNormalView
    //    impactGraph
    //    instantiate
    //    lock/unlock (multi-select)
    //    repeat
    //    run
    //    saveAsTemplate
    //    selectActivityRevision
    //    setAsDefaultFolder
    //    unSetAsDefaultFolder
    //    setAsHomeFolder
    //    showInBrowseTab
    //    showReferences
    //    uploadImage
    //    viewSummaryForAct
    //    unlinkWorkspaceFolder
    //    openInDiscover
    //    refreshThis
    //    expandThis


    Map requestMap = UINavigatorUtil.getRequestParameterMap(pageContext);
    MapList list = new MapList();

    String objectAction = emxGetParameter(request, "objectAction");
    String newUI = emxGetParameter(request, "newUI");
    String relid = (String)requestMap.get("relId");
    String oid   = (String)requestMap.get("objectId");
    String plus1 = emxGetParameter(request, "plus");
    if("OpenAdvisePortal".equals(objectAction)){
		%>
        <script language="javascript">
             openResultAnalytics();
        </script>
        <%
		return;
	}
    if("subscribeJob".equals(objectAction))
    {
        String tableRowId = emxGetParameter(request, "emxTableRowId");
        if(tableRowId.contains("|"))
        {
            StringList at = FrameworkUtil.split(tableRowId, "|");
            String tat    = (String)at.get(1);
            oid = tat;
        }
        StringBuilder contentURL = new StringBuilder(175);
        contentURL.append("../components/emxSubscriptionDialog.jsp?HelpMarker=emxhelpsubscriptionevents")
        .append("&suiteKey=Components&StringResourceFileId=emxComponentsStringResource&SuiteDirectory=components")
        .append("&objectId=").append(oid).append("&widgetId=null&targetLocation=popup");
        %>
        <script language="javascript">
             getTopWindow().showModalDialog("<%=contentURL.toString()%>");
        </script>
        <%
        return;
    }
    if("checkAndLoadComposeMenu".equals(objectAction))
    {
        String strTitle = "emxTeamCentral.Name.Content";

        %>
        <script>
        // VE4 - dev note
        // not clear why the header is not picked up otherwise.
        // tried giving correct suiteKey.
        // null and empty are handled by ENOVIA


        var url ="../common/emxIndentedTable.jsp?program=emxTeamContent:getFolderContentIds&table=TMCContentSummary&header=emxTeamCentral.Name.Content&topActionbar=TMCContentSummaryTopActionBar&bottomActionbar=TMCContentSummaryBottomActionBar&freezePane=Name&topActionbar=TMCContentSummaryTopActionBar&bottomActionbar=TMCContentSummaryBottomActionBar&selection=multiple&HelpMarker=emxhelpfoldercontent&parentRelName=relationship_VaultedDocuments&displayView=details&FilterFramePage=${COMPONENT_DIR}/emxCommonDocumentCheckoutUtil.jsp&FilterFrameSize=1&emxSuiteDirectory=teamcentral";


        var oid = "&objectId="+"<%=oid%>";

        // Check with VE4 about this top. It needs to be replaced with getTopWindow call
        var productActivated = getTopWindow().curProd;
        console.log("in Process composer, product is -->"+productActivated);

        // License setting promotion yet to be done to ENOVIA code
        // temporarily deactivating this code
        // the tree menu type_ProjectVault is not used by TEAM for display
        // of its tree. So this change is safe for now. @VE4
        //if("ENOBUPS_AP" === productActivated || "SCE" === productActivated || "ENOPRCB_AP" === productActivated)
            url = url + oid;
        //else
            //url = url + team + oid;

        var ddFrame = findFrame(getTopWindow(),"detailsDisplay");
        ddFrame.location.href=url;
        </script>
        <%

    }
    if ( (objectAction == null) || (objectAction.equals("")) )
    {
        if(nullandemptycheck(oid))
        {
            StringBuilder wintopURL = new StringBuilder(175);
            wintopURL.append("../simulationcentral/smaHomeUtil.jsp?")
            .append("objectAction=showInBrowseTab")
            .append("&objectId=").append(oid);
            %>
              <script>
                 try
                 {
                     var hFra = findFrame(getTopWindow(),"hiddenFrame");
                     hFra.location.href = "<%=wintopURL%>";
                 }
                 catch(error)
                 {
                     console.log("Failed loading Wintop styled URL!");
                 }
              </script>
            <%
            return;
        }
        else
        {
            emxNavErrorObject.addMessage("objectAction not found");
            objectAction = "";
        }

    }
    if(objectAction.equals("createTemplate") || objectAction.equals("createConnector") ||
            objectAction.equals("createAttributeGroup") || objectAction.equals("createSimulation"))
    {
        if(oid == null || oid.equals(""))
        {
             try
             {
                 oid = (String) JPO.invoke( context,
                     "jpo.simulation.SimulationUI", null,
                     "getWorkingFolderOID", null, String.class);
             }
             catch (Exception e)
             {

             }
        }
    }
    else if(objectAction.equals("goToHomeFolder") || objectAction.equals("goToDefaultFolder") || objectAction.equals("goToLastViewed"))
    {
        //oid = null;
    }
    else
    {
        // get an interned string ref for faster reference compares
        objectAction = objectAction.intern();
    }

    String[] sRowIds = null;
    String objectId = null;
    String parentId = null;
    String[] relIds = null;
    String[] objIds = null;
    String[] parIds = null;
    int nObjs = 0;

    String rootParentId = emxGetParameter(request, "objectId");

    String tableRowId = emxGetParameter(request, "emxTableRowId");
    String stepId = "";

    /////////////////
    // Get selected rows from the request map
    //
    // Add Category does not have anything selected
    // Fake the remaining code out by making the parent selected
    if(objectAction.equals("assignConnector"))
    {

            if(tableRowId.contains("|"))
            {
                StringList at = FrameworkUtil.split(tableRowId, "|");
                String tat    = (String)at.get(1);
                stepId = (String)at.get(0);
                objectId = tat;
                parentId = tat;
                //if(nullandemptycheck(tat))
                 //   sRowIds[0] = tat;
            }

            //parentId = sRowIds[0];

        /**
        String SPLIT_CHAR = "\\";
        // Assign Connector is only enabled from Steps page
        String stepId = emxGetParameterValues(request, "emxTableRowId");
        String ids[] = null;
        if (stepId.contains(SimulationConstants.XML_TABLE_EXPAND_SEPERATOR))
        {
            ids = stepId.split(SPLIT_CHAR+SimulationConstants.XML_TABLE_EXPAND_SEPERATOR);
        } else if (stepId.contains("%5E")) // "%5E" is unicode string for ^
        {
            ids = stepId.split("%5E");
        }
       **/

    }

    else
    {
        sRowIds = emxGetParameterValues(request, "emxTableRowId");
    }

    if("OpenInComposeWorkspace".equals(objectAction))
    {

    }
    if(objectAction.equals("openInDiscover"))
    {
        tableRowId = emxGetParameter(request, "emxTableRowId");
        if(tableRowId != null && tableRowId.contains("|") &&
            (oid == null || "".equals(oid)))
        {
            StringList at = FrameworkUtil.split(tableRowId, "|"); // tableRowId: "|oid||0,3"
            String tat    = (String)at.get(0);
            oid = tat;
            sRowIds = null;
        }
    }
    // sRowIds should never be null since these commands must have a
    // selection single/multiple setting and are thus caught
    // by M1 if nothing is selected
    else if ( (sRowIds == null) || (sRowIds.length == 0) )
    {
        if("true".equals(newUI) || nullandemptycheck(oid))
        {
            if(nullandemptycheck(oid))
            {

                relIds = new String[1];
                objIds = new String[1];
                parIds = new String[1];
                sRowIds = new String[1];

                String select1="to[Data Vaults].id";
                String select2="from.id";
                String select3="to[Vaulted Objects].id";
                String select4="to[Simulation Activity].id";
                String select5="to[Simulation Template Content].id";
                String dump_clause="dump";


                StringList lList  = new StringList();
                lList.addElement(select1);
                lList.addElement(select3);
                lList.addElement(select4);
                lList.addElement(select5);

                relid= getRelId( context, lList, oid, dump_clause);
                newUI="true";

                relIds[0]=relid;
                objIds[0]=oid;
                if(!"showInBrowseTab".equals(objectAction) && relid!=null && !"".equals(relid))
                parIds[0]= printConnectionMQL(context,relid, select2 , dump_clause );

                parentId = oid;
                // for RMB "folder" and "add existing" to work
                objectId = oid;
                //sRowIds[0] =oid;

            }


        }

        else if (!objectAction.startsWith("goTo") &&
            objectAction != "showInBrowseTab")
        {
            emxNavErrorObject.addMessage(EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", context.getLocale(), "emxFramework.Common.PleaseSelectitem"));
        }
    }

    // Something was selected, get the object and parent ids
    // ignore if create host since selection does not apply
    else if (!"createHost".equals(objectAction))
    {
        if(("true".equals(newUI) || nullandemptycheck(sRowIds[0]))
            && !"OpenAdvise".equals(objectAction) && !"selectActivityRevision".equals(objectAction))
        {
            if(nullandemptycheck(sRowIds[0]))
            {
                if(sRowIds[0].contains("|"))
                {
                    if(sRowIds[0].startsWith("|"))
                    {
                        sRowIds[0] = "nada"+sRowIds[0];
                    }
                    StringList at = FrameworkUtil.split(sRowIds[0], "|");
                    String tat    = (String)at.get(1);
                    if(nullandemptycheck(tat))
                        sRowIds[0] = tat;
                    else
                        sRowIds[0] = (String)at.get(0);
                }

                relIds = new String[1];
                objIds = new String[1];
                parIds = new String[1];

                final String TYPE_SIMULATIONACTIVITY =
                    SimulationUtil.getSchemaProperty(
                        SimulationConstants.SYMBOLIC_type_SimulationActivity);

                String select1="to[Data Vaults].id";
                String select2="from.id";
                String select3="to[Vaulted Objects].id";
                String select4="to[Simulation Content - Owned].id";
                String select5="to[Simulation Content - Referenced].id";
                String select6="to["+TYPE_SIMULATIONACTIVITY+"].id";
                String dump_clause="dump";

                StringList lList  = new StringList();
                lList.addElement(select1);
                lList.addElement(select3);
                lList.addElement(select4);
                lList.addElement(select5);
                lList.addElement(select6);
                relid= getRelId( context, lList, sRowIds[0], dump_clause);
                newUI="true";

                relIds[0]=relid;
                objIds[0]=sRowIds[0];
                if(!objectAction.equals("saveAsHomeTemplate") && relid!=null && !"".equals(relid))
                {
                parIds[0]= printConnectionMQL(context,relid, select2 , dump_clause );
                }
                parentId = sRowIds[0];

                if(objectAction.equals("createActivityInActivity"))
                {
                    objectId = objIds[0];
                }

                //objectId = oid;
                //sRowIds[0] = oid;

            }
        }
        else
        {
            nObjs = sRowIds.length;
            relIds = new String[nObjs];
            objIds = new String[nObjs];
            parIds = new String[nObjs];
            for (int i = 0; i < nObjs; i++)
            {
                StringList sIds = convertRowId(sRowIds[i]);
                relIds[i] = (String) sIds.get(0);
                objIds[i] = (String) sIds.get(1);
                parIds[i] = (String) sIds.get(2);

                if (sRowIds[i].startsWith("nada"))
                {
                    sRowIds[i] = sRowIds[i].substring(4);
                }

                if (objIds[i] == null && (objectAction == "showReferences"))
                {
                    objIds[i] = relIds[i];
                    relIds[i] = null;
                }
            }
            // Many of the commands below are single select commands
            // so get the object id from the first item selected
            objectId = objIds[0];
            parentId = parIds[0];
        }

    }


    /////////////////
    // The following are all the commands that do NOT open a popup
    // window (not including the javascript prompt).  If popup is
    // not popped up, don't close it ;-)
    boolean isPopup = true;
    boolean opensPopup = false;
    String windowName = null;
    boolean turnsOffProgress = false;
    if (objectAction.equals("OpenInComposeWorkspace") ||
        objectAction.equals("openInExperienceStudio") ||
        objectAction.equals("EntryInCompose") ||
        objectAction.equals("EntryInPerformanceStudy") ||
        objectAction.equals("EntryInAdhoc") ||
        objectAction.equals("EntryInExperienceStudio") ||
        objectAction.equals("EntryInDiagramming") ||
        objectAction.equals("TemplateList") ||
        objectAction.equals("ConnectorList") ||
        objectAction.equals("AttributeList") ||
        objectAction.equals("AttributeGroupList") ||
        objectAction.equals("OpenAdvise")     ||
        objectAction.equals("assignActivity")     ||
        objectAction.equals("assignSimulation")   ||
        objectAction.equals("assignDoc")          ||//wu4-(Porting)-Template for Simulation Document
        objectAction.equals("activateHosts")      ||
        objectAction.equals("deactivateHosts")    ||
        //objectAction.equals("delete")             ||
        objectAction.equals("lock")               ||
        objectAction.equals("unlock")             ||
        objectAction.equals("setAsHomeFolder")    ||
        objectAction.equals("setAsDefaultFolder") ||
        objectAction.equals("unSetAsDefaultFolder") ||
        objectAction.equals("setCurrentItem")     ||
        objectAction.equals("getJobStatus")       ||
        objectAction.equals("goToHomeFolder")     ||
        objectAction.equals("goToDefaultFolder")  ||
        objectAction.equals("goToLastViewed")     ||
        objectAction.equals("showInBrowseTab")    ||
        objectAction.equals("expandSelectedObject")    ||
        objectAction.equals("selectActivityRevision") ||
        objectAction.equals("unlinkWorkspaceFolder") ||
        objectAction.equals("flipSimview") ||
        objectAction.equals("refreshThis") ||
        objectAction.equals("expandThis")  ||
        objectAction.equals("flipSimview")      ||
        objectAction.equals("openInDiscover")   ||
        objectAction.equals("flipSimActview"))
    {
        isPopup = false;

        if (objectAction.equals("showReferences")||
            objectAction.equals("assignActivity") ||
            objectAction.equals("assignDoc")        ||//wu4-(Porting)-Template for Simulation Document
            objectAction.equals("assignSimulation"))
        {
            opensPopup = true;
        }
        else if (objectAction.equals("delete")   ||
                 objectAction.equals("lock")   ||
                 objectAction.equals("unlock") ||
                 objectAction.equals("unlinkWorkspaceFolder"))
        {
            turnsOffProgress = true;
        }
    }

    /////////////////
    // Contains URL for action
    StringBuilder contentURL = new StringBuilder(175);

    String refreshFrame = emxGetParameter(request, "refreshFrame");
    if (refreshFrame == null)
        refreshFrame = "smaHomeTOCContent";

    boolean appendRefreshFrame = false;

    // Set default refresh command
    String returnAction = "";
    String returnMsg = "";

    String cmd = null;

    try
    {
        // Do the actual work...

        // reset flag.
        cmdExpected = false;

        // Check if the arguments are correct, if the user has access
        // and if items are not locked (and if user is not the locker)
        // If all this passes, then proceed with the action
        if (cmdChecksOk(context, objIds, parIds, relIds, objectAction,
            emxNavErrorObject))
        {
            if ( objectAction.equals("OpenInComposeWorkspace") )  //////////////
            {

                contentURL.append("../common/emxIndentedTable.jsp?inquiry=SMAFindCompose_First100ModifiedSimulation&inquiryLabel=smaSimulationCentral.MySimulations.Owned&table=SMAListSimulationsNew&selection=multiple&header=smaSimulationCentral.SimProcs.Name&disableSorting=true&multiColumnSort=false&toolbar=SMAProcessListToolbar&export=false&PrinterFriendly=false&pagination=100&compare=false&objectBased=false&suiteKey=SimulationCentral&expandProgram=jpo.simulation.Simulation:getOrderedActivities&sortColumnName=none");
            }

            else if ( objectAction.equals("EntryInCompose") )  //////////////
            {
                %>
                <script language="javascript">
                    var appsMenuList = new Array();
                    appsMenuList[0] = 'SMAScenario_Definition_New';
                    getTopWindow().changeProduct('SIMULIA', 'Process Composer', 'ENOPRCB_AP', appsMenuList, 'ENOPRCB_AP', null);
                    getTopWindow().openPanel();
                </script>
                <%
                contentURL.append("../common/emxIndentedTable.jsp?inquiry=SMAFindCompose_First100ModifiedSimulation&inquiryLabel=smaSimulationCentral.MySimulations.Owned&table=SMAListSimulationsNew&selection=multiple&header=smaSimulationCentral.SimProcs.Name&disableSorting=true&multiColumnSort=false&toolbar=SMAProcessListToolbar&export=false&PrinterFriendly=false&pagination=100&compare=false&objectBased=false&suiteKey=SimulationCentral&expandProgram=jpo.simulation.Simulation:getOrderedActivities&sortColumnName=none");
            }
            else if ( objectAction.equals("EntryInAdhoc") )  //////////////
            {
                %>
                <script language="javascript">
                    var appsMenuList = new Array();
                    appsMenuList[0] = 'SMAScenario_Definition_New';
                    getTopWindow().changeProduct('SIMULIA', 'Simulation Companion', 'SIMCOMP_AP', appsMenuList, 'SIMCOMP_AP', null);
                    getTopWindow().openPanel();
                </script>
                <%
                contentURL.append("../common/emxIndentedTable.jsp?inquiry=SMAFindAdhoc_Simulation&table=SMAAdhocListSimulations&toolbar=SMAListSimulationsToolbar&selection=multiple&header=smaSimulationCentral.Adhoc&disableSorting=true&multiColumnSort=false&suiteKey=SimulationCentral");
            }

            else if ( objectAction.equals("EntryInExperienceStudio") )  //////////////
            {
                %>
                <script language="javascript">
                    var appsMenuList = new Array();
                    appsMenuList[0] = 'SMAScenario_Definition_New';
                    getTopWindow().changeProduct('SIMULIA', 'Process Composer', 'ENOPRCB_AP', appsMenuList, 'ENOPRCB_AP', null);

                </script>
                <%
                contentURL.append("../common/emxIndentedTable.jsp?program=jpo.simulation.SLMLiteTables:getSimulationTemplates&table=SMAExperienceStudioListSimulations&toolbar=SMATemplateListToolbar&selection=multiple&header=smaSimulationCentral.ExperienceStudio&disableSorting=true&multiColumnSort=false&suiteKey=SimulationCentral&export=false&PrinterFriendly=false&pagination=0&compare=false&objectBased=false&customize=false&expandProgram=jpo.simulation.Home:getSCEWorkSpaceFolderList");
            }
            else if ( objectAction.equals("EntryInDiagramming") )
            {
                DomainObject doj = new DomainObject(oid);

                String physicalId = doj.getInfo
                    (context, SimulationConstants.PHYSICAL_ID);

                contentURL.append("../webapps/SMAProcWebApp/cmp-app.htm?suiteKey=SimulationCentral&objectId="+physicalId);
                %>
                <script language="javascript">

                var ddFrame = findFrame(getTopWindow(),"detailsDisplay");

                ddFrame.location.href="<%=contentURL.toString()%>";

                </script>
                <%

                return;
            }
        else if ( objectAction.equals("TemplateList") )  //////////////
            {
                %>
                <script language="javascript">
                    var appsMenuList = new Array();
                    appsMenuList[0] = 'SMAScenario_Definition_New';
                    getTopWindow().changeProduct('SIMULIA', 'Process Composer', 'ENOPRCB_AP', appsMenuList, 'ENOPRCB_AP', null);
                </script>
                <%
                contentURL.append("../common/emxIndentedTable.jsp?inquiry=SMAFindCompose_Template&table=SMANewPageMockUp&selection=multiple&header=smaSimulationCentral.Templates&disableSorting=true&multiColumnSort=false&toolbar=SMATemplateListToolbar&export=false&PrinterFriendly=false&pagination=0&compare=false&objectBased=false&customize=false&suiteKey=SimulationCentral&expandProgram=jpo.simulation.Home:getSCEWorkSpaceFolderList");
            }
        else if ( objectAction.equals("ConnectorList") )  //////////////
        {
            %>
            <script language="javascript">
                try {
                    var appsMenuList = new Array();
                    appsMenuList[0] = 'SMAScenario_Definition_New';
                    getTopWindow().changeProduct('SIMULIA', 'Process Composer', 'ENOPRCB_AP', appsMenuList, 'ENOPRCB_AP', null);    
                } catch (error) {
                    console.log(error);
                }
                
            </script>
            <%
            contentURL.append("../common/emxIndentedTable.jsp?inquiry=SMAFindCompose_Connector&table=SMANewPageMockUp&selection=multiple&header=smaSimulationCentral.Entry.Connectors&disableSorting=true&multiColumnSort=false&toolbar=SMAConnectorListToolbar&export=false&PrinterFriendly=false&pagination=0&compare=false&objectBased=false&customize=false&suiteKey=SimulationCentral");
        }
        else if ( objectAction.equals("AttributeList") )  //////////////
        {
            %>
            <script language="javascript">
                try {
                    var appsMenuList = new Array();
                    appsMenuList[0] = 'SMAScenario_Definition_New';
                    getTopWindow().changeProduct('SIMULIA', 'Process Composer', 'ENOPRCB_AP', appsMenuList, 'ENOPRCB_AP', null);
                } catch (error) {
                    console.log(error);
                } 
                    
            </script>
            <%
            contentURL.append("../common/emxIndentedTable.jsp?table=SMASimType_Attributes&showRMB=false&header=smaSimulationCentral.Search.Label.SimTypeAttributes&toolbar=SMASimType_ManageAttributesToolbar&selection=multiple&program=jpo.simulation.SimulationAttributes:getAttributesTable&objectBased=false&sortColumnName=Name&CancelButton=true&CancelLabel=smaSimulationCentral.Button.Close&HelpMarker=SMASimType_ManageAttributes&export=false&PrinterFriendly=false&pagination=0&compare=false&customize=false&suiteKey=SimulationCentral&SuiteDirectory=simulationcentral");
        }
        else if ( objectAction.equals("AttributeGroupList") )  //////////////
            {
                %>
                <script language="javascript">
                    try {
                        var appsMenuList = new Array();
                        appsMenuList[0] = 'SMAScenario_Definition_New';
                        getTopWindow().changeProduct('SIMULIA', 'Process Composer', 'ENOPRCB_AP', appsMenuList, 'ENOPRCB_AP', null);    
                    } catch (error) {
                        console.log(error);
                    }
                    
                </script>
                <%
                contentURL.append("../common/emxIndentedTable.jsp?inquiry=SMAFindCompose_AttributeGroup&table=SMANewPageMockUp&selection=multiple&header=smaSimulationCentral.Entry.AttributeGroups&disableSorting=true&multiColumnSort=false&toolbar=SMAAttributeGroupListToolbar&export=false&PrinterFriendly=false&pagination=0&compare=false&objectBased=false&customize=false&suiteKey=SimulationCentral");
            }
            else if(objectAction.equals("subscribe"))
            {
                contentURL.append("../components/emxSubscriptionDialog.jsp?HelpMarker=emxhelpsubscriptionevents")
                .append("&objectId=").append(oid);
                %>
                <script language="javascript">
                     getTopWindow().showModalDialog("<%=contentURL.toString()%>");
                </script>
                <%
                return;
            }
            else if ( objectAction.equals("OpenAdvise") )  //////////////
            {
                session.setAttribute("specialRowID",tableRowId);

                contentURL.append("../common/emxNavigator.jsp?ContentPage=../simulationcentral/smaRunAdviseJob.jsp")
                .append("&emxTableRowId=").append(tableRowId);

            }
            else if ( objectAction.equals("flipSimview") )  //////////////
            {
                contentURL.append("../common/emxPortal.jsp?portal=SMASim_PowerViewFlip&categoryTreeName=type_Simulation&toolbar=SMASimFlipToolBar");
                contentURL.append("&suiteKey=SimulationCentral&Export=false&ShowPageURLIcon=true&HelpMarker=emxhelpsim_PowerViewflip")
                .append("&selection=multiple&PrinterFriendly=false&objectId=").append(oid);

            }
            else if(objectAction.equals("flipSimActview")){
                contentURL.append("../common/emxPortal.jsp?portal=SMASimAct_PowerViewFlip&categoryTreeName=type_SimulationActivity&toolbar=SMASimActPowerViewToolBar");
                contentURL.append("&suiteKey=SimulationCentral&Export=false&ShowPageURLIcon=true&HelpMarker=emxhelpsim_PowerViewflip")
                .append("&selection=multiple&PrinterFriendly=false&objectId=").append(oid);
            }
            else if(objectAction.equals("openInDiscover") || objectAction.equals("EntryInPerformanceStudy")){
                final String TYPE_SIMULATIONJOB =
                    SimulationUtil.getSchemaProperty(
                        SimulationConstants.SYMBOLIC_type_SimulationJob);
                final String TYPE_SIMULATION = SimulationUtil.getSchemaProperty(
                        SimulationConstants.SYMBOLIC_type_Simulation);


                String processId = (String)requestMap.get("processId");


                if(oid != null) {
                    DomainObject doObj = new DomainObject(oid);
                    if(doObj.isKindOf(context,TYPE_SIMULATIONJOB))
                    {
                        oid = doObj.getInfo(context, "relationship[Simulation Job].from.physicalid");
                    }else if(doObj.isKindOf(context,TYPE_SIMULATION)){
                        oid = doObj.getInfo(context, "physicalid");
                    }
                }
                if(processId != null)
                    oid = processId;

                String argsDi[] = null;
                boolean isLicenced =SimulationContentUtil.isDiscoverUser(context, argsDi);
                if(!isLicenced){
                  return;
                }

                %>
                <script>
                var topFrm = getTopWindow();
                frame = findFrame(topFrm,"content");
                if (frame == null || frame == undefined)
                    {
                    topFrm = getTopWindow().getWindowOpener().getTopWindow();
                    frame = findFrame(topFrm,"content");
                    }
                topFrm.currentApp = "SIMDISB_AP";
                var appsMenuList = new Array();
                appsMenuList[0] = 'SMAScenario_Definition_New';
                try {
                  topFrm.changeProduct('SIMULIA', 'Performance Study', 'SIMDISB_AP', appsMenuList, 'SIMDISB_AP', null);
                  topFrm.showMyDesk();
                } catch (e) {
                  console.log(e);
                }
                var openURL = topFrm.openURL;
                if(typeof openURL != 'string'){
                     openURL = openURL ? openURL.value : null;
                }
                var objId = "<%=oid%>";
                if(objId == "null")
                    frame.location.href = openURL ? openURL : "../webapps/SMAProcPSUI/ps-app/ps-app.html";
                else
                    frame.location.href = openURL ? openURL : "../webapps/SMAProcPSUI/ps-app/ps-app.html?physicalId="+"<%=oid%>";


                </script>
                <%
                return;
            }
            else if ( objectAction.equals("openInExperienceStudio") )  //////////////
            {
                objectId = emxGetParameter(request, "objectId");
                contentURL = new StringBuilder(175);
                final String RELATIONSHIP_SIMULATION_TEMPLATE_CONTENT = SimulationUtil.getSchemaProperty(SimulationConstants.SYMBOLIC_relationship_SimulationTemplateContent);
                final String RELATIONSHIP_SIMULATION_TEMPLATE_VIEW = SimulationUtil.getSchemaProperty(SimulationConstants.SYMBOLIC_relationship_SimulationTemplateView);
                final String kindOfSimualtion = SlmUtil.getKindOfString(SimulationUtil.getSchemaProperty(SimulationConstants.SYMBOLIC_type_Simulation));
                final String TYPE_SimulationTemplate =
                    SimulationUtil.getSchemaProperty(
                            SimulationConstants.SYMBOLIC_type_SimulationTemplate);
                final String TYPE_SimulationTemplateView =
                    SimulationUtil.getSchemaProperty(
                            SimulationConstants.SYMBOLIC_type_SimulationTemplateView);
                final String TITLE =  SimulationUtil.getSelectAttributeTitleString();
                boolean isXSUser = SimulationContentUtil.isXSUser(context, null);
                Template DO = null;
                boolean isSimulationTemplate = false, isTemplateView = false;
                String templateViewId = null, simId = null, templateId = null, templateTitle = null;;
                if (objectId != null)
                {
                    DO = new Template(objectId);
                    StringList templateSelects = new StringList(new String[] {SimulationConstants.PHYSICAL_ID, TITLE});
                    Map templateInfo = DO.getInfo(context, templateSelects);
                    templateId = (String)(templateInfo.get(SimulationConstants.PHYSICAL_ID));
                    templateTitle = (String)(templateInfo.get(TITLE));

                    MapList mapList = DO.getContentAndViewInfo(context);
                    Map map = null;
                    String relationshipName = null;
                    for (int i = 0; i < mapList.size(); i++)
                    {
                        map = (Map) mapList.get(i);
                        relationshipName = (String) map.get("relationship");
                        if (RELATIONSHIP_SIMULATION_TEMPLATE_CONTENT.equals(relationshipName))
                        {
                            isSimulationTemplate = Boolean.valueOf((String)map.get(kindOfSimualtion));
                            simId = (String) map.get("physicalid");
                        } else if (RELATIONSHIP_SIMULATION_TEMPLATE_VIEW.equals(relationshipName)) {
                            isTemplateView = true;
                            templateViewId = (String) map.get("physicalid");
                        }
                    }
                }
                if (isSimulationTemplate && isTemplateView && isXSUser) {
                    //append IDs to the URL and call experience studio
                    contentURL.append("../simulationcentral/smaExperienceStudio.jsp").append("?viewId=").append(templateViewId).append("&simId=").append(simId).append("&objectId=").append(templateId).append("&templateTitle=").append(templateTitle);
                } else {
                    contentURL.append("../common/emxTree.jsp?objectId="+objectId);
                }
                %>
                <script language="javascript">
                var topFrm = getTopWindow().getWindowOpener().getTopWindow();
                var hasXSLicense = "<%=Boolean.toString(isXSUser) %>";
                var frame = findFrame(topFrm,"content");
                if (frame == null || frame == undefined)
                    {
                    topFrm = getTopWindow();
                    frame = findFrame(topFrm,"content");
                    }

                if ("true" == hasXSLicense)
                {
                    topFrm.currentApp = "SIMDISB_AP";
                    var appsMenuList = new Array();
                    appsMenuList[0] = 'SMAScenario_Definition_New';
                    topFrm.changeProduct('SIMULIA', 'Process Experience Studio', 'SIMEXPS_AP', appsMenuList, 'SIMEXPS_AP', null);
                    topFrm.showMyDesk();
                }

                    var openURL = topFrm.openURL;
                    if(typeof openURL != 'string'){
                         openURL = openURL ? openURL.value : null;
                    }
                    frame.location.href = openURL ? openURL : "<%=contentURL.toString()%>";
                </script>
                <%
            }
            else if (objectAction.equals("assignActivity") ||
                objectAction.equals("assignSimulation") ||
                objectAction.equals("assignDoc"))//wu4-(Porting)-Template for Simulation Document
            {
                String confirmMsg = null;

                /* check for a parameter that indicates that the user
                 * has confirmed this delete operation
                 */
                if (emxGetParameter(request, "confirmAssign") == null)
                {
                    Map returnMap = (Map) JPO.invoke(
                        context,
                        "jpo.simulation.Template",
                        null,
                        "getAssignedId",
                        new String[] {objectId},
                        Map.class);

                    String confirmKey = null;
                    if (returnMap != null && returnMap.size() != 0)
                    {
                        if (objectAction.equals("assignActivity"))
                        {
                            confirmKey = "smaSimulationCentral.Template.Confirm.AssignActivity";
                        }
                        else if (objectAction.equals("assignSimulation"))
                        {
                            confirmKey = "smaSimulationCentral.Template.Confirm.AssignSimulation";
                        }
                        //wu4-Start-(Porting)-Template for Simulation Document
                        else if (objectAction.equals("assignDoc"))
                        {
                            confirmKey = "smaSimulationCentral.Template.Confirm.AssignSimDoc";
                        }
                        //wu4-End-(Porting)-Template for Simulation Document
                    }

                    // if we have a key get the prompt string
                    if (confirmKey != null)
                    {
                        confirmMsg = SimulationUtil.getI18NString
                                (context,
                                confirmKey);
                    }
                }

                if (confirmMsg != null)
                {
%>

<html>
    <head>
        <script language="JavaScript">
            <!--
            function pageLoaded()
            {
                //debugger;
                if (confirm('<%= confirmMsg %>'))
                {
                    document.tempForm.submit();
                }
            }
            //-->
        </script>
    </head>
    <body onload="pageLoaded();">
        <form name="tempForm" action="<%= "../simulationcentral/smaHomeUtil.jsp" %>"
            method="POST">
            <input type="hidden" name="confirmAssign" value="true"/>
<%
                    // add the rest of the parameters to the request
                    for (Iterator iter = Parameters.getParameterList(request).iterator();
                         iter.hasNext();)
                    {
                        Parameters.Parameter param = (Parameters.Parameter) iter.next();
%>
            <input name="<%= UINavigatorUtil.htmlEncode(param.getName()) %>"
<%
                        String paramValue = param.getValue();
                        if (paramValue != null)
                        {
%>
                value="<%= UINavigatorUtil.htmlEncode(paramValue) %>"
<%
                        }
%>
                type="hidden"/>
<%
                    }
%>
        </form>
    </body>
</html>
<%
                    /* have to return here so that the response is not
                     * interpreted as XML
                     */
                    return;
                }

                if ( objectAction.equals("assignActivity") )  /////////////
                {
                    // For IR-013373 Passing additional parameters to
                    // update the Template after assigning the activity-vn1
                    cmd = "SMATemplate_ContentAssignActivity";

                    String href = "../common/emxFullSearch.jsp?showInitialResults=true&from3DSpace=true&field=TYPES=type_SimulationActivity:Policy!=policy_SimulationTemplateContent&table=AEFGeneralSearchResults&selection=single&suiteKey=SimulationCentral&targetLocation=hiddenFrame&submitURL=../simulationcentral/smaTemplateAssignProcess.jsp&resultsToolbar=SMACommon_SearchResultToolbar&isTo=&HelpMarker=SMATemplate_ContentAssignActivity";

                    String timeStamp = emxGetParameter(request, "timeStamp");

                    if ( href != null && href.length() > 0 )
                    {
                        windowName = "ASSIGN_ACTIVITY";
                        contentURL.append(href)
                        .append("&refreshFrame=").append(refreshFrame)
                        .append("&emxTableRowId=").append(sRowIds[0])
                        .append("&fromPage=newUI")
                        .append("&timeStamp=").append(timeStamp)
                        .append("&parentOID=")
                        .append(parentId)
                        .append("&objectId=").append(oid);
                        appendRefreshFrame = true;
                    }
                }
                //wu4-Start-(Porting)-Template for Simulation Document
                else if ( objectAction.equals("assignDoc") )  /////////////
                {
                    // For IR-013373 Passing additional parameters to
                    // update the Template after assigning the process-vn1
                    cmd = "SMATemplate_ContentAssignSimdoc";

                    String href = "../components/emxCommonSearch.jsp?formName=editDataForm&"+
                        "frameName=formEditDisplay&searchmode=addexisting&suiteKey=Components&"+
                        "searchmenu=SMASearchContainer&searchcommand=SMASimDocumentSingle_Search&"+
                        "selection=single&isTo=true&srcDestRelName=dummy&"+
                        "SubmitURL=../simulationcentral/smaTemplateAssignProcess.jsp&"+
                        "resultsToolbar=SMACommon_SearchResultToolbar&isTo=&"+
                        "HelpMarker=SMATemplate_ContentAssignSimdoc";

                    String timeStamp = emxGetParameter(request, "timeStamp");

                    if ( href != null && href.length() > 0 )
                    {
                        windowName = "ASSIGN_DOC";
                        contentURL
                        .append(href)
                        .append("&refreshFrame=").append(refreshFrame)
                        .append("&emxTableRowId=").append(sRowIds[0])
                        .append("&fromPage=newUI")
                        .append("&timeStamp=").append(timeStamp)
                        .append("&objectId=").append(oid);
                        appendRefreshFrame = true;
                    }
                }
                //wu4-End-(Porting)-Template for Simulation Document
                else if ( objectAction.equals("assignSimulation") )  /////////////
                {
                    // For IR-013373 Passing additional parameters to
                    // update the Template after assigning the process-vn1
                    cmd = "SMATemplate_ContentAssignSimulation";

                    String href = "../common/emxFullSearch.jsp?showInitialResults=true&from3DSpace=true&field=TYPES=type_Simulation:Policy!=policy_SimulationTemplateContent&table=AEFGeneralSearchResults&selection=single&suiteKey=SimulationCentral&targetLocation=hiddenFrame&submitURL=../simulationcentral/smaTemplateAssignProcess.jsp&resultsToolbar=SMACommon_SearchResultToolbar&isTo=&HelpMarker=SMATemplate_ContentAssignSimulation";

                    String timeStamp = emxGetParameter(request, "timeStamp");

                    if ( href != null && href.length() > 0 )
                    {
                        windowName = "ASSIGN_PROCESS";
                        contentURL
                        .append(href)
                        .append("&refreshFrame=").append(refreshFrame)
                        .append("&emxTableRowId=").append(sRowIds[0])
                        .append("&fromPage=newUI")
                        .append("&timeStamp=").append(timeStamp)
                        .append("&parentOID=")
                        .append(parentId)
                        .append("&objectId=").append(oid);
                        appendRefreshFrame = true;
                    }
                }
            }

            else if ( objectAction.equals("assignConnector") )  //////////////
            {
                cmd = "SMAConnectorOptionValues_ListAssignConnector";
                String href = getCommandHref( context, cmd, objectId, requestMap );

                if ( href != null && href.length() > 0 )
                {
                    session.setAttribute("stepId", tableRowId);
                    contentURL.append(href);
                    appendRefreshFrame = true;
                }
            }


            else if( objectAction.equals("copy") )  //////////////////////////
            {
                final String TYPE_SIMULATION =
                    SimulationUtil.getSchemaProperty(
                        SimulationConstants.SYMBOLIC_type_Simulation);

                final String TYPE_ACTIVITY =
                    SimulationUtil.getSchemaProperty(
                        SimulationConstants.SYMBOLIC_type_SimulationActivity);

                final String TYPE_CONNECTOR =
                    SimulationUtil.getSchemaProperty(
                        SimulationConstants.SYMBOLIC_type_SimulationConnector);

                final String TYPE_ATTRGROUP =
                    SimulationUtil.getSchemaProperty(
                        SimulationConstants.SYMBOLIC_type_SimulationAttributeGroup);

                final String TYPE_TEMPLATE =
                    SimulationUtil.getSchemaProperty(
                        SimulationConstants.SYMBOLIC_type_SimulationTemplate);

                final String TYPE_HOST =
                    SimulationUtil.getSchemaProperty(
                        SimulationConstants.SYMBOLIC_type_SimulationHost);

                DomainObject DO = new DomainObject(oid);
                if ( DO == null ) return;

                String type = DO.getInfo(context,"type");

                cmd = "";
                if ( TYPE_SIMULATION.equals(type) )
                    cmd = "SMASimulation_ListCopy";
                else if ( TYPE_ACTIVITY.equals(type) )
                    cmd = "SMAActivity_ListCopy";
                else if ( TYPE_CONNECTOR.equals(type) )
                    cmd = "SMAConnector_ListCopy";
                else if ( TYPE_ATTRGROUP.equals(type) )
                    cmd = "SMASimType_ListCopy";
                else if ( TYPE_TEMPLATE.equals(type) )
                    cmd = "SMATemplate_ListCopy";
                else if ( TYPE_HOST.equals(type) )
                    cmd = "SMAHost_ListCopy";
                else
                    cmd = "SMACommon_ListCopy";

                String href = getCommandHref( context, cmd, objectId, requestMap );

                if ( href != null && href.length() > 0 )
                {
                    contentURL.append(href);
                    appendRefreshFrame = true;
                }
            }
            else if(objectAction.equals("expandThis")){
                %>
                <script>
                       waitandExpandParent("<%=objectId%>",500,20);
                </script>
                <%

            }
            else if(objectAction.equals("refreshThis")){
                // Refresh a particular item in the structure navigator
                 %>
                 <script>
                        refreshNode("<%=objectId%>","<%=parIds[0]%>");
                 </script>
                 <%
            }








            else if( objectAction.equals("delete") )  ////////////////////////
            {
                String confirmMsg = null;
                String confirmParamName = null;
                Boolean JobRunStatus=false;
                String status="";
                String attrName="";
                Boolean isDocument = false;
                Boolean isWorkspace = false;
                Boolean onlyHostToDelete=false;
                int numberOfHostsSelected=0;

                /* check for a parameter that indicates that the user
                 * has confirmed this delete operation
                 */
                if (emxGetParameter(request, "confirmFolderDelete") == null ||
                    emxGetParameter(request, "confirmOwnedRevsDelete") == null ||
                    emxGetParameter(request, "confirmStandaloneWithRefs") == null)
                {
                    try
                    {
                        String confirmKey = null;

                        List deleteOidsList = new ArrayList(sRowIds.length);
                        // look through the row IDs
                        for (int i = 0; i < sRowIds.length; ++i)
                        {
                            // get the object ID from the row ID
                            String connectid = sRowIds[i].split("\\|")[0];

                            String deleteOid = "";

                            try
                            {
                                // keeping the old delete behaviour
                                // or any delete op performed from SB
                               deleteOid =  sRowIds[i].split("\\|")[1];
                            }
                            catch(Exception ignore)
                            {

                            }
                            finally
                            {
                                // if done from details display of navigator
                                if(nullandemptycheck(connectid))
                                 deleteOid =  connectid;
                            }


                            deleteOidsList.add(deleteOid);
                            DomainObject doObj1 = new DomainObject();
                            //HF-111927 : To publish this event for Folder subscriptions as
                            //Team Central does not handle this

                            final String TYPE_HOST =
                            SimulationUtil.getSchemaProperty(SimulationConstants.
                                SYMBOLIC_type_SimulationHost);
                           doObj1.setId(deleteOid);


                           if(doObj1.isKindOf(context,TYPE_HOST))
                           {
                             onlyHostToDelete=(sRowIds.length==1)?true:false;
                             numberOfHostsSelected++;
                           }

                            if(!isDocument)
                            {
                                final String TYPE_DOCUMENTS =
                                    SimulationUtil.getSchemaProperty(
                                        DomainSymbolicConstants.SYMBOLIC_type_DOCUMENTS);
                                DomainObject doObj = new DomainObject(deleteOid);
                                if(doObj.isKindOf(context,TYPE_DOCUMENTS))
                                    isDocument = true;
                            }
                            if(!isWorkspace)
                            {
                                final String TYPE_WORKSPACE =
                                    SimulationUtil.getSchemaProperty(
                                        SimulationConstants.SYMBOLIC_type_Workspace);
                                final String TYPE_WORKSPACEVAULT =
                                    SimulationUtil.getSchemaProperty(
                                        SimulationConstants.SYMBOLIC_type_WorkspaceVault);
                                DomainObject doObj = new DomainObject(deleteOid);
                                if(TYPE_WORKSPACE.equals(
                                    doObj.getInfo(context, DomainConstants.SELECT_TYPE))
                                ||(TYPE_WORKSPACEVAULT.equals(
                                    doObj.getInfo(context, DomainConstants.SELECT_TYPE))))
                                {
                                    isWorkspace = true;
                                }
                            }
                      // Changes for IR-188043V6R2014
                            if(isWorkspace){
                                boolean hasExchangeUsrAssigned = PersonUtil.hasAssignment(
                                    context, "Exchange User");
                                if(!hasExchangeUsrAssigned){
                                    String ErrNotExchangeUser = SimulationUtil.getI18NString(context,"smaSimulationCentral.Content.ErrMsg.NotExchangeUser");
                                    throw new Exception(ErrNotExchangeUser);
                                }
                            }
                      // Changes for IR-188043V6R2014 ends here
                        }
                        if(numberOfHostsSelected==sRowIds.length)
                            onlyHostToDelete=true;

                        //WXB:HF-177605V6R2012_:START
                        String confirmMsgForSelected = SimulationUtil.getI18NString(context,"Confirm.SMAHome_EditDelete");
                        if((isWorkspace==true)||(numberOfHostsSelected>0))
                        {
                        %>

                        <script language="JavaScript">
                        if (confirm('<%=confirmMsgForSelected%>'))
                        {
                          // go ahead with delete processing
                        }
                        else
                        {
                            getTopWindow().closeWindow();
                        }
                        </script>
                        <%
                        }
                      //WXB:HF-177605V6R2012_:START


                        String[] deleteOids = (String[]) deleteOidsList.toArray(
                            new String[deleteOidsList.size()]);

                        if (emxGetParameter(request, "confirmOwnedRevsDelete") == null)
                        {
                            Boolean isOwnedWithRevs = (Boolean) JPO.invoke(
                                context,
                                "jpo.simulation.SimulationUtil",
                                null,
                                "isOwnedContentWithMultipleRevisions",
                                deleteOids,
                                Boolean.class);

                            if (isOwnedWithRevs.booleanValue())
                            {
                                confirmParamName = "confirmOwnedRevsDelete";
                                confirmKey = "smaSimulationCentral.OwnedContentWithRevisions.confirmDelete";
                            }
                        }

                        // check to see if the standalone object is
                        // referenced
                        if (confirmKey == null &&
                            emxGetParameter(request, "confirmStandaloneWithRefs") == null)
                        {
                            Boolean isStandaloneWithRefs = (Boolean) JPO.invoke(
                                context,
                                "jpo.simulation.SimulationUtil",
                                null,
                                "isStandaloneContentWithReferences",
                                deleteOids,
                                Boolean.class);

                            if (isStandaloneWithRefs.booleanValue())
                            {
                                confirmParamName = "confirmStandaloneWithRefs";
                                confirmKey = "smaSimulationCentral.StandaloneContentWithReference.confirmDelete";
                            }
                        }

                        if (confirmKey == null &&
                            emxGetParameter(request, "confirmFolderDelete") == null)
                        {
                            // get the home and default folder OIDs
                            String homeFolderOid = getHomeFolderOid(context);
                            String defaultFolderOid = getWorkingFolderOid(context);

                            // neither has been found yet
                            boolean homeFolder = false;
                            boolean defaultFolder = false;

                            for (int i = 0; i < deleteOids.length; ++i)
                            {
                                String deleteOid = deleteOids[i];

                                // home folder included?
                                if (!homeFolder &&
                                    deleteOid.equals(homeFolderOid))
                                {
                                    homeFolder = true;
                                }

                                // default folder included?
                                if (!defaultFolder &&
                                    deleteOid.equals(defaultFolderOid))
                                {
                                    defaultFolder = true;
                                }
                            }

                            if (homeFolder)
                            {
                                confirmParamName = "confirmFolderDelete";
                                if (defaultFolder)
                                {
                                    // deleting both
                                    confirmKey = "smaSimulationCentral.HomeFolderAndDefaultFolder.confirmDelete";
                                }
                                else
                                {
                                    // deleting home folder
                                    confirmKey = "smaSimulationCentral.HomeFolder.confirmDelete";
                                }
                            }
                            else if (defaultFolder)
                            {
                                confirmParamName = "confirmFolderDelete";
                                // deleting default folder
                                confirmKey = "smaSimulationCentral.DefaultFolder.confirmDelete";
                            }
                        }

                        // if we have a key get the prompt string
                        if (confirmKey != null)
                        {
                            confirmMsg = SimulationUtil.getI18NString
                                    (context,
                                    confirmKey);
                        }
                        if (deleteOids != null)
                        {
                            SIMULATIONS sim=new SIMULATIONS();
                            for(int i=0;i<deleteOids.length;i++)
                            {
                                  sim.setId(deleteOids[i]);
                                  status = sim.getRunStatus(context);
                                  if(status.equalsIgnoreCase(SimulationConstants.JOB_STATUS_RUNNING)
                                      ||status.equalsIgnoreCase(SimulationConstants.JOB_STATUS_PAUSED)
                                      ||status.equalsIgnoreCase(SimulationConstants.JOB_STATUS_NOTSTARTED)
                                      ||status.equalsIgnoreCase(SimulationConstants.JOB_STATUS_WAITING))
                                  {
                                      attrName=sim.getInfo(context, "attribute[Title]");
                                      JobRunStatus=true;
                                      break;
                                  }
                            }
                        }
                    }
                    /* if something fails during the check proceed
                     * with the delete
                     */
                    catch (Exception ignore) {
                        // Changes For IR-188043V6R2014
                        //Throw exception only if it is a workspace object
                        if(isWorkspace)
                        {
                        throw new Exception(ignore);
                        }
                    }
                }

                // prompt the user if we need confirmation
                if (confirmMsg != null)
                {
%>
<html>
<head>
<script language="JavaScript">
    <!--
    function pageLoaded()
    {
    if (confirm('<%= confirmMsg %>'))
    {
        document.preserveParamsForm.submit();
    }
    else
    {
        var frame = findFrame(getTopWindow(), "smaHomeTOCContent");
        if (frame != null)
        {
            frame.turnOffProgress();
        }
        //WXB-HF-186360V6R2013x_
        if(getTopWindow() !=null)
             getTopWindow().closeWindow();
    }
    }
    //-->
</script>
</head>
<body onload="pageLoaded();">
<form name="preserveParamsForm" method="POST"
    action="<%=  request.getRequestURL() %>?<%= confirmParamName %>=true">
<%
                    // add the rest of the parameters to the request
                    for (Iterator iter = Parameters.getParameterList(request).iterator();
                         iter.hasNext();)
                    {
                        Parameters.Parameter param = (Parameters.Parameter) iter.next();
%>
    <input name="<%= param.getName() %>"
<%
                        String paramValue = param.getValue();
                        if (paramValue != null)
                        {
%>
        value="<%= paramValue %>"
<%
                        }
%>
        type="hidden"/>
<%
                    }
%>
</form>
</body>
</html>
<%
                    /* have to return here so that the response is not
                     * interpreted as XML
                     */
                    return;
                }

                if(!JobRunStatus)
                {
                    if(onlyHostToDelete)
                    {
                        deleteItems(context, sRowIds);
                    }
                    else
                    {
                        //2013HL Delete and Unlink
                        contentURL.append("../common/emxForm.jsp?form=SMARemove_ContentConfirmation").append("&mode=edit")
                        .append("&postProcessURL=../simulationcentral/smaDeletePostProcess.jsp")
                        .append("&formHeader=smaSimulationCentral.DeleteContentFS.Heading")
                        .append("&HelpMarker=emxhelpremovecontentconfirmation")
                        .append("&submitAction=refreshCaller")
                        .append("&refreshFrame=").append(refreshFrame)
                        .append("&isDocument=").append(isDocument)
                        .append("&isWorkspace=").append(isWorkspace)
                        .append("&parentId=").append(parentId);

                      //Added by A2I for IR-183403V6R2015 Start
                        if(sRowIds.length>1)
                        {
                            session.setAttribute("deleteIds",sRowIds);
                        }
                        else
                        {
                           for(int i=0; i<sRowIds.length; i++)
                            contentURL.append("&emxTableRowId=").append(sRowIds[i]);
                        }
                        //Added by A2I for IR-183403V6R2015 Start
                    }
                }
                else
                {
                        String errMsg = SimulationUtil.getI18NString(context,
                            "Error.JobDelete.JobRunning");

                        throw new Exception(StringResource.format(
                            errMsg, "P1", attrName));
                }
                if(onlyHostToDelete)
                {
                    StringBuilder deletedIds = new StringBuilder();
                    for (int iii=0; iii<sRowIds.length; iii++)
                    {
                     String[] idParts = sRowIds[iii].split("\\|");
                     if (deletedIds.length() > 0)
                       deletedIds.append("|");
                     deletedIds.append(idParts[1]);
                    }
                 %>
                    <script language="javascript">

                      var frame1 = findFrame(getTopWindow().getWindowOpener().getTopWindow(), "smaHomeTOCContent");
                      if ( frame1 != null )
                      {

                          var checkedBoxes = frame1.getCheckedCheckboxes();
                          // convert the checkedBoxes object to an array.
                          //-- checkedBoxes is not an array.
                          var cboxArray = new Array();
                          for (var checkedRowId in checkedBoxes)
                          {
                              cboxArray[cboxArray.length] = checkedRowId;
                          }

                          frame1.removeRows(cboxArray);

                          var frame2 = findFrame(getTopWindow(), "smaHomeHeader");
                          if (frame2 != null)
                          {
                              frame2.respondToObjectDeleted("<%=deletedIds.toString()%>");
                              frame1.turnOffProgress();
                          }
                          var frameC = findFrame(getTopWindow().getWindowOpener().getTopWindow(),"smaHomeContent");
                          if ( frameC != null )
                          {
                              frameC.location.href =
                                  "../simulationcentral/smaHomeContentFS.jsp?"
                          }
                          if(getTopWindow().open)
                              getTopWindow().closeWindow();
                      }
                    </script>
                 <%
                 return;
                }
            }

            else if ( objectAction.equals("lock") ||  ////////////////////////
                      objectAction.equals("unlock") )
            {
                DomainObject obj = new DomainObject();

                // Loop through all selected
                for (int iii=0; iii<sRowIds.length; iii++)
                {
                    StringList sIds = convertRowId( sRowIds[iii] );
                    String selObjectId = (String)sIds.get(1);
                    if(selObjectId == null)
                        selObjectId = (String)sIds.get(0);
                    obj.setId(selObjectId);

                    if (objectAction.equalsIgnoreCase("lock"))
                    {
                        obj.lock(context);
                    }
                    else if (objectAction.equalsIgnoreCase("unlock"))
                    {
                        obj.unlock(context);
                    }
                }
                returnAction = "refresh";
            }
            else if( objectAction.equals("showReferences") ) ////////////////
            {
                cmd = "SMAHome_ActionsShowReferences";

                // want a unique id per user but since user name can have
                // special characters that cause a problem for the window name
                // use the user OID replacing "." with "_"
                windowName = "SHOW_REFERENCES";

                contentURL.append("../common/emxTable.jsp?")
                .append("table=SMAReferences")
                .append("&program=jpo.simulation.SimulationUI:getSelectedObject")
                .append("&emxTableRowId=").append(sRowIds[0])
                .append("&objectId=").append(objectId)
                .append("&showPageURLIcon=false")
                .append("&objectAction=showReferences");
            }
            else if ( objectAction.equals("selectActivityRevision" ) )
            {
                // rootParentId is appropriate here because we are on
                // an emxTable.jsp page, not a structure browser
                String[] args1 = new String[] {rootParentId, sRowIds[0]};

                Map returnMap = (Map) JPO.invoke( context,
                    "jpo.simulation.SimulationContent", null,
                    "selectRevisionById", args1, Map.class );

                if ( returnMap != null )
                {
                    final String TYPE_SIMULATION =
                        SimulationUtil.getSchemaProperty(
                            SimulationConstants.SYMBOLIC_type_Simulation);

                    String simId = (String) returnMap.get("simId");
                    String newRevId = (String) returnMap.get("newRevId");
                    String oldRevId = (String) returnMap.get("oldRevId");
                    String relId = (String) returnMap.get("relId");
                    DomainObject domObj = new DomainObject();
                    domObj.setId(simId);
                    String simType = domObj.getInfo(context, DomainObject.SELECT_TYPE);
                    if (TYPE_SIMULATION.equalsIgnoreCase(simType))
                    {
                        // Call JPO to update the attribute definition
                        Map argsMap = new HashMap();
                           argsMap.put("oldObjectID", oldRevId);
                           argsMap.put("newObjectID", newRevId);
                           argsMap.put("parentID", simId);

                            String message = (String) JPO.invoke(
                               context,
                               "jpo.simulation.SIMULATIONSBase",
                               null,
                               "updateAttributeDefinition",
                               JPO.packArgs(argsMap),
                               String.class);

                            StringBuffer contentURL1 = new StringBuffer(275);
                            contentURL1.append("../simulationcentral/smaHomeUtil.jsp");
                            contentURL1.append("?objectId=").append(newRevId);
                            contentURL1.append("&objectAction=showInBrowseTab");

                            // Popup the error message in case the attribute definition is not updated properly.
                            if(!message.equalsIgnoreCase("Updated"))
                            {%>
                                <script>
                                alert("<%=message%>");
                                </script>
                            <%}
                            %>
                            <script>
                            try
                            {
                               hFra = findFrame(getTopWindow(),"hiddenFrame");
                               hFra.location.href = "<%=contentURL1.toString()%>";
                            }
                            catch(error)
                            {
                              alert(error)
                            }
                            </script>
                            <%
                    }
                }
                return;
            }



            else if( objectAction.equals("saveAsTemplate") )  ////////////////
            {
                if(sRowIds.length==1)
                {
                cmd = "SMATemplate_ListSaveAsTemplate";
                String href = getCommandHref( context, cmd, objectId, requestMap );

                if ( href != null && href.length() > 0 )
                {
                    contentURL.append(href);
                    contentURL.append("&parentOID=");
                    if(!"".equals(parIds[0]) && parIds[0]!=null)
                        contentURL.append(parIds[0]);
                    else
                        contentURL.append(parentId);
                    appendRefreshFrame = true;
                }
                }
                else{
                    String errorSelectOne =  SimulationUtil.getI18NString(context,
                        "Error.ContentUtil.SelectOne" );
                    throw new Exception(errorSelectOne);
                }

            }

            else if( objectAction.equals("saveAsHomeTemplate") )  ////////////////
            {
                if(sRowIds.length==1)
                {
                cmd = "SMATemplate_ListSaveAsTemplate";
                String href = getCommandHref( context, cmd, objectId, requestMap );

                if ( href != null && href.length() > 0 )
                {
                    contentURL.append(href);
                    contentURL.append("&parentOID=");
                    if(!"".equals(parIds[0]) && parIds[0]!=null)
                        contentURL.append(parIds[0]);
                    else
                        contentURL.append(parentId);
                    appendRefreshFrame = true;
                }
                }
                else{
                    String errorSelectOne =  SimulationUtil.getI18NString(context,
                        "Error.ContentUtil.SelectOne" );
                    throw new Exception(errorSelectOne);
                }

            }

            else if( objectAction.equals("addExisting") ||
                     objectAction.equals("addWorkspaceContent") )
            {
                String hlp = emxGetParameter(request, "HelpMarker");
                String srcDestRelName =
                    emxGetParameter(request, "srcDestRelName");

                contentURL
                   .append("../simulationcentral/smaSearchUtil.jsp")
                   .append("?slmmode=").append(objectAction)
                   .append("&objectId=").append(objectId)
                   .append("&HelpMarker=").append(hlp)
                   .append("&emxTableRowId=").append(sRowIds[0])
                   .append("&refreshFrame=").append(refreshFrame)
                   .append("&srcDestRelName=").append(srcDestRelName)
                   .append("&fromPage=slmHome");
            }

            else if( objectAction.equals("activateHosts") )  ///////////////
            {
                // loop over selected hosts and activate
                int num = (objIds != null) ? objIds.length : 0;
                for (int idx = 0; idx < num; idx++)
                {
                    DomainObject obj = new DomainObject();
                    obj.setId(objIds[idx]);
                    obj.setState(context, "Active");
                }
                // refresh page when done to reflect changed state
                returnAction = "refresh";
            }

            else if( objectAction.equals("deactivateHosts") )  ///////////////
            {
                // loop over selected hosts and deactivate
                int num = (objIds != null) ? objIds.length : 0;
                for (int idx = 0; idx < num; idx++)
                {
                    DomainObject obj = new DomainObject();
                    obj.setId(objIds[idx]);
                    obj.setState(context, "Inactive");
                }
                // refresh page when done to reflect changed state
                returnAction = "refresh";
            }

            else if( objectAction.equals("createSimulation") )  //////////////
            {
                cmd = "SMASimulation_HomeCreate";
                String href = getCommandHref( context, cmd, objectId, requestMap );

                if ( href != null && href.length() > 0 )
                {
                    String temp = "../common/emxCreate.jsp?form=SMASimulation_Create&header=smaSimulationCentral.CreateSimProc.Name&postProcessURL=../simulationcentral/smaCreateNewProcess.jsp?postProcessProgram=jpo.simulation.Simulation:postCreate&policy=policy_Simulation&type=type_Simulation&submitAction=treeContent&suiteKey=SimulationCentral&SuiteDirectory=simulationcentral&typeChooser=false&nameField=keyin&findMxLink=false&";
                    String[] parts = href.split("\\?");
                    href = temp.concat(parts[1]);
                    contentURL.append(href);
                    contentURL.append("&plus=");
                    contentURL.append(plus1);
                    appendRefreshFrame = true;
                }
            }


            else if( objectAction.equals("createActivityInSim") )  ///////////
            {
                cmd = "SMASimulation_HomeCreateActivity";
                String href = getCommandHref( context, cmd, objectId, requestMap );

                if ( href != null && href.length() > 0 )
                {
                    String temp = "../common/emxCreate.jsp?form=SMAActivity_Create&submitAction=refreshCaller&showApply=true&header=smaSimulationCentral.CreateSimTask.Name&postProcessURL=../simulationcentral/smaCreateNewProcess.jsp&postProcessProgram=jpo.simulation.SimulationActivity:postCreate&policy=policy_SimulationActivity&type=type_SimulationActivity&";
                    String[] parts = href.split("\\?");
                    href = temp.concat(parts[1]);
                    contentURL.append(href);
                    appendRefreshFrame = true;
                }
            }

            //f3y - module for creating Activity within an Activity
            else if( objectAction.equals("createActivityInActivity") )  ///////////
            {
                 cmd = "SMASimulation_HomeCreateActivity";
                String href = getCommandHref( context, cmd, objectId, requestMap );

                if ( href != null && href.length() > 0 )
                {
                    String temp = "../common/emxCreate.jsp?form=SMAActivity_Create&submitAction=refreshCaller&showApply=true&header=smaSimulationCentral.CreateSimTask.Name&postProcessURL=../simulationcentral/smaCreateNewProcess.jsp&postProcessProgram=jpo.simulation.SimulationActivity:postCreate&policy=policy_SimulationActivity&type=type_SimulationActivity&";
                    String[] parts = href.split("\\?");
                    href = temp.concat(parts[1]);
                    contentURL.append(href);
                    appendRefreshFrame = true;
                }
            }

            else if( objectAction.equals("createDocSimNV") )  ////////////////
            {
                cmd = "SMADocumentNV_HomeCreate";
                String href = getCommandHref( context, cmd, objectId, requestMap );

                if ( href != null && href.length() > 0 )
                {
                    contentURL.append(href);
                    contentURL.append("&parentOID=");
                    contentURL.append(parentId);
                    appendRefreshFrame = true;
                }
            }

            else if( objectAction.equals("createDocSimVer") )  ///////////////
            {
                cmd = "SMADocumentVer_HomeCreate";
                String href = getCommandHref( context, cmd, objectId, requestMap );

                if ( href != null && href.length() > 0 )
                {
                    contentURL.append(href);
                    contentURL.append("&parentOID=");
                    contentURL.append(parentId);
                    appendRefreshFrame = true;
                }
            }



            else if( objectAction.equals("unlinkWorkspaceFolder") )  ///
            {
                cmd = "TMCFolderSummaryUnlinkSelected";

                /* the access for the unlink selected command is
                 * actually checked against the workspace which, in
                 * this case, is the parent
                 */
                String href = getCommandHref( context, cmd, parentId, requestMap );

                if (href != null)
                {
                    final String REPLACE_STRING =
                        "../simulationcentral/smaTeamUnlinkSelectedFoldersProcess.jsp?";

                //Replace the  url with the "sma" version
                href = href.replaceFirst("(.*)\\?", REPLACE_STRING);
%>
            <jsp:forward page="<%=href %>"></jsp:forward>
<%
                }
                else
                {
                    emxNavErrorObject.addMessage(
                            SimulationUtil.getI18NString(context,
                            "smaSimulationCentral.UnlinkSelectedFolders.insufficientAccess"));
                }
            }

            else if( objectAction.equals("createAttributeGroup") )  //////////
            {
                cmd = "SMAAttributeGroup_HomeCreate";
                String href = getCommandHref( context, cmd, objectId, requestMap );

                if ( href != null && href.length() > 0 )
                {
                    contentURL.append(href);
                    contentURL.append("&parentOID=");
                    contentURL.append(parentId);
                    contentURL.append("&plus=");
                    contentURL.append(plus1);
                    appendRefreshFrame = true;
                }
            }

            else if( objectAction.equals("createConnector") )  ///////////////
            {
                cmd = "SMAConnector_HomeCreate";
                String href = getCommandHref( context, cmd, objectId, requestMap );

                if ( href != null && href.length() > 0 )
                {
                    contentURL.append(href);
                    contentURL.append("&parentOID=");
                    contentURL.append(parentId);
                    contentURL.append("&plus=");
                    contentURL.append(plus1);
                    appendRefreshFrame = true;
                }
            }

            else if( objectAction.equals("createHost") )  ///////////////
            {
                cmd = "SMAHost_HomeCreate";
                String href = getCommandHref( context, cmd, objectId, requestMap );

                if ( href != null && href.length() > 0 )
                {
                    contentURL.append(href);
                    contentURL.append("&parentOID=");
                    contentURL.append(parentId);
                    appendRefreshFrame = true;
                }
            }

            else if( objectAction.equals("importHosts") )  ///////////////
            {
                cmd = "SMAHost_HomeImport";
                String href = getCommandHref( context, cmd, objectId, requestMap );
                href = href + "&rowId=" + sRowIds[0];
                if ( href != null && href.length() > 0 )
                {
                    contentURL.append(href);
                    contentURL.append("&parentOID=");
                    contentURL.append(parentId);
                    appendRefreshFrame = true;
                }
            }

            else if( objectAction.equals("exportHosts") )  ///////////////
            {
                String hostOids = FrameworkUtil.join(objIds, ",");
                cmd = "SMAHost_HomeExport";
                String href = getCommandHref( context, cmd, objectId, requestMap );
                href = href + "&rowId=" + hostOids;
                if ( href != null && href.length() > 0 )
                {
                    contentURL.append(href);
                    appendRefreshFrame = true;
                }
            }

            else if( objectAction.equals("createTemplate") )  ////////////////
            {
                cmd = "SMATemplate_HomeCreate";
                String href = getCommandHref( context, cmd, objectId, requestMap );

                if ( href != null && href.length() > 0 )
                {
                    contentURL.append(href);
                    contentURL.append("&parentOID=");
                    contentURL.append(parentId);
                    contentURL.append("&plus=");
                    contentURL.append(plus1);
                    appendRefreshFrame = true;
                }
            }
            // "Set As..." actions
            else if (objectAction.equals("setAsHomeFolder") ||
                     objectAction.equals("setAsDefaultFolder") ||
                     objectAction.equals("unSetAsDefaultFolder") ||
                     objectAction.equals("setCurrentItem"))
            {
                String jpoMethod;
                String refreshAction = "goToLastViewed";
                if (objectAction.equals("setAsHomeFolder"))
                {
                    jpoMethod = "setHomeFolder";
                    refreshAction = "goToHomeFolder";
                }
                else if (objectAction.equals("setAsDefaultFolder") )
                {
                    jpoMethod = "setWorkingFolder";
                    refreshAction = "goToDefaultFolder";
                }
                else if (objectAction.equals("unSetAsDefaultFolder") )
                {
                    jpoMethod = "unSetWorkingFolder";
                    refreshAction = "";
                }
                else
                {
                    jpoMethod = "setCurrentItem";
                }

                Map programMap = new HashMap();
                programMap.put("objectId", objIds[0]);

                // save the OID
                Boolean success = (Boolean) JPO.invoke(
                    context,
                    "jpo.simulation.SimulationUI",
                    null,
                    jpoMethod,
                    JPO.packArgs(programMap),
                    Boolean.class);

                if (Boolean.TRUE.equals(success))
                {
                    // need to refresh the TOC if successful
                    returnAction = "refresh";
                }
                // failure
                else
                {
                    if (objectAction.equals("setAsHomeFolder") )
                    {
                        emxNavErrorObject.addMessage(
                                SimulationUtil.getI18NString(context,
                                "smaSimulationCentral.SetAsHomeFolder.failed"));
                    }
                    else if (objectAction.equals("setAsDefaultFolder") )
                    {
                        emxNavErrorObject.addMessage(
                                SimulationUtil.getI18NString(context,
                                "smaSimulationCentral.SetAsDefaultFolder.failed"));
                    }
                }
                StringBuilder navigateURL = new StringBuilder(175);
                navigateURL.append("../simulationcentral/smaHomeUtil.jsp?")
                .append("objectAction=").append(refreshAction)
                .append("&objectId=").append(parentId);
                %>
                <script type="text/javascript">
                var hFra = findFrame(getTopWindow(),"hiddenFrame");
                hFra.location.href = "<%=navigateURL%>";
                </script>
                <%
            }
            // "Go To..." actions
            else if (objectAction.equals("goToHomeFolder") ||
                     objectAction.equals("goToDefaultFolder") ||
                     objectAction.equals("goToLastViewed") ||
                     objectAction == "goToHomeFolder" ||
                     objectAction == "goToDefaultFolder" ||
                     objectAction == "goToLastViewed")
            {
             // get the OID
                String goToObjectId;
                if (objectAction.equals("goToHomeFolder"))
                {
                    goToObjectId = getHomeFolderOid(context);
                }
                else if (objectAction.equals("goToDefaultFolder"))
                {
                    goToObjectId = getWorkingFolderOid(context);
                }
                else
                {

                    ArrayList[] shortcutList = shortcutInfo.getShortcutMap("Shortcut_Content");
                    int a = shortcutList[0].size()-1;
                    goToObjectId = (String)shortcutList[0].get(a);

                    // goToObjectId = (String) JPO.invoke(
                    //    context,
                    //    "jpo.simulation.SimulationUI",
                    //    null,
                    //    "getLastOpenedItemOID",
                     //   JPO.packArgs(new HashMap()),
                      //  String.class);

                }

                // check to see if the option has been set
                if (goToObjectId != null && goToObjectId.length() != 0)
                {
                            String composeWsId = "";
                            // set compose url if we need to load Compose page
                            StringBuffer composeurl = new StringBuffer();
                            composeurl.append("../common/emxTree.jsp?mode=insert");

                            composeurl.append("&objectId=").append(objectId);
                            %>
                            <script type="text/javascript">
                                 var frame = null;
                                 frame = findFrame(getTopWindow(),"content");
                                 if (frame) {
                                     frame.location.href = "<%=composeurl%>";
                                 }
                            </script>
                            <%

                        /* have to return here so that the response is
                         * not interpreted as XML
                         */
                        return;

                }
                // no OID defined
                else
                {
                    if (objectAction.equals("goToHomeFolder"))
                    {
                        emxNavErrorObject.addMessage(
                            SimulationUtil.getI18NString(context,
                                "smaSimulationCentral.GoToHomeFolder.undefined"));
                    }
                    else if (objectAction.equals("goToDefaultFolder"))
                    {
                        emxNavErrorObject.addMessage(
                            SimulationUtil.getI18NString(context,
                                "smaSimulationCentral.GoToDefaultFolder.undefined"));
                    }
                    else if (objectAction.equals("goToLastViewed"))
                    {
                        throw new Exception("No Last Viewed Item!");
                    }
                }
            }
            // "Show in Browse Tab" action
            else if (objectAction == "showInBrowseTab")
            {
                // get program parameter and if host/hostGroup create
                // reoad station monitor page since that is where
                // the host commands are currently found
                String program =  emxGetParameter(request, "program");
                if ("jpo.simulation.SimulationHost:postCreate".equals(program) ||
                    "jpo.simulation.SimulationHostGroup:postCreate".equals(program))
                {
                    HashMap requestMap2 =
                        UINavigatorUtil.getRequestParameterMap(
                            pageContext);
                    String href2 = SlmUIUtil.getCommandHref(
                        context, "SMAStation_ApplicationListView",
                        null, null, requestMap2);
                    %>
                          <script language="javascript">
                          var frame = null;
                          frame = findFrame(getTopWindow(),"content");
                          if (frame)
                            frame.location.href = "<%=href2%>";
                          </script>
                    <%
                    return;
                }
                String composeWsId = "";
                if (objectId == null || objectId.length() == 0)
                {
                    objectId = emxGetParameter(request, "objectId");
                }

                // check to see if the option has been set
                if (objectId != null && objectId.length() != 0)
                {
                    // set compose url if we need to load Compose page
                    StringBuffer composeurl = new StringBuffer();
                    composeurl.append("../common/emxTree.jsp?mode=insert");
                    composeurl.append("&objectId=").append(objectId);
%>
                    <script type="text/javascript">
                        var frame = null;
                        var topWindow = getTopWindow();
                        if (topWindow.getWindowOpener() != null)
                        {
                            topWindow = topWindow.getWindowOpener().getTopWindow();
                        }
                        frame = findFrame(topWindow,"content");
                        if (frame) {
                            frame.location.href = "<%=composeurl%>";
                            this.close();
                        }
                    </script>
<%
                    /* have to return here so that the response is not
                     * interpreted as XML
                     */
                    return;
                }
                // no OID defined
                else
                {
                    emxNavErrorObject.addMessage(
                            SimulationUtil.getI18NString(context,
                            "smaSimulationCentral.ShowInBrowseTab.noObjectId"));
                }
            }

            else if(objectAction.equals("expandSelectedObject"))
            {
                String lineageOids = objectId;
                 Map argsMap = new HashMap();
                 argsMap.put("objectId", objectId);
                lineageOids = (String) JPO.invoke(
                        context,
                        "jpo.simulation.Home",
                        null,
                        "getLineageOIDs",
                        JPO.packArgs(argsMap),
                        String.class);
                String[] oids = lineageOids.split(",");
                if(oids.length > 1){
                    String parentOId = oids[oids.length - 2];
                    lineageOids = parentOId+","+objectId;
                    %>
                    <script type="text/javascript">
                        openInNewUI("","<%=lineageOids%>");
                    </script>
                    <%
                }
            }

            else if (objectAction.equals("getJobStatus"))
            {
                try
                {
                    String[] objectIds;
                    String[] rootIds;

                    // build an array of OIDs
                    String objectIdsString = emxGetParameter(request, "objectIds");
                    if (objectIdsString != null)
                    {
                        objectIds = objectIdsString.split(",");
                    }
                    else
                    {
                        objectId = emxGetParameter(request, "objectId");
                        objectIds = new String[] {objectId};
                    }

                    // build an array of root IDs
                    String rootIdsString = emxGetParameter(request, "rootIds");
                    if (rootIdsString != null)
                    {
                        rootIds = rootIdsString.split(",");
                    }
                    else
                    {
                        rootIds = null;
                    }

                    // put the arrays into the args map
                    Map argsMap = new HashMap();
                    argsMap.put("objectIds", objectIds);
                    argsMap.put("rootIds", rootIds);

                    // make the JPO call and get the list of new icons
                    List iconsList = (List) JPO.invoke(
                        context,
                        "jpo.simulation.SimulationContent",
                        null,
                        "getColumnRemarksFromOids",
                        JPO.packArgs(argsMap),
                        List.class);

                    // build the XML response
                    out.clear();
                    response.setContentType("text/xml; charset=UTF-8");

                    // response root element
%>
<Remarks>
<%
                    // iterate through the list and add the responses
                    for (int i = 0; i < objectIds.length; ++i)
                    {
%>
    <remarksHTML objectId="<%= objectIds[i] %>"><%= iconsList.get(i) %></remarksHTML>
<%
                    }
%>
</Remarks>
<%
                }
                catch (Throwable ignore)
                {
                    // AJAX response => don't allow normal error processing
                }

                return;
            }
            //pt6 - Patse from Clipboard
            else if (objectAction.equals("pasteFromClipboard"))
            {
                String hlp = emxGetParameter(request, "HelpMarker");
                String srcDestRelName =
                    emxGetParameter(request, "srcDestRelName");

                if ( srcDestRelName == null ||
                    srcDestRelName.length() == 0 )
                {
                    srcDestRelName =
                        "relationship_VaultedDocuments";
                }

                // get program gets filtered clipboard objects
                // from all the user's clipboards.  It will filter
                // for objects that can be added as referenced content
                String program =
                    "smaAEFCollection:getClipboardObjectsForHomeTOC";

                //String context = emxGetParameter(request, "Context");
                //String locale = context.getSession().getLanguage();

                //String hdr = SimulationUtil.getI18NString(
                    //"smaSimulationCentral.Content.PasteFromClipboard",
                    //locale );

                String hdr = "";

                //bring up table with the clipboard objects
                contentURL
                   .append("../common/emxTable.jsp")
                   .append("?program=").append(program)
                   .append("&emxTableRowId=").append(sRowIds[0])
                   .append("&objectId=").append(objectId)
                   .append("&submit=true")
                   .append("&HelpMarker=emxhelpcollectionitems")
                   .append("&table=AEFCollectionItems")
                   .append("&objectBased=true")
                   .append("&sortColumnName=Name")
                   .append("&header=").append(hdr)
                   .append("&selection=single")
                   .append("&PrinterFriendly=true")
                   .append("&showClipboard=false")
                   .append("&CancelButton=true")
                   .append("&suiteKey=Framework")
                   .append("&refreshFrame=").append(refreshFrame)
                   .append("&srcDestRelName=").append(srcDestRelName)
                   .append("&SubmitURL=../simulationcentral/smaHomeConnect.jsp");

            }
            //pt6 - Patse from Clipboard
            else
            {
                 emxNavErrorObject.addMessage(objectAction + " not yet Implemented");
            }
        }
    }
    catch (Exception ex)
    {
        if (objectAction == "goToLastViewed")
        {
            emxNavErrorObject.addMessage(SimulationUtil.getI18NString(context,
                "smaSimulationCentral.GoToDefaultFolder.undefined"));

        }
        emxNavErrorObject.addMessage(ErrorUtil.getMessage(ex, false));
    }


    // Check for error
    String errorMsg = emxNavErrorObject.toString().trim();
    if (errorMsg == null  ||  errorMsg.length() == 0)
    {
        if (cmdExpected
            && (contentURL == null  ||  contentURL.length() == 0))
        {
            errorMsg = "smaHomeUtil: Internal Error: no command to forward to.";
        }
    }

    if ( errorMsg != null && errorMsg.length() > 0 )
    {
        returnAction = "error";
        returnMsg = errorMsg;

        if("true".equals(newUI))
        {
            String message = MessageServices.massageMessage(returnMsg);
            session.removeValue("error.message");
            %>
            <script>
               alert("<%=message%>");
            </script>
            <%
        }
        // For those commands whose target location is popup we must
        // handle the error message differently than if there is not a
        // popup.
        // For popups...
        // Open the utility jsp in the popup window which will then
        // send the XML return code to the listHidden frame.  In the
        // future, hopefully there will be a direct structure browser
        // function to call.
        // For non-popups...
        // Just return the appropriate XML string (non-popups target
        // location is listHidden)
        else if ( isPopup )
        {
            returnMsg =XSSUtil.encodeForURL(context,returnMsg);

            contentURL
                .append( "../simulationcentral/smaStructureBrowserUtil.jsp")
                .append("?action=").append(returnAction)
                .append("&message=").append(returnMsg)
                .append("&refreshFrame=smaHomeTOCContent");
%>
          <script language="javascript">
              getTopWindow().location.href = "<%=contentURL.toString()%>";
          </script>
<%
        }
        else
        {
            if (turnsOffProgress)
            {
%>
            <jsp:forward page="../simulationcentral/smaTurnOffProgress.jsp">
                <jsp:param name="mxRootAction" value="<%= returnAction %>"/>
                <jsp:param name="mxRootMessage" value="<%= returnMsg %>"/>
            </jsp:forward>
<%
              return;
            }

            out.clear();
            response.setContentType("text/xml; charset=UTF-8");

            // If there is a \\n in the message (needed for popups)
            // put it back to \n.  Also:
            // If there are escaped backslashses, let's remove them
            returnMsg = returnMsg.replace("\\n","\n");
            returnMsg = returnMsg.replace("\\","");
%>
            <mxRoot>
                <action><%= returnAction %></action>
                <message><![CDATA[<%= returnMsg %>]]></message>
            </mxRoot>
<%
        }
    }

    // No Errors!!!
    else
    {
        // If action opened a popup window, use it
        if (isPopup)
        {
            if (contentURL.indexOf("suiteKey") == -1)
            {
                contentURL.append(
                    contentURL.indexOf("?") == -1 ? "?" : "&");
                contentURL.append("suiteKey=SimulationCentral");
            }
            if (appendRefreshFrame)
            {
                contentURL.append("&refreshFrame=").append(refreshFrame);
                contentURL.append("&fromPage=slmHome");

                if (sRowIds != null  &&  sRowIds[0] != null)
                {
                    contentURL.append("&emxTableRowId=").append(sRowIds[0]);
                }

                String timeStamp = emxGetParameter(request, "timeStamp");
                if (timeStamp != null)
                {
                    contentURL.append("&timeStamp=").append(timeStamp);
                }
            }



              if( nullandemptycheck(objectAction)&&
               ("saveAsTemplate".equals(objectAction) || "createActivity".equals(objectAction)
               || "createSimulation".equals(objectAction) || "createHost".equals(objectAction)
               || "createTemplate".equals(objectAction) || "createAttributeGroup".equals(objectAction)
               || "createConnector".equals(objectAction) || "createActivityInSim".equals(objectAction)
               || "createActivityInActivity".equals(objectAction) ||"copy".equals(objectAction) ||
               "delete".equals(objectAction) || "saveAsHomeTemplate".equals(objectAction)
               ))
                 {
                     // indicate that we are using a slidein for this
                     // cmd
                     contentURL.append("&usingSlideIn=true");
                     %>
                     <script language="javascript">
                     getTopWindow().showSlideInDialog("<%=contentURL.toString()%>");
                     </script>
                     <%
                 }
              else
              {
                     %>
                    <script language="javascript">
                    handleDialog("<%=contentURL.toString()%>");

                    </script>
                    <%
                }
        }
        else if (opensPopup)
        {
            final String TYPE_PERSON =
                SimulationUtil.getSchemaProperty(
                    DomainSymbolicConstants.SYMBOLIC_type_Person);

            StringList selects = new StringList(1);
            selects.addElement(DomainObject.SELECT_ID);

            //Changes vault field to null as per multi-vault function
            MapList mapList =  DomainObject.findObjects(
                context,
                TYPE_PERSON,       // Type of item to find
                context.getUser(), // Name pattern
                "*",               // Revision pattern
                "*",               // Owner pattern
                null,               // Vault pattern
                null,              // Where clause
                null,              // Query Name
                true,              // Expand Type
                selects,           // Selectables
                (short) 0);         // Query limit

            String userId = null;
            if (mapList != null && mapList.size() > 0)
            {
                Map objectMap = (Map)mapList.get(0);
                userId = (String) objectMap.get(DomainObject.SELECT_ID);
            }

            if (userId == null)
            {
                userId = "";
            }

            // want a unique id per user but since user name can have
            // special characters that cause a problem for the window name
            // use the user OID replacing "." with "_"
            String scrubbedUserId = scrubForWindowName(userId);
            if (windowName != null)
            {
                // want a unique id per user but since user name can have
                // special characters that cause a problem for the window name
                // use the user OID replacing "." with "_"
                windowName += scrubbedUserId;
            }
            else
            {
                windowName = scrubbedUserId;
            }

            // set up job page href
            String helpMarker = emxGetParameter(request, "HelpMarker");
            if (helpMarker != null)
            {
                contentURL.append("&HelpMarker=").append(helpMarker);
            }

            String suiteKey = emxGetParameter(request, "suiteKey");
            if (suiteKey != null)
            {
                contentURL.append("&suiteKey=").append(suiteKey);
            }

            Map cmdSettings = SlmUIUtil.getCommandSettings(context, cmd);

            String width = (String) cmdSettings.get("Window Width");
            if (width == null)
            {
                width = "600";
            }

            String height = (String) cmdSettings.get("Window Height");
            if (height == null)
            {
                height = "600";
            }

            String modal = (String) cmdSettings.get("Popup Modal");

            // open url in new named window which will reuse the window if already open
%>
          <script language="javascript">
              <%--
              make sure we open this from "top" so that we don't lose the opener
              if the window changes
              --%>
              var topWindow = getTopWindow();
              if (topWindow.getWindowOpener() != null)
              {
                  topWindow = topWindow.getWindowOpener().getTopWindow();
              }

<%
            if (!Boolean.valueOf(modal).booleanValue())
            {
%>
            //
            // copied from emxUIModal.js
            //
            function showAndGetNonModalDialogWithName(strURL, strName, intWidth, intHeight, bScrollbars) {

                var strFeatures = "";

                if(intWidth == "Max" || intHeight == "Max")
                {
                    strFeatures = getMaxFeatures(bScrollbars);
                }else
                {

                    strFeatures = "width=" + intWidth + ",height=" + intHeight;
                    var intLeft = parseInt((screen.width - intWidth) / 2);
                    var intTop = parseInt((screen.height - intHeight) / 2);
                    if (isIE_M) {
                            strFeatures += ",left=" + intLeft + ",top=" + intTop;
                    } else{
                            strFeatures += ",screenX=" + intLeft + ",screenY=" + intTop;
                    }
                    if (isNS4_M) {
                            strFeatures += ",resizable=no";
                    } else {
                            strFeatures += ",resizable=yes";
                    }
                    // Passing an additional parameter for scrollbars
                    if (bScrollbars)
                    {
                         strFeatures += ",scrollbars=yes";
                    }
                 }
                strURL = addSuiteDirectory(strURL);
                var win = this.window;
                var objWindow = showNonModalDialog(strURL, 700, 500,true,true);
                registerChildWindows(objWindow, win.getTopWindow());
                objWindow.focus();
                return objWindow;
            }

              var myWin = showAndGetNonModalDialogWithName.apply(
                  topWindow,
                  ['<%= contentURL.toString() %>',
                   '<%= windowName %>',
                   '<%= width %>',
                   '<%= height %>',
                   true]);
<%
            }
            else
            {
%>
              showModalDialog.apply(
                  topWindow,
                  ['<%= contentURL.toString() %>',
                   '<%= width %>',
                   '<%= height %>',
                   true]);
<%
            }
%>
          </script>
<%
        }
        else if("true".equals(newUI) &&
            ("OpenInComposeWorkspace".equals(objectAction) ||"openInDiscover".equals(objectAction) ||"EntryInCompose".equals(objectAction) || "EntryInPerformanceStudy".equals(objectAction) || "EntryInAdhoc".equals(objectAction) || "EntryInExperienceStudio".equals(objectAction)|| "EntryInDiagramming".equals(objectAction) || "TemplateList".equals(objectAction) || "ConnectorList".equals(objectAction) || "AttributeList".equals(objectAction) || "AttributeGroupList".equals(objectAction)))
        {
            %>
            <script>
            var ddFrame = findFrame(getTopWindow(),"content");
             try
             {
               if(getTopWindow().objStructureTree != null){
                      getTopWindow().objStructureTree.clear();
                      getTopWindow().objStructureTree.structureMode="";
                      getTopWindow().objStructureTree.menuName="";
                      getTopWindow().objStructureTree.selectedStructure="";
                      getTopWindow().objStructureTree.root=null;
                   }
             }
             catch(ignore)
             {
                 console.log("Failed refreshing TOC!")
             }
             ddFrame.location.href="<%=contentURL.toString()%>";
            </script>
            <%
        }
        else if("true".equals(newUI) && ("flipSimview".equals(objectAction)||"flipSimActview".equals(objectAction)))
        {
            %>
            <script>
            var ddFrame = findFrame(getTopWindow(),"detailsDisplay");
            ddFrame.location.href="<%=contentURL.toString()%>";
           // var appsMenuList = new Array();
           // getTopWindow().changeProduct('ENOVIA', 'Process Composer', 'SCE', appsMenuList, 'SCE,');
            </script>

            <%
        }
        else if("OpenAdvise".equals(objectAction))
        {
            %>
            <script>
             var win = showNonModalDialog("<%=contentURL.toString()%>", 700, 500,true,true);
             win.focus();
             getTopWindow().closeWindow();
             //getTopWindow().location.href = "<%=contentURL.toString()%>";
           // var appsMenuList = new Array();
           // getTopWindow().changeProduct('ENOVIA', 'Advise', 'SCE', appsMenuList, 'SCE,');
            </script>

            <%
        }
                else if("true".equals(newUI))
        {
            %>
            <script>
            getTopWindow().refreshTrees();
            </script>

            <%
        }
        // Return appropriate code for commands that don't open a window
        else
        {
            if (turnsOffProgress)
            {
%>
            <jsp:forward page="../simulationcentral/smaTurnOffProgress.jsp">
                <jsp:param name="mxRootAction" value="<%= returnAction %>"/>
                <jsp:param name="mxRootMessage" value="<%= returnMsg %>"/>
            </jsp:forward>
<%
              return;
            }
            if("setAsDefaultFolder".equals(objectAction))
            {
                // TODO Set default folder tree changes.
                %>
                 <script>
                   getTopWindow().closeWindow();
                 </script>
                <%
                return;
            }

            out.clear();
            response.setContentType("text/xml; charset=UTF-8");
%>
            <mxRoot>
                <action><![CDATA[<%= returnAction %>]]></action>
                <message><![CDATA[<%= returnMsg   %>]]></message>
            </mxRoot>
<%
        }
    }
%>


<%!

// Method that retrieves the object and parent ids from single row
// if "selected row" array
// sIds[0] = connection id
// sIds[1] = object id
// sIds[2] = parent id
private StringList convertRowId( String sRowIds )
{
    // If called from emxTable, the row ids might be
    //   <connection id>|<selected object id>
    // If called from an emxIndentedTable, the row ids are:
    //   <conection id>|<selected object id>|<parent object id>|<indented table ordering tag>
    // In either case, pull out the <selected object id>.

    // Special case if user selected root... connection id will be
    // an empty string which causes split to not return an element
    // thus making everything off by 1

    if ( sRowIds.startsWith("|") )
        sRowIds = "nada" + sRowIds;

    // Get the ids
    StringList sIdList = FrameworkUtil.split(sRowIds, "|");

        // Make sure list has at least 3 elements in it
    while ( sIdList.size() < 3 ){
        String nullString = null;
        sIdList.addElement(nullString);
        }
    String first = (String)sIdList.get(0);
    if (first.equals("nada"))
        sIdList.set(0, null);

    return sIdList;
}


//Method that performs validation checks based on the selected objects
//and the objectAction (command) to execute.
//objIds - the selected objects
//parIds - ids of the parents of the selected objects
//relIds - ids of the connections of the selected objects
//objectAction - the command to be performed
//The valid commands are listed at the start of the jsp
private boolean cmdChecksOk(Context context, String[] objIds,
    String[] parIds, String[] relIds, String objectAction,
    FrameworkException emxNavErrorObject)
{
    boolean cmdChecksOK = true;
    String locale = context.getSession().getLanguage();
    String errMsg = "";
    try
    {
        int nObjs = (objIds != null) ? objIds.length : 0;
        if (objectAction.equals("selectActivityRevision") )
        {
            //no checks needed
            return cmdChecksOK;
        }

        // Set up select list of things to return from the query.
        // need job relation data for sim/sim act processing.
        // job relation is 1 to many so we need to get the last job.
        // need activity relation to see if stand alone activity

        StringList selectList = new StringList(22);
        selectList.add(DomainConstants.SELECT_ID);
        selectList.add(DomainConstants.SELECT_TYPE);
        selectList.add(DomainConstants.SELECT_NAME);
        selectList.add(DomainConstants.SELECT_CURRENT);
        selectList.add(DomainConstants.SELECT_POLICY);

        final String SELECT_TITLE =
            SimulationUtil.getAttributeSelect(
                DomainSymbolicConstants.SYMBOLIC_attribute_Title);

        selectList.add(SELECT_TITLE);


        final String REL_JOBS =
            SimulationUtil.getSchemaProperty(
                SimulationConstants.SYMBOLIC_relationship_SimulationJob);
        final String ATTR_RUN_STATUS =
            "attribute["
            + SimulationUtil
                .getSchemaProperty(SimulationConstants.SYMBOLIC_attribute_RunStatus)
            + "]";
        final String SEL_REL_JOB_STATUS =
            "from[" + REL_JOBS + "]." + ATTR_RUN_STATUS;

        final String SEL_REL_JOB_ID =
            "from[" + REL_JOBS + "].to.id";

        final String SEL_REL_JOB_MODIFIED =
            "from[" + REL_JOBS + "].to.modified";

        // get relation info
        selectList.add(SEL_REL_JOB_STATUS);
        selectList.add(SEL_REL_JOB_ID);
        selectList.add(SEL_REL_JOB_MODIFIED);


        // get lock info
        selectList.add(CommonDocument.SELECT_HAS_LOCK_ACCESS);
        selectList.add(CommonDocument.SELECT_HAS_UNLOCK_ACCESS);
        selectList.add(DomainConstants.SELECT_LOCKED);
        selectList.add(DomainConstants.SELECT_LOCKER);

        // Get access info
        final String SELECT_HAS_CONNECT_FROM_ACCESS =
            "current.access[modify,fromconnect]";
        final String SELECT_HAS_CONNECT_TO_ACCESS =
            "current.access[toconnect]";
        final String SELECT_HAS_CONNECT_TO_MODIFY_ACCESS =
            "current.access[modify,toconnect]";
        final String SELECT_HAS_CONNECT_FROM_VIEW_ACCESS =
            "current.access[modify,fromconnect,viewform]";
        final String SELECT_HAS_TODISCONNECT_ACCESS =
            "current.access[todisconnect]";
        final String SELECT_HAS_DELETE_ACCESS =
            "current.access[modify,delete]";
        final String SELECT_HAS_MODIFY_ACCESS =
            "current.access[modify]";

        selectList.add(SELECT_HAS_CONNECT_FROM_ACCESS);
        selectList.add(SELECT_HAS_CONNECT_FROM_VIEW_ACCESS);
        selectList.add(SELECT_HAS_CONNECT_TO_ACCESS);
        selectList.add(SELECT_HAS_CONNECT_TO_MODIFY_ACCESS);
        selectList.add(SELECT_HAS_TODISCONNECT_ACCESS);
        selectList.add(SELECT_HAS_DELETE_ACCESS);
        selectList.add(SELECT_HAS_MODIFY_ACCESS);


        final String REL_CONTENT_OWNED =
            SimulationUtil.getSchemaProperty(
                SimulationConstants.SYMBOLIC_relationship_SimulationContent_Owned);

        final String SELECT_HAS_REL_CONTENT_OWNED =
            "to[" + REL_CONTENT_OWNED + "].from.id";
        final String SELECT_REL_CONTENT_OWNED_MODIFY =
            "to[" + REL_CONTENT_OWNED + "].from.current.access[modify,disconnect]";
        final String SELECT_REL_CONTENT_OWNED_LOCKED =
            "to[" + REL_CONTENT_OWNED + "].from." + DomainConstants.SELECT_LOCKED;
        final String SELECT_REL_CONTENT_OWNED_LOCKER =
            "to[" + REL_CONTENT_OWNED + "].from." + DomainConstants.SELECT_LOCKER;

        selectList.add(SELECT_HAS_REL_CONTENT_OWNED);
        selectList.add(SELECT_REL_CONTENT_OWNED_MODIFY);
        selectList.add(SELECT_REL_CONTENT_OWNED_LOCKED);
        selectList.add(SELECT_REL_CONTENT_OWNED_LOCKER);


        final String REL_ACTIVITY =
            SimulationUtil.getSchemaProperty(
                SimulationConstants.SYMBOLIC_relationship_SimulationActivity);

        final String SELECT_HAS_REL_ACTIVITY =
            "to[" + REL_ACTIVITY + "].from.id";
        final String SELECT_REL_ACTIVITY_MODIFY =
            "to[" + REL_ACTIVITY + "].from.current.access[modify,disconnect]";
        final String SELECT_REL_ACTIVITY_LOCKED =
            "to[" + REL_ACTIVITY + "].from." + DomainConstants.SELECT_LOCKED;
        final String SELECT_REL_ACTIVITY_LOCKER =
            "to[" + REL_ACTIVITY + "].from." + DomainConstants.SELECT_LOCKER;

        selectList.add(SELECT_HAS_REL_ACTIVITY);
        selectList.add(SELECT_REL_ACTIVITY_MODIFY);
        selectList.add(SELECT_REL_ACTIVITY_LOCKED);
        selectList.add(SELECT_REL_ACTIVITY_LOCKER);


        final String REL_TEMPLATE_CONTENT =
            SimulationUtil.getSchemaProperty(
                SimulationConstants.SYMBOLIC_relationship_SimulationTemplateContent);

        final String SELECT_HAS_REL_TEMPLATE_CONTENT =
            "to[" + REL_TEMPLATE_CONTENT + "].from.id";
        final String SELECT_REL_TEMPLATE_CONTENT_MODIFY =
            "to[" + REL_TEMPLATE_CONTENT + "].from.current.access[modify,disconnect]";
        final String SELECT_REL_TEMPLATE_CONTENT_LOCKED =
            "to[" + REL_TEMPLATE_CONTENT + "].from." + DomainConstants.SELECT_LOCKED;
        final String SELECT_REL_TEMPLATE_CONTENT_LOCKER =
            "to[" + REL_TEMPLATE_CONTENT + "].from." + DomainConstants.SELECT_LOCKER;

        selectList.add(SELECT_HAS_REL_TEMPLATE_CONTENT);
        selectList.add(SELECT_REL_TEMPLATE_CONTENT_MODIFY);
        selectList.add(SELECT_REL_TEMPLATE_CONTENT_LOCKED);
        selectList.add(SELECT_REL_TEMPLATE_CONTENT_LOCKER);


        // Used to distinquish the major types
        final String SIMULATIONS_TYPE =
            SimulationUtil.getSchemaProperty(
                SimulationConstants.SYMBOLIC_type_SIMULATIONS);

        final String SIMULATION_TYPE =
            SimulationUtil.getSchemaProperty(
                SimulationConstants.SYMBOLIC_type_Simulation);

        final String ACTIVITY_TYPE =
            SimulationUtil.getSchemaProperty(
                SimulationConstants.SYMBOLIC_type_SimulationActivity);

        final String HOST_TYPE =
            SimulationUtil.getSchemaProperty(
                SimulationConstants.SYMBOLIC_type_SimulationHost);

        final String DOCUMENTS_TYPE =
            SimulationUtil.getSchemaProperty(
                DomainSymbolicConstants.SYMBOLIC_type_DOCUMENTS);

      //Start-wu4-(Porting)-Template for Simulation Document
        final String SIMDOCUMENTS_VER_TYPE =
            SimulationUtil.getSchemaProperty(
                SimulationConstants.SYMBOLIC_type_SimulationDocument_Versioned);

        final String SIMDOCUMENTS_NV_TYPE =
            SimulationUtil.getSchemaProperty(
                SimulationConstants.SYMBOLIC_type_SimulationDocument_NonVersioned);
        //End-wu4-(Porting)-Template for Simulation Document

        final String TEMPLATE_TYPE =
            SimulationUtil.getSchemaProperty(
                SimulationConstants.SYMBOLIC_type_SimulationTemplate);

        final String CONNECTOR_TYPE =
            SimulationUtil.getSchemaProperty(
                SimulationConstants.SYMBOLIC_type_SimulationConnector);

        final String ATTRGROUP_TYPE =
            SimulationUtil.getSchemaProperty(
                SimulationConstants.SYMBOLIC_type_SimulationAttributeGroup);

        final String WORKSPACE_TYPE =
            SimulationUtil.getSchemaProperty(
                DomainSymbolicConstants.SYMBOLIC_type_Project);

        final String WSFOLDER_TYPE =
            SimulationUtil.getSchemaProperty(
                DomainSymbolicConstants.SYMBOLIC_type_ProjectVault);

        final String VPM_REFERENCE_TYPE =
            SimulationUtil.getSchemaProperty(
                SimulationConstants.SYMBOLIC_type_PLMReference);

        // The following return the type of entity
        final String SELECT_KINDOF_SIMULATIONS =
            "type.kindof[" + SIMULATIONS_TYPE + "]";
        final String SELECT_KINDOF_SIMULATION =
            "type.kindof[" + SIMULATION_TYPE + "]";
        final String SELECT_KINDOF_ACTIVITY =
            "type.kindof[" + ACTIVITY_TYPE + "]";
        final String SELECT_KINDOF_HOST =
            "type.kindof[" + HOST_TYPE + "]";
        final String SELECT_KINDOF_DOCUMENTS =
            "type.kindof["+ DOCUMENTS_TYPE + "]";
        //Start-wu4-(Porting)-Template for Simulation Document
        final String SELECT_KINDOF_SIMDOCUMENTS_VER =
            "type.kindof["+ SIMDOCUMENTS_VER_TYPE + "]";
        final String SELECT_KINDOF_SIMDOCUMENTS_NV =
            "type.kindof["+ SIMDOCUMENTS_NV_TYPE + "]";
        //End-wu4-(Porting)-Template for Simulation Document
        final String SELECT_KINDOF_TEMPLATE =
            "type.kindof[" + TEMPLATE_TYPE + "]";
        final String SELECT_KINDOF_CONNECTOR =
            "type.kindof[" + CONNECTOR_TYPE + "]";
        final String SELECT_KINDOF_ATTRGROUP =
            "type.kindof[" + ATTRGROUP_TYPE + "]";
        final String SELECT_KINDOF_WS =
            "type.kindof[" + WORKSPACE_TYPE + "]";
        final String SELECT_KINDOF_WSFOLDER =
            "type.kindof[" + WSFOLDER_TYPE + "]";
        final String SELECT_KINDOF_VPMREFERENCE =
            "type.kindof[" + VPM_REFERENCE_TYPE + "]";

        selectList.add(SELECT_KINDOF_SIMULATIONS);
        selectList.add(SELECT_KINDOF_ACTIVITY);
        selectList.add(SELECT_KINDOF_SIMULATION);
        selectList.add(SELECT_KINDOF_DOCUMENTS);
        //Start-wu4-(Porting)-Template for Simulation Document
        selectList.add(SELECT_KINDOF_SIMDOCUMENTS_VER);
        selectList.add(SELECT_KINDOF_SIMDOCUMENTS_NV);
        //End-wu4-(Porting)-Template for Simulation Document
        selectList.add(SELECT_KINDOF_TEMPLATE);
        selectList.add(SELECT_KINDOF_CONNECTOR);
        selectList.add(SELECT_KINDOF_ATTRGROUP);
        selectList.add(SELECT_KINDOF_WS);
        selectList.add(SELECT_KINDOF_WSFOLDER);
        selectList.add(SELECT_KINDOF_HOST);
        selectList.add(SELECT_KINDOF_VPMREFERENCE);

        // Check for Connector on Activity.

        final String RELATIONSHIP_CONNECTOR =
            SimulationUtil.getSchemaProperty(
                SimulationConstants.SYMBOLIC_relationship_SimulationConnector);
        final String SELECT_HAS_CONNECTOR =
            SimulationUtil.getFromSelect(RELATIONSHIP_CONNECTOR);
        final String SELECT_HAS_TO_CONNECTOR =
            SimulationUtil.getToSelect(RELATIONSHIP_CONNECTOR);


        final String SELECT_IS_CONTENT =
            SimulationUtil.getToSelect(REL_TEMPLATE_CONTENT);

        // check for instantiated templates - they cannot be deleted
        final String REL_SIMULATION_TEMPLATE =
            SimulationUtil.getSchemaProperty(SimulationConstants
                .SYMBOLIC_relationship_SimulationTemplate);

        final String SELECT_HAS_REL_TEMPLATE =
            SimulationUtil.getToSelect(REL_SIMULATION_TEMPLATE);

        final String REL_ATTRIBUTE_GROUPS =
            SimulationUtil.getSchemaProperty(
                SimulationConstants
                    .SYMBOLIC_relationship_SimulationAttributeGroup);

        final String SELECT_HAS_REL_GROUPS =
            SimulationUtil.getToSelect(REL_ATTRIBUTE_GROUPS);

        selectList.add(SELECT_IS_CONTENT);
        selectList.add(SELECT_HAS_REL_TEMPLATE);
        selectList.add(SELECT_HAS_REL_GROUPS);

        // Get referenced issue information needed for delete
        final String REL_ISSUE_NAME =
            SimulationUtil.getSchemaProperty(
                DomainSymbolicConstants.SYMBOLIC_relationship_Issue);
        final String SEL_ISSUE_NAME =
            "to["+REL_ISSUE_NAME+"].from.name";
        final String SEL_ISSUE_ID =
            "to["+REL_ISSUE_NAME+"].from.id";

        selectList.addElement(SEL_ISSUE_NAME);
        selectList.addElement(SEL_ISSUE_ID);

        // Get the list of business objects in tree
        BusinessObjectWithSelectList bowsl =  null;
        if(objIds != null && objIds.length != 0)
        {
          bowsl = BusinessObject.getSelectBusinessObjectData(context, 
        		  objIds, selectList);
        }
        //perform checks based on type of operation

        final String WSFOLDER_DISPLAY_TYPE =
            UINavigatorUtil.getAdminI18NString(
                "Type", WSFOLDER_TYPE, locale);

        // Can only aborto run  a SIMULATION need extra job checks
        if (objectAction.equals("abort")
            )
        {
            if (!onlyOneObj(context, nObjs, emxNavErrorObject))
            {
                cmdChecksOK = false;
            }
            else
            {
                // Get Business Object from list
                BusinessObjectWithSelect bowsElem = bowsl
                    .getElement(0);

                // access needed by sim/sim act for execution operations
                boolean hasFromConnectViewAccess = "true"
                    .equalsIgnoreCase(bowsElem
                        .getSelectData(SELECT_HAS_CONNECT_FROM_VIEW_ACCESS));

                boolean isSIMSType = Boolean.parseBoolean(bowsElem
                    .getSelectData(SELECT_KINDOF_SIMULATIONS));

                boolean isActType = Boolean.parseBoolean(bowsElem
                    .getSelectData(SELECT_KINDOF_ACTIVITY));

                if (isSIMSType)
                {
                    // Check if this is template content.
                    String policy =  bowsElem.getSelectData(
                        DomainConstants.SELECT_POLICY);
                    String POLICY_TEMPLATE_CONTENT = SimulationUtil.
                    getSchemaProperty(
                        SimulationConstants.
                            SYMBOLIC_policy_SimulationTemplateContent);
                    if (POLICY_TEMPLATE_CONTENT.equals(policy))
                    {
                        if (isActType)
                        {
                        errMsg = SimulationUtil.getI18NString(context,
                                "smaHome.cmdChecks.Run.TemplContentAct"
                                );
                        }
                        else
                        {
                            errMsg = SimulationUtil.getI18NString(context,
                                "smaHome.cmdChecks.Run.TemplContent"
                                );
                        }
                        emxNavErrorObject.addMessage(errMsg);
                        cmdChecksOK = false;
                        return cmdChecksOK;
                    }
                    // get simulation state - if not In Process can't run
                    // This is based on the current simulation policy
                    // if this is changed this check would need to change
                    String state =  bowsElem.getSelectData(
                            DomainConstants.SELECT_CURRENT);
                    String transState =
                        UINavigatorUtil.getStateI18NString(
                        policy, state, locale);
                    if (!("In Process".equals(state)) &&
                        (!("Proposed".equals(state))))
                    {
                        if (isActType)
                        {
                        errMsg = SimulationUtil.getI18NString(context,
                                "smaHome.cmdChecks.Run.BadStateAct");
                        }
                        else
                        {
                            errMsg = SimulationUtil.getI18NString(context,
                                "smaHome.cmdChecks.Run.BadState");
                        }
                        errMsg = StringResource.format(
                            errMsg, "P1", transState);
                        emxNavErrorObject.addMessage(errMsg);
                        cmdChecksOK = false;
                        return cmdChecksOK;
                    }
                }

                // check for correct type, access and lock status
                boolean newCheck =
                    checkCommandForTypeAcessLock(context, bowsElem,
                        isSIMSType, hasFromConnectViewAccess,
                        SIMULATION_TYPE, ACTIVITY_TYPE, false,
                        emxNavErrorObject);
                if (!newCheck)
                {
                    cmdChecksOK = false;
                }
                else if (!checkJobInfo(context, objectAction,
                    bowsElem, emxNavErrorObject))
                {
                    cmdChecksOK = false;
                }

            }
        }
        else if (objectAction.equals("addExisting") ||
                 objectAction.equals("addWorkspaceContent") )
        {
            // only add into workspace folder
            if (!onlyOneObj(context, nObjs, emxNavErrorObject))
            {
                cmdChecksOK = false;
            }
            else
            {
                // Get Business Object from list
                BusinessObjectWithSelect bowsElem = bowsl
                    .getElement(0);

                // Determine if user can add things to the entity
                boolean hasFromConnectAccess = "true"
                    .equalsIgnoreCase(bowsElem
                        .getSelectData(SELECT_HAS_CONNECT_FROM_ACCESS));

                boolean isWSFolderType = Boolean
                    .parseBoolean(bowsElem
                        .getSelectData(SELECT_KINDOF_WSFOLDER));

                if (!checkCommandForTypeAcessLock(context, bowsElem,
                    isWSFolderType,
                    hasFromConnectAccess,
                    WSFOLDER_DISPLAY_TYPE,
                    emxNavErrorObject))
                {
                    cmdChecksOK = false;
                }
            }
        }
        // can only assign a connector to an activity
        else if (objectAction.equals("assignConnector"))
        {
            if (!onlyOneObj(context, nObjs, emxNavErrorObject))
            {
                cmdChecksOK = false;
            }
            else
            {
                // Get Business Object from list
                BusinessObjectWithSelect bowsElem =
                    bowsl.getElement(0);

                // access needed by sim/sim act for execution operations
                boolean hasFromConnectViewAccess =
                    "true".equalsIgnoreCase(
                        bowsElem.getSelectData(SELECT_HAS_CONNECT_FROM_ACCESS));

                boolean isActType =
                    Boolean.parseBoolean(
                        bowsElem.getSelectData(SELECT_KINDOF_ACTIVITY));
                if (!checkCommandForTypeAcessLock(context, bowsElem,
                        isActType, hasFromConnectViewAccess,
                        ACTIVITY_TYPE,
                        emxNavErrorObject))
                {
                    cmdChecksOK = false;
                }
                else if (!checkJobInfo(context, objectAction,
                    bowsElem, emxNavErrorObject))
                {
                    cmdChecksOK = false;
                }
            }
        }
        else if (objectAction.equals("showReferences"))
        {
            // no checks needed
            if (!onlyOneObj(context, nObjs, emxNavErrorObject))
            {
                cmdChecksOK = false;
            }
        }

        // can only continue a paused activity
        else if (objectAction.equals("repeat"))
        {
            if (!onlyOneObj(context, nObjs, emxNavErrorObject))
            {
                cmdChecksOK = false;
            }
            else
            {
                // Get Business Object from list
                BusinessObjectWithSelect bowsElem = bowsl
                    .getElement(0);

                // access needed by sim/sim act for execution operations
                boolean hasFromConnectViewAccess = "true"
                    .equalsIgnoreCase(bowsElem
                        .getSelectData(SELECT_HAS_CONNECT_FROM_VIEW_ACCESS));

                boolean isActType = Boolean.parseBoolean(bowsElem
                    .getSelectData(SELECT_KINDOF_ACTIVITY));
                // Check if this is template content.

                String policy =  bowsElem.getSelectData(
                        DomainConstants.SELECT_POLICY);
                String POLICY_TEMPLATE_CONTENT = SimulationUtil.
                    getSchemaProperty(
                        SimulationConstants.
                            SYMBOLIC_policy_SimulationTemplateContent);
                if (POLICY_TEMPLATE_CONTENT.equals(policy) &&
                    objectAction.equals("repeat") )
                {
                    if (isActType)
                    {
                        errMsg = SimulationUtil.getI18NString(context,
                            "smaHome.cmdChecks.Repeat.TemplContentAct");
                    }
                    else
                    {
                    errMsg = SimulationUtil.getI18NString(context,
                            "smaHome.cmdChecks.Repeat.TemplContent");
                    }
                    emxNavErrorObject.addMessage(errMsg);
                    cmdChecksOK = false;
                    return cmdChecksOK;
                }

                if (!checkCommandForTypeAcessLock(context, bowsElem,
                    isActType, hasFromConnectViewAccess,
                    ACTIVITY_TYPE,
                    emxNavErrorObject))
                {
                    cmdChecksOK = false;
                }
                else if (!checkJobInfo(context, objectAction,
                    bowsElem, emxNavErrorObject))
                {
                    cmdChecksOK = false;
                }
            }
        }
        else if (objectAction.equals("copy")) // (multi-select)
        {
            if (!onlyOneObj(context, nObjs, emxNavErrorObject))
            {
                cmdChecksOK = false;
            }
            else
            {
                final String METH_DEV =SimulationUtil.getSchemaProperty(
                    SimulationConstants.SYMBOLIC_role_SimulationMethodsDeveloper);
                BusinessObjectWithSelect bowsElem =
                    bowsl.getElement(0);
                boolean isWSFolderType = Boolean
                .parseBoolean(bowsElem
                    .getSelectData(SELECT_KINDOF_WSFOLDER));
                boolean isWorkSpace = Boolean
                .parseBoolean(bowsElem
                    .getSelectData(SELECT_KINDOF_WS));
                String policy =  bowsElem.getSelectData(
                    DomainConstants.SELECT_POLICY);
                String POLICY_TEMPLATE_CONTENT = SimulationUtil.
                getSchemaProperty(
                    SimulationConstants.
                        SYMBOLIC_policy_SimulationTemplateContent);

                boolean isTemplateContent =
                    POLICY_TEMPLATE_CONTENT.equals(policy);
                boolean isVpmType = Boolean
                .parseBoolean(bowsElem
                    .getSelectData(SELECT_KINDOF_VPMREFERENCE));
                if (isWorkSpace || isWSFolderType || isTemplateContent || isVpmType)
                {
                    errMsg = SimulationUtil.getI18NString(context,
                        "smaHome.cmdChecks.NoCopy");
                    emxNavErrorObject.addMessage(errMsg);
                    cmdChecksOK = false;
                }

                boolean isMethodsDev = PersonUtil.hasAssignment(
                    context, METH_DEV);
                if (cmdChecksOK && !isMethodsDev)
                {
                    boolean isTEMPLATE = Boolean.parseBoolean(
                        bowsElem.getSelectData(
                            SELECT_KINDOF_TEMPLATE));
                    boolean isCONNECTOR = Boolean.parseBoolean(
                        bowsElem.getSelectData(
                            SELECT_KINDOF_CONNECTOR));
                    boolean isATTRGROUP =
                        Boolean.parseBoolean(
                            bowsElem.getSelectData(
                                SELECT_KINDOF_ATTRGROUP));
                    if (isTEMPLATE || isCONNECTOR || isATTRGROUP)
                    {
                        errMsg = SimulationUtil.getI18NString(context,
                            "smaHome.cmdChecks.NoCopyNoMethods");
                        emxNavErrorObject.addMessage(errMsg);
                        cmdChecksOK = false;
                    }
                }

                Map argsMap = new HashMap();
                argsMap.put("objectIds", objIds);

                if (Boolean.TRUE.equals(
                        (Boolean) JPO.invoke(
                            context,
                            "jpo.simulation.Home",
                            null,
                            "isAnyActivityOwnedByProcessLockedByOtherUser",
                            JPO.packArgs(argsMap),
                            Boolean.class)))
                {
                    errMsg = SimulationUtil.getI18NString(context,
                        "smaHome.cmdChecks.OwnedByLockedProcess");
                    emxNavErrorObject.addMessage(errMsg);
                    cmdChecksOK = false;
                }

                if (Boolean.FALSE.equals(
                        (Boolean) JPO.invoke(
                            context,
                            "jpo.simulation.Home",
                            null,
                            "hasCopyAccessToOwningProcess",
                            JPO.packArgs(argsMap),
                            Boolean.class)))
                {
                    errMsg = SimulationUtil.getI18NString(context,
                        "smaHome.cmdChecks.NoCopyAccessToOwningProcess");
                    emxNavErrorObject.addMessage(errMsg);
                    cmdChecksOK = false;
                }
            }
        }
        //Activities can be created in Simulations or
        //workspace folders
        else if (objectAction.equals("createActivity"))
        {
            if (!onlyOneObj(context, nObjs, emxNavErrorObject))
            {
                cmdChecksOK = false;
            }
            else
            {
                // Get Business Object from list
                BusinessObjectWithSelect bowsElem = bowsl
                    .getElement(0);

                // Determine if user can add things to the entity
                boolean hasFromConnectAccess = "true"
                    .equalsIgnoreCase(bowsElem
                        .getSelectData(SELECT_HAS_CONNECT_FROM_ACCESS));

                boolean isSimulationType = Boolean
                    .parseBoolean(bowsElem
                        .getSelectData(SELECT_KINDOF_SIMULATION));
                boolean isWSFolderType = Boolean
                    .parseBoolean(bowsElem
                        .getSelectData(SELECT_KINDOF_WSFOLDER));

                if (!checkCommandForTypeAcessLock(context, bowsElem,
                    isSimulationType || isWSFolderType,
                    hasFromConnectAccess,
                    SIMULATION_TYPE, WSFOLDER_DISPLAY_TYPE, false,
                    emxNavErrorObject))
                {
                    cmdChecksOK = false;
                }
                if (isSimulationType && cmdChecksOK)
                {
                    if (!checkJobInfo(context, objectAction,
                        bowsElem, emxNavErrorObject))
                    {
                        cmdChecksOK = false;
                    }
                }
            }
        }
        // can only createActivityInSim if a simulation is selected
        else if (objectAction.equals("createActivityInSim"))
        {
            if (!onlyOneObj(context, nObjs, emxNavErrorObject))
            {
                cmdChecksOK = false;
            }
            else
            {
                // Get Business Object from list
                BusinessObjectWithSelect bowsElem = bowsl
                    .getElement(0);

                // Determine if user can add things to the entity
                boolean hasFromConnectAccess = "true"
                    .equalsIgnoreCase(bowsElem
                        .getSelectData(SELECT_HAS_CONNECT_FROM_ACCESS));

                boolean isSimulationType = Boolean
                    .parseBoolean(bowsElem
                        .getSelectData(SELECT_KINDOF_SIMULATION));

                if (!checkCommandForTypeAcessLock(context, bowsElem,
                    isSimulationType ,
                    hasFromConnectAccess,
                    SIMULATION_TYPE,
                    emxNavErrorObject))
                {
                    cmdChecksOK = false;
                }
                else if (!checkJobInfo(context, objectAction,
                    bowsElem, emxNavErrorObject))
                {
                    cmdChecksOK = false;
                }
            }
        }
        // other objects created in workspace folder (or sub folder)
        else if (objectAction.equals("createAttributeGroup") ||
            objectAction.equals("createConnector") ||
            objectAction.equals("createDocSimNV") ||
            objectAction.equals("createDocSimVer") ||
            objectAction.equals("createHost") ||
            objectAction.equals("importHosts") ||
            objectAction.equals("createSimulation") ||
            objectAction.equals("createTemplate")   )
        {
            if (!onlyOneObj(context, nObjs, emxNavErrorObject))
            {
                cmdChecksOK = false;
            }
            else
            {
               if(bowsl!=null && !bowsl.isEmpty())
               {
                    // Get Business Object from list
                    BusinessObjectWithSelect bowsElem = bowsl
                        .getElement(0);

                    // Determine if user can add things to the entity
                    boolean hasFromConnectAccess = "true"
                        .equalsIgnoreCase(bowsElem
                            .getSelectData(SELECT_HAS_CONNECT_FROM_ACCESS));

                    boolean isWSFolderType = Boolean
                    .parseBoolean(bowsElem
                        .getSelectData(SELECT_KINDOF_WSFOLDER));

                    if (!checkCommandForTypeAcessLock(context, bowsElem,
                        isWSFolderType ,
                        hasFromConnectAccess,
                        WSFOLDER_DISPLAY_TYPE,
                        emxNavErrorObject))
                    {
                        cmdChecksOK = false;
                    }
               }
            }
        }


        //Make sure all selected items are linked workspace folders.
        else if(objectAction.equals("unlinkWorkspaceFolder"))
        {
            final String RELATIONSHIP_LINKED_FOLDERS =
                SimulationUtil.getSchemaProperty(
                    "relationship_LinkedFolders");

            for (int ix = 0; ix < nObjs; ix++)
            {
                DomainRelationship DR = new DomainRelationship(relIds[ix]);

                String[] relId = {relIds[ix]};

                StringList selects =
                    new StringList(DomainConstants.SELECT_TYPE);

                MapList info = DR.getInfo(context, relId, selects);

                String type = "";
                if(info.size() > 0)
                {
                    type = (String)((Map)info.get(0)).get(
                                DomainConstants.SELECT_TYPE);
                }

                if(RELATIONSHIP_LINKED_FOLDERS.equals(type) == false)
                {
                    errMsg = SimulationUtil.getI18NString(context,
                        "smaHome.cmdChecks.MustBeLinked");
                    emxNavErrorObject.addMessage(errMsg);
                    cmdChecksOK = false;
                    break;
                }
            }
        }

        else if (objectAction.equals("delete")) // (multi-select)
        {
            // for delete also need to check parent lock and
            // parent access
            for (int ix = 0; ix < nObjs; ix++)
            {
                BusinessObjectWithSelect bowsElem =
                    bowsl.getElement(ix);
                // check object lock status
                if (checkIfLocked(context, bowsElem, emxNavErrorObject))
                {
                    cmdChecksOK = false;
                    break;
                }

                boolean hasTemplate =
                    Boolean.parseBoolean(
                        bowsElem.getSelectData(SELECT_HAS_REL_TEMPLATE));


                if (hasTemplate) {

                    //WXB:HF-177605V6R2012_:START
                    final String VAULTED_OBJECTS = DomainConstants.RELATIONSHIP_VAULTED_OBJECTS;
                    String vaulatedRelation = "to["+ VAULTED_OBJECTS +"].from.id";

                    String mqlCommand = "print bus $1 select $2 dump $3";
                    String mqlResult = MqlUtil.mqlCommand(context,
                            mqlCommand, bowsElem.getObjectId(), vaulatedRelation, "|");

                    String[] pipedResult = mqlResult.split("\\|");

                    if (pipedResult.length > 1) {
                        cmdChecksOK = true;
                    } else {

                        errMsg = SimulationUtil.getI18NString(context,
                                "smaHome.cmdChecks.DeleteBadTemplate");

                        emxNavErrorObject.addMessage(errMsg);
                        cmdChecksOK = false;
                        break;
                    }
                }//WXB:HF-177605V6R2012_:END




                boolean hasGroup =
                    Boolean.parseBoolean(
                        bowsElem.getSelectData(SELECT_HAS_REL_GROUPS));

                if (hasGroup)
                {
                    errMsg = SimulationUtil.getI18NString(context,
                        "smaHome.cmdChecks.DeleteBadGroupAllObjects");

                    emxNavErrorObject.addMessage(errMsg);
                    cmdChecksOK = false;
                    break;
                }


                boolean hasConnector = true;
                final String SEL_REL_CONNECT =
                    "to[" + RELATIONSHIP_CONNECTOR
                    + "].from." + DomainConstants.SELECT_ID;

                String id =
                    bowsElem.getSelectData(DomainConstants.SELECT_ID);
                DomainObject objDO = new DomainObject();
                objDO.setId(id);
                String objHasConn =
                    objDO.getInfo(context,SEL_REL_CONNECT);

                int count=0;
                final String TYPE_WSVAULT =
                    SimulationUtil.getSchemaProperty(SimulationConstants
                        .SYMBOLIC_type_WorkspaceVault);
                StringBuilder typePattern = new StringBuilder();
                typePattern.append(TYPE_WSVAULT);
                final String REL_WSVAULT =
                    SimulationUtil.getSchemaProperty(SimulationConstants
                        .SYMBOLIC_relationship_VaultedObjects);
                StringBuilder relPattern = new StringBuilder();
                relPattern.append(REL_WSVAULT);
                StringList objSelects = new StringList();
                objSelects.add(DomainConstants.SELECT_TYPE);
                MapList  relatedList =
                    objDO.getRelatedObjects(
                        context, relPattern.toString()  , typePattern.toString(), objSelects,
                        null, true, false,  (short)0, null, null,
                        0, null, null, null);


                count=relatedList.size();

                if (objHasConn == null)
                    hasConnector = false;

                if (hasConnector&&count<2)
                {
                    errMsg = SimulationUtil.getI18NString(context,
                        "smaHome.cmdChecks.DeleteBadConnector");
                    emxNavErrorObject.addMessage(errMsg);
                    cmdChecksOK = false;
                    break;
                }

                boolean hasTodisconnectAccess =
                    "true".equalsIgnoreCase(
                        bowsElem.getSelectData(SELECT_HAS_TODISCONNECT_ACCESS));
                if ( ! hasTodisconnectAccess )
                {
                    String objType = bowsElem.getSelectData(DomainConstants.SELECT_TYPE);
                    objType =
                        UINavigatorUtil.getAdminI18NString(
                            "Type", objType, locale);

                    String objName = bowsElem.getSelectData(SELECT_TITLE);
                    if (objName == null  ||  objName.length() == 0)
                    {
                        objName =
                            bowsElem.getSelectData(
                                DomainConstants.SELECT_NAME);
                    }
                    String state =
                        bowsElem.getSelectData(DomainConstants.SELECT_CURRENT);

                    String errMsg1 =
                        SimulationUtil.getI18NString(context,
                            "ErrMsg.Content.noaccess",
                            "TYPE", objType, "NAME", objName,
                            "NAME2", objName, "STATE", state);
                    emxNavErrorObject.addMessage(errMsg1);
                    cmdChecksOK = false;
                    break;
                }


                // check if can disconnect from any issues - if present
                StringList valueList =
                    bowsElem.getSelectDataList(SEL_ISSUE_ID);
                if (valueList != null)
                {
                    for (int jx=0;jx<valueList.size()&&cmdChecksOK;++jx)
                    {
                        String issueId = (String)valueList.get(jx);
                        DomainObject issueDO = new DomainObject();
                        issueDO.setId(issueId);
                        String reqParentAccess = "fromdisconnect";
                        if ( ! AccessUtil.hasAccess(
                            context, issueDO, reqParentAccess) )
                        {
                            StringList nameList =
                                bowsElem.getSelectDataList(
                                    SEL_ISSUE_NAME);
                            String issueName = (String)nameList.get(jx);
                            String objName = bowsElem.getSelectData(
                                SELECT_TITLE);
                            if (objName == null||objName.length() == 0)
                            {
                                objName =
                                    bowsElem.getSelectData(
                                        DomainConstants.SELECT_NAME);
                            }

                            errMsg = SimulationUtil.getI18NString(context,
                                "smaHome.cmdChecks.Delete.HasIssue");
                            errMsg = StringResource.format(errMsg,
                                 "P1", objName,
                                "P2",issueName);
                            emxNavErrorObject.addMessage(errMsg);
                            cmdChecksOK = false;
                        }
                    }
                    if (cmdChecksOK == false)
                        break;
                }



                // If the relId is null, then treat this as an actual
                // delete operation (as opposed to a disconnect operation).
                // - If no relId then this must be unmanaged data
                // - and the user must be asking to delete it.

                if (relIds[ix] == null)
                {
                    boolean hasDeleteAccess =
                        "true".equalsIgnoreCase(
                            bowsElem.getSelectData(SELECT_HAS_DELETE_ACCESS));
                    if ( ! hasDeleteAccess )
                    {
                        String objType = bowsElem.getSelectData(DomainConstants.SELECT_TYPE);
                        objType =
                            UINavigatorUtil.getAdminI18NString(
                                "Type", objType, locale);

                        String objName = bowsElem.getSelectData(SELECT_TITLE);
                        if (objName == null  ||  objName.length() == 0)
                        {
                            objName =
                                bowsElem.getSelectData(
                                    DomainConstants.SELECT_NAME);
                        }
                        String state =
                            bowsElem.getSelectData(DomainConstants.SELECT_CURRENT);

                        String errMsg1 =
                            SimulationUtil.getI18NString(context,
                                "ErrMsg.Content.noaccess",
                                 "TYPE", objType, "NAME", objName,
                                "NAME2", objName, "STATE", state);
                        emxNavErrorObject.addMessage(errMsg1);
                        cmdChecksOK = false;
                        break;
                    }
                }

                // check parent access and lock status.
                // If relId is null, then the parent is not a real
                // parent and does not need to be checked.
                // (This handles the Unmanaged Workspace.)
                if (parIds[ix] != null
                    &&  parIds[ix].length() > 0
                    &&  ! parIds[ix].equalsIgnoreCase("null")
                    &&  relIds[ix] != null)
                {
                    DomainObject parentDO = new DomainObject();
                    parentDO.setId(parIds[ix]);
                    if (AccessUtil.isLocked(context, parentDO, true))
                    {
                        String locker = parentDO.getInfo(context,
                            DomainConstants.SELECT_LOCKER);

                        final String msg1 =
                            SimulationUtil.getI18NString(context,
                                "smaSimulationCentral.Content.ErrMsg.cannotdooperation");
                        final String msg2 =
                            SimulationUtil.getI18NString
                                    (context,
                                "smaSimulationCentral.Content.ErrMsg.parentislocked","P1", locker);

                        String msg3 = msg1 + " " + msg2;
                        emxNavErrorObject.addMessage(msg3);
                        cmdChecksOK = false;
                        break;
                    }

                    String reqParentAccess = "modify,fromdisconnect";
                    if ( ! AccessUtil.hasAccess(
                        context, parentDO, reqParentAccess) )
                    {
                        String objName =
                            bowsElem.getSelectData(SELECT_TITLE);
                        if (objName == null||objName.length() == 0)
                            objName =
                                bowsElem.getSelectData(
                                    DomainConstants.SELECT_NAME);
                        String ptype =
                            parentDO.getInfo(
                                context,
                                DomainObject.SELECT_TYPE);
                        ptype =
                            UINavigatorUtil.getAdminI18NString(
                                "Type", ptype, locale);

                        String errMsg1 =
                            SimulationUtil.getI18NString(context,
                            "ErrMsg.Content.noaccessParent",
                             "OBJNAME", objName, "PTYPE", ptype);
                        emxNavErrorObject.addMessage(errMsg1);
                        cmdChecksOK = false;
                        break;
                    }
                } // if has parent

                // Check for SLM ownership.
                String[] relCheckKeys =
                    { SELECT_HAS_REL_CONTENT_OWNED,
                      SELECT_REL_CONTENT_OWNED_MODIFY,
                      SELECT_REL_CONTENT_OWNED_LOCKED,
                      SELECT_REL_CONTENT_OWNED_LOCKER,
                      SELECT_HAS_REL_ACTIVITY,
                      SELECT_REL_ACTIVITY_MODIFY,
                      SELECT_REL_ACTIVITY_LOCKED,
                      SELECT_REL_ACTIVITY_LOCKER,
                      SELECT_HAS_REL_TEMPLATE_CONTENT,
                      SELECT_REL_TEMPLATE_CONTENT_MODIFY,
                      SELECT_REL_TEMPLATE_CONTENT_LOCKED,
                      SELECT_REL_TEMPLATE_CONTENT_LOCKER
                    };
                for (int ixx=0; ixx<3; ++ixx)
                {
                    int jxx = ixx * 4;
                    String ownerOid =
                        bowsElem.getSelectData(relCheckKeys[jxx]);

                    //owner and parent id check added for IR-116675V6R2012x -sh2
                    if (ownerOid != null  &&  ownerOid.length() > 0 && ownerOid.equals(parIds[ix]))
                    {
                        // Check access.
                        if (Boolean.parseBoolean(
                                bowsElem.getSelectData(relCheckKeys[jxx+1])) == false)
                        {
                            String objName =
                                bowsElem.getSelectData(SELECT_TITLE);
                            if (objName == null||objName.length() == 0)
                                objName =
                                    bowsElem.getSelectData(
                                        DomainConstants.SELECT_NAME);

                            DomainObject parentDO = new DomainObject();
                            parentDO.setId(ownerOid);
                            String ptype =
                                parentDO.getInfo(
                                    context,
                                    DomainObject.SELECT_TYPE);
                            ptype =
                                UINavigatorUtil.getAdminI18NString(
                                    "Type", ptype, locale);

                            String errMsg1 =
                                SimulationUtil.getI18NString(context,
                                "ErrMsg.Content.noaccessParent",
                                 "OBJNAME", objName, "PTYPE", ptype);
                            emxNavErrorObject.addMessage(errMsg1);
                            cmdChecksOK = false;
                            break;
                        }
                        // Check if locked.
                        if (Boolean.parseBoolean(
                                bowsElem.getSelectData(relCheckKeys[jxx+2])))
                        {
                            String locker =
                                bowsElem.getSelectData(relCheckKeys[jxx+3]);

                            final String msg1 =
                                SimulationUtil.getI18NString(context,
                                    "smaSimulationCentral.Content.ErrMsg.cannotdooperation");
                            final String msg2 =
                                SimulationUtil.getI18NString(context,
                                    "smaSimulationCentral.Content.ErrMsg.parentislocked",
                                     "P1", locker);

                            String msg3 = msg1 + " " + msg2;
                            emxNavErrorObject.addMessage(msg3);
                            cmdChecksOK = false;
                            break;
                        }
                    }
                } // for

                if (cmdChecksOK == false)
                    break;

            } // for each object
        } // if delete

        else if (objectAction.equals("assignSimulation")||
            objectAction.equals("assignActivity"))
        {
            if (!onlyOneObj(context, nObjs, emxNavErrorObject))
            {
                cmdChecksOK = false;
            }
            else
            {
                BusinessObjectWithSelect bowsElem = bowsl
                    .getElement(0);
                boolean isTemplateType = Boolean
                .parseBoolean(bowsElem
                    .getSelectData(SELECT_KINDOF_TEMPLATE));

                boolean hasConnectAccess = true;

                // Determine if user can add things to the entity
                hasConnectAccess = "true"
                    .equalsIgnoreCase(bowsElem
                        .getSelectData(SELECT_HAS_CONNECT_FROM_ACCESS));

                if (!checkCommandForTypeAcessLock(context, bowsElem,
                    isTemplateType,
                    hasConnectAccess,
                    TEMPLATE_TYPE,
                    emxNavErrorObject))
                {
                    cmdChecksOK = false;
                }
            }
        }
        // Don't allow the locking of team central objects
        else if (objectAction.equals("lock")) //(multi-select)
        {
            for (int i = 0; i < nObjs; i++)
            {
                BusinessObjectWithSelect bowsElem =
                    bowsl.getElement(i);
                boolean isWSFolderType = Boolean
                .parseBoolean(bowsElem
                    .getSelectData(SELECT_KINDOF_WSFOLDER));
                boolean isWorkSpace = Boolean
                .parseBoolean(bowsElem
                    .getSelectData(SELECT_KINDOF_WS));
                boolean isVpmType = Boolean
                .parseBoolean(bowsElem
                    .getSelectData(SELECT_KINDOF_VPMREFERENCE));
                if (isWorkSpace || isWSFolderType)
                {
                    errMsg = SimulationUtil.getI18NString(context,
                        "smaHome.cmdChecks.NoLock");
                    emxNavErrorObject.addMessage(errMsg);
                    cmdChecksOK = false;
                    break;
                }
                if (isVpmType)
                {
                    errMsg =
                        SimulationUtil.getI18NString(context,
                            "smaHome.cmdChecks.Lock.NoVPM");
                    emxNavErrorObject.addMessage(errMsg);
                    cmdChecksOK = false;
                    break;
                }
                boolean canLock = Boolean.parseBoolean(bowsElem
                    .getSelectData(
                        CommonDocument.SELECT_HAS_LOCK_ACCESS));
                if (!canLock)
                {
                    String label = (String)bowsElem
                        .getSelectData(SELECT_TITLE);
                    if (label == null || label.length() == 0)
                        label = (String)bowsElem
                        .getSelectData(DomainConstants.SELECT_NAME);
                    errMsg = SimulationUtil.getI18NString(context,
                        "smaHome.cmdChecks.NoLockAccess");
                    errMsg = StringResource.format(
                        errMsg, "P1", label);
                    emxNavErrorObject.addMessage(errMsg);
                    cmdChecksOK = false;
                    break;
                }
            }
        }
        else if (objectAction.equals("activateHosts") ||
            objectAction.equals("deactivateHosts")) //(multi-select)
        {
            for (int i = 0; i < nObjs; i++)
            {
                BusinessObjectWithSelect bowsElem =
                    bowsl.getElement(i);
                boolean isHostType = Boolean.parseBoolean(bowsElem
                    .getSelectData(SELECT_KINDOF_HOST));

                boolean hasModifyAccess = "true"
                    .equalsIgnoreCase(bowsElem
                        .getSelectData(SELECT_HAS_MODIFY_ACCESS));

                if (!checkCommandForTypeAcessLock(context, bowsElem,
                    isHostType, hasModifyAccess,
                    HOST_TYPE,
                    emxNavErrorObject))
                cmdChecksOK = false;
                break;
            }
        }
        else if (objectAction.equals("exportHosts")) //(multi-select)
        {
            for (int i = 0; i < nObjs; i++)
            {
                BusinessObjectWithSelect bowsElem =
                    bowsl.getElement(i);
                boolean isHostType = Boolean.parseBoolean(bowsElem
                    .getSelectData(SELECT_KINDOF_HOST));

                if (!checkCommandForTypeAcessLock(context, bowsElem,
                    isHostType, true,
                    HOST_TYPE,
                    emxNavErrorObject))
                cmdChecksOK = false;
                break;
            }
        }
        // Don't allow the unlocking of team central objects
        else if (objectAction.equals("unlock")) //(multi-select)
        {
            for (int i = 0; i < nObjs; i++)
            {
                BusinessObjectWithSelect bowsElem =
                    bowsl.getElement(i);
                boolean isWSFolderType = Boolean
                .parseBoolean(bowsElem
                    .getSelectData(SELECT_KINDOF_WSFOLDER));
                boolean isWorkSpace = Boolean
                .parseBoolean(bowsElem
                    .getSelectData(SELECT_KINDOF_WS));
                boolean isVpmType = Boolean
                .parseBoolean(bowsElem
                    .getSelectData(SELECT_KINDOF_VPMREFERENCE));
                if (isWorkSpace || isWSFolderType)
                {
                    errMsg = SimulationUtil.getI18NString(context,
                        "smaHome.cmdChecks.NoUnlock");
                    emxNavErrorObject.addMessage(errMsg);
                    cmdChecksOK = false;
                    break;
                }
                if (isVpmType)
                {
                    errMsg =
                        SimulationUtil.getI18NString(context,
                            "smaHome.cmdChecks.Unlock.NoVPM");
                    emxNavErrorObject.addMessage(errMsg);
                    cmdChecksOK = false;
                    break;
                }

                // get lock info to see if can unlock
                boolean isLocked = "true".equalsIgnoreCase(bowsElem
                    .getSelectData(DomainConstants.SELECT_LOCKED));
                String locker = bowsElem
                    .getSelectData(DomainConstants.SELECT_LOCKER);
                boolean lockedByUser = isLocked
                    && context.getUser().equals(locker);
                boolean canUnlock = Boolean.parseBoolean(bowsElem
                    .getSelectData(
                        CommonDocument.SELECT_HAS_UNLOCK_ACCESS));

                // check if locked and locked by user
                if (!(isLocked && lockedByUser ) &&
                    canUnlock == false)
                {
                    String label = (String)bowsElem
                        .getSelectData(SELECT_TITLE);
                    if (label == null || label.length() == 0)
                        label = (String)bowsElem
                        .getSelectData(DomainConstants.SELECT_NAME);
                    errMsg = SimulationUtil.getI18NString(context,
                        "smaHome.cmdChecks.NoUnlockAccess");
                    errMsg = StringResource.format(
                        errMsg, "P1", label);
                    emxNavErrorObject.addMessage(errMsg);
                    cmdChecksOK = false;
                    break;
                }
            }
        }

        // VE4 : added Simulation documents to templates V6R2013 FD02
        // only SIMULATIONS  and Simulation Documents
        // can be saved as template
            else if (objectAction.equals("saveAsTemplate"))
            {
                if (!onlyOneObj(context, nObjs, emxNavErrorObject))
                {
                    cmdChecksOK = false;
                }
                else
                {
                    // Get Business Object from list
                BusinessObjectWithSelect bowsElem = bowsl
                    .getElement(0);

                    // only need read access on SIM to save as template
                    boolean isSIMSType = Boolean.parseBoolean(bowsElem
                        .getSelectData(SELECT_KINDOF_SIMULATIONS)),
                        performCommandCheckForSimulationAndActivity = false;
                    //Start-wu4-(Porting)-Template for Simulation Document
                    if (SimulationContentUtil
                        .isDocumentTemplateEnabled(context))
                    {

                        boolean isDOCType = false;
                        if (Boolean.parseBoolean(bowsElem
                            .getSelectData(SELECT_KINDOF_SIMDOCUMENTS_NV))
                            || Boolean
                                .parseBoolean(bowsElem
                                    .getSelectData(SELECT_KINDOF_SIMDOCUMENTS_VER)))
                            isDOCType = true;
                        if (isDOCType)
                        {
                            if (!checkCommandForTypeAcessLock(context,
                                bowsElem, isDOCType, true,
                                SIMDOCUMENTS_NV_TYPE,
                                SIMDOCUMENTS_VER_TYPE, false,
                                emxNavErrorObject))
                            {
                                cmdChecksOK = false;
                            }
                        }
                        else
                            performCommandCheckForSimulationAndActivity = true;
                    }
                    else
                        performCommandCheckForSimulationAndActivity = true;

                    if(performCommandCheckForSimulationAndActivity){
                        if (!checkCommandForTypeAcessLock(context,
                            bowsElem, isSIMSType, true,
                            SIMULATION_TYPE, ACTIVITY_TYPE, false,
                            emxNavErrorObject))
                        {
                            cmdChecksOK = false;
                        }
                    }

                    //End-wu4-(Porting)-Template for Simulation Document
                }
            }

            else if (objectAction.equals("saveAsHomeTemplate"))
            {
                if (!onlyOneObj(context, nObjs, emxNavErrorObject))
                {
                    cmdChecksOK = false;
                }
                else
                {
                    // Get Business Object from list
                BusinessObjectWithSelect bowsElem = bowsl
                    .getElement(0);

                    // only need read access on SIM to save as template
                    boolean isSIMSType = Boolean.parseBoolean(bowsElem
                        .getSelectData(SELECT_KINDOF_SIMULATIONS)),
                        performCommandCheckForSimulationAndActivity = false;
                    //Start-wu4-(Porting)-Template for Simulation Document
                    if (SimulationContentUtil
                        .isDocumentTemplateEnabled(context))
                    {

                        boolean isDOCType = false;
                        if (Boolean.parseBoolean(bowsElem
                            .getSelectData(SELECT_KINDOF_SIMDOCUMENTS_NV))
                            || Boolean
                                .parseBoolean(bowsElem
                                    .getSelectData(SELECT_KINDOF_SIMDOCUMENTS_VER)))
                            isDOCType = true;
                        if (isDOCType)
                        {
                            if (!checkCommandForTypeAcessLock(context,
                                bowsElem, isDOCType, true,
                                SIMDOCUMENTS_NV_TYPE,
                                SIMDOCUMENTS_VER_TYPE, false,
                                emxNavErrorObject))
                            {
                                cmdChecksOK = false;
                            }
                        }
                        else
                            performCommandCheckForSimulationAndActivity = true;
                    }
                    else
                        performCommandCheckForSimulationAndActivity = true;

                    if(performCommandCheckForSimulationAndActivity){
                        if (!checkCommandForTypeAcessLock(context,
                            bowsElem, isSIMSType, true,
                            SIMULATION_TYPE, ACTIVITY_TYPE, false,
                            emxNavErrorObject))
                        {
                            cmdChecksOK = false;
                        }
                    }

                    //End-wu4-(Porting)-Template for Simulation Document
                }
            }
            // only allow folder to be set as home folder
            else if (objectAction == "setAsHomeFolder")
            {
                if (!onlyOneObj(context, nObjs, emxNavErrorObject))
                {
                    cmdChecksOK = false;
                }
                else
                {
                    // Get Business Object from list
                BusinessObjectWithSelect bowsElem = bowsl
                    .getElement(0);

                boolean isWSFolderType = Boolean
                .parseBoolean(bowsElem
                        .getSelectData(SELECT_KINDOF_WSFOLDER));

                    if (!checkCommandForTypeAcessLock(context, bowsElem,
                        isWSFolderType,
                        true,           // user needs only Read
                        WSFOLDER_DISPLAY_TYPE,
                        emxNavErrorObject))
                    {
                        cmdChecksOK = false;
                    }
                }
            }
            // only allow folder with fromconnect access to be set as default folder
            else if (objectAction == "setAsDefaultFolder")
            {
                if (!onlyOneObj(context, nObjs, emxNavErrorObject))
                {
                    cmdChecksOK = false;
                }
                else
                {
                    // Get Business Object from list
                BusinessObjectWithSelect bowsElem = bowsl
                    .getElement(0);

                boolean isWSFolderType = Boolean
                .parseBoolean(bowsElem
                        .getSelectData(SELECT_KINDOF_WSFOLDER));

                    if (isWSFolderType)
                    {
                        // Determine if user can add things to the entity
                    if (!"true".equalsIgnoreCase(
                            bowsElem.getSelectData(SELECT_HAS_CONNECT_FROM_ACCESS)))
                        {
                        emxNavErrorObject.addMessage(
                                SimulationUtil.getI18NString(context,
                                        "smaSimulationCentral.SetAsDefaultFolder.access"));

                            cmdChecksOK = false;
                        }
                    }

                    else if (!checkCommandForTypeAcessLock(context,
                            bowsElem,
                            isWSFolderType,
                            true,           // ignore access error
                            WSFOLDER_DISPLAY_TYPE,
                            emxNavErrorObject))
                    {
                        cmdChecksOK = false;
                    }
                }
            }
        }
        catch (Exception ex)
        {
            cmdChecksOK = false;
            emxNavErrorObject.addMessage(ErrorUtil.getMessage(ex, false));
        }
        return cmdChecksOK;
    }

    // method to check if if only single item selected
    // this check is called when command should be single select
    // method should not be needed since check doen by matrix
    private boolean onlyOneObj(Context context, int nObjs,
        FrameworkException emxNavErrorObject)
    {
        boolean onlyOne = true;
        try
        {
            if (nObjs > 1)
            {
                onlyOne = false;
                String locale = context.getSession().getLanguage();
                String errMsg = SimulationUtil.getI18NString(context,
                    "smaHome.cmdChecks.SelectOnlyOne");
                emxNavErrorObject.addMessage(errMsg);
            }
        }
        catch (Exception ex)
        {
            onlyOne = false;
            emxNavErrorObject.addMessage(ErrorUtil.getMessage(ex, false));
        }
        return onlyOne;
    }

    // method to do validity checks to see if we have the right type, access
    // and selected object is not locked.
    // This method supports two possible types
    // It also support a reverse concept which will reverse the type  check
    // So if type to check is true then that is a bad type
    private boolean checkCommandForTypeAcessLock(Context context,
    BusinessObjectWithSelect bowsElem,
    boolean typeToCheck,
    boolean acessToCheck,
    String type1, String type2, boolean reverse,
        FrameworkException emxNavErrorObject)
    {
        boolean cmdOK = true;
        String locale = context.getSession().getLanguage();
        String errMsg = "";
        try
        {
            final String WSFOLDER_TYPE = SimulationUtil
        .getSchemaProperty(
            DomainSymbolicConstants.SYMBOLIC_type_ProjectVault);

        final String WSFOLDER_DISPLAY_TYPE =
            UINavigatorUtil.getAdminI18NString(
                "Type",
                WSFOLDER_TYPE,
                context.getSession().getLanguage());
            if (reverse)
            {
                if ((typeToCheck))
                {
                    if (WSFOLDER_DISPLAY_TYPE.equals(type2))
                    {
                        errMsg = SimulationUtil.getI18NString(context,
                            "smaHome.cmdChecks.BadType2WS");
                    errMsg = StringResource.format(
                        errMsg, "P1",type1);
                    }
                    else
                    {
                        errMsg = SimulationUtil.getI18NString(context,
                            "smaHome.cmdChecks.BadType2");
                    errMsg = StringResource.format(
                        errMsg, "P1",type1, "P2", type2);
                    }
                    emxNavErrorObject.addMessage(errMsg);
                    cmdOK = false;
                }
            }
            else
            {
                if (!(typeToCheck))
                {
                    if (WSFOLDER_DISPLAY_TYPE.equals(type2))
                    {
                        errMsg = SimulationUtil.getI18NString(context,
                            "smaHome.cmdChecks.NotGoodType2WS");
                    errMsg = StringResource.format(
                        errMsg, "P1",type1);
                    }
                    else
                    {
                        errMsg = SimulationUtil.getI18NString(context,
                            "smaHome.cmdChecks.NotGoodType2");
                    errMsg = StringResource.format(
                        errMsg, "P1",type1, "P2", type2);
                    }
                    emxNavErrorObject.addMessage(errMsg);
                    cmdOK = false;
                }
            }
            if (cmdOK)
            {
                if (!(acessToCheck))
                {
                    errMsg = SimulationUtil.getI18NString(context,
                        "smaHome.cmdChecks.BadAccess");
                    emxNavErrorObject.addMessage(errMsg);
                    cmdOK = false;
                }
            else if (checkIfLocked(context, bowsElem,
                emxNavErrorObject))
                {
                    cmdOK = false;
                }
            }
        }
        catch (Exception ex)
        {
            cmdOK = false;
            emxNavErrorObject.addMessage(ErrorUtil.getMessage(ex, false));
        }
        return cmdOK;
    }


    // method to do validity checks to see if we have the right type, access
    // and selected object is not locked.
    // This method supports only one possible types
    private boolean checkCommandForTypeAcessLock(Context context,
    BusinessObjectWithSelect bowsElem,
    boolean typeToCheck,
    boolean acessToCheck,
    String type1,
        FrameworkException emxNavErrorObject)
    {
        boolean cmdOK = true;
        String locale = context.getSession().getLanguage();
        String errMsg = "";
        try
        {
            if (!(typeToCheck))
            {
                final String WSFOLDER_TYPE = SimulationUtil
            .getSchemaProperty(
                DomainSymbolicConstants.SYMBOLIC_type_ProjectVault);

            final String WSFOLDER_DISPLAY_TYPE =
                UINavigatorUtil.getAdminI18NString(
                    "Type",
                    WSFOLDER_TYPE,
                    context.getSession().getLanguage());
                if (WSFOLDER_DISPLAY_TYPE.equals(type1))
                {
                    errMsg = SimulationUtil.getI18NString(context,
                        "smaHome.cmdChecks.NotGoodType1WS");
                }
                else
                {
                    errMsg = SimulationUtil.getI18NString(context,
                        "smaHome.cmdChecks.NotGoodType1");
                errMsg = StringResource.format(
                    errMsg, "P1",type1);
                }
                emxNavErrorObject.addMessage(errMsg);
                cmdOK = false;
            }
            else if (!(acessToCheck))
            {
                errMsg = SimulationUtil.getI18NString(context,
                    "smaHome.cmdChecks.BadAccess");
                emxNavErrorObject.addMessage(errMsg);
                cmdOK = false;
            }
        else if (checkIfLocked(context, bowsElem,
            emxNavErrorObject))
            {
                cmdOK = false;
            }
        }
        catch (Exception ex)
        {
            cmdOK = false;
            emxNavErrorObject.addMessage(ErrorUtil.getMessage(ex, false));
        }
        return cmdOK;
    }

    //method to do validity checks to see if we have the right type, access
    //and selected object is not locked.
    //This method checks to make sure that the selected entity is of a
    //type that is in the array legalTypes.
    private boolean checkCommandForTypeAcessLock(Context context,
 BusinessObjectWithSelect bowsElem,
 boolean acessToCheck,
 boolean checkLock,
 String[] legalTypes,
        FrameworkException emxNavErrorObject)
    {
        boolean cmdOK = true;
        String locale = context.getSession().getLanguage();
        String errMsg = "";
        try
        {
            //Make sure it is of a type in the array legalTypes
        DomainObject DO =
            new DomainObject(bowsElem.getObjectId());
            boolean foundMatch = false;
            StringBuilder types = new StringBuilder();
            String lastLegal = "";
            //Check against each type in legalTypes.
            for (int ii = 0; ii < legalTypes.length; ii++)
            {
                if (DO.isKindOf(context, legalTypes[ii]))
                {
                    foundMatch = true;
                }

            final String DISPLAY_TYPE =
                UINavigatorUtil.getAdminI18NString(
                    "Type",
                    legalTypes[ii],
                    context.getSession().getLanguage());

                if (ii < legalTypes.length - 1)
                {
                    types.append(DISPLAY_TYPE).append(", ");
                }
                else
                {
                    lastLegal = DISPLAY_TYPE;
                }
            }
            //It its not in the array build an error message.
            if (!foundMatch)
            {
                String legals = types.toString();


                errMsg = SimulationUtil.getI18NString(context,
                    "smaHome.cmdChecks.MustBeLegalType");
            errMsg = StringResource.format(
                errMsg, "P1",legals, "P2",lastLegal);

                emxNavErrorObject.addMessage(errMsg);
                cmdOK = false;
            }
            if (cmdOK)
            {
                if (!(acessToCheck))
                {
                    errMsg = SimulationUtil.getI18NString(context,
                        "smaHome.cmdChecks.BadAccess");
                    emxNavErrorObject.addMessage(errMsg);
                    cmdOK = false;
                }
                else if (checkLock)
                {
                    //Make sure it is unlocked
                if (checkIfLocked(context, bowsElem,
                    emxNavErrorObject))
                    {
                        cmdOK = false;
                    }
                }
            }
        }
        catch (Exception ex)
        {
            cmdOK = false;
            emxNavErrorObject.addMessage(ErrorUtil.getMessage(ex));
        }
        return cmdOK;
    }

    //method to check job related info for run, abort, and continue command
    private boolean checkJobInfo(Context context, String objectAction,
        BusinessObjectWithSelect bowsElem,
        FrameworkException emxNavErrorObject)
    {
        boolean jobInfoOK = true;
        String locale = context.getSession().getLanguage();
        String errMsg = "";
        try
        {

        String id =  bowsElem.getSelectData(
            DomainConstants.SELECT_ID);
            SIMULATIONS sim = new SIMULATIONS();
            sim.setId(id);
            SimulationJob job = sim.getJob(context);
            String jobStatus = "";
            String jobId = "";
            if (job != null)
            {
                jobId = job.getId(context);
                jobStatus = job.getStatus(context);
                if (objectAction.equals("repeat"))
                {
                    if (!(SimulationConstants.JOB_STATUS_PAUSED
                        .equals(jobStatus)))
                    {
                    errMsg = SimulationUtil.getI18NString(context,
                                "smaSimulationCentral.JobController.CantRepeat");
                        emxNavErrorObject.addMessage(errMsg);
                        jobInfoOK = false;
                    }
                else if (!(AccessUtil.hasAccess(context, context
                    .getUser(), jobId, "modify")))
                    {
                        errMsg = SimulationUtil.getI18NString(context,
                            "smaHome.cmdChecks.JobNoModify");
                        emxNavErrorObject.addMessage(errMsg);
                        jobInfoOK = false;
                    }
                }
                if (objectAction.equals("assignConnector"))
                {
                    if (SimulationConstants.JOB_STATUS_PAUSED
                    .equals(jobStatus) ||
                    SimulationConstants.JOB_STATUS_RUNNING
                    .equals(jobStatus) ||
                    SimulationConstants.JOB_STATUS_NOTSTARTED
                            .equals(jobStatus))
                    {
                        errMsg = SimulationUtil.getI18NString(context,
                            "smaHome.cmdChecks.BadConnectorAssign");
                        emxNavErrorObject.addMessage(errMsg);
                        jobInfoOK = false;
                    }
                else if (!(AccessUtil.hasAccess(context, context
                    .getUser(), jobId, "modify")))
                    {
                        errMsg = SimulationUtil.getI18NString(context,
                            "smaHome.cmdChecks.JobNoModify");
                        emxNavErrorObject.addMessage(errMsg);
                        jobInfoOK = false;
                    }
                }

                // cannot create an activity in a process if the process
                // has a job that is already running, paused
                // or is not started (since assumes will start shortly)
            if (objectAction.equals("createActivityInSim") ||
                objectAction.equals("createActivity"))
                {
                    if (SimulationConstants.JOB_STATUS_NOTSTARTED
                        .equals(jobStatus)
                        || SimulationConstants.JOB_STATUS_RUNNING
                            .equals(jobStatus)
                        || SimulationConstants.JOB_STATUS_PAUSED
                            .equals(jobStatus))
                    {
                        errMsg = SimulationUtil.getI18NString(context,
                            "smaHome.cmdChecks.JobCannotCreateActInSim");
                        emxNavErrorObject.addMessage(errMsg);
                        jobInfoOK = false;
                    }
                }

            }
            // there are no associated jobs so can't abort or continue
            else
            {
                if (objectAction.equals("repeat"))
                {
                    errMsg = SimulationUtil.getI18NString(context,
                        "smaSimulationCentral.JobController.CantRepeat"
                    );
                    emxNavErrorObject.addMessage(errMsg);
                    jobInfoOK = false;
                }
            }
        }
        catch (Exception ex)
        {
            jobInfoOK = false;
            emxNavErrorObject.addMessage(ErrorUtil.getMessage(ex, false));
        }
        return jobInfoOK;
    }

    // method to check if selected object is locked
    private boolean checkIfLocked(Context context,
        BusinessObjectWithSelect bowsElem,
        FrameworkException emxNavErrorObject)
    {
        boolean isObjLocked = false;
        //String locale = context.getSession().getLanguage();
        String errMsg = "";
        try
        {
            // check if object is locked
            boolean isLocked = "true".equalsIgnoreCase(bowsElem
                .getSelectData(DomainConstants.SELECT_LOCKED));

            String locker = bowsElem
                .getSelectData(DomainConstants.SELECT_LOCKER);

            boolean lockedByUser = isLocked
                && context.getUser().equals(locker);

            if (isLocked && (lockedByUser == false))
            {
                errMsg = SimulationUtil.getI18NString(context,
                "smaHome.cmdChecks.ObjIsLocked",
                "P1", locker);
                emxNavErrorObject.addMessage(errMsg);
                isObjLocked = true;
                return isObjLocked;
            }
        }
        catch (Exception ex)
        {
            isObjLocked = true;
            emxNavErrorObject.addMessage(ErrorUtil.getMessage(ex, false));
        }
        return isObjLocked;
    }




    // Flag to indicate if getCommandHref() is called.
    // Used to check for a faulty command (did not work for some reason).
    private boolean cmdExpected = false;


    /*
     * @param cmdName Name of command to retrieve.
     * @param objectId The object the command is being applied to.
     * @param requestMap The map of the http request parameters.
     */
private String getCommandHref(
    Context context, String cmdName, String objectId,
    Map requestMap)
throws MatrixException, Exception
    {
    return getCommandHref(context, cmdName, objectId, objectId, requestMap);
    }


    /*
     * @param cmdName Name of command to retrieve.
     * @param objectId The object the command is being applied to.
     * @param parentOid object id to use for the parent.
     * @param requestMap The map of the http request parameters.
     */
private String getCommandHref(
    Context context, String cmdName, String objectId,
    String parentOid, Map requestMap)
        throws MatrixException, Exception
    {
        cmdExpected = true;
    return SlmUIUtil.getCommandHref(context,
               cmdName, objectId, parentOid, requestMap);
    }


    private void deleteItems(Context context, String[] sRowIds)
        throws FrameworkException, MatrixException, Exception
    {
        // Sort based on level, we want to delete all leaves first and
        // then their parents.
        // Level is the last column of the row ids, so create a temp
        // set of row ids for sorting, with level first.

        StringList selectRowIds = new StringList(sRowIds.length);
        for (int jj = 0; jj < sRowIds.length; jj++)
        {
            String[] fields = sRowIds[jj].split("\\|");
            selectRowIds.add(fields[fields.length - 1] + "&" + sRowIds[jj]);
        }

        selectRowIds.sort();

        // Need to remove the added front part now.
        // Reverse the order so leaves come first
        int i = 0;
        for (int jj = sRowIds.length - 1; jj >= 0; jj--)
        {
            String sId = (String) selectRowIds.get(jj);
            String[] tmpParts = sId.split("\\&");
            sRowIds[i++] = tmpParts[1];
        }

        SlmUIUtil.removeTOCReferences(context, sRowIds, true);
    }


private String getHomeFolderOid(Context context)
throws Exception
{
return (String) JPO.invoke(
    context,
    "jpo.simulation.SimulationUI",
    null,
    "getHomeFolderOID",
    JPO.packArgs(new HashMap()),
            String.class);
    }

private String getWorkingFolderOid(Context context)
throws Exception
{
return (String) JPO.invoke(
    context,
    "jpo.simulation.SimulationUI",
    null,
    "getWorkingFolderOID",
    JPO.packArgs(new HashMap()),
            String.class);
    }

private static boolean isOwnedActivity(
        Context context,
        BusinessObjectWithSelect bowsElem)
    throws MatrixException
    {
        if (isKindOfActivity(bowsElem))
        {
            // and have parent simulation
            return SlmUIUtil.isOwnedActivity(context, bowsElem);
        }

        return false;
    }

private static boolean isOwnedDocument(
        Context context,
        BusinessObjectWithSelect bowsElem)
    throws MatrixException
    {
        if (isKindOfDocument(bowsElem))
        {
            return SlmUIUtil.isOwnedContent(context, bowsElem);
        }

        return false;
    }

private static boolean isActivityInactiveRevision(
        Context context,
        BusinessObjectWithSelect bows)
    throws MatrixException
    {
        if (isKindOfActivity(bows))
        {
            return SlmUIUtil.isInactiveRevisionActivity(context, bows);
        }

        return false;
    }

private static boolean isOwnedDocumentInactiveRevision(
        Context context,
        BusinessObjectWithSelect bows)
    throws MatrixException
    {
        if (isKindOfDocument(bows))
        {
            return SlmUIUtil.isInactiveRevisionOwnedContent(context, bows);
        }

        return false;
    }

    private static boolean isKindOfActivity(
        BusinessObjectWithSelect bowsElem)
    {
    final String ACTIVITY_TYPE =
        SimulationUtil.getSchemaProperty(
            SimulationConstants.SYMBOLIC_type_SimulationActivity);

    final String SELECT_KINDOF_ACTIVITY =
        new StringBuilder().
            append("type.kindof[").
            append(ACTIVITY_TYPE).
            append(']').
            toString();

        return isKindOf(bowsElem, SELECT_KINDOF_ACTIVITY);
    }

    private static boolean isKindOfDocument(
        BusinessObjectWithSelect bowsElem)
    {
    final String DOCUMENTS_TYPE =
        SimulationUtil.getSchemaProperty(
            DomainSymbolicConstants.SYMBOLIC_type_DOCUMENTS);

    final String SELECT_KINDOF_DOCUMENTS =
        new StringBuilder().
            append("type.kindof[").
            append(DOCUMENTS_TYPE).
            append(']').
            toString();

        return isKindOf(bowsElem, SELECT_KINDOF_DOCUMENTS);
    }

private static boolean isKindOf(
    BusinessObjectWithSelect bowsElem,
        String kindOfString)
    {
    return Boolean.parseBoolean(
        bowsElem.getSelectData(kindOfString));
    }

    private static String scrubForWindowName(String string)
    {
        if (string != null)
        {
            return string.replaceAll("\\.", "_");
        }

        return "";
    }

    private boolean nullandemptycheck(String arg)
    {
        if (arg != null && !"".equals(arg))
            return true;
        return false;
    }

private String printBusMQL(Context ctx,String oid,String select,String dump)
throws FrameworkException
    {
    return MqlUtil.mqlCommand(ctx, "print bus $1  select $2 $3 ",true, oid, select , dump );
    }

private String printConnectionMQL(Context ctx,String relid,String select,String dump)
throws FrameworkException
    {
    return MqlUtil.mqlCommand(ctx, "print connection $1  select $2 $3 ",true, relid, select , dump );
    }

    private void deleteConnection(Context ctx, String relid)
        throws FrameworkException
    {
        MqlUtil.mqlCommand(ctx, "delete connection $1 ", true, relid);
    }

private String getRelId(Context ctx,StringList lList,String id,String dump)
throws FrameworkException
    {

        Iterator itr = lList.iterator();
        String temp = "";
        while (itr.hasNext())
        {
            temp = printBusMQL(ctx, id, (String) itr.next(), dump);
            if (nullandemptycheck(temp))
                return temp;
        }
        return temp;
}
%>
