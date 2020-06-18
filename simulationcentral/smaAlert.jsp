<%-- (c) Dassault Systemes, 2007, 2008 --%>

<%@page import = "com.matrixone.apps.domain.util.MqlUtil"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkUtil"%>

<html>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>


<%
    String alertString = "Internal Error: No Data Available";
    String objectAction = emxGetParameter(request, "objectAction");
    
    if ( alertString != null && alertString.length() > 0 )
    {
%>
        <script>
        var alertString = "";
<%
        alertString = alertString.replace("\t:", ":");
        StringList alertStr = FrameworkUtil.split(alertString,"\n");
        for ( int ii=0; ii<alertStr.size(); ii++ )
        {
            String str = (String) alertStr.get(ii);
            StringList SL = FrameworkUtil.split(str,"\t");
            if ( SL.size() >= 2 )
            {
                // Pad length of string to 25 chars so that we have
                // a chance of lining up the data in the popup
                String vault = (String)SL.get(0);
                int lengthDiff = 25 - vault.length();
                char[] spaces = new char[lengthDiff];
                java.util.Arrays.fill(spaces, ' ');
                vault = vault + new String(spaces);
                
                if ( "Complete".equalsIgnoreCase((String) SL.get(1)) )
                    str = vault + "\t" + (String)SL.get(2);
                else
                    str = vault + "\t" + (String)SL.get(1);
            }
%>
            alertString += '<%=str %>' + '\n';
<%
        }
%>
            alert(alertString);
        </script>
<%
    }
%>

