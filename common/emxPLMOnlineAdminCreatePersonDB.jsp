<%@include file = "../common/emxNavigatorNoDocTypeInclude.inc"%>
<%@ page import="com.matrixone.vplm.posws.stubsaccess.ClientWithoutWS"%>
<%@ page import="com.matrixone.vplm.posmodel.license.LicenseUserAssignment" %>
<%@ page import="com.dassault_systemes.vplmposadministrationui.uiutil.AdminUtilities" %>
<%@include file = "../common/emxPLMOnlineAdminAttributesCalculation.jsp"%>
<%@include file = "../common/emxPLMOnlineAdminAuthorize.jsp"%>
<%
    response.setContentType("text/xml");
   response.setContentType("charset=UTF-8");
   response.setHeader("Content-Type", "text/xml");
   response.setHeader("Cache-Control", "no-cache");
    String responseCreatePerson="<?xml version='1.0' encoding='UTF-8'?><root><createResult>";
    

    String[] listOrg = emxGetParameter(request,"List_Org").split(",");
    String[] secCtx = emxGetParameter(request,"ctx_id").split(",");
    String Active = emxGetParameter(request,"Activated");
    // JIC 2014:10:24 Added Contractor support
    String Contractor = emxGetParameter(request,"Contractor");
   

    Map m= new HashMap();
	m.put("method","createPerson");
	
	m.put("PLM_ExternalID",emxGetParameter(request,"PLM_ExternalID"));
    m.put("IsActive",Active);
    // JIC 2014:10:24 Added Contractor support
    m.put("Contractor",Contractor);
    m.put("v_first_name",emxGetParameter(request,"V_first_name"));
    m.put("v_last_name",emxGetParameter(request,"V_last_name"));
    m.put("street",emxGetParameter(request,"Street"));
    m.put("v_email",emxGetParameter(request,"V_email"));
    m.put("v_distinguished_name",emxGetParameter(request,"V_distinguished_name"));
    m.put("v_phone",emxGetParameter(request,"V_phone"));
	m.put("Work_Phone_Number",emxGetParameter(request,"Work_Phone_Number"));
    m.put("city",emxGetParameter(request,"City"));
    m.put("postalCode",emxGetParameter(request,"postalCode"));
    m.put("state",emxGetParameter(request,"State"));
    m.put("country",emxGetParameter(request,"Country"));
    m.put("ctx_id",secCtx);
    m.put("list_Org",listOrg);
    m.put("org_id",emxGetParameter(request,"org_id"));
    m.put("Accreditation",emxGetParameter(request,"secLevel"));
    // JIC 2015:04:01 Added Casual Hour support
    if (emxGetParameter(request,"CasualHour") != null) {
        m.put("CasualHour", emxGetParameter(request,"CasualHour"));
    }

    // JIC 18:07:03 FUN076129: Removed use of PLM key/added context
    ClientWithoutWS client = new ClientWithoutWS(mainContext);
    Map  num = client.serviceCall(m);
    int resultat = ((Integer)num.get("resultat")).intValue();

        String licences = emxGetParameter(request,"licences");
        String[] licencesTable = licences.split(",,");
        try{
            LicenseUserAssignment lua = new LicenseUserAssignment(emxGetParameter(request,"PLM_ExternalID"));
			if (!licences.equals("")){
                    // retrieve licenses list from request parameters
                for ( int l = 0 ; l < licencesTable.length ; l++ ) {
                    String value = licencesTable[l];
                    String val = value.substring(4,value.length()-4);
                   lua.addLicenseParameterIfValid(value,val);
                }
			} else {
				lua.addLicenseParameterIfValid("","");
           }
                // person licenses assignments modifications (add/remove)
                lua.update(mainContext,myNLS);
        }catch(Exception e){
            e.printStackTrace();
        }
	
 
    String message = "";
    switch (resultat){
            case 0 :
                message = getNLS("YourPersonHasBeenCreated");
                break;
             case 1 :
                message = getNLSMessageWithParameter("ERR_CreationRight","UserID");
                break;
            case 2 :
                message = getNLSMessageWithParameter("ERR_IDCannotBeEmpty","UserID");
                break;
            case 4 :
                 message =getNLSMessageWithParameter("ERR_IDAlreadyExist","PersonID");
                break;
           case 12 :
                message =getNLSMessageWithParameter("ERR_IDAlreadyExist","UserAlias");
                break;
		default :
                message ="Couldn't create User";
                break;
     }
    
    responseCreatePerson = responseCreatePerson+message+"</createResult></root>";
    response.getWriter().write(responseCreatePerson);
%>
