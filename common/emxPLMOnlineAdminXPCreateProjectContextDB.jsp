<% response.setContentType("text/xml");
   response.setContentType("charset=UTF-8");
   response.setHeader("Content-Type", "text/xml");
   response.setHeader("Cache-Control", "no-cache");
   response.getWriter().write("<?xml version='1.0' encoding='UTF-8'?>");
%>
<%@ page import="java.util.Map"  %>
<%@ page import="java.util.HashMap"  %>
<%@ page import="com.matrixone.vplm.posws.stubsaccess.ClientWithoutWS"  %>
<%@ page import="com.dassault_systemes.vplmposadminservices.model.PLMProjectTemplate" %>
<%@ page import="com.dassault_systemes.vplmposadministrationui.uiutil.EncodeUtil" %>
<%@ page import="com.matrixone.vplm.posbusinessmodel.SecurityContext"  %>
<%@ page import="com.matrixone.apps.common.Person"  %>
<%@ page import="com.matrixone.vplm.posbusinessmodel.Project"%>
<%@ page import="com.dassault_systemes.vplmposadministrationui.uiutil.AdminUtilities"%>
<%@include file = "../common/emxNavigatorNoDocTypeInclude.inc"%>
<%@include file = "../common/emxPLMOnlineAdminAttributesCalculation.jsp"%>
<%@include file = "../common/emxPLMOnlineAdminAuthorize.jsp"%>
<%
    String responseCreateProject="<root><createResult>";
    
    /*Variables initialisation*/      
    String name = emxGetParameter(request,"project");
    String Assignment = emxGetParameter(request,"HiddenElement");
    String parent =emxGetParameter(request,"parent");
    String desc = emxGetParameter(request,"V_id");
    String source = emxGetParameter(request,"source");
    String currentOrga = emxGetParameter(request,"currentOrganization");
    String auto = emxGetParameter(request,"autoName");
    		
    
    // AGA14: FUN[080973]
    String title = emxGetParameter(request,"V_Name");
    String newTitle = emxGetParameter(request,"NewPrjV_Name");
    
	name = EncodeUtil.decode(name);
    title = EncodeUtil.decode(title);
	newTitle = EncodeUtil.decode(newTitle);

    String removeSelect ="";
    String message = "";

    if (parent == null) {parent="";}
    if (name == null) {name="";}
    if (desc == null) {desc="";}
    if (Assignment == null) {Assignment="";}
    
    if (title == null) {title="";}

    String Tab[] = new String[1];
    Tab[0]=EncodeUtil.escape(emxGetParameter(request,"project"));

    Map project = new HashMap();
    Map ret = new HashMap();
    Map contx = new HashMap();
    Map role = new HashMap();
    Map organization = new HashMap();
    Map prject = new HashMap();
    Map fin = new HashMap();
    StringList members = new StringList();
    StringList roles = new StringList();

    String HostCompanyName= getHostCompanyName(mainContext);
    String prefUser = prefUtil.getUserPreferredUISolution(mainContext);

    PLMProjectTemplate clientUtil = new PLMProjectTemplate();
    if(prefUser.equals("TEAM")){
        Map FamVisSol = clientUtil.getProjectTemplateInfos(context,parent);
        project.put("Family",FamVisSol.get("Family"));
        project.put("Solution",FamVisSol.get("Solution"));
        project.put("Visibility",FamVisSol.get("Visibility"));
    }else{
        project.put("Family",parent);
        project.put("Solution","VPM");
    }
    // JIC 18:07:03 FUN076129: Removed use of PLM key/added context
    ClientWithoutWS client = new ClientWithoutWS(mainContext);

    int nbCtxToCreate=0;
    int nbCtxCreated=0;
    int resultat = -5;
     /*Filling the project Map*/
    project.put("v_id",desc);
    
    if(auto != null && auto.equals("true") && !source.equals("XPUpdateProject")) {
    	project.put("PLM_ExternalID",null);
    } else {
    	project.put("PLM_ExternalID",name);	
    }
    
    project.put("V_Name",title);
   
    /*Update the basic informations of the project*/
    if (source.equals("XPUpdateProject")){
        fin.put("method","updateProject");
        fin.put("iProject2Update",project);
        //project.put("V_Name",newTitle); // new title
        Map  res = client.serviceCall(fin);
        resultat = ((Integer)res.get("resultat")).intValue();
       
        /*Remove Security Contexts*/
        removeSelect = emxGetParameter(request,"removeSelect");
        if( (removeSelect!=null) && (!removeSelect.equals(""))){
            String[] ProjContext = removeSelect.split(",,");

            // JIC 2013:03:08 IR-222350V6R2014: Set application to "VPLM"
            // JIC 2013:03:26 IR-222350V6R2014: Added test for null application
            if (context.getApplication() == null || context.getApplication().equals(""))
                context.setApplication("VPLM");
            // JIC 2013:03:26 IR-222350V6R2014: Changed initial index from 1 to 0
            for (int i = 1 ; i < ProjContext.length ; i++){
                String ctx="";
						// RBR2: FUN[080973]: It will happen in update: Hence name will be there.
                        String [] PersConcProj = ProjContext[i].split(";");

                        String namePeople = PersConcProj[0].replaceAll(",", " ");
                        String nameRole =   PersConcProj[1].replaceAll(",", " ");
                        String nameContext = nameRole+"."+currentOrga+"."+name;
                        StringList Cont = new StringList();
                        Cont.addElement(nameContext);
                        Person per = Person.getPerson(context, namePeople);
                        SecurityContext.removeSecurityContexts(context, per,Cont );
                    }
                    }
        }else{
           /*Create  the project*/
           fin.put("method","createProject");
           fin.put("iProjectInfo",project);
           if (auto.equals("true"))  {
           	fin.put("auto","true");
           } 
           ret = client.serviceCall(fin);
           resultat = ((Integer)ret.get("resultat")).intValue();
        }

        /*If the project was created/updated successfully, Create the contexts and assign people*/
        if ( (resultat==0) && !(Assignment.equals("") ) ){
        		//RBR2: FUN[080973] We need name to perform further ops even in Autoname scenario
        	 	name   = (name != null && !name.equals("")) ? name : (String)((Map)fin.get("iProjectInfo")).get("PLM_ExternalID");     	
             	String[] PersContext = Assignment.split(",,");
               for (int i = 1 ; i <PersContext.length ; i++){ 
                   String roleName = PersContext[i].substring(PersContext[i].indexOf(";")+1,PersContext[i].length()).replaceAll(",", " ");
                   String contextName = roleName+"."+currentOrga+"."+name;
                   
                   String[] memberList = new String[1];
                   memberList[0]=PersContext[i].substring(0,PersContext[i].indexOf(";")).replaceAll(",", " ");
                 
					contx = new HashMap();
                    role = new HashMap();
                    organization = new HashMap();
                    prject = new HashMap();

                    contx.put("PLM_ExternalID",contextName);
                    contx.put("members",memberList);
                    role.put("PLM_ExternalID",roleName);
                    organization.put("PLM_ExternalID",currentOrga);
                    prject.put("PLM_ExternalID",name);

                    fin = new HashMap();
					fin.put("method","createContext");
					fin.put("iContextInfo",contx);
                    fin.put("iOrganizationInfo",organization);
                    fin.put("iProjectInfo",prject);
                    fin.put("iRoleInfo",role);
                
                    ret = new HashMap();
                    ret = client.serviceCall(fin);
                    
                /*if the context was created*/
                if( ((Integer)ret.get("resultat")).intValue() == 0){
                    nbCtxCreated=nbCtxCreated+1;
                    /* if the context already exist, assign people*/
                }else if(((Integer)ret.get("resultat")).intValue() == 7){
		            // JIC 2013:03:08 IR-222350V6R2014: Set application to "VPLM"
                    // JIC 2013:03:26 IR-222350V6R2014: Added test for null application
            		if (context.getApplication() == null || context.getApplication().equals(""))
                	    context.setApplication("VPLM");
                	for(int k = 0 ; k < memberList.length; k++){
                        StringList Cont = new StringList();
                        Cont.addElement(contextName);
                        Person per = Person.getPerson(context, memberList[k]);
                        if ( SecurityContext.getSecurityContexts(context, per, contextName, null, null).size()==0 ){
                            SecurityContext.addSecurityContexts(context, per,Cont );
                            nbCtxCreated=nbCtxCreated+1;

                        }
                    }
                }
            }

            if (roles.size() > 0){
                String rolesUnique = (String)roles.get(0);

                String[] ctext = rolesUnique.split(",");
                String ctx="";
                for (int k = 0 ; k< ctext.length-1 ; k++){
                     ctx = ctx + ctext[k] + " ";
                }
                ctx = ctx + ctext[ctext.length-1];

                role = new HashMap();
                organization = new HashMap();
                prject = new HashMap();

                String contextName = ctx+"."+currentOrga+"."+name;

                contx.put("PLM_ExternalID",contextName);
                role.put("PLM_ExternalID",ctx);
                organization.put("PLM_ExternalID",currentOrga);
                prject.put("PLM_ExternalID",name);
                String[] memberArray = new String[members.size()];

                for (int k = 0 ; k <members.size(); k++){
                    String mem = (String)members.get(k);
                     String [] memTab = mem.split(",");
                    if (memTab.length > 1 ){
                    mem = "";
                     for (int j = 0 ; j< memTab.length-1 ; j++){
                     mem = mem + memTab[j] + " ";
                     }
                 mem = mem + memTab[memTab.length-1];
                 }
                     memberArray[k]= mem;
                }

                nbCtxToCreate=nbCtxToCreate+1;

                contx.put("members",memberArray);

                fin = new HashMap();
				fin.put("method","createContext");
				fin.put("iContextInfo",contx);
                fin.put("iOrganizationInfo",organization);
                fin.put("iProjectInfo",prject);
                fin.put("iRoleInfo",role);


                ret = new HashMap();
                ret = client.serviceCall(fin);

                if( ((Integer)ret.get("resultat")).intValue() == 0){
                    nbCtxCreated=nbCtxCreated+1;
                } else if(((Integer)ret.get("resultat")).intValue() == 7){
		            // JIC 2013:03:08 IR-222350V6R2014: Set application to "VPLM"
                    // JIC 2013:03:26 IR-222350V6R2014: Added test for null application
            		if (context.getApplication() == null || context.getApplication().equals(""))
                	    context.setApplication("VPLM");
                    for(int k = 0 ; k < memberArray.length; k++){
                        StringList Cont = new StringList();
                        Cont.addElement(contextName);
                        Person per = Person.getPerson(context, memberArray[k]);
                        if ( SecurityContext.getSecurityContexts(context, per, contextName, null, null).size()==0 ){
                            SecurityContext.addSecurityContexts(context, per,Cont );
                            nbCtxCreated=nbCtxCreated+1;
                        }
                    }
                }

            }
            

            if(nbCtxCreated==nbCtxToCreate){
                if (source.equals("XPUpdateProject")){
                    resultat = 0;
                }else{
                    resultat = 4;
                }
           }else{
                if (source.equals("XPUpdateProject")){
                   resultat = 0;
                }else{
                     resultat = 4;
                }
          }
          }else if ((resultat==0) && (Assignment.equals("") )){
                if (source.equals("XPUpdateProject")){
                    resultat = 0;
                }else{
                    resultat = 4;
                }
          }
		  
		String newName = emxGetParameter(request,"NewPrjV_Name"); // String newTitle = emxGetParameter(request,"NewPrjV_Name");
		if( (newName!=null) && (!newName.equals(""))) {
				try{
				manageContextTransaction(mainContext,"start");
				Project projectBO = Project.getProject(mainContext,name);
				projectBO.setAttributeValue(mainContext,"Title", newName); // RBR2: Set title instead
	        	//projectBO.setName(mainContext, newName);
				//RBR2: FUN[080973] No need to perform the reset role
                /*if(mainContext.getRole().endsWith("."+name)) {
                    Context trueContext = Framework.getMainContext(session);
                    trueContext.resetRole(mainContext.getRole().replace(name,newName));
                    mainContext = Framework.getFrameContext(session);
                }*/
               	manageContextTransaction(mainContext,"end");
				}catch(Exception e){
				resultat = 3;
				manageContextTransaction(mainContext,"abort");
               	}
		}
       
    responseCreateProject = responseCreateProject+resultat+"</createResult></root>";
    response.getWriter().write(responseCreateProject);
%>
