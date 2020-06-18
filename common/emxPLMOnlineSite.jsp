<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxPLMOnlineIncludeStylesScript.inc"%>
<%@include file = "../common/emxPLMOnlineAdminAttributesCalculation.jsp"%>
<%@include file = "../common/emxPLMOnlineAdminAuthorize.jsp"%>
<%@ page import="com.matrixone.apps.domain.util.MqlUtil" %>
<%@ page import="java.net.URLEncoder" %>

<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <script>
            function changeContent(){
                var index = document.getElementById('selectSite').selectedIndex;
                var value = document.getElementById('selectSite').options[index].innerHTML;
                document.getElementById('tableFrame').src = "emxPLMOnlineSiteMQL.jsp?Site="+encodeURIComponent(value);
            }
        </script>
    </head>
    <body>
    <%
        String requestAllSites = "list site";
        String resultAllSites = MqlUtil.mqlCommand(mainContext,requestAllSites);

        if( (resultAllSites.indexOf("Error")!= -1) || (resultAllSites == null) || (resultAllSites.equals("")) ){
        %>
            <div class="headerVPLM" style="height : 5%">
                <img src="../common/images/iconSmallSite.gif"> <%=myNLS.getMessage("ERROR_NoSiteFound")%>
            </div>
        <%}
            else{
                String[] allSites = resultAllSites.split("\n");
                String result = MqlUtil.mqlCommand(mainContext,"print person $1 select $2 dump $3",mainContext.getUser(),"site","|");
        %>
                <div class="headerVPLM" style="height : 5%">
                    <img src="../common/images/iconSmallSite.gif"> <%=getNLS("Site")%>
                    <select id="selectSite" style="color :#990000 ; font-weight: bold; font-size: 8pt; font-family: Arial, Helvetica, Sans-Serif; letter-spacing: 1pt;" onchange="javascript:changeContent();">
                        <option><%
                            for (int i = 0 ; i < allSites.length ; i++ ) {
                                if (allSites[i].equals(result)){
                                    %><option selected><%=allSites[i]%><%
                                }else{
                                    %><option><%=allSites[i]%><%
                                }
                            }
                            String target = "emxPLMOnlineSiteMQL.jsp?Site="+URLEncoder.encode(result,"UTF-8");%>
                    </select>
                <hr>
                </div>
                <div style="height:85%">
                <iframe id="tableFrame" src="<%=target%>"  style=" margin-top: 4% ; border: 0px" width="100%" height="90%">
                </iframe>
           </div>
           <%}%>
          
           <script>
             addFooter("","","");
            </script>
        </body>
</html>
