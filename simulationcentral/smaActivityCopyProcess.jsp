<%-- (c) Dassault Systemes, 2007, 2008 --%>
<%--
  Process various SLM commands on the "My *" pages.
--%>

<%-- Common Includes --%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>

<%@page import = "com.matrixone.apps.domain.util.MapList"%>
<%@page import = "com.matrixone.apps.domain.DomainObject"%>
<%@page import = "java.util.List"%>
<%@page import = "java.util.HashMap"%>
<%@page import = "java.util.Map"%>
<%@page import = "java.util.StringTokenizer"%>
<%@page import = "matrix.db.JPO"%>
<%@page import = "matrix.db.BusinessObject"%>
<%@page import = "matrix.db.Attribute"%>

<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUITableUtil.js"></script>
<script language="Javascript" src="../common/scripts/emxUITreeUtil.js"></script>
<script language="Javascript" src="../common/scripts/emxUICoreTree.js"></script>
<script language="Javascript" src="../common/scripts/emxUIHistoryTree.js"></script>
<script language="Javascript" src="../common/scripts/emxUIDetailsTree.js"></script>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>

<!--  <html> and <head> were added by something above here.   -->

<%
    String strObjId = emxGetParameter(request, "objectId");
    String suiteKey = emxGetParameter(request, "suiteKey");
    String parentSAOID = emxGetParameter(request, "parentOID");

    HashMap paramMap = new HashMap();
    HashMap programMap = new HashMap();

    Enumeration prms = request.getParameterNames();
    while (prms.hasMoreElements())
    {
        String name = (String) prms.nextElement();
        String value = emxGetParameter(request, name);
        paramMap.put(name,value);
    }

    programMap.put("paramMap",paramMap);

    String[] args = JPO.packArgs(programMap);
    
    String newID = (String)JPO.invoke(context, "jpo.simulation.SimulationUI", null,
        "postCopy", args, String.class);
    
    // If successful, the update the nav tree
    if ( newID != null && newID.length() > 0 )
    {
        // We need the object id to be that of the parent sim
        programMap.put("objectId", parentSAOID);
        args = JPO.packArgs(programMap);
    
        // Get new list of activities to update tree with
        MapList ML = (MapList)JPO.invoke(context, "jpo.simulation.Simulation", null,
            "getActivities", args, MapList.class);
    
        String sActivityIDs = "";
    
        // Put the returned object ids of the contained
        // activities into a comma delimited string for use
        // in the javascript below
        for ( int ii=0; ii<ML.size(); ii++ )
        {
            Map HM = (Map)ML.get(ii);
            sActivityIDs += ",\"" + HM.get("id") + "\"";
        }
    
        if ( sActivityIDs.startsWith(",") )
            sActivityIDs = sActivityIDs.substring(1);
    
        String appDir = "SimulationCentral";
        
        String strURL = "";
        String strIcon = "";
        String strExpandURL = "";
        String strObjectId = newID;
        String strRelId = "";
        String strLabel = "";

        try
        {
            BusinessObject newBO = new BusinessObject(newID);
            
            Attribute attr = newBO.getAttributeValues(context, "Title");
            strLabel = attr.getValue();
            // strIcon = (String)newBO.getIcon(context);
        }
        catch (Exception e)
        {}
%>
<body>
    <script type="text/javascript">//<![CDATA[
    <!-- hide Javascript from non-Javascript browsers
function smaActivityUIObjectNode(strIcon, strText, strURL, strObjectID, strRelID, strCommandName, strExpandURL) {
        this.superclass = emxUIObjectNode;
        this.superclass(strIcon, strText, strURL, strObjectID, strRelID, strCommandName, strExpandURL);
        delete this.superclass;
        this.className = "smaActivityUIObjectNode";
} 


        // Array containing object ids of activities to
        // remove and then replace in the tree
        var IDnew = "<%=newID %>";
        var objectIds = new Array(<%=sActivityIDs%>);
        var tree = getTopWindow().getWindowOpener().getTopWindow().objDetailsTree;
        var parentObj = tree.getSelectedNode();
        
//        parentObj.collapse();
        parentObj.expanded = false;
        parentObj.loaded = false;
        tree.draw();
//        parentObj.expand();

//        // Create entity to save the parent's children in
//        var saveTheChildren = new emxUICategoryNode( 
//            parentObj.getName(), 
//            parentObj.getURL(), 
//            parentObj.objectID, 
//            parentObj.relID, 
//            parentObj.commandName, 
//            parentObj.loadURL);
//
//        // Save parent's children
//        for ( var ii=0; ii<parentObj.childNodes.length; ii++ )
//        {
//            var len = saveTheChildren.childNodes.length;
//            saveTheChildren.childNodes[len] = parentObj.childNodes[ii];
//        }
//        
//        // Kill the kids
//        for ( var ii=0; ii<parentObj.childNodes.length; ii++ )
//        {
//            var obj = parentObj.removeChildByID(parentObj.childNodes[ii].nodeID,false);
//        }

//        for ( var ii=0; ii<objectIds.length; ii++ )
//        {
//            var ID = objectIds[ii];
//            if ( ID != undefined && ID != IDnew )
//            {
//                var obj = parentObj.removeChildByID(ID,false);
//            }
//        }

        // Create new node for new entity
//        var newObjNode = smaActivityUIObjectNode(null, "<%=strLabel%>", "", IDnew, "", "", "");
//
//        // Add new entity to others
//        saveTheChildren.addCloneChild(newObjNode);

        // Loop through saved children, adding back to parent
        // NOTE THIS SHOULD FOLLOW OBJECTIDS ORDER        
//        for ( var ii=0; ii<saveTheChildren.childNodes.length; ii++ )
//        {
////            parentObj.childNodes[ii] = saveTheChildren.childNodes[ii];
//            parentObj.addCloneChild(saveTheChildren.childNodes[ii]);
//        }
        
//        // Set status indicators and refresh the display
//        parentObj.expanded = true;
//        parentObj.loaded = true;
//        tree.refresh(false);
        
        var now = new Date();
        var startTime = now.getTime();
        var endTime = now.getTime();

        while ( endTime - startTime < 1100 )
        {
            now = new Date();
            endTime = now.getTime();
        }

//Stop Hiding here -->//]]>
    </script>
<%
	}
%>

</body>

</html>
</html>
