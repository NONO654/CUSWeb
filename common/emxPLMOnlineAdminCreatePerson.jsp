<%@ page import="java.util.Date"%>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.text.DateFormat"%>
<%@ page import="com.matrixone.vplm.posmodel.license.LicenseInfo" %>
<%@ page import="com.matrixone.vplm.posws.stubsaccess.ClientWithoutWS" %>
<%@ page import="com.dassault_systemes.vplmposadministrationui.uiutil.AdminUtilities" %>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxPLMOnlineIncludeStylesScript.inc"%>
<%@include file = "../common/emxPLMOnlineAdminAttributesCalculation.jsp"%>
<%@include file = "../emxJSValidation.inc" %>
<%@include file = "../common/emxPLMOnlineAdminAuthorize.jsp"%>
<%--
    Document   : emxPLMOnlineAdminCreatePerson.jsp
    Author     : LXM
    Modified :   26/05/2011 -> Replace Post by GEt for AIX
    Modified :   26/10/2011 -> Removed the form
--%>
<%!
    /*

     * Adds a line to a section
     *
     * @param id    the line id
     * @param chk   the 'checkbox' checked flag
     * @param state the line state (unknown, available, unavailable)
     * @param title the line title
     */
    public void addLine(JspWriter out, String id, boolean checked, String state, String nls_state, String title) throws IOException {
        out.println("<tr>");
        String sChecked = checked ? " checked=\"checked\"" : "";
        out.println("  <td></td>");
		// ALU4 17:08:24 IR-536079-3DEXPERIENCER2017x IFW and CSV are selected by default. This IR consists in making CSV optional.
		if(id.equals("IFW"))
        out.println("  <td><input type=\"checkbox\" id=\"lic_"+id+"_chk\" name=\"lic_"+id+"_chk\" value=\""+id+"\" onclick=\"clic(this);\" checked=\"checked\" disabled=\"disabled\"></td>");
		else
        out.println("  <td><input type=\"checkbox\" id=\"lic_"+id+"_chk\" name=\"lic_"+id+"_chk\" value=\""+id+"\" onclick=\"clic(this);\""+sChecked+"></td>");
        out.println("  <td></td>");
        out.println("  <td><img src=\"images/iconLicense"+state+".gif\" id=\"lic_"+id+"\" title=\""+nls_state+"\" style=\"cursor:pointer\"></td>");
        out.println("  <td><div id=\"lic_"+id+"_txt\">"+title+"</div></td>");
        out.println("</tr>");
    }
	    %>
<%
    String nlsINFO_UNKNOWN      =  getNLS("LicenseUnknown");
    String nlsINFO_UNAVAIL      =  getNLS("LicenseUnavailable");
    String nlsINFO_UNAVAIL_WARN =  getNLS("LicenseUnavailableWarning");
    String nlsINFO_AVAILABLE    =  getNLS("LicenseAvailable");
    String nlsINFO_SELECTALL    =  getNLS("LicenseSectionSelectUnselectAll");
    String nlsLicSection1       =  getNLS("LicenseSectionUsed");
    String nlsLicSectionFilter  =  getNLS("LicenseSectionFilter");
    String nlsLicSection2       =  getNLS("LicenseSectionOther");
    String nlsWARNING_CONTRACTOR = getNLS("WarningAdminSecurityContextsRemovedBecauseOfContractor");
     String dest = (String)emxGetParameter(request,"dest");
    String TabInteger[] = new String[2];
    TabInteger[0]=getNLS("UserID");
    TabInteger[1]=getNLS("Special");
    String ERRCannotContain = myNLS.getMessage("ERR_ProjectCannotContain",TabInteger);
    TreeMap mapUserLicenses = new TreeMap();
    TreeMap lics = new TreeMap();
    LicenseInfo.getDeclaredLicenses(context, lics, request.getLocale());
    //JIC 14:04:02 Added license status update
    LicenseInfo.updateLicensesStatus(context, lics);
    Collection licinfos = lics.values();
    %>
<html>
    <head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <style>
            div.horiz      { width:100%; position:relative; }
            div.divHauts   { height:45%; }
            div.divMilieus { height:50%; margin-left:-1px; overflow:auto; }
            div.divBass    { height:6%; }
            div.scroll-cont{
                            float:left; overflow:auto;
                            width:49%;   /* a cause des marges (et de leur gestion differente par IE et FF, il  */
                                         /* faut prendre un % de longueur inferieur a 50%                       */
                            height:100%; /* il est capital de fixer height pour que scroll-bloc ne deborde pas! */
            }
            div.licHeader {border:0px; background:#dfdfdf;}
            .tableLicMargin       {width:32; background:white; }
            .tableLicCheckbox     {width:32;}
            .tableLicAvailability {width:32;}
            .tableLicTitle        {}
        </style>
    <script>
        var xmlreqs = new Array();
        var xmlhttpOrganization = "";
        var xmlhttpContext = "";
        var xmlhttpConfidentiality = "";
        var xmlhttpCreatePerson = "";

        function formatResponseOrganization()
        {
            xmlhttpOrganization = xmlreqs[0];

            xmlhttpOrganization.onreadystatechange=function()
            {
                if(xmlhttpOrganization.readyState==4)
		{
                    addOptionsToSelect("List_Org",xmlhttpOrganization,"PLM_ExternalID","","no");
                    var response = xmlhttpOrganization.responseXML.getElementsByTagName("org_Type");
                    var responsePLMID = xmlhttpOrganization.responseXML.getElementsByTagName("PLM_ExternalID");

                    for(var i = 0 ; i < response.length ; i++ ){
                        var respType = response[i].firstChild.data;
			if (respType == "Company"){
                            var nameElement = responsePLMID[i].firstChild.data;
                            var nouvel_element = new Option(nameElement,nameElement,false,true);
                            document.getElementById("org_id").options[document.getElementById("org_id").length] = nouvel_element;
                            if(document.getElementById("org_id").size <= 10){
                                document.getElementById("org_id").size=document.getElementById("org_id").size+1;
                            }
			}
                    }
		}
				document.getElementById("loadingOrgAndCtx").style.display = "none";
            }
        }

        function formatResponseContext(){
                xmlhttpContext = xmlreqs[2];

                xmlhttpContext.onreadystatechange=function()
                {
                    if(xmlhttpContext.readyState==4)
                    {
                            xmlreq("emxPLMOnlineAdminAjaxResponse.jsp","source=Organization&responseOrg=org_Type",formatResponseOrganization,0);
                            addOptionsToSelect("ctx_id",xmlhttpContext,"PLM_ExternalID","","no");
            }
                }

        }

        function formatResponseConfidentiality(){
            xmlhttpConfidentiality = xmlreqs[3];
            xmlhttpConfidentiality.onreadystatechange=function()
                {
                    if(xmlhttpConfidentiality.readyState==4)
            {
                    //xmlreq("emxPLMOnlineAdminAjaxResponse.jsp","source=Context",formatResponseContext,2);
                         xmlreq("emxPLMOnlineAdminAjaxResponse.jsp","source=Organization&responseOrg=org_Type",formatResponseOrganization,0);
                        var secLevel = xmlhttpConfidentiality.responseXML.getElementsByTagName("Name");
                        for(var i = 0 ; i < secLevel.length ; i++ ){
                            var respType = secLevel[i].firstChild.data;
                var nouvel_element = new Option(respType,respType,false,true);
                document.getElementById("secLevel").options[document.getElementById("secLevel").length] = nouvel_element;
                        }
            }
                }
            }

            function createPersonResult(){
                xmlhttpCreatePerson= xmlreqs[4];
                xmlhttpCreatePerson.onreadystatechange=function()
                {
                    if(xmlhttpCreatePerson.readyState==4)
            {
                        HideLoading();
                        var createResult = xmlhttpCreatePerson.responseXML.getElementsByTagName("createResult");
                        document.getElementById("hidethisone").style.display="block";
                        document.getElementById("messageError").innerHTML=createResult[0].firstChild.data;
            }
                }
            }

        function initQueryOrganizationAndContext(){
				document.getElementById("loadingOrgAndCtx").style.display = "block";
                xmlreq("emxPLMOnlineAdminAjaxResponse.jsp","source=Confidentiality",formatResponseConfidentiality,3);
        }

        function getContentsForCreation() {
            if(!document.getElementById("List_Org").value) { window.alert('you must choose at least one member of org'); }

            else if (hasSpecialChar(document.getElementById("PLM_ExternalID").value)){
                alert("<%=ERRCannotContain%>" + ": " + emxUIAdminConsoleUtil.FORBIDDEN_CHARACTERS);
                HideLoading();
            }else if((document.getElementById("PLM_ExternalID").value == "")){alert("User ID cannot be empty");}
            else if(!IsEMail(document.getElementById("V_email").value)){alert("Email address is not valid");}
            //else if(!IsAlphaString(document.getElementById("V_first_name").value) && (document.getElementById("V_first_name").value.length >0)){alert("Your First Name is not valid");}
            //else if(!IsAlphaString(document.getElementById("V_last_name").value) && (document.getElementById("V_last_name").value.length >0)){alert("Your Last Name is not valid"); }
            else if(!IsPhoneNumber(document.getElementById("V_phone").value) && (document.getElementById("V_phone").value.length >0) ){alert("Your Home Phone number is not valid");}
            else if(!IsPhoneNumber(document.getElementById("Work_Phone_Number").value) && (document.getElementById("Work_Phone_Number").value.length >0) ){alert("Your Office Phone number is not valid");}
            else if(!document.getElementById("ctx_id").value) { window.alert('you must choose at least one security context'); }

            else{
                DisplayLoading();
                var inputs = document.getElementsByTagName("Input");
                var Licences = "";
                var paramValues ="";
                for (var i = 0 ; i < inputs.length ; i++){
                    if ((inputs[i].type=="checkbox") && (inputs[i].checked) && !(inputs[i].disabled=="true") && (inputs[i].id.indexOf("lic_") == 0)){
                        Licences = Licences+inputs[i].id+",,";
                        continue;
                    }
                    if (inputs[i].name != "" && inputs[i].type == "text") {
                        if(inputs[i].value != "") {
                            paramValues=paramValues+inputs[i].name+"="+encodeURIComponent(inputs[i].value)+"&";
                        } else {
                            paramValues=paramValues+inputs[i].name+"=&";
                        }
                    }
                }
                paramValues=paramValues+"ctx_id=";
                var ctxNames = "";
                var contexts = document.getElementById("ctx_id");
                for (var j=0; j<contexts.options.length ;j++){
                    if (contexts.options[j].selected){
                       //RBR2: FUN[080973] OLD code: ctxNames=ctxNames+encodeURIComponent(contexts.options[j].text)+",";
                       ctxNames=ctxNames+encodeURIComponent(contexts.options[j].id.toString())+",";
                    }
                }
                ctxNames=ctxNames.substring(0,ctxNames.length-1);
                paramValues=paramValues+ctxNames+"&secLevel=";
                var secName="";
                if(document.getElementById("secLevel").selectedIndex != 0){
                    secName=document.getElementById("secLevel").options[document.getElementById("secLevel").selectedIndex].text;
                }
                paramValues=paramValues+encodeURIComponent(secName);

                paramValues=paramValues+"&Country=";
                var country="";
                if(document.getElementById("CountryId").selectedIndex != -1){
					if(document.getElementById("CountryId").options[document.getElementById("CountryId").selectedIndex].value == "```manualEntryOptionDisplay```") {
						country=document.getElementById("CountryIdtxt").value;
					} else {
						country=document.getElementById("CountryId").options[document.getElementById("CountryId").selectedIndex].value;
					}
                }
                paramValues=paramValues+encodeURIComponent(country);

                paramValues=paramValues+"&List_Org=";
                var orgNames = "";
                var orgs = document.getElementById("List_Org");
                for (var j=0; j<orgs.options.length ;j++){
                    if (orgs.options[j].selected){
                        orgNames=orgNames+encodeURIComponent(orgs.options[j].text)+",";
                    }
                }
                paramValues=paramValues+orgNames+"&org_id=";
                orgNames=orgNames.substring(0,orgNames.length-1);
                var orgName=document.getElementById("org_id").options[document.getElementById("org_id").selectedIndex].text;
                paramValues=paramValues+encodeURIComponent(orgName);

                paramValues=paramValues+"&Activated=";
                var orgName=document.getElementById("Active");
                if(orgName.checked){
                    paramValues=paramValues+"true";
                }
                else{
                    paramValues=paramValues+"false";
                }

                // JIC 2014:10:24 Added contractor support
                paramValues=paramValues+"&Contractor=";
                var Contractor=document.getElementById("Contractor");
                if (Contractor.checked){
                    paramValues=paramValues+"true";
                }
                else {
                    paramValues=paramValues+"false";
                }

                // JIC 2015:04:24 Added Casual Hour support
                if (document.getElementById("Casual") != null) {
                    paramValues=paramValues+"&CasualHour="+(document.getElementById("Casual").checked==true?"40":"0");
                }

                paramValues=paramValues+"&licences="+Licences;
                createPersonInDB(paramValues);
            }
        }

        function createPersonInDB(paramValues){
                xmlreq("emxPLMOnlineAdminCreatePersonDB.jsp",paramValues,createPersonResult,4);
        }

        function clic(elem)
        {
            var id = elem.id.substring(0,elem.id.length-4);
            var img = $(id);
            if (!elem.checked) {
                // now unchecked
                // checking whether there was a 'warning' msg
                if (img != undefined) {
                    if (img.src.indexOf('iconLicenseError.gif')>=0) {
                        // there was a warning : reset to 'unavailable'
                        setUnavailable(img);
                    }
                }
            }
            else {
                // now checked
                if (img != undefined) {
                    if (img.src.indexOf('iconLicenseUnavailable.gif')>=0) {
                        // warning : reset to 'unavailable'
                        setUnavailable(img);
                    }
                }
            }
        }

        // update NLS title help
        nlsINFO_SELECTALL      = "<%=nlsINFO_SELECTALL%>";
        nlsINFO_AVAILABLE      = "<%=nlsINFO_AVAILABLE%>";
        nlsINFO_UNAVAIL        = "<%=nlsINFO_UNAVAIL%>";
        nlsSECTION_AVAIL          = "<%=myNLS.getMessage("LicenseSectionAvailable")%>";
        nlsSECTION_UNAVAIL_RICH   = "<%=myNLS.getMessage("LicenseSectionUnavailableRich")%>";
        nlsSECTION_UNAVAIL_SERVER = "<%=myNLS.getMessage("LicenseSectionUnavailableServer")%>";
        nlsWARNING_CONTRACTOR  = "<%=nlsWARNING_CONTRACTOR%>";

        var prev_filter_lic = "";
        var filter_lic = false;

        function initLic(){
             /* Request to get the Licenses */
            xmlreq("emxPLMOnlineAdminXHRLicenseGet.jsp","",getLicensesResponse,1);
        }

        // 2014:10:24 Added method "refreshAdminSecurityContexts" for Contractor support
        function refreshAdminSecurityContexts() {
            var isHiddenContext = false;
            var isContractor = document.getElementById("Contractor").checked;
            var contexts = document.getElementById("ctx_id");
            for (var j=0; j<contexts.options.length ;j++){
                var contextName = contexts.options[j].text;
                var roleName = contextName.substring(0, contextName.indexOf("."));
                // Note: Following code will not work with custom admin roles
                if (roleName == "VPLMAdmin") {
                    if (isContractor){
                        contexts.options[j].selected = false;
                        contexts.options[j].disabled = 'true';

                        isHiddenContext = true;
                    }
                    else{
                        contexts.options[j].disabled = '';
                    }
                }
            }

            if (isHiddenContext){
                alert(nlsWARNING_CONTRACTOR);
            }
        }

        // JIC 15:04:24 Added function "CheckUncheckCasual"
        function CheckUncheckCasual() {
            var destCasualHour = "CasualHour="+(document.getElementById("Casual").checked==true?"40":"0");
            xmlreq("emxPLMOnlineAdminXHRLicenseGet.jsp",destCasualHour,getLicensesResponse,1);
        }
    </script>
    </head>
    <%
	String FirstName= getNLS("FirstName");
	String LastName= getNLS("LastName");
	String Email= getNLS("Email");
	String Phone= getNLS("HomePhone");
	String Street= getNLS("Street");
	String City= getNLS("City");
	String State= getNLS("State");
	String PostalCode= getNLS("PostalCode");
	String SecurityContexts=getNLS("SecurityContexts");
	String Create=getNLS("Create");
	String WorkPhone= getNLS("WorkPhone");

	%>
        <body onload="javascript:initLic()" style=" height: 100% ; position: absolute ; width: 100%" >
         <script>addTransparentLoading("");</script>
         <script>addReturnMessage();</script>
          <div class="haut">
	<%if(dest==null) {%>
              <a href="emxPLMOnlineAdminPerson.jsp" class="link" ><%=getNLS("Search")%>...</a>
	<%}%>
        </div>
        <div style="height: 96% ; overflow: auto ; ">
	       	<div class="divHauts horiz" >
	       	<div class="scroll-cont" style="width: 60%">
            <table width="100%" >
                <tr style=" height: 100%">
                    <td >
                        <table class="big" >
                            <thead><img src="images/iconSmallPeople.gif" title="<%=getNLS("UserProfile")%>"></thead>
                            <tr>
                                <td class="title" width="25%" ><%=getNLS("UserID")%><b style="color:red;">*</b></td>
                                <td><input onkeypress="return enterEvent(event,getContentsForCreation)" type="text" size="20" id="PLM_ExternalID" name="PLM_ExternalID" value=""></td>
                                <td  class="title"><%=getNLS("UserAlias")%></td>
                                <td><input type="text" size="20" id="V_distinguished_name" name="V_distinguished_name" value=""></td>
                            </tr>
                            <script>
                                addTr("<%=FirstName%>","V_first_name","<%=LastName%>","V_last_name", "getContentsForCreation");
                               addTr("<%=Phone%>","V_phone","<%=Email%>","V_email", "getContentsForCreation");
                            </script>
                            <tr><td class="title"><%=WorkPhone%></td>
                                <td>
                                    <input onkeypress="return enterEvent(event,getContentsForCreation)" type="text" size="20" id="Work_Phone_Number" name="Work_Phone_Number" value="">
                                </td>
                                <td  class="title"><%=getNLS("SecurityLevel")%></td>
                                <td>
                                    <select  name="secLevel" id="secLevel" onkeypress="return enterEvent(event,getContentsForCreation)">
                                        <option style="color:gray ; font-style : italic" selected value=""><%=getNLS("None")%></option>
                                   </select>
                                </td>
                            </tr>
        	                    <tr><hr></tr>
                        </table>
                    </td>
                    <td>
                        <table class="big">
                            <thead><img src="images/iconSmallAddress.gif" title="<%=getNLS("Address")%>"></thead>
                            <script>
                                addTr("<%=Street%>","Street","<%=City%>","City", "getContentsForCreation");
                                addTr("<%=State%>","State","<%=PostalCode%>","postalCode", "getContentsForCreation");
                            </script>
                            <tr><td class="title" ><%=getNLS("Country")%></td>
  <td>
<%
	java.util.Map countryChoiceDetails = (java.util.Map) matrix.db.JPO.invoke(context, "emxOrganization", null, "getCountryChooserDetailsForHTMLDisplay", new String[]{request.getHeader("Accept-Language")}, java.util.HashMap.class);
	java.util.List optionList =  (java.util.List)countryChoiceDetails.get("optionList");
	java.util.List valueList =  (java.util.List)countryChoiceDetails.get("valueList");
	java.util.List manualEntryList =  (java.util.List)countryChoiceDetails.get("manualEntryList");
	String countryDefaultValue = (String)countryChoiceDetails.get("default");
%>
         <framework:editOptionList disabled="false" name="Country" optionList="<%=optionList%>" valueList="<%=valueList%>" sortDirection="ascending" selected="<%=countryDefaultValue%>" manualEntryList="<%=manualEntryList%>"/>
    </td>
                            </tr>
                            <tr><td  class="title"><%=getNLS("Active")%></td>
                                <td><input type="checkbox" checked id="Active" name="Active" onkeypress="return enterEvent(event,getContentsForCreation)" ></td>
                            </tr>
                            <!-- 2014:10:24 Added "Contractor" checkbox for Contractor support -->
                            <tr><td  class="title"><%=getNLS("Contractor")%></td>
                                <td><input type="checkbox" id="Contractor" name="Contractor" onkeypress="return enterEvent(event,getContentsForCreation)" onchange="refreshAdminSecurityContexts()" ></td>
                            </tr>
        	                <tr><hr></tr>
                       </table>
                    </td>
                </tr>
            </table>
    		</div>
            <div id="lics" style="width:38%; margin-left:3px;" class="scroll-cont">
                <img src="../common/images/iconSmallCommonLicensingApp.gif">
                <div id="lics_section1_container">
                    <!-- JIC 15:04:24 Added License type -->
                    <div id="lics_section1_casual">
                        <table class="titleLic" border="0" cellspacing="0" cellpadding="0" width="100%">
                            <colgroup>
                                <col class="tableLicMargin" />
                                <col class="tableLicCheckbox" />
                                <col class="tableLicTitle" />
                            </colgroup>
                            <tr>
                                <td/>
                                <td>
                                <input type="checkbox" id="Casual" name="Casual" onchange="javascript:CheckUncheckCasual()" />
                                </td>
                                <td/>
                                <td><div id="CasualLicenseType"><%=getNLS("LicenseAssignCasual")%></div></td>
                            </tr>
                        </table>
                    </div>
                    <div id="lics_section1_w_filter" class="licHeader">
                    <table  border="0" cellspacing="0" cellpadding="0" width="100%" colspan="4*,*"><tr>
                        <td><div id="lics_section1">
                                <table class="titleLic" border="0" cellspacing="0" cellpadding="0" width="100%">
                                <colgroup>
                                    <col class="tableLicCheckbox" />
                                    <col class="tableLicCheckbox" />
                                    <col class="tableLicTitle" />
                                </colgroup>
                                <tr>
                                    <td onclick="toggleSection('lics_section1');">
                                        <img src="images/iconSectionCollapse.gif" id="lics_section1_img">
                                    </td>
                                    <td>
                                        <input id="lics_section1_chk" type="checkbox" onclick="toggleCheckLicense(this,'lics_section1_table');" title="<%=nlsINFO_SELECTALL%>">
                                    </td>
                                    <td >
                                        <%=nlsLicSection1%>
                                    </td>
                                </tr>
                            </table>
                        </div></td>
                        <td >
                            <div>
                                <input id="lic_filter" type="text" title="<%=nlsLicSectionFilter%>" value="" onkeyup="license_filter(this,['lics_section1_table','lics_Available_table','lics_UnavailRich_table','lics_UnavailServer_table']);" />
                            </div>
                        </td>
                    </tr><tr><hr></tr></table>
                    </div>
                    <div id="lics_section1_body" width="100%">
                        <!-- JIC 15:04:16 Removed div contents (added automatically by getLicensesResponse instead) -->
                    </div>
                </div>
                <div id="lics_section0_container">
                    <div id="lics_section0" class="licHeader">
                            <table class="titleLic" border="0" cellspacing="0" cellpadding="0" width="100%">
                                <colgroup>
                                    <col class="tableLicCheckbox" />
                                    <col class="tableLicCheckbox" />
                                    <col class="tableLicTitle" />
                                </colgroup>
                                <tr>
                                    <td>
                                        <img src="images/iconSectionCollapse.gif" id="lics_section0_img">
                                    </td>
                                    <td>
                                    </td>
                                    <td>
                                        <%=nlsLicSection2%>
                                    </td>
                                </tr>
                            </table>
                    </div>
                    <div id="lics_section0_body" width="100%">
                        <table class="titleLic" id="lics_section1_table" border="0" cellspacing="0" cellpadding="0" width="100%">
                            <colgroup>
                                <col class="tableLicMargin" />
                                <col class="tableLicCheckbox" />
                                <col class="tableLicAvailability" />
                                <col class="tableLicTitle" />
                            </colgroup>
                                <tr>
                                    <td> </td>
                                    <td> </td>
                                    <td> </td>
                                    <td>
                                        <img src="images/iconLoader.gif">
                                    </td>
                                </tr>

                        </table>
                    </div>
                </div>
                <div id="lics_section3_container" style="display:none;">
                </div>
            </div>
            </div>
            <div class="divMilieus horiz" >
			<script>addTransparentLoadingInSession("none","loadingOrgAndCtx");</script>
            <table width="100%" style="height:95% ; border-color: white" >
                <tr>
                    <td>
                        <table class="big">
                            <thead><img src="images/iconSmallContext.gif" title="<%=getNLS("SecurityContexts")%>"></thead>
                             <tr>
                                 <td class="title"><%=SecurityContexts%><b style="color:red;">*</b></td>
                                 <td><select multiple onkeypress="return enterEvent(event,getContentsForCreation)" size="10" id="ctx_id" name="ctx_id" ><%
                                     Map param = new HashMap();
                                     param.put("PLM_ExternalID","*");
                                     // RBR2: FUN [080973]
                                     //  RBR2: Code is managed at server side, hence no content management in JS
                                     param.put("V_Name","*");
                                     Map lisc = new HashMap();
                                     lisc.put("context0",param);
                                     Map fin = new HashMap();
                                     fin.put("method","queryContext");
                                     fin.put("iContextInfo",lisc);
                                     // JIC 18:07:03 FUN076129: Removed use of PLM key/added context
                                     ClientWithoutWS client = new ClientWithoutWS(mainContext);
                                     Map result = client.serviceCall(fin);
                                     Map contextResult = (Map)result.get("context");
                                     for (int i = 0 ; i < contextResult.size() ; i++) {
                                         Map temp = (Map)contextResult.get("context"+i);
                                         String PLM = (String)temp.get("PLM_ExternalID");
                                         // RBR2: Added FUN [080973]
                                         String V_Name = (String)temp.get("V_Name");
                                         %>
                                         <option id ="<%=PLM%>" value="<%=V_Name%>" title="Name: <%=PLM%>"><%=V_Name%>
                                         </option>
                                         <%
                                     }%>
                                 </select></td>
                             </tr>
        	                    <tr><hr></tr>
                        </table>
                    </td>
                    <td>
                        <table  class="big">
                            <script>
                                initQueryOrganizationAndContext();
                            </script>
                            <thead><img src="images/iconSmallOrganization.gif" title="<%=getNLS("Organizations")%>"></thead>
                            <tr>
                                <td class="title"  width="25%"><%=getNLS("MemberOf")%><b style="color:red">*</b></td>
                                <td>
                                    <select multiple  size="10" name="List_Org" id="List_Org"   onkeypress="return enterEvent(event,getContentsForCreation)">
                                    </select>
                                </td>
                                <td class="title"  ><%=getNLS("Employee")%></td>
                                <td>
                                    <select size="0"  id="org_id" name="org_id" valign="top" onkeypress="return enterEvent(event,getContentsForCreation)">
                                    </select>
                                </td>
                            </tr>
        	                    <tr><hr></tr>
                         </table>
                    </td>
                </tr>
                <tr style="height :2%">
                    <td align="left" style="color: red;" class="link"><b>(*)</b><%=getNLS("Required")%></td><td></td>
                </tr>
            </table>
    </div>
    </div>
    <script>addFooter("javascript:getContentsForCreation()","images/buttonDialogAdd.gif","<%=Create%>","<%=Create%>");</script>
   </body>
</html>
