<%-- (c) Dassault Systemes, 2008 --%>

<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>

<%
    // This JSP is called from the Home page TOC title column when the
    // user clicks a link.  This link (via this JSP) causes the object
    // details navigation frame to load with the appropriate commands.

    String objectId = emxGetParameter(request, "objectId");
    StringBuilder URL = new StringBuilder("../simulationcentral/smaHomeContentHeader.jsp");
    URL.append("?objectId=").append(objectId);

    String lineageOids = emxGetParameter(request, "lineageOIDs");
    if (lineageOids == null || lineageOids.length() == 0)
    {
        lineageOids = objectId;
    }
    URL.append("&lineageOIDs=").append(lineageOids);

    String tocTableRowId = emxGetParameter(request, "emxTableRowId");
    if (tocTableRowId != null)
    {
        URL.append("&tocTableRowId=").append(tocTableRowId);
    }

    String timestamp = emxGetParameter(request, "timeStamp");
    if (timestamp != null)
    {
        URL.append("&tocTimeStamp=").append(timestamp);
    }
%>

<!-- Used to load "findFrame" --> 
<script type="text/javascript" src="../common/scripts/emxUIConstants.js"></script>

<script language="JavaScript">

    var frame = findFrame(getTopWindow(),"smaHomeHeader");
    
    if ( frame != null ) frame.location.href = "<%=URL.toString() %>";

</script>

