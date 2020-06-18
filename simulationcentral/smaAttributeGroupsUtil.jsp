<%-- (c) Dassault Systemes, 2010 --%>
<%--
  Process commands on the Attribute Groups page.
--%>

<%@page import="com.dassault_systemes.smaslm.matrix.common.SimulationConstants"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkException"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkUtil"%>
<%@page import="com.matrixone.apps.framework.ui.UINavigatorUtil"%>
<%@page import="com.dassault_systemes.smaslm.common.util.StringUtil"%>
<%@page import="com.dassault_systemes.smaslm.matrix.web.ErrorUtil"%>
<%@page import="com.dassault_systemes.smaslm.matrix.web.SlmUIUtil"%>
<%@page import="com.dassault_systemes.smaslm.matrix.common.SimulationUtil"%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="matrix.db.Context"%>
<%@page import="matrix.util.MatrixException"%>
<%@page import="matrix.util.StringList"%>

<%@page import="java.util.Map"%>

<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>

<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../simulationcentral/smaWebUtil.inc"%>

<script type="text/javascript" src="../simulationcentral/smaStructureBrowser.js"></script>
<script type="text/javascript" src="../common/scripts/emxUIModal.js"></script>
<script type="text/javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>

<%
    // What is it that we want to do?
    // Possible objectAction values:
    //    assignAttributeGroups
    //    clearAttributeGroups
    //    removeAttributeGroups
    //    moveUp
    //    moveDown
    //    

    Map requestMap = UINavigatorUtil.getRequestParameterMap(pageContext);

    String objectAction = emxGetParameter(request, "objectAction");
    if ( (objectAction == null) || (objectAction.equals("")) )
    {
        emxNavErrorObject.addMessage("objectAction not found");
        objectAction = "";
    }
    else
    {
        // get an interned string ref for faster reference compares
        objectAction = objectAction.intern();
    }

    String objectId = null;
    String parentId = null;
    String[] relIds = null;
    String[] objIds = null;
    String[] parIds = null;
    int nObjs = 0;

    String rootParentId = emxGetParameter(request, "objectId");

    /////////////////
    // Get selected rows from the request map
    String[] sRowIds = emxGetParameterValues(request, "emxTableRowId");

    // sRowIds should never be null since these commands must have a
    // selection single/multiple setting and are thus caught 
    // by M1 if nothing is selected
    if ( (sRowIds == null) || (sRowIds.length == 0) )
    {
        if (objectAction != "assignAttributeGroups" &&
            objectAction != "clearAttributeGroups" && objectAction != "updateDefaultField")
        {
            emxNavErrorObject.addMessage(
                EnoviaResourceBundle.getProperty(context,"emxFrameworkStringResource",context.getLocale(),
                    "emxFramework.Common.PleaseSelectitem"));
        }
    }

    // Something was selected, get the object and parent ids
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

            if (objIds[i] == null &&
                objectAction == "assignAttributeGroups" ||
                objectAction == "removeAttributeGroups" ||
                objectAction == "moveUp" ||
                objectAction == "moveDown" )
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


    /////////////////
    // The following are all the commands that do NOT open a popup
    // window (not including the javascript prompt).  If popup is
    // not popped up, don't close it ;-)
    boolean isPopup = true;
    if (objectAction == "removeAttributeGroups" ||
        objectAction == "clearAttributeGroups"  ||
        objectAction == "moveUp"  ||
        objectAction == "moveDown"  )
    {
        isPopup = false;
    }

    /////////////////
    // Contains URL for action 
    URLBuilder contentURL = getURLBuilder(request);

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
            Boolean isUpdated = null;

            Map argsMap = new HashMap();
            argsMap.put("objectId", rootParentId);

            if (objectAction == "assignAttributeGroups")
            {
                argsMap.put("attributeGroupsOIDs", objIds);

                isUpdated = (Boolean) JPO.invoke(
                    context,
                    "jpo.simulation.AttributeGroup",
                    null,
                    "addAttributeGroups",
                    JPO.packArgs(argsMap),
                    Boolean.class);
            }
            else if (objectAction == "removeAttributeGroups")
            {
                argsMap.put("attributeGroupsOIDs", objIds);

                isUpdated = (Boolean) JPO.invoke(
                    context,
                    "jpo.simulation.AttributeGroup",
                    null,
                    "removeAttributeGroups",
                    JPO.packArgs(argsMap),
                    Boolean.class);
            }
            else if (objectAction == "clearAttributeGroups")
            {
                isUpdated = (Boolean) JPO.invoke(
                    context,
                    "jpo.simulation.AttributeGroup",
                    null,
                    "clearAttributeGroups",
                    JPO.packArgs(argsMap),
                    Boolean.class);
            }
            else if (objectAction == "moveUp" || 
                objectAction == "moveDown" )
            {
                String timeStamp = emxGetParameter(request, "timeStamp");
                Map tableData = (Map)tableBean.getTableData(timeStamp);
                argsMap.put("attributeGroupsOIDs", objIds);
                argsMap.put("objectAction", objectAction);
                argsMap.put("tableData", tableData);

                isUpdated = (Boolean) JPO.invoke(
                    context,
                    "jpo.simulation.AttributeGroup",
                    null,
                    "moveAttributeGroups",
                    JPO.packArgs(argsMap),
                    Boolean.class);
            }
            // Changes for Multivalue Attribute - x86
            else if (objectAction == "updateDefaultField")
            {
                isUpdated = true;
                String[] arrChoicesValues = emxGetParameterValues(request,"Choices");
                String defValue = null;
                String sNewLine = "\\n";
                for (int i=0; arrChoicesValues!= null && i<arrChoicesValues.length; i++)
                {
                    //Prepare the Default string value form the stringarray choices
                    if(arrChoicesValues[i] != null && !(("").equalsIgnoreCase(arrChoicesValues[i])))
                        {
                        if (defValue == null)
                        {
                        defValue = arrChoicesValues[i] + "\\n";
                        }
                        else
                        {
                            defValue += arrChoicesValues[i] + "\\n"; 
                        }
                        }
                }
                String fieldDef = emxGetParameter(request, "cellValue");
                String formOrg = emxGetParameter(request, "fName");
               %>
                <script language="javascript" type="text/javaScript">
                //<![CDATA[
                var frame2 = sbFindFrame(getTopWindow().getWindowOpener().getTopWindow(),"formEditDisplay");
                var sExistDefVal = frame2.document.editDataForm.<%=fieldDef%>.value;
                <%
                if (defValue != null)
                {
                %>
              //  If (sExistDefVal )//&& // Add the existing value along with the chosen default value
             frame2.document.editDataForm.<%=fieldDef%>.value = "<%=defValue%>";
                <%
                }
                %>
               getTopWindow().closeWindow();
                </script>
                <%
              return; 
            }
         // Changes for Multivalue Attribute ends here 
            if (Boolean.TRUE.equals(isUpdated)&& !(objectAction.equalsIgnoreCase("updateDefaultField")))
            {                String type =new DomainObject(rootParentId).getInfo(context, DomainObject.SELECT_TYPE);
                if(SimulationConstants.TYPE_SIMULATION_ACTIVITY.equals(type))
                    type= SimulationConstants.SYMBOLIC_type_SimulationActivity;
                else if("Simulation Document - NonVersioned".equals(type)||"Simulation Document - Versioned".equals(type))
                    type=SimulationConstants.SYMBOLIC_type_DOCUMENTS;
                else if("Simulation Template".equals(type))
                    type=SimulationConstants.SYMBOLIC_type_SimulationTemplate;
                
                if(type.equals(
                    SimulationConstants.SYMBOLIC_type_DOCUMENTS))
                    contentURL.append(getCommandHref(
                        context,
                        "SMADocument_NavTreeAttributeGroups",
                        rootParentId,
                        requestMap));
                else  if(type.equals(
                        SimulationConstants.SYMBOLIC_type_AnalyticsCase))
                        contentURL.append(getCommandHref(
                            context,
                            "SMAAdvise_NavTreeAttributeGroups",
                            rootParentId,
                            requestMap));
                else
                contentURL.append(getCommandHref(
                    context,
                    "SMACommon_NavTreeAttributeGroups",
                    rootParentId,
                    requestMap));

                contentURL.append("&categoryTreeName=");
                contentURL.append(type);

%>
<script type="text/javascript" src="../simulationcentral/smaGeneral.js"></script>
<script type="text/javascript" src="../simulationcentral/smaStructureBrowser.js"></script>
<script language="JavaScript">
    var curWindow = window;
    var contentFrame = null;

    while (contentFrame == null && curWindow != null)
    {
      contentFrame = sbFindFrame(curWindow.getTopWindow(), 'detailsDisplay');
      curWindow = curWindow.getTopWindow().getWindowOpener();
    }

    contentFrame.location.href = '<%= contentURL.toString() %>';

<% if (objectAction == "assignAttributeGroups") { %>
    if (getTopWindow().getWindowOpener())
    {
        getTopWindow().closeWindow();
    }
<% } %>
</script>
<%
                return;
            }
            else if (objectAction.equalsIgnoreCase("updateDefaultField"))
            {
            }
            else
            {
                emxNavErrorObject.addMessage(
                    SimulationUtil.getI18NString(context,
                        "smaSimulationCentral.AttributeGroups.updateAttributeGroup.failed"));
            }
        }
        else
        {
             emxNavErrorObject.addMessage(objectAction + " not yet Implemented");
        }
    }
    catch (Exception ex)
    {
        emxNavErrorObject.addMessage(ErrorUtil.getMessage(ex, false));
    }

    
    // Check for error
    String errorMsg = emxNavErrorObject.toString().trim();
    if (errorMsg == null  ||  errorMsg.length() == 0)
    {
        if (cmdExpected
            && (contentURL == null  ||  contentURL.length() == 0))
        {
            errorMsg = "smaAttributeGroupUtil: Internal Error: no command to forward to.";
        }
    }
        
    if ( errorMsg != null && errorMsg.length() > 0 )
    {
        returnAction = "error";
        returnMsg = errorMsg;

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
        if ( isPopup )
        {
           if (objectAction.equalsIgnoreCase("assignAttributeGroups"))
           {
%>
                <script language="javascript">      
                  alert("<%= returnMsg%>");
                  getTopWindow().setTableSubmitAction(true);
                </script>
<%
           }
           else
           {
	           returnMsg =XSSUtil.encodeForURL(context,returnMsg);
	            
	           contentURL
	                .append( "../simulationcentral/smaStructureBrowserUtil.jsp")
	                .append("?action=").append(returnAction)
	                .append("&message=").append(returnMsg);
%>
	          <script language="javascript">
	              getTopWindow().location.href = "<%=contentURL.toString()%>";
	          </script>
<%           }
        }
        else
        {
            out.clear();

            contentURL.
                append( "../simulationcentral/smaStructureBrowserUtil.jsp").
                append("?action=").append(returnAction).
                append("&message=").append(returnMsg);
%>

    <script type="text/javascript" src="../simulationcentral/smaStructureBrowser.js"></script>
    <script language="javascript">
        // Find lsitHidden frame
        var frame = null;
        if ( getTopWindow().getWindowOpener() )
            frame = sbFindFrame(getTopWindow().getWindowOpener().getTopWindow(),"listHidden");
        else
            frame = sbFindFrame(getTopWindow(),"listHidden");

        frame.location.href = "<%= contentURL.toString()%>";
    </script>
<%
        }
    }

    // No Errors!!!
    else
    {
        // If action opened a popup window, use it
        if (isPopup)
        {
            if (contentURL.toString().indexOf("suiteKey") == -1)
            {
                contentURL.append(
                    contentURL.toString().indexOf("?") == -1 ? "?" : "&");
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
%>
            <script language="javascript">
                getTopWindow().location.href = "<%=contentURL.toString()%>";
            </script>
<%
        }
        // Return appropriate code for commands that don't open a window
        else
        {
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

    return cmdChecksOK;
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
%>
