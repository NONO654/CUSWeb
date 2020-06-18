<%--  emxComponentsAddExistingPersonProcess.jsp   -   connect people to Company

   Copyright (c) 1992-2018 Dassault Systemes. All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxComponentsAddExistingPersonProcess.jsp.rca 1.9 Wed Oct 22 16:17:50 2008 przemek Experimental przemek $
--%>

<%@include file = "emxComponentsDesignTopInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="matrix.db.BusinessObject"%>
<%@page import="com.matrixone.apps.common.Person"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%
  //import com.matrixone.apps.common.*;
  DomainObject orgObj = DomainObject.newInstance(context);
  DomainObject personObj = DomainObject.newInstance(context);

  String objectId = emxGetParameter(request,"objectId");
  String typeAlias = emxGetParameter(request,"typeAlias");

  String selectedPeople[] = (String[]) session.getAttribute("selectedPeople");
  /*Begin of add by Infosys for Bug # 301242 on 3/31/2005*/
  String userName = "";
  /*End of add by Infosys for Bug # 301242 on 3/31/2005*/

  for (int i = 0; i < selectedPeople.length; i++) {
     try {
       String selectedRoles[] = emxGetParameterValues(request, selectedPeople[i]);

       // Connect The Person to The Specified Company / Business Unit / Organization
       
       personObj.setId(selectedPeople[i]);
       String strParentCompanyID = objectId;
	   String RELATIONSHIP_ORGANIZATION_PLANT = PropertyUtil.getSchemaProperty(context,"relationship_OrganizationPlant");
       String strCompanyID = personObj.getInfo(context, "to[" + DomainObject.RELATIONSHIP_EMPLOYEE + "].from.id");
       if ("type_Department".equals(typeAlias)) {
          com.matrixone.apps.common.Department departmentObj = new com.matrixone.apps.common.Department(objectId);
          //departmentObj.addEmployeePerson(context, selectedPeople[i], false);
          strParentCompanyID  = Company.getCompanyIdForChildObjects(context, objectId);
          departmentObj.addMemberPerson(context, selectedPeople[i], selectedRoles);
       } else if ("type_BusinessUnit".equals(typeAlias)){
          BusinessUnit businessUnitObj = new BusinessUnit(objectId);
          businessUnitObj.addEmployeePerson(context, selectedPeople[i], false);
          strParentCompanyID  = Company.getCompanyIdForChildObjects(context, objectId);
          businessUnitObj.addMemberPerson(context, selectedPeople[i], selectedRoles);
       } else if("type_Plant".equals(typeAlias)){
           com.matrixone.apps.common.Organization plantObj = new com.matrixone.apps.common.Organization(objectId);
           strParentCompanyID  = Company.getCompanyIdForChildObjects(context, objectId);
           plantObj.addMemberPerson(context, selectedPeople[i], selectedRoles);
       }
         else{
          Company companyObj = new Company(objectId);
          companyObj.addMemberPerson(context, selectedPeople[i], selectedRoles);
       }
       if (strCompanyID ==null || "".equals(strCompanyID) || "null".equals(strCompanyID)){
           Company parentCompanyObj = new Company(strParentCompanyID);
           parentCompanyObj.addEmployeePerson(context, selectedPeople[i], false);
       }
       
       /*Begin of add by Infosys for Bug # 301242 on 3/31/2005*/
          //clear the persons RDO cache
          BusinessObject personBusObj = new BusinessObject(selectedPeople[i]);
          personBusObj.open(context);
          userName = personBusObj.getName();
          personBusObj.close(context);
          PersonUtil.clearUserCacheProperty(context, userName, "RDO");
          // clear application cache too
          HashMap paramMap = new HashMap();
          paramMap.put("userName", userName);
          paramMap.put("propertyName", "RDO");
          String[] methodargs = JPO.packArgs(paramMap);
          JPO.invoke(context, "emxUtil", null, "clearPersonCacheProperty", methodargs);
	  session.setAttribute("company.hashtable", new Hashtable());
      /*End of add by Infosys for Bug # 301242 on 3/31/2005*/
     }catch(MatrixException e) {
        session.putValue("error.message", e.getMessage());
     }
  }

%>
<script language="javascript">
	var frameToRefresh = findFrame(getTopWindow().getWindowOpener(), "detailsDisplay");
	if(frameToRefresh == null){
		frameToRefresh = findFrame(getTopWindow().getWindowOpener().getTopWindow(), "detailsDisplay");
	}
	frameToRefresh.location.href=frameToRefresh.location.href;
      window.closeWindow();
</script>
<%@include file = "emxComponentsDesignBottomInclude.inc"%>
