<%@ page import="com.matrixone.apps.domain.util.MqlUtil" %>
<%@ page import="java.util.StringTokenizer" %>
<%@ page import="com.dassault_systemes.vplmsecurity.PLMSecurityManager" %>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "emxPLMOnlineAdminAttributesCalculation.jsp"%>
<%@include file = "../common/emxPLMOnlineAdminAuthorize.jsp"%>
<%@include file= "../common/emxPLMOnlineIncludeStylesScript.inc"%>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
         </head>
    <body>   
    <%
        String requestAllSites = "list site";
        String resultAllSites = MqlUtil.mqlCommand(mainContext,requestAllSites);
        String[] allSites = resultAllSites.split("\n");

        String user = context.getUser();
        String resultSite = MqlUtil.mqlCommand(context,"print person $1 select $2 dump $3",user,"site","|");
		
        String site = (String)emxGetParameter(request,"Site");
        if(!resultSite.equals(site)) {
            %><script>alert("Modifying my site...")</script><%

            PLMSecurityManager sm = new PLMSecurityManager(context);
            sm.pushUserAgentContext();
            // JIC 13:02:25 IR IR-191605V6R2014: Replaced "mainContext" with "context" in MQL command execution 
            MqlUtil.mqlCommand(context, "modify person $1 site $2",user,site);
            sm.popUserAgentContext();
        }                
    %>
    <table width="100%" >
        <tr id="highRow" width="100%" style="overflow : auto">
            <td class="MatrixLabel" ></td>
            <td class="MatrixLabel" ><%=myNLS.getMessage("Location")%></td>
            <td class="MatrixLabel" ><%=myNLS.getMessage("Hidden")%></td>
            <td class="MatrixLabel" ><%=myNLS.getMessage("Modified")%></td>
            <td class="MatrixLabel"><%=myNLS.getMessage("Created")%></td>
            <td class="MatrixLabel" ><%=myNLS.getMessage("Encrypted")%></td>
            <td class="MatrixLabel" ><%=myNLS.getMessage("Compressed")%></td>
            <td class="MatrixLabel" ><%=myNLS.getMessage("Permission")%></td>
            <td class="MatrixLabel" ><%=myNLS.getMessage("Host")%></td>
            <td class="MatrixLabel" ><%=myNLS.getMessage("Path")%></td>
            <td class="MatrixLabel" ><%=myNLS.getMessage("Protocol")%></td>
        </tr>
        <%
		for (int i = 0 ; i < allSites.length ; i++ ) {
                String resultLocation = MqlUtil.mqlCommand(context,"print site $1 select $2 dump $3",allSites[i],"location","|");
                StringTokenizer tokenLocation = new StringTokenizer(resultLocation,"|");
                        while(tokenLocation.hasMoreTokens()) {
                            String s = tokenLocation.nextToken();
                            
                            String res = MqlUtil.mqlCommand(context,"print location $1 selectable ",s);
                            String[] finalRes = res.split("\n");                         
                           
                        %>
                        <tr >
                <%if (allSites[i].equals(site)){ %>
                           <td class="MatrixFeel"><img src="../common/images/iconStatusCheckmark.gif"></td>
                <%} else {%>
                           <td class="MatrixFeel"></td>
                <%}%>
                           <td class="MatrixFeel"><%=finalRes[1].split("=")[1]%></td>
                            <td class="MatrixFeel"><%=finalRes[3].split("=")[1]%></td>
                            <td class="MatrixFeel"><%=finalRes[5].split("=")[1]%></td>
                            <td class="MatrixFeel"><%=finalRes[6].split("=")[1]%></td>
                            <td class="MatrixFeel"><%=finalRes[8].split("=")[1]%></td>
                            <td class="MatrixFeel"><%=finalRes[9].split("=")[1]%></td>
                            <td class="MatrixFeel"><%=finalRes[10].split("=")[1]%></td>
                            <td class="MatrixFeel"><%=finalRes[11].split("=")[1]%></td>
                            <td class="MatrixFeel"><%=finalRes[12].split("=")[1]%></td>
                            <td class="MatrixFeel"><%=finalRes[13].split("=")[1]%></td>

                        </tr>      
                        <% }
            }%>   
                    </table>

    </body>
</html>
