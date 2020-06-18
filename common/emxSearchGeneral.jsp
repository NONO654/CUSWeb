<%-- emxSearchGeneral.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxSearchGeneral.jsp.rca 1.46 Wed Oct 22 15:48:26 2008 przemek Experimental przemek $
--%>

<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>

<%
boolean showAdvancedLink = true;

String useTypeChooser = emxGetParameter(request, "useTypeChooser");
String typeSelection = emxGetParameter(request, "SelectType");
String editable = emxGetParameter(request, "editable");
String InclusionList = emxGetParameter(request, "InclusionList");
String ExclusionList = emxGetParameter(request, "ExclusionList");
String SelectAbstractTypes = emxGetParameter(request,"SelectAbstractTypes");
String multiSelect = emxGetParameter(request, "multiSelect");
String incCollPartners = emxGetParameter(request, "incCollPartners");
StringBuffer typeChooserURL = new StringBuffer(150);
StringBuffer vaultChooserURL = new StringBuffer(100);
StringList vaultList = new StringList();
String vaultDefaultSelection = "";
String languageStr = request.getHeader("Accept-Language");
boolean isTypeFieldEditable = true;
String contextVault = "";
String lastSearchedTypes = "";
StringBuffer translatedTypeNames = new StringBuffer(80);
String strContainedIn = "";
String strActualContainedIn = "";
String strContainedInType="";
String strContainedInRev="";
String headerText = "emxFramework.GlobalSearch.SearchResults";
String containedInFlag=emxGetParameter(request, "containedInFlag");


if (containedInFlag==null|| "null".equals(containedInFlag)||"".equals(containedInFlag))
{
    containedInFlag="true";
}
if (containedInFlag.equals("false"))
{
    headerText = "emxFramework.GlobalSearch.SearchResultsContainedIn";
}

// set the default value as true if parameter is not passed
if(incCollPartners == null || "null".equals(incCollPartners))
{
  incCollPartners = "true";
}

// set the default value as 'true' if parameter is not passed
if(multiSelect == null || "null".equals(multiSelect))
{
  multiSelect = "true";
}

try{
    ContextUtil.startTransaction(context, false);
    if(!"false".equalsIgnoreCase(useTypeChooser) && !"true".equalsIgnoreCase(editable)) {
        isTypeFieldEditable = false;
    }

    if(typeSelection == null || "".equals(typeSelection)) {
        typeSelection = "multiselect";
    }

    typeChooserURL.append("emxTypeChooser.jsp?callbackFunction=updateType&formName=SearchForm&frameName=searchContent&fieldNameActual=txtTypeActual&fieldNameDisplay=txtTypeDisplay");
    typeChooserURL.append("&SelectType=");
    typeChooserURL.append(XSSUtil.encodeForURL(context, typeSelection));

    //Allow type chooser to use abstract types?
    if(SelectAbstractTypes != null && "false".equals(SelectAbstractTypes.toLowerCase())) {
        SelectAbstractTypes = "false";
    }else{
        SelectAbstractTypes = "true";
    }
    typeChooserURL.append("&SelectAbstractTypes=");
    typeChooserURL.append(XSSUtil.encodeForURL(context, SelectAbstractTypes));

    if(InclusionList != null && InclusionList.trim().length() > 0) {
        typeChooserURL.append("&InclusionList=");
        typeChooserURL.append(XSSUtil.encodeForURL(context, InclusionList));
    } else if(ExclusionList != null && ExclusionList.trim().length() > 0) {
        typeChooserURL.append("&ExclusionList=");
        typeChooserURL.append(XSSUtil.encodeForURL(context, ExclusionList));
    } else {
        typeChooserURL.append("&InclusionList=emxFramework.GenericSearch.Types");
    }

    //vaultList = FrameworkUtil.split(OrganizationUtil.getAllVaults(context, PersonUtil.getUserCompanyId(context), true),",");
    vaultDefaultSelection = PersonUtil.getSearchDefaultSelection(context);

    if(vaultDefaultSelection == null || "".equals(vaultDefaultSelection)) {
       vaultDefaultSelection = EnoviaResourceBundle.getProperty(context, "emxFramework.DefaultSearchVaults");
    }
    strContainedIn = emxGetParameter(request, "txtContainedIn");
    strActualContainedIn = emxGetParameter(request, "txtActualContainedIn");

    if ((strActualContainedIn == null) || "null".equalsIgnoreCase(strActualContainedIn))
     {
          strActualContainedIn = "";
     }
    if ((strContainedIn == null) || "null".equalsIgnoreCase(strContainedIn))
     {
          strContainedIn = "";
     }
//Contained Object Type Name and Rev Information
    strContainedInType = emxGetParameter(request, "txtContainedInType");

    if ((strContainedInType == null) || "null".equalsIgnoreCase(strContainedInType))
     {
          strContainedInType = "";
     }
    
    strContainedInRev = emxGetParameter(request, "txtContainedInRev");

    if ((strContainedInRev == null) || "null".equalsIgnoreCase(strContainedInRev))
     {
          strContainedInRev = "";
     }

    vaultChooserURL.append("emxVaultChooser.jsp?fieldNameActual=vaults&fieldNameDisplay=vaultsDisplay");
    vaultChooserURL.append("&multiSelect=");
    vaultChooserURL.append(XSSUtil.encodeForURL(context, multiSelect));
    vaultChooserURL.append("&incCollPartners=");
    vaultChooserURL.append(XSSUtil.encodeForURL(context, incCollPartners));

    //get last searched types for this user
    if("true".equals(containedInFlag)) {
        lastSearchedTypes = PersonUtil.getLastContainedInSearchedTypePreference(context);
    }else {
        lastSearchedTypes = PersonUtil.getLastSearchedTypePreference(context);
    }

    if(lastSearchedTypes != null && !"".equals(lastSearchedTypes) && !"null".equals(lastSearchedTypes))
    {
        StringList sl = FrameworkUtil.split(lastSearchedTypes, ",");
        // Loop through the list and create the map.
        Iterator itr = sl.iterator();
        while (itr.hasNext())
        {
           String typeName = (String) itr.next();
           String translatedTypeName = i18nNow.getTypeI18NString(typeName, languageStr);
           if(translatedTypeNames.toString() == null || "".equals(translatedTypeNames.toString()))
           {
              translatedTypeNames.append(translatedTypeName);
           }
           else
           {
              translatedTypeNames.append(",").append(translatedTypeName);
           }
        }
    }

}catch (Exception ex){
    ContextUtil.abortTransaction(context);

    if(ex.toString() != null && (ex.toString().trim()).length()>0){
            emxNavErrorObject.addMessage("emxSearch:" + ex.toString().trim());
    }
}
finally{
    ContextUtil.commitTransaction(context);
}

  

    

%>
<html>
<head>
<title></title>
<%@include file = "emxUIConstantsInclude.inc"%>
<script type="text/javascript" language="javascript" src="scripts/emxUICalendar.js"></script>
<script type="text/javascript" language="JavaScript" src="scripts/emxUIModal.js"></script>
<script type="text/javascript" language="JavaScript" src="scripts/emxUIPopups.js"></script>
<script type="text/javascript" language="JavaScript" src="scripts/emxUICalendar.js"></script>
<script type="text/javascript" language="JavaScript" src="scripts/emxSearchGeneral.js"></script>
<script type="text/javascript">addStyleSheet("emxUIContainedInSearch");</script>

</head>
<body onload="doLoad(), turnOffProgress(), getTopWindow().loadSearchFormFields()">
    <form method="post" name="SearchForm" id="SearchForm" onsubmit="doSubmit(); return false">
      <table border="0" cellpadding="5" cellspacing="2" width="100%">
        <tr>
          <td width="150" class="label"><emxUtil:i18n localize="i18nId">emxFramework.Common.Type</emxUtil:i18n></td>

          <td class="inputField">
          <% if(isTypeFieldEditable){ %>
          <input type="text" name="txtTypeDisplay" id="txtTypeDisplay" value="<%=translatedTypeNames.toString()%>" size="20" onChange="updateType(this.value);"/>
          <% }else{ %>
          <input type="text" name="txtTypeDisplay" id="txtTypeDisplay" value="<%=translatedTypeNames.toString()%>" size="20" readonly="readonly"/>
          <% } %>
          <input type="hidden" name="txtTypeActual" id="txtTypeActual" value="<%=lastSearchedTypes%>"/>
<%
        if(!"false".equalsIgnoreCase(useTypeChooser)) {
%>
            <!-- //XSSOK -->
            <input name="button" type="button" value="..." onclick="javascript:getTopWindow().showChooser('<%=typeChooserURL.toString()%>', 500, 500)"/>
            &nbsp;
            <a class="dialogClear" href="javascript:;" onclick="javascript:clearType()"><emxUtil:i18n localize="i18nId">emxFramework.Common.Clear</emxUtil:i18n></a>
<%
        }
%>
          </td>
        </tr>
        <tr>
          <td width="150" class="label"><emxUtil:i18n localize="i18nId">emxFramework.Common.Name</emxUtil:i18n></td>
          <!--  To display dynamic textarea in General Consolidated Search -->
          <td class="inputField"><input type="text" size="20" value="*" name="txtName" id="txtName" onFocus="displayDynamicTextarea(this)" />
          </td>
        </tr>
        <tr>
          <td width="150" class="label"><emxUtil:i18n localize="i18nId">emxFramework.Basic.Revision</emxUtil:i18n></td>
          <td class="inputField"><input type="text" name="txtRev" id="txtRev" value="*"/>
            <input type="checkbox" name="latestRevision" value="last" onclick="javascript:disableRevision()"/><emxUtil:i18n localize="i18nId">emxFramework.GlobalSearch.LatestRevisionOnly</emxUtil:i18n></td>
        </tr>



        <tr>
          <td width="150" class="label"><emxUtil:i18n localize="i18nId">emxFramework.Basic.Vault</emxUtil:i18n>&nbsp;</td>
          <td class="inputField">
            <table border="0" cellspacing="1" cellpadding="2">
            <tr>
<%
               String checked = "";
               if (  PersonUtil.SEARCH_DEFAULT_VAULT.equals(vaultDefaultSelection) )
               {
                  checked = "checked";
               }
%>
               <!-- //XSSOK -->
               <td><input name="vaultSelction" type="radio" value="<%=PersonUtil.SEARCH_DEFAULT_VAULT%>" <%=checked%> />
                  <emxUtil:i18n localize="i18nId">emxFramework.Preferences.UserDefaultVault</emxUtil:i18n>&nbsp;
               </td>
            </tr>
            <tr>
<%
               checked = "";
               if (  PersonUtil.SEARCH_LOCAL_VAULTS.equals(vaultDefaultSelection) )
               {
                  checked = "checked";
               }
%>
               <!-- //XSSOK -->
               <td><input name="vaultSelction" type="radio" value="<%=PersonUtil.SEARCH_LOCAL_VAULTS%>" <%=checked%> />
                   <emxUtil:i18n localize="i18nId">emxFramework.Preferences.LocalVaults</emxUtil:i18n>&nbsp;
               </td>
            </tr>
            <tr>
<%
               checked = "";
               String vaults = "";
               String selVault = "";
               String selDisplayVault = "";
               String vaultSelected = vaultDefaultSelection;
               if (!PersonUtil.SEARCH_DEFAULT_VAULT.equals(vaultDefaultSelection) &&
                   !PersonUtil.SEARCH_LOCAL_VAULTS.equals(vaultDefaultSelection) &&
                   !PersonUtil.SEARCH_ALL_VAULTS.equals(vaultDefaultSelection) )
               {
                  checked = "checked";
                  selDisplayVault = i18nNow.getI18NVaultNames(context, vaultDefaultSelection, languageStr);
               }else{
                  vaultSelected = "";
               }
 %>
               <!-- //XSSOK -->
               <td><input type="radio" name="vaultSelction" value="SELECTED_VAULT" <%=checked%> />
                  <emxUtil:i18n localize="i18nId">emxFramework.Preferences.SelectedVaults</emxUtil:i18n>&nbsp;
                  <input type="text" name="vaultsDisplay" value="<%=selDisplayVault%>" size="15" readonly="readonly" onfocus="this.title=this.value;" onmouseover="this.title=this.value;" title="<%=selDisplayVault%>" />
                  <!-- //XSSOK -->
                  <input name="btnType" type="button" value="..." onclick="javascript:setSelectedVaultOption('<%=vaultChooserURL.toString()%>')" />
                  <input type="hidden" name="vaults" value="<%=vaultDefaultSelection%>" size="15" />
                  &nbsp;
                  <a class="dialogClear" href="javascript:;" onclick="javascript:clearVault()"><emxUtil:i18n localize="i18nId">emxFramework.Common.Clear</emxUtil:i18n></a>
               </td>
            </tr>
            <tr>
 <%
               checked = "";
               if (  PersonUtil.SEARCH_ALL_VAULTS.equals(vaultDefaultSelection) )
               {
                  checked = "checked";
               }
 %>
               <!-- //XSSOK -->
               <td><input type="radio" name="vaultSelction" value="<%=PersonUtil.SEARCH_ALL_VAULTS%>" <%=checked%> />
                  <emxUtil:i18n localize="i18nId">emxFramework.Preferences.AllVaults</emxUtil:i18n>&nbsp;
               </td>
            </tr>
          </table>
        </td>
  <tr>
<% 
if ("true".equals(containedInFlag)) {
%>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
      </tr>
   <tr >
                <td width="150" class="label"><emxUtil:i18n localize="i18nId">emxFramework.Common.ContainedIn</emxUtil:i18n></td>
    <td  nowrap="nowrap" class="InputField" >
   <input type="text" name="txtContainedIn" size="20" readonly="readonly" value="<xss:encodeForHTMLAttribute><%=strContainedIn%></xss:encodeForHTMLAttribute>" />
   <input class="button" type="button" name="btnAffectedItem" size="200" value="..." alt=""  onClick="javascript:showAffectedItemSelector();"/>
   <input type="hidden" name="txtActualContainedIn" value="<xss:encodeForHTMLAttribute><%=strActualContainedIn%></xss:encodeForHTMLAttribute>"/>
   <input type="hidden" name="txtContainedInType" value="<xss:encodeForHTMLAttribute><%=strContainedInType%></xss:encodeForHTMLAttribute>"/>
   <input type="hidden" name="txtContainedInRev" value="<xss:encodeForHTMLAttribute><%=strContainedInRev%></xss:encodeForHTMLAttribute>"/>
               &nbsp;
            <a class="dialogClear" href="javascript:;" onclick="javascript:clearContainedIn()"><emxUtil:i18n localize="i18nId">emxFramework.Common.Clear</emxUtil:i18n></a>
&nbsp;<img src="images/iconActionHelp.gif" border="0" style="cursor: pointer" id="imgTag" ></img>
    
        </td>

      </tr>
   <tr>
<% 
    if(FrameworkUtil.isThisSuiteRegistered(context,session,"eServiceSuiteCommonComponents")) {
%>
    
                     <td width="150" class="label"><emxUtil:i18n localize="i18nId">emxFramework.Common.DiscussionKeywords</emxUtil:i18n></td>
                  <td  nowrap="nowrap" class="InputField">
                  <input type="text" name="txtDiscussionKeywords" size="20" value="*"/>
                 </td>
              </tr>
        </td>
         </tr>
  </table>
<%
    }
}
%>

<%
String containedInStr = "emxFramework.Common.ContainedIn"; 

InclusionList = "emxFramework.ContextSearch.ContainedIn.Types";
%>
<script language="javascript" type="text/javaScript">
var floatingDiv=null;
    function showAffectedItemSelector()
    {
  //This function is for popping Affected Item chooser
  //The value chosen by the type chooser is returned to the corresponding field.
      var sURL= "../common/emxSearch.jsp?formName=SearchForm&containedInFlag=false&defaultSearch=AEFContainedInSearch";
      sURL = sURL + "&frameName=Content&fieldNameActual=txtActualContainedIn";
      sURL = sURL + "&fieldNameDisplay=txtContainedIn&searchmode=chooser&suiteKey=Components&SelectType=multiselect&containedInFlag=false";
      //XSSOK
      sURL = sURL + "&InclusionList=<%=XSSUtil.encodeForURL(context, InclusionList)%>&SubmitURL=../common/emxObjectSelect.jsp&CancelButton=true&title=<%=containedInStr%>&containedInFieldType=txtContainedInType&containedInFieldRev=txtContainedInRev";

      showModalDialog(sURL,700,600);
    }
    
    
</script>

      <table border="0" cellpadding="5" cellspacing="2" width="100%">
        <tr>
          <td>&nbsp;</td>
        </tr>
      </table>
<% if(showAdvancedLink){ %>
      <table border="0" cellpadding="5" cellspacing="2" width="100%">
        <tr>
          <td width="150"><img src="../common/images/utilSearchPlus.gif" width="15" height="15" align="texttop" border="0" id="imgMore"/><a href="javascript:;" onclick="javascript:localCalendars = new Array;toggleMore();"><emxUtil:i18n localize="i18nId">emxFramework.Common.More</emxUtil:i18n></a></td>
          <td>&nbsp;</td>
        </tr>
      </table>
<% } 
    InclusionList = "emxComponents.ContextSearch.ContainedIn.Types";
%>

    <%

String urlParameter = emxGetParameter(request, "useTypeChooser");
String mxLink= emxGetParameter(request, "mxLink");
String table = "AEFGeneralSearchResults";
String program = "emxSearch:getContextSearchResults";
if("true".equals(mxLink)){
    table="AEFMxLinkSearchResults";
    program="emxSearch:getContextSearchResults,emxSearch:getLatestREVSearchResult";

}


%>
   <input type="hidden" name="table" value="<%=table%>"/> 

    <input type="hidden" name="Style" value="dialog"/>  
    <input type="hidden" name="program" value="<%=program%>"/>
    <input type="hidden" name="toolbar" value="AEFSearchResultToolbar"/>
    <!-- //XSSOK -->
    <input type="hidden" name="header" value="<%=headerText%>"/>
    <input type="hidden" name="TransactionType" value="update"/> 
   <%
   if("true".equals(mxLink)){
    %>
    <input type="hidden" name="programLabel" value="emxFramework.RevisionSpecificmxLinks,emxFramework.LatestRevisionmxLinks"/>


    <%
    }
    if ("true".equals(containedInFlag)){
    %>
    <input type="hidden" name="selection" value="multiple" />
    <%}
    else if ("false".equals(containedInFlag)){
    %>
        <input type="hidden" name="selection" value="single" />
    <%
        }
    %>
    <input type="hidden" name="QueryLimit" value=""/>
    <input type="hidden" name="pagination" value=""/>
    <input type="hidden" name="listMode" value="search"/>
    <input type="hidden" name="CancelButton" value="true"/>
    <input type="hidden" name="CancelLabel" value="emxFramework.GlobalSearch.Close"/>
    <input type="hidden" name="HelpMarker" value="emxhelpselectuserresults"/>



<%
    StringList slFieldNames = new StringList();
    slFieldNames.addElement("txtTypeDisplay");
    slFieldNames.addElement("txtTypeActual");
    slFieldNames.addElement("txtName");
    slFieldNames.addElement("txtRev");
    slFieldNames.addElement("vaultSelction");
    slFieldNames.addElement("txtContainedIn");
    slFieldNames.addElement("txtActualContainedIn");
    slFieldNames.addElement("table");
    slFieldNames.addElement("Style");
    slFieldNames.addElement("program");
    slFieldNames.addElement("toolbar");
    slFieldNames.addElement("header");
    slFieldNames.addElement("selection");
    slFieldNames.addElement("QueryLimit");
    slFieldNames.addElement("pagination");


    Enumeration eNumParameters = emxGetParameterNames(request);
    while( eNumParameters.hasMoreElements() ) {
        String strParamName = (String)eNumParameters.nextElement();
        String strParamValue = emxGetParameter(request, strParamName);

        if(!slFieldNames.contains(strParamName)){
%>
                <input type="hidden" name="<xss:encodeForHTMLAttribute><%=strParamName%></xss:encodeForHTMLAttribute>" value="<xss:encodeForHTMLAttribute><%=strParamValue%></xss:encodeForHTMLAttribute>" />
<%
        }
    }

    String CollectionName = emxGetParameter(request,"CollectionName");
if(CollectionName != null && !CollectionName.equals("")){
    session.putValue("CollectionName", CollectionName);
}

%>
<!-- the following div MUST come just before closing form tag -->
    <div id="divMore" style="display:none"></div>
    </form>
<%@include file = "emxNavigatorBottomErrorInclude.inc"%>

</body>
</html>
