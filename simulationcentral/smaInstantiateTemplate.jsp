<%-- (c) Dassault Systemes, 2007, 2008 --%>
<%--
  Process instantiate template commands.
--%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="java.util.HashMap"%>
<%@page import="java.util.Map"%>
<%@page
    import="com.dassault_systemes.smaslm.matrix.common.SimulationUtil"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page
    import="com.dassault_systemes.smaslm.matrix.common.SimulationConstants"%>
<%@page import="com.dassault_systemes.smaslm.matrix.server.Template"%>

<%@page import="matrix.util.StringList"%>
<%@include file="../common/emxNavigatorInclude.inc"%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>

<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script type="text/javascript"
    src="../simulationcentral/smaStructureNavigator.js"></script>
<script type="text/javascript" src="../common/scripts/emxUIModal.js"></script>

<!-- Used to load "findFrame" -->
<script type="text/javascript" src="../common/scripts/emxUIConstants.js"></script>
<%
String objectId  = emxGetParameter(request, "objectId");
String parentId  = emxGetParameter(request, "parentOID");
String drms = emxGetParameter(request, "drms");

//Added code to show alert when user tries to instantiate template in Obsolete state.
DomainObject doObj = new DomainObject(objectId);
String templateStateString = doObj.getInfo(context, DomainObject.SELECT_CURRENT);
if(templateStateString.equalsIgnoreCase("obsolete")){
	%>
	 <script>
     var warningMsg = "Template is in Obsolete state.";
     alert(warningMsg);     
     </script>
     <%
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
    if((objectId!=null&&parentId!=null)||(objectId!=" "&&parentId!=" "))
    {
        differentFolder=true;
        if(!objectId.equals(parentId) && parentId!=null && !"".equals(parentId))
        {
            session.setAttribute("TargetFolder",parentId); 
        }
    }
    //added and modified for Template enhancements <Release R2012>
    String strMode = emxGetParameter(request, "mode");
    String optType = emxGetParameter(request, "optionType");
    String showApply = emxGetParameter(request, "showApply");
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

    // Should only happen via internal errors
    if ( objectId == null || objectId.length() == 0 )
    {
        String msg = SimulationUtil.getI18NString(context,
            "Error.Internal.NoSelection");
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
        String parentRowId = emxGetParameter(request, "parentRowId");
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

        if (parentId == null || parentId.length() == 0 ||
            parentId.equals(objectId))
        {
            if(differentFolder)
            {
                    //retrieve session data to get target folder info 
                    //while changing instantiation fields
                    String temp=(String)session.getAttribute("TargetFolder");
                    defaultFolderId = temp;
                    parentId=temp;
               
            }
            else{
                try
                {
                    defaultFolderId = (String) JPO.invoke( context,
                        "jpo.simulation.SimulationUI", null,
                        "getWorkingFolderOID", null, String.class);
                }
                catch (Exception e)
                {
                    // No default folder found
                }  
            }
        }
        else
            defaultFolderId = parentId;
        
        //if nothing works set target as umanaged simulations
        // or the folder containing template
        if(defaultFolderId==null&&parentId==null)
        {
            defaultFolderId = "";
            parentId=objectId;
        }
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
                    "smaSimulationCentral.CopyTarget") + ": " + path; 

            }
            catch (Exception e)
            {
                // Ignore path
            }
        }
        
        if(strMode.equalsIgnoreCase(SimulationConstants.TEMPLATE_MODE_INSTANTIATE_IN_ACTIVITY))
            objectId = parentRowId;

        StringBuffer href = new StringBuffer(256);
        href
            .append("../common/emxTableEdit.jsp")            
            .append("?objectId=").append(objectId)
            .append("&table=SMATemplate_Instantiate")
            .append("&selection=none")
            .append("&HelpMarker=SMATemplate_NavTreeInstantiate")
            .append("&Export=false")
            .append("&PrinterFriendly=true")
            .append("&program=jpo.simulation.Template:getOptions")
            .append("&preProcessJPO=jpo.simulation.Template:preInstantiate")
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
            .append("&refreshFrame=").append(refreshFrame)
            .append("&drms=").append(drms);
        
        if(showApply!=null && showApply.equalsIgnoreCase("true"))
            href.append("&showApply=true");
        
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
            var contentframe = findFrame(getTopWindow(),"content");
            if(contentframe!=null)
            	{
                  contentframe.location.href = hrefURL;
            	}else{
            		getTopWindow().location.href = hrefURL;
            	}
                        
        }
        catch(error)
        {
            console.log(error);
        }
        </script>
<%
}
%>

