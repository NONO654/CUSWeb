<%-- (c) Dassault Systemes, 2007, 2008 --%>
<%--
  Utility to return xml string to structure browser.  This is called
  after creating a new folder
--%>

<%@include file = "../common/emxNavigatorInclude.inc"%>

<%@page import = "com.dassault_systemes.smaslm.matrix.web.StructureBrowserUtil"%>
<%@page import = "com.dassault_systemes.smaslm.matrix.web.ErrorUtil"%>
<%@page import = "matrix.util.StringList"%>

<!-- Used to load "findFrame" --> 
<script type="text/javascript" src="../common/scripts/emxUIConstants.js"></script>
<script type="text/javascript" src="../simulationcentral/smaStructureBrowser.js"></script>

<% 
    String action = "add";
    String message = "";
    String[] parentRowIds = emxGetParameterValues(request,"emxTableRowId");
    String isSlidein = emxGetParameter(request, "isSlidein");
    
    matrix.db.Context context2 = 
        (matrix.db.Context)request.getAttribute("context");
    if (context2 != null)
        context = context2;
    
    String parentId   = emxGetParameter(request,"objectId");
    String folderName = emxGetParameter(request,"Name");
    String folderDesc = emxGetParameter(request,"Description");
    String refreshFrame = emxGetParameter(request, "refreshFrame");
    
    String[] args = new String[]{parentId, folderName, folderDesc};

    StringList folderData = new StringList();
    try
    {
        // Create the folder and return the IDs
        folderData = (StringList)JPO.invoke(context, 
            "jpo.simulation.SimulationUI", null,
                "createFolder", args, StringList.class);
    }
    catch (Exception ex)
    {
        action = "error";
        message = ErrorUtil.getMessage(ex);
        folderData.setSize(0);
    }
    
    // Convert parent ID and added content to an appropriate javascript
    // code that either adds the entities or displays an error message.
    String sXML = StructureBrowserUtil.convertToXMLString(
        context, action, message, parentRowIds[0], folderData, 
            refreshFrame, true );
%>
    <%= sXML %>

<%
if ("true".equals(isSlidein))
{
    %>
    <script language="JavaScript">
    getTopWindow().closeSlideInDialog();
    </script>
    <%
}
%>









