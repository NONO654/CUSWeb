<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="com.dassault_systemes.pos.resource.interfaces.PLMxPosTableServices" %>
<%@ page import="com.dassault_systemes.pos.resource.interfaces.PLMxPosDisciplineServices" %>
<%@ page import="com.matrixone.vplm.posws.stubsaccess.ClientWithoutWS" %>
<%@ page import="com.dassault_systemes.vplmposadministrationui.uiutil.EncodeUtil" %>
<%@ page import="com.dassault_systemes.vplmposadministrationui.uiutil.AdminUtilities"%>
<%@include file = "../common/emxPLMOnlineIncludeStylesScript.inc"%>
<%@include file = "../common/emxPLMOnlineAdminAttributesCalculation.jsp"%>
<%@include file = "../common/emxPLMOnlineAdminAuthorize.jsp"%>
<script type="text/javascript" src="scripts/emxUICore.js"></script>
    <%

         String ProjectName = getNLS("Name"); // RBR2: This should not be modifiable.
    	 String ProjectTitle = getNLS("Title"); // RBR2: FUN[080973]
         String ProjectDescription = getNLS("Description");
         String ProjectParent = getNLS("Parent"); // RBR2: No Change
		 String ChildrenNLS = getNLS("Children");// RBR2: No Change
         String Family = getNLS("Family");
         String Accreditation = getNLS("Accreditation");
         String Disciplines = getNLS("Disciplines");
         String ProjectUsers = getNLS("ProjectUsers");
         String Edit= getNLS("Edit");
         String Change= getNLS("Change");
	String Remove= getNLS("Remove");
 String CancelModificationButton= getNLS("CancelModificationButton");

	  String Update= getNLS("Update");
	 String SearchForUsers= getNLS("SearchForUsers");

		String TabInteger[] = new String[2];
		TabInteger[0]=getNLS("ProjectName");
		TabInteger[1]="Special";
		String ERRCannotContain = myNLS.getMessage("ERR_ProjectCannotContain",TabInteger);
		String ERR_TitleCannotBeGreater = getNLSMessageWithParameter("ERR_CannotBeGreater","ProjectTitle");

	  String message = (String)emxGetParameter(request,"message");

        if (message != null) {%> 
            <script>alert("<%=message%>");</script><%}

        String plmexternalid = (String)emxGetParameter(request,"PLM_ExternalID");
		String escplmid = EncodeUtil.escape(plmexternalid);
        Map project = new HashMap();
        Map listproject = new HashMap();
        Map fin =  new HashMap();
	  fin.put("method","queryProject");
        
	  project.put("PLM_ExternalID",plmexternalid);
        listproject.put("project0",project);
        fin.put("iProjectInfo",listproject);
                                                                                    
        // JIC 18:07:03 FUN076129: Removed use of PLM key/added context
        ClientWithoutWS client = new ClientWithoutWS(mainContext);
        Map proj = client.serviceCall(fin);
        Map rep =(Map) proj.get("project0");
                                           
        StringList members = (StringList)rep.get("members");
        String descs = (String)rep.get("v_id");
        String parents= (String)rep.get("project_Parent");
		if (parents.equals(""))parents="None";
        String accreditation= (String)rep.get("Accreditation");
        StringList childs = (StringList)rep.get("child");
        String family= (String)rep.get("Family");
    	
        // RBR2: FUN[080973]
        String prjTitle = (String)rep.get("V_Name");
        String prjParentTitle = (String)rep.get("Project_Parent_V_Name");
        if(parents.equals("None"))prjParentTitle=parents;
        StringList prjChildTitles = (StringList)rep.get("Project_Child_V_Name");
		
        
        %><html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<script>
		   var prjName="";
	       var prjParentName="";
	       var prjTitle = ""; // RBR2: 
	       var prjParentTitle = ""; // RBR2:

	    	 function reTitlePRJ(){
	         	 if(prjTitle == ""){ // prjTitle this will be empty for first time edit is clicked.
	         		prjTitle=$("PrjV_Name").innerHTML.htmlDecode(); // DefaulltTitle
	         		$("PrjV_Name").innerHTML='<input type="text" name="PrjV_NameIn" id="PrjV_NameIn" value="'+prjTitle+'" >';
	         	 }
	         }

			// Withotu Parent
            function ASubmitFunction1(plm_externalid){
				ASubmitFunction2(plm_externalid,"");
            }

			// Witht Parent 
            function ASubmitFunction2(plm_externalid,parent){
                DisplayLoading();
				
                var V_id= document.getElementById("description").value;
                var secLevel= document.getElementById("secLevel").value;
                var disc2Add= document.getElementById("stockAdd").value;
                var disc2Rem= document.getElementById("stockRemove").value;
    			
                var thePrjName = $("PrjPLMId").innerHTML.htmlDecode(); // This wont change
				var thePrjParent = $("PrjParent").innerHTML.htmlDecode(); // This wont change
				
				if ( (thePrjParent.indexOf('emxPLMOnlineAdminProjectSubTree')>-1) ) {
					thePrjParent = $("PrjParent").firstChild.innerHTML.htmlDecode(); 
				}
				
				var thePrjTitle = $("PrjV_Name").innerHTML.htmlDecode(); //Probable ODL Title <-- Here the input tag is injected
				var thePrjParentTitle = $("PrjParentV_Name").innerHTML.htmlDecode(); //Probable ODL Parnet Title 
    			
				var newPrjTitle = "";
    			var oldPrjTitle = "";
				
    			if ( (thePrjTitle == null) || (thePrjTitle.indexOf('input')>-1) || (thePrjTitle.indexOf('INPUT')>-1) ) {
    				// Edit button clicked
    				thePrjTitle=prjTitle; // OLD
                	newPrjTitle= $("PrjV_NameIn").value;
                	//Check that name doesn't contain illegal characters only if it has been changed, to support old illegal names.
                	if(newPrjTitle !== thePrjTitle && hasSpecialChar(newPrjTitle,true)){
        				alert("<%=ERRCannotContain%>" + ": " + emxUIAdminConsoleUtil.FORBIDDEN_CHARACTERS_WITH_DOT);
                        HideLoading();
                        return;
                	}
                	else if(newPrjTitle.length >32)
                		{
	                		alert("<%=ERR_TitleCannotBeGreater%>");
	                        HideLoading();
	                        return;
                		}
                	oldPrjTitle = prjTitle; // Current state at server
                } else if(prjTitle == ""){
                	// No title change
                	oldPrjTitle = $("PrjV_Name").innerHTML.htmlDecode();
                	newPrjTitle = $("PrjV_Name").innerHTML.htmlDecode();
                }
    			
    			
                if ( (thePrjParentTitle.indexOf('emxPLMOnlineAdminProjectSubTree')>-1) ) {
					thePrjParentTitle = $("PrjParentV_Name").firstChild.innerHTML.htmlDecode(); // input tag value
				}

                var target = "PLM_ExternalID="+encodeURIComponent(thePrjName)+
                "&Parent="+encodeURIComponent(thePrjParent)+
                "&Disc2Add="+encodeURIComponent(disc2Add)+
                "&Disc2Rem="+encodeURIComponent(disc2Rem)+
                "&PrjV_Name="+encodeURIComponent(oldPrjTitle)+
                "&NewPrjV_Name="+encodeURIComponent(newPrjTitle)+
                "&secLevel="+encodeURIComponent(secLevel)+
                "&V_id="+encodeURIComponent(V_id)+
                "&NewParentV_Name="+encodeURIComponent(thePrjParentTitle);
				xmlreq("emxPLMOnlineAdminUpdateProject.jsp",target,updatePrjDB,1);
           }
		   
           function updatePrjDB(){
                var xmlhttp = xmlreqs[1];

                xmlhttp.onreadystatechange=function()
                {
                    if(xmlhttp.readyState==4){
                        
                        var updateResult = xmlhttp.responseXML.getElementsByTagName("updateResult");
                        var done = xmlhttp.responseXML.getElementsByTagName("Done"); // Can be false or true
                        
                        document.getElementById("hidethisone").style.display="block";
                       
                        document.getElementById("messageError").innerHTML= updateResult[0].firstChild.data.htmlEncode();
                        var thePrjName = $("PrjPLMId").innerHTML.htmlDecode();
						if(done[0].firstChild.data == "true"){
							initProject(thePrjName);
                       	}else{
                       		HideLoading();
                       	}
                    }
                }
           }
		   // RBR2: This works on PLMID not on title : IDFilter
		   function initProject(plmid){
                DisplayLoading();
            	xmlreq("emxPLMOnlineAdminAjaxResponse.jsp","source=Project&Destination=VPLMAdmin&Solution=VPM&Method=Query&IDFilter="+encodeURIComponent(plmid),formatResponse,0);
            }

            var xmlreqs = new Array();
         	
            // RBR2: 30/08/2018 required revist
            function formatResponse()
            {
                var xmlhttp = xmlreqs[0];

                xmlhttp.onreadystatechange=function()
                {
                    if(xmlhttp.readyState==4)
                    {	
                    	$("PrjPLMId").innerHTML = xmlhttp.responseXML.getElementsByTagName("PLM_ExternalID")[0].firstChild.data.htmlEncode();
                    	// RBR2: Push V_Name
                    	$("PrjV_Name").innerHTML = xmlhttp.responseXML.getElementsByTagName("V_Name")[0].firstChild.data.htmlEncode();
                    	
                    	if ( (xmlhttp.responseXML.getElementsByTagName("project_Parent").length >0) && (xmlhttp.responseXML.getElementsByTagName("project_Parent")[0].firstChild != null)){
                            var pparent = xmlhttp.responseXML.getElementsByTagName("project_Parent")[0].firstChild.data;
                            var prjParentTitle = xmlhttp.responseXML.getElementsByTagName("Project_Parent_V_Name")[0].firstChild.data;
							$("PrjParent").innerHTML = '<a href="emxPLMOnlineAdminProjectSubTree.jsp?PLM_ExternalID='+encodeURIComponent(pparent)+'">'+pparent.htmlEncode()+'</a>';
							$("PrjParentV_Name").innerHTML = '<a href="emxPLMOnlineAdminProjectSubTree.jsp?PLM_ExternalID='+encodeURIComponent(pparent)+'">'+prjParentTitle.htmlEncode()+'</a>';
                        }else{
                        	$("PrjParent").style.color ="gray";
                        	$("PrjParent").innerHTML = "None";
                        	// Grey out Parent Title
                        	$("PrjParentV_Name").style.color ="gray";
                        	$("PrjParentV_Name").innerHTML = "None";	
                        	
                        }
						
						var children = xmlhttp.responseXML.getElementsByTagName("child");
						var childrenTitles = xmlhttp.responseXML.getElementsByTagName("Project_Child_V_Name");
                        if (children!=null && children.length!=0){
							var table=document.getElementById('PrjChildren');
							while(table.hasChildNodes()) table.removeChild(table.lastChild);
							for (var i = 0 ; i <childrenTitles.length ; i++){
								var row=table.insertRow(-1);
								var cell=row.insertCell(-1);
								var pchild = children.item(i).firstChild.data;
								var pchildTitle = childrenTitles.item(i).firstChild.data;
								cell.innerHTML='<a href="emxPLMOnlineAdminProjectSubTree.jsp?PLM_ExternalID='+encodeURIComponent(pchild)+'">'+pchildTitle.htmlEncode()+'<a>';
								cell.title = pchild;
							}
						}
						// RBR2: This section is not very clear.
						if((prjName != "") && (prjName != $("PrjPLMId").innerHTML.htmlDecode())){
                          	prjName="";
                        }
                        
						var localpprj = $("PrjParent").innerHTML;
						if(localpprj.indexOf('emxPLMOnlineAdminProjectSubTree')>-1) {
							localpprj = $("PrjParent").firstChild.innerHTML.htmlDecode();
						}
                        if((prjParentName != "") && (prjParentName != localpprj)){
    	                    prjParentName=""
                        }
						
                        HideLoading();
                    }
                }
            }
            
          
		   
           function effacer(){
            var index = document.getElementById("DisciplinesElse").options[ document.getElementById("DisciplinesElse").options.selectedIndex];
            var text = index.innerHTML.htmlDecode();
            document.getElementById("DisciplinesElse").options[ document.getElementById("DisciplinesElse").options.selectedIndex]=null;
             var opt = new Option(text,text);
            document.getElementById("DisciplinesHas").options[ document.getElementById("DisciplinesHas").options.length]=opt;
               document.getElementById("DisciplinesElse").size = document.getElementById("DisciplinesElse").size-1;
              document.getElementById("DisciplinesHas").size = document.getElementById("DisciplinesHas").size+1;
           document.getElementById("stockRemove").value = document.getElementById("stockRemove").value + "," + text;
	 			if (document.getElementById("stockAdd").value.indexOf(","+text) != -1)
	 			{
					var value2Add = document.getElementById("stockAdd").value;
					document.getElementById("stockAdd").value = value2Add.substring(0,value2Add.indexOf("," + text)) + value2Add.substring(value2Add.indexOf("," + text)+text.length+1,value2Add.length);
	 			}
            }

         function ajouter(){
            var index = document.getElementById("DisciplinesHas").options[ document.getElementById("DisciplinesHas").options.selectedIndex];
            var text = index.innerHTML.htmlDecode();
            document.getElementById("DisciplinesHas").options[ document.getElementById("DisciplinesHas").options.selectedIndex]=null;
              var opt = new Option(text,text);
            document.getElementById("DisciplinesElse").options[ document.getElementById("DisciplinesElse").options.length]=opt;
              document.getElementById("DisciplinesElse").size = document.getElementById("DisciplinesElse").size+1;
              document.getElementById("DisciplinesHas").size = document.getElementById("DisciplinesHas").size-1;
              document.getElementById("stockAdd").value = document.getElementById("stockAdd").value + "," + text;
	 			if (document.getElementById("stockRemove").value.indexOf(","+text) != -1)
	 			{
					var value2Add = document.getElementById("stockRemove").value;
					document.getElementById("stockRemove").value = value2Add.substring(0,value2Add.indexOf("," + text)) + value2Add.substring(value2Add.indexOf("," + text)+text.length+1,value2Add.length);
			 	}
          }
         // RBR2: Chnaged to manage the modify title not the Name
		 function modifyParent(remove){
			prjParentName=$("PrjParent").innerHTML.htmlDecode();
			prjParentTitle = $("PrjParentV_Name").innerHTML.htmlDecode(); 
			
			if (prjParentName.indexOf('emxPLMOnlineAdminProjectSubTree')>-1){
				prjParentName=$("PrjParent").firstChild.innerHTML.htmlDecode();
			}
			
			if (prjParentTitle.indexOf('emxPLMOnlineAdminProjectSubTree')>-1){
				prjParentTitle=$("PrjParentV_Name").firstChild.innerHTML.htmlDecode();
			}
			var plmID = $("PrjPLMId").innerHTML.htmlDecode(); // This wont change ever
			var vname = $("PrjV_Name").innerHTML.htmlDecode(); // This will change now
			
			if (remove == "Remove"){
				$("PrjParent").innerHTML = "None" ;
				$("PrjParentV_Name").innerHTML = "None"; // Reset the title
			}else{
				 alert("New Parent Name"+prjParentTitle);
				 top.showSlideInDialog("emxPLMOnlineAdminModifyProjectParent.jsp?Source=VPLMAdmin&projectName="
							+encodeURIComponent(plmID)+
							"&prjFamily="+encodeURIComponent($("prjFamily").innerHTML.htmlDecode())+
							"&childs="+encodeURIComponent("<%=childs%>")+
							"&prjParent="+encodeURIComponent(prjParentName)+
							"&prjParentV_Name="+encodeURIComponent(prjParentTitle), true);
				}
		  }
         
          function searchUsers(){
          	top.showSlideInDialog("emxPLMOnlineAdminSearchProjectUser.jsp?Source=VPLMAdmin&projectName="+encodeURIComponent($("PrjPLMId").innerHTML.htmlDecode())+"&prjFamily="+encodeURIComponent($("prjFamily").innerHTML.htmlDecode()), true);
          }
        </script>
    </head>
<body onload="javascript:initProject('<%=escplmid%>')">
         <script>addReturnMessage();</script>
         <script>addTransparentLoading("","");</script>
    <textarea id="stockRemove" style="display:none"></textarea>
    <textarea id="stockAdd" style="display:none"></textarea>

        <form action="" id="submitForm" name="submitForm"  method="POST">
            <div id="pageContentDiv" class="divPageBodyVPLM"  style="right : 500px; overflow: auto">
            <table width="100%" style="height:95% ; border-color: white" border="1px">
                <!-- V_Name : RBR2 modifiable  -->
                <tr style="height:30px">
                    <td class="MatrixLabel"><%=ProjectTitle%></td>
                    <td class="MatrixFeel"  id="V_Name" >
                    	<table style="padding-left : -1px" width="100%" >
                    		<tr>
                    		<td class="MatrixFeel" id="PrjV_Name" style="width : 210px" ><%=prjTitle%></td>
                    		<td >
                    		<input type="button" name="btnparentName" value="<%=Edit%>" onclick="javascript:reTitlePRJ()">
                    		</td>
                    		</tr>
                    		</table>
                    </td>
              	</tr>
                <!-- PLMExtenrnaliD : RBR2 unmodifiable  -->
                <!-- <input type="button" name="btnparentName" value="" onclick="javascript:renamePRJ()"> -->
                <tr style="height:30px">
                    <td class="MatrixLabel"><%=ProjectName%></td>
                    <td class="MatrixFeel"  id="PLM_ExternalID" >
                    	<table style="padding-left : -1px" width="100%" >
                    		<tr>
                    		<td class="MatrixFeel" id="PrjPLMId" style="width : 210px" ><%=escplmid%></td>
                    		<td >
                    		</td>
                    		</tr>
                    		</table>
                    </td>
              	</tr>
              	<!-- FAMILY -->
              	<tr style="height:30px">
                    <td class="MatrixLabel"><%=Family%></td>
                    <td class="MatrixFeel" id="prjFamily"><%=family%></td>
                </tr>
				<!-- Description -->
                <%if ( plmexternalid.equals("Default") || plmexternalid.equals("DEFAULT") ){%>
                    <tr style="height:30px">
                        <td class="MatrixLabel"><%=ProjectDescription%></td>
                        <td class="MatrixFeel">
                        <table style="padding-left : -1px" width="100%" >
                    		<tr >
                    		<td class="MatrixFeel" style="width : 210px" ><input type="text" value="<%=descs%>"  size="<%=descs.length()%>" disabled name="V_id"></td>
                    		<td > 
                    		</td>
                    		</tr>
                    		</table>
                    </tr>
                <%}else{%>
                    <tr style="height:30px">
                        <td class="MatrixLabel"><%=ProjectDescription%></td>
                        <td class="MatrixFeel">
                            <input id="description" type="text" value="<%=descs%>"  name="V_id" size="30" maxlength="100">
                        </td>
                    </tr>
                <%}%>
                <tr style="height:30px">
                    <td></td>
                    <td></td>
                </tr>
 				<!-- Accreditation -->
               <tr style="height:30px">
                    <td class="MatrixLabel"><%=Accreditation%></td>
                    <td class="MatrixFeel">
                        <select name="secLevel" id="secLevel">
                           <option style="color:gray ; font-style : italic" value="_NONE_"><%=getNLS("None")%></option>

                            <%manageContextTransaction(mainContext,"start");
                            MapList mpl = PLMxPosTableServices.getTableRows(mainContext, "Confidentiality");
                            manageContextTransaction(mainContext,"end");
                            for(int mi=0; mi<mpl.size(); ++mi) {
                                Hashtable h = (Hashtable)mpl.get(mi);
                                if (h.get("V_row_name").equals(accreditation)){
                                %>
                                    <option selected value="<%=h.get("V_row_name")%>"><%=h.get("V_row_name")%></option>
                                <%}else{%>
                                    <option value="<%=h.get("V_row_name")%>"><%=h.get("V_row_name")%></option>
                                <%}}%>
                        </select>
                      </td>
                 </tr> 
                 <!-- Parent  -->
                 <tr style="height:30px">
                	<td class="MatrixLabel" name="Project_Parent"><%=ProjectParent%></td>
                	<td class="MatrixFeel" >
                    	<table width="100%" >
                    		<tr>
                    		<!-- Hide name but show the title -->
                    		<td class="MatrixFeel"  name="PrjParent" id="PrjParent" style="width : 210px" hidden><%=parents%>
							</td>
							<td class="MatrixFeel"  name="PrjParentV_Name" id="PrjParentV_Name" style="width : 210px"><%=prjParentTitle%>
							</td>
                        	<td >
                        	<input type="button" name="btnparentName" value="<%=Change%> ..." onclick="javascript:modifyParent()">
                        	</td>
                        	</tr>
							<tr>
							<td class="MatrixFeel"></td>
							<td   id="removeButton"><input type="button" name="btnparentName" value="<%=Remove%>" title="<%=Remove%>" onclick="javascript:modifyParent('Remove')"></td></tr>
			            </table>
                        </td>
                        </tr>  
                        
                        <tr style="height:30px"><td class="MatrixLabel"><%=ChildrenNLS%></td>
                         	<td class="MatrixFeel" >
							<table width="100%" id="PrjChildren">
							</table>
							</td>
						</tr>

						<tr style="height:30px">
                     <td class="MatrixLabel"><%=Disciplines%></td>
                     <td>
                        <table width="100%">
						<tr> <!-- RBR2: Title is here instead of PLMID -->
                            <td class="MatrixLabel" align="center"><%=prjTitle%> <%=Disciplines%></td>
                            <td class="MatrixLabel" align="center"><%=getNLS("Add")%>/<%=getNLS("Remove")%></td>
                            <td class="MatrixLabel" align="center"><%=getNLS("OtherDisciplines")%></td>
                        </tr>
                        <tr>
                            <td class="MatrixFeel" align="center">
                                <%    manageContextTransaction(mainContext,"start");
                                StringList disciplines = PLMxPosDisciplineServices.getDisciplinesForProjectAsStrings(mainContext,plmexternalid);
                                manageContextTransaction(mainContext,"end");
                                %>
                                <select name="DisciplinesElse" id="DisciplinesElse" size="<%=disciplines.size()%>" multiple>
                                <%  for(int discIt=0; discIt<disciplines.size(); ++discIt) {%>
                                        <option><%=disciplines.get(discIt)%></option>
                                    <%}%>
                                </select>
                          </td>
                          <td class="MatrixFeel" width="5px" align="center">
                            <table>
                                <tr>
                                    <td>
                                        <img src="images/buttonActionbarNext.gif" onclick="effacer();">
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <img src="images/buttonActionbarPrev.gif" onclick="ajouter();">
                                    </td>
                                </tr>
                            </table>
                          </td>
                        <td class="MatrixFeel" align="center">
                            <%   manageContextTransaction(mainContext,"start");
                            StringList disc= PLMxPosDisciplineServices.getRootDisciplinesAsStrings(mainContext,null);
                            manageContextTransaction(mainContext,"end");
                            int sizes = disc.size() - disciplines.size();
                            %>
                            <select name="DisciplinesHas" id="DisciplinesHas" multiple size="<%=sizes%>">
                            <%for(int discIt=0; discIt<disc.size(); ++discIt) {
                                if(!disciplines.contains(disc.get(discIt))){%>
                                    <option><%=disc.get(discIt)%></option>
                            <%}}%>
                            </select>
                        </td>
                      </tr>
                    </table>
                   </td>
                 </tr>

                 <tr><hr></tr>
            </table>
            </div>
        </form>
        <%if ( plmexternalid.equals("Default") || plmexternalid.equals("DEFAULT") ){%>
        <%}else{
        	if(parents.length()>0) {%>
            <script>addFooter("javascript:searchUsers()","images/iconAdminPeople.gif","<%=SearchForUsers%>","<%=SearchForUsers%>","javascript:ASubmitFunction2('"+"<%=escplmid%>"+"','"+"<%=parents%>"+"')","images/buttonDialogApply.gif","Update","Update");</script>
        <% }else{ %>
            <script>addFooter("javascript:searchUsers()","images/iconAdminPeople.gif","<%=SearchForUsers%>","<%=SearchForUsers%>","javascript:ASubmitFunction1('"+"<%=escplmid%>"+"')","images/buttonDialogApply.gif","<%=Update%>","<%=Update%>");</script>
        <%}}%>
  </body>
</html>
