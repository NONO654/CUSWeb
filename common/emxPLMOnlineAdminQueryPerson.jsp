<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>
<%@include file = "../common/emxPLMOnlineIncludeStylesScript.inc"%>
<%@include file = "../common/emxPLMOnlineAdminAttributesCalculation.jsp"%>
<%@ page import="com.matrixone.vplm.posws.stubsaccess.ClientWithoutWS" %>
<%@ page import="com.dassault_systemes.vplmposadministrationui.uiutil.AdminUtilities" %>
<%@include file = "../common/emxPLMOnlineAdminAuthorize.jsp"%>
<script type="text/javascript" src="scripts/emxUICore.js"></script>
<%--
    Document   : emxPLMOnlineAdminQueryPerson.jsp
    Author     : LXM
    Modified : 19/10/2010 -> New UI
--%>
<%
       String resetPassword = myNLS.getMessage("CONF_ResetPassword");
       String resetPass = myNLS.getMessage("ResetPassword");
       String ERR_NothingToSave = myNLS.getMessage("ERR_NothingToSave");
       String NLSMessage = getNLSMessageWithParameter("ERR_ThereIsNoMatchingThisCriteria", "Person");
%>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <script>
            var toActivate = "";
            var Activation = false;
            var xmlreqs = new Array();

            function appelFonction(plmexternalID, firstName, lastName){
                // JIC 13:07:04 IR IR-241854V6R2013x: Changed JSP to emxPLMOnlineAdminDisplayPerson.jsp
                // JIC 13:10:07 IR IR-256906V6R2013x: Removed rows; changed target of "emxPLMOnlineAdminDisplayPerson.jsp" from "banniere" to "Topos"
                parent.document.getElementById('Topos').src="emxPLMOnlineAdminDisplayPerson.jsp?source=Admin&PLM_ExternalID="+encodeURIComponent(plmexternalID)+"&FirstName="+encodeURIComponent(firstName)+"&LastName="+encodeURIComponent(lastName);
            }

            function appelFonctionXP(plmexternalID){
                //parent.document.getElementById('frameRow').rows="50,50";
                //parent.document.getElementById('banniere').src="emxPLMOnlineAdminXPUpdatePerson.jsp?source=Admin&PLM_ExternalID="+encodeURIComponent(plmexternalID);
                parent.document.getElementById('Topos').src="emxPLMOnlineAdminXPUpdatePerson.jsp?source=Admin&PLM_ExternalID="+encodeURIComponent(plmexternalID);
				}

            function editRow(){
                var activeInactive = document.getElementsByTagName("input");
                for (var i = 0 ; i <activeInactive.length ; i++){
                   var typeActive =activeInactive[i].type
                   if (typeActive == "checkbox"){
                       activeInactive[i].disabled=false;
                    }
                }
            }


            function checkActive(checkboxId){
                if(toActivate.indexOf(";;"+checkboxId+";;") == -1 ){
                    toActivate=toActivate + ";;" + checkboxId +";;";
                    
                }else{
                    toActivate = toActivate.substring(0,toActivate.indexOf(";;"+checkboxId+";;"))+toActivate.substring(toActivate.indexOf(";;"+checkboxId+";;")+checkboxId.length+4,toActivate.length);
                }

            }

             function save(Active){
                 
                var persons= "";
                if (toActivate == ""){alert("<%=ERR_NothingToSave%>");}else{
                
                var toActivateList = toActivate.split(";;");
                for (var i = 0 ; i < toActivateList.length ; i++){
                   if(toActivateList[i] != ""){

                       var person = "Per"+toActivateList[i];
                       var per2Update = document.getElementById(person).innerHTML.htmlDecode();
                       persons=persons+per2Update+"::";
                   }
                }

                updatePersons(persons,Active);
                }
             }

             function formatResponse(){
               var xmlhttpPerson= xmlreqs[0];

                 xmlhttpPerson.onreadystatechange=function()
            {
               if(xmlhttpPerson.readyState==4)
                {
                    toActivate="";
                    var createResult = xmlhttpPerson.responseXML.getElementsByTagName("result");
                    document.getElementById("hidethisone").style.display="block";
                    document.getElementById("messageError").innerHTML=createResult[0].firstChild.data;

                    var persons = xmlhttpPerson.responseXML.getElementsByTagName("persons");
                    var persList = persons[0].firstChild.data;
                   
                    var pers2Remove = persList.split("::");
                     var lengthArray = pers2Remove.length;
                      var array2Sort = new Array(lengthArray-1);
                   
                     for(var i = 0 ; i < pers2Remove.length ; i++){
                     if( (pers2Remove[i] != "") ){
                         var row2Rem = document.getElementById(pers2Remove[i]);
                         var input = row2Rem.getElementsByTagName("input");
                       
                       var table = document.getElementById("tableRes");
                       var rowID2del = input[0].id;
                        array2Sort[i]=Number(rowID2del)+1;
                      }
                     }
                       array2Sort=array2Sort.sort();
                    
                       array2Sort.sort(tri_nombres);
                      for(var j = 0 ; j<array2Sort.length; j++){
                           var row2 = array2Sort[j];
                       table.deleteRow(row2-j);
                      }

                         }
                    }

                }
            function tri_nombres(a,b)
            { return a-b; }


             function updatePersons(persons,Active){
                 xmlreq("emxPLMOnlineAdminAjaxResponse.jsp?source=Activate&Persons="+encodeURIComponent(persons)+"&Active="+Active,"",formatResponse,0);
           
             }

             function resetPasswordResponse(){
                  var xmlhttpResetPass= xmlreqs[1];

                 xmlhttpResetPass.onreadystatechange=function()
                {
                    if(xmlhttpResetPass.readyState==4){
                        var createResult = xmlhttpResetPass.responseXML.getElementsByTagName("result");
                        document.getElementById("hidethisone").style.display="block";
                        document.getElementById("messageError").innerHTML=createResult[0].firstChild.data;

                    }
                }
                }
             


             function resetPassword(plmExternalID){
                 var conf =confirm("<%=resetPassword%>");
                 if(conf == true){
                     xmlreq("emxPLMOnlineAdminAjaxResponse.jsp?source=resetPassword&UserID="+encodeURIComponent(plmExternalID),"",resetPasswordResponse,1);
                 }
            }
        </script>
    </head>
      
    <body>
        <div class="divPageBodyVPLM">
           <script>addReturnMessage();</script>
            <table width="100%" style="border-color: white" border="1px"  >
            
                <tr id="highRow" width="100%" style="overflow : auto">
                    <td width="100%" >
                    <%  
                        String source = emxGetParameter(request,"source");
			String Active = emxGetParameter(request,"Active");
                       
                      
                        Map person = new HashMap();
                        Map fin = new HashMap();
                        Map listperson = new HashMap();
                        Map orgEmp = new HashMap();
                        Map listOrgEmp = new HashMap();

                        person.put("street",emxGetParameter(request,"street"));
                        person.put("city",emxGetParameter(request,"city"));
                        person.put("state",emxGetParameter(request,"state"));
                        person.put("postalCode",emxGetParameter(request,"postalCode"));
                        person.put("country",emxGetParameter(request,"Country"));
                        person.put("v_first_name",emxGetParameter(request,"v_first_name"));
                        person.put("v_last_name",emxGetParameter(request,"v_last_name"));
                        person.put("v_email",emxGetParameter(request,"v_email"));
                        person.put("v_phone",emxGetParameter(request,"v_phone"));
                        person.put("PLM_ExternalID",emxGetParameter(request,"plm_ExternalID"));
			person.put("IsActive",Active);
                        
                        if (!AdminUtilities.isCentralAdmin(mainContext)){
                            StringList Orgas = AdminUtilities.getAnyAdminRoleOrganizations(mainContext);
                            for (int i = 0 ; i < Orgas.size(); i++){
                                    orgEmp = new HashMap();
                                    orgEmp.put("PLM_ExternalID",Orgas.get(i));
                                    listOrgEmp.put("organization"+i,orgEmp);
                            }
                        }


        		
                        listperson.put("person0" ,person);
				String responseType= emxGetParameter(request,"responseType");
	                String[] slec = new String[] {""};
                        if (responseType.equals("BASICS")){
                                slec = new String[] {"BASICS"};
                                fin.put("iSelectableList",slec);
                        }

                        String Edit = getNLS("EditLine");
                        String Save = getNLS("Save");

                        fin.put("method","queryPerson");   
                        fin.put("iPerson",listperson);
                        // JIC 18:07:03 FUN076129: Removed use of PLM key/added context
                        ClientWithoutWS client = new ClientWithoutWS(mainContext);
                        Map persons = client.serviceCall(fin);

                        String iSolution = "";

                        if (!source.equals("XPPerson")){
                            iSolution="VPLM";
                        }
				
				if((responseType.equals("BASICS"))){
					iSolution="SMB";
				}
                        
                        Map Attributes = getAttributes(mainContext,"Person",iSolution);
				StringList AttributesToShow = (StringList)Attributes.get("ListAttributes");
	java.util.Map countryChoiceDetails = (java.util.Map) matrix.db.JPO.invoke(context, "emxOrganization", null, "getCountryChooserDetailsForHTMLDisplay", new String[]{request.getHeader("Accept-Language")}, java.util.HashMap.class);
	java.util.List optionList =  (java.util.List)countryChoiceDetails.get("optionList");
	java.util.List valueList =  (java.util.List)countryChoiceDetails.get("valueList");

                       
                                             if(persons.size() == 0 ){
                        %>  
                            <script>alert("<%=NLSMessage%>");</script>
                        <%}%>
                     <table id="tableRes" width="100%"   style="height:98% ;border-color: white" border="1px" >
                            <tr style="width : 100%">
                                <td class="MatrixLabel"></td>
                                <%for (int i = 0 ; i < AttributesToShow.size() ; i++) {
                                    String NLSName = (String)Attributes.get(AttributesToShow.get(i));
                                %>
                                    <td class="MatrixLabel"><%=NLSName%></td>
                                <%}%>
                            </tr>
                            <%for(int i = 0 ; i <persons.size() ; i++){
                                Map pers = (Map)persons.get("person"+i);
                                String Activating = (String)pers.get("IsActive");
				String idPer= "Per"+i;
                            %>
                                <tr id="<%=pers.get("PLM_ExternalID")%>"  >
                                    <td class="MatrixFeel"><img src="images/iconActionChangePassword.gif" style="cursor:pointer" title="<%=resetPass%>" onclick="javascript:resetPassword('<%=XSSUtil.encodeForJavaScript(context,(String)pers.get("PLM_ExternalID"))%>')"></td>
                                    <td class="MatrixFeel">
                                    <%if (Activating.equals("Active")){%>
                                        <input id="<%=i%>" type="checkbox" checked disabled onchange="javascript:checkActive(this.id)">
                                    <%}else{%>
                                        <input id="<%=i%>" type="checkbox"  disabled onchange="javascript:checkActive(this.id)">
                                    <%}%>
                           	    </td>
                                    <td class="MatrixFeel">
                                      <% if ( (source.equals("XPPerson"))){%>
                                        <a id="<%=idPer%>" href="javascript:appelFonctionXP('<%=XSSUtil.encodeForJavaScript(context,(String)pers.get("PLM_ExternalID"))%>');"><%=pers.get("PLM_ExternalID")%></a>
                                      <%}else{%>
                                        <a id="<%=idPer%>" href="javascript:appelFonction('<%=XSSUtil.encodeForJavaScript(context,(String)pers.get("PLM_ExternalID"))%>','<%=XSSUtil.encodeForJavaScript(context,(String)pers.get("v_first_name"))%>','<%=XSSUtil.encodeForJavaScript(context,(String)pers.get("v_last_name"))%>');"><%=pers.get("PLM_ExternalID")%></a>
                                      <%}%>
                                    </td>
                                    <%
                                        for (int j = 2 ; j < AttributesToShow.size() ; j++) {
                                            String AttributeName = (String)AttributesToShow.get(j);
                                            if(!AttributeName.equals("list_Org") && !AttributeName.equals("ctx") && !AttributeName.equals("Address")){
                                    %>
                                                <td class="MatrixFeel"><%=pers.get(AttributeName)%></td>
                                            <%}else{
                                                if (AttributeName.equals("Address")){
                                                %><td class="MatrixFeel"><%if(!(pers.get("street").equals("")) ){%><%=pers.get("street")%><br><%}%>
                                                <%if(!(pers.get("city").equals("")) ){%><%=pers.get("city")%><br><%}%>
                                                <%if(!(pers.get("state").equals("")) ){%><%=pers.get("state")%><br><%}%>
                                                <%if(!(pers.get("postalCode").equals("")) ){%><%=pers.get("postalCode")%><br><%}%>
                                                <%if(!(pers.get("country").equals("")) ){
													String country = (String)pers.get("country");
													int countryIndex = valueList.indexOf(country);
													if(countryIndex>=0) country = (String)optionList.get(countryIndex);
												%><%=country%><br><%}%></td>
                                                <%}else{%>
                                                    <% if ( !(responseType.equals("BASICS"))){%>
           								 <td class="MatrixFeel">
                                                    <% StringList memb = (StringList)pers.get(AttributeName);
                                                        if(memb.size() > 1){%>
                                                            <select><%
                                                                for (int k = 0 ; k < memb.size() ; k++) {%>
                                                                    <option><%=memb.get(k)%>
                                                                <%}%>
                                                            </select>
                                                        <%}else{
                                                            if(memb.size() == 1){%><%=memb.get(0)%>
                                                        <%}}%>
                                                    </td>
<%}%>
                                                <%}
                                            }
                                        }%>
                                </tr>
                            <%}%>
                        </table>
                    </td>
                </tr>
            </table>
        </div>
        <script>
            addFooter("javascript:editRow()","images/buttonDialogApply.gif","<%=Edit%>","<%=Edit%>","javascript:save(<%=Active%>)", "images/buttonDialogDone.gif","<%=Save%>","<%=Save%>");
        </script>
    </body>
</html>
