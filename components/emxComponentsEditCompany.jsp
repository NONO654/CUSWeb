<%--
  emxComponentsEditCompany.jsp --

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program

   static const char RCSID[] = "$Id: emxComponentsEditCompany.jsp.rca 1.19 Wed Oct 22 16:18:22 2008 przemek Experimental przemek $";
--%>
<%@include file = "emxComponentsDesignTopInclude.inc"%>
<%@include file = "emxComponentsVisiblePageInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>
<jsp:useBean id="requestBean" scope="page" class="com.matrixone.apps.domain.util.Request"/>

<jsp:useBean id="formBean" scope="session" class="com.matrixone.apps.common.util.FormBean"/>
<%

  BusinessObject companyObj = null;
  // Create a temp directory to place the file into
  String attrFileStoreSymName    = PropertyUtil.getSchemaProperty(context, "attribute_FileStoreSymbolicName");
  String relSubsidiary = PropertyUtil.getSchemaProperty(context, "relationship_Subsidiary");
  String sAttrOrgId = PropertyUtil.getSchemaProperty(context, "attribute_OrganizationID");
  String sAttrCageCode = PropertyUtil.getSchemaProperty(context, "attribute_CageCode");  
  String companyId = "";
  String name        = "";
  String newObjectId = "";
  String parentId  = "";

  boolean multiPart = false;
  
  boolean bolChangeNameError = false;
  
  StringBuffer strBufSecondaryVaultMessage = new StringBuffer();
  String strStoreMessage = "";
  
  String languageStr  = request.getHeader("Accept-Language");
  
  if (request.getContentType() != null && request.getContentType().indexOf("multipart/form-data") == 0)
  {
      multiPart = true;
  }

  boolean isCageCodeNotUnique = false;
  boolean isCompanyIdNotUnique = false;

  if (multiPart)
  {

      com.matrixone.servlet.FileUploadMultipartRequest multi  = null;
      Company boParentCompany = (Company)DomainObject.newInstance(context,DomainConstants.TYPE_COMPANY,null);
      multi = requestBean.uploadFile(context,request,true, true);
      String attrSecondaryVaults  = PropertyUtil.getSchemaProperty(context, "attribute_SecondaryVaults");
                        String isSubsidiaryEdit = "";
                        isSubsidiaryEdit = multi.getParameter("isSubsidiaryEdit");

      // Get request parameters.
      companyId   = multi.getParameter("companyId");
      name        = multi.getParameter("txtName");
      String description = multi.getParameter("description");

      if(description == null)
      {
          description = "";
      }  

      String sVault      = multi.getParameter("vaultName");

      String attrCageCode = PropertyUtil.getSchemaProperty(context, "attribute_CageCode");
      String sType = PropertyUtil.getSchemaProperty(context, "type_Company");
      String sRevision = "-";
      String strAttrCageCode="";
      String strMessage = "";
      String strMessage1 = "";
      String strMessage2 = "";
      String isUniqueCageCode = EnoviaResourceBundle.getProperty(context,"emxComponents.cageCode.Uniqueness");
      strAttrCageCode        = multi.getParameter(sAttrCageCode); 
      
      String attrOrgId=PropertyUtil.getSchemaProperty(context,"attribute_OrganizationID");
      StringList strlistObjectSelect   = new StringList();
      strlistObjectSelect.addElement(DomainObject.SELECT_ID);
      String strOrgId   = multi.getParameter(sAttrOrgId);
         
      String whereStr = DomainObject.getAttributeSelect(attrOrgId) + " == \""+strOrgId+"\" && id !="+companyId;
      MapList companyList = DomainObject.findObjects(context,sType,"*",whereStr,strlistObjectSelect);
      int companyCount = companyList.size();
        
      if(companyCount > 0 )
      {
            isCompanyIdNotUnique = true;
            strMessage1 = EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource", context.getLocale(), "emxComponents.CreateOrEditCompany.CompanyIdAlreadyExists"); 
            strMessage2 = EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource", context.getLocale(), "emxComponents.CreateOrEditCompany.SubsidiaryIdAlreadyExists");
            if (isSubsidiaryEdit != null && "true".equals(isSubsidiaryEdit))
          {
            MqlUtil.mqlCommand(context,"error $1",strMessage2);
          }
          else
          {
              MqlUtil.mqlCommand(context,"error $1",strMessage1);
          }

      }


      if(isUniqueCageCode != null && isUniqueCageCode.trim().equalsIgnoreCase("true"))
      {
         whereStr = DomainObject.getAttributeSelect(attrCageCode) + " == \""+strAttrCageCode+"\" && id !="+companyId;

         companyList=DomainObject.findObjects(context,sType,"*",whereStr,strlistObjectSelect);
         companyCount = companyList.size();

         if(companyCount > 0 )
         {
            isCageCodeNotUnique = true ;
            strMessage = EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource", context.getLocale(), "emxComponents.CreateOrEditCompany.CageCodeAlreadyExists"); 
            MqlUtil.mqlCommand(context,"error $1",strMessage);
         }
       }
       if(!isCompanyIdNotUnique && !isCageCodeNotUnique) {

          String jpoName = "emxCommonFile";
          String fileName = "";
          String oldParentId = "";
          Map requestMap = new HashMap();
          Enumeration enumParam;

         requestMap.put("fcsEnabled", "false");
         parentId = multi.getParameter("parentId");
         oldParentId = multi.getParameter("oldParentId");
         isSubsidiaryEdit = multi.getParameter("isSubsidiaryEdit");

         if(parentId == null || "".equals(parentId) || "null".equals(parentId)) {
            parentId = "";
         }

         if(oldParentId == null || "".equals(oldParentId) || "null".equals(oldParentId)) {
            oldParentId = "" ;
         }

         fileName = multi.getParameter("fileName");
         enumParam = multi.getParameterNames();

          while (enumParam.hasMoreElements())
         {
            String paramName = (String) enumParam.nextElement();
            requestMap.put(paramName, multi.getParameter(paramName));
         }

          DomainObject company  = new DomainObject(companyId);
          company.open(context);

          String sCurrent         = FrameworkUtil.getCurrentState(context,company).getName();

          // If a description was passed in and is different, then change it.
          if (description != null && (description.equals(company.getDescription()) == false)) {
            company.setDescription(description);
            company.update(context);
          }

          BusinessObjectAttributes boAttrGeneric  = company.getAttributes(context);
          AttributeItr attrItrGeneric         = new AttributeItr(boAttrGeneric.getAttributes());
          AttributeList attrListGeneric       = new AttributeList();

          String sAttrName = "";
          String sAttrValue             = "";
          String sTrimVal               = "";
          String strVaultName           = "";
          while (attrItrGeneric.next()) 
          {
            Attribute attrGeneric = attrItrGeneric.obj();
            sAttrValue = multi.getParameter(attrGeneric.getName());
              sAttrName = attrGeneric.getName();
                if(sAttrName.equals(attrSecondaryVaults))
                {
                  sAttrValue = multi.getParameter( attrSecondaryVaults);

                  if (sAttrValue != null)
                  {

                    StringList vaultList = FrameworkUtil.split(sAttrValue,",");
                    StringItr  vaultItr  = new StringItr(vaultList);
                    StringList secondaryVaultList = new StringList();
                    while( vaultItr.next() )
                    {
                      strVaultName = (String)vaultItr.obj();
                      String vault = FrameworkUtil.getAliasForAdmin(context,"vault", strVaultName, true);
                      if(vault != null && !"".equals(vault))
                      {
                        secondaryVaultList.add(vault);
                      }
                      else
                      {
                        if(strBufSecondaryVaultMessage.length() > 0 )
                        {
                            strBufSecondaryVaultMessage.append(", ");
                        }
                        strBufSecondaryVaultMessage.append(strVaultName);
                      }
                    }

                    String secondaryVaultStr = FrameworkUtil.join(secondaryVaultList,"~");
                    attrGeneric.setValue(secondaryVaultStr);
                  }
                }
                else
                {
                        if (sAttrValue != null) 
                        {
                          if(sAttrName.equals(attrFileStoreSymName) && !"".equals(sAttrValue))
                          {
                            String strStoreValue = sAttrValue;
                            sAttrValue = FrameworkUtil.getAliasForAdmin(context,"Store",sAttrValue,true);
                            if(sAttrValue == null)
                            {
                                sAttrValue = "";
                                strStoreMessage = strStoreValue;
                            }
                          }

                          sTrimVal = sAttrValue.trim();
                          attrGeneric.setValue(sTrimVal);
                        } else {
                            sAttrValue = "";
                            attrGeneric.setValue(sAttrValue);
                        }

                }
                attrListGeneric.addElement(attrGeneric);
          }

          //Update the attributes on the Business Object
          company.setAttributes(context, attrListGeneric);

         // Connect the created company as subsidiary to selected parent.
         if(!parentId.equals(oldParentId))
         {
            if(!"".equals(oldParentId)) {
               boParentCompany.setId(oldParentId);
               company.disconnect( context, new RelationshipType(relSubsidiary), false, boParentCompany);
            }

            if(!"".equals(parentId)) {
               boParentCompany.setId(parentId);
               company.connect( context, relSubsidiary, boParentCompany, true);
            }
         }

          company.update(context);

          requestMap.put("append", "false");
          requestMap.put("unlock", "true");
          requestMap.put("objectId", companyId);
          request.setAttribute("requestMap", requestMap);

          String[] args = JPO.packArgs(requestMap);

          if ( fileName!=null && !"".equals(fileName) && !"null".equals(fileName))
          {
              JPO.invoke(context, jpoName, null, "checkin", args, String.class);
          }

          // If a name was passed in and it is different from
          // the current company name, then try to change it.
          if (name != null && sVault!=null && (!name.equals(company.getName()) || !sVault.equals(company.getVault())) ) {
          

              String strResult = MqlUtil.mqlCommand(context,"list user $1",true,name);

              if(!"".equals(strResult))
              {
                  bolChangeNameError = true;
                  
                  strMessage = EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource", context.getLocale(), "emxComponents.CreateOrEditCompany.CompanyNameAlreadyExists1") + name + EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource", context.getLocale(), "emxComponents.CreateOrEditCompany.CompanyNameAlreadyExists2");
                  MqlUtil.mqlCommand(context, "notice $1",strMessage);
              }
              else
              {
                  companyObj = company.change(context, company.getTypeName(), name,company.getRevision(), sVault, company.getPolicy().getName());
                  companyObj.open(context);
                  newObjectId = companyObj.getObjectId(context);
                  companyObj.close(context);
              }
          }
          // Close the company object.
          company.close(context);
        
        // Following code is to remove the values from formBean
        String keyCompany = (String)multi.getParameter("keyCompany");
        session.removeAttribute(keyCompany);
        //------------------------------------

    }  //end of if(!isCageCodeNotUnique


} // end of multi part


    if(strBufSecondaryVaultMessage.length() > 0)
    {
        StringBuffer strBufMessage = new StringBuffer();
        strBufMessage.append(EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource", context.getLocale(), "emxComponents.CompanyEdit.SecondaryVaultMessage1"));
        strBufMessage.append(" '");
        strBufMessage.append(strBufSecondaryVaultMessage.toString());
        strBufMessage.append("' ");
        strBufMessage.append(EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource", context.getLocale(), "emxComponents.CompanyEdit.SecondaryVaultMessage2"));
        
        MqlUtil.mqlCommand(context,"warning $1",strBufMessage.toString());
        
    }
    if(strStoreMessage.length() > 0)
    {
        StringBuffer strBufStoreMessage = new StringBuffer();
        strBufStoreMessage.append(EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource", context.getLocale(), "emxComponents.CompanyEdit.StoreMessage1"));
        strBufStoreMessage.append(" '");
        strBufStoreMessage.append(strStoreMessage);
        strBufStoreMessage.append("' ");
        strBufStoreMessage.append(EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource", context.getLocale(), "emxComponents.CompanyEdit.StoreMessage2"));

        MqlUtil.mqlCommand(context,"warning $1 ",strBufStoreMessage.toString());
    }
    
%>
<%@include file = "../emxUICommonHeaderEndInclude.inc" %>

<script type="text/javascript">
	//XSSOK
    if(<%=isCageCodeNotUnique%> || <%=isCompanyIdNotUnique%>)
    {
        getTopWindow().location.href=getTopWindow().location.href;
    } else {
    	//XSSOK
        if (<%=!"".equals(XSSUtil.encodeForJavaScript(context, newObjectId)) %>) 
        {
            var tree = parent.window.getWindowOpener().getTopWindow().objStructureTree;
            if (tree!=null) 
            {
                tree.getSelectedNode().changeObjectName("<%=XSSUtil.encodeForJavaScript(context, name)%>",false);
                tree.getSelectedNode().changeObjectID("<%=XSSUtil.encodeForJavaScript(context, newObjectId)%>");
                tree.refresh();
                parent.window.getWindowOpener().parent.window.location.href="emxComponentsCompanyDetailsFS.jsp?objectId=<%=XSSUtil.encodeForURL(context, newObjectId)%>";
            }
            else
            {
                parent.window.getWindowOpener().parent.window.location.href= parent.window.getWindowOpener().parent.window.location.href;
            }
        } else {
        	//XSSOK
            if(<%=bolChangeNameError%>)
            {
                getTopWindow().location.href=getTopWindow().location.href;
            }
            else
            {
                parent.window.getWindowOpener().parent.window.location.href= parent.window.getWindowOpener().parent.window.location.href;
            }
        }
        if(<%=!bolChangeNameError%>)
        {
            getTopWindow().closeWindow();
        }
    }

</script>

<%@include file = "../emxUICommonEndOfPageInclude.inc" %>

