<%-- (c) Dassault Systemes, 2007, 2008 --%>
<%--
  Adds the selected Categories to the parent Simulation or Activity.
--%>

<%@include file = "../common/emxNavigatorInclude.inc"%>

<%@page import = "com.dassault_systemes.smaslm.matrix.web.StructureBrowserUtil"%>
<%@page import = "com.dassault_systemes.smaslm.matrix.web.ErrorUtil"%>
<%@page import="matrix.util.StringList"%>

<script type="text/javascript" src="../simulationcentral/smaStructureBrowser.js"></script>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>

<% 
    String action = "add";
    String message = "";

    String parentId   = emxGetParameter(request,"objectId");
    String categories = emxGetParameter(request,"categories");
    String refreshFrame = emxGetParameter(request, "refreshFrame");

    // Since the root may or may not be selected, we must fake it out
    // so it thinks it is selected.
    String parentRowId = "|" + parentId + "||0";

    // Add the parent and all select categories to the args list
    String[] cats = categories.split(",");
    String[] args = new String[cats.length+1];
    
    args[0] = parentId;

    for ( int ii=1; ii<=cats.length; ii++ )
        args[ii] = cats[ii-1];

    StringList categoryData = new StringList();
    try
    {
        // Let's create the categories
        categoryData = (StringList)JPO.invoke(context, 
            "jpo.simulation.SIMULATIONS", null,
                "createCategories", args, StringList.class);
    }
    catch (Exception ex)
    {
        action = "error";
        message = ErrorUtil.getMessage(ex);
        categoryData.setSize(0);
    }
    
    // Convert parent ID and added content to an appropriate javascript
    // code that either adds the entities or displays an error message.

    if ( refreshFrame == null )
    {
         refreshFrame = "detailsDisplay";
    }
    
    String sXML = StructureBrowserUtil.convertToXMLString(
        context, action, message, parentRowId, categoryData, 
            refreshFrame, true );
%>
    <%= sXML %>
    
