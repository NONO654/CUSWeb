<% response.setContentType("text/xml");
        response.setContentType("charset=UTF-8");
        response.setHeader("Content-Type", "text/xml");
        response.setHeader("Cache-Control", "no-cache");
        String responseCreateProject="<?xml version='1.0' encoding='UTF-8'?><root><createResult>";
%>
<%@ page import="java.util.Map"  %>
<%@ page import="java.util.HashMap"  %>
<%@ page import="com.matrixone.vplm.posws.stubsaccess.ClientWithoutWS"  %>
<%@include file = "../common/emxNavigatorNoDocTypeInclude.inc"%>
<%@ page import="com.dassault_systemes.pos.resource.interfaces.PLMxPosDisciplineServices" %>
<%@ page import="com.dassault_systemes.vplmposadministrationui.uiutil.EncodeUtil" %>
<%@ page import="com.dassault_systemes.vplmposadministrationui.uiutil.AdminUtilities"%>
<%@include file = "emxPLMOnlineAdminAttributesCalculation.jsp"%>
<%@include file = "../common/emxPLMOnlineAdminAuthorize.jsp"%>

    <%
        String name = emxGetParameter(request,"project");
  		//SSI21 : FUN[080973]Title project chnages
    	String title = emxGetParameter(request,"projectTitle");
    	String autoName = emxGetParameter(request,"autoName");
        String parent = emxGetParameter(request,"parent");
        String desc = emxGetParameter(request,"V_id");
        String Family = emxGetParameter(request,"Family");
        String secLevel = emxGetParameter(request,"secLevel");
        String discsone = emxGetParameter(request,"disciplines");

        Map project = new HashMap();
        
        String[] discs = discsone.split(",");
        if (discs == null)discs=new String[0];
      	//SSI21 : Title project chnages
        if (autoName.equals("true"))  {
        	name = null; // NULL name : Meant autoname
        	// if shivam's autoname working then push it here.
        } 
        
        if (parent == null || parent.equals("")) {
            parent="";
            project.put("Solution","VPM");
        }
        if (desc == null) {desc="";}
  	if (secLevel == null) {secLevel="";}
        
        Map project1 = new HashMap();
        
        project.put("v_id",desc);
        project.put("PLM_ExternalID",name);
        project.put("V_Name", title);			//SSI21 : Title project chnages
        project.put("Accreditation",secLevel);
        if ( (Family != null)){
        	project.put("Family",Family);
       	}
        
       project1.put("PLM_ExternalID",parent);

       Map fin = new HashMap();
	   fin.put("method","createProject");
	   fin.put("iProjectInfo",project);
       fin.put("iProjectParent",project1);
       // RBR2: FUN[080973]
       if (autoName.equals("true")){
       		fin.put("auto","true");
       }  
       
       // JIC 18:07:03 FUN076129: Removed use of PLM key/added context
       ClientWithoutWS client = new ClientWithoutWS(mainContext);
       Map ret = client.serviceCall(fin);
       int resultat = ((Integer)ret.get("resultat")).intValue();
       String message="";
       Boolean color=false;


       switch (resultat){
           case 0 :
               int resultatAssignDisciplines = 0;
                if ( (discs.length == 1) && (discs[0]=="") ){resultatAssignDisciplines= 0;
               }else {if( (discs.length > 0)   ){

                 StringList disciplinesList = new StringList();
                for (int i = 0 ; i < discs.length ; i++){
                    if (!(discs[i].equals(""))){
                     disciplinesList.addElement(discs[i]);
                    }
                }
                Context ctx = Framework.getFrameContext(session);
				if (null == ctx.getApplication())ctx.setApplication("VPLM");
                if (!ctx.isTransactionActive())
                {ctx.start(true);
                }        
                 resultatAssignDisciplines = PLMxPosDisciplineServices.addDisciplinesToProject(ctx,name,disciplinesList);
                if (ctx.isTransactionActive())
                {ctx.commit();
                }}}
          
           
            switch (resultatAssignDisciplines){
                case 0 :
                String TabInteger[] = new String[1];
                TabInteger[0]= emxGetParameter(request,"projectTitle"); //RBR2: Show Title emxGetParameter(request,"project");
                message = myNLS.getMessage("CONF_HasBeenCreated",TabInteger);
                 break;
             default :
                  String TabInteger1[] = new String[1];
                TabInteger1[0]= emxGetParameter(request,"projectTitle"); //RBR2: Show Title emxGetParameter(request,"project");
                message = myNLS.getMessage("CONF_HasBeenCreated",TabInteger1);

                color=true;
                break;

        }
                break;
         case 1 :
              message = getNLS("ERR_CreationRight");
               color=false;
              break;
          case 2 :
               message = getNLSMessageWithParameter("ERR_IDCannotBeEmpty", "ProjectName");
              break;
          case 3 :
              message = getNLSMessageWithParameter("ERR_IDAlreadyExist", "ProjectOrOrganization");
              break;
          case 4 :
        	  message = getNLSMessageWithParameter("ERR_IDCannotBeEmpty", "ProjectTitle");   		//SSI21 : Title project chnages
        	  break;
    	  default :
               message = "Error while creating project"; // RBR2: USe NLS --> SSI21
               color=false;
              }
    responseCreateProject = responseCreateProject+message+"</createResult>></root>";
    response.getWriter().write(responseCreateProject);
%>

