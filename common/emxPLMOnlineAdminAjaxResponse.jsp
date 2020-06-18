<% response.setContentType("text/xml");
   response.setContentType("charset=UTF-8");
   response.setHeader("Content-Type", "text/xml");
   response.setHeader("Cache-Control", "no-cache");
   response.getWriter().write("<?xml version='1.0' encoding='UTF-8'?>");
%>
<%--
    Document   : emxPLMOnlineAdminAjaxResponse.jsp
    Author     : LXM
    Modified : 10/10/2010 -> Added User preferences + New UI (New WS spec)
    Modified : 22/10/2010 -> change NLS
--%>
<%@include file = "emxPLMOnlineAdminLicensesUtil.inc"%>
<%@include file = "../common/emxNavigatorNoDocTypeInclude.inc"%>
<%@include file = "../common/emxPLMOnlineAdminAttributesCalculation.jsp"%>
<%@ page import="java.util.HashSet" %>
<%@ page import="java.util.Set" %>
<%@ page import="java.util.regex.Matcher" %>
<%@ page import="java.util.regex.Pattern" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="com.matrixone.vplm.posws.stubsaccess.ClientWithoutWS" %>
<%@ page import="com.matrixone.apps.common.Person" %>
<%@ page import="com.matrixone.vplm.posbusinessmodel.SecurityContext"%>
<%@ page import="com.matrixone.vplm.posbusinessmodel.BusinessRole"%>
<%@ page import="com.dassault_systemes.pos.resource.interfaces.*" %>
<%@ page import="com.matrixone.apps.common.Organization"%>
<%@ page import="com.dassault_systemes.vplmsecurity.PLMSecurityManager" %>
<%@ page import="java.net.URLDecoder"%>
<%@ page import="com.matrixone.vplm.posmodel.license.LicenseInfo" %>
<%@ page import="com.dassault_systemes.pos.resource.interfaces.PLMxPosDisciplineServices" %>
<%@ page import="com.dassault_systemes.vplmposadministrationui.uiutil.AdminUtilities"%>
<%@include file = "../common/emxPLMOnlineAdminAuthorize.jsp"%>
<%  
    StringBuilder finalNameString= new StringBuilder("<root>");
    String source = emxGetParameter(request,"source");

    PLMSecurityManager pm =new PLMSecurityManager(mainContext);
    String userLogged = mainContext.getUser();
	
    if ( (source.equals(null)) || (source.equals(""))){source="";}
    Map role = new HashMap();
    Map listrole = new HashMap();
    Map listcontext = new HashMap();
    Map query = new HashMap();
    Map project = new HashMap();
    Map listproject = new HashMap();
    Map listperson = new HashMap();
    Map person = new HashMap();

    // JIC 18:07:03 FUN076129: Removed use of PLM key/added context
	ClientWithoutWS client = new ClientWithoutWS(mainContext);
	 
    if ( source.indexOf("Person") > -1 ){
	 String filter = emxGetParameter(request,"User");
		
        Map parametrec = new HashMap();
        String filterDest = emxGetParameter(request,"PersonDestination");
        String SearchUser = emxGetParameter(request,"SearchUser");
        Map lisc= new HashMap();
        
        if(SearchUser != null){
        	String prJFilter = emxGetParameter(request,"ProjectFilter");
      	  	String orgFilter = emxGetParameter(request,"OrgFilter");
      	  	String roleFilter = emxGetParameter(request,"RoleFilter");
      	    
      	  	String orgTable[] = orgFilter.split(", ");
      	  	String roleTable[] = roleFilter.split(", ");
      	  	int l = 0;
      	  
      	  	for (int j = 0 ; j < orgTable.length; j++){
      			for (int k = 0 ; k < roleTable.length; k++){
      				String filterCtx= roleTable[k]+"."+orgTable[j]+"."+prJFilter;
      			  	parametrec = new HashMap();
      			  	parametrec.put("PLM_ExternalID",filterCtx);
                    lisc.put("context"+l,parametrec);
                    l++;
      		  	}  
      	  	}
     		person.put("PLM_ExternalID","*");
      		query.put("iContext",lisc);
			query.put("iSelectableList",new String[]{"BASICS"});
        }else{
        	if(filterDest == null){filterDest="";}
        	if(filterDest.equals("XP")){
            	String PersonFilter = prefUtil.getUserPreferredUIPersonFilter(mainContext);
        	if(filter != null){PersonFilter=filter;}

            	person.put("IsActive","true");
            	person.put("PLM_ExternalID",PersonFilter);
				query.put("iSelectableList",new String[]{"BASICS"});
        	}else{
        	if(filter == null){filter="*";}
        		person.put("PLM_ExternalID",filter);
        	}
        }
        listperson.put("person0" ,person);

        query.put("method","queryPerson");
        query.put("iPerson",listperson);
        Map persons = client.serviceCall(query);
        if(persons.size() == 0){
			String Person = myNLS.getMessage("Person");
            String Tab1[] = new String[1];
            Tab1[0]=Person;
            String message = myNLS.getMessage("ERR_IDDoesNotExist",Tab1);
            finalNameString.append("<Error>").append(message).append("</Error>");
		}else{
            for (int i = 0 ; i < persons.size(); i ++){
                Map finalName = (Map)persons.get("person"+i);
                StringList contx = (StringList)finalName.get("ctx");
                StringList list_Org = (StringList)finalName.get("list_Org");

                finalNameString.append("<Person>").append(EncodeUtil.escape((String)finalName.get("PLM_ExternalID")));
                finalNameString.append("<FirstName>").append(EncodeUtil.escape((String)finalName.get("v_first_name"))).append("</FirstName>");
                finalNameString.append("<LastName>").append(EncodeUtil.escape((String)finalName.get("v_last_name"))).append("</LastName>");
                finalNameString.append("<Email>").append(EncodeUtil.escape((String)finalName.get("v_email"))).append("</Email>");
                finalNameString.append("<Street>").append(EncodeUtil.escape((String)finalName.get("street"))).append("</Street>");
                finalNameString.append("<City>").append(EncodeUtil.escape((String)finalName.get("city"))).append("</City>");
                finalNameString.append("<State>").append(EncodeUtil.escape((String)finalName.get("state"))).append("</State>");
                finalNameString.append("<PostalCode>").append(EncodeUtil.escape((String)finalName.get("postalCode"))).append("</PostalCode>");
                finalNameString.append("<Country>").append(EncodeUtil.escape((String)finalName.get("country"))).append("</Country>");
                finalNameString.append("<Phone>").append(EncodeUtil.escape((String)finalName.get("v_phone"))).append("</Phone>");
                finalNameString.append("<Alias>").append(EncodeUtil.escape((String)finalName.get("v_distinguished_name"))).append("</Alias>");
                finalNameString.append("<WorkPhone>").append(EncodeUtil.escape((String)finalName.get("Work_Phone_Number"))).append("</WorkPhone>");
				String org_id = (String)finalName.get("org_id");
                if(org_id!=null) finalNameString.append("<Emp>").append(EncodeUtil.escape(org_id)).append("</Emp>");
                finalNameString.append("<IsActive>").append(EncodeUtil.escape((String)finalName.get("IsActive"))).append("</IsActive>");

                for(int j = 0 ; j < contx.size(); j++ ){
                    finalNameString.append( "<Context>").append(EncodeUtil.escape((String)contx.get(j))).append("</Context>");
                }

                 for(int k = 0 ; k < list_Org.size(); k++ ){
                    finalNameString.append( "<Org>").append(EncodeUtil.escape((String)list_Org.get(k))).append("</Org>");
                }
                finalNameString.append("</Person>");
            }
        }
    }
	//RBR2: Project based operations
    if (source.indexOf("Project") > -1 ){
    	
        String Solution = emxGetParameter(request,"Solution");
        String Destination = emxGetParameter(request,"Destination");
        String Method = emxGetParameter(request,"Method"); // [Query, ]
        String Filter = emxGetParameter(request,"Filter"); // Title now
		
        String IDFilter = emxGetParameter(request,"IDFilter"); // PLMID now [E.G method: Query ]
        
		String searchFilter = "";
		boolean titleBasedOps = true; // Default Mode is title based Ops
		
		ProjectUIRules projectRule = new ProjectUIRules(Solution,Destination,Method);
        
		if (Filter == null) Filter="*"; // Any title
		
		if (IDFilter == null && Filter != null) {
			IDFilter = "*"; //  Any Name
			searchFilter = EncodeUtil.decode(Filter);
	        query = projectRule.getTitleFilterForProject(mainContext, searchFilter); // RBR2: Now has the "V_Name"
	    } else if(!(IDFilter.trim().isEmpty())) {
			// PLMID based Operations
			searchFilter = EncodeUtil.decode(IDFilter);
	        query = projectRule.getFilterForProject(mainContext, searchFilter); // RBR2: with PLMID
	        titleBasedOps = false;
		}
	    
        query.put("method","queryProject");
	    //query.put("protocol",protocol);
        //query.put("urlpath",request.getContextPath());
        //query.put("iKey",session.getAttribute("PLMKey"));
        //query.put("endpoint",request.getServerName());
        //query.put("port",request.getServerPort()); 
        Map proj = client.serviceCall(query);
		
        // JIC 13:09:09 IR IR-252755V6R2013x: Added pattern for Local Admin
        Pattern pattern = null;
        if (AdminUtilities.isLocalAdmin(mainContext)){
            pattern = AdminUtilities.buildSearchPattern(searchFilter); 
        }
        for (int i = 0 ; i < proj.size(); i ++){
        	
            Map finalName = (Map)proj.get("project"+i);
            if (Method.equals("Create")){
                finalNameString.append("<Project>");
                finalNameString.append("<PLM_ExternalID>").append(EncodeUtil.escape((String)finalName.get("PLM_ExternalID"))).append("</PLM_ExternalID>");
                // RBR2: FUN [080973]
                finalNameString.append("<V_Name>").append(EncodeUtil.escape((String)finalName.get("V_Name"))).append("</V_Name>");
                finalNameString.append("</Project>");
            }
            else{
                // JIC 13:09:09 IR IR-252755V6R2013x: Added pattern checking for Local Admin
                boolean addProject=true;
                if (pattern != null){
                	// RBR2:  Check retrieve project satisify the search pattern coming from user
                	// RBR2: Added Matcher for Title based Ops
                    if (!titleBasedOps && finalName.containsKey("PLM_ExternalID")){
                    	Matcher matcher = pattern.matcher((String)finalName.get("PLM_ExternalID"));
                        addProject = matcher.matches(); // addProject will be true when the reg ex is matched
                    } else if (titleBasedOps && finalName.containsKey("V_Name")){
                    	Matcher matcher = pattern.matcher((String)finalName.get("V_Name"));
                        addProject = matcher.matches(); // addProject will be true when the reg ex is matched
                    }
                }
                
                if (addProject){
                	/*
                	{project1={project_Parent=, Project_Parent_V_Name=, Project_Child_V_Name=[], v_id=, V_Name=xRBR2_Title, 
                	PLM_ExternalID=x, member=[], Family=, Accreditation=, Visibility=, Solution=VPM, managers=[], child=[]}, 
                	
                	project0={project_Parent=, Project_Parent_V_Name=, Project_Child_V_Name=[], v_id=, V_Name=XRBR2_Title, 
                	PLM_ExternalID=X, member=[], Family=, Accreditation=, Visibility=, Solution=VPM, managers=[], child=[]}}*/
                	
                    Set keys = finalName.keySet();
                    Iterator keyIterator = keys.iterator(); 
                    finalNameString.append("<Project>");
                    while (keyIterator.hasNext()){
                        String keyName = (String)keyIterator.next();

                        if ((finalName.get(keyName).getClass().getName()).contains("java.lang.String")){
                            finalNameString.append("<").append(keyName).append(">").append(EncodeUtil.escape((String)finalName.get(keyName))).append("</").append(keyName).append(">");
                        }
                        if ((finalName.get(keyName).getClass().getName()).contains("matrix.util.StringList")){
                            for (int k = 0 ; k < ((StringList)finalName.get(keyName)).size() ; k++){
                                finalNameString.append("<").append(keyName).append(">").append(EncodeUtil.escape((String)((StringList)finalName.get(keyName)).get(k)) ).append("</").append(keyName).append(">");
                            }
                        }
                    }
		            if (Method.equals("Update")){
							manageContextTransaction(mainContext,"start");
		                    StringList disciplines = PLMxPosDisciplineServices.getDisciplinesForProjectAsStrings(mainContext,(String)finalName.get("PLM_ExternalID"));
		                    manageContextTransaction(mainContext,"end");
		                    for(int discIt=0; discIt<disciplines.size(); ++discIt) {
		                        finalNameString.append("<disc>").append(EncodeUtil.escape((String)disciplines.get(discIt))).append("</disc>");
							}
					}
					finalNameString.append("</Project>");
                }
            }
        }
    }

    if ( source.indexOf("Role") > -1  ){
        String Solution = emxGetParameter(request,"Solution");
        String Destination = emxGetParameter(request,"Destination");
        String Method = emxGetParameter(request,"Method");
        String Filter = emxGetParameter(request,"Filter");
        Map roleSorted = new HashMap();
        StringList objectsSelects = new StringList();
        objectsSelects.addElement("name");
        objectsSelects.addElement("id");
        StringList RoleApp = new StringList();
             
        if (AdminUtilities.isLocalAdmin(mainContext) && !Destination.equals("Profile")){
			String FilterOrg = emxGetParameter(request,"FilterOrg");
            StringList Organizations = AdminUtilities.getAnyAdminRoleOrganizations(mainContext);
			if(FilterOrg!=null) {
				Organizations.clear();
				Organizations.add(FilterOrg);
			}
            for (int i =0 ; i < Organizations.size(); i++){
                /** Query using parameters **/
                MapList mapList = DomainObject.findObjects(mainContext, "Organization", (String)Organizations.get(i), "*", "*", "*", "", true, objectsSelects);
                Map orga = (Map)mapList.get(0);
                String iD = (String)orga.get("id");

                /** Getting Organization bus **/
                Organization organization1 = new Organization(iD);
                organization1.open(mainContext);

                MapList appRole = BusinessRole.getApplicableRoles(mainContext, organization1,(FilterOrg!=null)?Filter:BusinessRole.QUERY_WILDCARD,objectsSelects,"attribute[PnO Family].value != 'Admin'");
                //int sizeRole = appRole.size()-1;//pourquoi??
                //if (sizeRole>0){
                    for (int j = 0 ; j < appRole.size(); j++){
                        Map roleApp = (Map)appRole.get(j);
                        String roleName = (String)roleApp.get("name");
                        if(!RoleApp.contains(roleName)){
                            RoleApp.addElement(roleName);
                            finalNameString.append("<Role><PLM_ExternalID>").append(EncodeUtil.escape(roleName)).append("</PLM_ExternalID>");
                            finalNameString.append("</Role>");
                        }
                    }
                //}
            }
        }
        else{
            if (Filter == null)Filter="*";

            RoleUIRules roleRule = new RoleUIRules(Solution,Destination,Method);
            query = roleRule.getFilterForRole(mainContext,Filter);
            query.put("method","queryRole");
            //query.put("urlpath",request.getContextPath());
            //query.put("protocol",protocol);
            //query.put("iKey",session.getAttribute("PLMKey"));
            //query.put("endpoint",request.getServerName());
            //query.put("port",request.getServerPort());

            roleSorted = client.serviceCall(query);

            for (int i = 0 ; i < roleSorted.size(); i ++){
                Map finalName = (Map)roleSorted.get("role"+i);
                if (Method.equals("Create")){
                    String finalNameSt = getNLS((String)finalName.get("PLM_ExternalID"));
                    if (finalNameSt.contains("UNKNOWN"))finalNameSt=EncodeUtil.escape((String)finalName.get("PLM_ExternalID"));

                    finalNameString.append("<Role><PLM_ExternalID>").append(EncodeUtil.escape((String)finalName.get("PLM_ExternalID"))).append("</PLM_ExternalID>");
                    finalNameString.append("</Role>");
                }
                else{
                    Set keys = finalName.keySet();
                    Iterator keyIterator = keys.iterator();
                    finalNameString.append("<Role>");
                    while (keyIterator.hasNext()){
                        String keyName = (String)keyIterator.next();
                        if ((finalName.get(keyName).getClass().getName()).contains("java.lang.String")){
                            finalNameString.append("<").append(keyName).append(">").append(EncodeUtil.escape((String)finalName.get(keyName))).append("</").append(keyName).append(">");
                        }
                        if ((finalName.get(keyName).getClass().getName()).contains("matrix.util.StringList")){
                        for (int k = 0 ; k < ((StringList)finalName.get(keyName)).size() ; k++){
                                finalNameString.append("<").append(keyName).append(">").append(EncodeUtil.escape((String)((StringList)finalName.get(keyName)).get(k))).append("</").append(keyName).append(">");
                            }
                        }
                    }
                    finalNameString.append("</Role>");
                }
            }
        }
    }


    if ( source.indexOf("Organization") > -1 ){ 
        String responseType = emxGetParameter(request,"responseOrg");
        String filter = emxGetParameter(request,"filterOrg");
	    String dest = emxGetParameter(request,"Destination");
	    String fchild = emxGetParameter(request,"filterChild");
        if(filter==null)filter="*";
		if(fchild != null) {
			String oldo = prefUtil.getUserPreferredUICompanyFilter(mainContext);
			if(!oldo.equals(filter)) prefUtil.setUserPreferredUICompanyFilter(mainContext,mainContext.getUser(),filter);
		}
        if(dest==null)dest="";
        if(responseType==null)responseType="";
        String[] generateResp = responseType.split(",");
		boolean needParentChild = !(responseType.indexOf("org_Parent")<0);

        Map organization = new HashMap();
        Map  listorganization  = new HashMap();
		StringList iSelectList = new StringList();
		if(needParentChild) iSelectList.addElement("parentchild");
		Pattern pattern = null;

	    if (!(AdminUtilities.isLocalAdmin(mainContext)) || dest.equals("Profile")){
        	organization.put("PLM_ExternalID",filter);
            listorganization.put("organization0",organization);
            if(fchild!=null) iSelectList.addElement("childs");
        }else{           
        	if(!dest.equals("UpdatePage") && fchild==null){
				pattern = AdminUtilities.buildSearchPattern(filter);
				StringList orgList = AdminUtilities.getAnyAdminRoleOrganizations(mainContext);
				for (int i = 0 ; i < orgList.size() ; i++){
					organization = new HashMap();
					organization.put("PLM_ExternalID",(String)orgList.get(i));
					listorganization.put("organization"+i,organization);
				}
        	 }  else {
        		 organization.put("PLM_ExternalID",filter);
                 listorganization.put("organization0",organization);
				 if(fchild!=null) iSelectList.addElement("childs");
        	 }
        }
		query.put("iSelectList",iSelectList.toArray(new String[0]));
        query.put("iOrgId",listorganization);
        query.put("method","queryOrg");

        Map org= client.serviceCall(query);
        for (int i = 0 ; i < org.size(); i ++){
            Map finalName = (Map)org.get("organization"+i);
            boolean addOrga=true;
            if (pattern != null){
                    if (finalName.containsKey("PLM_ExternalID")){
                        Matcher matcher = pattern.matcher((String)finalName.get("PLM_ExternalID"));
                        addOrga = matcher.matches();
                    }
            }
            if (addOrga){
				finalNameString.append("<Organization><PLM_ExternalID>").append(EncodeUtil.escape((String)finalName.get("PLM_ExternalID"))).append("</PLM_ExternalID>");
				if(!generateResp[0].equals("")){
                    for (int j = 0 ; j< generateResp.length; j++){
                      if (( finalName.containsKey(generateResp[j])) && (finalName.get(generateResp[j]) != null) && finalName.get(generateResp[j]).getClass().getName() == "java.lang.String"){
                            finalNameString.append("<").append(generateResp[j]).append(">").append(EncodeUtil.escape((String)finalName.get(generateResp[j]))).append("</").append(generateResp[j]).append(">");
                    }
                    if (( finalName.containsKey(generateResp[j])) && (finalName.get(generateResp[j]) != null) && finalName.get(generateResp[j]).getClass().getName() == "matrix.util.StringList"){

                            for (int k = 0 ; k < ((StringList)finalName.get(generateResp[j])).size() ; k++){
                                finalNameString.append("<").append(generateResp[j]).append(">").append(EncodeUtil.escape((String)((StringList)finalName.get(generateResp[j])).get(k))).append("</").append(generateResp[j]).append(">");
                            }
                         }
                    }
                 }
                finalNameString.append("</Organization>");
			}
		}
    }

    if ( source.indexOf("OrgAndRolApp") > -1 ){
        String filter = emxGetParameter(request,"Filter");

        if(filter==null)filter="*";

        Map organization = new HashMap();
        Map  listorganization  = new HashMap();

        if(AdminUtilities.isLocalAdmin(mainContext)){
            StringList orgList = AdminUtilities.getAnyAdminRoleOrganizations(mainContext);
            for (int i = 0 ; i < orgList.size() ; i++){
                 organization = new HashMap();
                 organization.put("PLM_ExternalID",(String)orgList.get(i));
                 listorganization.put("organization"+i,organization);
            }
        }else{
            organization.put("PLM_ExternalID",filter);
            listorganization.put("organization0",organization);
        }
	
        query.put("method","queryOrg");
        query.put("iOrgId",listorganization);
        query.put("iSelectList",new String[]{"BASICS"});

        
        Map org= client.serviceCall(query);
        StringList objectsSelects = new StringList();
        objectsSelects.addElement("name");
        objectsSelects.addElement("id");
          
        
        for (int i = 0 ; i < org.size(); i ++){
            Map finalName = (Map)org.get("organization"+i);
            String finalNamePLMID = (String)finalName.get("PLM_ExternalID");

            Set keys = finalName.keySet();
            Iterator keyIterator = keys.iterator();
            finalNameString.append("<Organization>");
         
            while (keyIterator.hasNext()){
                String keyName = (String)keyIterator.next();
                if ( ( finalName.containsKey(keyName)) && (finalName.get(keyName) != null) &&((finalName.get(keyName).getClass().getName()).contains("java.lang.String"))){
                    finalNameString.append("<").append(keyName).append(">").append(EncodeUtil.escape((String)finalName.get(keyName))).append("</").append(keyName).append(">");
                }
                if (( finalName.containsKey(keyName)) && (finalName.get(keyName) != null) && (finalName.get(keyName).getClass().getName()).contains("matrix.util.StringList")){
                    for (int k = 0 ; k < ((StringList)finalName.get(keyName)).size() ; k++){
                   	finalNameString.append("<").append(keyName).append(">").append(EncodeUtil.escape((String)((StringList)finalName.get(keyName)).get(k))).append("</").append(keyName).append(">");
                    }
                }
            }

            /** Query using parameters **/
            MapList mapList = DomainObject.findObjects(mainContext, "Organization", finalNamePLMID, "*", "*", "*", "", true, objectsSelects);
            Map orga = (Map)mapList.get(0);
            String iD = (String)orga.get("id");
            /** Getting Organization bus **/
            Organization organization1 = new Organization(iD);
            organization1.open(mainContext);
            MapList appRole = BusinessRole.getApplicableRoles(mainContext, organization1,BusinessRole.QUERY_WILDCARD,objectsSelects,"");
            finalNameString.append("<RoleApplicable>");
            String roleToSend="";
            // JIC 13:07:15 IR IR-243916V6R2013x: Added roles family
            String roleFamilyToSend="";
            int sizeRole = appRole.size()-1;
            if (sizeRole>-1){
                for (int j = 0 ; j < appRole.size()-1; j++){
                    Map roleApp = (Map)appRole.get(j);
                    String roleName = (String)roleApp.get("name");
                    roleToSend = roleToSend+roleName+",";
                    String roleFamily = MqlUtil.mqlCommand(mainContext, "print role $1 select $2 dump",roleName,"property[FAMILY].value");
                    roleFamilyToSend = roleFamilyToSend+roleFamily+",";
                }
                Map roleApp1 = (Map)appRole.get(sizeRole);
                String roleName1 = (String)roleApp1.get("name");
                roleToSend = roleToSend+roleName1;
                String roleFamily1 = MqlUtil.mqlCommand(mainContext, "print role $1 select $2 dump",roleName1,"property[FAMILY].value");
                roleFamilyToSend = roleFamilyToSend+roleFamily1;
            }
            finalNameString.append(EncodeUtil.escape(roleToSend)).append("</RoleApplicable><FamilyRoleApplicable>").append(EncodeUtil.escape(roleFamilyToSend)).append("</FamilyRoleApplicable><RoleApplicableNum>").append(appRole.size()).append("</RoleApplicableNum>");
            // JIC 13:07:15 IR IR-243916V6R2013x: Replaced hard-coded pattern with where clause on role family
            String nameFilter = "*."+finalNamePLMID+".*";
            MapList secContexts = SecurityContext.getSecurityContexts(mainContext,nameFilter, objectsSelects, "from[Security Context Role].to.attribute[PnO Family].value ~~ 'LocalAdmin'");
            String name2Send="";
            int sizeCtx = secContexts.size()-1;
            if(sizeCtx > -1)
            {
                for (int k = 0; k < sizeCtx  ; k++)
                {
                    Map secCtxMap = (Map)secContexts.get(k);
                    String secName = (String)secCtxMap.get("name");
                    name2Send = name2Send+secName+" , ";
                }
                Map secCtxMap1 = (Map)secContexts.get(sizeCtx);
                String secName1 = (String)secCtxMap1.get("name");
                name2Send = name2Send+secName1;
           }
           finalNameString.append("<SecurityContext>").append(EncodeUtil.escape(name2Send)).append("</SecurityContext>");
           finalNameString.append("<SecurityContextNum>").append(secContexts.size()).append("</SecurityContextNum>");
           finalNameString.append("</Organization>");
        }
    }


    if ( source.indexOf("Context") > -1 ){
        Map parametrec= new HashMap();
        Map lisc= new HashMap();

        String filter = emxGetParameter(request,"ctxFilter");
        String Method = emxGetParameter(request,"Method");
        String SearchUser = emxGetParameter(request,"SearchUser");
        if (filter == null){filter = emxGetParameter(request,"Filter");}
        if (filter == null)filter="*";
        if (Method == null)Method ="";
        String save = emxGetParameter(request,"saveFilter");
     	// RBR2: FUN [080973]
        String iDFilter = emxGetParameter(request,"ctxID");
        
        // RBR2: Done this to support unique Context queries.
        boolean isIDBased = false;
        if(iDFilter != null && !iDFilter.trim().isEmpty()){
        	filter = iDFilter;
        	isIDBased = true;
        }
        
        if (save != null){
        	//RBR2: Here with title being in picture, we will never set the Context query with title.
        	//this is only managed when name is there.
        	String oldctx = prefUtil.getUserPreferredUIAvailableCtxFilter(mainContext); // Involves Names
			if(!oldctx.equals(filter)){
				// RBR2: FUN[080973]
				// Reason behind this is to manage the Title based filtering
				// As name are generated from Title, this will be help keeping querying near to name
				if(filter != null && !filter.equals("*")){
					//if(!filter.startsWith("*")) filter = "*"+filter;
					if(!filter.endsWith("*")) filter = filter +"*";
				}
				prefUtil.setUserPreferredUIAvailableCtxFilter(mainContext,mainContext.getUser(),filter);
			}
		}
		
        boolean isTitleBased = false;
        lisc.put("context0",parametrec);
      	if ((AdminUtilities.isCentralAdmin(mainContext)) || (Method.equals("Create"))){ 
            // RBR2: Commented the PLM_ExternalID
            //parametrec.put("PLM_ExternalID",filter);
            if(!isIDBased){
            	parametrec.put("V_Name",filter);
                lisc.put("context0",parametrec);
                isTitleBased = true;	
            } else {
            	parametrec.put("PLM_ExternalID",filter);
                lisc.put("context0",parametrec);
            }
      	}else{
       		// if local Admin User
       		// RBR2: Proposition should be like Name and Title [While Proposition Name or Title is not valid]
            StringList result = AdminUtilities.getContextsFilterForLocalAdmin(mainContext);
            for(int i = 0 ; i < result.size() ; i++){
                parametrec = new HashMap();
                parametrec.put("PLM_ExternalID",result.get(i));
                lisc.put("context"+i,parametrec);
            }
        }

        if(emxGetParameter(request,"select") != null)
        {
            String[] slec = new String[1];
     		slec[0]="person";
            query.put("iSelectableList",slec);
        }
        if(emxGetParameter(request,"selectOrg") != null)
        {
            String[] slec = new String[2];
     		slec[0]="organization";
     		slec[1]="role";
            query.put("iSelectableList",slec);
        }
        query.put("method","queryContext");
        query.put("iContextInfo",lisc);

        Map result = client.serviceCall(query);
        
        Map contextResults = (Map)result.get("context");
        String responseType = emxGetParameter(request,"response");

        if(responseType==null)responseType="";
        String[] generateResp = responseType.split(",");

        if(emxGetParameter(request,"selectOrg") != null){
            Map orgMap = (Map)result.get("organization");
			Set<String> unique = new HashSet<String>();
    		for (int i = 0 ; i < orgMap.size() ; i ++){
                Map orgaMap = (Map)orgMap.get("organization"+i);
    			String newOrg = "<Organization>"+EncodeUtil.escape((String)orgaMap.get("PLM_ExternalID"))+"</Organization>";
    			if(unique.add(newOrg))finalNameString.append(newOrg);
    		}
    		Map roleMap = (Map)result.get("role");
			unique.clear();
    		for (int i = 0 ; i < roleMap.size() ; i ++){
    		    Map rolesMap = (Map)roleMap.get("role"+i);
    		    String newRole = "<Role>"+EncodeUtil.escape((String)rolesMap.get("PLM_ExternalID"))+"</Role>";
    		    if(unique.add(newRole))finalNameString.append(newRole);                 
            }
			unique.clear();
        }
      
        // JIC 13:09:09 IR IR-252755V6R2013x: Added pattern for Local Admin
        Pattern pattern = null;
        if (AdminUtilities.isLocalAdmin(mainContext)){
            pattern = AdminUtilities.buildSearchPattern(filter);
        }
        for (int i = 0 ; i < contextResults.size() ; i ++){
            Map contextMap = (Map)contextResults.get("context"+i);
           
            // JIC 13:09:09 IR IR-252755V6R2013x: Added pattern checking for Local Admin
            boolean addContext=true;
            // RBR2: if Client queries with specifying the Title then matcher must applies to Title 
            //  in some cases of uniqueness based query, matcher is applied on PLM_ExnternID as same is pushed by client
            if (pattern != null && isTitleBased && !isIDBased){ 
                if (contextMap.containsKey("V_Name") ){
                    //RBR2: Now V_Name based Matcher
                    Matcher matcher = pattern.matcher((String)contextMap.get("V_Name"));
                    addContext = matcher.matches();
                }
            }else if (pattern != null && isIDBased && !isTitleBased){
            	// Same old ID based Matching.
                if (contextMap.containsKey("PLM_ExternalID") ){
                    Matcher matcher = pattern.matcher((String)contextMap.get("PLM_ExternalID"));
                    addContext = matcher.matches();
                }
            }
            
            if (addContext){
                String nom = (String)contextMap.get("PLM_ExternalID");
                String vname = (String)contextMap.get("V_Name");
                finalNameString.append("<Context><PLM_ExternalID>").append(EncodeUtil.escape((String)nom)).append("</PLM_ExternalID>");
                //RBR2: Push title also
                finalNameString.append("<V_Name>").append(EncodeUtil.escape((String)vname)).append("</V_Name>");
                if(!generateResp[0].equals("")){
                    for (int j = 0 ; j< generateResp.length; j++){
                        if (contextMap.get(generateResp[j]).getClass().getName() == "java.lang.String"){
                             finalNameString.append("<").append(generateResp[j]).append(">").append(EncodeUtil.escape((String)contextMap.get(generateResp[j]))).append("</").append(generateResp[j]).append(">");
                        }
                        if (contextMap.get(generateResp[j]).getClass().getName() == "matrix.util.StringList" || contextMap.get(generateResp[j]).getClass().getName() == "java.lang.String[]"){
                            for (int k = 0 ; k < ((StringList)contextMap.get(generateResp[j])).size() ; k++){
                                finalNameString.append("<").append(generateResp[j]).append(">").append(EncodeUtil.escape((String)((StringList)contextMap.get(generateResp[j])).get(k))).append("</").append(generateResp[j]).append(">");
                            }
                        }
                    }
                }
                
                finalNameString.append("</Context>");
            }
        }
    } // RBR2: Done conttext
	  // RBR2: FUN [080973]: This will set the Title of Project not the name
      if ( source.indexOf("setUserPreferences") > -1 ){
		String personFilter = emxGetParameter(request,"personFilter");
		// RBR2: This is Title Filter
		String projectFilter= emxGetParameter(request,"projectFilter");
		String roleFilter= emxGetParameter(request,"roleFilter");
		String preferedSolution= emxGetParameter(request,"preferedSolution");
		pm.pushUserAgentContext();
                String res = prefUtil.setUserAllUIPreferences(mainContext,userLogged,personFilter,roleFilter,projectFilter,preferedSolution);
		pm.popUserAgentContext();
		if (res.contains(" ")){
                    res=getNLS("SUC_AdminPrefReset");
                }
                finalNameString.append("<resultat>").append(res ).append("</resultat>");

	}

    if ( source.indexOf("setUserSolutionPreferences") > -1 ){
		String preferedSolution= emxGetParameter(request,"Solution");
		pm.pushUserAgentContext();
                String res = prefUtil.setUserPreferredUISolution(mainContext,userLogged,preferedSolution);
		pm.popUserAgentContext();
		if (res.contains(" ")){
                    res=getNLS("SUC_AdminPrefReset");
                }
                finalNameString.append("<resultat>").append(res ).append("</resultat>");

	}

    //RBR2: FUN[080973] This will provide the Project Title instead of Name
	if ( source.indexOf("getUserPreferences") > -1 ){
		String prefUser = prefUtil.getUserAllUIPreferences(mainContext);
		finalNameString.append(prefUser) ;
	}
    
      if ( source.indexOf("Discipline") > -1 ){
           manageContextTransaction(mainContext,"start");
           StringList disciplines = PLMxPosDisciplineServices.getRootDisciplinesAsStrings(mainContext,"");
        manageContextTransaction(mainContext,"end");
                for (int i = 0 ; i < disciplines.size(); i++ ){
                       finalNameString.append("<Discipline>").append(EncodeUtil.escape((String)disciplines.get(i))).append("</Discipline>");
        }
    }         


        if ( source.indexOf("DiscForPrj") > -1 ){
           manageContextTransaction(mainContext,"start");

                String filter = emxGetParameter(request,"filter");
                
                StringList disciplines = PLMxPosDisciplineServices.getDisciplinesForProjectAsStrings(mainContext,filter);
        manageContextTransaction(mainContext,"end");
                for (int i = 0 ; i < disciplines.size(); i++ ){
                       finalNameString.append("<Disciplines>").append(EncodeUtil.escape((String)disciplines.get(i))).append("</Disciplines>");
            }
        }

   if ( source.indexOf("Confidentiality") > -1 ){
        manageContextTransaction(mainContext,"start");
            
             MapList mpl = PLMxPosTableServices.getTableRows(mainContext, "Confidentiality");
        manageContextTransaction(mainContext,"end");

              for (int i = 0 ; i < mpl.size(); i++ ){
                  Hashtable h = (Hashtable)mpl.get(i);
                   String desc = (String)h.get("V_description");
                  if (desc.equals("NULL"))desc=" ";
                finalNameString.append("<Confidentiality><PLMID>").append(h.get("PLMID")).append("</PLMID><Name>").append(EncodeUtil.escape((String)h.get("V_row_name"))).append("</Name><Value>").append(EncodeUtil.escape((String)h.get("V_row_value"))).append("</Value><Description>").append(EncodeUtil.escape(desc)).append("</Description></Confidentiality>");

        }
    }

     if ( source.indexOf("Family") > -1 ){
        manageContextTransaction(mainContext,"start");
         String Solution = emxGetParameter(request,"Solution");
             MapList mpl = PLMxPosTableServices.getFamiliesForSolution(mainContext, Solution);
        manageContextTransaction(mainContext,"end");

              for (int i = 0 ; i < mpl.size(); i++ ){
                  Hashtable h = (Hashtable)mpl.get(i);
                   String desc = (String)h.get("V_description");
                  if (desc.equals("NULL"))desc=" ";
                finalNameString.append("<Family><PLMID>").append(h.get("PLMID")).append("</PLMID><Name>").append(EncodeUtil.escape((String)h.get("V_row_name"))).append("</Name><Value>").append(EncodeUtil.escape((String)h.get("V_row_value"))).append("</Value><Description>").append(EncodeUtil.escape(desc)).append("</Description></Family>");

        }
    }
             

      if ( source.indexOf("getSolution") > -1 ){
            manageContextTransaction(mainContext,"start");

             MapList mpl = PLMxPosTableServices.getTableRows(mainContext, "Solution");
        manageContextTransaction(mainContext,"end");

             for (int i = 0 ; i < mpl.size(); i++ ){
                  Hashtable h = (Hashtable)mpl.get(i);
                   String desc = (String)h.get("V_description");
                  if (desc.equals("NULL"))desc=" ";
                finalNameString.append("<Solution><PLMID>").append(h.get("PLMID")).append("</PLMID><Name>").append(EncodeUtil.escape((String)h.get("V_row_name"))).append("</Name><Value>").append(EncodeUtil.escape((String)h.get("V_row_value"))).append("</Value><Description>").append(EncodeUtil.escape(desc)).append("</Description></Solution>");

        }
    }


     if ( source.indexOf("UserCtx") > -1 ){
			// RBR2: FUN[080973] Mdofied for V_Name
			String PLM_ExternalID = emxGetParameter(request, "SearchUser");
	        String CtxFilterHas = emxGetParameter(request,"ctxFilter");
	        Person CtxAssignee = Person.getPerson(mainContext, PLM_ExternalID);
			StringList lstSelectable = new StringList();
            lstSelectable.addElement(DomainConstants.SELECT_NAME);
            lstSelectable.addElement(DomainConstants.SELECT_ATTRIBUTE_TITLE); // Seelct Title
            String where = "(attribute[Title].value matchlist const '"+CtxFilterHas+"' ',')";
           	MapList lstSecurityContext = SecurityContext.getSecurityContexts(mainContext,
                                                                             CtxAssignee,
                                                                             null,
                                                                             lstSelectable,
                                                                             where); 
           	if (lstSecurityContext != null)
			{
				lstSecurityContext.addSortKey(DomainConstants.SELECT_NAME, "ascending", "string");
			    lstSecurityContext.sort();
				for (int i = 0; i < lstSecurityContext.size(); i++)
				{
					String nom = (String)((Map)lstSecurityContext.get(i)).get(DomainConstants.SELECT_NAME);
					String V_name = (String)((Map)lstSecurityContext.get(i)).get(DomainConstants.SELECT_ATTRIBUTE_TITLE);
					finalNameString.append("<Context><PLM_ExternalID>").append(EncodeUtil.escape(nom)).append("</PLM_ExternalID>");
					finalNameString.append("<V_Name>").append(EncodeUtil.escape(V_name)).append("</V_Name></Context>");
				}
			}
			String oldctx = prefUtil.getUserPreferredUIAssignedCtxFilter(mainContext);
			if(!oldctx.equals(CtxFilterHas)){
				// RBR2: FUN[080973]
				// Reason behind this is to manage the Title based filtering
				// As name are generated from Title, this will be help keeping querying near to name
				if(CtxFilterHas != null && !CtxFilterHas.equals("*")){
					//if(!CtxFilterHas.startsWith("*")) CtxFilterHas = "*"+CtxFilterHas;
					if(!CtxFilterHas.endsWith("*")) CtxFilterHas = CtxFilterHas +"*";
				}
				prefUtil.setUserPreferredUIAssignedCtxFilter(mainContext,mainContext.getUser(),CtxFilterHas);			
			}
    }


   if ( source.indexOf("CheckAccess") > -1 ){
            String iUserName = emxGetParameter(request,"UserName");
            String iSecurityContextName = emxGetParameter(request,"SecurityContextName");
            String iObjectType = emxGetParameter(request,"ObjectType");
            String iObjectName = emxGetParameter(request,"ObjectName");
            String iObjectRevision = emxGetParameter(request,"ObjectRevision");
            String iAccess = emxGetParameter(request,"Access");
  
            String[] AllAccesses = iAccess.split(",,");

            short[] accessToAsk = new short[AllAccesses.length];
            for(int i = 0 ; i <AllAccesses.length ; i++ ){
                  
                short temp =  Short.valueOf(AllAccesses[i]);
              
                accessToAsk[i]= temp;
            }


           try{
               boolean[] check = pm.checkAccess(iUserName,iSecurityContextName,iObjectType ,iObjectName  ,iObjectRevision , accessToAsk );

                for(int j = 0 ; j < check.length ; j++){
                finalNameString.append("<Access>").append(check[j]).append("</Access>");
                }
                }catch(Exception e){
                   e.printStackTrace();
                   finalNameString.append("<Error>").append(e.getMessage()).append("</Error>");
               }

        }
 		if ( source.indexOf("Activate") > -1 ){
            Map parametrec= new HashMap();
            Map lisc= new HashMap();

            String Activating = emxGetParameter(request,"Active");
            String Persons = emxGetParameter(request,"Persons");

           if (Activating.equals("true")){
               query.put("iActiveInactive",0);
           }else{
               query.put("iActiveInactive",1);
           }
           
           String[] personList = Persons.split("::");
          
           query.put("iPersonsList",personList);

            query.put("method","changeUsersState");
       

            Map result = client.serviceCall(query);
            Integer resultat = (Integer)result.get("resultat");
            finalNameString.append( "<result>").append(resultat).append(" " ).append( getNLS("personsHaveBeenUpdated")).append(".</result><persons>").append(EncodeUtil.escape(Persons)).append("</persons>");
	}

    
if ( source.indexOf("resetPassword") > -1 ){
             String UserID = emxGetParameter(request,"UserID");

            query.put("iUserID",UserID);
            query.put("iNewPassword",UserID);
            query.put("method","resetPassword");
            Map res =  client.serviceCall(query);
            Integer result = (Integer)res.get("resultat");
            switch (result){
            case 0 :
                  finalNameString.append( "<result>").append(getNLS("passwordReset")).append("</result>");
         		break;
            case 1 :
                finalNameString.append( "<result>").append(getNLS("ERR_ResetRight")).append("</result>");
                break;
            default :
                finalNameString.append( "<result>").append("Error while trying to reset " ).append(EncodeUtil.escape(UserID)).append( "s password</result>");
                break;
        }

        }
    
    if ( source.indexOf("RolApplicable") > -1 ){
    	// xmlreq("emxPLMOnlineAdminAjaxResponse.jsp","source=RolApplicable&Filter="+encodeURIComponent(filterorg)+"&Method=Create&ProjectApp=Yes&ProjectFilter="+encodeURIComponent(filter),formatResponseRoleApp,5);
        String prjFilter = emxGetParameter(request,"ProjectFilter"); // This will be coming from Create COntext Page: RBR2 [TITLE]
        if (prjFilter==null)prjFilter="*";
        String orgFilter = emxGetParameter(request,"Filter");
        String method = emxGetParameter(request,"Method");
		String ProjectApp = emxGetParameter(request,"ProjectApp");
        if (ProjectApp==null)ProjectApp="";
            
        boolean doQuery = true;
          
        Map org = new HashMap();
        MapList appRole = new MapList();
        String iD="";

        manageContextTransaction(mainContext,"start");
        StringList objectsSelects = new StringList();
        objectsSelects.addElement("name");
        objectsSelects.addElement("id");
        objectsSelects.addElement("to[Division].businessobject.name");
        objectsSelects.addElement("to[Company Department].businessobject.name");
        objectsSelects.addElement("to[Subsidiary].businessobject.name");
        objectsSelects.addElement("description");

        /** Query using parameters **/
        MapList mapList = DomainObject.findObjects(mainContext, "Organization", orgFilter, "*", "*", "*", "", true, objectsSelects);
        if (mapList.size()>0){
            org = (Map)mapList.get(0);
        }
        /*If Method equals parent means that we need parents applicable Roles*/
        if (method.equals("Parent") ){
            if (org.containsKey("to[Division].businessobject.name") || org.containsKey("to[Company Department].businessobject.name")|| org.containsKey("to[Subsidiary].businessobject.name")){
                iD = (String)org.get("to[Company Department].businessobject.name");
                if(iD==null){
                    iD = (String)org.get("to[Division].businessobject.name");
                }
                if(iD==null){
                    iD = (String)org.get("to[Subsidiary].businessobject.name");
                }
                mapList = DomainObject.findObjects(mainContext, "Organization", iD, "*", "*", "*", "", true, objectsSelects);
                if (mapList.size()>0){
                    org = (Map)mapList.get(0);
                }
            }else{
                if(!AdminUtilities.isLocalAdmin(mainContext)){
                    appRole = BusinessRole.getRoles(mainContext,"*", objectsSelects, "(attribute[PnO Solution] ~~ VPM)");
                    doQuery=false;
                }
            }
        }

                  
        /** Query using parameters **/
        if(doQuery){
            iD = (String)org.get("id");
            /** Getting Organization bus **/
            Organization organization = new Organization(iD);
            organization.open(mainContext);

            appRole = BusinessRole.getApplicableRoles(mainContext, organization,BusinessRole.QUERY_WILDCARD,objectsSelects,"");
        }
        for (int i = 0 ; i < appRole.size(); i++){
            finalNameString.append("<RoleApplicable>");
            Map roleApp = (Map)appRole.get(i);
         
            String roleName = (String)roleApp.get("name");
            String roleDesc = (String)roleApp.get("description");
            finalNameString.append("<PLM_ExternalID>").append(EncodeUtil.escape(roleName)).append("</PLM_ExternalID><Description>").append(EncodeUtil.escape(roleDesc)).append("</Description>");
            finalNameString.append("</RoleApplicable>");
        }

        if ( !ProjectApp.equals("") ){
        	// RBR2: This performs String split on Security Context Names to get The 
            StringList ListPRJ = AdminUtilities.getProjectsForAnOrganization(mainContext,orgFilter);
        	// TODO: REMAIN 
            StringList ListPRJTitles = AdminUtilities.getProjectsTitleForAnOrganization(mainContext,orgFilter);
			Pattern pattern = null;
			if (AdminUtilities.isLocalAdmin(mainContext)){
				pattern = AdminUtilities.buildSearchPattern(prjFilter); // This will be Title hence applied to Title only : RBR2 []
			}
            for (int i = 0 ; i <ListPRJ.size(); i++){
				boolean addProject = true;
                if (pattern != null){
                    Matcher matcher = pattern.matcher((String)ListPRJ.get(i));
                    addProject = matcher.matches();
                }
                if(addProject) finalNameString.append("<ProjectApp>").append(EncodeUtil.escape((String)ListPRJ.get(i))).append("</ProjectApp>");
            }
        }
        manageContextTransaction(mainContext,"end");
    }

    // JIC 13:07:18 IR IR-243916V6R2013x: Changed source name
        if ( source.indexOf("AddRolApplicability") > -1 ){
            String roles2Rem = emxGetParameter(request,"RolesToRem");
           String roles2Add = emxGetParameter(request,"Roles2Add");
           String orgFilter = emxGetParameter(request,"Filter");


            manageContextTransaction(mainContext,"start");
            StringList objectsSelects = new StringList();
            objectsSelects.addElement("name");
            objectsSelects.addElement("id");

            /** Query using parameters **/
            MapList mapList = DomainObject.findObjects(mainContext, "Organization", orgFilter, "*", "*", "*", "", true, objectsSelects);
            Map org = (Map)mapList.get(0);
            String iD = (String)org.get("id");

            /** Getting Organization bus **/
            Organization organization = new Organization(iD);
            organization.open(mainContext);

            String[] roleTabRem = roles2Rem.split(";;");
            String[] roleTabAdd = roles2Add.split(";;");

            StringList roleNamesAdd = new StringList();
            StringList roleNamesRem = new StringList();
            for(int i = 1 ; i < roleTabRem.length ; i++){
                roleNamesRem.addElement(roleTabRem[i]);
            }
            for(int i = 1 ; i < roleTabAdd.length ; i++){
                roleNamesAdd.addElement(roleTabAdd[i]);
            }
          
           BusinessRole.removeApplicableRoles(mainContext, organization, roleNamesRem);
           Map res =new HashMap();
            if (roleNamesAdd.size()>0){
                res =   BusinessRole.addApplicableRoles(mainContext, organization, roleNamesAdd);
            }
           finalNameString.append("<ApplicableRoles>").append(res.size()).append("</ApplicableRoles>");
           mainContext.commit();

   }

    if ( source.indexOf("CreateCtx") > -1 ){
         String PrjNames =   emxGetParameter(request,"Prj2Add");
         String[] prjNamesOneByIOne = PrjNames.split(";;");
         String OrgNames =   emxGetParameter(request,"OrgName");
         String roleName = "Local Administrator";

         for (int i = 1 ; i < prjNamesOneByIOne.length ; i++ ){
             String contextName = roleName+"."+OrgNames+"."+prjNamesOneByIOne[i];
            Map organization = new HashMap();
        listcontext= new HashMap();
        role= new HashMap();
        project= new HashMap();

              listcontext.put("PLM_ExternalID",contextName);
              role.put("PLM_ExternalID",roleName);
              organization.put("PLM_ExternalID",OrgNames);
              project.put("PLM_ExternalID",prjNamesOneByIOne[i]);

              Map fin = new HashMap();
              //fin.put("endpoint",request.getServerName());
                //fin.put("port",request.getServerPort());
                //fin.put("protocol",protocol);
                //fin.put("urlpath",request.getContextPath());
                //fin.put("iKey",session.getAttribute("PLMKey"));
                fin.put("method","createContext");
                fin.put("iContextInfo",listcontext);
                fin.put("iOrganizationInfo",organization);
                fin.put("iProjectInfo",project);
                fin.put("iRoleInfo",role);

              
                Map ret = client.serviceCall(fin);
                finalNameString.append("<Result>").append(((Integer)ret.get("resultat")).intValue()).append("</Result>");

         }
      }
    
    if ( source.indexOf("Licences") > -1 ){
    
    	String Filter = emxGetParameter(request,"Filter");
        String casualLicences = getCasualLicencesAssigned(mainContext,Filter,"40");
        String CasualLicenseTable[] = casualLicences.split(",");
        finalNameString.append("<Result>");

        for (int i = 0 ; i < CasualLicenseTable.length; i++){
        	 finalNameString.append("<CasualLicense>").append(CasualLicenseTable[i]).append("</CasualLicense>");
        }
        Vector lListOfUserLicenses = new Vector();
        LicenseInfo.getUserLicenses(mainContext, Filter, lListOfUserLicenses);
        for (int i = 0; i < lListOfUserLicenses.size(); i++) {
            String s = (String)lListOfUserLicenses.get(i);
            finalNameString.append("<FullLicense>").append(s).append("</FullLicense>");
        }
        finalNameString.append("</Result>");
    }

        finalNameString.append("</root>");
        response.getWriter().write(finalNameString.toString());
  %>
