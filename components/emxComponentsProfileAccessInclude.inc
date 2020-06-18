<%--  emxComponentsProfileAccessInclude.inc -- This page displays the details of a company.

  Copyright (c) 1992-2018 Dassault Systemes. All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxComponentsProfileAccessInclude.inc.rca 1.8 Wed Oct 22 16:17:47 2008 przemek Experimental przemek $
--%>

<%!
    /**
    *   If the person is a Host Company Representative OR Buyer Admin OR Company Representative of the 
    *   Selected Company then this method will return true.
    */

    public boolean hasAccessToCommand(Context context, HttpSession session, String objectId, String adminRoleList, String roleList)
         throws Exception
    {
        boolean isHostRep = Company.isHostRep(context,com.matrixone.apps.common.Person.getPerson(context));
        if(isHostRep)
        {
            return true;
        }
        
        com.matrixone.apps.common.Person loginPerson = com.matrixone.apps.common.Person.getPerson(context);
        
        StringList adminRolesList   = FrameworkUtil.split(adminRoleList,",");
        Iterator adminRolesItr      = adminRolesList.iterator();
        
        String role = "";
        String roleName = "";
        while (adminRolesItr.hasNext())
        {
            role = (String) adminRolesItr.next();
            roleName = PropertyUtil.getSchemaProperty(context, role);
            if(loginPerson.hasRole(context,roleName))
            {
                return true;
            }
        }
        String strOrgRepRel               = PropertyUtil.getSchemaProperty(context, "relationship_CompanyRepresentative");
        
        String strCompRepId = loginPerson.getInfo(context,"to["+strOrgRepRel+"].from.id");

        if(strCompRepId == null || "".equals(strCompRepId))
        {
            return false;
        }
        
        String strCompanyType             = PropertyUtil.getSchemaProperty(context, "type_Company");
        String strBusinessUnitType        = PropertyUtil.getSchemaProperty(context, "type_BusinessUnit");
        String strLocationType            = PropertyUtil.getSchemaProperty(context, "type_Location");
        String strDepartmentType          = PropertyUtil.getSchemaProperty(context, "type_Department");        
        String strDivisionRel             = PropertyUtil.getSchemaProperty(context, "relationship_Division");
        String strCompanyDepRel           = PropertyUtil.getSchemaProperty(context, "relationship_CompanyDepartment");        
        String strEmployeeRel             = PropertyUtil.getSchemaProperty(context, "relationship_Employee");
        String strBusUnitEmpRel           = PropertyUtil.getSchemaProperty(context, "relationship_BusinessUnitEmployee");
        String strPersonType              = PropertyUtil.getSchemaProperty(context, "type_Person");
        String strRegionType              = PropertyUtil.getSchemaProperty(context, "type_Region");
        String strOrgRegionRel            = PropertyUtil.getSchemaProperty(context, "relationship_OrganizationRegion");
        String strSubsidiaryRel           = PropertyUtil.getSchemaProperty(context, "relationship_Subsidiary");
        

        String strCompRepType = loginPerson.getInfo(context,"to["+strOrgRepRel+"].from.type");

        String strTypeToCompare = "";
        String strEmpRel = "";
        if(strCompanyType.equals(strCompRepType))
        {
            strTypeToCompare = strCompanyType;
            strEmpRel = strEmployeeRel;
        }
        else if(strBusinessUnitType.equals(strCompRepType))
        {
            strTypeToCompare = strBusinessUnitType;
            strEmpRel = strBusUnitEmpRel;
        }

        String strOrganizationId = objectId;
        DomainObject busOrganization = new DomainObject(strOrganizationId);
        String sTypeName = busOrganization.getInfo(context,DomainObject.SELECT_TYPE);

        while(!strTypeToCompare.equals(sTypeName) && !"".equals(sTypeName))
        {
            if(strBusinessUnitType.equals(sTypeName))
            {
                sTypeName = busOrganization.getInfo(context,"to[" + strDivisionRel + "].from.type");
                strOrganizationId = busOrganization.getInfo(context,"to[" + strDivisionRel + "].from.id");
                busOrganization = new DomainObject(strOrganizationId);
            }
            else if (strDepartmentType.equals(sTypeName))
            {
                sTypeName = busOrganization.getInfo(context,"to[" + strCompanyDepRel + "].from.type");
                strOrganizationId = busOrganization.getInfo(context,"to[" + strCompanyDepRel + "].from.id");
                busOrganization = new DomainObject(strOrganizationId);
            }
            else if(strPersonType.equals(sTypeName))
            {
                sTypeName = busOrganization.getInfo(context,"to[" + strEmpRel + "].from.type");
                strOrganizationId = busOrganization.getInfo(context,"to[" + strEmpRel + "].from.id");
                busOrganization = new DomainObject(strOrganizationId);
            }
            else if (strRegionType.equals(sTypeName))
            {
                sTypeName = busOrganization.getInfo(context,"to[" + strOrgRegionRel + "].from.type");
                strOrganizationId = busOrganization.getInfo(context,"to[" + strOrgRegionRel + "].from.id");
                busOrganization = new DomainObject(strOrganizationId);
            }
            else
            {
                sTypeName = "";
            }
        }

        if(strCompRepId.equals(strOrganizationId))
        {
            return true;
        }

        if(strCompanyType.equals(strTypeToCompare))
        {
            while(strCompanyType.equals(sTypeName))
            {
                sTypeName = busOrganization.getInfo(context,"to[" + strSubsidiaryRel + "].from.type");
                strOrganizationId = busOrganization.getInfo(context,"to[" + strSubsidiaryRel + "].from.id");
                if(strCompRepId.equals(strOrganizationId))
                {
                    return true;
                }
                busOrganization = new DomainObject(strOrganizationId);
            }
        }
        else if(strBusinessUnitType.equals(strTypeToCompare))
        {
            while(strBusinessUnitType.equals(sTypeName))
            {
                sTypeName = busOrganization.getInfo(context,"to[" + strDivisionRel + "].from.type");
                strOrganizationId = busOrganization.getInfo(context,"to[" + strDivisionRel + "].from.id");
                if(strCompRepId.equals(strOrganizationId))
                {
                    return true;
                }
                busOrganization = new DomainObject(strOrganizationId);
            }
        }

        return false;
    }
    
    /**
    *   If the person is a Host Company Representative OR Buyer Admin OR Company Representative of the 
    *   Selected Company then this method will return true.
    */    
    // This method accepts Relationship ID also.
    public boolean hasAccessToCommand(Context context, HttpSession session, String objectId,String relId, String adminRoleList, String roleList)
         throws Exception
    {
        if(hasAccessToCommand(context,session,objectId,adminRoleList,roleList))
        {
            return true;
        }
        if(relId == null || "".equals(relId))
        {
            return false;
        }
        
        com.matrixone.apps.common.Person loginPerson = com.matrixone.apps.common.Person.getPerson(context);
        
        String strCompanyType             = PropertyUtil.getSchemaProperty(context, "type_Company");
        String strOrgRepRel               = PropertyUtil.getSchemaProperty(context, "relationship_CompanyRepresentative");
        String strManuProcessType         = PropertyUtil.getSchemaProperty(context, "type_ManufacturingProcess");
        String strDesignProcessType       = PropertyUtil.getSchemaProperty(context, "type_DesignProcess");
        String strTestingProcessType      = PropertyUtil.getSchemaProperty(context, "type_TestingProcess");
        String strCapabilityRel           = PropertyUtil.getSchemaProperty(context, "relationship_Capability");

        String strOrganizationId = objectId;
        DomainObject busOrganization = new DomainObject(objectId);
        
        String sTypeName = busOrganization.getInfo(context,DomainObject.SELECT_TYPE);

        while(!sTypeName.equals(strCompanyType) && !"".equals(sTypeName))
        {
            if(strManuProcessType.equals(sTypeName) || strDesignProcessType.equals(sTypeName) || strTestingProcessType.equals(sTypeName) )
            {
                Relationship processRelObject = new Relationship(relId);
                processRelObject.open(context);
                busOrganization = new DomainObject(processRelObject.getFrom());
                sTypeName = busOrganization.getInfo(context,DomainObject.SELECT_TYPE);
                strOrganizationId = busOrganization.getInfo(context,DomainObject.SELECT_ID);
            }
            else
            {
                sTypeName = "";
            }
        }
        String strCompRepId = loginPerson.getInfo(context,"to["+strOrgRepRel+"].from.id");
        if(strOrganizationId.equals(strCompRepId))
        {
            return true;
        }

        return false;
    }
%>

