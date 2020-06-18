<%--  emxEngrFindLocation.jsp   - Location Search page.
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@include file = "emxDesignTopInclude.inc"%>
<%@include file = "emxEngrVisiblePageInclude.inc"%>


<script language="JavaScript">
<%
  /***********************************Vault Code Start*****************************************/
  // Display Vault Field as options
  String sGeneralSearchPref ="";
  String allCheck ="";
  String defaultCheck ="";
  String localCheck ="";
  String selectedVaults ="";
  String selectedVaultsValue ="";

  try{
    sGeneralSearchPref = com.matrixone.apps.common.Person.getPropertySearchVaults(context);
  } catch(Exception ex){
    throw ex;
  }

  // Check the User SearchVaultPreference Radio button
  if(sGeneralSearchPref.equals("ALL_VAULTS")  || sGeneralSearchPref.equals("")) {
    allCheck="checked";
  } else if (sGeneralSearchPref.equals("LOCAL_VAULTS")){
    localCheck="checked";
  } else if (sGeneralSearchPref.equals("DEFAULT_VAULT")) {
    defaultCheck="checked";
  } else {
    selectedVaults="checked";
    com.matrixone.apps.common.Person person = com.matrixone.apps.common.Person.getPerson(context);
    selectedVaultsValue = person.getSearchDefaultVaults(context);

  }
  /***********************************Vault Code End***************************************/
%>
  var bVaultMultiSelect = true;
  var strTxtVault = "document.forms['FindLocation'].selVaults.value";
  var txtVault = null;

  <!----------------------------------Vault Code Start--------------------------------------->
  var strSelectOption = "document.forms['FindLocation'].vaultOption[3]";
  var selectOption = null;

  function showVaultSelector()
  {
    txtVault = eval(strTxtVault);
    selectOption = eval(strSelectOption);
    showModalDialog('../components/emxComponentsSelectSearchVaultsDialogFS.jsp?multiSelect="+bVaultMultiSelect+"&fieldName=selVaults&selectedVaults="+txtVault+"&incCollPartners=true', 300, 350);
  }

  function clearSelectedVaults() {
    document.FindLocation.tempStore.value=document.FindLocation.selVaults.value
    document.FindLocation.vaultOption[3].value="";
    document.FindLocation.selVaults.value="";
  }

  function showSelectedVaults() {
    document.FindLocation.selVaults.value=document.FindLocation.tempStore.value;
  }
  function selectSelectedVaultsOption() {
    document.FindLocation.vaultOption[3].checked=true;
  }

<!-----------------------------------Vault Code End-------------------------------------->
</script>
<%
   String strTypeName = emxGetParameter(request,"typename");
   String isMepLocation = emxGetParameter(request, "isMepLocation");
   String strFieldName = emxGetParameter(request,"field");
   String rowselect = emxGetParameter(request,"rowselect");
   String isAVLReport = emxGetParameter(request,"isAVLReport");
   String languageStr = request.getHeader("Accept-Language");
   // Added for MCC EC Interoperability Feature
   String sFieldNameDisplay = emxGetParameter(request,"fieldNameDisplay");
   String sFieldNameId = emxGetParameter(request,"fieldNameId");
   String sSelManufacturerId = emxGetParameter(request,"manufacturerId");
   String sFormName = emxGetParameter(request,"formName");
   String isManufacturingLocation = emxGetParameter(request,"isManufacturingLocation");
   // Modified for Bug No:329148 - Start
   String checkFromConnectAccess = emxGetParameter(request,"checkFromConnectAccess");
   // Modified for Bug No:329148 - End
   

   if(isMepLocation == null || "null".equals(isMepLocation) || "".equals(isMepLocation)){
		isMepLocation = (String)session.getAttribute("isMepLocation");
   }
   if(sFieldNameDisplay == null || "null".equals(sFieldNameDisplay) || "".equals(sFieldNameDisplay))
   {
		sFieldNameDisplay = (String)session.getAttribute("fieldNameDisplay");
   }
   else 
   {
		session.setAttribute("fieldNameDisplay",sFieldNameDisplay);
   }
   

   if(sSelManufacturerId == null || "".equals(sSelManufacturerId) || "null".equalsIgnoreCase(sSelManufacturerId) ) 
   {
      //get the value from session if present.
      //Required when user comes for the first time & click on "Location" command present on toolbar.In this case it refresh the page & all request value are lost
      String sLocationType =PropertyUtil.getSchemaProperty(context,"type_Location");
      if(strTypeName.equals(sLocationType))
      {
          sFieldNameDisplay = (String)session.getAttribute("fieldNameDisplay");
          sFieldNameId = (String)session.getAttribute("fieldNameId");
          sSelManufacturerId = (String)session.getAttribute("manufacturerId");
          sFormName = (String)session.getAttribute("formName");
          isManufacturingLocation = (String)session.getAttribute("isManufacturingLocation");
          checkFromConnectAccess = (String)session.getAttribute("checkFromConnectAccess");
      }
   }
   //end

   if(rowselect == null || "".equals(rowselect) || "null".equalsIgnoreCase(rowselect) ) {
    //get the value from session if present
      try {
          rowselect = (String)session.getAttribute("rowselect");
       }catch(Exception e)  {
       //do nothing......catching IllegalStateException
       }
      //if not in session also set to default single
       if(rowselect == null || "".equals(rowselect) || "null".equalsIgnoreCase(rowselect) ) {
          rowselect = "multi";
      }
   }

   if(!"single".equalsIgnoreCase(rowselect) && !"multi".equalsIgnoreCase(rowselect) ) {
         rowselect = "single";
   }

   if(isAVLReport == null) {
      //get the value from session if present
      try {
          isAVLReport = (String)session.getAttribute("isAVLReport");
       }catch(Exception e)  {
           //catching IllegalStateException
           isAVLReport = "FALSE";
       }
      //if not in session also set to default false
       if(isAVLReport == null) {
          isAVLReport = "FALSE";
      }

   }

   if(!"TRUE".equals(isAVLReport) && !"FALSE".equals(isAVLReport)) {
         isAVLReport = "FALSE";
   }

   //setting the value in session for when comes for the first time
   session.setAttribute("rowselect",rowselect);
   session.setAttribute("isAVLReport",isAVLReport);
   // Added for MCC EC Interoperability Feature
   session.setAttribute("fieldNameDisplay",sFieldNameDisplay);
   session.setAttribute("fieldNameId",sFieldNameId);
   session.setAttribute("manufacturerId",sSelManufacturerId);
   session.setAttribute("formName",sFormName);
   session.setAttribute("isManufacturingLocation",isManufacturingLocation);
   session.setAttribute("checkFromConnectAccess",checkFromConnectAccess);
   session.setAttribute("isMepLocation",isMepLocation);
   //end 

   String defaultTypeIcon    = JSPUtil.getCentralProperty(application, session, "type_Default", "SmallIcon");
   String typeIcon     = null;

   String alias = FrameworkUtil.getAliasForAdmin(context, "type", strTypeName, true);
   if ((alias == null) || (alias.equals("null")) || (alias.equals(""))) {
       typeIcon = defaultTypeIcon;
   } else {
        typeIcon = JSPUtil.getCentralProperty(application, session, alias, "SmallIcon");
   }

   if(typeIcon == null) {
       typeIcon = defaultTypeIcon;
   }
   String typeName = strTypeName.replace(' ','_');
 //Multitenant
   //String displayType = i18nNow.getI18nString("emxFramework.Type."+typeName,"emxFrameworkStringResource",languageStr);
   String displayType = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", context.getLocale(),"emxFramework.Type."+typeName); 

%>
<html>
<head>
<META http-equiv="Content-Type" content="text/html; charset=UTF-8" />

<script language="JavaScript" src="../common/scripts/emxUIConstants.js"></script>
<script type="text/javascript">
    addStyleSheet("emxUIDefault");
    addStyleSheet("emxUIForm");
    addStyleSheet("emxUIList");
    addStyleSheet("emxUIMenu");
    addStyleSheet("emxUIToolbar");


</script>

<title></title>
<meta http-equiv="imagetoolbar" content="no" />
<meta http-equiv="pragma" content="no-cache" />
<script language="JavaScript" src="../common/scripts/emxUIConstants.js"></script>
<script language="JavaScript" src="../common/scripts/emxUICore.js"></script>
<script language="JavaScript" src="../common/scripts/emxUIModal.js"></script>
<script language="JavaScript" src="../common/scripts/emxUIPopups.js"></script>
<script language="JavaScript" src="../common/scripts/emxUISearch.js"></script>

<script language="JavaScript">

function doSearch() {
     
       if((document.FindLocation.vaultOption[3].checked==true) && (document.FindLocation.selVaults.value==""))
       {
             alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.VaultOptions.PleaseSelectVault</emxUtil:i18nScript>");
             return;
       }
        if(document.FindLocation.vaultOption[3].checked==true)
        {
            document.FindLocation.vaultOption[3].value=document.FindLocation.selVaults.value;
        }

   //get the form
   var theForm = document.forms[0];
   var type = theForm.typename.value;
   theForm.target = "searchView";
   theForm.submit();

}

</script>
</head>

<body onload="turnOffProgress();top.loadSearchFormFields()">

<form name="FindLocation" method="post" Action="emxEngrLocationSearchResultsFS.jsp" onSubmit="return false">
<input type="hidden" name="typename" value="<xss:encodeForHTMLAttribute><%=strTypeName %></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="isMepLocation" value="<xss:encodeForHTMLAttribute><%=isMepLocation %></xss:encodeForHTMLAttribute>" />

<input type="hidden" name="isManufacturingLocation" value="<xss:encodeForHTMLAttribute><%=isManufacturingLocation %></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="checkFromConnectAccess" value="<xss:encodeForHTMLAttribute><%=checkFromConnectAccess %></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="QueryLimit" value="" />
<input type="hidden" name="rowselect" value="<xss:encodeForHTMLAttribute><%=rowselect%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="isAVLReport" value="<xss:encodeForHTMLAttribute><%=isAVLReport%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="pagination" value="true" />
<%
     // Added for MCC EC Interoperability Feature
     if(sSelManufacturerId != null || !"null".equalsIgnoreCase(sSelManufacturerId) || !"".equals(sSelManufacturerId) ) 
     {
%>  
        <input type="hidden" name="manufacturerId" value="<xss:encodeForHTMLAttribute><%=sSelManufacturerId%></xss:encodeForHTMLAttribute>" />
        <input type="hidden" name="fieldNameDisplay" value="<xss:encodeForHTMLAttribute><%=sFieldNameDisplay%></xss:encodeForHTMLAttribute>" />
        <input type="hidden" name="fieldNameId" value="<xss:encodeForHTMLAttribute><%=sFieldNameId%></xss:encodeForHTMLAttribute>" />
        <input type="hidden" name="formName" value="<xss:encodeForHTMLAttribute><%=sFormName%></xss:encodeForHTMLAttribute>" />
<%  }
     //end 
%>

<table border="0" cellpadding="5" cellspacing="2" width="100%">
<tr>
<td width="150" class="label"><emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.Type</emxUtil:i18n></td>
<td class="inputField">
<table border="0">
<tr>
<!-- XSSOK -->
<td valign="top"><img src="../common/images/<%=typeIcon %>" border="0" alt="<xss:encodeForHTMLAttribute><%=strTypeName %></xss:encodeForHTMLAttribute>" /></td>
<td><span class="object"><xss:encodeForHTML><%=displayType %></xss:encodeForHTML></span></td>
</tr>
</table>
</td>
</tr>
<tr>
<td width="150" class="label"><emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.Name</emxUtil:i18n></td>
<td class="inputField">
<input type="text" size="20" value="*" name="txtLocName" id="txtLocName"/></td>
</tr>
<!----------------------------------Vault Code Start--------------------------------------->
  <tr>
      <td class="label"><emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.Vault</emxUtil:i18n></td>
      <td class="inputField">
        <table border="0">
          <tr>
            <td>
            <!-- XSSOK -->
              <input type="radio" <%=allCheck%> value="ALL_VAULTS" name="vaultOption" onClick="javascript:clearSelectedVaults();" />
            </td>
            <!-- XSSOK -->
            <%--Multitenant--%>
		  <%--<td><%=i18nNow.getI18nString("emxEngineeringCentral.VaultOptions.All", "emxEngineeringCentralStringResource", languageStr)%></td>--%>
		  <td><%=EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.VaultOptions.All")%></td>
          </tr>
          <tr>
            <td>
            <!-- XSSOK -->
              <input type="radio"  <%=localCheck%> value="LOCAL_VAULTS" name="vaultOption" onClick="javascript:clearSelectedVaults();" />
            </td>
            <!-- XSSOK -->
            <%--Multitenant--%>
		    <%--<td><%=i18nNow.getI18nString("emxEngineeringCentral.VaultOptions.Local", "emxEngineeringCentralStringResource", languageStr)%></td>--%>
		    <td><%=EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.VaultOptions.Local")%></td>
          </tr>
          <tr>
            <td>
            <!-- XSSOK -->
              <input type="radio" <%=defaultCheck%> value="DEFAULT_VAULT" name="vaultOption" onClick="javascript:clearSelectedVaults();" />
            </td>
            <!-- XSSOK -->
            <%--Multitenant--%>
		    <%--<%=i18nNow.getI18nString("emxEngineeringCentral.VaultOptions.Default", "emxEngineeringCentralStringResource", languageStr)%></td>--%>
		    <%=EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.VaultOptions.Default")%></td>
          </tr>
          <tr>
            <td>
            <!-- XSSOK -->
              <input type="radio" <%=selectedVaults%> value="<%=selectedVaultsValue%>" name="vaultOption" onClick="javascript:showSelectedVaults();" />
            </td>
            <td>
            <!-- XSSOK -->
              <%--Multitenant--%>
		      <%--<%=i18nNow.getI18nString("emxEngineeringCentral.VaultOptions.Selected", "emxEngineeringCentralStringResource", languageStr)%>--%>
		      <%=EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.VaultOptions.Selected")%></td>
          <input type="text" name="selVaults" size="20" readonly="readonly" value="<xss:encodeForHTMLAttribute><%=selectedVaultsValue%></xss:encodeForHTMLAttribute>" />
              <input class="button" type="button" size = "200" value="..." alt="..." onClick="javascript:showVaultSelector();selectSelectedVaultsOption()" />
              <input type="hidden" name="tempStore" value="<xss:encodeForHTMLAttribute><%=selectedVaultsValue%></xss:encodeForHTMLAttribute>" />
            </td>
          </tr>
        </table>
      </td>
  </tr>
<!----------------------------------Vault Code End--------------------------------------->

</table>
<table border="0" cellpadding="5" cellspacing="2" width="100%">
<tr>
<td></td>
</tr>
</table>
</form>
<table width="100%" align="center" cellspacing="0" cellpadding="0">
<tr></tr>
<tr></tr>
<tr></tr>
<tr></tr>
<tr></tr>
</table>
</body>
</html>
