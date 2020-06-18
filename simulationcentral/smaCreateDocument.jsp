<%-- (c) Dassault Systemes, 2007, 2008 --%>
<%--
   Performs prechecks for creating a Document within a Simulation:

   - verify that a folder is selected.
--%>

<%-- Common Includes --%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>

<%@page import = "com.matrixone.apps.domain.DomainConstants" %>
<%@page import = "com.matrixone.apps.domain.DomainObject"%>
<%@page import = "com.matrixone.apps.domain.util.FrameworkException"%>
<%@page import = "com.matrixone.apps.framework.ui.UINavigatorUtil"%>
<%@page import = "com.dassault_systemes.smaslm.matrix.common.AccessUtil"%>
<%@page import = "com.dassault_systemes.smaslm.matrix.common.SimulationConstants"%>
<%@page import = "com.dassault_systemes.smaslm.matrix.common.SimulationUtil"%>
<%@page import = "com.dassault_systemes.smaslm.matrix.web.ErrorUtil"%>
<%@page import = "matrix.db.User"%>
<%@page import = "java.util.List"%>
<%@page import = "java.util.StringTokenizer"%>
<%@page import="com.matrixone.apps.domain.DomainSymbolicConstants" %>

<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript" src="../common/scripts/emxUITableUtil.js"></script>


<!--  <html> and <head> were added by something above here.   -->
</head>
<body>

<%	
	String rel        = "relationship_VaultedDocuments";
    final String locale = context.getSession().getLanguage();

    // ID of the sim category or folder to create a relationship to
    // after the document has been created.  Will be null if creating 
    // doc from global actions menu.
    String parentID = emxGetParameter(request, "parentOID");

    // If emxTableRowId is not null, then this jsp was called from 
    // the content page (or actually from a page with an emxTable 
    // or emxIndentedTable). If this is the case then the document 
    // must be created within a folder or category.

    // Get the ID of the folder/category.
    String sRowIds[] = request.getParameterValues("emxTableRowId");
    if ( sRowIds != null )
    {
        // Only a single thing should be selected however to be safe
        // make sure 
        if ( sRowIds.length == 1 )
        {
            // If called from emxTable, the row ids are
            //   <connection id>|<selected object id>
            // If called from an emxIndentedTable, the row ids are:
            //   <conection id>|<selected object id>|<parent object id>|<indented table ordering tag>
            // In either case, pull out the <selected object id>.
            parentID = sRowIds[0];
            if ( parentID != null && parentID.indexOf('|') > -1 )
            {
                String objectId = parentID;
                int pos1 = objectId.indexOf('|');
                pos1 += 1;
                int pos2 = objectId.indexOf('|', pos1);
                if (pos2 == -1)
                {
                    pos2 = objectId.length();
                }
                parentID = objectId.substring(pos1, pos2);
            }
        }
        // This should never happen since the command is only available
        // when a single something is selected
        else
        {
            String msg = SimulationUtil.getI18NString(context,
                "Error.CreateDoc.SelectOne" );
            emxNavErrorObject.addMessage(msg);
        }

    } //     if ( sRowIds != null )

    try
    {
        if ( parentID != null )
        {
            DomainObject parentDO = new DomainObject();
            parentDO.setId(parentID);

            if(parentDO.isKindOf(
                    context, SimulationUtil.getSchemaProperty(
                        SimulationConstants.
                            SYMBOLIC_type_SimulationFolders)))
			{
					rel = "relationship_SimulationContent_Owned";
			}
            // Got a parent ID, make sure it is a sim folder or a 
            // workspace folder
            if (! parentDO.isKindOf(
                context, SimulationUtil.getSchemaProperty(
                    SimulationConstants.
                        SYMBOLIC_type_SimulationFolders)) &&
                ! parentDO.isKindOf(
                context, SimulationUtil.getSchemaProperty(
                    DomainSymbolicConstants.
                        SYMBOLIC_type_ProjectVault)))
            {
                String errMsg = SimulationUtil.getI18NString(context,
                "smaSimulationCentral.Content.ErrMsg.selectednotfolder");
                emxNavErrorObject.addMessage(errMsg);

                parentID = null;
            }

            // Make sure parent object is not locked.
            if ( parentID != null &&
                 AccessUtil.isLocked( context, parentDO, true ) )
            {
                String objName = parentDO.getInfo(
                    context, DomainConstants.SELECT_LOCKER);
        
                String msg1 = SimulationUtil.getI18NString(context,
                "smaSimulationCentral.Content.ErrMsg.cannotdooperation");
                String msg2 = SimulationUtil.getI18NString(context,
                "smaSimulationCentral.Content.ErrMsg.selectedislocked");

                String msg3 = msg1 + " " + 
                    StringResource.format(msg2, "P1", objName);
                emxNavErrorObject.addMessage(msg3);
    
                parentID = null;
            }

            // Access parent needs to create/connect document
            String reqAccess = "modify,fromconnect";

            if ( parentID != null &&
                 ! AccessUtil.hasAccess(context, parentDO, reqAccess) )
            {
                String objName = parentDO.getInfo(
                    context, DomainConstants.SELECT_NAME);
    
                String ptype = 
                    parentDO.getInfo(context, 
                        DomainObject.SELECT_TYPE);
                ptype = 
                    UINavigatorUtil.getAdminI18NString(
                        "Type", ptype, locale);

                String errMsg1 = 
                    SimulationUtil.getI18NString(context,
                        "ErrMsg.Content.noaccessParent", 
                        "OBJNAME", objName, "PTYPE", ptype);
                emxNavErrorObject.addMessage(errMsg1);

                parentID = null;
            }
        }
    }
    catch (FrameworkException fe)
    {
        emxNavErrorObject.addMessage(ErrorUtil.getMessage(fe));
        parentID = null;
    }

    // If no errors so far then call code to create doc
    // NOTE THAT PARENTID MAY BE NULL IF CREATING FROM THE GLOBAL MENU
    String sErrMsg = emxNavErrorObject.toString();
    if ( sErrMsg == null || sErrMsg.trim().length() == 0 )
    {
        // Clear session variable because M1 doesn't on cancel - old
        // values then hang around
        session.removeAttribute("emxCommonDocumentCheckinData");
%>
        <form name="application"  
              action="../components/emxCommonDocumentPreCheckin.jsp" >
          <input type="hidden" name="objectId" value="<%=parentID%>">
          <input type="hidden" name="parentRelName" value="<%=rel%>">
<%
        // Loop through the request elements and add them to the URL
        Enumeration enumParam = request.getParameterNames();
        while (enumParam.hasMoreElements())
        {
            String name = (String) enumParam.nextElement();
            if (name.equals("objectId") || name.equals("RequestValuesMap") )
                continue;
            String value = emxGetParameter(request, name);
%>
            <input type="hidden" name="<%= name %>" value="<%=value %>">
<%
        }
%>
            <input type="hidden" name="appDir" value="simulationcentral">
<%
			if(sRowIds==null){
%>
            <input type="hidden" name="appProcessPage" value="smaCreateDocumentUtil.jsp">
<%
			}else{
%>
			<input type="hidden" name="appProcessPage" value="smaCreateDocumentUtil.jsp?emxTableRowId=<%=sRowIds[0] %>">
<%
			}
%>
        </form>
        <script>
            document.application.submit();
        </script>
<%
    }
    else
    {
        // Display error message.
%>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
        // the above include will cause the display of an alert 
        // message. The following will kill the popup window once
        // the alert message is dismissed.
        <script>
            getTopWindow().closeWindow();
        </script>
<%
    }
%>

</body>
</html>
