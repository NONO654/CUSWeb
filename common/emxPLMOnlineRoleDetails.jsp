<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../emxTagLibInclude.inc"%>
<%@include file = "../common/emxPLMOnlineAdminAuthorize.jsp"%>
<html>
    <head>
	<link rel=stylesheet type="text/css" href="styles/emxUIDOMLayout.css">
          <link rel=stylesheet type="text/css" href="styles/emxUIDefault.css">
        <link rel=stylesheet type="text/css" href="styles/emxUIPlmOnline.css">
        <script src="scripts/emxUIAdminConsoleUtil.js" type="text/javascript"></script>
    </head>
    <body>
    <%
        String Role = emxGetParameter(request,"name");
    %>
        <script>
            var xmlreqs = new Array();
            
		initAjaxCall("Role","VPM","Profile","Query","<%=Role%>",formatResponse,0);
           
            function formatResponse()
            {
                var xmlhttp = xmlreqs[0];

                xmlhttp.onreadystatechange=function()
                {
                    if(xmlhttp.readyState==4)
                    {
                        var Description="";
                        var Parent ="";
                        var child="";
                        var plmid = xmlhttp.responseXML.getElementsByTagName("PLM_ExternalID")[0].firstChild.data;
                       
                        if (xmlhttp.responseXML.getElementsByTagName("V_id")[0].firstChild != null){
                            Description = xmlhttp.responseXML.getElementsByTagName("V_id")[0].firstChild.data;
                        }
                        if (xmlhttp.responseXML.getElementsByTagName("Role_Parent")[0].firstChild != null){
                            Parent = xmlhttp.responseXML.getElementsByTagName("Role_Parent")[0].firstChild.data;
                        }

                        var child = xmlhttp.responseXML.getElementsByTagName("child");
                        var children ="";
                        if (child != null){
                            for (var i = 0; i < child.length ; i++ ) {
                                children = children + child[i].firstChild.data + "," ;
                            }
                        }
                        document.getElementById("imageWaiting").style.display = 'none';
                        var target =  "emxPLMOnlineForm.jsp?type=Role&plmid="+plmid+"&child="+children+"&description="+Description+"&parent="+Parent;
                        document.getElementById("targetPage").src=target;
                    }
                }
            }
        </script>
        <script>
        addHeader("images/iconSmallRole.gif","<%=Role%>");
        addMiddle("targetPage","","images/iconParamProgress.gif");
       </script>
    </body>
</html>
