<%--  emxComponentsCreateBusinessUnitProcess.jsp   -    Creating the Business Unit Object
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxComponentsCreateBusinessUnitProcess.jsp.rca 1.14 Wed Oct 22 16:18:27 2008 przemek Experimental przemek $
--%>

<%@ page import="com.matrixone.apps.framework.ui.*" %>

<%@include file = "emxComponentsDesignTopInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>

<%@ page import ="com.matrixone.apps.domain.util.*" %>
<%@ page import ="com.matrixone.apps.domain.*" %>
<%@ page import ="com.matrixone.apps.common.Organization" %>
<%@include file = "../emxUICommonHeaderEndInclude.inc" %>
<%@include file = "emxComponentsTreeUtilInclude.inc" %>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>

<%
  // Get actual admin names.
  String typeBusinessUnit     = PropertyUtil.getSchemaProperty(context, "type_BusinessUnit");
  String attrOrganizationName = PropertyUtil.getSchemaProperty(context, "attribute_OrganizationName");
  String sAttrOrgId = PropertyUtil.getSchemaProperty(context, "attribute_OrganizationID");
  String sAttrCageCode = PropertyUtil.getSchemaProperty(context, "attribute_CageCode");  
  String policyOrganization   = PropertyUtil.getSchemaProperty(context, "policy_Organization");
  String relDivision          = PropertyUtil.getSchemaProperty(context, "relationship_Division");
  String sStandardCost            = PropertyUtil.getSchemaProperty(context, "attribute_StandardCost");

  String companyId        = "";
  String name             = "";
  String description      = "";
  String strVault         = "";
  String FromActionsTab   = "";
  String treeUrl          = "";
  String orgId            = "";
  String cageCode         = "";
  String strResourceManagerName = "";
  boolean bExists         = false;
  
    // Get page parameters.
    companyId        = request.getParameter("companyId");
    name             = request.getParameter(attrOrganizationName);
    description      = request.getParameter("txtDesc");
    strVault         = request.getParameter("vaultName");
    FromActionsTab   = request.getParameter("FromActionsTab");
    orgId            = request.getParameter(sAttrOrgId);
    cageCode         = request.getParameter(sAttrCageCode); 
    
  //Added:01-June-2010:s4e:R210 PRG:AdvanceResourcePlanning
    String strselcurrency       = request.getParameter("selcurrency");
    String standardCost     = request.getParameter(sStandardCost);    
    String stdCostWithCurrency  = standardCost + " " + strselcurrency;
  //End:01-June-2010:s4e:R210 PRG:AdvanceResourcePlanning
    
    treeUrl        = "";

    bExists = false;
  
    // Need the company id in order to add a business unit.
    if (companyId == null) 
    {
      throw new MatrixException(ComponentsUtil.i18nStringNow("emxComponents.AddBusinessUnit.ExceptionCompanyId", request.getHeader("Accept-Language")));
    }
  
    BusinessObject busCompany = new BusinessObject(companyId);

    busCompany.open(context);
    if (strVault == null || "null".equals(strVault) || "".equals(strVault))
    {
      strVault = busCompany.getVault();
    }
    busCompany.close(context);
    // Create a business unit business object with an autonamed revision.
    String businessUnitId = null;
    
    StringList strList = new StringList(1);
    strList.addElement("from["+relDivision+"].to.name");
    strList.addElement("from["+relDivision+"].to.attribute["+sAttrOrgId+"]");
    strList.addElement("from["+relDivision+"].to.attribute["+sAttrCageCode+"]");
    BusinessObjectWithSelect busWithSel = busCompany.select(context,strList);
    strList = busWithSel.getSelectDataList("from["+relDivision+"].to.name");
    int iSize = 0;
    boolean nameExists = false;
    if(strList != null && (iSize = strList.size()) > 0 )
    {
        for(int i = 0 ; i < iSize ; i++)
        {
            if(name.equals(strList.elementAt(i).toString()))
            {
                nameExists = true;
                break;
            }
        }
    }

    if(Organization.hasAdminUserRole(context,name))
    {
        nameExists = true;
        
    }

    boolean idExists = false;
    if(!nameExists) {
        strList = busWithSel.getSelectDataList("from["+relDivision+"].to.attribute["+sAttrOrgId+"]");
        if(strList != null && (iSize = strList.size()) > 0 )
        {
            for(int i = 0 ; i < iSize ; i++)
            {
                if(orgId.equals(strList.elementAt(i).toString()))
                {
                    idExists = true;
                    break;
                }
            }
        }
    }
    
    String isUniqueCageCode=EnoviaResourceBundle.getProperty(context,"emxComponents.cageCode.Uniqueness");
    if( isUniqueCageCode!=null && isUniqueCageCode.trim().equalsIgnoreCase("true")) {
          isUniqueCageCode = "true";
    } else {
          isUniqueCageCode = "false";
    }
    boolean cageCodeExists = false;

    if(isUniqueCageCode.equals("true") && !nameExists && !idExists) {
        strList = busWithSel.getSelectDataList("from["+relDivision+"].to.attribute["+sAttrCageCode+"]");
        if(strList != null && (iSize = strList.size()) > 0 )
        {
            for(int i = 0 ; i < iSize ; i++)
            {
                if(cageCode.equals(strList.elementAt(i).toString()))
                {
                    cageCodeExists = true;
                    break;
                }
            }
        }
    }

    
    if(!nameExists && !idExists && !cageCodeExists) 
    {
      businessUnitId = FrameworkUtil.autoRevision(context, typeBusinessUnit, name, policyOrganization,strVault);
      BusinessObject businessUnit = new BusinessObject(businessUnitId);
      businessUnit.open(context);
      String orgDescription = businessUnit.getDescription();

      // Connect the business unit to the company.
      businessUnit.connect( context, new RelationshipType(relDivision), false, busCompany);

      // Promote the business unit to the active state.
      businessUnit.promote(context);

      BusinessObjectAttributes boAttrGeneric = businessUnit.getAttributes(context);
      AttributeItr attrItrGeneric   = new AttributeItr(boAttrGeneric.getAttributes());
      AttributeList attrListGeneric = new AttributeList();

      String sAttrValue = "";
      Attribute attrGeneric = null;
      while (attrItrGeneric.next()) 
      {
        attrGeneric = attrItrGeneric.obj();
        sAttrValue = request.getParameter(attrGeneric.getName());
        if(sAttrValue==null) {
			//Bug Fix Begin- 316090 
			if(attrGeneric.hasChoices()) {
				AttributeType attrGenericType = attrGeneric.getAttributeType();
				sAttrValue = attrGenericType.getDefaultValue(context); 
			} else {
			//Bug Fix End - 316090
				sAttrValue = "";
			}
        }
        sAttrValue = sAttrValue.trim();
        attrGeneric.setValue(sAttrValue);
        attrListGeneric.addElement(attrGeneric);
      }

      // Update the business unit description
      if(description != null && !description.equals(orgDescription)) 
      {
          businessUnit.setDescription(description);
      }

      //Update the attributes on the Business Object
      businessUnit.setAttributes(context, attrListGeneric);
      
    //Added:01-June-2010:s4e:R210 PRG:AdvanceResourcePlanning
      if(standardCost != null && !"null".equals(standardCost)){
    	  businessUnit.setAttributeValue(context, sStandardCost, stdCostWithCurrency); 
      }
    //End:01-June-2010:s4e:R210 PRG:AdvanceResourcePlanning
    
      businessUnit.update(context);
      
      // Added:4-Nov-08:oef:R208:PRG Resource Planning 
      String strResourceManagerIDs = request
              .getParameter("ResourceManagerID");

      String strOrgID = request.getParameter(sAttrOrgId);

      if (null == strResourceManagerIDs
              || "null".equals(strResourceManagerIDs)
              || "".equals(strResourceManagerIDs.trim())) {
          strResourceManagerIDs = "";
      }

      StringList slSelectedResourceManagers = FrameworkUtil
              .split(strResourceManagerIDs, ",");

      Organization organization = new Organization(businessUnitId);
      organization.assignResourceManagers(context,slSelectedResourceManagers);
      //End:R208:PRG Resource Planning
    
      businessUnit.close(context);
    }
    else 
    {
      bExists = true;
      String strLanguage = request.getHeader("Accept-Language");
      if(nameExists) {
          session.putValue("error.message", ComponentsUtil.i18nStringNow("emxComponents.BusinessUnit.BusinessAlreadyExists", strLanguage));
      }else if(idExists) {
          session.putValue("error.message", ComponentsUtil.i18nStringNow("emxComponents.CreateOrEditOrganization.OrganizationIdAlreadyExists", strLanguage));
      }else if(cageCodeExists) {
          session.putValue("error.message", ComponentsUtil.i18nStringNow("emxComponents.CreateOrEditCompany.CageCodeAlreadyExists", strLanguage));
      }
    }

    if (!bExists) 
    {
      // Forward to the edit business unit page to set the attributes.
      treeUrl = UINavigatorUtil.getCommonDirectory(context)+ "/emxTree.jsp?AppendParameters=false"+
                "&objectId=" + businessUnitId  + "&companyId=" + companyId  +"&emxSuiteDirectory="+appDirectory + "&mode=insert";
    
%>  
	  
      <script language="javascript">
			// getTopWindow().getWindowOpener().document.location.href = getTopWindow().getWindowOpener().document.location.href;
	  loadTreeNode("<%=XSSUtil.encodeForJavaScript(context, businessUnitId)%>", "<%=XSSUtil.encodeForJavaScript(context, companyId)%>", null, "<%=XSSUtil.encodeForJavaScript(context, appDirectory)%>", true, "<%=XSSUtil.encodeForJavaScript(context, treeUrl)%>");
      parent.window.closeWindow();
      </script>
<%  
    }
    else 
    {
%>
      <form name="newForm" target="_parent" action="emxComponentsCreateBusinessUnitDialogFS.jsp" >
          <input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=companyId%></xss:encodeForHTMLAttribute>" />
      </form>
      <script language="javascript">
      document.newForm.submit();
      </script>
<%
    }
 
%>

<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
