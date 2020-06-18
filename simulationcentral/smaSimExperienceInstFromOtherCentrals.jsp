<%-- (c) Dassault Systemes, 2013, 2014 --%>
<%--
  Process instantiate template command from other centrals
--%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="java.util.HashMap"%>
<%@page import="java.util.Map"%>
<%@page import="com.dassault_systemes.smaslm.matrix.common.SimulationUtil"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.dassault_systemes.smaslm.matrix.common.SimulationConstants"%>
<%@page import="com.dassault_systemes.smaslm.matrix.server.Template"%>
<%@page import="com.matrixone.apps.domain.util.MapList"%>
<%@page import="matrix.util.StringList"%>
<%@include file="../common/emxNavigatorInclude.inc"%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>

<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script type="text/javascript" src="../simulationcentral/smaStructureNavigator.js"></script>
<script type="text/javascript" src="../common/scripts/emxUIModal.js"></script>

<!-- Used to load "findFrame" -->
<script type="text/javascript" src="../common/scripts/emxUIConstants.js"></script>
<%
String objectId  = "";
String tableRowIdList[] = request.getParameterValues("emxTableRowId");
String parentId  = emxGetParameter(request, "parentOID");
String tableRowId = "";

if (tableRowIdList != null)
    {
        tableRowId = tableRowIdList[0];
    }

if (tableRowId != null && tableRowId.length() > 0)
    {
        objectId = tableRowId.trim();
        if(objectId.indexOf("|") != -1)
        {
            StringList objectIdList = FrameworkUtil.split(objectId, "|");
            if (objectIdList.size() == 3) //objectIdList.size() will be 3 for root node
            {
               objectId = (String)objectIdList.get(0);
               parentId = (String)objectIdList.get(1);
            }
            else
            {
                parentId = (String)objectIdList.get(1);
            }
        }
}

String timestamp = emxGetParameter(request, "timeStamp");
String refreshFrame = emxGetParameter(request, "refreshFrame");

String lang = request.getHeader("Accept-Language");
Boolean differentFolder=false;
    
    //remove session data if the template is being instantiated
    // in parent folder
    if(objectId==null&&parentId==null)
    {
        session.removeAttribute("TargetFolder");
    }
    // set session data if the template is being instantiated 
    // in diffrent folder!
    
    //added and modified for Template enhancements <Release R2012>
    String strMode = emxGetParameter(request, "mode");
    String optType = emxGetParameter(request, "optionType");
    if (optType == null || optType.length() == 0) 
        optType = "viewableFields";
    if ( objectId == null || objectId.length() == 0 )
    {
        String[] sRowIds = 
            emxGetParameterValues(request, "emxTableRowId");
        
        if ( sRowIds != null && sRowIds.length >= 1 )
            objectId = sRowIds[0];

        objectId = objectId.replaceFirst("^.*?\\|", "" );
        objectId = objectId.replaceFirst("\\|.*", "" );
}

    // check for the template type 
    DomainObject objType = DomainObject.newInstance(context, objectId);
    String type = objType.getType(context);
    if ("Simulation".equals(type))
    {
        String msg = SimulationUtil.getI18NString(context,
            "Error.Internal.PleaseSelectTemplateForInstantiation");
        emxNavErrorObject.addMessage(msg);
%>
<%@include file="../common/emxNavigatorBottomErrorInclude.inc"%>
<%
    }
    // Got the objectId, lets show the table
    else
    {
        if(strMode.equalsIgnoreCase(SimulationConstants.TEMPLATE_MODE_INSTANTIATE) ||
            strMode.equalsIgnoreCase(SimulationConstants.TEMPLATE_MODE_INSTANTIATE_LITE) ||
            strMode.equalsIgnoreCase(SimulationConstants.TEMPLATE_MODE_INSTANTIATE_RUN) ||
            strMode.equalsIgnoreCase(SimulationConstants.TEMPLATE_MODE_INSTANTIATE_RUN_LITE))
        {
            try{
            Template templateObj = new Template(objectId);
            if(templateObj.isActivityBeingInstantiated(context)){
                    String msg = SimulationUtil.getI18NString(context,
                        "smaSimulationCentral.error.Template.InstantiateActivty");
                    %>
                    <script>
                    var errorMsg = "<%=msg%>";
                    alert(errorMsg);
                    getTopWindow().closeWindow();
                    </script>
                    <%
            }
        }catch(Exception e){
            throw e;
        }
        }
        String parentRowId = parentId;
        if ( parentRowId == null || parentRowId.length() == 0 )
            parentRowId = emxGetParameter(request, "emxTableRowId");
        
        // Get target folder information
        String defaultFolderId = "";
        
        // the objectId is the oid of the template being instantiated
        // when creating a process or an activity from
        // a template...we are in affect instantiating the 
        // template but the newly instantiated object is put into
        // the selected folder not the default folder
        // in this case the parentOID is the oid of the
        // target folder so use it.  
        // It will be empty if we used the
        // action icon to do the instantiation and will be the same
        // as the object id if we selected the template and used
        // the menu to do the instantiation and in that case need to
        // get the default target folder

        // If target folder defined, get the path information
        String path = "";
        if ( defaultFolderId != null && defaultFolderId.length() > 0 )
        {
            try
            {
                HashMap paramMap = new HashMap();
                HashMap programMap = new HashMap();

                paramMap.put("objectId", defaultFolderId );
                programMap.put("paramMap",paramMap);

                String[] args = JPO.packArgs(programMap);

                path = (String) JPO.invoke( context,
                        "jpo.simulation.SimulationContent", null,
                        "getFolderLocation", args, String.class);
                
                // getFolderLocation does not return the info for the
                // item passed in, just its parents so add item here.
                DomainObject DO = new DomainObject();
                DO.setId(defaultFolderId);

                String parentTitle = DO.getInfo(context, "attribute[Title]" );
                if ( parentTitle == null || parentTitle.length() == 0 )
                    parentTitle = DO.getInfo(context, "name" );
                
                path += " / " + parentTitle;
                
                path = SimulationUtil.getI18NString(context,
                    "smaSimulationCentral.CopyTarget" ) + ": " + path; 

            }
            catch (Exception e)
            {
                // Ignore path
            }
        }
        
        if(strMode.equalsIgnoreCase(SimulationConstants.TEMPLATE_MODE_INSTANTIATE_IN_ACTIVITY))
        {
            objectId = parentRowId;
        }

        StringBuffer href = new StringBuffer(256);
        href
            .append("../common/emxTableEdit.jsp")            
            .append("?objectId=").append(objectId)
            .append("&table=SMATemplate_Instantiate")
            //commented for Template enhancements <Release R2012> 
            //.append("&header=Template.Instantiate.PageHeading") 
            //.append("&editToolbar=SMATemplate_InstantiateToolbar")
            .append("&selection=none")
            .append("&HelpMarker=SMATemplate_NavTreeInstantiate")
            .append("&Export=false")
            .append("&PrinterFriendly=true")
            .append("&program=jpo.simulation.Template:getOptions")
            .append("&postProcessURL=../simulationcentral/smaInstantiateTemplateProcess.jsp")
            .append("&disableSorting=true")
            .append("&multiColumnSort=false")
            .append("&headerRepeat=0")
            .append("&objectBased=false")
            .append("&customize=false")
            .append("&findMxLink=false")
            .append("&pagination=0")
            .append("&massUpdate=false")
            .append("&suiteKey=SimulationCentral")
            .append("&origTimestamp=").append(timestamp)
            .append("&cancelProcessJPO=jpo.simulation.Template:cancelInstantiate")
            .append("&isPopup=true")
            .append("&stopOOTBRefresh=false")
            .append("&parentOID=").append(parentId)
            .append("&parentRowId=").append(parentRowId)
            .append("&refreshFrame=").append(refreshFrame);
        
        //added for Template enhancements <Release R2012> - Start
        if(strMode.equalsIgnoreCase(SimulationConstants.TEMPLATE_MODE_INSTANTIATE) ||
                strMode.equalsIgnoreCase(SimulationConstants.TEMPLATE_MODE_INSTANTIATE_IN_ACTIVITY))
        {
            href.append("&header=Template.Instantiate.PageHeading");
            href.append("&editToolbar=SMATemplate_InstantiateOnlyToolbar");
        }
        else if(strMode.equalsIgnoreCase(SimulationConstants.TEMPLATE_MODE_INSTANTIATE_LITE))
        {
            href.append("&header=Template.Instantiate.PageHeading");
            href.append("&editToolbar=SMATemplate_InstantiateLiteOnlyToolbar");
        }
        else if(strMode.equalsIgnoreCase(SimulationConstants.TEMPLATE_MODE_INSTANTIATE_RUN))
        {
            href.append("&header=Template.InstantiateRun.PageHeading"); 
            href.append("&editToolbar=SMATemplate_InstantiateRunToolbar");
        }
        else if(strMode.equalsIgnoreCase(SimulationConstants.TEMPLATE_MODE_INSTANTIATE_RUN_LITE))
        {
            href.append("&header=Template.InstantiateRun.PageHeading"); 
            href.append("&editToolbar=SMATemplate_InstantiateRunLiteToolbar");
        }
        href.append("&mode=").append(strMode);   
        href.append("&optionType=").append(optType);
        
        //added for Template enhancements <Release R2012> - End
        if ( path != null && path.length() > 0 )
            href.append("&subHeader=").append(path);
;
%>

<script>

        try
        {
            var hrefURL = "<%=href.toString()%>";

                getTopWindow().location.href = hrefURL;
        }
        catch(error)
        {
            console.log(error);
        }
        </script>
<%
}

%>



