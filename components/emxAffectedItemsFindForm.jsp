
<%--  emxAffectedItemsFindForm.jsp  -
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = "$Id: emxAffectedItemsFindForm.jsp.rca 1.3.3.2 Wed Oct 22 16:18:36 2008 przemek Experimental przemek $";
--%>

<!-- Include directives -->
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../components/emxSearchInclude.inc"%>
<%@include file = "../emxTagLibInclude.inc"%>


<!-- Page directives -->
<%@page import="com.matrixone.apps.common.Person"%>
<%@page import = "com.matrixone.apps.domain.util.PersonUtil"%>
<%@page import="com.matrixone.apps.common.Search"%>


<emxUtil:localize id="i18nId" bundle="<%=FRAMEWORK_BUNDLE%>"
         locale='<%=request.getHeader("Accept-Language")%>'/>


<!-- Declarations -->
<%!

  private static final String LABEL_CLEAR_LINK = "emxComponents.Search.FindLike.ActionLink.Clear";
%>



<!-- Processing -->
<%

  String strFindResultTable = emxGetParameter(request, "table");
  String strFindJPO = emxGetParameter(request, "program");

  String strSuiteKey        = emxGetParameter(request, Search.REQ_PARAM_SUITE_KEY);
  String strInclusionList   =  emxGetParameter(request, "InclusionList");
  String srcDestRelName     = emxGetParameter(request, "srcDestRelName");
  String satisfiedItems     = emxGetParameter(request, "satisfiedItems");
  String strActualRelName   = PropertyUtil.getSchemaProperty(context, srcDestRelName);

  final String DEFAULT_TYPE_KEY          = getProperty(context,SUITE_PREFIX + strSuiteKey + "." + srcDestRelName + ".DefaultType");

  // Use the list returned from mql to populate
  // the type chooser


  try {
    if(strInclusionList != null && !"".equals(strInclusionList.trim()) && !"null".equals(strInclusionList.trim()))
    {
      //strInclusionList should contain the comma separater Symbolicnames of types, which will listed in Type chooser as a tree.
      StringList slTypes = FrameworkUtil.split(strInclusionList.trim(), ",");
      StringBuffer sbTypeNames = new StringBuffer();
      //get the Actual names from Symbolic names
      for(int i=0; i<slTypes.size(); i++)
      {
        String strTypeSymbolicName = ((String)slTypes.get(i)).trim();
        if(!"".equals(strTypeSymbolicName))
        {
          sbTypeNames.append(PropertyUtil.getSchemaProperty(context,strTypeSymbolicName)+",");
        }
      }
      if(sbTypeNames.length() > 0)
      {
        sbTypeNames.setLength(sbTypeNames.length()-1);
      }
      strInclusionList =  sbTypeNames.toString();
    }else
    {
      // the flag indicates if this search is for adding 'Satisfied Items' to an EC
      if(satisfiedItems != null && satisfiedItems.equalsIgnoreCase("true")){

            // Setup mql command string.  Selecting the fromtype on the relationship
            // name, gives only the types at the end of the rel (no expansion)
            strInclusionList = MqlUtil.mqlCommand(context, "print relationship $1 select $2 dump ",strActualRelName,"fromtype");
      } else {

            // Setup mql command string.  Selecting the totype on the relationship
            // name, gives only the types at the end of the rel (no expansion)
            strInclusionList = MqlUtil.mqlCommand(context, "print relationship $1 select $2 dump ",strActualRelName,"totype");
      }
    }

  }
  // End of Modify by Infosys for bug no. 304793, dated 05/19/2005
  catch (FrameworkException fe) {
    // in case invalid relationship name is expanded, make Inclusion List empty
    strInclusionList = " ";
  }

  String strSuiteKeyAlias = SUITE_PREFIX + strSuiteKey;
  String strAcceptLanguage = request.getHeader("Accept-Language");
  String strTypeDisplay = emxGetParameter(request, "txtTypeDisplay");
  String strType = emxGetParameter(request, "hdnType");
  String strLocale = context.getSession().getLanguage();
  i18nNow i18nNowInstance = new i18nNow();
  Person person = Person.getPerson(context, context.getUser());
  String strVaults = person.getCompany(context).getAllVaults(context);
  String strAll = i18nNowInstance.GetString("emxFrameworkStringResource",strLocale,"emxFramework.Preferences.AllVaults");
  String strDefault = i18nNowInstance.GetString("emxFrameworkStringResource",strLocale,"emxFramework.Preferences.UserDefaultVault");
  String strSelected = i18nNowInstance.GetString("emxFrameworkStringResource",strLocale,"emxFramework.Preferences.SelectedVaults");
  String strLocal = i18nNowInstance.GetString("emxFrameworkStringResource",strLocale,"emxFramework.Preferences.LocalVaults");

   String vaultDefaultSelection = PersonUtil.getSearchDefaultSelection(context);
   String languageStr = request.getHeader("Accept-Language");
  if (strType == null)
  {
    String strTypeSymb = DEFAULT_TYPE_KEY;
    strType = PropertyUtil.getSchemaProperty(context,strTypeSymb);
    strTypeDisplay = i18nNow.getTypeI18NString(strType, strAcceptLanguage);

    if(strType == null || strType.equals("null")) {
      strType = "";
    }
    if(strTypeDisplay == null || strTypeDisplay.equals("null")) {
      strTypeDisplay = "";
    }
  }else if(!"".equals(strType) && !"null".equals(strType))
  {
        //  added below line for bug 328071
        String strTypeActual=strType;

        strType = PropertyUtil.getSchemaProperty(context,strType);
        // Start of code added for bug 328071
         if( "".equals(strType) || strType == null) {
           strType = strTypeActual;
         }
        // End of code added for bug 328071
      strTypeDisplay = i18nNow.getTypeI18NString(strType, strAcceptLanguage);
  }
%>


<link rel="stylesheet" href="../common/styles/emxUIDefault.css" type="text/css" />
<link rel="stylesheet" href="../common/styles/emxUIForm.css" type="text/css" />
<link rel="stylesheet" href="../common/styles/emxUIList.css" type="text/css" />

<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="javascript" src="../common/scripts/emxUIModal.js"></script>

<script language="javascript">

  function doLoad() {
    if (document.forms[0].elements.length > 0) {
      var objElement = document.forms[0].txtTypeDisplay;
      if (objElement.focus) {
        objElement.focus();
      }
      if (objElement.select) {
        objElement.select();
      }
    }
  }


  function getTypeChooser() {
    //alert("1");
    var strURL="../common/emxTypeChooser.jsp?fieldNameDisplay=txtTypeDisplay&fieldNameActual=hdnType&formName=editDataForm&SelectType=multiselect&SelectAbstractTypes=true&InclusionList=<%=XSSUtil.encodeForURL(context, strInclusionList)%>&ObserveHidden=true&ShowIcons=true&SuiteKey=<%=XSSUtil.encodeForURL(context, strSuiteKeyAlias)%>";
    //alert("2");
    showChooser(strURL, 500, 400);
  }

  function getPersonChooser()
{
  //This function is for popping the person chooser.
  showChooser('../components/emxCommonSearch.jsp?formName=editDataForm&frameName=pageContent&fieldNameActual=hdnOwner&fieldNameDisplay=txtOwner&searchmode=PersonChooser&suiteKey=Components&searchmenu=SearchIssueAddExistingChooser&searchcommand=SearchOwnerIssueLink', 700, 500)
}

  function setSelectedVaultOption()
  {
   document.forms[0].vaultOption[2].checked=true;
      showChooser('../common/emxVaultChooser.jsp?fieldNameActual=vaults&fieldNameDisplay=vaultsDisplay&incCollPartners=false&isFromSearchForm=true&multiSelect=true');
  }
</script>




<html>
  <body onload="doLoad()">
    <form method="post" name="editDataForm">
      <input type="hidden" name="toolbar" value="APPGlobalAddExistingToolBar" />
      <input type="hidden" name="program" value='<%=emxGetParameter(request, "program")%>' />
      <input type="hidden" name="table" value='<%=emxGetParameter(request, "table")%>' />
      <input type="hidden" name="topActionbar" value='<%=emxGetParameter(request, "topActionbar")%>' />
      <input type="hidden" name="bottomActionbar" value='<%=emxGetParameter(request, "bottomActionbar")%>' />
      <input type="hidden" name="header" value='<%=emxGetParameter(request, "header")%>' />
      <input type="hidden" name="selection" value='<%=emxGetParameter(request, "selection")%>' />
      <input type="hidden" name="queryLimit" value="" />
      <input type="hidden" name="pagination" value="" />
      <input type="hidden" name="Style" value='<%=emxGetParameter(request, "Style")%>' />
      <input type="hidden" name="Export" value='<%=emxGetParameter(request, "Export")%>' />
      <input type="hidden" name="PrinterFriendly" value='<%=emxGetParameter(request, "PrinterFriendly")%>' />
      <input type="hidden" name="suiteKey" value="<%=strSuiteKey%>" />
      <input type="hidden" name="CancelButton" value='<%=emxGetParameter(request, "CancelButton")%>' />
      <input type="hidden" name="searchmenu" value='<%=emxGetParameter(request, "searchmenu")%>' />
      <input type="hidden" name="searchcommand" value='<%=emxGetParameter(request, "searchcommand")%>' />
      <input type="hidden" name="searchmode" value='<%=emxGetParameter(request, "searchmode")%>' />
      <input type="hidden" name="CommandName" value='<%=emxGetParameter(request, "CommandName")%>' />
      <input type="hidden" name="HelpMarker" value='<%=emxGetParameter(request, "HelpMarker")%>' />
      <input type="hidden" name="SubmitURL" value='<%=emxGetParameter(request, "SubmitURL")%>' />
      <input type="hidden" name="srcDestRelName" value='<%=emxGetParameter(request, "srcDestRelName")%>' />
      <input type="hidden" name="satisfiedItems" value='<%=emxGetParameter(request, "satisfiedItems")%>' />
      <input type="hidden" name="isTo" value='<%=emxGetParameter(request, "isTo")%>' />
       <input type="hidden" name="objectId" value='<%=emxGetParameter(request, "objectId")%>' />
       <!--Added for Bug#304580 by Infosys on 18-May-2005-->
       <input type="hidden" name="sortColumnName" value='<%=emxGetParameter(request, "sortColumnName")%>' />

      <input type="hidden" name="frameName" value='<%=emxGetParameter(request, Search.REQ_PARAM_FRAME_NAME)%>' />
      <input type="hidden" name="formName" value='<%=emxGetParameter(request, Search.REQ_PARAM_FORM_NAME)%>' />
      <input type="hidden" name="fieldNameActual" value='<%=emxGetParameter(request, Search.REQ_PARAM_FIELD_NAME_ACTUAL)%>' />
      <input type="hidden" name="fieldNameDisplay" value='<%=emxGetParameter(request, Search.REQ_PARAM_FIELD_NAME_DISPLAY)%>' />

      <input type="hidden" name="doConnect" value='<%=emxGetParameter(request, "doConnect")%>' />
      <input type="hidden" name="addProgram" value='<%=emxGetParameter(request, "addProgram")%>' />
      <input type="hidden" name="addFunction" value='<%=emxGetParameter(request, "addFunction")%>' />

      <table border="0" cellpadding="5" cellspacing="2" width="100%">
        <tr>
          <td width="150" class="label"><emxUtil:i18nScript localize="i18nId">emxComponents.Basic.Type</emxUtil:i18nScript></td>
          <td class="inputField">
            <input  READONLY type="text" name="txtTypeDisplay" value="<%=strTypeDisplay%>" size="20" />
            <input type="hidden" name="hdnType" value="<%=strType%>" size="20" />
            <input type="button" value="..." onclick="getTypeChooser()" />
          </td>
        </tr>
        <tr>
          <td width="150" class="label"><emxUtil:i18nScript localize="i18nId">emxComponents.Basic.Name</emxUtil:i18nScript></td>
          <td class="inputField"><input type="text" name="txtName" value="*" /></td>
        </tr>
        <tr>
          <td width="150" class="label"><emxUtil:i18nScript localize="i18nId">emxComponents.Basic.Revision</emxUtil:i18nScript></td>
          <td class="inputField"><input type="text" name="txtRevision" value="*" /></td>
         </tr>
        <tr>
          <td width="150" class="label"><emxUtil:i18nScript localize="i18nId">emxComponents.Basic.Description</emxUtil:i18nScript></td>
         <td class="inputField"><input type="text" name="txtDescription" value="*" /></td>
        </tr>
        <tr>
          <td width="150" class="label"><emxUtil:i18nScript localize="i18nId">emxComponents.Basic.Owner</emxUtil:i18nScript>
          </td>
          <td class="inputField"><input type="text" name="txtOwner" value="*" />
           <input type="hidden" name="hdnOwner" value="" size="20" />
           <input type="button" value="..." onclick="getPersonChooser()" />
            </td>
        </tr>
        <tr>
          <td width="150" class="label"><emxUtil:i18nScript localize="i18nId">emxComponents.Basic.State</emxUtil:i18nScript></td>
          <td class="inputField"><input type="text" name="txtState" value="*" /></td>
        </tr>
         <td width="150" class="label">
           <emxUtil:i18n localize="i18nId">
           emxComponents.Common.Vault
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
    <input type="radio" value="<%=PersonUtil.SEARCH_DEFAULT_VAULT%>" name="vaultOption" <%=checked%> /><%=strDefault%><br/>
<%
               checked = "";
               if (  PersonUtil.SEARCH_LOCAL_VAULTS.equals(vaultDefaultSelection) )
               {
                  checked = "checked";
               }
%><!-- //XSSOK -->
    <input type="radio" value="<%=PersonUtil.SEARCH_LOCAL_VAULTS%>" name="vaultOption"<%=checked%> /><%=strLocal%><br/>
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
    <input type="radio" name="vaultOption" value="<%=selVault%>" <%=checked%> /><%=strSelected%>&nbsp;
                <input type="text" name="vaultsDisplay" value="<%=selDisplayVault%>" size="15" readonly="readonly" />

    <input type="button" name="button3" value="..." onclick="javascript:setSelectedVaultOption()" />

    <input type="hidden" name="vaults" value="<%=selVault%>" size="15" /><br/>
 <%
               checked = "";
               if (  PersonUtil.SEARCH_ALL_VAULTS.equals(vaultDefaultSelection) )
               {
                  checked = "checked";
               }
 %>
<!-- //XSSOK -->
    <input type="radio" name="vaultOption" value="<%=PersonUtil.SEARCH_ALL_VAULTS%>" <%=checked%> /><%=strAll%>
    <br/>
           </td>
          </tr>
         </table>
        </td>
       </tr>
      </table>

    </form>
  </body>
</html>
