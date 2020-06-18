<%@include file = "../common/emxNavigatorInclude.inc"%>

<%@ page import="com.dassault_systemes.smaslm.matrix.web.Parameters" %>
<%@ page import="com.dassault_systemes.smaslm.matrix.web.SlmUIUtil" %>

<%@ page import="java.net.URI" %>

<%
final String ENOVIA_STD_PAGE_PATH = "../common/emxTree.jsp";
final String SIMULATION_HOME_PAGE_PATH = "../simulationcentral/smaHomeFS.jsp";

String forwardPath = ENOVIA_STD_PAGE_PATH;

Boolean goToSimHome =
    (Boolean) JPO.invoke(context,
                         "jpo.simulation.SimulationContent",
                         null,
                         "isSlmUser",
                         (String[]) null,
                         Boolean.class);
if (goToSimHome.booleanValue())
{
    goToSimHome = 
        (Boolean) JPO.invoke(context,
            "jpo.simulation.SimulationContent",
            null,
            "isObjectHandledByHomePage",
            getObjectIds(request),
            Boolean.class);
    
    if (goToSimHome.booleanValue())
    {
        forwardPath = SIMULATION_HOME_PAGE_PATH;
    }
}

URI uri = new URI(request.getRequestURL().toString());
uri = uri.resolve(forwardPath);

StringBuilder requestUrl = new StringBuilder(uri.toString());

if (request.getQueryString() != null)
{
    requestUrl.append('?').
        append(request.getQueryString());
}
%>
<html>
    <body>

        <jsp:include page="../simulationcentral/smaPreserveParamsForm.jsp">
            <jsp:param name="smaPreserveParamsFormAction" value="<%= requestUrl.toString() %>"/>
            <jsp:param name="smaPreserveParamsIncludeQueryParams" value="false"/>
        </jsp:include>

    </body>
</html>

<%!
private String[] getObjectIds(HttpServletRequest request)
{
    String[] objectIds = null;
    
    String objectId = emxGetParameter(request, "objectId");
    if (objectId != null)
    {
        objectIds = new String[] {objectId};
    }
    else
    {
        String[] rowIds = emxGetParameterValues(request, "emxTableRowId");
        if (rowIds != null && rowIds.length != 0)
        {
            objectIds = new String[rowIds.length];

            for (int i = 0; i < rowIds.length; ++i)
            {
                objectIds[i] = rowIds[i].split("\\|")[1];
            }
        }
    }

    return objectIds;
}
%>
