
<%--  emxComponentsCreateCompanyDialog.jsp --Create Company dialog

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxComponentsCreateCompanyDialog.jsp.rca 1.38 Tue Oct 28 23:01:03 2008 przemek Experimental przemek $
--%>

<%@include file = "emxComponentsDesignTopInclude.inc"%>
<%@include file = "emxComponentsVisiblePageInclude.inc"%>
<%@include file = "emxComponentsJavaScript.js"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "eServiceUtil.inc"%>
<%@include file = "../emxJSValidation.inc" %>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkUtil"%>

<jsp:useBean id="formBean" scope="session" class="com.matrixone.apps.common.util.FormBean"/>

<% 
  String keyCompany = emxGetParameter(request,"keyCompany");
  //Added for Organization feature v11
  String companyType = emxGetParameter(request,"companyType");
  //end
  String attrOrgId               = PropertyUtil.getSchemaProperty(context, "attribute_OrganizationID");
  String attrCageCode            = PropertyUtil.getSchemaProperty(context, "attribute_CageCode");
  String attrDUNS                = PropertyUtil.getSchemaProperty(context, "attribute_DUNSNumber");
  String attrWebSite             = PropertyUtil.getSchemaProperty(context, "attribute_WebSite");
  String attrFTPHost             = PropertyUtil.getSchemaProperty(context, "attribute_FTPHost");
  String attrFTPDirectory        = PropertyUtil.getSchemaProperty(context, "attribute_FTPDirectory");
  String attrOrgPhone            = PropertyUtil.getSchemaProperty(context, "attribute_OrganizationPhoneNumber");
  String attrOrgFax              = PropertyUtil.getSchemaProperty(context, "attribute_OrganizationFaxNumber");

//  String attrMeetingSiteName     = PropertyUtil.getSchemaProperty(context, "attribute_MeetingSiteName");
//  String attrMeetingSiteId       = PropertyUtil.getSchemaProperty(context, "attribute_MeetingSiteID");
  String attrFileStoreSymName    = PropertyUtil.getSchemaProperty(context, "attribute_FileStoreSymbolicName");
  String attrSecondaryVault      = PropertyUtil.getSchemaProperty(context, "attribute_SecondaryVaults");
  String attrAddress             = PropertyUtil.getSchemaProperty(context, "attribute_Address");
  String attrPostalCode          = PropertyUtil.getSchemaProperty(context, "attribute_PostalCode");
  String attrCountry             = PropertyUtil.getSchemaProperty(context, "attribute_Country");
  String sStandardCost          = PropertyUtil.getSchemaProperty(context, "attribute_StandardCost");
  String sCurrency    = "";
  //Added for Organization feature v 11
  String attrAlternateName   = PropertyUtil.getSchemaProperty(context, "attribute_AlternateName");
  //end
  //check to see if Cage Code is unique 
  String isUniqueCageCode        = "";
  String languageStr = request.getHeader("Accept-Language");
  
	boolean isPMCInstalled =  FrameworkUtil.isSuiteRegistered(context,"appVersionProgramCentral",false,null,null);
	
  boolean bEdit          = false;
  boolean isHostRep          = false;
  boolean isSubsidiaryEdit = false;
  StoreList storeList        = new StoreList();
  Iterator storeListItr;
  String storeName         = "";
  String strChecked        = "";
  String strCompStoreName        = "";
  Locale locale				   = context.getLocale();
  String strUnknown            = "Unknown";
  String strUnknownFaxNumber   = EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.Default.Organization_Fax_Number", locale);
  String strUnknownPhoneNumber = EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.Default.Organization_Phone_Number", locale);
  String strUnknownWebSite     = EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.Default.Web_Site", locale);
  String strUnknownAddress     = EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.Default.Address", locale);

  // check to see whether Webex is enabled
//  String isWebExEnabled = "";
//  isWebExEnabled = JSPUtil.getApplicationProperty(application,"emxComponents.enableWebEx");
  String typeCompany = PropertyUtil.getSchemaProperty(context, "type_Company");
 
  isUniqueCageCode=EnoviaResourceBundle.getProperty(context,"emxComponents.cageCode.Uniqueness");

   // Brought to this place for bug no. 302913
  String isSubsidiaryCreate       = (String)formBean.getElementValue("isSubsidiaryCreate");
  String companyId = "";
  companyId = (String)formBean.getElementValue("objectId");

/*  if( isWebExEnabled == null){
    isWebExEnabled = "true";
  }*/

  if( isUniqueCageCode!=null && isUniqueCageCode.trim().equalsIgnoreCase("true")) {
      isUniqueCageCode = "true";
  } else {
      isUniqueCageCode = "false";
  } 

  int allowedDunsDigit = Integer.parseInt(EnoviaResourceBundle.getProperty(context,"emxComponents.allowedDUNSNumberDigitDisplay"));
  boolean isOnPremise  = FrameworkUtil.isOnPremise(context);
    String companyName              = "";
    String strAttrCompanyId         = "";
    String companyDesc              = "";
    String companyVault             = "";
    String sState                   = "";
    Company company                 = null;
    String FromActionsTab           = (String)formBean.getElementValue("FromActionsTab");
    String parentCompanyName        = "";
    String strSecondaryVaults       = "";
    String parentCompanyId          = "";
    String strAttrCageCode          = "";
    String strAttrDunsNumber        = "";
    String strAttrPhoneNumber       = "";
    String strAttrFaxNumber         = "";
    String strAttrWebSite           = "";
    String strAttrFTPHost           = "";
    String strAttrFTPDirectory      = "";
    String strAttrMeetingSiteName   = "";
    String strAttrMeetingSiteId     = "";
    String strAddress               = "";
    String strPostalCode            = "";
    String strCountry               = "";
    String standardCost   = "0.0";
    String currencyUnit   = "";
    //Error message for string length
    String errMessage=EnoviaResourceBundle.getProperty(context,"emxFrameworkStringResource",context.getLocale(), "emxFramework.Create.NameColumn");
    //Added for Organization feature v 11
    String strAlternateName   = "";
    //end
    StringList objectSelects = new StringList(2);
    objectSelects.addElement(Company.SELECT_ID);
    objectSelects.addElement(Company.SELECT_NAME);

    HashMap attributesMap  = new HashMap();
    String targetPage ="emxComponentsCreateCompanyProcess.jsp";
    String strFileName = "";
    isHostRep = Company.isHostRep(context,JSPUtil.getPerson(context,session));

    if(companyId != null && !"".equals(companyId) && !"null".equals(companyId) && !"true".equals(isSubsidiaryCreate)) 
    {
        bEdit = true;
        // Access and open the company business object.
        company = (Company)DomainObject.newInstance(context, companyId);
        company.open(context);
        companyName = company.getName();
        //companyDesc = company.getDescription();
        companyDesc = company.getInfo(context,DomainConstants.SELECT_DESCRIPTION);
        companyVault=company.getVault();
        sState = FrameworkUtil.getCurrentState(context,company).getName();

        String strFileFormat = company.getDefaultFormat(context);
        FileItr fileItr = new FileItr( company.getFiles(context,strFileFormat));

        if ( fileItr.next() ) 
        {
            strFileName = fileItr.obj().getName();
        }

        // Create an attribute hashmap.
        attributesMap = ComponentsUtil.getAttributesIntoHashMap(context, company);
        company.close(context);

        targetPage ="emxComponentsEditCompany.jsp";

        strCompStoreName = PropertyUtil.getSchemaProperty(context, (String)attributesMap.get(attrFileStoreSymName));

        strSecondaryVaults = company.getSecondaryVaults(context);
        Map parentMap = (Map) company.getRelatedObject(context,DomainConstants.RELATIONSHIP_SUBSIDIARY,false,objectSelects,null);

        if(parentMap!=null) 
        {
            parentCompanyId = (String) parentMap.get(Company.SELECT_ID);
            parentCompanyName = (String) parentMap.get(Company.SELECT_NAME);
            if(parentCompanyId!=null && !"null".equals(parentCompanyId) && parentCompanyId.length() > 0)
            {
                isSubsidiaryEdit = true;
            }
        }

        StringList secondaryVaultList = FrameworkUtil.split(strSecondaryVaults,",");
        Iterator itr = secondaryVaultList.iterator();
        String secondaryVaultName = "";
        StringBuffer sVaultName = new StringBuffer();
        while (itr.hasNext()) 
        {
            secondaryVaultName =(String)itr.next();
            sVaultName.append(secondaryVaultName);
            sVaultName.append(",");
        }
        if(sVaultName.length() > 0) 
        {
            sVaultName.deleteCharAt(sVaultName.length()-1);
        }

        strSecondaryVaults = sVaultName.toString();
    }
    else
    {
        companyName = (String)formBean.getElementValue("txtName");
        if(companyName == null || "null".equals(companyName))
        {
            companyName = "";
        }
        
        strAttrCompanyId = (String)formBean.getElementValue(attrOrgId);
        if(strAttrCompanyId == null || "null".equals(strAttrCompanyId))
        {
            strAttrCompanyId = "";
        }
        strAttrCageCode = (String)formBean.getElementValue(attrCageCode);
        if(strAttrCageCode == null || "null".equals(strAttrCageCode))
        {
            strAttrCageCode = "";
        }
        strAttrDunsNumber = (String)formBean.getElementValue(attrDUNS);
        if(strAttrDunsNumber == null || "null".equals(strAttrDunsNumber))
        {
            strAttrDunsNumber = "";
        }
        strAttrPhoneNumber = (String)formBean.getElementValue(attrOrgPhone);
        if(strAttrPhoneNumber == null || "null".equals(strAttrPhoneNumber))
        {
            strAttrPhoneNumber = "";
        }
        strAttrFaxNumber = (String)formBean.getElementValue(attrOrgFax);
        if(strAttrFaxNumber == null || "null".equals(strAttrFaxNumber))
        {
            strAttrFaxNumber = "";
        }
        strAttrWebSite = (String)formBean.getElementValue(attrWebSite);
        if(strAttrWebSite == null || "null".equals(strAttrWebSite))
        {
            strAttrWebSite = "";
        }
        strCompStoreName = (String)formBean.getElementValue(attrFileStoreSymName);
        if(strCompStoreName == null || "null".equals(strCompStoreName))
        {
            strCompStoreName = "";
        }
        strAttrFTPHost = (String)formBean.getElementValue(attrFTPHost);
        if(strAttrFTPHost == null || "null".equals(strAttrFTPHost))
        {
            strAttrFTPHost = "";
        }
        strAttrFTPDirectory = (String)formBean.getElementValue(attrFTPDirectory);
        if(strAttrFTPDirectory == null || "null".equals(strAttrFTPDirectory))
        {
            strAttrFTPDirectory = "";
        }
        companyDesc = (String)formBean.getElementValue("description");
        if(companyDesc == null || "null".equals(companyDesc))
        {
            companyDesc = "";
        }
        strAddress = (String)formBean.getElementValue(attrAddress);
        if(strAddress == null || "null".equals(strAddress))
        {
            strAddress = "";
        }
        strPostalCode = (String)formBean.getElementValue(attrPostalCode);
        if(strPostalCode == null || "null".equals(strPostalCode))
        {
            strPostalCode = "";
        }
        strCountry = (String)formBean.getElementValue(attrCountry);
        if(strCountry == null || "null".equals(strCountry))
        {
            strCountry = "";
        }
        
        //Added for Organization feature v 11
        strAlternateName =(String)formBean.getElementValue(attrAlternateName);
        if(strAlternateName == null || "null".equals(strAlternateName))
        {
            strAlternateName   = "";
        }
        //end
    }

%>

<script language="javascript">

  function trimStr(str){
    while(str.length != 0 && str.substring(0,1) == ' '){
      str = str.substring(1);
    }
    while(str.length != 0 && str.substring(str.length -1) == ' '){
      str = str.substring(0, str.length -1);
    }
    return str;
  }

function updateParent(parentId, parentName)
{
   document.createDialog.parentName.value = parentName;
   document.createDialog.parentId.value = parentId;

}
  function submitForm() {
      if(jsIsClicked()) {
          alert("<emxUtil:i18nScript  localize="i18nId">emxComponents.Search.RequestProcessMessage</emxUtil:i18nScript>");
          return;
      }

    var bWebExEnabled   = false;
    var bSiteName     = false;
    var f         = document.createDialog;
    var orgName       = f["txtName"];
    var dunsNumber    = f["<%= XSSUtil.encodeForJavaScript(context,attrDUNS) %>"];
    var webSite       = f["<%= XSSUtil.encodeForJavaScript(context,attrWebSite) %>"];
	<%if(isOnPremise){%>
	    var txtCompanyId  = f["<%=XSSUtil.encodeForJavaScript(context,attrOrgId)%>"];
	    var cageCode      = f["<%=XSSUtil.encodeForJavaScript(context, attrCageCode) %>"];
    var store       = f["<%=XSSUtil.encodeForJavaScript(context, attrFileStoreSymName) %>"];
    //XSSOK
	var isCageCode = <%=isUniqueCageCode %>;
	<%}%>
    var webSiteValue  = trimStr(webSite.value);
    webSite.value     = webSiteValue;
    webSiteValue    = webSiteValue.toLowerCase();

    var namebadCharName = checkForNameBadCharsList(document.createDialog.txtName);
    var nameLengthcheck = checkValidLength(orgName.value,"Organization");
    if (namebadCharName.length != 0){
      alert("<emxUtil:i18nScript localize="i18nId">emxComponents.Common.AlertInValidChars</emxUtil:i18nScript>"+namebadCharName+"<emxUtil:i18nScript localize="i18nId">emxComponents.Common.AlertRemoveInValidChars</emxUtil:i18nScript>");
      document.createDialog.txtName.focus();
      return;
    }
    if(!nameLengthcheck){    	
    	alert("<%=errMessage%>");
    	document.createDialog.txtName.focus();
        return;
    }
    <%if(isOnPremise){%>
    namebadCharName = checkForNameBadCharsList(cageCode);
    if (namebadCharName.length != 0)
    {
      alert("<emxUtil:i18nScript localize="i18nId">emxComponents.Common.AlertInValidChars</emxUtil:i18nScript>"+namebadCharName+"<emxUtil:i18nScript localize="i18nId">emxComponents.Common.AlertRemoveInValidChars</emxUtil:i18nScript>");
      cageCode.focus();
      return;
    }
    <%}%>

    var descBadCharName = checkForBadChars(document.createDialog.description);
    orgName.value = trimStr(orgName.value);
    <%if(isOnPremise){%>
    orgIdValue = jsTrim(txtCompanyId.value);
    //Added for bug 356377
 	var orgLen = orgIdValue.replace(/[.]/g, '');
    txtCompanyId.value = orgIdValue;
    cageCode.value = jsTrim(cageCode.value);
    cageCodeValue = jsTrim(cageCode.value);
	<%}%>
    dunsNumber.value = jsTrim(dunsNumber.value);  
    if (orgName.value.length == 0) {
      alert("<emxUtil:i18nScript localize="i18nId">emxComponents.CompanyDialog.EnterName</emxUtil:i18nScript>");
      document.createDialog.txtName.focus();
      return;
    } else if (<%=isOnPremise%> && !isAlphanumeric(orgIdValue, true)) {
      alert("<emxUtil:i18nScript localize="i18nId">emxComponents.CompanyDialog.PleaseTypeAlphaNumeric</emxUtil:i18nScript>"+ " <%= XSSUtil.encodeForJavaScript(context, i18nNow.getAttributeI18NString(attrOrgId,languageStr))%>.");
      txtCompanyId.focus();
      return; 
    } //XSSOK
    else if( <%=isOnPremise%> && "true" == "<%=isUniqueCageCode%>" && cageCodeValue.length == 0 ) {
        alert("<emxUtil:i18nScript localize="i18nId">emxComponents.CompanyDialog.EnterCageCode</emxUtil:i18nScript>");
        cageCode.select();
        cageCode.focus();
        return;
    } else if(dunsNumber.value < 0 ) {
      alert("<%= XSSUtil.encodeForJavaScript(context, i18nNow.getAttributeI18NString(attrDUNS,languageStr)) %> " + "<emxUtil:i18nScript localize="i18nId">emxComponents.CompanyDialog.PositiveNumber</emxUtil:i18nScript>");
      dunsNumber.focus();
      return;
    } else if(dunsNumber.value.length > '<%=allowedDunsDigit%>') {
      alert("<%= XSSUtil.encodeForJavaScript(context, i18nNow.getAttributeI18NString(attrDUNS,languageStr)) %> " + "<emxUtil:i18nScript localize="i18nId">emxComponents.Common.allowedDunsNumber</emxUtil:i18nScript>"+'<%=allowedDunsDigit%>');
      dunsNumber.focus();
      return;
    } else if(/\s/.test(webSite.value)) {
      alert("<emxUtil:i18nScript localize="i18nId">emxComponents.CompanyDialog.Invalid</emxUtil:i18nScript>"+ "<%= XSSUtil.encodeForJavaScript(context, i18nNow.getAttributeI18NString(attrWebSite,languageStr))%>.");
      webSite.focus();
      return;
    } else if (descBadCharName.length != 0) {
        alert("<emxUtil:i18nScript localize="i18nId">emxComponents.Common.AlertInValidChars</emxUtil:i18nScript>"+descBadCharName+"<emxUtil:i18nScript localize="i18nId">emxComponents.Common.AlertRemoveInValidChars</emxUtil:i18nScript>");
        document.createDialog.description.focus();
        return;
    }

    if (jsDblClick()) {
        f.submit();
    }
    return;
  }

function closeWindow() 
{
    getTopWindow().location.href="emxComponentsCompanyDialogClose.jsp?keyCompany=<%=XSSUtil.encodeForURL(context, keyCompany)%>";
}


function showVaultSelector()
{
    showChooser('../common/emxVaultChooser.jsp?fieldNameActual=vaultName&fieldNameDisplay=vaultNameDisplay&action=createCompany&multiSelect=false');
}

function clearSecondaryVaults() {
    document.createDialog.secondaryVaults.value = "";
    document.createDialog.secondaryVaultsDisplay.value = "";
    return;
}

function clearParent() {
    document.createDialog.parentName.value = "";
    document.createDialog.parentId.value = "";
    return;
}

function showParentCompanySelector()
{
	var searchURL = "../common/emxFullSearch.jsp?field=TYPES=type_Company:CURRENT=policy_Organization.state_Active&chooserType=CustomChooser&submitAction=refreshCaller&fieldNameOID=parentNameOID&relId=&suiteKey=Components&showInitialResults=false&submitURL=AEFSearchUtil.jsp&table=AEFGeneralSearchResults&fieldNameDisplay=parentNameDisplay&fieldNameActual=parentName&hideHeader=true&selection=single&mode=Chooser&targetLocation=popup";
	showModalDialog(searchURL, 600, 500);
}


  function showSecondaryVaultsSelector() {
<%
    if( bEdit )
    {
%>
      alert("<emxUtil:i18nScript localize="i18nId">emxComponents.CompanyDialog.SecondaryVaultAlertMessage</emxUtil:i18nScript>");
      showChooser('../common/emxVaultChooser.jsp?fieldNameActual=secondaryVaults&fieldNameDisplay=secondaryVaultsDisplay&action=editCompany&objectId=<%=XSSUtil.encodeForURL(context, companyId)%>');  
<%
    }
    else
    {
%>
      showChooser('../common/emxVaultChooser.jsp?fieldNameActual=secondaryVaults&fieldNameDisplay=secondaryVaultsDisplay&action=createCompany');    
<%
    }
%>
  }
  function displaymessage(eventObj)
  {
    if(eventObj.keyCode != '9')
    {
        alert("<emxUtil:i18nScript localize="i18nId">emxComponents.Common.BrowseWithButton</emxUtil:i18nScript>");
        return false;
    }
    return true;
  }
  
  <%-- Added:4-Nov-08:oef:R207:PRG Resource Planning --%>
   function showResourceManagerSelector()
    {
    var objCommonAutonomySearch = new emxCommonAutonomySearch();
       //[Modified::Jan 11, 2011:s4e:R211:IR-079535V6R2012 ::Start]    
       objCommonAutonomySearch.txtType = "type_Person&form=AEFSearchPersonForm";
       //[Modified::Jan 11, 2011:s4e:R211:IR-079535V6R2012 ::End] 
	   objCommonAutonomySearch.selection = "multiple";
	   objCommonAutonomySearch.onSubmit = "getTopWindow().getWindowOpener().submitAutonomySearchResourceManager"; 
	   objCommonAutonomySearch.excludeOIDprogram = "emxOrganization:getExcludeOIDForResourceManagerSearch";
	   objCommonAutonomySearch.open();
	
    }
    
    function submitAutonomySearchResourceManager(arrSelectedObjects) 
	{

		var objForm = document.forms["createDialog"];
		
		var displayElement = objForm.elements["ResourceManagerName"];
		var hiddenElement = objForm.elements["ResourceManagerID"];

		displayElement.value = "";
		hiddenElement.value = "";

		for (var i = 0; i < arrSelectedObjects.length; i++) 
		{ 
			var objSelection = arrSelectedObjects[i];
			
			if (displayElement.value != "") {
				displayElement.value += ",";
			}
			if (hiddenElement.value != "") {
				hiddenElement.value += ",";
			}
			
			displayElement.value += objSelection.name;
			hiddenElement.value += objSelection.objectId;
		}
	}
	function clearResourceManagerField()
  	{
          document.forms[0].ResourceManagerID.value = "";
          document.forms[0].ResourceManagerName.value = "";
          return;
    }
      <%--End:R207:PRG Resource Planning --%>
 
</script>

<%@include file = "../emxUICommonHeaderEndInclude.inc" %>

<form name="createDialog" method="post" action="<%=targetPage%>" onSubmit="submitForm(); return false;">
 <input type="hidden" name="companyId" value="<xss:encodeForHTMLAttribute><%= companyId %></xss:encodeForHTMLAttribute>"/>
 <input type="hidden" name="webEx" value=""/>
 <input type="hidden" name="FromActionsTab" value="<xss:encodeForHTMLAttribute><%=FromActionsTab%></xss:encodeForHTMLAttribute>"/>
 <input type="hidden" name="format0" value="<xss:encodeForHTMLAttribute><%=DomainConstants.FORMAT_GENERIC%></xss:encodeForHTMLAttribute>"/>
 <input type="hidden" name="isSubsidiaryCreate" value="<xss:encodeForHTMLAttribute><%=isSubsidiaryCreate%></xss:encodeForHTMLAttribute>"/>
 <input type="hidden" name="keyCompany" value="<xss:encodeForHTMLAttribute><%=keyCompany%></xss:encodeForHTMLAttribute>"/>
 <!--  Modified for IR-052863V6R2011x -Starts -->
 <!-- <input type="hidden" name="parentOID" value="<%=formBean.getElementValue("parentOID")%>"> -->
 <input type="hidden" name="parentOID" value="<xss:encodeForHTMLAttribute><%=formBean.getElementValue("objectId")%></xss:encodeForHTMLAttribute>"/>
 <input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=formBean.getElementValue("objectId")%></xss:encodeForHTMLAttribute>"/>
 <!--  Modified for IR-052863V6R2011x -Ends -->
 <input type="hidden" name="isSubsidiaryEdit" value="<xss:encodeForHTMLAttribute><%=isSubsidiaryEdit%></xss:encodeForHTMLAttribute>"/>
 <!--Added for Organization feature v11-->
 <input type="hidden" name="companyType" value="<xss:encodeForHTMLAttribute><%=companyType%></xss:encodeForHTMLAttribute>"/>
 <!--end-->
  <table>
    <tr>
  		<td class="labelRequired"><emxUtil:i18n localize="i18nId">emxComponents.Common.Name</emxUtil:i18n></td>
<%
  // Only a host rep can modify a company name, unless it is add mode.
  if (!bEdit || isHostRep) {
%>
      	<td class="inputField"><input type="Text" name="txtName" size="20" value="<xss:encodeForHTMLAttribute><%= companyName %></xss:encodeForHTMLAttribute>" /></td>
<%
  } else {
%>
      	<td class="inputField"><input type="hidden" name="txtName" value="<xss:encodeForHTMLAttribute><%= companyName %></xss:encodeForHTMLAttribute>"/><%= XSSUtil.encodeForHTML(context, companyName) %> </td>

<%
  }
%>
    </tr>
<%if(isOnPremise){
    if (!bEdit) { // if create a new company
        if(isSubsidiaryCreate != null && "true".equals(isSubsidiaryCreate)) {// if creating new subsidiary
            //  Modified for IR-052863V6R2011x -Starts
            //parentCompanyId = (String)formBean.getElementValue("parentOID");
            parentCompanyId = (String)formBean.getElementValue("objectId");
			//  Modified for IR-052863V6R2011x -Ends
            company = (Company)DomainObject.newInstance(context, parentCompanyId);
            parentCompanyName = company.getInfo(context,DomainConstants.SELECT_NAME);
%>
            <tr>
            	<td class="label"><label for="parentName"><emxUtil:i18n localize="i18nId">emxComponents.CompanyDetails.ParentCompany</emxUtil:i18n></label></td>
              <td class="inputField"><%=XSSUtil.encodeForHTML(context, parentCompanyName)%>
                 <input type="hidden" name="parentName" id="parentName" value="<xss:encodeForHTMLAttribute><%=parentCompanyName%></xss:encodeForHTMLAttribute>" />
                 <input type="hidden" name="parentId" id="parentId" value="<%=XSSUtil.encodeForHTMLAttribute(context,parentCompanyId)%>" />
                 <input type="hidden" name="parentNameOID" id="parentNameOID" value="<xss:encodeForHTMLAttribute><%=parentCompanyId%></xss:encodeForHTMLAttribute>" />
                 <input type="hidden" name="parentNameDisplay" id="parentNameDisplay" value="<xss:encodeForHTMLAttribute><%=parentCompanyName%></xss:encodeForHTMLAttribute>" />
               </td>
            </tr>
<%
		} else {
            parentCompanyName = (String)formBean.getElementValue("parentName");
            if(parentCompanyName == null || "null".equals(parentCompanyName)) {
                parentCompanyName = "";
            }
            parentCompanyId = (String)formBean.getElementValue("parentId");
            if(parentCompanyId == null || "null".equals(parentCompanyId)) {
                parentCompanyId = "";
            }
%>
            <tr>
         		<td class="label"><label for="parentName"><emxUtil:i18n localize="i18nId">emxComponents.CompanyDetails.ParentCompany</emxUtil:i18n></label></td>
                <td class="inputField">
                    <input type="text" READONLY name="parentName" id="parentName" size="16" value="<xss:encodeForHTMLAttribute><%=parentCompanyName%></xss:encodeForHTMLAttribute>" />&nbsp;<input class="button" type="button" size = "200" value="..." onClick="javascript:showParentCompanySelector();" />
                    <a href="javascript:clearParent()"><emxUtil:i18n localize="i18nId">emxComponents.Common.Clear</emxUtil:i18n></a>
                    <input type="hidden" name="parentId" id="parentId" value="<xss:encodeForHTMLAttribute><%=parentCompanyId%></xss:encodeForHTMLAttribute>"/>
					<input type="hidden" name="parentNameOID" id="parentNameOID" value="<xss:encodeForHTMLAttribute><%=parentCompanyId%></xss:encodeForHTMLAttribute>" />
                 <input type="hidden" name="parentNameDisplay" id="parentNameDisplay" value="<xss:encodeForHTMLAttribute><%=parentCompanyName%></xss:encodeForHTMLAttribute>" />
                </td>
            </tr>
<%
        }
    } else {// if edit an existing company  
%>
        <tr>
        	<td class="label"><label for="parentName"><emxUtil:i18n localize="i18nId">emxComponents.CompanyDetails.ParentCompany</emxUtil:i18n></label></td>
            <td class="inputField">
                <input type="text" READONLY name="parentName" id="parentName" size="16" value="<xss:encodeForHTMLAttribute><%=parentCompanyName%></xss:encodeForHTMLAttribute>" />&nbsp;<input class="button" type="button" size = "200" value="..." onClick="javascript:showParentCompanySelector();" />
                <a href="javascript:clearParent()"><emxUtil:i18n localize="i18nId">emxComponents.Common.Clear</emxUtil:i18n></a>
                <input type="hidden" name="parentId" id="parentId" value="<xss:encodeForHTMLAttribute><%=parentCompanyId %></xss:encodeForHTMLAttribute>"/>
                <input type="hidden" name="oldParentId" id="oldParentId" value="<xss:encodeForHTMLAttribute><%=parentCompanyId %></xss:encodeForHTMLAttribute>"/>
            </td>
        </tr>
<%  
    }

%>
    <tr><!-- //XSSOK -->
    	<td class="label"><label for="Name"><emxUtil:i18n localize="i18nId">    <%=((isSubsidiaryCreate!=null && "true".equals(isSubsidiaryCreate))||isSubsidiaryEdit==true)?"emxComponents.CompanyDetails.SubsidiaryID": "emxComponents.CompanyDetails.CompanyID"%></emxUtil:i18n></label></td>
      	<!-- //XSSOK -->
		<td class="inputField"><input type="Text" name="<%=attrOrgId%>" value="<%=(attributesMap.get(attrOrgId) == null? XSSUtil.encodeForHTMLAttribute(context,strAttrCompanyId):XSSUtil.encodeForHTMLAttribute(context,attributesMap.get(attrOrgId).toString()) )%>" size="20" /></td>
    </tr>
    
    <%-- Added:4-Nov-08:oef:R207:PRG Resource Planning --%>  
     <%
    	if(isPMCInstalled) {
             %>
          <tr>
          		<td class="label"><label for="ResourceManager"><emxUtil:i18n localize="i18nId">emxComponents.Common.ResourceManager</emxUtil:i18n></label></td>
          		<td class="inputField"><input type="text" name="ResourceManagerName"  value="" readonly="true"/>
          <input type="hidden" name="ResourceManagerID" value=""/>
          <input class="button" type="button" name="btnResourceManager" size="200" value="..." alt=""  onClick="javascript:showResourceManagerSelector();"/> 
           <a href="javascript:clearResourceManagerField();"><emxUtil:i18n localize="i18nId">emxComponents.Common.Clear</emxUtil:i18n></a>
           </td>
           </tr>
         <% 
        }
        %>
        <%--End:R207:PRG Resource Planning --%>  
    <tr>
      <%
    if(isUniqueCageCode.equals("true")) {
%>
   			<td class="labelRequired"><label for="Name"><emxUtil:i18n localize="i18nId">emxComponents.CompanyDetails.CageCode</emxUtil:i18n></label></td>
<%
    } else {
%>
    		<td class="label"><label for="Name"><emxUtil:i18n localize="i18nId">emxComponents.CompanyDetails.CageCode</emxUtil:i18n></label></td>
<%
    }
%>
      	<td class="inputField"><input type="Text" name="<%=attrCageCode%>" size="20" value="<xss:encodeForHTMLAttribute><%= (attributesMap.get(attrCageCode) == null?strAttrCageCode:attributesMap.get(attrCageCode))%></xss:encodeForHTMLAttribute>" /></td>
    </tr>
    <% } %>
    <tr>
      <td class="label"><label for="Name"><emxUtil:i18n localize="i18nId">emxComponents.CompanyDetails.DunsNumber</emxUtil:i18n></label></td>
      <td class="inputField"><input type="Text" name="<%=attrDUNS%>" size="20" value="<xss:encodeForHTMLAttribute><%= (attributesMap.get(attrDUNS) == null?strAttrDunsNumber:attributesMap.get(attrDUNS))%></xss:encodeForHTMLAttribute>" /></td>
    </tr>
    <tr>
      <td class="label"><label for="Name"><emxUtil:i18n localize="i18nId">emxComponents.CompanyDetails.OrgPhone</emxUtil:i18n></label></td>
      <td class="inputField"><input type="Text" name="<%=attrOrgPhone%>" size="20" value="<xss:encodeForHTMLAttribute><%= (attributesMap.get(attrOrgPhone) == null?strAttrPhoneNumber:(attributesMap.get(attrOrgPhone).equals(strUnknown))?strUnknownPhoneNumber:attributesMap.get(attrOrgPhone)) %></xss:encodeForHTMLAttribute>" /></td>
    </tr>
    <tr>
      <td class="label"><label for="Name"><emxUtil:i18n localize="i18nId">emxComponents.CompanyDetails.OrgFax</emxUtil:i18n></label></td>
      <td class="inputField"><input type="Text" name="<%=attrOrgFax%>" size="20" value="<xss:encodeForHTMLAttribute><%= (attributesMap.get(attrOrgFax) == null? strAttrFaxNumber:(attributesMap.get(attrOrgFax).equals(strUnknown))?strUnknownFaxNumber:attributesMap.get(attrOrgFax)) %></xss:encodeForHTMLAttribute>" /></td>
    </tr>
    <tr>
      <td class="label"><label for="Name"><emxUtil:i18n localize="i18nId">emxComponents.CompanyDetails.WebSite</emxUtil:i18n></label></td>
      <td class="inputField"><input type="Text" name="<%=attrWebSite%>" size="40" value="<xss:encodeForHTMLAttribute><%= (attributesMap.get(attrWebSite) == null?strAttrWebSite:(attributesMap.get(attrWebSite).equals(strUnknown))?strUnknownWebSite:attributesMap.get(attrWebSite)) %></xss:encodeForHTMLAttribute>" /></td>
    </tr>
<%
if(isOnPremise){
    if(isHostRep) {
        storeList = Store.getStores(context);
        storeListItr = storeList.iterator();
%>
        <tr>
            <td class="label"><label for="Name"><emxUtil:i18n localize="i18nId">emxComponents.CompanyDialog.FileStore</emxUtil:i18n></label></td>
            <td class="inputField"> <!-- XSSOK -->
            <select name="<%=attrFileStoreSymName%>"  >
                <option value=""></option>
<%
                while(storeListItr.hasNext()) {
                    storeName = ((Store)storeListItr.next()).getName();
                    if(storeName.equals(strCompStoreName)) {
                        strChecked = "selected";
                    }
%><!-- //XSSOK -->
                    <option value="<%=XSSUtil.encodeForHTMLAttribute(context, storeName)%>" <%=strChecked%>><%=XSSUtil.encodeForHTMLAttribute(context, i18nNow.getAdminI18NString("Store",storeName,languageStr))%></option>
<%
                    strChecked = "";
                }
%>
            </select>
            </td>
        </tr>
<%
    } 
%>
    <tr>
      <td class="label"><label for="Name"><emxUtil:i18n localize="i18nId">emxComponents.CompanyDetails.FtpHost</emxUtil:i18n></label></td>
      <td class="inputField"><input type="Text" name="<%=attrFTPHost%>" size="40" value="<xss:encodeForHTMLAttribute><%= (attributesMap.get(attrFTPHost) == null?strAttrFTPHost:attributesMap.get(attrFTPHost)) %></xss:encodeForHTMLAttribute>" /></td>
    </tr>
    <tr>
      <td class="label"><label for="Name"><emxUtil:i18n localize="i18nId">emxComponents.CompanyDetails.FtpDir</emxUtil:i18n></label></td>
      <td class="inputField"><input type="Text" name="<%=attrFTPDirectory%>" size="20" value="<xss:encodeForHTMLAttribute><%= (attributesMap.get(attrFTPDirectory) == null?strAttrFTPDirectory:attributesMap.get(attrFTPDirectory)) %></xss:encodeForHTMLAttribute>" /></td>
    </tr>


<%
   if (bEdit) {
%>
        <tr>
        	<td class="label"><label for="State"><emxUtil:i18n localize="i18nId">emxComponents.Common.State</emxUtil:i18n></label></td>
            <td class="inputField" >
<%
            if(sState.equals("Active")) {
%>
                <emxUtil:i18n localize="i18nId">emxComponents.CompanyDialog.Active</emxUtil:i18n>
<%
            } else {
%>
                <emxUtil:i18n localize="i18nId">emxComponents.CompanyDialog.InActive</emxUtil:i18n>
<%
            }
%>
            </td>
        </tr>
<%
    } else {
%>
        <tr>
            <td class="label"><label for="State"><emxUtil:i18n localize="i18nId">emxComponents.Common.State</emxUtil:i18n></label></td>
            <td class="inputField" ><emxUtil:i18n localize="i18nId">emxComponents.CompanyDialog.Active</emxUtil:i18n></td>
        </tr>
<%
    }
	}
%>
    <tr>
        <td class="label"><label for="Description"><emxUtil:i18n localize="i18nId">emxComponents.Common.Description</emxUtil:i18n></label></td>
        <td class="inputField" ><textarea name="description" cols="25" rows="5" wrap ><xss:encodeForHTML><%=companyDesc%></xss:encodeForHTML></textarea></td>
    </tr>
    <tr>
      <td class="label"><label for="Name"><emxUtil:i18n localize="i18nId">emxComponents.CompanyDetails.Address</emxUtil:i18n></label></td>
      <td class="inputField"><input type="Text" name="<%=attrAddress%>" size="40" value="<xss:encodeForHTMLAttribute><%= (attributesMap.get(attrAddress) == null?strAddress:(attributesMap.get(attrAddress).equals(strUnknown))?strUnknownAddress:attributesMap.get(attrAddress)) %></xss:encodeForHTMLAttribute>"/></td>
    </tr>
    <tr>
      <td class="label"><label for="Name"><emxUtil:i18n localize="i18nId">emxComponents.CompanyDetails.PostalCode</emxUtil:i18n></label></td>
      <td class="inputField"><input type="Text" name="<%=attrPostalCode%>" size="40" value="<xss:encodeForHTMLAttribute><%= (attributesMap.get(attrPostalCode) == null?strPostalCode:attributesMap.get(attrPostalCode)) %></xss:encodeForHTMLAttribute>"/></td>
    </tr>
    <%if(isOnPremise){ %>
    <tr>
      <td class="label"><label for="Name"><emxUtil:i18n localize="i18nId">emxComponents.CompanyDetails.Country</emxUtil:i18n></label></td>
      <td class="inputField">
	<% 
	    java.util.Map countryChoiceDetails = (java.util.Map) matrix.db.JPO.invoke(context, "emxOrganization", null, "getCountryChooserDetailsForHTMLDisplay", new String[]{request.getHeader("Accept-Language")}, java.util.HashMap.class);
	    java.util.List optionList =  (java.util.List)countryChoiceDetails.get("optionList");
  	    java.util.List valueList =  (java.util.List)countryChoiceDetails.get("valueList");
  	    java.util.List manualEntryList =  (java.util.List)countryChoiceDetails.get("manualEntryList");  	    
   	    String countryDefaultValue = (String)countryChoiceDetails.get("default");
	%>      
		<framework:editOptionList disabled="false" name="<%=XSSUtil.encodeForHTMLAttribute(context, attrCountry)%>" optionList="<%=optionList%>" valueList="<%=valueList%>" sortDirection="ascending" selected="<%=XSSUtil.encodeForHTML(context, countryDefaultValue)%>" manualEntryList="<%=manualEntryList%>"/>
      </td>
    </tr>
    
      <!--  Added:01-June-2010:s4e:R210 PRG:AdvanceResourcePlanning-->
          <%
    	if(isPMCInstalled) {
             %>
        <tr>
        	<td class="label"><label for="Standard Cost"><emxUtil:i18n localize="i18nId">emxComponents.CompanyDetails.StandardCost</emxUtil:i18n></label></td>
            <td class="inputField"><input type="text" name="<%= sStandardCost %>" id="StandardCost" onblur="javascript:validateStandardCost(this);" value="<xss:encodeForHTMLAttribute><%= (attributesMap.get(sStandardCost) == null?standardCost: attributesMap.get(sStandardCost)) %></xss:encodeForHTMLAttribute>" />
           <%
            StringList unitOptionsList = new StringList();
            StringList unitValueList = new StringList();
            Organization organization = new Organization();
            Map mapValues  = organization.getCurrencyRangeForStandardCost(context);
            
            unitOptionsList= (StringList)mapValues.get("unitOptionsList");
            unitValueList= (StringList)mapValues.get("unitValueList");
            %>
            <select id="selcurrency" name="selcurrency" >
			<!-- //XSSOK -->
            <framework:optionList  optionList="<%=unitOptionsList%>"  valueList="<%=unitValueList%>"  selected= "<%=currencyUnit%>"/>
            </select></td>  
        </tr>
          <%
              }
             %>
         <!--  End:01-June-2010:s4e:R210 PRG:AdvanceResourcePlanning-->
<%
   //Added for Organization feature v11
   if("Supplier".equalsIgnoreCase(companyType)) {
%>
    <tr>
		<td class="label"><label for="AlternateSupplierNames">
     <emxUtil:i18n localize="i18nId">emxComponents.CompanyDetails.AlternateSupplierNames</emxUtil:i18n></label></td>
     	<td class="inputField" >
     <textarea name="<%=attrAlternateName%>" cols="25" rows="5" wrap ><xss:encodeForHTML><%=(!bEdit) ? "":(attributesMap.get(attrAlternateName) == null ?strAlternateName:attributesMap.get(attrAlternateName))%></xss:encodeForHTML></textarea>
     </td>
    </tr>
<%
   }
  }
   //end
%>
</table>
&nbsp;
</form>
<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
