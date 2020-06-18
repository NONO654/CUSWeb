<% response.setContentType("text/xml");
        response.setContentType("charset=UTF-8");
        response.setHeader("Content-Type", "text/xml");
        response.setHeader("Cache-Control", "no-cache");
        String responseCreateProject="<?xml version='1.0' encoding='UTF-8'?><root><updateResult>";
%>
<%@include file = "../common/emxNavigatorNoDocTypeInclude.inc"%>
<%@ page import="java.util.*" %>
<%@ page import="java.lang.Integer" %>
<%@ page import="com.matrixone.vplm.posws.stubsaccess.ClientWithoutWS"%>
<%@include file = "emxPLMOnlineAdminAttributesCalculation.jsp"%>
<%@include file = "../common/emxPLMOnlineAdminAuthorize.jsp"%>
<%@ page import="com.matrixone.apps.common.Organization"%>
<%
    Map project = new HashMap();
    boolean resetParent = false;
    Map organization = new HashMap();
    Map organizationParent = new HashMap();
    String orgUpdate = getNLS("organizationHaveBeenUpdated");
            
    
    
    String parent = (String)emxGetParameter(request,"Org_Parent");
    if(parent==null) parent = (String)emxGetParameter(request,"OrgParent");
    if (parent==null) parent ="";
    if( (parent.equals("None")) ){
        resetParent = true;
        parent="";
    }
    String resp = "";
    if(resp==null) resp = "";
        
    organization.put("org_Parent",parent);
    organization.put("PLM_ExternalID",emxGetParameter(request,"PLM_ExternalID"));
    organization.put("street",emxGetParameter(request,"Street"));
    organization.put("city",emxGetParameter(request,"City"));
    organization.put("state",emxGetParameter(request,"State"));
    organization.put("postalCode",emxGetParameter(request,"postalCode"));
    organization.put("country",emxGetParameter(request,"Country"));
    organization.put("v_name",emxGetParameter(request,"OrgV_Name"));
        
    organizationParent.put("PLM_ExternalID",parent);
    Map requestMap = new HashMap();
	requestMap.put("method","updateOrg");
	requestMap.put("iOrgInfo",organization);
    requestMap.put("iParent",organizationParent);
    
    // JIC 18:07:03 FUN076129: Removed use of PLM key/added context
    ClientWithoutWS client = new ClientWithoutWS(mainContext);
    Map resultMap = client.serviceCall(requestMap);
    int resultat = ((Integer)resultMap.get("resultat")).intValue();
    String message="";
    boolean done = true;
    switch (resultat){
           case 0 :
        	   String newOrgName = (String)emxGetParameter(request,"NewOrgName");
        	   if (!(newOrgName.equals(""))){
        		   StringList objectsSelects = new StringList();
        	   		objectsSelects.addElement("name");
               		objectsSelects.addElement("id");
        	   		MapList mapList = DomainObject.findObjects(mainContext, "Organization", (String)emxGetParameter(request,"PLM_ExternalID"), "*", "*", "*", "", true, objectsSelects);
               		Map orga = (Map)mapList.get(0);
               		String iD = (String)orga.get("id");
               
               		/** Getting Organization bus **/
               		Organization organization1 = new Organization(iD);
               		organization1.open(mainContext);
               		try{
                            organization1.setName(mainContext, (String)emxGetParameter(request,"NewOrgName"));
                            if(mainContext.getRole().contains("."+((String)emxGetParameter(request,"PLM_ExternalID"))+".")) {
                                Context trueContext = Framework.getMainContext(session);
                                trueContext.resetRole(mainContext.getRole().replace((String)emxGetParameter(request,"PLM_ExternalID"),(String)emxGetParameter(request,"NewOrgName")));
                                mainContext = Framework.getFrameContext(session);
                            }
               		}catch(Exception e){
				String Existtab[] = new String[1];
                		Existtab[0] =  myNLS.getMessage("OrganizationName");
                		message = myNLS.getMessage("ERR_IDAlreadyExist", Existtab);
               			
               			done = false;
               		}

        	   }


                   if(resetParent){
                        StringList objectsSelects = new StringList();
        	   	objectsSelects.addElement("name");
               		objectsSelects.addElement("id");

                        MapList mapList = null;
						if(newOrgName==null || newOrgName.equals("")) mapList = DomainObject.findObjects(mainContext, "Organization", (String)emxGetParameter(request,"PLM_ExternalID"), "*", "*", "*", "", true, objectsSelects);
						else mapList = DomainObject.findObjects(mainContext, "Organization", newOrgName, "*", "*", "*", "", true, objectsSelects);
               		Map orga = (Map)mapList.get(0);
					if(orga!=null) {
               		String iD = (String)orga.get("id");


               		/** Getting Organization bus **/
               		Organization organization1 = new Organization(iD);
               		organization1.open(mainContext);

                        StringList relationshipSelects = new StringList();
                        relationshipSelects.addElement(DomainObject.RELATIONSHIP_DIVISION);
                        relationshipSelects.addElement(DomainObject.RELATIONSHIP_COMPANY_DEPARTMENT);

                        Map mapParent = new HashMap();
                        /** query by getRelatedObjects **/
                        MapList mapList1 = organization1.getRelatedObjects(mainContext,"*", "Organization", true, false, 1, objectsSelects, relationshipSelects,"","","","", null);

                        if (!mapList1.isEmpty()){
                        Iterator I = mapList1.iterator();
                        while (I.hasNext()) mapParent = (Map)I.next();
                        
                        RelationshipType rel = new RelationshipType((String) mapParent.get("relationship"));
                        Organization oldParent = new Organization((String) mapParent.get("id"));
                        oldParent.open(mainContext);
                        try{organization1.disconnect(mainContext, rel, false, oldParent);
                        }catch(Exception e){
						String NotValidtab[] = new String[1];
                		NotValidtab[0] =  myNLS.getMessage("OrganizationParent");
                		message = myNLS.getMessage("ERR_NotValid", NotValidtab);               			
               			done = false;
						}
						}
					}
                   }

               if (message.equals(""))message = orgUpdate;
               break;
    	  default :
               message = "Error while creating organization";
              }
    responseCreateProject = responseCreateProject+message+"<Done>"+done+"</Done></updateResult></root>";
    response.getWriter().write(responseCreateProject);
%>



