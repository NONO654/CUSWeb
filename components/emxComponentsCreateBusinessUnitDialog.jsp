<%--  emxComponentsCreateBusinessUnitDialog.jsp   -   Display Create BusinessUnit Dialog
  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxComponentsCreateBusinessUnitDialog.jsp.rca 1.24 Wed Oct 22 16:18:25 2008 przemek Experimental przemek $
--%>

<%@include file = "emxComponentsDesignTopInclude.inc"%>
<%@include file = "emxComponentsVisiblePageInclude.inc"%>
<%@include file = "emxComponentsJavaScript.js"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "eServiceUtil.inc"%>
<%@include file = "../emxJSValidation.inc" %>
<%@page import="com.matrixone.apps.domain.util.FrameworkUtil"%>
<%@page import="matrix.db.JPO"%>
<%@page import="com.matrixone.apps.common.Organization"%>



<%
  String sTypeCompany           = PropertyUtil.getSchemaProperty(context, "type_Company");
  String sTypeBusinessUnit      = PropertyUtil.getSchemaProperty(context, "type_BusinessUnit");
  String sAttrOrgName           = PropertyUtil.getSchemaProperty(context, "attribute_OrganizationName");
  String sAttrOrgId             = PropertyUtil.getSchemaProperty(context, "attribute_OrganizationID");
  String sAttrCageCode          = PropertyUtil.getSchemaProperty(context, "attribute_CageCode");
  String sAttrDUNS              = PropertyUtil.getSchemaProperty(context, "attribute_DUNSNumber");
  String sAttrPhone             = PropertyUtil.getSchemaProperty(context, "attribute_OrganizationPhoneNumber");
  String sAttrFax               = PropertyUtil.getSchemaProperty(context, "attribute_OrganizationFaxNumber");
  String sAttrWebSite           = PropertyUtil.getSchemaProperty(context, "attribute_WebSite");
  String sAttrFTPHost           = PropertyUtil.getSchemaProperty(context, "attribute_FTPHost");
  String sAttrFTPDirectory      = PropertyUtil.getSchemaProperty(context, "attribute_FTPDirectory");
  String sAttrBusinssUnitName   = PropertyUtil.getSchemaProperty(context, "attribute_BusinessUnitName");
  String sAttrBusinessUnitID    = PropertyUtil.getSchemaProperty(context, "attribute_BusinessUnitID");
//Added:01-June-2010:s4e:R210 PRG:AdvanceResourcePlanning
  String sStandardCost			= PropertyUtil.getSchemaProperty(context, "attribute_StandardCost");
  String sCurrency    = "";
//End:01-June-2010:s4e:R210 PRG:AdvanceResourcePlanning
  String strLanguage = request.getHeader("Accept-Language");
//Error message for string length
  String errMessage=EnoviaResourceBundle.getProperty(context,"emxFrameworkStringResource",context.getLocale(), "emxFramework.Create.NameColumn");

  String isUniqueCageCode=EnoviaResourceBundle.getProperty(context,"emxComponents.cageCode.Uniqueness");
  if( isUniqueCageCode!=null && isUniqueCageCode.trim().equalsIgnoreCase("true")) {
      isUniqueCageCode = "true";
  } else {
      isUniqueCageCode = "false";
  } 
	boolean isPMCInstalled =  FrameworkUtil.isSuiteRegistered(context,"appVersionProgramCentral",false,null,null);
  
  // Get page parameters. 
  String companyId = emxGetParameter(request, "companyId");
  
  String businessUnitId = emxGetParameter(request, "businessUnitId");

  // Define objects.
  BusinessObject businessUnit = null;
  BusinessObject company = null;
  String companyName = "";
  String businessUnitName = "";
  String businessUnitDesc = "";
  String targetPage = "";
  HashMap attributesMap = null;
  boolean isAddMode = false;
  String sDefaultVault = "";
  String businessUnitVault   ="";
  String standardCost   = "0.0";
  String currencyUnit   = "";
  boolean FromActionsTab = false;

  String strFileName = "";

  int intTabIndexCounter = 1;
  boolean isOnPremise  = FrameworkUtil.isOnPremise(context);
  BusinessObject myPerson  = JSPUtil.getPerson(context,session);
  BusinessObject repCompany = Company.getCompanyForRep(context,myPerson);
  String repCompanyId = null;
  if(repCompany != null)
  {
    repCompanyId = repCompany.getObjectId();
  }
  if(companyId == null)
  {
    com.matrixone.apps.common.Person contextPerson = com.matrixone.apps.common.Person.getPerson(context);
    Company contextCompany = contextPerson.getCompany(context);
    companyId = contextCompany.getId();
    FromActionsTab = true;
  }

  // If a business unit id was passed in, then get into to edit.
  // Otherwise, setup to add a business unit.
  if (businessUnitId != null && !"".equals(businessUnitId) && !"null".equals(businessUnitId))
  {
    // Not add mode.
    isAddMode = false;

    // Access the business unit object.
    businessUnit = new BusinessObject(businessUnitId);
    businessUnit.open(context);
    businessUnitName = businessUnit.getName();
    businessUnitDesc = businessUnit.getDescription();
    businessUnitVault = businessUnit.getVault();
    attributesMap = ComponentsUtil.getAttributesIntoHashMap(context, businessUnit);

    // Get the connected company information.
    company = JSPUtil.getCompany(context,session, businessUnit);
    company.open(context);
    companyId = company.getObjectId();
    companyName = company.getName();
    company.close(context);

    String strFileFormat = businessUnit.getDefaultFormat(context);
    FileItr fileItr = new FileItr( businessUnit.getFiles(context,strFileFormat));
    if ( fileItr.next() )
    {
      strFileName = fileItr.obj().getName();
    }

    // Close the business unit object.
    businessUnit.close(context);

    // Initialize mode-specific strings.
    targetPage = "emxComponentsEditBusinessUnit.jsp";

  }
  else
  {
    BusinessObject person = JSPUtil.getPerson(context, session);
    person.open(context);
    sDefaultVault = person.getVault();
    person.close(context);

    // This is add mode.
    isAddMode = true;

    // Error if a company id was not passed in.
    if (companyId == null) {
      throw new MatrixException(ComponentsUtil.i18nStringNow("emxComponents.BusinessUnitDialog.ExceptionCompanyId", strLanguage) + "'companyId'" + ComponentsUtil.i18nStringNow("emxComponents.BusinessUnitDialog.ExceptionCompanyIdCont", strLanguage));
    }

    targetPage = "emxComponentsCreateBusinessUnitProcess.jsp";
    attributesMap = new HashMap();
  }

%>

  <script language="JavaScript">

  function trim(str)
  {
    while(str.length != 0 && str.substring(0,1) == ' '){
      str = str.substring(1);
    }
    while(str.length != 0 && str.substring(str.length -1) == ' '){
      str = str.substring(0, str.length -1);
    }
    return str;
  }

  function validateAndSubmit()
  {
      if(jsIsClicked()) {
          alert("<emxUtil:i18nScript  localize="i18nId">emxComponents.Search.RequestProcessMessage</emxUtil:i18nScript>");
          return;
      }
    
    // "shortcut" variables\
    var f = document.CreateBusinessUnit;
    var orgName = f["<%= XSSUtil.encodeForJavaScript(context, sAttrOrgName) %>"];
    var orgId = f["<%= XSSUtil.encodeForJavaScript(context, sAttrOrgId) %>"];
    <%if(isOnPremise){%>
    var cageCode = f["<%= XSSUtil.encodeForJavaScript(context, sAttrCageCode) %>"];
    <%}%>
    var dunsNumber = f["<%= XSSUtil.encodeForJavaScript(context, sAttrDUNS) %>"];
    var webSite = f["<%= XSSUtil.encodeForJavaScript(context, sAttrWebSite) %>"];
    var webSiteValue  = trim(webSite.value);
    webSite.value     = webSiteValue;
    webSiteValue    = webSiteValue.toLowerCase();


  // Name can not have apostrophe character "'", or DoubleQuotes character """, "#" hash charecter
    var hashPosition = trim(orgName.value).indexOf("#");
    var doublequotesPosition = trim(orgName.value).indexOf("\"");

    var namebadCharName = checkForNameBadCharsList(orgName);
    var namebadCharId = checkForNameBadCharsList(orgId);
    var orgNameLengthCheck=checkValidLength(orgName.value);
    if (namebadCharName.length != 0)
    {
      alert("<emxUtil:i18nScript localize="i18nId">emxComponents.Common.AlertInValidChars</emxUtil:i18nScript>"+namebadCharName+"<emxUtil:i18nScript localize="i18nId">emxComponents.Common.AlertRemoveInValidChars</emxUtil:i18nScript>");
      orgName.focus();
      return;
    }
    if(!orgNameLengthCheck)
    	{
    	orgName.focus();
   	    alert("<%=errMessage%>");
        return;
    	}
    if (namebadCharId.length != 0)
    {
      alert("<emxUtil:i18nScript localize="i18nId">emxComponents.Common.AlertInValidChars</emxUtil:i18nScript>"+namebadCharName+"<emxUtil:i18nScript localize="i18nId">emxComponents.Common.AlertRemoveInValidChars</emxUtil:i18nScript>");
      orgId.focus();
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
    namebadCharName = checkForBadChars(document.CreateBusinessUnit.txtDesc);
    if (namebadCharName.length != 0)
    {
      alert("<emxUtil:i18nScript localize="i18nId">emxComponents.Common.AlertInValidChars</emxUtil:i18nScript>"+namebadCharName+"<emxUtil:i18nScript localize="i18nId">emxComponents.Common.AlertRemoveInValidChars</emxUtil:i18nScript>");
      document.CreateBusinessUnit.txtDesc.focus();
      return;
    }

    orgName.value = trim(orgName.value);
    var organizationName = trim(orgName.value);
    orgName.value = organizationName;
    var orgIdvalue = trim(orgId.value);
    orgId.value = orgIdvalue;
    if (orgName.value.length == 0 || orgName.value == "") {
      alert("<emxUtil:i18nScript localize="i18nId">emxComponents.BusinessUnitDialog.EnterName</emxUtil:i18nScript>");
      orgName.select();
      orgName.focus();
      return;
    } else if (!isAlphanumeric(orgIdvalue, true)) {
       alert("<emxUtil:i18nScript localize="i18nId">emxComponents.CompanyDialog.PleaseTypeAlphaNumeric</emxUtil:i18nScript>"+ " <%= XSSUtil.encodeForJavaScript(context, i18nNow.getAttributeI18NString(sAttrOrgId,strLanguage))%>.");
       orgId.focus();
       return; 
    }else if (hashPosition != -1 || doublequotesPosition != -1){
      alert ("<emxUtil:i18nScript localize="i18nId">emxComponents.Common.SpecialCharacters</emxUtil:i18nScript>");
      orgName.focus();
      return;
    }

    if( trim(orgId.value)=="" ) {
        alert("<emxUtil:i18nScript localize="i18nId">emxComponents.OrganizationDialog.EnterOrganizationId</emxUtil:i18nScript>");
        orgId.select();
        orgId.focus();
        return; 
    }
	//XSSOK
    if( (<%=isOnPremise%> && "true" == "<%=isUniqueCageCode%>") && trim(cageCode.value)=="" ) {
        alert("<emxUtil:i18nScript localize="i18nId">emxComponents.CompanyDialog.EnterCageCode</emxUtil:i18nScript>");
        cageCode.select();
        cageCode.focus();
        return;
    }
    
    if (!isNumeric(dunsNumber.value)) {
      alert("<emxUtil:i18nScript localize="i18nId">emxComponents.CompanyDialog.PleaseTypeNumbers</emxUtil:i18nScript>"+ " <%= XSSUtil.encodeForJavaScript(context, i18nNow.getAttributeI18NString(sAttrDUNS,strLanguage))%>.");
      dunsNumber.select();
      dunsNumber.focus();
      return;
    }
    else if(/\s/.test(webSite.value)) {
      alert("<emxUtil:i18nScript localize="i18nId">emxComponents.CompanyDialog.Invalid</emxUtil:i18nScript>"+ " <%= XSSUtil.encodeForJavaScript(context, i18nNow.getAttributeI18NString(sAttrWebSite,strLanguage))%>.");
      webSite.select();
      webSite.focus();
      return;
    }

    if (jsDblClick()) {
        f.submit();
    }
    return; 
  }

  function closeWindow()
  {
    getTopWindow().closeWindow();
    return;
  }

  function showVaultSelector()
  {
      showChooser('../common/emxVaultChooser.jsp?fieldNameActual=vaultName&fieldNameDisplay=vaultNameDisplay&action=createCompany&multiSelect=false');
  }
  
  function displaymessage(eventObj) {
    if(eventObj.keyCode != '9') {
        alert("<emxUtil:i18nScript localize="i18nId">emxComponents.Common.BrowseWithButton</emxUtil:i18nScript>");
        return false;
    }
    return true;
  }
   
  <%-- Added:4-Nov-08:oef:R207:PRG Resource Planning --%>
  function showResourceManagerSelector() {
    var objCommonAutonomySearch = new emxCommonAutonomySearch();
       //[Modified::Jan 11, 2011:s4e:R211:IR-079535V6R2012 ::Start]    
	   objCommonAutonomySearch.txtType = "type_Person&form=AEFSearchPersonForm";
	   //[Modified::Jan 11, 2011:s4e:R211:IR-079535V6R2012 ::End] 
	   objCommonAutonomySearch.selection = "multiple";
	   objCommonAutonomySearch.onSubmit = "getTopWindow().getWindowOpener().submitAutonomySearchResourceManager"; 
	   objCommonAutonomySearch.excludeOIDprogram = "emxOrganization:getExcludeOIDForResourceManagerSearch";
	   objCommonAutonomySearch.open();
	
    }
    
  function submitAutonomySearchResourceManager(arrSelectedObjects) {
		var objForm = document.forms["CreateBusinessUnit"];
		var displayElement = objForm.elements["ResourceManagerName"];
		var hiddenElement = objForm.elements["ResourceManagerID"];

		displayElement.value = "";
		hiddenElement.value = "";
		for (var i = 0; i < arrSelectedObjects.length; i++) { 
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
  function clearResourceManagerField() {
          document.forms[0].ResourceManagerName.value = "";
          document.forms[0].ResourceManagerID.value = "";    
          return;
    }
    <%--End:R207:PRG Resource Planning--%>
  
 </script>

<%@include file = "../emxUICommonHeaderEndInclude.inc" %>

<form name="CreateBusinessUnit" method="post" action="<%= XSSUtil.encodeForHTML(context, targetPage) %>" onSubmit="validateAndSubmit(); return false;">
  <input type="hidden" name="companyId" value="<xss:encodeForHTMLAttribute><%= companyId %></xss:encodeForHTMLAttribute>"/>
  <input type="hidden" name="businessUnitId" value="<xss:encodeForHTMLAttribute><%= businessUnitId %></xss:encodeForHTMLAttribute>"/>
  <input type="hidden" name="FromActionsTab" value="<xss:encodeForHTMLAttribute><%= FromActionsTab %></xss:encodeForHTMLAttribute>"/>
  <input type="hidden" name="currency" value="<xss:encodeForHTMLAttribute><%= sCurrency %></xss:encodeForHTMLAttribute>"/>


      <table>
        <tr>
    	<td class="labelRequired"><label for="Name"><emxUtil:i18n localize="i18nId">emxComponents.Common.Name</emxUtil:i18n></label></td>
        <td class="inputField"><input type="text" name="<%= sAttrOrgName %>" id="Name" value="<xss:encodeForHTMLAttribute><%= businessUnitName %></xss:encodeForHTMLAttribute>" /></td>
        </tr>
        <tr>
    	<td class="labelRequired"><label for="BusinessUnit ID"><emxUtil:i18n localize="i18nId">emxComponents.BusinessUnitDialog.ID</emxUtil:i18n></label></td>
        <td class="inputField"><input type="text" name="<%= sAttrOrgId %>" id="BusinessUnitId" value="<%= (attributesMap.get(sAttrOrgId) == null?"": attributesMap.get(sAttrOrgId))%>" /></td>
        </tr>
        
         <!-- Added:4-Nov-08:oef:R207:PRG Resource Planning -->
             <%
	if(isOnPremise){
    if(isPMCInstalled) {
             %>
	<tr>
		<td class="label">
			<label for="ResourceManager">
				<emxUtil:i18n localize="i18nId">emxComponents.Common.ResourceManager</emxUtil:i18n>
			</label>
		</td>
        <td class="inputField">
        	<input type="text" name="ResourceManagerName" value="" readonly="true"/>
        	<input type="hidden" name="ResourceManagerID" value=""/>
          	<input class="button" type="button" name="btnResourceManager" size="200" value="..." alt=""  onClick="javascript:showResourceManagerSelector();"/> 
            <a href="javascript:clearResourceManagerField();">
            	<emxUtil:i18n localize="i18nId">emxComponents.Common.Clear</emxUtil:i18n>
            </a>
    	</td>
	</tr>
        <% 
        }
        %>
          <!--End:R207:PRG Autonomy Search -->
        
        <tr>
<%
        if(isUniqueCageCode.equals("true")) {  
%>
    	<td class="labelRequired"><label for="Cage Code"><emxUtil:i18n localize="i18nId">emxComponents.CompanyDialog.CageCode</emxUtil:i18n></label></td>
<%
        }else {
%>
      	<td class="label"><label for="Cage Code"><emxUtil:i18n localize="i18nId">emxComponents.CompanyDialog.CageCode</emxUtil:i18n></label></td>
<%
        }
%>
    	<td class="inputField"><input type="text" name="<%= sAttrCageCode %>" id="CageCode" value="<xss:encodeForHTMLAttribute><%= (attributesMap.get(sAttrCageCode) == null?"": attributesMap.get(sAttrCageCode)) %></xss:encodeForHTMLAttribute>" /></td>
        </tr>
        <%} %>
        <tr>
    	<td class="label"><label for="DUNS Number"><emxUtil:i18n localize="i18nId">emxComponents.CompanyDialog.DunsNumber</emxUtil:i18n></label></td>
        <td class="inputField"><input type="text" name="<%= sAttrDUNS %>" id="DUNSNumber" value="<xss:encodeForHTMLAttribute><%= (attributesMap.get(sAttrDUNS) == null?"": attributesMap.get(sAttrDUNS)) %></xss:encodeForHTMLAttribute>" /></td>
        </tr>
        <tr>
    	<td class="label"><label for="Phone Number"><emxUtil:i18n localize="i18nId">emxComponents.CompanyDialog.OrgPhone</emxUtil:i18n></label></td>
        <td class="inputField"><input type="text" name="<%= sAttrPhone %>" id="PhoneNumber" value="<xss:encodeForHTMLAttribute><%= (attributesMap.get(sAttrPhone) == null?"": attributesMap.get(sAttrPhone)) %></xss:encodeForHTMLAttribute>" /></td>
        </tr>
        <tr>
    	<td class="label"><label for="Fax Number"><emxUtil:i18n localize="i18nId">emxComponents.CompanyDialog.OrgFax</emxUtil:i18n></label></td>
        <td class="inputField"><input type="text" name="<%= sAttrFax %>" id="FaxNumber" value="<xss:encodeForHTMLAttribute><%= (attributesMap.get(sAttrFax) == null?"": attributesMap.get(sAttrFax)) %></xss:encodeForHTMLAttribute>" /></td>
        </tr>
        <tr>
    	<td class="label"><label for="Web Site"><emxUtil:i18n localize="i18nId">emxComponents.CompanyDialog.WebSite</emxUtil:i18n></label></td>
        <td class="inputField"><input type="text" name="<%= sAttrWebSite %>" id="WebSite" value="<xss:encodeForHTMLAttribute><%= (attributesMap.get(sAttrWebSite) == null?"": attributesMap.get(sAttrWebSite)) %></xss:encodeForHTMLAttribute>" /></td>
        </tr>
        <tr>
        <%if(isOnPremise){ %>
    	<td class="label"><label for="FTP Host"><emxUtil:i18n localize="i18nId">emxComponents.CompanyDetails.FtpHost</emxUtil:i18n></label></td>
        <td class="inputField"><input type="text" name="<%= sAttrFTPHost %>" id="FTPHost" value="<xss:encodeForHTMLAttribute><%= (attributesMap.get(sAttrFTPHost) == null?"": attributesMap.get(sAttrFTPHost)) %></xss:encodeForHTMLAttribute>" /></td>
        </tr>
        <tr>
    	<td class="label"><label for="FTP Directory"><emxUtil:i18n localize="i18nId">emxComponents.CompanyDetails.FtpDir</emxUtil:i18n></label></td>
        <td class="inputField"><input type="text" name="<%= sAttrFTPDirectory %>" id="FTPDirectory" value="<xss:encodeForHTMLAttribute><%= (attributesMap.get(sAttrFTPDirectory) == null?"": attributesMap.get(sAttrFTPDirectory)) %></xss:encodeForHTMLAttribute>" /></td>
        </tr>
        
         <!--  Added:01-June-2010:s4e:R210 PRG:AdvanceResourcePlanning-->
         <%
	if(isPMCInstalled) {
         %>
		<tr>
        	<td class="label"><label for="Standard Cost"><emxUtil:i18n localize="i18nId">emxComponents.CompanyDetails.StandardCost</emxUtil:i18n></label></td>
          	<td class="inputField"><input type="text" name="<%= sStandardCost %>" id="StandardCost" onBlur="javascript:validateStandardCost(this);" value="<xss:encodeForHTMLAttribute><%= (attributesMap.get(sStandardCost) == null?standardCost: attributesMap.get(sStandardCost)) %></xss:encodeForHTMLAttribute>" />
      <%
      StringList unitOptionsList = new StringList();
      StringList unitValueList = new StringList();
      
      Organization organization = new Organization();
      Map mapValues  = organization.getCurrencyRangeForStandardCost(context);
      
      unitOptionsList= (StringList)mapValues.get("unitOptionsList");
      unitValueList= (StringList)mapValues.get("unitValueList");
            %>
            <select id="selcurrency" name="selcurrency" >           
            <framework:optionList
                optionList="<%=unitOptionsList%>"
                valueList="<%=unitValueList%>"
                selected= "<%=XSSUtil.encodeForHTML(context, currencyUnit)%>"/>
            </select></td>  
        </tr>
                 <%
              }
             %>
        <!--  End:01-June-2010:s4e:R210 PRG:AdvanceResourcePlanning-->
        
        <tr>
    	<td class="label"><label for="State"><emxUtil:i18n localize="i18nId">emxComponents.Common.State</emxUtil:i18n></label></td>
          <td class="inputField"><input type="text" readonly name="State" id="State" value="<framework:i18n localize='i18nId'>emxComponents.CompanyDialog.Active</framework:i18n>" size="20"/>&nbsp;</td>
        </tr>
        <%} %>
        <tr>
    	<td class="label"><label for="Description"><emxUtil:i18n localize="i18nId">emxComponents.Common.Description</emxUtil:i18n></label></td>
        <td class="inputField"><textarea name="txtDesc" id="txtDesc" rows="5" cols="40" ><xss:encodeForHTML><%=businessUnitDesc%></xss:encodeForHTML></textarea></td>
        </tr>
      </table>
      &nbsp;
</form>

<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
<%@include file = "emxComponentsDesignBottomInclude.inc"%>
