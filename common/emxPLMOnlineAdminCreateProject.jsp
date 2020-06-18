<%@ page import="com.dassault_systemes.vplmposadministrationui.uiutil.AdminUtilities"%>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxPLMOnlineAdminAttributesCalculation.jsp"%>
<%@include file = "../common/emxPLMOnlineIncludeStylesScript.inc"%>
<%@include file = "../common/emxPLMOnlineAdminAuthorize.jsp"%>
<script type="text/javascript" src="scripts/emxUICore.js"></script>
<%--
    Document   : emxPLMOnlineAdminCreateProject.jsp
    Author     : LXM
    Modified :   26/05/2011 -> Replace Post by GEt for AIX
--%>
<%
     String dest = (String)emxGetParameter(request,"dest");
       String ERR_CannotBeEmpty= getNLSMessageWithParameter("ERR_CannotBeEmpty","ProjectName");
    	String ERR_TitleCannotBeEmpty = getNLSMessageWithParameter("ERR_CannotBeEmpty","ProjectTitle");
    	String ERR_TitleCannotBeGreater = getNLSMessageWithParameter("ERR_CannotBeGreater","ProjectTitle");
    	String ERR_NameCannotBeGreater = getNLSMessageWithParameter("ERR_CannotBeGreater","ProjectName");
    	
                String TabInteger[] = new String[2];
        TabInteger[0]=getNLS("ProjectName");
        TabInteger[1]=getNLS("Special");
        String ERRCannotContain = myNLS.getMessage("ERR_ProjectCannotContain",TabInteger);

    // JIC 16:07:18 IR IR-456664-3DEXPERIENCER2015x: Added local administration variable
    boolean isLocal = false;
    if(AdminUtilities.isLocalAdmin(mainContext))isLocal=true;
%>
<html>
    <head>
        <script>
            var xmlreqs = new Array();
            var xmlhttpProject = "";
            var all = true;

            function formatResponse()
            {
                xmlhttpProject = xmlreqs[0];

                xmlhttpProject.onreadystatechange=function()
                {
                    if(xmlhttpProject.readyState==4)
                    {
                        if(all){xmlreq("emxPLMOnlineAdminAjaxResponse.jsp","source=Discipline",ResponseDiscipline,1);}
                        //SSI21 : FUN[080973] Title project chnages, call change to new method
                        addOptionsToSelectWithoutDoublonsProject("parent",xmlhttpProject,"PLM_ExternalID","imageWaitingProject","8");   	
                    }
                }
            }
			
            //SSI21: FUN[080973] Title project Changes, new method to set Title and name for parent projects
            function addOptionsToSelectWithoutDoublonsProject(selectName,req,tagName,imageName,sizeIn) {
                document.getElementById(selectName).style.display = '';
                if(imageName != "")document.getElementById(imageName).style.display = 'none';

                var alreadyDone ="";
                for (var j = 1; j < document.getElementById(selectName).length ; j++){
                    alreadyDone= alreadyDone + document.getElementById(selectName).options[j].value+";;";
                }
				alreadyDone = alreadyDone.split(";;");
                var response = req.responseXML.getElementsByTagName(tagName);
                var responseTitle = req.responseXML.getElementsByTagName("V_Name")
                 if (sizeIn == null) sizeIn=12;

                if(response.length < sizeIn ){document.getElementById(selectName).size=response.length+1;}else{
                     document.getElementById(selectName).size=sizeIn;
                 }
                 for(var i = 0 ; i < response.length ; i++ ){
                     if( (response[i].firstChild != null)  && (responseTitle[i].firstChild != null) ) {
                         if(alreadyDone.contains(response[i].firstChild.data) == false){
                             alreadyDone.push(response[i].firstChild.data);
                         var nouvel_element = new Option(responseTitle[i].firstChild.data,responseTitle[i].firstChild.data,false,true);
                         nouvel_element.id=response[i].firstChild.data;
                         nouvel_element.setAttribute("title","Name: "+nouvel_element.id);
                         nouvel_element.selected=false;
                         document.getElementById(selectName).options[document.getElementById(selectName).length] = nouvel_element;
                		}
            		}
               }
          } // End of method
            
            function ResponseDiscipline(){
                var xmlhttpDiscipline= xmlreqs[1];

                xmlhttpDiscipline.onreadystatechange=function()
                {
                    if(xmlhttpDiscipline.readyState==4)
                    {
                        xmlreq("emxPLMOnlineAdminAjaxResponse.jsp","source=Confidentiality",ResponseConfidentiality,2);
                        addOptionsToSelect("disciplines",xmlhttpDiscipline,"Discipline","imageWaitingDiscipline");
                    }
                }
            }

            function ResponseConfidentiality(){
                var xmlhttpConfidentiality= xmlreqs[2];
                xmlhttpConfidentiality.onreadystatechange=function()
                {
                    if(xmlhttpConfidentiality.readyState==4)
                    {xmlreq("emxPLMOnlineAdminAjaxResponse.jsp","source=Family&Solution=VPM",ResponseFamily,3);

                        addOptionsToSelect("secLevel",xmlhttpConfidentiality,"Name", "imageWaitingConfidentiality");
                    }
                }
            }

            function ResponseFamily(){
                var xmlhttpFamily= xmlreqs[3];
                xmlhttpFamily.onreadystatechange=function()
                {
                    if(xmlhttpFamily.readyState==4)
                    {
                        addOptionsToSelect("Family",xmlhttpFamily,"Name","imageWaitingFamily","non","7");

                    }
                }
            }

            function initCreateProject(){
                var destProject =  "source=Project&Solution=VPM&Destination=VPLMAdmin&Method=Create";
                xmlreq("emxPLMOnlineAdminAjaxResponse.jsp",destProject,formatResponse,0);
            }

            function createProjectResult(){
                var xmlhttpCreateProject= xmlreqs[3];

                xmlhttpCreateProject.onreadystatechange=function()
                {
                    if(xmlhttpCreateProject.readyState==4)
                    {
                        HideLoading();
                        var createResult = xmlhttpCreateProject.responseXML.getElementsByTagName("createResult");
                        document.getElementById("hidethisone").style.display="block";
                        document.getElementById("messageError").innerHTML=createResult[0].firstChild.data;
                    }
                    all=false;
                    initCreateProject();
                }
            }

            function getContentsForCreation() {
                DisplayLoading();
                var selectAutoName = document.getElementById("autoname");
                
                if(document.getElementById("projectTitle").value == ""){
                	HideLoading();																//Use
                	alert("<%=ERR_TitleCannotBeEmpty%>");
                }
                else if(document.getElementById("projectTitle").value.length > 32)
                	{
	                	HideLoading();																//Use
	                	alert("<%=ERR_TitleCannotBeGreater%>");
                	}
                
                if(!selectAutoName.checked && (document.getElementById("project").value == "")){
                	// non auto + invalid 
                     HideLoading();
			 		 alert("<%=ERR_CannotBeEmpty%>");
                } else {
                	   	
                    if(!selectAutoName.checked && (hasSpecialChar(document.getElementById("project").value)) || (document.getElementById("project").value.indexOf(".") > -1 )){
                  		alert("<%=ERRCannotContain%>" + ": " + emxUIAdminConsoleUtil.FORBIDDEN_CHARACTERS_WITH_DOT);
                      	HideLoading();
                	}
                  	//IR-668265-3DEXPERIENCER2018x AJY3 Limit Collaborative Space name to 32 characters
                    else if (!selectAutoName.checked && document.getElementById("project").value.length > 32){
                    	HideLoading();
                    	alert("<%=ERR_NameCannotBeGreater%>");
                    }
                    else{  
                	//SSI21 : Title project chnages
                	var	auto = "true";
                	if(!selectAutoName.checked) auto = "false";
                		
                	
                    var paramValues ="project="+encodeURIComponent(document.getElementById("project").value)+"&V_id="+encodeURIComponent(document.getElementById("V_id").value)+"&projectTitle="+encodeURIComponent(document.getElementById("projectTitle").value)+"&autoName="+encodeURIComponent(auto);
                    var selectLevel = encodeURIComponent(document.getElementById("secLevel").options[document.getElementById("secLevel").options.selectedIndex].text);
                    if(document.getElementById("secLevel").options.selectedIndex == 0)selectLevel="";
                    paramValues =  paramValues + "&secLevel="+selectLevel;

                    if (document.getElementById("parent").options.selectedIndex == -1){ alert("Please choose a parent project");
                        HideLoading();
                    }else{ 
                    	//SSI21 : Title project chnages
                        var parent = document.getElementById("parent").options[document.getElementById("parent").options.selectedIndex].id;    //replace text with PLM_ExternalID
                    
                        <%if (!isLocal){%>
                            if ( (parent =="") || (document.getElementById("parent").options.selectedIndex == 0) ){
                                // JIC 2013:08:23 IR IR-247727V6R2013x: Added empty family support
                                var family = encodeURIComponent(document.getElementById("Family").value);
                                if(document.getElementById("Family").options.selectedIndex == 0) family="";
                                paramValues =  paramValues + "&parent=&Family="+family;
                            }else{
                                paramValues =  paramValues + "&parent="+encodeURIComponent(parent);
                            }
                        <%}
                        else {%>
                            paramValues =  paramValues + "&parent="+encodeURIComponent(parent);
                        <%}%>
                        var disc = document.getElementById("disciplines");
                        var discName="";
                        for (var j=1; j<disc.options.length ;j++){
                            if (disc.options[j].selected){
							discName=discName+disc.options[j].innerHTML.htmlDecode() +",";
                            }
                        }
                        discName=discName.substring(0,discName.length-1);
                        paramValues =  paramValues + "&disciplines="+encodeURIComponent(discName);

                        createProjectInDB(paramValues);
                    }
                }
            }
            }

            function createProjectInDB(paramValues){
                xmlreq("emxPLMOnlineAdminCreateProjectDB.jsp",paramValues,createProjectResult,3);
            }


            function checkParent(){
                var parent = document.getElementById("parent").options[document.getElementById("parent").options.selectedIndex].value;
                if (parent != ""){
                    document.getElementById("FamilyGroup").style.display = "none";
                }else{
                    document.getElementById("FamilyGroup").style.display = "";
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
        </script>
    </head>
    <body onload="javascript:initCreateProject()">
       <form style=" overflow: auto"   >
            <script>addReturnMessage();</script>
        <script>addTransparentLoading("");</script>
	<%if(dest==null) {%>
         <a href="emxPLMOnlineAdminProject.jsp?source=Project" class="link" ><%=myNLS.getMessage("Search")%>...</a>
	<%}%>
            <table width="100%" style="height:95% ; border-color: white" border="1px">
                <!--****************************** Premiere ligne *******************************-->
                <tr style=" height: 43%">
                    <!--****************************** Premiere colonne *******************************-->
                    <td border="1px"  width="50%" >
                        <table class="big" >
                            <thead><img src="images/I_ENOVIA_RscProject.bmp" title="<%=myNLS.getMessage("Project")%>"></thead>
                            <tr>
                              <td class="title" width="50%"><%=myNLS.getMessage("ProjectTitle")%> :</td>
                              <td><input type="text" onkeypress="return enterEvent(event,getContentsForCreation)" size="20" name="projectTitle" id="projectTitle" value=""></td>
                           </tr>
                            <tr>
                              <td class="title" width="50%"><%=myNLS.getMessage("ProjectName")%> :</td>
                             <% String disabled = "",checked=""; %>
                              <td><input type="text" onkeypress="return enterEvent(event,getContentsForCreation)" size="20" name="project" id="project" value="">
                               <input type="checkbox" id="autoname" name="autoname"	onClick="autoNameValue()" <%=checked %> />
                               <%= i18nNow.getI18nString("emxComponents.Common.AutoName","emxComponentsStringResource",context.getSession().getLanguage()) %></td>
                          </tr>
                          <tr><td class="title" width="50%"><%=myNLS.getMessage("ProjectDescription")%> :
                              </td>
                              <td>
                                  <textarea name="V_id" id="V_id" cols="15" rows="5" onkeypress="return enterEvent(event,getContentsForCreation)"></textarea>
                              </td>
                          </tr>
                        </table>
                    </td>
                    <!--****************************** Fin Premiere colonne *******************************-->
                    <!--****************************** Deuxieme colonne *******************************-->
                    <td>
                        <table class="big">
                            <thead><img src="images/I_ENOVIA_RscProject.bmp" title="<%=myNLS.getMessage("ProjectParent")%>"></thead>
                            <tr>

                            <td class="title" width="50%"><%=myNLS.getMessage("ProjectParent")%> :</td>
                            <td><img  id="imageWaitingProject"  src="images/iconParamProgress.gif" >
                                <%		if (AdminUtilities.isCentralAdmin(mainContext)){%>
						 <select name="parent" id="parent" size="1"  style="display:none" onchange="javascript:checkParent()" onkeypress="return enterEvent(event,getContentsForCreation)">
								<option style="color:gray ; font-style : italic" selected value=""><%=getNLS("None")%></option>
                                </select><%}else{%>
                                <select name="parent" id="parent" size="8"  style="display:none" onchange="javascript:checkParent()" onkeypress="return enterEvent(event,getContentsForCreation)">
                                </select>
                                <%}%>
                            </td>
                        </tr>
                        <tr id="FamilyGroup">
                            <td class="title" width="50%" ><%=getNLS("Family")%> :</td>
                            <td><img  id="imageWaitingFamily"  src="images/iconParamProgress.gif">
                                <select id="Family" style="display:none">
                                             <!-- JIC 2013:08:23 IR IR-247727V6R2013x: Added empty family support -->
                                             <option style="color:gray ; font-style : italic" selected value=""><%=getNLS("None")%></option>
                                </select>
                               <!--<input type="text" id="Family" name="Family" onkeypress="return enterEvent(event,getContentsForCreation)">-->
                            </td>
                        </tr>
                       </table>
                    </td>
                </tr>
                <!--****************************** Fin Premiere ligne *******************************-->
                <!--****************************** Deuxieme ligne *******************************-->

                <tr style="height : 43%">
                    <td>
                        <table class="big">
                            <thead><img src="images/iconSmallConfidentiality.gif" title="<%=myNLS.getMessage("Accreditation")%>"></thead>
                            <tr>
                              <td class="title"  width="50%"><%=myNLS.getMessage("Accreditation")%> :</td>
                              <td><img  id="imageWaitingConfidentiality"  src="images/iconParamProgress.gif">
                                <select name="secLevel" id="secLevel" style="display:none" onkeypress="return enterEvent(event,getContentsForCreation)">
                                             <option style="color:gray ; font-style : italic" selected value=""><%=getNLS("None")%></option>

                                </select>
                              </td>
                          </tr>

                        </table>
                    </td>
                    <td>
                        <table  class="big">

                            <thead><img src="images/iconSmallDisciplines.gif" title="<%=myNLS.getMessage("Disciplines")%>"></thead>
                            <tr>
                            <td class="title" width="50%" ><%=myNLS.getMessage("Disciplines")%> :</td>
                            <td><img  id="imageWaitingDiscipline"  src="images/iconParamProgress.gif">
                                <select name="disciplines" id="disciplines" size="10" multiple style="display:none" onkeypress="return enterEvent(event,getContentsForCreation)">
                                             <option style="color:gray ; font-style : italic" selected value=""><%=getNLS("None")%></option>

                                </select>
                            </td>
                        </tr>
                         </table>
                    </td>
                </tr>
                 <!--****************************** Fin Deuxieme ligne *******************************-->
                <!--****************************** 3eme ligne *******************************-->
            </table>
        </form>
   <%String Create =myNLS.getMessage("Create");%>
    <script>addFooter("javascript:getContentsForCreation()","images/buttonDialogAdd.gif","<%=Create%>","<%=Create%>");</script>
  </body>
</html>
