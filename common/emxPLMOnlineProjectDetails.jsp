<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../emxTagLibInclude.inc"%>
<%@ page import="com.dassault_systemes.vplmadmin.InstallConfig"%>
<%@ page import="com.dassault_systemes.vplmadmin.InstallConfigManager"%>
<%@include file = "../common/emxPLMOnlineAdminAuthorize.jsp"%>
<html>
<head>
    <link rel=stylesheet type="text/css" href="styles/emxUIPlmOnline.css">
    <script src="scripts/emxUIAdminConsoleUtil.js" type="text/javascript"></script>
    <link rel=stylesheet type="text/css" href="styles/emxUIDOMLayout.css">
    <link rel=stylesheet type="text/css" href="styles/emxUIDefault.css">
    
</head>
<body>
    <%
              InstallConfigManager icm = new InstallConfigManager();
    InstallConfig ic = null;

    String mode="";
    try {
          ic = icm.getInstallConfig(context);
           mode = ic.getMode();
    }
    catch (Exception e) { }

    String Prj = (String)emxGetParameter(request,"name");
    String destination = (String)emxGetParameter(request,"dest");
      %>
       <script>
       var xmlreqs = new Array();
        var dest = "source=Project&Solution=VPM&Destination=Profile&Method=Query&Filter="+"<%=Prj%>";

        xmlreq("emxPLMOnlineAdminAjaxResponse.jsp",dest,formatResponse,0);
       if ("<%=mode%>" != "SMB"){
        xmlreq("emxPLMOnlineAdminAjaxResponse.jsp","source=DiscForPrj&filter=<%=Prj%>",formatResponse,2);
       }//

       function formatResponse()
        {
            var xmlhttp = xmlreqs[0];
            var xmlhttpdisciplines = xmlreqs[2];
            var check=false;
            var target="";

            xmlhttp.onreadystatechange=function()
            {
               if(xmlhttp.readyState==4)
                {
                      var Description="";
                      var Parent ="";
                      var secLevel="";
                      var plmid = xmlhttp.responseXML.getElementsByTagName("PLM_ExternalID")[0].firstChild.data;
                      if (xmlhttp.responseXML.getElementsByTagName("v_id")[0].firstChild != null){
                        Description = xmlhttp.responseXML.getElementsByTagName("v_id")[0].firstChild.data;
                      }
                      if (xmlhttp.responseXML.getElementsByTagName("project_Parent")[0].firstChild != null){
                        Parent = xmlhttp.responseXML.getElementsByTagName("project_Parent")[0].firstChild.data;
                      }

                      if (xmlhttp.responseXML.getElementsByTagName("Accreditation")[0].firstChild != null){
                        secLevel = xmlhttp.responseXML.getElementsByTagName("Accreditation")[0].firstChild.data;
                      }
                      var child = xmlhttp.responseXML.getElementsByTagName("child");
                      var children ="";
                      for (var i = 0; i < child.length ; i++ ) {
                           children = children + child[i].firstChild.data + "," ;
                      }

                      if ("<%=mode%>" == "SMB"){
                           document.getElementById("imageWaiting").style.display = 'none';
                            target = "emxPLMOnlineForm.jsp?type=Project&Destination=Profile&dest="+encodeURI("<%=destination%>")+"&name="+encodeURI("<%=Prj%>")+"&child="+encodeURI(children)+"&plmid="+encodeURI(plmid)+"&description="+encodeURI(Description)+"&parent="+encodeURI(Parent);
                           document.getElementById("targetPage").src=target;
                        }else{
                        if(check==false ){
                           target = "emxPLMOnlineForm.jsp?type=Project&Destination=Profile&dest="+encodeURI("<%=destination%>")+"&name="+encodeURI("<%=Prj%>")+"&child="+encodeURI(children)+"&plmid="+encodeURI(plmid)+"&description="+encodeURI(Description)+"&parent="+encodeURI(Parent)+"&secLevel="+encodeURI(secLevel);
                           check=true;
                        }else{
                           document.getElementById("imageWaiting").style.display = 'none';
                            target = target+"&type=Project&Destination=Profile&dest="+encodeURI("<%=destination%>")+"&name="+encodeURI("<%=Prj%>")+"&child="+encodeURI(children)+"&plmid="+encodeURI(plmid)+"&description="+encodeURI(Description)+"&parent="+encodeURI(Parent)+"&secLevel="+encodeURI(secLevel);
                           document.getElementById("targetPage").src=target;
                        }
                      }
                }        
        }

        if ("<%=mode%>" != "SMB"){  xmlhttpdisciplines.onreadystatechange=function()
            {
               if(xmlhttpdisciplines.readyState==4)
                {
                      var discipline = xmlhttpdisciplines.responseXML.getElementsByTagName("Disciplines");
                      var disciplines ="";
                      for (var i = 0; i < discipline.length ; i++ ) {
                           disciplines = disciplines + discipline[i].firstChild.data + ",," ;
                      }

                    if(check==false){
                           target = "emxPLMOnlineForm.jsp?disciplines="+encodeURI(disciplines);
                           check=true;
                      }else{
                          document.getElementById("imageWaiting").style.display = 'none';
                           target = target+"&disciplines="+encodeURI(disciplines);
                           document.getElementById("targetPage").src=target;
                      }
                 }
                }}
        }
     </script>
<script>
        addHeader("images/iconSmallProject.gif","<%=Prj%>");
        addMiddle("targetPage","","images/iconParamProgress.gif");
       </script> 
</body>
</html>
