<%@ page import="java.util.Date"%>
<%@ page import="java.util.Date"%>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.text.DateFormat"%>
<%@ page import="java.net.URLEncoder" %>
<%@include file = "../common/emxPLMOnlineIncludeStylesScript.inc"%>
<%@include file = "../common/emxPLMOnlineAdminAttributesCalculation.jsp"%>
<%@include file = "emxPLMOnlineAdminLicensesUtil.inc"%>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@ page import="com.matrixone.vplm.posmodel.license.LicenseInfo" %>
<%@ page import="com.dassault_systemes.vplmposadministrationui.uiutil.AdminUtilities" %>
<%@include file = "../emxJSValidation.inc" %>
<%@include file = "../common/emxPLMOnlineAdminAuthorize.jsp"%>
<script type="text/javascript" src="scripts/emxUICore.js"></script>

<%--
    Document   : emxPLMOnlineAdminXPPerson.jsp
    Author     : LXM
    Modified :   26/05/2011 -> Replace Post by GEt for AIX
--%>
<%  //NLS Section
    String Roles[][]= new String[7][2];
    Roles[0][0] = "VPLMProjectAdministrator";
    Roles[0][1] = getNLS("VPLMProjectAdministrator");
    Roles[1][0] = "VPLMCreator";
    Roles[1][1] = getNLS("VPLMCreator");
    Roles[2][0] = "VPLMExperimenter";
    Roles[2][1] = getNLS("VPLMExperimenter");
    Roles[3][0] = "VPLMProjectLeader";
    Roles[3][1] = getNLS("VPLMProjectLeader");
    Roles[4][0] = "VPLMViewer";
    Roles[4][1] = getNLS("VPLMViewer");
    Roles[5][0] = "VPLMSecuredCrossAccess";
    Roles[5][1] = getNLS("VPLMSecuredCrossAccess");
    // JIC 13:10:08 IR-260240V6R2014x: Added role "Domain Expert"
    Roles[6][0] = "Domain Expert";
    Roles[6][1] = getNLS("DomainExpert");

    String ResultString[]= new String[5];
    ResultString[0]     = getNLS("YourPersonHasBeenCreated");
    ResultString[1]     = getNLSMessageWithParameter("ERR_CreationRight","UserID");
    ResultString[2]     = getNLSMessageWithParameter("ERR_IDCannotBeEmpty","UserID");
    ResultString[4]     = getNLSMessageWithParameter("ERR_IDAlreadyExist","PersonID");
    String  ERR_CannotBeEmpty= getNLSMessageWithParameter("ERR_CannotBeEmpty","UserID");
    String UserId       = getNLS("UserID");
    String Email        = getNLS("Email");
    String FirstName    = getNLS("FirstName");
    String LastName     = getNLS("LastName");
    String Phone        = getNLS("HomePhone");
    String Street       = getNLS("Street");
    String City         = getNLS("City");
    String State        = getNLS("State");
    String PostalCode   = getNLS("PostalCode");
    String Country      = getNLS("Country");
    String FilterProjects = getNLS("FilterProject");
    String create       = getNLS("Create");
    String WorkPhone    = getNLS("WorkPhone");
    String current    = getNLS("CurrentOrganization");
    String Member    = getNLS("Member");
    String Employee    = getNLS("Employee");
    String TabInteger[] = new String[2];
    TabInteger[0]=UserId;
    TabInteger[1]=getNLS("Special");
    String ERRCannotContain = myNLS.getMessage("ERR_ProjectCannotContain",TabInteger);
	String TabInteger1[] = new String[3];
    TabInteger1[0]=getNLS("0");
    TabInteger1[1]=getNLS("40");
	TabInteger1[2]=getNLS("40");

    String nlsINFO_FullCasual = myNLS.getMessage("LicenSectionFullOrCasual",TabInteger1);
%>
<%
    String target="";
    String source = (String)emxGetParameter(request,"source");
    String message = (String)emxGetParameter(request,"message");
    String HostCompanyName = getHostCompanyName(mainContext);

    TreeMap mapUserLicenses = new TreeMap();
    String sPersonId="";
    if (sPersonId.length()>0) {
        Vector lListOfUserLicenses = new Vector();
        LicenseInfo.getUserLicenses(context, sPersonId, lListOfUserLicenses);
        for (int i = 0; i < lListOfUserLicenses.size(); i++) {
            String s = (String)lListOfUserLicenses.get(i);
            mapUserLicenses.put(s,s);
        }
    }

    TreeMap lics = new TreeMap();
    LicenseInfo.getDeclaredLicenses(context, lics, request.getLocale());
    //JIC 14:04:02 Added license status update
    LicenseInfo.updateLicensesStatus(context, lics);
    Collection licinfos = lics.values();
    java.util.List info = LicenseUtil.getLicenseInfo( mainContext, null );
    Map LicenseMap = new HashMap();
%>
    <script>
        var xmlLicences = "";
        </script>
<%
    for( int i=0, len=info.size(); i<len; i++ ) {
        HashMap rowmap = (HashMap)info.get(i);
    %>
    <script>
         xmlLicences = xmlLicences + "<%=rowmap.get(LicenseUtil.INFO_LICENSE_NAME)%>" + "||" + "<%=rowmap.get(LicenseUtil.INFO_CASUAL_HOUR)%>"+";;";
    </script>
    <%    LicenseMap.put(rowmap.get(LicenseUtil.INFO_LICENSE_NAME),rowmap.get(LicenseUtil.INFO_CASUAL_HOUR));
    }
%>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <style>
            div.horiz      { width:100%; position:relative; }
            div.divHauts   { height:40%;}
            div.divMilieus { height:52%; margin-left:2px; overflow:auto; }
            div.scroll-cont{
                            float:left; overflow:auto;
                         /* a cause des marges (et de leur gestion differente par IE et FF, il  */
                                         /* faut prendre un % de longueur inferieur a 50%                       */
                            height:100%; /* il est capital de fixer height pour que scroll-bloc ne deborde pas! */
            }
            div.scroll-contOrg{
                            float:left; overflow:auto;
                            width:22%;   /* a cause des marges (et de leur gestion differente par IE et FF, il  */
                                         /* faut prendre un % de longueur inferieur a 50%                       */
                            height:100%; /* il est capital de fixer height pour que scroll-bloc ne deborde pas! */
            }
            div.licHeader {border:0px; background:#dfdfdf;}
            .tableLicMargin       {width:32; background:white; }
            .tableLicCasual       {width:35; }
            .tableLicCheckbox     {width:32;}
            .tableLicAvailability {width:32;}
            .tableLicTitle        {}
            .matrixCell{ font-weight: bold ; font-size: 12pt; background-color:#659ac2 ; color: white;}
        </style>
        <script>

        // update NLS title help
        nlsINFO_SELECTALL      = "<%=nlsINFO_SELECTALL%>";
        nlsINFO_AVAILABLE      = "<%=nlsINFO_AVAILABLE%>";
        nlsINFO_UNAVAIL        = "<%=nlsINFO_UNAVAIL%>";
	  	nlsINFO_UNAVAIL_WARN        = "<%=getNLS("LicenseUnavailableWarning")%>";
        nlsSECTION_AVAIL          = "<%=getNLS("LicenseSectionAvailable")%>";
        nlsSECTION_UNAVAIL_RICH   = "<%=getNLS("LicenseSectionUnavailableRich")%>";
        nlsSECTION_UNAVAIL_SERVER = "<%=getNLS("LicenseSectionUnavailableServer")%>";
		nlsINFO_FullCasual ="<%=nlsINFO_FullCasual%>";


        var prev_filter_lic = "";
        var filter_lic = false;
        var xmlreqs = new Array();
        var host="";
        var xmlhttp = "";
        var xmlhttpRole = "";
        var projects="";
        var roles = "";


        function displayProjectMatrix()
        {
            xmlhttp = xmlreqs[2];
            if(xmlhttp.readyState==4)
            { document.getElementById("imageWaiting").style.display = 'none';

                projects =xmlhttp.responseXML.getElementsByTagName("Project");
                var table=document.getElementById('TableToFilter');

                for (var i = 0 ; i <projects.length ; i++){
                    var row=table.insertRow(-1);
                    var cell=row.insertCell(-1);
                    cell.className = "matrixCell";
                    // RBR2: Dont disturb the DOM
                    cell.style.display = "none";
                    
                    //var prjName =projects[i].getElementsByTagName("PLM_ExternalID").item(0).firstChild.data;
                    //cell.innerHTML=projects[i].getElementsByTagName("PLM_ExternalID").item(0).firstChild.data.htmlEncode();
					//LFE 17/11/16 IR-476183-3DEXPERIENCER2016x
                    var prjName =projects[i].getElementsByTagName("PLM_ExternalID").item(0).textContent;
                    cell.innerHTML=projects[i].getElementsByTagName("PLM_ExternalID").item(0).textContent.htmlEncode();
                    
                    
                    var cellTitle =row.insertCell(-1);
                    cellTitle.className = "matrixCell";
                  	//RBR2: Title FUN[080973]
                    var prjNameTitle =projects[i].getElementsByTagName("V_Name").item(0).textContent; 
                    cellTitle.id=prjName
                    var titleTextNode = document.createElement("span");
                     titleTextNode.setAttribute("title","Name:"+prjName);
                    titleTextNode.innerHTML = projects[i].getElementsByTagName("V_Name").item(0).textContent.htmlEncode();
                    cellTitle.appendChild(titleTextNode);
                    
                    
                    
                    for (var j = 0 ; j <roles.length ; j++){
                        var cell=row.insertCell(-1);
                        var roleName = roles[j].getElementsByTagName("PLM_ExternalID").item(0).firstChild.data;
                   var roleNameNLS = roleName;
                   <%for (int i = 0 ; i < 7 ; i ++){%>
                   if ("<%=Roles[i][0]%>" == roleName)roleNameNLS="<%=Roles[i][1]%>";
                   <%}%>

                        var string = prjName+"!!"+roleName;
                        var secCtx = roleNameNLS+" / "+prjName;

                        string = ReplaceAllOccurence(string," ",",");
                        cell.innerHTML="<input type='checkbox' align='center'  id="+string+" title='"+secCtx+"' >";
                   }
               }

            }

        }

       function displayRoleMatrix()
       {
            xmlhttpRole = xmlreqs[0];
           if(xmlhttpRole.readyState==4)
           {
           	roles =xmlhttpRole.responseXML.getElementsByTagName("Role");
           	xmlreq("emxPLMOnlineAdminAjaxResponse.jsp","source=Organization&Destination=VPLMAdmin&filterOrg=*&responseOrg=org_Type",displayRoleMatrixWithOrganization,6);
          }
      }

       
       function filterStringsNew(){
           var doc = document.getElementById("FilterArea").value;
		   var regex = /\*/g;
		   doc = doc.replace(regex,".*");
           var row= document.getElementById("TableToFilter").rows;
           for (var i = 1 ; i < row.length ; i++){
                row[i].style.display = "";
            }
           for (var i = 1 ; i < row.length ; i++){
                /*var nom = row[i].cells[1].innerHTML;*/
        	   	var nom = row[i].cells[1].textContent; 
        	   	//TODO: case sensitivity check
                 if (nom.match(doc) == null){
                    row[i].style.display = "none";
                }
           }
       }

       function displayRoleMatrixWithOrganization()
       {
            var xmlhttpOrg = xmlreqs[6];
           if(xmlhttpOrg.readyState==4)
           {
               var table=document.getElementById('TableToFilter');
           	var response = xmlhttpOrg.responseXML.getElementsByTagName("org_Type");
            var responsePLMID = xmlhttpOrg.responseXML.getElementsByTagName("PLM_ExternalID");

               var row=table.insertRow(-1);
               var cell=row.insertCell(-1);
               cell.style.fontSize = "10pt";
               cell.style.fontWeight = "bold";
               cell.style.height = "30px";

               cell.innerHTML="<%=FilterProjects%>"+" <input size='5'  id='FilterArea' onkeyup='javascript:filterStringsNew();'>";



               	var table1=document.getElementById('TableOrg');
               	var row2=table1.insertRow(-1);
               	var row1=table1.insertRow(-1);
               	var cell1=row1.insertCell(-1);
               	cell1.className="title";
			cell1.style.width = "200px";
               	cell1.innerHTML="<%=Member%>"+":";

            	var cell2=row1.insertCell(-1);
               	cell2.style.fontSize = "10pt";
               	cell2.style.fontWeight = "bold";
               	cell2.style.width = "250px";
               	cell2.style.height = "30px";

               	cell2.innerHTML=" <select size='5'  id='FilterArea1'>";
               	addOptionsToSelect("FilterArea1",xmlhttpOrg,"PLM_ExternalID","imageWaitingTable","no","3");

               	var cell3=row2.insertCell(-1);
               	cell3.className="title";
               	cell3.innerHTML="<%=Employee%>"+":<b style=\"color:red\" >*";

            	var cell4=row2.insertCell(-1);
               	cell4.style.fontSize = "10pt";
               	cell4.style.fontWeight = "bold";
               	cell4.style.width = "300px";
               	cell4.style.height = "30px";

               	cell4.innerHTML=" <select id='FilterArea2'>";



				 for(var i = 0 ; i < response.length ; i++ ){
               var respType = response[i].firstChild.data;
				if (respType == "Company"){
                   // JIC 17:03:13 IR IR-508813-3DEXPERIENCER2018x: Replaced "firstChild.data" with loop on all nodes as Internet Explorer 10 splits text containins hyphens into several nodes (and "textContext" is not supported prior to Internet Explorer 9...)
                   //var nameElement = responsePLMID[i].firstChild.data;
                   var childNodes = responsePLMID[i].childNodes;
                   var nameElement = ""
                   for (var j = 0; j < childNodes.length; j++)
                   {
                       nameElement = nameElement + childNodes[j].data.htmlEncode();
                   }
                   if (nameElement == "<%=HostCompanyName%>"){
                       var nouvel_element = new Option(nameElement,nameElement,true,true);
                   }else{
                	    var nouvel_element = new Option(nameElement,nameElement,false,false);
                   }
                   document.getElementById("FilterArea2").options[document.getElementById("FilterArea2").length] = nouvel_element;

				}
           }
			     var row3=table1.insertRow(-1);
	               var cell5=row3.insertCell(-1);
	               cell5.className="title";
	               cell5.innerHTML="<%=current%>"+":<b style=\"color:red\" >*";

	            	var cell6=row3.insertCell(-1);
	               cell6.style.fontSize = "10pt";
	               cell6.style.fontWeight = "bold";
	               cell6.style.width = "300px";

	               cell6.innerHTML=" <select id='FilterArea3'>";

					 for(var i = 0 ; i < response.length ; i++ ){
	               var respType = response[i].firstChild.data;
                       // JIC 16:05:13 IR IR-441308-3DEXPERIENCER2016x: Replaced "firstChild.data" with loop on all nodes as Internet Explorer 10 splits text containins hyphens into several nodes (and "textContext" is not supported prior to Internet Explorer 9...)
	                   //var nameElement = responsePLMID[i].firstChild.data;
                       var childNodes = responsePLMID[i].childNodes;
                       var nameElement = ""
                       for (var j = 0; j < childNodes.length; j++)
                       {
                           nameElement = nameElement + childNodes[j].data;
                       }
	                   if (nameElement == "<%=HostCompanyName%>"){
	                       var nouvel_element = new Option(nameElement,nameElement,true,true);
	                   }else{
	                	    var nouvel_element = new Option(nameElement,nameElement,false,false);
	                   } document.getElementById("FilterArea3").options[document.getElementById("FilterArea3").length] = nouvel_element;
	           }



               for (var i = 0 ; i <roles.length ; i++){
                   var cell=row.insertCell(-1);
                   cell.className = "matrixCell";

                   var roleName = roles[i].getElementsByTagName("PLM_ExternalID").item(0).firstChild.data;
                   var roleNameNLS = roleName;
                   <%for (int i = 0 ; i < 7 ; i ++){%>
                   if ("<%=Roles[i][0]%>" == roleName)roleNameNLS="<%=Roles[i][1]%>";
                   <%}%>
                   cell.innerHTML=roleNameNLS;
                   cell.title=roleNameNLS;
               }
               xmlreq("emxPLMOnlineAdminAjaxResponse.jsp","source=Project&Solution=VPM&Destination=XP&Method=Create",displayProjectMatrix,2);



          }
      }

        function initXPPerson(hostCompany){
            host=hostCompany;
            /* Request to get the matrix */
            var destRole =  "source=Role&Destination=XP&Method=Create";

            /* Request to get the Licenses */

            xmlreq("emxPLMOnlineAdminAjaxResponse.jsp",destRole,displayRoleMatrix,0);
            xmlreq("emxPLMOnlineAdminXHRLicenseGet.jsp","",getLicensesResponse,1);
        }



     function sendToPage() {
      DisplayLoading();
      var URLToSend = "";
      var personAttributes = document.getElementsByTagName("input");
      if((document.getElementById("PLM_ExternalID").value == "")){
    	  alert("<%=ERR_CannotBeEmpty%>");
    	  HideLoading();
   	  }else{
   		  if (hasSpecialChar(document.getElementById("PLM_ExternalID").value)){
			  alert("<%=ERRCannotContain%>" + ": " + emxUIAdminConsoleUtil.FORBIDDEN_CHARACTERS);
              HideLoading();
          }
   		  else{
   	  	      for(var i = 0 ; i < personAttributes.length ; i++){

        	  	if( (personAttributes[i].name != "") && (personAttributes[i].type == "text") ){
            	  URLToSend=URLToSend+personAttributes[i].name+"="+encodeURIComponent(personAttributes[i].value)+"&";
          		}
      	      }

                URLToSend=URLToSend+"Country=";
                var country="";
                if(document.getElementById("CountryId").selectedIndex != -1){
					if(document.getElementById("CountryId").options[document.getElementById("CountryId").selectedIndex].value == "```manualEntryOptionDisplay```") {
						country=document.getElementById("CountryIdtxt").value;
					} else {
						country=document.getElementById("CountryId").options[document.getElementById("CountryId").selectedIndex].value;
					}
                }
                URLToSend=URLToSend+encodeURIComponent(country)+"&";

      			var checkBoxes = getSelectedCheckbox();
      			var Licences = getSelectedLicencesCheckbox();


      			/*String employeeOf = emxGetParameter(request,"employeeOrg");
      		    String secCtxOrg = emxGetParameter(request,"secCtxOrg");
      		    String memberOf = emxGetParameter(request,"memberOrg");
      		    */
      		  	var secContextsOrg ="";
      		  	var EmployeeOrg="";
      		  	var MemberOrg="";

      		  	 secContextsOrg = document.getElementById("FilterArea3").options[document.getElementById("FilterArea3").options.selectedIndex].value;
   	  	      	 EmployeeOrg = document.getElementById("FilterArea2").options[document.getElementById("FilterArea2").options.selectedIndex].value;
				if(document.getElementById("FilterArea1").options.selectedIndex != -1){
	   	  	   		 MemberOrg = document.getElementById("FilterArea1").options[document.getElementById("FilterArea1").options.selectedIndex].value;
   	  	   		}else{
					MemberOrg = EmployeeOrg;
				}
				      			URLToSend=URLToSend+"Assignment="+encodeURIComponent(checkBoxes);
      			URLToSend=URLToSend+"&Active="+document.getElementsByName("Active")[0].checked;
                <!-- JIC 2014:10:21 Added parameter "Contractor" for contractor support-->
                URLToSend=URLToSend+"&Contractor="+document.getElementById("Contractor").checked;
	      		URLToSend=URLToSend+"&VPLMAdmin="+document.getElementsByName("VPLMAdmin")[0].checked;
	      		URLToSend=URLToSend+"&secCtxOrg="+encodeURIComponent(secContextsOrg);
	      		URLToSend=URLToSend+"&employeeOrg="+encodeURIComponent(EmployeeOrg);
	      		URLToSend=URLToSend+"&memberOrg="+encodeURIComponent(MemberOrg);
	      		URLToSend=URLToSend+"&source="+"<%=source%>";
	      		URLToSend=URLToSend+"&Licences="+Licences;
                <!-- JIC 15:04:23 Added Added Casual Hour support -->
                if (document.getElementById("Casual") != null) {
                    URLToSend=URLToSend+"&CasualHour="+(document.getElementById("Casual").checked==true?"40":"0");
                }

	      		xmlreq("emxPLMOnlineAdminCreatePersonContextDB.jsp",URLToSend,createPersonDB,3);
	     	}
     }
     }

     function createPersonDB(){
             var xmlhttp=xmlreqs[3];

            xmlhttp.onreadystatechange=function()
            {
                if(xmlhttp.readyState==4)
                {
                   var createResult = xmlhttp.responseXML.getElementsByTagName("createResult");
                    <% for (int i = 0 ; i <5 ; i++){%>
                               if (<%=i%> == createResult[0].firstChild.data){
                                       document.getElementById("messageError").innerHTML = "<%=ResultString[i]%>";
                               }
                    <%}%>
                    if (document.getElementById("messageError").innerHTML == "") document.getElementById("messageError").innerHTML = "<%=ResultString[1]%>";
                   HideLoading();
                   document.getElementById("hidethisone").style.display="block";
                }
          }
     }

        // JIC 15:04:09 Added function "CheckUncheckCasual"
        function CheckUncheckCasual() {
            DisplayLoading();
            // JIC 15:04:21 Added parameter "User"
            var destCasualHour = "CasualHour="+(document.getElementById("Casual").checked==true?"40":"0");
            xmlreq("emxPLMOnlineAdminXHRLicenseGet.jsp",destCasualHour,getLicensesResponse,1);
        }

  </script>
      <script>addReturnMessage();</script><script>addTransparentLoading();</script>
 <%
        if (AdminUtilities.isProjectAdmin(mainContext)){%>
            <body>
                <div class="transparencyForErrors" id="loading"   style="z-index:1;" >
                    <table width="100%" style="height : 100%" >
                        <tr valign="middle" align="middle">
                            <td style="color:#990000 ; font-style:italic; font-family: Arial, Helvetica, Sans-Serif ; font-weight: bold; font-size: 10pt; letter-spacing: 1pt">
                            <%=YoudonotHaveRights%></td>
                        </tr>
                    </table>
                </div>
            </body>
        <%}else{%>
            <script>
                // JIC 2014:10:21 Added functions "refreshContractor" and "refreshVPLMAdmin" for contractor support
                function refreshContractor(){
                    var isVPLMAdmin = document.getElementById("VPLMAdmin").checked;
                    if (isVPLMAdmin == true)
                    {
                        document.getElementById("Contractor").checked = false;
                    }
                }
                function refreshVPLMAdmin(){
                    var isContractor = document.getElementById("Contractor").checked;
                    if (isContractor == true)
                    {
                        document.getElementById("VPLMAdmin").checked = false;
                    }
                }
            </script>
            <body onload="javascript:initXPPerson('<%=XSSUtil.encodeForJavaScript(context,(String)HostCompanyName)%>');">
                <form action="emxPLMOnlineAdminCreatePersonContextDB.jsp" id="submitForm" name="submitForm"  method="GET">

                    <div class="divHauts horiz" id="divHauts" style=" border: 1px ; border-color: white"  >
                    <div class="scroll-cont" style="width : 38%" >
                        <table  class="big" >
                            <img src="images/iconSmallXPPerson.gif">
                            <tr>
                                <td  class="title"><%=UserId%><b style="color:red" >*</td><td valign="middle"><input type="text" id="PLM_ExternalID" name="PLM_ExternalID"></td>
                                <td   class="title" ><%=getNLS("UserAlias")%></td><td valign="middle"><input type="text" id="V_distinguished_name" name="V_distinguished_name"></td>
                            </tr>
                            <tr><td class="title"><%=FirstName%></td><td><input type="text" name="V_first_name"></td><td class="title"><%=Street%></td><td><input type="text" name="Street"></td></tr>
                            <tr><td class="title"><%=LastName%></td><td><input type="text" name="V_last_name"></td><td class="title"><%=City%></td><td><input type="text" name="City"></td></tr>
                            <tr><td class="title"><%=Email%></td><td><input type="text" name="V_email"></td><td class="title"><%=State%></td><td><input type="text" name="State"></td></tr>
                            <tr><td class="title"><%=Phone%></td><td><input type="text" name="V_phone"></td><td class="title"><%=PostalCode%></td><td><input type="text" name="PostalCode"></td></tr>
                            <tr><td class="title"><%=WorkPhone%></td><td><input type="text" name="Work_Phone_Number"></td><td class="title"><%=Country%></td>
									<%
	java.util.Map countryChoiceDetails = (java.util.Map) matrix.db.JPO.invoke(context, "emxOrganization", null, "getCountryChooserDetailsForHTMLDisplay", new String[]{request.getHeader("Accept-Language")}, java.util.HashMap.class);
	java.util.List optionList =  (java.util.List)countryChoiceDetails.get("optionList");
	java.util.List valueList =  (java.util.List)countryChoiceDetails.get("valueList");
	java.util.List manualEntryList =  (java.util.List)countryChoiceDetails.get("manualEntryList");
	String countryDefaultValue = (String)countryChoiceDetails.get("default");
									%>
            	        	    	<td>
         <framework:editOptionList disabled="false" name="Country" optionList="<%=optionList%>" valueList="<%=valueList%>" sortDirection="ascending" selected="<%=countryDefaultValue%>" manualEntryList="<%=manualEntryList%>"/>
									</td>
							</tr>
                            <!-- JIC 2014:10:21 Added checkbox "Contractor" for contractor support-->
                            <tr><td class="title"><%=getNLS("Active")%></td><td style="font-family: Arial, Helvetica, Sans-Serif ; font-weight: bold; font-size: 10pt; letter-spacing: 1pt; color : #50596f ;"><input type="checkbox" checked name="Active"></tr>
                            <tr><td class="title"><%=getNLS("Contractor")%></td><td><input type="checkbox" id="Contractor" name="Contractor" onchange="refreshVPLMAdmin()"> </td></tr>
                            <tr><td class="title"><%=getNLS("Administrator")%></td><td><input type="checkbox" id="VPLMAdmin" name="VPLMAdmin" onchange="refreshContractor()"></td></tr>
                        </table>
                    </div>
                    <div class="scroll-contOrg" style="border-left: 1px white solid;border-right: 1px white solid">
                     <img  align="middle" id="imageWaitingTable"  src="images/iconParamProgress.gif">
                    	<table width="100%"  id="TableOrg" style="height : 90%">
                    	<img src="images/iconSmallXPOrganization.gif">
                   	 </table>
                    </div>
                    <!-- ici commence le frame des licenses -->
                    <div id="lics"  class="scroll-cont" style="width : 38%;margin-left:3px;" >
                        <div id="lics_section1_container">
                            <!-- JIC 15:03:03 Added License type -->
                            <div id="lics_section1_casual">
                                <table class="titleLic" id="lics_section1_casual_table" border="0" cellspacing="0" cellpadding="0" width="100%">
                                    <colgroup>
                                        <col class="tableLicMargin" />
                                        <col class="tableLicCheckbox" />
                                        <col class="tableLicTitle" />
                                    </colgroup>
                                    <tr>
                                        <td/>
                                        <td><input type="checkbox" id="Casual" name="Casual" onchange="javascript:CheckUncheckCasual()"></td>
                                        <td/>
                                        <td><div id="lics_section1_casual_title"><%=getNLS("LicenseAssignCasual")%></div></td>
                                    </tr>
                                </table>
                            </div>
                            <div id="lics_section1_w_filter" class="licHeader">
                                <table  border="0" cellspacing="0" cellpadding="0" width="100%" colspan="4*,*">
                                    <tr>
                                        <td>
                                          <%
                                          addFirstLicenseSection(out);%>
                                        </td>
                                        <td >
                                            <div>
                                                <input id="lic_filter" type="text" title="<%=nlsLicSectionFilter%>" value="" onkeyup="license_filter(this,['lics_section1_table','lics_Available_table','lics_UnavailRich_table','lics_UnavailServer_table']);" />
                                            </div>
                                        </td>
                                    </tr>
                                </table>
                            </div>
                            <div id="lics_section1_body" width="100%">
                                <table class="titleLic" id="lics_section1_table" border="0" cellspacing="0" cellpadding="0" width="100%">
                                    <colgroup>
                                        <col class="tableLicMargin" />
                                        <col class="tableLicCheckbox" />
                                        <col class="tableLicCasual" />
                                        <col class="tableLicAvailability" />
                                        <col class="tableLicTitle" />
                                    </colgroup>
                                    <%
                                        // JIC 14:04:02 Added expire date
                                        DateFormat dateFormat = DateFormat.getDateInstance(DateFormat.MEDIUM, getNLSCatalog().getLocale());
                                        for (Iterator it = licinfos.iterator(); it.hasNext();) {
                                            LicenseInfo licenseInfo = (LicenseInfo)it.next();
                                            boolean bAssignedToUser = (sPersonId.length()>0) && mapUserLicenses.containsKey(licenseInfo.getName());
                                            // JIC 15:04:21 Added multiple casual hour/assignment support
                                            java.util.List<Integer> lstCasualHour = licenseInfo.getCasualHours();
                                            for (int i = 0; i < lstCasualHour.size(); i++)
                                            {
                                                // JIC 15:06:03 IR IR-375897-3DEXPERIENCER2015x: Moved back to single "is assigned" information coming from MCS rather than N coming from license server
                                                if (lstCasualHour.get(i).equals("0") && licenseInfo.isAssigned())
                                                {
                                                    String titleExpireDate = "";
                                                    Date expireDate = licenseInfo.getExpireDate();
                                                    if (expireDate != null) {
                                                        titleExpireDate = " (" + getNLS("LicenseExpires") + " " + dateFormat.format(expireDate) + ")";
                                                    }
                                                    addLine(out, licenseInfo.getName(), bAssignedToUser, "Unknown", nlsINFO_UNKNOWN, licenseInfo.getTitle()+titleExpireDate,"0");
                                                }
                                            }
                                        }
                                    %>
                                </table>
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
                                <table class="titleLic" id="lics_section0_table" border="0" cellspacing="0" cellpadding="0" width="100%">
                                    <colgroup>
                                        <col class="tableLicMargin" />
                                        <col class="tableLicCheckbox" />
                                        <col class="tableLicCasual" />
                                        <col class="tableLicAvailability" />
                                        <col class="tableLicTitle" />
                                    </colgroup>
                                    <tr>
                                        <td> </td>
                                        <td> </td>
                                        <td> </td>
                                        <td>
                                            <img src="images/iconParamProgress.gif">
                                        </td>
                                    </tr>
                                </table>
                            </div>
                        </div>
                        <div id="lics_section3_container" style="display:none;">
                        </div>
                    </div>
                    <!-- ici finit le frame des licenses -->
                </div>
                <hr>
                <div class="divMilieus horiz" >
                    <img  align="middle" id="imageWaiting"  src="images/iconParamProgress.gif">
                    <table width="100%" style="height:99% ; border-color: white" border="1px" id="TableToFilter" >
                    </table>
                </div>
                <textarea style="display:none"  name="HiddenElement" id="HiddenElement"></textarea>
           </form>
           <script>
                addFooter("javascript:sendToPage()","images/buttonDialogAdd.gif","<%=create%>","<%=create%>");
           </script>
        </body>
    <%}%>
</html>
