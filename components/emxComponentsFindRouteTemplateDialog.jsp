<%--  emxComponentsFindRouteTemplateDialog.jsp   
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxComponentsFindRouteTemplateDialog.jsp.rca 1.8 Wed Oct 22 16:18:11 2008 przemek Experimental przemek $
--%>

<%@include file = "emxComponentsCommonUtilAppInclude.inc"%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "../common/emxUIConstantsInclude.inc"%>

<%@page import  = "com.matrixone.apps.domain.util.PersonUtil"%>
<script language="javascript">
  /*This function is needed to support AEF Global Search*/
    function doSearch() {
        var objForm = document.editDataForm;
        objForm.target = "searchView";
        objForm.action="../common/emxTable.jsp?selection=multiple&toolbar=APPSearchResultToolbar&header=emxComponents.Heading.SearchResult";
        objForm.submit();
    }

/* This function is added for the Enter Key functionality*/

    function submitForm() {
        bottomFrame = findFrame(getTopWindow(),"BottomFrame");
        if(bottomFrame == null)
        {
         parent.doFind();
        }
        else
        {
          bottomFrame.validateLimit();
        }
    }

    function  ShowOrg()
    {
        showModalDialog('../components/emxComponentsSelectBusinessUnitDialogFS.jsp?fieldNameDisplay=owningOrg&fieldNameOID=objectId&strFormPopUp=false',400,500);
        return;
    }

    function clearRoutesOwningOrg() { 
        document.editDataForm.owningOrg.value = ""; 
        document.editDataForm.objectId.value = ""; 
    }
</script>

<%@include file = "../emxUICommonHeaderEndInclude.inc" %>

<%
    Enumeration enumParamNames    = emxGetParameterNames(request);
    String timeStamp              = Request.getParameter(request, "timeStamp");
    String pagination             = emxGetParameter(request,"pagination");
    String queryLimit             = emxGetParameter(request,"queryLimit");
    String selPurpose             = emxGetParameter(request,"Purpose");
    String restrictToPurpose      = emxGetParameter(request,"restrictToPurpose");
    String restrictAvailability   = emxGetParameter(request,"restrictAvailability");
    String previousCommand        = emxGetParameter(request, "previousCommand");
    String commandName            = emxGetParameter(request, "CommandName");
    String selAvailability        = emxGetParameter(request,"Availability");
    String selVaultName           = emxGetParameter(request,"vaultName");
    String selVaultOption         = emxGetParameter(request,"vaultOption");
    String selDisplayVault        = emxGetParameter(request,"vaultNameDisplay");
    
    String[] intArgs              = new String[]{};
    String paramName              = null;
    String paramValue             = null;
    HashMap requestMap            = new HashMap();
    HashMap paramMap              = new HashMap();
    String typeRouteTemplate      = DomainConstants.TYPE_ROUTE_TEMPLATE;
    String typeI18N               = i18nNow.getTypeI18NString(typeRouteTemplate,sLanguage);
    String typeIcon               = UINavigatorUtil.getTypeIconProperty(context,typeRouteTemplate);
    String sAttrRouteBasePurpose  = PropertyUtil.getSchemaProperty(context, "attribute_RouteBasePurpose" );
    String vaultDefaultSelection  = PersonUtil.getSearchDefaultSelection(context);
    String selVaultOptionAll      = "";
    String selVaultOptionLocal    = "";
    String selVaultOptionDefault  = "";
    String selVaultOptionSelected = "";
    String strVaults              = "";
    
    String sObjectId = emxGetParameter(request,"objectId");
    String sECRECOUI = emxGetParameter(request,"ecrEcoUi");
	/** Added For X3 */
	String stype=emxGetParameter(request,"type");
	String TYPE_PLANT = PropertyUtil.getSchemaProperty(context,"type_Plant");
	String sLocationId =null;
	String splantId=emxGetParameter(request,"objPlantId");
	/** End */
    String sOwningOrganizationName = "";

    if (sECRECOUI != null && "true".equalsIgnoreCase(sECRECOUI) && (sObjectId != null && !"".equals(sObjectId) && !" ".equals(sObjectId) && !"null".equals(sObjectId))) {
    
      DomainObject oOwningOrgObj = DomainObject.newInstance(context, sObjectId);
      sOwningOrganizationName = oOwningOrgObj.getInfo(context, DomainConstants.SELECT_NAME);
    }
	/** Added For X3 */
    if(splantId!=null && splantId.length()!=0)
	{   
		MapList mlLocationList =null;
		StringList busSelList = new StringList();
		String PLANT_ID = PropertyUtil.getSchemaProperty(context,"attribute_PlantID");
    
                StringList relSelList = new StringList();
                busSelList.add(DomainObject.SELECT_ID);
                busSelList.add(DomainObject.SELECT_NAME);
                String sWherecondition ="attribute["+PLANT_ID+"]"+" == '"+splantId+"'";
				mlLocationList=DomainObject.findObjects(context, // eMatrix context
                                                        stype,  // type pattern
                                                        "*",
                                                        DomainConstants.QUERY_WILDCARD,     // revision pattern
                                                        DomainConstants.QUERY_WILDCARD,     // owner pattern
                                                        DomainConstants.QUERY_WILDCARD,     // vault pattern
                                                        sWherecondition,        // where expression
                                                        false,               // expand types
                                                        busSelList);     // object selects
			
            if( (mlLocationList !=null) && (mlLocationList.size()>0) )
            {
                sLocationId=(String)((Map)mlLocationList.get(0)).get(DomainObject.SELECT_ID);
            }
            DomainObject oOwningOrgObj = DomainObject.newInstance(context, sLocationId);
      sOwningOrganizationName = oOwningOrgObj.getInfo(context, DomainConstants.SELECT_NAME);
			
	}
	/** END */
    if(selPurpose == null || selPurpose.trim().length() == 0) {
      selPurpose = DomainObject.QUERY_WILDCARD;
    }

    if(queryLimit == null || queryLimit.trim().length() == 0 ) {
      queryLimit = "100";
    }
    if(selAvailability == null || selAvailability.trim().length() == 0) {
      selAvailability = DomainObject.QUERY_WILDCARD;
    }
    String selName = emxGetParameter(request,"Name");
    if(selName == null || selName.trim().length() == 0) {
      selName = DomainObject.QUERY_WILDCARD;
    }
    if(selDisplayVault == null || selDisplayVault.equalsIgnoreCase("null")) {
        selDisplayVault = "";
    }
    if(selVaultName != null && selVaultName.trim().length() != 0) {
        strVaults = selVaultName;
    }  
    if(previousCommand == null || previousCommand.trim().length() == 0) {
      previousCommand = commandName;
    }
    if(!previousCommand.equals(commandName)) {
      selName = DomainObject.QUERY_WILDCARD;
      selAvailability=DomainObject.QUERY_WILDCARD;
      selPurpose=DomainObject.QUERY_WILDCARD;
    }
    
    if(selVaultOption == null || selVaultOption.trim().length() == 0) {
        if (  PersonUtil.SEARCH_DEFAULT_VAULT.equals(vaultDefaultSelection) ) {
            selVaultOptionDefault = "checked";
        } else if (  PersonUtil.SEARCH_LOCAL_VAULTS.equals(vaultDefaultSelection) ) {
            selVaultOptionLocal = "checked";
        } else if (  PersonUtil.SEARCH_ALL_VAULTS.equals(vaultDefaultSelection) ) {
            selVaultOptionAll = "checked";
        } else if (!PersonUtil.SEARCH_DEFAULT_VAULT.equals(vaultDefaultSelection) &&
               !PersonUtil.SEARCH_LOCAL_VAULTS.equals(vaultDefaultSelection) &&
               !PersonUtil.SEARCH_ALL_VAULTS.equals(vaultDefaultSelection) ) {
            selVaultOptionSelected = "checked";
            strVaults = vaultDefaultSelection;
            selDisplayVault = i18nNow.getI18NVaultNames(context, vaultDefaultSelection, request.getHeader("Accept-Language"));
        }

    } else if (selVaultOption.equals(PersonUtil.SEARCH_ALL_VAULTS)) {
      selVaultOptionLocal = "";
      selVaultOptionAll = "checked";
      selVaultOptionDefault = "";
      selVaultOptionSelected = "";
    } else if (selVaultOption.equals(PersonUtil.SEARCH_DEFAULT_VAULT)) {
      selVaultOptionLocal = "";
      selVaultOptionAll = "";
      selVaultOptionDefault = "checked";
      selVaultOptionSelected = "";
    } else if (selVaultOption.equals(PersonUtil.SEARCH_LOCAL_VAULTS)) {
      selVaultOptionLocal = "checked";
      selVaultOptionAll = "";
      selVaultOptionDefault = "";
      selVaultOptionSelected = "";
    } else if (selVaultOption.equals("Selected")) {
      selVaultOptionLocal = "";
      selVaultOptionAll = "";
      selVaultOptionDefault = "";
      selVaultOptionSelected = "checked";
    }

 %>

<body onload="turnOffProgress(),getTopWindow().loadSearchFormFields()">
<form name="editDataForm" method="post" onSubmit="submitForm(); return false">
<%
    while(enumParamNames.hasMoreElements()) {
        paramName = (String) enumParamNames.nextElement();
        paramValue = (String)emxGetParameter(request, paramName);
        if (paramValue != null && paramValue.trim().length() > 0 ) {
          requestMap.put(paramName, paramValue);
        }
        if(!paramName.equals("Name") &&
           !paramName.equals("Availability") &&
           !paramName.equals("Purpose") &&
           !paramName.equals("State") &&
           !paramName.equals("vaultOption") &&
           !paramName.equals("vaultName") &&
           !paramName.equals("vaultNameDisplay") &&
           !paramName.equals("queryLimit") &&
           !paramName.equals("timeStamp") &&
           !paramName.equals("pagination") &&
           !paramName.equals("previousCommand") && !paramName.equals("objectId") && !paramName.equals("table")) {
%>
            <input type="hidden" name="<xss:encodeForHTMLAttribute><%=paramName%></xss:encodeForHTMLAttribute>" value="<xss:encodeForHTMLAttribute><%=paramValue%></xss:encodeForHTMLAttribute>" />
<%
      }
    }
    requestMap.put("languageStr", request.getHeader("Accept-Language") );
    paramMap.put("requestMap",requestMap );
%>


    <input type="hidden" value ="<%=XSSUtil.encodeForHTMLAttribute(context,queryLimit)%>" name ="queryLimit" />
    <input type="hidden" value ="<%=XSSUtil.encodeForHTMLAttribute(context,queryLimit)%>" name ="QueryLimit" />
    <input type="hidden" name="timeStamp" value="<%=XSSUtil.encodeForHTMLAttribute(context,timeStamp)%>" />
    <input type="hidden" value ="<%=XSSUtil.encodeForHTMLAttribute(context,pagination)%>" name ="pagination" />
    <input type="hidden" value ="<%=XSSUtil.encodeForHTMLAttribute(context,commandName)%>" name ="CommandName" />
    <input type="hidden" name="objectId" value="<%=XSSUtil.encodeForHTMLAttribute(context,sObjectId)%>" />
    <input type="hidden" name="table" value='<xss:encodeForHTMLAttribute><%=emxGetParameter(request, "table")%></xss:encodeForHTMLAttribute>' />

    <table border="0" cellpadding="5" cellspacing="2" width="100%">
        <tr>
            <td width="150" class="label"><label for="Type"><emxUtil:i18n localize="i18nId">emxFramework.Basic.Type</emxUtil:i18n></label></td>
            <td width="550" class="inputField"><img src="../common/images/<%=typeIcon%>" /><%=typeI18N%></td>
        </tr>
        <tr>
            <td width="150" class="label"><label for="Type"><emxUtil:i18n localize="i18nId">emxFramework.Basic.Name</emxUtil:i18n></label></td>
            <td width="550" class="inputField">
                <input type="text" name="Name" id="" value="<%=XSSUtil.encodeForHTMLAttribute(context,selName)%>" />
            </td>
        </tr>

        <tr>
            <td nowrap="nowrap" class="label"><emxUtil:i18n localize="i18nId">emxComponents.RouteTemplate.Availability</emxUtil:i18n></td>
            <td width="550" class="inputField">
<%
                String propertyFile        = "emxComponentsStringResource";
				Locale locale			   = context.getLocale(); 
                String i18nEnterpriseScope = EnoviaResourceBundle.getProperty(context, propertyFile, locale, "emxComponents.SearchTemplate.Enterprise");
                String i18nAllScope = EnoviaResourceBundle.getProperty(context, propertyFile, locale, "emxComponents.Routes.All");
                String i18nUserScope       = EnoviaResourceBundle.getProperty(context, propertyFile, locale, "emxComponents.SearchTemplate.User");

%>

                <select name="Availability">
<%
                if(restrictAvailability == null || restrictAvailability.trim().length() == 0 || "null".equalsIgnoreCase(restrictAvailability)){
%>
                    
					
					<option value="*"%><%=i18nAllScope%></option>
                    <option value="Enterprise" <%="Enterprise".equalsIgnoreCase(selAvailability)?"Selected":""%>><%=i18nEnterpriseScope%></option>
                    <option value="User" <%="User".equals(selAvailability)?"Selected":""%>><%=i18nUserScope%></option>

<%
                } else if (restrictAvailability.equalsIgnoreCase("Enterprise")){
%>
                    <option value="Enterprise" <%="Enterprise".equalsIgnoreCase(selAvailability)?"Selected":""%>><%=i18nEnterpriseScope%></option>
<%
                } else if (restrictAvailability.equalsIgnoreCase("User")){
%>
                    <option value="User" <%="User".equalsIgnoreCase(selAvailability)?"Selected":""%>><%=i18nUserScope%></option>
<%
                }
%>
                </select>
            </td>
        </tr>

        <tr>
            <td nowrap="nowrap" class="label"><emxUtil:i18n localize="i18nId">emxComponents.Route.RouteBasePurpose</emxUtil:i18n></td>
            <td width="550" class="inputField">
                <select name="Purpose">
<%
                if(restrictToPurpose == null || restrictToPurpose.trim().length() == 0) {
%>
                    <option value="*"><emxUtil:i18n localize="i18nId">emxComponents.Search.Star</emxUtil:i18n></option>
<%                  StringItr strPurposeItr = new StringItr(FrameworkUtil.getRanges(context,sAttrRouteBasePurpose));
                    String sAttrRange       = "";
                    while(strPurposeItr.next()) {
                     sAttrRange = strPurposeItr.obj();
%>
                     <option value="<%= sAttrRange %>" <%=sAttrRange.equals(selPurpose)?"Selected":""%>><%= i18nNow.getRangeI18NString(sAttrRouteBasePurpose, sAttrRange,request.getHeader("Accept-Language")) %></option>
<%
                    }

                 } else {
%>
                    <option value="<%=XSSUtil.encodeForHTMLAttribute(context,restrictToPurpose)%>"><xss:encodeForHTML><%=i18nNow.getRangeI18NString(sAttrRouteBasePurpose,restrictToPurpose,request.getHeader("Accept-Language"))%></xss:encodeForHTML></option>
<%
                 } 
%>

                </select>

            </td>
        </tr>

        <tr>
          <td width="150" class="label"><emxUtil:i18n localize="i18nId">emxComponents.Common.OwningOrganization</emxUtil:i18n></td>
          <td class="inputField"><input type="text" name="owningOrg" value="<%=XSSUtil.encodeForHTMLAttribute(context,sOwningOrganizationName) %>" size="20" onFocus="blur()" />
          <input type="button" name="" value="..." onclick="javascript:ShowOrg();" />
          <a href onClick="clearRoutesOwningOrg();return false;"><emxUtil:i18n localize="i18nId">emxComponents.Common.Clear</emxUtil:i18n></a>
            </td>
        </tr>
	  <!-- Added For X3 -->
<% if(TYPE_PLANT.equals(stype))
{
%>
<input type="hidden" name="PlantId" size="20" value="<%=XSSUtil.encodeForHTMLAttribute(context,sLocationId)%>" />
<%}%>
<!--End-->
        <tr>
            <td nowrap="nowrap" class="label">
                <framework:i18n localize="i18nId">emxComponents.Common.Vault</framework:i18n>
            </td>
            <td nowrap="nowrap" class="field">

<%
            String vaultAwareness = EnoviaResourceBundle.getProperty(context,"eServiceSuiteComponents.VaultAwareness");
            if (vaultAwareness.equalsIgnoreCase("FALSE")) {
%>
                 <input type="radio"  value="<%=PersonUtil.SEARCH_DEFAULT_VAULT%>" <%=selVaultOptionDefault%> name="vaultOption"><emxUtil:i18n localize="i18nId">emxComponents.Common.Default</emxUtil:i18n><br/>
                 <input type="radio"  value="<%=PersonUtil.SEARCH_LOCAL_VAULTS%>" <%=selVaultOptionLocal%> name="vaultOption" ><emxUtil:i18n localize="i18nId">emxComponents.Common.Local</emxUtil:i18n><br/>
                 <input type="radio"  value="Selected" <%=selVaultOptionSelected%> name="vaultOption" /><emxUtil:i18n localize="i18nId">emxComponents.Common.Selected</emxUtil:i18n>
                 <input type="text"   name="vaultNameDisplay" value ="<%=XSSUtil.encodeForHTMLAttribute(context,selDisplayVault)%>" id="" size="20" readonly="readonly" />
                 <input type="button" name="btn" value="..." onclick="javascript:document.forms[0].vaultOption[2].checked=true;showChooser('../common/emxVaultChooser.jsp?multiSelect=false&fieldNameActual=vaultName&fieldNameDisplay=vaultNameDisplay&isFromSearchForm=true','700','500');" />
                 <input type="hidden" name="vaultName" value ="<%=XSSUtil.encodeForHTMLAttribute(context,strVaults)%>" id="" size="20"><br/>
                 <input type="radio"  value="<%=PersonUtil.SEARCH_ALL_VAULTS%>"  <%=selVaultOptionAll%> name="vaultOption" /><emxUtil:i18n localize="i18nId">emxComponents.Common.All</emxUtil:i18n>
<%
            } else {
%>
              <xss:encodeForHTML><%=strVaults%></xss:encodeForHTML>
<%
            }
%>
            </td>
        </tr>
    </table>&nbsp;
</form>
</body>
<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
