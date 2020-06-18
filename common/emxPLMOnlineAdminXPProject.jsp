<%@ page import="com.dassault_systemes.vplmposadminservices.model.PLMProjectTemplate" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="com.matrixone.vplm.posws.stubsaccess.ClientWithoutWS" %>
<%@ page import="com.dassault_systemes.vplmposadministrationui.uiutil.AdminUtilities"%>
<%@include file = "../common/emxPLMOnlineIncludeStylesScript.inc"%>
<%@include file = "../common/emxPLMOnlineAdminAttributesCalculation.jsp"%>
<%@ page import="com.dassault_systemes.pos.resource.interfaces.PLMxPosTableServices" %>
<%@include file = "../common/emxPLMOnlineAdminAuthorize.jsp"%>
<script type="text/javascript" src="scripts/emxUICore.js"></script>
<%--
    Document   : emxPLMOnlineAdminXPProject.jsp
    Author     : LXM
    Modified :  19/10/2010 -> New UI
                26/05/2011 -> Replace Post by GEt for AIX
--%>
<html>
    <head>
    <%
        String ProjectName = getNLS("ProjectName");
    String HostCompanyName= getHostCompanyName(mainContext);
	String Description = getNLS("Description");
	String Template = getNLS("Template");
	String NoTemplateIsApplied = getNLS("NoTemplateIsApplied");
	String Update = getNLS("Update");
	String Create = getNLS("Create");
         String Edit= getNLS("Edit");
        String Family = getNLS("Family");
        String FilterUsers = getNLS("FilterUsers");
        String ERR_CANNOTBEEMPTY = getNLSMessageWithParameter("ERR_CannotBeEmpty","ProjectName");
        // RBR2: FUN [080973]
		String titleNLS = getNLS("Title");
        
        
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
        ResultString[0] = getNLSMessageWithParameter("CONF_HasBeenUpdated","Project");
        ResultString[4] = getNLSMessageWithParameter("CONF_HasBeenCreated","Project");
        ResultString[1] = getNLSMessageWithParameter("ERR_CreationRight","UserID");
        ResultString[2] = getNLSMessageWithParameter("ERR_IDCannotBeEmpty","ProjectName");
        ResultString[3] = getNLSMessageWithParameter("ERR_IDAlreadyExist","ProjectOrOrganization");
        String  ERR_CannotBeEmpty= getNLSMessageWithParameter("ERR_CannotBeEmpty","ProjectName");

        String TabInteger[] = new String[2];
        TabInteger[0]=ProjectName;
        TabInteger[1]="Special";
        String ERRCannotContain = myNLS.getMessage("ERR_ProjectCannotContain",TabInteger);
       String plmexternalid = (String)emxGetParameter(request,"PLM_ExternalID");
	   String orgid = (String)emxGetParameter(request,"currentOrganization");
	   if(orgid==null || orgid.isEmpty()) orgid = HostCompanyName;
          String source = (String)emxGetParameter(request,"source");
          if(source == null)source="";

    %>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<style>
.divMilieuXPProjects {
	bottom: 25px;
	left: 0;
	overflow: auto;
	position: absolute;
	height: 77%;
	right: 0;
	top: 20%;
	padding-left: 0px;
	padding-top: 0px;
	padding-right: 0px;
	padding-bottom: 0px;
	top: 175px;
}


</style>
<script type="text/javascript">
       
            function ajaxFunction(source)
            {
                DisplayLoading();
                var xmlhttp;
                if (window.XMLHttpRequest)
                {
                    // code for IE7+, Firefox, Chrome, Opera, Safari
                    xmlhttp=new XMLHttpRequest();
                }
                else if (window.ActiveXObject)
                {
                    // code for IE6, IE5
                    xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
                }
                else
                {
                    alert("Your browser does not support XMLHTTP!");
                }

                xmlhttp.onreadystatechange=function()
                {
                    if(xmlhttp.readyState==4)
                    {
                        var personsTable = xmlhttp.responseXML.getElementsByTagName("Person");
                        var roleTable = xmlhttp.responseXML.getElementsByTagName("Role");

                        var table=document.getElementById('TableToFilter');
                        var row=table.insertRow(-1);
                        row.height = "10px";
                        var cell=row.insertCell(-1);
                        cell.style.fontSize = "10pt";
                        cell.style.fontWeight = "bold";
                        cell.innerHTML="<%=FilterUsers%>"+"<input size='5' id='FilterArea' onkeyup='javascript:filterStrings();'>";

                        for (var i = 0 ; i <roleTable.length ; i++){
                            var cell=row.insertCell(-1);
                            var roleName = roleTable[i].getElementsByTagName("PLM_ExternalID").item(0).firstChild.data;
                            var roleNameNLS = roleName;

                        cell.style.fontWeight = "bold";
                        cell.style.fontSize = "12pt";
                        cell.bgColor = "#659ac2";
                        cell.style.color="white";
                        cell.id=roleName;
                         <%for (int j = 0 ; j < 7 ; j ++){%>
                    if ("<%=Roles[j][0]%>" == roleName)roleNameNLS="<%=Roles[j][1]%>";
                    <%}%>
                    cell.innerHTML=roleNameNLS;
                    cell.title=roleNameNLS;
                    }

                     for (var i = 0 ; i <personsTable.length ; i++){
                         var row=table.insertRow(-1);

                         var cell=row.insertCell(-1);
                         cell.style.fontWeight = "bold";
                         cell.style.fontSize = "12pt";
                         cell.bgColor = "#659ac2";
                         cell.style.color="white";
						 // ALU4 06.02.2017 IR-525465-3DEXPERIENCER2018x Collaborative Space Assignment - User names are not displayed correctly if name contains a dash ( - ) and user is not updated
						 var childNodes = personsTable[i].childNodes ;
						 // Determine person ID
						 var personID = "";
						 for(var k = 0; k < childNodes.length; k++)
						 {
							var temp = childNodes[k].data ; 
							if(temp == undefined)
								break;
							personID = personID + temp ;
						 }
					     // ALU4 06.02.2017 codes before fix provided for IR-525465-3DEXPERIENCER2018x
                         //cell.innerHTML=personsTable[i].firstChild.data.htmlEncode();
						 // AJY3 2/20/2018 IR-579811-3DEXPERIENCER2019x Use htmlEncode to correctly encode names.
						 cell.innerHTML = personID.htmlEncode();
                         for (var j = 0 ; j <roleTable.length ; j++){
                           var roleName = roleTable[j].getElementsByTagName("PLM_ExternalID").item(0).firstChild.data;
                           var roleNameNLS = roleName;
                         <%for (int j = 0 ; j < 7 ; j ++){%>
                    if ("<%=Roles[j][0]%>" == roleName)roleNameNLS="<%=Roles[j][1]%>";
                    <%}%>
                           var cell=row.insertCell(-1);
                           // ALU4 06.02.2017 codes before fix provided for IR-525465-3DEXPERIENCER2018x
                           //var string = personsTable[i].firstChild.data+";"+roleName;
                           //var name = personsTable[i].firstChild.data + " / " + roleNameNLS;
						   var string = personID +";"+roleName;
						   var name = personID + " / " + roleNameNLS;

                           string = ReplaceAllOccurence(string," ",",");
                           cell.innerHTML="<input type='checkbox' align='center'  id="+string+"  onclick='javascript:RemoveCheckBox(\""+string+"\")' title=\""+name+"\" >";
                         }
                     }
                     HideLoading();
                     context2Stock();
                }

            }

           xmlhttp.open("GET","emxPLMOnlineAdminAjaxResponse.jsp?source="+source+"&PersonDestination=XP&Destination=XP&Method=Create",true);
           xmlhttp.send(null);
        }



        function context2Stock(){
				var txt =document.getElementById("ctx2Stock").innerHTML;
            	if (txt!=null && txt!="") {
					var boxCombin = txt.split(",,");
					for (var i=1; i<boxCombin.length; i++) {
                    	var nameCheckBox = boxCombin[i].htmlDecode();
                   		if(document.getElementById(nameCheckBox)!=null) {
							document.getElementById(nameCheckBox).checked = true;
						}
					}
				}
    	}


 function createProjectDB(paramValues,source){
             var xmlhttp;

            if (window.XMLHttpRequest)
            {
                 // code for IE7+, Firefox, Chrome, Opera, Safari
                xmlhttp=new XMLHttpRequest();
            }
            else if (window.ActiveXObject)
            {
                // code for IE6, IE5
                xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
            }
            else
            {
                alert("Your browser does not support XMLHTTP!");
            }
            xmlhttp.open("POST","emxPLMOnlineAdminXPCreateProjectContextDB.jsp",true);
            xmlhttp.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
            xmlhttp.send(paramValues);
            
            xmlhttp.onreadystatechange=function()
            {
                if(xmlhttp.readyState==4)
                { HideLoading();
                   var createResult = xmlhttp.responseXML.getElementsByTagName("createResult");
				   if(createResult[0].firstChild.data==0 || createResult[0].firstChild.data==4) {
						var dbView = document.getElementById("ctx2Stock").innerHTML;
						var removeSelect = document.getElementById("removeSelect").innerHTML;
						var boxCombin = removeSelect.split(",,");
						for (var i=1; i<boxCombin.length; i++) {
							dbView = ReplaceAllOccurence(dbView,",,"+boxCombin[i],"");
						}
						document.getElementById("removeSelect").innerHTML = "";
						document.getElementById("ctx2Stock").innerHTML = dbView + document.getElementById("HiddenElement").innerHTML;
						document.getElementById("HiddenElement").innerHTML = "";
                        var project = $("project").innerHTML.htmlDecode();
						if((prjName != "") && (prjName != project)){
                          	prjName="";
                        }
                        if ((project==null) || (project.indexOf('input')>-1) || (project.indexOf('INPUT')>-1)) {
                        	$("project").innerHTML = $("PrjPLMIdIn").value;
                        }
				   }
                    <% for (int i = 0 ; i <5 ; i++){%>
                               if (<%=i%> == createResult[0].firstChild.data){
                                      document.getElementById("messageError").innerHTML = "<%=ResultString[i]%>";
                               }
                    <%}%>
                   if (document.getElementById("messageError").innerHTML == "") document.getElementById("messageError").innerHTML = "<%=ResultString[1]%>";
                   document.getElementById("hidethisone").style.display="block";

           }
            }

          
        }
		

	        function getContentsForCreation() {
                DisplayLoading();
                var project ="";//id
                var source="";//either crate/update
                               var newPrj = "";//id
                               
                               var prjTtlInput = "";
                               var newPrjTile = "";
                               var selectAutoName = document.getElementById("autoname");
                               var auto = false;
                               
                               if (document.getElementById("projectV_Name").type == "text"){
                                              //create zone
                                              prjTtlInput = document.getElementById("projectV_Name").value;
                                             // newPrjTile = prjTtlInput
 											  source = "Other";
                					}
                               else{
                               //update zone
                   					if(document.getElementById("projectV_Name").childNodes[0].type == "text")
                   						{
                   							// title update: update
                   							newPrjTile = document.getElementById("projectV_Name").childNodes[0].value.trim();
                   						}
                   					else
                   						{
                   							// Non title update: update
                   							newPrjTile = document.getElementById("projectV_Name").childNodes[0].textContent.trim();
                   						}
                   
	                                		prjTtlInput = newPrjTile;//oldone
	                          				source = "XPUpdateProject";
                				}
                               
                               if (document.getElementById("project").value !== undefined){
									project = document.getElementById("project").value;
								}
                               else if(document.getElementById("project").innerHTML !== undefined ) {
									project = document.getElementById("project").innerHTML;
								}
                               
                               if(source === "Other" && selectAutoName.checked){
                                      auto = true;
                               }
                               //Handle both creation and update name validation.
                               //Check at update that name doesn't contain illegal characters only if it has been changed, to support old illegal names.
                				if ((hasSpecialChar(project,true) && source==="Other" && !auto)  
                                              || (hasSpecialChar(prjTtlInput,true) && source==="Other") 
                                              || (newPrjTile !== prjTtlInput && hasSpecialChar(newPrjTile,true)))// <-- edit condition
               					 {
                              				 // TODO: RBR2: Manage the separate for name and title
                                              alert("<%=ERRCannotContain%>" + ": " + emxUIAdminConsoleUtil.FORBIDDEN_CHARACTERS_WITH_DOT);
  												HideLoading();
								}
                				else{
 								// consider project name in non auto mode only
                               if((project == "" && !auto) ||  (newPrjTile == "" && source !== "Other")){
                                              alert("<%=ERR_CannotBeEmpty%>");
                                              HideLoading();
                               }
                               else{
                               //Project Name and Description
                               var paramValues ="project="+encodeURIComponent(project)+"&V_Name="+encodeURIComponent(prjTtlInput)+
                                                                                            "&source="+source+"&V_id="+encodeURIComponent(document.getElementById("V_id").value);

               					if (document.getElementById("parent") != null && document.getElementById("parent").options.length != 0){
                                              this.paramValues =paramValues + "&parent=" + document.getElementById("parent").options[document.getElementById("parent").options.selectedIndex].text;
              					 }
               					this.paramValues =this.paramValues + "&HiddenElement="+encodeURIComponent(document.getElementById("HiddenElement").innerHTML.htmlDecode());
               					this.paramValues =this.paramValues + "&removeSelect="+encodeURIComponent(document.getElementById("removeSelect").innerHTML.htmlDecode());
               					this.paramValues =this.paramValues + "&currentOrganization="+encodeURIComponent(document.getElementById("FilterArea3").options[document.getElementById("FilterArea3").selectedIndex].value);
                                                             //paramValues =paramValues + "&NewPrjName="+encodeURIComponent(newPrj);
                                                             this.paramValues =this.paramValues + "&NewPrjV_Name="+encodeURIComponent(newPrjTile);
                                                             if(source === "Other"){
                                                            	 this.paramValues =this.paramValues + "&autoName="+encodeURIComponent(auto.toString());
                                                             }
                               createProjectDB(this.paramValues,this.source);
                }
                               }
}


        var xmlreqs = new Array();

        function displayRoleMatrixWithOrganization()
        {
             var xmlhttpOrg = xmlreqs[2];
            if(xmlhttpOrg.readyState==4)
            {

                 var responsePLMID = xmlhttpOrg.responseXML.getElementsByTagName("PLM_ExternalID");


 					 for(var i = 0 ; i < responsePLMID.length ; i++ ){
 	                   var nameElement = responsePLMID[i].firstChild.data;
 	                   if (nameElement == "<%=orgid%>"){
 	                       var nouvel_element = new Option(nameElement,nameElement,true,true);
 	                   }else{
 	                	    var nouvel_element = new Option(nameElement,nameElement,false,false);
 	                   }
 	                   document.getElementById("FilterArea3").options[document.getElementById("FilterArea3").length] = nouvel_element;
 	           }
 					ajaxFunction('PersonRole');

           }

            }
        
      //SSI21 : Title project chnages
        function autoNameValue() {
	    	var checkBox = document.getElementById("autoname");
	    	var selectName = document.getElementById("project");
	        if( checkBox.checked ) {
	        	selectName.value = "";
	        	selectName.disabled = true;
	        	checkBox.focus();
	        }
	        else
	        {
	        	selectName.disabled = false;
	        }
	        return;
	      }  

        function refreshTable(){
				var orga = $("FilterArea3").options[$("FilterArea3").options.selectedIndex].value;
        <%if (!source.equals("XPProject")){%>
				window.location.replace("emxPLMOnlineAdminXPProject.jsp?currentOrganization="+encodeURIComponent(orga));
        <%}else{%>
				window.location.replace("emxPLMOnlineAdminXPProject.jsp?PLM_ExternalID="+encodeURIComponent("<%=plmexternalid%>")+"&source=XPProject&currentOrganization="+encodeURIComponent(orga));
        <%}%>
		}

        function loadOrganization(){
        	 	xmlreq("emxPLMOnlineAdminAjaxResponse.jsp","source=Organization&Destination=VPLMAdmin&filterOrg=*&responseOrg=org_Type",displayRoleMatrixWithOrganization,2);
        }

        var prjName=""; // No Importance as of now in here
        var prjTitle = "";
        function renamePRJ(){
         	 if(prjTitle==""){
         		prjTitle=$("projectV_Name").childNodes[0].textContent.trim();
         	 	//$("project").innerHTML='<input type="text" name="PrjPLMIdIn" id="PrjPLMIdIn" value="'+prjName+'" >';
         	 	$("projectV_Name").innerHTML='<input type="text" name="projectV_NameIN" id="projectV_NameIN" value="'+prjTitle.trim()+'" >';
         	 }
        }
        
        function renameTitle(){
        	 if(prjTitle==""){
        		prjTitle=$("projectV_Name").childNodes[0].textContent.trim();
        	 	//$("project").innerHTML='<input type="text" name="PrjPLMIdIn" id="PrjPLMIdIn" value="'+prjName+'" >';
        	 	$("projectV_Name").innerHTML='<input type="text" name="projectV_NameIN" id="projectV_NameIN" value="'+prjTitle.trim()+'" >';
        	 }
       }

        </script>
</head>
<%
       String YoudonotHaveRights       =  getNLS("NonAppropriateContext");

    %>
<%if (!AdminUtilities.isCentralAdmin(mainContext) && !source.equals("XPProject")){%>
<body>
	<script>addTransparentLoading("<%=YoudonotHaveRights%>","display");</script>
</body>
<%}else{%>
<body onload="javascript:loadOrganization();">
	<%
      String message = (String)emxGetParameter(request,"message");
       	String Desc = "";
      	String PrjName="";
        String ctxToStock =""; // rbr2: No change with this
        String PrjFamily="";
        String PrjVisibility="";
        // RBR2: FUN [080973]
        String PrjTitle = "";

      if (source == null){source ="";}
      if (source.equals("XPProject")){
            Map project = new HashMap();
            Map listproject = new HashMap();
            Map fin =new HashMap();

            project.put("PLM_ExternalID",plmexternalid);
            listproject.put("project0",project);

			fin.put("method","queryProject");
			fin.put("iProjectInfo",listproject);
			// Step 1: Get Project Info + Title
            // JIC 18:07:03 FUN076129: Removed use of PLM key/added context
            ClientWithoutWS client = new ClientWithoutWS(mainContext);
            Map proj = client.serviceCall(fin);
            Map rep =(Map) proj.get("project0");
            StringList members = (StringList)rep.get("members");
            Desc = (String)rep.get("v_id");
            PrjName=(String)rep.get("PLM_ExternalID");
            PrjFamily=(String)rep.get("Family");
            PrjVisibility=(String)rep.get("Visibility");
            // RBR2: Get title from Map
            PrjTitle = (String)rep.get("V_Name");

            Map parametrec= new HashMap();
            Map lisc= new HashMap();
            project= new HashMap();
            listproject= new HashMap();

			// Step 2: Get Context Info + Title
            String namePrj = "*."+orgid+"."+PrjName;
            parametrec.put("PLM_ExternalID",namePrj);
            parametrec.put("members",new String[]{""});
            parametrec.put("v_id","");
            lisc.put("context0",parametrec);

            String[] slec = new String[1];
            slec[0]="person";

			fin.put("method","queryContext");
			fin.put("iContextInfo",lisc);
            fin.put("iSelectableList",slec);
            Map result = client.serviceCall(fin);
            Map ctextResult = (Map)result.get("context");

            for (int i = 0; i< ctextResult.size(); i ++){
                Map ctxUnique = (Map)ctextResult.get("context"+i);
				String roleName = ((String)ctxUnique.get("PLM_ExternalID")).substring(0,((String)ctxUnique.get("PLM_ExternalID")).indexOf("."+orgid+"."+PrjName));
                members = (StringList)ctxUnique.get("member");
                for (int j = 0 ; j < members.size(); j++){
                	ctxToStock = ctxToStock + ",," + (members.get(j) + ";" + roleName).replaceAll(" ",",");
                }
            }
            // RBR2: Roles to be displayed.
			ctxToStock = EncodeUtil.escape(ctxToStock);
        }
     %>
	<script>addTransparentLoading("");</script>
	<script>addReturnMessage();</script>
	<textarea id="ctx2Stock" style="display: none"><%=ctxToStock%></textarea>
	<textarea name="removeSelect" rows="1" id="removeSelect"
		style="display: none"></textarea>
	<div>
		<table>
			<tr>
				<td>
					<div class="divHautXPProject" style="position: absolute";>
						<table width="100%">
							<tr style="height: 60px">
								<!-- RBR2: Title entries -->
								<td class="pic"><img src="images/I_ENOVIA_RscProject.bmp">
								</td>

								<td class="title"><%=titleNLS%>:<b style="color: red">*</td>
								<%
                    if (source.equals("XPProject")){%>
								<td name="projectV_Name" id="projectV_Name"
									style="font-family: Arial, Helvetica, Sans-Serif; font-weight: bold; font-size: 10pt; letter-spacing: 1pt; color: #50596f">
									<%=PrjTitle%><input type="button" name="btnRename"
									value="<%=Edit%>" onclick="javascript:renameTitle()"
									style="padding: 4px; margin: 10px">
								</td>
								<%}else{%>
								<td><input type="text" id="projectV_Name"
									name="projectV_Name" size="30"
									onkeypress="return enterEvent(event,getContentsForCreation);">
								</td>
								<%}%>
								

								<td class="title"><%=ProjectName%>:<b style="color: red">*</td>
								<% String disabled = "",checked=""; %>
								<%
                    if (source.equals("XPProject")){%>
								<td name="project" id="project"
									style="font-family: Arial, Helvetica, Sans-Serif; font-weight: bold; font-size: 10pt; letter-spacing: 1pt; color: #50596f"><%=PrjName%></td>
								<!--RBR2: Commented this <td ><input type="button" name="btnRename" value="" onclick="javascript:renamePRJ()"></td> -->
								<%}else{%>
								<td><input type="text" id="project" name="project"
									size="30"
									onkeypress="return enterEvent(event,getContentsForCreation);"
									value=""> <input type="checkbox" id="autoname"
									name="autoname" onClick="autoNameValue()" <%=checked %> /> <%= i18nNow.getI18nString("emxComponents.Common.AutoName","emxComponentsStringResource",context.getSession().getLanguage()) %>
								</td>
								<%}%>


							</tr>
							<tr style="height: 60px">
								<td></td>
								<!-- RBR2: Org entries -->
								<td class="title"><%=getNLS("CurrentOrganization")%>:</td>
								<td><select id='FilterArea3' onchange='refreshTable()'></select>
								</td>
								<%String prefUser = prefUtil.getUserPreferredUISolution(mainContext);
                    if(prefUser.equals("TEAM")){%>
								<td class="title"><%=Template%> :</td>
								<td
									style="font-family: Arial, Helvetica, Sans-Serif; font-weight: bold; font-size: 10pt; letter-spacing: 1pt; color: #50596f">
									<% if (source.equals("XPProject")){
                            PLMProjectTemplate clientutil= new PLMProjectTemplate();
                            StringList listTemplates =clientutil.getAllTemplatesFromFamilyVisibility(context,PrjFamily,PrjVisibility);
                            if(listTemplates.size() > 0){
                            %> <select name="parent" id="parent"
									onkeypress="return enterEvent(event,getContentsForCreation);">
										<%
                                    for (int i = 0; i < listTemplates.size() ; i++){
                                        String templateName = (String)listTemplates.get(i);
                                        if(templateName.contains(PrjVisibility) && templateName.contains(PrjFamily)){
                                        %>
										<option selected><%=templateName%></option>
										<%}else{%>
										<option><%=templateName%></option>
										<%}
                                    }
                            }else{%>
										<%=NoTemplateIsApplied%>
										<%}
                        }else{%>
										<select name="parent" id="parent"
										onkeypress="return enterEvent(event,getContentsForCreation);">
											<%
                                PLMProjectTemplate clientutil= new PLMProjectTemplate();
                                StringList prjTemplates = clientutil.getProjectTemplates(context);
                                for(int i = 0 ; i < prjTemplates.size() ; i++){
                                    String NameTemplate = (String)prjTemplates.get(i);
                                    %>
											<option>
												<%=NameTemplate%></option>
											<%}
                        }%>
									</select>
								</td>
								<%}else{%>
								<%if (!source.equals("XPProject")){%>
								<td class="title"><%=Family%> :</td>
								<td
									style="font-family: Arial, Helvetica, Sans-Serif; font-weight: bold; font-size: 10pt; letter-spacing: 1pt; color: #50596f">
									<select name="parent" id="parent"
									onkeypress="return enterEvent(event,getContentsForCreation);">
										<option></option>
										<%
                                manageContextTransaction(mainContext,"start");
                                MapList mpl = PLMxPosTableServices.getFamiliesForSolution(mainContext, "VPM");
                                manageContextTransaction(mainContext,"end");
                                for (int i = 0 ; i < mpl.size(); i++ ){
                                    Hashtable h = (Hashtable)mpl.get(i);
                                    String nameFamily = (String)h.get("V_row_name");
                                    %>
										<option>
											<%=nameFamily%></option>
										<%}%>
								</select>
								</td>
								<%}
                    }%>
							</tr>
							<tr>
								<td></td>
								<td class="title"><%=Description%>:</td>
								<% if (source.equals("XPProject")){%>
								<td><input type="text" maxlength="100" size="30"
									name="V_id" id="V_id"
									onkeypress="return enterEvent(event,getContentsForCreation);"
									value="<%=Desc%>"></input></td>
								<td></td>
								<%}else{%>
								<td><input type="text" maxlength="100" size="30"
									name="V_id" id="V_id"
									onkeypress="return enterEvent(event,getContentsForCreation);"></input>
								</td>
								<%}%>
								<td class="title"></td>
								<td></td>
								<td class="title"></td>
								<td></td>
							</tr>

						</table>
					</div>
				</td>
			</tr>
			<tr>
				<td>
					<div class="divMilieuXPProjects">
						<table id="TableToFilter" width="98%" style="border-color: white"
							border="1px">
						</table>
					</div>
				</td>
			</tr>
		</table>


	</div>
	<textarea style="display: none" name="HiddenElement" id="HiddenElement"></textarea>
	<div id="divPageFoot" style="position: fixed;">
		<script>
        <%
            if (source.equals("XPProject")){%>
                addFooter("javascript:getContentsForCreation();","images/buttonDialogDone.gif","<%=Update%>","<%=Update%>");
             <%}else{%>
                addFooter("javascript:getContentsForCreation();","images/buttonDialogAdd.gif","<%=Create%>","<%=Create%>");
             <%}%>
            </script>
	</div>
</body>
<%}%>
</html>
