<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.net.URLEncoder" %>
<%@include file = "../common/emxPLMOnlineIncludeStylesScript.inc"%>
<%@include file = "../common/emxPLMOnlineAdminAttributesCalculation.jsp"%>
<%@include file = "../common/emxPLMOnlineAdminAuthorize.jsp"%>
<%@ page import="com.matrixone.vplm.posws.stubsaccess.ClientWithoutWS" %>
<%@ page import="com.dassault_systemes.vplmposadministrationui.uiutil.AdminUtilities" %>
<%@ page import="com.dassault_systemes.vplmposadministrationui.uiutil.EncodeUtil" %>
<script type="text/javascript" src="scripts/emxUICore.js"></script>
<html>
<%                       String PLM_ExternalID = emxGetParameter(request,"Param1");
                      String street = emxGetParameter(request,"Param2");
                        String city = emxGetParameter(request,"Param3");
                        String state = emxGetParameter(request,"Param4");
                        String postalCode = emxGetParameter(request,"Param5");
                        String country = emxGetParameter(request,"Param6");
                        String org_Parent = emxGetParameter(request,"Param7");
                        String v_name = emxGetParameter(request,"Param8");
                        String dest = emxGetParameter(request,"dest");
                        %> 
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <script>
            function getValue(){
                parent.parent.parent.document.getElementById("sommaire").src="emxPLMOnlineAdminOrganization.jsp?&dest="+"<%=dest%>";
            }
        </script>
    </head>
    <body>
        <div class="divPageBodyVPLMNoFooter">
            <table width="100%" >
                <tr id="highRow" width="100%" style="overflow : auto">
                    <td width="100%" height="50px">
                    <%
                 	 Map organization = new HashMap();
                        Map listorganization = new HashMap();
                        Map organizationParent = new HashMap();
                        Map listorganizationParent = new HashMap();
                        Map query = new HashMap();
                        boolean checkFilter = false;
                    
			if (!AdminUtilities.isCentralAdmin(mainContext)){
                            if(!PLM_ExternalID.equals("*"))checkFilter=true;
                            StringList orgHierarchy = AdminUtilities.getAnyAdminRoleOrganizations(mainContext);
                            for (int i =0 ; i < orgHierarchy.size() ; i++){
                                organization= new HashMap();
                                organization.put("PLM_ExternalID",orgHierarchy.get(i));
                                organization.put("street",street);
                                organization.put("city",city);
                                organization.put("state",state);
                                organization.put("postalCode",postalCode);
                                organization.put("country",country);

                                listorganization.put("organization"+i,organization);
                                 String[] iSelectable= new String[3];
                                iSelectable[0] = "Person";
                                 iSelectable[1] = "childs";
                                 iSelectable[2] = "parentchild";
                                 query.put("iSelectList",iSelectable);
                            }
                        }else{
                            organization.put("PLM_ExternalID",PLM_ExternalID);
                            organization.put("v_name",v_name);
                            organization.put("street",street);
                            organization.put("city",city);
                            organization.put("state",state);
                            organization.put("postalCode",postalCode);
                            organization.put("country",country);
                    
                            listorganization.put("organization0",organization);
                             String[] iSelectable= new String[2];
                            iSelectable[0] = "Person";
                            iSelectable[1] = "parentchild";
                            query.put("iSelectList",iSelectable);
                        }

                        organizationParent.put("PLM_ExternalID",org_Parent);
                        listorganizationParent.put("organization0",organizationParent);
                    
                        query.put("method","queryOrg");
                        query.put("iOrgId",listorganization);
                        query.put("iOrgParents",listorganizationParent);
                        
                        // JIC 18:07:03 FUN076129: Removed use of PLM key/added context
                        ClientWithoutWS client = new ClientWithoutWS(mainContext);
                        Map resultat = client.serviceCall(query);
                    
                        query = new HashMap();
                        query.putAll(resultat);
                        int size = query.size();

                        String parameters[] = new String[1];
                        parameters[0]= getNLS("Organization");

                        String NLSNAme = getNLSWithParameters("ERR_ThereIsNoMatchingThisCriteria",parameters);
                        String NameNLS = getNLS("Name");
                        String TypeNLS = getNLS("OrganizationType");
                        String OrganizationID = getNLS("OrganizationID");
                        String AdressNLS = getNLS("Address");
                        String ParentNLS = getNLS("Parent");
                        String ChildrenNLS = getNLS("Child");
                        String EmployeeNLS = getNLS("Employee");
                        String MemberNLS = getNLS("Member");
                        String OrganizationFilter = getNLS("OrganizationFilter");
   
                        if (resultat.size() == 0){
                        %>
                            <script>alert("<%=NLSNAme%>");</script>
                    <%}%>
                    <table  style="height:50px ; border-color: white" border="1px" id="tableRes" width="98%"   >
<!--                        <tr valign="middle" >
                            <td  colspan="7" align="right" valign="middle">
                                <img src="images/iconSmallSearch.gif" onclick="javascript:getValue();" style="cursor : pointer"><a href="" onclick="javascript:getValue();" id="send" target="_parent" class="link"><%=OrganizationFilter%></a>
                            </td>
                        </tr> -->
                        <tr bgcolor="#b0b2c3" style="width : 100%">
                            <td class="MatrixLabel"><%=NameNLS%></td>
                            <td class="MatrixLabel"><%=OrganizationID%></td>
                            <td class="MatrixLabel"><%=TypeNLS%></td>
                            <td class="MatrixLabel"><%=AdressNLS%></td>
                            <td class="MatrixLabel"><%=ParentNLS%></td>
                            <td class="MatrixLabel"><%=ChildrenNLS%></td>
                        </tr>
                        <%
	java.util.Map countryChoiceDetails = (java.util.Map) matrix.db.JPO.invoke(context, "emxOrganization", null, "getCountryChooserDetailsForHTMLDisplay", new String[]{request.getHeader("Accept-Language")}, java.util.HashMap.class);
	java.util.List optionList =  (java.util.List)countryChoiceDetails.get("optionList");
	java.util.List valueList =  (java.util.List)countryChoiceDetails.get("valueList");
                        int num = 0;
                        for(int i = 0 ; i <resultat.size() ; i++){
                            Map pers = (Map)resultat.get("organization"+i);
                            String plmid = (String)pers.get("PLM_ExternalID");
                            if ((checkFilter == false) || (checkFilter && stringMatch(plmid,PLM_ExternalID))){
							String escplmid = EncodeUtil.escape(plmid);
                            num=num+1;
                            StringList child = (StringList)pers.get("child");
                            StringList op = (StringList)pers.get("op");
                            StringList hier = (StringList)pers.get("hier");
                            street = (String)pers.get("street");
                            city = (String)pers.get("city");
                            String type = (String)pers.get("org_Type");
                            state = (String)pers.get("state");
                            
                            String v_nameRes = (String)pers.get("v_name");
							v_nameRes = EncodeUtil.escape(v_nameRes);
                            postalCode = (String)pers.get("postalCode");
                            country = (String)pers.get("country");
                            String parent = (String)pers.get("org_Parent");
                        
                            if (parent == null || parent.length() == 0) parent = "";
							else parent = EncodeUtil.escape(parent);
                            if (street == null || street.length() == 0) street = "";
							else street = EncodeUtil.escape(street);
                            if (city == null || city.length() == 0) city = "";
							else city = EncodeUtil.escape(city);
                            if (state == null || state.length() == 0) state = "";
							else state = EncodeUtil.escape(state);
                            if (postalCode == null || postalCode.length() == 0) postalCode = "";
							else postalCode = EncodeUtil.escape(postalCode);
                            if (country == null || country.length() == 0) country = "";
                        %>
                        <tr>
                            <td class="MatrixFeel"><a href="emxPLMOnlineAdminOrganizationSubTree.jsp?suiteKey=Framework&StringResourceFileId=emxFrameworkStringResource&SuiteDirectory=common&PLM_ExternalID=<%=URLEncoder.encode(plmid)%>"><%=escplmid%></td>
                            <td class="MatrixFeel"><%=v_nameRes%></td>
                            <td class="MatrixFeel"><%=type%></td>
                            <td class="MatrixFeel"><%if(!(street.equals("")) ){%><%=street%><%}%>
                                <%if(!(city.equals("")) ){%>,<%=city%><%}%>
                                <%if(!(state.equals("")) ){%>,<%=state%><br><%}%>
                                <%if(!(postalCode.equals("")) ){%>,<%=postalCode%><%}%>
                                <%if(!(country.equals("")) ){
													int countryIndex = valueList.indexOf(country);
													if(countryIndex>=0) country = (String)optionList.get(countryIndex);
													country = EncodeUtil.escape(country);
								%>,<%=country%>
								<%}%>
                            </td>
                            <td class="MatrixFeel"><%=parent%></td>
                            <td class="MatrixFeel"><%if(child.size()>0){%>
                                <select style="background-color: #FFFFEB; width:100%" >
                                    <% for(int k=0; k<child.size(); ++k) {
									String escchild = EncodeUtil.escape((String)child.get(k));%>
                                    <option style="background-color: #FFFFEB;"><%=escchild%></option>
                                    <%}%>
                                </select>
                                <%}%>
                            </td>                          
                        </tr><%}}%>
                    </table>
                    <%if (num == 0){%>
                                           <script>alert("<%=NLSNAme%>");</script>
                   <%}%>
                </td>
            </tr>
            </table>
        </div>
    </body>
</html>        
       


