<%-- emxSearch.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxSearchView.jsp.rca 1.10 Wed Oct 22 15:48:36 2008 przemek Experimental przemek $
--%>

<%@include file = "emxNavigatorInclude.inc"%>

<%@include file = "emxNavigatorTopErrorInclude.inc"%>

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

String headerURL = "emxSearchHeader.jsp";

if(queryString.length() > 1){
    headerURL += "?" + queryString.toString();
}

String toolbar = emxGetParameter(request, "toolbar");
String showToolbar = emxGetParameter(request, "showToolbar");
String objectId = null;
String relId = null;

if( (toolbar == null || toolbar.trim().length() == 0) && (!"false".equalsIgnoreCase(showToolbar)))
{
    toolbar = PropertyUtil.getSchemaProperty(context,"menu_AEFSearchToolbar");
}

//get title
String languageStr = request.getHeader("Accept-Language");
if(title != null && title.length() > 0) {
    String containedInStr = "";
    containedInStr = UINavigatorUtil.getI18nString(title,"emxFrameworkStringResource",languageStr);
    if(containedInStr != null && containedInStr.length() > 0) {
        title = containedInStr;
    }
}

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
        <title><emxUtil:i18n localize="i18nId">emxFramework.GlobalSearch.Search</emxUtil:i18n></title>
        <script language="JavaScript" src="scripts/emxUIConstants.js"></script>
        <script language="JavaScript" src="scripts/emxUICore.js"></script>
        <script language="JavaScript" src="scripts/emxUICoreMenu.js"></script>
        <script language="JavaScript" src="scripts/emxUIToolbar.js"></script>
        <script language="JavaScript" src="scripts/emxUIActionbar.js"></script>
        <script language="JavaScript" src="scripts/emxUIModal.js"></script>
        <script language="JavaScript" src="scripts/emxUIPopups.js"></script>
        <script language="JavaScript" src="scripts/emxUISearch.js"></script>
        <script language="JavaScript" src="scripts/emxUISearchUtils.js" type="text/javascript"></script>
        <script>
        var QueryLimitNumberFormat = "<emxUtil:i18nScript localize="i18nId">emxFramework.GlobalSearch.ErrorMsg.QueryLimitNumberFormat</emxUtil:i18nScript>";
        //XSSOK
        var QueryLimitMaxAllowed = "<emxUtil:i18nScript localize="i18nId">emxFramework.GlobalSearch.ErrorMsg.QueryLimitMaxAllowed</emxUtil:i18nScript> <%= upperQueryLimit %>";
        //XSSOK
        var paginationRange = "<%=paginationRange%>";
        //XSSOK
        var maxPaginationRange = "<%=maxPaginationRange%>";
        //XSSOK
        var upperQueryLimit = <%= upperQueryLimit %>;

        function trimWhitespace(strString) {
            strString = strString.replace(/^[\s\u3000]*/g, "");
            return strString.replace(/[\s\u3000]+$/g, "");
        }
        function loadContentFrame(){
        	loadHeader();
        	setFormfields();
            var searchPageURL = getTopWindow().pageControl.getSearchContentURL();
            var searchPageFrame = findFrame(this,"searchContent");
            searchPageFrame.location.href = searchPageURL;
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
                arguments[0] = getTopWindow().pageControl.helpMarker;
                getTopWindow().openHelp.apply(this, arguments);
            }

            function enablesave () {
				setTimeout(function(){
					setSaveFunctionality(true);
				}, 100);
			}
            //This method needed for Mozilla
            function beforeClearWindows(){
            	parent.ids=parent.ids=="_dummyids_"?"":parent.ids;          		
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

        <%@include file = "emxNavigatorBottomErrorInclude.inc"%>
    </head>
    <body onunload="clearWindows();" onload="loadContentFrame();" onbeforeunload="beforeClearWindows();">
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
			<jsp:include page = "emxToolbar.jsp" flush="true">
			    <jsp:param name="toolbar" value="<%=XSSUtil.encodeForURL(context, toolbar)%>"/>
			    <jsp:param name="objectId" value="<%=objectId%>"/>
			    <jsp:param name="relId" value="<%=relId%>"/>
			    <jsp:param name="export" value="false"/>
			    <jsp:param name="PrinterFriendly" value="false"/>
			</jsp:include>
		</div>
		<div id="divPageBody">
          		<iframe name="searchContent" src="emxBlank.jsp" width="100%" height="100%"  frameborder="0" border="0"></iframe>
		</div>
        <div id="divPageFoot">
			<form name="searchFooterForm" action="" method="post" >
			      <table>
			        <tr>
			          <td class="functions">
			            <table border="0">
			              <tr>
			                <td><emxUtil:i18n localize="i18nId">emxFramework.GlobalSearch.LimitTo</emxUtil:i18n></td>
			                <td><input type="text" name= "QueryLimit" id="QueryLimit" value="<%= queryLimit %>" size="5"/>
			                </td>
			                <td><emxUtil:i18n localize="i18nId">emxFramework.GlobalSearch.Results</emxUtil:i18n></td>
			                <td><input type="checkbox" name="pagination" id="pagination" value="<%=paginationRange%>" <%= ("true".equals(pagination))?"checked":"" %>/>
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
		</div>
    </body>
</html>
