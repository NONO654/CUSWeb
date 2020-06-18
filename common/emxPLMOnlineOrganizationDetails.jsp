<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../emxTagLibInclude.inc"%>
<%@include file = "../common/emxPLMOnlineAdminAuthorize.jsp"%>
<head>
    <script src="scripts/emxUIAdminConsoleUtil.js" type="text/javascript"></script>
	<link rel=stylesheet type="text/css" href="styles/emxUIDOMLayout.css">
          <link rel=stylesheet type="text/css" href="styles/emxUIDefault.css">
    <link rel=stylesheet type="text/css" href="styles/emxUIPlmOnline.css"> 
</head>
<body>
    <%
      String Org = emxGetParameter(request,"name");
    %>
        <script>
            var xmlreqs = new Array();
            xmlreq("emxPLMOnlineAdminAjaxResponse.jsp","source=Organization&Destination=Profile&responseOrg=manager,op,org_Type,child,org_Parent&filterOrg=<%=Org%>",formatResponse,0);

            function formatResponse()
            {
                var xmlhttp = xmlreqs[0];

                xmlhttp.onreadystatechange=function()
                {
                    if(xmlhttp.readyState==4)
                    {
                        var Parent ="";
                        var child="";
                        var plmid = xmlhttp.responseXML.getElementsByTagName("PLM_ExternalID")[0].firstChild.data;
                     if ((xmlhttp.responseXML.getElementsByTagName("org_Parent").length>0) && xmlhttp.responseXML.getElementsByTagName("org_Parent")[0].firstChild != null){
                            Parent = xmlhttp.responseXML.getElementsByTagName("org_Parent")[0].firstChild.data;
                        }

                        var child = xmlhttp.responseXML.getElementsByTagName("child");
                        var children ="";
                        if (child != null){
                            for (var i = 0; i < child.length ; i++ ) {
                                children = children + child[i].firstChild.data + "," ;
                            }
                        }

                        var emp = xmlhttp.responseXML.getElementsByTagName("employees");
                        var Employees ="";
                        if (emp != null){
                            for (var i = 0; i < emp.length ; i++ ) {
                                Employees = Employees + emp[i].firstChild.data + "," ;
                            }
                        }

                        var mem = xmlhttp.responseXML.getElementsByTagName("members");
                        var Members ="";
                        if (mem != null){
                            for (var i = 0; i < mem.length ; i++ ) {
                                Members = Members + mem[i].firstChild.data + "," ;
                            }
                        }

                        var Address ="";

                        document.getElementById("imageWaiting").style.display = 'none';
                        var target = "emxPLMOnlineForm.jsp?type=Organization&plmid="+plmid+"&child="+children+"&parent="+Parent+"&Address="+Address;
                        document.getElementById("targetPage").src=target;
                    }
                }
            }
        </script>

   <script>
        addHeader("images/iconSmallCompany.gif","<%=Org%>");
        addMiddle("targetPage","","images/iconParamProgress.gif");
       </script> 
</body>
</html>



