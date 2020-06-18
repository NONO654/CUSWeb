<%-- emxSearchSaveDialog.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
--%>

<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>

<html>
<head>
        <title>
         <framework:i18n localize="i18nId">emxFramework.GlobalSearch.SearchTitle</framework:i18n>&nbsp;
         <framework:i18n localize="i18nId">emxFramework.GlobalSearch.Save</framework:i18n>
        </title>
        <script type="text/javascript" language="JavaScript" src="scripts/emxUIConstants.js"></script>
        <script type="text/javascript" language="JavaScript" src="scripts/emxUICore.js"></script>
        <script type="text/javascript" language="JavaScript" src="scripts/emxUICoreMenu.js"></script>
        <%@include file = "../emxJSValidation.inc" %>
        
        <script type="text/javascript" language="JavaScript">       
            addStyleSheet("emxUIDefault");
            addStyleSheet("emxUIForm");
            addStyleSheet("emxUIDOMLayout");
			addStyleSheet("emxUIDialog");
<%--  These i18n strings must come before emxSearchSaveDialog.js --%>
            //i18n strings
            var EmptyNameField = "<emxUtil:i18nScript localize="i18nId">emxFramework.GlobalSearch.ErrorMsg.EmptyNameField</emxUtil:i18nScript>";
            var InvalidInputMsg = "<emxUtil:i18nScript localize="i18nId">emxFramework.GlobalSearch.ErrorMsg.InvalidInputMsg</emxUtil:i18nScript>";
            
                
            function doDone(){

                var result = "";
                turnOnProgress();
                var searchName = document.forms['bodyform'].elements[0].value;
                
            
                //are there special characters?
                if(!checkField(document.forms['bodyform'].elements[0])){
                    document.forms['bodyform'].elements[0].focus();
                    turnOffProgress();
                    return;
                }
                
                searchName = trimString(searchName);
                if (searchName.length > 0){
                    result = getTopWindow().getWindowOpener().saveSearch(searchName,"save",null);
                }else{
                    alert(EmptyNameField);
                    turnOffProgress();
                }
               searchSaveHidden.document.write(result);
            }

        </script>
        <script type="text/javascript" language="JavaScript" src="scripts/emxUISearchUtils.js"></script>
</head>
<body onLoad="turnOffProgress();" >
<div id="pageHeadDiv">
<form name="tableHeaderForm">
   <table>
  <tr>
    <td class="page-title">
      <h2><emxUtil:i18n localize="i18nId">emxFramework.GlobalSearch.SaveSearch</emxUtil:i18n></h2>
    </td>
<%
String languageStr = request.getHeader("Accept-Language");	
String processingText = UINavigatorUtil.getProcessingText(context, languageStr);
%>
        <td class="functions">
        <table>
              <tr>
                <!-- //XSSOK -->
                <td class="progress-indicator"><div id="imgProgressDiv"><%=processingText%></div></td>
        </tr></table>
        </td>
  </tr>
</table>
        </form>
</div>
<div id="divPageBody">
  <form name="bodyform" method="post" onsubmit="doDone(); return false">
    <table border="0" cellpadding="5" cellspacing="2" width="100%">
      <tr>
        <td  class="label"><emxUtil:i18n localize="i18nId">emxFramework.GlobalSearch.Name</emxUtil:i18n></td>
        <td class="inputField"><input type="text" size="35" name="txtName" id="txtName" value="" /></td>
      </tr>
    </table>
  </form>
<iframe class="hidden-frame" src="emxBlank.jsp" name="searchSaveHidden" id="searchSaveHidden"></iframe>  
</div>
<div id="divPageFoot">
<form name="editFooter" method="post">
<table border="0" cellspacing="0" cellpadding="0" width="100%">
<tr>
    <td class="pagination"></td>
	<td class="buttons">
    <table>
      <tr>
        <td><a class="footericon" href="javascript:doDone()"><img src="../common/images/buttonDialogDone.gif" border="0" alt="Done" /></a></td>
        <td><a onClick="javascript:doDone()"><button class="btn-primary" type="button"><emxUtil:i18n localize="i18nId">emxFramework.GlobalSearch.Done</emxUtil:i18n></button></a></td>
        <td><a class="footericon" href="javascript:getTopWindow().closeWindow()"><img src="../common/images/buttonDialogCancel.gif" border="0" /></a></td>
        <td><a onClick="javascript:getTopWindow().closeWindow()"><button class="btn-default" type="button"><emxUtil:i18n localize="i18nId">emxFramework.GlobalSearch.Cancel</emxUtil:i18n></button></a></td>
      </tr>
    </table>
	</td>
</tr>
</table>
</form>          
  </div>
</body>
</html>
