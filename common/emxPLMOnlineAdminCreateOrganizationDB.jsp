<%@include file = "../common/emxNavigatorNoDocTypeInclude.inc"%>
<%@ page import="com.matrixone.vplm.posws.stubsaccess.ClientWithoutWS"%>
<%@ page import="com.dassault_systemes.vplmposadministrationui.uiutil.EncodeUtil" %>
<%@include file = "../common/emxPLMOnlineAdminAttributesCalculation.jsp"%>
<%@include file = "../common/emxPLMOnlineAdminAuthorize.jsp"%>
<%
   response.setContentType("text/xml");
   response.setContentType("charset=UTF-8");
   response.setHeader("Content-Type", "text/xml");
   response.setHeader("Cache-Control", "no-cache");
   String responseCreateOrganization="<?xml version='1.0' encoding='iso-8859-1'?><root><createResult>";
        Map m=new HashMap();  

        Map organization = new HashMap();
        Map parent = new HashMap();
        String v_name = emxGetParameter(request,"v_name");

		if ( (null == v_name) || (v_name.equals(""))) v_name=emxGetParameter(request,"PLM_ExternalID");
        organization.put("v_name",v_name);
        organization.put("org_Type",emxGetParameter(request,"org_Type"));
        organization.put("PLM_ExternalID",emxGetParameter(request,"PLM_ExternalID"));
        organization.put("street",emxGetParameter(request,"Street"));
        organization.put("city",emxGetParameter(request,"City"));
        organization.put("state",emxGetParameter(request,"State"));
        organization.put("postalCode",emxGetParameter(request,"PostalCode"));
        organization.put("country",emxGetParameter(request,"Country"));
        
        
        String Org_Parent = emxGetParameter(request,"Org_Parent");

        if(null==Org_Parent) Org_Parent="";
        parent.put("v_name",Org_Parent);
        parent.put("PLM_ExternalID",Org_Parent);   
               
        m.put("method","createOrg");
        m.put("iOrgInfo",organization);
        m.put("iParent",parent);
        
        // JIC 18:07:03 FUN076129: Removed use of PLM key/added context
        ClientWithoutWS client = new ClientWithoutWS(mainContext);
        Map  res = client.serviceCall(m);
        int resultat = ((Integer)res.get("resultat")).intValue();

        String message = "";
        switch (resultat){
            case 0 :
                String tab[] = new String[1];
                tab[0] = EncodeUtil.escape(emxGetParameter(request,"PLM_ExternalID"));
                message = myNLS.getMessage("CONF_HasBeenCreated", tab);
                break;
             case 1 :
                message = myNLS.getMessage("ERR_CreationRight");
                break;
            case 2 :
                String Emptytab[] = new String[1];
                Emptytab[0] =  myNLS.getMessage("OrganizationName");
                message = myNLS.getMessage("ERR_IDCannotBeEmpty", Emptytab);
                 break;
            case 3 :
                message = "Incompatible type between the organization and its parent";
                break;
            case 4 :
                String Existtab[] = new String[1];
                Existtab[0] =  myNLS.getMessage("OrganizationName");
                message = myNLS.getMessage("ERR_IDAlreadyExist", Existtab);
             break;
            case 5 :
                 String Existtab1[] = new String[1];
                Existtab1[0] =  myNLS.getMessage("OrganizationName");
                message = myNLS.getMessage("ERR_IDAlreadyExist", Existtab1);
            break;
            case 7 :
               message = "Incompatible type between the organization and her parent";
                break;
            default :
                message = "Organization could not be created";
                break;
        }

    responseCreateOrganization = responseCreateOrganization+message+"</createResult></root>";
    response.getWriter().write(responseCreateOrganization);
   %>
