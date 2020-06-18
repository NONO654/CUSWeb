<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@ page import="com.matrixone.vplm.posws.stubsaccess.ClientWithoutWS" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="com.dassault_systemes.vplmadmin.InstallConfig"%>
<%@ page import="com.dassault_systemes.vplmadmin.InstallConfigManager"%>
<%@include file = "emxPLMOnlineAdminAttributesCalculation.jsp"%>
<%@include file = "../common/emxPLMOnlineAdminAuthorize.jsp"%>
<%@include file= "../common/emxPLMOnlineIncludeStylesScript.inc"%>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
           <script>
             function sendToUpdate(){
                  document.getElementById("submitForm").action = "emxPLMOnlineUpdatePreferences.jsp";
                   document.getElementById("submitForm").submit();
              }
                  </script>
    </head>
    <body>

<%
                  String message="";
                  Map person = new HashMap();
                        Map fin = new HashMap();
                        Map listperson = new HashMap();
                       
                        person.put("PLM_ExternalID",context.getUser());
                        listperson.put("person0" ,person);
                   
                        fin.put("method","queryPerson");   
                        fin.put("iPerson",listperson);
                        
                        // JIC 18:07:03 FUN076129: Removed use of PLM key/added context
                        ClientWithoutWS client = new ClientWithoutWS(mainContext);
                        Map persons = client.serviceCall(fin);  
                        Map temp = (Map) persons.get("person0");
                        
                        String Preferences = (String)temp.get("Preferences");
                        StringList ctxs = (StringList)temp.get("ctx");
                        ctxs.sort();
                         Enumeration param = emxGetParameterNames(request);
                       while (param.hasMoreElements()){
                           String nextParam = (String)param.nextElement();
                           if ( nextParam.equals("message") ){
                                message = emxGetParameter(request,"message");
                           }
                       }

                          /*Getting the server mode : SMB or VPM*/
                InstallConfigManager icm = new InstallConfigManager();
                InstallConfig ic = null;
                String mode="";
                try {
                    ic = icm.getInstallConfig(context);
                    mode = ic.getMode();
            }
    catch (Exception e) { }
              
              if( !(message.equals("")) && !(message.equals(null))  ){ 
               %>
               <script>alert("<%=message%>");</script>
               <%}%>
               <div class="divPageBodyVPLM">
			<form id="submitForm" name="submitForm"  action=""  >
                   <table id="tableRes" width="100%">
                       <tr bgcolor="#b0b2c3" style="width : 100%">
                           <td class="MatrixLabel" width="20px" ><%=myNLS.getMessage("Default")%></td>
                          <% if (mode.equals("SMB")){%>
                           <td class="MatrixLabel" ><%=myNLS.getMessage("Role")%></td>  <td class="MatrixLabel" ><%=myNLS.getMessage("Project")%></td>

                           <%}else{%>
                           <td class="MatrixLabel" ><%=myNLS.getMessage("SecurityContexts")%></td>
                           <%}%>
                       </tr>
                       <%for (int i = 0 ; i < ctxs.size() ; i++){
                                String preferred = "";
                                preferred=(String)ctxs.get(i);
                                String name = "RadioButton"+i;
                       %><tr >
                           <td class="MatrixFeel" width="20px">
                               <%if (preferred.equals(Preferences)){%>
                               <input type="radio" name="group" id="<%=name%>" value="<%=preferred%>" checked><%}else{%>
                               <input type="radio" id="<%=name%>" name="group" value="<%=preferred%>"><%}%>
                           </td>
                           <% if (mode.equals("SMB")){
                                String roleOfPref=preferred.substring(0,preferred.indexOf("."));
                                String prjOfPref=preferred.substring(preferred.lastIndexOf(".")+1,preferred.length());
                           %>
                           <td class="MatrixFeel"><%=roleOfPref%></td><td class="MatrixFeel"><%=prjOfPref%></td>
                           <%}else{%>
                            <td class="MatrixFeel"><%=preferred%></td>
                           <%}%>
                       </tr>      
                       <%}%>
                       <tr><td></td>
                             <%if ((mode.equals("SMB"))){%><td></td><%}%>
 <%
                                String Update =myNLS.getMessage("Update");
                             %>
                     
                            </table>
                                           </form>
</div>
                              <script>
                           addFooter("javascript:sendToUpdate()","images/buttonDialogDone.gif","<%=Update%>");
                       </script>  
    </body>
</html>
