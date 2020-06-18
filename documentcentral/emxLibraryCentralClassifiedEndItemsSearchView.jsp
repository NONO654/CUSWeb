<%-- emxLibraryCentralClassifiedEndItemsSearchView.jsp
   Copyright (c) 1992-2016 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxLibraryCentralClassifiedEndItemsSearchView.jsp.rca 1.4 Wed Oct 22 16:02:32 2008 przemek Experimental przemek $
--%>

<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@page import = "com.matrixone.apps.classification.Classification"%>
<%@page import = "com.matrixone.apps.domain.DomainObject"%>
<%@page import ="com.matrixone.apps.domain.DomainConstants"%>
<%@page import ="com.matrixone.apps.common.Person"%>
<%@page import = "com.matrixone.apps.domain.util.FrameworkUtil"%>
<%@page import = "com.matrixone.apps.library.LibraryCentralConstants"%>
<%@page import="java.util.HashMap"%>
<%@page import ="com.matrixone.apps.domain.util.MapList"%>
<%@page import = "matrix.db.BusinessObject"%>
<%@page import = "matrix.util.StringList"%>
<%

    String objectId = null;
    String relId = null;

    objectId = emxGetParameter(request, "objectId");


    String defaultRDO = null;
    String userDefaultRDO = Person.getDesignResponsibilityInSearch(context);
    defaultRDO = userDefaultRDO;

//get title
//String title = emxGetParameter(request, "title");

String languageStr = request.getHeader("Accept-Language");

%>

<%
//Get requestParameters for searchContent
StringBuffer queryString = new StringBuffer("");

    Enumeration eNumParameters = emxGetParameterNames(request);
    int paramCounter = 0;
    while( eNumParameters.hasMoreElements() ) {
        String strParamName = (String)eNumParameters.nextElement();
        String strParamValue = emxGetParameter(request, strParamName);

        //do not pass showAdvanced or url on
        if(!"url".equals(strParamName)){
            if(paramCounter > 0){
                queryString.append("&");
            }
            paramCounter++;
            queryString.append(strParamName);
            queryString.append("=");
            queryString.append(strParamValue);
        }
    }

String title = emxGetParameter(request, "title");


String toolbar      = emxGetParameter(request, "toolbar");
String showToolbar  = emxGetParameter(request, "showToolbar");
if( (toolbar == null || toolbar.trim().length() == 0) && (!"false".equalsIgnoreCase(showToolbar)))
{
    toolbar         = PropertyUtil.getSchemaProperty(context,"menu_AEFSearchToolbar");
}
//get title
if(title != null && title.length() > 0) {
    String containedInStr   = "";
    containedInStr          = EnoviaResourceBundle.getProperty(context,"emxFrameworkStringResource",new Locale(languageStr),title);
    if(containedInStr != null && containedInStr.length() > 0) {
        title               = containedInStr;
    }
}

String pagination           = "";
String paginationRange      = "";
String maxPaginationRange   = "";
String queryLimit           = "";
String upperQueryLimit      = "";

try{
        ContextUtil.startTransaction(context, false);
        pagination          = PersonUtil.getPaginationPreference(context);
        if(pagination == null || "null".equals(pagination) || "".equals(pagination)) {
                pagination  = "true";
        }
        paginationRange     = PersonUtil.getPaginationRangePreference(context);
        if( (paginationRange == null) || (paginationRange.equals("null")) || (paginationRange.equals(""))) {
            paginationRange = EnoviaResourceBundle.getProperty(context, "emxFramework.PaginationRange");
            if( (paginationRange == null) || (paginationRange.equals("null")) || (paginationRange.equals(""))) {
                paginationRange = "10";
            }
        }

        maxPaginationRange = EnoviaResourceBundle.getProperty(context, "emxFramework.Pagination.MaxNumberOfItems");
        if((maxPaginationRange == null) || (maxPaginationRange.equals("null")) || (maxPaginationRange.equals(""))){
            maxPaginationRange  = "0";
        }
        queryLimit              = EnoviaResourceBundle.getProperty(context, "emxFramework.Search.QueryLimit");
        if( (queryLimit == null) || (queryLimit.equals("null")) || (queryLimit.equals(""))) {
            queryLimit="100";
        }

        upperQueryLimit         = EnoviaResourceBundle.getProperty(context, "emxFramework.Search.UpperQueryLimit");
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
        <title><emxUtil:i18n localize="i18nId">emxFramework.GlobalSearch.Search</emxUtil:i18n></title>
        <script language="JavaScript" src="../common/scripts/emxUIConstants.js"></script>
        <script language="JavaScript" src="../common/scripts/emxUICore.js"></script>
        <script language="JavaScript" src="../common/scripts/emxUICoreMenu.js"></script>
        <script language="JavaScript" src="../common/scripts/emxUIToolbar.js"></script>
        <script language="JavaScript" src="../common/scripts/emxUIActionbar.js"></script>
        <script language="JavaScript" src="../common/scripts/emxUIModal.js"></script>
        <script language="JavaScript" src="../common/scripts/emxUIPopups.js"></script>
        <script language="JavaScript" src="../common/scripts/emxUISearch.js"></script>
        <script language="JavaScript" src="../common/scripts/emxUISearchUtils.js" type="text/javascript"></script>

        <script>

        var QueryLimitNumberFormat  = "<emxUtil:i18nScript localize="i18nId">emxFramework.GlobalSearch.ErrorMsg.QueryLimitNumberFormat</emxUtil:i18nScript>";
        var QueryLimitMaxAllowed    = "<emxUtil:i18nScript localize="i18nId">emxFramework.GlobalSearch.ErrorMsg.QueryLimitMaxAllowed</emxUtil:i18nScript> <xss:encodeForJavaScript><%= upperQueryLimit %></xss:encodeForJavaScript>";
        var paginationRange         = "<xss:encodeForJavaScript><%=paginationRange%></xss:encodeForJavaScript>";
        var maxPaginationRange      = "<xss:encodeForJavaScript><%=maxPaginationRange%></xss:encodeForJavaScript>";
        var upperQueryLimit         = <xss:encodeForJavaScript><%= upperQueryLimit %></xss:encodeForJavaScript>;

        function trimWhitespace(strString) {
            strString               = strString.replace(/^[\s\u3000]*/g, "");
            return strString.replace(/[\s\u3000]+$/g, "");
        }


        function loadContentFrame(RDOval){
            loadHeader();
            setFormfields();
            var RDOvalue;
            if(RDOval == null){
            RDOvalue = "<xss:encodeForJavaScript><%=defaultRDO%></xss:encodeForJavaScript>";
            }
            else{
            RDOvalue = RDOval;
            }
            var searchPageURL           = getTopWindow().pageControl.getSearchContentURL();
            var searchPageURLwithRDO    = searchPageURL + "&RDO="+RDOvalue;
            var searchPageFrame         = findFrame(this,"searchContent");
            searchPageFrame.location.href = searchPageURLwithRDO;
            turnOffProgress();
        }
        function clearWindows(){
            getTopWindow().pageControl.clearChildWindows();
        }
        </script>

        <script type="text/javascript">
            addStyleSheet("emxUIDefault");
            addStyleSheet("emxUIDOMLayout");
            addStyleSheet("emxUIToolbar");
            addStyleSheet("emxUIDialog");
            //overide openHelp
            function openHelp(){
                getTopWindow().pageControl.openHelp(arguments);
            }

            function enablesave () {
                setTimeout(function(){
                    setSaveFunctionality(true);
                }, 1000);
            }

            function loadHeader(){
<%
                if(title == null || "null".equals(title) || "".equals(title)) {
%>
                //set window Title
                getTopWindow().pageControl.setWindowTitle();
<%
                }else {
%>
                    getTopWindow().pageControl.setWindowTitle("<xss:encodeForJavaScript><%=title%></xss:encodeForJavaScript>");
<%
                }

                //set window Title
                if(title == null || "null".equals(title) || "".equals(title)) {
%>
                    getTopWindow().pageControl.setPageHeaderText();
<%
                }else {
%>
                    getTopWindow().pageControl.setPageHeaderText("<xss:encodeForJavaScript><%=title%></xss:encodeForJavaScript>");
<%
                }
%>
                enablesave();
                }
        </script>
      <%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
    </head>

        <body onunload="clearWindows();" onload="loadContentFrame();">
        <div id="pageHeadDiv">
               <table>
                 <tr>
                <td class="page-title">
                  <h2><emxUtil:i18n localize="i18nId">emxFramework.GlobalSearch.Search</emxUtil:i18n></h2>
                </td>
                    <td class="functions">
                        <table><tr>
                                <td class="progress-indicator"><div id="imgProgressDiv"></div></td>
                        </tr></table>
                    </td>
                    </tr>
                    </table>
            <jsp:include page = "../common/emxToolbar.jsp" flush="true">
                <jsp:param name="toolbar" value="<xss:encodeForHTML><%=toolbar%></xss:encodeForHTML>"/>
                <jsp:param name="objectId" value="<xss:encodeForHTML><%=objectId%></xss:encodeForHTML>"/>
                <jsp:param name="relId" value="<xss:encodeForHTML><%=relId%></xss:encodeForHTML>"/>
                <jsp:param name="export" value="false"/>
                <jsp:param name="PrinterFriendly" value="false"/>
            </jsp:include>
        </div>
        <div id="divPageBody">
                <iframe name="searchContent" src="../common/emxBlank.jsp" width="100%" height="100%"  frameborder="0" border="0"></iframe>
        </div>
        <div id="divPageFoot">
            <form name="searchFooterForm" action="" method="post" >
                  <table>
                    <tr>
                      <td class="functions">
                        <table border="0">
                          <tr>
                            <td><input type="hidden" name="QueryLimit" id="QueryLimit" size="5" value="<xss:encodeForHTMLAttribute><%= queryLimit %></xss:encodeForHTMLAttribute>" />
                            </td>
                            <td><input type="hidden" name="pagination" id="pagination" value="<xss:encodeForHTML><%=paginationRange%></xss:encodeForHTML>" <xss:encodeForHTML><%= ("true".equals(pagination))?"checked":"" %></xss:encodeForHTML>>
                            </td>
                          </tr>
                        </table>
                      </td>
                      <td class="buttons">
                        <table>
                          <tr>
                            <td><a class="footericon" href="javascript:doFind()"><img border="0" alt="<emxUtil:i18n localize="i18nId">emxFramework.GlobalSearch.Search</emxUtil:i18n>" src="../common/images/buttonDialogNext.gif"></a></td>
                            <td nowrap><a onClick="javascript:doFind()" class="button"><button class="btn-primary" type="button"><emxUtil:i18n localize="i18nId">emxFramework.GlobalSearch.Search</emxUtil:i18n></button></a></td>
                            <td><a class="footericon" href="javascript:getTopWindow().closeWindow()"><img border="0" alt="<emxUtil:i18n localize="i18nId">emxFramework.Button.Cancel</emxUtil:i18n>" src="../common/images/buttonDialogCancel.gif"></a></td>
                            <td nowrap><a class="button" onClick="javascript:getTopWindow().closeWindow()"><button class="default" type="button"><emxUtil:i18n localize="i18nId">emxFramework.Button.Cancel</emxUtil:i18n></button></a></td>
                          </tr>
                        </table>
                      </td>
                    </tr>
                  </table>
              </form>
        </div>
    </body>
 </html>
