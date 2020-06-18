<%@ page import="com.dassault_systemes.vplmposadministrationui.uiutil.AdminUtilities"%>
<%@include file = "../common/emxPLMOnlineAdminAttributesCalculation.jsp"%>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxPLMOnlineIncludeStylesScript.inc"%>
<%@include file = "../common/emxPLMOnlineAdminAuthorize.jsp"%>
<script type="text/javascript" src="scripts/emxUICore.js"></script>
<%
    String projectName  = emxGetParameter(request,"projectName");
%>
<html>
<head>
<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="javascript" src="../common/scripts/emxUICoreMenu.js"></script>
<script type="text/javascript">
	addStyleSheet("emxUIToolbar");
</script>
<script language="JavaScript" src="scripts/emxUIActionbar.js"></script>
<script language="JavaScript" src="scripts/emxUIToolbar.js"></script>
<script>
    var xmlreqs = new Array();
    var xmlhttp="";
    var alreadyClickedRole = false;
    var alreadyClickedOrg = false;
    
    var Organizations ="";  
    var Roles ="";  
    
  function queryOrganization(){
	   var FilterValue = document.getElementById("Filter").value;	  
       xmlreq("emxPLMOnlineAdminAjaxResponse.jsp","source=Organization&Destination=VPLMAdmin&responseOrg=org_Type&filterOrg="+FilterValue,formatResponse,0);
  }


    
    function OrgRoleList(orgRole){
    	OrgRole=orgRole;
    	if (xmlhttp == ""){
    		//First request
    		var CtxFilter ="*.*."+"<%=projectName%>";
    		if(orgRole == "ROLE"){
    			document.getElementById("divRole").style.display = "";
    		}else{
    			document.getElementById("divOrg").style.display = "";
    		}
    		xmlreq("emxPLMOnlineAdminAjaxResponse.jsp","source=Context&Destination=VPLMAdmin&selectOrg=yes&ctxFilter="+encodeURIComponent(CtxFilter),formatResponse,0);
    	}else{
    		if ( (orgRole == "ROLE") ){
    			//Case we want to undisplay the Role
    			if ($("divRole").style.display == ""){
    				$("divRole").style.display = "none";
    				/*var RoleList = "";
    				for(var j = 0 ; j < $("divRole").getElementsByTagName("input").length ; j++){
						if ($("divRole").getElementsByTagName("input")[j].checked==true){
							RoleList = RoleList + ", " + $("divRole").getElementsByTagName("input")[j].id;
						}    					
    				}
					document.getElementById("AllRoles").innerHTML = RoleList;*/
    			}else{
    				document.getElementById("divRole").style.display = "";
    				document.getElementById("divOrg").style.display = "none";
    			}
    		}else{
    			if (document.getElementById("divOrg").style.display == ""){
    				document.getElementById("divOrg").style.display = "none";
    				/*var OrgList = "";
    				for(var j = 0 ; j < $("divOrg").getElementsByTagName("input").length ; j++){
						if ($("divOrg").getElementsByTagName("input")[j].checked==true){
							OrgList = OrgList + ", " + $("divOrg").getElementsByTagName("input")[j].id;
						}    					
    				}
					document.getElementById("AllOrgs").innerHTML = OrgList;*/
    			}else{
    				document.getElementById("divOrg").style.display = "";
    				document.getElementById("divRole").style.display = "none";
    			}
    			
    		}
    	}				
    }
    
    var OrgRole= "";
    
    function formatResponse()
    {
        xmlhttp = xmlreqs[0];

        xmlhttp.onreadystatechange=function()
        {
            if(xmlhttp.readyState==4)
            	
            {   
            	 var organizationName = xmlhttp.responseXML.getElementsByTagName("Organization");
           	  
            	  var tableToAdd = document.getElementById("TableOrg");
            	 
            	 
            	  for(var i = 0 ; i < organizationName.length ; i++){
            		  var row=tableToAdd.insertRow(-1);
            		  var cellInnerHTML = "<input type='checkbox' id='"+organizationName[i].firstChild.data+"' onclick='verifyCheck(\"ORG\",this)'>";
    	              addCellInARow(row, "MatrixFeel", 0,cellInnerHTML);
    	              cellInnerHTML = organizationName[i].firstChild.data;
    	              var newCell = addCellInARow(row, "MatrixFeel", 1);
					  newCell.appendChild(document.createTextNode(cellInnerHTML));
            	  }
            	  
            	  var RoleName = xmlhttp.responseXML.getElementsByTagName("Role");
               	  
            	   tableToAdd = document.getElementById("TableRole");
            	 
            	 
            	  for(var i = 0 ; i < RoleName.length ; i++){
            		  row=tableToAdd.insertRow(-1);
            		  var cellInnerHTML = "<input type='checkbox' id='"+RoleName[i].firstChild.data+"' onclick='verifyCheck(\"ROLE\",this)'>";
    	              addCellInARow(row, "MatrixFeel", 0,cellInnerHTML);
    	              cellInnerHTML = RoleName[i].firstChild.data;
    	              var newCell = addCellInARow(row, "MatrixFeel", 1);
					  newCell.appendChild(document.createTextNode(cellInnerHTML));
            	  }
            	  if(OrgRole == "ROLE"){
            		  document.getElementById("divRole").style.display = "";
            	  }else{
            		  document.getElementById("divOrg").style.display = "";
            	  }
            	  
            	  
            }
        }
    }
    
    
    function verifyCheck(divName,checkbox){
    	if (divName == "ROLE"){
    		if(checkbox.checked){
    			if(!alreadyClickedRole)document.getElementById("AllRoles").innerHTML ="";
    			if (document.getElementById("AllRoles").innerHTML =="")document.getElementById("AllRoles").innerHTML = document.getElementById("AllRoles").innerHTML + checkbox.id;    
    			else document.getElementById("AllRoles").innerHTML = document.getElementById("AllRoles").innerHTML + ", "+checkbox.id;    
    			alreadyClickedRole=true;
    		}else{
    			var roleList = document.getElementById("AllRoles").innerHTML;
    			roleList = roleList.substring(0, roleList.indexOf(checkbox.id)-2) + roleList.substring(roleList.indexOf(checkbox.id)+checkbox.id.length,roleList.length );
    			if (roleList.indexOf(",") == 0)roleList= roleList.substring(2,roleList.length);
    			document.getElementById("AllRoles").innerHTML = roleList;
    		}
    	}else{
    		if(checkbox.checked){
    			if(!alreadyClickedOrg)document.getElementById("AllOrgs").innerHTML ="";
    			if (document.getElementById("AllOrgs").innerHTML =="")document.getElementById("AllOrgs").innerHTML = document.getElementById("AllOrgs").innerHTML + checkbox.id;    
    			else document.getElementById("AllOrgs").innerHTML = document.getElementById("AllOrgs").innerHTML + ", "+checkbox.id;    
    			alreadyClickedOrg=true;
    		}else{
    			var orgList = document.getElementById("AllOrgs").innerHTML;
    			orgList = orgList.substring(0, orgList.indexOf(checkbox.id) -2) + orgList.substring(orgList.indexOf(checkbox.id)+checkbox.id.length,orgList.length );
    			if (orgList.indexOf(",") == 0)orgList= orgList.substring(2,orgList.length);
    			document.getElementById("AllOrgs").innerHTML = orgList;
    			
    		}
			    		
    	}
    }
    
    
    
    function formatResult()
    {
        var xmlhttp1 = xmlreqs[1];

        xmlhttp1.onreadystatechange=function()
        {
            if(xmlhttp1.readyState==4)
            	
            {   
            	var personsTable = xmlhttp1.responseXML.getElementsByTagName("Person");
                  
                var table=document.getElementById('TableResult');
                document.getElementById("TableResult").style.display = "";
                var nbRow =  document.getElementById("TableResult").rows.length;
                if(nbRow > 1){
                    for (var j = 0 ; j < nbRow-1 ; j++){
                     document.getElementById('TableResult').deleteRow(-1);
                    }
                }
                
                
                
                 
                var row=table.insertRow(-1);
                row.height = "10px";
                
                for (var i = 0 ; i <personsTable.length ; i++){
                     var row=table.insertRow(-1);

                     var cell=row.insertCell(-1);
                     cell.className = "MatrixFeel";
                     cell.innerHTML=personsTable[i].firstChild.data.htmlEncode();
				     
                     var cell=row.insertCell(-1);
                     cell.className = "MatrixFeel";
                     var firstName = "";
                     var lastName = "";
                     if (xmlhttp1.responseXML.getElementsByTagName("FirstName")[i].firstChild != null)
                         firstName =xmlhttp1.responseXML.getElementsByTagName("FirstName")[i].firstChild.data;
                     if (xmlhttp1.responseXML.getElementsByTagName("LastName")[i].firstChild != null)
                         lastName =xmlhttp1.responseXML.getElementsByTagName("LastName")[i].firstChild.data;
                     
                     cell.innerHTML=firstName + " "+ lastName;
				     
                     var cell=row.insertCell(-1);
                     cell.className = "MatrixFeel";
                     var Email = "";

                     if (xmlhttp1.responseXML.getElementsByTagName("Email")[i].firstChild != null)
                    	 Email =xmlhttp1.responseXML.getElementsByTagName("Email")[i].firstChild.data;
                     
                     cell.innerHTML=Email;
				     
                     
                    
                 }

            }
        }
    }
    
    function afficheUsers(){
    	var Orgs = document.getElementById("AllOrgs").innerHTML.htmlDecode();
   		var Roles = document.getElementById("AllRoles").innerHTML.htmlDecode();
   		
   		
   			
    	xmlreq("emxPLMOnlineAdminAjaxResponse.jsp","source=Person&Destination=VPLMAdmin&SearchUser=yes&RoleFilter="+encodeURIComponent(Roles)+"&OrgFilter="+encodeURIComponent(Orgs)+"&ProjectFilter="+encodeURIComponent("<%=projectName%>"),formatResult,1);

    }
    
    
 </script>
</head>
<body class="slide-in-panel">
    <div id="pageHeadDiv">
        <table>
            <tbody>
                <tr>
                    <td class="page-title">
                    	<h2><%=getNLS("SearchForProjectMembers")%></h2>
                     </td>
                     <td class="functions">
                         <table>
                             <tbody>
                                 <tr>
                                    <td class="progress-indicator">
                                        <div id="imgProgressDiv" style="visibility: hidden;"></div>
                                    </td>
                                </tr>
                             </tbody>
                         </table>
                    </td>
                </tr>
            </tbody>
        </table>

<div id="divToolbarContainer" class="toolbar-container">
            <div class="toolbar-frame" id="divToolbar">
 
            </div>
        </div>
    </div>
    <div id="divPageBody" style="top :87px;">
        <div  id="divOrg" style="z-index:1; position:absolute;  width:150px;margin-left:172px;margin-top:30px;background-color:white;display :none">
        	<table id="TableOrg">
        	<tr><td></td><td></td></tr>
        	</table>
		</div>
          <div  id="divRole" style="z-index:1; position:absolute;  width:150px;margin-left:172px;margin-top:50px;background-color:white;display :none">
        	<table id="TableRole" >
        	<tr><td></td><td></td></tr>
        	</table>
		</div>                           
    
        <table  border="1px" style=" border-color: white;margin-top: 10px ; padding-top: 10px; top: 10px ">
            
           <tr >
                            <td>
                                <table border="1px" id="tabRes" style=" overflow:scroll; height: 20px ;  border-color: white" width="100%">
                                    <tr id="Header" style=" width: 100%" >
                                        <td class="MatrixLabel"><%=getNLS("Organization")%></td><td class="MatrixFeel" id="AllOrgs"><%=getNLS("None")%></td>
                                        <td width="20px" align="right"><img src='images/utilActionScrollArrowDown.gif' style='cursor:pointer' onClick="OrgRoleList('ORG')"></td>
                                    </tr>
                     				<tr>
                                        <td class="MatrixLabel"><%=getNLS("Roles")%></td><td class="MatrixFeel" id="AllRoles"><%=getNLS("None")%></td><td width="20px" align="right"><img src='images/utilActionScrollArrowDown.gif' style='cursor:pointer' onClick="OrgRoleList('ROLE')"></td></tr>
                                   </tr>
                                   
                                </table>
                            </td>
           </tr>
           <tr>
              <td class="MatrixFeel" align="right"><img src="images/iconSmallSearch.gif" onClick="javascript:afficheUsers()"></td>  
      
       <table border="1px" style="margin-top : 20px;  border-color: white ; display:none" id="TableResult" >
       		<tr>
       			<td class="MatrixLabel"><%=getNLS("Name")%></td><td class="MatrixLabel"><%=getNLS("FullName")%></td><td class="MatrixLabel"><%=getNLS("Email")%></td>
       		</tr>
       </table>
    </div>
      
    <div id="divPageFoot">
        <script>addFooter("javascript:top.closeSlideInDialog();", "images/buttonDialogDone.gif", '<%=getNLS("Done")%>','<%=getNLS("Done")%>');</script>
    </div>
</body>
</html>
