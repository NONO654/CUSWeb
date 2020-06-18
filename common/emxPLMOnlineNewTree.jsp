<%--
    Document   : emxPLMOnlineNewTree.jsp
    Author     : LXM
    Modified : 22/09/2010 -> Removed Local Admin functionnality from MyProfile.
--%>
<%@ page import=" java.util.Hashtable"%>
<%@ page import=" java.util.Vector"%>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@ page import=" java.net.URLEncoder"%>
<%@ page import=" matrix.util.StringList"%>
<%@ page import="com.matrixone.vplm.posws.stubsaccess.ClientWithoutWS" %>
<%@include file = "../common/emxPLMOnlineIncludeStylesScript.inc"%>
<%@include file = "../common/emxPLMOnlineAdminAttributesCalculation.jsp"%>
<%@include file = "../common/emxPLMOnlineAdminAuthorize.jsp"%>
<html>
<head>
<%
    String WAR_EmailNotValid = getNLSMessageWithParameter("ERR_NotValid", "Email");
    String WAR_HomeNotValid = getNLSMessageWithParameter("ERR_NotValid", "HomePhone");
    String WAR_WorkNotValid = getNLSMessageWithParameter("ERR_NotValid", "WorkPhone");
    String ResultString[]= new String[2];
    ResultString[0] = getNLS("YourPersonHasBeenUpdated");
    ResultString[1] = getNLSMessageWithParameter("ERR_CreationRight","UserID");
%>
<script>
    var xmlreqs = new Array();
    function getTop(number){
        DisplayLoading();
        var middleFrame=window.frames['middleFrame'].document;
        var plmID= middleFrame.getElementById('PLM_ExternalID').firstChild.data;
    
        var URLToSend = "PLM_ExternalID="+plmID+"&";
        var personAttributes = middleFrame.getElementsByTagName("input");
        for(var i = 0 ; i < personAttributes.length ; i++){
            if( (personAttributes[i].id != "") && (personAttributes[i].type == "text") ){
                URLToSend=URLToSend+personAttributes[i].id+"="+encodeURIComponent(personAttributes[i].value)+"&";
            }
        }

        if (middleFrame.getElementById('Accreditation') != null){
            var Accreditation= middleFrame.getElementById('Accreditation').value;
            URLToSend = URLToSend + "Accreditation="+encodeURIComponent(Accreditation);
        }
        var Alias= middleFrame.getElementById('Alias').value;
        if (Alias == null ){
            Alias= middleFrame.getElementById('Alias').innerHTML;
        }
	if(!IsEMail(middleFrame.getElementById('V_email').value)){
            HideLoading();
            alert("<%=WAR_EmailNotValid%>");}
        else if(!IsPhoneNumber(middleFrame.getElementById('V_phone').value) && (middleFrame.getElementById('V_phone').value.length >0) ){
            HideLoading();
            alert("<%=WAR_HomeNotValid%>");}
        else if(!IsPhoneNumber(middleFrame.getElementById('Work_Phone_Number').value) && (middleFrame.getElementById('Work_Phone_Number').value.length >0) ){
            HideLoading();
            alert("<%=WAR_WorkNotValid%>");}
        else{
            if(number == 0){
                URLToSend = URLToSend + "&Alias="+encodeURIComponent(Alias);
            }
            else{
                var Active = "false";
                if( middleFrame.getElementById('Active').checked){
                    Active = "true";
                }
                var ctx= middleFrame.getElementById('stockAdd').value;
                var ctxRemove= middleFrame.getElementById('stockRemove').value;
                URLToSend = URLToSend +"&Source=Admin&Ctx2Add="+encodeURIComponent(ctx)+"&Ctx2Remove="+encodeURIComponent(ctxRemove)+"&Active="+Active;
           }
           xmlreq("emxPLMOnlineAdminUpdatePerson.jsp",URLToSend,updatePersonDB,0);
         }
         
       }

        function updatePersonDB(){
            var xmlhttp=xmlreqs[0];

            xmlhttp.onreadystatechange=function()
            {
                if(xmlhttp.readyState==4)
                {
                    var updateResult = xmlhttp.responseXML.getElementsByTagName("updateResult");
                    HideLoading();

                     <% for (int i = 0 ; i <2 ; i++){%>
                               if (<%=i%> == updateResult[0].firstChild.data){
                                       alert("<%=ResultString[i]%>");
                               }
                    <%}%>

                }
            }
        }
</script>
</head>
<%  //Check if we are in the administration side
    String source = emxGetParameter(request,"source");
    if (source == null)source="";
    if (! source.equals("Admin")){%>
        <body onload="javascript:affiche()">
            <script>addTransparentLoading();</script>
    <%}else{%>
        <body>
            <script>addTransparentLoading();</script>
    <%}
        String target ="";
        StringList listElem = new StringList();
        
        String firstName =mainContext.getUser();

        String configuration="";
        String personFromFile ="";
        Map person = new HashMap();
        Map fin = new HashMap();
        Map listperson = new HashMap();

       
        String HostCompanyName= getHostCompanyName(mainContext);
    
        // String PLMKey = (String)session.getAttribute("PLMKey");

        // if(PLMKey==null || PLMKey.length()<=0) {
			// V2KeyService v2s = new V2KeyService();
			// ServiceKeyHolder skh = new ServiceKeyHolder();
                
			// CredentialSet CredentialSetVar = new CredentialSet("V6LOGIN","2");
			// CredentialSetVar.addAuthenticationCredential("user", mainContext.getUser(), false);
			// CredentialSetVar.addAuthenticationCredential("password", mainContext.getPassword(), true);

			// CredentialSetVar.addApplicativeCredential("SecurityContext", "VPLMDesigner",false);
			// CredentialSetVar.addApplicativeCredential("Machine", "localhost", false);
			// CredentialSetVar.addApplicativeCredential("Port", String.valueOf(request.getServerPort()), false);
			// CredentialSetVar.addApplicativeCredential("URLPath", request.getContextPath(), false);
			// CredentialSetVar.setRequest(request);
			// v2s.generateServiceKey(CredentialSetVar, skh);
		
			// String plmkey = skh.getValue().getValue();
			
			// session.setAttribute("PLMKey", plmkey);
			
             // }

            Enumeration sessionAtt = session.getAttributeNames();
            String util = "";
            StringList enumList = new StringList();

            /*
            * Check if we are in a SMB configuration
            */
            String result = MqlUtil.mqlCommand(mainContext,"list command $1","APPVPLMAdministration");
            if (result.length() == 0){configuration = "SMB"; }

            while(sessionAtt.hasMoreElements()){
                String next = (String)sessionAtt.nextElement();
                enumList.addElement(next);
            }

            //Get the Context Attributes
            Enumeration eNumObj     = emxGetParameterNames(request);
            while (eNumObj.hasMoreElements())
            {
                String nextElem = (String)eNumObj.nextElement();
                listElem.addElement(nextElem);
            }

            //Set the person we want to get
           if (!source.equals("Admin")){
                 personFromFile = mainContext.getUser();
            }else{
                personFromFile= emxGetParameter(request,"PLM_ExternalID");
            }

            // JIC 18:07:03 FUN076129: Removed use of PLM key/added context
      		//ServiceKey sk1 = new ServiceKey((String)session.getAttribute("PLMKey"));
            //sk1.setRequest(request);
            ClientWithoutWS client = new ClientWithoutWS(mainContext);
            person.put("PLM_ExternalID",personFromFile);
            listperson.put("person0" ,person);
            String[] slec = new String[] {""};
            fin = new HashMap();
			fin.put("method","queryPerson");
            fin.put("iPerson",listperson);
            Map persons = client.serviceCall(fin);

            if(persons.containsKey("Error")){
            %>
            <script>
       addHeader("images/iconSmallPeople.gif","<%=persons.get("Error")%>");
   </script><%}
            else{
            Map personn = (Map)persons.get("person0");
            String Preferences = (String)personn.get("Preferences");
            String FirstName = (String)personn.get("v_first_name");
            String LastName = (String)personn.get("v_last_name");
            String WorkPhoneNumber = (String)personn.get("Work_Phone_Number");
            String Email = URLEncoder.encode((String)personn.get("v_email"),"UTF-8");
            String Phone = URLEncoder.encode((String)personn.get("v_phone"),"UTF-8");
            String street = URLEncoder.encode((String)personn.get("street"),"UTF-8");
            String postalCode = URLEncoder.encode((String)personn.get("postalCode"),"UTF-8");
            String country = URLEncoder.encode((String)personn.get("country"),"UTF-8");
            String v_photo = URLEncoder.encode((String)personn.get("v_photo"),"UTF-8");
            String org_id = (String)personn.get("org_id");
            String state = URLEncoder.encode((String)personn.get("state"),"UTF-8");
            String city = URLEncoder.encode((String)personn.get("city"),"UTF-8");
            String secLevel = URLEncoder.encode((String)personn.get("Accreditation"),"UTF-8");

            String Active = (String)personn.get("IsActive");
            String Alias ="";

            if(personn.get("v_distinguished_name") != null){
                 Alias = URLEncoder.encode((String)personn.get("v_distinguished_name"),"UTF-8");
            }
   

            StringList ctxs = (StringList)personn.get("ctx");
            ctxs.sort();
            StringList list_Org = (StringList)personn.get("list_Org");          

            String Sites = getNLS("SitesTree");
            String contexts = getNLS("ContextsTree");
            String projects = getNLS("ProjectsTree");
            String role = getNLS("RoleTree");
            String organizations = getNLS("OrganizationsTree");
            String resources = getNLS("ResourcesTree");
            String Accesses = getNLS("AccessTree");         
            String PRM = getNLS("PRMTree");
            String settings = getNLS("Settings");
            String Reference = getNLS("Reference");
            String User = getNLS("User");       
            String Applications = getNLS("Applications");
            String Policies = getNLS("Policies");       
            String Rules = getNLS("Rules");
            String DesignTable = getNLS("DesignTable");       
            String Commands = getNLS("Commands");
            String Masks = getNLS("Masks");
			String PreferencesUser = getNLS("Preferences");
			String SecurityContextLabel = getNLS("SecurityContexts");
			String UpdateLabel = getNLS("Update");
			
			
            String AdminContext = "VPLMAdmin."+HostCompanyName+".Default";

            String ctxToSend = "";
            boolean isLocalAdmin = false;
            for (int i = 0 ; i < ctxs.size(); i++){
                // JIC 13:07:15 IR IR-243916V6R2013x: Added role family support
                String ctx = (String)ctxs.get(i);
                if (!isLocalAdmin &&
                    AdminUtilities.isLocalAdmin(mainContext, ctx))
                {
                    isLocalAdmin = true;
                }

                ctxToSend = ctxToSend + ctx + ",";
            }
            String Orgs ="";
                   for (int j = 0 ; j < list_Org.size(); j++ ){
                        Orgs = Orgs + (String)list_Org.get(j) + ",";
            }
                if (! source.equals("Admin")){
    %>
                <script>
                 function affiche()
                { 
                    //******************************************Get The top-level node
                    var objDetailsTree = top.objDetailsTree;
                    var objRootNode = objDetailsTree.getOriginalRoot();
                    
                    var conf = "<%=configuration%>";
                    var config = "SMB";
                  
                    //******************************************Create and Add Preferences Node
                    var objNewNodePreferences = addNodeToTree(objRootNode,"buttonMiniDone.gif","<%=PreferencesUser%>","emxPLMOnlineHelpNONE.jsp");
                    //******************************************Create and Add Sites Node
                    addNodeToTree(objNewNodePreferences,"iconSmallSite.gif","<%=Sites%>","emxPLMOnlineSite.jsp");
                    //******************************************Create and Add Prefered Context Node
                    addNodeToTree(objNewNodePreferences,"iconSmallReservedByUser.gif","<%=SecurityContextLabel%>","emxPLMOnlinePreferences.jsp?&Preferences=<%=Preferences%>&SecContexts=<%=ctxToSend%>");

                    <% if(enumList.contains("Utilisateur")){ %>
                    //******************************************Create and Add Contexts Node
                        var objNewNode = addNodeToTree(objRootNode,"iconSmallReservedByUser.gif","<%=contexts%>","emxPLMOnlineAddContexts.jsp");
                   <% }else{%>
                        var objNewNode = addNodeToTree(objRootNode,"iconSmallReservedByUser.gif","<%=contexts%>","emxPLMOnlineHelpContexts.jsp");
                   <%}%>

                    //******************************************Create and Add Projects Node
                    var objNewNodeProjects = addNodeToTree(objRootNode,"iconSmallProject.gif","<%=projects%>","emxPLMOnlineHelpProjects.jsp?type=Project");
                    //******************************************Create and Add Roles Node
                    var objNewNodeRole = addNodeToTree(objRootNode,"iconSmallRole.gif","<%=role%>","emxPLMOnlineHelpRoles.jsp");
                    //******************************************Create and Add Organizations Node
                    if (! (conf == config ) ){
                        var objNewNodeOrg = addNodeToTree(objRootNode,"iconSmallCompany.gif","<%=organizations%>","emxPLMOnlineHelpOrganizations.jsp?type=Organization");
                    }
                   //******************************************Create and Add Resources Node
                    var objNewNodeRsc = addNodeToTree(objRootNode,"iconSmallPackage.gif","<%=resources%>","emxPLMOnlineHelpNONE.jsp");
                    //******************************************Create and Add Settings Node to the Resources Node
                    var objNewNodeSet = addNodeToTree(objNewNodeRsc,"iconSmallFiles.gif","<%=settings%>","emxPLMOnlineHelpNONE.jsp");
                    //******************************************Create and Add PRM Node to the Resources Node
                     var objNewNodePRM = addNodeToTree(objNewNodeRsc,"iconSmallProgram.gif","<%=PRM%>","emxPLMOnlineHelpNONE.jsp");
                   
                    //******************************************Creating the users and reference node
                    var SubobjNewNodeReferenceSetNode = addNodeToTree(objNewNodeSet,"utilSpacer.gif","<%=Reference%>","emxPLMOnlineHelpNONE.jsp");
                    var SubobjNewNodeUserSet = addNodeToTree(objNewNodeSet,"utilSpacer.gif","<%=User%>","emxPLMOnlineHelpNONE.jsp");
         
                    /* Add Accesses node with all his subnode
                     * Add All sub nodes to organizations
                     * In a SMB Configuration these nodes do not exist
                     * */
                    if (!(conf == config )){

                        var objNewNodeAccess = addNodeToTree(objRootNode,"iconActionLock.gif","<%=Accesses%>","emxPLMOnlineHelpAccesses.jsp");
                        addNodeToTree(objNewNodeAccess,"utilSpacer.gif","<%=Policies%>","emxPLMOnlineAdminPoliciesDetails.jsp");
                        addNodeToTree(objNewNodeAccess,"utilSpacer.gif","<%=Rules%>","emxPLMOnlineAdminRulesDetails.jsp");
                        addNodeToTree(objNewNodeAccess,"utilSpacer.gif","<%=Commands%>","emxPLMOnlineAdminCommandsDetails.jsp");
                        addNodeToTree(objNewNodeAccess,"utilSpacer.gif","<%=Masks%>","emxPLMOnlineAdminMasksDetails.jsp");
                     }

                        var ctx = "<%=ctxToSend%>";

                        var tab = ctx.split(",");
                        var isLocalAdmin = false;
                        //******************************************Getting Project/Role/Organization names and adding them at the right node
                      for (var i = 0 ; i < tab.length-1; i ++){
                        // JIC 13:07:15 IR IR-243916V6R2013x: Added role family support
                        <%
                        if (isLocalAdmin)
                        {
                        %>
                            if (!isLocalAdmin)
                            {
                                addNodeToTree(objRootNode,"iconSmallRole.gif","Local Admin","emxPLMOnlineLocalAdmin.jsp");
                                isLocalAdmin=true;
                            }
                        <%
                        }
                        %>

                        var names="emxPLMOnlineContextDetails.jsp?type=Context&name="+encodeURIComponent(tab[i])+"&suiteKey=Framework&StringResourceFileId=emxFrameworkStringResource&SuiteDirectory=common";
                        var prj = tab[i].substring(tab[i].lastIndexOf(".")+1,tab[i].length);
                        var role = tab[i].substring(0,tab[i].indexOf("."));
                        var org = tab[i].substring(tab[i].indexOf(".")+1,tab[i].lastIndexOf("."));

                        var nomProj = nomProj +  prj + "\n";
                        //******************************************Adding the contexts to the "Context" node
                            if( ( tab[i].indexOf('<%=AdminContext%>') != -1) && (conf == "SMB")  ) {}else{
                        		if(tab[i] == "<%=Preferences%>")  {
                                    if (conf == config ){
                                        var contextNameForSMB = role + " in " +  prj;
                                        addNodeToTree(objNewNode,"buttonMiniDone.gif",contextNameForSMB,names);
                                    }
                                    else{
                                         addNodeToTree(objNewNode,"buttonMiniDone.gif",tab[i],names);}
                                    }
                                else{
                                    if (!(conf == config )){
                                        addNodeToTree(objNewNode,"utilSpacer.gif",tab[i],names);
                                    }else{
                                        var contextNameForSMB = role + " in " +  prj;
                                        addNodeToTree(objNewNode,"utilSpacer.gif",contextNameForSMB,names);
                                    }
                               }
                         }

                        //******************************************Adding the projects to the "Project" node

                        var prjNamesForm ="emxPLMOnlineProjectDetails.jsp?type=Project&name="+encodeURIComponent(prj)+"&dest=Project&suiteKey=Framework&StringResourceFileId=emxFrameworkStringResource&SuiteDirectory=common";
                        var prjRefName = "emxPLMOnlineResourcesDetails.jsp?Project="+encodeURIComponent(prj)+"&source=DefaultSettings&dest=Project&suiteKey=Framework&StringResourceFileId=emxFrameworkStringResource&SuiteDirectory=common";
                        var prjUserName = "emxPLMOnlineResourcesDetails.jsp?Project="+encodeURIComponent(prj)+"&source=UsersSettings&dest=Project&suiteKey=Framework&StringResourceFileId=emxFrameworkStringResource&SuiteDirectory=common";
                        var prjPRMName = "emxPLMOnlineResourcesDetails.jsp?Project="+encodeURIComponent(prj)+"&source=PRM&dest=Project&suiteKey=Framework&StringResourceFileId=emxFrameworkStringResource&SuiteDirectory=common";
                         if( (tab[i].indexOf('<%=AdminContext%>') != -1) && (conf == "SMB")  ) {}else{
                            addNodeToTree(objNewNodeProjects,"utilSpacer.gif",prj,prjNamesForm);
                            objNewNodeSetFinal = addNodeToTree(SubobjNewNodeUserSet,"utilSpacer.gif",prj,prjUserName);
                            addNodeToTree(SubobjNewNodeReferenceSetNode,"utilSpacer.gif",prj,prjRefName);
                            addNodeToTree(objNewNodePRM,"utilSpacer.gif",prj,prjPRMName);
                        }

                         //******************************************Adding the role to the "Role" node
                         if( (tab[i].indexOf('<%=AdminContext%>') != -1) && (conf == "SMB")  ) {}else{

			var name = "emxPLMOnlineRoleDetails.jsp?type=Role&name="+encodeURIComponent(role);
                        addNodeToTree(objNewNodeRole,"utilSpacer.gif",role,name);
                        }
                    }

                       //******************************************Create and Add Organizations to "Organizations" Node
                        var org = "<%=Orgs%>";
                        var tab = org.split(",");

                        var nameOrgForm = "emxPLMOnlineOrganizationDetails.jsp?type=Organization&name="+encodeURIComponent("<%=org_id%>");
                       addNodeToTree(objNewNodeOrg,"utilSpacer.gif","<%=org_id%>",nameOrgForm);

                        <%  for (int i = 0 ; i < list_Org.size() ; i ++){
                            String nameOrg = (String)list_Org.get(i);
                         %>
                             var nameOrgForm = "emxPLMOnlineOrganizationDetails.jsp?type=Organization&name="+"<%=URLEncoder.encode(nameOrg,"UTF-8")%>";
                             addNodeToTree(objNewNodeOrg,"utilSpacer.gif","<%=nameOrg%>",nameOrgForm);
                        <%}%>
                        }
                        </script>  
                   <%
                   }
                   
                   String theCtxs = URLEncoder.encode(ctxToSend,"UTF-8");
                    String theOrgs = URLEncoder.encode(Orgs,"UTF-8");
                    org_id = URLEncoder.encode(org_id,"UTF-8");
                    String theFirstName = URLEncoder.encode(FirstName,"UTF-8");
                    String theLastName = URLEncoder.encode(LastName,"UTF-8");
                    String thePersonFromFile = URLEncoder.encode(personFromFile,"UTF-8");
                    if(configuration.equals("SMB")){
                        target = "emxPLMOnlineForm.jsp?type=Person&PLM_ExternalID="+thePersonFromFile+"&Email="+Email+"&Phone="+Phone+"&WorkPhoneNumber="+WorkPhoneNumber+"&FirstName="+theFirstName+"&LastName="+theLastName+"&Photo="+v_photo+"&employeeOf="+org_id+"&ctxs="+theCtxs+"&memberOf="+theOrgs+"&Street="+street+"&City="+city+"&State="+state+"&Country="+country+"&PostalCode="+postalCode+"&secLevel="+secLevel+"&Active="+Active+"&Alias="+Alias;
                  }else{
                    if (! source.equals("Admin")){
                       target = "emxPLMOnlineForm.jsp?type=Person&PLM_ExternalID="+thePersonFromFile+"&Email="+Email+"&Phone="+Phone+"&WorkPhoneNumber="+WorkPhoneNumber+"&FirstName="+theFirstName+"&LastName="+theLastName+"&Photo="+v_photo+"&employeeOf="+org_id+"&ctxs="+theCtxs+"&memberOf="+theOrgs+"&Street="+street+"&City="+city+"&State="+state+"&Country="+country+"&PostalCode="+postalCode+"&secLevel="+secLevel+"&Active="+Active+"&Alias="+Alias;
                    }else{
                       target = "emxPLMOnlineForm.jsp?type=Person&source=Admin&PLM_ExternalID="+thePersonFromFile+"&Email="+Email+"&Phone="+Phone+"&WorkPhoneNumber="+WorkPhoneNumber+"&FirstName="+theFirstName+"&LastName="+theLastName+"&Photo="+v_photo+"&employeeOf="+org_id+"&ctxs="+theCtxs+"&memberOf="+theOrgs+"&Street="+street+"&City="+city+"&State="+state+"&Country="+country+"&PostalCode="+postalCode+"&secLevel="+secLevel+"&Active="+Active+"&Alias="+Alias;
                   }}
                %>

   <%String titre = FirstName + " " + LastName;%>
   <script>
       addHeader("images/iconSmallPeople.gif","<%=titre%>");
   </script>
   <div style="height:85%">
       <iframe  id="middleFrame" name="middleFrame" style=" margin-top: 4% ; border: 0px" width="100%" height="90%" src="<%=target%>"></iframe>
   </div>
    <script>
    <%if (!source.equals("Admin")){%>
      addFooter("javascript:getTop('0');","images/buttonDialogDone.gif","<%=UpdateLabel%>","<%=UpdateLabel%>");
       <%}else{%>
           addFooter("javascript:getTop('1');","images/buttonDialogDone.gif","<%=UpdateLabel%>","<%=UpdateLabel%>");
           <%}%>
  </script>
    <%}%>
    </body>
</html>
