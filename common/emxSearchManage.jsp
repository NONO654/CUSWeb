<%-- emxSearchManage.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxSearchManage.jsp.rca 1.16.2.1 Fri Nov  7 09:41:38 2008 ds-kvenkanna Experimental $
--%>
<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>

<% 
//addded for BUG 327438 Begin
String CollectionName = emxGetParameter(request,"CollectionName");
if(CollectionName != null && !CollectionName.equals("")){
    session.putValue("CollectionName", CollectionName);
}
//addded for BUG 327438 End

//addded for BUG 305200
String languageStr = request.getHeader("Accept-Language");
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
  String editDisplay=FrameworkUtil.i18nStringNow("emxFramework.SavedSearch.AltMsg.EditSavedQuery",languageStr);
  String deleteDisplay=FrameworkUtil.i18nStringNow("emxFramework.SavedSearch.AltMsg.DeleteSavedQuery",languageStr);

    String upperQueryLimit = EnoviaResourceBundle.getProperty(context, "emxFramework.Search.UpperQueryLimit");
    if( (upperQueryLimit == null) || (upperQueryLimit.equals("null")) || (upperQueryLimit.equals(""))) {
        //this number must not excede 32767
        upperQueryLimit="1000";
    }
 %>

<html>
   <head>
        <title>Search Manage</title>
        <script type="text/javascript" language="JavaScript" src="scripts/emxUIConstants.js"></script>
        <script type="text/javascript" language="JavaScript" src="scripts/emxUICore.js"></script>
        <script type="text/javascript" language="JavaScript" src="scripts/emxUIModal.js"></script>
        <script type="text/javascript" language="JavaScript" src="scripts/emxUIPopups.js"></script>
        <script type="text/javascript" language="JavaScript" src="scripts/emxUICoreMenu.js"></script>
        <script type="text/javascript">
            addStyleSheet("emxUIDefault");
            addStyleSheet("emxUIList");
            addStyleSheet("emxUIMenu");
            <%--  These i18n strings must come before emxUISearchUtils.js --%>
            //i18n strings
            var ConfirmDelete = "<emxUtil:i18nScript localize="i18nId">emxFramework.GlobalSearch.ErrorMsg.ConfirmDelete</emxUtil:i18nScript> \"";
            
            function doSearch(str){
                if (!verifyQueryLimit()) {
                    return;
                }
                if(typeof str == "string"){
                setSaveName(str);
                }
                
                if(trimWhitespace(getTopWindow().pageControl.getSavedSearchName()).length==0){
                    alert(getTopWindow().STR_SEARCH_EMPTY_OPTION);
                    turnOffProgress();
                    return;
                }
        
                //set doSubmit =true
                getTopWindow().pageControl.setDoSubmit(true);
                //get saved search
                getTopWindow().importSavedSearchXML("view");
                turnOffProgress();
            }
            
      function trimWhitespace(strString) {
        if(strString == null || strString == 'undefined') {
          return '';
        } else {
          strString = strString.replace(/^[\s\u3000]*/g, "");
          return strString.replace(/[\s\u3000]+$/g, "");
        }
      }
      
      function disablesave () {
			setTimeout(function(){
				getTopWindow().setSaveFunctionality(false);
			}, 100);
		}
            
        </script>
        <script type="text/javascript" language="JavaScript" src="scripts/emxUISearchUtils.js"></script>
   </head>
   <body onload="turnOffProgress(); disablesave();">
      <form method="post" name="emxTableForm" onsubmit="doSearch(); return false">
         <table border="0" cellpadding="3" width="100%" id="tblMain" cellspacing="2" class="list">
            <thead>
               <tr>
                  <th width="5%" style="text-align:center">
                  </th>
                  <th>
                     <emxUtil:i18n localize="i18nId">emxFramework.GlobalSearch.Name</emxUtil:i18n>
                  </th>
                  <th style="text-align:center">
                     <emxUtil:i18n localize="i18nId">emxFramework.GlobalSearch.Edit</emxUtil:i18n>
                  </th>
                  <th style="text-align:center">
                     <emxUtil:i18n localize="i18nId">emxFramework.GlobalSearch.Delete</emxUtil:i18n>
                  </th>
               </tr>
            </thead>
            <tbody>
<%  
String rowClass = "odd";
int iCounter = 0;
while(searchIterator.hasNext()){ 
        String strVal = (String)searchIterator.next(); 
        if(strVal != null && (strVal.indexOf(".emx") > -1)){
            String strDisplayVal = "";
            if(strVal.indexOf(".emx") > -1){
                strDisplayVal = strVal.substring(4);
            }
                iCounter++; %>
        <script language="javascript">
          var strValue<%=iCounter%> ="<%= XSSUtil.encodeForJavaScript(context, strVal) %>";
          var strDisplayValue<%=iCounter%> ="<%= XSSUtil.encodeForJavaScript(context, strDisplayVal) %>";
        </script>                
               <tr class="<%= rowClass %>">
                  <td style="text-align: center; ">
                     <input type="radio" name="savedSearchName" id="savedSearchName" value="<%= strVal %>" onClick="setSaveName(this.value)"/>
                  </td>
                  <td>
                     <table border="0">
                        <tr>
                           <td valign="top">
                              <img src="images/iconSmallFile.gif" border="0" alt="File" />
                           </td>
                           <td>
                              <span class="object"><a href="javascript:doSearch(strValue<%=iCounter%>)"><%= strDisplayVal %></a></span>
                           </td>
                        </tr>
                     </table>
                  </td>
                  <td style="text-align: center; ">
                     <a href="javascript:doEdit(strValue<%=iCounter%>)"><img src="images/iconActionEdit.gif" alt="<%=editDisplay%>" border="0" /></a> 
                  </td>
                  <td style="text-align: center; ">
                     <a href="javascript:doDelete(strDisplayValue<%=iCounter%>,strValue<%=iCounter%>)"><img src="images/buttonChannelClose.gif" alt="<%=deleteDisplay%>" border="0" /></a> 
                  </td>
               </tr>
<%
                rowClass = (rowClass == "odd") ? "even" : "odd";
        }
} 
if(iCounter == 0){
%>
                <!-- //XSSOK -->
                <tr class="<%= rowClass %>">
                  <td style="text-align: center; " colspan="4">
                     <framework:i18n localize="i18nId">emxFramework.Commom.NoObjectsFound</framework:i18n>
                  </td>
               </tr>
<%
}
%>               
            </tbody>
         </table>
      </form>
      <iframe src="emxBlank.jsp" width="0" height="0" scrolling="no" frameborder="0" name="searchManageHidden" id="searchManageHidden"></iframe>
      <%@include file = "emxNavigatorBottomErrorInclude.inc"%>
   </body>
</html>

