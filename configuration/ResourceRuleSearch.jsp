<%--  ResourceRuleSearch.jsp  -
	Copyright (c) 1993-2018 Dassault Systemes.
	All Rights Reserved.
	This program contains proprietary and trade secret information of
	Dassault Systemes.
	Copyright notice is precautionary only and does not evidence any actual
	or intended publication of such program
--%>

<!-- Include directives -->
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../components/emxSearchInclude.inc"%>
<%@include file = "../emxTagLibInclude.inc"%>


<!-- Page directives -->
<%@page import="com.matrixone.apps.common.Search"%>
<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session" />
<!-- Declarations -->
<%!
  private static final String DEFAULT_BUNDLE = "emxConfigurationStringResource";
%>

<emxUtil:localize id="i18nId" bundle="<xss:encodeForHTMLAttribute><%=DEFAULT_BUNDLE%></xss:encodeForHTMLAttribute>" locale='<%=request.getHeader("Accept-Language")%>'/>


<%

try{  

	String strObjectId = emxGetParameter(request, "objectId");
	DomainObject domObjectSelect = new DomainObject(strObjectId);
	String contextName = domObjectSelect.getInfo(context, DomainConstants.SELECT_NAME);
	String strStar ="*";
	String strClear ="Clear";
%>


<link rel="stylesheet" href="../common/styles/emxUIDefault.css" type="text/css" />
<link rel="stylesheet" href="../common/styles/emxUIForm.css" type="text/css" />
<link rel="stylesheet" href="../common/styles/emxUIList.css" type="text/css" />

<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="javascript" src="../common/scripts/emxUIModal.js"></script>

<script language="javascript">

  var getWindowOpener() = self;

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
</script>

<html>
  <body onload="doLoad()">
    <form method="post" name="editDataForm">
   
      <input type="hidden" name="program" value="<xss:encodeForHTMLAttribute><%=emxGetParameter(request, "program")%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="table" value="<xss:encodeForHTMLAttribute><%=emxGetParameter(request, "table")%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="topActionbar" value="<xss:encodeForHTMLAttribute><%=emxGetParameter(request, "topActionbar")%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="bottomActionbar" value="<xss:encodeForHTMLAttribute><%=emxGetParameter(request, "bottomActionbar")%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="header" value="<xss:encodeForHTMLAttribute><%=emxGetParameter(request, "header")%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="selection" value="<xss:encodeForHTMLAttribute><%=emxGetParameter(request, "selection")%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="queryLimit" value="" />
      <input type="hidden" name="pagination" value="" />
      <input type="hidden" name="Style" value="<xss:encodeForHTMLAttribute><%=emxGetParameter(request, "Style")%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="Export" value="<xss:encodeForHTMLAttribute><%=emxGetParameter(request, "Export")%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="PrinterFriendly" value="<xss:encodeForHTMLAttribute><%=emxGetParameter(request, "PrinterFriendly")%></xss:encodeForHTMLAttribute>" /> 
      <input type="hidden" name="CancelButton" value="<xss:encodeForHTMLAttribute><%=emxGetParameter(request, "CancelButton")%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="searchmenu" value="<xss:encodeForHTMLAttribute><%=emxGetParameter(request, "searchmenu")%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="searchcommand" value="<xss:encodeForHTMLAttribute><%=emxGetParameter(request, "searchcommand")%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="searchmode" value="<xss:encodeForHTMLAttribute><%=emxGetParameter(request, "searchmode")%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="CommandName" value="<xss:encodeForHTMLAttribute><%=emxGetParameter(request, "CommandName")%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="HelpMarker" value="<xss:encodeForHTMLAttribute><%=emxGetParameter(request, "HelpMarker")%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="SubmitURL" value="<xss:encodeForHTMLAttribute><%=emxGetParameter(request, "SubmitURL")%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="srcDestRelName" value="<xss:encodeForHTMLAttribute><%=emxGetParameter(request, "srcDestRelName")%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="midBusType" value="<xss:encodeForHTMLAttribute><%=emxGetParameter(request, "midBusType")%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="midDestRelName" value="<xss:encodeForHTMLAttribute><%=emxGetParameter(request, "midDestRelName")%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="srcMidRelName" value="<xss:encodeForHTMLAttribute><%=emxGetParameter(request, "srcMidRelName")%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="isTo" value="<xss:encodeForHTMLAttribute><%=emxGetParameter(request, "isTo")%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=emxGetParameter(request, "objectId")%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="frameName" value="<xss:encodeForHTMLAttribute><%=emxGetParameter(request, Search.REQ_PARAM_FRAME_NAME)%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="formName" value="<xss:encodeForHTMLAttribute><%=emxGetParameter(request, Search.REQ_PARAM_FORM_NAME)%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="fieldNameActual" value="<xss:encodeForHTMLAttribute><%=emxGetParameter(request, Search.REQ_PARAM_FIELD_NAME_ACTUAL)%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="fieldNameDisplay" value="<xss:encodeForHTMLAttribute><%=emxGetParameter(request, Search.REQ_PARAM_FIELD_NAME_DISPLAY)%></xss:encodeForHTMLAttribute>" />     
	  <input type="hidden" name="toolbar" value="<xss:encodeForHTMLAttribute><%=emxGetParameter(request, "toolbar")%></xss:encodeForHTMLAttribute>" />
	  <input type="hidden" name="sortColumnName" value="<xss:encodeForHTMLAttribute><%=emxGetParameter(request, "sortColumnName")%></xss:encodeForHTMLAttribute>" />
     
      
 
      <table border="0" cellpadding="5" cellspacing="2" width="100%">
        <tr>
          <td width="150" class="label">
             <emxUtil:i18n localize="i18nId">
           emxProduct.Basic.Context
             </emxUtil:i18n>
          </td>
          <td class="inputField">
            <input readonly type="text" name="txtTypeDisplay" size="20" value="<xss:encodeForHTMLAttribute><%=contextName%></xss:encodeForHTMLAttribute>" />
            <input type="hidden" name="hdnType" size="20" value="<xss:encodeForHTMLAttribute><%=strObjectId%></xss:encodeForHTMLAttribute>" />
             <input type="button" name="btnTypeChooser" value="..." onclick="javascript:showTypeChooser();">&nbsp;<a class="dialogClear" href="#" onclick="document.editDataForm.txtTypeDisplay.value='<xss:encodeForHTMLAttribute><%=strStar%></xss:encodeForHTMLAttribute>'" /><%=XSSUtil.encodeForHTML(context,strClear)%></a>
           
          </td>
        </tr>
        <tr>
          <td width="150" class="label">
             <emxUtil:i18n localize="i18nId">
            emxFramework.Basic.Type
             </emxUtil:i18n>
          </td>
          <td class="inputField"><input READONLY type="text" name="type" value="Resource Rule" /></td>
          </tr>
          
          
           <tr>
          <td width="150" class="label">
             <emxUtil:i18n localize="i18nId">
             emxFramework.Basic.Name
             </emxUtil:i18n>
          </td>
          <td class="inputField"><input type="text" name="txtName" value="*" /></td>
          </tr>
          
           <tr>
          <td width="150" class="label">
             <emxUtil:i18n localize="i18nId">
          emxProduct.Basic.Comment
             </emxUtil:i18n>
          </td>
          <td class="inputField"><input type="text" name="comment" value="*" /></td>
          </tr>
      
       </tr>
       
      </table>

    </form>

  </body>
</html>



       
<script language="javascript">
 
    function showTypeChooser()
  {  
 showChooser('../components/emxCommonSearch.jsp?formName=editDataForm&frameName=searchContent&fieldNameActual=hdnType&fieldNameDisplay=txtTypeDisplay&searchmode=chooser&suiteKey=Configuration&searchmenu=SearchAddExistingChooserMenu&searchcommand=PLCSearchProductsCommand,PLCSearchProductLinesCommand,FTRSearchFeaturesCommand,FTRSearchProductVariant&type=emxFramework.search.Rule.Types', 700, 500)
   
   }
</script>

<%    }
 catch (Exception exception){
       %>
         <script>
            alert("<%=XSSUtil.encodeForJavaScript(context,exception.getMessage())%>");
         </script>
<%
       }%>
       
       
