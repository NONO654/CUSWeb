<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="com.matrixone.vplm.posws.stubsaccess.ClientWithoutWS" %>
<%@ page import="com.matrixone.apps.common.Organization"%>
<%@ page import="com.dassault_systemes.vplmposadministrationui.uiutil.AdminUtilities" %>
<%@include file = "../common/emxPLMOnlineIncludeStylesScript.inc"%>
<%@include file = "../common/emxPLMOnlineAdminAttributesCalculation.jsp"%>
<%@include file = "../common/emxPLMOnlineAdminAuthorize.jsp"%>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <script>
 
            function appelFonction(plmexternalID,ctxUser){
                //parent.document.getElementById('frameRow').rows="50,50";
                if (ctxUser == null || ctxUser == "null") ctxUser="";
                //parent.document.getElementById('banniere').src="emxPLMOnlineLocalAdminQueryContextUser.jsp?PLM_ExternalID="+encodeURIComponent(plmexternalID)+"&ctxUser="+encodeURIComponent(ctxUser);
                parent.document.getElementById('Topos').src="emxPLMOnlineLocalAdminQueryContextUser.jsp?PLM_ExternalID="+encodeURIComponent(plmexternalID)+"&ctxUser="+encodeURIComponent(ctxUser);

            }

            function assignSecCtxLicences(){
                 //parent.document.getElementById('frameRow').rows="50,50";
                 var users = getSelectedCheckbox();
                 
                 //parent.document.getElementById('banniere').src="emxPLMOnlineLocalAdminAssignLicences.jsp?users="+users;
                 parent.document.getElementById('Topos').src="emxPLMOnlineLocalAdminAssignLicences.jsp?users="+users;
            }
           
        </script>
    </head>
    <body>
        <div class="divPageBodyVPLM" >
            <table width="98%" style="border-color: white" border="1px" >
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
                        StringList objectsSelects= new StringList();
                       
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
                        
                        StringList Orgas = AdminUtilities.getAnyAdminRoleOrganizations(mainContext);
                        StringList CompaniesOrga = new StringList();

                           StringList relationshipSelects = new StringList();

                        objectsSelects.addElement("id");
			objectsSelects.addElement("type");
			objectsSelects.addElement("name");



                        int numOrg = 0;

                        for (int j = 0 ; j  < Orgas.size(); j++){
                            MapList mapList = DomainObject.findObjects(mainContext, "Organization", (String)Orgas.get(j), "*", "*", "*", "", true, objectsSelects);
                            Map orga = (Map)mapList.get(0);
                          
                         	String iD = (String)orga.get("id");
                            String Type = (String)orga.get("type");
				String Name = (String)orga.get("name");

                            /** Getting Organization bus **/
		 
                            Organization organization1 = new Organization(iD);
                            organization1.open(mainContext);
                            
                            objectsSelects.addElement("to[Division].businessobject.name");
                            objectsSelects.addElement("to[Company Department].businessobject.name");
                            objectsSelects.addElement("to[Subsidiary].businessobject.name");
                            objectsSelects.addElement("name");

                            MapList resultList = organization1.getRelatedObjects(mainContext,"*", "Organization",true,false,99,objectsSelects,relationshipSelects,"","","","", null);
	
				for (int k = 0 ; k < resultList.size(); k++){
                                Map resultMapParent = (Map)resultList.get(k);
                            	
				    if (resultMapParent.get("type").equals("Company")){
                                    orgEmp = new HashMap();
                                    orgEmp.put("PLM_ExternalID",resultMapParent.get("name"));
                                    listOrgEmp.put("organization"+numOrg,orgEmp);
                                    CompaniesOrga.add((String)resultMapParent.get("name"));
                                    numOrg++;
                                }
				}
					
				    if(Type.equals("Company")){
					 CompaniesOrga.addElement(Name);
					 orgEmp = new HashMap();
                                    orgEmp.put("PLM_ExternalID",Name);
					 listOrgEmp.put("organization"+numOrg,orgEmp);
				    }
                            
                        }
			
			 String AssignSecCtxAndLicense = getNLS("AssignLicensesAndSecurityContexts");

        		String key = (String)session.getAttribute("PLMKey");
                        String address = request.getServerName();
                        int port = request.getServerPort();
                        String uri = request.getContextPath();

                        listperson.put("person0" ,person);

                        fin.put("method","queryPerson");
                        fin.put("iPerson",listperson);
                        fin.put("iOrganisation",listOrgEmp);
                       
                        String slec[] = new String[] {"BASICS","ORGANIZATIONS","SECCONTEXTS"};
                      
                        fin.put("iSelectableList",slec);

                        // JIC 18:07:03 FUN076129: Removed use of PLM key/added context
                        ClientWithoutWS client = new ClientWithoutWS(mainContext);

                        Map persons = client.serviceCall(fin);
                        Map personsEmploye = new HashMap();
                        int nbPers = 0;
	java.util.Map countryChoiceDetails = (java.util.Map) matrix.db.JPO.invoke(context, "emxOrganization", null, "getCountryChooserDetailsForHTMLDisplay", new String[]{request.getHeader("Accept-Language")}, java.util.HashMap.class);
	java.util.List optionList =  (java.util.List)countryChoiceDetails.get("optionList");
	java.util.List valueList =  (java.util.List)countryChoiceDetails.get("valueList");

                        for (int l = 0 ; l < persons.size(); l++){
                            Map pers = (Map)persons.get("person"+l);
                          
                            String orgEmployee = (String)pers.get("org_id");
				if (CompaniesOrga.contains(orgEmployee)){
                                personsEmploye.put("person"+nbPers, pers);
                                nbPers = nbPers +1;
                            }
                        }


                        StringList AssignCtx = AdminUtilities.getLocalAdminAssignableContexts(mainContext);
                        
                        if(personsEmploye.size() == 0 ){
                        %>
                        <script>alert("There is no person matching this criteria");</script>
                        <%}%>
                        
                        <table  id="tableRes" width="100%" style="height:50px;border-color: white" border="1px" >
                            <tr bgcolor="#b0b2c3" style="width : 100%">
				<td class="MatrixLabel"></td>
                                <td class="MatrixLabel"><%=getNLS("UserID")%></td>
                                <td class="MatrixLabel"><%=getNLS("Email")%></td>
                                <td class="MatrixLabel"><%=getNLS("FirstName")%></td>
                                <td class="MatrixLabel"><%=getNLS("LastName")%></td>
                                <td class="MatrixLabel"><%=getNLS("Address")%></td>
                                <td class="MatrixLabel"><%=getNLS("Phone")%></td>
				<td class="MatrixLabel">Accreditation</td>
                                <td class="MatrixLabel"><%=getNLS("Employee")%></td>
                                <td class="MatrixLabel"><%=getNLS("Member")%></td>
                                <td class="MatrixLabel"><%=getNLS("SecurityContexts")%></td>
                            </tr>
                            <%
                            int k = 0 ;
                            for(int i = 0 ; i <personsEmploye.size() ; i++){
                                Map pers = (Map)personsEmploye.get("person"+i);
                              
                             StringList contx = (StringList)pers.get("ctx");
                            String contextString = "";
                            StringList ctx2show = new StringList();


                            for (int j = 0; j < contx.size() ; j ++){
                               
                                if(AssignCtx.contains(contx.get(j))){
                                     contextString += contx.get(j)+ ",";
                                    ctx2show.addElement(contx.get(j));
                                }
                            }

                            StringList list_Org = (StringList)pers.get("list_Org");
                            String OrgString = "";
                            for (int l = 0; l < list_Org.size() ; l ++){
                            OrgString += list_Org.get(l)+ ",";
                            }

                            String Activating = (String)pers.get("IsActive");
			    String idPer= "Per"+i;


                            %>
                            <tr id="<%=pers.get("PLM_ExternalID")%>"  >
                                <td class="MatrixFeel">
                                     <input id="<%=pers.get("PLM_ExternalID")%>" type="checkbox">
                                    </td>
                                <td class="MatrixFeel"> 
                                    <a id="<%=idPer%>"  href="javascript:appelFonction('<%=XSSUtil.encodeForJavaScript(context,(String)pers.get("PLM_ExternalID"))%>','<%=contextString%>');"><%=pers.get("PLM_ExternalID")%></a>
                                </td>
                                <td class="MatrixFeel"><%=pers.get("v_email")%></td>
                                <td class="MatrixFeel"><%=pers.get("v_first_name")%></td>
                                <td class="MatrixFeel"><%=pers.get("v_last_name")%></td>
                                <td class="MatrixFeel"><%if(!(pers.get("street").equals("")) ){%><%=pers.get("street")%><br><%}%>
                                    <%if(!(pers.get("city").equals("")) ){%><%=pers.get("city")%><br><%}%>
                                    <%if(!(pers.get("state").equals("")) ){%><%=pers.get("state")%><br><%}%>
                                    <%if(!(pers.get("postalCode").equals("")) ){%><%=pers.get("postalCode")%><br><%}%>
                                    <%if(!(pers.get("country").equals("")) ){
													String country = (String)pers.get("country");
													int countryIndex = valueList.indexOf(country);
													if(countryIndex>=0) country = (String)optionList.get(countryIndex);
									%><%=country%><br><%}%>
                                </td>
                                <td class="MatrixFeel"><%=pers.get("v_phone")%></td>
					 <td class="MatrixFeel"><%=pers.get("Accreditation")%></td>
                                <td class="MatrixFeel"><%=pers.get("org_id")%></td>
                                <td class="MatrixFeel">
                                    <% StringList memb = (StringList)pers.get("list_Org");
                                    if(memb.size() > 1){%>
                                    <select><%
                                        for (int j = 0 ; j < memb.size() ; j++) {
                                        %>
                                        <option><%=memb.get(j)%>
                                        <%}%>
                                    </select>
                                    <%}
                                    else{
                                    if(memb.size() == 1){%><%=memb.get(0)%>
                                    <%}}%>
                                </td>
                                <td class="MatrixFeel">
                                    <% 
                                    if(ctx2show.size() > 1 ){%>
                                    <select><%
                                        for (int j = 0 ; j < ctx2show.size() ; j++) {
                                            
                                            %>
                                        <option><%=ctx2show.get(j)%>
                                        <%}%>
                                    </select>
                                    <%}
                                    else{
                                    if(ctx2show.size() == 1){%><%=ctx2show.get(0)%>
                                    <%}}%>
                                </td>
                            </tr>
                            <%}%>
                        </table>
                </td>
            </tr>

        </table>
</div>
    <!--<script>addFooter("javascript:assignSecCtxLicences()","images/buttonDialogDone.gif","<%=AssignSecCtxAndLicense%>","<%=AssignSecCtxAndLicense%>");</script>-->
    </body>
</html>
