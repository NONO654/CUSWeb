<%-- 
    Document   : emxPLMOnlineAdminAttributesCalculation
    Created on : Oct 26, 2010, 11:23:12 AM
    Author     : LXM
--%>
<%@ page import="com.dassault_systemes.vplmadmin.InstallConfig"%>
<%@ page import="com.dassault_systemes.vplmadmin.InstallConfigManager"%>
<%@ page import="java.util.regex.Matcher"%>
<%@ page import="java.util.regex.Pattern"%>
<%@ page import="com.matrixone.apps.common.Company" %>
<%@ page import = "matrix.db.*, matrix.util.*,
				   com.matrixone.util.*,
				   com.matrixone.servlet.*,
				   com.matrixone.apps.framework.ui.*,
				   com.matrixone.apps.domain.util.*,
				   com.matrixone.apps.domain.*,
				   java.util.*,
				   java.io.*,
				   java.net.URLEncoder,
				   java.util.*,
				   com.matrixone.jsystem.util.*"
				   %>
<%@include file= "../common/emxPLMOnlineAdminIncludeNLS.jsp"%>
<%@include file = "../emxTagLibInclude.inc"%>
<%@ page import="com.dassault_systemes.vplmposadministrationui.uiutil.*" %>

<%   /*Initialise the NLS catalogue*/
        initNLSCatalog("myMenu",request);
        PreferencesUtil prefUtil = new PreferencesUtil();
        Context mainContext = Framework.getFrameContext(session);
        mainContext.setApplication("VPLM");
        String UserRole = mainContext.getRole();
        NLSCatalog myNLS  = getNLSCatalog();
        session.setAttribute("NLS",myNLS);
        StringBuffer URLPath = request.getRequestURL();
        String LimitBySlash[] = (String[])URLPath.toString().split("://");
        String protocol = LimitBySlash[0];
        String iKey = (String)session.getAttribute("PLMKey");
        String iEndpoint = request.getServerName();
        int iPort = request.getServerPort();
        String iUrlPath = request.getContextPath();
		//ServiceKey sk = new ServiceKey(iKey);
		//sk.setRequest(request);

%>
<%!
    public String switchSolution(Context ctx,String iUser,String iSolution){
        PreferencesUtil prefUtil = new PreferencesUtil();
        prefUtil.setUserPreferredUISolution(ctx,iUser,iSolution);
        System.out.println(prefUtil.getUserPreferredUISolution(ctx));
        return "";
    }

	public String getAdminKey(Context ctx){
		try{
			String result = MqlUtil.mqlCommand(ctx,"print role $1 select $2;","Service Administrator","property[Admin Key].value");
			String[] resFinal = result.split("= ");
			if (resFinal.length == 1){
	        	System.out.println("Administration Key was not found !");
	        }else{
	        	return resFinal[1];
	        }   
		}catch(Exception e){
			return "";
		}
		return "";
	
	}


	
	public boolean isPLMExpress(Context ctx){
		 try{
			 String result = MqlUtil.mqlCommand(ctx,"list command $1;","APPVPLMAdministration");
		     if (result.length() == 0){return true; }
		 }catch (Exception e){
			 return false;
		 }
		 return false;
	}

      public boolean stringMatch(String iText,String iFilter){
        StringTokenizer st = new StringTokenizer(iFilter, "*");
        String filter = "";

        while (st.hasMoreTokens()) {
            filter = filter  +st.nextToken()+"(.)*";
        }
        if(iFilter.startsWith("*")){filter = "(.)*"+filter;}else{filter = "^"+filter;}
        if(!iFilter.substring(iFilter.length()-1,iFilter.length()).equals("*")){
            filter = filter.substring(0,filter.length()-4);
            filter = filter + "$";
        }

        
        Pattern p = 	Pattern.compile(filter);
        Matcher m = p.matcher(iText);
        boolean b = m.find();
        return b;
    }




   public String getHostCompanyName(Context ctx){
        try{
            String HostCompanyID = Company.getHostCompany(ctx);
            Company HostCompany= new Company(HostCompanyID);
            HostCompany.open(ctx);
            String HostCompanyName= HostCompany.getName();
            return HostCompanyName;
        }catch(Exception e){
            e.printStackTrace();
            return "";
        }
    }

    public String getNLSMessageWithParameter(String MessageToSend, String firstParameter){
            String TabInteger[] = new String[1];
            TabInteger[0]=myNLS.getMessage(firstParameter);
            String ERR_Message = myNLS.getMessage(MessageToSend,TabInteger);
            return ERR_Message;
   }

   public void manageContextTransaction(Context iContext,String iState){
        try{
            if(iState.equals("start")){
                if (!iContext.isTransactionActive())
                {
                    iContext.start(true);
                }
            }
            if(iState.equals("end")){
                if (iContext.isTransactionActive())
                {
                    iContext.commit();
                }
            }
            if(iState.equals("abort")){
                if (iContext.isTransactionActive())
                {
                    iContext.abort();
                }
            }
        }catch(Exception e){e.printStackTrace();}
    }

    public Map getAttributes(Context ctx ,String iType, String iSolution)
    {
        InstallConfigManager icm = new InstallConfigManager();
        InstallConfig ic = null;
        String mode="";
        
        if(iSolution.equals("")){
            try {
                ic = icm.getInstallConfig(ctx);
                mode = ic.getMode();
            }
            catch (Exception e) { }
       
            if (!mode.equals("SMB")){
                PreferencesUtil prefUtil = new PreferencesUtil();
                String Solution = prefUtil.getUserPreferredUISolution(ctx);

                if(Solution.equals("TEAM")){
                    mode = "SMB";
                }
            }
        }else{
            mode=iSolution;
        }
        if(iType.equals("Person")){
            return getPersonAttributes(mode);
        }
        if(iType.equals("Project")){
            return getProjectAttributes(mode);
        }
        if(iType.equals("Role")){
            return getRoleAttributes();
        }
        return null;

    }

     public Map getPersonAttributes(String iSolution){
            StringList listAttributesToSend = new StringList();
            Map listAttributeToSendWithNLS = new HashMap();

            listAttributesToSend.addElement("Active");
            listAttributesToSend.addElement("PLM_ExternalID");
            listAttributesToSend.addElement("v_email");
            listAttributesToSend.addElement("v_first_name");
            listAttributesToSend.addElement("v_last_name");
            listAttributesToSend.addElement("Address");
            listAttributesToSend.addElement("v_phone");
		listAttributesToSend.addElement("Work_Phone_Number");
            listAttributeToSendWithNLS.put("Active",getNLS("Active"));
            listAttributeToSendWithNLS.put("PLM_ExternalID",getNLS("UserID"));
            listAttributeToSendWithNLS.put("v_email",getNLS("Email"));
            listAttributeToSendWithNLS.put("v_first_name",getNLS("FirstName"));
            listAttributeToSendWithNLS.put("v_last_name",getNLS("LastName"));
            listAttributeToSendWithNLS.put("Address",getNLS("Address"));
		listAttributeToSendWithNLS.put("v_phone",getNLS("HomePhone"));
            listAttributeToSendWithNLS.put("Work_Phone_Number",getNLS("WorkPhone"));

            if(!iSolution.equals("SMB")){
                listAttributesToSend.addElement("Accreditation");
                listAttributesToSend.addElement("org_id");
                listAttributesToSend.addElement("list_Org");
                listAttributesToSend.addElement("ctx");
                listAttributesToSend.addElement("ctx_V_Name"); // RBR2: Added this. No need to push with NLS
                listAttributeToSendWithNLS.put("Accreditation",getNLS("Accreditation"));
                listAttributeToSendWithNLS.put("org_id",getNLS("Employee"));
                listAttributeToSendWithNLS.put("list_Org",getNLS("Member"));
                listAttributeToSendWithNLS.put("ctx",getNLS("SecurityContexts"));
            }
            listAttributeToSendWithNLS.put("ListAttributes",listAttributesToSend);
            return listAttributeToSendWithNLS;
     }

      public Map getProjectAttributes(String iSolution){
            StringList listAttributesToSend = new StringList();
            Map listAttributeToSendWithNLS = new HashMap();

            listAttributesToSend.addElement("V_Name"); // RBR2: Title of Project
            listAttributesToSend.addElement("PLM_ExternalID");
            listAttributesToSend.addElement("v_id");
            listAttributesToSend.addElement("Family");
            listAttributeToSendWithNLS.put("V_Name",getNLS("Title")); // RBR2: Push the Title NLS
            listAttributeToSendWithNLS.put("PLM_ExternalID",getNLS("Name"));
            listAttributeToSendWithNLS.put("v_id",getNLS("Description"));
            listAttributeToSendWithNLS.put("Family",getNLS("Family"));

            if(iSolution.equals("SMB")){
                 listAttributesToSend.addElement("Visibility");
                listAttributeToSendWithNLS.put("Visibility",getNLS("Visibility"));
            }

            if(!iSolution.equals("SMB")){
                listAttributesToSend.addElement("Accreditation");
                listAttributeToSendWithNLS.put("Accreditation",getNLS("Confidentiality"));
                listAttributesToSend.addElement("project_Parent");
              	//listAttributesToSend.addElement("parent_V_Name"); // RBR2: //Parent's V_Name
                listAttributeToSendWithNLS.put("project_Parent",getNLS("Parent"));
                listAttributesToSend.addElement("child");
                listAttributeToSendWithNLS.put("child",getNLS("Children"));
                //listAttributesToSend.addElement("child_V_Name"); // RBR2: Children's V_Name
            }
            
            listAttributeToSendWithNLS.put("ListAttributes",listAttributesToSend);
            return listAttributeToSendWithNLS;
     }


      public Map getRoleAttributes(){
            StringList listAttributesToSend = new StringList();
            Map listAttributeToSendWithNLS = new HashMap();

            listAttributesToSend.addElement("PLM_ExternalID");
            listAttributesToSend.addElement("V_id");
            listAttributesToSend.addElement("Role_Parent");
            listAttributesToSend.addElement("child");
            listAttributeToSendWithNLS.put("PLM_ExternalID",getNLS("Name"));
            listAttributeToSendWithNLS.put("V_id",getNLS("Description"));
            listAttributeToSendWithNLS.put("Role_Parent",getNLS("Parent"));
            listAttributeToSendWithNLS.put("child",getNLS("Child"));

            listAttributeToSendWithNLS.put("ListAttributes",listAttributesToSend);
            return listAttributeToSendWithNLS;
     }
%>
