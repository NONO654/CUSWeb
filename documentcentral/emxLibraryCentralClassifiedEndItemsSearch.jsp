<%-- emxLibraryCentralClassifiedEndItemsSearch.jsp
   Copyright (c) 1992-2016 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxLibraryCentralClassifiedEndItemsSearch.jsp.rca 1.10 Wed Oct 22 16:02:43 2008 przemek Experimental przemek $
--%>

<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@ page import = "com.matrixone.apps.library.LibraryCentralConstants"%>
<%@ page import="java.util.List,java.util.Map,com.matrixone.apps.library.LibraryCentralCommon" %>
<%
HashMap allowedEndItemsMap = (HashMap)LibraryCentralCommon.getAllowedEndItemsMap(context);
HashMap allowedClassesMap = (HashMap)LibraryCentralCommon.getAllowedClassesMap(context);


    //Get requestParameters for searchContent
    StringBuffer queryString = new StringBuffer("");
    Enumeration eNumParameters = emxGetParameterNames(request);
    int paramCounter = 0;
    while( eNumParameters.hasMoreElements() ) {
        String strParamName = (String)eNumParameters.nextElement();
        String strParamValue = emxGetParameter(request, strParamName);

        //do not pass url on
        if(!"url".equals(strParamName) && !"showAdvanced".equals(strParamName)){
            if(paramCounter > 0){
                queryString.append("&");
            }
            paramCounter++;
            queryString.append(strParamName);
            queryString.append("=");
            queryString.append(strParamValue);
        }
    }


    String url = "";
    String title = "";
    String helpMarker = "";
    String helpMarkerSuiteDir = "";
    String objectId = "";
    String ChildtypeName = "";
    String showAdvanced = emxGetParameter(request, "showAdvanced");
    String defaultSearch = emxGetParameter(request, "defaultSearch");
    String searchToolbar = emxGetParameter(request, "toolbar");
    objectId = emxGetParameter(request, "objectId");

    DomainObject domObj = new DomainObject(objectId);
    String typeName = domObj.getInfo(context,"type");

    String sGeneralClass      = LibraryCentralConstants.TYPE_GENERAL_CLASS;
    String sGeneralLibrary    = LibraryCentralConstants.TYPE_GENERAL_LIBRARY;
    String sPartFamily        = LibraryCentralConstants.TYPE_PART_FAMILY;
    String sPartLibrary       = LibraryCentralConstants.TYPE_PART_LIBRARY;
    String sPart              = LibraryCentralConstants.TYPE_PART;
    String sDoc = PropertyUtil.getSchemaProperty(context,"type_GenericDocument");

if(typeName != null)
{
    //Fix IR 016955, get the title and childtypename
    String strSymType = com.matrixone.apps.domain.util.FrameworkUtil.getAliasForAdmin(context,"type",typeName,true);
    Map details = LibraryCentralCommon.getSearchWithInDetails(context, strSymType);
    if(details != null) {
        ChildtypeName = (String)details.get("childTypeName");
        title = (String)details.get("title");
    }
}

helpMarker = emxGetParameter(request, "helpMarker");

if (searchToolbar == null || searchToolbar.trim().length() == 0)
{
    searchToolbar = "LibraryEndItemsSearchToolBar";
}


try{
        ContextUtil.startTransaction(context, false);

        Vector userRoleList = PersonUtil.getAssignments(context);
        HashMap paramMap = UINavigatorUtil.getRequestParameterMap(request);
        

        // Check if the url for the search content page is present in the session variable ?
        //
        url = emxGetParameter(request, "urlSearchContentPage");
        if ( url == null || "null".equalsIgnoreCase(url) || "".equals(url) )
        {
            url = "../documentcentral/emxLibraryCentralClassifiedItemsSearch.jsp";
        }

        if (url == null || url.trim().length() == 0){
            url = "../common/emxBlank.jsp";
        }

        if(url != null && queryString.length() > 1){
            url += (url.indexOf("?") == -1 ? "?" : "&") + queryString.toString();
        }

        if(title == null || "".equals(title)){
                title = "";
        }

        if(helpMarker == null || "".equals(helpMarker)){
                helpMarker = "emxhelpsearchwithin";
                helpMarkerSuiteDir = "DocumentCentral";
        }

}catch (Exception ex){
        ContextUtil.abortTransaction(context);

        if(ex.toString() != null && (ex.toString().trim()).length()>0){
        }
}
finally{
        ContextUtil.commitTransaction(context);
}

String searchViewURL = "emxLibraryCentralClassifiedEndItemsSearchView.jsp";

if(queryString != null && queryString.length() > 1){
    searchViewURL += "?" + queryString.toString();
}

StringBuffer sbBaseQuery = new StringBuffer();
eNumParameters = emxGetParameterNames(request);
    paramCounter = 0;
    String strParamName = null;
    String strParamValue = null;
    while( eNumParameters.hasMoreElements() ) {
        strParamName = (String)eNumParameters.nextElement();
        strParamValue = emxGetParameter(request, strParamName);
        //do not pass url on
        if(!"url".equals(strParamName) && !"showAdvanced".equals(strParamName)){
            if(paramCounter > 0){
                sbBaseQuery.append("&");
            }
            paramCounter++;
            sbBaseQuery.append(strParamName);
            sbBaseQuery.append("=");
            sbBaseQuery.append(strParamValue);
        }
    }
    String pagination          = PersonUtil.getPaginationPreference(context);
    if(pagination == null || "null".equals(pagination) || "".equals(pagination)) {
            pagination  = "true";
    }
    
    String queryLimit              = EnoviaResourceBundle.getProperty(context, "emxFramework.Search.QueryLimit");
    if( (queryLimit == null) || (queryLimit.equals("null")) || (queryLimit.equals(""))) {
        queryLimit="100";
    }
    
%>
<html>
    <head>
        <title>Search</title>
        <%@include file = "../common/emxUIConstantsInclude.inc"%>
        <script language="javascript" src="../common/scripts/emxUICore.js"></script>
        <script language="javascript" src="../common/scripts/emxUIModal.js"></script>
        <script language="javascript" src="../common/scripts/emxUIPopups.js"></script>
        <script language="javascript" src="../common/scripts/emxNavigatorHelp.js"></script>
        <script language="javascript" src="../common/scripts/emxJSValidationUtil.js"></script>
        <%@ include file="../common/emxSearchConstantsInclude.inc"%>
        <script language="JavaScript" src="../common/scripts/emxUISearch.js"></script>
        <script language="JavaScript">
            try{
            pageControl.setSearchContentURL("<xss:encodeForJavaScript><%= url %></xss:encodeForJavaScript>");
            pageControl.setShowingAdvanced(<xss:encodeForJavaScript><%= showAdvanced %></xss:encodeForJavaScript>);
            pageControl.setTitle("<xss:encodeForJavaScript><%=title%></xss:encodeForJavaScript>");
            pageControl.setType("<xss:encodeForJavaScript><%= ChildtypeName %></xss:encodeForJavaScript>");
            pageControl.setHelpMarkerSuiteDir("<xss:encodeForJavaScript><%= helpMarkerSuiteDir %></xss:encodeForJavaScript>");
            pageControl.setHelpMarker("<xss:encodeForJavaScript><%= helpMarker %></xss:encodeForJavaScript>");
            pageControl.setBaseQueryString("<xss:encodeForJavaScript><%=sbBaseQuery.toString()%></xss:encodeForJavaScript>");

            }catch(Exp){}

        function newSearch() {
           <%
           StringBuffer reqParams = new StringBuffer();
           Enumeration enumReqParams = request.getParameterNames();
           while(enumReqParams.hasMoreElements()){
                String reqParamName = (String)enumReqParams.nextElement();
                String reqParamValue = request.getParameter(reqParamName);
                reqParams.append(reqParamName);
                reqParams.append("=");
                reqParams.append(XSSUtil.encodeForURL(reqParamValue));
                reqParams.append("&");
           }
           
           %>
           var strSearchProcessPage       = "../documentcentral/emxLibraryCentralClassifiedEndItemsSearchView.jsp?<xss:encodeForJavaScript><%=reqParams.toString()%></xss:encodeForJavaScript>";
           try  {

               pageControl.setSearchContentURL("<xss:encodeForJavaScript><%= url %></xss:encodeForJavaScript>");
               pageControl.setShowingAdvanced(<xss:encodeForJavaScript><%= showAdvanced %></xss:encodeForJavaScript>);
               pageControl.setTitle("<xss:encodeForJavaScript><%=title%></xss:encodeForJavaScript>");
               pageControl.setType("<xss:encodeForJavaScript><%= ChildtypeName %></xss:encodeForJavaScript>");
               pageControl.setHelpMarkerSuiteDir("<xss:encodeForJavaScript><%= helpMarkerSuiteDir %></xss:encodeForJavaScript>");
               pageControl.setHelpMarker("<xss:encodeForJavaScript><%= helpMarker %></xss:encodeForJavaScript>");
               pageControl.setBaseQueryString("<xss:encodeForJavaScript><%=sbBaseQuery.toString()%></xss:encodeForJavaScript>");
   
                 var myframe              = findFrame(getTopWindow(),"searchView");
                 pageControl.queryLimit     = <xss:encodeForJavaScript><%=queryLimit%></xss:encodeForJavaScript>;
                 pageControl.pagination     = <xss:encodeForJavaScript><%=pagination%></xss:encodeForJavaScript>;
                 searchView.location.href = strSearchProcessPage;
           } catch(Exec) {
           }
        }
        function reviseSearch(){
        	//debugger
        	    //if doSubmit use hidden content frame
        	    var searchViewFrame = null;
        	    if(pageControl.getDoSubmit()){
        	        searchViewFrame = findFrame(getTopWindow(),"searchContent");
        	    }else{
        	        searchViewFrame = findFrame(getTopWindow(),"searchView");
        	    }
        	    //querystring
        	    var querystring = escape(pageControl.getSearchContentURL());
        	    var qStr = pageControl.getSearchContentURL();
        	    qStr = qStr.substring(qStr.indexOf("title"),qStr.length);
        	    qStr = qStr.substring(0,qStr.indexOf("&"));
        	    // get searchViewUrl
        	    var searchViewUrl = "url=" +querystring+"&"+qStr;
        	    
        	     if(!searchViewFrame) {
        	        searchViewFrame = findFrame(getTopWindow(),"searchContent");
        	        searchViewUrl = pageControl.getSearchContentURL();
        	     }
        	  var baseQueryString = pageControl.getBaseQueryString();
        	    if(baseQueryString.length > 0)
        	        searchViewUrl +="&" + baseQueryString;
        	    
        	    //if hidden submit use only the
        	    if(pageControl.getDoSubmit()){
        	        searchViewUrl = pageControl.getSearchContentURL();
        	    }
        	    
        	    pageControl.setDoReload(true);
        	    //pageControl.setSavedSearchName("");

        	    //var footerFrame = findFrame(getTopWindow(), "searchFoot");
        	    //if (footerFrame) {
        	        var queryLimitObj = getTopWindow().document.getElementById("QueryLimit");
        	        if (queryLimitObj) {
        	            sQueryLimit = queryLimitObj.value;
        	            searchViewUrl += "&queryLimit=" + sQueryLimit;
        	        }
        	    //}
        	    if(searchViewFrame && !pageControl.getDoSubmit()) {
        	    var searchQueryParams = searchViewUrl.split("&");
        	    var searchViewForm = searchViewFrame.document.createElement("FORM");
        	    for(var i=0;i<searchQueryParams.length;i++){
        	    	var searchQueryParam = searchQueryParams[i];
        	    	var searchQueryParamNameValue = searchQueryParam.split("=",2);
        	    	var searchQueryParamName = searchQueryParamNameValue[0];
        	    	var searchQueryParamValue = searchQueryParamNameValue[1];
        	    	
        	    	var searchQueryParamElem = document.createElement("INPUT");
        	    	searchQueryParamElem.setAttribute("type","hidden");
        	    	searchQueryParamElem.setAttribute("name","searchQueryParamName");
        	    	searchQueryParamElem.setAttribute("value","searchQueryParamValue");
        	    	searchViewForm.appendChild(searchQueryParamElem);
        	    }
        	    searchViewForm.setAttribute("action","../documentcentral/emxLibraryCentralClassifiedEndItemsSearchView.jsp?<%=reqParams.toString()%>");
        	    searchViewForm.setAttribute("method","post");
        	    
        	    searchViewFrame.document.body.appendChild(searchViewForm);
        	    searchViewForm.submit();
        	    }else{
        	    searchViewFrame.location.href = searchViewUrl;
        	    }
        	    //NOTE add footer values
        	} 
        </script>
        <%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
    </head>
    <frameset rows="*,0" framespacing="0" frameborder="no" border="0">
        <frame src="<xss:encodeForHTML><%=searchViewURL%></xss:encodeForHTML>" name="searchView" noresize scrolling="no" marginwidth="10" marginheight="10" frameborder="no" />
        <frameset rows="*" framespacing="0" frameborder="no" border="0">
          <frame src="../common/emxBlank.jsp" name="searchHidden" id="searchHidden" frameborder="0" scrolling="no">
        </frameset>
    </frameset>
    <noframes></noframes>
</html>
