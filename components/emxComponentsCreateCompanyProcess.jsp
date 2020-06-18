<%--  emxComponentsCreateCompanyProcess.jsp  --  Creating Company object

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxComponentsCreateCompanyProcess.jsp.rca 1.21 Wed Oct 22 16:18:33 2008 przemek Experimental przemek $
 --%>

<%@include file = "emxComponentsDesignTopInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>

<jsp:useBean id="requestBean" scope="page" class="com.matrixone.apps.domain.util.Request"/>
<jsp:useBean id="formBean" scope="session" class="com.matrixone.apps.common.util.FormBean"/>

<%@include file = "../emxUICommonHeaderEndInclude.inc" %>
<%@include file = "emxComponentsTreeUtilInclude.inc" %>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>

<%
    Company company = (Company)DomainObject.newInstance(context,DomainConstants.TYPE_COMPANY,null);

    String companyType =  (String)formBean.getElementValue("companyType") ;
    // Create a temp directory to place the file into

    //Bug 337556 - Start
    String attributeOrganizationName      = PropertyUtil.getSchemaProperty(context, "attribute_OrganizationName");
    //Bug 337556 - End

    String attrFileStoreSymName           = PropertyUtil.getSchemaProperty(context, "attribute_FileStoreSymbolicName");
    String sType                          = PropertyUtil.getSchemaProperty(context, "type_Company");
    String sPolicy                        = PropertyUtil.getSchemaProperty(context, "policy_Organization");
    String relSubsidiary                  = PropertyUtil.getSchemaProperty(context, "relationship_Subsidiary");
  // MEP Name/Revision Feature
    String attrOrgId                      = PropertyUtil.getSchemaProperty(context, "attribute_OrganizationID");
    String attrCageCode                   = PropertyUtil.getSchemaProperty(context, "attribute_CageCode");
    String isUniqueCageCode               = EnoviaResourceBundle.getProperty(context,"emxComponents.cageCode.Uniqueness");
    
    String sStandardCost                  = PropertyUtil.getSchemaProperty(context, "attribute_StandardCost");
    boolean isNotUnique                   = false;
    String fileName   = "";
    String parentId   = "";
    String strAttrCageCode="";
    String strAttrCompanyId="";
    Map requestMap    = new HashMap();

    StringBuffer strBufSecondaryVaultMessage = new StringBuffer();
    String strStoreMessage = "";

    String languageStr  = request.getHeader("Accept-Language");

    formBean.processForm(session,request,"keyCompany");
    String keyCompany = (String)formBean.getElementValue("keyCompany");

    StringBuffer strBufQueryString = new StringBuffer();
    strBufQueryString.append("&").append("keyCompany").append("=").append(XSSUtil.encodeForURL(context, keyCompany)).append("&").append("companyType").append("=").append(XSSUtil.encodeForURL(context, companyType));

    //parentId = (String)formBean.getElementValue("parentId");
    parentId = (String)formBean.getElementValue("parentNameOID");

    Iterator iterator = formBean.getElementNames();

    while(iterator.hasNext())
    {
        String name = (String) iterator.next();
        if(name.equals(attrCageCode))
        {
            strAttrCageCode =(String)formBean.getElementValue(name);
        }
        if(name.equals(attrOrgId))
        {
            strAttrCompanyId =(String)formBean.getElementValue(name);
        }
        requestMap.put(name,formBean.getElementValue(name));
    }

    String sName    = (String)formBean.getElementValue("txtName");
    String sDescription = (String)formBean.getElementValue("description");
    String sRevision = "-";
    String FromActionsTab = (String)formBean.getElementValue("FromActionsTab");
    String attrSecondaryVaults  = PropertyUtil.getSchemaProperty(context, "attribute_SecondaryVaults");
    String strCompanyVault = JSPUtil.getCompanyVault(context, session);
    String strVaultName = strCompanyVault;
    String strVault = "";
    String strCompanyId = "";
    String isSubsidiaryCreate = (String)formBean.getElementValue("isSubsidiaryCreate");
    String strMessage = "";
    String strMessage1 = "";
    String strMessage2 = "";
    String strselcurrency       = (String)formBean.getElementValue("selcurrency");
    String standardCost       = (String)formBean.getElementValue(sStandardCost);
    String stdCostWithCurrency  = standardCost + " " + strselcurrency;
    boolean bBackPage= false;
    boolean closePage = false;

    if ( (String)formBean.getElementValue( "vaultName") != null && !"".equals((String)formBean.getElementValue( "vaultName")) )
    {
        strVaultName = (String)formBean.getElementValue( "vaultName");
    }

    // If the company does not exist, then create it.
    String strEnableCompanyVaulting = JSPUtil.getApplicationProperty(context,application,"emxComponents.CompanyVaulting","emxComponentsProperties");

    if ( "TRUE".equalsIgnoreCase(strEnableCompanyVaulting) )
    {
        matrix.db.Query query = new matrix.db.Query();
        query.open(context);
        query.setBusinessObjectType(sType);
        query.setBusinessObjectName("*");
        query.setBusinessObjectRevision("*");
        query.setVaultPattern(strVaultName);
        query.setOwnerPattern("*");
        query.setWhereExpression("");
        BusinessObjectList boList = query.evaluate(context);
        query.close(context);

        int countEqual = boList.size();
        if ( countEqual >= 1 )
        {
            session.setAttribute("error.message", ComponentsUtil.i18nStringNow("emxComponents.CompanyDialog.ErrorVaultAlreadyHasCompany", languageStr));
            bBackPage = true;
        } else {
            strVault = strVaultName;
        }
    }

    if(!bBackPage)
    {
        matrix.db.Query query = new matrix.db.Query();
        /* Check to see if the cagecode is unique if the property setting is true*/
        if(isUniqueCageCode.equals("true") && !(isNotUnique))
        {
            String whereStr = DomainObject.getAttributeSelect(attrCageCode) + " == \""+strAttrCageCode+"\"";
            query.open(context);
            query.setBusinessObjectType(sType);
            query.setBusinessObjectRevision(sRevision);
            query.setVaultPattern("*");
            query.setOwnerPattern("*");
            query.setWhereExpression(whereStr);
            BusinessObjectList boList2 = query.evaluate(context);
            query.close(context);
            int countCageCode = boList2.size();
            if(countCageCode > 0 )
            {
                isNotUnique = true ;
                strMessage = EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource", context.getLocale(), "emxComponents.CreateOrEditCompany.CageCodeAlreadyExists");
                session.setAttribute("error.message", strMessage);
                bBackPage = true;
            }
        }
        if(!isNotUnique)
        { // Checking for Name

            query.open(context);
            query.setBusinessObjectType(sType);
            query.setBusinessObjectName(sName);
            query.setBusinessObjectRevision(sRevision);
            query.setVaultPattern("*");
            query.setOwnerPattern("*");
            query.setWhereExpression("");
            BusinessObjectList boList = query.evaluate(context);
            query.close(context);
            int countEqual = boList.size();
            if ( countEqual <= 0 )
            {
              try
              {
                ContextUtil.startTransaction(context, true);
                company.create(context, sName, sPolicy, strVaultName, false);
                company.open(context);

            // Connect the created company as subsidiary to selected parent.
            if(parentId!=null && !"".equals(parentId) && !"null".equals(parentId))
            {
                company.addFromObject(context, new RelationshipType(relSubsidiary), parentId);
            }

            //Added for Organization feature v11

            if (companyType != null && !"null".equals(companyType) && !"".equals(companyType))
            {
                  //get logged in person's host company
                  String strHostCompanyId = com.matrixone.apps.common.Person.getPerson(context).getCompanyId(context);
                  if(strHostCompanyId != null && !"null".equals(strHostCompanyId) && !"".equals(strHostCompanyId))
                  {
                     if("Supplier".equalsIgnoreCase(companyType))
                      {
                          String relSupplier= PropertyUtil.getSchemaProperty(context, "relationship_Supplier");
                          //Connect Company(Supplier) to Host Company
                          company.addFromObject(context, new RelationshipType(relSupplier), strHostCompanyId);
                      }
                      else if("Customer".equalsIgnoreCase(companyType))
                      {
                          String relCustomer= PropertyUtil.getSchemaProperty(context, "relationship_Customer");
                          //Connect Company(Customer) to Host Company
                          company.addFromObject(context, new RelationshipType(relCustomer), strHostCompanyId);
                      }
                  }
            }
            //end

            company.promote(context);
            //company.setDescription(sDescription);
            company.setDescription(context,sDescription);
            BusinessObjectAttributes boAttrGeneric = company.getAttributes(context);
            AttributeItr attrItrGeneric   = new AttributeItr(boAttrGeneric.getAttributes());
            AttributeList attrListGeneric = new AttributeList();

            String sAttrName = "";
            String sAttrValue = "";
            String sTrimVal   = "";
            String sVaultName = "";
            while (attrItrGeneric.next())
            {
              Attribute attrGeneric = attrItrGeneric.obj();
              sAttrName = attrGeneric.getName();
              sAttrValue = (String)formBean.getElementValue(sAttrName);
              if(sAttrName.equals(attrSecondaryVaults))
              {
                  sAttrValue = (String)formBean.getElementValue( attrSecondaryVaults);

                  if (sAttrValue != null)
                  {

                    StringList vaultList = FrameworkUtil.split(sAttrValue,",");
                    StringItr  vaultItr  = new StringItr(vaultList);
                    StringList secondaryVaultList = new StringList();
                    while( vaultItr.next() )
                    {
                      sVaultName = (String)vaultItr.obj();
                      String vault = FrameworkUtil.getAliasForAdmin(context,"vault", sVaultName, true);
					  //Bug 306725 Fix Start
                      if((sVaultName!=null && !"".equals(sVaultName.trim())) && (vault==null || "".equals(vault.trim())))
                      {
                        vault = FrameworkUtil.getAliasForAdmin(context,"vault", sVaultName, false);
                      }
					  //Bug 306725 Fix End
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
                        strBufSecondaryVaultMessage.append(sVaultName);
                      }
                    }
		    final String secondaryVaultStr = FrameworkUtil.join(secondaryVaultList,"~");
                    attrGeneric.setValue(secondaryVaultStr);
                    attrListGeneric.addElement(attrGeneric);
                  }
              }
              else if(sAttrName.equals(attrOrgId) )
                  {
                      if(sAttrValue != null && !"".equals(sAttrValue))
                      {
                        sTrimVal = sAttrValue.trim();
                        attrGeneric.setValue(sTrimVal);
                        attrListGeneric.addElement(attrGeneric);
                      }
                  }
              else {
                if(sAttrValue != null)
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
                    attrListGeneric.addElement(attrGeneric);
                }

              }
            }

            //Update the attributes on the Business Object

            //Bug 337556 - Start
            Attribute attrOrganizationName = new Attribute(new AttributeType(attributeOrganizationName), sName);
            attrListGeneric.addElement(attrOrganizationName);
            //Bug 337556 - End
            company.setAttributes(context, attrListGeneric);
            ClientTaskList listNotices = context.getClientTasks();
            ClientTaskItr itrNotices = new ClientTaskItr(listNotices);
            while (itrNotices.next()) {
                ClientTask clientTaskMessage = itrNotices.obj();
                String sTaskData = (String) clientTaskMessage.getTaskData();
            	if(sTaskData.contains("Warning #1501905")){
            		continue;
            	}else {
            		 throw new Exception("");
            	}
            }
                
              //Added:01-June-2010:s4e:R210 PRG:AdvanceResourcePlanning  
                if(standardCost != null && !"null".equals(standardCost)){
                	company.setAttributeValue(context, sStandardCost, stdCostWithCurrency); 
                }     
              //End:01-June-2010:s4e:R210 PRG:AdvanceResourcePlanning
              
            company.update(context);
            strCompanyId = company.getId();
                      
            // Added:6-Nov-08:oef:R207:PRG Resource Planning 
            String strResourceManagerIDs = (String)formBean.getElementValue("ResourceManagerID");

           if (null == strResourceManagerIDs
                    || "null".equals(strResourceManagerIDs)
                    || "".equals(strResourceManagerIDs.trim())) {
                strResourceManagerIDs = "";
            }

            StringList slSelectedResourceManagers = FrameworkUtil.split(strResourceManagerIDs, ",");

            com.matrixone.apps.common.Organization organization = new com.matrixone.apps.common.Organization (strCompanyId);
            organization.assignResourceManagers(context,
                    slSelectedResourceManagers);
            //End:R207:PRG Autonomy Search businessUnitId

            
            company.close(context);
            ContextUtil.commitTransaction(context);
              } catch (Exception ex) {
                ContextUtil.abortTransaction(context);
                ex.printStackTrace();
                bBackPage = true;
              }
         }
        
        else
        {
            strMessage = EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource", context.getLocale(), "emxComponents.CreateOrEditCompany.CompanyNameAlreadyExists1") + sName + EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource", context.getLocale(), "emxComponents.CreateOrEditCompany.CompanyNameAlreadyExists2");
            session.setAttribute("error.message", strMessage);
            isNotUnique = false;
            bBackPage = true;
        }
    } // else if

        if ( company == null )
        {
            if (session.getAttribute("error.message") == null )
            {
              session.setAttribute("error.message", ComponentsUtil.i18nStringNow("emxComponents.CompanyDialog.ErrorInCreatingCompany", languageStr));
            }
            closePage = true;
        }

        /**
         * Determine if we are doing an FTP transfer or an HTTP Transfer
         */
    }

    // If any error while Creating the Company go Back to Dialog page
    if(bBackPage)
    {
%>
        <script language="javascript">
          getTopWindow().document.location.href="emxComponentsCreateCompanyDialogFS.jsp?<%=strBufQueryString.toString()%>";
        </script>
<%
    }
    else if(closePage)
    {
%>
        <script language="javascript">
        //XSSOK
          alert("<%=session.getAttribute("error.message")%>");
          getTopWindow().closeWindow();
        </script>
<%
        session.removeAttribute("error.message");
    }
    else
    {
        String treeUrl = UINavigatorUtil.getCommonDirectory(context)+ "/emxTree.jsp?emxSuiteDirectory="+appDirectory + "&objectId=" + strCompanyId;

        if (isSubsidiaryCreate!=null && "true".equals(isSubsidiaryCreate))
        {
            treeUrl += "&companyId=" + parentId;
        }

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

            MqlUtil.mqlCommand(context,"warning $1",strBufStoreMessage.toString());
        }

        requestMap.put("objectId", strCompanyId);
        request.setAttribute("requestMap", requestMap);
%>

        <script language="javascript">
			 //getTopWindow().getWindowOpener().document.location.href = getTopWindow().getWindowOpener().document.location.href;
        loadTreeNode("<%=XSSUtil.encodeForJavaScript(context,strCompanyId)%>", "<%=XSSUtil.encodeForJavaScript(context,parentId)%>", null, "<%=XSSUtil.encodeForJavaScript(context, appDirectory)%>", true, "<%=XSSUtil.encodeForJavaScript(context, treeUrl)%>");
	    parent.window.closeWindow();
        </script>
<%
        // Following code is to remove the values from formBean
        Iterator test = formBean.getElementNames();
        String name = "";
        while(test.hasNext())
        {
            name = (String) test.next();
            formBean.setElementValue(name,"");
        }
        formBean.removeFormInstance(session,request);
        session.removeAttribute(keyCompany);
        //------------------------------------
    }
%>
<%@include file = "emxComponentsDesignBottomInclude.inc"%>
<%@include file = "../emxUICommonEndOfPageInclude.inc" %>


