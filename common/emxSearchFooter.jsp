<%-- emxSearchFooter.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxSearchFooter.jsp.rca 1.25 Wed Oct 22 15:48:25 2008 przemek Experimental przemek $
--%>

<%@include file = "emxNavigatorInclude.inc"%>

<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<%
String pagination = "";
String paginationRange = "";
String maxPaginationRange = "";
String queryLimit = "";
String upperQueryLimit = "";

try{
        ContextUtil.startTransaction(context, false);
        pagination = PersonUtil.getPaginationPreference(context);
        if(pagination == null || "null".equals(pagination) || "".equals(pagination)) {
                pagination = "true";
        }

        paginationRange = PersonUtil.getPaginationRangePreference(context);
        if( (paginationRange == null) || (paginationRange.equals("null")) || (paginationRange.equals(""))) {
            paginationRange=EnoviaResourceBundle.getProperty(context, "emxFramework.PaginationRange");
            if( (paginationRange == null) || (paginationRange.equals("null")) || (paginationRange.equals(""))) {
                paginationRange="10";
            }
        }

        maxPaginationRange = EnoviaResourceBundle.getProperty(context, "emxFramework.Pagination.MaxNumberOfItems");
        if((maxPaginationRange == null) || (maxPaginationRange.equals("null")) || (maxPaginationRange.equals("")))
        {
            maxPaginationRange = "0";
        }

        queryLimit = EnoviaResourceBundle.getProperty(context, "emxFramework.Search.QueryLimit");
        if( (queryLimit == null) || (queryLimit.equals("null")) || (queryLimit.equals(""))) {
            queryLimit="100";
        }

        upperQueryLimit = EnoviaResourceBundle.getProperty(context, "emxFramework.Search.UpperQueryLimit");
        if( (upperQueryLimit == null) || (upperQueryLimit.equals("null")) || (upperQueryLimit.equals(""))) {
            //this number must not excede 32767
            upperQueryLimit="1000";
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
        <title>Search Footer</title>
        <script type="text/javascript" language="JavaScript" src="scripts/emxUICore.js"></script>
        <script type="text/javascript" language="JavaScript" src="scripts/emxUIConstants.js"></script>
        <script type="text/javascript" language="JavaScript" src="scripts/emxUIModal.js"></script>
        <script type="text/javascript" language="JavaScript" src="scripts/emxUIPopups.js"></script>
        <script type="text/javascript" language="JavaScript">
            addStyleSheet("emxUIDefault");
            addStyleSheet("emxUISearch");
            addStyleSheet("emxUIDialog");
        <%-- These i18n strings must come before emxUISearchUtils.js --%>

            //i18n strings
            var QueryLimitNumberFormat = "<emxUtil:i18nScript localize="i18nId">emxFramework.GlobalSearch.ErrorMsg.QueryLimitNumberFormat</emxUtil:i18nScript>";
            //XSSOK
            var QueryLimitMaxAllowed = "<emxUtil:i18nScript localize="i18nId">emxFramework.GlobalSearch.ErrorMsg.QueryLimitMaxAllowed</emxUtil:i18nScript> <%= upperQueryLimit %>";
            //XSSOK
            var paginationRange = "<%=paginationRange%>";
            //XSSOK
            var maxPaginationRange = "<%=maxPaginationRange%>";
            //XSSOK
            var upperQueryLimit = <%= upperQueryLimit %>;


            function doDone() {
                turnOnProgress("utilProgressBlue.gif");
                setTimeout("getTopWindow().closeWindow()", 500);
            }


            function trimWhitespace(strString) {
                strString = strString.replace(/^[\s\u3000]*/g, "");
                return strString.replace(/[\s\u3000]+$/g, "");
            }
        </script>
        <script language="JavaScript" src="scripts/emxUISearchUtils.js" type="text/javascript"></script>
    </head>
    <body class="foot dialog" onload="setFormfields();">
    <form action="" name="searchFooterForm" method="post" onsubmit="doFind(); return false">
      <table>
        <tr>
          <td class="functions">
            <table border="0">
              <tr>
                <td><emxUtil:i18n localize="i18nId">emxFramework.GlobalSearch.LimitTo</emxUtil:i18n></td>
                <td><input type="text" name= "QueryLimit" id="QueryLimit" value="<%= queryLimit %>" size="5" />
                </td>
                <td><emxUtil:i18n localize="i18nId">emxFramework.GlobalSearch.Results</emxUtil:i18n></td>
                <td><input type="checkbox" name="pagination" id="pagination" value="<%=paginationRange%>" <%= ("true".equals(pagination))?"checked":"" %> />
                </td>
                <td><emxUtil:i18n localize="i18nId">emxFramework.GlobalSearch.PaginateResults</emxUtil:i18n></td>
              </tr>
            </table>
          </td>
          <td class="buttons">
            <table>
              <tr>
                <td><a class="footericon" href="javascript:doFind()"><img border="0" alt="<emxUtil:i18n localize="i18nId">emxFramework.GlobalSearch.Search</emxUtil:i18n>" src="images/buttonDialogNext.gif" /></a></td>
                <td nowrap><a onClick="javascript:doFind()" class="button"><button class="btn-primary" type="button"><emxUtil:i18n localize="i18nId">emxFramework.GlobalSearch.Search</emxUtil:i18n></button></a></td>
                <td><a class="footericon" href="javascript:getTopWindow().closeWindow()"><img border="0" alt="<emxUtil:i18n localize="i18nId">emxFramework.Button.Cancel</emxUtil:i18n>" src="images/buttonDialogCancel.gif" /></a></td>
                <td nowrap><a class="button" onClick="javascript:getTopWindow().closeWindow()"><button class="btn-default" type="button"><emxUtil:i18n localize="i18nId">emxFramework.Button.Cancel</emxUtil:i18n></button></a></td>
              </tr>
            </table>
          </td>
        </tr>
      </table>
    </form>
    <%@include file = "emxNavigatorBottomErrorInclude.inc"%>
    </body>
</html>
