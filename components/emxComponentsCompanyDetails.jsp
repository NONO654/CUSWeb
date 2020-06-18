<%-- emxComponentsCompanyDetails.jsp -- This page displays the details of a company.

  Copyright (c) 1992-2018 Dassault Systemes.All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

     static const char RCSID[] = "$Id: emxComponentsCompanyDetails.jsp.rca 1.18 Wed Oct 22 16:18:57 2008 przemek Experimental przemek $";
--%>

<%@include file = "emxComponentsDesignTopInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%@include file = "emxComponentsVisiblePageInclude.inc"%>


<%
  // Get actual admin names.
  String attrOrgName             = PropertyUtil.getSchemaProperty(context, "attribute_OrganizationName");
  String attrOrgId               = PropertyUtil.getSchemaProperty(context, "attribute_OrganizationID");
  String attrCageCode            = PropertyUtil.getSchemaProperty(context, "attribute_CageCode");
  String attrDUNS                = PropertyUtil.getSchemaProperty(context, "attribute_DUNSNumber");
  String attrWebSite             = PropertyUtil.getSchemaProperty(context, "attribute_WebSite");
  String attrFTPHost             = PropertyUtil.getSchemaProperty(context, "attribute_FTPHost");
  String attrFTPDirectory        = PropertyUtil.getSchemaProperty(context, "attribute_FTPDirectory");
  String attrOrgPhone            = PropertyUtil.getSchemaProperty(context, "attribute_OrganizationPhoneNumber");
  String attrOrgFax              = PropertyUtil.getSchemaProperty(context, "attribute_OrganizationFaxNumber");
  String attrFileStoreSymName    = PropertyUtil.getSchemaProperty(context, "attribute_FileStoreSymbolicName");
  String relCollaborationRequest = PropertyUtil.getSchemaProperty(context, "relationship_CollaborationRequest");
  String relCollaborationPartner = PropertyUtil.getSchemaProperty(context, "relationship_CollaborationPartner");
  String typeCompany             = PropertyUtil.getSchemaProperty(context, "type_Company");
  String typeBusinessUnit        = PropertyUtil.getSchemaProperty(context, "type_BusinessUnit");
  String attrAddress             = PropertyUtil.getSchemaProperty(context, "attribute_Address");
  String attrPostalCode          = PropertyUtil.getSchemaProperty(context, "attribute_PostalCode");
  String attrCountry             = PropertyUtil.getSchemaProperty(context, "attribute_Country");
 
  //Added for Organization feature v11.FSP section 4.1.5
  String attrAlternateName   = PropertyUtil.getSchemaProperty(context, "attribute_AlternateName");
  //end

  // Get the page parameters.
  String companyId               = emxGetParameter(request, "objectId");

  //Determine if we should use printer friendly version
  boolean isPrinterFriendly = false;
  String printerFriendly    = emxGetParameter(request, "PrinterFriendly");

  if (printerFriendly != null && "true".equals(printerFriendly) ) {
     isPrinterFriendly = true;
  }

  String relId1 = null;
  String relId2 = null;
  String myOrganizationId =null;
%>

 <script language="javascript">

    function showCollaborate() {
      document.companyDetails.action="emxComponentsCreateCompanyCollaboration.jsp";
      document.companyDetails.submit();
      return;
    }
    function showDeCollaborate() {
      document.companyDetails.action="emxComponentsDeleteCompanyCollaboration.jsp";
      document.companyDetails.submit();
      return;
    }

</script>

<%@include file = "../emxUICommonHeaderEndInclude.inc" %>

<%
  String languageStr 		   = request.getHeader("Accept-Language");
  Locale locale	= context.getLocale();
  String strUnknownOrgId       = EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.Default.Organization_ID", locale);
  String strUnknownPhoneNumber = EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.Default.Organization_Phone_Number", locale);
  String strUnknownFaxNumber   = EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.Default.Organization_Fax_Number", locale);
  String strUnknownWebSite     = EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.Default.Web_Site", locale);
  String strUnknownAddress     = EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.Default.Address", locale);
  
  String strUnknown            = "Unknown";
  
  String strCheckoutUrl     = "";
  int image_found           = 0;
  BusinessObject company = new BusinessObject(companyId);

  company.open(context);
  String vault = company.getVault();
  String companyName = company.getName();
  String companyDesc = company.getDescription();
  String parentCompanyName = "";
  String parentCompanyId = "";  

  StringList objectSelects = new StringList(2);
  objectSelects.addElement(Company.SELECT_ID);  
  objectSelects.addElement(Company.SELECT_NAME);
 
  Company companyObj    = (Company)DomainObject.newInstance(context, companyId);
  String strSecondaryVaults = companyObj.getSecondaryVaults(context);
  Map parentMap = (Map) companyObj.getRelatedObject(context,DomainConstants.RELATIONSHIP_SUBSIDIARY,false,objectSelects,null);
  
  if(parentMap!=null) {
    parentCompanyName = (String) parentMap.get(Company.SELECT_NAME);
    parentCompanyId = (String) parentMap.get(Company.SELECT_ID);
  }
  
  StringList secondaryVaultList = FrameworkUtil.split(strSecondaryVaults,",");
  Iterator itr = secondaryVaultList.iterator();
  String secondaryVaultName = null;
  StringBuffer sVaultName = new StringBuffer();
  while (itr.hasNext()) {
    secondaryVaultName =(String)itr.next();
    sVaultName.append(i18nNow.getAdminI18NString("Vault",secondaryVaultName,languageStr));
    sVaultName.append(",");
  }
  if(sVaultName.length() > 0) {
      sVaultName.deleteCharAt(sVaultName.length()-1);
  }
  
  strSecondaryVaults = sVaultName.toString();

  String companyCurrentState = FrameworkUtil.getCurrentState(context,company).getName();
  String strFileFormat = company.getDefaultFormat(context);
  FileItr fileItr = new FileItr( company.getFiles(context,strFileFormat));
  String strFileName = null;
  if ( fileItr.next() ) {
    image_found = 1;
    strFileName = fileItr.obj().getName();
  }

  //Removed references to the deprecated Servlet "FileCheckoutServlet" as part of V6R2011x

  
  if (strCheckoutUrl==null) {
    strCheckoutUrl ="";
  }

  // is this company active
  boolean isActive = true;
  if (companyCurrentState.equals("Inactive")){
    isActive = false;
  }

  HashMap attributesMap = ComponentsUtil.getAttributesIntoHashMap(context, company);
  
  company.close(context);

  /*
   * Determine access and buttons to show.
   */

  boolean editAccess = false;
  ArrayList buttonUrlList = new ArrayList();
  ArrayList buttonImageList = new ArrayList();

  String myCompanyId = null;
  String url = null;
  String image = null;
  String relCollabs = relCollaborationRequest + "," + relCollaborationPartner;

  BusinessObject myPerson  = JSPUtil.getPerson(context, session);
  BusinessObject myCompany = Company.getCompanyForRep(context,myPerson);

  BusinessObject myOrganization = null;
  if(myCompany != null) {
  // Access my company business object.
  myCompany.open(context);

  myCompanyId = myCompany.getObjectId();

  // Case 1:If you are Company Rep, If this is not my company, then display a collaborate button.
  // Case 2:If you are BU rep, the company to which BU is division of, is not this company ,
  // then display a collaborate button.
  // find whether you are Company Representative or BusinessUnit Representative

  if ( myCompany.getTypeName().equals(typeCompany)) {
    myOrganizationId = myCompanyId;
  } else if ( myCompany.getTypeName().equals(typeBusinessUnit)) {
    myOrganization = JSPUtil.getOrganization(context,  session, myPerson);
    myOrganizationId = myOrganization.getObjectId();
  }
  if ((! companyId.equals(myOrganizationId)) && (isActive)){
    // If we are collaborating, then show the de-collaboration button.
    // Otherwise, show the collaboration button.
    ArrayList collabRelList = JSPUtil.getCollaborationRels(context, session, company, myCompany);
    if(collabRelList != null && collabRelList.size() > 0){
      Iterator collabRelIterator = collabRelList.iterator();
      while(collabRelIterator.hasNext()){
        relId1 = (String)collabRelIterator.next();
        while(collabRelIterator.hasNext()){
          relId2 = (String)collabRelIterator.next();
        }
      }
    }

  }
  } else {
    com.matrixone.apps.common.Person contextPerson = com.matrixone.apps.common.Person.getPerson(context);
    myCompany = contextPerson.getCompany(context);
  }
  String policy = myCompany.getPolicy(context).getName();

  // Close my company business object.
  myCompany.close(context);
%>

<form name="companyDetails" method="post">
<input type="hidden" name="relId1" value="<xss:encodeForHTMLAttribute><%=relId1%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="relId2" value="<xss:encodeForHTMLAttribute><%=relId2%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="companyId" value="<xss:encodeForHTMLAttribute><%=companyId%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="myCompanyId" value="<xss:encodeForHTMLAttribute><%=myOrganizationId%></xss:encodeForHTMLAttribute>" />

<table class="border" border="0" cellpadding="1" cellspacing="0" width="100%" align="center" class="formBG">
  <tr>
    <td>

    <table class="dialogback" border="0" cellpadding="0" cellspacing="0" width="100%">
      <tr>
        <td>

        <table border="0" cellpadding="3" cellspacing="2" width="100%">
          <tr>
            <td align="left"  width="200" nowrap class="label"><emxUtil:i18n localize="i18nId">emxComponents.CompanyDialog.Image</emxUtil:i18n></td>
            <td class="Field">
<%
    if(!strCheckoutUrl.equals("")) {
%>
		<!-- //XSSOK -->
        <img src="<%=Framework.encodeURL(response, strCheckoutUrl)%>" name="imgGeneric" id="imgGeneric" alt="*" width="164" height="100" />
<%
    }
%>
           &nbsp;</td>          </tr>
        
          <tr>
            <td align="left"  width="200" nowrap class="label"><emxUtil:i18n localize="i18nId">emxComponents.Common.Name</emxUtil:i18n></td>
            <td class="field" align="left"><%=XSSUtil.encodeForHTML(context, companyName)%>&nbsp;</td>
          </tr>
  <tr>
      <td nowrap  width="150" class="label"><label for="parentName"><emxUtil:i18n localize="i18nId">emxComponents.CompanyDetails.ParentCompany</emxUtil:i18n></label></td>
         <td class="field" align="left">
<%
    boolean isSubsidiary = false;
    if(parentCompanyId!=null && !"null".equals(parentCompanyId) && parentCompanyId.length() > 0)
    {
        String treeUrl = "../common/emxTree.jsp?emxSuiteDirectory=components&suiteKey=Components&objectId=" + XSSUtil.encodeForHTML(context, parentCompanyId);
        isSubsidiary = true;
%>
        <img src="../common/images/iconSmallCompany.gif" />
<%
        if(!isPrinterFriendly){
%>
			<!-- //XSSOK -->
             <a href="javascript: emxShowModalDialog('<%=treeUrl%>',700, 600)" ><%=XSSUtil.encodeForHTML(context, parentCompanyName)%></a>
<%
            }  else{
%>
            <%=XSSUtil.encodeForJavaScript(context, parentCompanyName)%>
<%
        }
     }
%>
        &nbsp;
      </td>
             
    </tr>
          
          <tr>
            <td align="left"  width="200" nowrap class="label"><emxUtil:i18n localize="i18nId"><%=(isSubsidiary)?"emxComponents.CompanyDetails.SubsidiaryID": "emxComponents.CompanyDetails.CompanyID"%></emxUtil:i18n></td>
            <!-- //XSSOK -->
			<td class="field" align="left"><%= (strUnknown.equals((String)attributesMap.get(attrOrgId)))?strUnknownOrgId:attributesMap.get(attrOrgId) %>&nbsp;</td>
          </tr>

          <tr>
            <td align="left"  width="200" nowrap class="label"><emxUtil:i18n localize="i18nId">emxComponents.CompanyDetails.CageCode</emxUtil:i18n></td>
            <td class="field" align="left"><%= XSSUtil.encodeForHTML(context, (String)attributesMap.get(attrCageCode)) %>&nbsp;</td>
          </tr>

          <tr>
            <td align="left"  width="200" nowrap class="label"><emxUtil:i18n localize="i18nId">emxComponents.CompanyDetails.DunsNumber</emxUtil:i18n></td>
            <td class="field" align="left"><%= XSSUtil.encodeForHTML(context, (String)attributesMap.get(attrDUNS)) %>&nbsp;</td>
          </tr>

          <tr>
            <td align="left"  width="200" nowrap class="label"><emxUtil:i18n localize="i18nId">emxComponents.CompanyDetails.OrgPhone</emxUtil:i18n></td>
            <!-- //XSSOK -->
			<td class="field" align="left"><%= (strUnknown.equals((String)attributesMap.get(attrOrgPhone)))?strUnknownPhoneNumber:XSSUtil.encodeForHTML(context, (String)attributesMap.get(attrOrgPhone)) %>&nbsp;</td>
          </tr>

          <tr>
            <td align="left"  width="200" nowrap class="label"><emxUtil:i18n localize="i18nId">emxComponents.CompanyDetails.OrgFax</emxUtil:i18n></td>
            <!-- //XSSOK -->
			<td class="field" align="left"><%=(strUnknown.equals((String)attributesMap.get(attrOrgFax)))?strUnknownFaxNumber:XSSUtil.encodeForHTML(context, (String)attributesMap.get(attrOrgFax)) %>&nbsp;</td>
          </tr>

          <tr>
            <td align="left"  width="200" nowrap class="label"><emxUtil:i18n localize="i18nId">emxComponents.CompanyDetails.WebSite</emxUtil:i18n></td>
            <td class="field" align="left">
<%
            String strWebSite = (String)attributesMap.get(attrWebSite);
            String strWebSiteHref = strWebSite = strWebSite.toLowerCase();
            if(strWebSite.startsWith("http://") || strWebSite.startsWith("https://")) 
            {
                strWebSite = strWebSite.substring(7);
                if(strWebSite.startsWith("/")) {
                    strWebSite = strWebSite.substring(1);
                }
            }
            else
            {
                strWebSiteHref = "http://"+strWebSite;
            }

            if(!isPrinterFriendly){
%>
            <a target="_blank" href="<%= XSSUtil.encodeForHTML(context, strWebSiteHref) %>"><%= XSSUtil.encodeForHTML(context, (strUnknown.equalsIgnoreCase(strWebSite))?strUnknownWebSite:strWebSite) %></a>&nbsp;</td>
<%
            }  else{
%>
            <%= XSSUtil.encodeForJavaScript(context, strWebSite) %>&nbsp;</td>
<%
            }
%>


          </tr>
<%
          if(Company.isHostRep(context,JSPUtil.getPerson(context,session))){
            String sFileStore =  PropertyUtil.getSchemaProperty(context, (String)attributesMap.get(attrFileStoreSymName));
            if(sFileStore == null || "null".equals(sFileStore)){
              sFileStore = "";
            }

%>
          <tr>
            <td align="left"  width="200" nowrap class="label"><emxUtil:i18n localize="i18nId">emxComponents.CompanyDialog.FileStore</emxUtil:i18n>
            </td>
            <td class="field" align="left"><%=XSSUtil.encodeForHTML(context, i18nNow.getAdminI18NString("Store",sFileStore,languageStr))%>&nbsp;</td>
          </tr>
<%
          }
%>

          <tr>
            <td align="left"  width="200" nowrap class="label"><emxUtil:i18n localize="i18nId">emxComponents.CompanyDetails.FtpHost</emxUtil:i18n>
            </td>
            <td class="field" align="left">
<%
            if(!isPrinterFriendly){
%>
            <a target="_blank" href="<%= XSSUtil.encodeForHTMLAttribute(context, (String)attributesMap.get(attrFTPHost)) %>"><%= XSSUtil.encodeForHTML(context, (String)attributesMap.get(attrFTPHost)) %></a>
<%
            }  else{
%>
            <%= XSSUtil.encodeForHTML(context, (String)attributesMap.get(attrFTPHost)) %>
<%
            }
%>
            &nbsp;</td>

          </tr>

          <tr>
            <td align="left"  width="200" nowrap class="label"><emxUtil:i18n localize="i18nId">emxComponents.CompanyDetails.FtpDir</emxUtil:i18n>
            </td>
            <td class="field" align="left"><%= XSSUtil.encodeForHTML(context, (String)attributesMap.get(attrFTPDirectory)) %>&nbsp;</td>
          </tr>

          <tr>
            <td align="left"  width="200" nowrap class="label"><emxUtil:i18n localize="i18nId">emxComponents.Common.State</emxUtil:i18n>
            </td>
            <td class="field" align="left"><%= XSSUtil.encodeForHTML(context, i18nNow.getStateI18NString(policy,companyCurrentState,languageStr)) %>&nbsp;</td>
          </tr>

          <tr>
            <td align="left"  width="200" nowrap class="label"><emxUtil:i18n localize="i18nId">emxComponents.Common.Description</emxUtil:i18n></td>
            <td class="field" align="left"><%= XSSUtil.encodeForHTML(context, companyDesc) %>&nbsp;</td>
          </tr>

          <tr>
            <td align="left"  width="200" nowrap class="label"><emxUtil:i18n localize="i18nId">emxComponents.CompanyDetails.PrimaryVault</emxUtil:i18n></td>
            <td class="field" align="left"><%=XSSUtil.encodeForHTML(context, i18nNow.getAdminI18NString("Vault",vault,languageStr))%>&nbsp;</td>
          </tr>

  <tr>
      <td nowrap  width="150" class="label"><label for="SecondaryVaultName"><emxUtil:i18n localize="i18nId">emxComponents.CompanyDetails.SecondaryVaults</emxUtil:i18n></label></td>
      <td class="field">
          <%= XSSUtil.encodeForHTML(context, (strSecondaryVaults == null?"":strSecondaryVaults)) %>&nbsp;
       </td>
    </tr>

          <tr>
            <td align="left"  width="200" nowrap class="label"><emxUtil:i18n localize="i18nId">emxComponents.CompanyDetails.Address</emxUtil:i18n></td>
            <!-- //XSSOK -->
			<td class="field" align="left"><%= (strUnknown.equals((String)attributesMap.get(attrAddress)))?strUnknownAddress:XSSUtil.encodeForHTML(context, (String)attributesMap.get(attrAddress)) %>&nbsp;</td>
          </tr>

          <tr>
            <td align="left"  width="200" nowrap class="label"><emxUtil:i18n localize="i18nId">emxComponents.CompanyDetails.PostalCode</emxUtil:i18n></td>
            <td class="field" align="left"><%= XSSUtil.encodeForHTML(context, (String)attributesMap.get(attrPostalCode)) %>&nbsp;</td>
          </tr>

          <tr>
            <td align="left"  width="200" nowrap class="label"><emxUtil:i18n localize="i18nId">emxComponents.CompanyDetails.Country</emxUtil:i18n></td>
            <td class="field" align="left"><%= XSSUtil.encodeForHTML(context, (String)attributesMap.get(attrCountry)) %>&nbsp;</td>
          </tr>
      <%
          //Added for Organization feature v11.FSP section 4.1.5
          //check for supplier company connected to host with Supplier relatioship
          StringList supList = companyObj.getInfoList(context,"to["+DomainObject.RELATIONSHIP_SUPPLIER+"].from.id");
          if(supList !=null && !supList.equals("null") && supList.size() >0)
          {
      %>
          <tr>
           <td align="left"  width="200" nowrap class="label">
           <emxUtil:i18n localize="i18nId">emxComponents.CompanyDetails.AlternateSupplierNames</emxUtil:i18n></td>
           <td class="field" align="left"><%= XSSUtil.encodeForHTML(context, (String)attributesMap.get(attrAlternateName)) %>&nbsp;</td>
          </tr>
      <%
          }
          //end
      %>
        </table>

          </td>
        </tr>
      </table>
    </td>
  </tr>
</table>
</form>
<%@ include file="emxComponentsCommitTransaction.inc"%>

<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
