<%-- emxEngineeringChangeSearchDialog.jsp

   Copyright (c) 2005-2018 Dassault Systemes. All Rights Reserved.

   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxEngineeringChangeSearchDialog.jsp.rca 1.9 Wed Oct 22 16:18:31 2008 przemek Experimental przemek $
--%>
<!-- Include directives -->
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "emxComponentsCommonInclude.inc"%>
<%@include file = "../emxTagLibInclude.inc"%>
<!-- Page directives -->
<%@page import = "java.util.HashSet"%>
<%@page import = "java.util.List"%>
<%@page import = "com.matrixone.apps.common.EngineeringChange"%>
<%@page import = "com.matrixone.apps.common.Person"%>
<%@page import = "com.matrixone.apps.domain.util.PersonUtil"%>
<%@page import = "com.matrixone.apps.domain.util.mxType"%>
<%@page import = "matrix.db.Policy"%>
<%@page import = "matrix.db.StateRequirementList"%>
<%@page import="com.matrixone.apps.common.Search"%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.matrixone.apps.domain.util.i18nNow"%>

<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="javascript" src="../common/scripts/emxUIModal.js"></script>
<script language="javascript" src="../common/scripts/emxUISearch.js"></script>
<script language="javascript" src="../emxUIPageUtility.js"></script>

<%@include file = "../emxStyleDefaultInclude.inc"%>
<%@include file = "../emxStyleFormInclude.inc"%>


<script language="javascript">
    addStyleSheet("emxUIMenu");
</script>

<!-- Declarations -->
<%!
  private static final String DEFAULT_BUNDLE = "emxComponentsStringResource";
%>

<%
try {
    String strStar = EnoviaResourceBundle.getProperty(context,"emxComponents.Search.Star");

    String strLocale = context.getSession().getLanguage();
    i18nNow i18nNowInstance = new i18nNow();

    String strClear = i18nNowInstance.GetString(DEFAULT_BUNDLE,strLocale,"emxComponents.Button.Clear");
    String strAllValidStates = i18nNowInstance.GetString("emxComponentsStringResource",strLocale,"emxComponents.Form.Radio.AllValidStates");
    String strAll = i18nNowInstance.GetString("emxFrameworkStringResource",strLocale,"emxFramework.Preferences.AllVaults");
    String strDefault = i18nNowInstance.GetString("emxFrameworkStringResource",strLocale,"emxFramework.Preferences.UserDefaultVault");
    String strSelected = i18nNowInstance.GetString("emxFrameworkStringResource",strLocale,"emxFramework.Preferences.SelectedVaults");
    String strLocal = i18nNowInstance.GetString("emxFrameworkStringResource",strLocale,"emxFramework.Preferences.LocalVaults");














    String strTypeToDisplay=null;
    StateRequirementList stateRequirementList;
    Policy policy;

    String strTypeDisplay = emxGetParameter(request, "TypeDisplayEngineeringChange");
    String strTypeActual = emxGetParameter(request, "hdnType");
    String strSelectedPolicy = emxGetParameter(request, "Policy");
    String strSuiteKey = emxGetParameter(request, Search.REQ_PARAM_SUITE_KEY);

    Person person = Person.getPerson(context, context.getUser());
    String strVaults = person.getCompany(context).getAllVaults(context);

    String vaultDefaultSelection = PersonUtil.getSearchDefaultSelection(context);
    String languageStr = request.getHeader("Accept-Language");

    /* Suppose, a Type is selected, then, change the Policy dropdown for the given type only */
    String strType = null;
    if ( strTypeDisplay!=null && !strTypeDisplay.equals("") ) {
        strTypeToDisplay = strTypeDisplay;
        strType = strTypeActual;
    } else {
        strType = DomainConstants.TYPE_ENGINEERING_CHANGE;
        strTypeToDisplay = i18nNow.getTypeI18NString(strType, strLocale);
      }
    if(strSelectedPolicy==null || "null".equalsIgnoreCase(strSelectedPolicy) ||  strSelectedPolicy.equals("")) {
        Map defaultMap = mxType.getDefaultPolicy(context, strType, true);
        strSelectedPolicy = (String)defaultMap.get("name");
      }

    AttributeType atType = new AttributeType(DomainConstants.ATTRIBUTE_SEVERITY);
    atType.open(context);
    List listSeverity = atType.getChoices();
    atType.close(context);

    AttributeType cfcType = new AttributeType(DomainConstants.ATTRIBUTE_CATEGORY_OF_CHANGE);
    cfcType.open(context);
    List listCategoryOfChange = cfcType.getChoices();
    cfcType.close(context);

    policy = new Policy(strSelectedPolicy);
    policy.open ( context );

    stateRequirementList= policy.getStateRequirements ();

    StateRequirementItr stateRequirementItr  = new StateRequirementItr(stateRequirementList );
    HashSet _stateNameSet = new HashSet();


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
    String strCancelLabel = emxGetParameter(request, "CancelLabel");
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
    String strSortColumnName = emxGetParameter(request, "sortColumnName");
    String strToolbar = emxGetParameter(request, "toolbar");

%>
<body onload="turnOffProgress(),getTopWindow().loadSearchFormFields()">
    <form method="post" name="editDataForm" onsubmit="submitForm(); return false;">
      <!-- QueryLimit was added as a dummy hidden field since it was being accessed from /common/emxSearchFooter.jsp-->
      <input type="hidden" name="QueryLimit" value=""/>
   <input type="hidden" name="queryLimit" value=""/>
      <input type="hidden" name="pagination" value=""/>

    <%
  //strSearchMode is null when the mode is globalsearch, since we are not passing this parameter from command.
  if(strSearchMode==null)
  {
   strSearchMode = "globalsearch";
 %>
   <input type="hidden" name="toolbar" value="APPSearchResultToolbar" />
   <input type="hidden" name="selection" value="multiple" />
   <input type="hidden" name="CancelButton" value="true" />
      <input type="hidden" name="CancelLabel" value="emxComponents.ActionLink.Close" />
 <%
  }
 %>

<%
 if ( strSuiteKey!=null && !strSuiteKey.equals("") ) { %>
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
      <input type="hidden" name="selection" value='<%=strSelection%>'/>
    <% } if ( strStyle!=null && !strStyle.equals("") ) { %>
      <input type="hidden" name="Style" value="<xss:encodeForHTMLAttribute><%=strStyle%></xss:encodeForHTMLAttribute>"/>
    <% } if ( strExport!=null && !strExport.equals("") ) { %>
      <input type="hidden" name="Export" value="<xss:encodeForHTMLAttribute><%=strExport%></xss:encodeForHTMLAttribute>"/>
    <% } if ( strPrinterFriendly!=null && !strPrinterFriendly.equals("") ) { %>
      <input type="hidden" name="PrinterFriendly" value="<xss:encodeForHTMLAttribute><%=strPrinterFriendly%></xss:encodeForHTMLAttribute>"/>
    <% } if ( strCancelButton!=null && !strCancelButton.equals("") ) { %>
      <input type="hidden" name="CancelButton" value='<%=strCancelButton%>'/>
   <% } if ( strCancelLabel!=null && !strCancelLabel.equals("") ) { %>
      <input type="hidden" name="CancelLabel" value='<%=strCancelLabel%>'/>
    <% } if ( strSubmitURL!=null && !strSubmitURL.equals("") ) { %>
      <input type="hidden" name="SubmitURL" value='<%=strSubmitURL%>'/>
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
      <input type="hidden" name="objectId" value='<%=strObjectId%>'/>
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
    <% } if ( strSortColumnName!=null && !strSortColumnName.equals("") ) { %>
      <input type="hidden" name="sortColumnName" value="<xss:encodeForHTMLAttribute><%=strSortColumnName%></xss:encodeForHTMLAttribute>"/>
 <% } if ( strToolbar!=null && !strToolbar.equals("") ) { %>
      <input type="hidden" name="toolbar" value='<%=strToolbar%>'/>
 <% }
%>

      <table border="0" width="99%" cellpadding="5" cellspacing="2">
        <tr>
          <td width="150" class="label">
             <emxUtil:i18n localize="i18nId">
             emxFramework.Basic.Type
             </emxUtil:i18n>
          </td>
          <td class="inputField" nowrap="nowrap" colspan="1">
             <input type="text" READONLY name="TypeDisplayEngineeringChange" value="<%=strTypeToDisplay%>" maxlength="" size="20" readonly="readonly"/><input type="hidden" name="hdnType"  value="<%=strType%>"/><input type="button" name="button1" value="..." onclick="javascript:showTypeChooser();"/>
          </td>
        </tr>

        <tr>
          <td width="150" class="label">
             <emxUtil:i18n localize="i18nId">
             emxFramework.Basic.Name
             </emxUtil:i18n>
          </td>
          <td class="inputField" nowrap="nowrap" colspan="1">
             <input type="text" name="txtName" maxlength="" size="20" value="<xss:encodeForHTMLAttribute><%=strStar%></xss:encodeForHTMLAttribute>"/>
          </td>
        </tr>


        <tr>
          <td width="150" class="label">
            <emxUtil:i18n localize="i18nId">
            emxFramework.Basic.Description
            </emxUtil:i18n>
          </td>
          <td class="inputField" colspan="1">
            <input type="text" name="txtDescription" maxlength="" size="20" value="<xss:encodeForHTMLAttribute><%=strStar%></xss:encodeForHTMLAttribute>"/>
          </td>
        </tr>

        <tr>
          <td width="150" class="label">
            <emxUtil:i18n localize="i18nId">
            emxFramework.Basic.State
            </emxUtil:i18n>
          </td>
          <td class="inputField" colspan="1">

                  <select name="txtState">
                    <option value="<%=strStar%>">
                     <%=strAllValidStates%>
                    </option>
                    <% while ( stateRequirementItr.next () ) {
                       String strState = ((String)stateRequirementItr.obj ().getName ());
                     %>
                    <option value="<%=strState%>"><%=i18nNow.getStateI18NString(strSelectedPolicy, strState,acceptLanguage)%>
                    </option>
                    <% } %>
                  </select>

          </td>
        </tr>
        <tr>
          <td width="150" class="label">
            <emxUtil:i18n localize="i18nId">
            emxFramework.Basic.Owner
            </emxUtil:i18n>
          </td>
          <td class="inputField" colspan="1">
            <input type="text" READONLY name="txtOwner" value="<%=strStar%>" maxlength="" size="20" readonly="readonly"/><input type="hidden" name="Owner"  value="<%=strStar%>"/><input type="button" name="button2" value="..." onclick="javascript:showOwnerChooser();"/>&nbsp;<a class="dialogClear" href="#" onclick="document.editDataForm.txtOwner.value='<%=strStar%>'"><%=strClear%></a>
          </td>
        </tr>

        <tr>
           <td width="150" class="label">
             <emxUtil:i18n localize="i18nId">
             emxFramework.Attribute.CategoryOfChange
             </emxUtil:i18n>
           </td>
           <td class="inputField" colspan="1">
                   <select name="txtCategoryOfChange">
                     <option value="<%=strStar%>" selected><%=strStar%></option>
                     <% for (int i=0; i<listCategoryOfChange.size(); i++) {
                            String strCategoryOfChange = (String)listCategoryOfChange.get(i);




                     %>
                                <option value="<%=strCategoryOfChange%>"><%=i18nNow.getRangeI18NString(DomainConstants.ATTRIBUTE_CATEGORY_OF_CHANGE,strCategoryOfChange,languageStr)%></option>
                     <%
                        } %>
                   </select>
           </td>
        </tr>

        <tr>
          <td width="150" class="label">
            <emxUtil:i18n localize="i18nId">
            emxFramework.Attribute.Severity
            </emxUtil:i18n>
          </td>
          <td class="inputField" colspan="1">
                  <select name="txtSeverity">
                  <option value="<%=strStar%>" selected><%=strStar%></option>
                  <% for (int i=0; i<listSeverity.size(); i++) {
                        String strSeverity = (String)listSeverity.get(i);
                  %>
                        <option value="<%=strSeverity%>"><%=i18nNow.getRangeI18NString(DomainConstants.ATTRIBUTE_SEVERITY,strSeverity,languageStr)%></option>
                  <%
                     }//end of for loop


                   %>
                  </select>
          </td>
        </tr>


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
             <td>
    <input type="radio" value="<%=PersonUtil.SEARCH_DEFAULT_VAULT%>" name="vaultOption" <%=checked%>/><%=strDefault%><br>
<%
               checked = "";
               if (  PersonUtil.SEARCH_LOCAL_VAULTS.equals(vaultDefaultSelection) )
               {
                  checked = "checked";
               }
%>
    <input type="radio" value="<%=PersonUtil.SEARCH_LOCAL_VAULTS%>" name="vaultOption"<%=checked%>/><%=strLocal%><br>
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
 %>
    <input type="radio" name="vaultOption" value="<%=selVault%>" <%=checked%>/><%=strSelected%>&nbsp;
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

<script language="javascript">
turnOffProgress();
 function showTypeChooser()
  {
    showChooser('../common/emxTypeChooser.jsp?frameName=searchPane&formName=editDataForm&SelectType=single&SelectAbstractTypes=true&InclusionList=type_EngineeringChange&ObserveHidden=true&ShowIcons=true&fieldNameActual=hdnType&fieldNameDisplay=TypeDisplayEngineeringChange&ReloadOpener=true',500,400);
  }

 function showOwnerChooser()
   {
      showChooser('../components/emxCommonSearch.jsp?formName=editDataForm&frameName=searchPane&searchmode=PersonChooser&suiteKey=Components&searchmenu=APPECSearchAddExistingChooser&searchcommand=SearchECAssigneeLink&selection=multiple&fieldNameActual=Owner&fieldNameDisplay=txtOwner',700,500);
   }

 function reload()
   {
      document.editDataForm.method= "post";
      document.editDataForm.action="../components/emxEngineeringChangeSearchDialog.jsp?program=emxCommonEngineeringChange:getEngineeringChangeSearchResults&table=APPECContextSearchList&CommandName=ObjectSearchEngineeringChangesCommand&sortColumnName=Name&header=emxComponents.Heading.Search&Style=dialog&HelpMarker=emxhelpsearchresults&suiteKey=Components&StringResourceFileId=emxComponentsStringResource&SuiteDirectory=Components&defaultSearch=ObjectSearchEngineeringChangesCommand&Policy=null";
      document.editDataForm.submit();
    }

// Added to submit the form when user pressed enter
function submitForm()
{
  //this part of the code will execute for internal search
  if(parent.searchPane)
  {
    getTopWindow().doSearch();
  }
  else
  {
    //this part of the code will execute for global search
    var footFrame = findFrame(getTopWindow(),"searchFoot");
    if(footFrame)
    {
      footFrame.doFind();
    }
  }
}

function doSearch()
 {
      //get the form
        var theForm = document.forms[0];
        //set form target
        theForm.target = "searchView";
        // If the page need to do some pre-processing before displaying the results
        // Use the "searchHidden" frame for target

        //assigning the QueryLimit value entered in the footer page to queryLimit parameter in this page
  //theForm.queryLimit.value=getTopWindow().frames['pageContent'].frames[2].document.forms[0].QueryLimit.value;
  theForm.queryLimit.value=getTopWindow().frames['pageContent'].document.forms[0].QueryLimit.value;
  theForm.action = "../common/emxTable.jsp";
      if (jsDblClick()) {
              theForm.submit();
        }

    }

function setSelectedVaultOption()
  {
   document.forms[0].vaultOption[2].checked=true;
      showChooser('../common/emxVaultChooser.jsp?fieldNameActual=vaults&fieldNameDisplay=vaultsDisplay&incCollPartners=false&isFromSearchForm=true&multiSelect=true');
  }
</script>


<%
}


 catch (Exception exp)  {
     exp.printStackTrace(System.out);
     throw exp;
 }
%>



