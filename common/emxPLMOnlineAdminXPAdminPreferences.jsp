<%@include file = "../common/emxPLMOnlineIncludeStylesScript.inc"%>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxPLMOnlineAdminAttributesCalculation.jsp"%>
<%@include file = "../common/emxPLMOnlineAdminAuthorize.jsp"%>
<html>
    <head>
      <script>
        xmlreqs = new Array();
        var confidentialities="";

        function formatResponse()
        {
            //var xmlhttp = xmlreqs[0];
            var xmlhttp = xmlreqs[0];

            xmlhttp.onreadystatechange=function()
            {
               if(xmlhttp.readyState==4)
                {
                   var Solutions = xmlhttp.responseXML.getElementsByTagName("Solution");
                   var PersonFilter = xmlhttp.responseXML.getElementsByTagName("PersonFilter");
                   var ProjectFilter = xmlhttp.responseXML.getElementsByTagName("ProjectFilter");
                   var RoleFilter = xmlhttp.responseXML.getElementsByTagName("RoleFilter");
                   document.getElementById("personFilter").value = PersonFilter.item(0).firstChild.data;
                   document.getElementById("roleFilter").value = RoleFilter.item(0).firstChild.data;
                   document.getElementById("projectFilter").value = ProjectFilter.item(0).firstChild.data;
                   var Solution = document.getElementsByName("Solution");
                 
                   for (var i = 0 ; i < Solution.length ; i++){
                    if (Solution[i].value == Solutions.item(0).firstChild.data){
                        Solution[i].checked=true;
                    }
                   }
               }
            }
        }

        function sendCreate(){
            var xmlhttp1 = xmlreqs[1];

            xmlhttp1.onreadystatechange=function()
            {
               if(xmlhttp1.readyState==4)
                {
                    var createResult = xmlhttp1.responseXML.getElementsByTagName("resultat");
                    document.getElementById("hidethisone").style.display="";
                    //document.getElementById("messageError").innerHTML=createResult[0].firstChild.data;
                    alert(createResult[0].firstChild.data);
					top.content.location = "../common/emxPortal.jsp?portal=APPXPPreferencesAdminPortal&toolbar=APPXPAdminToolBar&header=emxPlmOnline.label.ManageOption&suiteKey=VPLMAdministration&StringResourceFileId=emxVPLMAdministrationStringResource&SuiteDirectory=.";
                }
            }
         }

         function appelFramePerson(){
            var personFilter = document.getElementById("personFilter").value;
            var projectFilter = document.getElementById("projectFilter").value;
            var roleFilter = document.getElementById("roleFilter").value;
            var Solution = document.getElementsByName("Solution");
            var val;

            for (var i = 0 ; i < Solution.length ; i++){
                if (Solution[i].checked == true){
                    val = Solution[i].value;
                    if ( (val == "TEAM") && (roleFilter!="*") ){
                       alert("Role Filter cannot be applied to TEAM Solution");
                       roleFilter="*";
                       document.getElementById("roleFilter").value="*";
                   }
                }
            }
 
            xmlreq("emxPLMOnlineAdminAjaxResponse.jsp","source=setUserPreferences&personFilter="+personFilter+"&projectFilter="+projectFilter+"&roleFilter="+roleFilter+"&preferedSolution="+val,sendCreate,1);
         }


        function init(){
             xmlreq("emxPLMOnlineAdminAjaxResponse.jsp","source=getUserPreferences",formatResponse,0);
        }
    </script>
    </head>
     <script>addReturnMessage();</script>
        
    <body onload="javascript:init()">
       <form  action="" name="submitForm" id="submitForm" method="POST"  >
            <table width="100%" style="height:98%">
                <tr style="height:90%" valign="top">
                    <td border="1" >
                        <table width="100%">
                        <% 
                            String HostCompanyName= getHostCompanyName(mainContext);

                            String Solution = getNLS("Solution");
                           String CurretOrg = getNLS("CurrentOrganization");
                            String QueriesFilter = getNLS("QueriesFilter");
                            String PersonFilter = getNLS("PersonFilter");
                            //RBR2: FUN [080973] This will be treated as Title based Preference
                            String ProjectFilter = getNLS("ProjectFilter");
                            String RoleFilter = getNLS("RoleFilter");
                            String Apply = getNLS("Save");
                          
                        %>
                            <script>
                                addTable("iconSmallSolution.gif","<%=Solution%>",1);
                                document.write('<tr><td class="title"  width="50%"><%=getNLS("Team")%></td>');
                                document.write('<td><input type="radio" name="Solution"  checked  value="TEAM"></td></tr>');
                                document.write('<tr><td class="title"  width="50%"><%=getNLS("Vplm")%></td>');
                                document.write('<td><input type="radio"  name="Solution"  value="VPLM"></td></tr>');
                                addCloseTag();
                                addTable("iconSmallCompany.gif","<%=CurretOrg%>",2);
                                document.write('<tr><td class="title" width="50%" id="companyName">'+"<%=HostCompanyName%>"+'</td>');
                                document.write('<td></td></tr>');
                                addCloseTag();
                                addTable("iconSmallQuery.gif","<%=QueriesFilter%>",3);
                                addTdRE("<%=PersonFilter%>","personFilter","*","appelFramePerson");
                                addTdRE("<%=ProjectFilter%>","projectFilter","*","appelFramePerson");
                                addTdRE("<%=RoleFilter%>","roleFilter","*","appelFramePerson");
                                addCloseTag();
                            </script>
                        </table>
                    </td>
                </tr>
            </table>
        </form>
        <script>
            addFooter("javascript:appelFramePerson()","images/buttonDialogDone.gif","<%=Apply%>","<%=Apply%>");
        </script>
  </body>
</html>
