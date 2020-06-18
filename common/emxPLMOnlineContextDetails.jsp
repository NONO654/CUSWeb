<%@include file="../emxUIFramesetUtil.inc"%>    
<%@ page import="java.net.URLEncoder" %>
<%@ page import="com.dassault_systemes.vplmadmin.InstallConfig"%>
<%@ page import="com.dassault_systemes.vplmadmin.InstallConfigManager"%>
<%@include file = "../common/emxPLMOnlineAdminAuthorize.jsp"%>
<html>
<head>
        <link rel=stylesheet type="text/css" href="styles/emxUIPlmOnline.css">
        <script src="scripts/emxUIAdminConsoleUtil.js" type="text/javascript"></script>
		<script type="text/javascript" src="scripts/emxUICore.js"></script>
</head>
<%
 /*Getting the server mode : SMB or VPM*/
    InstallConfigManager icm = new InstallConfigManager();
    InstallConfig ic = null;

    String mode="";
    try {
          ic = icm.getInstallConfig(context);
           mode = ic.getMode();
    }
    catch (Exception e) { }

    String Context = emxGetParameter(request,"name");
%>
     <script>
       var xmlreqs = new Array();
        // JIC 13:02:25 IR IR-191605V6R2014: Added input "Method=Create" to cheat "emxPLMOnlineAdminAjaxResponse.jsp" into retrieving security context filters correctly 
        xmlreq("emxPLMOnlineAdminAjaxResponse.jsp","source=Context&Method=Create&response=v_id,member&select=person&ctxFilter=<%=Context%>",formatResponse,0);
        function formatResponse()
        {
            var xmlhttp = xmlreqs[0];

            xmlhttp.onreadystatechange=function()
            {
               if(xmlhttp.readyState==4)
                {
                   document.getElementById("imageWaiting").style.display = 'none';
                   var Desc ="";
                    var ID = xmlhttp.responseXML.getElementsByTagName("PLM_ExternalID")[0].firstChild.data;
                    if(xmlhttp.responseXML.getElementsByTagName("v_id")[0].firstChild != null){
                     Desc = xmlhttp.responseXML.getElementsByTagName("v_id")[0].firstChild.data;
                    }
					var members = xmlhttp.responseXML.getElementsByTagName("member");
                                       
                    var finalRes="";
                    var RoleFromCtx= ID.substring(0,ID.indexOf("."));
                    var PRJFromCtx= ID.substring(ID.lastIndexOf(".")+1,ID.length);
                    if("<%=mode%>" == "SMB"){
                        document.getElementById("button2value").innerHTML = RoleFromCtx + "in" + PRJFromCtx;
                    }else{
                        document.getElementById("button2value").innerHTML = xmlhttp.responseXML.getElementsByTagName("PLM_ExternalID")[0].firstChild.data.htmlEncode();
                    }

                    for(var i = 0 ; i < members.length ; i++){
                            finalRes = finalRes + members[i].firstChild.data + ",";
                    }
                  
                   var target = "emxPLMOnlineForm.jsp?type=Context&plmid="+ID+"&Assignees="+finalRes+"&description="+Desc;
                   document.getElementById("iFrameForResult").src=target;
                }
            }
        }
     </script>
     <div class="header" style="height : 5%" >
        <table>
            <tr>
                <td><img src="images/iconSmallContext.gif" ></td>
                <td class="headers" id="button2value" ></td>
            </tr>
        </table>
        <hr>
     </div>
    <div class="middle" style="height :88%">  <img  id="imageWaiting"  src="images/iconParamProgress.gif">
       <iframe width="100%" height="100%" frameborder="0" id="iFrameForResult" src=""></iframe>  
    </div>
    <div class="footer" style="height : 5%"><hr>
    </div>
</body>
</html>
