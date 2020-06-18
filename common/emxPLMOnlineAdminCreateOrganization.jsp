<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxPLMOnlineIncludeStylesScript.inc"%>
<%@include file = "../common/emxPLMOnlineAdminAttributesCalculation.jsp"%>
<%@include file = "../common/emxPLMOnlineAdminAuthorize.jsp"%>
<%@include file = "../emxJSValidation.inc" %>
<%--
    Document   : emxPLMOnlineAdminCreateOrganization.jsp
    Author     : LXM
    Modified :   26/05/2011 -> Replace Post by GEt for AIX
--%>
<%
     String OrganizationName = getNLS("OrganizationName");
	 String OrganizationID = getNLS("OrganizationID");
     String Street = getNLS("Street");
     String City = getNLS("City");
     String State = getNLS("State");
     String PostalCode = getNLS("PostalCode");
     String Country = getNLS("Country");
     String OrganizationParent = getNLS("OrganizationParent");
     String OrganizationType = getNLS("OrganizationType");
     String Company = getNLS("Company");
     String BusinessUnit = getNLS("BusinessUnit");
     String Department = getNLS("Department");
     String Create = getNLS("Create");
     String Search = getNLS("Search");
     String NONE = getNLS("None");
     String dest = (String)emxGetParameter(request,"dest");
     String ERR_CannotBeEmpty= getNLSMessageWithParameter("ERR_CannotBeEmpty","OrganizationName");
     String TabInteger[] = new String[2];
     TabInteger[0]=OrganizationName;
     TabInteger[1]=getNLS("Special");
     String ERRCannotContain = myNLS.getMessage("ERR_ProjectCannotContain",TabInteger);
     String ERR_OrgNameLength = myNLS.getMessage("ERR_OrgNameLength");
%>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <script>
            var xmlreqs = new Array();
            var xmlhttpOrganization = "";
            var companies = "";
            var bus = "";
            var dep="";

            function formatResponse()
            {
                xmlhttpOrganization = xmlreqs[0];
                companies ="";
                bus = "";
                dep="";
                xmlhttpOrganization.onreadystatechange=function()
                {
                    if(xmlhttpOrganization.readyState==4)
                    {
                        document.getElementById("Org_Parent").options.length=0;
                        addOptionsToSelectWithoutDoublons("Org_Parent",xmlhttpOrganization,"PLM_ExternalID","","8");

                        var orgList = xmlhttpOrganization.responseXML.getElementsByTagName("Organization");
                        for (var i = 0 ; i < orgList.length; i++){
                            var orgType= orgList[i].getElementsByTagName("org_Type");
                            var orgName= orgList[i].getElementsByTagName("PLM_ExternalID");
							// ALU4 2017.06.22 IR-530954-3DEXPERIENCER2018x Organization could not be created if the Parent Organization name includes a hyphen
							var childNodes = orgName[0].childNodes ;
							// determine organization name
							var orgNameRes = "";
							for (var j = 0; j < childNodes.length; j++)
							{
								orgNameRes = orgNameRes + childNodes[j].data ;
							}
							if (orgType[0].firstChild.data == "Company"){
								// companies = companies + ",," + orgName[0].firstChild.data;
                                companies = companies + ",," + orgNameRes;
                            }else if (orgType[0].firstChild.data == "Business Unit"){
								// bus = bus + ",," + orgName[0].firstChild.data;
                                bus = bus + ",," + orgNameRes;
                            }else if (orgType[0].firstChild.data == "Department"){
								// dep = dep + ",," + orgName[0].firstChild.data;
                                dep = dep + ",," + orgNameRes;
                            }
                        }
                        changedOrgType();
                    }
                }
            }


            function createOrganizationResult(){
                var xmlhttpCreateOrg= xmlreqs[1];
                xmlhttpCreateOrg.onreadystatechange=function()
                {
                    if(xmlhttpCreateOrg.readyState==4)
                    {
                        HideLoading();
                        var createResult = xmlhttpCreateOrg.responseXML.getElementsByTagName("createResult");
                        document.getElementById("hidethisone").style.display="block";
                        document.getElementById("messageError").innerHTML=createResult[0].firstChild.data;
                        initQueryOrganization();
                    }
                }
            }

            function initQueryOrganization(){
                xmlreq("emxPLMOnlineAdminAjaxResponse.jsp","source=Organization&responseOrg=org_Type",formatResponse,0);
            }

            function changedOrgType(typeName){
                document.getElementById("Org_Parent").length=0;
                if(typeName==null){
                    if(document.getElementById("Company").checked)typeName="Company";
                    if(document.getElementById("Business Unit").checked)typeName="Business Unit";
                    if(document.getElementById("Department").checked)typeName="Department";
                }

                //If Type=Company show only Companies
                if (typeName == "Company"){
                    var compTables = companies.split(",,");

                    if (compTables.length >10){document.getElementById("Org_Parent").size = 10;}
                    else{document.getElementById("Org_Parent").size = compTables.length;}

                    var opt0 = new Option("<%=NONE%>","<%=NONE%>");

                    document.getElementById("Org_Parent").options[0]=opt0;
                    document.getElementById("Org_Parent").options[0].style.color ="gray";
                    document.getElementById("Org_Parent").options[0].style.fontStyle ="italic";
                    document.getElementById("Org_Parent").options[0].selected ="true";

                    for (var i = 1 ; i < compTables.length ; i++ ){
                        var opt0 = new Option(compTables[i],compTables[i]);
                        document.getElementById("Org_Parent").options[i]=opt0;
                    }
                }

                if (typeName == "Business Unit" || typeName == "Department")
                {
                    var compTable = companies.split(",,");
                    var busTable = bus.split(",,");

                    if ((compTable.length+busTable.length) >10){document.getElementById("Org_Parent").size = 10;}
                    else{document.getElementById("Org_Parent").size = (compTable.length+busTable.length)-2;}

                    for (var j = 1 ; j < compTable.length ; j++ ){
                         var opt0 = new Option(compTable[j],compTable[j]);
                        document.getElementById("Org_Parent").options[j-1]=opt0;

                    }
                    for (var k = 1 ; k < busTable.length ; k++){
                        var opt1 = new Option(busTable[k],busTable[k]);
                        document.getElementById("Org_Parent").options[j-1]=opt1;
                        j=j+1;
                    }
                    document.getElementById("Org_Parent").options[0].selected=true;

                }
           }

           function getContentsForCreation() {
                 DisplayLoading();
                 var radio = "";

                 if((document.getElementById("PLM_ExternalID").value == "")){alert("<%=ERR_CannotBeEmpty%>");
                    HideLoading();
                 }else{
                    if (document.getElementById("Org_Parent").options.selectedIndex == -1){ alert("Please choose an organization parent");
                    HideLoading();
                   }else{
                       if((hasSpecialChar(document.getElementById("PLM_ExternalID").value))){
                    	alert("<%=ERRCannotContain%>" + ": " + emxUIAdminConsoleUtil.FORBIDDEN_CHARACTERS);
                        HideLoading();
                    	}
                       //IR-668265-3DEXPERIENCER2018x AJY3 Limit Organization name to 116 characters
                       else if(document.getElementById("PLM_ExternalID").value.length > 116){
                    	   alert("<%=ERR_OrgNameLength%>");
                    	   HideLoading();
                       }
                       else{
                        var form = document.getElementById("submitForm");
                        var inputs = form.getElementsByTagName("Input");
                        var paramValues ="";
                        for (var i = 0 ; i < inputs.length ; i++){
                            if( inputs[i].type!="radio"){
                                if (inputs[i].value != "" ){
                                    paramValues=paramValues+inputs[i].name+"="+encodeURIComponent(inputs[i].value)+"&";
                                }else{
                                    paramValues=paramValues+inputs[i].name+"=&";
                                }
                            }else{
                                if (inputs[i].checked){
                                    radio = inputs[i].id;
                                }
                            }
                        }
						paramValues=paramValues+"Country=";
						var country="";
						if(document.getElementById("CountryId").selectedIndex != -1){
							if(document.getElementById("CountryId").options[document.getElementById("CountryId").selectedIndex].value == "```manualEntryOptionDisplay```") {
								country=document.getElementById("CountryIdtxt").value;
							} else {
								country=document.getElementById("CountryId").options[document.getElementById("CountryId").selectedIndex].value;
							}
						}
						paramValues=paramValues+encodeURIComponent(country)+"&";
                        paramValues=paramValues+"org_Type="+radio;
                        var parentOrg="";
                        if( (radio == "Company") && (document.getElementById("Org_Parent").options.selectedIndex == 0) ){
                            parentOrg="";
                        }else{
                            parentOrg = document.getElementById("Org_Parent").options[document.getElementById("Org_Parent").options.selectedIndex].text;
                        }paramValues=paramValues+"&Org_Parent="+encodeURIComponent(parentOrg);

                        createOrgInDB(paramValues);
                    }
                }
           }
           }

        function createOrgInDB(paramValues){
            xmlreq("emxPLMOnlineAdminCreateOrganizationDB.jsp",paramValues,createOrganizationResult,1);
        }
    </script>
    </head>

    <body>

        <form action="emxPLMOnlineAdminCreateOrganizationDB.jsp" id="submitForm" name="submitForm"  method="GET">
        <script>
                addReturnMessage();
                addTransparentLoading();
            </script><%
            Enumeration eNumObj  = emxGetParameterNames(request);
            StringList listElem = new StringList();
            String plmid = "";
            String source="";


            while (eNumObj.hasMoreElements())
            {
             String nextElem = (String)eNumObj.nextElement();
             listElem.addElement(nextElem);
            }

            if (listElem.contains("PLM_ExternalID")) {
                plmid = (String)emxGetParameter(request,"PLM_ExternalID");
            }

             if (listElem.contains("source")) {
                source = (String)emxGetParameter(request,"source");
            }
            if ((plmid == null || plmid.length()<1 ) && !(source.equals("LocalAdmin")) && ( null == dest ) ){%>
                <a href="emxPLMOnlineAdminOrganization.jsp" class="link" ><%=Search%>...</a>
            <%}%>

            <table width="100%" style="height:95% ; border-color: white" border="1px">
                <tr style=" height: 50%">
                    <td>
                        <img src="images/iconSmallOrganization.gif" title="<%=getNLS("Organization")%>">
                            <table class="big">
                                <%if(plmid == null || plmid==""){%>
                                        <tr><td class="title" width="50%"><%=OrganizationName%><b style="color:red;">*</b></td>
                                    	<td><input  onkeypress="return enterEvent(event,getContentsForCreation)" type="text" size="20" name=PLM_ExternalID value="" id=PLM_ExternalID></td></tr>
                                    	 <tr><td class="title" width="50%"><%=OrganizationID%></td>
                                    	 <td><input  onkeypress="return enterEvent(event,getContentsForCreation)" type="text" size="20" name=v_name value="" id=v_name></td></tr>
                                <%}else{%>
                                    <script>
                                        addTdRE("<%=OrganizationName%> :","v_name","<%=plmid%>");
                                    </script>
                                <%}%>
                            </table>
                    </td>
                    <td>
                    	<img src="images/iconSmallAddress.gif" title="<%=getNLS("Address")%>">
                        <table class="big">
<%
	java.util.Map countryChoiceDetails = (java.util.Map) matrix.db.JPO.invoke(context, "emxOrganization", null, "getCountryChooserDetailsForHTMLDisplay", new String[]{request.getHeader("Accept-Language")}, java.util.HashMap.class);
	java.util.List optionList =  (java.util.List)countryChoiceDetails.get("optionList");
	java.util.List valueList =  (java.util.List)countryChoiceDetails.get("valueList");
	java.util.List manualEntryList =  (java.util.List)countryChoiceDetails.get("manualEntryList");
								if(plmid != ""){%>
                                    <script>
                                        addTdRE("<%=Street%>","Street","<%=emxGetParameter(request,"Street")%>");
                                        addTdRE("<%=City%>","City","<%=emxGetParameter(request,"City")%>");
                                        addTdRE("<%=State%>","State","<%=emxGetParameter(request,"State")%>");
                                        addTdRE("<%=PostalCode%>","postalCode","<%=emxGetParameter(request,"PostalCode")%>");
                                    </script>
									<tr><td class="title" width="50%"><%=Country%></td>
									<td>
									<%String countryValue = (String)emxGetParameter(request,"Country");%>
										<framework:editOptionList disabled="false" name="Country" optionList="<%=optionList%>" valueList="<%=valueList%>" sortDirection="ascending" selected="<%=countryValue%>" manualEntryList="<%=manualEntryList%>"/>
									</td></tr>
                                <%}else{%>
                                    <script>
                                        addTd("<%=Street%> ","Street","getContentsForCreation");
                                        addTd("<%=City%> ","City","getContentsForCreation");
                                        addTd("<%=State%> ","State","getContentsForCreation");
                                        addTd("<%=PostalCode%> ","PostalCode","getContentsForCreation");
									</script>
									<tr><td class="title" width="50%"><%=Country%></td>
									<td>
									<%String countryDefaultValue = (String)countryChoiceDetails.get("default");%>
										<framework:editOptionList disabled="false" name="Country" optionList="<%=optionList%>" valueList="<%=valueList%>" sortDirection="ascending" selected="<%=countryDefaultValue%>" manualEntryList="<%=manualEntryList%>"/>
									</td></tr>
                                <%}%>
                        </table>
                    </td>
                </tr>
                <tr  style="height:50%">
                    <td>
                        <img src="images/iconSmallRole.gif" title="<%=OrganizationType%>">
                        <table class="big">
                            <tr>
                                <td class="title" width="50%"><%=OrganizationType%> :</td>
                                <td>
                                    <table>
                                        <tr><td style="font-family: Arial, Helvetica, Sans-Serif ; font-weight: bold; font-size: 10pt; letter-spacing: 1pt; color : #50596f"><input type="radio" name="org_Type" id="Company" checked onclick="javascript:changedOrgType('Company')"><%=Company%></td></tr>
                                        <tr><td style="font-family: Arial, Helvetica, Sans-Serif ; font-weight: bold; font-size: 10pt; letter-spacing: 1pt; color : #50596f"> <input type="radio" name="org_Type" id="Business Unit" onclick="javascript:changedOrgType('Business Unit')"><%=BusinessUnit%></td></tr>
                                        <tr><td style="font-family: Arial, Helvetica, Sans-Serif ; font-weight: bold; font-size: 10pt; letter-spacing: 1pt; color : #50596f"> <input type="radio" name="org_Type" id="Department" onclick="javascript:changedOrgType('Department')"><%=Department%></td></tr>
                                    </table>
                                </td>
                            </tr>
                        </table>
                    </td>
                    <td>
                        <img src="images/iconSmallOrganization.gif" title="<%=OrganizationParent%>" >
                        <table class="big">
                            <tr><td class="title" width="50%"><%=OrganizationParent%> :</td>
                                <td>
                                    <select size="5" id="Org_Parent" name="Org_Parent" style="width:200px;align:middle" >

                                        <script>
                                            initQueryOrganization();
                                        </script>
                                    </select>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                                <tr style="height :2%">
                    <td align="left" style="color: red;" class="link"><b>(*)</b><%=getNLS("Required")%></td><td></td>
                </tr>
            </table>
        </form>
       <script>addFooter("javascript:getContentsForCreation()","images/buttonDialogAdd.gif","<%=Create%>","<%=Create%>");</script>
  </body>
</html>
