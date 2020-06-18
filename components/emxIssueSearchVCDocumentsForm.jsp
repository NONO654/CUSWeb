<%-- emxIssueSearchVCDocumentsForm.jsp

   Copyright (c) 1999-2018 Dassault Systemes.
   All Rights Reserved.

   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = "$Id: emxIssueSearchVCDocumentsForm.jsp.rca 1.8.2.5.2.1 Tue Dec 23 05:54:52 2008 ds-hkarthikeyan Experimental $"

--%>
<!-- Include directives -->
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "emxComponentsCommonInclude.inc"%>
<%@include file = "../emxTagLibInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%@include file = "../emxJSValidation.inc" %>
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
    //String emxSearchBadChars = FrameworkProperties.getProperty(context,"emxComponents.Common.SearchBadChars");
    String strClear = i18nNowInstance.GetString(DEFAULT_BUNDLE,strLocale,"emxComponents.Button.Clear");
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

      String stores = MqlUtil.mqlCommand(context, "list store" );
      StringList storeList = FrameworkUtil.split(stores, "\n");
      Iterator storeItr = storeList.iterator();
      StringList servers = new StringList(1);
      String storeType;
      String storeName;
      while(storeItr.hasNext())
      {
          storeName = (String) storeItr.next();
          storeType = MqlUtil.mqlCommand(context, "print store '" + storeName + "' select type dump;" );
          if( "designsync".equalsIgnoreCase(storeType) )
          {
              servers.add(storeName);
          }
      }


  String strProgram = emxGetParameter(request, "program");
  String strExpandProgram = emxGetParameter(request, "expandProgram");

  String strTable = emxGetParameter(request, "table");
  String strTopActionbar = emxGetParameter(request, "topActionbar");
  String strBottomActionbar = emxGetParameter(request, "bottomActionbar");
  String strHeader = emxGetParameter(request, "header");
  String strSelection = emxGetParameter(request, "selection");
  String strStyle = emxGetParameter(request, "Style");
  String strExport = emxGetParameter(request, "Export");
  String strCommandName = emxGetParameter(request, "CommandName");
  String strPrinterFriendly = emxGetParameter(request, "PrinterFriendly");
  String strCancelLabel = emxGetParameter(request, "cancelLabel");
  String strSubmitLabel = emxGetParameter(request, "submitLabel");
  String strHelpMarker = emxGetParameter(request, "HelpMarker");
  String strSubmitURL = emxGetParameter(request, "SubmitURL");
  String strActionURL = emxGetParameter(request, "ActionURL");
  String strFromPage = emxGetParameter(request, "fromPage");
  String strObjectAction = emxGetParameter(request, "objectAction");
  String strparentId = emxGetParameter(request, "parentOID");

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
  String strToolbar = emxGetParameter(request, "toolbar");

 %>
 <%@include file = "../emxUICommonHeaderEndInclude.inc"%>
  <form method="post" name="editDataForm">
    <input type="hidden" name="queryLimit" value=""/>
    <input type="hidden" name="pagination" value=""/>
    <input type="hidden" name="suiteKey" value="<xss:encodeForHTMLAttribute><%=strSuiteKey%></xss:encodeForHTMLAttribute>"/>
	<% if ( strparentId!=null && !strparentId.equals("") ) { %>
    <input type="hidden" name="parentId" value="<xss:encodeForHTMLAttribute><%=strparentId%></xss:encodeForHTMLAttribute>"/>
  <% }if ( strSuiteKey!=null && !strSuiteKey.equals("") ) { %>
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
    <input type="hidden" name="selection" value='single'/>
  <% } if ( strStyle!=null && !strStyle.equals("") ) { %>
    <input type="hidden" name="Style" value="<xss:encodeForHTMLAttribute><%=strStyle%></xss:encodeForHTMLAttribute>"/>
  <% } if ( strExport!=null && !strExport.equals("") ) { %>
    <input type="hidden" name="Export" value="<xss:encodeForHTMLAttribute><%=strExport%></xss:encodeForHTMLAttribute>"/>
  <% } if ( strPrinterFriendly!=null && !strPrinterFriendly.equals("") ) { %>
    <input type="hidden" name="PrinterFriendly" value="<xss:encodeForHTMLAttribute><%=strPrinterFriendly%></xss:encodeForHTMLAttribute>"/>
  <% } if ( strSubmitURL!=null && !strSubmitURL.equals("") ) { %>
    <input type="hidden" name="submitURL" value='<xss:encodeForHTMLAttribute><%=strSubmitURL%></xss:encodeForHTMLAttribute>'/>
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
  <% } if ( strHelpMarker!=null && !strHelpMarker.equals("") ) { %>
    <input type="hidden" name="HelpMarker" value="<xss:encodeForHTMLAttribute><%=strHelpMarker%></xss:encodeForHTMLAttribute>"/>
  <% } if ( strActionURL!=null && !strActionURL.equals("") ) { %>
      <input type="hidden" name="ActionURL" value="<xss:encodeForHTMLAttribute><%=strActionURL%></xss:encodeForHTMLAttribute>"/>
  <% } if ( strExpandProgram!=null && !strExpandProgram.equals("") ) { %>
    <input type="hidden" name="expandProgram" value="<xss:encodeForHTMLAttribute><%=strExpandProgram%></xss:encodeForHTMLAttribute>"/>
  <% } if ( strFromPage!=null && !strFromPage.equals("") ) { %>
    <input type="hidden" name="fromPage" value="<xss:encodeForHTMLAttribute><%=strFromPage%></xss:encodeForHTMLAttribute>"/>
  <% } if ( strCancelLabel!=null && !strCancelLabel.equals("") ) { %>
    <input type="hidden" name="cancelLabel" value="<xss:encodeForHTMLAttribute><%=strCancelLabel%></xss:encodeForHTMLAttribute>"/>
  <% } if ( strSubmitLabel!=null && !strSubmitLabel.equals("") ) { %>
    <input type="hidden" name="submitLabel" value="<xss:encodeForHTMLAttribute><%=strSubmitLabel%></xss:encodeForHTMLAttribute>"/>
  <% } if ( strObjectAction!=null && !strObjectAction.equals("") ) { %>
    <input type="hidden" name="objectAction" value="<xss:encodeForHTMLAttribute><%=strObjectAction%></xss:encodeForHTMLAttribute>"/>
  <% } if ( strToolbar!=null && !strToolbar.equals("") ) { %>
    <input type="hidden" name="toolbar" value="<xss:encodeForHTMLAttribute><%=strToolbar%></xss:encodeForHTMLAttribute>"/>
  <% } %>
      <input type="hidden" name="isTo" value=''/>
      <input type="hidden" name="parentOID" value='<xss:encodeForHTMLAttribute><%=strObjectId%></xss:encodeForHTMLAttribute>'/>
    <table border="0" width="99%" cellpadding="5" cellspacing="2">
   <tr>
     <td width="150" class="label">
     <emxUtil:i18n localize="i18nId">
     emxFramework.Basic.Type
     </emxUtil:i18n>
     </td>
     <td class="inputField" nowrap="nowrap" colspan="1">
     <!-- //XSSOK -->
	 <input type="text" READONLY name="TypeDisplayDocument" value="<%=XSSUtil.encodeForHTMLAttribute(context,strTypeToDisplay)%>" maxlength="" size="20" readonly="readonly"/><input type="hidden" name="TypeDocument"  value="<%=XSSUtil.encodeForHTMLAttribute(context,strType)%>"/><input type="button" name="button1"  value="..." onclick="javascript:showTypeChooser();"/>
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
   <tr>
     <td width="150" class="label">
    <emxUtil:i18n localize="i18nId">
    emxFramework.Basic.Owner
    </emxUtil:i18n>
     </td>
     <td class="inputField" colspan="1">
     <!-- //XSSOK -->
    <input type="text" READONLY name="OwnerDisplay" value="<%=STAR%>" maxlength="" size="20" readonly="readonly"/><input type="hidden" name="Owner"  value="<%=STAR%>"><input type="button" name="button2" value="..." onclick="javascript:showOwnerChooser();"/>&nbsp;<a class="dialogClear" href="#" onclick="document.editDataForm.OwnerDisplay.value='<%=STAR%>'"><%=strClear%></a>
     </td>
   </tr>

   <tr>
     <td width="150" class="label">
    <emxUtil:i18n localize="i18nId">
    emxComponents.VCDocument.DesignSync
    </emxUtil:i18n>
     </td>
     <td class="inputField" colspan="1">
    <input type="checkbox" name="DesignSyncFile"  id="DesignSyncFile" value="DesignSyncFile" checked/>&nbsp;    <emxUtil:i18n localize="i18nId">
    emxComponents.CommonDocument.File
    </emxUtil:i18n>

    <input type="checkbox" name="DesignSyncFolder"  id="DesignSyncFolder" value="DesignSyncFolder" checked/>&nbsp;    <emxUtil:i18n localize="i18nId">
    emxComponents.CommonDocument.Folder
    </emxUtil:i18n>
    <input type="checkbox" name="DesignSyncModule"  id="DesignSyncModule" value="DesignSyncModule" checked/>&nbsp;    <emxUtil:i18n localize="i18nId">
    emxComponents.CommonDocument.Module
    </emxUtil:i18n>
     </td>
   </tr>
    </tr>
    <tr>
    <td width="10%" class="label"><emxUtil:i18n localize="i18nId">emxComponents.CommonDocument.Server</emxUtil:i18n>&nbsp;
    </td>
    <td colspan="1" class="inputField">
          <select id="server" name="server">&nbsp;
          <option value="None"></option>
<%
          Iterator serverItr = servers.iterator();
          while(serverItr.hasNext())
          {
            String serverName = (String)serverItr.next();
%>
            <option value="<%=XSSUtil.encodeForHTMLAttribute(context,serverName)%>"><%=XSSUtil.encodeForHTML(context,serverName)%>&nbsp;</option>
<%
          }
%>
        </select>
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
     // ReloadOpener is passed as false to avoid reloading of the page
	 showChooser('../common/emxTypeChooser.jsp?frameName=searchPane&formName=editDataForm&SelectType=single&SelectAbstractTypes=true&InclusionList=<%=XSSUtil.encodeURLwithParsing(context,strBaseType)%>&ObserveHidden=true&ShowIcons=true&fieldNameActual=TypeDocument&fieldNameDisplay=TypeDisplayDocument&ReloadOpener=false',500,400);
   }
  function showOwnerChooser()
    {
   showChooser('../components/emxCommonSearch.jsp?formName=editDataForm&frameName=searchPane&searchmode=chooser&suiteKey=Components&searchmenu=SearchIssueAddExistingChooser&searchcommand=SearchAssigneeIssueLink&fieldNameActual=Owner&fieldNameDisplay=OwnerDisplay',700,500);
    }
 function reload()
    {
    document.editDataForm.method= "post";
    document.editDataForm.action="../components/emxIssueSearchVCDocumentsForm.jsp?suiteKey=Components";
    document.editDataForm.submit();
  }
  
 </script>
 <%

}
 catch (Exception exp)  {
     exp.printStackTrace(System.out);
     throw exp;
  }
%>


