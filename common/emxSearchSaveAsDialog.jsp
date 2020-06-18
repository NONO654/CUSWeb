<%-- emxSearchSaveAsDialog.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
--%>
<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>

<% 
String strNamePrefix = emxGetParameter(request, "namePrefix");
if (strNamePrefix == null || strNamePrefix.equals("")) {
	strNamePrefix = ".emx";
}
int prefixLength = strNamePrefix.length();

StringList searchList = null;
try
{
    ContextUtil.startTransaction(context, true);
    searchList = UISearch.getSearchObjects(context);
    searchList.sort();
} catch (Exception ex) {
    ContextUtil.abortTransaction(context);
    if (ex.toString() != null && (ex.toString().trim()).length() > 0)
        emxNavErrorObject.addMessage(ex.toString().trim());

} finally {
    ContextUtil.commitTransaction(context);
}

  Iterator searchIterator = searchList.iterator();
 %>

<html>
   <head>
      <title>
         <framework:i18n localize="i18nId">emxFramework.GlobalSearch.SearchTitle</framework:i18n>&nbsp;
         <framework:i18n localize="i18nId">emxFramework.GlobalSearch.SaveAs</framework:i18n>
      </title>
<script type="text/javascript" language="JavaScript" src="scripts/emxUIConstants.js"></script>
<script type="text/javascript" language="JavaScript" src="scripts/emxUICore.js"></script>
<script type="text/javascript" language="JavaScript" src="scripts/emxUICoreMenu.js"></script>
<%@include file = "../emxJSValidation.inc" %>
<script type="text/javascript" language="JavaScript">
    addStyleSheet("emxUIDefault");
    addStyleSheet("emxUIList");
    addStyleSheet("emxUIForm");
    addStyleSheet("emxUIDOMLayout");
    addStyleSheet("emxUIDialog");

    //i18n strings
    var NameField = "<emxUtil:i18nScript localize="i18nId">emxFramework.GlobalSearch.ErrorMsg.NameField</emxUtil:i18nScript>";
    var InvalidInputMsg = "<emxUtil:i18nScript localize="i18nId">emxFramework.GlobalSearch.ErrorMsg.InvalidInputMsg</emxUtil:i18nScript>";
    
    function doSearch(){
        var result = "";
        //get saveName value
        var theForm = document.forms['emxTableForm'];
        var formLen = theForm.elements.length;
        var strName = "";
        var saveType = "";
        var objField = null;
        
        for(var i = 0; i < formLen; i++){
            if(theForm.elements[i].type == "radio" && theForm.elements[i].checked){
               if(theForm.elements[i].value == "txtName"){
                    objField = document.getElementById("txtName");
                    strName = objField.value;
                    saveType = "save";
                    break;
               }else{
                    objField = theForm.elements[i];
                    strName = objField.value;
                    saveType = "update";
                    break;
               }
            }
        }
        
        //is strName empty?
        if(trimWhitespace(strName).length == 0){
            alert(NameField);
            objField.focus();
            return;
        }
        
        //are there special characters?
        if(!checkField(objField)){
            objField.focus();
            turnOffProgress();
            return;
        }
                
        //getTopWindow().pageControl.getSavedSearchName()
        if(getTopWindow().getWindowOpener().pageControl.getSavedSearchName){
        	var collectionSavedName = getTopWindow().getWindowOpener().pageControl.getSavedSearchName();
        }
        getTopWindow().getWindowOpener().pageControl.setSavedSearchName(strName);
        
        //call save 
        result = getTopWindow().getWindowOpener().saveSearch(strName,saveType,collectionSavedName);
        
        searchSaveAsHidden.document.write(result);
    }
</script>
<script type="text/javascript" language="JavaScript" src="scripts/emxUISearchUtils.js"></script>
</head>
<body onload="turnOffProgress()">
	<div id="pageHeadDiv">
		<form name="tableHeaderForm">
			<table>
			<tr>
				<td class="page-title">
					<h2><emxUtil:i18n localize="i18nId">emxFramework.GlobalSearch.SaveAs</emxUtil:i18n></h2>
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
						</tr>
					</table>
				</td>
			</tr>
			</table>
		</form>
	</div>
<div id="divPageBody">
      <form method="post" name="emxTableForm" onsubmit="doSearch(); return false">
         <table class="list">
            <thead>
               <tr>
                  <th width="5%" style="text-align:center">
                  </th>
                  <th>
                     <emxUtil:i18n localize="i18nId">emxFramework.GlobalSearch.Name</emxUtil:i18n>
                  </th>
               </tr>
            </thead>
            <tbody>
            <tr class="odd">
                  <td style="text-align: center; ">
				<input type="radio" name="savedSearchName" id="savedSearchName" value="txtName" checked/>
			</td>
			<td>
				<img src="images/iconSmallFile.gif" alt="File"/>
				<span class="object"><input type="text" name="txtName" id="txtName" value=""/></span>
			</td>
		</tr>
<%  
String rowClass = "even";
String previousName = emxGetParameter(request, "collectionSavedName");
while(searchIterator.hasNext()){ 
	String strVal = (String)searchIterator.next(); 
	if(!strVal.equals(previousName)){
		if(strVal != null && strVal.length() > prefixLength && strVal.substring(0,prefixLength).equals(strNamePrefix)){%>            
			<tr class="<%= rowClass %>">
				<td style="text-align: center; ">
					<input type="radio" name="savedSearchName" id="savedSearchName" value="<%=XSSUtil.encodeForHTMLAttribute(context,strVal.substring(prefixLength))  %>" />
				</td>
				<td>
					<img src="images/iconSmallFile.gif" alt="File"/>
					<span class="object"><%=XSSUtil.encodeForHTML(context,strVal.substring(prefixLength))%></span>
				</td>
			</tr>
<%
rowClass = (rowClass == "odd") ? "even" : "odd";
		}
	}
} %>               
            </tbody>
         </table>
      </form>
      </div>
<iframe class="hidden-frame" src="emxBlank.jsp" name="searchSaveAsHidden" id="searchSaveAsHidden"></iframe>
<div id="divPageFoot">
<form name="editFooter" method="post">
<table border="0" cellspacing="0" cellpadding="0" width="100%">
<tr>
    <td class="pagination"></td>
	<td class="buttons">
    <table>
	    <tr>
        <td><a class="footericon" href="javascript:doSearch()"><img src="../common/images/buttonDialogDone.gif" border="0" alt="Done" /></a></td>
        <td><a onClick="javascript:doSearch()"><button class="btn-primary" type="button"><emxUtil:i18n localize="i18nId">emxFramework.GlobalSearch.Done</emxUtil:i18n></button></a></td>
        <td><a class="footericon" href="javascript:getTopWindow().closeWindow()"><img src="../common/images/buttonDialogCancel.gif" border="0" /></a></td>
        <td><a onClick="javascript:getTopWindow().closeWindow()"><button class="btn-default" type="button"><emxUtil:i18n localize="i18nId">emxFramework.GlobalSearch.Cancel</emxUtil:i18n></button></a></td>
		</tr>
	</table>
	</td>
</tr>
</table>
</form>          
</div>
<%@include file = "emxNavigatorBottomErrorInclude.inc"%>
</body>
</html>
