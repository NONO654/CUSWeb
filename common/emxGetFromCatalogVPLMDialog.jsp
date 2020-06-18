<%--  emxLibraryCentralObjectFindDialog.jsp  -   Brief Description
   Copyright (c) 1992-2007 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of
   MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any
   actual or intended publication of such program

   Description: Gather search criteria to search for business objects
   Parameters : baseType (Library/Bookshelf/Book/GenericDocument/All)
                                searchDirection (Up, Down, None)
                                search direction for expand construction
                                dialogAction (SearchResults, AddChildren, SearchIn, Chooser)

   static const char RCSID[] = "$Id: emxLibraryCentralObjectFindDialog.jsp.rca 1.19.1.1.1.5 Fri Dec 14 13:50:07 2007 c-GShilpi Experimental $"
--%>
<%@ page import = "matrix.db.*,
                   matrix.util.* ,
                   com.matrixone.servlet.*,
                   java.util.*,
                   java.io.*,
                   java.net.URLEncoder,
                   java.util.*,
                   java.util.Vector,
                   java.text.*" errorPage="../common/emxNavigatorErrorPage.jsp"%>

<%@ page import =  "com.matrixone.apps.common.BuyerDesk,
                    com.matrixone.apps.common.BusinessUnit,
                    com.matrixone.apps.common.Company,
                    com.matrixone.apps.common.Document,
                    com.matrixone.apps.common.DocumentHolder,
                    com.matrixone.apps.common.Location,
                    com.matrixone.apps.common.Message,
                    com.matrixone.apps.common.Meeting,
                    com.matrixone.apps.common.MessageHolder,
                    com.matrixone.apps.common.Organization,
                    com.matrixone.apps.common.Person,
                    com.matrixone.apps.common.Part,
                    com.matrixone.apps.common.Subscribable,
                    com.matrixone.apps.common.SubscriptionManager,
                    com.matrixone.apps.common.Workspace,
                    com.matrixone.apps.common.WorkspaceVault"%>

<%@ page import = "com.matrixone.apps.domain.*,
                   com.matrixone.apps.domain.util.*,
                   com.matrixone.apps.common.util.*,
                   com.matrixone.apps.framework.ui.*,
                   com.matrixone.apps.framework.taglib.*" %>

<%@ include file = "../emxTagLibInclude.inc"%>
<%@ include file = "../emxI18NMethods.inc"%>

<%@include file = "../emxUICommonAppInclude.inc"%>

<%@include file = "../emxJSValidation.inc" %>
<%@include file = "../common/emxUIConstantsInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%@include file = "../emxUICommonHeaderEndInclude.inc"%>

<emxUtil:localize id="i18nId" bundle="emxDocumentCentralStringResource" locale='<%= request.getHeader("Accept-Language") %>' />
<emxUtil:localize id="i18nId" bundle="emxLibraryCentralStringResource" locale='<%= request.getHeader("Accept-Language") %>' />

<script language="javascript" type="text/javascript" src="../common/scripts/emxUICalendar.js"></script>

<%!
    String makeNonNull(String strParam ,String strDefault){
        if(strParam == null){
            return strDefault;
        }
        return strParam;
    
    }
%>
<%
    //--Getting The Request Parameters
    String dialogAction     = emxGetParameter(request, "DialogAction");
    String strUseMode     = emxGetParameter(request, "useMode");
    String searchName          = emxGetParameter(request, "searchName");
    String searchVault          = emxGetParameter(request, "searchVault");
    String baseType         = emxGetParameter(request, "baseType");
    String searchType         = emxGetParameter(request, "searchType");
    String searchDirection  = emxGetParameter(request, "searchDirection");
    String parentOId        = emxGetParameter(request, "objectId");
    String selectOption     = emxGetParameter(request, "selectOption");
    String refineSearch     = emxGetParameter(request, "refineSearch");
    String languageStr      = request.getHeader("Accept-Language");
    String suiteKey         = emxGetParameter(request,"suiteKey");
    String SelectType       = emxGetParameter(request,"SelectType");
    String timeZoneString   = (String)session.getValue("timeZone");
    double clientTZOffset   = (new Double(timeZoneString)).doubleValue();
    Locale locale = request.getLocale();
   //Prepares Person chooser URL for Owner
   String vaultDefaultSelection =  PersonUtil.getSearchDefaultSelection(context);
    

    if(vaultDefaultSelection == null || "".equals(vaultDefaultSelection)) {
       vaultDefaultSelection = FrameworkProperties.getProperty("emxFramework.DefaultSearchVaults");
    }
    
    String STR_SEARCH_SELECT_VAULT      = UINavigatorUtil.getI18nString("emxFramework.Common.ErrorMsg.SelectVault",  "emxFrameworkStringResource", request.getHeader("Accept-Language"));

  	if(refineSearch == null)
    {
        refineSearch = "false";
    }

    if(dialogAction == null || "".equals(dialogAction) || "null".equals(dialogAction))
    {
      dialogAction="searchResults";
    }
    if(searchName == null ){
        searchName = "*";
    }
    if(searchVault == null ){
        searchVault = "*";
    }
  
    if(searchType == null ){
        searchType = "";
    }
    if(SelectType == null || "".equals(SelectType) || "null".equals(SelectType))
    {
      SelectType="singleselect";
    }
    
    //Setting default values to Search Fields

 	String sName                = "*";
    String sOwner               = "*";
    String sApprover            = "*";
    String sDisplayOwner        = "*";
    String sDisplayApprover     = "*";
    String sOriginator          = "*";
    String sVault               = "*";
    String sRevision            = "*";
    String sDisplaySearchWithin = "*";
    String sSearchWithin        = "";
    String sDescription         = "*";
    String sState               = "*";
    String sType                = "";
    
    if(searchType.equals("null") || searchType.trim().equals(""))
    {
        sType                = baseType;
    }else{
        sType = PropertyUtil.getSchemaProperty(context,searchType); 
    }   
    
    sName  = searchName;
    sVault = searchVault;
    String sAuto                ="false";

    String sTitle               ="*";
    String sKeyword             ="";

     String refreshMode ="";
    if ( refineSearch.equalsIgnoreCase ( "true" ) )
    {

        //In case of Refine search<refresh of Page the the Param is
        // set to true so that DR JSps also can prepopulate the
        // Data

        refreshMode     ="true";

        sName           = makeNonNull (emxGetParameter(request, "attribute_Name"),"*");
        sRevision       = makeNonNull (emxGetParameter(request, "attribute_Revision"),"*");
        sOwner          = makeNonNull (emxGetParameter(request, "attribute_Owner"),"*");
        sDisplayOwner   = makeNonNull (emxGetParameter(request, "DisplayOwner"),"*");
        sType           = emxGetParameter(request, "attribute_Type");
        searchType         = emxGetParameter(request, "searchType");    
        if(searchType != null && !searchType.trim().equals(""))
        {
            if(dialogAction != null && !dialogAction.equalsIgnoreCase("AddChildren"))
            {
                sType = searchType;
            }

        }else{
            sType = baseType;
        }
        sVault          = makeNonNull (emxGetParameter(request, "attribute_Vault"),"*");

        if(sType == null || "null".equals(sType) || "".equals(sType))
        {
            if(searchType != null)
                sType = searchType;
            else
                sType = baseType;
        }
    }

   //Variable to find out which options shouls be selected

    String sSelected = "";
    String resultPageHeader=(String)getI18NString("emxLibraryCentralStringResource","emxDocumentCentral.Button.SearchResults",languageStr);
%>

<body onload="turnOffProgress(),top.loadSearchFormFields()">
<form name="ContentSearchDocument" action="emxCatalogObjectFindSummaryFS.jsp" target="_parent" onSubmit="doSubmit();return false">
<input type="hidden" name="objectId" id="objectId" value="<%=parentOId%>"/>

  <input type="hidden" name="objectId" id="objectId" value="<%=parentOId%>"/>

  
  <input type="hidden" name="baseType" id="baseType" value="<%=baseType%>"/>
  <input type="hidden" name="searchType" id="searchType" value="<%=searchType%>"/>
  <input type="hidden" name="searchVault" id="searchType" value="<%=sVault%>"/>
  <input type="hidden" name="searchDirection" id="searchDirection" value="<%=searchDirection%>"/>
  <input type="hidden" name="DialogAction" id="DialogAction" value="<%=dialogAction%>"/>
  <input type="hidden" name="QueryLimit" id="QueryLimit"value=""/>
  <input type="hidden" name="selectOption" id="selectOption" value="<%=selectOption%>"/>
  <input type="hidden" name="attribute_Type" id="attribute_Type" value="<%=sType%>"/>
  <input type="hidden" name="attribute_Owner" id="attribute_Owner" value="<%=sOwner%>"/>
  <input type="hidden" name="attribute_SearchWithin" id="attribute_SearchWithin" value="<%=sSearchWithin%>"/>
  <input type=hidden name="timeZone" value="<%=timeZoneString%>">
  <input type=hidden name="useMode" value="<%=strUseMode%>">
  <table border="0" cellpadding="5" cellspacing="2" width="100%">
  
    <tr>
      <td width="150" class="label"><emxUtil:i18n localize="i18nId">emxDocumentCentral.Common.Name</emxUtil:i18n></td>
      <td class="inputField">
        <input type="text" size="20" name="attribute_Name" id="name" value="<%=sName%>"/>
      </td>
    </tr>

<%
        // The lastest reviosn checkbox is unchecked by default but in case of refine search
        // its checked /unchked depending upon previous search Criteria
        String sChecked="";
        if ( sAuto != null && sAuto.equals ( "true" ) )
        {
             sChecked="checked";
        }

%>
    <tr>
          <td width="150" class="label"><emxUtil:i18n localize="i18nId">emxDocumentCentral.Common.Vault</emxUtil:i18n>&nbsp;</td>
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
               <td><input name="vaultSelction" type="radio" value="<%=PersonUtil.SEARCH_DEFAULT_VAULT%>" <%=checked%>>
                  <emxUtil:i18n localize="i18nId">emxLibraryCentral.Preferences.UserDefaultVault</emxUtil:i18n>&nbsp;
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
               <td><input name="vaultSelction" type="radio" value="<%=PersonUtil.SEARCH_LOCAL_VAULTS%>" <%=checked%>>
                    <emxUtil:i18n localize="i18nId">emxLibraryCentral.Preferences.LocalVaults</emxUtil:i18n>&nbsp;
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
               <td><input type="radio" name="vaultSelction" value="SELECTED_VAULT" <%=checked%>>
                  <emxUtil:i18n localize="i18nId">emxLibraryCentral.Preferences.SelectedVaults</emxUtil:i18n>&nbsp;
                  <input type="text" name="vaultsDisplay" value="<%=sVault%>" size=15 readonly="readonly" onfocus="this.title=this.value;" onmouseover="this.title=this.value;" title="<%=sVault%>">
                  <input name="btnType" type="button" value="..." onclick="javascript:setSelectedVaultOption()">
                  <input type="hidden" name="attribute_Vault" value="<%=vaultDefaultSelection%>" size=15>
                  &nbsp;
                  <a class="dialogClear" href="#" onclick="javascript:clearVault()">Clear</a>
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
               <td><input type="radio" name="vaultSelction" value="<%=PersonUtil.SEARCH_ALL_VAULTS%>" <%=checked%>>
                   <emxUtil:i18n localize="i18nId">emxDocumentCentral.Search.VaultsAll</emxUtil:i18n>&nbsp;
               </td>
            </tr>
          </table>
        </td>
      </tr>

      </table>
      <table border="0" cellpadding="5" cellspacing="2" width="100%">
        <tr>
          <td>&nbsp;</td>
        </tr>
      </table>
      
      <table border="0" cellpadding="5" cellspacing="2" width="100%">

  </table>
  <input type="image" name="inputImage" height="1" width="1" src="../common/images/utilSpacer.gif" hidefocus="hidefocus" style="-moz-user-focus: none" />
</form>

<script language="javascript" src = "emxDocumentUtilities.js"></script>

<script language="javascript"  type="text/javaScript">//<![CDATA[

    <!-- hide JavaScript from non-JavaScript browsers


   
 
    function clearVault(){
        document.ContentSearchDocument.vaultsDisplay.value='';
        document.ContentSearchDocument.attribute_Vault.value='';
    }

    //Function to submit itself after choosing type(Reload the Page)

    function reload()
    {
      submitToItself();
    }

 
    // This fucntion handles the disabling of Revison field
    // depending upon the checkBox(lastest revion Check Value
    function handleFocus()
    {
    }
    //clear to date field
    function clearThisField( fieldValue, attrName )
    {
    }

     function searchResults()
     { 
        document.ContentSearchDocument.action = "emxCatalogObjectFindSummaryFS.jsp";
          if(jsDblClick())
        {
          document.ContentSearchDocument.submit();
        }
     }

    function doSubmit() {
  
        //find footer
        var footer = findFrame(top,"searchFoot");

        //call doFind Method
        footer.doFind();
    }

   function setSelectedVaultOption(){
            document.ContentSearchDocument.vaultSelction[2].checked=true;
            showChooser('../common/emxVaultChooser.jsp?fieldNameActual=attribute_Vault&fieldNameDisplay=vaultsDisplay&incCollPartners=true');
    }
    //Stop hiding here -->//]]>
</script>

</body>
<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
