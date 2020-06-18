<% response.setContentType("text/xml");
        response.setContentType("charset=UTF-8");
        response.setHeader("Content-Type", "text/xml");
        response.setHeader("Cache-Control", "no-cache");
        String responseCreateProject="<?xml version='1.0' encoding='UTF-8'?><root><updateResult>";
%>
<%@ page import="java.util.Map" %>
<%@ page import="java.io.*"%>
<%@ page import="com.matrixone.vplm.posws.stubsaccess.ClientWithoutWS"%>
<%@ page import="com.matrixone.vplm.posbusinessmodel.Project"%>
<%@ page import="com.dassault_systemes.pos.resource.interfaces.PLMxPosDisciplineServices" %>
<%@ page import="com.dassault_systemes.pos.resource.interfaces.IPLMxPosDiscipline" %>
<%@ page import="com.dassault_systemes.vplmposadministrationui.uiutil.AdminUtilities"%>
<%@include file = "../common/emxNavigatorNoDocTypeInclude.inc"%>
<%@include file = "emxPLMOnlineAdminAttributesCalculation.jsp"%>
<%@include file = "../emxTagLibInclude.inc"%>
<%@include file = "../common/emxPLMOnlineAdminAuthorize.jsp"%>

<%@ page import="java.util.*" %>
    <%
    
    String plm_externalId = emxGetParameter(request,"PLM_ExternalID");
	
    //RBR2: [FUN080973]
   	String v_name = emxGetParameter(request,"NewPrjV_Name"); // Can be empty or null
    String v_nameOld = emxGetParameter(request,"PrjV_Name");//PrjV_Name
    String ParentVName = emxGetParameter(request,"NewParentV_Name");
        
    String desc = emxGetParameter(request,"V_id");
    
    String secLevel = emxGetParameter(request,"secLevel");
    String Disc2Add = emxGetParameter(request,"Disc2Add");
    String Disc2Rem = emxGetParameter(request,"Disc2Rem");
    String Parent = emxGetParameter(request,"Parent");
  	
     if (plm_externalId == null) {plm_externalId="";}
     if (desc == null) {desc="";}
                                                                  
   
     if (secLevel == null) {secLevel="";}
     Map project = new HashMap();
     Map m = new HashMap();
     Map organization = new HashMap();
        
     project.put("v_id",desc);
     project.put("PLM_ExternalID",plm_externalId);
     
     boolean isTitleChanged = false;
     
     //RBR2: [FUN080973] Title of Prj 
     if(v_name == null || v_name.isEmpty()) {
    	// No edit button clicked
    	 project.put("V_Name",v_nameOld);
     }
     else if (!(v_name.equals(v_nameOld))){
    	// New Title
    	 project.put("V_Name",v_name);
    	 isTitleChanged = true;
     } else {
    	 // No change in title
    	 project.put("V_Name",v_nameOld);
     }
     
     project.put("Accreditation",secLevel);
     if (Parent.equals("None") && ParentVName.equals("None")){ // Check for both
     	// Have to remove any parent if exists
    	project.put("project_Parent","");
     	project.put("Project_Parent_V_Name","");
	 }    else{
    	project.put("project_Parent",Parent);
    	project.put("Project_Parent_V_Name",ParentVName);
	}                                                                 
   
    // RBR2: This update project must check:
    /*
    	1. Title in ProjectType Object is not NULL or EMPTY
    	2. No circular association parent and child [Already managed must operate on Name]
    	3. Name should not be changed
    
    */
    m.put("method","updateProject");
    m.put("iProject2Update",project);
    
    // JIC 18:07:03 FUN076129: Removed use of PLM key/added context
    ClientWithoutWS client = new ClientWithoutWS(mainContext);
    Map  res = client.serviceCall(m); // ProjectService.updateProject
    int resultat = ((Integer)res.get("resultat")).intValue();
	
    if(!Disc2Add.isEmpty()) {
    String[] tabOfDisc2Add = Disc2Add.split(",");
    StringList listOfDisc2Add = new StringList();
    for(int i=0; i <tabOfDisc2Add.length ; i++ ){
            listOfDisc2Add.addElement(tabOfDisc2Add[i]);
    }

     if(!mainContext.isTransactionActive())
                {
                    mainContext.start(true);
                }
    int result = PLMxPosDisciplineServices.addDisciplinesToProject(mainContext,plm_externalId ,listOfDisc2Add) ;

    if (result == 0 ){
        mainContext.commit();
    }else{
        mainContext.abort();
    }
	}
	
	if(!Disc2Rem.isEmpty()) {
    String[] tabOfDisc2Rem = Disc2Rem.split(",");
    StringList listOfDisc2Rem = new StringList();
     for(int j=0; j <tabOfDisc2Rem.length ; j++ ){
            listOfDisc2Rem.addElement(tabOfDisc2Rem[j]);
    }

    if(!mainContext.isTransactionActive())
                {
                    mainContext.start(true);
                }
    int result = PLMxPosDisciplineServices.removeDisciplinesFromProject(mainContext, plm_externalId, listOfDisc2Rem);
    if (result == 0 ){
        mainContext.commit();
    }else{
        mainContext.abort();
    }
	}

    String done = "true";
    String message = "";
%>
    <%if (resultat==0){
    			message=getNLSMessageWithParameter("CONF_HasBeenUpdated","Project");
    			// RBR2: String newPrJName = (String)emxGetParameter(request,"NewPrjName");
    			String newPrJName = (String)emxGetParameter(request,"NewPrjV_Name"); // New Title
			if (!(newPrJName.equals("")) || Parent.equals("None")){
				StringList objectsSelects = new StringList();
        	   		objectsSelects.addElement("name");
               		objectsSelects.addElement("id");
               		objectsSelects.addElement("attribute[Title].value"); // RBR2
                 
	                 /** Query to get the Specific project **/   
	                 MapList mapList = Project.getProjects(mainContext, (String)emxGetParameter(request,"PLM_ExternalID"), objectsSelects, "");    
	                 
	                 Map proj = (Map)mapList.get(0);
	               	 String iD = (String)proj.get("id");
	               	 String dbTitle = (String)proj.get("attribute[Title].value");
	               	 /** Getting Organization bus **/
	               	Project project1 = new Project(iD);
	               	project1.open(mainContext);

					if(Parent.equals("None")){
						try{
						manageContextTransaction(mainContext,"start");
						Project parentPRJ =  project1.getParentProject(mainContext);
		                if(parentPRJ != null) {
							StringList childPRJ = new StringList();
							childPRJ.addElement((String)emxGetParameter(request,"PLM_ExternalID"));
		                    parentPRJ.removeChildProjects(mainContext, childPRJ); // RBR2: Remove that Parent
		                }
						manageContextTransaction(mainContext,"end");
						}catch(Exception e){
		               		done="false";
		               		message = "Error while removing parent project";
							manageContextTransaction(mainContext,"abort");
		               	}
		            }
			
		    		if (!done.equals("false") && !newPrJName.equals("") && 
		    				isTitleChanged && !(dbTitle.equals(newPrJName))){	// RBR2: Modify attribute title only when required    
						try{
							// Renaming the Project
						manageContextTransaction(mainContext,"start");
			        	// RBR2: project1.setName(mainContext, (String)emxGetParameter(request,"NewPrjName"));
						project1.setAttributeValue(mainContext,"Title", newPrJName); // RBR2: Set title instead
		                if(mainContext.getRole().endsWith("."+((String)emxGetParameter(request,"PLM_ExternalID")))) {
		                    /*
		                    RBR2: FUN[080973] No need to perform the reset role
		                    As name wont change
		                    Context trueContext = Framework.getMainContext(session);
		                    trueContext.resetRole(mainContext.getRole().replace((String)emxGetParameter(request,"PLM_ExternalID"),(String)emxGetParameter(request,"NewPrjName")));
		                    mainContext = Framework.getFrameContext(session);
		                    */
		                }
		               	manageContextTransaction(mainContext,"end");
						}catch(Exception e){
							done="false";
		               		message = "Error while renaming project";
						manageContextTransaction(mainContext,"abort");
		               	}
		            }

			}
	}
    responseCreateProject = responseCreateProject+message+"<Done>"+done+"</Done></updateResult></root>";
    response.getWriter().write(responseCreateProject);
%>
          
 
