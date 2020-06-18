<%-- (c) Dassault Systemes, 2008 --%>
<%--
  Turns off the Simulation Home page progress indicator and forwards
  the parameters to the specified URL.
--%>

<%@ include file = "../common/emxNavigatorInclude.inc" %>
<%@ page import = "com.dassault_systemes.smaslm.matrix.web.Parameters" %>
<%@ page import = "com.matrixone.apps.framework.ui.UINavigatorUtil" %>

<html>
    <head>
        <script type="text/javascript" src="../common/scripts/emxUIConstants.js"></script>
		<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
        <script language="JavaScript">
            function pageLoaded()
            {
                try
                {
                var frame = findFrame(getTopWindow(), 'smaHomeTOCContent');

                if (frame != null)
                {
                    frame.turnOffProgress();
                }
    
                document.toSubmit.submit();
                }
                catch (E)
                {
                    alert(E.message);
                }
            }
        </script>
    </head>
    <body onload="pageLoaded();">
        <form name="toSubmit" action="../simulationcentral/smaReturnXML.jsp" method="post">
<%
// add the parameters to the form
for (Iterator iter = Parameters.getParameterList(request).iterator();
     iter.hasNext();)
{
    Parameters.Parameter param = (Parameters.Parameter) iter.next();
%>
            <%= getHiddenInput(param.getName(), param.getValue()) %>
<%
}
%>
      </form>
    </body>
</html>

<%!
private static String getHiddenInput(String name, String value)
{
    StringBuilder buf = new StringBuilder().
        append("<input type=\"hidden\"");

    if (name != null)
    {
        buf.append(" name=\"").
            append(UINavigatorUtil.htmlEncode(name)).
            append('\"');
    }
    
    if (value != null)
    {
        buf.append(" value=\"").
            append(UINavigatorUtil.htmlEncode(value)).
            append('\"');
    }
    
    return buf.append("/>").
        toString();
}
%>
