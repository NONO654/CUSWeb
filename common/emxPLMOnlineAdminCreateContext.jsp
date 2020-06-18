<%@include file = "../common/emxPLMOnlineAdminAttributesCalculation.jsp"%>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxPLMOnlineAdminAuthorize.jsp"%>
<%@include file = "../common/emxPLMOnlineIncludeStylesScript.inc"%>
<script type="text/javascript" src="scripts/emxUICore.js"></script>
<%
     String dest = (String)emxGetParameter(request,"dest");
    boolean isLocal = false;
    if(AdminUtilities.isLocalAdmin(mainContext)) isLocal=true;
	PreferencesUtil pouf = new PreferencesUtil();
    String PrefCompanyName= pouf.getUserPreferredUICompanyFilter(mainContext);
%>
<html>
	<head>
    	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <script>
        var xmlreqs = new Array();

        function filterOrg(){
			DisplayLoading();
           var filter = document.getElementById("orgName").value;
		   if(filter==null || filter=="") filter = "*";
			xmlreq("emxPLMOnlineAdminAjaxResponse.jsp","source=Organization&responseOrg=org_Type&Destination=VPLMAdmin&filterOrg="+encodeURIComponent($("compName").value)+"&filterChild="+encodeURIComponent(filter),formatResponseOrganization,2);
			cleanRole();
		   <%if(isLocal) {%>
			cleanPrj();
			<%}%>
        }

        function filterPrj(){
			DisplayLoading();
			cleanRole();
           var filter = document.getElementById("prjName").value;
		   if(filter==null || filter=="") filter = "*";
		   <%if(isLocal) {%>
			var notfound = true;
			var filterorg = "";
           var orgs = document.getElementsByName("orgas");
		   for (var i = 0; i < orgs.length && notfound; i++) {
				if (orgs[i].checked) {
					filterorg = orgs[i].id;
					 notfound = false;
				}
			}
		   if(filterorg=="") filterorg = "*";
    		xmlreq("emxPLMOnlineAdminAjaxResponse.jsp","source=RolApplicable&Filter="+encodeURIComponent(filterorg)+"&Method=Create&ProjectApp=Yes&ProjectFilter="+encodeURIComponent(filter),formatResponseRoleApp,5);
			filterRol();
			<%}else{%>
		   xmlreq("emxPLMOnlineAdminAjaxResponse.jsp","source=Project&Destination=VPLMAdmin&Method=Create&Filter="+encodeURIComponent(filter),formatResponseProject,0);
			<%}%>
        }

        function filterRol(){
			var notfound = true;
			var filterorg = "";
           var orgs = document.getElementsByName("orgas");
		   for (var i = 0; i < orgs.length && notfound; i++) {
				if (orgs[i].checked) {
					filterorg = orgs[i].id;
					notfound = false;
				}
			}
		   if(filterorg=="") return;
		   notfound = true;
			var filterprj = "";
           var prjs = document.getElementsByName("projects");
		   for (var i = 0; i < prjs.length && notfound; i++) {
				if (prjs[i].checked) {
					filterprj = prjs[i].id;
					notfound = false;
				}
			}
		   if(filterprj=="") return;
           var filter = document.getElementById("rolName").value;
		   if(filter==null || filter=="") filter = "*";
		   <%if(isLocal) {%>
    		xmlreq("emxPLMOnlineAdminAjaxResponse.jsp","source=Role&Destination=VPLMAdmin&Method=Create&Filter="+encodeURIComponent(filter)+"&FilterOrg="+encodeURIComponent(filterorg),formatResponseRole,1);
			<%}else{%>
    		xmlreq("emxPLMOnlineAdminAjaxResponse.jsp","source=Role&Destination=VPLMAdmin&Method=Create&Filter="+encodeURIComponent(filter),formatResponseRole,1);
			<%}%>
        }

        function filterCtx(){
			var notfound = true;
			var filterorg = "";
           var orgs = document.getElementsByName("orgas");
		   for (var i = 0; i < orgs.length && notfound; i++) {
				if (orgs[i].checked) {
					filterorg = orgs[i].id;
					notfound = false;
				}
			}
		   if(filterorg=="") return;
		   notfound = true;
			var filterprj = "";
           var prjs = document.getElementsByName("projects");
		   for (var i = 0; i < prjs.length && notfound; i++) {
				if (prjs[i].checked) {
					filterprj = prjs[i].id;
					notfound = false;
				}
			}
		   if(filterprj=="") return;
           var filter = document.getElementById("rolName").value;
		   if(filter==null || filter=="") filter = "*";
		   filter = filter+"."+filterorg+"."+filterprj;
    		// RBR2:ID based search, not the Title xmlreq("emxPLMOnlineAdminAjaxResponse.jsp","source=Context&Destination=VPLMAdmin&Method=Create&selectOrg=yes&ctxFilter="+encodeURIComponent(filter),formatResponseCtx,3);
		   xmlreq("emxPLMOnlineAdminAjaxResponse.jsp","source=Context&Destination=VPLMAdmin&Method=Create&selectOrg=yes&ctxID="+encodeURIComponent(filter),formatResponseCtx,3);
        }

        function formatResponseProject()
        {  
            var xmlhttp = xmlreqs[0];
            
            xmlhttp.onreadystatechange=function()
            { 
               if(xmlhttp.readyState==4)
                {   
                    var prjs = xmlhttp.responseXML.getElementsByTagName("PLM_ExternalID");
                    var prjsTitle = xmlhttp.responseXML.getElementsByTagName("V_Name");      //SSI21 Project Title change
                    
                    var tablePrj = document.getElementById("prjsarea");
					while(tablePrj.hasChildNodes()) tablePrj.removeChild(tablePrj.lastChild);
                    for(var i = 0 ; i < prjs.length ; i++ ){
						
						var label=document.createElement("label");
						tablePrj.appendChild(label);
						var checkID=document.createElement("input");
						checkID.setAttribute("type","radio");        
						checkID.setAttribute("name","projects");        
						checkID.setAttribute("id",prjs[i].firstChild.data);     
						checkID.setAttribute("onclick","javascript:filterRol()");
						label.appendChild(checkID);
						label.setAttribute("title","Name:"+prjs[i].firstChild.data);
						label.appendChild(document.createTextNode(prjsTitle[i].firstChild.data));
                    }
					HideLoading();
                }
            }
		}
        
    	function formatResponseCtx()
        {
            var xmlhttp3= xmlreqs[3];

            xmlhttp3.onreadystatechange=function()
            {
               if(xmlhttp3.readyState==4)
                { 
                    var ctxs = xmlhttp3.responseXML.getElementsByTagName("Role");
                    var tableRol = document.getElementById("rolsarea");
					for(var i = 0 ; i < ctxs.length ; i++ ){
						var exists = ctxs[i].firstChild.data;
						for(var j = 0 ; j < tableRol.children.length ; j++ ){
							var role = tableRol.children[j].children[0].id;
							if(role == exists) {
								tableRol.children[j].children[0].checked = true;
								tableRol.children[j].children[0].disabled = true;
							}
						}
                    }
                }
            }
		}
		
		function cleanRole()
		{
            var tableRol = document.getElementById("rolsarea");
            while(tableRol.hasChildNodes()) tableRol.removeChild(tableRol.lastChild);		
		}

		function cleanPrj()
		{
            var tablePrj = document.getElementById("prjsarea");
            while(tablePrj.hasChildNodes()) tablePrj.removeChild(tablePrj.lastChild);		
		}

    	function formatResponseRole()
        {
            var xmlhttp1= xmlreqs[1];

            xmlhttp1.onreadystatechange=function()
            {
               if(xmlhttp1.readyState==4)
                { 
                    var roles = xmlhttp1.responseXML.getElementsByTagName("PLM_ExternalID");
                    var tableRol = document.getElementById("rolsarea");
                    while(tableRol.hasChildNodes()) tableRol.removeChild(tableRol.lastChild);
					for(var i = 0 ; i < roles.length ; i++ ){
						var label=document.createElement("label");
						tableRol.appendChild(label);
						var checkID=document.createElement("input");
						checkID.setAttribute("type","checkbox");     
						checkID.setAttribute("name","roles");     
						checkID.setAttribute("id",roles[i].firstChild.data);     
						label.appendChild(checkID);
						label.appendChild(document.createTextNode(roles[i].firstChild.data));
                    }
					filterCtx();
                }
            }
		}

    function formatResponseRoleApp(){
        var xmlhttp5= xmlreqs[5];

        xmlhttp5.onreadystatechange=function()
        {
            if(xmlhttp5.readyState==4)
            {
                var projectApp = xmlhttp5.responseXML.getElementsByTagName("ProjectApp");
                var tablePrj = document.getElementById("prjsarea");
				while(tablePrj.hasChildNodes()) tablePrj.removeChild(tablePrj.lastChild);
                for(var l = 0 ; l < projectApp.length ; l++ ){
						var label=document.createElement("label");
						tablePrj.appendChild(label);
						var checkID=document.createElement("input");
						checkID.setAttribute("type","radio");        
						checkID.setAttribute("name","projects");        
						checkID.setAttribute("id",projectApp[l].firstChild.data);     
						checkID.setAttribute("onclick","javascript:filterRol()");
						label.appendChild(checkID);
						label.appendChild(document.createTextNode(projectApp[l].firstChild.data));
                }
				HideLoading();
			}
		}
	}
		
        function formatResponseOrganization()
        {
            var xmlhttp2= xmlreqs[2];
        	xmlhttp2.onreadystatechange=function()
            {
               if(xmlhttp2.readyState==4)
               {
					var filter = document.getElementById("orgName").value;
					if(filter==null || filter=="") filter = "*";
					filter = filter.replace(/\*/g,".*");
					filter = "^"+filter;
                    var orgs = xmlhttp2.responseXML.getElementsByTagName("Organization");
                    var tableOrg = document.getElementById("orgsarea");
					while(tableOrg.hasChildNodes()) tableOrg.removeChild(tableOrg.lastChild);
					if($("compName").value != "*") {
						var label=document.createElement("label");
						tableOrg.appendChild(label);
						var checkID=document.createElement("input");
						checkID.setAttribute("type","radio");
						checkID.setAttribute("name","orgas");
						checkID.setAttribute("id",$("compName").value);
		   <%if(isLocal){%>
						checkID.setAttribute("onclick","javascript:filterPrj()");
		   <%}else{%>
						checkID.setAttribute("onclick","javascript:filterRol()");
		   <%}%>
						label.appendChild(checkID);
						label.appendChild(document.createTextNode($("compName").value));
					}
					for(var i = 0 ; i < orgs.length ; i++ ){
						var name = orgs[i].getElementsByTagName("PLM_ExternalID")[0].firstChild.data;
						var type = orgs[i].getElementsByTagName("org_Type")[0].firstChild.data;
						if(type!="Business Unit" && type!="Department") continue;
						if(name.match(filter) == null) continue;
						label=document.createElement("label");
						tableOrg.appendChild(label);
						checkID=document.createElement("input");
						checkID.setAttribute("type","radio");        
						checkID.setAttribute("name","orgas");        
						checkID.setAttribute("id",name);     
		   <%if(isLocal){%>
						checkID.setAttribute("onclick","javascript:filterPrj()");
		   <%}else{%>
						checkID.setAttribute("onclick","javascript:filterRol()");
		   <%}%>
						label.appendChild(checkID);
						label.appendChild(document.createTextNode(name));
                    }
					HideLoading();
              }
			}
		}
		
         function searchCompany(){
          	top.showSlideInDialog("emxPLMOnlineAdminSearchOrg.jsp?OrgName="+encodeURIComponent("*"), true);
          }
		  
         function resetCompany(){
          	$("compName").value = "*";
          }
		  
          function getContextToCreate2(){
			DisplayLoading();
            var context2Create = "";
			var notfound = true;
			var filterorg = "";
           var orgs = document.getElementsByName("orgas");
		   for (var i = 0; i < orgs.length && notfound; i++) {
				if (orgs[i].checked) {
					filterorg = orgs[i].id;
					 notfound = false;
				}
			}
			 notfound = true;
			var filterprj = "";
           var prjs = document.getElementsByName("projects");
		   for (var i = 0; i < prjs.length && notfound; i++) {
				if (prjs[i].checked) {
					filterprj = prjs[i].id;
					 notfound = false;
				}
			}
            if (filterorg != "" && filterprj != "") {
            var tableRol = document.getElementById("rolsarea"); 
			for(var j = 0 ; j < tableRol.children.length ; j++ ){
				var role = tableRol.children[j].children[0].id;
				if(tableRol.children[j].children[0].disabled == false && tableRol.children[j].children[0].checked == true) {
                    context2Create= context2Create.concat(role);
                    context2Create= context2Create.concat(".");
                    context2Create= context2Create.concat(filterprj);
                    context2Create= context2Create.concat(",");
                }
			}
			}
			if (context2Create == "") {
				alert("You have to choose at least one organization, project, role triplet");
				HideLoading();
			} else {
                xmlreq("emxPLMOnlineAdminCreateContextDB.jsp","roleProject="+encodeURIComponent(context2Create)+"&organization="+encodeURIComponent(filterorg),responseCreate,4);
			}
           }
		   
        function responseCreate()
        {
            var xmlhttp4= xmlreqs[4];
        	xmlhttp4.onreadystatechange=function()
            {
               if(xmlhttp4.readyState==4)
               {
					var result = xmlhttp4.responseXML.getElementsByTagName("message");
					alert(result[0].firstChild.data);
					HideLoading();
					filterRol();
			   }
			}
		}
		
    function searchKeyPress(e)
    {
        if (typeof e == 'undefined' && window.event) { e = window.event; }
        if (e.keyCode == 13)
        {
			var butt = "btn";
			if(e.target) butt = butt+e.target.id;
			else if(e.srcElement) butt = butt+e.srcElement.id;
            document.getElementById(butt).click();
        }
    }

  </script>
<style>
		.multiselection {
       width:100%;
       height:40em;
	   background-color:#e6e6e6;
       border:solid 1px #ccc;
       overflow:auto;
       }
       .multiselection label {
       display:block;
       }
</style>
 </head>
<script>addTransparentLoading("","");</script>
 <body>
 <%
    String message = emxGetParameter(request,"message");
    %>
    <form  name="submitForm" id="submitForm" method="POST">
        <%if (message != null) {%> <script>setTime("<%=message%>");</script><%}%>
        <div style="height:100% ; overflow: auto">
            <table width="100%">
                <tr style="height : 20px">
                    <td align="left">
						<%if(dest==null) {%>
							<a href="emxPLMOnlineAdminContext.jsp" class="link"><%=getNLS("Search")%>...</a>
						<%}%>
                    </td>						
                    <td></td>
                    <td></td>
                </tr>
				<tr><td>
            <table align="center" width="90%">
                <tr style="height : 20px">
                    <td class="title" style="text-align: left;"><%=getNLS("Company")%></td>
                    <td></td>
                </tr>
                <tr>
                    <td align="center"><input style="width: 100%;background-color:#e6e6e6;" id="compName" disabled value="<%=PrefCompanyName%>" onchange="javascript:filterOrg()"></td>
                    <td align="left"><input type="button" value="..." onclick="javascript:searchCompany()"></td>
                    <td align="left"><input type="button" value="<%=getNLS("Reset")%>" onclick="javascript:resetCompany()"></td>
                </tr>
            </table></td>
			<td></td>
			<td></td>
                </tr>
				<tr><td>
            <table align="center" width="90%">
                <tr style="height : 20px">
                    <td class="title" style="text-align: left;"><%=getNLS("OrganizationsTree")%></td>
                    <td></td>
                </tr>
                <tr>
                    <td align="center"><input onkeypress="searchKeyPress(event);" style="width: 100%;" id="orgName" value="*"></td>
                    <td align="left"><input id="btnorgName" type="button" value="<%=getNLS("Filter")%>" onclick="javascript:filterOrg()"></td>
                </tr>
                <tr>
                    <td align="left"><div id="orgsarea" class="multiselection"></div></td>
                    <td></td>
                </tr>
            </table></td><td>
            <table align="center" width="90%">
                <tr style="height : 20px">
                    <td class="title" style="text-align: left;"><%=getNLS("ProjectsTree")%></td>
                    <td></td>
                </tr>
                <tr>
                    <td align="center"><input onkeypress="searchKeyPress(event);" style="width: 100%;" id="prjName" value="*"></td>
                    <td align="left"><input id="btnprjName" type="button" value="<%=getNLS("Filter")%>" onclick="javascript:filterPrj()"></td>
                </tr>
                <tr>
                    <td align="left"><div id="prjsarea" class="multiselection"></div></td>
                    <td></td>
                </tr>
            </table> </td><td valign="top" >
            <table align="center" width="90%">
                <tr style="height : 20px">
                    <td class="title" style="text-align: left;"><%=getNLS("Roles")%></td>
                    <td></td>
                </tr>
                <tr>
                    <td align="center"><input onkeypress="searchKeyPress(event);" style="width: 100%;" id="rolName" value="*"></td>
                    <td align="left"><input id="btnrolName" type="button" value="<%=getNLS("Filter")%>" onclick="javascript:filterRol()"></td>
                </tr>
                <tr>
                    <td align="left"><div id="rolsarea" class="multiselection"></div></td>
                    <td></td>
                </tr>
            </table> </td>
                </tr>
            </table> 
        </div>
        <%String create=getNLS("Create");%>
    </form>
    <script>
            addFooter("javascript:getContextToCreate2()","images/buttonDialogAdd.gif","<%=create%>","<%=create%>");
    </script>
  </body>
</html>
