<%@ page import="java.util.Date"%>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.List"%>
<%@ page import="java.text.DateFormat"%>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="com.matrixone.vplm.posws.stubsaccess.ClientWithoutWS" %>
<%@ page import="com.matrixone.apps.common.Person" %>
<%@ page import="com.matrixone.vplm.posmodel.license.LicenseInfo" %>
<%@ page import="com.dassault_systemes.vplmposadministrationui.uiutil.AdminUtilities" %>
<%@include file = "../common/emxNavigatorNoDocTypeInclude.inc"%>
<%@include file = "emxPLMOnlineAdminAttributesCalculation.jsp"%>
<%@include file = "emxPLMOnlineAdminLicensesUtil.inc"%>
<%@include file = "../emxJSValidation.inc" %>
<%@include file = "../common/emxPLMOnlineAdminAuthorize.jsp"%>
<script type="text/javascript" src="scripts/emxUICore.js"></script>
<%--
    Document   : emxPLMOnlineAdminXPUpdatePerson.jsp
    Author     : LXM
    Modified :   26/05/2011 -> Replace Post by GEt for AIX
--%>
<%

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
    String Current = getNLS("CurrentOrganization");

    String ResultString[]= new String[2];
    ResultString[0] = getNLS("YourPersonHasBeenUpdated");
    ResultString[1] = getNLSMessageWithParameter("ERR_CreationRight","UserID");
    String sPersonId=emxGetParameter(request,"PLM_ExternalID");
    String CannotRemLic = getNLS("ERR_CannotRemoveLicenses");
    String casualLicences = getCasualLicencesAssigned(mainContext,sPersonId,"40");
	String TabInteger[] = new String[3];
        TabInteger[0]=getNLS("0");
        TabInteger[1]=getNLS("40");
	  TabInteger[2]=getNLS("40");

        String nlsINFO_FullCasual = myNLS.getMessage("LicenSectionFullOrCasual",TabInteger);


    String HostCompanyName= getHostCompanyName(mainContext);

    String CasualLicenseTable[] = casualLicences.split(",");
    StringList casualStringList = new StringList(CasualLicenseTable);
    String target="";
    String source = (String)emxGetParameter(request,"source");
    String message = (String)emxGetParameter(request,"message");
    String FilterProject = myNLS.getMessage("FilterProject");
	String orgid = (String)emxGetParameter(request,"currentOrganization");
	if(orgid==null || orgid.isEmpty()) orgid = HostCompanyName;

    String nlsLicSection1       =  myNLS.getMessage("LicenseSectionUsed");
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
        <script src="scripts/emxUIAdminConsoleUtil.js" type="text/javascript"></script>
        <link rel=stylesheet type="text/css" href="styles/emxUIDOMLayout.css">
        <link rel=stylesheet type="text/css" href="styles/emxUIDefault.css">
        <link rel=stylesheet type="text/css" href="styles/emxUIPlmOnline.css">
        <style>
            div.horiz      { width:100%; position:relative; }
            div.divHauts   { height:42%; }
            div.divMilieus { height:53%; margin-left:-1px; overflow:auto; }
            div.divBass    { height:6%; }
            div.scroll-cont{
                            float:left; overflow:auto;
                            height:100%;
            }
            div.scroll-contOrg{
                            float:left; overflow:auto;
                            width:22%;   /* a cause des marges (et de leur gestion differente par IE et FF, il  */
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
    
        function sendToUpdatePage() {
            DisplayLoading();
            var URLToSend = "";
            var personAttributes = document.getElementsByTagName("input");

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

            var Licences = getSelectedLicencesCheckbox();

            var org = document.getElementById("FilterArea3").options[document.getElementById("FilterArea3").options.selectedIndex].value;
			URLToSend=URLToSend+"context="+encodeURIComponent(document.getElementById("removeSelect").innerHTML.htmlDecode());
            URLToSend=URLToSend+"&Assignment="+encodeURIComponent(document.getElementById("HiddenElement").innerHTML.htmlDecode());
            URLToSend=URLToSend+"&currentOrganization="+encodeURIComponent(org);

            URLToSend=URLToSend+"&Active="+document.getElementsByName("Active")[0].checked;
            // JIC 2014:10:23 Added Contractor support
            if (document.getElementById("Contractor") != null) {
            	URLToSend=URLToSend+"&Contractor="+document.getElementById("Contractor").checked;
            }
            if( (document.getElementsByName("VPLMAdmin") != null) && (document.getElementsByName("VPLMAdmin").length>0)  ){
            	URLToSend=URLToSend+"&VPLMAdmin="+document.getElementsByName("VPLMAdmin")[0].checked;
            }else{
            	URLToSend=URLToSend+"&VPLMAdmin=rien";
            }
            // JIC 2015:03:17 Added Casual Hour support
            if (document.getElementById("Casual") != null) {
            	URLToSend=URLToSend+"&CasualHour="+(document.getElementById("Casual").checked==true?"40":"0");
            }
            URLToSend=URLToSend+"&Licences="+Licences;
            URLToSend=URLToSend+"&ActualLicences="+"<%=casualLicences%>";

            if (document.getElementById("PrjAdmin") != null){
                URLToSend=URLToSend+"&PrjAdmin="+PrjAdmin;
            }

			var xmlhttp;
			if (window.XMLHttpRequest) {// Mozilla/Safari
				xmlhttp = new XMLHttpRequest();
			} else if (window.ActiveXObject) {// IE
				xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
			} else {
				alert('Sorry, your browser does not support XML HTTP Request!');
			}
			xmlreqs[3] = xmlhttp;
			xmlhttp.open("POST", "emxPLMOnlineAdminUpdatePerson.jsp", true);
			xmlhttp.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
			xmlhttp.onreadystatechange = updatePersonDB;
			xmlhttp.send(URLToSend);
		}

        function updatePersonDB(){
            var xmlhttp=xmlreqs[3];

            xmlhttp.onreadystatechange=function()
            {
                if(xmlhttp.readyState==4)
                {
                    var createResult = xmlhttp.responseXML.getElementsByTagName("updateResult");
				   if(createResult[0].firstChild.data==0) {
						var dbView = document.getElementById("contexts").innerHTML;
						var removeSelect = document.getElementById("removeSelect").innerHTML;
						var boxCombin = removeSelect.split("!!");
						for (var i=1; i<boxCombin.length; i++) {
							dbView = ReplaceAllOccurence(dbView,"!!"+boxCombin[i],"");
						}
						document.getElementById("removeSelect").innerHTML = "";
						document.getElementById("contexts").innerHTML = dbView + document.getElementById("HiddenElement").innerHTML;
						document.getElementById("HiddenElement").innerHTML = "";
				   }

                    var createLicenseResult = xmlhttp.responseXML.getElementsByTagName("LicMessage");
                    <% for (int i = 0 ; i <2 ; i++){%>
                        if (<%=i%> == createResult[0].firstChild.data){
                            document.getElementById("messageError").innerHTML = "<%=ResultString[i]%>";
                        }
                    <%}%>
                    if (document.getElementById("messageError").innerHTML == "") document.getElementById("messageError").innerHTML = "<%=ResultString[1]%>";
                    if (createLicenseResult[0].firstChild.data != "Rien"){
                        if (createLicenseResult[0].firstChild.data.length > 2){
                            document.getElementById("messageError").innerHTML = document.getElementById("messageError").innerHTML +"\n" +createLicenseResult[0].firstChild.data;
                        }else{
                            document.getElementById("messageError").innerHTML = document.getElementById("messageError").innerHTML +"\n" + "<%=CannotRemLic%>";
                        }
                    }
                    var LicencesString = "source=Licences&Filter="+encodeURIComponent("<%=sPersonId%>");
                    xmlreq("emxPLMOnlineAdminAjaxResponse.jsp",LicencesString,getCasualLicensesResponse,4);
                    HideLoading();
                    document.getElementById("hidethisone").style.display="block";
                }
            }
        }

	function getCasualLicensesResponse(){
        	 var xmlhttpCasual = xmlreqs[4];
             if(xmlhttpCasual.readyState==4)
             {

            	 //get the licences already checked
            	 var Licences = getSelectedLicencesCheckbox();
            	 // For each Licence checked need to know :
            		 // If the user still have the license do not do anything
            		 // If the user dont have the license anymore, uncheck it.
            	 var LicencesResult = xmlhttpCasual.responseXML.getElementsByTagName("CasualLicense");
            	 if (LicencesResult != null){
            	 	for (var i = 0 ; i < LicencesResult.length ; i++){
           				if(LicencesResult[i].firstChild != null){
            	 			var CasualLicenceAssigned = LicencesResult[i].firstChild.data;

            	 			if ((Licences.indexOf(";"+CasualLicenceAssigned+";") == -1) ){
            	 				if(Licences.indexOf(";"+FullLicenceAssigned+";40") == -1){
	            	 				var nameLic = "lic_"+CasualLicenceAssigned+"_chk";
    	        	 				document.getElementById(nameLic).checked == true;
            	 				}
            	 			}
            	 		}
            	 	}
            	 }

            	 var LicencesResultFull = xmlhttpCasual.responseXML.getElementsByTagName("FullLicense");
            	 if (LicencesResultFull != null){
                 	for (var i = 0 ; i < LicencesResultFull.length ; i++){
                 		if(LicencesResultFull[i].firstChild != null){
                    	 	var FullLicenceAssigned = LicencesResultFull[i].firstChild.data;

            	 			if (Licences.indexOf(";"+FullLicenceAssigned+";0") == -1){
            	 				var nameLic = "lic_"+FullLicenceAssigned+"_chk";
								document.getElementById(nameLic).checked = true;

                                // JIC 15:04:20 Removed Casual combo code
                                /*
								var sel1 = "lic_"+FullLicenceAssigned+"_sel";
								document.getElementById(sel1).style.visibility = "visible";
                                */
            	 			}
                 		}
            	 	}
            	 }
			}
        }


        function CheckContext(){
				var txt =document.getElementById("contexts").innerHTML;
            	if (txt!=null && txt!="") {
					var boxCombin = txt.split("!!");
					for (var i=1; i<boxCombin.length; i++) {
                    	var nameCheckBox = boxCombin[i].htmlDecode();
                   		if(document.getElementById(nameCheckBox)!=null) {
							document.getElementById(nameCheckBox).checked = true;
						}
					}
				}
        }
		
        function refreshTable(){
				var orga = $("FilterArea3").options[$("FilterArea3").options.selectedIndex].value;
				window.location.replace("emxPLMOnlineAdminXPUpdatePerson.jsp?PLM_ExternalID="+encodeURIComponent("<%=sPersonId%>")+"&source=Admin&currentOrganization="+encodeURIComponent(orga));
				
		}
        
	function RemoveCheckBoxBis(boxName){
			var found = false;
			var txt = document.getElementById("contexts").innerHTML;
			if(txt!=null && txt!="" && txt.indexOf(boxName)>-1) {
				found = true;
				var removeSelect = document.getElementById("removeSelect").innerHTML;
				if (document.getElementById(boxName).checked==false && removeSelect.indexOf(boxName)==-1) {
					removeSelect = removeSelect + "!!"+boxName;
				} else if(document.getElementById(boxName).checked==true && removeSelect.indexOf(boxName)>-1) {
					removeSelect = ReplaceAllOccurence(removeSelect,"!!"+boxName,"");
				}
				document.getElementById("removeSelect").innerHTML = removeSelect;
			}
            if (found==false) {
				var HiddenElement = document.getElementById("HiddenElement").innerHTML;
                if (document.getElementById(boxName).checked==true && HiddenElement.indexOf(boxName)==-1) {
                	HiddenElement = HiddenElement + "!!"+boxName;
				} else if(document.getElementById(boxName).checked==false && HiddenElement.indexOf(boxName)>-1) {
					HiddenElement = ReplaceAllOccurence(HiddenElement,"!!"+boxName,"");
                }
				document.getElementById("HiddenElement").innerHTML = HiddenElement;
			}
      }


// update NLS title help
nlsINFO_SELECTALL      = "<%=nlsINFO_SELECTALL%>";
nlsINFO_AVAILABLE      = "<%=nlsINFO_AVAILABLE%>";
nlsINFO_UNAVAIL        = "<%=nlsINFO_UNAVAIL%>";
nlsINFO_UNAVAIL_WARN        = "<%=getNLS("LicenseUnavailableWarning")%>";
nlsSECTION_AVAIL          = "<%=myNLS.getMessage("LicenseSectionAvailable")%>";
nlsSECTION_UNAVAIL_RICH   = "<%=myNLS.getMessage("LicenseSectionUnavailableRich")%>";
nlsSECTION_UNAVAIL_SERVER = "<%=myNLS.getMessage("LicenseSectionUnavailableServer")%>";
nlsINFO_FullCasual ="<%=nlsINFO_FullCasual%>";


var xmlreqs = new Array();
var prev_filter_lic = "";
var filter_lic = false;

    var host ="";
            var projects="";
        var roles = "";


        function displayRoleMatrix()
        {
             xmlhttpRole = xmlreqs[0];
            if(xmlhttpRole.readyState==4)
            {
            	roles =xmlhttpRole.responseXML.getElementsByTagName("Role");
            	xmlreq("emxPLMOnlineAdminAjaxResponse.jsp","source=Organization&Destination=VPLMAdmin&filterOrg=*&responseOrg=org_Type",displayRoleMatrixWithOrganization,6);
           }
       }
        
        /*
         * Filter a table, with a letter specified in an area which id = FilterArea.
         * and the Table ID = TableToFilter
         */
        function localfilterStrings(){
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
                var row=table.insertRow(-1);
                var cell=row.insertCell(-1);
                cell.style.fontSize = "10pt";
                cell.style.fontWeight = "bold";
                cell.style.height = "30px";

                cell.innerHTML="<%=FilterProject%>"+" <input size='5'  id='FilterArea' onkeyup='javascript:localfilterStrings()'>";

                	 var table1=document.getElementById('TableOrg');

               	 var response = xmlhttpOrg.responseXML.getElementsByTagName("org_Type");
               	 var responsePLMID = xmlhttpOrg.responseXML.getElementsByTagName("PLM_ExternalID");


 			     var row3=table1.insertRow(-1);
 	               var cell5=row3.insertCell(-1);
 	               cell5.className="title";
 	               cell5.innerHTML="<%=Current%>"+":<b style=\"color:red\" >*";

 	            	var cell6=row3.insertCell(-1);
 	               cell6.style.fontSize = "10pt";
 	               cell6.style.fontWeight = "bold";
 	               cell6.style.width = "300px";

 	               cell6.innerHTML=" <select id='FilterArea3' onchange='refreshTable()'>";

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
 	                   if (nameElement == "<%=orgid%>"){
 	                       var nouvel_element = new Option(nameElement,nameElement,true,true);
 	                   }else{
 	                	    var nouvel_element = new Option(nameElement,nameElement,false,false);
 	                   } document.getElementById("FilterArea3").options[document.getElementById("FilterArea3").length] = nouvel_element;
 	           }


 					document.getElementById("imageWaitingTable").style.display = 'none';


                for (var i = 0 ; i <roles.length ; i++){
                    var cell=row.insertCell(-1);
                    cell.className = "matrixCell";
                    cell.style.fontWeight = "bold";
                    cell.style.fontSize = "12pt";
                    cell.style.color = "white";
                      cell.bgColor = "#659ac2";

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

        function displayProjectMatrix()
        {
            var xmlhttp = xmlreqs[2];
            if(xmlhttp.readyState==4)
            { //document.getElementById("imageWaiting").style.display = 'none';

                projects =xmlhttp.responseXML.getElementsByTagName("Project");
                var table=document.getElementById('TableToFilter');

                for (var i = 0 ; i <projects.length ; i++){
                    var row=table.insertRow(-1);
                    var cell=row.insertCell(-1);
                     cell.style.fontWeight = "bold";
                       cell.style.fontSize = "12pt";
                       cell.style.color = "white";
                         cell.bgColor = "#659ac2";
                    // RBR2: Dont disturb the DOM
                    cell.style.display = "none";
					
                    var cellTitle =row.insertCell(-1);
                    cellTitle.style.fontWeight = "bold";
                    cellTitle.style.fontSize = "12pt";
                    cellTitle.style.color = "white";
                    cellTitle.bgColor = "#659ac2";
                    //var prjName =projects[i].getElementsByTagName("PLM_ExternalID").item(0).firstChild.data;
                    //cell.innerHTML=projects[i].getElementsByTagName("PLM_ExternalID").item(0).firstChild.data.htmlEncode();
					//LFE 17/11/16 IR-476183-3DEXPERIENCER2016x
                    var prjName =projects[i].getElementsByTagName("PLM_ExternalID").item(0).textContent;
                    cell.innerHTML = projects[i].getElementsByTagName("PLM_ExternalID").item(0).textContent.htmlEncode();
                    
                    //RBR2: Title FUN[080973]
                    var prjNameTitle =projects[i].getElementsByTagName("V_Name").item(0).textContent; 
                    cellTitle.id=prjName
                    /* cellTitle.setAttribute("onmouseover","javascript:mouseOver(this)");
                    cellTitle.setAttribute("onmouseout","javascript:mouseOut(this)");
                    cellTitle.setAttribute("title",prjName);
                     */
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

                        var string = roleName+";"+prjName;
                        var secCtx = roleNameNLS+" / "+prjName;

                        string = ReplaceAllOccurence(string," ",",");
                       if((prjName=="Default") && (roleName=="VPLMAdmin")){
                            cell.innerHTML="<input type='checkbox' align='center' disabled id="+string+" title='"+secCtx+"'>";
                       }else{
                            cell.innerHTML="<input type='checkbox' align='center' onclick='javascript:RemoveCheckBoxBis(\""+string+"\")' id="+string+" title='"+secCtx+"' >";
                       }
                   }
               }
               CheckContext();
			   HideLoading();
            }
        }


         function displayPerson()
        {
            var xmlhttpPerson = xmlreqs[2];
            if(xmlhttpPerson.readyState==4)
            {   var destRole =  "source=Role&Destination=XP&Method=Create";

                var person =xmlhttpPerson.responseXML.getElementsByTagName("Person");


                if(xmlhttpPerson.responseXML.getElementsByTagName("FirstName")[0].firstChild != null ){

                 document.getElementById("V_first_name").value = xmlhttpPerson.responseXML.getElementsByTagName("FirstName")[0].firstChild.data;
            }
            if(xmlhttpPerson.responseXML.getElementsByTagName("LastName")[0].firstChild != null)
                document.getElementById("V_last_name").value = xmlhttpPerson.responseXML.getElementsByTagName("LastName")[0].firstChild.data;
                if(xmlhttpPerson.responseXML.getElementsByTagName("Email")[0].firstChild != null)
				{
					// ALU4 2017.06.07 old code before fix provided for IR-527471-3DEXPERIENCER2018x
					//document.getElementById("V_email").value = xmlhttpPerson.responseXML.getElementsByTagName("Email")[0].firstChild.data;
					// ALU4 2017.06.07 IR-527471-3DEXPERIENCER2018x Email address isn’t shown if email address has included “-”.
					var childNodes = xmlhttpPerson.responseXML.getElementsByTagName("Email")[0].childNodes;
					var email = "";
					for(var k = 0; k < childNodes.length; k++)
					{
						email = email + childNodes[k].data ;
					}
					document.getElementById("V_email").value = email;
				}
                if(xmlhttpPerson.responseXML.getElementsByTagName("Street")[0].firstChild != null)
               document.getElementById("Street").value = xmlhttpPerson.responseXML.getElementsByTagName("Street")[0].firstChild.data;
                if(xmlhttpPerson.responseXML.getElementsByTagName("City")[0].firstChild != null)
               document.getElementById("City").value = xmlhttpPerson.responseXML.getElementsByTagName("City")[0].firstChild.data;
                if(xmlhttpPerson.responseXML.getElementsByTagName("State")[0].firstChild != null)
               document.getElementById("State").value = xmlhttpPerson.responseXML.getElementsByTagName("State")[0].firstChild.data;
                if(xmlhttpPerson.responseXML.getElementsByTagName("PostalCode")[0].firstChild != null)
               document.getElementById("PostalCode").value = xmlhttpPerson.responseXML.getElementsByTagName("PostalCode")[0].firstChild.data;
                if(xmlhttpPerson.responseXML.getElementsByTagName("Country")[0].firstChild != null) {
               document.getElementById("CountryId").value = xmlhttpPerson.responseXML.getElementsByTagName("Country")[0].firstChild.data;
					if(document.getElementById("CountryId").value == ""){
               document.getElementById("CountryIdtxt").style = "";
               document.getElementById("CountryIdtxt").disabled = false;
               document.getElementById("CountryIdtxt").value = xmlhttpPerson.responseXML.getElementsByTagName("Country")[0].firstChild.data;
               document.getElementById("CountryId").value = "```manualEntryOptionDisplay```";
					}
				}
                if(xmlhttpPerson.responseXML.getElementsByTagName("Alias")[0].firstChild != null)
               document.getElementById("Alias").value = xmlhttpPerson.responseXML.getElementsByTagName("Alias")[0].firstChild.data;
                if(xmlhttpPerson.responseXML.getElementsByTagName("Phone")[0].firstChild != null)
               document.getElementById("V_phone").value = xmlhttpPerson.responseXML.getElementsByTagName("Phone")[0].firstChild.data;
               if(xmlhttpPerson.responseXML.getElementsByTagName("WorkPhone")[0].firstChild != null)
               document.getElementById("Work_Phone_Number").value = xmlhttpPerson.responseXML.getElementsByTagName("WorkPhone")[0].firstChild.data;
                         
if(xmlhttpPerson.responseXML.getElementsByTagName("IsActive")[0].firstChild != null)
               {

                   if(xmlhttpPerson.responseXML.getElementsByTagName("IsActive")[0].firstChild.data == "Active"){
                        document.getElementsByName("Active")[0].checked = true;
                   }else{
						
                        document.getElementsByName("Active")[0].checked = false;

                   }
               }
               var OrgString="";
               if(xmlhttpPerson.responseXML.getElementsByTagName("Emp").length > 0 &&
			      xmlhttpPerson.responseXML.getElementsByTagName("Emp")[0].firstChild != null)
               {
                   // JIC 17:03:13 IR IR-508813-3DEXPERIENCER2018x: Replaced "firstChild.data" with loop on all nodes as Internet Explorer 10 splits text containins hyphens into several nodes (and "textContext" is not supported prior to Internet Explorer 9...)
                   // document.getElementById("OrgEmp").innerHTML = "<b>"+xmlhttpPerson.responseXML.getElementsByTagName("Emp")[0].firstChild.data.htmlEncode()+"</b>";
                   var childNodes = xmlhttpPerson.responseXML.getElementsByTagName("Emp")[0].childNodes;
                   var employeeOrgName = ""
                   for (var j = 0; j < childNodes.length; j++)
                   {
                       employeeOrgName = employeeOrgName + childNodes[j].data.htmlEncode();
                   }
                   document.getElementById("OrgEmp").innerHTML = "<b>"+employeeOrgName+"</b>";
               }
               if(xmlhttpPerson.responseXML.getElementsByTagName("Org").length > 0 &&
			      xmlhttpPerson.responseXML.getElementsByTagName("Org")[0].firstChild != null)
               {
                   if(xmlhttpPerson.responseXML.getElementsByTagName("Org").length == 1){
                       // JIC 17:03:13 IR IR-508813-3DEXPERIENCER2018x: Replaced "firstChild.data" with loop on all nodes as Internet Explorer 10 splits text containins hyphens into several nodes (and "textContext" is not supported prior to Internet Explorer 9...)
                       //document.getElementById("OrgMem").innerHTML = "<b>"+xmlhttpPerson.responseXML.getElementsByTagName("Org")[0].firstChild.data.htmlEncode()+"</b>";
                       var childNodes = xmlhttpPerson.responseXML.getElementsByTagName("Org")[0].childNodes;
                       var memberOrgName = ""
                       for (var j = 0; j < childNodes.length; j++)
                       {
                           memberOrgName = memberOrgName + childNodes[j].data.htmlEncode();
                       }
                       document.getElementById("OrgMem").innerHTML = "<b>"+memberOrgName+"</b>";
                   }else{
                       for (var j = 0 ; j < xmlhttpPerson.responseXML.getElementsByTagName("Org").length-1 ; j++){
                           // JIC 17:03:13 IR IR-508813-3DEXPERIENCER2018x: Replaced "firstChild.data" with loop on all nodes as Internet Explorer 10 splits text containins hyphens into several nodes (and "textContext" is not supported prior to Internet Explorer 9...)
                           //OrgString += xmlhttpPerson.responseXML.getElementsByTagName("Org")[j].firstChild.data+ ",";
                           var childNodes = xmlhttpPerson.responseXML.getElementsByTagName("Org")[j].childNodes;
                           var memberOrgName = ""
                           for (var k = 0; k < childNodes.length; k++)
                           {
                               memberOrgName = memberOrgName + childNodes[k].data.htmlEncode();
                           }
                           OrgString += memberOrgName + ",";
                       }
                       // JIC 17:03:13 IR IR-441308-3DEXPERIENCER2016x: Replaced "firstChild.data" with loop on all nodes as Internet Explorer 10 splits text containins hyphens into several nodes (and "textContext" is not supported prior to Internet Explorer 9...)
                       //OrgString += xmlhttpPerson.responseXML.getElementsByTagName("Org")[j].firstChild.data;
                       var childNodes = xmlhttpPerson.responseXML.getElementsByTagName("Org")[j].childNodes;
                       var memberOrgName = ""
                       for (var k = 0; k < childNodes.length; k++)
                       {
                           memberOrgName = memberOrgName + childNodes[k].data.htmlEncode();
                       }
                       OrgString += memberOrgName;
                       
                       document.getElementById("OrgMem").innerHTML = "<b>"+OrgString+"</b>";
                   }
               }

                xmlreq("emxPLMOnlineAdminAjaxResponse.jsp",destRole,displayRoleMatrix,0);
            }
       }

        function initXPPerson(hostCompany){
            host = hostCompany;
            var destPerson =  "source=Person&User="+encodeURIComponent("<%=sPersonId%>");
            xmlreq("emxPLMOnlineAdminAjaxResponse.jsp",destPerson,displayPerson,2);

            // JIC 15:04:21 Added parameters "CasualHour" and "User"
            var destCasualHour = "User="+encodeURIComponent("<%=sPersonId%>")+"&CasualHour="+(document.getElementById("Casual").checked==true?"40":"0");
            xmlreq("emxPLMOnlineAdminXHRLicenseGet.jsp",destCasualHour,getLicensesResponse,1);
        }

        // JIC 15:04:09 Added function "CheckUncheckCasual"
        function CheckUncheckCasual() {     
            DisplayLoading();
            var destCasualHour = "User="+encodeURIComponent("<%=sPersonId%>")+"&CasualHour="+(document.getElementById("Casual").checked==true?"40":"0");
            xmlreq("emxPLMOnlineAdminXHRLicenseGet.jsp",destCasualHour,getLicensesResponse,1);
        }
        
        </script>

    </head>
<%
    String UserId = myNLS.getMessage("UserID");
    String Email = myNLS.getMessage("Email");
    String FirstName = myNLS.getMessage("FirstName");
    String LastName = myNLS.getMessage("LastName");
    String Phone = myNLS.getMessage("HomePhone");
    String WorkPhone = myNLS.getMessage("WorkPhone");
    String Street = myNLS.getMessage("Street");
    String City = myNLS.getMessage("City");
    String State = myNLS.getMessage("State");
    String PostalCode = myNLS.getMessage("PostalCode");
    String Country = myNLS.getMessage("Country");
    String Update = myNLS.getMessage("Update");
    String Active = myNLS.getMessage("Active");
    String Contractor = myNLS.getMessage("Contractor");
    String Administrator = myNLS.getMessage("Administrator");
%>
    <body onload="javascript:initXPPerson('<%=XSSUtil.encodeForJavaScript(context,(String)orgid)%>');">
         <script>addTransparentLoading("","display");</script>
          <script>addReturnMessage();</script>
    <%

    // JIC 15:04:21 Remove user licenses map (moved to "emxPLMOnlineAdminXHRLicenseGet.jsp")

    TreeMap lics = new TreeMap();
    LicenseInfo.getDeclaredLicenses(context, lics, request.getLocale());
    //JIC 14:04:02 Added license status update
    LicenseInfo.updateLicensesStatus(context, lics);
    Collection licinfos = lics.values();

	boolean isAdmin = false;
	boolean isContractor = false;
    // JIC 15:03:18 Added person Casual Hours
    int casualHour = 0;

    Map person = new HashMap();
    Map listperson = new HashMap();

    person.put("PLM_ExternalID",sPersonId);
    listperson.put("person0" ,person);

    Map fin = new HashMap();
    fin.put("method","queryPerson");
    String[] slec = new String[] {""};
    fin.put("iPerson",listperson);
    // JIC 18:07:03 FUN076129: Removed use of PLM key/added context
    ClientWithoutWS client = new ClientWithoutWS(mainContext);
    Map per = client.serviceCall(fin);
    Map pers = (Map)per.get("person0");

    // JIC 2014:10:23 Added Contractor support
    isContractor = pers.get("Contractor") != null && ((String)pers.get("Contractor")).equals("true") ? true : false;

    // JIC 2015:03:18 Added Casual Hour support
    casualHour = pers.get("CasualHour") != null ? new Integer((String)pers.get("CasualHour")).intValue() : 0;

    StringList contx = (StringList)pers.get("ctx");
    String ctxtiti = "";

    for (int j = 0; j < contx.size() ; j ++){
        String contextName = (String)contx.get(j);
        if(contextName.indexOf("VPLMAdmin."+HostCompanyName+".Default")>=0) isAdmin = true;
        if(contextName.indexOf("."+orgid+".")<0) continue;
        ctxtiti = ctxtiti + "!!" + contextName.replace("."+orgid+".",";").replaceAll(" ",",");
    }
    ctxtiti = EncodeUtil.escape(ctxtiti);
    String targ = "emxPLMOnlineAdminUpdatePerson.jsp";
	%>

         <form action="<%=targ%>" id="submitForm" name="submitForm"  method="GET">
             <textarea name="contexts" id="contexts" style="display:none"><%=ctxtiti%></textarea>
			 <textarea name="removeSelect" id="removeSelect" style="display:none" ></textarea>
             <div style="display:none"><input type="text" name="Source" id="Source" style="display:none" value="UpdateXP">UpdateXP</input>
             <input type="text" name="PLM_ExternalID" id="PLM_ExternalID" style="display:none" value="<%=emxGetParameter(request,"PLM_ExternalID")%>"><%=emxGetParameter(request,"PLM_ExternalID")%></input>
             </div>
             <%if (message != null) {%>
               <script type="text/javascript">setTime("<%=message%>");</script><%}%>
            <div class="divHauts horiz" id="divHauts" >
                     <div class="scroll-cont" style="width : 38%" >
                        <table class="big">
                       <%if ( !AdminUtilities.isProjectAdmin(mainContext)){%>
                       <tr><td class="pic"></td>
                          <td class="title"><img src="images/iconSmallPeople.gif"/><%=UserId%> : <%=emxGetParameter(request,"PLM_ExternalID")%></td><td class="title"><%=myNLS.getMessage("UserAlias")%></td><td><input type="text" name="Alias" id="Alias" value=""></td></tr>
                         <tr><td class="title"><%=FirstName%></td><td><input type="text" id="V_first_name" name="V_first_name" value=""></td><td class="title"><%=Street%></td><td><input type="text" name="Street" id="Street" value=""></td></tr>
                        <tr><td class="title"><%=LastName%></td><td><input type="text" name="V_last_name" id="V_last_name" value=""></td><td class="title"><%=City%></td><td><input type="text" name="City"  id="City" value=""></td></tr>
                        <tr><td class="title"><%=Email%></td><td><input type="text" name="V_email" id="V_email" value=""></td><td class="title"><%=State%></td><td><input type="text" name="State" id="State" value=""></td></tr>
                        <tr><td class="title"><%=Phone%></td><td><input type="text" name="V_phone" id="V_phone" value=""></td><td class="title"><%=PostalCode%></td><td><input type="text" name="PostalCode"  id="PostalCode" value=""></td></tr>
                        <tr><td class="title"><%=WorkPhone%></td><td><input type="text" name="Work_Phone_Number" id="Work_Phone_Number" value=""></td>
						<td class="title"><%=Country%></td>
									<%
	java.util.Map countryChoiceDetails = (java.util.Map) matrix.db.JPO.invoke(context, "emxOrganization", null, "getCountryChooserDetailsForHTMLDisplay", new String[]{request.getHeader("Accept-Language")}, java.util.HashMap.class);
	java.util.List optionList =  (java.util.List)countryChoiceDetails.get("optionList");
	java.util.List valueList =  (java.util.List)countryChoiceDetails.get("valueList");
	java.util.List manualEntryList =  (java.util.List)countryChoiceDetails.get("manualEntryList");
	String countryDefaultValue = (String)countryChoiceDetails.get("default");
									%>
						<td>
         <framework:editOptionList disabled="false" name="Country" optionList="<%=optionList%>" valueList="<%=valueList%>" sortDirection="ascending" selected="<%=countryDefaultValue%>" manualEntryList="<%=manualEntryList%>"/>									
						</td></tr>
                        <tr>
                            <td class="title" ><%=Active%></td>
                            <td>
                                <input type="checkbox" name="Active">
                            </td>
                        </tr>
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
                        <!-- JIC 2014:10:21 Added checkbox "Contractor" for contractor support-->
                        <tr>
                            <td class="title"><%=Contractor%></td>
                            <td>
                                <%if (isContractor){%>
                                    <input type="checkbox" id="Contractor" name="Contractor" onchange="refreshVPLMAdmin()" checked>
                                <%}else{%>
                                    <input type="checkbox" id="Contractor" name="Contractor" onchange="refreshVPLMAdmin()">
                                <%}%>
                            </td>
                        </tr>
                        <tr>
                            <td class="title"><%=Administrator%></td><td>
                                <%if (isAdmin){%>
                                    <input type="checkbox" id="VPLMAdmin" name="VPLMAdmin" onchange="refreshContractor()" checked>
                                <%}else{%>
                                    <input type="checkbox" id="VPLMAdmin" name="VPLMAdmin" onchange="refreshContractor()">
                                <%}%>
                            </td>
                        </tr>
                            <%}else{%>
                          <td class="pic"><img src="images/iconSmallPeople.gif"><td class="title"><%=UserId%> : <%=emxGetParameter(request,"PLM_ExternalID")%></td>
                        <tr><td class="title"><%=FirstName%></td><td><input type="text" id="V_first_name"  name="V_first_name" value="" readonly></td><td class="title"><%=Street%></td><td><input type="text" name="Street" id="Street" value="" readonly></td></tr>
                        <tr><td class="title"><%=LastName%></td><td><input type="text" name="V_last_name" id="V_last_name" value="" readonly></td><td class="title"><%=City%></td><td><input type="text" name="City" id="City" value="" readonly></td></tr>
                        <tr><td class="title"><%=Email%></td><td><input type="text" name="V_email" id="V_email" value="" readonly></td><td class="title"><%=State%></td><td><input type="text" name="State" id="State" value="" readonly></td></tr>
                        <tr><td class="title"><%=Phone%></td><td><input type="text" name="V_phone"  id="V_phone" value="" readonly></td><td class="title"><%=PostalCode%></td><td><input type="text" name="PostalCode" id="PostalCode" value="" readonly></td></tr>
                        <tr><td class="title"><%=WorkPhone%></td><td><input type="text" name="Work_Phone_Number" id="Work_Phone_Number" value="" readonly></td>
						<td class="title"><%=Country%></td>
									<%
	java.util.Map countryChoiceDetails = (java.util.Map) matrix.db.JPO.invoke(context, "emxOrganization", null, "getCountryChooserDetailsForHTMLDisplay", new String[]{request.getHeader("Accept-Language")}, java.util.HashMap.class);
	java.util.List optionList =  (java.util.List)countryChoiceDetails.get("optionList");
	java.util.List valueList =  (java.util.List)countryChoiceDetails.get("valueList");
	java.util.List manualEntryList =  (java.util.List)countryChoiceDetails.get("manualEntryList");
	String countryDefaultValue = (String)countryChoiceDetails.get("default");
									%>
						<td>
         <framework:editOptionList disabled="true" name="Country" optionList="<%=optionList%>" valueList="<%=valueList%>" sortDirection="ascending" selected="<%=countryDefaultValue%>" manualEntryList="<%=manualEntryList%>"/>									
						</td></tr>
                        <tr><td  class="title" >Active</td><td >
                        <input type="checkbox" name="Active"  disabled>
                               </td><input name="PrjAdmin" value="PrjAdmin" style="display:none"></tr>

                        <%}%>

                        </table>
                </div>

                                    <div class="scroll-contOrg" style="border-left: 1px white solid;border-right: 1px white solid">
                     <img  align="middle" id="imageWaitingTable"  src="images/iconParamProgress.gif">
                    	<table width="100%"  id="TableOrg" style="height : 90%">
                    	<img src="images/iconSmallXPOrganization.gif">
                    	<tr style="width:100%">
                    		<td class="title" width="32%"><%=getNLS("Employee")%>: <td style="color:#50596F" id="OrgEmp"></td>


                    	</tr>
                    	<tr style="width:100%">
                    		<td class="title"><%=getNLS("Member")%>: <td style="color:#50596F" id="OrgMem"></td>


                    	</tr>
                   	 </table>
                    </div>

            <!-- ici commence le frame des licenses -->
            <div id="lics"  class="scroll-cont" style="width : 38%;margin-left:3px;" >
                <div id="lics_section1_container">
                    <!-- JIC 15:03:03 Added License type -->
                    <div>
                        <table class="titleLic" border="0" cellspacing="0" cellpadding="0" width="100%">
                            <colgroup>
                                <col class="tableLicMargin" />
                                <col class="tableLicCheckbox" />
                                <col class="tableLicTitle" />
                            </colgroup>
                            <tr>
                                <td/>
                                <td>
                                <%if (casualHour != 0){%>
                                    <input type="checkbox" id="Casual" name="Casual" checked onchange="javascript:CheckUncheckCasual()" />
                                <%}else{%>
                                    <input type="checkbox" id="Casual" name="Casual" onchange="javascript:CheckUncheckCasual()"/>
                                <%}%>
                                </td>
                                <td/>
                                <td><div id="CasualLicenseType"><%=getNLS("LicenseAssignCasual")%></div></td>
                            </tr>
                        </table>
                    </div>
                    <div id="lics_section1_w_filter" class="licHeader">
                        <table  border="0" cellspacing="0" cellpadding="0" width="100%" colspan="4*,*">
                            <tr>
                                <td><%addFirstLicenseSection(out);%></td>
                                <td >
                                    <div>
                                        <input id="lic_filter" type="text" title="<%=nlsLicSectionFilter%>" value="" onkeyup="license_filter(this,['lics_section1_table','lics_Available_table','lics_UnavailRich_table','lics_UnavailServer_table']);" />
                                    </div>
                                </td>
                            </tr>
                        </table>
                    </div>
                    <div id="lics_section1_body" width="100%" style="display:none;">
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
            <!-- ici finit le frame des licenses -->
            </div>

            <hr>
            <div class="divMilieus horiz" >
                    <table id="TableToFilter" width="100%" style="height:95% ; border-color: white" border="1px" >
                    </table>
            </div>


            <textarea style="display:none"  name="HiddenElement" id="HiddenElement"></textarea>

        </form>
	<script>addFooter("javascript:sendToUpdatePage()","images/buttonDialogDone.gif","<%=Update%>","<%=Update%>");</script>
</body>
</html>
