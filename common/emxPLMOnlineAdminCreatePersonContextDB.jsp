<%  response.setContentType("text/xml");
    response.setContentType("charset=UTF-8");
    response.setHeader("Content-Type", "text/xml");
    response.setHeader("Cache-Control", "no-cache");
    response.getWriter().write("<?xml version='1.0' encoding='UTF-8'?>");
%>
<%@ page import="java.util.Map"  %>
<%@ page import="java.util.HashMap"  %>
<%@ page import="com.dassault_systemes.vplmsecurity.PLMSecurityManager" %>
<%@ page import="com.matrixone.vplm.posws.stubsaccess.ClientWithoutWS"  %>
<%@ page import="com.matrixone.vplm.posmodel.VPLMRole"  %>
<%@ page import="com.matrixone.vplm.posmodel.license.LicenseInfo" %>
<%@ page import="com.matrixone.vplm.posmodel.VPLMAdminUtil" %>
<%@ page import="com.matrixone.vplm.posmodel.license.LicenseUserAssignment" %>
<%@ page import="com.dassault_systemes.vplmposadministrationui.uiutil.AdminUtilities" %>
<%@include file = "emxPLMOnlineAdminAttributesCalculation.jsp"%>
<%@include file = "../common/emxNavigatorNoDocTypeInclude.inc"%>
<%@include file = "../common/emxPLMOnlineAdminAuthorize.jsp"%>
<%
    String  responseCreatePerson = "<root><createResult>";
    String HostCompanyName= getHostCompanyName(mainContext);
    String source = emxGetParameter(request,"source");
    String Assignment = emxGetParameter(request,"Assignment");
    String Active = emxGetParameter(request,"Active");
    // JIC 2014:10:21 Added contractor support
    String Contractor = emxGetParameter(request,"Contractor");
    String Admin = emxGetParameter(request,"VPLMAdmin");
    String sPersonID = emxGetParameter(request,"PLM_ExternalID");
    String Licences = emxGetParameter(request,"Licences");
    String employeeOf = emxGetParameter(request,"employeeOrg");
    String secCtxOrg = emxGetParameter(request,"secCtxOrg");
    String memberOf = emxGetParameter(request,"memberOrg");
    // JIC 2015:04:01 Added Casual Hour support
    String CasualHour = emxGetParameter(request,"CasualHour");


    StringList ctxCreated = new StringList();
    String message ="";
    // JIC 18:07:03 FUN076129: Removed use of PLM key/added context
    ClientWithoutWS client = new ClientWithoutWS(mainContext);

    Map requestMap = new HashMap();
	requestMap.put("method","createPerson");
    requestMap.put("PLM_ExternalID",sPersonID);
    requestMap.put("v_first_name",emxGetParameter(request,"V_first_name"));
    requestMap.put("v_last_name",emxGetParameter(request,"V_last_name"));
    requestMap.put("street",emxGetParameter(request,"Street"));
    requestMap.put("v_email",emxGetParameter(request,"V_email"));
    requestMap.put("v_phone",emxGetParameter(request,"V_phone"));
    requestMap.put("Work_Phone_Number",emxGetParameter(request,"Work_Phone_Number"));
    requestMap.put("city",emxGetParameter(request,"City"));
    requestMap.put("postalCode",emxGetParameter(request,"PostalCode"));
    requestMap.put("state",emxGetParameter(request,"State"));
    requestMap.put("v_distinguished_name",emxGetParameter(request,"V_distinguished_name"));
    requestMap.put("country",emxGetParameter(request,"Country"));
    requestMap.put("IsActive",Active);
    requestMap.put("Contractor",Contractor);
    if (CasualHour != null) {
        requestMap.put("CasualHour", CasualHour);
    }
    requestMap.put("list_Org",new String[]{memberOf});
    requestMap.put("org_id",employeeOf);

    if ( !(Assignment.equals("") ) ){
        String[] PersContext = Assignment.split(",,");

        for (int i = 0 ; i < PersContext.length ; i++){
            Map contextMap = new HashMap();
            Map roleMap = new HashMap();
            Map organizationMap = new HashMap();
            Map projectMap = new HashMap();

            if (PersContext[i].contains("!!")){
                String[] PersContextOne = PersContext[i].split("!!");
                String RoleName = PersContextOne[1].replaceAll(","," ");
                String ProjectName = PersContextOne[0].replaceAll(","," ");

                String contextName = RoleName+"."+secCtxOrg+"."+ProjectName;
                  
                contextMap.put("PLM_ExternalID",contextName);
                roleMap.put("PLM_ExternalID",RoleName);
                organizationMap.put("PLM_ExternalID",secCtxOrg);
                projectMap.put("PLM_ExternalID",ProjectName);

                Map fin= new HashMap();
				fin.put("method","createContext");
                fin.put("iContextInfo",contextMap);
                fin.put("iOrganizationInfo",organizationMap);
                fin.put("iProjectInfo",projectMap);
                fin.put("iRoleInfo",roleMap);

                Map result = client.serviceCall(fin);
                int resFinal =((Integer)result.get("resultat")).intValue();

                if( (resFinal == 0) || (resFinal == 7)){
                    ctxCreated.addElement(contextName);
                }
            }
        }
    }

    String[] ctx4Pers = new String[0];
    if (!Admin.equals("false")){
        ctx4Pers = new String[ctxCreated.size()+1];
    }else{
        ctx4Pers = new String[ctxCreated.size()];
    }
    for (int j = 0 ; j < ctxCreated.size() ; j ++){
        ctx4Pers[j] =  (String)ctxCreated.get(j);
    }
    if (!Admin.equals("false")){
        ctx4Pers[ctxCreated.size()]="VPLMAdmin."+HostCompanyName+".Default";
    }
    requestMap.put("ctx_id",ctx4Pers);
    

   Map  num = client.serviceCall(requestMap);
    int resultat = ((Integer)num.get("resultat")).intValue();
    //int resultat = 0;
    if (resultat == 0){
      // person license assignment service
        try{
            LicenseUserAssignment lua = new LicenseUserAssignment(sPersonID);
            // retrieve licenses list from request parameters
            if(Licences != null){
               
                String sParamValue[] = Licences.split(",,");
                for (int a = 0 ; a < sParamValue.length ; a++){
                    if(sParamValue[a].contains("!!")){
                    	String sParamValueOneByOne[] =  sParamValue[a].split("!!");
                        // JIC 15:04:02 Removed Casual-specific code (both Full and Casual licenses are now managed by class LicenseUserAssignment)
                        lua.addLicenseParameterIfValid(sParamValueOneByOne[0],sParamValueOneByOne[1]);
                    }
                }
            }
            // person licenses assignments modifications (add/remove)
            lua.update(context,myNLS);
       }catch(Exception e){
           e.printStackTrace();
       }

       // JIC 2013:05:29 IR IR-235946V6R2013x: Refactored code so as to only execute a single MQL command
       // JIC 2014:03:27 IR IR-280881-3DEXPERIENCER2014x: Removed assignement to role "Exchange User"
       String assignString1 = "";
       MapList roles = VPLMRole.getRoles(context, "Msoffice User", null, "");
       if (roles.size() > 0){
           // JIC 2013:05:29 IR IR-235946V6R2013x: Added push/pop context in case current user is not granted business Matrix privileges
           PLMSecurityManager securityManager = new PLMSecurityManager(mainContext);
           securityManager.pushUserAgentContext();

           // JIC 2013:05:29 IR IR-235946V6R2013x: Changed Context object to mainContext
           MqlUtil.mqlCommand(mainContext, "mod person $1 assign role $2",sPersonID,"Msoffice User");

           securityManager.popUserAgentContext();
       }
    }
    responseCreatePerson = responseCreatePerson+resultat+"</createResult></root>";
    response.getWriter().write(responseCreatePerson);
%>


