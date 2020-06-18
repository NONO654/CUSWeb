<%-- emxIssueSearchDocumentsForm.jsp

   Copyright (c) 1999-2018 Dassault Systemes.
   All Rights Reserved.

   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<!-- Include directives -->
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "emxComponentsCommonInclude.inc"%>
<%@include file = "../emxTagLibInclude.inc"%>
 <%@include file = "../emxUICommonHeaderBeginInclude.inc"%>
<!-- Page directives -->
<%@page import = "java.util.List"%>
<%@page import = "matrix.db.BusinessType"%>
<%@page import = "matrix.db.FindLikeInfo"%>
<%@page import = "matrix.db.Policy"%>
<%@page import = "matrix.db.StateRequirementList"%>
<%@page import = "com.matrixone.apps.common.Search"%>
<%@page import = "com.matrixone.apps.common.Issue"%>
<%@page import = "com.matrixone.apps.common.Person"%>
<%@page import = "com.matrixone.apps.domain.util.PersonUtil"%>
<%@page import = "com.matrixone.apps.domain.util.FrameworkProperties"%>
<%@page import = "com.matrixone.apps.domain.DomainConstants"%>

<link rel="stylesheet" href="../common/styles/emxUIDefault.css" type="text/css"/>
<link rel="stylesheet" href="../common/styles/emxUIForm.css" type="text/css"/>
<link rel="stylesheet" href="../common/styles/emxUIList.css" type="text/css"/>

<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="javascript" src="../common/scripts/emxUIModal.js"></script>
<script language="javascript" src="../common/scripts/emxUISearch.js"></script>



<!-- Declarations -->
<%!
  private static final String DEFAULT_BUNDLE = "emxComponentsStringResource";
  private static final String STAR = "*";
%>

<%
try
  {
    String strLocale = context.getSession().getLanguage();
    i18nNow i18nNowInstance = new i18nNow();

    String strClear = i18nNowInstance.GetString(DEFAULT_BUNDLE,strLocale,"emxComponents.Button.Clear");
    String strLatestRevisionOnly = i18nNowInstance.GetString(DEFAULT_BUNDLE,strLocale,"emxComponents.Form.Radio.LatestRevisionOnly");
    String strAllStates = i18nNowInstance.GetString(DEFAULT_BUNDLE,strLocale,"emxComponents.Form.Radio.AllStates");
    String strAll = i18nNowInstance.GetString("emxFrameworkStringResource",strLocale,"emxFramework.Preferences.AllVaults");
    String strDefault = i18nNowInstance.GetString("emxFrameworkStringResource",strLocale,"emxFramework.Preferences.UserDefaultVault");
    String strSelected = i18nNowInstance.GetString("emxFrameworkStringResource",strLocale,"emxFramework.Preferences.SelectedVaults");
    String strLocal = i18nNowInstance.GetString("emxFrameworkStringResource",strLocale,"emxFramework.Preferences.LocalVaults");


    String strTypeToDisplay=null;
    String strDefaultPolicy=null;
    MapList policyList=null;
    StateRequirementList stateRequirementList;
    Policy policy;

    String strTypeDisplay = emxGetParameter(request, "TypeDisplayDocument");
    String strTypeActual = emxGetParameter(request, "TypeDocument");
    String strSelectedPolicy = emxGetParameter(request, "Policy");
    String strSuiteKey = emxGetParameter(request, Search.REQ_PARAM_SUITE_KEY);
    String strBaseType = PropertyUtil.getSchemaProperty(context, Issue.SYMBOLIC_type_DOCUMENTS);

    Person person = Person.getPerson(context, context.getUser());
    String strVaults = person.getCompany(context).getAllVaults(context);

 String vaultDefaultSelection = PersonUtil.getSearchDefaultSelection(context);
 String languageStr = request.getHeader("Accept-Language");
    
    //Modified for MCC X3 to accept include type to default in type chooser
    // "includeTypes" value shoud be a symbolic name of a tyoe
    String includeTypes  = emxGetParameter(request,"includeTypes");
    if(includeTypes != null && !"".equals(includeTypes))
    {
      strBaseType=PropertyUtil.getSchemaProperty(context,includeTypes);
    }

    // Suppose, a Type is selected, then, change the Policy dropdown for the given type only
    String strType = null;
    if ( strTypeDisplay!=null && !strTypeDisplay.equals("") )
      {
        strType = strTypeActual;
		//Begin of Add by RashmiL_Joshi, Infosys for bug 300712 Date: 4/6/2005
        strTypeToDisplay = i18nNow.getTypeI18NString(strType, strLocale);
		//End of Add for bug 300712
      }
    else
      {
        strType = strBaseType;
        strTypeToDisplay = i18nNow.getTypeI18NString(strType, strLocale);
      }

    policyList = mxType.getPolicies(context,strType,false);
    Map defaultMap = mxType.getDefaultPolicy(context, strType, false);


  String strProgram = emxGetParameter(request, "program");
  String strTable = emxGetParameter(request, "table");
  String strTopActionbar = emxGetParameter(request, "topActionbar");
  String strBottomActionbar = emxGetParameter(request, "bottomActionbar");
  String strHeader = emxGetParameter(request, "header");
  String strSelection = emxGetParameter(request, "selection");
  String strStyle = emxGetParameter(request, "Style");
  String strExport = emxGetParameter(request, "Export");
  String strCommandName = emxGetParameter(request, "CommandName");
  String strPrinterFriendly = emxGetParameter(request, "PrinterFriendly");
  String strCancelButton = emxGetParameter(request, "CancelButton");
  String strHelpMarker = emxGetParameter(request, "HelpMarker");
  String strSubmitURL = emxGetParameter(request, "SubmitURL");
  String strSearchMenu = emxGetParameter(request, Search.REQ_PARAM_MENU_NAME);
  String strSearchCommand = emxGetParameter(request, Search.REQ_PARAM_COMMAND);
  String strSearchMode = emxGetParameter(request, Search.REQ_PARAM_MODE);
  String strPRCParam1 = emxGetParameter(request, Search.REQ_PARAM_PRCPARAM1);
  String strDq = emxGetParameter(request, Search.REQ_PARAM_DEFAULT_QUERY);
  String strFrameName = emxGetParameter(request, Search.REQ_PARAM_FRAME_NAME);
  String strFormName = emxGetParameter(request, Search.REQ_PARAM_FORM_NAME);
  String strFieldNameActual = emxGetParameter(request, Search.REQ_PARAM_FIELD_NAME_ACTUAL);
  String strFieldNameDisplay = emxGetParameter(request, Search.REQ_PARAM_FIELD_NAME_DISPLAY);
  String strObjectId = emxGetParameter(request, Search.REQ_PARAM_OBJECT_ID);
  String strMidBusType = emxGetParameter(request, Search.REQ_PARAM_MID_BUS_TYPE);
  String strSrcDestRelName = emxGetParameter(request, Search.REQ_PARAM_SRC_DEST_REL_NAME);
  String strSrcMidRelName = emxGetParameter(request, Search.REQ_PARAM_SRC_MID_REL_NAME);
  String strMidDestRelName = emxGetParameter(request, Search.REQ_PARAM_MID_DEST_REL_NAME);
  String strIsTo = emxGetParameter(request, Search.REQ_PARAM_IS_TO);
  String strAddProgram = emxGetParameter(request, Search.REQ_PARAM_ADD_PROGRAM);
  String strAddFunction = emxGetParameter(request, Search.REQ_PARAM_ADD_FUNCTION);
  String strDoConnect = emxGetParameter(request, Search.REQ_PARAM_DO_CONNECT);
  String strDeleteJPO = emxGetParameter(request, Search.REQ_PARAM_DELETE_JPO);
  String strDeleteJPOMethod = emxGetParameter(request, Search.REQ_PARAM_DELETE_JPO_METHOD);
  //Begin of Add by RashmiL_Joshi, Infosys for bug 300133 Date: 3/25/2005  
  String strToolbar = emxGetParameter(request, "toolbar");
  //End of Add for bug 300133 Date: 3/25/2005
 %>
 
 <%@include file = "../emxUICommonHeaderEndInclude.inc"%>
 
  <form method="post" name="editDataForm">
    <input type="hidden" name="queryLimit" value=""/>
    <input type="hidden" name="pagination" value=""/>

  <% if ( strSuiteKey!=null && !strSuiteKey.equals("") ) { %>
    <input type="hidden" name="suiteKey" value="<xss:encodeForHTMLAttribute><%=strSuiteKey%></xss:encodeForHTMLAttribute>"/>
  <% } if ( strProgram!=null && !strProgram.equals("") ) { %>
    <input type="hidden" name="program" value="<xss:encodeForHTMLAttribute><%=strProgram%></xss:encodeForHTMLAttribute>"/>
  <% } if ( strTable!=null && !strTable.equals("") ) { %>
    <input type="hidden" name="table" value="<xss:encodeForHTMLAttribute><%=strTable%></xss:encodeForHTMLAttribute>"/>
  <% } if ( strTopActionbar!=null && !strTopActionbar.equals("") ) { %>
    <input type="hidden" name="topActionbar" value="<xss:encodeForHTMLAttribute><%=strTopActionbar%></xss:encodeForHTMLAttribute>"/>
  <% } if ( strBottomActionbar!=null && !strBottomActionbar.equals("") ) { %>
    <input type="hidden" name="bottomActionbar" value="<xss:encodeForHTMLAttribute><%=strBottomActionbar%></xss:encodeForHTMLAttribute>"/>
  <% } if ( strHeader!=null && !strHeader.equals("") ) { %>
    <input type="hidden" name="header" value="<xss:encodeForHTMLAttribute><%=strHeader%></xss:encodeForHTMLAttribute>"/>
  <% } if ( strSelection!=null && !strSelection.equals("") ) { %>
    <input type="hidden" name="selection" value="<xss:encodeForHTMLAttribute><%=strSelection%></xss:encodeForHTMLAttribute>"/>
  <% } if ( strStyle!=null && !strStyle.equals("") ) { %>
    <input type="hidden" name="Style" value="<xss:encodeForHTMLAttribute><%=strStyle%></xss:encodeForHTMLAttribute>"/>
  <% } if ( strExport!=null && !strExport.equals("") ) { %>
    <input type="hidden" name="Export" value="<xss:encodeForHTMLAttribute><%=strExport%></xss:encodeForHTMLAttribute>"/>
  <% } if ( strPrinterFriendly!=null && !strPrinterFriendly.equals("") ) { %>
    <input type="hidden" name="PrinterFriendly" value="<xss:encodeForHTMLAttribute><%=strPrinterFriendly%></xss:encodeForHTMLAttribute>"/>
  <% } if ( strCancelButton!=null && !strCancelButton.equals("") ) { %>
    <input type="hidden" name="CancelButton" value="<xss:encodeForHTMLAttribute><%=strCancelButton%></xss:encodeForHTMLAttribute>"/>
  <% } if ( strSubmitURL!=null && !strSubmitURL.equals("") ) { %>
    <input type="hidden" name="SubmitURL" value='<xss:encodeForHTMLAttribute><%=strSubmitURL%></xss:encodeForHTMLAttribute>'/>
  <% } if ( strSearchMenu!=null && !strSearchMenu.equals("") ) { %>
    <input type="hidden" name="searchmenu" value="<xss:encodeForHTMLAttribute><%=strSearchMenu%></xss:encodeForHTMLAttribute>"/>
  <% } if ( strSearchCommand!=null && !strSearchCommand.equals("") ) { %>
    <input type="hidden" name="searchcommand" value="<xss:encodeForHTMLAttribute><%=strSearchCommand%></xss:encodeForHTMLAttribute>"/>
  <% } if ( strSearchMode!=null && !strSearchMode.equals("") ) { %>
    <input type="hidden" name="searchmode" value="<xss:encodeForHTMLAttribute><%=strSearchMode%></xss:encodeForHTMLAttribute>"/>
  <% } if ( strCommandName!=null && !strCommandName.equals("") ) { %>
    <input type="hidden" name="CommandName" value="<xss:encodeForHTMLAttribute><%=strCommandName%></xss:encodeForHTMLAttribute>"/>
  <% } if ( strPRCParam1!=null && !strPRCParam1.equals("") ) { %>
    <input type="hidden" name="PRCParam1" value="<xss:encodeForHTMLAttribute><%=strPRCParam1%></xss:encodeForHTMLAttribute>"/>
  <% } if ( strDq!=null && !strDq.equals("") ) { %>
    <input type="hidden" name="dq" value="<xss:encodeForHTMLAttribute><%=strDq%></xss:encodeForHTMLAttribute>"/>
  <% } if ( strFrameName!=null && !strFrameName.equals("") ) { %>
    <input type="hidden" name="frameName" value="<xss:encodeForHTMLAttribute><%=strFrameName%></xss:encodeForHTMLAttribute>"/>
  <% } if ( strFormName!=null && !strFormName.equals("") ) { %>
    <input type="hidden" name="formName" value="<xss:encodeForHTMLAttribute><%=strFormName%></xss:encodeForHTMLAttribute>"/>
  <% } if ( strFieldNameActual!=null && !strFieldNameActual.equals("") ) { %>
    <input type="hidden" name="fieldNameActual" value="<xss:encodeForHTMLAttribute><%=strFieldNameActual%></xss:encodeForHTMLAttribute>"/>
  <% } if ( strFieldNameDisplay!=null && !strFieldNameDisplay.equals("") ) { %>
    <input type="hidden" name="fieldNameDisplay" value="<xss:encodeForHTMLAttribute><%=strFieldNameDisplay%></xss:encodeForHTMLAttribute>"/>
  <% } if ( strObjectId!=null && !strObjectId.equals("") ) { %>
    <input type="hidden" name="objectId" value='<xss:encodeForHTMLAttribute><%=strObjectId%></xss:encodeForHTMLAttribute>'/>
  <% } if ( strMidBusType!=null && !strMidBusType.equals("") ) { %>
    <input type="hidden" name="midBusType" value="<xss:encodeForHTMLAttribute><%=strMidBusType%></xss:encodeForHTMLAttribute>"/>
  <% } if ( strSrcDestRelName!=null && !strSrcDestRelName.equals("") ) { %>
    <input type="hidden" name="srcDestRelName" value="<xss:encodeForHTMLAttribute><%=strSrcDestRelName%></xss:encodeForHTMLAttribute>"/>
  <% } if ( strSrcMidRelName!=null && !strSrcMidRelName.equals("") ) { %>
    <input type="hidden" name="srcMidRelName" value="<xss:encodeForHTMLAttribute><%=strSrcMidRelName%></xss:encodeForHTMLAttribute>"/>
  <% } if ( strMidDestRelName!=null && !strMidDestRelName.equals("") ) { %>
    <input type="hidden" name="midDestRelName" value="<xss:encodeForHTMLAttribute><%=strMidDestRelName%></xss:encodeForHTMLAttribute>"/>
  <% } if ( strIsTo!=null && !strIsTo.equals("") ) { %>
    <input type="hidden" name="isTo" value="<xss:encodeForHTMLAttribute><%=strIsTo%></xss:encodeForHTMLAttribute>"/>
  <% } if ( strAddProgram!=null && !strAddProgram.equals("") ) { %>
    <input type="hidden" name="addProgram" value="<xss:encodeForHTMLAttribute><%=strAddProgram%></xss:encodeForHTMLAttribute>"/>
  <% } if ( strAddFunction!=null && !strAddFunction.equals("") ) { %>
    <input type="hidden" name="addFunction" value="<xss:encodeForHTMLAttribute><%=strAddFunction%></xss:encodeForHTMLAttribute>"/>
  <% } if ( strDoConnect!=null && !strDoConnect.equals("") ) { %>
    <input type="hidden" name="doConnect" value="<xss:encodeForHTMLAttribute><%=strDoConnect%></xss:encodeForHTMLAttribute>"/>
  <% } if ( strDeleteJPO!=null && !strDeleteJPO.equals("") ) { %>
    <input type="hidden" name="deleteJPO" value="<xss:encodeForHTMLAttribute><%=strDeleteJPO%></xss:encodeForHTMLAttribute>"/>
  <% } if ( strDeleteJPOMethod!=null && !strDeleteJPOMethod.equals("") ) { %>
    <input type="hidden" name="deleteJPOMethod" value="<xss:encodeForHTMLAttribute><%=strDeleteJPOMethod%></xss:encodeForHTMLAttribute>"/>
  <% } if ( strHelpMarker!=null && !strHelpMarker.equals("") ) { %>
    <input type="hidden" name="HelpMarker" value="<xss:encodeForHTMLAttribute><%=strHelpMarker%></xss:encodeForHTMLAttribute>"/>
  <% }

  //Modified for X3
  if ( includeTypes!=null && !includeTypes.equals("") ) { %>
    <input type="hidden" name="includeTypes" value="<xss:encodeForHTMLAttribute><%=includeTypes%></xss:encodeForHTMLAttribute>"/>
  <% }

  //Begin of Add by RashmiL_Joshi, Infosys for bug 300133 Date: 3/25/2005
  if ( strToolbar!=null && !strToolbar.equals("") ) { %>
    <input type="hidden" name="toolbar" value="<xss:encodeForHTMLAttribute><%=strToolbar%></xss:encodeForHTMLAttribute>"/>
  <% }
 //End of Add for bug 300133 Date: 3/25/2005
  %>

    <table border="0" width="99%" cellpadding="5" cellspacing="2">
   <tr>
     <td width="150" class="label">
     <emxUtil:i18n localize="i18nId">
     emxFramework.Basic.Type
     </emxUtil:i18n>
     </td>
     <td class="inputField" nowrap="nowrap" colspan="1">
     <input type="text" READONLY name="TypeDisplayDocument" value="<xss:encodeForHTMLAttribute><%=strTypeToDisplay%></xss:encodeForHTMLAttribute>" maxlength="" size="20" readonly="readonly" /><input type="hidden" name="TypeDocument"  value="<xss:encodeForHTMLAttribute><%=strType%></xss:encodeForHTMLAttribute>"/><input type="button" name="button1"  value="..." onclick="javascript:showTypeChooser();"/>
     </td>
   </tr>

   <tr>
     <td width="150" class="label">
     <emxUtil:i18n localize="i18nId">
     emxFramework.Basic.Name
     </emxUtil:i18n>
     </td>
     <td class="inputField" nowrap="nowrap" colspan="1">
     <input type="text" name="Name" maxlength="" size="20" value="<xss:encodeForHTMLAttribute><%=STAR%></xss:encodeForHTMLAttribute>"/>
     </td>
   </tr>

   <tr>
     <td width="150" class="label">
    <emxUtil:i18n localize="i18nId">
    emxFramework.Basic.Revision
    </emxUtil:i18n>
     </td>
     <td class="inputField" colspan="1">
    <table>
      <tr>
     <td>
       <input type="text" size="20" name="Revision" value="<xss:encodeForHTMLAttribute><%=STAR%></xss:encodeForHTMLAttribute>"/><input type="checkbox" name="latestOnly"/><%=strLatestRevisionOnly%>
     </td>
      </tr>
    </table>
     </td>
   </tr>

   <tr>
     <td width="150" class="label">
    <emxUtil:i18n localize="i18nId">
    emxFramework.Attribute.Title
    </emxUtil:i18n>
     </td>
     <td class="inputField" colspan="1">
    <input type="text" name="Title" maxlength="" size="20" value="<xss:encodeForHTMLAttribute><%=STAR%></xss:encodeForHTMLAttribute>"/>&nbsp;
     </td>
   </tr>

   <tr>
     <td width="150" class="label">
    <emxUtil:i18n localize="i18nId">
    emxFramework.Basic.Description
    </emxUtil:i18n>
     </td>
     <td class="inputField" colspan="1">
    <input type="text" name="Description" maxlength="" size="20" value="<xss:encodeForHTMLAttribute><%=STAR%></xss:encodeForHTMLAttribute>"/>&nbsp;
     </td>
   </tr>

<% if(!((policyList == null) || (policyList.isEmpty()) || (defaultMap == null)))
    {
  strDefaultPolicy = (String)defaultMap.get(DomainConstants.SELECT_NAME);

  // This is for the first call of the page.
  if ( strSelectedPolicy!=null && !strSelectedPolicy.equals("") )
  {
    strDefaultPolicy = strSelectedPolicy;
  }

  policy = new Policy(strDefaultPolicy);
  policy.open(context);
  stateRequirementList= policy.getStateRequirements(context);
  policy.close(context);
%>
   <tr>
     <td width="150" class="label">
    <emxUtil:i18n localize="i18nId">
    emxFramework.Basic.State
    </emxUtil:i18n>
     </td>
     <td class="inputField" colspan="1">
    <table>
      <tr>
     <td>
       <select name="State">
       <!-- //XSSOK -->
      <option value="<%=STAR%>">
       <%=strAllStates%>
      </option>
      <%
        int iLen = stateRequirementList.size();
        if (iLen == 1) {
      %><!-- //XSSOK -->
        <option value="<%=STAR%>"><%=XSSUtil.encodeForHTML(context,(String)((StateRequirement)stateRequirementList.get(0)).getName())%></option>
      <%
        }
        else {

        for (int i=0; i<stateRequirementList.size(); i++) {
        String strState = (String)((StateRequirement)stateRequirementList.get(i)).getName();
      %>
      <option value="<%=strState%>"><%=strState%></option>
      <%
       }
        }
      %>
       </select>
     </td>
      </tr>
    </table>
     </td>
   </tr>
 <%
 }
 %>

   <tr>
     <td width="150" class="label">
    <emxUtil:i18n localize="i18nId">
    emxFramework.Basic.Owner
    </emxUtil:i18n>
     </td>
     <td class="inputField" colspan="1">
     <!-- //XSSOK -->
    <input type="text" READONLY name="OwnerDisplay" value="<%=STAR%>" maxlength="" size="20" readonly="readonly"/><input type="hidden" name="Owner"  value="<%=STAR%>"/><input type="button" name="button2" value="..." onclick="javascript:showOwnerChooser();"/>&nbsp;<a class="dialogClear" href="#" onclick="document.editDataForm.OwnerDisplay.value='<%=STAR%>'"><%=XSSUtil.encodeForHTML(context, strClear)%></a>
     </td>
   </tr>

<% if(!((policyList == null) || (policyList.isEmpty()) || (defaultMap == null)))
    {
%>
   <tr>
     <td width="150" class="label">
    <emxUtil:i18n localize="i18nId">
    emxFramework.Basic.Policy
    </emxUtil:i18n>
     </td>
     <td class="inputField" colspan="1">
    <table>
      <tr>
     <td>
       <select name="Policy" onChange="javaScript:updateStates();">
        <% for (int i=0; i<policyList.size(); i++) {
       String strPolicy = (String)((Map)policyList.get(i)).get("name");
       if ( strPolicy.equals(strDefaultPolicy) )
         {
      %>
      <option value="<xss:encodeForHTMLAttribute><%=strPolicy%></xss:encodeForHTMLAttribute>" selected> <%=XSSUtil.encodeForHTML(context, strPolicy)%></option>
      <%
         }
       else
         {
      %>
      <option value="<xss:encodeForHTMLAttribute><%=strPolicy%></xss:encodeForHTMLAttribute>"> <%=XSSUtil.encodeForHTML(context, strPolicy)%> </option>

      <%    }
       }
      %>
       </select >
     </td>
      </tr>
    </table>
     </td>
    </tr>
<%
 }
%>
    <tr>
      <td width="150" class="label">
     <emxUtil:i18n localize="i18nId">
     emxFramework.Basic.Vault
     </emxUtil:i18n>
      </td>
<%   String checked = "";
   if (  PersonUtil.SEARCH_DEFAULT_VAULT.equals(vaultDefaultSelection) )
             {
                  checked = "checked";          
             }
%>
      <td class="inputField" colspan="1">
      <table>
    <tr>
     <td><!-- //XSSOK -->
    <input type="radio" value="<%=PersonUtil.SEARCH_DEFAULT_VAULT%>" name="vaultOption" <%=checked%> /><%=XSSUtil.encodeForHTML(context, strDefault)%><br>
<%
               checked = "";
               if (  PersonUtil.SEARCH_LOCAL_VAULTS.equals(vaultDefaultSelection) )
               {
                  checked = "checked";
               }
%><!-- //XSSOK -->
    <input type="radio" value="<%=PersonUtil.SEARCH_LOCAL_VAULTS%>" name="vaultOption"<%=checked%>/><%=XSSUtil.encodeForHTML(context, strLocal)%><br>
<%
               checked = "";
               String vaults = "";
               String selVault = "";
               String selDisplayVault = "";      
               if (!PersonUtil.SEARCH_DEFAULT_VAULT.equals(vaultDefaultSelection) &&
                   !PersonUtil.SEARCH_LOCAL_VAULTS.equals(vaultDefaultSelection) &&
                   !PersonUtil.SEARCH_ALL_VAULTS.equals(vaultDefaultSelection) )
               {
                  checked = "checked";
      selVault = vaultDefaultSelection;
                  selDisplayVault = i18nNow.getI18NVaultNames(context, vaultDefaultSelection, languageStr);          
               }            
 %><!-- //XSSOK -->
    <input type="radio" name="vaultOption" value="<%=XSSUtil.encodeForHTMLAttribute(context,selVault)%>" <%=checked%>/><%=XSSUtil.encodeForHTML(context, strSelected)%>&nbsp;
                <input type="text" name="vaultsDisplay" size="15" readonly="readonly" value="<xss:encodeForHTMLAttribute><%=selDisplayVault%></xss:encodeForHTMLAttribute>"/>
                
    <input type="button" name="button3" value="..." onclick="javascript:setSelectedVaultOption()"/>
                    
    <input type="hidden" name="vaults" size="15" value="<xss:encodeForHTMLAttribute><%=selVault%></xss:encodeForHTMLAttribute>"/><br>
 <%
               checked = "";
               if (  PersonUtil.SEARCH_ALL_VAULTS.equals(vaultDefaultSelection) )
               {
                  checked = "checked";
               }
 %>
    <!-- //XSSOK -->
    <input type="radio" name="vaultOption" value="<%=PersonUtil.SEARCH_ALL_VAULTS%>" <%=checked%> /><%=XSSUtil.encodeForHTML(context, strAll)%>
    <br/>
     </td>
    </tr>
      </table>
     </td>
    </tr>
   </table>
     </form>

 <script language="javascript">
 turnOffProgress();
 function showTypeChooser()
   {

   showChooser('../common/emxTypeChooser.jsp?frameName=searchPane&formName=editDataForm&SelectType=single&SelectAbstractTypes=true&InclusionList=<%=strBaseType%>&ObserveHidden=true&ShowIcons=true&fieldNameActual=TypeDocument&fieldNameDisplay=TypeDisplayDocument&ReloadOpener=true',500,400);//XSSOK
   }

  function showOwnerChooser()
    {
   showChooser('../components/emxCommonSearch.jsp?formName=editDataForm&frameName=searchPane&searchmode=chooser&suiteKey=Components&searchmenu=SearchIssueAddExistingChooser&searchcommand=SearchAssigneeIssueLink&fieldNameActual=Owner&fieldNameDisplay=OwnerDisplay',700,500);
    }


 function reload()
    {
    document.editDataForm.method= "post";
    document.editDataForm.action="../components/emxIssueSearchDocumentsForm.jsp?suiteKey=Components&Policy=";
    document.editDataForm.submit();
  }

   function updateStates()
  {
    document.editDataForm.method= "post";
    document.editDataForm.action="../components/emxIssueSearchDocumentsForm.jsp?suiteKey=Components";
    document.editDataForm.submit();
  }

   function setSelectedVaultOption()
  {
   document.forms[0].vaultOption[2].checked=true;      
      showChooser('../common/emxVaultChooser.jsp?fieldNameActual=vaults&fieldNameDisplay=vaultsDisplay&incCollPartners=false&isFromSearchForm=true&multiSelect=true');
  }
 </script>
 <%
 //}
}
 catch (Exception exp)  {
     exp.printStackTrace(System.out);
     throw exp;
  }
%>


