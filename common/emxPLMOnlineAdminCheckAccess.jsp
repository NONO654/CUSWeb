<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxPLMOnlineIncludeStylesScript.inc"%>
<%@include file = "../common/emxPLMOnlineAdminAttributesCalculation.jsp"%>
<%@include file = "../common/emxPLMOnlineAdminAuthorize.jsp"%>

<html>
  <head> 
     <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
  </head>
  <%
  String ERR_ObjTypeIncorrect = getNLS("ERR_ObjTypeIncorrect");
  String ERR_TNRIncorrect = getNLS("ERR_TNRIncorrect");
  String ERR_IDDoesNotExist = getNLSMessageWithParameter("ERR_IDDoesNotExist","User");
%>
  <script>
      function getUserCtxs(){
          document.getElementById('SecContexts').options.length = 0;

          var userName =document.getElementById('PLM_ExternalID').value;
          var target = "emxPLMOnlineAdminAjaxResponse.jsp?source=Person&User="+encodeURIComponent(userName);
          xmlreq(target,"",formatResponse,0);

      }
        xmlreqs = new Array();
        function formatResponse()
            {
            var xmlhttpContext = xmlreqs[0];

            xmlhttpContext.onreadystatechange=function()
            {
               if(xmlhttpContext.readyState==4)
                {
                    var elements = xmlhttpContext.responseXML.getElementsByTagName("Error");
                    if(elements.length>0){alert(elements[0].firstChild.data);}

                    else{
                          document.getElementById("SecurityContexts").style.display = "";
                         addOptionsToSelect("SecContexts",xmlhttpContext,"Context","","NotBlank");
                    }
                }

                for(var i = 0 ; i < 32 ; i++ ){
                    var TdName = "check"+i;
                    document.getElementById(TdName).className = "titleCheckAccess";
                }
            }}
       

            


       function checkAccess(){
            var UserName=document.getElementById('PLM_ExternalID').value;
            var ObjectType = document.getElementById('ObjectType').value;
            var ObjectName = document.getElementById('ObjectName').value;
            var ObjectRevision = document.getElementById('ObjectRevision').value;
          
            var checkbox =  getSelectedCheckbox();
           
            if (document.getElementById("selectAll").checked ==true){
                checkbox = checkbox.substring(checkbox.indexOf(",,")+2,checkbox.length);
            }
           
            var checkboxSelected  =  checkbox.split(",,");
            //checkbox= checkbox.substring(0,checkbox.indexOf(",,"));
            var secContexts = document.getElementById('SecContexts').value;

            var xmlhttp = getXMLHTTPObject();
            xmlhttp.onreadystatechange=function()
            {
               if(xmlhttp.readyState==4)
                {
                    var elementsError = xmlhttp.responseXML.getElementsByTagName("Error");
                      if(elementsError.length>0){
                          if( (elementsError[0].firstChild.data).indexOf("type") != -1){
                              alert("<%=ERR_ObjTypeIncorrect%>");
                          }
                          if( (elementsError[0].firstChild.data).indexOf("No business object") != -1){
                              alert("<%=ERR_TNRIncorrect%>");
                          }
                          if( (elementsError[0].firstChild.data).indexOf("person") != -1){
                              alert("<%=ERR_IDDoesNotExist%>");
                          }
                      }
                     else{
                         var elements = xmlhttp.responseXML.getElementsByTagName("Access");

                        for(var i = 0 ; i<elements.length ; i++ ){
                            var checkToadd = checkboxSelected[i];
                            var TDname = "check"+checkToadd;
                     
                            if (elements[i].firstChild.data == "true"){
                                document.getElementById(TDname).className = "access";
                            }else{
                                 document.getElementById(TDname).className = "forbidden";
                            }
                            }
                        }
                        document.getElementById("Legendary").style.display = "";
                }
              
            }
            var target = "emxPLMOnlineAdminAjaxResponse.jsp?source=CheckAccess&UserName="+UserName+"&SecurityContextName="+secContexts+"&ObjectType="+ObjectType+"&ObjectName="+ObjectName+"&ObjectRevision="+ObjectRevision+"&Access="+checkbox;
            xmlhttp.open("GET",target,true);
            xmlhttp.send(null);
       }

         function checkAll(){
             var check = document.getElementById("selectAll").checked;
             var elements = document.getElementsByTagName("input");

            if(check==true){
                for (var i=0 ; i <elements.length; i++){
                    if(elements[i].type == "checkbox"){
                        elements[i].checked = true;
                    }
                }
            }else{
                 for (var i=0 ; i <elements.length; i++){
                    if(elements[i].type == "checkbox"){
                        elements[i].checked = false;
                    }
                }
            }
         }

         function check(numCheckBox){
                  getUserCtxs();
                    if (numCheckBox >= 0 &&  numCheckBox <= 32){
                 if (document.getElementById(numCheckBox).className == "access" || document.getElementById(numCheckBox).className == "forbidden"){
                 document.getElementById(numCheckBox).className ="";
                }
             }
         }

  </script>
  <body>
    <div class="divPageBodyVPLM">
         <table width="98%" style="border-color: white ; height: 90%" border="1px"  >
             <tr>
             <div class="headerVPLM" style="height : 5%"> <%=getNLS("CheckAccessOnTNR")%></div>
                        <hr>
                </tr>
                <tr height="50%">
                    <td>
                        <table class="big">
                            <tr><td ></td>
                                <td>
                                    <table width="100%">
                                        <tr>
                                            <td class="title" width="50%">
                                                <%=getNLS("UserID")%>
                                            </td>
                                            <td>
                                                <input type="text" size="20" id='PLM_ExternalID' name='PLM_ExternalID' value=""  onchange="javascript:getUserCtxs()">
                                            </td>
                                        </tr>
                                        
                                    </table>
                                </td>
                                <td></td>
                            </tr>
                             <tr><td></td>
                                 <td> <table width="100%">
                                          
                                        <tr></tr>
                                        <tr id="SecurityContexts" style="display:none">
                                            <td class="title" width="50%"><%=getNLS("SecurityContexts")%>
                                            </td>
                                            <td>
                                                <select id="SecContexts" ></select>
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                                 <td></td>
                             </tr>
                             <tr ><td><table width="100%">
                                     <tr>
                                            <td class="title" width="50%"><%=getNLS("Type")%>
                                            </td>
                                            <td>
                                                <input type="text" size="20" id='ObjectType' name='ObjectType' value="" >
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                                 <td ><table width="100%">
                                     <tr>
                                            <td class="title" width="50%"><%=getNLS("Name")%>
                                            </td>
                                            <td>
                                                <input type="text" size="20" id='ObjectName' name='ObjectName' value="" >
                                            </td>
                                        </tr>
                                    </table>
                                 </td>
                                 <td><table width="100%">
                                     <tr>
                                            <td class="title" width="50%"><%=getNLS("Revision")%>
                                            </td>
                                            <td>
                                                <input type="text" size="20" id='ObjectRevision' name='ObjectRevision' value="" >
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                         </table>
                    </td>
                </tr>
                <tr height="40%">
                    <td border="1" align="center">
                        <table class="big" align="center">
                                 <tr><td class="pic"><img src="images/iconSmallCheckAccess.gif"></td><td class="titleCheckAccess"><%=getNLS("Accesses")%> : </td>
                                     <td align="center">
                                <table  >
                                    <tr>
                                        <td class="titleCheckAccess"><input type="checkbox" id="selectAll" onclick="javascript:checkAll()"><%=getNLS("SelectAll")%></td>                              </tr>
                                    <tr>
                                        <td class="titleCheckAccess" id="check0"><input type="checkbox" onchange="javascript:check(0)" id="0"><%=getNLS("Read")%></td><td class="titleCheckAccess" id="check1"><input type="checkbox" id="1"><%=getNLS("Modify")%></td><td class="titleCheckAccess" id="check2"><input type="checkbox" id="2"><%=getNLS("Delete")%></td><td class="titleCheckAccess" id="check3"><input type="checkbox" id="3"><%=getNLS("CheckOut")%></td><td class="titleCheckAccess" id="check4"><input type="checkbox" id="4"><%=getNLS("CheckIn")%></td><td class="titleCheckAccess" id="check16"><input type="checkbox" id="16"><%=getNLS("Schedule")%></td><td class="titleCheckAccess" id="check5"><input type="checkbox" id="5"><%=getNLS("Lock")%></td><td class="titleCheckAccess" id="check28"><input type="checkbox" id="28"><%=getNLS("Execute")%></td>
                                    </tr>
                                    <tr>
                                        <td class="titleCheckAccess" id="check6"><input type="checkbox" id="6"><%=getNLS("Unlock")%></td><td class="titleCheckAccess" id="check26"><input type="checkbox" id="26"><%=getNLS("Freeze")%></td><td class="titleCheckAccess" id="check27"><input type="checkbox" id="27"><%=getNLS("Thaw")%></td><td class="titleCheckAccess" id="check10"><input type="checkbox" id="10"><%=getNLS("Create")%></td><td class="titleCheckAccess" id="check17"><input type="checkbox" id="17"><%=getNLS("Revise")%></td><td class="titleCheckAccess" id="check11"><input type="checkbox" id="11"><%=getNLS("Promote")%></td><td class="titleCheckAccess" id="check12"><input type="checkbox" id="12"><%=getNLS("Demote")%></td><td class="titleCheckAccess" id="check7"><input type="checkbox" id="7"><%=getNLS("Grant")%></td>
                                    </tr>
                                    <tr>
                                        <td class="titleCheckAccess" id="check13"><input type="checkbox" id="13"><%=getNLS("Enable")%></td><td class="titleCheckAccess" id="check14"><input type="checkbox" id="14"><%=getNLS("Disable")%></td><td class="titleCheckAccess" id="check15"><input type="checkbox" id="15"><%=getNLS("Override")%></td><td class="titleCheckAccess" id="check19"><input type="checkbox" id="19"><%=getNLS("ChangeName")%></td><td class="titleCheckAccess" id="check21"><input type="checkbox" id="21"><%=getNLS("ChangeType")%></td><td class="titleCheckAccess" id="check9"><input type="checkbox" id="9"><%=getNLS("ChangeOwner")%></td><td class="titleCheckAccess" id="check20"><input type="checkbox" id="20"><%=getNLS("ChangePolicy")%></td><td class="titleCheckAccess" id="check8"><input type="checkbox" id="8"><%=getNLS("Revoke")%></td>
                                    </tr>
                                    <tr>
                                        <td class="titleCheckAccess" id="check18"><input type="checkbox" id="18"><%=getNLS("ChangeVault")%></td><td class="titleCheckAccess" id="check22"><input type="checkbox" id="22"><%=getNLS("FromConnect")%></td><td class="titleCheckAccess" id="check23"><input type="checkbox" id="23"><%=getNLS("ToConnect")%></td><td class="titleCheckAccess" id="check24"><input type="checkbox" id="24"><%=getNLS("FromDisconnect")%></td><td class="titleCheckAccess" id="check25"><input type="checkbox" id="25"><%=getNLS("ToDisconnect")%></td><td class="titleCheckAccess" id="check30"><input type="checkbox" id="30"><%=getNLS("ViewForm")%></td><td class="titleCheckAccess" id="check29"><input type="checkbox" id="29"><%=getNLS("ModifyForm")%></td><td class="titleCheckAccess" id="check31"><input type="checkbox" id="31"><%=getNLS("Show")%></td>
                                    </tr>
                                </table>

                            </td>
                                 </tr>
                             </table>
                        </td>
                </tr>
                <tr height="10%">
                    <td width="100%" >
                        <table width="100%">
                            <tr width="100%">
                                <td id="Legendary" style="display:none"><font color="#0ade0a" style="font-weight: bold;font-style: italic;" ><%=getNLS("AccessValid")%></font><br><font color="#990000" style="font-weight: bold;font-style: italic;"><%=getNLS("AccessDenied")%></font>

                                </td>
                                </tr>
                        </table>
                    </td>
                </tr>
            </table>
</div>
                                <% String check = getNLS("Check");%>
      <script>addFooter("javascript:checkAccess()","images/buttonDialogApply.gif","<%=check%>","<%=check%>");</script>
  </body>
</html>
