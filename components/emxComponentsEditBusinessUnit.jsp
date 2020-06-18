<%--  emxComponentsEditBusinessUnit.jsp   -   Editing the Business Unit Object
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxComponentsEditBusinessUnit.jsp.rca 1.14 Wed Oct 22 16:18:16 2008 przemek Experimental przemek $
--%>

<%@include file = "emxComponentsDesignTopInclude.inc"%>
<%@ include file = "emxComponentsVisiblePageInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>

<jsp:useBean id="requestBean" scope="page" class="com.matrixone.apps.domain.util.Request"/>

<% 
  DomainObject businessUnitObj = DomainObject.newInstance(context);
  String attrOrganizationName = PropertyUtil.getSchemaProperty(context, "attribute_OrganizationName");
  String typeBusinessUnit     = PropertyUtil.getSchemaProperty(context, "type_BusinessUnit");
  String sAttrOrgId = PropertyUtil.getSchemaProperty(context, "attribute_OrganizationID");
  String sAttrCageCode = PropertyUtil.getSchemaProperty(context, "attribute_CageCode");  
  String relDivision  = PropertyUtil.getSchemaProperty(context, "relationship_Division");
  String sType = PropertyUtil.getSchemaProperty(context, "type_BusinessUnit");
  String languageStr = request.getHeader("Accept-Language");
  String strMessage  = "";

  String fileName = "";  
  com.matrixone.servlet.FileUploadMultipartRequest multi  = null;
  boolean multiPart = false;
  
  if (request.getContentType() != null &&
      request.getContentType().indexOf("multipart/form-data") == 0)
  {
      multiPart = true;
  }
  
  // Get request parameters.
  String businessUnitId = "";
  String companyId      = "";
  String name           = "";
  String description    = "";
  String sVault         = "";
  String newObjectId = "";
  boolean bExists         = false;
  String orgId            = "";
  String cageCode         = "";
  boolean bRole = true;

  
  BusinessObject businessUnit = null;
  
  String isUniqueCageCode=EnoviaResourceBundle.getProperty(context,"emxComponents.cageCode.Uniqueness");
  if( isUniqueCageCode!=null && isUniqueCageCode.trim().equalsIgnoreCase("true")) {
      isUniqueCageCode = "true";
  } else {
      isUniqueCageCode = "false";
  }

  if(multiPart)
  {
    multi = requestBean.uploadFile(context,request,true, true);
    
    // Get request parameters.
    businessUnitId = multi.getParameter("businessUnitId");
    companyId      = multi.getParameter("companyId");
    name           = multi.getParameter(attrOrganizationName);
    description    = multi.getParameter("txtDesc");
    sVault         = multi.getParameter("vaultName");
    fileName       = multi.getParameter("fileName");
    orgId          = multi.getParameter(sAttrOrgId);
    cageCode       = multi.getParameter(sAttrCageCode);
    
    // Need the company id in order to add a business unit.
    if (companyId == null) 
    {
      throw new MatrixException(ComponentsUtil.i18nStringNow("emxComponents.AddBusinessUnit.ExceptionCompanyId", languageStr));
    }
  
    // Error if no business unit id was passed in.
    if (businessUnitId == null) 
    {
        throw new MatrixException("Need a businessUnitId");
    }

    DomainObject busCompany = new DomainObject(companyId);
    StringList objectSelects = new StringList(1);
    objectSelects.addElement(DomainObject.SELECT_ID);
    StringList relationshipSelects = new StringList(1);
    relationshipSelects.addElement(DomainRelationship.SELECT_ID);
    
    String whereStr = "";
    int objectCount = 0;
    MapList buList = null;

    whereStr = "name == \""+name+"\" && id !="+businessUnitId;
    buList = busCompany.getRelatedObjects(context, relDivision, sType, objectSelects, relationshipSelects, false, true, (short)1, whereStr, "");
    objectCount = buList.size();
    if(objectCount > 0 ) {
        //buExists = true; 
        strMessage = EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource", context.getLocale(), "emxComponents.BusinessUnit.BusinessAlreadyExists"); 
        session.putValue("error.message",strMessage);
        bExists = true;
    }

    if(!bExists) {
        whereStr = DomainObject.getAttributeSelect(sAttrOrgId) + " == \""+orgId+"\" && id !="+businessUnitId;
        buList = busCompany.getRelatedObjects(context, relDivision, sType, objectSelects, relationshipSelects, false, true, (short)1, whereStr, "");
        objectCount = buList.size();
        if(objectCount > 0 ) {
            strMessage = EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource", context.getLocale(), "emxComponents.CreateOrEditOrganization.OrganizationIdAlreadyExists");
            session.putValue("error.message",strMessage);
            bExists = true;
        }
    }

    if(isUniqueCageCode.equalsIgnoreCase("true") && !bExists) {
        whereStr = DomainObject.getAttributeSelect(sAttrCageCode) + " == \""+cageCode+"\" && id !="+businessUnitId;
        buList = busCompany.getRelatedObjects(context, relDivision, sType, objectSelects, relationshipSelects, false, true, (short)1, whereStr, "");
        objectCount = buList.size();
        if(objectCount > 0 ) {
            strMessage = EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource", context.getLocale(), "emxComponents.CreateOrEditCompany.CageCodeAlreadyExists");
            session.putValue("error.message",strMessage);
            bExists = true; 
        }
    }


    if(!bExists) 
    {
        businessUnit = new BusinessObject(businessUnitId);
        businessUnit.open(context);
        
        // Update the business unit description, if it has changed.
        if (description == null) 
        {
            description = "";
        }
        businessUnit.setDescription(description);

        BusinessObjectAttributes boAttrGeneric = businessUnit.getAttributes(context);
        AttributeItr attrItrGeneric   = new AttributeItr(boAttrGeneric.getAttributes());
        AttributeList attrListGeneric = new AttributeList();

        String sAttrValue = "";
        while (attrItrGeneric.next()) 
        {
          Attribute attrGeneric = attrItrGeneric.obj();
          sAttrValue = multi.getParameter(attrGeneric.getName());
          if(sAttrValue==null) {
              sAttrValue = "";
          }
          sAttrValue = sAttrValue.trim();
          attrGeneric.setValue(sAttrValue);
          attrListGeneric.add(attrGeneric);
          
        }
        
        //Update the attributes on the Business Object
        businessUnit.setAttributes(context, attrListGeneric);
        businessUnit.update(context);

        // Following Code is for Checkin the image
        if( fileName !=null && !"".equals(fileName) && !"null".equals(fileName) )
        {
          Map requestMap = new HashMap();
          requestMap.put("fcsEnabled", "false");
          requestMap.put("objectId",businessUnitId);
          requestMap.put("append", "false");      
          requestMap.put("unlock", "true");
          requestMap.put("fileName",fileName);
          String jpoName = "emxCommonFile";
          String[] args = JPO.packArgs(requestMap);
          JPO.invoke(context, jpoName, null, "checkin", args, String.class);
        }

        String strOriginalBusUnitName = businessUnit.getName();
        String strOriginalVaultName = businessUnit.getVault();
        
        boolean isNameChange = false;
        if(name != null && !name.equals(strOriginalBusUnitName) )
        {
            isNameChange = true;
        }
        
        // If a name was passed in and it is different from
        // the current BusinessUnit name, then try to change it.
        if ( isNameChange || (sVault != null && !sVault.equals(strOriginalVaultName)) ) 
        {
          try 
          {
              BusinessObject newBusUnitObj = businessUnit.change(context, businessUnit.getTypeName(), name,
                                    businessUnit.getRevision(), sVault,
                                    businessUnit.getPolicy().getName()
                                    );
              newBusUnitObj.open(context);
              newObjectId = newBusUnitObj.getObjectId(context);
              newBusUnitObj.close(context);
          }
          catch (MatrixException me) 
          {
			   strMessage = EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource", context.getLocale(), "emxComponents.Message.DupilcateRoleCreation.ProfileManagement");
              session.setAttribute("error.message", strMessage);
              bRole = false;
          }
        }

        // Close the business unit object.
        businessUnit.close(context);
    } //end of if(!buExists
  } // if multipart

%>


<%
    if (!bExists && bRole)
    {
%>

<script language="javascript">
  //XSSOK
  if(<%= (!"".equals(newObjectId)) %>)
  {
    var tree = parent.window.getWindowOpener().getTopWindow().objStructureTree;
    tree.getObject("<%=XSSUtil.encodeForJavaScript(context, businessUnitId)%>").changeName("<%=XSSUtil.encodeForJavaScript(context, name)%>",true);
    tree.getObject("<%=XSSUtil.encodeForJavaScript(context, businessUnitId)%>").changeID("<%=XSSUtil.encodeForJavaScript(context, newObjectId)%>",false);
  }
  else
  {
    parent.window.getWindowOpener().parent.window.location.href=parent.window.getWindowOpener().parent.window.location.href;
  }
  window.closeWindow();
</script>

<%
    }
    else 
    {
%>
      <script language="javascript">
      // to show error message if changed name is already exists 
		//XSSOK
        alert("<%=session.getAttribute("error.message")%>");
        document.location = 'emxComponentsCreateBusinessUnitDialog.jsp?businessUnitId=<%=XSSUtil.encodeForURL(context, businessUnitId)%>&objectId=<%=XSSUtil.encodeForURL(context, companyId)%>';
      </script>

<%
    }
%>

<%@include file = "../emxUICommonHeaderEndInclude.inc" %>
<%@include file = "emxComponentsDesignBottomInclude.inc"%>
<%@include file = "../emxUICommonEndOfPageInclude.inc" %> 
